---
subject: google/s2geometry
measured_at: 677c8cebcff11ba11accc0b02005bc214e06e9fd
status: final
---


# Folders

## 1. Bản đồ vùng chính (từ `top_dirs` của gm-01 §7: doc, doc/design, doc/examples, doc/pdf, src, src/python, src/s2)

Cây maxdepth-2 đo lại trên PIN (raw, trùng gm-01 §7):

```
.
├── doc/            (design/  examples/  pdf/)
├── src/            (MODULE.bazel + python/ + s2/)
└── CMakeLists.txt, README.md, setup.py, pyproject.toml, flaky_tests.txt, Config.cmake.in, LICENSE, NOTICE, AUTHORS, CONTRIBUTORS, CONTRIBUTING.md
```

| Vùng | Đường dẫn thật | Vai trò (1 câu) | Evidence |
|---|---|---|---|
| Build root | `CMakeLists.txt` | Toàn bộ build CMake của repo: khai báo project `s2-geometry VERSION 0.12.0`, chuẩn C++17, target lib `s2` (108 file .cc, dòng 153–261), test loop và 2 subdirectory `doc/examples` + `src/python`. | File: CMakeLists.txt \| Dòng: 1, 13–14, 35–38 \| Nội dung: `cmake_minimum_required(VERSION 3.18)` … `project(s2-geometry` `VERSION 0.12.0)` … `set(CMAKE_CXX_STANDARD 17 CACHE STRING "The C++ standard to build with")` (769 dòng, trùng gm-01 §5.1) |
| Docs | `doc/design/` | Tài liệu thiết kế chuyên sâu: bài 937 dòng về validation của shape index kèm ảnh minh hoạ. | File: doc/design/index_validation.md \| Dòng: 1–937 (wc -l = 937) \| Nội dung: design doc `index_validation.md`; thư mục kèm `doc/design/images/` |
| Docs | `doc/examples/` | 2 binary ví dụ C++ có `int main` (duy nhất trong repo ngoài test harness) + 1 ví dụ Python, được CMake build khi `BUILD_EXAMPLES=ON`. | File: doc/examples/point_index.cc \| Dòng: 25; doc/examples/term_index.cc \| Dòng: 38 \| Nội dung: `int main(int argc, char **argv)` / `int main(int argc, char** argv)` (gm-01 §6); CMakeLists.txt:539 `add_subdirectory("doc/examples" examples)` |
| Docs | `doc/pdf/` | Chứa đúng 1 file PDF xuất từ design doc. | `ls doc/pdf` → `dd-index-validation.pdf` (count = 1) |
| Code chính | `src/s2/` | Thư viện S2 toàn phần: 238 file .cc (gồm 124 `*_test.cc`) nằm phẳng + 4 thư mục phụ `base/` `internal/` `testing/` `util/`; 95–108 file .cc của lib `s2` khai báo từ đây. | gm-01 §4 (`*_test.cc in src/s2 = 124`, `all .cc in src/s2 = 238`); đếm lại subdir: base=6, internal=8, testing=2, util=35 file (.cc/.h) |
| Python binding | `src/python/` | Binding Python cho cả thư viện theo 2 đường song song: pybind11 (`module.cc` + 11 `*_bindings.cc`) và SWIG legacy (`s2.i`, `s2_common.i`) cho `setup.py` ở root. | gm-02 m02; gm-01 §4 liệt kê nội dung `src/python` gồm cả `module.cc`, `s2.i`, `s2_common.i`, 12 file `*_test.py` |
| Bazel module | `src/MODULE.bazel` | Điểm vào Bzlmod của project — nhưng đặt ở `src/` chứ không ở root (xem lệch L3). | `ls MODULE.bazel` → `No such file or directory`; `ls src/MODULE.bazel` → tồn tại (30 dòng, gm-01 §5.2) |
| Root phụ | `setup.py`, `pyproject.toml` | Packaging Python (pip) đọc SWIG interface từ `src/python/`. | `ls -p` root: `setup.py`, `pyproject.toml` tồn tại |
| Root phụ | `flaky_tests.txt` | Danh sách test known-flaky bị loại khỏi run (regex một dòng một test). | File: flaky_tests.txt \| Dòng: 1–5 \| Nội dung: `AllowedShapeTests/S2ClosestEdgeQueryShapeTest\.(CircleEdges\|FractalEdges…`, `CompareEdgeDistance\.Consistency`, … |

