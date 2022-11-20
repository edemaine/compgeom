margin = 10
refresh = 1000
eps = 0.000001

SVGNS = 'http://www.w3.org/2000/svg'

svgContent = viewBox = null

flatten = window['@flatten-js/core']
globals = {
  ...flatten
  draw: (obj, attrs) ->
    if obj instanceof flatten.Line or obj instanceof flatten.Ray
      svgContent.push obj.svg viewBox, attrs
    else
      svgContent.push obj.svg attrs
    box = obj.box
    unless box.xmin in [-Infinity, Infinity] or
           box.xmax in [-Infinity, Infinity] or
           box.ymin in [-Infinity, Infinity] or
           box.ymax in [-Infinity, Infinity]
      box.xmin -= margin
      box.ymin -= margin
      box.xmax += margin
      box.ymax += margin
      viewBox = viewBox.merge box
    obj
}
for math in Object.getOwnPropertyNames Math
  globals[math] = Math[math]

error = (e) ->
  console.error e
  document.getElementById('error').innerText = e

update = ->
  document.getElementById('error').innerText = ''
  svgContent = []
  viewBox = new flatten.Box
  state = @getState()
  try
    js = CoffeeScript.compile state.code, bare: true
  catch e
    return error e
  delete globals.default  # causes syntax error
  func = new Function ...Object.keys(globals), js
  try
    func ...Object.values globals
  catch e
    error e
  svg = document.getElementById 'display'
  setViewBox()
  if viewBox.xmin? and viewBox.ymin?
    svg.setAttribute 'viewBox',
      "#{viewBox.xmin} #{viewBox.ymin} #{viewBox.width} #{viewBox.height}"
    svgContent[0...0] = ["""<rect x="#{viewBox.xmin}" y="#{viewBox.ymin}" width="#{viewBox.width}" height="#{viewBox.height}" fill="black"/>"""]
  else
    svg.removeAttribute 'viewBox'
  if state.viewBox  # override
    svg.setAttribute 'viewBox', state.viewBox
  svg.innerHTML = svgContent.join ''

setViewBox = ->
  svg = document.getElementById 'display'
  if viewBox.xmin? and viewBox.ymin?
  else

getSVG = ->
  '<?xml version="1.0" encoding="utf-8"?>\n' +
  document.getElementById('display').outerHTML
  .replace /<svg/, "<svg xmlns=\"#{SVGNS}\""

## From Cocreate
svgPoint = (svg, x, y, matrix = svg) ->
  if matrix.getScreenCTM?
    matrix = matrix.getScreenCTM().inverse()
  pt = svg.createSVGPoint()
  pt.x = x
  pt.y = y
  pt.matrixTransform matrix

rectFromPoints = (p, q) ->
  x: Math.min p.x, q.x
  y: Math.min p.y, q.y
  width: Math.abs p.x - q.x
  height: Math.abs p.y - q.y

window.addEventListener 'DOMContentLoaded', ->
  furls = new Furls()
  .addInputs()
  .on 'stateChange', update
  .syncState()

  cm = CodeMirror.fromTextArea document.getElementById('code'),
    mode: 'coffeescript'
    lineNumbers: true
    theme: 'abcdef'
  saveTimeout = null
  cm.on 'change', ->
    clearTimeout saveTimeout
    saveTimeout = setTimeout ->
      cm.save()
      furls.maybeChange 'code'
    , refresh

  document.getElementById('downloadSVG').addEventListener 'click', ->
    download = document.getElementById 'download'
    download.href =
      url = URL.createObjectURL new Blob [getSVG()], type: 'image/svg+xml'
    download.click()
    download.href = ''
    URL.revokeObjectURL url

  document.getElementById('reset').addEventListener 'click', ->
    furls.set 'viewBox', ''

  svg = document.getElementById 'display'
  pointers = {}
  endDrag = (e) ->
    pointers[e.pointerId]?.rect.remove()
    delete pointers[e.pointerId]
  svg.addEventListener 'pointerdown', (e) ->
    rect = document.createElementNS SVGNS, 'rect'
    rect.setAttribute 'class', 'select'
    svg.appendChild rect
    start = svgPoint svg, e.clientX, e.clientY
    pointers[e.pointerId] = {start, rect}
  svg.addEventListener 'pointermove', (e) ->
    return unless pointers[e.pointerId]?
    {rect, start} = pointers[e.pointerId]
    here = svgPoint svg, e.clientX, e.clientY
    for key, value of rectFromPoints start, here
      rect.setAttribute key, value
  svg.addEventListener 'pointerup', (e) ->
    return unless pointers[e.pointerId]?
    {start} = pointers[e.pointerId]
    endDrag e
    here = svgPoint svg, e.clientX, e.clientY
    box = rectFromPoints start, here
    return unless box.width > eps and box.height > eps
    furls.set 'viewBox', "#{box.x} #{box.y} #{box.width} #{box.height}"
  svg.addEventListener 'pointerleave', (e) ->
    endDrag e
