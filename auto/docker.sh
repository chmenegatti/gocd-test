#!/bin/sh
echo $DOCKER_PASS >> pass.txt
cat pass.txt | docker login -u chmenegatti --password-stdin