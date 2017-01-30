#!/bin/bash

#Variables
MSCOCO_DIR="data/mscoco"
INCEPTION_CHECKPOINT="data/inception_v3.ckpt"
MODEL_DIR="model"

#Fonctions

# --------------------------
# -- function train
# --------------------------
train ()
{

	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
	export CUDA_HOME=/usr/local/cuda

bazel-bin/im2txt/train \
  --input_file_pattern="${MSCOCO_DIR}/train-?????-of-00256" \
  --inception_checkpoint_file="${INCEPTION_CHECKPOINT}" \
  --train_dir="${MODEL_DIR}/train" \
  --train_inception=false \
  --number_of_steps=1000000


}



####Corps

train
