# PTvsBT
On the Complementarity between Pre-Training and Back-Translation for Neural Machine Translation (Findings of EMNLP 2021)

### Citation

Please cite as:

```bibtex
@inproceedings{liu-etal-2021-complementarity-pre,
    title = "On the Complementarity between Pre-Training and Back-Translation for Neural Machine Translation",
    author = "Liu, Xuebo  and
      Wang, Longyue  and
      Wong, Derek F.  and
      Ding, Liang  and
      Chao, Lidia S.  and
      Shi, Shuming  and
      Tu, Zhaopeng",
    booktitle = "Findings of the Association for Computational Linguistics: EMNLP 2021",
    month = nov,
    year = "2021",
    address = "Punta Cana, Dominican Republic",
    publisher = "Association for Computational Linguistics",
    url = "https://aclanthology.org/2021.findings-emnlp.247",
    pages = "2900--2907",
    abstract = "Pre-training (PT) and back-translation (BT) are two simple and powerful methods to utilize monolingual data for improving the model performance of neural machine translation (NMT). This paper takes the first step to investigate the complementarity between PT and BT. We introduce two probing tasks for PT and BT respectively and find that PT mainly contributes to the encoder module while BT brings more benefits to the decoder. Experimental results show that PT and BT are nicely complementary to each other, establishing state-of-the-art performances on the WMT16 English-Romanian and English-Russian benchmarks. Through extensive analyses on sentence originality and word frequency, we also demonstrate that combining Tagged BT with PT is more helpful to their complementarity, leading to better translation quality. Source code is freely available at https://github.com/SunbowLiu/PTvsBT.",
}
```


### Requirements and Installation
This implementation is based on [fairseq(v0.10.2)](https://github.com/pytorch/fairseq/tree/v0.10.2/fairseq)

* [PyTorch](http://pytorch.org/) version >= 1.5.0
* Python version >= 3.6

```
git clone https://github.com/SunbowLiu/PTvsBT
cd PTvsBT
git -C scripts clone https://github.com/moses-smt/mosesdecoder --depth 1
git -C scripts clone https://github.com/rsennrich/wmt16-scripts.git
git clone --branch v0.10.2 https://github.com/pytorch/fairseq.git
cd fairseq
pip install --editable .
```

### Prepare pre-trained mBART and WMT16 Ro-En data from scratch with `prepare.sh`
```
sh prepare.sh
```

### Train and test the model with `run.sh`
```
sh run.sh
```
We used 4*A100 GPUs (40GB). The batch size per step is 32k, i.e., max-tokens * update-freq * num-of-gpus = 32k.

### Final Result
The model is expected to gain about 41.6 BLEU scores.
