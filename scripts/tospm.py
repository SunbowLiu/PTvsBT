#!/usr/bin/python
# -*- coding: UTF-8 -*-

import sentencepiece as spm
import sys

sp = spm.SentencePieceProcessor(sys.argv[1])

for line in sys.stdin:
    text = sp.encode(line,out_type=str)
    print(' '.join(text))
