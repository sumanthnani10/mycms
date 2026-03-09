## mycms

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![GitHub Pages](https://img.shields.io/badge/GitHub%20Pages-222222?style=for-the-badge&logo=GitHub%20Pages&logoColor=white)

### Overview

`mycms` is a lightweight, internal CMS-style admin panel built with Flutter and Flutter Web.
It provides a simple UI for managing application data (such as users, tracks, announcements,
payments, passes, etc.) backed by a custom HTTPS API.

The project is designed to be:

- **Private and secure**: Sensitive values (PIN, backend password, domains) are loaded from
  environment variables and never committed to the repository.
- **Web-first**: Built and deployed as a Flutter web app to GitHub Pages via GitHub Actions.
- **Simple to extend**: Collections and API endpoints are configured in code and can be
  adapted to other backends if needed.

---

### Features

- **PIN‑protected access** to the CMS UI.
- **Collection browser** for entities like users, tracks, tweets, announcements, payments,
  and passes.
- **Backend integration** via `https` POST calls to a configurable domain and path.
- **Reusable UI utilities** (navigation animations, dialogs, date formatting, ID generation).
- **Automated web build & deploy** using GitHub Actions and GitHub Pages.

---

### Tech Stack

- **Framework**: Flutter (Dart)
- **Targets**: Web (primary), Android/iOS build configs present
- **HTTP client**: `package:http`
- **State/UI**: Vanilla Flutter `StatefulWidget`s and `ThemeData`
- **CI/CD**: GitHub Actions → GitHub Pages

---

### Project Structure (high level)

- `lib/main.dart` – App entrypoint and theme bootstrap.
- `lib/pages/home_page.dart` – PIN gate and app launcher.
- `lib/pages/collections_page.dart` – Collection browser UI and data loading.
- `lib/utils/apps.dart` – Application metadata, collections, and API endpoint configuration.
- `lib/utils/utils.dart` – HTTP helpers, dialogs, ID generation, formatting.
- `lib/utils/theme.dart` – Light/dark theme definitions.
- `lib/objects/app.dart` – `App` model (server config, collections, API paths).
- `.github/workflows/deploy-pages.yml` – CI workflow to build and deploy Flutter web.
- `.env.example` – Template for local/CI environment configuration.

---

### Prerequisites

- Flutter SDK (stable channel) installed locally.
- Dart SDK (included with Flutter).
- Git (for version control).
- A GitHub repository (e.g. `sumanthnani10/mycms`) with:
  - **GitHub Pages** enabled with source **GitHub Actions**.
  - Required **repository secrets** configured (see below).

---

### Environment Configuration

Sensitive values are loaded at runtime from a `.env` file using `flutter_dotenv`.
The `.env` file is **not** committed to git; instead, a template is provided.

- **Template**: `.env.example`
- **Real file (local only)**: `.env` (in project root, in `.gitignore`)

Variables:

- `APP_PIN` – PIN required on the login dialog.
- `API_PASSWORD` – Backend `passd` value sent with each POST.
- `SERVER_DOMAIN` – Backend host (e.g. `tictrac.confegure.com`).
- `SERVER_TYPE` – Optional; protocol (defaults to `https`).
- `SERVER_PATH` – Optional; base path for API routes (defaults to empty).

#### Local setup

1. Copy the template:
   ```bash
   cp .env.example .env
   ```
   (On Windows PowerShell: `Copy-Item .env.example .env`)

2. Edit `.env` and fill in real values for your environment.

3. Confirm `.env` is **not** tracked:
   ```bash
   git status
   ```
   You should not see `.env` in the list of changes.

---

### Running Locally

From the project root:

```bash
flutter pub get
flutter run -d chrome
```

This will:

- Load `.env` at startup in `main.dart`.
- Require `APP_PIN` to access the main CMS screen.
- Use `SERVER_*` and `API_PASSWORD` for all API calls.

You can also build a local web release:

```bash
flutter build web --base-href "/mycms/"
```

For a different hosting path, adjust the `--base-href` accordingly.

---

### GitHub Actions & GitHub Pages

The project includes a workflow at `.github/workflows/deploy-pages.yml` which:

- Runs on pushes to `master` or `main`, or via manual dispatch.
- Checks out the repo, sets up Flutter (stable), and runs:
  - `flutter pub get`
  - `flutter build web --base-href "/mycms/"`
- Creates a `.env` file in CI from GitHub **repository secrets**.
- Uploads `build/web` as a GitHub Pages artifact.
- Deploys to GitHub Pages using `actions/deploy-pages`.

#### Required repository secrets

In GitHub:

- Go to `Settings → Secrets and variables → Actions → New repository secret`.
- Add:
  - `APP_PIN`
  - `API_PASSWORD`
  - `SERVER_DOMAIN`
  - (Optional) `SERVER_TYPE` – defaults to `https` if not set.
  - (Optional) `SERVER_PATH` – defaults to empty if not set.

The workflow writes these into `.env` at build time; the file is never committed.

#### Deployment URL

For a repo named `mycms` under the user `sumanthnani10`, the default URL is:

`https://sumanthnani10.github.io/mycms/`

If you change the repo name or host on a different path, update:

- The `--base-href` flag in `.github/workflows/deploy-pages.yml`.

---

### Security Notes

- No secrets (PIN, passwords, domains) are hardcoded into source files.
- `.env` is listed in `.gitignore` and must never be committed.
- For stronger security, consider:
  - Replacing the shared `API_PASSWORD` with per-user authentication tokens.
  - Moving authorization entirely to the backend (so the client only holds opaque tokens).

---

### Contributing / Extending

- **Collections & APIs** – Extend `lib/utils/apps.dart` and `lib/objects/app.dart` to add
  more collections, API endpoints, or additional applications.
- **Styling** – Adjust `lib/utils/theme.dart` to customize colors, typography, and layout.
- **Deployment** – See `GIT_AND_PAGES_SETUP.md` for details on repository structure and
  Pages configuration.

For any substantial changes, ensure:

- Local builds (`flutter run` and `flutter build web`) pass.
- Secrets are **never** added to source control or example files.

