# skills

내가 쓰는 Claude Code 스킬 모음. 프로젝트를 옮겨 다니며 쓰는 것들만 여기 둔다.

## 들어 있는 것

| 스킬 | 하는 일 | 판 |
|---|---|---|
| [`baton`](baton/) | 세션을 끝내며 다음 세션에 넘긴다. 산출물 상태를 실측하고, 검증을 다시 돌리고, 대화 기록 없이도 다음 세션이 첫 행동을 할 수 있는 핸드오프를 남긴다 | [Claude Code](baton/SKILL.md) · [ChatGPT](baton/gpt/) |

`baton` 은 두 판이 있다. 원리는 같고 작동 방식이 다르다 — Claude Code 판은 에이전트가 직접 상태를 실측하고, ChatGPT 판은 사용자가 붙여넣은 것만 사실로 쓴다. 자세한 건 [`baton/gpt/README.md`](baton/gpt/README.md).

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
