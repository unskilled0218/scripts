#!/bin/bash

set -e
setxkbmap -option ''            # clear existing XKB options
setxkbmap -option ctrl:nocaps   # Caps Lock becomes Ctrl