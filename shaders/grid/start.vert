#version 150
in vec2 inPosition; // input from the vertex buffer

varying vec3 normal;
varying vec3 lightDirection;
varying vec3 viewDirection;
varying float dist;

varying vec2 texCoord;
varying vec2 sphereText;
varying vec3 spotDirection;

varying vec4 myColor;
varying vec4 ambient;
varying vec4 diffuse;
varying vec4 specular;

varying float constantAttenuation;
varying float linearAttenuation;
varying float quadraticAttenuation;

varying float specularPower;

varying vec4 vertColor;
//uniform float time; // variable constant for all vertices in a single draw
uniform mat4 mMV;
uniform mat4 mProj;
uniform vec3 camera;
uniform int functionType;
uniform int repeatTextW;
uniform int repeatTextH;
uniform int isPerVert;

//const
const float PI = 3.1415926;
const float delta = 0.001;

vec3 toSpotDirection;

//functions
vec3 doNormal(vec2 uv);
vec3 calcTangent(vec2 uv);
vec3 doMyFunctions(vec2 uv);
vec3 doFunctionEle(vec2 uv);
vec3 doFunctionDonut(vec2 uv);
vec3 doFunctionThing(vec2 uv);
vec3 doFunctionBean(vec2 uv);
vec3 doFunctionGlobe(vec2 uv);
vec3 doFunctionCarpet(vec2 uv);
vec3 doFunctionSombrero(vec2 uv);
vec3 doFunctionVase(vec2 uv);
vec3 doFunctionGrid(vec2 uv);
vec4 perVertex();
void setConstants();


void main() {
    setConstants();
    vec3 funcPos = doMyFunctions(inPosition);
    vec4 positionMV = mMV * vec4(funcPos, 1);
	normal = inverse(transpose(mat3(mMV))) * doNormal(inPosition);
	//vec3 lightSource = vec3(-3.5, 3.0, 3.0);
	lightDirection = camera - funcPos.xyz;
	viewDirection = - normalize(positionMV.xyz);
	dist = length(funcPos.xyz - camera);
	vec3 vTangent = calcTangent(inPosition);

	//transformace do TP
	normal = normalize(normal);
	vTangent = mat3(mMV) * vTangent;
	vec3 vBinormal = cross(normalize(normal), normalize(vTangent));
	vTangent = cross(vBinormal, normal);
	mat3 TBN = mat3(vTangent, vBinormal, normal);
	viewDirection = viewDirection * TBN;
	lightDirection = lightDirection * TBN;
	spotDirection = toSpotDirection * TBN;

    if(functionType == 0 || functionType == 1){
        sphereText = vec2((atan(funcPos.y, funcPos.x) / PI + 1.0)*0.5, 1.0 - acos(funcPos.z) / PI);
    }
    else
    {
        texCoord = inPosition;
    }

    if(isPerVert == 1)
        vertColor = perVertex();

	gl_Position = mProj * mMV * vec4(doMyFunctions(inPosition), 1);
}
vec4 perVertex(){
     vec4 baseColor = myColor;
     vec3 lghtDrct = normalize(lightDirection);
     vec3 nrml = normalize(normal);
     vec3 viewDrct = normalize(viewDirection);

     //nastaveni slozek
     vec4 totalAmbient = ambient * baseColor;
     vec4 totalDifuse = vec4(0.0);
     vec4 totalSpecular = vec4(0.0);

     float NDotL = dot(lghtDrct, nrml);

     if(NDotL > 0.0){

        vec3 reflection = normalize(((2.0 * nrml) * NDotL) - lghtDrct);
        float RDotV = max(0.0, dot(reflection, viewDrct));
        vec3 halfVector = normalize(lghtDrct + viewDrct);
        float NDotH = max(0.0, dot(nrml, halfVector));

        //vypocet difuzni slozky
        totalDifuse = diffuse * NDotL * baseColor;
        //vypocet total difuzni slozky
        totalSpecular = specular * (pow(NDotH, specularPower*4.0));
     }
     //vypocet utlumu
     float att = 1.0/(constantAttenuation + linearAttenuation * dist + quadraticAttenuation * dist * dist);
     float spotEffect = dot(normalize(spotDirection), normalize(lghtDrct));

     return vec4(totalAmbient + att*(totalDifuse + totalSpecular));
}

void setConstants(){
    //barva
     myColor = vec4(1.0, 0.2, 0.0, 1.0);
     ambient = vec4(0.05);
     diffuse = vec4(0.80);
     specular = vec4(0.90);

     //utlum
     //konstatni osvetleni cim mensi tim vetsi osvetleni
     constantAttenuation = 0.05;
     linearAttenuation = 0.10; //0.05
     quadraticAttenuation = 0.01;

     specularPower = 6.0;

     toSpotDirection = vec3(-3.5, 3.0, 2.0);
}

