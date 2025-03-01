shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Wind parameters
uniform float wind_strength : hint_range(0.0, 2.0) = 0.15;
uniform float wind_speed : hint_range(0.0, 5.0) = 0.7;
uniform vec2 wind_direction = vec2(1.0, 0.5);
uniform float wind_turbulence : hint_range(0.0, 1.0) = 0.2;

// Dead tree specific parameters
uniform float trunk_rigidity : hint_range(0.0, 1.0) = 0.95;
uniform float branch_rigidity : hint_range(0.0, 1.0) = 0.7;
uniform float creaking_effect : hint_range(0.0, 1.0) = 0.3;
uniform float height_influence : hint_range(0.0, 2.0) = 1.0;

// Texture uniforms
uniform sampler2D texture_albedo : source_color;
uniform sampler2D texture_normal : hint_normal;
uniform float specular : hint_range(0.0, 1.0) = 0.3;
uniform float roughness : hint_range(0.0, 1.0) = 0.9;

// Vertex function to calculate wind effect for dead trees
vec3 apply_dead_tree_wind(vec3 vertex, vec3 normal, float time) {
    // Normalize wind direction
    vec2 normalized_wind_dir = normalize(wind_direction);
    
    // Calculate height factor
    float height_factor = vertex.y * height_influence;
    
    // Calculate rigidity based on vertex height (trunk vs branches)
    float rigidity = mix(trunk_rigidity, branch_rigidity, smoothstep(0.0, 1.0, height_factor));
    
    // Calculate wind time
    float wind_time = time * wind_speed;
    
    // Main wind movement - dead trees move less fluidly
    float main_wind = sin(wind_time + vertex.x * 0.03 + vertex.z * 0.03) * wind_strength;
    
    // Add turbulence/noise for more natural movement
    float noise1 = sin(wind_time * 0.9 + vertex.x * 0.2) * sin(wind_time * 0.4 + vertex.z * 0.1) * wind_turbulence;
    float noise2 = cos(wind_time * 0.6 + vertex.z * 0.1) * sin(wind_time * 0.3 + vertex.x * 0.1) * wind_turbulence;
    
    // Combine main wind and turbulence
    float wind_factor = main_wind + noise1 + noise2;
    
    // Creaking effect - sudden small movements
    float creaking = 0.0;
    if (sin(wind_time * 0.2) > 0.8) {
        creaking = sin(wind_time * 10.0 + vertex.x * 5.0 + vertex.z * 5.0) * creaking_effect * 0.05;
    }
    
    // Calculate displacement - dead trees move more rigidly
    vec3 displacement = vec3(
        normalized_wind_dir.x * wind_factor,
        0.0,  // Less vertical movement
        normalized_wind_dir.y * wind_factor
    );
    
    // Add creaking movement
    displacement += vec3(
        sin(wind_time * 8.0 + vertex.y * 4.0) * creaking,
        sin(wind_time * 7.5 + vertex.x * 4.0) * creaking * 0.2,
        cos(wind_time * 9.0 + vertex.z * 4.0) * creaking
    );
    
    // Apply rigidity factor (reduces movement for trunk and branches)
    // Dead trees are more rigid overall
    displacement *= (1.0 - rigidity) * smoothstep(0.0, 0.7, height_factor);
    
    return vertex + displacement;
}

void vertex() {
    // Apply wind effect
    VERTEX = apply_dead_tree_wind(VERTEX, NORMAL, TIME);
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