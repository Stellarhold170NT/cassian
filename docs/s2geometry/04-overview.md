---
subject: google/s2geometry
measured_at: 677c8cebcff11ba11accc0b02005bc214e06e9fd
status: final
---


# Overview

## 1. S2 Geometry — thư viện hình học trên mặt cầu là gì (5 câu)

1. S2 Geometry là thư viện C++ của Google để thao tác hình học tính toán và đánh chỉ mục không gian **trực tiếp trên mặt cầu** thay vì bản đồ phẳng — `File: README.md | Dòng: 5-8 | Nội dung: "This is a package for manipulating geometric shapes. Unlike many geometry libraries, S2 is primarily designed to work with _spherical geometry_, i.e., shapes drawn on a sphere rather than on a planar 2D map. This makes it especially suitable for working with geographic data."`; `pyproject.toml:3`: `description = "Computational geometry and spatial indexing on the sphere"`.
2. Nền tảng là phân rã mặt cầu thành 6 mặt rồi lưới ô đệ quy theo đường cong Hilbert, mỗi ô nhận một định danh 64-bit — `File: src/s2/s2cell_id.h | Dòng: 57-59 | Nội dung: "An S2CellId is a 64-bit unsigned integer that uniquely identifies a cell in the S2 cell decomposition.  It has the following format: id = [face][face_pos]"`.
3. Trên nền đó thư viện cung cấp các kiểu hình (S2Polygon/S2Polyline/S2Loop/S2Cap…), khung index S2ShapeIndex, bộ query (chứa / gần nhất / cắt nhau), phép toán Boolean, buffer, và bộ dựng hình S2Builder với snapping có bảo đảm sai số (`src/s2/s2builder.h:63-68`).
4. Sản phẩm chính là **thư viện** — không có binary ứng dụng cuối: chỉ có 3 `int main` trong cây, gồm 1 test harness (`src/s2/testing/test_main.cc:30`) và 2 ví dụ (`doc/examples/term_index.cc:38`, `doc/examples/point_index.cc:25`); cộng binding Python `src/python`.
5. Version 0.12.0 (`CMakeLists.txt:13-14`), license Apache-2.0 (`LICENSE:2-3`), quy mô 447 files / 154,055 LOC theo census v9 (gm-01 §4: `.cc` 254/99,497; `.h` 178/48,992; `.py` 15/5,566).

## 2. Nắm trong 5 phút — 10 bullet

1. **S2CellId 64-bit**: mã hoá ô Hilbert `[face][face_pos]`, đơn vị không gian của mọi API (`src/s2/s2cell_id.h:57-91`).
2. **S2Region + covering**: `S2RegionCoverer` sinh `S2CellUnion` xấp xỉ một region bất kỳ (`src/s2/s2region_coverer.h:72`); các hình cụ thể đều `final : public S2Region` — `S2Cap` (`s2cap.h:62`), `S2Cell` (`s2cell.h:46`), `S2Loop` (`s2loop.h:95`), `S2Polygon` (`s2polygon.h:118`).
3. **S2ShapeIndex** — trái tim của thư viện: `File: src/s2/s2shape_index.h | Dòng: 264-266 | Nội dung: "Internally, an S2ShapeIndex is essentially a map from S2CellIds to the set of shapes that intersect each S2CellId.  It is adaptively refined to ensure that no cell contains more than a small number of edges."` (abstract base `class S2ShapeIndex` @286).
4. **MutableS2ShapeIndex** là index mặc định (`src/s2/mutable_s2shape_index.h:135`); mô hình thread: `File: src/s2/mutable_s2shape_index.h | Dòng: 122-123 | Nội dung: "has the same thread-safety properties as \"vector\": const methods are thread-safe, while non-const methods are not thread-safe."`
5. **S2Builder** — dựng hình từ cạnh: `File: src/s2/s2builder.h | Dòng: 59-68 | Nội dung: "S2Builder is a tool for assembling polygonal geometry from edges.  Here are some of the things it is designed for: 1. Building polygons, polylines, and polygon meshes from unsorted collections of edges. 2. Snapping geometry to discrete representations (such as S2CellId centers or E7 lat/lng coordinates) while preserving the input topology and with guaranteed error bounds."` (`class S2Builder` @149).
6. **Boolean operation** union/intersection/difference: `class S2BooleanOperation` (`src/s2/s2boolean_operation.h:211`), engine 2,773 dòng dựng kết quả qua builder layer (gm-02 m07).
7. **Query khoảng cách**: `S2ClosestEdgeQuery` (`src/s2/s2closest_edge_query.h:107`) + base template dùng chung (gm-02 m05: `s2closest_edge_query_base.h:82`); biến thể furthest (m25) và Hausdorff (m33) tái dùng cùng base.
8. **Codec decode-on-the-fly**: `EncodedS2ShapeIndex final : public S2ShapeIndex` (`src/s2/encoded_s2shape_index.h:128`) — truy vấn trên dữ liệu đã mã hoá không cần giải nén toàn bộ (gm-02 m08).
9. **Binding Python 2 đường**: pybind11 `File: src/python/module.cc | Dòng: 20 | Nội dung: "PYBIND11_MODULE(s2geometry_bindings, m) {"` + SWIG legacy (`s2.i`, `s2_common.i`); README.md:25-27: "The Python API is particularly unstable, and it is planned that the SWIGged API will be replaced by a pybind11 version".
10. **Test khổng lồ**: 114 target `cc_test` (`src/BUILD.bazel`, target đầu @428, cuối @1595; 1 target bị comment @1525) = 124 file `*_test.cc` trong `src/s2` + 1 trong `src/python` = 125 file test; 13 pattern flaky được liệt kê sẵn trong `flaky_tests.txt` (13 dòng).

