#!/bin/bash

# This is a script for easily running the local testing
# Comes very handy in local development

TF_VERSION='0.14.6'
TG_VERSION='v0.28.4'
TF_WORKING_DIR='/var/opt'
TF_SUBCOMMAND='run-all plan'
TG_LOCAL_WORK_DIR="$(pwd)"  # TODO, provide some path which has the terragrunt code

function build_docker {
    echo "INFO: Building docker image"
    docker build -t tg .
}

function run_docker {
    echo "INFO: Test running docker"
    docker run -it \
        -e INPUT_TF_ACTIONS_VERSION=$TF_VERSION \
        -e INPUT_TG_ACTIONS_VERSION=$TG_VERSION \
        -e INPUT_TF_ACTIONS_SUBCOMMAND="$TF_SUBCOMMAND" \
        -e INPUT_TF_ACTIONS_WORKING_DIR="$TF_WORKING_DIR" \
        -v $TG_LOCAL_WORK_DIR:$TF_WORKING_DIR \
        tg "$*"
}

function main {

    # Build the image
    build_docker

    # test run it
    run_docker "$*"
}

main "$*"