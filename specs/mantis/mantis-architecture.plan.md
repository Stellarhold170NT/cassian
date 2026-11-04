---
subject: google/mantis
measured_at: 1e15346c2ca2d6e7db57ced59615bb9d1685992f
status: plan
---

# GM-09a — EXTRACTION PLAN, SLOT A — `mantis-architecture` (google/mantis)

- Node: `goldmine-mantis--ex_a--34a766d6` (slot A) · Subject: `google/mantis` · Language: Markdown agent-skill (prompt contract, no runtime code in the item).
- **PIN: `1e15346c2ca2d6e7db57ced59615bb9d1685992f`** (branch `main`). Mọi con số/dòng dưới đây đo trực tiếp trên cây PIN trong sandbox clone (bitnami/git:latest, Photon OS 5.0): `git rev-parse HEAD` = `1e15346c2ca2d6e7db57ced59615bb9d1685992f` — clone HEAD khớp PIN tuyệt đối, không trôi.
- **⚠️ ĐÂY CHỈ LÀ PLAN** — cắt thật (copy + prune) là lệnh riêng ngoài run này. Node này KHÔNG tự cắt, KHÔNG tạo repo, KHÔNG sửa upstream.

## 0. Chọn item (slot rule)

Quy tắc brief: lấy item **≥4★ ĐỨNG THỨ NHẤT** theo bảng `gm-08-stars.md` §1 (slot B lấy thứ hai; thiếu item đạt → N/A).

| Thứ tự | id | module | sao | Kết luận |
|---|---|---|---|---|
| 1 | s01 | mantis-advise | ★2 | loại (<4) |
| **2** | **s02** | **mantis-architecture** | **★4** | **CHỌN — item ≥4★ đầu tiên** |
| 3+ | s03…s26 | … | 3–5★ | slot B trở đi |

Bằng chứng thứ tự: `reports/mantis/gm-08-stars.md:13-14` — s01 ★2, s02 ★4 (5★ s14/s21/s26 đứng sau trong thứ tự bảng, không đụng luật "đứng thứ nhất").

## 1. Copy nguyên cục (verbatim) — danh sách file

Nguyên tắc copy-then-prune: copy **cả cục** những gì item cần, rồi mới cắt tỉa. Item là 1 skill Markdown thuần; "toàn bộ test liên quan" theo nghĩa upstream = surface test của thư mục `skills/` (item có T=0 — grep `mantis-architecture` trong `reference/tests` + `reference/evals` + `reference/test_suite.py` trên cây PIN = **0 hit**, đã chạy thật).

| # | File (đường dẫn @PIN) | Dung lượng đo | sha256 @PIN | Vai trong bản trích |
|---|---|---|---|---|
| 1 | `skills/mantis-architecture/SKILL.md` | 354 dòng / 21,168 bytes | `ba3bdd4da77a1a59b369c1425c64eea6e542b068ff497fa25c220af34bb0edd0` | Item — skill `/mantis-architecture`, byte-identical với PIN. Census: `find skills/mantis-architecture -type f` = đúng 1 file. |
| 2 | `test_skills_integrity.py` (root) | 5536 bytes | `15abc7f11a293d8cb67d5b27be95498b1c36f45a690fe4a935e2ea0644991848` | Toàn bộ test liên quan có thể chạy độc lập — stdlib-only (ast/pathlib/re/subprocess/unittest), docstring `:17` "Runs in a bare clone with nothing installed", `:22` tách bạch rõ "the reference implementation has its own suites under reference/". |
| 3 | `skills/README.md` | 1 hàng liên quan (dòng 9) | `9ec640ab1bb4a3d2f5e90b57878c83cb05eb2b85a7c1723dee8511e977f0a022` (bản gốc) | Config tối thiểu bắt buộc: `test_index_lists_exactly_the_skills` (`test_skills_integrity.py:63`) ép index phải liệt kê ĐÚNG tập skill hiện có → sau cắt chỉ giữ hàng `mantis-architecture` (nguyên văn hàng `skills/README.md:9`). |
| 4 | `LICENSE` | 11,358 bytes | `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30` | Apache-2.0 — giấy phép cho toàn bộ file copy + bắt buộc theo hợp đồng PROVENANCE của harvest. |

