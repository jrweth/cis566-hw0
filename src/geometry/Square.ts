import {vec3, vec4} from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import {gl} from '../globals';

class Square extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;
  colors: Float32Array;
  center: vec4;
  color: vec4;

  constructor(center: vec3, color: vec4) {
    super(); // Call the constructor of the super class. This is required.
    this.center = vec4.fromValues(center[0], center[1], center[2], 1);
    this.color = color;
  }

  create() {

      this.positions = new Float32Array([
          //left
          -1, -1, -1, 1,
          -1, -1,  1, 1,
          -1,  1, -1, 1,
          -1,  1,  1, 1,

          //right
           1, -1, -1, 1,
           1, -1,  1, 1,
           1,  1, -1, 1,
           1,  1,  1, 1,

          //top
          -1,  1, -1, 1,
          -1,  1,  1, 1,
           1,  1, -1, 1,
           1,  1,  1, 1,

          //bottom
          -1, -1, -1, 1,
          -1, -1,  1, 1,
          1,  -1, -1, 1,
          1,  -1,  1, 1,

          //back
          -1, -1, -1, 1,
          -1,  1, -1, 1,
          1, -1, -1, 1,
          1,  1, -1, 1,

          //front
          -1, -1, 1, 1,
          -1,  1, 1, 1,
           1, -1, 1, 1,
           1,  1, 1, 1
      ]);
      this.indices = new Uint32Array([
        //left side
        0, 1, 2,
        1, 2, 3,
        //right side
        4, 5, 6,
        5, 6, 7,
        //top
        8, 9, 10,
        9, 10, 11,
        //bottom
        12, 13, 14,
        13, 14, 15,
        //back
        16, 17, 18,
        17, 18, 19,
        //front
        20, 21, 22,
        21, 22, 23
    ]);
    this.normals = new Float32Array([
        //left
        -1,  0,  0, 0,
        -1,  0,  0, 0,
        -1,  0,  0, 0,
        -1,  0,  0, 0,
        //right
        1,  0,  0, 0,
        1,  0,  0, 0,
        1,  0,  0, 0,
        1,  0,  0, 0,
        //top
        0, 1, 0, 0,
        0, 1, 0, 0,
        0, 1, 0, 0,
        0, 1, 0, 0,
        //bottom
        0, -1, 0, 0,
        0, -1, 0, 0,
        0, -1, 0, 0,
        0, -1, 0, 0,
        //back
        0, 0, -1, 0,
        0, 0, -1, 0,
        0, 0, -1, 0,
        0, 0, -1, 0,
        //front
        0, 0, 1, 0,
        0, 0, 1, 0,
        0, 0, 1, 0,
        0, 0, 1, 0

    ]);

    //initialize colors
    let tmpColors = [];
    for(let i=0; i < 24; i++) {
      for(let j=0; j < 4; j++) {
        tmpColors.push(this.color[j]);
      }
    }
    this.colors = new Float32Array(tmpColors);

    //adjust positions to proscribed center
    for(let i =0; i < 24; i++) {
      this.positions[i*4] += this.center[0];
      this.positions[i*4 + 1] += this.center[1];
      this.positions[i*4 + 2] += this.center[2];
    }

    this.setColor(this.color);


    this.generateIdx();
    this.generatePos();
    this.generateNor();
    this.generateCol();

    this.count = this.indices.length;
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufCol);
    gl.bufferData(gl.ARRAY_BUFFER, this.colors, gl.STATIC_DRAW);

    console.log(`Created square`);
  }

  setColor(color: vec4) {
    this.color = color;
    for(let x of [-1, 1]){ for (let y of [-1, 1]) {for(let z of [-1, 1]){
      let randColor: vec4 = vec4.fromValues(Math.random(), Math.random(), Math.random(), color[3]);

      for(let i = 0; i < 24; i++) {
        if(this.positions[i*4] == x && this.positions[i*4 + 1] == y && this.positions[i*4 + 2] == z) {
          for(let j = 0; j < 4; j++) {
            this.colors[i*4 + j] = randColor[j];
          }
        }
      }
    }}}
    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufCol);
    gl.bufferData(gl.ARRAY_BUFFER, this.colors, gl.STATIC_DRAW);
  }
};

export default Square;