## 3. C4 L1 — System context

```
[Ứng dụng C++ nhúng lib s2]   [User Python]   [CI / nhà phát triển]
        │ include + link          │ import s2geometry        │ bazel test / ctest
        ▼                         ▼                          ▼
┌──────────────────── s2geometry repo (PIN 677c8ceb) ────────────────────┐
│  lib s2 (C++)  ·  python bindings (opt)  ·  examples (opt)  ·  tests   │
└────────────────────────────────────────────────────────────────────────┘
        │ runtime deps                             │ build/dev deps
        ▼                                          ▼
 Abseil LTS 20260526 (exact)                 googletest ≥1.10 · SWIG 4.0/4.2 +
 + OpenSSL (bignum) + Threads                Python 3.10 · Bazel 8 + BCR
```

- Abseil bắt buộc: `CMakeLists.txt:88` `find_package(absl REQUIRED)`; `README.md:61-63`: "Abseil LTS 20260526 … **This exact version must be used.**"
- OpenSSL: `CMakeLists.txt:315` `find_package(OpenSSL REQUIRED)`; `README.md:73-74` nêu mục đích "for its bignum library" (exactfloat).
- Threads: `CMakeLists.txt:92` `find_package(Threads REQUIRED)`.
- Python/SWIG optional: `CMakeLists.txt:104-110` (`Python3 3.10` + `SWIG 4.2` limited-API hoặc `SWIG 4.0`), option `WITH_PYTHON` mặc định OFF (`CMakeLists.txt:47`).
- Đường Bazel: `README.md:29-35` (Bazel 8+, "Builds were tested using C++20 as set in .bazelrc"); deps từ BCR: `src/MODULE.bazel:11` `bazel_dep(name = "abseil-cpp", version = "20260817.0")`, `:19` `googletest 1.18.0.bcr.1 (dev_dependency)`.
- Sản phẩm đầu ra: lib `s2` shared/static (`CMakeLists.txt:40` `BUILD_SHARED_LIBS` ON mặc định; `add_library(s2` @153), python module (`add_subdirectory("src/python" python)` @543), 2 example binary (`add_subdirectory("doc/examples" examples)` @539), test binaries (`add_executable(${test} …)` @502).

## 4. C4 L2 — Containers

1 repo, 1 lib chính + 3 phần optional, ranh giới duy nhất là C API/headers + Python API:

