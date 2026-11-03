---
subject: google/s2geometry
measured_at: 677c8cebcff11ba11accc0b02005bc214e06e9fd
status: final
---


# Usage

## Bảng 8/8 item — module | dùng khi nào | deps_out

| s_id | m_id | module | sao | dùng khi nào | deps_out |
|---|---|---|---|---|---|
| s15 | m15 | s2latlng | 3 | Vùng chữ nhật lat/lng: geofence bbox — điểm có nằm trong vùng phục vụ (Contains, nới biên ExpandedByDistance theo km), bbox tuyến đường khi GPS về stream (S2LatLngRectBounder), hợp/giao hai vùng (Union/Intersection). | gmock, mutable, s2-core, s2cap, s2cell, s2closest, s2convex, s2edge, s2loop, s2point, s2polygon, s2polyline, s2random, s2r2rect, s2region, s2shape, s2text |
| s22 | m22 | gmock | 3 | Unit test hình học: polyfill GMock matcher cho kiểu S2 (Point/Polyline/Polygon/Loop/LatLngRect/LatLng) dùng EXPECT_THAT với dung sai S1Angle, khớp từ chuỗi lat:lng hoặc từ object. | s2loop, s2polygon, s2polyline, s2region |
| s06 | m06 | s2edge | 2 | Hình học cạnh trắc địa: hai cạnh có cắt nhau (CrossingSign robust +1/0/-1), khoảng cách điểm–đoạn (GetDistance, cảnh báo tàu lệch luồng), duyệt chuỗi biên nhiều đỉnh (S2EdgeCrosser), tessellate cạnh cho vẽ map. | encoded, mutable, s1chord, s2-core, s2boolean, s2buffer, s2builder, s2builderutil, s2cell, s2chain, s2closest, s2contains, s2convex, s2crossing, s2furthest, s2latlng, s2loop, s2max, s2min, s2pointutil, s2polygon, s2polyline, s2predicates, s2shape, s2shapeutil, s2validation, s2winding |
| s14 | m14 | s2region | 2 | Covering/index cho mọi S2Region: xấp xỉ vùng bằng tối đa N cell để join không gian (S2RegionCoverer), index POI thành term cho inverted index và query theo vùng (S2RegionTermIndexer — example thật term_index.cc), gộp nhiều vùng thành một S2Region (S2RegionUnion). | s2cell, s2closest, s2density, s2polygon, s2shape |
| s16 | m16 | s2loop | 2 | Đo đạc loop khép kín trên mặt cầu: chu vi + diện tích thửa đất (GetPerimeter/GetArea/GetApproxArea, 0..4π sr, đổi m² qua S2Earth), diện tích ròng polygon nhiều loop có hole (GetSignedArea), đo trực tiếp trên S2Loop qua vertices_span(). | s2-core, s2shape |
| s20 | m20 | s2lax | 2 | Hình học lỏng không cần strict validity: polygon/polyline từ dữ liệu GPS thô (S2LaxPolygonShape đếm loop/đỉnh/chain, S2LaxPolylineShape duyệt đỉnh), output tự nhiên của S2Builder layers, đầu vào boolean/winding. | encoded, mutable, s2-core, s2boolean, s2buffer, s2builder, s2builderutil, s2chain, s2density, s2hausdorff, s2max, s2shape, s2shapeutil, s2text, s2validation, s2winding, s2wrapped |
| s21 | m21 | s2point | 2 | Điểm rời rạc: truy vấn POI trong bán kính (S2PointIndex + S2ClosestPointQuery — example thật point_index.cc), dump toàn bộ index (Iterator), so khớp điểm chính xác (S2PointRegion::Contains ==) và bọc tập điểm thành S2Shape (S2PointVectorShape). | encoded, mutable, s2-core, s2boolean, s2buffer, s2builderutil, s2cell, s2closest, s2contains, s2density, s2edge, s2furthest, s2hausdorff, s2lax, s2loop, s2max, s2polyline, s2region, s2shape, s2shapeutil, s2text, s2winding |
| s26 | m26 | s2text | 2 | Fixture test/debug: dựng geometry từ chuỗi lat:lng (Make*/MakeXxxOrDie), parse đầu vào không tin cậy (MakePoint bool overload), in lại geometry bằng ToString cho 10 kiểu; format không giữ full precision — không dùng để lưu dữ liệu. | encoded, gmock, mutable, s2-core, s2boolean, s2buffer, s2builder, s2builderutil, s2cell, s2chain, s2closest, s2contains, s2convex, s2crossing, s2density, s2edge, s2furthest, s2hausdorff, s2lax, s2latlng, s2loop, s2max, s2min, s2point, s2polygon, s2polyline, s2region, s2shape, s2shapeutil, s2validation, s2winding, s2wrapped |

## JSON block — 8 object (mỗi object 1 dòng, parse được bằng JSON parser chuẩn)

```json
[
{"s_id":"s15","m_id":"m15","module":"s2latlng","dung_khi_nao":"Vùng chữ nhật lat/lng: geofence bbox — điểm có nằm trong vùng phục vụ (Contains, nới biên ExpandedByDistance theo km), bbox tuyến đường khi GPS về stream (S2LatLngRectBounder), hợp/giao hai vùng (Union/Intersection).","deps_out":["gmock","mutable","s2-core","s2cap","s2cell","s2closest","s2convex","s2edge","s2loop","s2point","s2polygon","s2polyline","s2random","s2r2rect","s2region","s2shape","s2text"]},
{"s_id":"s22","m_id":"m22","module":"gmock","dung_khi_nao":"Unit test hình học: polyfill GMock matcher cho kiểu S2 (Point/Polyline/Polygon/Loop/LatLngRect/LatLng) dùng EXPECT_THAT với dung sai S1Angle, khớp từ chuỗi lat:lng hoặc từ object.","deps_out":["s2loop","s2polygon","s2polyline","s2region"]},
{"s_id":"s06","m_id":"m06","module":"s2edge","dung_khi_nao":"Hình học cạnh trắc địa: hai cạnh có cắt nhau (CrossingSign robust +1/0/-1), khoảng cách điểm–đoạn (GetDistance, cảnh báo tàu lệch luồng), duyệt chuỗi biên nhiều đỉnh (S2EdgeCrosser), tessellate cạnh cho vẽ map.","deps_out":["encoded","mutable","s1chord","s2-core","s2boolean","s2buffer","s2builder","s2builderutil","s2cell","s2chain","s2closest","s2contains","s2convex","s2crossing","s2furthest","s2latlng","s2loop","s2max","s2min","s2pointutil","s2polygon","s2polyline","s2predicates","s2shape","s2shapeutil","s2validation","s2winding"]},
{"s_id":"s14","m_id":"m14","module":"s2region","dung_khi_nao":"Covering/index cho mọi S2Region: xấp xỉ vùng bằng tối đa N cell để join không gian (S2RegionCoverer), index POI thành term cho inverted index và query theo vùng (S2RegionTermIndexer — example thật term_index.cc), gộp nhiều vùng thành một S2Region (S2RegionUnion).","deps_out":["s2cell","s2closest","s2density","s2polygon","s2shape"]},
{"s_id":"s16","m_id":"m16","module":"s2loop","dung_khi_nao":"Đo đạc loop khép kín trên mặt cầu: chu vi + diện tích thửa đất (GetPerimeter/GetArea/GetApproxArea, 0..4π sr, đổi m² qua S2Earth), diện tích ròng polygon nhiều loop có hole (GetSignedArea), đo trực tiếp trên S2Loop qua vertices_span().","deps_out":["s2-core","s2shape"]},
{"s_id":"s20","m_id":"m20","module":"s2lax","dung_khi_nao":"Hình học lỏng không cần strict validity: polygon/polyline từ dữ liệu GPS thô (S2LaxPolygonShape đếm loop/đỉnh/chain, S2LaxPolylineShape duyệt đỉnh), output tự nhiên của S2Builder layers, đầu vào boolean/winding.","deps_out":["encoded","mutable","s2-core","s2boolean","s2buffer","s2builder","s2builderutil","s2chain","s2density","s2hausdorff","s2max","s2shape","s2shapeutil","s2text","s2validation","s2winding","s2wrapped"]},
{"s_id":"s21","m_id":"m21","module":"s2point","dung_khi_nao":"Điểm rời rạc: truy vấn POI trong bán kính (S2PointIndex + S2ClosestPointQuery — example thật point_index.cc), dump toàn bộ index (Iterator), so khớp điểm chính xác (S2PointRegion::Contains ==) và bọc tập điểm thành S2Shape (S2PointVectorShape).","deps_out":["encoded","mutable","s2-core","s2boolean","s2buffer","s2builderutil","s2cell","s2closest","s2contains","s2density","s2edge","s2furthest","s2hausdorff","s2lax","s2loop","s2max","s2polyline","s2region","s2shape","s2shapeutil","s2text","s2winding"]},
{"s_id":"s26","m_id":"m26","module":"s2text","dung_khi_nao":"Fixture test/debug: dựng geometry từ chuỗi lat:lng (Make*/MakeXxxOrDie), parse đầu vào không tin cậy (MakePoint bool overload), in lại geometry bằng ToString cho 10 kiểu; format không giữ full precision — không dùng để lưu dữ liệu.","deps_out":["encoded","gmock","mutable","s2-core","s2boolean","s2buffer","s2builder","s2builderutil","s2cell","s2chain","s2closest","s2contains","s2convex","s2crossing","s2density","s2edge","s2furthest","s2hausdorff","s2lax","s2latlng","s2loop","s2max","s2min","s2point","s2polygon","s2polyline","s2region","s2shape","s2shapeutil","s2validation","s2winding","s2wrapped"]}
]
```