Ghi nhận: ngoài 7 `top_dirs` của gm-01, root còn các file phẳng nêu trên — không có thư mục `test/`, `tests/`, `include/`, `examples/` tách rời nào ở cấp repo.

## 2. Cấu trúc bên trong đại diện: họ `s2-core` (m01 — họ lớn nhất gm-02: 20,879 LOC, deps_in 24 / deps_out 60)

Đại diện được chọn theo brief = **họ tiền tố lớn nhất trong gm-02 = `s2-core` (m01)**, nằm phẳng trong `src/s2/`.

### 2.1 Layout: cặp .h/.cc một-class-một-file

Đo trên PIN, file phẳng `src/s2` (maxdepth 1) có basename **không chứa `_`** (đúng luật họ s2-core; kèm `_fp_contract_off.h`):

- **54 file code chính = 30 .h + 24 .cc**: `s2builder.cc/.h`, `s2polygon.cc/.h`, `s2polyline.cc/.h`, `s2loop.cc/.h`, `s2predicates.cc/.h`, `s2cap.cc/.h`, `s2cell.cc/.h`, `s2latlng.cc/.h`, `s1angle.cc/.h`, `s1interval.cc/.h`, `r1interval.h`, `r2.h`, `r2rect.cc/.h`, `s2coords.cc/.h`, `s2shape.h`, `s2region.h`, `s2point.h`, `s2coder.h`, `s2error.cc/.h`, `s2earth.cc/.h`, `s2fractal.cc/.h`, `s2measures.cc/.h`, `s2metrics.cc/.h`, `s2pointutil.cc/.h`, `s2projections.cc/.h`, `s2r2rect.cc/.h`, `s2centroids.cc/.h`, `s2debug.cc/.h`, `s2random.cc/.h`, `s2testing.cc/.h`, `_fp_contract_off.h`.
- **Header-only**: một số class nhỏ chỉ có `.h`, không có `.cc` — ví dụ `s2point.h` (176 dòng), `s2shape.h`, `s2region.h`, `s2coder.h`, `r1interval.h`. (raw `find` ở mục 2.1: các file này không có cặp .cc cùng tên)
- **Kích thước code chính** (wc -l đo lại, khớp gm-02 m01 main_files): `s2builder.cc` 2208, `s2predicates.cc` 1960, `s2polygon.cc` 1595, `s2loop.cc` 1508; header lớn `s2cell.h` 358, `s2point.h` 176.

### 2.2 Code chính vs test — tách bằng hậu tố, không tách thư mục

