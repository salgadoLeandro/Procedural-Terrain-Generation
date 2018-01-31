#version 420

uniform mat4 m_view;
uniform mat3 m_normal;
uniform vec4 l_dir;

in Data {
	vec3 normal;
	vec4 cor;
} DataIn;

out vec4 cOut;

void main() {
	vec3 n = normalize(m_normal * DataIn.normal);
	vec3 ld = normalize(vec3(m_view * -l_dir));
	int s = int(DataIn.cor == vec4(1.0));
	float intensity = max(dot(n, ld), 0.3 + (0.05 * s));
	cOut = intensity * DataIn.cor;
}