#!/bin/bash

# get mBART and En-Ro training data for WMT16
# adapt from https://github.com/rsennrich/wmt16-scripts/blob/master/sample/download_files.sh

ROOT=./
SCRIPTS=$ROOT/scripts
DEVTEST=$ROOT/devtest
cd $ROOT

# prepare mBART
wget https://dl.fbaipublicfiles.com/fairseq/models/mbart/mbart.cc25.v2.tar.gz
tar -xf mbart.cc25.v2.tar.gz
PATHTOMBART=$ROOT/mbart.cc25.v2

# prepare original WMT data
mkdir $ROOT/data
cd $ROOT/data
wget http://www.statmt.org/europarl/v7/ro-en.tgz
wget http://opus.lingfil.uu.se/download.php?f=SETIMES2/en-ro.txt.zip -O SETIMES2.en-ro.txt.zip

tar -xf ro-en.tgz
unzip SETIMES2.en-ro.txt.zip
cat europarl-v7.ro-en.en SETIMES.en-ro.en > corpus.en
cat europarl-v7.ro-en.ro SETIMES.en-ro.ro > corpus.ro

# prepare BT data
for lang in ro en
do
wget http://data.statmt.org/rsennrich/wmt16_backtranslations/en-ro/corpus.bt.en-ro.$lang.gz
gzip -d corpus.bt.en-ro.$lang.gz
done

# add tag to BT data
python3 $SCRIPTS/addtag.py < corpus.bt.en-ro.en > tag.bt.en

# cat two data
cat corpus.en tag.bt.en > train.en
cat corpus.ro corpus.bt.en-ro.ro > train.ro

# preprocess raw data
SRC=en_XX
TGT=ro_RO

# apply sentencepiece
python3 $SCRIPTS/tospm.py $PATHTOMBART/sentence.bpe.model < train.en > train.en_XX
python3 $SCRIPTS/tospm.py $PATHTOMBART/sentence.bpe.model < train.ro > train.ro_RO
python3 $SCRIPTS/tospm.py $PATHTOMBART/sentence.bpe.model < $DEVTEST/dev.en > dev.en_XX
python3 $SCRIPTS/tospm.py $PATHTOMBART/sentence.bpe.model < $DEVTEST/dev.ro > dev.ro_RO
python3 $SCRIPTS/tospm.py $PATHTOMBART/sentence.bpe.model < $DEVTEST/test.tag.en > test.en_XX
python3 $SCRIPTS/tospm.py $PATHTOMBART/sentence.bpe.model < $DEVTEST/test.ro > test.ro_RO

# build data bin for fairseq
SRCDICT=$PATHTOMBART/dict.txt
TGTDICT=$PATHTOMBART/dict.txt
fairseq-preprocess \
  --source-lang ${SRC} \
  --target-lang ${TGT} \
  --trainpref train \
  --validpref dev \
  --testpref test \
  --destdir $ROOT/tagbt-data-bin \
  --thresholdtgt 0 \
  --thresholdsrc 0 \
  --srcdict ${SRCDICT} \
  --tgtdict ${TGTDICT} \
  --workers 40






