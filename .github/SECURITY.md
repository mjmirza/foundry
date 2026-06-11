# Security policy

## Reporting a vulnerability

Please report a security issue privately. Open a GitHub Security Advisory on this repository through the Security tab, Report a vulnerability, or contact the maintainer through the repository profile. Do not open a public issue for a vulnerability.

## Scope

Foundry ships shell tooling and skill content. The tooling includes an installer that touches a user's files, a doctor, four linters, and an eval harness. Relevant concerns include the installer writing or moving a file it should not, a linter returning a wrong result that a user trusts, or guidance that could lead a user to build insecure tooling.

## What is not a vulnerability

The linters are teaching tools, not a security scanner. A missed secret pattern in check-mcp, or the hook linter flagging its own source because it contains the patterns it searches for, are known limits and not security issues.

## Supported versions

The latest release on the main branch is supported. Older tags are not patched.

## Handling

A report is acknowledged, triaged, and fixed on a private branch, then released with credit to the reporter unless they prefer otherwise.
