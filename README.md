# AI Web Agent

**AI-powered, Playwright-driven web automation agent** for crawling feeds, extracting posts, and generating human-like replies with an LLM.  
Includes a one-line Ubuntu installer, `systemd` scheduling, and policy safeguards for safe, compliant engagement.

---

## ✨ Features

- **Headless browser automation** via [Playwright](https://playwright.dev) (Chromium).
- **Feed crawling** — navigate, scroll, and extract posts even on JS-heavy sites.
- **LLM-driven reasoning** — decide whether to reply, like, or ignore.
- **Human-style replies** — configurable persona, tone, and safety rules.
- **Three modes**:
  - `research` — read-only, extract and store posts.
  - `draft` — generate replies for manual review.
  - `engage` — auto-like/reply where platform ToS permits.
- **Safety guardrails** — keyword filters, quiet hours, daily caps, and per-site policy flags.
- **Systemd integration** — run on a schedule without keeping a terminal open.
- **Installer script** — single command to install on headless Ubuntu.

---

## ⚠️ Compliance

This project is designed with **policy enforcement** in mind.

- Use **read-only** mode on platforms that prohibit automated interaction via the web UI.
- For sites that permit automation or provide an API, set `engagement_allowed: true` in `config.yaml`.
- Never bypass CAPTCHAs or MFA with this bot — switch to manual login or API mode.
- Respect each site’s [Terms of Service](https://en.wikipedia.org/wiki/Terms_of_service), robots.txt, and rate limits.
- You are responsible for lawful use in your jurisdiction.

---

## 📦 Installation

Run the following on your Ubuntu 20.04 or 22.04+ server:

```bash
wget -O aiwebagent-installer.sh https://raw.githubusercontent.com/aukiman/ai-web-agent/main/installer.sh \
  && chmod +x aiwebagent-installer.sh \
  && sudo bash aiwebagent-installer.sh

## 🛠 Configuration

After install, edit:

sudo nano /opt/ai-web-agent/.env            # API keys and environment vars
sudo nano /opt/ai-web-agent/config.yaml     # Sites, feeds, modes, limits, persona settings

Key files:

.env

OPENAI_API_KEY — your OpenAI (or compatible) API key.

OPENAI_BASE_URL — default is https://api.openai.com/v1.

OPENAI_MODEL — e.g. gpt-4o-mini.

TZ — your timezone for quiet hours.

config.yaml

mode — research, draft, or engage.

sites — list of target sites, base URLs, and engagement flags.

feeds — list of feed URLs to crawl and frequency.

limits — action caps, delays, and quiet hours.

safety — banned keywords, max reply length, review rules.

▶️ Running

The installer sets up a systemd service + timer:

sudo systemctl status aiwebagent.service    # Check last run
sudo systemctl status aiwebagent.timer      # See schedule
journalctl -u aiwebagent.service -f         # View logs live


The timer runs the agent every 10 minutes by default. Change this in:

sudo nano /etc/systemd/system/aiwebagent.timer
sudo systemctl daemon-reload
sudo systemctl restart aiwebagent.timer

🗂 Project Structure
ai-web-agent/
  agent.py               # Main runner
  actions.py             # Like/reply actions
  extractors.py          # Site-specific post extraction
  persona.py             # Persona prompt builder
  policy.py              # Safety guardrails
  db.py                  # SQLite storage
  llm.py                  # LLM API call logic
  utils.py               # Helpers
  requirements.txt
  config.yaml.sample
  .env.sample
  scripts/
    installer.sh
    uninstall.sh
  systemd/
    aiwebagent.service
    aiwebagent.timer

❌ Uninstall
sudo /opt/ai-web-agent/scripts/uninstall.sh

📝 License
This project is released under the MIT License.
You are solely responsible for using it in a manner consistent with local laws and site policies.
