install-dependencies:
	gem install xcpretty
build:
	swift build
test:
	swift test 2>&1 | xcpretty
