
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
#let invisible(content) = box(fill: none, stroke: none, text(fill: white.transparentize(100%), content))

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

#show raw: set text(size: 0.8em)


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



= Recapitulado

== Objetivos del proyecto

- Comprender y aplicar los conceptos de Autoencoders Dispersos (SAE) en
  modelos basados en transformers #pause

- Desarrollar habilidades en la interpretación mecanicista de modelos de
  lenguaje profundo #pause

- Explorar y aplicar optimizaciones computacionales, que nos permiten hacer mas
  las mismas operaciones pero más rápido #pause

- Post-entrenar llama3.2 usando RLHF o DPO, y comparar autoencoders sobre
  pre-entrenado y post-entrenado

== Resumen

#speaker-note[Los temas que abordamos en la primera parte del proyecto proporcionaron
una base sólida para comprender en profundidad los experimentos presentados
en esta exposición. Algunos de los más relevantes que analizamos fueron los siguientes]

Temas abordados en proyecto parte 1: 

- Formulación matemética desde las redes neuronales más simple hasta el
  transformer 
  // Se debe mencionar el prioceso de optimización que tambien definimos,
  // entre otros temas reelvantes.
- Definición y aproximaciones a la interpretabilidad mecanicista #pause
- SAE 
- Modelo Llama



== Introducción

En esta sección nos propusimos realizar una serie de experimentos orientados a
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


= Activaciones

== ¿Qué es una activación?
Una activación es el valor que produce 
una neurona artificial tras procesar su entrada con una función de activación.
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

== Captura de activaciones del modelo LLaMA 3

- Extraer activaciones internas (MLP-8) token por token.

- Modelo: LLaMA 3.2-1B, capa 8 

- Corpus: textos reales en streaming, filtrados por calidad.

- Tokenización y segmentación en bloques de 4096.


== Construcción y subida del dataset

- Procesamiento por lotes → activaciones (bfloat16 → uint16).

- Registro de: doc_id, token_id, pos, activación.

- Shards de 50K ejemplos

- RMS global calculado para normalizar activaciones.

- Backup local en caso de error de subida.

= Entrenamiento de Autoencoder
== Modelo de dos capas
== JumpReLU SAE

- Optimización con restricciones #pause

- $ell_0$ #pause

- $ "JumpReLU" (z | theta) = z dot.circle H(z - theta) $

== JumpReLU

#slide(repeat: 6, self => {
  let u(n, text) = if self.subslide < n  {" " * text.len()} else {text}

  let o(n, text) = if self.subslide != n {""} else {text}

  let a(..alternatives) = {
    let options = alternatives.pos()
    if options.len() == 0 { return "" }

    // Determine which alternative to show based on subslide
    let index = calc.min(self.subslide - 1, options.len() - 1)
    if index < 0 { index = 0 }

    // Get the content to show
    let content = options.at(index)

    // Find the maximum width for layout preservation
    let max-len = 0
    for option in options {
      max-len = calc.max(max-len, option.len())
    }

    // Pad content to max width with spaces if needed
    let padding = " " * calc.max(0, max-len - content.len())
    return content + padding
  }

  let lines = (
    u(6, "class JumpReLU(torch.autograd.Function):"      ),
    u(6, "    @staticmethod"                             ),
         "    def forward(ctx, x, threshold):",
         "        ctx.save_for_backward(x, threshold)",
         "        return (x > threshold).float() * x",
    o(1, "        #      ⌞▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁⌟"         )
  +      "",
    o(1, "        #         vector de 0s y 1s"            )
  + u(6, "    @staticmethod"                              ),
    o(1, "        # "                                     )
  + u(2, "    def backward(ctx, grad_output):"            ),
    o(1, "        # \">\" funciona elemento por elemento" )
  + u(2, "        bandwidth = 0.001"                      ),
    u(2, "        x, threshold = ctx.saved_tensors"       ),
    u(3, "        jacobian_x = (x > threshold).float()"   ),
    u(4, "        jacobian_threshold = (-threshold / bandwidth) * ("),
    u(4, "          (abs(x - threshold) < bandwidth/2)") + u(5, " & (x > 0)") + o(5, " # <──────"),
    u(4, "        ).float()") +            o(5, "                                      #        │"),
    o(5, "        # evitar pre-activaciones negativas influyan threshold ─┘"),
    u(3, "        return jacobian_x*grad_output") + u(4, ", jacobian_threshold*grad_output")
  )

  // h(1fr)
  raw(lines.join("\n"), lang: "python")
})

== Entrenamiento

```python
def hook(grad_in):
    # esto asume que la norma de las columnas es 1
    # así que hay que normalizar luego de cada
    # actualización a los parámetros
    dot = (self.dec.weight * grad_in).sum(dim=0, keepdim=True)
    return grad_in - dot * tensor

self.dec.weight.register_hook(hook)
```

#pagebreak(weak: true)

```python
with torch.autocast(device_type="cuda", dtype=torch.bfloat16):
    reconstrución_y_otras_salidas = model(x)
```

== Rendimiento General

