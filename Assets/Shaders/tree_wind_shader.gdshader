shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Wind parameters
uniform float wind_strength : hint_range(0.0, 2.0) = 0.3;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.5);
uniform float wind_turbulence : hint_range(0.0, 1.0) = 0.5;

// Tree parameters
uniform float trunk_stiffness : hint_range(0.0, 1.0) = 0.8;
uniform float branch_stiffness : hint_range(0.0, 1.0) = 0.4;
uniform float detail_noise : hint_range(0.0, 1.0) = 0.3;

// Texture uniforms
uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_normal : hint_normal;
uniform float specular : hint_range(0.0, 1.0) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.7;

// Vertex function to calculate wind effect
vec3 apply_wind(vec3 vertex, vec3 normal, float time) {
    // Normalize wind direction
    vec2 normalized_wind_dir = normalize(wind_direction);
    
    // Calculate height factor (higher parts of the tree move more)
    float height_factor = vertex.y;
    
    // Calculate stiffness based on vertex height (trunk vs branches/leaves)
    float stiffness = mix(trunk_stiffness, branch_stiffness, smoothstep(0.0, 1.0, height_factor));
    
    // Calculate wind time
    float wind_time = time * wind_speed;
    
    // Main wind movement
    float main_wind = sin(wind_time + vertex.x * 0.1 + vertex.z * 0.1) * wind_strength;
    
    // Add turbulence/noise for more natural movement
    float noise1 = sin(wind_time * 1.3 + vertex.x * 0.5) * sin(wind_time * 0.7 + vertex.z * 0.3) * wind_turbulence;
    float noise2 = cos(wind_time * 0.5 + vertex.z * 0.2) * sin(wind_time * 0.6 + vertex.x * 0.3) * wind_turbulence;
    
    // Combine main wind and turbulence
    float wind_factor = main_wind + noise1 + noise2;
    
    // Apply detail noise for small movements
    float detail = sin(wind_time * 3.0 + vertex.x * 2.0 + vertex.z * 2.0) * detail_noise;
    
    // Calculate displacement
    vec3 displacement = vec3(
        normalized_wind_dir.x * wind_factor,
        0.0,  // Less vertical movement
        normalized_wind_dir.y * wind_factor
    );
    
    // Add small detail movement in all directions
    displacement += vec3(
        sin(wind_time * 5.0 + vertex.y * 2.0) * detail,
        sin(wind_time * 4.0 + vertex.x * 2.0) * detail * 0.5,
        cos(wind_time * 6.0 + vertex.z * 2.0) * detail
    );
    
    // Apply stiffness factor (reduces movement for trunk)
    displacement *= (1.0 - stiffness) * smoothstep(0.0, 0.5, height_factor);
    
    return vertex + displacement;
}

void vertex() {
    // Apply wind effect
    VERTEX = apply_wind(VERTEX, NORMAL, TIME);
}

void fragment() {
    // Basic PBR material setup
    vec4 albedo_tex = texture(texture_albedo, UV);
    ALBEDO = albedo_tex.rgb;
    
    // Apply normal mapping
    NORMAL_MAP = texture(texture_normal, UV).rgb;
    
    // Set material properties
    SPECULAR = specular;
    ROUGHNESS = roughness;
} 