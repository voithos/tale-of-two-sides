shader_type canvas_item;


const vec3 epsilon = vec3(0.01, 0.01, 0.01);

const vec3 max_hex = vec3(0xff, 0xff, 0xff);

// Floor colors.
//4b9645
//2a812f
//1d6b2b
//543524
const vec3 gf1 = vec3(0x4b, 0x96, 0x45) / max_hex;
const vec3 gf2 = vec3(0x2a, 0x81, 0x2f) / max_hex;
const vec3 gf3 = vec3(0x1d, 0x6b, 0x2b) / max_hex;
const vec3 gf4 = vec3(0x54, 0x35, 0x24) / max_hex;

// Ceiling colors.
//805f4b
//5c3629
//694433
//a3846c
const vec3 gc1 = vec3(0x80, 0x5f, 0x4b) / max_hex;
const vec3 gc2 = vec3(0x5c, 0x36, 0x29) / max_hex;
const vec3 gc3 = vec3(0x69, 0x44, 0x33) / max_hex;
const vec3 gc4 = vec3(0xa3, 0x84, 0x6c) / max_hex;

// Interior colors.
//82664b
//73553f
const vec3 gi1 = vec3(0x82, 0x66, 0x4b) / max_hex;
const vec3 gi2 = vec3(0x73, 0x55, 0x3f) / max_hex;

// Floor colors.
//ebeb7df
//e6dac3
//d4c3a7
//c2ae8f
const vec3 tf1 = vec3(0xeb, 0xeb, 0x7d) / max_hex;
const vec3 tf2 = vec3(0xe6, 0xda, 0xc3) / max_hex;
const vec3 tf3 = vec3(0xd4, 0xc3, 0xa7) / max_hex;
const vec3 tf4 = vec3(0xc2, 0xae, 0x8f) / max_hex;

// Ceiling colors.
//ebe4df
//e6d0c3
//d4b6a7
//c29f8f
//b38e81
const vec3 tc1 = vec3(0xeb, 0xe4, 0xdf) / max_hex;
const vec3 tc2 = vec3(0xe6, 0xd0, 0xc3) / max_hex;
const vec3 tc3 = vec3(0xd4, 0xb6, 0xa7) / max_hex;
const vec3 tc4 = vec3(0xc2, 0x9f, 0x8f) / max_hex;
const vec3 tc5 = vec3(0xb3, 0x8e, 0x81) / max_hex;

// Interior marble colors.
//ede7df
//e8d7c5
//d6bca7
//c2a58f
//b59782
const vec3 ti1 = vec3(0xed, 0xe7, 0xdf) / max_hex;
const vec3 ti2 = vec3(0xe8, 0xd7, 0xc5) / max_hex;
const vec3 ti3 = vec3(0xd6, 0xbc, 0xa7) / max_hex;
const vec3 ti4 = vec3(0xc2, 0xa5, 0x8f) / max_hex;
const vec3 ti5 = vec3(0xb5, 0x97, 0x82) / max_hex;

// Mortar colors.
//a0afad
//878896
//707282
const vec3 tm1 = vec3(0xa0, 0xaf, 0xad) / max_hex;
const vec3 tm2 = vec3(0x87, 0x88, 0x96) / max_hex;
const vec3 tm3 = vec3(0x70, 0x72, 0x82) / max_hex;


uniform float floor_saturation;
uniform float ceiling_saturation;

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    
    // Modulate.
    
//    vec4 tint_color = vec4(0.0, 0.0, 0.0, 1.0);
//    COLOR = texture_color * tint_color;
    
    // Desaturate.
    
    // Different color channels contribute different weights to brightness, so
    // we scale their saturation with different weights.
//    COLOR.rgb = mix(
//            vec3(dot(texture_color.rgb, vec3(0.299, 0.587, 0.114))),
//            texture_color.rgb,
//            saturation);
//    COLOR.a = texture_color.a;
    
    // 
    
    float saturation;
    if (all(greaterThan(epsilon, abs(texture_color.rgb - gf1))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - gf2))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - gf3))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - gf4))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tf1))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tf2))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tf3))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tf4)))) {
        saturation = floor_saturation;
    } else if (all(greaterThan(epsilon, abs(texture_color.rgb - gc1))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - gc2))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - gc3))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - gc4))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tc1))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tc2))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tc3))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tc4))) ||
            all(greaterThan(epsilon, abs(texture_color.rgb - tc5)))) {
        saturation = ceiling_saturation;
    } else {
        saturation = 1.0;
    }
    COLOR.rgb = mix(
            vec3(dot(texture_color.rgb, vec3(0.299, 0.587, 0.114))),
            texture_color.rgb,
            saturation);
    COLOR.a = texture_color.a;
}