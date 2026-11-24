# Personal Machine Configuration

The language used to describe how Michiel's machines are rebuilt, kept current and kept clean from this repository.

## Language

### Lifecycle

**Bootstrap**:
Restoring a wiped or new machine's system settings, apps, CLI tools and dotfiles. Documents and project contents are not part of it.
_Avoid_: Install, provisioning, restore

**Fast path**:
Activating unmerged configuration on the machine you are sitting at.
_Avoid_: Local deploy, dev switch

**Gated path**:
Reaching a machine only through `main`, after CI has passed. It applies to machines that deploy unattended.
_Avoid_: Production deploy, GitOps

### Software

**Cooldown**:
The minimum time a release must have been public before it may be installed.
_Avoid_: Pinning, delay, quarantine

**Exempt tool**:
Software named as allowed to skip the cooldown.
_Avoid_: Fast lane (too close to fast path), auto-updater

**Ephemeral tool**:
A tool run for the task at hand without being installed on the machine.
_Avoid_: Temporary package, one-off install

**Promotion**:
Adding a tool you keep reaching for to this repository, so that it becomes part of a machine.
_Avoid_: Installing, keeping

**Drift**:
Anything installed or configured on a machine that this repository does not account for.
_Avoid_: Mess, leftovers

### Dotfiles

**Generated dotfile**:
A configuration file produced from this repository that cannot be edited in place.
_Avoid_: Managed file, declared file

**Linked dotfile**:
A configuration file that lives in this repository and can be edited in place by you or by the app that uses it.
_Avoid_: Mutable file, symlinked config

**App state**:
Data an app accumulates through use, such as histories, caches and sessions. It is never a dotfile.
_Avoid_: App data, user data

### Agents

**Sandbox**:
An isolated work environment for one project and one privilege profile, kept away from your secrets, SSH agent and home directory.
_Avoid_: Execution cell, devshell, workspace

**Devshell**:
The set of tools available for one project. It gives no isolation.
_Avoid_: Sandbox, environment
