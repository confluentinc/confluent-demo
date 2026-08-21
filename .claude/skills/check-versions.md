---
name: check-versions
description: Check for available version updates for all Confluent and infrastructure components
globs: [".env", "CLAUDE.md"]
---

# Version Update Checker

This skill checks all component versions in `.env` against the latest available releases and reports what updates are available.

## Instructions

1. **Read current versions** from `.env` file to get baseline

2. **Query latest versions** from official sources:

   **Helm Charts (use Bash tool):**
   ```bash
   helm repo update confluentinc 2>/dev/null
   helm search repo confluentinc/confluent-for-kubernetes --versions | head -3
   helm search repo confluentinc/confluent-manager-for-apache-flink --versions | head -3
   helm search repo confluentinc/flink-kubernetes-operator --versions | head -3
   ```

   **Docker Hub Images (use WebFetch tool):**
   - CP Server: `https://hub.docker.com/r/confluentinc/cp-server/tags` (extract latest tag)
   - Schema Registry: `https://hub.docker.com/r/confluentinc/cp-schema-registry/tags` (extract latest tag)
   - Control Center: `https://hub.docker.com/r/confluentinc/cp-enterprise-control-center-next-gen/tags` (extract latest tag)
   - CP Flink: `https://hub.docker.com/r/confluentinc/cp-flink/tags` (look for latest with -cp*-java21 pattern)
   - CP Flink SQL: `https://hub.docker.com/r/confluentinc/cp-flink-sql/tags` (extract latest 1.19-cp* tag)

   **Other Sources:**
   - Envoy Gateway: `https://gateway.envoyproxy.io/docs/install/install-helm/` (check version in docs)
   - Vault Helm: `https://github.com/hashicorp/vault-helm/releases` (get latest release)

3. **Compare versions** and categorize:
   - Patch updates (x.y.Z changes)
   - Minor updates (x.Y.z changes)
   - Major updates (X.y.z changes)
   - Already latest
   - Intentionally pinned (check CLAUDE.md for constraints)

4. **Check version constraints** documented in CLAUDE.md:
   - Schema Registry is pinned to 7.9.6 due to DEK Registry RBAC constraints
   - CP_FLINK_MAJOR_VERSION must match CP_FLINK_TAG
   - CP_FLINK_SQL_MAJOR_VERSION must match CP_FLINK_SQL_TAG
   - Control Center version must have matching Prometheus/AlertManager images

5. **Generate report** with this structure:

   ```markdown
   # Version Update Check - [DATE]

   ## Components with Updates Available
   
   | Component | Current | Latest | Type | Notes |
   |-----------|---------|--------|------|-------|
   | ... | ... | ... | Patch/Minor/Major | ... |

   ## Components Already at Latest
   - Component: version ✓

   ## Components Intentionally Pinned
   - Component: version (reason)

   ## Verification Commands
   
   For each update, provide docker manifest inspect or helm search commands to verify
   
   ## Recommended Actions
   
   List which updates are safe to apply immediately vs. need investigation
   ```

6. **Provide update commands** if any updates are found:
   - Show exact .env edits needed
   - Note any CLAUDE.md updates required
   - Flag any that need testing or investigation

## Output Format

- Use tables for comparison data
- Use ✅ for already latest
- Use ⚠️ for pinned versions with constraints
- Use 🔄 for available updates
- Keep report concise but actionable
- Include dates on version checks (versions change over time)

## Notes

- Run helm repo update before checking Helm charts
- Docker Hub tags are sorted by push date, not semantic version
- Some components (like FKO) use the Confluent Helm repo, not upstream Apache
- Always respect version constraints documented in CLAUDE.md
- Flink version tags can have unusual patterns (cp1, cp2, etc.) - report these for investigation
