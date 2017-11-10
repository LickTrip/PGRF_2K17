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
vec3 doFunctionTimer(vec2 uv);
vec3 doFunctionTimer2(vec2 uv);
vec3 doFunctionBean(vec2 uv);
vec3 doFunctionGlobe(vec2 uv);
vec3 doFunctionCarpet(vec2 uv);


void main() {
    vec4 positionMV = mMV * vec4(doMyFunctions(inPosition), 1);
	normal = inverse(transpose(mat3(mMV))) * doNormal(inPosition);
	lightDirection = lightSource - positionMV.xyz;
	viewDirection = - positionMV.xyz;
	dist = length(lightDirection);

	texCoord = inPosition;

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
        return doFunctionBean(uv);
    case 1:
        return doFunctionTimer(uv);
    case 2:
        return doFunctionTimer2(uv);
    case 3:
        return doFunctionEle(uv);
    case 4:
        return doFunctionGlobe(uv);
    case 5:
        return doFunctionCarpet(uv);
    }
    return doFunctionBean(uv);
}

vec3 doFunctionTimer(vec2 uv){
    vec3 position;

	//od -1 do 1 t
	float zen = uv.x * 2 - 1;
	//od 0 do 2pi s
	float az = uv.y * 2.0 * PI;
	float r = zen;

	position.x = r * zen * cos(az);
	position.y = r * zen * sin(az);
	position.z = r;

	return position;
}

vec3 doFunctionTimer2(vec2 uv){
    vec3 position;

	float zen = uv.x * 2 - 1;
	float az = uv.y * 2.0 * PI;
	float r = zen;

	position.x = r * cos(az);
	position.y = r * sin(az);
	position.z = r;

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

vec3 doFunctionBean(vec2 uv){
    vec3 position;

	//od 0 do pi t
	float zen = uv.x * PI;
	//od 0 do 2pi s
	float az = uv.y * 2.0 * PI;
	float r = zen;

	position.x = sin(r) * cos(az);
	position.y = 2*sin(r) * sin(az);
	position.z = cos(r);

	return position;
}

vec3 doFunctionGlobe(vec2 uv){
    vec3 position;

	//od 0 do pi t
	float zen = uv.x * PI;
	//od 0 do 2pi s
	float az = uv.y * 2.0 * PI;
	float r = zen;

	position.x = sin(r) * cos(az);
	position.y = sin(r) * sin(az);
	position.z = cos(r);

	return position;
}

vec3 doFunctionCarpet(vec2 uv){
    vec3 position;

	position.xy = (inPosition - 0.57) * 2.8;
	position.z = (4.5 * (cos(sqrt(8 * (inPosition.x * inPosition.x)+ 3 * (inPosition.y *  inPosition.y)+5))-0.5))+6;

	return position;
}


