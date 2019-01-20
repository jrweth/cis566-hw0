#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_Time;         // The time

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;            // The position of each vertex

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

void main()
{
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation
    vec4 tmpPos = vs_Pos;

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = vec4(invTranspose * vec3(vs_Nor), 0);          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.

    float pi = 3.14159;
    float angle = mod(u_Time, 360.0);
    float radians = (angle * pi * 2.0) / 360.0;
    //bring toward the center and back
    if(vs_Pos.x < 0.0) {
        tmpPos.x += sin(radians) * 3.5 + 2.0;
    }
    else {
        tmpPos.x = tmpPos.x + 3.5 - sin(radians) * 3.5 - 6.0;
    }


    //check for the square vertices and make them bigger
    if(vs_Pos.x == -1.0 && tmpPos.x >= 0.0 && tmpPos.x <= pi/2.0) {
        tmpPos.y = tmpPos.y * (1.0+sin(tmpPos.x * 2.0) * 0.5) ;
        tmpPos.z = tmpPos.z * (1.0+sin(tmpPos.x * 2.0) * 0.5);
    }
    if(vs_Pos.x == -3.0 && tmpPos.x >= -pi/2.0 && tmpPos.x <= 0.0) {
        tmpPos.y = tmpPos.y * (1.0+sin(tmpPos.x * -2.0) * 0.5);
        tmpPos.z = tmpPos.z * (1.0+sin(tmpPos.x * -2.0) * 0.5);
    }






    //float angle = u_Time / 100.0;
    mat4 xRotation = mat4(1, 0, 0, 0,
                          0, cos(angle), sin(angle), 0,
                          0, -sin(angle), cos(angle), 0,
                          0, 0, 0, 1);
    mat4 zRotation = mat4(cos(angle), sin(angle), 0, 0,
                     -sin(angle), cos(angle), 0, 0,
                     0, 0, 1, 0,
                     0, 0, 0, 1);

    //tmpPos = zRotation * xRotation * tmpPos;


    fs_Pos = tmpPos;                         // Pass the vertex colors to the fragment shader for interpolation

    vec4 modelposition = u_Model * tmpPos;   // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}