---

## s15 — s2latlng

> *Merge provenance: `gm-12-usage-w1.md` @10 (worker u_w1) · `u-status-w1.json`: section_done=true, examples=3, evidence_lines=17 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

Họ này cung cấp vùng chữ nhật trong hệ tọa độ lat/lng: class **S2LatLngRect** (`final : public S2Region`) biểu diễn một khung giới hạn trên trái đất, cho phép hỏi nhanh một điểm/rect/cell có nằm trong hoặc có giao với khung hay không; kèm **S2LatLngRectBounder** để tích lũy dần các điểm (stream) rồi lấy bbox nhỏ nhất bao trọn. Nhu cầu thực tế: geofence theo bbox (vùng phục vụ xe, vùng kho, cửa sổ bản đồ), tính bbox tuyến đường, hợp/giao các vùng quảng cáo (gm-02 m15: "Vùng chữ nhật lat/lng — S2LatLngRect final : public S2Region (s2latlng_rect.h:63), S2LatLngRectBounder (s2latlng_rect_bounder.h:37)").

### (b) Use cases

#### UC-1: Geofence — điểm pickup có nằm trong vùng phục vụ (bbox) hay không

Kịch bản: một trạm xe khai vùng phục vụ dạng khung lat/lng quanh trung tâm; hệ thống phải từ chối đơn nằm ngoài vùng, nhưng vẫn nhận đơn biên nếu nới khung thêm một khoảng cách vật lý cố định (km). `FromCenterSize` dựng khung từ tâm + kích thước, `Contains(S2LatLng)` trả lời câu hỏi chứa, `ExpandedByDistance` nới khung theo bán kính thực (km→radian qua `S2Earth`).

```cpp
#include "s2/s1angle.h"
#include "s2/s2earth.h"
#include "s2/s2latlng.h"
#include "s2/s2latlng_rect.h"

// Vùng phục vụ: bbox tâm (21.028, 105.834), kích thước đầy đủ 0.2° x 0.3°.
S2LatLngRect MakeServiceZone() {
  return S2LatLngRect::FromCenterSize(
      S2LatLng::FromDegrees(21.028, 105.834),
      S2LatLng::FromDegrees(0.20, 0.30));      // size = full height x width
}

bool CanServe(const S2LatLngRect& zone, const S2LatLng& pickup) {
  if (zone.Contains(pickup)) return true;      // trong bbox gốc
  // Nới biên thêm 3 km để nhận cả đơn nằm sát mép vùng.
  return zone.ExpandedByDistance(
      S1Angle::Radians(S2Earth::KmToRadians(3.0))).Contains(pickup);
}
```

Evidence (grep trên cây PIN):
- `src/s2/s2latlng_rect.h:92` — `static S2LatLngRect FromCenterSize(const S2LatLng& center, ...)`; `:179` — `bool Contains(const S2LatLng& ll) const;`; `:295` — `S2LatLngRect ExpandedByDistance(S1Angle distance) const;`
- `src/s2/s2latlng.h:72` — `static constexpr S2LatLng FromDegrees(double lat_degrees, double lng_degrees);`
- `src/s2/s2earth.h:52` — `static constexpr double KmToRadians(double km);`; `src/s2/s1angle.h:86` — `static constexpr S1Angle Radians(double radians);`

#### UC-2: Tính bbox tuyến đường khi điểm GPS đến dần theo stream

Kịch bản: điểm GPS của một tuyến xe buýt về hệ thống theo từng đợt, chưa biết trước biên. `S2LatLngRectBounder` nạp từng điểm (`AddPoint`) rồi lấy `GetBound()` — bbox nhỏ nhất bao trọn mọi điểm đã thấy, dùng làm khóa cache hoặc cửa sổ truy vấn bản đồ.

```cpp
#include <vector>
#include "s2/s2latlng.h"
#include "s2/s2latlng_rect.h"
#include "s2/s2latlng_rect_bounder.h"

// bbox tuyến xe buýt: nạp dần từng điểm GPS rồi lấy khung bao trọn.
S2LatLngRect RouteBounds(const std::vector<S2LatLng>& samples) {
  S2LatLngRectBounder bounder;                 // bounder rỗng
  for (const S2LatLng& p : samples) {
    bounder.AddPoint(p.ToPoint());             // nạp từng điểm GPS
  }
  return bounder.GetBound();                   // khung nhỏ nhất chứa hết
}

// Cửa sổ bản đồ người dùng có đụng tới tuyến này không?
bool MapWindowSeesRoute(const S2LatLngRect& bbox,
                        const S2LatLngRect& map_window) {
  return bbox.Intersects(map_window);
}
```

Evidence:
- `src/s2/s2latlng_rect_bounder.h:37` — `class S2LatLngRectBounder {`; `:39` — `S2LatLngRectBounder() : bound_(S2LatLngRect::Empty()) {}` (ctor mặc định); `:44` — `void AddPoint(const S2Point& b);`; `:54` — `S2LatLngRect GetBound() const;`
- `src/s2/s2latlng.h:126` — `S2Point ToPoint() const;`
- `src/s2/s2latlng_rect.h:200` — `bool Intersects(const S2LatLngRect& other) const;`

#### UC-3: Hợp / giao hai vùng quảng cáo lat-lng

Kịch bản: hai chiến dịch quảng cáo khai vùng theo cặp góc (đi qua `FromPointPair`); hệ thống phải biết hai vùng có chồng nhau không, vùng trùng là gì (tính ngân sách trùng lặp), và khung phủ tổng (để vẽ bản đồ). Cả `Intersects`, `Intersection`, `Union`, `Contains(rect)` đều là phép đại số hộp chạy tức thời.

```cpp
#include "s2/s2latlng.h"
#include "s2/s2latlng_rect.h"

// Hai vùng quảng cáo khai bằng cặp góc đối diện.
S2LatLngRect campaign_a = S2LatLngRect::FromPointPair(
    S2LatLng::FromDegrees(10.0, 106.6), S2LatLng::FromDegrees(10.8, 106.8));
S2LatLngRect campaign_b = S2LatLngRect::FromPointPair(
    S2LatLng::FromDegrees(10.5, 106.7), S2LatLng::FromDegrees(11.2, 107.0));

bool overlap       = campaign_a.Intersects(campaign_b);      // có chồng nhau?
S2LatLngRect common = campaign_a.Intersection(campaign_b);   // vùng trùng
S2LatLngRect total  = campaign_a.Union(campaign_b);          // khung phủ cả hai
bool nested        = campaign_a.Contains(campaign_b);        // A chứa trọn B?
```

Evidence:
- `src/s2/s2latlng_rect.h:103` — `static S2LatLngRect FromPointPair(const S2LatLng& p1, const S2LatLng& p2);`; `:200` — `Intersects(const S2LatLngRect&)`; `:257` — `S2LatLngRect Intersection(const S2LatLngRect& other) const;`; `:251` — `S2LatLngRect Union(const S2LatLngRect& other) const;`; `:192` — `bool Contains(const S2LatLngRect& other) const;`

### (d) Deps cần kéo theo

- Include trong ví dụ: `s2/s2latlng.h`, `s2/s2latlng_rect.h`, `s2/s2latlng_rect_bounder.h`, `s2/s1angle.h`, `s2/s2earth.h`.
- Link: thư viện `s2` (build từ `CMakeLists.txt` root — đã kiểm `ls CMakeLists.txt` tồn tại trên cây PIN). Không dep ngoài nào khác; `S2LatLng`/`S2Point`/`S1Angle` thuộc s2-core (cùng lib). Theo `u-checklist.json` deps_out của s15 có 17 item — ví dụ trên chỉ dùng lớp nền (s2-core, s2latlng), không kéo boolean/builder.

### (e) Build

**SKIPPED** — sandbox `bitnami/git:latest` không có toolchain: `which cmake g++ make gcc` trả về "no cmake / no g++ / no make / no gcc"; node bị cấm cài dependency. Repo có `CMakeLists.txt` ở root (đã `ls` thấy) nhưng KHÔNG có `src/s2/CMakeLists.txt`; không chạy được `cmake -S . -B build && cmake --build build -j2` → không ghi output build (cấm bịa).

---

## s22 — gmock

> *Merge provenance: `gm-12-usage-w1.md` @113 (worker u_w1) · `u-status-w1.json`: section_done=true, examples=3, evidence_lines=14 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

Polyfill GMock matcher cho các kiểu hình học S2 (`gmock_matchers.h:27-28`): thay vì so sánh tay từng đỉnh trong unit test, item này cung cấp matcher cho S2Point/S2Polyline/S2Polygon/S2Loop/S2LatLngRect/S2LatLng dùng trực tiếp trong `EXPECT_THAT`, hỗ trợ cả so khớp từ chuỗi `"lat:lng"` lẫn từ object, với dung sai `S1Angle` (gm-02 m22: "gmock_matchers — polyfill GMock matcher cho kiểu S2 ... cho unit test hình học").

