# Moving Git to Root and Deploying with GitHub Actions

This guide covers moving your Git repo from `build/web` to the project root and using GitHub Actions to build the web app with secrets and deploy to GitHub Pages.

---

## Part 1: Move Git to project root

You currently have a repo **inside** `build/web`. We want one repo at **mycms** root with the full project, and let Actions produce the web build.

### Option A: Fresh start (recommended if you can force-push or don’t need to keep build/web history)

1. **Back up your current remote URL** (you already have it):
   ```
   https://github.com/sumanthnani10/mycms.git
   ```

2. **Remove the nested Git repo** (from your machine, in the `mycms` folder):
   ```powershell
   cd d:\StudioProjects\mycms
   Remove-Item -Recurse -Force build\web\.git
   ```

3. **Initialize Git at the project root** (if there is no `.git` here yet):
   ```powershell
   git init
   git remote add origin https://github.com/sumanthnani10/mycms.git
   ```

4. **Add, commit, and push the full project** (not just `build/web`):
   ```powershell
   git add .
   git status   # confirm: .env is NOT listed (it’s in .gitignore)
   git commit -m "Move repo to root; add Actions workflow for Pages"
   git branch -M master
   git push -u origin master --force
   ```
   Use `--force` only if the remote currently has only the old `build/web` content and you’re okay replacing it with the full project. Otherwise push to a new branch first and fix default branch in GitHub if needed.

### Option B: Keep existing repo and add project files

If the remote already has other content or you want to avoid force-push:

1. Clone the repo into a new folder and cd into it.
2. Remove the nested `build/web/.git` from your **original** mycms folder (as in Option A step 2).
3. Copy all project files from your original mycms into the cloned repo (so the clone has lib, pubspec.yaml, .github, .env.example, etc.), **except** don’t copy `build/web/.git`.
4. In the clone: add, commit, push. Your repo will then be at root with the full project; `build/` is in `.gitignore` so it won’t be committed.

---

## Part 2: GitHub repository secrets

The workflow builds the app with values from **Actions secrets**, not from a committed `.env` file.

1. Open the repo: **https://github.com/sumanthnani10/mycms**
2. Go to **Settings → Secrets and variables → Actions**
3. Click **New repository secret** and add:

| Secret name     | Required | Description                          |
|-----------------|----------|--------------------------------------|
| `APP_PIN`       | Yes      | Unlock PIN for the app               |
| `API_PASSWORD`  | Yes      | API `passd` value for your backend   |
| `SERVER_DOMAIN` | Yes     | Backend host (e.g. `tictrac.confegure.com`) |
| `SERVER_TYPE`   | No       | Default `https` if not set           |
| `SERVER_PATH`   | No       | Default empty if not set             |

Use the same values you have in your local `.env`.

---

## Part 3: Enable GitHub Pages (Actions)

1. In the repo: **Settings → Pages**
2. Under **Build and deployment**:
   - **Source:** choose **GitHub Actions**.

After the first successful run of **“Build and deploy to GitHub Pages”**, the site will be at:

- **Project site:** `https://sumanthnani10.github.io/mycms/`

The workflow uses `--base-href "/mycms/"` so the app loads correctly at that path. If you use a **user/org site** (e.g. `username.github.io`) instead, change the workflow to `flutter build web` with no `--base-href` and deploy from the same repo if needed.

---

## Part 4: What the workflow does

- **Triggers:** Push to `master` or `main`, or manual **Run workflow**.
- **Build job:** Checkout → create `.env` from secrets → `flutter pub get` → `flutter build web --base-href "/mycms/"` → upload `build/web` as the Pages artifact.
- **Deploy job:** Deploys that artifact to GitHub Pages.

So: Git is at the repo root, all source is in the repo, and the web app is built in CI with secrets and published to GitHub Pages. You no longer need to build locally and push `build/web`.
