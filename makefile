.PHONY: deploy
deploy:
	mkdir -p ./build/
	~/bin/Godot_v3.4.4-stable_linux_headless.64 --export "HTML5" ./build/build.html
	mv ./build/build.html ./build/index.html
	zip -r -j build.zip ./build/*
	~/bin/butler push ./build.zip perons/gmtk2022:html5
	rm -rf ./build/
	rm ./build.zip
