# The MacBook is exempt from pull-based deployment

Always-on machines (the NAS, the Mac Studio and later the agent host) pull `main` after CI has built them. The MacBook does not: its user activates any branch directly. Waiting for CI made every small change slow, and the person at the keyboard is already the review. This replaces the part of the agent platform's ADR 0002 that has every machine pull approved `main`.

## Consequences

The MacBook can run configuration that was never merged, so drift has to be reported instead of prevented. Agents still build and never activate. CI builds the MacBook for information only, while builds of the pulling hosts are required.
