import gleam/io
import gleam/list
import gleam/result
import gleeunit
import gleeunit/should
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
  // |> should.equal([])
}
