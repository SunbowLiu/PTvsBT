#!/bin/bash
#SBATCH --job-name tt
#SBATCH --output mbart.tagbt.bs32k.txt
#SBATCH --cpus-per-task 24
#SBATCH --mem 160G
#SBATCH --gres gpu:4
#SBATCH --time 24:00:00
#SBATCH --partition a100_batch

ROOT=./
FAIRSEQ=$ROOT/fairseq
PRETRAIN=$ROOT/mbart.cc25.v2/model.pt
OUTPUT=$ROOT/mbart-tagbt-32k-checkpoints

DATA=$ROOT/tagbt-data-bin
PRERO=$ROOT/scripts/rotok.sh
SPM=$ROOT/mbart.cc25.v2/sentence.bpe.model
REF=$ROOT/devtest/test.ro

SRC=en_XX
TGT=ro_RO
langs=ar_AR,cs_CZ,de_DE,en_XX,es_XX,et_EE,fi_FI,fr_XX,gu_IN,hi_IN,it_IT,ja_XX,kk_KZ,ko_KR,lt_LT,lv_LV,my_MM,ne_NP,nl_XX,ro_RO,ru_RU,si_LK,tr_TR,vi_VN,zh_CN

mkdir $OUTPUT
cp $0 $OUTPUT
git --git-dir=$FAIRSEQ/.git log | head -1 |& tee $OUTPUT/git.log

python3 $FAIRSEQ/train.py $DATA \
--encoder-normalize-before --decoder-normalize-before  --share-all-embeddings \
--arch mbart_large --task translation_from_pretrained_bart  --source-lang en_XX --target-lang ro_RO \
--criterion label_smoothed_cross_entropy --label-smoothing 0.2  \
--dataset-impl mmap --optimizer adam --adam-eps 1e-06 --adam-betas '(0.9, 0.98)' \
--lr-scheduler polynomial_decay --lr 3e-05 --min-lr -1 \
--warmup-updates 2500 --total-num-update 100000 --max-update 100000 \
--dropout 0.3 --attention-dropout 0.1 --weight-decay 0.0 \
--max-tokens 4096 --update-freq 2 --save-interval 1 --save-interval-updates 5000 --keep-interval-updates 1 --no-epoch-checkpoints \
--log-format simple --log-interval 1000 --reset-optimizer --reset-meters --reset-dataloader --reset-lr-scheduler \
--restore-file $PRETRAIN --langs $langs --layernorm-embedding  --ddp-backend no_c10d --fp16 \
--seed 222 --save-dir $OUTPUT \
|& tee $OUTPUT/train.log

RESULT=$OUTPUT/test
PYTHONIOENCODING=utf-8 python3 $FAIRSEQ/fairseq_cli/generate.py $DATA \
  --path $OUTPUT/checkpoint_best.pt \
  --task translation_from_pretrained_bart \
  --gen-subset test \
  -t ${TGT} -s ${SRC} \
  --bpe 'sentencepiece' --sentencepiece-model $SPM \
  --remove-bpe 'sentencepiece' \
  --langs $langs > ${RESULT}.all

cat ${RESULT}.all | grep -P "^H" |sort -V |cut -f 3- | sed 's/\[ro_RO\]//g' > ${RESULT}.hyp
sacrebleu -t wmt16 -l en-ro --detail < ${RESULT}.hyp > $RESULT.sacre.score

sh $PRERO ${RESULT}.hyp > ${RESULT}.mbart.tok.hyp
sh $PRERO ${REF} > ${RESULT}.mbart.tok.ref
sacrebleu -tok 'none' -s 'none' ${RESULT}.mbart.tok.ref < ${RESULT}.mbart.tok.hyp > $RESULT.mbart.tok.score
