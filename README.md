# lux

A slightly cursed transpiler for JSX-like syntax to Lustre in Gleam

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
