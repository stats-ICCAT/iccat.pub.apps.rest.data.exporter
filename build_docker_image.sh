docker build -t iccat/apps/data_exporter_rest:0.1.0 \
			 --build-arg GITLAB_AUTH_TOKEN=$GITLAB_AUTH_TOKEN \
			 -f Dockerfile --progress=plain .