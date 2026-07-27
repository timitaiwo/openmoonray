{
  description = "LLDB exploration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # LLVM with the libraries you need
        llvm = pkgs.llvmPackages_22.llvm;
        lld = pkgs.llvmPackages_22.lld;
        clang = pkgs.llvmPackages_22.clang;
        clang-unwrapped = pkgs.symlinkJoin {
          name = "clang-unwrapped-merged";
          paths = [
            pkgs.llvmPackages_22.clang-unwrapped.dev
            pkgs.llvmPackages_22.clang-unwrapped.lib
            pkgs.llvmPackages_22.clang-unwrapped.out
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "lldb exploration";

          buildInputs = [
            # Build system
            pkgs.cmake
            pkgs.ninja
            pkgs.libffi
            pkgs.libxml2

            # NodeJS
            pkgs.nodejs

            # LLVM toolchain
            llvm
            clang
            clang-unwrapped
            lld
            # lldb

            # Libraries
            pkgs.libedit
            pkgs.zstd
            pkgs.curl
          ];

          # Ensure the shell knows where to find LLVM
          shellHook = ''
            export CC=clang
            export CXX=clang++
            export CLANG_RESOURCE_DIR="$(clang -print-resource-dir)"
            echo "🔧 Yọrọ development environment loaded!"
            echo "   CMake:   $(cmake --version | head -1)"
            echo "   Ninja:   $(ninja --version)"
            echo "   Node.js: $(node --version)"
            echo "   LLVM:    $(llvm-config --version)"
          '';

          # Help CMake find libraries
          CMAKE_PREFIX_PATH = "${llvm}/lib/cmake/llvm";
        };
      }
    );
}