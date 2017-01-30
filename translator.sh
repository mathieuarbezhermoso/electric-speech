#!/bin/bash

#Variables
errorString="FancyNoInputs-$$"
Model_Path=${1:-${errorString}}
Picture_Folder=${2:-${errorString}}
SRT_Name=${3:-${errorString}}
Video=${4:-${errorString}}
Words_File=${5:-${errorString}}
Choice=${6:-1}
temp_folder=/tmp/subtitleCreatorKeyFramesTempFolder-$$
date=$(date +%F-%Hh%M)
keyFramesFolderName=keyFrames
im2txtPath=/media/workshop/DocumentsC1/Learning/im2txt
neuraltalkPath=/media/workshop/DocumentsC1/Learning/flickrm/neuraltalk2
#Fonctions


# --------------------------
# -- function usage
# --------------------------
usage ()
{
    echo "Usage: $0 <Model> <Folder> <SRT-File> <Video> <Words> <Translation-Process>"

    echo -e "\nINPUT::"
    echo " Model - path to your im2txt Model checkpoint is located"
    echo " Picture-Folder - path to a EMPTY folder where the video frames will be stored"
    echo " SRT-File - name of the future subtitle file that will be created"
    echo " Video - name of the video to be sampled and subtitled"
    echo " Words - path to the word_counts.txt file"
    echo " Translation-Process - Type 1 for im2txt;  Type 2 for NeuralTalk2.  Default is im2txt"
    #echo " TimingSeconds - How many seconds each subtitle will remain on screen. Default is 1 second."
    #echo " TimingMilliSeconds - How many milliseconds each subtitle will remain on screen. Default is 0 milliseconds."
    #echo " Total time on screen will be TimingSeconds + TimingMilliSeconds"
    echo -e "\nExample::"
    #echo -e "E.g.: $0 ~/neuraltalk2/model /local/data/myPictures ~/subtitle.srt 1 53 \nThis will generate ~/subtitle.srt with 1s53ms spacing"
    echo -e "E.g.: $0 ~/model/train ~/data/test/frames ~/subtitle.srt ~/myvideo.mp4 ~/word_counts.txt 2"
##./im2txt_translator4.sh model/train data/test2/24fps data/test2/24fps.srt data/test2/24fps.mp4 data/mscoco/word_counts.txt 1 in case of im2txt
##./im2txt_translator4.sh model_id.t7 data/test2/24fps data/test2/24fps.srt data/test2/24fps.mp4 2
##model /local/data/myPictureSamples ~/subtitle.srt ~/myvideo.mp4"
##./im2txt_translator4_nt2.sh /home/workshop/neuraltalk2/modelstalks/modelflickrm3 data/test3/key3 data/test3/Key3nt2.srt data/test3/reel.mp4 2 in case of nt2
##./im2txt_translator4_nt2.sh /home/workshop/neuraltalk2/modelstalks/modelflickrm3 /media/workshop/DocumentsC1/Learning/im2txt/data/test3/key3 /media/workshop/DocumentsC1/Learning/im2txt/data/test3/Key3nt2.srt /media/workshop/DocumentsC1/Learning/im2txt/data/test3/key3.mp4 2

    echo "OUTPUT::"
    echo "An subtitle file (srt format) subtitling Only +Key Frames+ and adjusting the subtitle times accordingly"
    echo ""
}

# -------------------------------------
# -- setting up paths
# -------------------------------------
setting ()
{
       export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
       export CUDA_HOME=/usr/local/cuda
}

