#!/bin/bash
./destroy_environment.sh
sudo docker build -t gitlab .
./run_gitlab.sh

