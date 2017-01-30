#!/bin/bash

#Variables
MSCOCO_DIR="data/mscoco"
INCEPTION_CHECKPOINT="data/inception_v3.ckpt"
MODEL_DIR="model"

#Fonctions

# --------------------------
# -- function eval
# --------------------------
evaluate ()
{

	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
	export CUDA_HOME=/usr/local/cuda
	export CUDA_VISIBLE_DEVICES=""

bazel-bin/im2txt/evaluate \
  --input_file_pattern="${MSCOCO_DIR}/val-?????-of-00004" \
  --checkpoint_dir="${MODEL_DIR}/train" \
  --eval_dir="${MODEL_DIR}/eval"


}



####Corps

evaluate