# -------------------------------------
# -- function Input Check
# -------------------------------------
inputParamsCheck ()
{
	##Do we have at least five parameters
	if [[ ( $Model_Path = ${errorString} ) || ( $Picture_Folder = ${errorString} ) || ( $SRT_Name = ${errorString} ) || ( $Video = ${errorString} ) || ( $Words_File = ${errorString} ) ]]
	then
		usage ; exit
	fi

	if [ ! -d $Model_Path ] 
	then 
		echo "Error IP000: $Model_Path does not exist!" ; exit
	fi
	if [ ! -d $Picture_Folder ] 
	then 
		echo "Warning IP001: $Picture_Folder does not exist! Creating it for you. This is not an error" 
		mkdir $Picture_Folder
		if [ ! -d $Picture_Folder ]
		then
			echo "Error IP001: Unable to create $Picture_Folder ! Check your variable. " 
		fi
	fi

	if [ "$(ls -A $Picture_Folder)" ]; then
	     echo "Error IP003: $Picture_Folder is not Empty" ; exit
	fi

	if [ -f $SRT_Name ] 
	then 	
		echo "Error IP004: $SRT_Name file already exists! - no file was created."; exit
	fi
	if [ ! -f $Video ] 
	then 
		echo "Error IP005: $Video does not exist!"; exit
	fi
}

# -------------------------------------
# -- function Time Check
# -------------------------------------
timeCheck ()
{
	##Only handling positive integers
	re='^[0-9]+$'
	if ! [[ "$InterFrameSeconds" =~ $re ]]
        then
		echo "Error TCk503: Timing only accepts positive integers. Sorry"; exit
	fi	
	##Only handling positive integers
	re='^[0-9]+$'
	if ! [[ "$InterFrameMilliSeconds" =~ $re ]]
        then
		echo "Error TCk504: Timing only accepts positive integers. Sorry"; exit
	fi	
	if [ $InterFrameSeconds -eq 0 ] && [ $InterFrameMilliSeconds -eq 0 ]
	then 
		echo "Error TCk505: Timing cannot be 0 seconds and 0 ms. Sorry"; exit
	fi

}


# ------------------------------------------------------------
# -- function converting FPS to time
# ------------------------------------------------------------
timeConverter ()
{
	#ffprobe -i $Video 2>$temp_folder/020-Timer-Output.txt ##This is now done in function video2frame
	if [ ! -f $temp_folder/020-Timer-Output.txt ] 
	then 
		echo "Error TC001: $temp_folder/020-Timer-Output.txt  does not exist!"; exit
	fi
	FPS=$(more  $temp_folder/020-Timer-Output.txt | grep fps | tail -n1 | cut -d "," -f6 | cut -d " " -f2)
	##Only handling positive integers or decimals
	re='^[0-9]+([.][0-9]+)?$'
	if ! [[ "$FPS" =~ $re ]]
        then
		echo "Error TC002: FPS erroneous calculation: FPS=$FPS"; exit
	fi
	Time0=$(echo "scale=5; 1/$FPS " | bc)
	Time=$(LC_ALL=C /usr/bin/printf "%.*f\n" 3 ${Time0})
	InterFrameSeconds=$(echo $Time | cut -d "." -f1 | sed "s/^0*//" )
	InterFrameMilliSeconds=$(echo $Time | cut -d "." -f2 | sed "s/^0*//" )
	if [ -z $InterFrameSeconds ]
	then
		InterFrameSeconds=0;
	fi
	if [ -z $InterFrameMilliSeconds ]
	then
		InterFrameMilliSeconds=0;
	fi
	timeCheck
	echo "FPS=$FPS Time=$Time InterFrameSeconds=$InterFrameSeconds InterFrameMilliSeconds=$InterFrameMilliSeconds" > $temp_folder/050-FTS-timings.txt
}

