import gleam/io
import gleam/result
import gleeunit
import lux
import simplifile

pub fn main() {
  gleeunit.main()
}

pub fn hello_world_test() {
  simplifile.read("./test/test1/hello.lux")
  |> result.unwrap("")
  |> lux.lux_to_gleam
  |> io.debug
}
