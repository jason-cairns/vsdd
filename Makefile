.PHONY: validate

SKILLS := \
	skills/vsdd \
	skills/vsdd-spec-gen \
	skills/vsdd-spec-to-tests \
	skills/vsdd-tests-to-tasks \
	skills/vsdd-implement-tasks \
	skills/vsdd-soundness-review

validate:
	@command -v yq >/dev/null || { echo "VSDD requires yq. On macOS install it with: brew install yq"; exit 1; }
	@set -e; for skill in $(SKILLS); do \
		file="$$skill/SKILL.md"; \
		name="$${skill##*/}"; \
		frontmatter="$${TMPDIR:-/tmp}/vsdd-frontmatter-$$$$.yaml"; \
		test -f "$$file" || { echo "Missing $$file"; exit 1; }; \
		awk 'NR == 1 && $$0 != "---" { exit 2 } NR > 1 && $$0 == "---" { exit } NR > 1 { print }' "$$file" > "$$frontmatter"; \
		actual_name="$$(yq -r '.name // ""' "$$frontmatter")"; \
		description="$$(yq -r '.description // ""' "$$frontmatter")"; \
		keys="$$(yq -r 'keys | sort | join(",")' "$$frontmatter")"; \
		rm -f "$$frontmatter"; \
		test "$$actual_name" = "$$name" || { echo "$$file: name must be $$name, got $$actual_name"; exit 1; }; \
		test -n "$$description" || { echo "$$file: description is required"; exit 1; }; \
		test "$$keys" = "description,name" || { echo "$$file: frontmatter must contain only name and description"; exit 1; }; \
		test -f "$$skill/agents/openai.yaml" || { echo "$$skill: missing agents/openai.yaml"; exit 1; }; \
		yq -e '.interface.display_name and .interface.short_description and .interface.default_prompt' "$$skill/agents/openai.yaml" >/dev/null; \
	done
	@test -z "$$(find skills -maxdepth 2 -type f \( -name 'README.md' -o -name 'CHANGELOG.md' -o -name 'INSTALLATION*' -o -name 'QUICK_REFERENCE.md' \) -print)" || { echo "Unexpected auxiliary docs under skills/"; exit 1; }
	bash scripts/select_ready_claims.sh references/artifacts/SPEC.example.yaml 10 >/dev/null
	bash scripts/select_ready_tests.sh references/artifacts/SPEC.example.yaml references/artifacts/TEST_PLAN.example.yaml CLAIM-001 10 >/dev/null
	bash scripts/select_ready_tasks.sh references/artifacts/TEST_PLAN.example.yaml references/artifacts/TASKS.example.yaml TEST-001 10 >/dev/null
	bash scripts/trace_last_completed_task.sh references/artifacts/SPEC.example.yaml references/artifacts/TEST_PLAN.example.yaml >/dev/null
	git diff --check