# ------------------------------------------------------------
# -- function converting FPS to time for timer2 function
# ------------------------------------------------------------
timeConverter2 ()
{
	#Calculate to 5 decimal
	TimeT2=$(echo "scale=5; ${frameEnd}/$FPS " | bc)
	#Round to 3 decimal
	TimeT3=$(LC_ALL=C /usr/bin/printf "%.*f\n" 3 ${TimeT2})
	#Seperate s and ms
	FullFrameSeconds=$(echo $TimeT3 | cut -d "." -f1 | sed "s/^0*//" )
	FullFrameMilliSeconds=$(echo $TimeT3 | cut -d "." -f2 | sed "s/^0*//" )
	if [ -z $FullFrameSeconds ]
	then
		FullFrameSeconds=0;
	fi
	if [ -z $FullFrameMilliSeconds ]
	then
		FullFrameMilliSeconds=0;
	fi
	if [ $FullFrameSeconds -eq 0 ] && [ $FullFrameMilliSeconds -eq 0 ]
	then 
		echo "Error TCk605: Timing cannot be 0 seconds and 0 ms. Sorry"; exit
	fi
	
}
# ---------------------------------------------------------------
# -- function seperating key Frames from the general population
# ---------------------------------------------------------------
segragation ()
{
	## $temp_folder/030-frame_index.txt is generated in video2frame
	if [ ! -f $temp_folder/030-frame_index.txt ] 
	then 
		echo "Error Seg001: $temp_folder/020-Timer-Output.txt  does not exist!"; exit
	fi
	mkdir 	${Picture_Folder}/$keyFramesFolderName
	while read line
	do
		mv ${Picture_Folder}/$(printf "%09d.jpg" "${line}") ${Picture_Folder}/$keyFramesFolderName 
	done < $temp_folder/030-frame_index.txt	
	
}

# ------------------------------------------------------------
# -- function converting Video To Frame
# ------------------------------------------------------------
video2frame ()
{
	if [ -d $temp_folder ] 
	then 
		echo "Error VF001: $temp_folder already exists!"; exit
	else
		mkdir $temp_folder
	fi
	ffprobe -select_streams v -show_frames -show_entries frame=pict_type -of csv $Video 2>$temp_folder/020-Timer-Output.txt | grep -n I | cut -d ':' -f 1 > $temp_folder/030-frame_index.txt
	timeConverter
	ffmpeg -i $Video ${Picture_Folder}/%09d.jpg -qscale:v 2 2>$temp_folder/040-Framing-Output.txt
	segragation
	echo -e "Created frames in $Picture_Folder and placed Key Frames in ${Picture_Folder}/$keyFramesFolderName"
}

# --------------------------
# -- function neuraltalk
# --------------------------
buildinference ()
{
	setting
	bazel build -c opt im2txt/run_inference
}


# --------------------------
# -- function neuraltalk
# --------------------------
nt2 ()
{
	if [ "$(ls -A $Picture_Folder/$keyFramesFolderName)" ]; then
		echo "$Picture_Folder/$keyFramesFolderName contains files, continuing process"
	else
		echo "Error NT001: $Picture_Folder/$keyFramesFolderName is empty.  Something went wrong in the previous steps."; exit
	fi
	echo -e "Using: th ${neuraltalkPath}/eval.lua -model $Model_Path -image_folder $Picture_Folder/$keyFramesFolderName -num_images -1\nPlease wait"
	if th ${neuraltalkPath}/eval.lua -model $Model_Path -image_folder $Picture_Folder/$keyFramesFolderName -num_images -1  > $temp_folder/000-nt2-Output.txt 
	then echo -e "\nNeuralTalk2 successfull"
	else 
		echo -e "Error NT002: Problem with NeuralTalk2. Check your formula"
		exit
	fi

}

