xcodebuild -workspace Example.xcworkspace -scheme Example -destination=build -configuration Debug -sdk iphonesimulator7.0 ONLY_ACTIVE_ARCH=YES test | xcpretty $1 $2 $3
