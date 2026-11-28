# New releases wait seven days

Nothing is installed until it has been public for seven days: flake inputs, npm, PyPI and Bun packages, and container images. Most malicious releases are noticed within days, while security fixes still arrive weekly without manual work. Lock updates that are old enough merge by themselves once builds pass.

Exempt tools are named explicitly; today they are Claude Code and t3-code, which release daily and are wanted daily, and Cloudflare's `cf` CLI, which is in active pre-release development. On the MacBook, `rig update` installs `cf` from npm at its latest release, declared in the workstation profile. A person can always skip the cooldown for one update.

## Considered options

- **Daily updates with auto-merge:** the fastest fixes, with no protection against a release that is pulled a day later.
- **A person merges every update:** tried, and updates only happened when someone remembered.

## Consequences

An urgent security fix needs a deliberate override. Not every path can enforce the age: Homebrew casks that update themselves do not have one, Dockhand counts from the image's build date, and Git deployments of container stacks bypass it.
