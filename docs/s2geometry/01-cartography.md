---
subject: google/s2geometry
measured_at: 677c8cebcff11ba11accc0b02005bc214e06e9fd
status: final
---


# Cartography

## 1. Clone nông

Lệnh (sandbox_shell, trong sandbox):

```
if [ -d /workspace/s2geometry/.git ]; then echo "EXISTS-REUSE"; else git clone --depth 100 --single-branch -b master https://github.com/google/s2geometry /workspace/s2geometry; fi
```

Raw output:

```
Cloning into '/workspace/s2geometry'...
CLONED-AT 677c8cebcff11ba11accc0b02005bc214e06e9fd 2026-09-25 21:12:25 +0200 build(deps): bump pypa/gh-action-pypi-publish from 1.14.0 to 1.14.2 (#660)
[sandbox_shell] exit=0
```

Nhận xét: clone nông thành công lần 1, không cần fallback `sandbox_git_clone` (ghi nhận: **không re-clone-full**).

## 2. (a) HEAD + commit count

Lệnh: `git log -1 --format='%H %ci %s'` và `git rev-list --count HEAD`

```
=== (a) git log -1 ===
677c8cebcff11ba11accc0b02005bc214e06e9fd 2026-09-25 21:12:25 +0200 build(deps): bump pypa/gh-action-pypi-publish from 1.14.0 to 1.14.2 (#660)
=== (a2) rev-list count ===
100
(shallow <=100)
[sandbox_shell] exit=0
```

Nhận xét: **PIN = `677c8cebcff11ba11accc0b02005bc214e06e9fd`**; commit_count = 100 bị chặn bởi độ sâu nông (shallow ≤100) — không phải tổng số commit thật của upstream.

## 3. (b) LICENSE — cổng BLOCKED/OK

Lệnh: `ls LICENSE*`

```
=== (b) LICENSE ===
LICENSE
LICENSE-OK
[sandbox_shell] exit=0
```

Lệnh: `head -3 LICENSE`

```
                                 Apache License
                           Version 2.0, January 2004
```

Nhận xét: cổng license **ĐẠT** — LICENSE (Apache 2.0) tồn tại, không BLOCKED.

## 4. (c) Census LOC — công thức v9 (từng extension rồi cộng, cấm `xargs wc -l | tail -1`)

Lệnh (nguyên văn từ brief):

```
for ext in cc h hpp c++ py; do
  n=$(find . -type f -name "*.$ext" -not -path './.git/*' | wc -l)
  l=$(find . -type f -name "*.$ext" -not -path './.git/*' -print0 | xargs -0 cat | wc -l)
  echo "EXT .$ext files=$n lines=$l"
done
```

Raw output:

```
EXT .cc files=254 lines=99497
EXT .h files=178 lines=48992
EXT .hpp files=0 lines=0
EXT .c++ files=0 lines=0
EXT .py files=15 lines=5566
[sandbox_shell] exit=0
```

Nhận xét: tổng **447 files / 154,055 LOC** (254+178+0+0+15 files; 99497+48992+5566 = 154,055). Không có `.hpp`/`.c++`.

Số liệu bổ sung cho node sau (cùng sandbox, lệnh `find`/`grep -c`):

```
=== *_test.cc in src/s2 === 124
=== all .cc in src/s2 (flat+subdirs) === 238
=== cc_test targets in src/BUILD.bazel === 114
=== src/python content === BUILD.bazel CMakeLists.txt README.md coder.i module.cc
  r1interval_bindings.cc r1interval_test.py r2point_bindings.cc r2point_test.py
  r2rect_bindings.cc r2rect_test.py s1angle_bindings.cc s1angle_test.py
  s1chord_angle_bindings.cc s1chord_angle_test.py s1interval_bindings.cc
  s1interval_test.py s2.i s2_common.i s2cap_bindings.cc s2cap_test.py
  s2cell_bindings.cc s2cell_id_bindings.cc s2cell_id_range.cc s2cell_id_range.h
  s2cell_id_range_test.cc s2cell_id_test.py s2cell_test.py s2geometry_test.py
  s2geometry_pybind s2latlng_bindings.cc s2latlng_test.py s2point_bindings.cc
  s2point_test.py
=== doc/examples content === CMakeLists.txt point_index.cc term_index.cc term_index.py
```

