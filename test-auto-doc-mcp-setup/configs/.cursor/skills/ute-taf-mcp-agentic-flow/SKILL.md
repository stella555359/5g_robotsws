---
name: taf-libraries-agentic-flow
description: >-
  Grounds edits and investigations in the Test Automation Framework (TAF) Knowledge Base via
  the test-auto-doc MCP server. Use when the user asks to modify, replace, or refactor code in
  this repo; when troubleshooting UTE TAF Python libraries (including imports under
  `taf.namespaces`); or when checking TAF APIs, function behavior, signatures, and usage
  examples. Prefer authoritative MCP output over guessing library contracts.
---

# TAF libraries and code workflow

**TAF** means **Test Automation Framework**: shared libraries used by testers and automation
code (Python helpers, Robot resources, and related glue). **UTE** TAF libraries are the
product-side namespaces commonly imported as `taf.namespaces.*` in test code.

This skill applies alongside broader project rules. When the task touches TAF imports,
symbols from `taf.namespaces`, or you are unsure of a helper’s contract, treat the Knowledge
Base as the source of truth before editing.


## When to apply

- User requests **code changes** (add, modify, replace, refactor), especially in tests,
  resources, or Python that may call TAF.
- **Troubleshooting** failures, odd behavior, or environment issues tied to a TAF library.
- **API or usage questions**: parameters, return values, side effects, or **examples** of
  correct usage.

## MCP server: `test-auto-doc`

### Knowledge Base and documentation search

| Tool | Purpose |
|------|---------|
| **`list_vectorstores`** | Lists registered documentation collections (vectorstore domains) in the Knowledge Base. Call first when you need to see which doc corpora exist before querying. |
| **`query_taf_documentation`** | Semantic search over **TAF documentation**: Python libraries for product automation (SBTS, vRAN, UE automation, measurement equipment, APIs, device access). Pass a natural-language `query`; optional `n_results` (default 5). |
| **`query_automation_strategy`** | Semantic search over **test automation strategy** docs: guidelines for product-specific automation approaches, APIs, and library use. |
| **`query_uevt_documentation`** | Semantic search over **User Equipment (UE)** docs: supported devices, UE management, attach/detach, Nokia Android application, UE proxy, installation. |
| **`query_agents_documentation`** | Semantic search over **UTE agents** docs: agent configuration, deployment, and usage across test agents. |

### Per-library TAF catalog (structured)

| Tool | Purpose |
|------|---------|
| **`list_taf_libraries`** | Lists all **TAF libraries** registered in the Knowledge Base (name, status, version, counts of functions/examples). Use to resolve exact `library_name` when imports or filenames are ambiguous. |
| **`get_taf_library`** | **Overview** of one library: URL, status, version, and lists of available **functions** and **examples**. |
| **`get_taf_library_functions`** | **All functions** in a library with short documentation and URLs—use to browse capabilities or disambiguate symbol names. |
| **`get_taf_function`** | **Full documentation** for one function: parameters, return values, narrative docs, links—authoritative before changing call sites. |
| **`get_taf_function_examples`** | **Code examples** that call a specific function written in Python, prefer over inventing usage. |
| **`get_taf_library_examples`** | **All examples** that are actual working code (Python or Robot Framework) that demonstrate library usage |
| **`get_taf_troubleshooting`** | **Troubleshooting handbook** for a library: known issues, workarounds, debugging notes—use early when tests fail or behavior is flaky. |

## What to do when mcp server is not available

1. retry once after 1 second
2. if still not available, fail with error message that mcp server is not available.
3. MUST warn the user with message that answer will be based on knowledge base only and might be incomplete. This MUST be done before failing.
