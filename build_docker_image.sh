docker build -t iccat/apps/data_exporter_rest:0.1.0 \
			 --build-arg GITHUB_AUTH_TOKEN=$GITHUB_AUTH_TOKEN \
			 -f Dockerfile --progress=plain .