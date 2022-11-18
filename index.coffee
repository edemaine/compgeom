margin = 5
refresh = 1000

svgContent = viewBox = null

flatten = window['@flatten-js/core']
globals = {...flatten,
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

update = ->
  svgContent = []
  viewBox = new flatten.Box
  {code} = @getState()
  try
    code = CoffeeScript.compile code, bare: true
  catch e
    console.error e
  delete globals.default  # causes syntax error
  code = new Function ...Object.keys(globals), code
  try
    code ...Object.values globals
  catch e
    console.error e
  svg = document.getElementById 'display'
  svg.innerHTML = svgContent.join ''
  if viewBox.xmin? and viewBox.ymin?
    svg.setAttribute 'viewBox',
      "#{viewBox.xmin} #{viewBox.ymin} #{viewBox.width} #{viewBox.height}"

updateTimeout = null
updateSoon = ->
  clearTimeout updateTimeout
  updateTimeout = setTimeout (=> update.call @), refresh

window.addEventListener 'DOMContentLoaded', ->
  furls = new Furls()
  .addInputs()
  .on 'stateChange', updateSoon
  .syncState()