### (b) Use cases

#### UC-1: Unit test geocoder trả về đúng tọa độ trong dung sai

Kịch bản: hàm geocode của ứng dụng trả về `S2Point`; test phải khớp tọa độ thật "10.7724:106.6980" trong dung sai nhỏ (0.0001°). `S2::PointApproxEquals(string, S1Angle)` nhận chuỗi hoặc object, in diff dễ đọc khi fail (`PointEquals` dùng khi muốn so chính xác tuyệt đối).

```cpp
#include <gmock/gmock.h>
#include "s2/gmock_matchers.h"
#include "s2/s1angle.h"

// Geocoder trả về S2Point; test khớp tọa độ thật trong dung sai 1e-4 độ.
TEST(GeocodingTest, ReturnsExpectedLocationWithinTolerance) {
  S2Point got = Geocode("Ben Thanh market");          // hàm của ứng dụng
  EXPECT_THAT(got, S2::PointApproxEquals("10.7724:106.6980",
                                         S1Angle::Degrees(1e-4)));
}

// So chính xác theo chuỗi — parse bằng s2textformat bên trong matcher.
TEST(GeocodingTest, MatchesExactString) {
  EXPECT_THAT("10:10", S2::PointEquals("10:10"));
}
```

Evidence:
- `src/s2/gmock_matchers.h:556` — `PolymorphicMatcher<S2PointMatcher> PointApproxEquals(absl::string_view expected, S1Angle tolerance);`; `:553` — `PointEquals(absl::string_view expected);`; `:162` — `class S2PointMatcher {`
- `src/s2/gmock_matchers.h:54` — doc comment ví dụ chính thức `EXPECT_THAT(latlng, S2::LatLngEquals("10:10"));`, `:85` — `EXPECT_THAT(point, S2::PointEquals("10:10");`
- `src/s2/s1angle.h:87` — `static constexpr S1Angle Degrees(double degrees);`
- Dùng thật trong test suite: `src/s2/gmock_matchers_test.cc:76` — `EXPECT_THAT("10:10", PointApproxEquals("10:10", S1Angle::Radians(1e-10)));`

#### UC-2: Test kết quả polygon do engine tính khớp polygon kỳ vọng

Kịch bản: engine ứng dụng (vd: bao lồi của các điểm kho) trả về `S2Polygon`; test khớp hình kỳ vọng viết dưới dạng chuỗi đỉnh trong dung sai 1e-7°, và phủ định bằng `Not(PolygonEquals(...))` khi muốn chắc hình KHÔNG rơi vào một hình khác.

```cpp
#include <gmock/gmock.h>
#include "s2/gmock_matchers.h"
#include "s2/s1angle.h"
#include "s2/s2polygon.h"

// Hull do engine tính phải khớp polygon kỳ vọng trong dung sai 1e-7 độ.
TEST(HullTest, HullMatchesExpectedRegion) {
  std::vector<S2Point> pts = ReadDepots();            // dữ liệu ứng dụng
  S2Polygon hull = ComputeConvexHull(pts);            // engine ứng dụng
  EXPECT_THAT(hull, S2::PolygonApproxEquals("0:0, 0:3, 3:3, 3:0",
                                            S1Angle::Degrees(1e-7)));
  EXPECT_THAT(hull, Not(S2::PolygonEquals("0:0, 0:1, 1:1")));
}
```

Evidence:
- `src/s2/gmock_matchers.h:603` — `PolygonApproxEquals(absl::string_view expected, S1Angle tolerance);`; `:600` — `PolygonEquals(absl::string_view expected);`; `:272` — `class S2PolygonMatcher {`

#### UC-3: Test cửa sổ tile lat-lng khớp kỳ vọng, kể cả matcher Options riêng

Kịch bản: ứng dụng tính cửa sổ tile dưới dạng `S2LatLngRect`; test khớp "gần đúng" theo dung sai lat/lng riêng (`LatLngRectApproxEquals` string + S1Angle) hoặc so chính xác qua matcher class có `Options` riêng với 3 kiểu so sánh `EQUALS / APPROX_EQUALS / APPROX_EQUALS_2` trùng tên phương thức của `S2LatLngRect`.

```cpp
#include <gmock/gmock.h>
#include "s2/gmock_matchers.h"
#include "s2/s1angle.h"
#include "s2/s2latlng_rect.h"

// Cửa sổ tile ứng dụng tính phải khớp kỳ vọng trong dung sai 1e-6 độ.
TEST(TileTest, TileWindowMatchesExpected) {
  S2LatLngRect got = ComputeTileWindow();             // ứng dụng
  EXPECT_THAT(got, S2::LatLngRectApproxEquals(
      "10.0:106.0, 10.9:106.9", S1Angle::Degrees(1e-6)));
  // Chắc chắn KHÔNG trùng hình khác: Not(LatLngRectEquals(...)).
  EXPECT_THAT(got, Not(S2::LatLngRectEquals("10:106, 10.9:106.9")));
}
```

Evidence:
- `src/s2/gmock_matchers.h:661` — `LatLngRectApproxEquals(absl::string_view expected, S1Angle tolerance);`; `:658` — `LatLngRectEquals(absl::string_view expected);`; `:429` — `class S2LatLngRectMatcher {` với `struct Options` + `enum ComparisonType { EQUALS, APPROX_EQUALS, APPROX_EQUALS_2 }` (`:433-452`, đã đọc nguyên khối Options).

### (d) Deps cần kéo theo

- External bắt buộc: `<gmock/gmock.h>` (matcher là `::testing::PolymorphicMatcher`), absl (`absl::string_view` — include thấy ở đầu header `gmock_matchers.h`).
- Header S2: `s2/gmock_matchers.h` tự kéo `s2/s2latlng.h`, `s2/s2latlng_rect.h`, `s2/s2loop.h`, `s2/s2point.h`, `s2/s2polygon.h`, `s2/s2polyline.h`, `s2/s2text_format.h` (đọc phần include đầu file, dòng 22-35) — khớp `deps_out` của s22 trong `u-checklist.json` (s2loop, s2polygon, s2polyline, s2region).
- Ví dụ dùng thêm `s2/s1angle.h` (S1Angle::Degrees).

### (e) Build

**SKIPPED** — cùng lý do mục s15(e): sandbox không có cmake/g++/make; không chạy được build, không bịa output.

---

## s06 — s2edge

> *Merge provenance: `gm-12-usage-w1.md` @207 (worker u_w1) · `u-status-w1.json`: section_done=true, examples=3, evidence_lines=12 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

Họ hàm tự do và lớp hỗ trợ cho hình học cạnh trắc địa: `S2::CrossingSign` trả lời chính xác (robust predicate) hai cạnh có cắt nhau không; `S2::GetDistance` đo khoảng cách điểm–đoạn; `S2EdgeCrosser` tái dùng một cạnh (a,b) để thử cắt liên tiếp với nhiều cạnh của một chuỗi mà không tính lại từ đầu; ngoài họ còn `S2EdgeTessellator` (chia cạnh trắc địa thành nhiều đoạn cho vẽ map) và `S2EdgeVectorShape` (gói tập cạnh thành S2Shape) — gm-02 m06.

### (b) Use cases

#### UC-1: Cạnh đường bay có cắt vùng cấm bay (đoạn biên) không?

Kịch bản: cạnh a→b của đường bay và cạnh c→d là một đoạn biên vùng cấm; hệ thống cần biết có cắt thực sự (+1), chạm đúng đỉnh (0) hay không cắt (−1) để quyết định phân mảnh đường bay. `S2::CrossingSign` là predicate robust (không sai số floating point ở gần biên).

```cpp
#include "s2/s2edge_crossings.h"
#include "s2/s2latlng.h"
#include "s2/s2point.h"

// Cạnh đường bay a→b có cắt đoạn biên vùng cấm c→d không?
bool FlightPathCrossesNoFly(const S2Point& a, const S2Point& b,
                            const S2Point& c, const S2Point& d) {
  int sign = S2::CrossingSign(a, b, c, d);
  if (sign > 0) return true;    // hai cạnh cắt thực sự
  if (sign == 0) return true;   // chạm đúng đỉnh (vertex crossing)
  return false;                 // -1: không cắt
}
```

Evidence:
- `src/s2/s2edge_crossings.h:127` — `int CrossingSign(const S2Point& a, const S2Point& b, ...)` (khai báo trong namespace S2; quy ước trả về +1/0/−1 nêu ở comment `:113-116` của cùng file).

#### UC-2: Tàu lệch bao xa khỏi luồng hải trình?

Kịch bản: luồng hải trình là đoạn trắc địa a→b; hệ thống giám sát tàu nhận vị trí `ship` mỗi giây và phải cảnh báo khi tàu cách luồng quá 2 km. `S2::GetDistance(x, a, b)` trả `S1Angle` khoảng cách ngắn nhất từ điểm tới đoạn; so với giới hạn đổi từ km.

