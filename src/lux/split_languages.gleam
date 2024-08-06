import gleam/list
import gleam/string

pub type Language {
  Gleam(String)
  Lux(String)
}

pub fn detect_language_gleam(
  document: String,
  current_token: String,
  tokens: List(Language),
  inside_lux: Bool,
) -> List(Language) {
  let current_char = case string.first(document) {
    Ok(first_char) -> first_char
    Error(_) -> ""
  }

  let peek = case string.first(string.drop_left(document, 1)) {
    Ok(first_char) -> first_char
    Error(_) -> ""
  }

  case count_braces(current_token, 0, False) {
    val if val < 0 ->
      detect_language_lux(
        document,
        "",
        list.append(tokens, [
          Gleam(
            string.drop_right(current_token, case inside_lux {
              True -> 1
              False -> 0
            }),
          ),
        ]),
      )
    _ ->
      case current_char {
        "" if current_token != "" -> list.append(tokens, [Gleam(current_token)])
        "" -> tokens
        _ ->
          case peek {
            "<" if current_char == "(" ->
              detect_language_lux(
                string.drop_left(document, 1),
                "",
                list.append(tokens, [Gleam(current_token)]),
              )
            _ ->
              detect_language_gleam(
                string.drop_left(document, 1),
                current_token <> current_char,
                tokens,
                inside_lux,
              )
          }
      }
  }
}

pub fn detect_language_lux(
  document: String,
  current_token: String,
  tokens: List(Language),
) -> List(Language) {
  let current_char = case string.first(document) {
    Ok(first_char) -> first_char
    Error(_) -> ""
  }

  let peek = case string.first(string.drop_left(document, 1)) {
    Ok(first_char) -> first_char
    Error(_) -> ""
  }

  case current_char {
    "" if current_token != "" -> list.append(tokens, [Lux(current_token)])
    "" -> tokens
    "{" ->
      detect_language_gleam(
        string.drop_left(document, 1),
        "",
        list.append(tokens, [Lux(current_token)]),
        True,
      )
    _ ->
      case peek {
        ")" if current_char == ">" ->
          detect_language_gleam(
            string.drop_left(document, 2),
            "",
            list.append(tokens, [Lux(current_token <> ">")]),
            False,
          )
        _ ->
          detect_language_lux(
            string.drop_left(document, 1),
            current_token <> current_char,
            tokens,
          )
      }
  }
}

fn count_braces(document: String, count: Int, is_string: Bool) -> Int {
  let current_char = case string.first(document) {
    Ok(first_char) -> first_char
    Error(_) -> ""
  }

  case current_char {
    "" -> count
    "\"" -> count_braces(string.drop_left(document, 1), count, !is_string)
    "{" if !is_string ->
      count_braces(string.drop_left(document, 1), count + 1, is_string)
    "}" if !is_string ->
      count_braces(string.drop_left(document, 1), count - 1, is_string)
    _ -> count_braces(string.drop_left(document, 1), count, is_string)
  }
}
