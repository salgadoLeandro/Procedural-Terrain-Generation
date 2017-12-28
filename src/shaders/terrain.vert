#version 420

uniform mat3 m_normal;

in vec4 position;
in vec3 normal;

out Data {
	vec4 pos;
	vec3 normal;
	vec4 cor;
} DataOut;

vec3 permute(vec3 v){
	return mod((((v * 34.0) + 1.0) * v), 289.0);
}

float sperlin(vec2 pos){
	const vec4 C = vec4(0.5*(sqrt(3.0)-1.0),
						(3.0-sqrt(3.0)/6.0),
						-1.0 + 2.0 * (3.0-sqrt(3.0)/6.0),
						1.0/41.0);

	//first corner
	vec2 i = floor(pos + dot(pos, C.yy));
	vec2 x0 = pos - (i - dot(i, C.xx));

	//other corners
	vec2 i1;
	i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;
	
	//permutations
	i = mod(i, 289.0);
	vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
	vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m *= m;
	m *= m;

	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;

	//normalize gradients implicitly by scaling m
	//approximation of: m *= inversesqrt(a0 * a0 + h * h)
	m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

	//final noise value at p
	vec3 g;
	g.x = a0.x * x0.x + h.x * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	return 130.0 * dot(m, g);
}

float turbulence(vec2 pos){
    float noise = 0.0;
    float maxAmplitude = 0.0;
    float amplitude = 22.0;
    float frequency = 2.0;
    float persitence = 0.03125;

	for(int i = 0; i < 6; ++i){
		noise += amplitude * sperlin(pos * frequency);
		frequency *= 2;
		maxAmplitude += amplitude;
		amplitude *= persitence;
	}

	return abs(noise)/maxAmplitude;
}

void main() {
	DataOut.normal = normalize(m_normal * normal);
	DataOut.pos = vec4(position.x, turbulence(position.xz), position.z, 1);
	DataOut.cor = (DataOut.pos.y < 0) ? vec4(0.0, 0.1, 1.0, 1.0) : vec4(0.0,1.0,0.0,1.0);
	gl_Position = DataOut.pos;
}