```cpp
#include "s2/s1angle.h"
#include "s2/s2earth.h"
#include "s2/s2edge_distances.h"
#include "s2/s2latlng.h"

// Tàu cách luồng hải trình (đoạn a→b) quá 2 km thì cảnh báo.
bool ShipOffChannel(const S2Point& ship, const S2Point& a, const S2Point& b) {
  S1Angle miss = S2::GetDistance(ship, a, b);        // điểm → đoạn
  S1Angle limit = S1Angle::Radians(S2Earth::KmToRadians(2.0));
  return miss > limit;
}
```

Evidence:
- `src/s2/s2edge_distances.h:50` — `S1Angle GetDistance(const S2Point& x, const S2Point& a, const S2Point& b);` (comment dùng thực tế `S2::GetDistance(x, a, b) < limit` tại `:48`)
- `src/s2/s2earth.h:52` — `KmToRadians`; `src/s2/s1angle.h:86` — `S1Angle::Radians`
- Mẫu đổi km→S1Angle dùng thật tại `doc/examples/term_index.cc:71-72` — `S1Angle radius = S1Angle::Radians(S2Earth::KmToRadians(...));`

#### UC-3: Chuỗi biên nhiều đỉnh có cắt cạnh a→b không? (S2EdgeCrosser)

Kịch bản: một vùng cấm được khai bằng chuỗi nhiều đỉnh; hệ thống phải thử cắt cạnh a→b với TẤT CẢ cạnh của chuỗi. Gọi `CrossingSign` rời cho từng cặp là lãng phí; `S2EdgeCrosser` giữ sẵn (a,b) và chỉ thêm đỉnh mới mỗi bước — pattern chính là ví dụ hướng dẫn ngay trong header (`S2EdgeCrosser crosser(&a, &b);`).

```cpp
#include <vector>
#include "s2/s2edge_crosser.h"
#include "s2/s2latlng.h"

// Chuỗi biên (nhiều đỉnh) có cắt cạnh a→b không?
bool ChainCrosses(const S2Point& a, const S2Point& b,
                  const std::vector<S2Point>& chain) {
  S2EdgeCrosser crosser(&a, &b);   // a,b phải sống đến hết vòng lặp (con trỏ)
  for (size_t i = 1; i < chain.size(); ++i) {
    if (crosser.CrossingSign(&chain[i - 1], &chain[i]) > 0) {
      return true;
    }
  }
  return false;
}
```

Evidence:
- `src/s2/s2edge_crosser.h:287` — `using S2EdgeCrosser = S2EdgeCrosserBase<S2::internal::S2Point_PointerRep>;` (ArgType = `const S2Point*`); `:82` — doc ctor `S2EdgeCrosser(const S2Point* a, const S2Point* b);`; `:136` — `int CrossingSign(ArgType c, ArgType d);`; `:69` — `class S2EdgeCrosserBase {`; lưu ý về vòng đời con trỏ tại `:79-80`.

### (d) Deps cần kéo theo

- Include: `s2/s2edge_crossings.h`, `s2/s2edge_distances.h`, `s2/s2edge_crosser.h`, cùng `s2/s2point.h`, `s2/s2latlng.h`, `s2/s1angle.h`, `s2/s2earth.h`.
- `S2EdgeCrosser` được explicit-instantiate trong .cc (extern template `:301-302`) — cần link lib `s2`, không chỉ include header.
- Ví dụ chỉ dùng lớp nền (s2-core + s2latlng); deps_out 27 item của s06 là quang phổ consumer, không bắt buộc với các use case này.

### (e) Build

**SKIPPED** — sandbox thiếu toolchain (như trên); không chạy được build, không bịa output.

---

## s14 — s2region

> *Merge provenance: `gm-12-usage-w1.md` @297 (worker u_w1) · `u-status-w1.json`: section_done=true, examples=3, evidence_lines=26 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

Họ covering/index cho mọi `S2Region`: **S2RegionCoverer** sinh tập `S2CellId` (cell union) xấp xỉ một vùng bất kỳ với trần số cell (`max_cells`) — nền cho join không gian cấp cell; **S2RegionTermIndexer** biến vùng thành các index terms cho hệ thống tìm kiếm đảo (inverted index); kèm `S2RegionUnion`/`S2RegionIntersection`/`S2RegionSharder` để ghép nhiều vùng thành một region hoặc chia tải (gm-02 m14). Đây là item duy nhất trong slice có entrypoint thật dạng binary: `doc/examples/term_index.cc`.

### (b) Use cases

#### UC-1: Phủ kho hàng bằng tối đa 8 cell để join không gian

Kịch bản: dữ liệu lô hàng đã index theo cell token; muốn join với "vùng kho" (bbox lat/lng) thì phải quy vùng kho về tập cell ở cùng hệ quy chiếu. `S2RegionCoverer::Options::set_max_cells(8)` chặn trần số cell; `GetCovering` trả `std::vector<S2CellId>`; mỗi cell đổi thành token để làm khóa index.

```cpp
#include <vector>
#include "s2/s2cell_id.h"
#include "s2/s2latlng.h"
#include "s2/s2latlng_rect.h"
#include "s2/s2region_coverer.h"

// Quy vùng kho về tối đa 8 cell để join không gian theo cell.
std::vector<S2CellId> DepotCovering() {
  S2LatLngRect depot = S2LatLngRect::FromCenterSize(
      S2LatLng::FromDegrees(21.03, 105.85),
      S2LatLng::FromDegrees(0.10, 0.15));
  S2RegionCoverer::Options opts;              // Options nằm trong class
  opts.set_max_cells(8);                      // trần số cell của covering
  S2RegionCoverer coverer(opts);
  std::vector<S2CellId> covering;
  coverer.GetCovering(depot, &covering);      // cells xấp xỉ vùng kho
  for (const S2CellId& id : covering) {
    (void)id.ToToken();                       // token = khóa index cell
  }
  return covering;
}
```

Evidence:
- `src/s2/s2region_coverer.h:72` — `class S2RegionCoverer {`; `:74` — `class Options {`; `:108` — `void set_max_cells(int max_cells);`; `:165` — `explicit S2RegionCoverer(const Options& options);`; `:193` — `void GetCovering(const S2Region& region, std::vector<S2CellId>* covering);`
- `src/s2/s2cell_id.h:423` — `std::string ToToken() const;`
- `src/s2/s2latlng_rect.h:92` — `FromCenterSize` (đã evidence ở s15).

#### UC-2: Index POI thành term không gian và truy vấn theo vùng (theo example thật của repo)

Kịch bản: mỗi POI là một "document" gồm một điểm; hệ thống lưu inverted index term→docid và truy vấn bằng một vùng bất kỳ (vd `S2Cap`, `S2LatLngRect`). Đây chính là flow của example binary `doc/examples/term_index.cc` (main tại `:38`): dựng `S2RegionTermIndexer` với `set_index_contains_points_only(true)`, index bằng `GetIndexTerms(point, prefix)`, truy vấn bằng `GetQueryTerms(region, prefix)`.

```cpp
#include <map>
#include <string>
#include <vector>
#include "s2/s2region.h"
#include "s2/s2region_term_indexer.h"

static const char kPrefix[] = "s2:";   // tiền tố phân biệt term không gian

std::vector<int> SpatialSearch(const std::vector<S2Point>& docs,
                               const S2Region& query_region) {
  S2RegionTermIndexer::Options options;
  options.set_index_contains_points_only(true);      // index chỉ chứa điểm
  S2RegionTermIndexer indexer(options);
  std::map<std::string, std::vector<int>> inverted;
  for (int docid = 0; docid < docs.size(); ++docid)  // nạp term từng POI
    for (const auto& term : indexer.GetIndexTerms(docs[docid], kPrefix))
      inverted[term].push_back(docid);
  // Union docid của mọi term do vùng truy vấn sinh ra.
  std::vector<int> hits;
  for (const auto& term : indexer.GetQueryTerms(query_region, kPrefix))
    for (int docid : inverted[term]) hits.push_back(docid);
  return hits;
}
```

Evidence:
- `src/s2/s2region_term_indexer.h:112` — `class S2RegionTermIndexer {`; `:122` — `class Options : public S2RegionCoverer::Options {`; `:203` — `void set_index_contains_points_only(bool value)`; `:273` — `GetIndexTerms(const S2Point& point, ...)`; `:265` — `GetQueryTerms(const S2Region& region, ...)`; `:257` — `GetIndexTerms(const S2Region& region, ...)`; `:275` — `GetQueryTerms(const S2Point& point, ...)`
- Example thật: `doc/examples/term_index.cc:38` — `int main(int argc, char** argv) {`; `:59` — `options.set_index_contains_points_only(true);`; `:65` — `indexer.GetIndexTerms(index_region, kPrefix)`; `:84` — `indexer.GetQueryTerms(query_region, kPrefix)` (file 103 dòng, tồn tại trên cây PIN)

#### UC-3: Gộp nhiều vùng phục vụ thành một S2Region duy nhất

Kịch bản: dịch vụ mở 2 vùng phục vụ rời rạc; thay vì giữ danh sách region riêng lẻ trong toàn pipeline, gộp vào `S2RegionUnion` (mặc định rỗng, `Add` từng vùng qua `std::unique_ptr<S2Region>`) — từ đó mọi consumer (covering, query) chỉ cần nhìn nó như MỘT `S2Region`.