# --------------------------
# -- function im2txt
# --------------------------
im2txt ()
{

	##setting up paths
	if [ "$(ls -A $Picture_Folder/$keyFramesFolderName)" ]; then
		echo "$Picture_Folder/$keyFramesFolderName contains files, continuing process"
	else
		echo "Error IM001: $Picture_Folder/$keyFramesFolderName is empty.  Something went wrong in the previous steps."; exit
	fi
	echo -e "${im2txtPath}/bazel-bin/im2txt/run_inference \  --checkpoint_path=${Model_Path} \  --vocab_file=${Words_File} \  --input_files=${Picture_Folder}/$keyFramesFolderName/*.jpg\nPlease wait"
	##if th ${neuraltalkPath}/neuraltalk2/eval.lua -model $Model_Path -image_folder $Picture_Folder/$keyFramesFolderName -num_images -1  > $temp_folder/000-nt2-Output.txt 

        if 

${im2txtPath}/bazel-bin/im2txt/run_inference \
  --checkpoint_path=${Model_Path} \
  --vocab_file=${Words_File} \
  --input_files=${Picture_Folder}/$keyFramesFolderName/*.jpg > $temp_folder/000-nt2-Output.txt

	then echo -e "\nim2txt successfull"
	else 
		echo -e "Error IM002: Problem with im2txt. Check your formula"
		exit
	fi

}


# ------------------------------------------------------------
# -- function calculating the time between two frames
# ------------------------------------------------------------
frameTimeSeperation ()
{
	#Most calculation here are just for kicks and reporting.  Important is frameBegin and frameEnd.
	TimingMilliSeconds=0
	TimingSeconds=0
	sepStart=$cpt
	sepStop=$[ $cpt + 1 ]
	frameBegin=$(sed -n ${sepStart}p $temp_folder/030-frame_index.txt)
	frameEnd=$(sed -n ${sepStop}p $temp_folder/030-frame_index.txt)
	if [ -z $frameBegin ]
	then
		frameBegin=0
	fi 
	if [ -z $frameEnd ]
	then
		frameEnd=$lastFrame
	fi 
	difference=$(( $frameEnd - $frameBegin ))
	TimingMilliSeconds=$(( $difference * $InterFrameMilliSeconds ))
	while [ $TimingMilliSeconds -ge 1000 ]
	do
		TimingSeconds=$[ $TimingSeconds + 1 ]
		TimingMilliSeconds=$[ $TimingMilliSeconds - 1000 ]
	done
	TimingSeconds=$(( $TimingSeconds + $InterFrameSeconds))
	echo "${sepStart}-${sepStop}: ${frameEnd}-${frameBegin}=${difference} ${TimingSeconds}.$(printf "%03d" ${TimingMilliSeconds}) sec" >> $temp_folder/050-FTS-timings.txt
}


# ------------------------------------------------------------
# -- function controlling time of each subtitle : delivers a rounded sequ
# ------------------------------------------------------------
timer ()
{
	timerStart=$(printf "%02d:%02d:%02d,%03d\n" "$timerHour" "$timerMin" "$timerSec" "$timerMilliSec")
	timerMilliSec=$[ $timerMilliSec + $TimingMilliSeconds ]
	while [ $timerMilliSec -ge 1000 ]
	do
		timerSec=$[ $timerSec + 1 ]
		timerMilliSec=$[ $timerMilliSec - 1000 ]
	done
	timerSec=$[ $timerSec + $TimingSeconds ]
	while [ $timerSec -ge 60 ]
	do
		timerMin=$[ $timerMin + 1 ]
		timerSec=$[ $timerSec - 60 ]
	done
	while [ $timerMin -ge 60 ]
	do
		timerHour=$[ $timerHour + 1 ]
		timerMin=$[ $timerMin - 60 ]
	done
	timerStop=$(printf "%02d:%02d:%02d,%03d\n" "$timerHour" "$timerMin" "$timerSec" "$timerMilliSec")
}

# ------------------------------------------------------------
# -- function controlling time of each subtitle: direct FPS to time calculation
# ------------------------------------------------------------
timer2 ()
{
	#Respecting srt format for time
	timerStart=$(printf "%02d:%02d:%02d,%03d\n" "$timerHour" "$timerMin" "$timerSec" "$timerMilliSec")
	timeConverter2
	timerMilliSec=$FullFrameMilliSeconds
	timerSec=$FullFrameSeconds
	timerMin=0
	timerHour=0
	while [ $timerSec -ge 60 ]
	do
		timerMin=$[ $timerMin + 1 ]
		timerSec=$[ $timerSec - 60 ]
	done
	while [ $timerMin -ge 60 ]
	do
		timerHour=$[ $timerHour + 1 ]
		timerMin=$[ $timerMin - 60 ]
	done
	timerStop=$(printf "%02d:%02d:%02d,%03d\n" "$timerHour" "$timerMin" "$timerSec" "$timerMilliSec")
}

# ------------------------------
# -- function subtitle-creation
# ------------------------------
subtitle-creation ()
{
	case $Choice in 
	1)
		## if im2txt
		less $temp_folder/000-nt2-Output.txt | grep -w "0)" | cut -d ")" -f 2 | cut -d "." -f 1 | cut -d "(" -f 1 > $temp_folder/010-SubsWithNoTime.srt ##grep et cut pour im2txt 
		;;
	2)
		## if nt2
		less $temp_folder/000-nt2-Output.txt | grep -w "image" | cut -d ":" -f 2 > $temp_folder/010-SubsWithNoTime.srt
		;;
	*)
		## all other cases
		
		echo -e "Error SC001: Unknown subtitle creator.  Ciao! "
		exit
		;;
	esac

	#Read content of previous file
	cpt=0
	timerMilliSec=0
	timerSec=0
	timerMin=0
	timerHour=0
	lastFrame=$(ls  ${Picture_Folder}/ | tail -n2 | head -n1 | cut -d "." -f1 | sed "s/^0*//" )
	while read line
	do
		cpt=$[ $cpt + 1 ]
		#Calculating the time spacing between each key Frame (see function)
		frameTimeSeperation
		#Preparing the time of the image (see function)
		timer2
		##Creating the subtitle model
		echo -e "${cpt}\n${timerStart} --> ${timerStop}\n${line}\n" >>  $temp_folder/011-SubsWithTime.srt
		
	done < $temp_folder/010-SubsWithNoTime.srt
	cp $temp_folder/011-SubsWithTime.srt $SRT_Name

}

