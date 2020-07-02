install-dependencies:
	gem install xcpretty jazzy
build:
	swift build
test:
	swift test 2>&1 | xcpretty
cleandocs:
	rm -fr docs
docs: cleandocs
	jazzy \
		--module Validations \
		--swift-build-tool spm \
