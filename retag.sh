TAG=20240118

docker manifest create krzysztofkortas/devenv-trunk:latest --amend krzysztofkortas/devenv-trunk:latest-amd64
docker manifest annotate krzysztofkortas/devenv-trunk:latest krzysztofkortas/devenv-trunk:latest-amd64 --arch amd64
docker manifest push krzysztofkortas/devenv-trunk:latest

docker manifest create krzysztofkortas/devenv-trunk:${TAG} --amend krzysztofkortas/devenv-trunk:${TAG}-amd64
docker manifest annotate krzysztofkortas/devenv-trunk:${TAG} krzysztofkortas/devenv-trunk:${TAG}-amd64 --arch amd64
docker manifest push krzysztofkortas/devenv-trunk:${TAG}