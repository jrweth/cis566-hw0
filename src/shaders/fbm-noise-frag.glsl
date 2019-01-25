#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.

uniform float u_Time;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

vec3 noiseRandom3to3(vec3 p){
   return fract(sin(vec3(
       dot(p, vec3(127.1, 311.7, 191.999)),
       dot(p, vec3(269.5, 183.3, 766.54)),
       dot(p, vec3(420.69, 631.2, 109.21))
    )) * 43758.1234);
}

float noiseRandom3to1(vec3 p) {
   return fract(sin(dot(p, vec3(123.2, 311.7, 32.12)))*43758.5453);
}

float noiseRandom2to1(vec2 p) {
   return fract(sin(dot(p, vec2(123.2, 311.7)))*43758.5453);
}

float noiseRandom1to1(float p) {
   return fract(sin(p)*343.1234);
}

float interpNoiseRandom1d(float p) {
    float fractP = fract(p);
    float p1 = floor(p);
    float p2 = p1 + 1.0;

    float v1 = noiseRandom1to1(p1);
    float v2 = noiseRandom1to1(p2);

    return smoothstep(v1, v2, fractP);

}

float interpNoiseRandom2d(vec2 p) {
    float fractX = fract(p.x);
    float x1 = p.x - fractX;
    float x2 = x1 + 1.0;
    float fractY = fract(p.y);
    float y1 = p.y - fractY;
    float y2 = y1 + 1.0;

    float v1 = noiseRandom2to1(vec2(x1, y1));
    float v2 = noiseRandom2to1(vec2(x2, y1));
    float v3 = noiseRandom2to1(vec2(x1, y2));
    float v4 = noiseRandom2to1(vec2(x2, y2));

    float i1 = smoothstep(v1, v2, fractX);
    float i2 = smoothstep(v3, v4, fractX);

    return smoothstep(i1, i2, fractY);

}

float interpNoiseRandom3to1(vec3 p) {
    float fractX = fract(p.x);
    float x1 = floor(p.x);
    float x2 = x1 + 1.0;

    float fractY = fract(p.y);
    float y1 = floor(p.y);
    float y2 = y1 + 1.0;


    float fractZ = fract(p.z);
    float z1 = floor(p.z);
    float z2 = z1 + 1.0;

    float v1 = noiseRandom3to1(vec3(x1, y1, z1));
    float v2 = noiseRandom3to1(vec3(x2, y1, z1));
    float v3 = noiseRandom3to1(vec3(x1, y2, z1));
    float v4 = noiseRandom3to1(vec3(x2, y2, z1));

    float v5 = noiseRandom3to1(vec3(x1, y1, z2));
    float v6 = noiseRandom3to1(vec3(x2, y1, z2));
    float v7 = noiseRandom3to1(vec3(x1, y2, z2));
    float v8 = noiseRandom3to1(vec3(x2, y2, z2));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);
    float i3 = mix(v5, v6, fractX);
    float i4 = mix(v7, v8, fractX);

    float i5 = mix(i1, i2, fractY);
    float i6 = mix(i3, i4, fractY);

    return mix(i5, i6, fractZ);

}

float fbm1to1(float p) {
    float total  = 0.0;
    float persistence = 0.5;
    float octaves = 8.0;

    for(float i = 0.0; i < octaves; i++) {
        float freq = pow(2.0, i);
        float amp = pow(persistence, i);
        total = total + interpNoiseRandom1d(p * freq) * amp;
    }
    return total;

}

float fbm2to1(vec2 p) {
    float total  = 0.0;
    float persistence = 0.5;
    float octaves = 8.0;

    for(float i = 0.0; i < octaves; i++) {
        float freq = pow(2.0, i);
        float amp = pow(persistence, i);
        total = total + interpNoiseRandom2d(vec2(p.x * freq, p.y * freq)) * amp;
    }
    return total;
}


float fbm3to1(vec3 p) {
    float total  = 0.0;
    float persistence = 0.5;
    float octaves = 3.0;

    for(float i = 0.0; i < octaves; i++) {
        float freq = pow(2.0, i);
        float amp = pow(persistence, i);
        total += interpNoiseRandom3to1(p*freq) * amp;
    }
    return total;
}

void main()
{
        // Material base color (before shading)

        vec3 positionWarp = vec3(
           fbm3to1(vec3(fs_Pos.x + u_Time/100.0, fs_Pos.y, fs_Pos.z)),
           fbm3to1(vec3(fs_Pos.x, fs_Pos.y + u_Time/100.0, fs_Pos.z)),
           fbm3to1(vec3(fs_Pos.x, fs_Pos.y, fs_Pos.z + u_Time/100.0))
        );


        float positionNoise = fbm3to1(vec3(
            positionWarp.x,
            positionWarp.y,
            positionWarp.z));
        vec4 diffuseColor = u_Color * positionNoise;

        diffuseColor[3] = u_Color[3];




        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
        // Avoid negative lighting values
        // diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
