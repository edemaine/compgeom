# Computational Geometry Playground

This webapp is a (currently very simple) playground for interactively
changing and automatically executing computational geometry code
in CoffeeScript, with access to the following globals:

* [Flatten.js](https://github.com/alexbol99/flatten-js#readme) (see also [docs](https://alexbol99.github.io/flatten-js/)): `point`, `line`, `ray`, `segment`, `polygon`, `circle`, etc.
* `draw(obj, [attrs])` draws a given Flatten.js object to the SVG canvas.
  * For objects with finite bounding box (`point`, `segment`, `circle`, `polygon`, etc.), this updates the `viewBox`.
  * For objects with infinite bounding box (`line`, `ray`, etc.), the drawing gets clipped to the *current* `viewBox`. So be sure to draw some finite objects first.
  * `attrs` can specify the few rendering attributes supported by Flatten.js's `svg` methods: `fill`, `stroke`, `strokeWidth`, `r` for `point`s, `fillOpacity` for `polygon`s.
* [Math](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math): `sin`, `cos`, `PI`, etc. (no need for `Math.` prefix).

The window is divided into an SVG canvas on the top,
and a [CodeMirror](https://codemirror.net/5) code entry box at the bottom.
If the code produces an error, it gets displayed at the very bottom.

As you edit the code, it automatically executes after a second of idle time.
The code also gets embedded into the page's URL, so you can share the
playground with your code by sending the link.
