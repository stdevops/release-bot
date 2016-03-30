#!/bin/bash -ex

docker build --rm -t release-bot-test .

docker run --rm \
-v $PWD:/usr/src/app \
release-bot-test \
bundle exec rspec -c -fd