| # | Container | Nội dung | Build switch | Evidence |
|---|---|---|---|---|
| 1 | **lib `s2` (C++17)** | 108 file `.cc` trên CMake (dòng 153–261) / 95 srcs trên Bazel (16–285) — drift ghi mục 10.3 | luôn build | `CMakeLists.txt:35` `CMAKE_CXX_STANDARD 17`; `CMakeLists.txt:153`; `src/BUILD.bazel:16` |
| 2 | **Python bindings** (`src/python`) | pybind11 (`module.cc:20`) + SWIG legacy (`s2.i`), 12 test `.py` + 1 test `.cc` | `WITH_PYTHON` (OFF @47) | `CMakeLists.txt:543` |
| 3 | **Examples** (`doc/examples`) | `point_index.cc:25`, `term_index.cc:38` | `BUILD_EXAMPLES` (ON @44) | `CMakeLists.txt:539` |
| 4 | **Test harness** | `s2testing` STATIC @346 + `test_main` @362 + 114 `cc_test` | `BUILD_TESTS` (ON @45) | `CMakeLists.txt:502` |

Giao tiếp giữa containers: ứng dụng ↔ lib qua headers (API C++), Python ↔ lib qua pybind11/SWIG bindings, tests ↔ lib qua `s2testing` + gtest. Không có IPC/network — đây là thư viện nhúng.

## 5. C4 L3 — Components

Phân rã theo 61 item của gm-02 (tóm lược thành 8 cụm; LOC theo gm-02 §3):

| Cụm | Items (module id — tên) | Vai trò chính | Evidence đại diện |
|---|---|---|---|
| Lõi hình học | m01 `s2-core` (20,879 LOC) | S2Polygon/S2Loop/S2Builder/S2Cell/S2Shape/S2LatLng/S2Cap/S2Predicates… — nền của mọi họ khác | `s2polygon.h:118`, `s2loop.h:95`, `s2builder.h:149`, `s2cell.h:46`, `s2shape.h:64` |
| Không gian ô | m03 `s2cell`, m41 `s2padded`, m39 `s2coords`, m14 `s2region`, m15 `s2latlng` | S2CellId/S2CellUnion/S2CellIndex, S2PaddedCell, bảng Hilbert nội bộ, covering + term indexer, rect lat/lng | `s2cell_id.h:91`, `s2region_coverer.h:72`, `s2region_term_indexer.h:257` `GetIndexTerms` |
| Index | m11 `s2shape`, m12 `mutable`, m08 `encoded`, m21 `s2point` | abstract S2ShapeIndex + 2 subtype lớn (mutable/encoded) + index điểm rời rạc | `s2shape_index.h:286`, `mutable_s2shape_index.h:135`, `encoded_s2shape_index.h:128`, `s2point_index.h:107` |
| Dựng hình | m09 `s2builder` (Graph/Layer), m04 `s2builderutil` (layer + snap), m20 `s2lax` (lax shapes), m38/m42/m43 lexicons | edges → geometry, snapping, output lax, từ điển nén id | `s2builder_layer.h:29` `class Layer`, `s2builderutil_snap_functions.h:41/82/165`, `s2lax_polygon_shape.h:86` |
| Cạnh + predicate | m06 `s2edge`, m28 `s2crossing`, m48 `s2wedge` (+ m23 test) | crossings robust, khoảng cách điểm–đoạn, crosser, quan hệ wedge | `s2edge_crossings.h:127` (gm-02), `s2crossing_edge_query.h:72` (gm-02), `s2wedge_relations.h:37` (gm-02) |
| Operation cấp cao | m07 `s2boolean`, m24 `s2buffer`, m27 `s2winding` | boolean union/intersect/difference; buffer kiểu Minkowski; winding number | `s2boolean_operation.h:211`, `s2buffer_operation.h:63`, `s2winding_operation.h:80` |
| Khoảng cách | m30 `s1chord`, m52 `s2distance`, m31 `s2min`, m29 `s2max`, m05 `s2closest`, m25 `s2furthest`, m33 `s2hausdorff` | S1ChordAngle (dây cung bình phương), target abstraction, 3 cặp query | `s1chord_angle.h:124` (gm-02), `s2distance_target.h:92` (gm-02), `s2closest_edge_query.h:107` |
| Hạ tầng + test + python | m26 `s2text`, m22 `gmock`, m55 `thread`, m36 `s2memory`, m17 `s2density`, m02 `s2-python`, 16 item test-only còn lại (tổng 17 item test-only — m23 đã liệt kê ở cụm Cạnh + predicate; gốc: dòng enum "16" của gm-02 §2.4 thiếu m44, đã sửa theo gm-10) | format test/debug, GMock matcher, race harness, memory tracker, density tree, bindings | `s2text_format.h:66`, `thread_testing.h:33` (gm-02), `s2memory_tracker.h:101`, `module.cc:20` |

