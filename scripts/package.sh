#!/usr/bin/env bash
# package.sh — 올릴 수 있는 형태로 묶는다
#
# 목적지마다 필요한 모양이 다르다. 그걸 손으로 맞추다 보면 ChatGPT 용 묶음을
# Claude 에 올리는 사고가 난다(실제로 났다). 그래서 스크립트로 고정했다.
#
# 사용법:  scripts/package.sh [스킬이름]     (생략하면 baton)
# 결과:    dist/ 아래에 zip 세 개. dist/ 는 git 에 안 올린다 — 파일이 원본이고
#          zip 은 만들어 쓰는 것이다. 저장소에 두면 곧 내용과 갈린다.

set -euo pipefail

SKILL="${1:-baton}"
ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
SRC="$ROOT/$SKILL"
DIST="$ROOT/dist"

[ -d "$SRC" ] || { echo "그런 스킬이 없다: $SKILL" >&2; exit 1; }
[ -f "$SRC/SKILL.md" ] || { echo "SKILL.md 가 없다: $SRC" >&2; exit 1; }
command -v zip >/dev/null || { echo "zip 명령이 필요하다" >&2; exit 1; }

rm -rf "$DIST/_work"
mkdir -p "$DIST/_work"

# --- SKILL.md 가 업로더에 받아들여질 모양인지 먼저 본다 ---------------------
python3 - "$SRC/SKILL.md" "$SKILL" <<'PY'
import re, sys
path, want = sys.argv[1], sys.argv[2]
raw = open(path, 'rb').read()
s = raw.decode('utf-8')
bad = []
if raw.startswith(b'\xef\xbb\xbf'): bad.append('파일 앞에 BOM 이 붙어 있다')
if b'\r\n' in raw:                  bad.append('줄바꿈이 CRLF 다 (LF 여야 한다)')
m = re.match(r'^---\n(.*?)\n---\n', s, re.S)
if not m:
    bad.append('맨 위 --- frontmatter 가 없거나 모양이 틀렸다')
else:
    fm = m.group(1)
    name = re.search(r'^name:\s*(\S+)\s*$', fm, re.M)
    desc = re.search(r'^description:\s*(.+)$', fm, re.M)
    if not name:                     bad.append('name 이 없다')
    elif name.group(1) != want:      bad.append(f'name({name.group(1)}) 이 폴더명({want}) 과 다르다')
    elif not re.fullmatch(r'[a-z0-9-]+', name.group(1)):
                                     bad.append('name 은 소문자와 하이픈만 쓴다')
    if not desc:                     bad.append('description 이 없다')
    elif len(desc.group(1)) > 1024:  bad.append(f'description 이 {len(desc.group(1))}자다 (한도 1024)')
if bad:
    print('SKILL.md 가 업로드에 걸릴 수 있다:', file=sys.stderr)
    for b in bad: print('  -', b, file=sys.stderr)
    sys.exit(1)
print('SKILL.md 검사 통과')
PY

# --- ① Claude 계정 스킬 · 폴더형 -------------------------------------------
# zip 은 있는 파일에 덧붙인다. 지우고 시작하지 않으면 지난 판의 파일이 그대로
# 남아, 뺀 폴더가 계속 딸려 들어간다. 2026-08-22 에 gemini/ 로 실제로 겪었다.
rm -f "$DIST/$SKILL"-*.zip

# 업로더가 받는 모양이 이것이다 (2026-08-19 실제 업로드로 확인).
mkdir -p "$DIST/_work/a"
cp -r "$SRC" "$DIST/_work/a/$SKILL"
rm -rf "$DIST/_work/a/$SKILL/gpt" "$DIST/_work/a/$SKILL/gemini"   # 다른 제품용 자료는 뺀다
( cd "$DIST/_work/a" && zip -qr "$DIST/$SKILL-skill.zip" "$SKILL" -x '*.DS_Store' '__MACOSX/*' )

# --- ② Claude 계정 스킬 · 평면형 (예비 — ①이 통과하므로 평소엔 안 쓴다) ----
mkdir -p "$DIST/_work/b"
cp -r "$SRC/." "$DIST/_work/b/"
rm -rf "$DIST/_work/b/gpt" "$DIST/_work/b/gemini"
( cd "$DIST/_work/b" && zip -qr "$DIST/$SKILL-skill-flat.zip" . -x '*.DS_Store' '__MACOSX/*' )

# --- ③ ChatGPT 용 (스킬 아님 — 지침 붙여넣기 + 지식 업로드) ----------------
if [ -d "$SRC/gpt" ]; then
  mkdir -p "$DIST/_work/c"
  cp "$SRC/gpt/"*.md "$DIST/_work/c/" 2>/dev/null || true
  cp "$SRC/references/"*.md "$DIST/_work/c/" 2>/dev/null || true
  ( cd "$DIST/_work/c" && zip -qr "$DIST/$SKILL-gpt.zip" . -x '*.DS_Store' '__MACOSX/*' )
fi

# --- ④ Gemini 용 (스킬 아님 — Gem 안내 붙여넣기 · CLI 는 GEMINI.md) -------
if [ -d "$SRC/gemini" ]; then
  mkdir -p "$DIST/_work/d"
  cp "$SRC/gemini/"*.md "$DIST/_work/d/" 2>/dev/null || true
  cp "$SRC/references/"*.md "$DIST/_work/d/" 2>/dev/null || true
  cp "$SRC/gpt/PASTE_COMMANDS.md" "$DIST/_work/d/" 2>/dev/null || true   # Gem 도 붙여넣기가 필요하다
  ( cd "$DIST/_work/d" && zip -qr "$DIST/$SKILL-gemini.zip" . -x '*.DS_Store' '__MACOSX/*' )
fi

rm -rf "$DIST/_work"

echo
echo "dist/ 에 만들었다 — 목적지를 헷갈리지 마라"
echo "  $SKILL-skill.zip       → Claude 설정 · Skills 에 업로드 (이게 통과하는 모양이다)"
echo "  $SKILL-skill-flat.zip  → 예비. 위가 거부될 때만 쓴다"
[ -f "$DIST/$SKILL-gpt.zip" ] && \
echo "  $SKILL-gpt.zip         → ChatGPT 용. Claude 에 올리면 거부된다 (SKILL.md 가 없다)"
[ -f "$DIST/$SKILL-gemini.zip" ] && \
echo "  $SKILL-gemini.zip      → Gemini 용. Gem 은 INSTRUCTIONS, CLI 는 GEMINI.md"
echo
ls -la "$DIST"/*.zip