```cpp
#include <memory>
#include "s2/s2latlng.h"
#include "s2/s2latlng_rect.h"
#include "s2/s2region_union.h"

// Gộp 2 vùng phục vụ rời rạc thành 1 S2Region để covering/query chung.
S2RegionUnion MakeServiceArea() {
  S2RegionUnion zone;                     // bắt đầu rỗng, Add dần
  zone.Add(std::make_unique<S2LatLngRect>(S2LatLngRect::FromPointPair(
      S2LatLng::FromDegrees(10.0, 106.6),
      S2LatLng::FromDegrees(10.8, 106.8))));
  zone.Add(std::make_unique<S2LatLngRect>(S2LatLngRect::FromPointPair(
      S2LatLng::FromDegrees(10.5, 106.7),
      S2LatLng::FromDegrees(11.2, 107.0))));
  return zone;                            // dùng như một S2Region hoàn chỉnh
}
```

Evidence:
- `src/s2/s2region_union.h:48` — `class S2RegionUnion final : public S2Region {`; `:51` — `S2RegionUnion() = default;`; `:75` — `void Add(std::unique_ptr<S2Region> region);`
- `src/s2/s2latlng_rect.h:72` — ctor `S2LatLngRect(const S2LatLng& lo, const S2LatLng& hi);`; `:103` — `FromPointPair`
- (Cùng họ, đã grep nhưng không dùng trong ví dụ: `src/s2/s2region_intersection.h:36` — `class S2RegionIntersection final : public S2Region {`; `src/s2/s2region_sharder.h:34` — `class S2RegionSharder {` với ctor `:38`/`:41`.)

### (d) Deps cần kéo theo

- Include: `s2/s2region_coverer.h`, `s2/s2region_term_indexer.h`, `s2/s2region_union.h`, cùng `s2/s2cell_id.h` (ToToken), `s2/s2latlng_rect.h`, `s2/s2region.h`, `s2/s2latlng.h`.
- Example thật còn dùng `absl` (flags, btree_set/flat_hash_map), `s2/s2random.h`, `s2/s2cap.h`, `s2/s2earth.h` (`doc/examples/term_index.cc:21-31`).
- `deps_out` của s14 trong `u-checklist.json`: s2cell, s2closest, s2density, s2polygon, s2shape — ví dụ trên chỉ chạm s2cell (S2CellId) và s2latlng (S2LatLngRect).

### (e) Build

**SKIPPED** — sandbox thiếu toolchain (cmake/g++/make đều không có; node cấm cài dependency). Example binary `term_index.cc` không build được trong sandbox này; nội dung example trích nguyên văn bằng `sed` từ clone PIN (không bịa).

---

## s16 — s2loop · `src/s2/s2loop_measures.h` (366 dòng)

> *Merge provenance: `gm-12-usage-w2.md` @11 (worker u_w2) · `u-status-w2.json`: section_done=true, examples=3, evidence_lines=24 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

Họ `s2loop` (theo luật tiền tố census) là bộ hàm đo đạc hình học cho loop — đường viền khép kín trên mặt cầu: `GetPerimeter`/`GetArea`/`GetApproxArea` (s2loop_measures.h:44/50/59) tính chu vi và diện tích trong khoảng 0..4π steradians, xử lý cả loop degenerate và clockwise (fact từ gm-02 m16). Kèm `GetSignedArea` (:78) để tính diện tích ròng cho polygon nhiều loop và `GetCurvatureMaxError` (:103) cho bound sai số. Struct `LoopOrder` (:129) và class `KahanSum` (:181, trong `namespace internal` :143–205) là phụ trợ được class `S2Loop` (thuộc s2-core, `s2/s2loop.h`) gọi.

### (b) Use cases

#### UC1 — Đo chu vi + diện tích một thửa đất

Kịch bản: hệ thống địa chính cần diện tích (m²) và chu vi một thửa 4 đỉnh. Các hàm measure nhận `S2PointLoopSpan` (s2point_span.h:45) nên truyền thẳng `std::vector<S2Point>` được — y như test chuẩn của repo gọi `S2::GetPerimeter(vector<S2Point>{})` (s2loop_measures_test.cc:235).

```cpp
#include <cstdio>
#include <vector>
#include "s2/s1angle.h"
#include "s2/s2earth.h"
#include "s2/s2latlng.h"
#include "s2/s2loop_measures.h"

// Ranh gioi thua dat 4 dinh. Measure nhan S2PointLoopSpan (s2point_span.h:45);
// truyen vector<S2Point> truc tiep nhu test chuan (s2loop_measures_test.cc:235).
std::vector<S2Point> ring = {
    S2LatLng::FromDegrees(10.030, 105.770).ToPoint(),
    S2LatLng::FromDegrees(10.030, 105.785).ToPoint(),
    S2LatLng::FromDegrees(10.018, 105.785).ToPoint(),
    S2LatLng::FromDegrees(10.018, 105.770).ToPoint(),
};

S1Angle perimeter = S2::GetPerimeter(ring);          // s2loop_measures.h:44
double area_sr    = S2::GetArea(ring);               // :50 — [0, 4*Pi] sr (:47)
double approx_sr  = S2::GetApproxArea(ring);         // :59 — nhanh hon, sai so toi da
                                                     // 2.22e-15 sr moi dinh (:53)
double err_sr     = S2::GetCurvatureMaxError(ring);  // :103 — tran sai so cua :59

std::printf("perimeter = %.6f deg\n", perimeter.degrees());  // s1angle.h:124
std::printf("area = %.1f m2 | approx = %.1f m2 | err_bound = %.3e m2\n",
            S2Earth::SteradiansToSquareMeters(area_sr),       // s2earth.h:76
            S2Earth::SteradiansToSquareMeters(approx_sr),
            S2Earth::SteradiansToSquareMeters(err_sr));
```

Evidence (grep trên cây PIN):
- `src/s2/s2loop_measures.h:44` — `S1Angle GetPerimeter(S2PointLoopSpan loop);`
- `src/s2/s2loop_measures.h:47` — comment "The result is between 0 and 4*Pi steradians."
- `src/s2/s2loop_measures.h:50` — `double GetArea(S2PointLoopSpan loop);`
- `src/s2/s2loop_measures.h:53` — "The maximum error is 2.22e-15" (của GetApproxArea)
- `src/s2/s2loop_measures.h:59` — `double GetApproxArea(S2PointLoopSpan loop);`
- `src/s2/s2loop_measures.h:103` — `double GetCurvatureMaxError(S2PointLoopSpan loop);`
- `src/s2/s2point_span.h:45` — `class S2PointLoopSpan : public S2PointSpan`
- `src/s2/s2loop_measures_test.cc:235` — `EXPECT_EQ(S1Angle::Zero(), S2::GetPerimeter(vector<S2Point>{}));`
- `src/s2/s2latlng.h:72` — `static constexpr S2LatLng FromDegrees(double lat_degrees, double lng_degrees);`
- `src/s2/s2latlng.h:126` — `S2Point ToPoint() const;`
- `src/s2/s1angle.h:124` — `constexpr double degrees() const;`
- `src/s2/s2earth.h:76` — `static constexpr double SteradiansToSquareMeters(double steradians);`

#### UC2 — Diện tích ròng của thửa có hồ (polygon nhiều loop)

Kịch bản: thửa đất có một hồ bên trong (hole). `GetSignedArea` trả giá trị âm/dương theo chiều loop — "Counter-clockwise loops are guaranteed to have positive area, and clockwise loops are guaranteed to have negative area" (:69) — và được sinh ra cho đúng mục đích "accurately compute the area of polygons consisting of multiple loops" (:63-64); cộng các signed area lại được diện tích ròng.

```cpp
#include <cstdio>
#include <vector>
#include "s2/s2earth.h"
#include "s2/s2latlng.h"
#include "s2/s2loop_measures.h"

// Thua dat co ao: loop ngoai CCW (signed duong), loop trong CW (signed am) theo :69.
std::vector<S2Point> outer = {
    S2LatLng::FromDegrees(10.00, 105.75).ToPoint(),
    S2LatLng::FromDegrees(10.00, 105.80).ToPoint(),
    S2LatLng::FromDegrees(10.05, 105.80).ToPoint(),
    S2LatLng::FromDegrees(10.05, 105.75).ToPoint(),
};
std::vector<S2Point> hole = {
    S2LatLng::FromDegrees(10.02, 105.77).ToPoint(),
    S2LatLng::FromDegrees(10.01, 105.77).ToPoint(),
    S2LatLng::FromDegrees(10.01, 105.78).ToPoint(),
    S2LatLng::FromDegrees(10.02, 105.78).ToPoint(),
};

double net_sr = S2::GetSignedArea(outer) + S2::GetSignedArea(hole);  // :78, [-2Pi, 2Pi] sr (:63)
std::printf("net = %.1f m2 | hole = %.1f m2\n",
            S2Earth::SteradiansToSquareMeters(net_sr),
            S2Earth::SteradiansToSquareMeters(-S2::GetSignedArea(hole)));
```

