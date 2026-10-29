# cassian

Cai ten lay tu Consigliere — nguoi co van cua gia dinh: khong ra tran,
khong khoe, nhung luon nam ro moi chuyen va tra loi dung luc.

Repo nay la co van cua ban cho apache/kafka. No da doc toan bo source o
trunk, chot mot commit, cham gia 66 module bang rubric do duoc, ve ban do
phu thuoc, va nhat nguyen ven phan code dang lay vao modules/. Ban hoi,
no tra loi bang so lieu da do — khong bang cam tinh.

Ben trong:
- matrix/matrix.csv — 66 module, sao, duong dan. Mo dau tu day.
- modules/kafka/<module>/ — code goc tung module kem PROVENANCE.md
  (upstream sha, license, files/LOC do lai). Diff voi upstream la rong.
- docs/kafka/ — 01 cartography, 02 module-map, 03 C4, 04 overview,
  05 stars, 06 flows, 07 usage (use case cho module 4-5 sao, moi API
  deu co file:line lam chung), final.
- specs/kafka/ — ke hoach cat tung module.
- tracking/kafka.md — so commit chot voi HEAD upstream, biet khi nao
  nen cat lai.

Cach dung: chon module trong matrix theo so sao, doc dong "dung khi nao"
trong 07 usage, keo code tu modules/ kem cac phu thuoc no can
(deps_out ghi san trong module map). Muon hieu sau, docs da co du.

License: code giu nguyen Apache-2.0 cua apache/kafka (xem PROVENANCE.md
tung module). Tai lieu do cassian bien soan, phat hanh Apache-2.0.