## 5. (d) Build manifests — dán nguyên văn phần khai báo

### 5.1 CMakeLists.txt (root, 769 dòng) — phần khai báo

Nguyên văn `CMakeLists.txt` dòng 1–95 (project / chuẩn ngôn ngữ / options):

```cmake
cmake_minimum_required(VERSION 3.18)


# avoids error: aligned allocation function of type 'void *(std::size_t, std::align_val_t)' is only available on macOS 10.13 or newer
# see https://github.com/google/oss-policies-info/blob/main/foundational-cxx-support-matrix.md#macos
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum macOS version")


# Custom "Dev" build type: optimized but without -DNDEBUG so that asserts remain
# active.  Use with -DCMAKE_BUILD_TYPE=Dev.  Defining the _INIT variables before
# project() seeds the cache via the same mechanism CMake uses for the built-in
# build types (Debug, Release, etc.).
set(CMAKE_CXX_FLAGS_DEV_INIT "-O1")


project(s2-geometry
        VERSION 0.12.0)


include(CMakeDependentOption)
include(CheckCXXCompilerFlag)
include(FeatureSummary)
include(FetchContent)
include(FindPackageHandleStandardArgs)
include(GNUInstallDirs)


set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# Avoid "Policy CMP0042 is not set" warning on macOS.
if (APPLE)
    set(CMAKE_MACOSX_RPATH TRUE)
endif()


# s2geometry needs to use the same C++ standard that absl used to avoid
# undefined symbol errors since ABSL_HAVE_STD_STRING_VIEW etc will
# end up defined differently.  There is probably a better way to achieve
# this than assuming what absl used.  We require at least C++17.
# Using CACHE allows the user to override the default.
set(CMAKE_CXX_STANDARD 17 CACHE STRING "The C++ standard to build with")
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# No compiler-specific extensions, i.e. -std=c++17, not -std=gnu++17.
set(CMAKE_CXX_EXTENSIONS OFF)


option(BUILD_SHARED_LIBS "Build shared libraries instead of static." ON)
add_feature_info(SHARED_LIBS BUILD_SHARED_LIBS
                 "builds shared libraries instead of static.")


option(BUILD_EXAMPLES "Build s2 documentation examples." ON)
option(BUILD_TESTS "Build s2 unittests." ON)


option(WITH_PYTHON "Add python interface" OFF)
# Requires SWIG >= 4.2 and CMake >= 3.26.
option(WITH_PYTHON_LIMITED_API "Use Python Limited API for SWIG" OFF)
add_feature_info(PYTHON WITH_PYTHON "provides python interface to S2")


option(S2_USE_SYSTEM_INCLUDES
    "Silence warnings in s2 headers by marking them as SYSTEM includes." OFF)
add_feature_info(S2_USE_SYSTEM_INCLUDES S2_USE_SYSTEM_INCLUDES
    "Silence warnings in s2 headers by marking them as SYSTEM includes.")
```

Nguyên văn `CMakeLists.txt` dòng 153–261 — **`add_library(s2 ...)` toàn bộ 108 file .cc** (nguồn khai báo universe phía CMake):

