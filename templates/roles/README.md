# Role Registry

Role definitions for use with the AI-Assisted Software Development Workflow. Each role is a prompt snippet that gets composed with a phase template to provide domain-specific expertise and constraints.

Adapted from [agency-agents](https://github.com/msitarzewski/agency-agents) with modifications for this workflow's phase structure.

## How to Use

1. Check the phase mapping below to identify which role(s) to use.
2. Open the role file from this directory.
3. Paste the role definition as a prefix to your phase prompt.
4. If composing multiple roles (multi-role review), run each role in a separate session.

## Phase-to-Role Mapping

### Phase 2: Specification

| Role | When to Engage |
|------|---------------|
| [Software Architect](software-architect.md) | Always (default) |
| [Security Reviewer](security-reviewer.md) | Auth, payments, PII, compliance requirements |
| [Domain Specialist](domain-specialist.md) | Complex business rules, industry-specific logic |
| [Product Reviewer](product-reviewer.md) | User-facing features, multiple user personas |

**Complexity triggers for multi-role review:**

- Compliance requirements (SOC2, HIPAA, PCI-DSS, etc.) → add Security Reviewer
- Complex business rules or industry-specific logic → add Domain Specialist
- User-facing features with multiple personas → add Product Reviewer
- Multiple integration points (>3 external systems) → add Security Reviewer + Domain Specialist
- Team size > 3 → engage all roles

### Phase 3: Task Breakdown

| Role | Focus |
|------|-------|
| [Software Architect](software-architect.md) | Decomposition feasibility, dependency ordering |
| [Senior Engineer](senior-engineer.md) | Task scope realism, hidden complexity identification |
| [Senior PM](senior-pm.md) | Priority, risk, milestone sequencing |

### Phase 4: Execution (matched to task type)

| Task Type | Role |
|-----------|------|
| Frontend component, UI | [Frontend Developer](frontend-developer.md) |
| API endpoint, service logic | [Backend Engineer](backend-engineer.md) |
| Database migration, data pipeline | [Data Engineer](data-engineer.md) |
| Infrastructure, CI/CD, deployment | [DevOps Engineer](devops-engineer.md) |
| Test implementation | [QA Engineer](qa-engineer.md) |
| Security-sensitive implementation | [Security Engineer](security-engineer.md) |

### Phase 5: Verification

| Role | Focus |
|------|-------|
| [Code Reviewer](code-reviewer.md) | Code quality, patterns, maintainability across the milestone |
| [QA Engineer](qa-engineer.md) | Test coverage gaps, untested edge cases |

## Role File Structure

Each role file follows this consistent structure:

```
# Role: {Name}

## Identity
{Who this role is and what they specialize in}

## When to Use
{Phases and task types where this role applies}

## Priorities (in order)
{Ordered list of what this role cares about most}

## Methodology
{How this role approaches work}

## Anti-patterns (do NOT)
{What this role explicitly avoids}
```

## Installing Additional Roles

For roles beyond this core set, see [agency-agents](https://github.com/msitarzewski/agency-agents):

```bash
# Clone the repo
git clone https://github.com/msitarzewski/agency-agents.git /tmp/agency-agents

# Browse available roles
ls /tmp/agency-agents/engineering/
ls /tmp/agency-agents/testing/
ls /tmp/agency-agents/project-management/

# Copy a role to your project
cp /tmp/agency-agents/engineering/engineering-senior-developer.md templates/roles/

# Adapt the role file to match the structure above
```

Available agency-agents divisions: engineering (23 agents), design (8), testing (8), project-management (6), product (4), and more. See their repo for the full catalog.
