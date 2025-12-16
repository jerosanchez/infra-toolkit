# Bash script content

To ensure that AI-generated bash scripts are safe, readable, and pass linting checks (e.g., `shellcheck`), follow these guidelines:

- Use `#!/bin/bash` as the shebang for portability.
- Prefer `set -euo pipefail` at the top for safer scripts.
- Quote all variable expansions (e.g., `"$var"`).
- Use `read -r` to avoid mangling backslashes.
- Avoid using `eval` unless absolutely necessary.
- Use functions for reusable code blocks or to improve human readability.
- Add comments for clarity and maintainability.
- Indent with 4 spaces or tabs consistently.
- Check command exit codes and handle errors.
- Prefer long-form options for commands (e.g., `--help`).
