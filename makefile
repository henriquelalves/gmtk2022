.PHONY: deploy
deploy:
	mkdir -p ./build/
	godot --export "HTML5" ./build/build.html
	mv ./build/build.html ./build/index.html
	zip -r -j build.zip ./build/*
	butler push ./build.zip perons/gmtk2022:html5
	rm -rf ./build/
	rm ./build.zip
