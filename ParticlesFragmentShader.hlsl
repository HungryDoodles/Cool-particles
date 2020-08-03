#version 450 core
in float alpha;
in float vel;
out vec4 out_Color;
uniform vec3 ambientLight;
void main()
{
	float transpAlpha = (1 - abs(alpha * 2 - 1)) * 2.0;
	float transparency = 0.02*transpAlpha;
	//float transparency = alpha * 0.2;
	out_Color = mix(vec4(transparency * 0.1, transparency * 0.3, transparency, 1.0), vec4(transparency, transparency * 0.4, transparency * 0.01, 1.0), clamp(0.5+sin(vel*3.14159)*0.5, 0, 1));
	//out_Color = mix(vec4(0.0, 0.0, transparency, 1.0), vec4(transparency, 0.0, 0.0, 1.0), alpha);
	//out_Color = vec4(0.1, 0.3, 1.0, 1.0);
}//