```cmake
add_library(s2
            src/s2/base/malloc_extension.cc
            src/s2/encoded_s2cell_id_vector.cc
            src/s2/encoded_s2point_vector.cc
            src/s2/encoded_s2shape_index.cc
            src/s2/encoded_string_vector.cc
            src/s2/id_set_lexicon.cc
            src/s2/internal/s2incident_edge_tracker.cc
            src/s2/internal/s2index_cell_data.cc
            src/s2/mutable_s2shape_index.cc
            src/s2/r2rect.cc
            src/s2/s1angle.cc
            src/s2/s1chord_angle.cc
            src/s2/s1interval.cc
            src/s2/s2boolean_operation.cc
            src/s2/s2buffer_operation.cc
            src/s2/s2builder.cc
            src/s2/s2builder_graph.cc
            src/s2/s2builderutil_closed_set_normalizer.cc
            src/s2/s2builderutil_find_polygon_degeneracies.cc
            src/s2/s2builderutil_get_snapped_winding_delta.cc
            src/s2/s2builderutil_lax_polygon_layer.cc
            src/s2/s2builderutil_lax_polyline_layer.cc
            src/s2/s2builderutil_s2point_vector_layer.cc
            src/s2/s2builderutil_s2polygon_layer.cc
            src/s2/s2builderutil_s2polyline_layer.cc
            src/s2/s2builderutil_s2polyline_vector_layer.cc
            src/s2/s2builderutil_snap_functions.cc
            src/s2/s2cap.cc
            src/s2/s2cell.cc
            src/s2/s2cell_id.cc
            src/s2/s2cell_index.cc
            src/s2/s2cell_union.cc
            src/s2/s2centroids.cc
            src/s2/s2chain_interpolation_query.cc
            src/s2/s2closest_cell_query.cc
            src/s2/s2closest_edge_query.cc
            src/s2/s2closest_point_query.cc
            src/s2/s2contains_vertex_query.cc
            src/s2/s2convex_hull_query.cc
            src/s2/s2coords.cc
            src/s2/s2crossing_edge_query.cc
            src/s2/s2debug.cc
            src/s2/s2density_tree.cc
            src/s2/s2earth.cc
            src/s2/s2edge_clipping.cc
            src/s2/s2edge_crosser.cc
            src/s2/s2edge_crossings.cc
            src/s2/s2edge_distances.cc
            src/s2/s2edge_tessellator.cc
            src/s2/s2error.cc
            src/s2/s2fractal.cc
            src/s2/s2furthest_edge_query.cc
            src/s2/s2hausdorff_distance_query.cc
            src/s2/s2latlng.cc
            src/s2/s2latlng_rect.cc
            src/s2/s2latlng_rect_bounder.cc
            src/s2/s2lax_loop_shape.cc
            src/s2/s2lax_polygon_shape.cc
            src/s2/s2lax_polyline_shape.cc
            src/s2/s2loop.cc
            src/s2/s2loop_measures.cc
            src/s2/s2max_distance_targets.cc
            src/s2/s2measures.cc
            src/s2/s2memory_tracker.cc
            src/s2/s2metrics.cc
            src/s2/s2min_distance_targets.cc
            src/s2/s2padded_cell.cc
            src/s2/s2point_compression.cc
            src/s2/s2point_region.cc
            src/s2/s2pointutil.cc
            src/s2/s2polygon.cc
            src/s2/s2polyline.cc
            src/s2/s2polyline_alignment.cc
            src/s2/s2polyline_measures.cc
            src/s2/s2polyline_simplifier.cc
            src/s2/s2predicates.cc
            src/s2/s2projections.cc
            src/s2/s2r2rect.cc
            src/s2/s2random.cc
            src/s2/s2region_coverer.cc
            src/s2/s2region_intersection.cc
            src/s2/s2region_sharder.cc
            src/s2/s2region_term_indexer.cc
            src/s2/s2region_union.cc
            src/s2/s2shape_index.cc
            src/s2/s2shape_index_buffered_region.cc
            src/s2/s2shape_index_measures.cc
            src/s2/s2shape_measures.cc
            src/s2/s2shape_nesting_query.cc
            src/s2/s2shapeutil_build_polygon_boundaries.cc
            src/s2/s2shapeutil_coding.cc
            src/s2/s2shapeutil_contains_brute_force.cc
            src/s2/s2shapeutil_conversion.cc
            src/s2/s2shapeutil_count_vertices.cc
            src/s2/s2shapeutil_edge_iterator.cc
            src/s2/s2shapeutil_edge_wrap.cc
            src/s2/s2shapeutil_get_reference_point.cc
            src/s2/s2shapeutil_visit_crossing_edge_pairs.cc
            src/s2/s2text_format.cc
            src/s2/s2wedge_relations.cc
            src/s2/s2winding_operation.cc
            src/s2/util/bits/bit-interleave.cc
            src/s2/util/coding/coder.cc
            src/s2/util/coding/varint.cc
            src/s2/util/math/exactfloat/bignum.cc
            src/s2/util/math/exactfloat/exactfloat.cc
            src/s2/util/math/mathutil.cc
            src/s2/util/units/length-units.cc)
```

Nguyên văn `CMakeLists.txt` dòng 539–545 (subdirectories):

```cmake
  add_subdirectory("doc/examples" examples)
endif()


if (WITH_PYTHON)
  add_subdirectory("src/python" python)
endif()
```

