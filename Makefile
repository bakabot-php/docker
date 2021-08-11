build:
	bash build.sh

push: build
	docker push "bakabot/php:latest"
	docker push "bakabot/php-dev:latest"
	git commit -am "Rebuild"
	git push origin main