Hub dependency (gm-02 §4, deps_out lớn nhất): `s2-core` 60 module phụ thuộc vào; `mutable` 23; `s2text` 32; `s2cell` 31. Ghi chú: `s2builder.cc/.h` và `s2loop.cc/.h`… rơi vào m01 `s2-core` theo luật tiền tố dù là "trái tim" của họ builder/loop — ranh giới cụm ở L3 là quy ước naming, không phải ranh giới biên dịch (1 target `s2` duy nhất chứa cả 108 file).

## 6. Bản đồ thư mục + vai trò vùng

```
s2geometry/
├── CMakeLists.txt            # build chính: project 0.12.0 @13-14; lib s2 @153 (108 .cc);
│                             #   s2testing @346, test_main @362, tests @502; subdirs @539/543
├── src/BUILD.bazel           # bazel (1603 dòng): cc_library s2 @16 (95 srcs), s2shared @287,
│                             #   s2_testing_headers @389, 114 cc_test (428→1595)
├── src/MODULE.bazel          # bazel module "s2geometry" + BCR deps (abseil 20260817.0 @11)
├── README.md LICENSE NOTICE AUTHORS CONTRIBUTING.md CONTRIBUTORS Config.cmake.in
├── flaky_tests.txt           # 13 pattern test flaky — KHÔNG có consumer trong CMakeLists/src (grep = 0 hit)
├── pyproject.toml / setup.py # packaging Python (authors @6-15, description @3)
├── doc/
│   ├── design/               # index_validation.md + images (thiết kế index)
│   ├── examples/             # point_index.cc:25, term_index.cc:38 (2 binary ví dụ)
│   └── pdf/
└── src/
    ├── python/               # item s2-python: module.cc (pybind11 @20), s2.i/SWIG, 12 test .py
    └── s2/                   # 364 file .cc/.h phẳng (maxdepth 1) + subdirs hạ tầng:
        ├── (phẳng)           #   toàn bộ 61 item trừ infra — 124/125 file *_test.cc nằm ở đây
        ├── base/             #   6 file: casts, log_severity, malloc_extension, spinlock, timer
        ├── internal/         #   8 file nội bộ (s2incident_edge_tracker, s2index_cell_data, …)
        ├── testing/          #   test_main.cc:30 (main của test harness) + s2testing
        └── util/             #   bitmap(1) bits(2) coding(6) endian(1) gtl(8) hash(1)
                              #   math(4) + math/exactfloat(7) random(1) task(1) units(3)
```

Số đếm tự chạy trên cây PIN: `find src/s2 -maxdepth 1 -type f (cc|h)` = 364; từng subdir như trên; `find src -name '*_test.cc'` = 125 (124 trong `src/s2`, 1 trong `src/python`).

## 7. Luồng đắt giá — teaser

Chi tiết step-by-step thuộc stream D: **`reports/s2geometry/gm-06-flows.md`** (đang song song, node này KHÔNG chờ — nếu file chưa tồn tại tại thời điểm đọc thì đó là đúng tiến độ, không phải lỗi).

Teaser 4 luồng đắt giá nhất (điểm vào + bằng chứng khai báo):

1. **Boolean operation pipeline**: shape + `MutableS2ShapeIndex` → crossing/predicate → `S2Builder` layer → lax polygon output (`s2boolean_operation.h:211`; engine `s2boolean_operation.cc` 2,773 dòng — gm-02 m07).
2. **Buffering**: `S2BufferOperation` = WindingOperation + S2Builder + MemoryTracker, bán kính âm/0/dương (`s2buffer_operation.h:63`).
3. **Closest/furthest edge query**: duyệt index + prune bằng `S1ChordAngle` (`s2closest_edge_query.h:107`; base dùng chung `s2closest_edge_query_base.h:82` — gm-02 m05).
4. **Encode/decode index**: ghi/đọc index mã hoá, query decode-on-the-fly (`encoded_s2shape_index.h:128`).

## 8. Chạy/harness — lệnh thật

Lệnh chuẩn theo README:

