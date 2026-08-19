# skills

내가 쓰는 Claude Code 스킬 모음. 프로젝트를 옮겨 다니며 쓰는 것들만 여기 둔다.

## 들어 있는 것

| 스킬 | 하는 일 | 판 |
|---|---|---|
| [`baton`](baton/) | 세션을 끝내며 다음 세션에 넘긴다. 산출물 상태를 실측하고, 검증을 다시 돌리고, 대화 기록 없이도 다음 세션이 첫 행동을 할 수 있는 핸드오프를 남긴다 | [Claude Code](baton/SKILL.md) · [ChatGPT](baton/gpt/) |

`baton` 은 두 판이 있다. 원리는 같고 작동 방식이 다르다 — Claude Code 판은 에이전트가 직접 상태를 실측하고, ChatGPT 판은 사용자가 붙여넣은 것만 사실로 쓴다. 자세한 건 [`baton/gpt/README.md`](baton/gpt/README.md).

## 어디에 올리나 — 목적지를 헷갈리지 마라

같은 스킬이라도 목적지마다 필요한 모양이 다르다. **ChatGPT 용 묶음을 Claude 에 올리면 "유효하지 않은 스킬" 로 거부된다** — `SKILL.md` 가 없기 때문이다. 실제로 한 번 겪었다.

Claude 업로더가 받는 모양은 **`스킬이름/SKILL.md` 로 폴더 한 겹이 있는 zip** 이다(2026-08-19 확인). 평면형도 만들어 두지만 예비다.

```bash
scripts/package.sh baton     # dist/ 에 세 개가 만들어진다
```

| 만들어지는 것 | 어디로 | 어떻게 |
|---|---|---|
| `baton-skill.zip` | **Claude** 설정 → Skills | 그대로 업로드. **2026-08-19 실제로 통과 확인** |
| `baton-skill-flat.zip` | 〃 | 예비용. `SKILL.md` 가 최상위에 있는 형태 — 지금은 쓸 일이 없다 |
| `baton-gpt.zip` | **ChatGPT** 커스텀 GPT | **업로드가 아니다.** 압축을 풀어 `INSTRUCTIONS.md` 는 지침란에 붙여넣고, 나머지만 지식 파일로 올린다 |
| 저장소 폴더 자체 | **Claude Code** 프로젝트 | 아래 "가져다 쓰기" 참고 |

스크립트는 묶기 전에 `SKILL.md` 를 먼저 검사한다 — frontmatter 모양, `name` 이 폴더명과 같은지, description 길이, BOM, 줄바꿈. 걸리면 zip 을 만들지 않고 이유를 알려준다. 업로더에서 "유효하지 않은 스킬" 만 보고 원인을 못 찾는 상황을 막으려는 것이다.

**`dist/` 는 git 에 올리지 않는다.** 파일이 원본이고 zip 은 만들어 쓰는 것이다. 저장소에 두면 곧 내용과 갈려서, 낡은 zip 을 올리고 왜 안 바뀌냐고 헤매게 된다.

## 가져다 쓰기

프로젝트의 `.claude/skills/` 아래에 스킬 폴더째 넣으면 그 프로젝트에서 잡힌다.

```bash
# 필요한 스킬 하나만
git clone --depth 1 https://github.com/mongsiljjang/skills /tmp/skills
cp -r /tmp/skills/baton <프로젝트>/.claude/skills/
chmod +x <프로젝트>/.claude/skills/baton/scripts/repo_snapshot.sh
```

셸 스크립트의 실행 권한(`chmod +x`)이 빠지면 스냅샷 단계가 조용히 실패한다.
git 이 실행 비트를 보존하므로 보통은 그대로 따라오지만, 압축을 풀어 옮겼다면 확인한다.

## 고칠 때

**원본은 여기다.** 프로젝트 안의 사본을 고치면 다음에 가져다 쓸 때 사라진다.
여기서 고치고 프로젝트로 다시 복사한다.