Chỉ mục target CMake (grep -n): `add_library(s2` @153; `add_library(s2testing STATIC` @346; `add_library(test_main` @362; vòng `add_executable(${test} ...)` @502 (BUILD_TESTS); `add_subdirectory("doc/examples" ...)` @539; `add_subdirectory("src/python" ...)` @543.

### 5.2 src/MODULE.bazel — nguyên văn TOÀN BỘ (30 dòng)

```python
module(
    name = "s2geometry",
    version = "head",
    bazel_compatibility = [
        ">=8.0.0",
    ],
    compatibility_level = 1,
)


# Production dependencies
bazel_dep(name = "abseil-cpp", version = "20260817.0")
bazel_dep(name = "bazel_skylib", version = "1.9.2")
bazel_dep(name = "rules_cc", version = "0.2.22")


# Development dependencies (only needed for tests)
bazel_dep(name = "boringssl", version = "0.20260813.0", dev_dependency = True)
bazel_dep(name = "openssl", version = "4.0.1.bcr.0", dev_dependency = True)
bazel_dep(name = "google_benchmark", version = "1.9.5", dev_dependency = True)
bazel_dep(name = "googletest", version = "1.18.0.bcr.1", dev_dependency = True)


# Python configuration
# The platforms dependency is needed for pybind_extension rules. See:
# https://github.com/pybind/pybind11_bazel/blob/master/MODULE.bazel
bazel_dep(name = "platforms", version = "1.1.0")
bazel_dep(name = "pybind11_bazel", version = "3.0.1")
bazel_dep(name = "rules_python", version = "2.3.1")


# Extensions
cc_configure = use_extension("@rules_cc//cc:extensions.bzl", "cc_configure_extension", dev_dependency = True)
use_repo(cc_configure, "local_config_cc")
```

Ghi nhận: **MODULE.bazel chỉ tồn tại ở `src/MODULE.bazel`** — root `MODULE.bazel` KHÔNG tồn tại (`ls MODULE.bazel` → `No such file or directory`).

### 5.3 src/BUILD.bazel (1603 dòng) — phần khai báo chính

Nguyên văn `src/BUILD.bazel` dòng 1–14 (header + flags):

```python
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library", "cc_test")


package(default_visibility = ["//visibility:public"])


bool_flag(
    name = "use_openssl",
    build_setting_default = False,
)


config_setting(
    name = "use_openssl_setting",
    flag_values = {":use_openssl": "True"},
)
```

Nguyên văn `src/BUILD.bazel` dòng 16–56 — đầu `cc_library(name = "s2")` (srcs):

