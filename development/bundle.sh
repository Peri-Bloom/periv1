cd ..

function render() {
    docker run --rm -u 1000 -v "$(pwd):/spec" redocly/cli bundle specifications/"$1".openapi.yaml -o computable/OAS/"$1".openapi.json
    echo "Creating json files..."
    cd development
    docker-compose run --rm php /opt/project/bin/generate_all computable/OAS/"$1".openapi.json
    cd ..
    docker run --rm -u 1000 -v "$(pwd):/spec" redocly/cli bundle computable/OAS/"$1"-codegen.openapi.json --remove-unused-components -o computable/OAS/"$1"-codegen.openapi.yaml
    docker run --rm -u 1000 -v "$(pwd):/spec" redocly/cli bundle computable/OAS/"$1"-validation.openapi.json -o computable/OAS/"$1"-validation.openapi.yaml
    echo "Generating HTML file..."
    docker run --rm --env NODE_OPTIONS="--max-old-space-size=4048" -u 1000 -v "$(pwd):/spec" redocly/cli build-docs computable/OAS/"$1"-html.openapi.json --cdn -o docs/"$1".html -t development/redoc-template.html --templateOptions.page_"$1"
    echo "Removing json files..."
    rm -rfv computable/OAS/*.json
}


case "${1:-}" in
		overview|ehr|query|definition)
		  render "$@"
      ;;
		all)
		  render overview
		  render ehr
		  render query
		  render definition
      ;;
		"")
			echo "Usage: bundle.sh [overview|ehr|query|definition]"
			echo "   or: bundle.sh all"
			;;
	esac
