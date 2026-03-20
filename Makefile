.PHONY: sync check-sync test diff

# Sync templates/phases/ into skills/*/template.md
# Run this after editing any file in templates/phases/
sync:
	cp templates/phases/01-research.md skills/research/template.md
	cp templates/phases/02-specification.md skills/spec/template.md
	cp templates/phases/03-task-breakdown.md skills/plan/template.md
	cp templates/phases/04-execution.md skills/execute/template.md
	cp templates/phases/05-verification.md skills/verify/template.md
	@echo "Synced templates → skills"

# Verify skill templates match source templates
check-sync:
	@PASS=true; \
	diff -q templates/phases/01-research.md skills/research/template.md || PASS=false; \
	diff -q templates/phases/02-specification.md skills/spec/template.md || PASS=false; \
	diff -q templates/phases/03-task-breakdown.md skills/plan/template.md || PASS=false; \
	diff -q templates/phases/04-execution.md skills/execute/template.md || PASS=false; \
	diff -q templates/phases/05-verification.md skills/verify/template.md || PASS=false; \
	if $$PASS; then echo "All templates in sync"; else echo "DRIFT DETECTED — run 'make sync'"; exit 1; fi

# Run the test suite
test:
	bash tests/test.sh

# Show which templates are out of sync
diff:
	@diff templates/phases/01-research.md skills/research/template.md || true
	@diff templates/phases/02-specification.md skills/spec/template.md || true
	@diff templates/phases/03-task-breakdown.md skills/plan/template.md || true
	@diff templates/phases/04-execution.md skills/execute/template.md || true
	@diff templates/phases/05-verification.md skills/verify/template.md || true