//normala pro stinovani barvy
vec3 doNormal(vec2 uv){
	vec3 du = doMyFunctions(vec2(uv.x + delta, uv.y)) - doMyFunctions(vec2(uv.x - delta, uv.y));
	vec3 dv = doMyFunctions(vec2(uv.x, uv.y + delta)) - doMyFunctions(vec2(uv.x, uv.y - delta));

	return normalize(cross(du,dv)); //normalizovat aby byla videt barva
}

vec3 calcTangent(vec2 uv){
    vec3 du = doMyFunctions(vec2(uv.x + delta, uv.y)) - doMyFunctions(vec2(uv.x - delta, uv.y));
    return du;
}

vec3 doMyFunctions(vec2 uv){
    switch(functionType){
    case 0:
        return doFunctionGlobe(uv);
    case 1:
        return doFunctionDonut(uv);
    case 2:
        return doFunctionCarpet(uv);
    case 3:
        return doFunctionEle(uv);
    case 4:
        return doFunctionThing(uv);
    case 5:
        return doFunctionSombrero(uv);
    case 6:
        return doFunctionVase(uv);
    }
    return doFunctionBean(uv);
}

vec3 doFunctionGlobe(vec2 uv){
    vec3 position;

	//od 0 do pi t
	float zen = uv.x * PI;
	//od 0 do 2pi s
	float az = uv.y * 2.0 * PI;

	position.x = sin(zen) * cos(az);
	position.y = sin(zen) * sin(az);
	position.z = cos(zen);

	return position;
}

vec3 doFunctionDonut(vec2 uv){
    vec3 position;

	float zen = uv.x * 2.0 * PI;
	float az = uv.y * 2.0 * PI;

	position.y = 3 * cos(az)+cos(zen)*cos(az);
	position.x = 3 * sin(az)+cos(zen)*sin(az);
	position.z = sin(zen);

	return position/3;
}

vec3 doFunctionCarpet(vec2 uv){
    vec3 position;
    vec2 myPosition = uv.xy;

	position.x = (myPosition.x - 0.57) * 2.8;
	position.y = (myPosition.y - 0.57) * 2.8;
	position.z = 0.5*cos(sqrt(15.0*myPosition.y*2.5*myPosition.y + 30.0*myPosition.x*myPosition.x)-0.5);

	return position;
}

vec3 doFunctionEle(vec2 uv){
	vec3 position;

	float ze = uv.x*PI;
	float az = uv.y*2*PI;
	float r = (3+cos(4*az))/5;

	position.x = r * sin(ze) * cos(az);
	position.y = r * sin(ze) * sin(az);
	position.z = r * cos(ze);

	return position;
}

vec3 doFunctionThing(vec2 uv){
    vec3 position;

    float ze = uv.x*PI;
    float az = uv.y*2*PI;
    float r = 0.5+cos(ze)*sin(2*az);

    position.x = r * sin(ze) * cos(az);
    position.y = r * sin(ze) * sin(az);
    position.z = r * cos(ze);

    return position;
}

vec3 doFunctionSombrero(vec2 uv) {
    vec3 position;

    float zen = uv.x * 2.0 * PI;
    float az = uv.y * 2.0 * PI;

    position.x = zen * cos(az);
    position.y = zen * sin(az);
    position.z = 2.0 * sin(zen);

    return position / 3;
}

vec3 doFunctionVase(vec2 uv) {
    vec3 position;

    float zen = uv.x * 2.0 * PI;
    float az = uv.y * 2.0 * PI;

    position.x = (2+cos(zen))/(3+sin(zen))*cos(az);
    position.y = (2+cos(zen))/(3+sin(zen))*sin(az);
    position.z = 2-zen;

    return position / 2;
}

vec3 doFunctionBean(vec2 uv){
    vec3 position;

	//od 0 do pi t
	float zen = uv.x * PI;
	//od 0 do 2pi s
	float az = uv.y * 2.0 * PI;

	position.x = sin(zen) * cos(az);
	position.y = 2*sin(zen) * sin(az);
	position.z = cos(zen);

	return position;
}

vec3 doFunctionGrid(vec2 uv){
    vec3 position;
    vec2 myPosition = uv.xy;

	position.x = (myPosition.x - 0.57) * 2.8;
	position.y = (myPosition.y - 0.57) * 2.8;
	position.z = 1;

	return position;
}



