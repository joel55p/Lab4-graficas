const rl = @import("raylib_c.zig").raylib;

pub const Point = struct {
    x: i32,
    y: i32,
};

pub const Framebuffer = struct {
    width: i32,
    height: i32,
    image: rl.Image,
    texture: ?rl.Texture2D,
    background_color: rl.Color,

    pub fn init(width: i32, height: i32, color: rl.Color) Framebuffer {
        return Framebuffer{
            .width = width,
            .height = height,
            .image = rl.GenImageColor(width, height, color),
            .background_color = color,
            .texture = null,
        };
    }

    /// Pone un pixel usando coordenadas enteras e ignora coordenadas fuera de la ventana
    pub fn draw_pixel_i32(self: *Framebuffer, x: i32, y: i32, color: rl.Color) void {
        if (x < 0 or y < 0 or x >= self.width or y >= self.height) return;
        rl.ImageDrawPixel(&self.image, x, y, color);
    }

    /// Algoritmo de Bresenham que tambien del lab1  para dibujar una linea entre dos puntos enteros
    pub fn draw_line_i32(self: *Framebuffer, x0: i32, y0: i32, x1: i32, y1: i32, color: rl.Color) void {
        var x = x0;
        var y = y0;
        const dx: i32 = @intCast(@abs(x1 - x0));
        const dy: i32 = -@as(i32, @intCast(@abs(y1 - y0)));
        const step_x: i32 = if (x0 < x1) 1 else -1;
        const step_y: i32 = if (y0 < y1) 1 else -1;
        var err: i32 = dx + dy;

        while (true) {
            self.draw_pixel_i32(x, y, color);

            if (x == x1 and y == y1) break;

            const e2 = 2 * err;
            if (e2 >= dy) {
                err += dy;
                x += step_x;
            }
            if (e2 <= dx) {
                err += dx;
                y += step_y;
            }
        }
    }

    /// Dibuja el contorno (q es orilla) de un poligono, conectando cada punto  con el siguiente y cerrando la figura (ultimo punto ahora es  primer punto)
    pub fn draw_polygon_outline(self: *Framebuffer, points: []const Point, color: rl.Color) void {
        const n = points.len;
        if (n < 2) return;

        var i: usize = 0;
        while (i < n) : (i += 1) {
            const j = (i + 1) % n;
            self.draw_line_i32(points[i].x, points[i].y, points[j].x, points[j].y, color);
        }
    }

    /// Exporta el framebuffer actual a un archivo de imagen
    pub fn export_image(self: *Framebuffer, path: [*c]const u8) void {
        _ = rl.ExportImage(self.image, path);
    }

    pub fn clear(self: *Framebuffer) void {
        rl.ImageClearBackground(&self.image, self.background_color);
        if (self.texture) |texture| {
            rl.UnloadTexture(texture);
        }
    }

    pub fn swap(self: *Framebuffer) void {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        self.texture = rl.LoadTextureFromImage(self.image);
        rl.DrawTexture(self.texture.?, 0, 0, rl.WHITE);
    }
};
