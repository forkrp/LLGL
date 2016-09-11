// GLSL tessellation evaluation shader
#version 400

// Tessellation evaluation input configuration
layout(quads, fractional_odd_spacing, cw) in;

// Uniform buffer object (also named "Constant Buffer")
layout(std140) uniform Settings
{
	mat4 projectionMatrix;
	mat4 viewMatrix;
	mat4 worldMatrix;
	float tessLevelInner;
	float tessLevelOuter;
	float twist;
	float _pad0;
};

// Input and output attributes
in vec3 tcPosition[];
out vec3 teColor;

// Vertex shader main function
void main()
{
	// Interpolate position
	float u = gl_TessCoord.x;
	float v = gl_TessCoord.y;
	
	vec3 a = mix(tcPosition[0], tcPosition[1], u);
	vec3 b = mix(tcPosition[2], tcPosition[3], u);
	
	vec3 position = mix(a, b, v);
	
	// Apply twist rotation matrix (rotate around Y axis)
	float twistFactor = (position.y + 1.0) * 0.5;
	
	float s = sin(twist * twistFactor);
	float c = cos(twist * twistFactor);
	
	mat3 rotation = mat3(
		 c, 0, s,
		 0, 1, 0,
		-s, 0, c
	);
	
	position = rotation * position;
	
	// Transform vertex by the world-view-projection matrix chain
	gl_Position = projectionMatrix * viewMatrix * worldMatrix * vec4(position, 1);
	teColor = (1.0 - position) * 0.5;
}
