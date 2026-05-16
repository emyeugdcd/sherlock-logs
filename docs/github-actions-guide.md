# How to Test GitHub Actions (A Guide for Students & Professionals)

So you’ve built a CI/CD pipeline using GitHub Actions! That’s a massive step toward becoming a proper DevOps engineer. But how do you actually know if it works? How do you test it without breaking the main branch of your repository? 

This guide will teach you the professional workflow for testing GitHub Actions, both in this project and in real life.
---

## The Golden Rule: Never Test on `main`
In a professional environment, pushing broken code directly to the `main` branch to "see if the CI pipeline works" is a huge red flag. 

Instead, the workflow is always:
1. Create a new branch.
2. Make a deliberate change (a "test case").
3. Push the branch to GitHub.
4. Watch the Actions tab to see if the pipeline behaves as expected.
5. Fix any pipeline bugs on that branch until it goes green.

---

## 🛑 Scenario 1: Proving the CI Pipeline Catches Bad Code
A CI pipeline is a **Quality Gate**. Its primary job is to *fail* when a developer writes bad code. If your CI pipeline always passes, it’s useless!

### How to test this in `sherlock-logs`:
1. **Create a new branch:**
   ```bash
   git checkout -b test-broken-ci
   ```
2. **Break the Go code:**
   Open `backend/main.go` and add a deliberate syntax error. For example, delete a closing bracket `}` at the end of a function, or misspell a variable.
3. **Commit and Push:**
   ```bash
   git add backend/main.go
   git commit -m "chore: deliberate syntax error to test CI"
   git push origin test-broken-ci
   ```
4. **Observe the Results:**
   - Go to the **Actions** tab in your GitHub repository.
   - Click on the pipeline run for your `test-broken-ci` branch.
   - You should see the `Run Go Unit Tests` step **FAIL (Red)**. 
   - Expand the logs for that step, and you will see the exact Go compiler error explaining what you broke.
   
*Congratulations! You just proved that your pipeline successfully protects the `main` branch from broken code.*

---

## ✅ Scenario 2: Proving the CI Pipeline Runs Real Tests
We just replaced the "mocked" echo test with a real unit test (`main_test.go`) that hits the `/health` endpoint and expects `{"status":"ok"}`. Let's prove that the test is actually executing!

### How to test this in `sherlock-logs`:
1. **Fix the syntax error:**
   Fix whatever you broke in Scenario 1.
2. **Break the Business Logic:**
   Open `backend/main.go` and go to the `healthHandler` function. Change the JSON output from `{"status":"ok"}` to `{"status":"broken"}`.
3. **Commit and Push:**
   ```bash
   git add backend/main.go
   git commit -m "test: deliberately break healthcheck logic"
   git push origin test-broken-ci
   ```
4. **Observe the Results:**
   - Go to the **Actions** tab.
   - This time, the code will compile perfectly! (Static Analysis passes).
   - However, the `Run Go Unit Tests` step will **FAIL**!
   - If you look at the logs, you will see `main_test.go` complaining: `handler returned unexpected body: got {"status":"broken"} want {"status":"ok"}`.

*You have just proven that your automated tests are successfully validating business logic in the cloud!*

---

## 🚀 Scenario 3: Testing Deployment Workflow (Local vs Real Life)
In a real-world enterprise environment, the `deploy` step in GitHub Actions will SSH into your production servers and deploy the code automatically. 

### In Real Life:
To test the deployment phase in real life, you use a **Staging Environment**. 
You would configure your GitHub Action to deploy to `staging.yourcompany.com` whenever a Pull Request is opened. You verify the deployment there. Only when the code is merged to `main` does the Action deploy to `production.yourcompany.com`.

### In Our Vagrant Project:
Because GitHub's cloud servers cannot reach your local Mac's private VirtualBox IP addresses (`192.168.56.x`), our `deploy.yml` simulates the deployment phase using `echo` statements for educational purposes. 

To actually deploy your code locally after writing it, you use the deployment script:
```bash
./deploy_apps.sh
```
This script acts exactly like the GitHub Action would in real life—it SSHs into the VMs, builds the Docker images, runs health checks, and rolls back if anything fails!

---

## Summary Checklist for Students
Whenever you build a new CI/CD pipeline, ask yourself:
- [ ] Did I remove all `echo "Simulating..."` steps and replace them with actual test commands?
- [ ] Did I intentionally break the code and verify that the pipeline fails?
- [ ] Did I intentionally break a unit test and verify that the pipeline fails?
- [ ] Did I push perfect code and verify that the pipeline turns green?

If you can check all four boxes, you have built a professional-grade CI pipeline!
