#!/bin/bash

#Variables
MSCOCO_DIR="data/mscoco"
INCEPTION_CHECKPOINT="data/inception_v3.ckpt"
MODEL_DIR="model"
VOCAB_FILE="data/mscoco/word_counts.txt"
CHECKPOINT_DIR="model/train"
IMAGE_FILE="data/test/*.jpg"

#Fonctions

# --------------------------
# -- function caption
# --------------------------
caption ()
{

	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
	export CUDA_HOME=/usr/local/cuda

bazel build -c opt im2txt/run_inference

bazel-bin/im2txt/run_inference \
  --checkpoint_path=${CHECKPOINT_DIR} \
  --vocab_file=${VOCAB_FILE} \
  --input_files=${IMAGE_FILE}


}



####Corps

caption
