# ADR 0003: Copy-first template layering

## Status
Accepted

## Context
CNA uses EJS/`package.js`; CPA is largely copy-first. V scaffolding should stay simple and deterministic.

## Decision
Merge template/addon layers by filesystem copy (with optional reflink/hardlink). Merge `v.mod` via dedicated helpers. No EJS/Jinja in the core scaffolder.

## Consequences
Complex transforms belong in template-authored scripts, not the CLI runtime.
