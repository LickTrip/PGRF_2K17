#version 150
in vec2 inPosition; // input from the vertex buffer
//in vec2 inTextureCoordinates;
//in vec3 inColor; // input from the vertex buffer
//out vec3 vertColor; // output from this shader to the next pipeline stage

varying vec3 normal;
varying vec3 lightDirection;
varying vec3 viewDirection;
varying float dist;

varying vec2 texCoord;

//uniform float time; // variable constant for all vertices in a single draw
uniform mat4 mMV;
uniform mat4 mProj;
uniform int functionType;

//const
const float PI = 3.1415926;
const vec3 lightSource = vec3(-3.5, 3.0, 3.0);

//functions
vec3 doMyFunctions(vec2 uv);
vec3 doNormal(vec2 uv);
vec3 doFunctionEle(vec2 uv);
vec3 doFunctionDonut(vec2 uv);
vec3 doFunctionThing(vec2 uv);
vec3 doFunctionBean(vec2 uv);
vec3 doFunctionGlobe(vec2 uv);
vec3 doFunctionCarpet(vec2 uv);
vec3 doFunctionSombrero(vec2 uv);
vec3 doFunctionVase(vec2 uv);


void main() {
    vec3 funcPos = doMyFunctions(inPosition);
    vec4 positionMV = mMV * vec4(funcPos, 1);
	normal = inverse(transpose(mat3(mMV))) * doNormal(inPosition);
	lightDirection = lightSource - positionMV.xyz;
	viewDirection = - positionMV.xyz;
	dist = length(lightDirection);

    if(functionType == 0 || functionType == 1){
        vec2 shereText = vec2((atan(funcPos.y, funcPos.x) / PI + 1.0), 1.0 - acos(funcPos.z) / PI);
        texCoord = shereText;
    }
    else{
	    texCoord = inPosition;
	}

	gl_Position = mProj * mMV * vec4(doMyFunctions(inPosition), 1);
}

//normala pro stinovani barvy
vec3 doNormal(vec2 uv){
	const float delta = 0.001;
	vec3 du = doMyFunctions(vec2(uv.x + delta, uv.y)) - doMyFunctions(vec2(uv.x - delta, uv.y));
	vec3 dv = doMyFunctions(vec2(uv.x, uv.y + delta)) - doMyFunctions(vec2(uv.x, uv.y - delta));

	return normalize(cross(du,dv)); //normalizovat aby byla videt barva
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
    vec2 myPosition = inPosition.xy;

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



