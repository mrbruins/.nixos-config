## Requirements: Git Multi-Profile Setup (Nix Config)

### Goal
Configure a dual-account Git setup for a macOS developer using Nix config. Two accounts must coexist without manual switching:

| | Personal | Work |
|---|---|---|
| **Host** | `github.com` | `eneco-bv.ghe.com` |
| **Username** | `mrbruins` | `Michiel-Bruins` |
| **Email** | `michiel@m11s.nl` | `michiel.bruins@eneco.com` |
| **SSH Auth** | 1Password agent (already configured) | `~/.ssh/id_ed25519_eneco.pub` |

---

### 1. SSH Config

Merge the following into the existing SSH config (which already includes `/Users/michielbruins/.ssh/config_external` and a wildcard `Host *` block using the 1Password agent socket):

```
Host github.com
    HostName github.com
    User git
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    IdentitiesOnly yes

Host eneco-bv.ghe.com
    HostName eneco-bv.ghe.com
    User git
    IdentityFile ~/.ssh/id_ed25519_eneco
    IdentitiesOnly yes
```

**Constraints:**
- The wildcard `Host *` block must remain and come **after** explicit host blocks
- `AddKeysToAgent no` and `ForwardAgent no` must stay on the wildcard block
- Do not remove the `Include /Users/michielbruins/.ssh/config_external` directive

---

### 2. Git Config

**Global `~/.gitconfig`** must have these `includeIf` directives:

```ini
[includeIf "gitdir:~/dev/personal/"]
    path = ~/.config/git/config-personal

[includeIf "gitdir:~/dev/Eneco/"]
    path = ~/.config/git/config-work
```

**`~/.config/git/config-personal`:**

```ini
[user]
    name = mrbruins
    email = michiel@m11s.nl

[url "git@github.com:"]
    insteadOf = https://github.com/
```

**`~/.config/git/config-work`:**

```ini
[user]
    name = Michiel-Bruins
    email = michiel.bruins@eneco.com

[url "git@eneco-bv.ghe.com:"]
    insteadOf = https://eneco-bv.ghe.com/
```

The `url.insteadOf` rewrites ensure HTTPS clone URLs are transparently redirected to SSH, so both the GitHub web UI copy-paste and CLI work without thinking about it.

---

### 3. Verification Commands

The implementing agent should validate the setup produces this output:

```bash
# Personal identity
cd ~/dev/personal/some-repo
git config user.email  # → michiel@m11s.nl
git config user.name   # → mrbruins

# Work identity
cd ~/dev/Eneco/some-repo
git config user.email  # → michiel.bruins@eneco.com
git config user.name   # → Michiel-Bruins

# SSH connectivity
ssh -T git@github.com             # → "Hi mrbruins!"
ssh -T git@eneco-bv.ghe.com       # → "Hi Michiel-Bruins!"
```

---

### 4. Notes for the Implementing Agent

- The current repo `eneco-skill-agent-hub` lives in `~/dev/public/` which is outside both configured directories — it will have **no identity applied** until moved to `~/dev/personal/` or `~/dev/Eneco/`. Move it to the appropriate directory after setup.
- Do **not** set a global `[user]` block — identity must only come from the conditional includes.
- Do **not** configure `credential.helper` — SSH is used exclusively via `url.insteadOf`.
- The `id_ed25519_eneco` private key is already present on the machine at `~/.ssh/id_ed25519_eneco`.