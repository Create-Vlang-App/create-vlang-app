# ADR 0005: VPM-primary distribution

## Status
Accepted

## Context
Node uses npm; Python uses PyPI. V's package manager is VPM.

## Decision
Primary install path is `v install create-vlang-app`. GitHub Release binaries, Docker, AUR, and Homebrew are secondary.

## Consequences
Docs and smoke tests prioritize VPM; secondary channels may lag the first Release.
