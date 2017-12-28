#version 420

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 m_pvm;

in Data {
	vec4 pos;
	vec3 normal;
	vec4 cor;
} DataIn[3];

out Data {
	vec3 normal;
	vec4 cor;
} DataOut;

void main(){
	
	vec3 v1 = vec3(DataIn[2].pos - DataIn[0].pos);
	vec3 v2 = vec3(DataIn[1].pos - DataIn[0].pos);
	vec3 tnormal = normalize(cross(v1, v2));

	for(int i = 0; i < 3; ++i){
		DataOut.normal = tnormal;
		DataOut.cor = DataIn[i].cor;
		gl_Position = m_pvm * DataIn[i].pos;
		EmitVertex();
	}
	EndPrimitive();
}