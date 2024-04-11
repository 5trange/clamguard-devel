const std = @import("std");
const buildin = @import("builtin");
const unicode = std.unicode;
const tag = buildin.os.tag;
const join = std.fs.path.join;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "engine",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    switch (tag) {
        .windows => {
            const clamav_path = b.env_map.get("CLAMAV_DIR") orelse "C:\\clamav";
            std.debug.print("clamav path is {s}\n", .{clamav_path});
            const clamav_include_raw = std.fmt.allocPrint(b.allocator, "{s}\\include", .{clamav_path});
            const clamav_include = clamav_include_raw catch "C:\\clamav\\include";
            defer b.allocator.free(clamav_include);

            exe.addIncludePath(clamav_include);
            exe.addLibraryPath(clamav_path);

            const openssl_path = b.env_map.get("OPENSSLDIR") orelse "C:\\openssl";
            std.debug.print("openssl path is {s}\n", .{openssl_path});
            const openssl_lib_raw = std.fmt.allocPrint(b.allocator, "{s}\\lib", .{openssl_path});
            const openssl_lib = openssl_lib_raw catch "C:\\openssl\\lib";
            defer b.allocator.free(openssl_lib);
            const openssl_include_raw = std.fmt.allocPrint(b.allocator, "{s}\\include", .{openssl_path});
            const openssl_include = openssl_include_raw catch "C:\\openssl\\include";
            defer b.allocator.free(openssl_include);

            exe.addLibraryPath(openssl_lib);
            exe.addIncludePath(openssl_include);

            exe.linkSystemLibrary("libssl");
        },
        else => {},
    }

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("clamav");
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