- Test nằm **cạnh** code, cùng thư mục phẳng `src/s2/`, đặt tên `<tên>_test.cc`: `s2polygon_test.cc` (4,414 dòng — item m10) cạnh `s2polygon.cc`; `s2builder_test.cc` (1,871 — thuộc item s2builder m09) cạnh `s2builder.cc`; `s2loop_test.cc` (2,084 — item m16) cạnh `s2loop.cc`; `s2cap_test.cc`, `s2latlng_test.cc`, `s2predicates_test.cc` cùng mẫu. (raw ls: 6/6 file tồn tại; tổng `*_test.cc` toàn src/s2 = 124, khớp gm-01 §4)
- Hạ tầng test-support cũng nằm trong vùng phẳng này: `s2testing.h`/`s2testing.cc` (218 dòng header, guard `S2_S2TESTING_H_`) — vì basename không có `_`, luật tiền tố gm-02 kéo 2 file này vào **chính item s2-core** → item "code chính" chứa kèm file test-support; ngoài ra `gmock_matchers.h/.cc` (m22), `thread_testing.h/.cc` (m55), 6 file `*_testing.h` (m61 `s2coder_testing.h` v.v.).
- Phần KHÔNG thuộc s2-core nhưng cùng cha `src/s2/`: 4 thư mục phụ bị luật phẳng loại ra (NOASSIGN trong gm-02) — `src/s2/base/` (6 file: casts, log_severity, malloc_extension, spinlock, timer…), `src/s2/internal/` (8 file: s2incident_edge_tracker, s2index_cell_data…), `src/s2/testing/` (2 file — gtest_prod.h nằm ở đây), `src/s2/util/` (35 file trong 10 subdir riêng BUILD.bazel: bitmap, bits, coding, endian, gtl, hash, math, random, task, units).

### 2.3 Mẫu bên trong một file

- File: src/s2/s2polygon.cc | Dòng: 18, 43–45 | Nội dung: `#include "s2/s2polygon.h"` rồi `#include "s2/base/casts.h"` `#include "s2/mutable_s2shape_index.h"` `#include "s2/r1interval.h"` — include gốc-tương-đối `src/`, hệ thống `<...>` tách riêng phía trên (dòng 20–22: `<algorithm>`, `<array>`, `<atomic>`).
- File: src/s2/s2polygon.h | Dòng: 18 | Nội dung: `#ifndef S2_S2POLYGON_H_` — include guard chuẩn Google, không `#pragma once` (0/177 header trong src/s2 dùng `#pragma once`).

## 3. Quy ước đặt tên đọc được từ code (≥3 ví dụ)

1. **Prefix miền đối tượng trong tên file**: `s2*` = hình trên sphere đơn vị (`s2polygon.h` khai báo `S2Polygon`), `s1*` = đại lượng 1 chiều trên đường tròn (`s1angle`, `s1interval`, `s1chord_angle`), `r1*`/`r2*` = hình học phẳng 1D/2D (`r1interval.h`, `r2.h`, `r2rect.h`). Gia đình tiện ích có prefix riêng: `encoded_*` (codec decode-on-the-fly, m08), `mutable_*` (index đột biến, m12), `s2builderutil_*` (layer đầu-ra cho S2Builder, m04), `s2shapeutil_*` (tiện ích vận hành shape, m13).
2. **Hậu tố vai trò**: `*_test.cc` = unit test (124 file); `*_internal.h` = helper riêng tư của 1 implementation file (5 file: `s2predicates_internal.h`, `s2coords_internal.h`, `s2edge_crossings_internal.h`, `s2polyline_alignment_internal.h`, `s2density_tree_internal.h`); `*_testing.h` = helper dùng cho test của module khác (6 file: `s2coder_testing.h`, `s2builderutil_testing.h`, `s2cell_iterator_testing.h`, `s2closest_edge_query_testing.h`, `s2shapeutil_testing.h`, `thread_testing.h`).
3. **Tên file snake_case ↔ tên class CamelCase khớp 1-1**: `s2polygon.h` → `class S2Polygon`, `s2builderutil_lax_polygon_layer.h:73` → `class LaxPolygonLayer : public S2Builder::Layer` (grep dòng 73), `mutable_s2shape_index.h:135` → `MutableS2ShapeIndex final : public S2ShapeIndex` (gm-02 m12).
4. **Include guard sinh từ đường dẫn**: `S2_S2POLYGON_H_` (s2polygon.h:18), `S2_S2CELL_H_` (s2cell.h:18), `S2_UTIL_CODING_VARINT_H_` (src/s2/util/coding/varint.h:30) — mẫu `S2_<ĐƯỜNG_DẪN>_H_`.
5. **Namespace = miền nghịch đảo của prefix file**: `namespace S2` cho API chính (s2predicates.h — `int Sign @87`, `OrderedCCW @103` theo gm-02 m23), `namespace s2random`, `namespace s2coding` (s2coder_testing.h:27 theo gm-02 m61).

