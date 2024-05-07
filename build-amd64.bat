set TAG=20240118
docker buildx build --no-cache --push --platform linux/amd64 --tag krzysztofkortas/devenv-trunk:latest-amd64 --tag krzysztofkortas/devenv-trunk:%TAG%-amd64 .