shader_type canvas_item;

uniform sampler2D mask_tex;
uniform vec2 mask_size;
uniform vec2 mask_pos;

void fragment() {
    // Convert screen UV to mask texture UV
    vec2 mask_uv = (SCREEN_UV - mask_pos) / mask_size;
    
    // Sample the mask texture
    vec4 mask_color = texture(mask_tex, mask_uv);

    // Discard pixels where mask is transparent
    if (mask_color.a < 0.1) {
        discard;
    }

    // Draw the texture normally
    COLOR = texture(TEXTURE, UV) * COLOR;
}