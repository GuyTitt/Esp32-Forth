cmake_minimum_required(VERSION 3.16)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)

project(forth_interpreter)

# --- WORKAROUND CRITIQUE: Force l'acceptation du cross-compilateur par CMake ---
# Ce patch est necessaire car Clang/Xtensa ne peut pas executer de programme
# de test sur l'hote Windows, ce qui fait echouer la verification CMake.
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)
# -----------------------------------------------------------------------------

# Fichier: CMakeLists.txt, Localisation: /CMakeLists.txt, Version: 1.21
