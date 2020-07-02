build:
	swift build
test:
	swift test 2>&1 | bundle exec xcpretty
cleandocs:
	rm -fr docs
docs: cleandocs
	bundle exec jazzy \
		--module Validations \
		--swift-build-tool spm \
		--theme fullwidth
