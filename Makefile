.DEFAULT_GOAL=help
.PHONY: validate build clean
CLI=openapi-generator-cli.jar
SPEC=openapi.yaml
PGM=java -jar $(CLI)

validate: $(CLI) ## validate the openapi.yaml file
	$(PGM) validate -i $(SPEC)

clients/go: $(CLI) ## Generate the golang SDK client
	$(PGM) generate -i $(SPEC) -g $(shell basename $@) -o $@ \
	--global-property='skipFormModel=false' \
	--additional-properties='packageName=streamlabs' \
	--git-user-id='mcdostone' \
	--git-repo-id='go-streamlabs' \
	--git-host='github.com' \
	--enable-post-process-file

$(CLI): ## Download openapi-generator-cli JAR file
	wget https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/5.1.0/openapi-generator-cli-5.1.0.jar -O $@
	
clean: ## Remove the jar CLI 
	rm -rf clients

help: ## Show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

lint: ## Lint the file
	docker run --rm -it -v $$PWD/$(SPEC):/tmp/file.yaml wework/speccy lint /tmp/file.yaml
	docker run --rm -it -v $$PWD/$(SPEC):/tmp/file.yaml stoplight/spectral lint /tmp/file.yaml