## 4. Chỗ LỆCH chuẩn C++ (mỗi chỗ ≥2 ví dụ — đều verify trên clone PIN, không bịa)

> "Chuẩn" ở đây = quy ước bố cục/danh cần của một project C++ hiện đại (đặt tên file nhất quán, tách test khỏi production tree, manifest build một nguồn chân lý, mã nguồn ASCII). 4 lệch đáng kể:

### L1. Tên file không nhất quán: kebab-case trong `src/s2/util/` vs snake_case toàn phần còn lại

- Ví dụ 1: `src/s2/util/bits/bit-interleave.cc` + `bit-interleave.h`
- Ví dụ 2: `src/s2/util/units/length-units.cc` + `length-units.h` + `physical-units.h`
- Ví dụ 3: `src/s2/util/coding/nth-derivative.h`
- Đối chiếu: toàn bộ `src/s2` phẳng dùng snake_case (`s2boolean_operation.cc`, `mutable_s2shape_index.cc`) — raw `find src/s2/util -name '*-*'` = 6 file kebab-case, 0 file kebab-case ngoài `util/`.

### L2. Test code và hạ tầng test lẫn vào production tree (không có thư mục test riêng)

- Ví dụ 1: 124 file `*_test.cc` nằm ngay `src/s2/` phẳng cạnh file production — `s2polygon_test.cc` cạnh `s2polygon.cc`, `s2builder_test.cc` cạnh `s2builder.cc` (ls verify).
- Ví dụ 2: `src/s2/s2testing.h` + `s2testing.cc` (test helper sinh dữ liệu ngẫu nhiên) nằm trong vùng production phẳng và vì không có `_` bị luật tiền tố kéo vào item `s2-core` (m01) — item "code chính" chứa file test-support.
- Ví dụ 3: `src/s2/gmock_matchers.h/.cc` (polyfill GMock matcher, m22) và `src/s2/thread_testing.h/.cc` (m55) — hạ tầng test thuần nằm phẳng giữa code production.
- Điểm nhấn cùng nhóm: 1 production header include hạ tầng test — File: src/s2/s2loop.h | Dòng: 49 | Nội dung: `#include "s2/testing/gtest_prod.h"`; và Dòng: 538 `FRIEND_TEST(S2LoopTestBase, PointersCorrectAfterMove);` (macro khai báo friend test trong header production; `gtest_prod.h` là header duy nhất làm vậy — grep toàn src/s2 `--include='*.h'` chỉ hit s2loop.h).

### L3. Manifest build không một nguồn chân lý + vị trí MODULE.bazel bất thường

- Ví dụ 1: `MODULE.bazel` nằm ở `src/` thay vì root — `ls MODULE.bazel` → `No such file or directory`; chuẩn Bzlmod đặt module file ở repo root (gm-01 §5.2 cũng ghi nhận).
- Ví dụ 2: hai manifest khai báo lib `s2` lệch nhau trên cùng cây PIN: CMake `add_library(s2 ...)` = **108** file .cc (CMakeLists.txt:153–261) vs Bazel `cc_library(name = "s2")` = **95** (src/BUILD.bazel:16–285); 4 file chỉ CMake build, không nằm target Bazel nào — `s2chain_interpolation_query.cc`, `s2density_tree.cc`, `s2region_sharder.cc`, `s2shapeutil_count_vertices.cc` (verify lại: `grep -c 's2density_tree.cc' src/BUILD.bazel` = 0, `grep -c 's2chain_interpolation_query.cc' src/BUILD.bazel` = 0; chi tiết phân rã 108=95+8+4+1 ở gm-01 §5.5).
- Ví dụ 3: `s2random.cc` khác vai giữa hai hệ — CMake biên dịch vào lib `s2`, Bazel chỉ dùng trong target test-only `s2_testing_headers` (gm-01 §5.5 mục 3).

