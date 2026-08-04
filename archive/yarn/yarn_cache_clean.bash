#!/bin/bash

rm -rfv node_modules
yarn cache clean
yarn $@
