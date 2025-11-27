# Add SSH Keys to GitHub Secrets

You need to add TWO SSH secrets to GitHub for the CI/CD pipeline to work:

## 1. SSH_PUBLIC_KEY (Already added? ✓)

This is used by Terraform to create the key pair in AWS.

```bash
# Get your public key
cat ~/.ssh/id_rsa.pub
# Copy the output (starts with ssh-rsa AAAAB3...)
```

## 2. SSH_PRIVATE_KEY (⚠️ MISSING - Add this!)

This is used by Ansible to connect to the server from GitHub Actions.

```bash
# Get your PRIVATE key
cat ~/.ssh/id_rsa
# Copy the ENTIRE output including:
# -----BEGIN OPENSSH PRIVATE KEY-----
# ... all the lines ...
# -----END OPENSSH PRIVATE KEY-----
```

## Steps to Add Secrets:

1. **Go to Repository Settings:**
   ```
   https://github.com/DestinyObs/DevOps-Stage-6/settings/secrets/actions
   ```

2. **Click "New repository secret"**

3. **Add SSH_PRIVATE_KEY:**
   - Name: `SSH_PRIVATE_KEY`
   - Value: Paste the ENTIRE private key including header/footer
   - Click "Add secret"

4. **Verify SSH_PUBLIC_KEY exists:**
   - Should already be there from earlier
   - If not, add it with the public key content

## ⚠️ Security Warning:

- NEVER commit private keys to git
- NEVER share private keys
- These secrets are encrypted by GitHub
- Only the GitHub Actions runner can access them

## After Adding:

1. Commit any pending changes
2. Push to trigger the workflow
3. Pipeline will now be able to SSH into the server
4. Ansible provisioning will work!

---

**Current Issue:** The workflow is failing because `${{ secrets.SSH_PRIVATE_KEY }}` doesn't exist, so the SSH key setup step creates an empty file.
