#!/bin/bash
sh Configure -Dprefix=$PREFIX -d -e
make
make install
