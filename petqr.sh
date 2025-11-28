#!/bin/bash
string=$1

qrencode "$string" -t ASCIII -m 4 -o - | ./petscii-qr.pl

