install-dependencies:
	gem install xcpretty
test:
	swift test 2>&1 | xcpretty
