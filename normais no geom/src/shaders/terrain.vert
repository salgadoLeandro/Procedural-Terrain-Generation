#version 420

uniform mat3 m_normal;
uniform vec4 camera_pos;

in vec4 position;

out Data {
	vec4 pos;
	vec4 cor;
} DataOut;

vec2 gt(float x, float y){
	bool s = x > y;
	return vec2(int(s), int(!s));
}

vec4 color(float height, float snow){
	bool r = height < 0.0;
	int nr = int(!r);
	int s = int(height > snow);
	return vec4(s, max(nr, s), max(int(r), s), height * nr);
}

vec3 permute(vec3 v){
	return mod((((v * 34.0) + 1.0) * v), 289.0);
}

float sperlin(vec2 pos){
	const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                       -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0

	//first corner
	vec2 i = floor(pos + dot(pos, C.yy));
	vec2 x0 = pos - (i - dot(i, C.xx));

	//other corners
	vec2 i1 = gt(x0.x, x0.y);
	vec4 x12 = x0.xyxy + C.xxzz;
	x12.xy -= i1;
	
	//permutations
	i = mod(i, 289.0);
	vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
	vec3 m = max(0.5 - vec3(dot(x0, x0), dot(x12.xy, x12.xy), dot(x12.zw, x12.zw)), 0.0);
	m = m * m;
	m = m * m;

	vec3 x = 2.0 * fract(p * C.www) - 1.0;
	vec3 h = abs(x) - 0.5;
	vec3 ox = floor(x + 0.5);
	vec3 a0 = x - ox;

	//approximation of: m *= inversesqrt(a0 * a0 + h * h)
	m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);

	//final noise value at p
	vec3 g;
	g.x = a0.x * x0.x + h.x * x0.y;
	g.yz = a0.yz * x12.xz + h.yz * x12.yw;
	return 420 * dot(m, g);
}

float turbulence(vec2 pos, int octaves){
    float noise = 0.0;
    float maxAmplitude = 0.0;
    float amplitude = 22.0;
    float frequency = 0.003;
    float persitence = 0.6;

	for(int i = 0; i < octaves; ++i){
		noise += amplitude * sperlin(pos * frequency);
		frequency *= 2;
		maxAmplitude += amplitude;
		amplitude *= persitence;
	}

	return ((abs(noise)/maxAmplitude) - 0.2) * 30;
}

void main() {
	vec2 cam = floor(camera_pos.xz);

	vec4 pos = vec4(position.x + cam.x, position.y, position.z + cam.y, 1.0);
	
	DataOut.pos = vec4(pos.x, turbulence(pos.xz, 8), pos.z, 1.0);

	vec4 color = color(DataOut.pos.y, 45.0);
	DataOut.cor = vec4(color.rgb, 1.0);
	DataOut.pos.y = color.a;
	gl_Position = DataOut.pos;
}