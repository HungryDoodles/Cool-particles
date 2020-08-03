#version 450 core
uniform mat4 MVP;
in vec3 vPos;
out vec3 color;
out vec3 normal;
uniform float time;
const float a = 0.04;
const float b = 30.0;
const float c = 0.05;
void main()
{
	float len = length(vPos.xy);
	float height = cos((len + time * a) * b) * c;
    gl_Position = MVP * vec4(vPos.xy, height, 1.0);

	if(len != 0)
	normal = normalize(
		vec3(b * vPos.x / len*(sin((len + time*a)*b)*c), 
		1.0, 
		b * vPos.y / len*(sin((len + time*a)*b)*c) ) );
	else normal = vec3(0, 1, 0);

    color = mix(vec3(0.8, 0.1, 0.0), vec3(0.05, 0.3, 0.9), height + 1.0);
}//