File 1–2 copy **byte-identical** trừ đúng 2 quyết định prune ở §2 (P1, P2). File 3 copy hàng đơn; phần còn lại của README cắt.

Điểm neo cơ chế của item (để reviewer đối chiếu sau cắt — grep-verified trên PIN):
- I/O contract đọc/ghi runtime state: `skills/mantis-architecture/SKILL.md:32-79` (mục "## Input/Output Contract", `:47` `changed_files`).
- Freshness gate cơ học: `:140` ("KB SNAPSHOT FRESHNESS GATE (mechanical; STATE + KB marker only…"), STALE banner `:162,:202`.
- Commit transactional: `:333` (`mv workspace/learnings.jsonl …`), `:340` (`cp -a workspace/kb/. workspace/archive/kb/kb_pass_${N}_${X_kb}/`).

## 2. Prune — KEEP / VENDOR / CUT (mỗi quyết định 1 dòng lý do)

| Quyết định | Đối tượng | Lý do (1 dòng) |
|---|---|---|
| **KEEP** | `skills/mantis-architecture/SKILL.md` | Item đích; tự trị, không nhúng code nào (grep `schema` = 0 hit, grep link `references/` = 0 hit trên PIN). |
| **KEEP** | `test_skills_integrity.py` | Test độc lập duy nhất của surface `skills/`, stdlib-only, chạy được trong clone trống. |
| **KEEP** | `LICENSE` | Giấy phép + provenance bắt buộc. |
| **KEEP (prune nội dung)** | `skills/README.md` → chỉ hàng `:9` | Index phải khớp đúng tập skill còn lại sau cắt (`test_skills_integrity.py:63-68`); hàng giữ nguyên văn upstream, không tự viết lại. |
| **PRUNE (sửa 1 dòng trong test đã copy — P1)** | `test_skills_integrity.py:41` `assertGreater(len(SKILLS), 10)` → hạ thành "≥1" | Assert đếm upstream giả định 19 skill; bản trích chứa đúng 1 skill → nguyên bản sẽ FAIL oan; mọi thứ khác trong file giữ byte-identical. |
| **PRUNE (sửa 1 dòng trong test đã copy — P2)** | `test_skills_integrity.py:124` `assertGreater(len(self.TEST_FILES), 10)` → hạ thành "≥1" | Cùng lý do P1 cho bộ TEST_FILES (glob test_*.py ở root + reference/) — bản trích chỉ có 1 test module. |
| **CUT** | `schema.json` (55KB) | SKILL.md không tham chiếu schema nào trong file (grep `schema` trên PIN = 0 hit); `kb_snapshot_id` (`schema.json:788`) là trường pipeline consumer đọc, không phải file skill đọc → không cần cho chạy độc lập. |
| **CUT** | `reference/**` toàn bộ (harness + `requirements.in` 16 dòng + `requirements.txt` 2691 dòng + `install.sh` + `tests/`) | Thuộc các item reference-*; docstring test `:22` tự tách bạch; item có T=0 (0 hit trong reference/tests|evals|test_suite.py). |
| **CUT** | 18 skill còn lại trong `skills/` | Item chỉ phụ thuộc runtime workspace, không phụ thuộc file skill khác; README prune tương ứng (KEEP hàng `:9`). |
| **CUT** | `action/`, `.github/`, `README.md`, `README_AGENTS.md`, `AGENTS.md`, `CONTRIBUTING.md`, `.pre-commit-config.yaml`, `.pip-tools.toml`, `.gitignore` | Không có tham chiếu nào từ item (grep path-like trong SKILL.md chỉ trả về đường dẫn runtime `workspace/…` — đã chạy trên PIN). |
| **CUT** | runtime `workspace/` (learnings.jsonl, .mantis_state.json, kb/, archive/) | Không được track trong upstream (`git ls-files \| grep workspace/learnings` = rỗng trên PIN) — là dữ liệu runtime item tự sinh/tiêu theo I/O contract `SKILL.md:32-79`. |
| **VENDOR — không cần** | — | Không có dependency ngoài nào cần vendor: item không có pip/node dep (test stdlib-only); không có link `references/*.md` để phải kéo theo (grep = 0 hit). |

