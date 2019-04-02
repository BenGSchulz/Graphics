#define PI 3.1415962

// Fragment shader for Sphere
precision mediump float;

// Light information.  Four lights are supported.  Light intensities are
// stored in a mat4, one per row.
uniform mat4 fLightDiffuse;
uniform mat4 fLightAmbient;
uniform mat4 fLightSpecular;

// Light on/off information for the 4 light sources.  For light i,
// fLightOn is non-zero to use the light, 0 to ignore it.
uniform vec4 fLightOn;

// Texture variables
uniform sampler2D fTexSampler;


// Interpolated input values from vertex shader
varying vec4 fNormal;
varying mat4 fLightDir;
varying vec4 fSpecular;
varying mat4 fLightHalfway;
varying float fShininess;
varying vec4 fTexCoords;

varying float viewer2vertex;

void main()
{
  vec4 shade = vec4(0.0, 0.0, 0.0, 0.0);     // initialize shade sum
  vec4 normal = normalize(fNormal);          // must normalize interpolated vector
  vec4 fDiffuse = vec4(0.7, 0.7, 0.7, 1.0);  // use white as diffuse color

// Texturing
  float t = (asin(fTexCoords.z) / PI) + 0.5;
  float s = 0.0;
  if (fTexCoords.z > -1.0 && fTexCoords.z < 1.0) {
    s = (atan(fTexCoords.y, fTexCoords.x) / PI) * 0.5 + 0.5;
  }

  vec2 stCoords = vec2(-s, t);


  for (int i = 0; i < 4; ++i) {
    if (fLightOn[i] != 0.0) {
      shade += fLightAmbient[i] * fDiffuse;    // use diffuse reflectance for ambient
      
      // Normalize interpolated light vectors
      vec4 lightDir = normalize(fLightDir[i]);
      vec4 halfway = normalize(fLightHalfway[i]);

      // Compute diffuse and specular reflectance
      float diffuse_coeff = dot(normal, lightDir);
      if (diffuse_coeff > 0.0) {               // if light in front of surface
        // Add diffuse components
        shade += (fLightDiffuse[i] * fDiffuse) * diffuse_coeff;

        // Compute specular reflectance
        float specular_coeff = dot(normal, halfway);
        if (specular_coeff > 0.0) {
          shade += fLightSpecular[i] * fSpecular * pow(specular_coeff, fShininess);
        }
      }
    }
  }
  shade.a = 1.0;

  // Fog
 //float fogFactor = 1.0 - camera2vertex;
  //vec4 texColor = texture2D(fTexSampler, stCoords);
  //vec4 fogColor = vec4(0.0, 0.0, 0.0, 0.0);
  //vec3 fogIntermediate = mix(fogColor.rgb, texColor.rgb, fogFactor);
  //vec4 finalFogColor = vec4(fogIntermediate, texColor.a);
  //gl_FragColor = finalFogColor * shade;
    
  //gl_FragColor = shade * texColor;

    vec2 fogDist = vec2(8, 15);
    vec3 fogColor = vec3(0.0, 0.0, 0.0);
    float fogFactor = clamp(((fogDist.y - viewer2vertex)/(fogDist.y-fogDist.x)), 0.0, 1.0);

    
    vec4 surfaceColor = shade * texture2D(fTexSampler, stCoords);

    vec3 color = mix(fogColor, vec3(surfaceColor), fogFactor);

    gl_FragColor = vec4(color, surfaceColor.a);
}