### L4. Ký tự non-ASCII trong comment mã nguồn

- Ví dụ 1: File: src/s2/s1chord_angle.cc | Dòng: 78 | Nội dung: `//   u is the unit round-off, equal to ε/2 = 2^-53`
- Ví dụ 2: File: src/s2/s2predicates.h | Dòng: 182 | Nội dung: `//                            | N   •  |` (ASCII-art có bullet Unicode; lưu ý s1chord_angle.cc chỉ dài 157 dòng nên không thể chứa dòng 182)
- Ví dụ 3: `src/s2/s2predicates.h` và `src/s2/s2predicates.cc` cũng chứa non-ASCII (grep -rlP tổng cộng 8 file .cc/.h trong src/s2, gồm cả 2 file test `s2builder_test.cc`, `s2cell_test.cc`).

### Những điểm KIỂM RA và KHÔNG phải lệch (để gate không hiểu lầm)

- Không dùng tab (0 file), không CRLF (0 file), các .cc core lớn không có dòng >100 ký tự (awk trên s2builder.cc/s2predicates.cc/s2polygon.cc = 0); dòng >100 chỉ rải rác ~10 file test, 1–5 dòng mỗi file.
- Header extension thống nhất `.h` (0 file `.hpp`, 0 `.hxx` — census gm-01 §4).
- Chuẩn ngôn ngữ ghim cứng C++17, tắt extension compiler: CMakeLists.txt:35–38 (`set(CMAKE_CXX_STANDARD 17 …)` @35, `set(CMAKE_CXX_EXTENSIONS OFF)` @38).
- 0/177 header dùng `#pragma once` — nhất quán hoàn toàn theo include guard.

## 5. Gợi ý đọc hiểu (đọc gì trước, vì sao)

1. **`README.md` (231 dòng) trước tiên** — định vị sản phẩm: thư viện hình học trên sphere, khác biệt với geometry library phẳng (dòng 1–12, raw sed ở trên).
2. **`src/s2/s2point.h` (176 dòng) → `s2latlng.h` → `s2cell.h` (358 dòng)** — bộ kiểu nền nhỏ, đọc nhanh; mọi họ khác (deps_out của m01 = 60/61 item) đều include các kiểu này.
3. **`src/s2/s2shape.h` rồi `src/s2/s2shape_index.h` (638 dòng)** — hai abstraction trung tâm (shape = hình trừu tượng; index = cấu trúc truy vấn); hiểu 2 interface này là hiểu được nửa số tên file trong `src/s2`.
4. **`src/s2/mutable_s2shape_index.h` (776 dòng) + design doc `doc/design/index_validation.md` (937 dòng)** — index mặc định mà mọi query/operation chạy trên đó; doc design giải thích lý thuyết validation đằng sau.
5. **`src/s2/s2builder.h` (1,325 dòng) → `s2builderutil_*_layer.h`** — pipeline dựng/sửa hình học; các operation lớn (`s2boolean_operation.cc` 2,773 dòng, `s2buffer_operation.cc`, `s2winding_operation.cc`) đều đi qua builder.
6. **Cuối cùng: query family `s2closest_*_base.h` / `s2edge_*`** — chỉ cần khi làm việc với khoảng cách/cắt cạnh; chúng xây trên index và predicates đã đọc ở bước 2–4.

Lý do thứ tự: hướng phụ thuộc trong gm-02 — m01 `s2-core` deps_in 24 (được mọi người phụ thuộc), m12 `mutable` deps_out 23 (index nuôi toàn bộ query/boolean/buffer) → đọc nền trước, operation trên builder sau, query lá cuối.

---

## JSON BLOCK (máy đọc)

