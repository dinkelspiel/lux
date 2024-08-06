import gleam/list
import gleam/string
import lux/split_languages

pub type Token {
  ArrowRight
  Id(String)
  Equals
  String(String)
  ArrowLeft
  Slash
  Code(String)
}

pub fn languages_to_tokens(
  languages: List(split_languages.Language),
) -> List(Token) {
  languages
  |> list.flat_map(tokenize_language)
}

pub fn tokenize_language(language: split_languages.Language) -> List(Token) {
  case language {
    split_languages.Gleam(code) -> [Code(code)]
    split_languages.Lux(code) -> tokenize_lux(code, "", [])
  }
}

pub fn tokenize_lux(
  lux: String,
  current_token: String,
  tokens: List(Token),
) -> List(Token) {
  let current_char = case string.first(lux) {
    Ok(char) -> char
    Error(_) -> ""
  }

  case current_char {
    "<" ->
      tokenize_lux(
        string.drop_left(lux, 1),
        "",
        list.append(tokens, add_prev_id_if_exists(current_token, [ArrowLeft])),
      )
    ">" ->
      tokenize_lux(
        string.drop_left(lux, 1),
        "",
        list.append(tokens, add_prev_id_if_exists(current_token, [ArrowRight])),
      )
    "=" ->
      tokenize_lux(
        string.drop_left(lux, 1),
        "",
        list.append(tokens, add_prev_id_if_exists(current_token, [Equals])),
      )
    "/" ->
      tokenize_lux(
        string.drop_left(lux, 1),
        "",
        list.append(tokens, add_prev_id_if_exists(current_token, [Slash])),
      )
    " " ->
      case current_token {
        "" ->
          tokenize_lux(
            string.drop_left(lux, 1),
            current_token <> current_char,
            tokens,
          )
        _ ->
          tokenize_lux(
            string.drop_left(lux, 1),
            "",
            list.append(tokens, add_prev_id_if_exists(current_token, [])),
          )
      }
    "" -> add_prev_id_if_exists(current_token, tokens)
    _ ->
      tokenize_lux(
        string.drop_left(lux, 1),
        current_token <> current_char,
        tokens,
      )
  }
}

fn add_prev_id_if_exists(
  current_token: String,
  new_tokens: List(Token),
) -> List(Token) {
  list.append(
    case
      string.replace(current_token, " ", "")
      |> string.replace("\n", "")
    {
      "" -> []
      _ -> [Id(current_token)]
    },
    new_tokens,
  )
}
