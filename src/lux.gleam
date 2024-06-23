import gleam/io
import gleam/list
import gleam/string
import lux/exporter
import lux/parser
import lux/split_languages
import lux/tokenizer
import simplifile

pub fn lux_to_gleam(document: String) {
  case
    split_languages.detect_language_gleam(document, "", [], False)
    |> list.map(io.debug)
    |> tokenizer.languages_to_tokens
    // |> list.map(io.debug)
    |> parser.parse_data([], "")
  {
    Ok(#(_, ast)) -> ast
    Error(error) -> panic(error)
  }
  |> exporter.export("")
}

pub fn main() {
  case simplifile.get_files(".") {
    Ok(files) -> files
    Error(_) -> panic as "Couldn't read files"
  }
  |> list.filter(ends_in_lux)
  |> list.map(fn(filepath) { #(filepath, simplifile.read(filepath)) })
  |> list.map(fn(file) {
    case file {
      #(filepath, Ok(content)) -> #(filepath, content)
      #(_, Error(_)) -> panic as "Failed to read file"
    }
  })
  |> list.map(fn(file) {
    #(strip_file_extension(file.0) <> ".gleam", lux_to_gleam(file.1))
  })
  |> list.map(fn(file) {
    io.debug("Writing " <> file.0 <> "...")
    simplifile.write(file.0, file.1)
  })
}

fn ends_in_lux(value: String) {
  case
    string.split(value, ".")
    |> list.last
  {
    Ok(end) if end == "lux" -> True
    Error(_) | _ -> False
  }
}

fn strip_file_extension(value: String) {
  string.split(value, ".")
  |> list.take(
    {
      string.split(value, ".")
      |> list.length
    }
    - 1,
  )
  |> string.join(".")
}