- Bazel (chạy từ `src/`): `bazel test "//:*"` (`README.md:41`), `bazel build //:s2` (`README.md:45`); yêu cầu Bazel 8+ (`README.md:33-35`).
- CMake: `cmake -S . -B build && cmake --build build -j2`; yêu cầu CMake ≥ 3.22 (`README.md:57`), Abseil LTS 20260526 exact (`README.md:61-63`), OpenSSL (`README.md:73-74`, `CMakeLists.txt:315`), C++17 (`CMakeLists.txt:35`). Ubuntu: `sudo apt-get install cmake libssl-dev` (`README.md:71`).

Thực thi thật trong sandbox này (`bitnami/git:latest`, VMware Photon OS 5.0 — image chỉ có git, KHÔNG có cmake/bazel/gcc/python3):

```
$ cmake -S . -B build
bash: line 1: cmake: command not found        # exit=127
$ bazel --version
bash: line 1: bazel: command not found        # exit=127
$ which cmake gcc g++ make python3 swig       # (trống — không tool nào tồn tại)
```

→ **SKIPPED (trung thực)**: sandbox thiếu toàn bộ toolchain và Abseil; cài Abseil-từ-nguồn + build 108 file vượt ngân sách node. KHÔNG bịa output test. Bộ test đáng lẽ chạy: 114 `cc_test` (`src/BUILD.bazel` @428→@1595) trừ 13 pattern flaky (`flaky_tests.txt:1-13`).

## 9. Điểm mở rộng đắt giá (teaser từ gm-02)

1. **`S2Builder::Layer`** (`s2builder_layer.h:29` `class Layer`) — interface để thêm kiểu output mới cho builder pipeline (cả 10 layer của m04 cài interface này).
2. **Snap functions** — chính sách snapping cắm vào builder: `IdentitySnapFunction` @41, `S2CellIdSnapFunction` @82, `IntLatLngSnapFunction` @165 (`s2builderutil_snap_functions.h`).
3. **`S2Region`** — mọi hình cụ thể là `final : public S2Region` (`s2cap.h:62`, `s2cell.h:46`, `s2polygon.h:118`); region mới tự hưởng covering (`s2region_coverer.h:72`) và term indexing (`s2region_term_indexer.h:257`).
4. **`S2ShapeIndex` subtypes + Iterator contract đồng nhất**: `File: src/s2/s2shape_index.h | Dòng: 268-271 | Nội dung: "In addition to implementing a shared set of virtual methods, all S2ShapeIndex subtypes define an Iterator type with the same API."` — index mới (in-memory, encoded, tuỳ ý) cắm vào mọi query hiện có; còn có thể làm template argument để bỏ overhead virtual.
5. **`S2DistanceTarget<Distance>`** (`s2distance_target.h:92` — gm-02 m52) — trừu tượng hoá metric khoảng cách; doc nhắc thay thế được bằng WGS84 ellipsoid (`:48`, `:87`).
6. **Lexicons** (`sequence_lexicon.h:63`, `value_lexicon.h:54`, `id_set_lexicon.h:75` — gm-02 m38/m42/m43) — mở rộng coding/compression của builder.
7. **`S2WrappedShape`** (`s2wrapped_shape.h:30`) — bọc shape có sẵn vào index khác không cần copy.

## 10. Rủi ro khi tái sử dụng

