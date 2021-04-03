publish:
	-rmdir npm-prepublishOnlyLOCKED
	pnpm publish --access=public --no-git-checks

test-all: test

test:
	$(BROWSER) *.html

prettier:
	pnpm run lint:fix

depends:
	pnpm ls
	@echo ""
	pnpm run check

.PHONY: publish

.PHONY: test

.PHONY: test-all

.PHONY: prettier

.PHONY: depends
