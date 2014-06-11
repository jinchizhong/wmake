all: build

build: 
	gem build *.gemspec

clean:
	rm -rfv *.gem

install: build
	sudo gem install ./*.gem

uninstall:
	sudo gem uninstall $$(cat *.gemspec | sed -n "/name/ s/.*'\(.*\)'.*/\1/p")

rununit:
	PATH="$$PWD/bin:$$PATH" RUBYLIB="$$PWD/lib" ruby test/run_all_test.rb
