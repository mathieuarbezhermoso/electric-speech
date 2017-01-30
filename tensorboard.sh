#!/bin/bash

#Variables
MODEL_DIR="/media/workshop/DocumentsC1/Learning/im2txt/model"

#Fonctions

# --------------------------
# -- function train
# --------------------------
board ()
{

	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
	export CUDA_HOME=/usr/local/cuda

cd /usr/local/lib/python2.7/dist-packages/tensorflow/tensorboard

python tensorboard.py --logdir="${MODEL_DIR}"


}



####Corps

board
