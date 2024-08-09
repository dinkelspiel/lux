import gleam/list
import lux/tokenizer.{ArrowLeft, ArrowRight, Code, Equals, Id, Slash, String}

pub type AST {
  Gleam(String)
  Tag(name: String, attributes: List(#(String, AST)), children: List(AST))
  Data(String)
}

pub fn parse_data(
  tokens: List(tokenizer.Token),
  ast: List(AST),
  name: String,
) -> Result(#(List(tokenizer.Token), List(AST)), String) {
  case tokens {
    [ArrowLeft, Slash, Id(name2), ArrowRight, ..final_rest] if name == name2 ->
      Ok(#(final_rest, ast))
    [ArrowLeft, ..rest] ->
      case parse_tag(rest) {
        Ok(#(new_tokens, tag)) ->
          parse_data(new_tokens, list.append(ast, [tag]), name)
        Error(error) -> Error(error)
      }
    [Code(code), ..rest] ->
      parse_data(rest, list.append(ast, [Gleam(code)]), name)
    [Id(_), ..] -> {
      let #(rest, acc) = add_ids(tokens, "")
      parse_data(rest, list.append(ast, [Data(acc)]), name)
    }
    [] -> Ok(#([], ast))
    _ -> Error("Error in parsing data")
  }
}

fn add_ids(tokens: List(tokenizer.Token), acc: String) {
  let spacer = case acc {
    "" -> ""
    _ -> " "
  }

  case tokens {
    [Id(value), ..rest] -> add_ids(rest, acc <> spacer <> value)
    _ -> #(tokens, acc)
  }
}

fn parse_tag(
  tokens: List(tokenizer.Token),
) -> Result(#(List(tokenizer.Token), AST), String) {
  case tokens {
    [Id(name), ..rest] -> {
      case parse_tag_attributes(rest, []) {
        Ok(#(attrib_tokens, attributes)) ->
          case parse_data(attrib_tokens, [], name) {
            Ok(#(data_tokens, data_ast)) ->
              Ok(#(
                data_tokens,
                Tag(name: name, attributes: attributes, children: data_ast),
              ))
            Error(error) -> Error(error)
          }
        Error(error) -> Error(error)
      }
    }
    _ -> Error("First token in tag must be an Id")
  }
}

fn parse_tag_attributes(
  tokens: List(tokenizer.Token),
  attributes: List(#(String, AST)),
) -> Result(#(List(tokenizer.Token), List(#(String, AST))), String) {
  case tokens {
    [Id(key), Equals, value, ..rest] ->
      case value {
        Code(code) ->
          parse_tag_attributes(
            rest,
            list.append(attributes, [#(key, Gleam(code))]),
          )
        String(string) ->
          parse_tag_attributes(
            rest,
            list.append(attributes, [#(key, Data(string))]),
          )
        _ -> Error("Invalid value for attribute must be String or Gleam")
      }
    [ArrowRight, ..rest] -> Ok(#(rest, attributes))
    _ -> Error("Invalid next token in tag")
  }
}
