# test-auto-doc MCP setup (Cursor)

Reference **Cursor** configuration for using the **test-auto-doc** MCP server with UTE TAF documentation: MCP server wiring plus **rules** and a **task-triggered skill** so agents reliably query the Knowledge Base instead of guessing Nokia-specific terms and library contracts.

Upstream mirror: [TAF/ai/test-auto-doc-mcp-setup](https://wrgitlab.ext.net.nokia.com/TAF/ai/test-auto-doc-mcp-setup/-/tree/main/configs/.cursor?ref_type=heads) (`configs/.cursor`).

---

## TL;DR

For better UTE TAF MCP usage:

Copy the `configs/.cursor/rules` and `configs/.cursor/skills` trees from this repository into your own `.cursor/` directory (project or user scope — [see below](#where-to-install-rules-and-skills)).

Installing the MCP server exposes the tools, but an MCP-capable agent does not automatically know **when** to call them, **which** vectorstore to query, or **how** to interpret Nokia-specific vocabulary. Pairing the server with these **rules** and **skill** improves tool invocation and grounds answers in authoritative documentation.

---

## Repository layout

| Path | Purpose |
|------|---------|
| [`configs/.cursor/mcp.json`](configs/.cursor/mcp.json) | Declares the `test-auto-doc` MCP server (`command`: `test-auto-doc`). |
| [`configs/.cursor/rules/`](configs/.cursor/rules/) | Always-on Cursor rules (domain + search methodology). |
| [`configs/.cursor/skills/ute-taf-mcp-agentic-flow/`](configs/.cursor/skills/ute-taf-mcp-agentic-flow/) | Task-triggered skill: TAF workflows bound to MCP tool usage and graceful degradation. |

---

## Rules and skills overview

| File | Scope | Purpose |
|------|--------|---------|
| [`01-nokia-domain-knowledge.mdc`](configs/.cursor/rules/01-nokia-domain-knowledge.mdc) | Always-on vocabulary | Nokia domain acronyms (TAF, UTE, SBTS, vCU, vDU, gNB/eNB, COAM, SCF, NETCONF, OAM, RFRL, WTS, UE, UEVT, NetAct, …) and TAF naming (`taf.*`, `ta_*`, `ta5g_*`, `rfsw.*`) plus lifecycle statuses (`lead`, `active`, `deprecated`). When such terms appear, the agent should treat the topic as Nokia-domain and consult the Knowledge Base via MCP. |
| [`02-knowledge-base-exploration.mdc`](configs/.cursor/rules/02-knowledge-base-exploration.mdc) | Search methodology | Agentic search: **decomposition → deepening → exploration → coverage check** before answering factual questions; synonyms, abbreviations, cause→effect / part→whole threads; keep searching until definitions, limits, steps, and edge cases are covered. |
| [`ute-taf-mcp-agentic-flow/SKILL.md`](configs/.cursor/skills/ute-taf-mcp-agentic-flow/SKILL.md) | Task-triggered TAF workflow | Binds TAF work (e.g. `taf.namespaces.*`, library failures, API/usage questions) to **test-auto-doc** MCP tools; describes degradation when the server is unavailable (retry, warn, then fallback). |

---

## Where to install rules and skills

Mirror the layout under [`configs/.cursor`](configs/.cursor) when copying into your environment.

Cursor discovers rules and skills from:

| Scope | Rules | Skills | When to use |
|--------|--------|--------|-------------|
| **Project** | `<repo-root>/.cursor/rules/<rule-name>.mdc` | `<repo-root>/.cursor/skills/<skill-name>/SKILL.md` (+ assets in the same folder) | Commit with the repo so every contributor and CI agent gets the same guidance. |
| **User (global)** | `~/.cursor/rules/<rule-name>.mdc` | `~/.cursor/skills/<skill-name>/SKILL.md` (+ assets) | Apply across all workspaces (several TAF-adjacent repos or scratch projects). |

Project-scoped and user-global configs can coexist; project files typically take precedence over user-global fallbacks.

Place each rule file directly under `rules/`. Place each skill in its own folder under `skills/` (folder name = skill id; contains `SKILL.md` and any supporting files).

### Example layouts

**Project-scoped (committed with the repo):**

```text
<repo-root>/.cursor/
├── rules/
│   ├── 01-nokia-domain-knowledge.mdc
│   └── 02-knowledge-base-exploration.mdc
├── skills/
│   └── ute-taf-mcp-agentic-flow/
│       └── SKILL.md
└── mcp.json   # optional; merge with your existing MCP servers
```

**User-global:**

```text
~/.cursor/
├── rules/
│   ├── 01-nokia-domain-knowledge.mdc
│   └── 02-knowledge-base-exploration.mdc
└── skills/
    └── ute-taf-mcp-agentic-flow/
        └── SKILL.md
```

No extra configuration is required for rules and skills beyond placing the files; Cursor picks them up on the next turn.

---

## MCP server configuration

This repo ships a minimal [`configs/.cursor/mcp.json`](configs/.cursor/mcp.json):

```json
{
  "mcpServers": {
    "test-auto-doc": {
      "command": "test-auto-doc"
    }
  }
}
```

Merge `mcpServers.test-auto-doc` into your project or user `mcp.json` if you already define other servers. Ensure the `test-auto-doc` executable is on your `PATH` (or replace `command` with the appropriate invocation for your install).

---

## Why both rules and a skill

- **Rules** load on every turn: domain vocabulary and search methodology so the agent recognizes Nokia/TAF scope and plans retrieval before answering.
- **Skills** activate when intent matches the skill description: they bind that intent to a concrete MCP call sequence.

Together:

1. A rule flags terms like `taf.sw.neat` or `COAM` as Nokia-domain.
2. A rule enforces a decomposed, multi-term search plan.
3. The skill routes the plan through the correct **test-auto-doc** tools.
4. The agent answers from documentation with real citations instead of guessing.

---

## Links

- Rules and skills in GitLab: [configs/.cursor](https://wrgitlab.ext.net.nokia.com/TAF/ai/test-auto-doc-mcp-setup/-/tree/main/configs/.cursor?ref_type=heads)
- Individual files: [01-nokia-domain-knowledge.mdc](https://wrgitlab.ext.net.nokia.com/TAF/ai/test-auto-doc-mcp-setup/-/blob/main/configs/.cursor/rules/01-nokia-domain-knowledge.mdc?ref_type=heads) · [02-knowledge-base-exploration.mdc](https://wrgitlab.ext.net.nokia.com/TAF/ai/test-auto-doc-mcp-setup/-/blob/main/configs/.cursor/rules/02-knowledge-base-exploration.mdc?ref_type=heads) · [ute-taf-mcp-agentic-flow/SKILL.md](https://wrgitlab.ext.net.nokia.com/TAF/ai/test-auto-doc-mcp-setup/-/blob/main/configs/.cursor/skills/ute-taf-mcp-agentic-flow/SKILL.md?ref_type=heads)
