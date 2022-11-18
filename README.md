# Computational Geometry Playground

This webapp is a (currently very simple) playground for interactively
changing and automatically executing computational geometry code
in CoffeeScript, with access to the following globals:

* [Flatten.js](https://github.com/alexbol99/flatten-js#readme) (see also [docs](https://alexbol99.github.io/flatten-js/)): `point`, `line`, `ray`, `segment`, `polygon`, `circle`, etc.
* `draw(obj)` draws a given object to the SVG canvas.
  * For objects with finite bounding box (`point`, `segment`, `circle`, `polygon`, etc.), this updates the `viewBox`.
  * For objects with infinite bounding box (`line`, `ray`, etc.), the drawing gets clipped to the *current* `viewBox`. So be sure to draw some finite objects first.
* [Math](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math): `sin`, `cos`, `PI`, etc. (no need for `Math.` prefix).