```python
cc_library(
    name = "s2",
    srcs = [
        ":s2/encoded_s2cell_id_vector.cc",
        ":s2/encoded_s2point_vector.cc",
        ":s2/encoded_s2shape_index.cc",
        ":s2/encoded_string_vector.cc",
        ":s2/id_set_lexicon.cc",
        ":s2/internal/s2incident_edge_tracker.cc",
        ":s2/internal/s2index_cell_data.cc",
        ":s2/mutable_s2shape_index.cc",
        ":s2/r2rect.cc",
        ":s2/s1angle.cc",
        ":s2/s1chord_angle.cc",
        ":s2/s1interval.cc",
        ":s2/s2boolean_operation.cc",
        ":s2/s2buffer_operation.cc",
        ":s2/s2builder.cc",
        ":s2/s2builder_graph.cc",
        ":s2/s2builderutil_closed_set_normalizer.cc",
        ":s2/s2builderutil_find_polygon_degeneracies.cc",
        ":s2/s2builderutil_get_snapped_winding_delta.cc",
        ":s2/s2builderutil_lax_polygon_layer.cc",
        ":s2/s2builderutil_lax_polyline_layer.cc",
        ":s2/s2builderutil_s2point_vector_layer.cc",
        ":s2/s2builderutil_s2polygon_layer.cc",
        ":s2/s2builderutil_s2polyline_layer.cc",
        ":s2/s2builderutil_s2polyline_vector_layer.cc",
        ":s2/s2builderutil_snap_functions.cc",
        ":s2/s2cap.cc",
        ":s2/s2cell.cc",
        ":s2/s2cell_id.cc",
        ":s2/s2cell_index.cc",
        ":s2/s2cell_union.cc",
        ":s2/s2centroids.cc",
        ":s2/s2closest_cell_query.cc",
        ":s2/s2closest_edge_query.cc",
        ":s2/s2closest_point_query.cc",
        ":s2/s2contains_vertex_query.cc",
        ":s2/s2convex_hull_query.cc",
        ":s2/s2coords.cc",
        ":s2/s2crossing_edge_query.cc",
        ":s2/s2debug.cc",
        ":s2/s2earth.cc",
        ":s2/s2edge_clipping.cc",
        ":s2/s2edge_crosser.cc",
        ":s2/s2edge_crossings.cc",
        ":s2/s2edge_distances.cc",
        ":s2/s2edge_tessellator.cc",
        ":s2/s2error.cc",
        ":s2/s2fractal.cc",
        ":s2/s2furthest_edge_query.cc",
        ":s2/s2hausdorff_distance_query.cc",
        ":s2/s2latlng.cc",
        ":s2/s2latlng_rect.cc",
        ":s2/s2latlng_rect_bounder.cc",
        ":s2/s2lax_loop_shape.cc",
        ":s2/s2lax_polygon_shape.cc",
        ":s2/s2lax_polyline_shape.cc",
        ":s2/s2loop.cc",
        ":s2/s2loop_measures.cc",
        ":s2/s2max_distance_targets.cc",
        ":s2/s2measures.cc",
        ":s2/s2memory_tracker.cc",
        ":s2/s2metrics.cc",
        ":s2/s2min_distance_targets.cc",
        ":s2/s2padded_cell.cc",
        ":s2/s2point_compression.cc",
        ":s2/s2point_region.cc",
        ":s2/s2pointutil.cc",
        ":s2/s2polygon.cc",
        ":s2/s2polyline.cc",
        ":s2/s2polyline_alignment.cc",
        ":s2/s2polyline_measures.cc",
        ":s2/s2polyline_simplifier.cc",
        ":s2/s2predicates.cc",
        ":s2/s2projections.cc",
        ":s2/s2r2rect.cc",
        ":s2/s2region_coverer.cc",
        ":s2/s2region_intersection.cc",
        ":s2/s2region_term_indexer.cc",
        ":s2/s2region_union.cc",
        ":s2/s2shape_index.cc",
        ":s2/s2shape_index_buffered_region.cc",
        ":s2/s2shape_index_measures.cc",
        ":s2/s2shape_measures.cc",
        ":s2/s2shape_nesting_query.cc",
        ":s2/s2shapeutil_build_polygon_boundaries.cc",
        ":s2/s2shapeutil_coding.cc",
        ":s2/s2shapeutil_contains_brute_force.cc",
        ":s2/s2shapeutil_conversion.cc",
        ":s2/s2shapeutil_edge_iterator.cc",
        ":s2/s2shapeutil_edge_wrap.cc",
        ":s2/s2shapeutil_get_reference_point.cc",
        ":s2/s2shapeutil_visit_crossing_edge_pairs.cc",
        ":s2/s2text_format.cc",
        ":s2/s2wedge_relations.cc",
        ":s2/s2winding_operation.cc",
    ],
```

Sau `srcs` là `hdrs` (dòng ~106–228, 125 header `.h` gồm cả `internal/`), rồi `deps` (dòng ~229–252: `//s2/base:casts|log_severity|spinlock`, `//s2/testing:gtest_prod`, `//s2/util/bitmap|bits|coding|endian|gtl:*|hash:mix|math:mathutil|matrix3x3|vector|math/exactfloat|random|task:status_macros|units`, và `@abseil-cpp//...`) — block `cc_library s2` kết thúc ở dòng 285 `)`.

Chỉ mục target `src/BUILD.bazel` (grep -n): `cc_library(name = "s2")` @16; `cc_binary(name = "s2shared")` @287 (92 .cc); `cc_library(name = "s2_testing_headers", testonly = True)` @389 (chứa `:s2/s2random.cc` @395 và `:s2/s2random.h` @406); **114 `cc_test`** (đầu tiên @428, cuối cùng @1595).

### 5.4 Bản đồ BUILD.bazel lồng nhau (16 file)