1. **0.x không ổn định API/ABI**: `README.md:19-21`: "Note that all [releases] are version 0.x, so there are [no API or ABI stability guarantees]".
2. **Python API unstable**, SWIG bị lên kế hoạch thay bằng pybind11 (`README.md:25-27`).
3. **Manifest drift CMake ↔ Bazel**: CMake 108 `.cc` vs Bazel 95 srcs; 4 file CHỈ CMake build (grep `src/BUILD.bazel` = 0 hit cho cả 4: `s2density_tree.cc`, `s2chain_interpolation_query.cc`, `s2region_sharder.cc`, `s2shapeutil_count_vertices.cc` — kiểm lại trên PIN lần 2, khớp gm-01 §5.5); `s2random.cc`: CMake biên dịch vào lib, Bazel chỉ test-only (gm-01 §5.5).
4. **Hai manifest pin Abseil khác nhau**: CMake yêu cầu exact LTS `20260526` (`README.md:61-63`) trong khi Bazel dùng `20260817.0` (`src/MODULE.bazel:11`) — cây abseil không thể dùng chung giữa 2 đường build.
5. **Thread model hẹp**: chỉ const-methods thread-safe (`mutable_s2shape_index.h:122-123`; `s2shape_index.h:283-285` "The S2ShapeIndex subtypes provided by the S2 library are thread-compatible").
6. **Flaky test được khai nhận**: 13 pattern (`flaky_tests.txt:1-13`, vd `SignTest\.StressTest`, `CompareEdgeDistance\.Consistency`); README.md:50 còn ghi "On Apple M1, s2loop_measures_test fails due to a 6% excess accumlated error". Lưu ý: **không thấy cơ chế nào trong repo tiêu thụ `flaky_tests.txt`** (`grep -rn flaky_tests CMakeLists.txt src/` = 0 hit) — khả năng chỉ là danh sách tham khảo thủ công [CẦN XÁC MINH].
7. **Text format không giữ precision**: `File: src/s2/s2text_format.h | Dòng: 21-24 | Nội dung: "Be aware that the human-readable format is *not* designed to preserve the full precision of the original object, so it should not be used for data storage."`
8. **Memory risk trên operation lớn**: cần cắm `S2MemoryTracker` + `set_limit_bytes` (`s2memory_tracker.h:54` ví dụ 500 MB, `:127` impl) cho builder/boolean/buffer nếu không muốn OOM.
9. **Lệch tài liệu↔cấu hình C++ version**: README.md:35 nói test bằng "C++20 as set in .bazelrc" nhưng `.bazelrc` KHÔNG tồn tại trong cây (`ls -a` root: không có) và CMake ghim C++17 (`CMakeLists.txt:35`).
10. **Biên CMake version**: README.md:57 yêu cầu ≥ 3.22 nhưng `CMakeLists.txt:1` chỉ `cmake_minimum_required(VERSION 3.18)`; bên trong có submodule đòi 3.26 (`CMakeLists.txt:103`) và SWIG limited-API đòi CMake ≥ 3.26 (`CMakeLists.txt:103` context) — dùng 3.18–3.21 có thể không được test.

## 11. Provenance

- **Repo**: `google/s2geometry`, branch `master`, **PIN `677c8cebcff11ba11accc0b02005bc214e06e9fd`** — `git log -1` trên clone sandbox: `677c8cebcff11ba11accc0b02005bc214e06e9fd 2026-09-25 21:12:25 +0200 build(deps): bump pypa/gh-action-pypi-publish from 1.14.0 to 1.14.2 (#660)` (khớp gm-01 §2; clone lần 1 exit=0, không re-clone).
- **License thật trong repo**: Apache-2.0 — `File: LICENSE | Dòng: 2-3 | Nội dung: "Apache License / Version 2.0, January 2004"`; `NOTICE:1-6`: "S2 Geometry Library Copyright 2017 Google Inc. All Rights Reserved. This product includes software developed at Google".
- **Version**: `0.12.0` (`CMakeLists.txt:13-14` `project(s2-geometry VERSION 0.12.0)`).
- **Census v9** (gm-01 §4, đo trên cùng PIN): 447 files / 154,055 LOC (`.cc` 254/99,497 · `.h` 178/48,992 · `.py` 15/5,566; không có `.hpp`/`.c++`).
- Mọi dòng số trong report này được đo lại trực tiếp trên clone PIN (nguồn trên cả số trong gm-01 khi lệch — xem mục ⚠️ đầu trang).

## 12. Câu hỏi còn mở

1. 4 file chỉ-CMake (mục 10.3) là thiếu sót của `src/BUILD.bazel` hay cố ý loại khỏi Bazel? Chưa thấy comment giải thích trong BUILD.bazel.
2. `.bazelrc` được README.md:35 tham chiếu nhưng không tồn tại trong tree — bị xoá, hay nằm ở nơi khác (CI workflow)? Cần xác minh với maintainer/upstream mới hơn.
3. `flaky_tests.txt` do đâu sinh ra và ai tiêu thụ (grep trong repo = 0 hit) — cơ chế loại-flaky của CI nằm ngoài repo?
4. Hai đường Python binding (SWIG `s2.i` legacy + pybind11 `module.cc`) tồn tại song song tới khi nào; README hứa bỏ SWIG — tiến độ ở đâu?
5. `s2random.cc` hai vai (lib trên CMake, test-only trên Bazel @389-406) — chủ ý hay drift (liên quan câu hỏi 1)?
6. Lệch yêu cầu Abseil giữa 2 manifest (20260526 vs 20260817.0) — đường nào là chuẩn tương lai?
