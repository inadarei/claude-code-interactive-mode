# Document Project Context

Document everything you know about this project so that another session of Claude Code can be productive as soon as they check out this repository from git. Decide to analyze and survey the entire project first, if you do not already have full understanding of the project and how it is implemented, including its architecture and purpose. Pay attention to README.md file since it often contains valuable information

- Create fine-grained context files scoped to the directories where they matter
- Create any additional slash commands needed for repeatable tasks
- Carefully analyze opportunities for creating well-thought skills to make sure further code modifications follow existing architectural approaches, coding style, and best practices
- Do not add anything to the main CLAUDE.md except for a short (single small paragraph) synopsis of what the project is trying to achieve.
- Do add to top-level CLAUDE.md short (single small paragraph) synopsis of what the project is trying to achieve
- Make sure to create relevant skills

CRITICAL: Present a plan of what you are going to change in this project to achieve this, before modifying anything.

## Skills are REQUIRED, not optional

  Skills differ from commands in one critical way: Claude auto-invokes them
  based on conversation context, without the user typing anything. They live
  in `.claude/skills/<name>/` as directories containing a `SKILL.md` file.

  For any non-trivial project you MUST create at least 2 skills. Failure to
  create skills is a documentation failure.

### What makes a good skill (auto-invocation is the key test)

Ask: "Would a new Claude session benefit from this knowledge being loaded
automatically, without having to remember to ask for it?" If yes → skill.
If it only helps when explicitly requested → command instead.

Good candidates:
- Architectural patterns a new session would likely get wrong
  (e.g. "adding a new provider using our Strategy pattern")
- Multi-step workflows with domain-specific sequencing that linting can't
  catch (e.g. "adding a new database query + migration + test")
- Patterns where the *shape* of the solution matters as much as correctness
  (e.g. "how we wire async thread-pool work in this codebase")

Bad candidates (use commands instead):
- Simple recipe checklists with no contextual judgment needed
- Tasks the user will always invoke explicitly ("run the tests")

### Skill structure
Each skill is a directory:
.claude/skills/
  SKILL.md          ← required; describe trigger conditions in frontmatter
  template.py       ← optional supporting file (code template, example, etc.)

Use frontmatter to control invocation:
---description: Loaded when adding a new reranker or ranking provider
