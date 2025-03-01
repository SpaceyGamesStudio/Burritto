shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Wind parameters
uniform float wind_strength : hint_range(0.0, 2.0) = 0.2;
uniform float wind_speed : hint_range(0.0, 5.0) = 0.8;
uniform vec2 wind_direction = vec2(1.0, 0.5);
uniform float wind_turbulence : hint_range(0.0, 1.0) = 0.3;

// Pine tree specific parameters
uniform float trunk_rigidity : hint_range(0.0, 1.0) = 0.9;
uniform float branch_flexibility : hint_range(0.0, 1.0) = 0.3;
uniform float needle_movement : hint_range(0.0, 1.0) = 0.5;
uniform float height_influence : hint_range(0.0, 2.0) = 1.2;

// Texture uniforms
uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_normal : hint_normal;
uniform float specular : hint_range(0.0, 1.0) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.7;

// Vertex function to calculate wind effect for pine trees
vec3 apply_pine_wind(vec3 vertex, vec3 normal, float time) {
    // Normalize wind direction
    vec2 normalized_wind_dir = normalize(wind_direction);
    
    // Calculate height factor with more influence at the top
    float height_factor = pow(vertex.y * height_influence, 1.5);
    
    // Calculate stiffness based on vertex height (trunk vs branches/needles)
    float stiffness = mix(trunk_rigidity, branch_flexibility, smoothstep(0.0, 1.0, height_factor));
    
    // Calculate wind time
    float wind_time = time * wind_speed;
    
    // Main wind movement - pines tend to sway more as a whole unit
    float main_wind = sin(wind_time + vertex.x * 0.05 + vertex.z * 0.05) * wind_strength;
    
    // Add turbulence/noise for more natural movement
    float noise1 = sin(wind_time * 1.1 + vertex.x * 0.3) * sin(wind_time * 0.5 + vertex.z * 0.2) * wind_turbulence;
    float noise2 = cos(wind_time * 0.7 + vertex.z * 0.1) * sin(wind_time * 0.4 + vertex.x * 0.2) * wind_turbulence;
    
    // Combine main wind and turbulence
    float wind_factor = main_wind + noise1 + noise2;
    
    // Pine needle movement (higher frequency, smaller amplitude)
    float needle_factor = sin(wind_time * 4.0 + vertex.x * 3.0 + vertex.z * 3.0) * needle_movement * 0.1;
    
    // Calculate displacement - pines tend to sway more as a whole
    vec3 displacement = vec3(
        normalized_wind_dir.x * wind_factor,
        0.0,  // Less vertical movement
        normalized_wind_dir.y * wind_factor
    );
    
    // Add small needle movement in all directions
    displacement += vec3(
        sin(wind_time * 6.0 + vertex.y * 3.0) * needle_factor,
        sin(wind_time * 5.5 + vertex.x * 3.0) * needle_factor * 0.3,
        cos(wind_time * 7.0 + vertex.z * 3.0) * needle_factor
    );
    
    // Apply stiffness factor (reduces movement for trunk)
    // Pine trees have a more rigid structure, so movement increases more sharply with height
    displacement *= (1.0 - stiffness) * smoothstep(0.1, 0.6, height_factor);
    
    return vertex + displacement;
}

void vertex() {
    // Apply wind effect
    VERTEX = apply_pine_wind(VERTEX, NORMAL, TIME);
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