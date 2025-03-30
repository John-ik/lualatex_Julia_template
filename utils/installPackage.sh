#!/bin/env bash

TEXMF="$(kpsewhich -var-value=TEXMFHOME)"

mkdir -p "$TEXMF/tex/lualatex/guap"

cp -vpru guap.sty lua/ "$TEXMF"

texhash "$TEXMF"