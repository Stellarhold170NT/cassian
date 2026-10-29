# cassian

Cái tên lấy từ Consigliere — người cố vấn của gia đình: không ra trận,
không khoe, nhưng luôn nắm rõ mọi chuyện và trả lời đúng lúc.

Repo này là cố vấn của bạn cho apache/kafka. Nó đã đọc toàn bộ source ở
trunk, chốt một commit, chấm giá 66 module bằng rubric đo được, vẽ bản đồ
phụ thuộc, và nhặt nguyên vẹn phần code đáng lấy vào modules/. Bạn hỏi,
nó trả lời bằng số liệu đã đo — không bằng cảm tính.

Bên trong:
- matrix/matrix.csv — 66 module, sao, đường dẫn. Mở đầu từ đây.
- modules/kafka/<module>/ — code gốc từng module kèm PROVENANCE.md
  (upstream sha, license, files/LOC đo lại). Diff với upstream là rỗng.
- docs/kafka/ — 01 cartography, 02 module-map, 03 C4, 04 overview,
  05 stars, 06 flows, 07 usage (use case cho module 4-5 sao, mọi API
  đều có file:line làm chứng), final.
- specs/kafka/ — kế hoạch cắt từng module.
- tracking/kafka.md — so commit chốt với HEAD upstream, biết khi nào
  nên cắt lại.

Cách dùng: chọn module trong matrix theo số sao, đọc dòng "dùng khi nào"
trong 07 usage, kéo code từ modules/ kèm các phụ thuộc nó cần
(deps_out ghi sẵn trong module map). Muốn hiểu sâu, docs đã có đủ.

License: code giữ nguyên Apache-2.0 của apache/kafka (xem PROVENANCE.md
từng module). Tài liệu do cassian biên soạn, phát hành Apache-2.0.
