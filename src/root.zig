
const std = @import("std");
const Io = std.Io;

//igual se reuso del lab1
pub fn printAnotherMessage(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("Run `zig build test` to run the tests.\n", .{});
}

pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}



//realmente pues este archivo se puede borrar ya que lo genere cuando hice el zig init, el tema es que si lo borro tendria que modificar el build pero ya funciona todo por lo que lo voy a dejar y es indiferente ya que si funciona todo.