attribute vec4 Position;
attribute vec4 SourceColor; 

attribute vec4 NormalIn; 


varying vec4 DestinationColor; 

uniform mat4 ProjectionMtx;
uniform mat4 normalMtx;
uniform mat4 modelViewMtx;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

uniform vec4 LightIn;




varying vec3 LightOut;
varying vec3 ViewOut;
varying vec3 NormalOut;

void main(void) {
    DestinationColor = SourceColor;
    
    TexCoordOut     = TexCoordIn;
    NormalOut       = vec3(normalMtx * NormalIn);
    vec3 vVertex    = vec3(modelViewMtx * Position);
    LightOut        = normalize(LightIn.xyz -vVertex);
    ViewOut         = -vVertex;
    
    gl_Position     = ProjectionMtx  * Position;
    
}