![One desk, one Mac, many model paths](docs/hero-freellmapi.jpg)

*หนึ่งเครื่อง หลายเส้นทาง · One Mac, many model paths. Civic-studio illustration — no text on the image.*

# FreeLLMAPI

**A local-first OpenAI-compatible proxy you run yourself.** Point any client at one `/v1` on your machine. The router in this tree picks among the free-tier adapters you actually configured, falls over when a key is rate-limited, and keeps provider secrets in an encrypted SQLite file.

[![CI](https://github.com/Nonarkara/freellmapi/actions/workflows/ci.yml/badge.svg)](https://github.com/Nonarkara/freellmapi/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-1A1A1A)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

Studio fork for learners who land from the [Nonarkara](https://github.com/Nonarkara) profile. Upstream source: [tashfeenahmed/freellmapi](https://github.com/tashfeenahmed/freellmapi).

By [Non Arkaraprasertkul](https://github.com/Nonarkara) (Nonarkara) — Axiom X Co., Ltd., Bangkok. Written for a bilingual Thai–English audience. This repository is **not** a hosted API, not a ranking product, and not an official depa / ASEAN / municipal service.

---

## What this is

FreeLLMAPI is an npm workspace you can clone and run:

| Path | What it is |
|---|---|
| `server/` | Express proxy (`@freellmapi/server` 0.2.1). `/v1` for clients; `/api/*` for the dashboard. |
| `client/` | React + Vite admin UI — keys, fallback chain, playground, analytics, embeddings, image/audio. |
| `desktop/` | Optional Electron tray (`freellmapi-desktop` 0.4.1) that hosts the same server locally. |
| `shared/` | Shared TypeScript types. |
| `docker-compose.yml` | Single-user container, published to `127.0.0.1` by default. |

What the code actually exposes:

- **OpenAI-shaped `/v1`** — `chat/completions`, `completions`, `responses`, `embeddings`, `images/generations`, `audio/speech`, and `GET /v1/models`.
- **Anthropic-shaped `/v1/messages`** (plus `count_tokens`) so Claude-style clients can hit the same router.
- **A router** (`server/src/services/router.ts`) with a hand-ordered fallback chain, optional bandit presets (`balanced` / `smartest` / `fastest` / `reliable` / `custom`), sticky sessions, and cooldown on 429 / 5xx.
- **Encrypted key storage** — AES-256-GCM over SQLite (`better-sqlite3`). Clients talk to you with one unified `freellmapi-…` bearer; upstream keys never leave the box.
- **Provider adapters** in `server/src/providers/` — Google, Groq, Cerebras, NVIDIA NIM, Mistral, OpenRouter, GitHub Models, Cohere, Cloudflare, Zhipu, Hugging Face Router, Ollama Cloud, Kilo, Pollinations, LLM7, OpenCode Zen, OVH, Agnes, Reka, SiliconFlow, Routeway, BazaarLink, AINative, AI Horde, plus a **custom** OpenAI-compatible slot (llama.cpp, LM Studio, local Ollama, vLLM).
- **Dashboard i18n** in `client/src/i18n/locales/` — `en`, `zh-CN`, `fr`, `es`, `pt-BR`, `it`. Thai copy is not in that folder today.

This tree also contains inherited catalog-sync and `/api/premium` code that talks to the **upstream** catalog host (`api.freellmapi.co` in `server/src/services/catalog-sync.ts`). This studio fork does not operate that service and does not publish model counts, token budgets, or a live catalog URL of its own. Treat those paths as optional upstream machinery, not as a Nonarkara product.

**This repo is not:**

- A public inference endpoint you can paste into a production app.
- A black-box leaderboard of “best” models.
- A claim about how many free tokens the internet currently offers.

---

## Philosophy

Studio tenets, applied to a proxy:

1. **Fork the method, not the secrets.** Take the router, the adapters, the fallback idea. Put *your* keys in `.env` and the dashboard. Never commit a provider token, a unified key, or an `ENCRYPTION_KEY`.
2. **One Mac.** The intended runtime is a single machine you own — Node 20+ on the desk, or the desktop tray, or Docker bound to localhost. Not a multi-tenant cloud.
3. **No black-box rankings.** The dashboard can show reliability / speed / intelligence *weights you can read* (`server/src/services/scoring.ts`). Default `balanced` is a convex combination of those weights plus headroom and rate-limit guards — not a secret score. Switch to `priority` if you want only the chain you ordered.
4. **Thai–English as audience.** Learners from the civic studio should be able to read this README in English and follow the method in Thai or English. The UI locales above are what the tree actually ships.

Company: **Axiom X Co., Ltd.** Author: **Non Arkaraprasertkul (Nonarkara)**. The MIT grant on this fork does not relicense upstream providers, their models, or their terms.

---

## Ethical use

Free tiers exist so a person can learn and prototype. Stacking them behind one local port does not make them yours to resell.

**Do**

- Run this for yourself on a machine you control. Default bind is loopback; keep it that way unless you are on a trusted LAN and understand the risk.
- Add only keys you created. One account per provider. Stay under that provider’s free-tier caps.
- Read each provider’s terms before you send traffic. The old ToS notes in git history are informational, not legal advice.
- Keep `ENCRYPTION_KEY` and the SQLite file (`server/data/` or the desktop app-support folder) off the internet and out of git.
- Label this as a personal proxy. Do not imply depa, a city, or Axiom X hosts inference for the public from this repo.

**Do not**

- Expose `:3001` to the public internet. The proxy is single-user; the unified key is the only gate on `/v1`.
- Resell, share, or wrap this endpoint as a paid API. That fights the providers’ no-resale clauses and burns the free tiers other learners need.
- Commit `.env`, `freeapi.db`, `fla_` / `freellmapi-` tokens, or catalog license keys.
- Treat fallback as an SLA. When every key is cooling down, the honest answer is “the pool is empty,” not a silent fake completion.
- Ship a product that depends on unpaid tiers. If the work is real, pay a provider with a contract.

If a contribution only works by pasting a secret, it does not belong here.

---

## How to use / learn

**Prerequisites:** Node.js 20.18+ (see `.nvmrc` / `package.json` `engines`), npm 10+, and a 64-character hex `ENCRYPTION_KEY`.

```bash
git clone https://github.com/Nonarkara/freellmapi.git
cd freellmapi
npm install
ENCRYPTION_KEY="$(node -e 'console.log(require("crypto").randomBytes(32).toString("hex"))')"
printf "ENCRYPTION_KEY=%s\nPORT=3001\n" "$ENCRYPTION_KEY" > .env
npm run dev
```

- Dashboard (Vite): [http://localhost:5173](http://localhost:5173)
- Proxy + built UI (after `npm run build`): [http://localhost:3001](http://localhost:3001)

On first server run, set the dashboard account. Open **Keys**, add provider credentials you own, order the **Fallback Chain**, copy the unified `freellmapi-…` key. Point a client at `http://localhost:3001/v1`:

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:3001/v1",
    api_key="freellmapi-your-unified-key",
)
print(client.chat.completions.create(
    model="auto",
    messages=[{"role": "user", "content": "Say hello in one sentence."}],
).choices[0].message.content)
```

```bash
curl http://localhost:3001/v1/chat/completions \
  -H "Authorization: Bearer freellmapi-your-unified-key" \
  -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"hi"}]}'
```

`model: "auto"` means “let the router decide.” Pin a catalog id when you need a specific model. Every completion can carry `X-Routed-Via: <platform>/<model>`.

**Docker (localhost only):**

```bash
ENCRYPTION_KEY="$(openssl rand -hex 32)"
printf "ENCRYPTION_KEY=%s\nPORT=3001\n" "$ENCRYPTION_KEY" > .env
docker compose up -d --build
```

The compose file still names `ghcr.io/tashfeenahmed/freellmapi:latest` as a pull image; `--build` uses this tree’s `Dockerfile`. Data lives in the `freellmapi-data` volume. Same `ENCRYPTION_KEY` on upgrade, or you cannot decrypt keys.

**Desktop tray:** `npm install --prefix desktop` then `npm run desktop:dist` (macOS) or `npm run desktop:dist:win`. The desktop build signs you into a hidden local account — no dashboard password. Default loopback port is `31415`. State: `~/Library/Application Support/FreeLLMAPI/` (macOS), `%APPDATA%\FreeLLMAPI\` (Windows), `~/.config/FreeLLMAPI/` (Linux).

**Learn the method, not a hosted demo**

1. Read `server/src/providers/index.ts` — every adapter that is actually registered.
2. Read `server/src/services/router.ts` and `scoring.ts` — how a request becomes a model.
3. Read `server/src/lib/crypto.ts` — why keys are not plaintext in SQLite.
4. Break it on purpose: disable a key, hit a 429, watch fallback and `X-Fallback-Attempts`.
5. Add a custom OpenAI-compatible base URL (local Ollama / llama.cpp) from the Keys page.

Windows PowerShell equivalents and native-build notes: [CONTRIBUTING.md](CONTRIBUTING.md). Env knobs: [`.env.example`](.env.example). Docker ops: [`docker/README.md`](docker/README.md). Desktop: [`desktop/README.md`](desktop/README.md).

---

## System diagram

Short labels so GitHub’s renderer does not clip.

```mermaid
flowchart LR
  CLI[SDK / CLI] --> V1["/v1"]
  UI[Dashboard] --> API["/api"]
  Tray[Desktop] --> V1
  V1 --> R[Router]
  API --> DB[(SQLite)]
  R --> DB
  R --> P[Adapters]
  R --> C[Custom]
```

```mermaid
flowchart TD
  Req[Request] --> Auth[Unified key]
  Auth --> Pick[Pick healthy model]
  Pick --> Call[Decrypt + call]
  Call -->|429 / 5xx| Cool[Cooldown]
  Cool --> Pick
  Call -->|OK| Out[Stream / JSON]
```

---

## License / contributing

[MIT](LICENSE). Copyright © 2026 Non Arkaraprasertkul / Axiom X Co., Ltd. Upstream copyright © 2026 Tashfeen Ahmed is retained.

Reuse the method with attribution. The license covers **this repository**. It does not relicense Google, Groq, or any other provider, and it does not grant a catalog, a hosted URL, or anyone else’s API key.

Contributions: see [CONTRIBUTING.md](CONTRIBUTING.md). Good first work: a provider adapter with a real test, a docs fix that stays factual, or a dashboard locale (Thai would match the studio audience). Do not add paid-only / card-gated tiers. Do not invent model counts. PRs should keep `npm test` green.

If you fork this into a civic stack — a council, a control tower, a classroom — say what you changed. The interesting part is the method.
