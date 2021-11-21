#!/bin/bash

set -eu
ROOT=./
REPLACE_UNICODE_PUNCT=$ROOT/mosesdecoder/scripts/tokenizer/replace-unicode-punctuation.perl
NORM_PUNC=$ROOT/mosesdecoder/scripts/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$ROOT/mosesdecoder/scripts/tokenizer/remove-non-printing-char.perl
REMOVE_DIACRITICS=$ROOT/wmt16-scripts/preprocess/remove-diacritics.py
NORMALIZE_ROMANIAN=$ROOT/wmt16-scripts/preprocess/normalise-romanian.py
TOKENIZER=$ROOT/mosesdecoder/scripts/tokenizer/tokenizer.perl

sys=$1

lang=ro
for file in $sys; do
  cat $file \
  | $REPLACE_UNICODE_PUNCT \
  | $NORM_PUNC -l $lang \
  | $REM_NON_PRINT_CHAR \
  | $NORMALIZE_ROMANIAN \
  | $REMOVE_DIACRITICS \
  | $TOKENIZER -no-escape -l $lang
done