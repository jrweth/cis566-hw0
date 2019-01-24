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

float noiseRandom2to1(vec2 p) {
   return fract(sin(dot(p, vec2(123.2, 311.7)))*43758.5453);
}

float interpNoiseRandom2d(float x, float y) {
    float fractX = fract(x);
    float x1 = x - fractX;
    float x2 = x1 + 1.0;
    float fractY = fract(y);
    float y1 = y - fractY;
    float y2 = y1 + 1.0;

    float v1 = noiseRandom2to1(vec2(x1, y1));
    float v2 = noiseRandom2to1(vec2(x2, y1));
    float v3 = noiseRandom2to1(vec2(x1, y2));
    float v4 = noiseRandom2to1(vec2(x2, y2));

    float i1 = mix(v1, v2, fractX);
    float i2 = mix(v3, v4, fractX);

    return mix(i1, i2, fractY);

}



float fbm2d(vec2 p) {
    float total  = 0.0;
    float persistence = 0.5;
    float octaves = 8.0;

    for(float i = 0.0; i < octaves; i++) {
        float freq = pow(2.0, i);
        float amp = pow(persistence, i);
        total += interpNoiseRandom2d(p.x, p.y) * amp;
    }
    return total;
}

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = u_Color;

        diffuseColor.r = fbm2d(vec2(fs_Pos.x, fs_Pos.y));
        diffuseColor.g = fbm2d(vec2(fs_Pos.x, fs_Pos.y + 343.343));
        diffuseColor.b = fbm2d(vec2(fs_Pos.x, fs_Pos.y + 33.33));

//        diffuseColor.r = noiseRandom2to1(vec2(fs_Pos.x, fs_Pos.y));
//        diffuseColor.g = noiseRandom2to1(vec2(fs_Pos.x, fs_Pos.y + 4343.3434));
//        diffuseColor.b = noiseRandom2to1(vec2(fs_Pos.x, fs_Pos.y + 93433.343));

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
