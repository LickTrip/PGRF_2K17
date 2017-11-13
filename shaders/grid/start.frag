#version 150
//varying vec3 vertColor; // input from the previous pipeline stage
varying vec3 normal;
varying vec3 lightDirection;
varying vec3 viewDirection;
varying float dist;

varying vec2 texCoord;

uniform int efectType;
uniform int degreeOfEfect;
uniform sampler2D texture1;
uniform sampler2D texture1Norm;
uniform sampler2D texture1Para;

uniform sampler2D texture2;
uniform sampler2D texture2Norm;
uniform sampler2D texture2Para;
uniform sampler2D texture2Ao;

uniform int showTexture;
uniform int normalMap;
uniform int functionType;
uniform int changeText;

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

//paralex mapping
float scaleL = 0.02;
float scaleK = 0.0;

void main() {

    //normalizace
    vec3 lghtDrct = normalize(lightDirection);
    vec3 nrml = normalize(normal);
    vec3 viewDrct = normalize(viewDirection);

    vec3 bump;
    vec3 glossColor;
    float reflectivity;
    if(showTexture == 1){
         float heightText;
         if(changeText == 0){
             //base
             baseColor = texture(texture1, texCoord);
             //height mapp
             heightText = texture(texture1Para, texCoord).r;
         }
         else{
            //base
            baseColor = texture(texture2, texCoord);
            //height
            heightText = texture(texture2Para, texCoord).r;
            //gloss
            glossColor = texture(texture2Ao, texCoord * vec2(2.0,1.0)).rgb;
            reflectivity = 0.30*glossColor.r + 0.59*glossColor.g + 0.11*glossColor.b;
         }
         if(texCoord.x > 1.0 || texCoord.y > 1.0 || texCoord.x < 0.0 || texCoord.y < 0.0)
         discard;

         float v = heightText * scaleL + scaleK;
         vec2 offSet = viewDrct.xy / viewDrct.z * v;
         //prepocet souradnic na <-1;1>
         if(changeText == 0)
            bump = texture(texture1Norm, texCoord + offSet).rgb * 2.0 - 1.0;
         else
            bump = texture(texture2Norm, texCoord + offSet).rgb * 2.0 - 1.0;
    }

    vec4 color = baseColor;

    //nastaveni slozek
    vec4 totalAmbient = ambient * baseColor;
    vec4 totalDifuse = vec4(0.0);
    vec4 totalSpecular = vec4(0.0);

    float NDotL;
    if(showTexture == 0){
        NDotL = dot(lghtDrct, nrml);
    }
    else{
        if(normalMap == 1)
            NDotL = dot(lghtDrct, nrml * bump);
        else
            NDotL = dot(lghtDrct, bump);
    }

    if(NDotL > 0.0){
        //skalar soucty
        vec3 reflection = normalize(((2.0 * nrml) * NDotL) - lghtDrct);
        float RDotV = max(0.0, dot(reflection, viewDrct));

        vec3 halfVector = normalize(lghtDrct + viewDrct);

        float NDotH;
        if(showTexture == 0){
            NDotH = max(0.0, dot(nrml, halfVector));
        }
        else{
            if(normalMap == 1)
                NDotH = max(0.0, dot(bump * nrml, halfVector));
            else
                NDotH = max(0.0, dot(bump, halfVector));
        }

        //vypocet difuzni slozky
        totalDifuse = diffuse * NDotL * baseColor;
        //vypocet total difuzni slozky
        totalSpecular = specular * (pow(NDotH, specularPower*4.0));
    }
    //vypocet utlumu
    float att = 1.0/(constantAttenuation + linearAttenuation * dist + quadraticAttenuation * dist * dist);
    float spotEffect = dot(normalize(spotDirection), normalize(lghtDrct));
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
                case 2:
                    outColor = totalAmbient + totalDifuse;
                break;
                //phong with soecular
                case 1:
                    outColor = totalAmbient + totalDifuse + totalSpecular;
                break;
                //attenuation of light
                case 0:
                    if(showTexture == 0)
                        outColor = totalAmbient + att*(totalDifuse + totalSpecular);
                    else
                        outColor = reflectivity * totalAmbient + att*(totalDifuse + totalSpecular);
                break;
                //reflector
                case 3:
                    if(spotEffect > spotCutOff){
                        outColor = totalAmbient + att*(totalDifuse + totalSpecular);
                    }else
                        //outColor = vec4(vec3(spotEffect),1);
                        outColor = totalAmbient;
                break;
                case 4:

                    if(spotEffect > spotCutOff){
                        float blend = clamp(((spotEffect - 1 + spotCutOff) / spotCutOff ), 0.0, 1.0);
                        outColor = mix(totalAmbient, totalAmbient + att*(totalDifuse + totalSpecular), blend);
                    }else
                        outColor = totalAmbient;
                break;
          }
        break;
    }
} 
