const std = @import("std");
const rl = @import("raylib_c.zig").raylib;

// Representa un vertice en 3D en x, y, z del monito
pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,
};

// Cada cara osea triangulo guarda los 3 puntos  que se conectan entre ellos
pub const Face = [3]usize;

/// De un bloque toma solo el primer numero  y le resta 1
fn leerIndiceVertice(bloque: []const u8) !usize {
    var partes = std.mem.splitScalar(u8, bloque, '/');
    const numero = try std.fmt.parseInt(usize, partes.next().?, 10);
    return numero - 1; // en el objeto cuentan desde 1 pero aqui desde 0
}

pub const Model = struct {
    vertices: std.ArrayList(Vec3),
    faces: std.ArrayList(Face),

    pub fn load(allocator: std.mem.Allocator, path: [*c]const u8) !Model {
        const raw_text = rl.LoadFileText(path);
        if (raw_text == null) return error.FileNotFound;
        defer rl.UnloadFileText(raw_text);

        const content = std.mem.span(raw_text);

        var vertices: std.ArrayList(Vec3) = .empty;
        var faces: std.ArrayList(Face) = .empty;

        var lines = std.mem.splitScalar(u8, content, '\n');
        while (lines.next()) |raw_line| {
            const line = std.mem.trim(u8, raw_line, " \r\t");
            if (line.len == 0 or line[0] == '#') continue;

            // En el .obj, las lineas que empiezan con "v " son puntos
            if (std.mem.startsWith(u8, line, "v ")) {
                var partes = std.mem.tokenizeScalar(u8, line[2..], ' ');
                const x = try std.fmt.parseFloat(f32, partes.next().?);
                const y = try std.fmt.parseFloat(f32, partes.next().?);
                const z = try std.fmt.parseFloat(f32, partes.next().?);
                try vertices.append(allocator, .{ .x = x, .y = y, .z = z });
            }
            // Las lineas que empiezan con "f " son los triangulos
            else if (std.mem.startsWith(u8, line, "f ")) {
                var partes = std.mem.tokenizeScalar(u8, line[2..], ' ');
                const v1 = try leerIndiceVertice(partes.next().?);
                const v2 = try leerIndiceVertice(partes.next().?);
                const v3 = try leerIndiceVertice(partes.next().?);
                try faces.append(allocator, .{ v1, v2, v3 });
            }
        }

        return Model{
            .vertices = vertices,
            .faces = faces,
        };
    }

    pub fn deinit(self: *Model, allocator: std.mem.Allocator) void {
        self.vertices.deinit(allocator);
        self.faces.deinit(allocator);
    }
};