Không prune gì trong `SKILL.md` — file giữ 100% byte-identical (hợp đồng modules harvest).

## 3. Lệnh build+test độc lập dự kiến + dry-run (output thật)

Env recipe (sandbox thực tế của node này): image `bitnami/git:latest` (VMware Photon OS 5.0) **không có python3 và không có apt** → cài bằng `yum install -y python3` (đã chạy thật → Python 3.14.8). Nếu môi trường cắt không có python3: ghi SKIPPED trung thực, không bịa.

Lệnh build+test của bản trích (không cần pip, không cần venv — test stdlib-only):

```
python3 test_skills_integrity.py                                            # toàn bộ surface check
find skills/mantis-architecture -type f                                     # kỳ vọng: đúng 1 file
find skills/mantis-architecture -name '*.md' -print0 | xargs -0 wc -l       # kỳ vọng: 354
sha256sum skills/mantis-architecture/SKILL.md                               # kỳ vọng: ba3bdd4d…edd0
```

Dry-run đã chạy THẬT trong sandbox (trên clone PIN đầy đủ, <2s — quá budget 2 phút nên dán nguyên văn; sau cắt kỳ vọng 7 tests vẫn OK với 2 assert đã prune):

```
$ cd /workspace/mantis && time python3 test_skills_integrity.py
.......
----------------------------------------------------------------------
Ran 7 tests in 1.005s
OK
real 0m2.001s / user 0m1.800s / sys 0m0.130s
$ python3 -m json.tool schema.json > /dev/null && echo SCHEMA_JSON_VALID
SCHEMA_JSON_VALID        # (chỉ kiểm chứng ngữ cảnh upstream; schema.json bị CUT khỏi bản trích)
```

Ghi nhận trung thực (SKIPPED): lệnh template chung `python3 -m venv venv && pip install -r reference/requirements.in && python3 -m pytest reference/tests -x -q` **không phải** build+test của item này (item T=0; suite `reference/` thuộc item khác, cần `reference/install.sh`, vượt budget dry-run 2 phút) → không chạy, không bịa output; command pytest đó giao cho item reference-* tương ứng.

## 4. Rủi ro cắt tỉa + cách kiểm sau cắt

| # | Rủi ro | Cách kiểm sau cắt |
|---|---|---|
| R1 | 2 assert đếm trong test (`:41`, `:124`) FAIL trên cây 1-skill nếu quên prune P1/P2 | Chạy `python3 test_skills_integrity.py` sau cắt — kỳ vọng `Ran 7 tests … OK`; nếu FAIL ở `test_skills_discovered`/`test_main_guard…` → P1/P2 chưa áp. |
| R2 | `skills/README.md` prune sai (thiếu/không khớp hàng) làm `test_index_lists_exactly_the_skills` (`:63`) + `test_index_links_resolve` FAIL | Cùng lệnh test trên; lỗi sẽ nêu đúng "run: python3 reference/scripts/gen_skills_index.py" → nghĩa là index ↔ skills lệch. |
| R3 | `SKILL.md` bị sửa tay làm mất byte-identical với PIN (vi phạm hợp đồng modules) | `sha256sum skills/mantis-architecture/SKILL.md` phải = `ba3bdd4d…edd0`; lệch → copy lại từ cây PIN, cấm merge tay. |
| R4 | Lélyt Python version (đã thử 3.14.8; môi trường khác có thể 3.8+) | Test chỉ dùng stdlib ổn định; ghi interpreter version vào PROVENANCE; nếu FAIL do version → ghi SKIPPED + môi trường, không sửa SKILL.md. |
| R5 | Khi re-sync hoặc gộp nhiều skill trích về 1 repo, assert "≥1" đã prune sẽ quá lỏng | Ghi vào PROVENANCE: 2 dòng P1/P2 phải siết lại về số skill/test thật của repo đích khi tái hợp — re-sync theo `tracking/<subject>.md`. |

## 5. Phủ định thực thi

Node này chỉ **chỉ định** file và lệnh. Việc copy/prune thật (tạo repo trích, push, PROVENANCE.md) là lệnh riêng ngoài run — đúng nguyên tắc "KHÔNG tự cắt, KHÔNG tự tạo repo" của brief gm-09a.
