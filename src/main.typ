
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

= Introducción
= Resumen
= Infraestructura
= Entrenamiento de Autoencoder
= Extracción de Características
= Para prueba despligue pages
= Autointerpretabilidad

// == SECCIÓN MODIFICADA: PRUEBAS DE LOSS CON GRÁFICO DINÁMICO
// ===================================================================

= Pruebas de Loss

== Graficas

// -> Impotacion de las librerias necesarias

#import "@preview/cetz-plot:0.1.1" // Caja especializada para graficos o diagramas.

// Creacion del lienzo -- todo lo realcionado con el dibujo (grafico) debe quedar dentro.
#cetz.canvas({
  // Conveniencia, desempaqueta cajas de herramientas
  // para escribir nombres de funciones mas cotos (alias).
  import cetz.draw: *
  import cetz-plot: *

  // -> Se le el archivo csv.
  let raw-data = csv("data.csv") // funcion que realiza toso, abre, lee y organiza.
  // Por lo tanto la variable guarda el resultado ordenado.
  let data2 = csv("data2.csv")
  let data3 = csv("data3.csv")

  // -> Se convierten lo datos a una forma adecuada para graficar.
  let plottable-data = () // es un arrreglo vacio (la clave son '()').


  for row in raw-data.slice(1) {
    // toma el raw-data y lo corta, toma solo desde el segundo elemento. (asi se omite el encabezado). En cada iteracion se almacena en row.

    // Desempaqueta el primer elemtento para las x el segundo para las y y los sonvierte en flotante.
    let x-value = float(row.at(0))
    let y-value = float(row.at(1))

    // se crea un par de tuplas y con el push se agrega este al final por iteción.

    plottable-data.push((x-value, y-value))
  } // Fin de canvas

  for row in data2.slice(1) {
    // toma el raw-data y lo corta, toma solo desde el segundo elemento. (asi se omite el encabezado). En cada iteracion se almacena en row.

    // Desempaqueta el primer elemtento para las x el segundo para las y y los sonvierte en flotante.
    let x-value = float(row.at(0))
    let y-value = float(row.at(1))

    // se crea un par de tuplas y con el push se agrega este al final por iteción.

    plottable-data.push((x-value, y-value))
  } // Fin de canvas

  for row in data3.slice(1) {
    // toma el raw-data y lo corta, toma solo desde el segundo elemento. (asi se omite el encabezado). En cada iteracion se almacena en row.

    // Desempaqueta el primer elemtento para las x el segundo para las y y los sonvierte en flotante.
    let x-value = float(row.at(0))
    let y-value = float(row.at(1))

    // se crea un par de tuplas y con el push se agrega este al final por iteción.

    plottable-data.push((x-value, y-value))
  } // Fin de canvas


  // Creacion del grafico

  plot.plot(
    // configuracion para el marco del grafico, ejes, etiquetas, etc.
    size: (10, 6), // alto y ancho
    x-label: [Time (from CSV)],
    y-label: [Measurement (from CSV)],
    axis-style: "scientific", // eleige el estilo del grafico
    {
      // Funcion que realiza el dibujo real de los datos
      plot.add(
        plottable-data, // Se le estan dando los datos
        mark: "o", // figura por datos
        line: "linear", // conectar por linea recta cada punto.
        style: (stroke: 1.5pt + blue), // tamaño y color de linea.
      )
    },
  )
})


