
// --- Importaciones ---
// Se mantienen tus importaciones originales
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2" // caja fundamental para creaer formas
#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *

#import cosmos.clouds: *
#import "@preview/simpleplot:0.1.1": *

// --- Reglas 'show' y Configuración del Tema ---
// Primero se configura el tema y luego se aplica la regla de Theorion
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
#show: show-theorion // Se aplica después del tema

// --- Configuraciones Generales ---
#set text(lang: "es")
#set text(font: "New Computer Modern")
#set heading(numbering: numbly("{1}.", default: "1.1"))

// --- Definiciones Personalizadas ---
// Se mantienen tus definiciones personalizadas
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
  align(center, if hidden { text(fill: black.transparentize(100%), label) } else { label }),
  width: 175pt,
  fill: if hidden { transparent } else { tint.lighten(60%) },
  stroke: if hidden { transparent } else { 1pt + tint.darken(20%) },
  corner-radius: 10pt,
  ..args,
)
#let plusnode(pos, ..args) = node(pos, $ plus.circle $, inset: -5pt, ..args)
#let edge-hidden(hidden: false, ..args) = {
  let named = args.named()
  if hidden { named.insert("stroke", transparent) }
  edge(..args.pos(), ..named)
}

// --- Vínculos de Touying con Cetz y Fletcher ---
// ESTAS LÍNEAS SON FUNDAMENTALES Y YA LAS TENÍAS CORRECTAMENTE.
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)


// --- Contenido de la Presentación ---

#title-slide()

== Índice <touying:hidden>
#components.adaptive-columns(outline(title: none, indent: 1em, depth: 1))

= Resumen
= Introducción
= Infrestructura
= Generacion de datos

== ¿Qué son las activaciones?

En este contexto, la activación de latentes se refiere al estudio de cómo las
neuronas individuales o grupos de neuronas (unidades latentes) en las capas
ocultas de un modelo de inteligencia artificial se activan en respuesta a
diferentes entraadas, y cómo estas activaciones contribuyen al comportamiento
general del modelo.

= Entrenamiento de Autoencoder
== Modelo de dos capas
== Jump ReLU vs otras
== Delta ML Loss vs L0
= Extracción de Características
== Loss dim vs prevalencia and histograma prevalencia

= Autointerpretabilidad

Los modelos que son autointerpretables están diseñados desde el principio para
revelar la lógica de sus predicciones a través de sus propias estructuras del
modelo. En este enfoque se distingue que aplica métodos a modelos ya
entrenados.

La interpretabilidad se integra directamente en la arquitectura y el proceso
de entrenamiento del modelo, en lugar de ser una adición.
A menudo se basan en estructuras sencillas, cuya lógica son fáciles de
visualizar y comprender.
Se busca revelar los procesos de toma de decisiones como parte de su
operación, proporcionando explicaciones comprensibles por humanos para sus
predicciones.

== Promt
== Paso a GPT
== Resultados

= Prueba LOSS

== Graficas 1

// == SECCIÓN MODIFICADA: PRUEBAS DE LOSS CON GRÁFICO DINÁMICO
// ===================================================================
// Importar las librerías necesarias
#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1"

#cetz.canvas({
  // Importar los módulos al scope local
  import cetz.draw: *
  import cetz-plot: *

  // --- Procesamiento de Datos ---
  // Repetimos el proceso de leer y convertir para cada archivo CSV.

  // 1. Procesar el primer archivo: datos_sensor_1.csv
  let datos1 = csv("data.csv")
    .slice(1)
    .map(row => {
      (float(row.at(0)), float(row.at(1)))
    })

  // 2. Procesar el segundo archivo: datos_sensor_2.csv
  let datos2 = csv("data2.csv")
    .slice(1)
    .map(row => {
      (float(row.at(0)), float(row.at(1)))
    })

  // 3. Procesar el tercer archivo: datos_sensor_3.csv
  let datos3 = csv("data3.csv")
    .slice(1)
    .map(row => {
      (float(row.at(0)), float(row.at(1)))
    })

  // --- Creación de la Gráfica ---
  // Usamos un solo entorno plot.plot para dibujar todo en los mismos ejes.
  plot.plot(
    size: (12, 7),
    x-label: [Tiempo (s)],
    y-label: [Valor del Sensor],
    axis-style: "scientific",
    // Configura la posición de la leyenda (ver manual, pág. 7)
    legend: (9.8, 6.8),
    legend-anchor: "north-east",
    {
      // Añadimos cada conjunto de datos con una llamada a plot.add()

      // Gráfica 1: Datos del sensor 1 (azul)
      plot.add(
        datos1,
        mark: "o",
        line: "linear",
        label: [Sensor 1], // Etiqueta para la leyenda
        style: (stroke: 1.5pt + blue),
      )

      // Gráfica 2: Datos del sensor 2 (rojo)
      plot.add(
        datos2,
        mark: "square",
        line: "linear",
        label: [Sensor 2], // Etiqueta para la leyenda
        style: (stroke: 1.5pt + red),
      )

      // Gráfica 3: Datos del sensor 3 (verde)
      plot.add(
        datos3,
        mark: "triangle",
        line: "linear",
        label: [Sensor 3], // Etiqueta para la leyenda
        style: (stroke: 1.5pt + green),
      )
    },
  )
})
