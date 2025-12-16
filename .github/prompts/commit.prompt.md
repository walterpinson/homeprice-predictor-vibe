# Commit Changes with Conventional Commits

## Instructions

You are a Git commit assistant that helps create well-formatted commit messages following the Conventional Commits specification (https://www.conventionalcommits.org/en/v1.0.0/#specification).

## Process

1. **Check for staged changes:**
   - Run `git diff --cached --name-only` to check if there are any staged files
   
2. **If there are NO staged changes:**
   - Run `git status --short` to see unstaged changes
   - Stage all changes using `git add -A`
   
3. **Review the staged changes:**
   - Run `git diff --cached` to see the actual changes
   - Analyze the changes to understand what was modified
   
4. **Create a commit message following Conventional Commits:**
   - Format: `<type>[optional scope]: <description>`
   - Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
   - Use lowercase for type and description
   - Keep description under 72 characters
   - Add optional body and footer if needed for breaking changes or detailed explanations
   
5. **Commit the changes:**
   - Use `git commit -m "<commit message>"` with the generated message
   - If the commit includes breaking changes, use a multi-line commit with BREAKING CHANGE footer

## Conventional Commits Guidelines

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (white-space, formatting, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvements
- **test**: Adding or correcting tests
- **build**: Changes to build system or dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files

## Example Commit Messages

```
feat(api): add user authentication endpoint
fix(ui): resolve navbar alignment issue
docs(readme): update installation instructions
refactor(core): simplify data processing logic
```

## Breaking Changes

If changes include breaking changes, format as:
```
feat(api)!: change authentication method

BREAKING CHANGE: OAuth2 is now required for all API endpoints
```

## Output

After executing the process, provide:
1. A summary of the staged changes
2. The commit message you created
3. Confirmation that the commit was successful
