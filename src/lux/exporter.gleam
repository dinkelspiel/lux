import gleam/list
import gleam/string
import lux/parser.{type AST, Data, Gleam, Tag}

pub fn export(ast: List(AST), output: String) -> String {
  case ast {
    [Gleam(code), ..rest] -> export(rest, output <> code)
    [Data(value), ..rest] ->
      export(rest, output <> "element.text(\"" <> value <> "\")")
    [Tag(name, attributes, children), ..rest] ->
      export(
        rest,
        output
          <> export_tag(
          Tag(name, attributes, children),
          is_next_in_ast_tag(rest),
        ),
      )
    [] -> output
  }
}

fn is_next_in_ast_tag(ast: List(AST)) -> Bool {
  case list.first(ast) {
    Ok(tok) ->
      case tok {
        Tag(..) -> True
        _ -> False
      }
    _ -> False
  }
}

pub fn export_tag(tag: AST, are_more_tags: Bool) -> String {
  case tag {
    Tag(name, attributes, children) ->
      "html."
      <> name
      <> "("
      <> export_attributes(attributes)
      <> ", ["
      <> export(children, "")
      <> "])"
      <> case are_more_tags {
        True -> ", "
        False -> ""
      }
    _ -> panic as "Invalid ast passed to export_tag"
  }
}

fn export_attributes(attributes: List(#(String, AST))) -> String {
  "["
  <> list.map(attributes, fn(attrib) {
    "attribute." <> attrib.0 <> "(" <> ast_to_string(attrib.1) <> ")"
  })
  |> string.join(", ")
  <> "]"
}

fn ast_to_string(ast: AST) -> String {
  case ast {
    Gleam(code) -> code
    Data(value) -> "element.text(\"" <> value <> "\")"
    _ -> export_tag(ast, False)
  }
}
