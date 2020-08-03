#version 450 core
uniform mat4 MVP;
uniform float deltaTime;
uniform float time;
uniform vec4 attraction;
out float alpha;
out float vel;

struct particle_t 
{
	vec3 pos;
	vec3 vel;
};

layout(std430, binding = 0) buffer particles
{
	particle_t particle[];
};

vec4 hash(vec3 coord)
{
	//    gridcell is assumed to be an integer coordinate
	const vec3 OFFSET = vec3(26.0, 161.0, 2166.0);
	const float DOMAIN = 71.0;
	const float SOMELARGEFLOAT = 951.135664;
	vec4 P = vec4(coord.xyz, length(coord.xyz) + 1.0);
	P = P - floor(P * (1.0 / DOMAIN)) * DOMAIN;    //    truncate the domain
	P += OFFSET.xyxy;                                //    offset to interesting part of the noise
	P *= P;                                          //    calculate and return the hash
	return fract(P.xzxz * P.yyww * (1.0 / SOMELARGEFLOAT.x).xxxx);
}

void Compute(int index) 
{
	particle_t p = particle[index]; // Local data

	// Use safe attraction to sphere

	float coef1 = length(p.pos) - 1.0;
	float coef2 = 1 / (length(p.pos) * length(p.pos) + 1);
	vec3 sphere1 = p.pos * coef1 * 10.0 * deltaTime ; // Attract sphere
	vec3 sphere2 = p.pos * coef2 * 2.0 * deltaTime;
	p.vel -= mix(sphere1, sphere2, sin(time*0.5));

	//Orbiting
	p.vel += normalize(cross(p.pos, vec3(0, 0, 1))) * 0.5 * deltaTime / coef1 * 0.7;


	// Vertical distribution
	p.vel.z += (sign(p.vel.z) * 0.8 * (abs(p.vel.z) + 1) + (sin(p.vel.x * p.pos.y * 10 + time) + sin(p.vel.y * p.pos.x * 10 + 1.71 * time)) * 0.1)  * deltaTime; // Huge pseudorandom movement

	// Hashmap shift
	vec3 modPos = floor(p.pos * (length(p.pos) - 0.9) * 100 + vec3(1,1,1));
	//p.vel += vec3(hash(p.pos).x, hash(p.pos + vec3(1,1156,456)).y, hash(p.pos + vec3(100,561,65)).z) * 10.0 * deltaTime;
	p.vel = mix(p.vel, mix(vec3(-1,-1,-1), vec3(1,1,1), hash(modPos).xyz) * 150.0 * deltaTime, 0.02);

	//Pulse
	//if (fract(time * 0.1) < deltaTime * 0.25)
	{
		vec3 addVec = p.pos * 5.0 / (2+coef1);
		addVec += (hash(p.pos * 100).xyz - vec3(1.0, 1.0, 1.0)) * 1.0;
		p.vel *= (1.0 + addVec * pow(abs(sin(time*5.0)), 100.0)*0.0);
	}

	if(deltaTime != 0) p.vel *= pow(abs(sin(time*0.5)*0.5+0.5)*0.8 + 0.19, deltaTime / 0.01666666);// Drag
	//if (deltaTime != 0) p.vel *= pow(0.89, deltaTime / 0.01666666);// Drag

	particle[index].pos = p.pos + p.vel * deltaTime;
	particle[index].vel = p.vel;
}

void main()
{
	bool compute = (gl_VertexID % 2) == 0;

	if (compute) 
	{
		Compute(gl_VertexID / 2);
		gl_Position = MVP * vec4(particle[gl_VertexID/2].pos, 1.0);
		alpha = 1.0;
	}
	else
	{
		Compute(gl_VertexID / 2);
		gl_Position = MVP * vec4(particle[gl_VertexID/2].pos + particle[gl_VertexID / 2].vel * 0.05, 1.0);
		alpha = 0.0;
	}
	vel = length(particle[gl_VertexID / 2].vel);
}//