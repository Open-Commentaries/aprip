#!/usr/bin/env bash

FILE="static/editions/aprip.docx"

pandoc --lua-filter pandoc_filters/aprip.lua \
    -f docx+styles --track-changes=accept \
    --extract-media=static/img "$FILE" \
    --reference-location=block \
    --standalone \
    -t gfm -o static/editions/tlg0525.tlg001.aprip-nagy.md
