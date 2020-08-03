#version 450 core
in vec3 color;
in vec3 normal;
uniform vec3 lightDir;
uniform vec3 ambientLight;
out vec4 out_Color;
void main()
{
	out_Color = vec4(color * clamp(dot(normal, normalize(-lightDir)), 0.0, 1.0) + ambientLight, 1.0);
}//