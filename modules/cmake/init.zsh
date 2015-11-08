#
# Initialize build directories for CMake.
#
# Authors:
#   Benjamin Chrétien <chretien dot b at gmail dot com>
#   Thomas Moulard <thomas dot moulard at gmail dot com>
#

# Get the install prefix or use the default.
zstyle -s ':prezto:module:cmake' install-prefix '_cmake_install_prefix' \
  || _cmake_install_prefix='/usr'

# Get the build prefix.
zstyle -s ':prezto:module:cmake' build-prefix '_cmake_build_prefix' \
  || _cmake_build_prefix='_build'

# Get the profiles to consider or use the default.
zstyle -a ':prezto:module:cmake' profiles '_cmake_profiles' \
  || _cmake_profiles=(Debug Release)

# Check for clang
_cmake_has_clang=false
if (( $+commands[clang] )); then
  _cmake_has_clang=true
fi

function makeBuildDirectory
{
  local extra_flags="$@"

  local d=`pwd`
  if `test x$(find . -maxdepth 1 -name CMakeLists.txt) = x`; then
    echo "Run this in your project's root directory"
    return 1
  fi

  local common_flags="-DCMAKE_INSTALL_PREFIX=${_cmake_install_prefix}"

  # Create default GCC profiles.
  for p in "${_cmake_profiles[@]}"; do
    echo "*** Creating ${p:l} profile..."
    local build_dir="${d}/${_cmake_build_prefix}/${p:l}"
    mkdir -p "${build_dir}"
    (cd "${build_dir}" && \
      cmake ${common_flags} ${extra_flags} -DCMAKE_BUILD_TYPE=${p} \
      "${d}")
    echo "*** ...done!"
  done

  # If clang is available, create clang profiles.
  if ${_cmake_has_clang}; then
    for p in "${_cmake_profiles[@]}"; do
      echo "*** Creating ${p:l} profile (clang)..."
      local build_dir="${d}/${_cmake_build_prefix}/clang+${p:l}"
      mkdir -p "${build_dir}"
      (cd "${build_dir}" && \
        CC=clang CXX=clang++ \
        cmake ${common_flags} ${extra_flags} -DCMAKE_BUILD_TYPE=${p} \
        "${d}")
      echo "*** ...done!"
    done
  fi
}

alias mb=makeBuildDirectory
