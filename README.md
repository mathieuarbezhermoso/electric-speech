# Electric speech
[<i>Electric speech</i>](http://01032017.net/) is a part of an ongoing speculative transmedia documentary started in respublica Tuva in 2015. It’s also a web publishing and the remain of one of the first machine happening. 

Inspired by both <i>Do android dream electric sheep</i> from Philip K. Dick and the relationship between datas, speeches and images in politic and contemporary mass medias as defined by Adam Curtis in [<i>Hypernormalisation</i>](https://www.youtube.com/watch?v=yEKC_B1mLL0) as a part of a risks management system initiated with Aladdin, a super computer dedicated to the risk management division of the world largest investment management corporation, [<i>BlackRock, Inc.</i>](https://www.blackrock.com/) <i>Electric speech</i> is attempting to turn a useful system, which is used to shape our financial and digital realities, into a poietic counter-system.

This proposal builds on my previous work including [<i>From</i>](https://www.youtube.com/watch?v=T8jy5ftCC0I) and <i>Spleen</i> which address the boundaries between languages and things, and the way speeches mediate those spaces. Most similar is [<i>unnarrative</i>](http://unnarrative.pysgs.net/) where I worked with the <i>BOX gallery</i> and <i>Le Centre d'Art du Parc Saint-Léger</i> to create an antomatically randomly generated movie made from sequences of isolated, zoomed and extracted extras from regular movies. The result is a low definition-like movie with no story, no actors, no heros and no climaxs. When it's shown, <i>unnarrative</i> is maintained by [a sound proposal made by a different artist for each occasion](https://youtu.be/cAlCLS5-wUg).

In the work of others, I was inspired by Walter Benjamin's [<i>The translator's task</i>](https://www.erudit.org/revue/ttr/1997/v10/n2/037302ar.pdf), Mathelinda Nabugodi's [<i>Pure Language 2.0</i>](http://openhumanitiespress.org/feedback/literature/pure-language-2-0-walter-benjamins-theory-of-language-and-translation-technology/) and Giovanni Anselmo's [<i>Particolare</i>](https://s3.amazonaws.com/media.artslant.com/work/image/850189/slide/20140905161150-particulare_website.jpg). During the process of developing the proposal, a friend shown me [<i>Sucking on words</i>](http://www.informationasmaterial.org/portfolio/sucking-on-words-dvd/) by Kenneth Goldsmith which probably confirmed the work in its actual shape. Another interesting reference could be Avital Ronell's [<i>The Telephone Book</i>](https://drive.google.com/open?id=0B_qCJ40uBfjEdktLMXE2NkZkVmM) which is linking technology and schizophrenia by exploring deep origins of well known technologies.

<center>![](http://mathieu-arbez-hermoso.net/wp-content/uploads/2017/01/vlcsnap-2017-01-29-20h50m38s173.jpg)</center>

In the early begining, we used [Andrej Karpathy's torch implementation](https://github.com/karpathy/neuraltalk2) of the models proposed by [Vinyals et al. from Google (CNN + LSTM)](http://arxiv.org/abs/1411.4555) and by [Karpathy and Fei-Fei from Stanford (CNN + RNN)](http://cs.stanford.edu/people/karpathy/deepimagesent/). Both models take an image and predict its sentence description with a Recurrent Neural Network (either an LSTM or an RNN). Firstly, we trained the models by using a custom dataset made from 1 million images and related hashtags as labels from Flickr. This solution leaded the language structure to gracefully fails at express complex percepts in a proper english but, in the same time, it were really interesting as a poetic purposal and process. Finally, we decided to use [im2txt](https://github.com/tensorflow/models/tree/master/im2txt) and the [inception_V3](https://github.com/tensorflow/models/tree/master/inception) model which was released on Github in 2016. We used a pretrained checkpoint on imagenet dataset and finetuned it for months on MS-COCO dataset. We wanted to use an "alternative intelligence" as close as possible as its used in industrials and competitives contexts.


## Technical details

All footage was recorded over 144 minutes at 4k 24fps on a Panasonic GH4, modified with a [Sigma 24-70mm lens](http://www.the-digital-picture.com/Reviews/Sigma-24-70mm-f-2.8-EX-DG-Lens-Review.aspx). The european version of the GH4 outputs short videos (30 minutes) that are then stripped of audio and concatenated with `ffmpeg`. Before being concatenated the videos are copied to a temporary folder on the internal SSD which changes the processing time from days to minutes. All sequences are then edited, color graded and exported into h264. We're using `ffprobe` and `ffmpeg` to extract keyframes and its related time stamps and send it to `im2txt` which generates text english translation for each image. Finally, the videos and captions are uploaded to YouTube, which will handles the streaming and buffering for the [online version](http://01032017.net/).

Firtsly, we wanted to present a live streaming of the Ai performing but since the learning phase is separated from the performing phase on actual convolutional network solutions we didn't see any reasons to go that way and decided to present a recorded stream of a machine happening occured on 03/01/2017 at 5:17pm (Paris Time).


## Software details

Make sure you have installed the following required packages:

* **Bazel** ([instructions](http://bazel.io/docs/install.html)).
* **TensorFlow** r0.12 or greater ([instructions](https://www.tensorflow.org/versions/master/get_started/os_setup.html)).
* **im2txt** ([instructions](https://github.com/tensorflow/models/tree/master/im2txt)).
* **NumPy** ([instructions](http://www.scipy.org/install.html)).
* **Natural Language Toolkit (NLTK)**:
    * First install NLTK ([instructions](http://www.nltk.org/install.html)).
    * Then install the NLTK data ([instructions](http://www.nltk.org/data.html)).
* **ffmpeg** ([instructions](https://github.com/FFmpeg/FFmpeg).

Then run :

```shell
$ ./train.sh
```
For initializing the initial training phase for the inception model.

```shell
$ ./train2.sh
```
For initializing the second training phase for the inception model.

```shell
$ ./eval.sh
```
For initializing the evaluation. You should run the evaluation script in a separate process. This will log evaluation
metrics to TensorBoard which allows training progress to be monitored in
real-time.

Note that you may run out of memory if you run the evaluation script on the same
GPU as the training script. You can run the command
`export CUDA_VISIBLE_DEVICES=""` to force the evaluation script to run on CPU.
If evaluation runs too slowly on CPU, you can decrease the value of
`--num_eval_examples`.

```shell
$ ./tensorboard.sh
```
For running tensorboard.

```shell
$ ./caption.sh
```
For captioning an image.

```shell
$ ./translator.sh ${MODEL PATH} ${KEYFRAME_TEMP_FOLDER} ${.SRT OUTPUT PATH} ${VIDEO FILE PATH} ${MS COCO WORD_COUNT.TXT PATH}
```
For running the translation script which will take a video, extract each keyframe, caption them and generate a .srt file with the right time stamps. ${MODEL PATH} and ${KEYFRAME_TEMP_FOLDER} must be folders. ${.SRT OUTPUT PATH}, ${VIDEO FILE PATH} and ${MS COCO WORD_COUNT.TXT PATH} must be files.

##Credits

```
ELECTRIC SPEECH (2016)
by MATHIEU ARBEZ HERMOSO
with DORIAN FAUCON

SUBSIDIZED by CONSEIL GENERAL DE COTE D'OR and DIRECTION REGIONALE DES AFFAIRES CULTURELLES

SPECIAL THANKS to ANTONIN RENAULT, GAËLLE LE FLOCH, DELPHINE PAUL, SHAWN QUIRK and THE TUVAN CULTURAL CENTER
```

