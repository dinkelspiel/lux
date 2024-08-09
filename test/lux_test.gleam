import gleam/result
import gleam/string
import gleeunit
import gleeunit/should
import lux
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn lux_to_gleam_test() {
  simplifile.read("./test/example.lux")
  |> result.unwrap("")
  |> lux.lux_to_gleam
  |> string.length
  |> fn(len) {
    case len {
      0 -> False
      _ -> True
    }
  }
  |> should.be_true
}
