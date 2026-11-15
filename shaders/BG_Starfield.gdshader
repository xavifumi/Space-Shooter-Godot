shader_type canvas_item;

uniform vec2 scroll = vec2(0.0);            // acumulado desde el script (píxeles)
uniform int layers : hint_range(1, 8) = 4;
uniform float min_speed = 0.1;              // capa lejana (estrellas pequeñas)
uniform float max_speed = 1.0;              // capa cercana (estrellas grandes)
uniform float cell_far = 40.0;              // tamaño de celda en px (más pequeña = más densa)
uniform float cell_near = 90.0;
uniform float star_chance : hint_range(0.0, 1.0) = 0.5;  // % de celdas con estrella
uniform float color_chance : hint_range(0.05, 0.10) = 0.08; // 5–10% de estrellas de color
uniform float twinkle : hint_range(0.0, 1.0) = 0.3;
uniform vec4 bg_color : source_color = vec4(0.0, 0.0, 0.02, 1.0);
uniform vec3 star_red : source_color = vec3(0.949, 0.0, 0.031);   // #f20008
uniform vec3 star_blue : source_color = vec3(0.0, 0.490, 0.969);  // #007df7

float hash(vec2 p, float seed) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031 + seed * 0.137);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
//vec3 col = bg_color.rgb;
vec3 col = vec3(0.0);
float alpha = 0.0;

	for (int i = 0; i < layers; i++) {
		float t = layers > 1 ? float(i) / float(layers - 1) : 1.0;
		float speed = mix(min_speed, max_speed, t);
		float cell = mix(cell_far, cell_near, t);
		float seed = float(i) * 17.0;

		vec2 p = (FRAGCOORD.xy + scroll * speed) / cell;
		vec2 id = floor(p);
		vec2 f = fract(p);

		if (hash(id, seed + 1.0) > star_chance) continue;

		// posición aleatoria dentro de la celda (con margen para no cortar la estrella)
		vec2 pos = vec2(hash(id, seed + 2.0), hash(id, seed + 3.0)) * 0.5 + 0.25;
		//float radius = mix(0.8, 2.4, t) * (0.6 + 0.8 * hash(id, seed + 4.0));
		//float d = length((f - pos) * cell);
		//float star = 1.0 - smoothstep(radius * 0.4, radius, d);
		// "radius" es la mitad del lado del cuadrado, en píxeles
		float radius = mix(0.6, 1.32, t) * (0.6 + 0.8 * hash(id, seed + 4.0));
		radius = max(radius, 0.5);                 // mínimo 1 px de lado para que no desaparezcan
		vec2 q = abs((f - pos) * cell);
		float d = max(q.x, q.y);                   // distancia de Chebyshev -> forma cuadrada
		float star = clamp(radius + 0.5 - d, 0.0, 1.0);  // borde con antialiasing de 1 px


		// parpadeo
		float phase = hash(id, seed + 7.0) * 6.2831;
		star *= 1.0 - twinkle * (0.5 + 0.5 * sin(TIME * (1.0 + 2.0 * hash(id, seed + 8.0)) + phase));

		// color: blanco, o rojo/azul con probabilidad color_chance
		vec3 sc = vec3(1.0);
		if (hash(id, seed + 5.0) < color_chance) {
			sc = hash(id, seed + 6.0) < 0.5 ? star_red : star_blue;
		}

		//col += sc * star * mix(0.5, 1.0, t);
		float a = star * mix(0.5, 1.0, t);
		col += sc * a;
		alpha = max(alpha, a);
	}

	//COLOR = vec4(col, 1.0);
	COLOR = vec4(min(col, vec3(1.0)), alpha);
}