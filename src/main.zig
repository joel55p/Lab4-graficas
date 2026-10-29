const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const fb = @import("framebuffer.zig");
const obj = @import("obj.zig");
const Point = fb.Point;

/// Convierte un vertice 3D del monito a coordenadas 2D de pantalla
fn project(v: obj.Vec3, scale: f32, offset_x: f32, offset_y: f32) Point {
    return Point{
        .x = @intFromFloat(@round(v.x * scale + offset_x)),
        // en pantalla el eje Y crece hacia abajo, por eso usamos -v.y pa verlo derecho
        .y = @intFromFloat(@round(-v.y * scale + offset_y)),
    };
}

/// Recorre todas las caras del monito y dibuja aristas
fn draw_wireframe(framebuffer: *fb.Framebuffer, model: obj.Model, scale: f32, offset_x: f32, offset_y: f32, color: rl.Color) void {
    for (model.faces.items) |face| {
        const v0 = model.vertices.items[face[0]];
        const v1 = model.vertices.items[face[1]];
        const v2 = model.vertices.items[face[2]];

        const triangle = [_]Point{
            project(v0, scale, offset_x, offset_y),
            project(v1, scale, offset_x, offset_y),
            project(v2, scale, offset_x, offset_y),
        };

        framebuffer.draw_polygon_outline(&triangle, color);
    }
}

pub fn main() !void {
    const width = 800;
    const height = 600;
    const allocator = std.heap.page_allocator;

    // Cargamos el modelo triangulo que se hizo en blender osea el monito
    var model = try obj.Model.load(allocator, "Suzanne.obj");
    defer model.deinit(allocator);

    var framebuffer = fb.Framebuffer.init(width, height, rl.BLACK);

    rl.InitWindow(width, height, "Lab 4 Carga de Modelos (Wireframe monito de blender)");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    // Escala y posicion para centrar a mono en ventana de 800x600
    const scale: f32 = 220.0;
    const offset_x: f32 = @as(f32, @floatFromInt(width)) / 2.0;
    const offset_y: f32 = @as(f32, @floatFromInt(height)) / 2.0;

    var exported = false;

    while (!rl.WindowShouldClose()) {
        framebuffer.clear();

        draw_wireframe(&framebuffer, model, scale, offset_x, offset_y, rl.WHITE);

        if (!exported) {
            framebuffer.export_image("out.bmp");
            framebuffer.export_image("out.png");
            exported = true;
        }

        framebuffer.swap();
    }
}
