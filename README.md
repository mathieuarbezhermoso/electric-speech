# Electric speech
[<i>Electric speech</i>](http://01032017.pysgs.net/) is a clouds reading machine which is able to translate abstract cloudy shapes into a proper english. It's a part of an ongoing speculative transmedia documentary started in respublica Tuva in 2015 and it’s also a web publishing and the remain of one of the first machine happening. 

Inspired by both <i>Do android dream of electric sheep?</i> from Philip K. Dick and the relationship between datas, speeches and images in politic and contemporary mass medias as defined by Adam Curtis in [<i>Hypernormalisation</i>](https://www.youtube.com/watch?v=yEKC_B1mLL0) as a part of a risks management system initiated with Aladdin, a super computer dedicated to the risk management division of the world largest investment management corporation, [<i>BlackRock, Inc.</i>](https://www.blackrock.com/) <i>Electric speech</i> is attempting to turn a useful system, which is used to shape our financial and digital realities, into a poietic counter-system.

This proposal builds on my previous work including [<i>From</i>](https://www.youtube.com/watch?v=T8jy5ftCC0I) and <i>Spleen</i> which address the boundaries between languages and things, and the way speeches mediate those spaces. Most similar is [<i>unnarrative</i>](http://unnarrative.pysgs.net/) where I worked with the <i>BOX gallery</i> and <i>Le Centre d'Art du Parc Saint-Léger</i> to create an antomatically randomly generated movie made from sequences of isolated, zoomed and extracted extras from regular movies. The result is a low definition-like movie with no story, no actors, no heros and no climaxs. When it's shown, <i>unnarrative</i> is maintained by [a sound proposal made by a different artist for each occasion](https://youtu.be/cAlCLS5-wUg).

In the work of others, I was inspired by Walter Benjamin's [<i>The translator's task</i>](https://www.erudit.org/revue/ttr/1997/v10/n2/037302ar.pdf), Mathelinda Nabugodi's [<i>Pure Language 2.0</i>](http://openhumanitiespress.org/feedback/literature/pure-language-2-0-walter-benjamins-theory-of-language-and-translation-technology/) and Giovanni Anselmo's [<i>Particolare</i>](https://s3.amazonaws.com/media.artslant.com/work/image/850189/slide/20140905161150-particulare_website.jpg). During the process of developing the proposal, a friend shown me [<i>Sucking on words</i>](http://www.informationasmaterial.org/portfolio/sucking-on-words-dvd/) by Kenneth Goldsmith which probably confirmed the work in its actual shape. Another interesting reference could be Avital Ronell's [<i>The Telephone Book</i>](https://drive.google.com/open?id=0B_qCJ40uBfjEdktLMXE2NkZkVmM) which is linking technology and schizophrenia by exploring deep origins of well known technologies.

<center>![](http://mathieu-arbez-hermoso.net/wp-content/uploads/2017/01/vlcsnap-2017-01-29-20h50m38s173.jpg)</center>

In the early begining, we used [Andrej Karpathy's torch implementation](https://github.com/karpathy/neuraltalk2) of the models proposed by [Vinyals et al. from Google (CNN + LSTM)](http://arxiv.org/abs/1411.4555) and by [Karpathy and Fei-Fei from Stanford (CNN + RNN)](http://cs.stanford.edu/people/karpathy/deepimagesent/). Both models take an image and predict its sentence description through a Recurrent Neural Network (either an LSTM or an RNN). Firstly, we trained the models by using a custom dataset made from 1 million images and related hashtags as labels from Flickr. This solution leaded the language structure to gracefully fails at express complex concepts in a proper English but, at the same time, it was absorbing as a poetic purposal and process. Finally, we decided to use [im2txt](https://github.com/tensorflow/models/tree/master/im2txt) and the [Inception v3](https://github.com/tensorflow/models/tree/master/inception) model which was released on Github in 2016. We used a pretrained checkpoint on the Imagenet dataset and finetuned it for months on the MS-COCO dataset. We wanted to use an "alternative intelligence" as close as possible as its used in industrial and competitive contexts.


## Technical details

All footage was recorded over 144 minutes at 4k 24fps on a Panasonic GH4, modified with a [Sigma 24-70mm lens](http://www.the-digital-picture.com/Reviews/Sigma-24-70mm-f-2.8-EX-DG-Lens-Review.aspx). The European version of the GH4 outputs short videos (30 minutes) that are then stripped of audio and concatenated with `ffmpeg`. Before being concatenated the videos are copied to a temporary folder on the internal SSD which changes the processing time from days to minutes. All sequences are then edited, color graded and exported into h264. We're using `ffprobe` and `ffmpeg` to extract keyframes and its related time stamps and send it to `im2txt` which generates text English translation for each image. Finally, the videos and captions are uploaded to YouTube, which will handles the streaming and buffering for the [online version](http://01032017.pysgs.net/).

Firstly, we wanted to present a live streaming of the A.I performing but since the learning phase is separated from the performing phase on actual neural network solutions we didn't see any reasons to go that way and decided to present a recorded stream of a machine happening occured on 03/01/2017 at 5:17pm (Paris Time).


## Software details

### Install Required Packages

Make sure you have installed the following required packages:

* **Bazel** ([instructions](http://bazel.io/docs/install.html)).
* **TensorFlow** r0.12 or greater ([instructions](https://www.tensorflow.org/versions/master/get_started/os_setup.html)).
* **im2txt** ([instructions](https://github.com/tensorflow/models/tree/master/im2txt)).
* **NumPy** ([instructions](http://www.scipy.org/install.html)).
* **Natural Language Toolkit (NLTK)**:
    * First install NLTK ([instructions](http://www.nltk.org/install.html)).
    * Then install the NLTK data ([instructions](http://www.nltk.org/data.html)).
* **ffmpeg** ([instructions])(https://github.com/FFmpeg/FFmpeg).

### Prepare the Training Data

To train the model you will need to provide training data in native TFRecord
format. The TFRecord format consists of a set of sharded files containing
serialized `tf.SequenceExample` protocol buffers. Each `tf.SequenceExample`
proto contains an image (JPEG format), a caption and metadata such as the image
id.

Each caption is a list of words. During preprocessing, a dictionary is created
that assigns each word in the vocabulary to an integer-valued id. Each caption
is encoded as a list of integer word ids in the `tf.SequenceExample` protos.

Google Brain team provided a script to download and preprocess the [MSCOCO]
(http://mscoco.org/) image captioning data set into this format. Downloading
and preprocessing the data may take several hours depending on your network and
computer speed.

Before running the script, ensure that your hard disk has at least 150GB of
available space for storing the downloaded and processed data.

```shell
# Location to save the MSCOCO data.
MSCOCO_DIR="${HOME}/im2txt/data/mscoco"

# Build the preprocessing script.
bazel build im2txt/download_and_preprocess_mscoco

# Run the preprocessing script.
bazel-bin/im2txt/download_and_preprocess_mscoco "${MSCOCO_DIR}"
```

The final line of the output should read:

```
2016-09-01 16:47:47.296630: Finished processing all 20267 image-caption pairs in data set 'test'.
```

When the script finishes you will find 256 training, 4 validation and 8 testing
files in `DATA_DIR`. The files will match the patterns `train-?????-of-00256`,
`val-?????-of-00004` and `test-?????-of-00008`, respectively.

### Download the Inception v3 Checkpoint

The *Show and Tell* model requires a pretrained *Inception v3* checkpoint file
to initialize the parameters of its image encoder submodel.

This checkpoint file is provided by the
[TensorFlow-Slim image classification library](https://github.com/tensorflow/models/tree/master/slim#tensorflow-slim-image-classification-library)
which provides a suite of pre-trained image classification models. You can read
more about the models provided by the library
[here](https://github.com/tensorflow/models/tree/master/slim#pre-trained-models).


Run the following commands to download the *Inception v3* checkpoint.

```shell
# Location to save the Inception v3 checkpoint.
INCEPTION_DIR="${HOME}/im2txt/data"
mkdir -p ${INCEPTION_DIR}

wget "http://download.tensorflow.org/models/inception_v3_2016_08_28.tar.gz"
tar -xvf "inception_v3_2016_08_28.tar.gz" -C ${INCEPTION_DIR}
rm "inception_v3_2016_08_28.tar.gz"
```

Note that the *Inception v3* checkpoint will only be used for initializing the
parameters of the *Show and Tell* model. Once the *Show and Tell* model starts
training it will save its own checkpoint files containing the values of all its
parameters (including copies of the *Inception v3* parameters). If training is
stopped and restarted, the parameter values will be restored from the latest
*Show and Tell* checkpoint and the *Inception v3* checkpoint will be ignored. In
other words, the *Inception v3* checkpoint is only used in the 0-th global step
(initialization) of training the *Show and Tell* model.

### Initial Training

For initializing the initial training phase for the inception model, you can manually run the training script :

```shell
# Directory containing preprocessed MSCOCO data.
MSCOCO_DIR="${HOME}/im2txt/data/mscoco"

# Inception v3 checkpoint file.
INCEPTION_CHECKPOINT="${HOME}/im2txt/data/inception_v3.ckpt"

# Directory to save the model.
MODEL_DIR="${HOME}/im2txt/model"

# Build the model.
bazel build -c opt im2txt/...

# Run the training script.
bazel-bin/im2txt/train \
  --input_file_pattern="${MSCOCO_DIR}/train-?????-of-00256" \
  --inception_checkpoint_file="${INCEPTION_CHECKPOINT}" \
  --train_dir="${MODEL_DIR}/train" \
  --train_inception=false \
  --number_of_steps=1000000
```
Or automatically doing it by using :

```shell
$ ./train.sh
```
For initializing the second training phase for the inception model, you can manually run the training script :

```shell
# Restart the training script with --train_inception=true.
bazel-bin/im2txt/train \
  --input_file_pattern="${MSCOCO_DIR}/train-?????-of-00256" \
  --train_dir="${MODEL_DIR}/train" \
  --train_inception=true \
  --number_of_steps=3000000  # Additional 2M steps (assuming 1M in initial training).
```

Or automatically doing it by using :

```shell
$ ./train2.sh
```

For initializing the evaluation, you can manually run the eval script :

```shell
MSCOCO_DIR="${HOME}/im2txt/data/mscoco"
MODEL_DIR="${HOME}/im2txt/model"

# Ignore GPU devices (only necessary if your GPU is currently memory
# constrained, for example, by running the training script).
export CUDA_VISIBLE_DEVICES=""

# Run the evaluation script. This will run in a loop, periodically loading the
# latest model checkpoint file and computing evaluation metrics.
bazel-bin/im2txt/evaluate \
  --input_file_pattern="${MSCOCO_DIR}/val-?????-of-00004" \
  --checkpoint_dir="${MODEL_DIR}/train" \
  --eval_dir="${MODEL_DIR}/eval"
```
Or automatically doing it by using :

```shell
$ ./eval.sh
```
You should run the evaluation script in a separate process. This will log evaluation
metrics to TensorBoard which allows training progress to be monitored in
real-time.

Note that you may run out of memory if you run the evaluation script on the same
GPU as the training script. You can run the command
`export CUDA_VISIBLE_DEVICES=""` to force the evaluation script to run on CPU.
If evaluation runs too slowly on CPU, you can decrease the value of
`--num_eval_examples`.

For running tensorboard, you can manually run the training script :

```shell
MODEL_DIR="${HOME}/im2txt/model"

# Run a TensorBoard server.
tensorboard --logdir="${MODEL_DIR}"
```
Or automatically doing it by using :

```shell
$ ./tensorboard.sh
```
For captioning an image, you can manually run the caption script :

```shell
# Directory containing model checkpoints.
CHECKPOINT_DIR="${HOME}/im2txt/model/train"

# Vocabulary file generated by the preprocessing script.
VOCAB_FILE="${HOME}/im2txt/data/mscoco/word_counts.txt"

# JPEG image file to caption.
IMAGE_FILE="${HOME}/im2txt/data/mscoco/raw-data/val2014/COCO_val2014_000000224477.jpg"

# Build the inference binary.
bazel build -c opt im2txt/run_inference

# Ignore GPU devices (only necessary if your GPU is currently memory
# constrained, for example, by running the training script).
export CUDA_VISIBLE_DEVICES=""

# Run inference to generate captions.
bazel-bin/im2txt/run_inference \
  --checkpoint_path=${CHECKPOINT_DIR} \
  --vocab_file=${VOCAB_FILE} \
  --input_files=${IMAGE_FILE}
```

Or automatically doing it by using :

```shell
$ ./caption.sh
```

### Using im2txt and the Inception v3 model on videos

For running the translation script which will take a video, extract each keyframe, caption them and generate a .srt file with the right time stamps. ${MODEL PATH} and ${KEYFRAME_TEMP_FOLDER} must be folders. ${.SRT OUTPUT PATH}, ${VIDEO FILE PATH} and ${MS COCO WORD_COUNT.TXT PATH} must be files, you'll have to use :

```shell
$ ./translator.sh ${MODEL PATH} ${KEYFRAME_TEMP_FOLDER} ${.SRT OUTPUT PATH} ${VIDEO FILE PATH} ${MS COCO WORD_COUNT.TXT PATH}
```

##Credits

```
ELECTRIC SPEECH (2016)
by MATHIEU ARBEZ HERMOSO
with DORIAN FAUCON

SUBSIDIZED by CONSEIL GENERAL DE COTE D'OR and DIRECTION REGIONALE DES AFFAIRES CULTURELLES

SPECIAL THANKS to ANTONIN RENAULT, GAËLLE LE FLOCH, DELPHINE PAUL, SHAWN QUIRK and THE TUVAN CULTURAL CENTER
```