# -------------------------------------
# -- function cleaning temporary files
# -------------------------------------
cleanFiles ()
{
	echo "Clean Up: Erasing temporary folders $temp_folder and $Picture_Folder"
	rm -rf $temp_folder
	rm -f /tmp/tmp.file.*
	rm -rf $Picture_Folder
}

####Corps


#Test Variables
#echo -e "Error: $errorString\nModel: $Model_Path\nFolder: $Picture_Folder\nSubtitle: $SRT_Name\nTiming: ${TimingSeconds}s${TimingMilliSeconds}ms\nTempFolder: $temp_folder\n"
#echo -e "Model: $Model_Path\nFolder: $Picture_Folder\nSubtitle: $SRT_Name\nTiming: $TimingSeconds second(s) and $TimingMilliSeconds ms\n"
echo -e "Model: $Model_Path\nFolder: $Picture_Folder\nSubtitle: $SRT_Name\nVideo: $Video\n"

##Input Check
inputParamsCheck


echo -e "\n$date : Starting Process: 1) Video to Frames 2) Translating on Key Frames and 3) Writing"

##Creating Frames into Picture Folder and creating Key Frame File
echo -e "\n--Step 1: Video to Frames and Key Frame File creation."
video2frame
##Neuraltalking the Key Frame Files

case $Choice in 
1)
	## if im2txt
	echo -e "\n--Step 2: Translating with im2txt."
	## build inference
	buildinference
	## run inference
	im2txt
	;;
2)
	## if nt2
	echo -e "\n--Step 2: Translating with Neuraltalk2."
	nt2
	;;
*)
	## all other cases

	echo -e "Error Main001: Unknown translator. Ciao! "
	exit
	;;
esac
##Create Subtitle On the Key Frames
echo -e "\n--Step 3: Writing."
subtitle-creation
##Cleaning the temporary files. Comment if you want to see them
cleanFiles

echo -e "\n--Status: SUCCESS:  Subtitle file can be found under $SRT_Name\n\n--Preview\nHere under the first 7 lines of the $SRT_Name file:"
head -n7 $SRT_Name