```
./src/BUILD.bazel
./src/MODULE.bazel
./src/python/BUILD.bazel
./src/s2/base/BUILD.bazel
./src/s2/testing/BUILD.bazel
./src/s2/util/bitmap/BUILD.bazel
./src/s2/util/bits/BUILD.bazel
./src/s2/util/coding/BUILD.bazel
./src/s2/util/endian/BUILD.bazel
./src/s2/util/gtl/BUILD.bazel
./src/s2/util/hash/BUILD.bazel
./src/s2/util/math/BUILD.bazel
./src/s2/util/math/exactfloat/BUILD.bazel
./src/s2/util/random/BUILD.bazel
./src/s2/util/task/BUILD.bazel
./src/s2/util/units/BUILD.bazel
```

Target trong các BUILD lồng (grep name =): `src/s2/base` → casts, log_severity, **malloc_extension** (`srcs = ["malloc_extension.cc"]`), spinlock, timer; `src/s2/util/bits` → **bits** (`bit-interleave.cc`); `src/s2/util/coding` → **coding** (`coder.cc`, `varint.cc`); `src/s2/util/math` → **mathutil** (`mathutil.cc`), matrix3x3, vector; `src/s2/util/math/exactfloat` → **bignum** (`bignum.cc`), **exactfloat** (`exactfloat.cc`), bignum_test, exactfloat_test, exactfloat_underflow_test; `src/s2/util/units` → **units** (`length-units.cc`).

### 5.5 ⚠️ PHÁT HIỆN LECH MANIFEST (CMake vs Bazel) — đầu vào bắt buộc cho node universe

Đối chiếu 2 manifest trên cùng cây PIN `677c8ceb`:

| Nguồn | Số file .cc của thư viện s2 |
|---|---|
| `CMakeLists.txt` `add_library(s2 ...)` (dòng 153–261) | **108** |
| `src/BUILD.bazel` `cc_library(name = "s2")` (dòng 16–285) | **95** |
| md5 danh sách tên đã sort | CMake `9aec52ddd6d21c770f9716923aecb217` ≠ Bazel `3e2c8107e33956c257a0483f1eaa90e4` |

Phân rã đúng 13 file chênh (108 = 95 + 8 + 4 + 1):

1. **8 file CMake biên dịch trực tiếp; Bazel tách vào BUILD lồng** (vẫn được build, qua deps): `base/malloc_extension`, `util/bits/bit-interleave`, `util/coding/coder`, `util/coding/varint`, `util/math/mathutil`, `util/math/exactfloat/bignum`, `util/math/exactfloat/exactfloat`, `util/units/length-units`.
2. **4 file CHỈ CMake biên dịch — không nằm trong target Bazel nào của src/BUILD.bazel (grep cả cây BUILD* = 0 hit):** `s2chain_interpolation_query.cc`, `s2density_tree.cc`, `s2region_sharder.cc`, `s2shapeutil_count_vertices.cc` (file tồn tại trên đĩa, đã kiểm `EXISTS`).
3. **1 file hai bên khác vai:** `s2random.cc` — CMake biên dịch trong lib s2; Bazel chỉ có trong `s2_testing_headers` (test-only @395).

Nhận xét: khi node sau chốt universe `src/s2`, CMake list (108) là tập khai báo đầy đủ nhất; Bazel thiếu thật sự 4 file — phải ghi nhận trong cartography để gate không bắt "bịa item" và để quyết định gộp item dựa trên chuẩn CMake.

## 6. (e) Entrypoints

Lệnh: `grep -rn 'int main' --include='*.cc' src doc | head -20`

```
src/s2/testing/test_main.cc:30:int main(int argc, char *argv[]) {
doc/examples/term_index.cc:38:int main(int argc, char** argv) {
doc/examples/point_index.cc:25:int main(int argc, char **argv) {
```

Nhận xét: không có binary ứng dụng người dùng cuối — 1 main test-harness (`test_main.cc`) + 2 ví dụ C++ (`doc/examples/`); thư viện là sản phẩm chính, thêm bindings Python `src/python` (pybind/SWIG, không có `int main` trong .cc).

## 7. (f) Cây thư mục top (maxdepth 2)

Lệnh: `find . -maxdepth 2 -type d -not -path './.git*' | sort | head -80`

```
.
./doc
./doc/design
./doc/examples
./doc/pdf
./src
./src/python
./src/s2
```

