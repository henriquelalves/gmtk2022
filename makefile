.PHONY: deploy
deploy:
	mkdir -p ./build/
	godot --export "HTML5" ./build/build.html
	mv ./build/build.html ./build/index.html
	zip -r -j build.zip ./build/*
	butler push ./build.zip perons/dungeonsanddice:html5
	rm -rf ./build/
	rm ./build.zip

	mkdir -p ./build/
	godot --export "WindowsDesktop" ./build/DungeonsAndDice.exe
	zip -r -j build.zip ./build/*
	butler push ./build.zip perons/dungeonsanddice:windows
	rm -rf ./build/
	rm ./build.zip

	mkdir -p ./build/
	godot --export "LinuxX11" ./build/DungeonsAndDice
	zip -r -j build.zip ./build/*
	butler push ./build.zip perons/dungeonsanddice:linux
	rm -rf ./build/
	rm ./build.zip
