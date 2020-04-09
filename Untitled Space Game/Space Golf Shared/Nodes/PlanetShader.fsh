void main() {
    vec4 defaultShading = SKDefaultShading();
    
    if (texture2D(u_texture, v_tex_coord).a > 0.0) {
        float d = min(1.0, distance(v_tex_coord, vec2(0.5, 0.5)) * 2.0);
        vec4 color = mix(u_start_color, u_end_color, d);
        float progress = sin(u_time * (3 / 2) * (1 / u_duration)) / 2 + 0.5;
        float alpha = mix(u_min_alpha, 1, progress);
        gl_FragColor = vec4(mix(defaultShading, color, color.a)) * alpha;
    } else {
        gl_FragColor = defaultShading;
    }
}
