shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

uniform float pixel_size : hint_range(0.0, 20.0, 1.0);
uniform float levels : hint_range(0.0, 2000.0, 1.0);
uniform vec2 gamma;

uniform float curvature = 5.0;
uniform float vignette_multiplier = 0.6;
uniform float test_scanlines = 5.0;

uniform sampler2D screen_texture: hint_screen_texture;



//void vertex() {
	//POSITION = vec4(VERTEX.xy,1.0,1.0);
//}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 tex_size = vec2(textureSize(screen_texture,0));
	vec2 pixel_count = tex_size / (pixel_size * 2.0);
	vec2 pixelated_uv = floor(SCREEN_UV * pixel_count) / pixel_count;
	vec4 color = texture(screen_texture,pixelated_uv);
	
	color.rgb = pow(color.rgb,vec3(gamma.x));
	
	
	float grayscale = max(color.r,max(color.g,color.b));
	float lower = floor(grayscale * levels)/levels;
	float higher = ceil(grayscale * levels)/levels;
	
	float lower_diff = abs(lower - grayscale);
	float higher_diff = abs(higher - grayscale);
	
	float level = lower_diff < higher_diff ? lower : higher;
	
	float adjustement = level / grayscale;
	
	color.rgb *= adjustement;
	color.rgb = pow(color.rgb,vec3(gamma.y));
	
	COLOR.xyz = color.rgb;
	COLOR.a = color.a;
	vec2 centered_uv = pixelated_uv * 2.0 - 1.0;
	vec2 uv_offset = centered_uv.yx / curvature;
	vec2 warped_uv = centered_uv + centered_uv * uv_offset * uv_offset;
	vec3 cutoff = vec3(step(abs(warped_uv.x), 1.0) * step(abs(warped_uv.y), 1.0));
	vec3 scanlines = vec3(sin(test_scanlines * warped_uv.y * 180.0) * 0.05 + 0.95);
	vec3 vignette = vec3(length(pow(abs(centered_uv), vec2(4.0)) / 3.0));

	vec3 screen_color = textureLod(screen_texture, (warped_uv + 1.0) / 2.0, 0.2).rgb * cutoff * scanlines;
	screen_color -= vignette * vignette_multiplier;
	//COLOR += vec4(screen_color, 1.0)/10.0;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