#align(center, block(
  width: 80%,
  fill: rgb("#fff3cd"),
  inset: 0.5em,
  radius: 0.9em,
  stroke: 0.04em + rgb("#d4a934"),
  [
    Como matemático, escribes la ecuación y todas las letras están en la
    misma línea, no hay cuello de botella de comunicación entre la $A$ y la $B$
    que está al lado. (Josh Batson)
  ]))

#pagebreak(weak: true)


#let performance_data = (
  ([Kernel],     49559),
  ([Memcpy],      2111),
  ([Memset],         3),
  ([Runtime],        0),
  ([DataLoader],     0),
  ([CPU Exec],   14955),
  ([Other],        486),
)

#align(center)[
#cetz-canvas({
  let colors = gradient.linear(blue, purple, red)
  let total = performance_data.map(el => el.at(1)).sum()

  chart.piechart(
    performance_data,
    value-key: 1,
    label-key: 0,
    radius: 4,
    slice-style: colors,
    inner-radius: 1,
    inner-label: (content: (value, label) => (
      if value <= total * 0.02 {invisible(str(calc.round(value / total * 100)) + "%")} else {str(calc.round(value / total * 100)) + "%"}
    ), radius: 110%),
    outer-label: (content: (value, label) => (
      if value <= total * 0.02 {invisible(label)} else {label}
    ), radius: 140%),
    legend: (label: none)
  )
})
]

== Eficiencia GPU
#let data = (
  // durations in μs
  ([ADAM],                32716),
  ([mm1],       15698),
  ([mm2],       15477),
  ([mm3],       15417),
  ([mm4],       15336),
  ([mm5],       15240),
  ([mm6],       15230),
  ([eltwise-mul],          5570),
  ([vec-add],              3830),
  ([poi-exp-gt-mul],       3827),
  ([poi-copy],             3825),
  ([vec-mul],              3761),
  ([step-backward-reduce], 3699),
  ([l2-norm-reduce],       1876),
  ([sum-reduce],           1415),
)

#slide(repeat: 2, self => {
  align(center)[
    #cetz-canvas({
      let colors = gradient.linear(red, blue, green, yellow)
      let total = data.map(el => el.at(1)).sum()

      chart.piechart(
        data,
        value-key: 1,
        label-key: 0,
        radius: 4,
        slice-style: colors,
        inner-radius: 1,
        inner-label: (content: (value, label) => (
          if value <= total * 0.05 {none} else {str(calc.round(value / total * 100)) + "%"}
        ), radius: 110%),
        outer-label: (content: (value, label) => (
          if self.subslide == 1 {
            if label == [ADAM] {label} else {invisible(label)}
          } else {
            if value <= total * 0.05 {invisible(label)} else {label}
          }
        ),
          radius: 140%),
        legend: (label: none)
      )
    })
  ]
})


- $ "JumpReLU" (z | theta) = z dot.circle H(z - theta) $


== Gráficos prueba reconstrucción

#import "@preview/cetz:0.3.2"
#import "@preview/cetz-plot:0.1.1"

#slide(align: center + horizon)[
  #cetz-canvas({
    import cetz.draw: *
    import cetz-plot: *

    // --- CORRECCIÓN APLICADA AQUÍ ---
    // Leemos el nuevo archivo JSON.
    // Como ahora es un array de arrays, accedemos a los datos por su índice con .at()
    // Usaremos la segunda columna (índice 1) para el eje X 
    // y la tercera columna (índice 2) para el eje Y.
    let datos_reconstruccion = json("reconstruccion.json")
      .map(row => (float(row.at(1)), float(row.at(2))))

    plot.plot(
      size: (15, 10),

      // --- ETIQUETAS ACTUALIZADAS PARA LOS NUEVOS DATOS ---
      x-label: text(14pt, [Columna 2]), // <- Cambia esto por un nombre descriptivo
      y-label: text(14pt, [Columna 3]), // <- Cambia esto por un nombre descriptivo

      x-format: v => text(11pt)[#v],
      y-format: v => text(11pt)[#v],

      axis-style: "scientific",
      legend: (10.8, 9.5),

      title: text(16pt, [Gráfico de Dispersión de Reconstrucción]),

      {
        plot.add(
          // Pasamos los datos correctamente procesados
          datos_reconstruccion,
          
          mark: "o",

          line: (stroke: none),
          mark-size: 0.08,
          label: text(12pt, [Datos de Reconstrucción]), 

          style: (
            mark-style: (
              stroke: 1.5pt + green.darken(10%)
            ),
          )
        )
      },
    )
  })
]

== Jump ReLU vs otras
== Delta ML Loss vs L0

== Loss dim vs prevalencia and histograma prevalencia

= Interpretabilidad

== Interpretabilidad en modelos Transformer

Utilizamos un SAE para proyectar las activaciones internas del
Transformer en un espacio latente disperso. Esto nos permite identificar
direcciones latentes que influyen en tareas específicas y analizar el 
comportamiento del modelo de forma interpretable.


== Promt
== Paso a GPT
== Resultados

= Prueba LOSS

== Graficas 1

// == SECCIÓN MODIFICADA: PRUEBAS DE LOSS CON GRÁFICO DINÁMICO
// ===================================================================
// Importar las librerías necesarias

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
