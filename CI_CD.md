# CI/CD Pipeline — Brainstorm

This document captures CI/CD principles and brainstorm topics for future detailed design. The specific pipeline implementation is per-project and belongs in each project's SPEC.md.

## Workflow Principles (captured in WORKFLOW.md)

1. **Every task must pass automated verification before human review.** Lint, type check, and tests must pass before the human sees a diff.
2. **Every merge must deploy to a verifiable environment.** Merged code must be deployable and verifiable in a real (or realistic) environment.

## Pipeline Stages (to design per-project)

### PR-Triggered (non-negotiable)

- Lint
- Type check
- Unit tests
- Build verification

### Test Environment

Options to evaluate:

- **Local (Docker Compose)** — simplest, no cloud cost
- **On-demand AWS infrastructure** (CDK/Terraform, spin up per PR, tear down after) — realistic but adds complexity and cost
- **Dedicated test environment** — persistent, good for integration testing but wasteful for small teams

### Merge to Main

- Full test suite (unit + integration)
- Build
- Deploy to staging environment

### Production Deployment

- Tag-based or merge to `production` branch
- Full test suite
- Blue-green deployment
- Health check verification
- Rollback plan

## Open Questions

- What's the right test environment strategy for different project sizes?
- How to handle database migrations in CI/CD (test env needs consistent state)?
- Cost analysis: on-demand infrastructure vs dedicated test env?
- Monitoring and alerting setup as part of the pipeline?
- Canary deployments vs blue-green for different risk profiles?
- How does the CI/CD pipeline interact with the worktree-per-task model in Phase 4?

## References

- See WORKFLOW.md for the development workflow context
- Per-project CI/CD design goes in `workflow/spec/SPEC.md` under "Deployment Architecture"
