# lux

A slightly cursed transpiler for JSX-like syntax to Lustre in Gleam

> [!CAUTION]
> This project is a superset of Gleam and no tooling made
> for the Gleam Programming language should be expected to
> work with a codebase utilising Lux.
> This project is also not affiliated with Gleam or Lustre, any
> issues related to the html syntax should be reported here in
> the lux repository.

## How it works

It takes this lux code from the 01-hello-world lustre example

```
let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

let app = lustre.element((<div style={styles}>
    <h1>Hello, world.</h1>
    <h2>Welcome to Lustre.</h2>
  </div>))
```

and turns it into lustre

```
let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]

let app =
  lustre.element(
    html.div([attribute.style(styles)], [
      html.h1([], [element.text("Hello, world.")]),
      html.h2([], [element.text("Welcome to Lustre.")]),
    ]),
  )
```

## Usage

Currently running `gleam run` in the project will transpile any lux files in or below the project directory with a **.lux** extension to a **.lux.gleam** with the transpiled gleam code.
