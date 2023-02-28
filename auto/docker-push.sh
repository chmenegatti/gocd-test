#push image to docker hub
docker push $1:v$GO_PIPELINE_COUNTER
docker push $1:latest