---
name: strategy
description: 'Coordinate multi-team delivery across discovery, strategy, build, QA, launch, and operations. Use this skill as the admin layer that orchestrates the team skills.'
---

# Strategy Team

Use this skill as the orchestration and administration layer for the team skills. Route the request to the right operating mode, runbook, playbook, and team combination.

## When to Use
- Use for work that spans multiple team skills or lifecycle phases.
- Use when sequencing, handoffs, quality gates, or escalation paths need explicit coordination.
- Use when the request is larger than any single team skill.

## Routing Logic
1. Start with [Quickstart](./references/QUICKSTART.md) to choose the operating mode.
2. Read [Core strategy](./references/nexus-strategy.md) for the full doctrine.
3. Use [Team skills](./references/skill-groups.md) to assemble the right team set.
4. Choose a scenario runbook when it matches the work:
   - [Startup MVP](./references/runbooks/scenario-startup-mvp.md)
   - [Enterprise feature](./references/runbooks/scenario-enterprise-feature.md)
   - [Marketing campaign](./references/runbooks/scenario-marketing-campaign.md)
   - [Incident response](./references/runbooks/scenario-incident-response.md)
5. Use the right phase playbook when running phase-by-phase:
   - [Phase 0 discovery](./references/playbooks/phase-0-discovery.md)
   - [Phase 1 strategy](./references/playbooks/phase-1-strategy.md)
   - [Phase 2 foundation](./references/playbooks/phase-2-foundation.md)
   - [Phase 3 build](./references/playbooks/phase-3-build.md)
   - [Phase 4 hardening](./references/playbooks/phase-4-hardening.md)
   - [Phase 5 launch](./references/playbooks/phase-5-launch.md)
   - [Phase 6 operate](./references/playbooks/phase-6-operate.md)
6. Use [Activation prompts](./references/coordination/agent-activation-prompts.md) and [Handoff templates](./references/coordination/handoff-templates.md) to coordinate work.

## Procedure
1. Define the desired outcome, scope, constraints, stakeholders, and quality bars.
2. Select the right operating mode, runbook, or phase playbook.
3. Choose the smallest sufficient set of team skills.
4. Coordinate execution, evidence-based handoffs, and retries when a gate fails.
5. Re-plan whenever priorities, risk, or dependencies change.