Evidence (grep trên cây PIN):
- `src/s2/s2loop_measures.h:63-64` — "whichever is smaller in magnitude. The result is between -2*Pi and 2*Pi steradians. This method is used to accurately compute the area of polygons"
- `src/s2/s2loop_measures.h:69` — "Counter-clockwise loops are guaranteed to have positive area"
- `src/s2/s2loop_measures.h:78` — `double GetSignedArea(S2PointLoopSpan loop);`
- `src/s2/s2latlng.h:126` — `S2Point ToPoint() const;`
- `src/s2/s2earth.h:76` — `SteradiansToSquareMeters`

#### UC3 — Đo loop đã đóng gói thành class S2Loop (s2-core)

Kịch bản: dữ liệu đã được lưu thành class `S2Loop` (thuộc s2-core). Đo chu vi qua `vertices_span()` — trả đúng kiểu `S2PointLoopSpan` mà measure nhận — không phải copy lại mảng đỉnh.

```cpp
#include <cstdio>
#include <vector>
#include "s2/s1angle.h"
#include "s2/s2loop.h"             // class S2Loop thuoc s2-core
#include "s2/s2loop_measures.h"

std::vector<S2Point> ring = {
    S2LatLng::FromDegrees(10.030, 105.770).ToPoint(),
    S2LatLng::FromDegrees(10.030, 105.785).ToPoint(),
    S2LatLng::FromDegrees(10.018, 105.785).ToPoint(),
    S2LatLng::FromDegrees(10.018, 105.770).ToPoint(),
};

// Convenience constructor goi Init() voi dinh da cho (s2/s2loop.h:109).
S2Loop loop(absl::Span<const S2Point>(ring));

if (loop.IsValid()) {                                // s2/s2loop.h:179
  S1Angle p = S2::GetPerimeter(loop.vertices_span()); // vertices_span :218 -> measure :44
  std::printf("perimeter = %.6f deg, vertices = %d\n",
              p.degrees(), loop.num_vertices());      // s2/s2loop.h:187
}
```

Evidence (grep trên cây PIN):
- `src/s2/s2loop.h:109` — `explicit S2Loop(absl::Span<const S2Point> vertices);` (comment ngay trên: "Convenience constructor that calls Init() with the given vertices.")
- `src/s2/s2loop.h:179` — `bool IsValid() const;`
- `src/s2/s2loop.h:187` — `int num_vertices() const { return num_vertices_; }`
- `src/s2/s2loop.h:218` — `S2PointLoopSpan vertices_span() const {`
- `src/s2/s2loop_measures.h:44` — `GetPerimeter`
- `src/s2/s2latlng.h:126` — `ToPoint`
- `src/s2/s1angle.h:124` — `degrees()`

### (d) Deps cần kéo theo

- Theo `u-checklist.json` (deps_out gm-02 m16): `s2-core`, `s2shape` (+ tests gmock/s2text phía test).
- Ví dụ trên include: `s2/s1angle.h`, `s2/s2earth.h`, `s2/s2latlng.h`, `s2/s2loop.h` (s2-core), `s2/s2loop_measures.h` (tự kéo thêm `s2/s2point_span.h`, `s2/s2edge_crossings.h` — thấy ở header :32-40); `absl` (Span).

### (e) Build riêng item

- Build entry greppable: `CMakeLists.txt:1` — `cmake_minimum_required(VERSION 3.18)`; `CMakeLists.txt:13` — `project(s2-geometry ...)` → lệnh chuẩn `cmake -S . -B build && cmake --build build -j2`.
- **SKIPPED — không chạy build thật**: sandbox `bitnami/git:latest` không có toolchain (`which cmake g++ make gcc` → không tìm thấy file nào, exit=4). Không bịa output build.

---

## s20 — s2lax · `src/s2/s2lax_polygon_shape.h` / `s2lax_polyline_shape.h` / `s2lax_loop_shape.h`

> *Merge provenance: `gm-12-usage-w2.md` @154 (worker u_w2) · `u-status-w2.json`: section_done=true, examples=2, evidence_lines=14 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

`s2lax` là họ lax shape — biểu diễn hình học lỏng không đòi hỏi strict validity như S2Polygon/S2Loop (fact từ gm-02 m20): `S2LaxPolygonShape` (s2lax_polygon_shape.h:86, bản encoded :196), `S2LaxPolylineShape` (s2lax_polyline_shape.h:43, bản encoded :110), `S2LaxLoopShape`/`S2LaxClosedPolylineShape`/`S2VertexIdLaxLoopShape` (s2lax_loop_shape.h:54/105/119). Là output tự nhiên của S2Builder layers và đầu vào của boolean/winding operation.

### (b) Use cases

#### UC1 — Polygon lỏng (có hole) từ dữ liệu thô, đếm cấu trúc

Kịch bản: dữ liệu GPS thô gồm loop ngoài + loop trong, chưa qua bước strict-validity. `S2LaxPolygonShape` nhận trực tiếp tập vector đỉnh (`Loop = std::vector<S2Point>` :100, ctor từ `Span<const Loop>` :101) và cho biết cấu trúc: số loop, số đỉnh, số chain.

```cpp
#include <cstdio>
#include <vector>
#include "s2/s2lax_polygon_shape.h"
#include "s2/s2latlng.h"

// Du lieu tho: loop ngoai + loop trong (hole), chua qua strict-validity.
std::vector<std::vector<S2Point>> loops = {
    {S2LatLng::FromDegrees(10.00, 105.75).ToPoint(),
     S2LatLng::FromDegrees(10.00, 105.80).ToPoint(),
     S2LatLng::FromDegrees(10.05, 105.80).ToPoint(),
     S2LatLng::FromDegrees(10.05, 105.75).ToPoint()},
    {S2LatLng::FromDegrees(10.02, 105.77).ToPoint(),
     S2LatLng::FromDegrees(10.01, 105.77).ToPoint(),
     S2LatLng::FromDegrees(10.01, 105.78).ToPoint(),
     S2LatLng::FromDegrees(10.02, 105.78).ToPoint()},
};

// Loop = std::vector<S2Point> (s2lax_polygon_shape.h:100);
// ctor tu Span<const Loop> (:101).
S2LaxPolygonShape lax(absl::Span<const std::vector<S2Point>>(loops));
std::printf("loops=%d vertices=%d chains=%d\n",
            lax.num_loops(),      // s2lax_polygon_shape.h:123
            lax.num_vertices(),   // :126
            lax.num_chains());    // :160 — tra ve num_loops()
```

Evidence (grep trên cây PIN):
- `src/s2/s2lax_polygon_shape.h:86` — `class S2LaxPolygonShape : public S2Shape {`
- `src/s2/s2lax_polygon_shape.h:100` — `using Loop = std::vector<S2Point>;`
- `src/s2/s2lax_polygon_shape.h:101` — `explicit S2LaxPolygonShape(absl::Span<const Loop> loops);`
- `src/s2/s2lax_polygon_shape.h:123` — `int num_loops() const { return num_loops_; }`
- `src/s2/s2lax_polygon_shape.h:126` — `int num_vertices() const { return num_vertices_; }`
- `src/s2/s2lax_polygon_shape.h:160` — `int num_chains() const final { return num_loops(); }`
- `src/s2/s2latlng.h:72/:126` — `FromDegrees` / `ToPoint`

#### UC2 — Tuyến đường dạng lax polyline, duyệt đỉnh và in lại

Kịch bản: lưu tuyến đường 3 điểm làm lax polyline (không cần khép kín), duyệt từng đỉnh và in ra định dạng `lat:lng` bằng `ToString` của s2text (item s26 — dep kế cận).

```cpp
#include <cstdio>
#include <vector>
#include "s2/s2lax_polyline_shape.h"
#include "s2/s2latlng.h"
#include "s2/s2text_format.h"

std::vector<S2Point> road = {
    S2LatLng::FromDegrees(10.030, 105.760).ToPoint(),
    S2LatLng::FromDegrees(10.020, 105.780).ToPoint(),
    S2LatLng::FromDegrees(10.010, 105.790).ToPoint(),
};

// Ctor tu Span<const S2Point> (s2lax_polyline_shape.h:56).
S2LaxPolylineShape line(absl::Span<const S2Point>(road));

for (int i = 0; i < line.num_vertices(); ++i) {                  // :69
  std::printf("v%d = %s\n", i,
              s2textformat::ToString(line.vertex(i)).c_str());   // vertex(i) :70; ToString(point) :403
}
std::printf("whole: %s\n", s2textformat::ToString(line).c_str()); // ToString(lax polyline) :414
```

Evidence (grep trên cây PIN):
- `src/s2/s2lax_polyline_shape.h:43` — `class S2LaxPolylineShape : public S2Shape {`
- `src/s2/s2lax_polyline_shape.h:56` — `explicit S2LaxPolylineShape(absl::Span<const S2Point> vertices);`
- `src/s2/s2lax_polyline_shape.h:69` — `int num_vertices() const { return num_vertices_; }`
- `src/s2/s2lax_polyline_shape.h:70` — `const S2Point& vertex(int i) const { return vertices_[i]; }`
- `src/s2/s2text_format.h:403` — `std::string ToString(const S2Point& point);`
- `src/s2/s2text_format.h:414` — `std::string ToString(const S2LaxPolylineShape& polyline);`
- `src/s2/s2latlng.h:72/:126` — `FromDegrees` / `ToPoint`

