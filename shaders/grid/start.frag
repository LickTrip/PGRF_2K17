#version 150
//varying vec3 vertColor; // input from the previous pipeline stage
varying vec3 normal;
varying vec3 lightDirection;
varying vec3 viewDirection;
varying float dist;

varying vec2 texCoord;

uniform int efectType;
uniform int degreeOfEfect;
uniform sampler2D textureID;
uniform int showTexture;

out vec4 outColor; // output from the fragment shader

//osvetleni
vec4 baseColor = vec4(1.0, 0.2, 0.0, 1.0);
vec4 ambient = vec4(0.05);
vec4 diffuse = vec4(0.80);
vec4 specular = vec4(0.90);

//cim mensi cislo tim vetsi radius
float specularPower = 6.0;

//utlum
//konstatni osvetleni cim mensi tim vetsi osvetleni
float constantAttenuation = 0.05;
float linearAttenuation = 0.05;
float quadraticAttenuation = 0.01;

//reflektor
float spotCutOff = 0.999;
vec3 spotDirection = vec3(-4.5, 3.7, 9.0);

void main() {

    if(showTexture == 1)
        baseColor = texture(textureID, texCoord);

    vec4 color = baseColor;
    //normalizace
    vec3 lghtDrct = normalize(lightDirection);
    vec3 nrml = normalize(normal);
    vec3 viewDrct = normalize(viewDirection);

    //nastaveni slozek
    vec4 totalAmbient = ambient * baseColor;
    vec4 totalDifuse = vec4(0.0);
    vec4 totalSpecular = vec4(0.0);

    float NDotL = dot(lghtDrct, nrml);

    if(NDotL > 0.0){
        //skalar soucty
        vec3 reflection = normalize(((2.0 * nrml) * NDotL) - lghtDrct);
        float RDotV = max(0.0, dot(reflection, viewDrct));

        vec3 halfVector = normalize(lghtDrct + viewDrct);
        float NDotH = max(0.0, dot(nrml, halfVector));

        //vypocet difuzni slozky
        totalDifuse = diffuse * NDotL * baseColor;
        //vypocet total difuzni slozky
        totalSpecular = specular * (pow(NDotH, specularPower*4.0));
    }
    switch(efectType){
        //basic
        case 0:
          switch(degreeOfEfect){
                //normal
                case 0:
                   outColor = vec4(vec3(nrml), 1.0);
                break;
                //scalar
                case 1:
                   outColor = vec4(vec3(NDotL), 1.0);
                break;
                case 2:
                   outColor = vec4(baseColor.rgb, 1.0);
                break;
           }
        break;
        //light
        case 1:
         switch(degreeOfEfect){
                //phong
                case 0:
                    outColor = totalAmbient + totalDifuse;
                break;
                //phong with soecular
                case 1:
                    outColor = totalAmbient + totalDifuse + totalSpecular;
                break;
                //attenuation of light
                case 2:
                    //vypocet utlumu
                    float att = 1.0/(constantAttenuation + linearAttenuation * dist + quadraticAttenuation * dist * dist);
                    outColor = totalAmbient + att*(totalDifuse + totalSpecular);
                break;
                //reflector
                case 3:
                    float spotEffect = dot(normalize(spotDirection), normalize(lghtDrct));

                    if(spotEffect > spotCutOff){
                        float att = 1.0/(constantAttenuation + linearAttenuation * dist + quadraticAttenuation * dist * dist);
                        outColor = totalAmbient + att*(totalDifuse + totalSpecular);
                    }else
                        //outColor = vec4(vec3(spotEffect),1);
                        outColor = totalAmbient;
                break;
          }
        break;
        //texture
        /*case 2:
         switch(degreeOfEfect){
                //basic
                case 0:
                    outColor = vec4(baseColor.rgb, 1.0);
                break;
                //with phong
                case 1:
                    outColor = totalAmbient + totalDifuse + totalSpecular;
                break;
                case 2:
                    outColor = totalAmbient + totalDifuse + totalSpecular;
                break;
          }
        break;*/
    }
} 
