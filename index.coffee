margin = 10
refresh = 1000

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
  {code} = @getState()
  try
    code = CoffeeScript.compile code, bare: true
  catch e
    return error e
  delete globals.default  # causes syntax error
  code = new Function ...Object.keys(globals), code
  try
    code ...Object.values globals
  catch e
    error e
  svg = document.getElementById 'display'
  if viewBox.xmin? and viewBox.ymin?
    svg.setAttribute 'viewBox',
      "#{viewBox.xmin} #{viewBox.ymin} #{viewBox.width} #{viewBox.height}"
    svgContent[0...0] = ["""<rect x="#{viewBox.xmin}" y="#{viewBox.ymin}" width="#{viewBox.width}" height="#{viewBox.height}" fill="black"/>"""]
  svg.innerHTML = svgContent.join ''

getSVG = ->
  '<?xml version="1.0" encoding="utf-8"?>\n' +
  document.getElementById('display').outerHTML
  .replace /<svg/, '<svg xmlns="http://www.w3.org/2000/svg"'

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