### (d) Deps cần kéo theo

- Theo `u-checklist.json` (deps_out gm-02 m20, 17 item): `s2-core`, `s2shape`, `s2text`, `encoded`, `mutable`, `s2builder`, `s2chain`, `s2winding`, …
- Hai ví dụ trên include: `s2/s2lax_polygon_shape.h`, `s2/s2lax_polyline_shape.h` (kéo `s2coding`/`Encoder` cho bản encoded), `s2/s2latlng.h` (s2-core), `s2/s2text_format.h` (s26), `absl` (Span).
- Các biến thể còn lại của họ (dùng khi làm layer/index riêng): `S2LaxLoopShape` :54, `S2LaxClosedPolylineShape` :105, `S2VertexIdLaxLoopShape` :119 (`src/s2/s2lax_loop_shape.h`), `EncodedS2LaxPolygonShape` :196, `EncodedS2LaxPolylineShape` :110.

### (e) Build riêng item

- Build entry: `CMakeLists.txt:1/:13` như mục s16 (cùng repo build tree).
- **SKIPPED — không chạy build thật**: sandbox không có cmake/g++/make/gcc (`which` → exit=4). Không bịa output.

---

## s21 — s2point · `src/s2/s2point_index.h` / `s2point_region.h` / `s2point_vector_shape.h` / `s2point_compression.h`

> *Merge provenance: `gm-12-usage-w2.md` @251 (worker u_w2) · `u-status-w2.json`: section_done=true, examples=3, evidence_lines=21 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

`s2point` là họ index/region/vector cho điểm rời rạc (fact từ gm-02 m21): `S2PointIndex<Data>` (s2point_index.h:107 — btree-multimap điểm→data), `S2PointRegion final : public S2Region` (s2point_region.h:42), `S2PointVectorShape : public S2Shape` (s2point_vector_shape.h:38), struct nén điểm `S2XYZFaceSiTi` (s2point_compression.h:58). Đây là item duy nhất (cùng s14) có **entrypoint binary thật trong repo**: `doc/examples/point_index.cc:25` dựng index + query điểm gần nhất.

### (b) Use cases

#### UC1 — Tra "những POI trong bán kính 2 km" bằng S2PointIndex + S2ClosestPointQuery

Kịch bản: index vài nghìn địa điểm (điểm → id) rồi trả lời truy vấn bán kính. Mẫu dùng đúng theo example binary của repo `doc/examples/point_index.cc` (dòng 25–46): `index.Add(point, data)` → `S2ClosestPointQuery` với `set_max_distance` → `FindClosestPoints`.

```cpp
#include <cstdio>
#include "s2/s1angle.h"
#include "s2/s2closest_point_query.h"
#include "s2/s2earth.h"
#include "s2/s2latlng.h"
#include "s2/s2point_index.h"

// Index POI (diem -> id), truy van ban kinh — mau giong
// doc/examples/point_index.cc:25-46 (entrypoint that cua repo).
S2PointIndex<int> index;                                    // s2point_index.h:107
const double poi[][2] = {{10.030, 105.770}, {10.031, 105.771}, {10.100, 105.900}};
for (int i = 0; i < 3; ++i) {
  index.Add(S2LatLng::FromDegrees(poi[i][0], poi[i][1]).ToPoint(), i);  // Add :142
}

S2ClosestPointQuery<int> query(&index);                     // s2closest_point_query.h
query.mutable_options()->set_max_distance(S1Angle::Radians(
    S2Earth::KmToRadians(2.0)));                            // s2earth.h:52

S2ClosestPointQuery<int>::PointTarget target(               // mau tai point_index.cc:41
    S2LatLng::FromDegrees(10.0305, 105.7705).ToPoint());
std::printf("%zu POI trong 2km\n",
            query.FindClosestPoints(&target).size());       // s2closest_point_query.h:267
```

Evidence (grep trên cây PIN):
- `src/s2/s2point_index.h:107` — `class S2PointIndex {`
- `src/s2/s2point_index.h:142` — `void Add(const S2Point& point, const Data& data);`
- `doc/examples/point_index.cc:25-46` — `int main(...)` dựng `S2PointIndex<int> index; index.Add(s2random::Point(bitgen), i); S2ClosestPointQuery<int> query(&index); query.mutable_options()->set_max_distance(...); ... query.FindClosestPoints(&target).size()`
- `doc/examples/point_index.cc:41` — `S2ClosestPointQuery<int>::PointTarget target(s2random::Point(bitgen));`
- `src/s2/s2closest_point_query.h:267` — `std::vector<Result> FindClosestPoints(Target* target);`
- `src/s2/s2earth.h:52` — `static constexpr double KmToRadians(double km);`
- `src/s2/s2latlng.h:72/:126` — `FromDegrees` / `ToPoint`

#### UC2 — Duyệt toàn bộ nội dung index (dump cho báo cáo/debug)

Kịch bản: cần liệt kê mọi entry trong index kèm data gắn với điểm. `S2PointIndex` có Iterator riêng; comment trong header (:95-99) chính là mẫu duyệt chuẩn của repo.

```cpp
#include <cstdio>
#include "s2/s2latlng.h"
#include "s2/s2point_index.h"

S2PointIndex<int> index;
index.Add(S2LatLng::FromDegrees(10.030, 105.770).ToPoint(), 101);
index.Add(S2LatLng::FromDegrees(10.100, 105.900).ToPoint(), 102);

// Iterator di theo thu tu S2CellId; mau duyet tai comment s2point_index.h:95-99.
S2PointIndex<int>::Iterator it(&index);                 // ctor tu index :174
for (; !it.done(); it.Next()) {
  const S2Point& p = it.point();                        // Iterator::point() :189
  int id = it.data();                                   // Iterator::data()  :193
  std::printf("poi %d at (%.4f, %.4f)\n", id,
              S2LatLng(p).lat().degrees(),              // s2latlng.h:95 + s1angle.h:124
              S2LatLng(p).lng().degrees());             // s2latlng.h:96
}
std::printf("total = %d\n", index.num_points());        // s2point_index.h:141
```

Evidence (grep trên cây PIN):
- `src/s2/s2point_index.h:95-99` — comment mẫu: `S2PointIndex<int>::Iterator it(&index); it.Seek(...); for (; !it.done() && it.id() <= target_id.range_max(); it.Next()) { DoSomething(it.id(), it.point(), it.data()); }`
- `src/s2/s2point_index.h:141` — `int num_points() const { return static_cast<int>(points_.size()); }`
- `src/s2/s2point_index.h:174` — `explicit Iterator(const S2PointIndex* index);`
- `src/s2/s2point_index.h:189` — `const S2Point& point() const;`
- `src/s2/s2point_index.h:193` — `const Data& data() const;`
- `src/s2/s2latlng.h:95` — `constexpr S1Angle lat() const` ; `:96` — `constexpr S1Angle lng() const`
- `src/s2/s1angle.h:124` — `degrees()`

#### UC3 — S2PointRegion (region 1 điểm) + S2PointVectorShape (points thành shape)

Kịch bản: (1) kiểm tra một toạ độ có trùng chính xác điểm đã đăng ký không — `S2PointRegion::Contains` so sánh bằng toán tử `==` (s2point_region.h:64); (2) bọc tập điểm thành `S2Shape` để nạp vào shape index hoặc layer của S2Builder.

```cpp
#include <cstdio>
#include <vector>
#include "s2/s2latlng.h"
#include "s2/s2point_region.h"
#include "s2/s2point_vector_shape.h"

S2Point key = S2LatLng::FromDegrees(10.030, 105.770).ToPoint();

// Region "mot diem": Contains so sanh bang == (s2point_region.h:64).
S2PointRegion region(key);                              // ctor :45
bool exact = region.Contains(S2LatLng::FromDegrees(10.030, 105.770).ToPoint());

// Boc tap hop diem thanh S2Shape (kTypeTag = 3, s2point_vector_shape.h:40).
std::vector<S2Point> pts = {key,
                            S2LatLng::FromDegrees(10.031, 105.771).ToPoint()};
S2PointVectorShape shape(pts);                          // ctor :49

std::printf("exact=%d points=%d\n", exact, shape.num_points());  // :55
```

Evidence (grep trên cây PIN):
- `src/s2/s2point_region.h:42` — `class S2PointRegion final : public S2Region {`
- `src/s2/s2point_region.h:45` — `explicit S2PointRegion(const S2Point& point);`
- `src/s2/s2point_region.h:64` — `bool Contains(const S2Point& p) const override { return (point_ == p); }`
- `src/s2/s2point_vector_shape.h:38` — `class S2PointVectorShape : public S2Shape {`
- `src/s2/s2point_vector_shape.h:49` — `explicit S2PointVectorShape(std::vector<S2Point> points) {`
- `src/s2/s2point_vector_shape.h:55` — `int num_points() const { return static_cast<int>(points_.size()); }`
- `src/s2/s2latlng.h:72/:126` — `FromDegrees` / `ToPoint`

### (d) Deps cần kéo theo

