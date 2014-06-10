all: build

build: 
	gem build *.gemspec

clean:
	rm -rfv *.gem

install: build
	sudo gem install ./*.gem

uninstall:
	sudo gem uninstall $$(cat *.gemspec | sed -n "/name/ s/.*'\(.*\)'.*/\1/p")
