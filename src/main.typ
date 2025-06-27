#import "@preview/touying:0.6.1": *
#import themes.university: * // Using university theme
#import "@preview/cetz:0.3.2"
#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import cosmos.clouds: *
#import "@preview/simpleplot:0.1.1": * // Import simpleplot once

#show: show-theorion // This show rule is for theorion, so keep it.

// --- Theme Configuration (Apply only once) ---
// The main theme for the presentation should be set once at the beginning.
#show: university-theme.with(
  aspect-ratio: sys.inputs.at("aspect-ratio", default: "16-9"),
  align: horizon,
  config-common(handout: sys.inputs.at("handout", default: "false") == "true"),
  config-common(frozen-counters: (theorem-counter,)),
  config-info(
    title: [Exploración de modelos Transformers y su Interpretabilidad
      Mecanicista],
    subtitle: [Proyecto de investigación, parte 1],
    author: [Sergio Antonio Hernández Peralta, Juan Emmanuel Cuéllar Lugo, \
      Julia López Diego, Nathael Ramos Cabrera],
    logo: box(image("Logo_de_la_UAM_no_emblema.svg", width: 36pt)),
  ),
  footer-a: [Sergio, Juan, Julia, Nathael],
)

// --- General Settings ---
#set text(lang: "es")
#set text(font: "New Computer Modern")
#set heading(numbering: numbly("{1}.", default: "1.1"))

// --- Custom Definitions ---
#let palette = (
  "q": rgb("e6b800"),
  "k": blue,
  "v": red,
  "out": gray.darken(30%),
)
#let innerproduct(x, y) = $lr(angle.l #x, #y angle.r)$

#let sae-neuron-color = rgb("4a90e2")
#let transparent = black.transparentize(100%)
#let edge-corner-radius = 0.4cm
#let node-corner-radius = 10pt

#let blob(pos, label, tint: white, hidden: false, ..args) = node(
  pos,
  align(
    center,
    if hidden { text(fill: black.transparentize(100%), label) } else { label },
  ),
  width: 175pt,
  fill: if hidden { transparent } else { tint.lighten(60%) },
  stroke: if hidden { transparent } else { 1pt + tint.darken(20%) },
  corner-radius: 10pt,
  ..args,
)

#let plusnode(pos, ..args) = node(pos, $ plus.circle $, inset: -5pt, ..args)

#let edge-hidden(hidden: false, ..args) = {
  let named = args.named()
  if hidden {
    named.insert("stroke", transparent)
  }
  edge(..args.pos(), ..named)
}

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)


// --- Presentation Content ---

#title-slide()

== Índice <touying:hidden>

#components.adaptive-columns(
  outline(
    title: none,
    indent: 1em,
    depth: 1,
  ),
)

= Introducción

== Resumen

= Pruebas de Loss

== Curva de Pérdida Simulada

Este gráfico muestra una curva de pérdida simulada a lo largo de 20 iteraciones, con una tendencia general descendente y ligeras oscilaciones.

#let points = {
  let i = 1
  let data = () // Initialize an empty tuple to store points
  while i <= 20 {
    let y = 1.0 / i + 0.05 * calc.sin(i)
    data = data + ((i, y),) // Append the point (i, y) to the tuple
    i = i + 1
  }
  data // Return the tuple of points
}

#simpleplot(
  xsize: 400pt,
  ysize: 250pt,
  alignment: center + horizon,
  axis-style: "scientific",
  {
    add(points)
  },
)


= Conclusión

== Conclusión

- Estudiamos los transformers y su interpretabilidad mecanicista #pause

- Nuestro proyecto busca entender los mecanismos internos de Llama 3.2 1B #pause
  - Usando aprendizaje de diccionario
  - Enfocándonos en el perceptrón multicapa intermedio #pause

- Próximos pasos:
  - Completar el entrenamiento del autoencoder disperso
  - Analizar los resultados
  - Documentar los hallazgos
