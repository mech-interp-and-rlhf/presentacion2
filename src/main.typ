
// --- Importaciones ---
// Se mantienen tus importaciones originales
#import "@preview/touying:0.6.1": *
#import themes.university: *
#import "@preview/cetz:0.3.2" // caja fundamental para creaer formas
#import "@preview/fletcher:0.5.4" as fletcher: diagram, node, edge
#import fletcher.shapes: house, hexagon
#import "@preview/numbly:0.1.0": numbly
#import "@preview/theorion:0.3.2": *
#import "@preview/cetz:0.4.1": canvas, draw
#import draw: circle, content, line, rect

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
    subtitle: [Proyecto de investigación, parte 2],
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
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)


// --- Contenido de la Presentación ---

#title-slide()

== Índice <touying:hidden>
#show outline.entry: it => block(
  below: 3.5em,
  it.indented(
    it.prefix(),
    it.body(),
  ),
)

#components.adaptive-columns(outline(
  title: none,
  indent: 1em,
  depth: 1,
))

= Resumen

== Resumen

#speaker-note[Los temas que abordamos en la primera parte del proyecto nos proporcionaron
una base sólida para comprender en profundidad los experimentos presentados
en esta exposición. Algunos de los más relevantes que analizamos fueron los siguientes]

Temas abordados en proyecto parte 1: 

- Formulación matemética desde las redes neuronales más simple hasta el
  trasformer 
  // Se debe mencionar el prioceso de optimización que tambien definimos,
  // entre otros temas reelvantes.
- Definición y aproximaciones a la interpretabilidad mecanicista #pause
- SAE 
- Modelo Llama



== Introducción

En esta sección nos propusimos realizar una serie experimentos orientados a
entender el funcionamiento interno de modelos transformers desde una perspectiva
mecanicista, analizando cómo se activan y organizan sus representaciones
internas (activaciones latentes) para interpretar patrones y decisiones
del modelo.

== Infraestructura

#speaker-note[El desarrollo del proyecto se ha apoyado en una infraestructura híbrida que
combina herramientas en la nube y recursos de cómputo de alto rendimiento.]



#slide(composer: (2fr, 0.7fr))[

Entorno de desarrollo:

- Jupyter Notebook alojado en GitHub.

- Generación de presentaciones con Typst. #pause

Cómputo para entrenamiento del modelo:

- Plataforma: VAST.ai

- GPU: NVIDIA RTX 4090

//CPU: Multinúcleo (ej. AMD Ryzen o Intel Xeon)
//RAM: 64-128 GB (opcional, pero se utilizó menos)
//Almacenamiento: SSD NVMe
//Herramientas: Acceso por SSH

][
  #figure(
    image("Jnotebook.png", width: 80%),
  ) <logo-vast>

  #v(2em) // Espacio vertical entre las imágenes

  #figure(
    image("4090.jpg", width: 80%),
  ) <logo-nvidia>
]


= Generacion de datos

== ¿Qué es una activación?
Una activación es el valor que produce 
una neurona tras procesar su entrada con una función de activación.
//Representa cuánto y cómo responde esa neurona a la información que recibe.(speaker note)

== ¿Qué es una activación?

