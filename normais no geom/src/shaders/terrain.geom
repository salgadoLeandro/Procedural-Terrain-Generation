#version 420

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 m_pvm;

in Data {
	vec4 pos;
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

	float d = abs(dot(tnormal, vec3(0.0,1.0,0.0)));
	bool i = d < 0.225;
	//int id = int(i); 
	int ind = int(!i);
	vec4 rock = vec4(0.75,0.75,0.75,1.0) * int(i);

	for(int i = 0; i < 3; ++i){
		DataOut.normal = tnormal;
		DataOut.cor = max(rock, DataIn[i].cor * ind);
		gl_Position = m_pvm * DataIn[i].pos;
		EmitVertex();
	}
	EndPrimitive();
}