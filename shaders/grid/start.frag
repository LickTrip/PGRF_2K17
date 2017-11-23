#version 150
//varying vec3 vertColor; // input from the previous pipeline stage
varying vec3 normal;
varying vec3 lightDirection;
varying vec3 viewDirection;
varying float dist;

varying vec2 texCoord;
varying vec3 spotDirection;
varying vec2 sphereText;

varying vec4 myColor;
varying vec4 ambient;
varying vec4 diffuse;
varying vec4 specular;

varying float constantAttenuation;
varying float linearAttenuation;
varying float quadraticAttenuation;

varying float specularPower;

uniform vec3 camera;
uniform int isPerVert;

uniform int efectType;
uniform int degreeOfEfect;

uniform sampler2D texture1;
uniform sampler2D texture1Norm;
uniform sampler2D texture1Para;

uniform sampler2D texture2;
uniform sampler2D texture2Norm;
uniform sampler2D texture2Para;
uniform sampler2D texture2Ao;

uniform int repeatTextW;
uniform int repeatTextH;

uniform int showTexture;
uniform int normalMap;
uniform int functionType;
uniform int changeText;

//paralax
uniform float scaleL;
uniform float scaleK;

varying vec4 vertColor;
out vec4 outColor; // output from the fragment shader

vec4 baseColor;

//reflektor
float spotCutOff = 0.99;

void perPixel();

void main() {

    if(isPerVert == 0){
        baseColor = myColor;
        perPixel();
    }
    else{
        outColor = vertColor;
    }
}

void perPixel(){
    //normalizace
    vec3 lghtDrct = normalize(lightDirection);
    vec3 nrml = normalize(normal);
    vec3 viewDrct = normalize(viewDirection);
    vec3 bump;
    vec3 glossColor;
    float reflectivity;

    if(showTexture == 1){
         float heightText;

         vec2 newTextCoord;
         if(functionType == 0 || functionType == 1){
             newTextCoord = mod(sphereText * vec2(repeatTextW, repeatTextH), vec2(1.0, 1.0));
         }
         else{
              newTextCoord = mod(texCoord * vec2(repeatTextW, repeatTextH), vec2(1.0, 1.0));
     	 }
         if(changeText == 0){
             //base
             baseColor = texture(texture1, newTextCoord);
             //height mapp
             heightText = texture(texture1Para, newTextCoord).r;
         }
         else{
            //base
            baseColor = texture(texture2, newTextCoord);
            //height
            heightText = texture(texture2Para, newTextCoord).r;
            //gloss
            glossColor = texture(texture2Ao, newTextCoord * vec2(2.0,1.0)).rgb;
            reflectivity = 0.30*glossColor.r + 0.59*glossColor.g + 0.11*glossColor.b;
         }

         //vypocet paralax
         float v = heightText * scaleL + scaleK;
         vec3 eye = normalize(camera);
         vec2 offSet = eye.xy * v;

         //orezani paralax
         if(newTextCoord.x > 1.0 || newTextCoord.y > 1.0 || newTextCoord.x < 0.0 || newTextCoord.y < 0.0)
            discard;

         //prepocet souradnic na <-1;1>
         if(changeText == 0)
            bump = texture(texture1Norm, newTextCoord + offSet).rgb * 2.0 - 1.0;
         else
            bump = texture(texture2Norm, newTextCoord + offSet).rgb * 2.0 - 1.0;
    }

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
                        outColor = totalAmbient + att*(totalDifuse + totalSpecular)*0.4;
                break;
                //reflector
                case 3:
                    if(spotEffect > spotCutOff){
                        outColor = totalAmbient + att*(totalDifuse + totalSpecular);
                        //outColor = vec4(vec3(spotEffect),1);
                    }else
                        outColor = vec4(vec3(spotEffect),1);
                        //outColor = totalAmbient;
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
