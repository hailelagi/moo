const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // CoWTrie Library
    const lib = b.addStaticLibrary(.{
        .name = "CowTrie",
        .target = target,
        .optimize = optimize,
    });

    lib.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/trie.cpp" },
        .flags = &.{"-std=c++20"},
    });
    lib.addCSourceFile(.{
        .file = .{ .cwd_relative = "src/store.cpp" },
        .flags = &.{"-std=c++20"},
    });

    lib.linkLibCpp();
    b.installArtifact(lib);

    // GoogleTest Setup
    const gtest = b.addStaticLibrary(.{
        .name = "gtest",
        .target = target,
        .optimize = optimize,
    });

    const gtest_include_flags = [_][]const u8{
        "-std=c++17",
        "-Igoogletest/googletest/include",
        "-Igoogletest/googletest",
        "-pthread",
    };

    const fetch_gtest = b.addSystemCommand(&.{
        "sh",
        "-c",
        "if [ ! -d googletest ]; then git clone https://github.com/google/googletest.git; fi",
    });

    gtest.step.dependOn(&fetch_gtest.step);

    gtest.addCSourceFile(.{
        .file = .{ .cwd_relative = "googletest/googletest/src/gtest-all.cc" },
        .flags = &gtest_include_flags,
    });
    gtest.addCSourceFile(.{
        .file = .{ .cwd_relative = "googletest/googletest/src/gtest_main.cc" },
        .flags = &gtest_include_flags,
    });

    gtest.linkLibCpp();

    // Test Executable
    const gtests = b.addExecutable(.{
        .name = "trie_test",
        .target = target,
        .optimize = optimize,
    });

    gtests.addCSourceFile(.{
        .file = .{ .cwd_relative = "test/trie_test.cpp" },
        .flags = &.{
            "-std=c++17",
            "-Igoogletest/googletest/include",
            "-Ifmt/include",
            "-pthread",
        },
    });

    gtests.addCSourceFile(.{
        .file = .{ .cwd_relative = "test/store_test.cpp" },
        .flags = &.{
            "-std=c++17",
            "-Igoogletest/googletest/include",
            "-Ifmt/include",
            "-pthread",
        },
    });

    gtests.linkLibrary(gtest);
    gtests.linkLibrary(lib);
    gtests.linkLibCpp();
    b.installArtifact(gtests);

    // Formatting Step for C++ Files
    const format_step = b.step("fmt", "Format C++ code with clang-format");
    const cpp_files = &[_][]const u8{
        "src/store.cpp",
        "src/trie.cpp",
        "src/trie.h",
    };
    for (cpp_files) |file| {
        const format_cmd = b.addSystemCommand(&.{ "clang-format", "-i", file });
        format_step.dependOn(&format_cmd.step);
    }

    // Test Step
    const test_step = b.step("test", "Run GTest tests");
    const run_test_cmd = b.addRunArtifact(gtests);
    test_step.dependOn(&run_test_cmd.step);
}
