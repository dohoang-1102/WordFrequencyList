varying lowp vec4 DestinationColor;

varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

varying lowp vec3 NormalOut;
varying lowp vec3 LightOut;

varying lowp vec3 ViewOut;

void main(void) {
    lowp vec3 N = normalize(NormalOut);
	lowp vec3 L = normalize(LightOut);
    
    lowp float nDotL            = max(dot(N,L),0.0);
    

	lowp vec3 H = normalize(normalize(ViewOut)+L);
        
    lowp float spectualTerm     = pow(max(dot(N,H),0.0)/2.0,2.0);
    
    
    lowp vec4 color     = vec4(0.0,0.0,0.0,1.0)+(0.5+ nDotL*0.3 + spectualTerm * .5 ) * DestinationColor;
	gl_FragColor        = color;//vec4(NormalOut,1.0);//* texture2D(Texture, TexCoordOut);
}