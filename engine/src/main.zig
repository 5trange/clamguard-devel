const std = @import("std");
const clamav = @cImport({
    @cInclude("clamav.h");
});

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // Init ClamAV. If this is successful, cl_init returns CL_SUCCESS
    const c_init_status: c_uint = clamav.cl_init(clamav.CL_INIT_DEFAULT);

    if (c_init_status != clamav.CL_SUCCESS) {
        // Failed to init ClamAV.
        try stdout.print("FAILED TO INITIALIZE LIBCLAMAV\n", .{});
        return;
    }
    try stdout.print("SUCCESSFULLY INITIALIZED LIBCLAMAV\n", .{});

    // Create a new engine.
    var engine: ?*clamav.cl_engine = null;
    engine = clamav.cl_engine_new();

    if (engine == null) {
        try stdout.print("FAILED TO CREATE AN ENGINE\n", .{});
        return;
    }
    try stdout.print("SUCCESSFULLY CREATED AN ENGINE\n", .{});

    // Print the default database directory.
    try stdout.print("DEFAULT DATABASE DIRECTORY {s}\n", .{clamav.cl_retdbdir()});

    const c_exit_status = clamav.cl_engine_free(engine);
    if (c_exit_status != clamav.CL_SUCCESS) {
        try stdout.print("FAILED to FREE THE LIBCLAMAV\n", .{});
        return;
    }
}

pub fn create_engine() !void {}
