# Commit Message Generation Instructions

CRITICAL: Every commit message MUST start with the prefix: %GHC-QT

## Format

```plain
%GHC-QT <emoji> <type>(<optional scope>): <description>

[optional body with more detailed explanation]

[optional footer(s)]
```

## Types and Emojis

Use exactly ONE emoji matching the type:

### General Types
- feat (new feature): ✨
- fix (bug fix): 🐛
- docs (documentation): 📝
- style (formatting): 🎨
- refactor (code restructuring): ♻️
- test (tests): ✅
- chore (maintenance): 🔧
- build (build system): 📦
- ci (CI config): 🤖
- perf (performance): ⚡
- revert (revert commit): ⏪

### Robot Framework Specific Types
- keyword (custom keywords): 🔑
- resource (resource files): 📦
- library (test libraries): 📚
- suite (test suites): 🧪
- variables (variable files): 💾
- config (robot configs): ⚙️

## Rules

- ALWAYS include the %GHC-QT prefix first
- Use exactly ONE emoji matching the type
- Use imperative mood ("Add" not "Added")
- Capitalize the description
- Do not end description with a period
- Limit subject line to 50 characters after the prefix
- Separate header from body with a blank line
- Wrap body at 72 characters

## Robot Framework Specific Guidance

### Recommended Scopes
- Use component names (Cloud, ENB, Power, Loki, etc.) for targeted changes
- Use file categories (resources, configs, scripts) when appropriate

### Common Patterns
- **keyword**: When adding/modifying custom keywords in .robot files
- **suite**: When creating or updating test suites
- **test**: When adding/modifying individual test cases using ✅
- **resource**: When updating resource files or shared keywords
- **config**: When changing robocop.toml, EPC configs, or SCF templates
- **fix**: When fixing failing tests or broken functionality

## Examples

### General Examples
```plain
%GHC-QT ✨ feat(auth): Add login functionality
```

```plain
%GHC-QT 🐛 fix(api): Resolve timeout issue
```

```plain
%GHC-QT ♻️ refactor(core): Simplify data processing logic

- Extracted repeated code into helper functions
- Improved error handling for edge cases
```

### Robot Framework Specific Examples
```plain
%GHC-QT 🔑 keyword(5G): Add ENB power cycle keyword
```

```plain
%GHC-QT 🐛 fix(Cloud): Fix variable reference in health check
```

```plain
%GHC-QT 📚 library(common): Update common_keywords resource
```

```plain
%GHC-QT 💾 variables(SRAN): Add new EPC simulator configs
```