Nhận xét: cấu trúc phẳng đúng như kỳ vọng AGENTS.md — toàn bộ core nằm trong `src/s2` (phẳng + `internal/` + `base/` + `testing/` + `util/*`), Python binding tách `src/python`, docs `doc/`.

## 8. Repo đích cassian — kiểm tra CHỈ ĐỌC (không push)

Lệnh (token một-shot, không lưu file): `git ls-remote https://x-access-token:$TOKEN@github.com/Stellarhold170NT/cassian.git HEAD`

```
895fe8ecc59975a2dad1e3ddbd452ae13c740c77	HEAD
```

- Kết quả: **OK** — token hợp lệ, repo đích truy được; node này KHÔNG push gì.
- REDACTION: `grep -r 'ghp_' /workspace/s2geometry --exclude-dir=.git` → **0** dòng.

## 9. Họ tiền tố file `src/s2` tính TỪ MANIFEST (đầu vào universe cho node sau)

Tính từ 95 srcs của `cc_library(name = "s2")` trong `src/BUILD.bazel`, theo luật AGENTS.md §1 (họ = tên file trước `_` đầu tiên; `s2builderutil_*` là họ riêng; không `_` → `s2-core`):

| Họ | Số file .cc |
|---|---|
| s2-core (không `_`, đúng 22: r2rect, s1angle, s1interval, s2builder, s2cap, s2cell, s2centroids, s2coords, s2debug, s2earth, s2error, s2fractal, s2latlng, s2loop, s2measures, s2metrics, s2pointutil, s2polygon, s2polyline, s2predicates, s2projections, s2r2rect) | 22 |
| s2builderutil | 10 |
| s2shapeutil | 8 |
| s2shape (s2shape_index, s2shape_index_buffered_region, s2shape_index_measures, s2shape_measures, s2shape_nesting_query) | 5 |
| s2edge | 5 |
| s2region | 4 |
| encoded | 4 |
| s2polyline | 3 |
| s2lax | 3 |
| s2closest | 3 |
| s2cell (s2cell_id, s2cell_index, s2cell_union) | 3 |
| s2point | 2 |
| s2latlng | 2 |
| đơn lẻ (mỗi họ 1 file): s2winding, s2wedge, s2text, s2padded, s2min, s2memory, s2max, s2loop, s2hausdorff, s2furthest, s2crossing, s2convex, s2contains, s2builder (chỉ chứa s2builder_graph.cc — còn s2builder.cc ở s2-core), s2buffer, s2boolean, s1chord, mutable (mutable_s2shape_index), id (id_set_lexicon) | 19 |
| `internal/` (src/s2/internal/: s2incident_edge_tracker, s2index_cell_data — không phẳng) | 2 |
| **Cộng** | **95** |

Ghi chú trung thực cho node chốt universe: luật "trước `_` đầu tiên" tách `s2cell_id.cc` vào họ `s2cell` trong khi `s2cell.cc` (không `_`) rơi vào `s2-core` — số liệu trên là phép tính LITERAL từ manifest, quyết định gộp (<50 LOC vào họ cha) thuộc node thiết kế universe; item riêng `s2-python` = `src/python` (33 file trong ls ở mục 4).

---

## JSON BLOCK (máy đọc)

