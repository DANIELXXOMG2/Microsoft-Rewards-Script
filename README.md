# Microsoft Rewards Script

An automated TypeScript-based bot for Microsoft Rewards, powered by Playwright and Cheerio.

[![Version](https://img.shields.io/badge/version-1.5.3-blue.svg)](package.json)
[![License](https://img.shields.io/badge/license-ISC-green.svg)](LICENSE)
[![TypeScript](https://img.shields.io/badge/typescript-5.5.4-blue.svg)](package.json)
[![Playwright](https://img.shields.io/badge/playwright-1.52.0-red.svg)](package.json)

> **⚠️ Personal Use Disclaimer**: This project is developed primarily for personal use. Use at your own risk.

## ✨ Features

- 🔄 **Multi-Account Support** - Manage multiple Microsoft accounts
- 💾 **Session Storage** - Persistent browser sessions to reduce login frequency
- 🔐 **2FA & Passwordless Support** - Full authentication method compatibility
- 🤖 **Headless Operation** - Run silently in background (Docker-friendly)
- 🔗 **Discord Webhooks** - Real-time notifications and logging
- 🖥️ **Desktop & Mobile Searches** - Complete daily search requirements
- ⚙️ **Configurable Tasks** - Enable/disable specific activities
- 🌍 **Geo-Localized Queries** - Country-specific search terms
- 🎯 **Smart Task Detection** - Daily set, promotions, punch cards, and more
- 🔄 **Proxy Support** - HTTP, HTTPS, and SOCKS proxy compatibility
- 🐳 **Docker Support** - Containerized deployment with automated scheduling
- ⚡ **Clustering** - Parallel processing for multiple accounts

## 📋 Quick Start

### Local Installation

1. **Download or clone** the repository
   ```bash
   git clone https://github.com/DANIELXXOMG2/Microsoft-Rewards-Script.git
   cd Microsoft-Rewards-Script
   ```

2. **Install dependencies**
   ```bash
   npm i
   # or with bun
   bun install
   ```

3. **Configure accounts**
   ```bash
   cp src/accounts.example.jsonc src/accounts.jsonc
   # Edit src/accounts.jsonc with your Microsoft account credentials
   ```

4. **Configure settings**
   ```bash
   cp src/config.example.jsonc src/config.jsonc
   # Adjust src/config.jsonc to your preferences
   ```

5. **Build and run**
   ```bash
   npm run build
   npm run start
   ```

### Docker Deployment (Recommended)

1. **Prepare configuration files**
   ```bash
   cp src/accounts.example.jsonc src/accounts.jsonc
   cp src/config.example.jsonc src/config.jsonc
   # Edit both files with your settings
   ```

2. **Configure Docker Compose**
   - Edit `compose.yaml` to set your timezone and schedule
   - Ensure `config.jsonc` has `"headless": true` and `"clusters": 1`

3. **Deploy**
   ```bash
   docker compose up -d
   ```

4. **Monitor logs**
   ```bash
   docker logs microsoft-rewards-script -f
   ```

## 🐳 Docker Configuration

### Prerequisites

- Remove local `/node_modules` and `/dist` folders if previously built locally
- Clean up any old session data from previous versions
- Existing `accounts.jsonc` files from v1.4+ are compatible

### Essential Docker Settings

Ensure these values in your `config.jsonc`:
```jsonc
{
  "headless": true,
  "clusters": 1
}
```

### Docker Compose Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `TZ` | Container timezone | - | `America/New_York` |
| `CRON_SCHEDULE` | Execution schedule (cron format) | - | `0 7,17 * * *` |
| `RUN_ON_START` | Run script on container startup | `false` | `true` |
| `EXPECTED_DAILY_RUNS` | Required successful runs per day | `1` | `2` |
| `MIN_SLEEP_MINUTES` | Minimum random start delay | `5` | `10` |
| `MAX_SLEEP_MINUTES` | Maximum random start delay | `50` | `60` |
| `SKIP_RANDOM_SLEEP` | Disable randomized start times | `false` | `true` |

### Volume Mounts

- `./src/accounts.jsonc:/usr/src/microsoft-rewards-script/dist/accounts.jsonc:ro` - Account credentials
- `./src/config.jsonc:/usr/src/microsoft-rewards-script/dist/config.jsonc:ro` - Configuration settings
- `./sessions:/usr/src/microsoft-rewards-script/dist/browser/sessions` - Persistent browser sessions
- `./logs:/usr/src/microsoft-rewards-script/logs` - Execution logs

## ⚙️ Configuration Reference

### Core Settings

| Option | Description | Default | Type |
|--------|-------------|---------|------|
| `baseURL` | Microsoft Rewards base URL | `https://rewards.bing.com` | string |
| `sessionPath` | Browser session storage directory | `sessions` | string |
| `headless` | Run browser in headless mode | `false` | boolean |
| `parallel` | Run desktop/mobile tasks concurrently | `true` | boolean |
| `runOnZeroPoints` | Continue execution when 0 points available | `false` | boolean |
| `clusters` | Number of parallel worker processes | `1` | number |
| `globalTimeout` | Default action timeout | `30s` | string/number |

### Worker Tasks

| Worker | Description | Default |
|--------|-------------|---------|
| `doDailySet` | Complete daily set activities | `true` |
| `doMorePromotions` | Complete additional promotions | `true` |
| `doPunchCards` | Complete punch card activities | `true` |
| `doDesktopSearch` | Perform desktop searches | `true` |
| `doMobileSearch` | Perform mobile searches | `true` |
| `doDailyCheckIn` | Complete daily check-in | `true` |
| `doReadToEarn` | Complete read-to-earn activities | `true` |

### Search Settings

| Option | Description | Default | Type |
|--------|-------------|---------|------|
| `useGeoLocaleQueries` | Use country-specific search queries | `false` | boolean |
| `scrollRandomResults` | Simulate scrolling behavior | `true` | boolean |
| `clickRandomResults` | Click random search results | `true` | boolean |
| `searchDelay.min` | Minimum delay between searches | `3min` | string/number |
| `searchDelay.max` | Maximum delay between searches | `5min` | string/number |
| `retryMobileSearchAmount` | Mobile search retry attempts | `2` | number |

### Fingerprint Persistence

| Option | Description | Default |
|--------|-------------|---------|
| `saveFingerprint.desktop` | Reuse desktop browser fingerprint | `false` |
| `saveFingerprint.mobile` | Reuse mobile browser fingerprint | `false` |

### Proxy Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `proxy.proxyGoogleTrends` | Proxy Google Trends requests | `true` |
| `proxy.proxyBingTerms` | Proxy Bing suggestions requests | `true` |

### Webhook Integration

| Option | Description | Default |
|--------|-------------|---------|
| `webhook.enabled` | Enable Discord webhook notifications | `false` |
| `webhook.url` | Discord webhook URL | `""` |

### Logging

| Option | Description | Default |
|--------|-------------|---------|
| `logExcludeFunc` | Functions to exclude from console logs | `["SEARCH-CLOSE-TABS"]` |
| `webhookLogExcludeFunc` | Functions to exclude from webhook logs | `["SEARCH-CLOSE-TABS"]` |

## 📦 NPM Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `pre-build` | Install dependencies and Playwright | `npm run pre-build` |
| `build` | Compile TypeScript and copy JSONC files | `npm run build` |
| `start` | Run compiled JavaScript | `npm run start` |
| `ts-start` | Run TypeScript directly | `npm run ts-start` |
| `dev` | Run in development mode | `npm run dev` |
| `kill-chrome-win` | Kill orphaned Chrome processes (Windows) | `npm run kill-chrome-win` |
| `create-docker` | Build Docker image | `npm run create-docker` |

## 🔧 Account Configuration

The `accounts.jsonc` file supports multiple accounts with individual proxy settings:

```jsonc
[
  {
    "email": "your_email@outlook.com",
    "password": "your_password",
    "proxy": {
      "proxyAxios": false,     // Use proxy for HTTP requests
      "url": "",               // Proxy URL (empty = no proxy)
      "port": 0,               // Proxy port
      "username": "",          // Proxy authentication
      "password": ""           // Proxy authentication
    }
  }
]
```

### Supported Proxy Types

- HTTP: `http://proxy.example.com:8080`
- HTTPS: `https://proxy.example.com:8080`
- SOCKS5: `socks5://proxy.example.com:1080`

## 🚨 Important Notes

### Chrome Process Management
If you terminate the script while running in non-headless mode, Chrome processes may remain active. Use the task manager or run:
```bash
npm run kill-chrome-win  # Windows only
```

### Automation Best Practices
- Run the script **at least twice daily** to ensure all tasks are completed
- Set `"runOnZeroPoints": false` to skip execution when no points are available
- Use randomized scheduling to avoid patterns that might trigger detection
- Monitor logs regularly for account health and issues

### Security Considerations
- Keep `accounts.jsonc` and `config.jsonc` private and secure
- Use strong, unique passwords for your Microsoft accounts
- Enable 2FA where possible
- Review proxy providers for reliability and security

## 🐛 Troubleshooting

### Common Issues

1. **Stuck browser processes**: Use `npm run kill-chrome-win` (Windows)
2. **Login failures**: Check credentials, 2FA settings, and proxy configuration
3. **Zero points detected**: Normal behavior when daily limits are reached
4. **Docker container won't start**: Verify volume mounts and file permissions

### Getting Help

- Check logs in `./logs/` directory for detailed error information
- Ensure all configuration files are valid JSONC format
- Verify proxy settings if using proxy authentication
- Test with a single account first before adding multiple accounts

## ⚖️ Disclaimer

**USE AT YOUR OWN RISK**: This script automates interactions with Microsoft Rewards. Your account may be at risk of suspension or termination. The developers assume no responsibility for any consequences resulting from the use of this software.

This project is intended for educational and personal use only. Users are responsible for complying with Microsoft's Terms of Service and any applicable laws or regulations.

## 📄 License

This project is licensed under the ISC License. See the LICENSE file for details.

---

**Made with ❤️ for the Microsoft Rewards community**
