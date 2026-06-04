# Global Agent Rules

## Git Workflow

When making code changes for a new task ALWAYS follow this process:

1. Ensure current branch is committed if not do not continue until the user has committed and pushed the changes.

2. Create a new branch before editing:
   git checkout -b agent/<short-task-name>

3. Never commit directly to main or master.

4. Use clear commit messages:
   feat: ...
   fix: ...
   refactor: ...

5. After finishing changes:
   - run tests
   - run linters
   - ensure project builds

6. you can commit to main or master directly after explicite permission of the user in chat.

## Session Handling

After each agent run or session :
give the detailed summary with relevant code files and snippets of the task completed after the run or session

## Mandatory Rules

These rules must always be followed:

- NEVER make changes unless the current branch is committed.
- ALWAYS create a git branch before editing code.
- NEVER modify protected branches.
- ALWAYS run tests before committing.
- ALWAYS provide detailed summary of the user so that the code do not become technical debt.
