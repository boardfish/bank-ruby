/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import styler from 'stylefire';
import { tween, easing } from 'popmotion';
import pose from 'popmotion-pose'
console.log('Hello World from Webpacker')
const box = styler(document.querySelector("td"));
tween({
  from: {
    x: -100,
    opacity: 0
  },
  to: {
    x: 0,
    opacity: 1
  },
  ease: {
    x: easing.easeOut,
    opacity: easing.easeOut
  }
}).start(box.set);