```json
{
  "repo": "google/s2geometry",
  "sha": "677c8cebcff11ba11accc0b02005bc214e06e9fd",
  "inputs": ["reports/s2geometry/gm-01-cartography.md", "reports/s2geometry/gm-02-module-map.md"],
  "representative_family": {"module": "s2-core", "id": "m01", "loc": 20879, "flat_files": {"h": 30, "cc": 24, "extra": "_fp_contract_off.h"}, "largest": {"s2builder.cc": 2208, "s2predicates.cc": 1960, "s2polygon.cc": 1595, "s2loop.cc": 1508}},
  "regions": [
    {"path": "CMakeLists.txt", "role": "cmake build root, project s2-geometry 0.12.0, C++17, lib s2 = 108 .cc"},
    {"path": "doc/design", "role": "design docs (index_validation.md 937 lines + images)"},
    {"path": "doc/examples", "role": "2 C++ example binaries (point_index.cc, term_index.cc) + 1 py"},
    {"path": "doc/pdf", "role": "1 pdf (dd-index-validation.pdf)"},
    {"path": "src/s2", "role": "core C++ library: 238 .cc (124 are *_test.cc) flat + base/internal/testing/util subdirs"},
    {"path": "src/python", "role": "python bindings: pybind11 module.cc + 11 *_bindings.cc + SWIG s2.i/s2_common.i + 12 *_test.py"},
    {"path": "src/MODULE.bazel", "role": "bzlmod module file (unusually under src/, not root)"}
  ],
  "naming_conventions": [
    "s2*/s1*/r1*/r2* domain prefixes; encoded_/mutable_/s2builderutil_/s2shapeutil_ utility prefixes",
    "suffixes: *_test.cc (124), *_internal.h (5), *_testing.h (6)",
    "snake_case file <-> CamelCase class 1:1 (s2polygon.h -> S2Polygon)",
    "include guards S2_<PATH>_H_ (S2_S2POLYGON_H_, S2_UTIL_CODING_VARINT_H_)"
  ],
  "deviations": [
    {"id": "L1", "name": "kebab-case files in src/s2/util vs snake_case elsewhere", "examples": ["src/s2/util/bits/bit-interleave.cc", "src/s2/util/units/length-units.cc", "src/s2/util/units/physical-units.h", "src/s2/util/coding/nth-derivative.h"], "count": 6},
    {"id": "L2", "name": "test code colocated in production flat tree", "examples": ["124 *_test.cc in src/s2 flat", "src/s2/s2testing.h/.cc (no '_' -> pulled into s2-core item)", "src/s2/gmock_matchers.h/.cc", "src/s2/thread_testing.h/.cc", "src/s2/s2loop.h:49 includes s2/testing/gtest_prod.h"], "count": "124 test files + 4 test-infra file pairs"},
    {"id": "L3", "name": "build manifest drift + MODULE.bazel location", "examples": ["MODULE.bazel under src/ not root", "CMake add_library(s2)=108 vs Bazel cc_library=95; 4 CMake-only files verified 0 hits in src/BUILD.bazel", "s2random.cc: CMake prod vs Bazel test-only"], "count": 3},
    {"id": "L4", "name": "non-ASCII chars in source comments", "examples": ["src/s2/s1chord_angle.cc:78 'ε/2'", "src/s2/s2predicates.h:182 '•'", "src/s2/s2predicates.cc"], "count": 8}
  ],
  "not_deviations": ["0 tabs, 0 CRLF, no >100-char lines in core .cc", "all headers .h (0 .hpp)", "C++17 pinned, extensions off (CMakeLists.txt:35-38)", "0/177 headers use #pragma once (consistent guards)"],
  "reading_order": ["README.md", "src/s2/s2point.h + s2latlng.h + s2cell.h", "src/s2/s2shape.h + s2shape_index.h", "src/s2/mutable_s2shape_index.h + doc/design/index_validation.md", "src/s2/s2builder.h + s2builderutil_*_layer.h", "s2closest_* / s2edge_* queries"]
}
```
