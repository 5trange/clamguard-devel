const std = @import("std");
const buildin = @import("builtin");
const unicode = std.unicode;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "engine",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    switch (target.result.os.tag) {
        .windows => {
            const clamav_path = std.process.getEnvVarOwned(b.allocator, "CLAMAV_PATH") catch |err| {
                std.debug.print("ERROR : {}", .{err});
                return;
            };
            defer b.allocator.free(clamav_path);
            const clamav_header_path = std.fmt.allocPrint(b.allocator, "{s}\\include", .{clamav_path}) catch |err| {
                std.debug.print("ERROR : failed to allocate the string in clamav_header_path : {}", .{err});
                return;
            };
            defer b.allocator.free(clamav_header_path);

            exe.addIncludePath(.{ .path = clamav_header_path });
            exe.addLibraryPath(.{ .path = clamav_path });

            const openssl_path = std.process.getEnvVarOwned(b.allocator, "OPENSSL_PATH") catch |err| {
                std.debug.print("ERROR : {}", .{err});
                return;
            };
            defer b.allocator.free(openssl_path);
            const openssl_path_include_path = std.fmt.allocPrint(b.allocator, "{s}\\include", .{openssl_path}) catch |err| {
                std.debug.print("ERROR : failed to allocate the string in openssl_path_include_path : {}", .{err});
                return;
            };
            defer b.allocator.free(openssl_path_include_path);

            const openssl_lib_path = std.fmt.allocPrint(b.allocator, "{s}\\lib\\VC\\x64\\MD", .{openssl_path}) catch |err| {
                std.debug.print("ERROR : failed to allocate the string in openssl_lib_path : {}", .{err});
                return;
            };

            defer b.allocator.free(openssl_lib_path);

            exe.addIncludePath(.{ .path = openssl_path_include_path });
            exe.addLibraryPath(.{ .path = openssl_lib_path });

            exe.linkSystemLibrary("openssl");
        },
        else => {},
    }

    exe.linkSystemLibrary("clamav");
    exe.linkLibC();
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