#slide(composer: (1fr, 1.5fr))[
  // --- Columna Izquierda: Texto ---
  #block(
    inset: (top: -6em), // Bajamos un poco el texto para alinear
    [
      Una activación es el valor que produce 
      una neurona tras procesar su entrada con una función de activación.
      
      #v(3em)

    ]
  )
  
  // --- Columna Derecha: Gráfico ---
  #place(center,
   cetz-canvas({
    // --- FUNCIÓN AUXILIAR DEFINIDA LOCALMENTE (LA FORMA CORRECTA) ---
    let neuron(pos, text: none, fill: white, stroke: black, radius: 0.6, name: none) = {
      // Ahora usamos los comandos de dibujo directamente, sin prefijo.
      circle(
        pos,
        radius: radius,
        fill: fill,
        stroke: stroke + 0.5pt,
        name: name
      )
      if text != none {
        content(pos, text, anchor: "center")
      }
    }
    
    // --- El resto del código del gráfico es el mismo ---
    let blue = rgb("#80b2ff")
    let gray = rgb("#ccc")
    let red = rgb("#ff6666")
    let dark-gray = rgb("#555")
    
    // Sintaxis de flecha COMPATIBLE con cetz v0.3.2
    let arrow-style = (
      mark: (end: (symbol: "stealth", size: 8pt, fill: dark-gray)),
      stroke: dark-gray + 0.5pt
    )

    // Entradas
    let input-x = -6
    content((input-x, 2.2), text(size: 0.9em)[Entradas])
    for i in range(3) {
      let y-pos = 1.2 - i * 1.2
      neuron((input-x, y-pos), text: $x_#(i+1)$, fill: blue, name: "x" + str(i+1))
    }

    // Suma Ponderada
    let sum-pos = (-2, 0)
    neuron(sum-pos, text: $z$, fill: gray, name: "sum-node")
    content((rel: (0, 1.0), to: "sum-node"), text(size: 0.9em)[Suma])
    for i in range(3) {
      line("x" + str(i+1), "sum-node", ..arrow-style, label: (content: $w_#(i+1)$, pos: 0.5, anchor: "south"))
    }
     content((sum-pos.at(0), -1.8), $z = sum_(i) w_i x_i + b$, anchor: "center")

    // Función de Activación (ReLU)
    let activation-pos = (2.5, 0)
    let box-width = 1.5; let box-height = 1.0;
    let center-x = activation-pos.at(0); let center-y = activation-pos.at(1)
    rect(
      (center-x - box-width, center-y - box-height),
      (center-x + box-width, center-y + box-height),
      name: "activation-box", stroke: 0.5pt + luma(200)
    )
    line((center-x - box-width, center-y), (center-x + box-width, center-y), stroke: luma(180) + 0.4pt)
    line((center-x, center-y - box-height), (center-x, center-y + box-height), stroke: luma(180) + 0.4pt)
    line((center-x - box-width, center-y), (center-x, center-y), (center-x + box-width, center-y + box-height), stroke: red + 1pt)
    content((center-x, 1.8), text(size: 0.9em)[Activación (ReLU)], anchor: "center")
    content((center-x+ 2.5
    , -1.8), $a = "ReLU"(z)$, anchor: "center")

    // Salida
    let output-pos = (7, 0)
    neuron(output-pos, text: $a$, fill: red, name: "output-node", radius: 0.7)
    content((rel: (0, 1.0), to: "output-node"), text(size: 0.9em)[Salida])

    // Flechas de Proceso
    line("sum-node", "activation-box.west", ..arrow-style)
    line("activation-box.east", "output-node", ..arrow-style)
  })
)
]

== Activaciones de latentes
¿Qué son?

- Son neuronas individuales o grupos de neuronas en las capas del modelo.
- Responden a una entrada específica.

#pagebreak(weak: true)

¿Qué se puede hacer con ellas?

- Se analiza cómo se activan esas unidades frente a distintas entradas.
- Comprender cómo esas activaciones afectan el comportamiento general del modelo.

= Entrenamiento de Autoencoder
== Modelo de dos capas
== JumpReLU SAE

- Optimización con restricciones #pause

- $ell_0$ #pause

- Salida de el perceptrón multicapa 8 #pause

- $ "JumpReLU" (z | theta) = z dot.circle H(z - theta) $

== Jump ReLU vs otras
== Delta ML Loss vs L0
= Extracción de Características
== Loss dim vs prevalencia and histograma prevalencia

= Autointerpretabilidad


== Modelos Autointerpretables


Los modelos que son autointerpretables están diseñados desde el principio para
revelar la lógica de sus predicciones a través de sus propias estructuras del
modelo. En este enfoque se distingue que aplica métodos a modelos ya entrenados.

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

== Prueba Loss 2

#cetz.canvas({
  import cetz.draw: *
  import cetz-plot: *

  let datos4 = csv("data4.csv")
    .slice(1)
    .map(row => {
      (float(row.at(0)), float(row.at(1)))
    })


  plot.plot(
    size: (12, 7),
    x-label: [I ],
    y-label: [Loss],
    axis-style: "scientific",
    // Configura la posición de la leyenda (ver manual, pág. 7)
    legend: (9.8, 6.8),
    legend-anchor: "north-east",
    {
      plot.add(
        datos4,
        mark: "+",
        line: "linear",
        label: [Sensor 3], // Etiqueta para la leyenda
        style: (stroke: 1.5pt + green),
      )
    },
  )
})
