#!/bin/bash

BASE_DIR="/home/vmlogs"
DATE="3"

cd $BASE_DIR
find . -type f -mtime +$DATE -delete