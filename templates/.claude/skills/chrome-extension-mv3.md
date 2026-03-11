# Skill: Chrome Extension (Manifest V3)

**Used by:** Chrome Extension agent, code-reviewer when working on browser extension projects.

---

## Scope

- Manifest V3 (MV3) APIs: service worker, declarative content scripts, optional host permissions.
- Security: CSP, no eval, minimal permissions.
- Structure: popup, options, background (service worker), content scripts, offscreen if needed.

## Conventions

- Use `chrome.scripting`, `chrome.storage`, `chrome.runtime` per MV3.
- Prefer declarative content scripts where possible.
- Document host permissions and justify each in the track.

See MANIFEST.md for when this skill is copied (Chrome extension team type or `--chrome-ext`).
