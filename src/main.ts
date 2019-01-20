import {vec3,vec4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Icosphere from './geometry/Icosphere';
import Square from './geometry/Square';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';

// Define an object with application parameters and button callbacks
// This will be referred to by dat.GUI's functions that add GUI elements.
const controls = {
  tesselations: 5,
  'Load Scene': loadScene, // A function pointer, essentially
  'Speed': 1.0,
  'Color Red': 0.1,
  'Color Green': 0.5,
  'Color Blue': 1.0,
  'Alpha': 1.0,
  'Vertex Shader': 'lambert',
  'Fragment Shader': 'lambert'
};

let color: vec4 = vec4.fromValues(controls["Color Red"], controls["Color Green"], controls["Color Blue"], controls.Alpha);
let icosphere: Icosphere;
let square: Square;
let prevTesselations: number = 5;
let prevVertexShader: string = 'lambert';
let prevFragmentShader: string = 'lambert';

function loadScene() {
  icosphere = new Icosphere(vec3.fromValues(2, 0, 0), 1, controls.tesselations, color);
  icosphere.create();
  square = new Square(vec3.fromValues(-2, 0, 0), color);
  square.create();
}

function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'tesselations', 0, 8).step(1);
  gui.add(controls, 'Load Scene');
  gui.add(controls, 'Speed', {'1/10': 0.1, '1/4': 0.25, '1/2': 0.5, 'normal': 1.0, 'x2': 2.0, 'x4': 4.0, 'x10': 10.0});
  gui.add(controls, 'Color Red', 0.0, 1.0).step(0.1);
  gui.add(controls, 'Color Green', 0.0, 1.0).step(0.1);
  gui.add(controls, 'Color Blue', 0.0,1.0).step(0.1);
  gui.add(controls, 'Alpha', 0.0,1.0).step(0.1);
  gui.add(controls, 'Vertex Shader',['lambert', 'wave', 'rotate', 'pass-through']);
  gui.add(controls, 'Fragment Shader',['lambert', 'polka-dot', 'color-splitscreen', 'random-lerp']);

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 5), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0.2, 0.2, 0.2, 1);
  gl.enable(gl.DEPTH_TEST);

  const shader = new ShaderProgram(
    new Shader(gl.VERTEX_SHADER, require('./shaders/' + controls["Vertex Shader"] +'-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/' + controls["Fragment Shader"] +'-frag.glsl'))
  );

  let time:number = 0;
  // This function will be called every frame
  function tick() {
    time++;
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    renderer.clear();
    renderer.setGeometryColor(
      controls["Color Red"],
      controls["Color Green"],
      controls["Color Blue"],
      controls["Alpha"]
    );
    renderer.setTime(time * controls.Speed);
    //icosphere.setColor(vec4.fromValues(controls["Color Red"],controls["Color Green"], controls["Color Blue"], controls.Alpha));
    //square.setColor(vec4.fromValues(controls["Color Red"],controls["Color Green"], controls["Color Blue"], controls.Alpha));
    if(controls.tesselations != prevTesselations)
    {
      prevTesselations = controls.tesselations;
      icosphere = new Icosphere(vec3.fromValues(0, 0, 0), 1, prevTesselations, color);
      icosphere.create();
    }
    if(controls["Vertex Shader"] != prevVertexShader) {
      shader.setVertexShader(new Shader(gl.VERTEX_SHADER, require('./shaders/'+ controls["Vertex Shader"] +'-vert.glsl')))
      prevVertexShader = controls["Vertex Shader"];
    }
    if(controls["Fragment Shader"] != prevFragmentShader) {
      shader.setFragmentShader(new Shader(gl.FRAGMENT_SHADER, require('./shaders/' + controls["Fragment Shader"] + '-frag.glsl')));
      prevFragmentShader= controls["Fragment Shader"];
    }
    renderer.render(camera, shader, [
      icosphere,
      square
    ]);
    stats.end();

    // Tell the browser to call `tick` again whenever it renders a new frame
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}

main();
