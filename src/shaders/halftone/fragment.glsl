uniform vec3 uColor;
uniform vec2 uResolution;

varying vec3 vNormal;
varying vec3 vPosition;

uniform float uShadowRepetition;
uniform vec3 uShadowColor;

uniform float uLightRepetition;
uniform vec3 uLightColor;
vec3 ambientLight (vec3 lightColor, float lightIntensity){
    return( lightColor*lightIntensity);
}

vec3 directionlLight (vec3 lightColor, float lightIntensity,vec3 normal,vec3 lightPosition,vec3 viewDirection,float specularPower){
   
   vec3 lightDirection=normalize(lightPosition);
   vec3 lightReflection=reflect(-lightDirection,normal);
 
// shading
   float shading=dot(normal,lightDirection);
   shading=max(0.0,shading);
   //specular
   float specular=-dot(lightReflection,viewDirection);
   specular=max(0.0,specular);
   specular=pow(specular,specularPower);


    return( lightColor*lightIntensity*(shading+specular));
}
vec3 pointLight (vec3 lightColor, float lightIntensity,vec3 normal,vec3 lightPosition,vec3 viewDirection,float specularPower,vec3 position,float lightDecay){
   vec3 lightDelta=lightPosition-position;
   float lightDistance=length(lightDelta);
   vec3 lightDirection=normalize(lightDelta);
   vec3 lightReflection=reflect(-lightDirection,normal);
 
// shading
   float shading=dot(normal,lightDirection);
   shading=max(0.0,shading);
   //specular
   float specular=-dot(lightReflection,viewDirection);
   specular=max(0.0,specular);
   specular=pow(specular,specularPower);
   float decay=1.0-lightDistance*lightDecay;
   decay=max(0.0,decay);
   return( lightColor*lightIntensity*decay*(shading+specular));
  
}

vec3 halftone(vec3 color,float repetition,vec3 direction ,float low,float high, vec3 pointColor,vec3 normal){
 float intensity=dot(normal,direction);
    intensity=smoothstep(low,high,intensity);
    vec2 uv=gl_FragCoord.xy/uResolution.y;
    uv*=repetition;
    uv=mod(uv,1.0);
    float point =distance(uv,vec2(0.5));
    point=1.0-step(0.5*intensity,point);
   return(mix(color,pointColor,point));

}

void main()
{
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = uColor;
    //lights

    vec3 light=vec3(0.0);
    light+=ambientLight(vec3(1.0),1.0);
    light+=directionlLight(
        vec3(1.0,1.0,1.0),
        1.0,
        normal,
        vec3(1.0,1.0,1.0),
        viewDirection,
        1.0
    );
    color*=light;

    //halftone
    vec3 pointColor=vec3(1.0,0.0,0.0);
    float repetition=50.0;
    vec3 direction=vec3(0.0,-1.0,0.0);
    float low=-0.8;
    float high=1.5;
   

    //halftone
    color=halftone(
       color,
       uShadowRepetition,
       vec3(0.0,-1.0,0.0),
       -0.8,
       1.5,
       uShadowColor,
       normal
    );
       color=halftone(
       color,
       uLightRepetition,
       vec3(1.0,1.0,0.0),
       0.5,
       1.5,
       uLightColor,
       normal
    );

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}