- Theo `u-checklist.json` (deps_out gm-02 m21, 22 item): `s2-core`, `s2cell`, `s2closest`, `s2edge`, `s2shape`, `s2shapeutil`, `s2text`, `encoded`, `mutable`, …
- Ví dụ trên include: `s2/s2point_index.h` (tự kéo `s2/s2cell_iterator.h` cho Iterator), `s2/s2closest_point_query.h`, `s2/s2earth.h`, `s2/s2latlng.h`, `s2/s2point_region.h`, `s2/s2point_vector_shape.h`, `absl`.
- Phần nén không đưa vào code (tránh mở rộng API surface): `S2XYZFaceSiTi` — `src/s2/s2point_compression.h:58`.

### (e) Build riêng item

- Build entry: `CMakeLists.txt:1/:13` như mục s16. Example binary `point_index.cc` thuộc target examples của repo (file nằm tại `doc/examples/point_index.cc`, greppable trên cây PIN).
- **SKIPPED — không chạy build thật**: sandbox không có toolchain (cmake/g++/make/gcc đều vắng, exit=4). Không bịa output.

---

## s26 — s2text · `src/s2/s2text_format.h`

> *Merge provenance: `gm-12-usage-w2.md` @379 (worker u_w2) · `u-status-w2.json`: section_done=true, examples=2, evidence_lines=9 · PIN `677c8ceb`. Nội dung dưới đây NGUYÊN VĂN từ worker.*

### (a) Item này giải quyết vấn đề gì

`s2text_format` là bộ chuyển đổi geometry ↔ chuỗi human-readable phục vụ test/debug — API fixture chuẩn của toàn test suite (deps_out nhiều nhất trong 8 item: 32 — fact từ gm-02 m26): các hàm `Make*` (`MakePoint` s2text_format.h:66, `MakeLatLng` :128, `MakeLoop` :213, `MakePolyline` :235, `MakeLaxPolyline` :257, `MakePolygon` :290) parse chuỗi `lat:lng`, và `ToString()` cho 10 kiểu (:403-415). Namespace `s2textformat` (:61). Cảnh báo ngay đầu file (:21-25): format **không** giữ full precision — không dùng để lưu dữ liệu.

### (b) Use cases

#### UC1 — Fixture: parse chuỗi → dựng geometry → in lại để so sánh (round-trip trong test)

Kịch bản: viết unit test cho tính năng hình học, cần dựng dữ liệu nhanh từ chuỗi ngắn và in kết quả ra log để diff trực quan. Đây chính là cách các test của repo dựng fixture.

```cpp
#include <cstdio>
#include <memory>
#include "s2/s2lax_polyline_shape.h"
#include "s2/s2polygon.h"
#include "s2/s2text_format.h"

// Fixture chuan: tao geometry tu chuoi "lat:lng, lat:lng" dinh dang "lat:lng".
auto road = s2textformat::MakeLaxPolylineOrDie(            // s2text_format.h:261
    "10.03:105.76, 10.02:105.78, 10.01:105.79");
auto lot = s2textformat::MakePolygonOrDie(                 // :293-296 (debug_override mac dinh S2Debug::ALLOW)
    "10.00:105.75, 10.00:105.80, 10.05:105.80, 10.05:105.75");

std::printf("road = %s\n",
            s2textformat::ToString(*road).c_str());        // ToString(lax polyline) :414
std::printf("lot  = %s\n",
            s2textformat::ToString(*lot).c_str());         // ToString(polygon) :410
std::printf("pt   = %s\n",
            s2textformat::ToString(
                s2textformat::MakePointOrDie("10.03:105.77")).c_str()); // :69 + :403
```

Evidence (grep trên cây PIN):
- `src/s2/s2text_format.h:61` — `namespace s2textformat {`
- `src/s2/s2text_format.h:66` — `absl::StatusOr<S2Point> MakePoint(absl::string_view str);`
- `src/s2/s2text_format.h:69` — `inline S2Point MakePointOrDie(absl::string_view str) {`
- `src/s2/s2text_format.h:261` — `inline std::unique_ptr<S2LaxPolylineShape> MakeLaxPolylineOrDie(`
- `src/s2/s2text_format.h:293-296` — `inline std::unique_ptr<S2Polygon> MakePolygonOrDie(absl::string_view str, S2Debug debug_override = S2Debug::ALLOW)`
- `src/s2/s2text_format.h:403` — `ToString(const S2Point&)` ; `:410` — `ToString(const S2Polygon&, ...)` ; `:414` — `ToString(const S2LaxPolylineShape&)`

#### UC2 — Parse đầu vào không tin cậy (không dùng OrDie)

Kịch bản: nhận toạ độ do người dùng gõ vào; chuỗi sai định dạng phải bị từ chối thay vì làm chương trình chết. Dùng overload bool (`MakePoint(str, &point)` :75) — trả `false` khi parse lỗi (:78: `ASSIGN_OR_RETURN(*point, MakePoint(str), false); return true;`).

```cpp
#include <cstdio>
#include "s2/s2point.h"
#include "s2/s2text_format.h"

// Dau vao nguoi dung co the sai: dung overload bool (:75) thay vi OrDie.
S2Point p;
if (!s2textformat::MakePoint("10,5:abc", &p)) {   // dinh dang sai -> false
  std::printf("rejected\n");
}
bool ok = s2textformat::MakePoint("-20:150", &p); // dung dinh dang "lat:lng" (:62-66)
if (ok) {
  std::printf("ok: %s\n", s2textformat::ToString(p).c_str());  // :403
}
```

Evidence (grep trên cây PIN):
- `src/s2/s2text_format.h:62-66` — comment "Returns an S2Point corresponding to the given a latitude-longitude coordinate in degrees. Example of the input format: `-20:150`" + khai báo `MakePoint`
- `src/s2/s2text_format.h:75-79` — `[[nodiscard]] inline bool MakePoint(absl::string_view str, S2Point* point)` với thân `absl::StatusOr<S2Point> point_or = MakePoint(str);` (mẫu `..., false` tại :78)
- `src/s2/s2text_format.h:403` — `ToString(const S2Point&)`

### (d) Deps cần kéo theo

- Theo `u-checklist.json` (deps_out gm-02 m26, 32 item — fixture của toàn test suite): nhưng 2 ví dụ trên chỉ kéo `s2-core` (S2Point, S2Polygon, S2LaxPolylineShape), `s2/s2text_format.h`, `absl` (StatusOr/string_view).
- Cảnh báo sử dụng (evidence `src/s2/s2text_format.h:21-25`): "the human-readable format is *not* designed to preserve the full precision of the original object, so it should not be used for data storage" — không dùng ToString để lưu trữ dữ liệu.

### (e) Build riêng item

- Build entry: `CMakeLists.txt:1/:13` như mục s16 (s2text_format.h là header-only dùng chung thư viện, greppable trong build tree tại `src/s2/BUILD.bazel` / CMake globs).
- **SKIPPED — không chạy build thật**: sandbox không có toolchain (exit=4). Không bịa output.

---

## Trạng thái merge (máy-đọc)

| nguồn | items | status | use case | evidence_lines | section anchor (worker file) |
|---|---|---|---|---|---|
| `gm-12-usage-w1.md` + `u-status-w1.json` | s15, s22, s06, s14 | 4/4 section_done=true | 12 | 69 | s15@10 · s22@113 · s06@207 · s14@297 |
| `gm-12-usage-w2.md` + `u-status-w2.json` | s16, s20, s21, s26 | 4/4 section_done=true | 10 | 68 | s16@11 · s20@154 · s21@251 · s26@379 |
| **Tổng** | **8/8** | **8/8 DONE** | **22** | **137** | — |

Ghi chú discipline node merge:
- Nội dung từng item (a)/(b)/(d)/(e) sao chép NGUYÊN VĂN từ worker — merge không thêm/sửa/xóa ví dụ hay evidence nào; dòng provenance blockquote đầu mỗi section là metadata do node merge thêm, không thuộc nội dung worker.
- Thay đổi duy nhất so với worker: bỏ phần header/đối soát của từng worker (chuyển thành header file này + bảng trạng thái trên); giữ nguyên toàn bộ section item.
- Build vẫn SKIPPED (trung thực kế thừa — không bịa output).
- Không commit git (tiền lệ chuỗi gm/pprof — deliverable là file workspace; `u-usage-plan.md` §5, `gm-12-usage-w2.md` ghi chú cuối).

## Tự kiểm merge

- Section `## s…`: 8/8 theo đúng thứ tự checklist (s15, s22, s06, s14, s16, s20, s21, s26) — grep `^## s` = 8.
- Bảng tổng hợp: 8 dòng item (grep `^\| s` = 8), cột `dùng khi nào` suy từ section (a) của worker, cột `deps_out` verbatim `u-checklist.json`.
- JSON block: 8 object/8 dòng, parse được; `deps_out` đối chiếu phần tử-từng-phần-tử với `u-checklist.json` — 8/8 identical (Σ|deps_out| = 17+4+27+5+2+17+22+32 = 126).
- Use case: 22 (w1 12 + w2 10) khớp field `examples` của 2 status file (3+3+3+3 / 3+2+3+2).
- PIN nhất quán w1/w2 = `677c8cebcff11ba11accc0b02005bc214e06e9fd` — mọi evidence trong file gắn cây PIN này.
- REDACTION: file không chứa token/secret.