```json
{
  "repo": "google/s2geometry",
  "upstream_branch": "master",
  "sha": "677c8cebcff11ba11accc0b02005bc214e06e9fd",
  "commit_count_shallow": 100,
  "shallow_note": "rev-list count capped by --depth 100; not the true upstream total",
  "license": "Apache-2.0 (LICENSE present; gate passed)",
  "languages": {
    ".cc":  { "files": 254, "lines": 99497 },
    ".h":   { "files": 178, "lines": 48992 },
    ".hpp": { "files": 0, "lines": 0 },
    ".c++": { "files": 0, "lines": 0 },
    ".py":  { "files": 15, "lines": 5566 },
    "total": { "files": 447, "lines": 154055 }
  },
  "manifests": {
    "cmake": {
      "path": "CMakeLists.txt",
      "lines_total": 769,
      "project": "s2-geometry VERSION 0.12.0",
      "cxx_standard": 17,
      "add_library_s2": { "line_start": 153, "line_end": 261, "cc_count": 108 },
      "other_targets": { "s2testing_static": 346, "test_main": 362, "tests_loop": 502 },
      "subdirs": { "doc/examples": 539, "src/python": 543 },
      "cmake_only_files_not_in_any_bazel_target": [
        "s2chain_interpolation_query.cc",
        "s2density_tree.cc",
        "s2region_sharder.cc",
        "s2shapeutil_count_vertices.cc"
      ],
      "cmake_only_files_in_nested_bazel_build": [
        "base/malloc_extension.cc", "util/bits/bit-interleave.cc",
        "util/coding/coder.cc", "util/coding/varint.cc",
        "util/math/mathutil.cc", "util/math/exactfloat/bignum.cc",
        "util/math/exactfloat/exactfloat.cc", "util/units/length-units.cc"
      ]
    },
    "bazel_build": {
      "path": "src/BUILD.bazel",
      "lines_total": 1603,
      "cc_library_s2": { "line_start": 16, "line_end": 285, "cc_count": 95, "hdr_count": 125 },
      "cc_binary": { "name": "s2shared", "line": 287, "cc_count": 92 },
      "cc_library_testonly": { "name": "s2_testing_headers", "line": 389, "note": "s2random.cc @395" },
      "cc_test_count": 114,
      "nested_build_files": 16,
      "md5_sorted_cc_names": "3e2c8107e33956c257a0483f1eaa90e4"
    },
    "bazel_module": {
      "path": "src/MODULE.bazel",
      "lines_total": 30,
      "module_name": "s2geometry",
      "root_module_bazel_present": false,
      "deps_prod": ["abseil-cpp 20260817.0", "bazel_skylib 1.9.2", "rules_cc 0.2.22"],
      "deps_dev": ["boringssl 0.20260813.0", "openssl 4.0.1.bcr.0", "google_benchmark 1.9.5", "googletest 1.18.0.bcr.1"]
    },
    "manifest_drift": "CMake add_library(s2)=108 vs Bazel cc_library s2=95; delta = 8 nested-BUILD files + 4 CMake-only files + 1 (s2random, test-only in Bazel); CMake list is the superset",
    "s2_prefix_families_from_manifest": {
      "rule": "family = filename before first '_' ; s2builderutil_* own family ; no '_' -> s2-core ; literal computation from cc_library(s2) 95 srcs",
      "families": [
        { "name": "s2-core", "files": 22 },
        { "name": "s2builderutil", "files": 10 },
        { "name": "s2shapeutil", "files": 8 },
        { "name": "s2shape", "files": 5 },
        { "name": "s2edge", "files": 5 },
        { "name": "s2region", "files": 4 },
        { "name": "encoded", "files": 4 },
        { "name": "s2polyline", "files": 3 },
        { "name": "s2lax", "files": 3 },
        { "name": "s2closest", "files": 3 },
        { "name": "s2cell", "files": 3 },
        { "name": "s2point", "files": 2 },
        { "name": "s2latlng", "files": 2 },
        { "name": "singletons(19)", "files": 19,
          "list": ["s2winding", "s2wedge", "s2text", "s2padded", "s2min", "s2memory", "s2max", "s2loop", "s2hausdorff", "s2furthest", "s2crossing", "s2convex", "s2contains", "s2builder", "s2buffer", "s2boolean", "s1chord", "mutable", "id"] },
        { "name": "internal/(not flat)", "files": 2 }
      ],
      "total": 95,
      "extra_items": { "s2-python": "src/python (separate item per AGENTS.md)" }
    }
  },
  "entrypoints": [
    { "file": "src/s2/testing/test_main.cc", "line": 30, "role": "test harness main" },
    { "file": "doc/examples/term_index.cc", "line": 38, "role": "example binary" },
    { "file": "doc/examples/point_index.cc", "line": 25, "role": "example binary" }
  ],
  "top_dirs": ["doc", "doc/design", "doc/examples", "doc/pdf", "src", "src/python", "src/s2"],
  "extra_facts": { "test_cc_in_src_s2": 124, "cc_in_src_s2_all_subdirs": 238 },
  "cassian_target": {
    "repo": "Stellarhold170NT/cassian",
    "head": "895fe8ecc59975a2dad1e3ddbd452ae13c740c77",
    "ls_remote_status": "OK",
    "push_performed": false,
    "token_written_to_files": false,
    "redaction_grep_ghp_hits": 0
  }
}
```
