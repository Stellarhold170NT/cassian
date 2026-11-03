// Structurizr DSL — S2 Geometry (google/s2geometry) C4 model
// Subject: s2geometry | PIN 677c8cebcff11ba11accc0b02005bc214e06e9fd (branch master)
// Node: goldmine-s2geometry--a-c4--110dacaf (stream A, C4 L1-L3)
// Inputs: reports/s2geometry/gm-01-cartography.md + reports/s2geometry/gm-02-module-map.md
// Rule: every element/relationship below carries an `// evidence:` locator into the
//       upstream tree at the PIN above. Elements without evidence are not modeled.
// validate: SKIPPED (tool missing) — no java/structurizr-cli in the sandbox; see
//       reports/s2geometry/diagrams.mmd for the Mermaid fallback rendering.

workspace {
  model {
    // ==== L1 — people ====
    // evidence: doc/examples/point_index.cc:15-25 (C++ consumer: includes s2/s1angle.h,
    //           s2/s2closest_point_query.h, s2/s2earth.h, s2/s2point_index.h, s2/s2random.h; int main @25)
    cppdev = person "C++ Developer" "Builds C++ applications on top of the S2 spherical geometry API"
    // evidence: src/python/README.md:5 ("This directory contains SWIG and pybind11-based Python SDK for S2 Geometry.")
    pydev = person "Python Developer" "Uses the S2 Geometry Python bindings for geospatial scripting"

    // ==== L1 — software system under study ====
    // evidence: README.md:1 ("# S2 Geometry Library"), README.md:6 ("designed to work with _spherical geometry_"),
    //           README.md:8 ("especially suitable for working with geographic data")
    s2 = softwareSystem "S2 Geometry Library" "C++ library for robust geometry on the surface of a sphere, with Python bindings"

    // ==== L1 — external systems ====
    // evidence: CMakeLists.txt:88 ("find_package(absl REQUIRED)"), src/MODULE.bazel:11
    //           ("bazel_dep(name = \"abseil-cpp\", version = \"20260817.0\")"); 312 files under src/s2 include absl headers
    absl = softwareSystem "Abseil (absl)" "Google open-source C++ common libraries linked into the S2 core"
    // evidence: CMakeLists.txt:312-315 ("Currently only bignum_test requires OpenSSL." / option SKIP_OPENSSL_TESTS /
    //           find_package(OpenSSL REQUIRED)); src/s2/util/math/exactfloat/bignum_test.cc:32-33 (<openssl/bn.h>)
    openssl = softwareSystem "OpenSSL libcrypto" "Crypto/bignum library required only to build and run bignum unit tests"
    // evidence: CMakeLists.txt:45 ("option(BUILD_TESTS \"Build s2 unittests.\" ON)"), src/s2/s2polygon_test.cc:34
    //           (#include <gtest/gtest.h>), src/MODULE.bazel:19 (googletest dev dependency)
    gtest = softwareSystem "GoogleTest" "Unit-test framework used by the test suite of the library"
    // evidence: CMakeLists.txt:47 ("option(WITH_PYTHON \"Add python interface\" OFF)"),
    //           CMakeLists.txt:543 (add_subdirectory("src/python" python)), src/python/module.cc:20 (PYBIND11_MODULE)
    pyrt = softwareSystem "Python Runtime" "Python interpreter that loads the s2geometry extension module"

    // ==== L1 — relationships ====
    // evidence: doc/examples/point_index.cc:15-25
    cppdev -> s2 "Uses the C++ geometry API (includes s2/*.h)"
    // evidence: src/python/README.md:5, src/python/module.cc:20
    pydev -> s2 "Uses the Python bindings module"
    // evidence: CMakeLists.txt:88, src/MODULE.bazel:11
    s2 -> absl "Compiled and linked against"
    // evidence: CMakeLists.txt:312-315, src/s2/util/math/exactfloat/bignum_test.cc:32-33
    s2 -> openssl "Runs bignum unit tests against (test-only dependency)"
    // evidence: CMakeLists.txt:45, src/s2/s2polygon_test.cc:34
    s2 -> gtest "Builds and runs its unit tests with"
    // evidence: CMakeLists.txt:47, CMakeLists.txt:543, src/python/module.cc:20
    s2 -> pyrt "Ships the s2geometry extension module for"

    s2 {
      // ==== L2 — containers ====
      // Container set = the 14 pillar (non-test-only) file-prefix families of src/s2 from
      // reports/s2geometry/gm-02-module-map.md (items m01-m15 minus test-only m10), 1:1.
      // Selection rule: non-test-only gm-02 items with >= 3,432 LOC; covers ~68% of mined LOC (95,403/139,825).
      // Direction of `uses` = C++ include of the target family's headers, grep-verified on the PIN tree.
      // Note: class S2Builder lives in the core family (no sub-prefix), so there is no
      // separate core->builder edge; the builder family (m09) only owns Graph/Layer plumbing.

      // evidence: src/s2/s2polygon.h:118 (class S2Polygon final : public S2Region), src/s2/s2loop.h:95,
      //           src/s2/s2builder.h:149 (class S2Builder), src/s2/s2cell.h:46 (class S2Cell final : public S2Region),
      //           src/s2/s2shape.h:64 (class S2Shape), src/s2/s2cap.h:62, src/s2/s2latlng.h:47,
      //           src/s2/s2predicates.h:330 (inline int Sign); gm-02 item m01 (20,879 LOC)
      core = container "S2 Core Types" "Foundational geometry types without a sub-prefix: S2Polygon, S2Loop, S2Builder, S2Cell, S2Shape, S2Cap, S2LatLng, robust predicates" "C++17 (src/s2 flat core)"
      // evidence: src/python/module.cc:20 (PYBIND11_MODULE(s2geometry_bindings, m)),
      //           src/python/s2_common.i:893-917 (29 %include "s2/*.h" for the SWIG path); gm-02 item m02 (9,125 LOC)
      pybind = container "Python Bindings" "pybind11 module (s2geometry_bindings) plus legacy SWIG interface exposing S2 to Python" "pybind11 + SWIG (src/python)"
      // evidence: src/s2/s2cell_id.h:91 (class S2CellId), src/s2/s2cell_union.h:65 (class S2CellUnion final : public S2Region),
      //           src/s2/s2cell_index.h:108 (class S2CellIndex); gm-02 item m03 (8,746 LOC)
      cellfam = container "Cell Framework" "Spatial addressing units: S2CellId (64-bit Hilbert cell), S2CellUnion, S2CellIndex" "C++17 (src/s2)"
      // evidence: src/s2/s2builderutil_lax_polygon_layer.h:73 (class LaxPolygonLayer : public S2Builder::Layer),
      //           src/s2/s2builderutil_s2polygon_layer.h:76 (class S2PolygonLayer : public S2Builder::Layer),
      //           src/s2/s2builderutil_snap_functions.h:82 (S2CellIdSnapFunction), :165 (IntLatLngSnapFunction); gm-02 item m04 (8,213 LOC)
      builderutil = container "Builder Output Layers" "S2Builder::Layer implementations and snap functions that turn builder graphs into output geometry" "C++17 (src/s2)"
      // evidence: src/s2/s2closest_edge_query.h:107 (class S2ClosestEdgeQuery), src/s2/s2closest_cell_query.h:89,
      //           src/s2/s2closest_point_query.h:204; gm-02 item m05 (8,084 LOC)
      closest = container "Distance Queries" "Closest-distance query stack over S2ShapeIndex: edge, cell and point queries plus shared bases" "C++17 (src/s2)"
      // evidence: src/s2/s2edge_crossings.h:127 (int CrossingSign), src/s2/s2edge_crosser.h:69 (S2EdgeCrosserBase),
      //           src/s2/s2edge_distances.h:50 (S1Angle GetDistance); gm-02 item m06 (6,608 LOC)
      edge = container "Edge Geometry" "Geodesic edge primitives: robust crossing tests, point-to-segment distance, edge crosser, tessellation" "C++17 (src/s2)"
      // evidence: src/s2/s2boolean_operation.h:211 (class S2BooleanOperation), src/s2/s2boolean_operation.cc (2,773 LOC engine); gm-02 item m07 (5,706 LOC)
      boolean = container "Boolean Operations" "Union/intersection/difference engine over shapes, built on the S2Builder pipeline" "C++17 (src/s2)"
      // evidence: src/s2/encoded_s2shape_index.h:128 (class EncodedS2ShapeIndex final : public S2ShapeIndex),
      //           src/s2/encoded_s2point_vector.h:57 (class EncodedS2PointVector); gm-02 item m08 (4,693 LOC)
      encoded = container "Encoded Storage" "Decode-on-the-fly codecs: encoded cell id/point vectors, strings and an encoded S2ShapeIndex" "C++17 (src/s2)"
      // evidence: src/s2/s2builder_graph.h:57 (class S2Builder::Graph), src/s2/s2builder_layer.h:29 (class S2Builder::Layer); gm-02 item m09 (4,555 LOC)
      builder = container "Builder Graph & Layer" "S2Builder::Graph edge/label API and the S2Builder::Layer interface implemented by output layers" "C++17 (src/s2)"
      // evidence: src/s2/s2shape_index.h:286 (class S2ShapeIndex, abstract base); gm-02 item m11 (4,185 LOC)
      shape = container "Shape Index Abstraction" "S2ShapeIndex abstract base plus index-region/measures/nesting helpers" "C++17 (src/s2)"
      // evidence: src/s2/mutable_s2shape_index.h:135 (class MutableS2ShapeIndex final : public S2ShapeIndex),
      //           src/s2/mutable_s2shape_index.h:630 (MutableS2ShapeIndex::BatchGenerator); gm-02 item m12 (3,815 LOC)
      mutable = container "Mutable Shape Index" "Default in-memory mutable S2ShapeIndex with adaptive cell clustering" "C++17 (src/s2)"
      // evidence: src/s2/s2shapeutil_edge_iterator.h:37 (class EdgeIterator); gm-02 item m13 (3,719 LOC)
      shapeutil = container "Shape Utilities" "Algorithms over shapes/indexes: edge iteration, crossing pairs, brute-force containment, coding factories" "C++17 (src/s2)"
      // evidence: src/s2/s2region_coverer.h:72 (class S2RegionCoverer), src/s2/s2region_term_indexer.h:112 (class S2RegionTermIndexer); gm-02 item m14 (3,643 LOC)
      region = container "Region Covering" "S2RegionCoverer approximations of regions by cell unions and the region term indexer for inverted indexes" "C++17 (src/s2)"
      // evidence: src/s2/s2latlng_rect.h:63 (class S2LatLngRect final : public S2Region); gm-02 item m15 (3,432 LOC)
      latlng = container "Lat/Lng Regions" "Rectangular latitude/longitude regions: S2LatLngRect and its incremental bounder" "C++17 (src/s2)"

      // ==== L2 — relationships (grep-verified includes, file:line) ====
      // evidence: src/s2/s2polygon.h:41 (#include "s2/s2cell_id.h")
      core -> cellfam "Depends on (includes S2CellId/S2CellUnion headers)"
      // evidence: src/s2/s2polygon.h:37 (#include "s2/mutable_s2shape_index.h")
      core -> mutable "Depends on (S2Polygon/S2Loop/S2Builder use MutableS2ShapeIndex)"
      // evidence: src/s2/s2polygon.h:51 (#include "s2/s2shape_index.h")
      core -> shape "Depends on (includes S2ShapeIndex)"
      // evidence: src/s2/s2polygon.h:39 (#include "s2/s2boolean_operation.h")
      core -> boolean "Depends on (S2Polygon convenience API includes BooleanOperation)"

      // evidence: src/s2/s2boolean_operation.h:29 (#include "s2/s2builder.h"); also src/s2/s2boolean_operation.cc:90
      boolean -> builder "Engine builds results through S2Builder"
      // evidence: src/s2/s2boolean_operation.cc:93 (#include "s2/s2builderutil_snap_functions.h")
      boolean -> builderutil "Uses snap functions for its output layers"
      // evidence: src/s2/s2boolean_operation.h:34 (#include "s2/s2shape_index.h")
      boolean -> shape "Operates on S2ShapeIndex inputs"

      // evidence: src/s2/mutable_s2shape_index.h:44 (#include "s2/s2shape_index.h"), :135 (": public S2ShapeIndex")
      mutable -> shape "Implements the S2ShapeIndex interface"
      // evidence: src/s2/mutable_s2shape_index.h:39 (#include "s2/s2cell_id.h")
      mutable -> cellfam "Clusters shapes along S2CellId cells"
      // evidence: src/s2/mutable_s2shape_index.h:45 (#include "s2/s2shapeutil_shape_edge_id.h")
      mutable -> shapeutil "Uses ShapeEdgeId bookkeeping"

      // evidence: src/s2/encoded_s2shape_index.h:37 (#include "s2/s2shape_index.h"), :128 (": public S2ShapeIndex")
      encoded -> shape "Implements the S2ShapeIndex interface"
      // evidence: src/s2/encoded_s2shape_index.h:33 (#include "s2/mutable_s2shape_index.h")
      encoded -> mutable "Shares cell vector machinery with the mutable index"

      // evidence: src/s2/s2closest_edge_query_base.h:50 (#include "s2/s2shape_index.h")
      closest -> shape "Queries run over S2ShapeIndex"
      // evidence: src/s2/s2closest_edge_query_base.h:44 (#include "s2/s2cell_id.h"), :45 (#include "s2/s2cell_union.h")
      closest -> cellfam "Prunes candidates by cell id / cell union"
      // evidence: src/s2/s2closest_edge_query_base.h:48 (#include "s2/s2region_coverer.h")
      closest -> region "Uses S2RegionCoverer to prioritize cells"
      // evidence: src/s2/s2closest_edge_query_base.h:51 (#include "s2/s2shapeutil_count_edges.h")
      closest -> shapeutil "Uses shape edge counting helpers"

      // evidence: src/s2/s2builderutil_lax_polygon_layer.h:47 (#include "s2/s2builder_layer.h"), :45 (#include "s2/s2builder.h")
      builderutil -> builder "Layers implement S2Builder::Layer and consume S2Builder::Graph"
      // evidence: src/s2/s2builderutil_lax_polygon_layer.h:44 (#include "s2/mutable_s2shape_index.h")
      builderutil -> mutable "Indexed layers output into a MutableS2ShapeIndex"

      // evidence: src/s2/s2builder.h:40 (#include "s2/mutable_s2shape_index.h")
      builder -> mutable "Builds graphs from index contents"
      // evidence: src/s2/s2builder.h:43 (#include "s2/s2cell_id.h")
      builder -> cellfam "Snaps and keys edges by S2CellId"
      // evidence: src/s2/s2builder.h:44 (#include "s2/s2edge_crossings.h")
      builder -> edge "Detects crossing edges while building"

      // evidence: src/s2/s2region_coverer.h:33 (#include "s2/s2cell_union.h")
      region -> cellfam "Coverings are S2CellUnion outputs"

      // evidence: src/s2/s2shapeutil_edge_iterator.h:24 (#include "s2/s2shape_index.h")
      shapeutil -> shape "Utilities iterate over S2ShapeIndex contents"
      // evidence: src/s2/s2shapeutil_coding.h:47 (#include "s2/encoded_string_vector.h")
      shapeutil -> encoded "Coding factories use encoded string vectors"

      // evidence: src/s2/s2shape_index.h:58 (#include "s2/s2shape.h")
      shape -> core "Indexes store S2Shape objects from core"
      // evidence: src/s2/s2edge_crossings.h:47 (#include "s2/s2predicates.h")
      edge -> core "Robust crossings built on core predicates"
      // evidence: src/s2/s2latlng_rect.h:36 (#include "s2/s2region.h")
      latlng -> core "Rects implement the core S2Region interface"
      // evidence: src/s2/s2cell_id.h:45 (#include "s2/s2region.h")
      cellfam -> core "CellId/CellUnion derive from core S2Region"

      // evidence: src/python/s2_common.i:913 (%include "s2/s2polygon.h")
      pybind -> core "Binds core geometry classes to Python"
      // evidence: src/python/s2_common.i:897 (%include "s2/s2boolean_operation.h")
      pybind -> boolean "Exposes BooleanOperation"
      // evidence: src/python/s2_common.i:901 (%include "s2/s2builderutil_s2polygon_layer.h")
      pybind -> builderutil "Exposes builder output layers"
      // evidence: src/python/s2_common.i:902 (%include "s2/s2cell_id.h"), :918 (%include "s2/s2cell.h")
      pybind -> cellfam "Exposes cell id / cell types"
      // evidence: src/python/s2_common.i:903 (%include "s2/s2edge_crossings.h"), :904 (%include "s2/s2edge_distances.h")
      pybind -> edge "Exposes edge geometry helpers"
      // evidence: src/python/s2_common.i:916 (%include "s2/s2region_coverer.h"), :917 (%include "s2/s2region_term_indexer.h")
      pybind -> region "Exposes covering and term indexer"
      // evidence: src/python/s2_common.i:908 (%include "s2/s2latlng.h"), :909 (%include "s2/s2latlng_rect.h")
      pybind -> latlng "Exposes lat/lng types and rects"
      // evidence: src/python/s2_common.i:921 (%include "s2/mutable_s2shape_index.h")
      pybind -> mutable "Exposes MutableS2ShapeIndex"
      // evidence: src/python/s2_common.i:920 (%include "s2/s2shape_index.h")
      pybind -> shape "Exposes S2ShapeIndex"
      // evidence: src/python/module.cc:20 (PYBIND11_MODULE(s2geometry_bindings, m))
      pybind -> pyrt "Loads as an extension module into"

      // ==== L3 — components of the 3 main containers ====
      // Deep-dive choice (rationale in reports/s2geometry/gm-03-c4.md): core = largest family
      // (gm-02 deps_in 24), mutable = runtime engine (deps_in 12), closest = query stack (deps_in 13).

      core {
        // evidence: src/s2/s2region.h (abstract base of the region hierarchy; every ": public S2Region" below)
        s2region = component "S2Region" "Abstract region interface implemented by the concrete core types" "C++17 abstract class"
        // evidence: src/s2/s2polygon.h:118 (class S2Polygon final : public S2Region)
        s2polygon = component "S2Polygon" "Multi-loop polygon on the sphere with region operations and coding" "C++17 class"
        // evidence: src/s2/s2loop.h:95 (class S2Loop final : public S2Region)
        s2loop = component "S2Loop" "Simple closed loop of vertices; containment and area semantics" "C++17 class"
        // evidence: src/s2/s2builder.h:149 (class S2Builder)
        s2builder = component "S2Builder" "Framework that snaps edges into a graph and emits it to layers" "C++17 class"
        // evidence: src/s2/s2cell.h:46 (class S2Cell final : public S2Region)
        s2cell = component "S2Cell" "Concrete cell region with exact edges from the S2 hierarchy" "C++17 class"
        // evidence: src/s2/s2shape.h:64 (class S2Shape)
        s2shape = component "S2Shape" "Abstract read-only geometry interface consumed by indexes and queries" "C++17 abstract class"
        // evidence: src/s2/s2cap.h:62 (class S2Cap final : public S2Region)
        s2cap = component "S2Cap" "Circular cap region on the sphere" "C++17 class"
        // evidence: src/s2/s2latlng.h:47 (class S2LatLng)
        s2latlng = component "S2LatLng" "Latitude/longitude point representation and conversions" "C++17 class"
        // evidence: src/s2/s2predicates.h:330 (inline int Sign), src/s2/s2predicates.cc (1,960 LOC exact arithmetic)
        s2predicates = component "S2Predicates" "Exact robust predicates (Sign, OrderedCCW, ...) underpinning all topology decisions" "C++17 functions"

        // evidence: src/s2/s2polygon.h:118 (": public S2Region")
        s2polygon -> s2region "Implements"
        // evidence: src/s2/s2loop.h:95 (": public S2Region")
        s2loop -> s2region "Implements"
        // evidence: src/s2/s2cell.h:46 (": public S2Region")
        s2cell -> s2region "Implements"
        // evidence: src/s2/s2cap.h:62 (": public S2Region")
        s2cap -> s2region "Implements"
        // evidence: src/s2/s2polygon.h:46 (#include "s2/s2loop.h")
        s2polygon -> s2loop "Composed of loops"
        // evidence: src/s2/s2polygon.h:40 (#include "s2/s2builder.h")
        s2polygon -> s2builder "Convenience construction via builder"
        // evidence: src/s2/s2builder.h:51 (#include "s2/s2shape.h")
        s2builder -> s2shape "Consumes input shapes"
        // evidence: src/s2/s2polygon.h:37 (#include "s2/mutable_s2shape_index.h")
        s2polygon -> s2.mutable "Uses the mutable index container"
        // evidence: src/s2/s2builder.h:43 (#include "s2/s2cell_id.h")
        s2builder -> s2.cellfam "Snaps by cell id"
        // evidence: src/s2/s2builder.h:44 (#include "s2/s2edge_crossings.h")
        s2builder -> s2.edge "Crossing detection during build"
        // evidence: src/s2/s2edge_crossings.h:47 (#include "s2/s2predicates.h")
        s2.edge -> s2predicates "Crossing tests call exact Sign predicates"
      }

      mutable {
        // evidence: src/s2/mutable_s2shape_index.h:135 (class MutableS2ShapeIndex final : public S2ShapeIndex)
        mIdx = component "MutableS2ShapeIndex" "Adaptively clustered in-memory index; add/remove shapes and query incrementally" "C++17 class"
        // evidence: src/s2/mutable_s2shape_index.h:146 (class Options)
        mOpts = component "MutableS2ShapeIndex::Options" "Configuration: cell size limits, edge count tuning" "C++17 nested class"
        // evidence: src/s2/mutable_s2shape_index.h:295 (class Iterator final : public IteratorBase)
        mIter = component "MutableS2ShapeIndex::Iterator" "Cell iterator over the clustered index contents" "C++17 nested class"
        // evidence: src/s2/mutable_s2shape_index.h:447 (class InteriorTracker)
        mTracker = component "InteriorTracker" "Tracks which cells a shape interior covers during refinement" "C++17 nested class"
        // evidence: src/s2/mutable_s2shape_index.h:630 (class MutableS2ShapeIndex::BatchGenerator)
        mBatch = component "MutableS2ShapeIndex::BatchGenerator" "Generates deterministic randomized index batches for testing" "C++17 nested class"

        // evidence: src/s2/mutable_s2shape_index.h:135 (": public S2ShapeIndex") and :44 (#include "s2/s2shape_index.h")
        mIdx -> s2.shape "Implements S2ShapeIndex"
        // evidence: src/s2/mutable_s2shape_index.h:39 (#include "s2/s2cell_id.h")
        mIdx -> s2.cellfam "Clusters along S2CellId"
        // evidence: src/s2/mutable_s2shape_index.h:45 (#include "s2/s2shapeutil_shape_edge_id.h")
        mIdx -> s2.shapeutil "ShapeEdgeId bookkeeping"
        // evidence: src/s2/mutable_s2shape_index.h:146 (Options declared inside MutableS2ShapeIndex)
        mIdx -> mOpts "Configured by"
        // evidence: src/s2/mutable_s2shape_index.h:295 (Iterator declared inside MutableS2ShapeIndex)
        mIdx -> mIter "Iterated by clients via"
        // evidence: src/s2/mutable_s2shape_index.h:447 (InteriorTracker declared inside MutableS2ShapeIndex)
        mIdx -> mTracker "Drives during cell refinement"
        // evidence: src/s2/mutable_s2shape_index.h:630 (BatchGenerator named MutableS2ShapeIndex::BatchGenerator)
        mBatch -> mIdx "Generates test batches for"
      }

      closest {
        // evidence: src/s2/s2closest_edge_query_base.h:82 (class S2ClosestEdgeQueryBase)
        eqBase = component "S2ClosestEdgeQueryBase<Distance>" "Template engine that traverses the index and returns nearest edges for any Distance type" "C++17 template"
        // evidence: src/s2/s2closest_cell_query_base.h:71 (class S2ClosestCellQueryBase)
        cqBase = component "S2ClosestCellQueryBase<Distance>" "Template engine returning nearest cells" "C++17 template"
        // evidence: src/s2/s2closest_point_query_base.h:154 (class S2ClosestPointQueryBase)
        pqBase = component "S2ClosestPointQueryBase<Distance>" "Template engine returning nearest indexed points" "C++17 template"
        // evidence: src/s2/s2closest_edge_query.h:107 (class S2ClosestEdgeQuery)
        edgeQuery = component "S2ClosestEdgeQuery" "Concrete edge query over S2MinDistance" "C++17 class"
        // evidence: src/s2/s2closest_cell_query.h:89 (class S2ClosestCellQuery)
        cellQuery = component "S2ClosestCellQuery" "Concrete cell query over S2MinDistance" "C++17 class"
        // evidence: src/s2/s2closest_point_query.h:204 (class S2ClosestPointQuery)
        pointQuery = component "S2ClosestPointQuery" "Concrete point query over S2MinDistance" "C++17 class"

        // evidence: src/s2/s2closest_edge_query.h:35 (#include "s2/s2closest_edge_query_base.h")
        edgeQuery -> eqBase "Uses the shared base engine"
        // evidence: src/s2/s2closest_cell_query.h:31 (#include "s2/s2closest_cell_query_base.h")
        cellQuery -> cqBase "Uses the shared base engine"
        // evidence: src/s2/s2closest_point_query.h:29 (#include "s2/s2closest_point_query_base.h")
        pointQuery -> pqBase "Uses the shared base engine"
        // evidence: src/s2/s2closest_edge_query_base.h:48 (#include "s2/s2region_coverer.h")
        eqBase -> s2.region "Prioritizes cells via S2RegionCoverer"
        // evidence: src/s2/s2closest_edge_query_base.h:50 (#include "s2/s2shape_index.h")
        eqBase -> s2.shape "Traverses S2ShapeIndex"
      }
    }
  }

  views {
    // L1
    systemContext s2 "S2Context" {
      include *
      description "L1 — System Context: developers and external systems around the S2 Geometry Library"
      autolayout lr
    }
    // L2
    container s2 "S2Containers" {
      include *
      description "L2 — Containers: the 14 pillar file-prefix families of src/s2 plus the Python bindings (gm-02)"
      autolayout tb
    }
    // L3 deep dives
    component s2 core "CoreComponents" {
      include *
      description "L3 — S2 Core Types components"
      autolayout tb
    }
    component s2 mutable "MutableIndexComponents" {
      include *
      description "L3 — Mutable Shape Index components"
      autolayout tb
    }
    component s2 closest "DistanceQueryComponents" {
      include *
      description "L3 — Distance Query stack components"
      autolayout tb
    }
  }
}
