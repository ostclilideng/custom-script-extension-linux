BINDIR=bin
BIN=custom-script-extension
BUNDLEDIR=bundle
BUNDLE=custom-script-extension.zip

bundle: clean binary
	@mkdir -p $(BUNDLEDIR)
	zip ./$(BUNDLEDIR)/$(BUNDLE) ./$(BINDIR)/Linux/$(BIN)
	zip ./$(BUNDLEDIR)/$(BUNDLE) ./$(BINDIR)/FreeBSD/$(BIN)
	zip ./$(BUNDLEDIR)/$(BUNDLE) ./$(BINDIR)/custom-script-shim
	zip -j ./$(BUNDLEDIR)/$(BUNDLE) ./misc/HandlerManifest.json
	zip -j ./$(BUNDLEDIR)/$(BUNDLE) ./misc/manifest.xml

binary: clean
	if [ -z "$$GOPATH" ]; then \
	  echo "GOPATH is not set"; \
	  exit 1; \
	fi
	GOOS=linux GOARCH=amd64 govvv build -v \
	  -ldflags "-X main.Version=`grep -E -m 1 -o  '<Version>(.*)</Version>' misc/manifest.xml | awk -F">" '{print $$2}' | awk -F"<" '{print $$1}'`" \
	  -o $(BINDIR)/Linux/$(BIN) ./main 
	GOOS=freebsd GOARCH=amd64 govvv build -v \
	  -ldflags "-X main.Version=`grep -E -m 1 -o  '<Version>(.*)</Version>' misc/manifest.xml | awk -F">" '{print $$2}' | awk -F"<" '{print $$1}'`" \
	  -o $(BINDIR)/FreeBSD/$(BIN) ./main 
	cp ./misc/custom-script-shim ./$(BINDIR)
clean:
	rm -rf "$(BINDIR)" "$(BUNDLEDIR)"

.PHONY: clean binary
