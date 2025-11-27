# Create Production Environment for Manual Approval

Your workflow is configured to require manual approval before deploying infrastructure changes. You need to create a "production" environment in GitHub.

## Steps to Create Environment:

1. **Go to your GitHub repository:**
   ```
   https://github.com/DestinyObs/DevOps-Stage-6
   ```

2. **Navigate to Settings:**
   - Click on **Settings** tab at the top
   - Scroll down to **Environments** in the left sidebar
   - Click **Environments**

3. **Create New Environment:**
   - Click **New environment** button
   - Name: `production`
   - Click **Configure environment**

4. **Add Protection Rules:**
   - ✅ Check **Required reviewers**
   - Add yourself as a reviewer (your GitHub username)
   - Click **Save protection rules**

5. **Optional Settings:**
   - You can also add deployment branch restrictions if needed
   - Set wait timer (e.g., wait 5 minutes before allowing approval)

## How It Works:

When changes are detected:
1. ✅ Terraform Plan runs successfully
2. 📧 Email sent with drift notification
3. ⏸️ Workflow pauses at "Wait for Manual Approval"
4. 👤 You review the plan and approve in GitHub UI
5. ✅ Terraform Apply runs after approval

## To Approve a Deployment:

1. Go to **Actions** tab in your repository
2. Click on the running workflow
3. You'll see "Review required" banner
4. Click **Review deployments**
5. Check **production**
6. Click **Approve and deploy**

---

**Note:** Without this environment configured, the workflow will skip the approval step and apply changes automatically when drift is detected!
