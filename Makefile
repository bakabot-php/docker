build:
	bash build.sh

push:
	docker push "bakabot/php:latest"
	docker push "bakabot/php-dev:latest"
