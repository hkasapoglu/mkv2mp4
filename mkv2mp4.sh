#/bin/bash
# Usage  : mkv2mp4.sh [-q] source.mkv
# Example: mkv2mp4.sh video.mkv
#
  if [ $# -lt 1 ] 
  then
    echo "Error  : Missing arguments"
    echo "Usage  : mkv2mp4 [-q] <source file>"
    echo "Example: mkv2mp4 video.mkv"
    exit
  fi

  if [ $# -gt 2 ] 
  then
    echo "Error  : Too many arguments"
    echo "Usage  : mkv2mp4 [-q] <source file>"
    echo "Example: mkv2mp4 video.mkv"
    exit
  fi

  quite1=""
  quite2=""
  input=$1
  if [ "$1" = "-q" ]
  then
    quite1="-q"
    quite2="-quiet"
    if [ $# -lt 2 ] 
    then
      echo "Error  : Missing arguments"
      echo "Usage  : mkv2mp4 [-q] <source file>"
      echo "Example: mkv2mp4 video.mkv"
      exit
    fi
    input=$2
  fi
  base=${input%.mkv}
  output=${base}.mp4

  if [ ! -f "$input" ] 
  then
    echo "Error  : Source file '$input' not exists"
    echo "Usage  : mkv2mp4 [-q] <source file>"
    echo "Example: mkv2mp4 video.mkv"
    exit
  fi

  if [ -f "$output" ] 
  then
    echo "Warning: Destination file '$output' already exists, deleting old one"
    rm ${base}.mp4
  fi

#  echo "====================================="
  echo "Converting: $input --> $output"
#  echo "====================================="
#  exit

  video_track_info=`mkvinfo -s $input | head | grep "Track " | grep "video, "`
  audio_track_info=`mkvinfo -s $input | head | grep "Track " | grep "audio, "`
  subtitle_track_info=`mkvinfo -s $input | head | grep "Track " | grep "subtitles, "`
  video_track=`echo $video_track_info | awk '{ print $2 }' | cut -f 1 -d : | head -1`
  audio_track=`echo $audio_track_info | awk '{ print $2 }' | cut -f 1 -d : | head -1`
  subtitle_track=`echo $subtitle_track_info | awk '{ print $2 }' | cut -f 1 -d : | head -1`
  let video_track_id=video_track-1
  let audio_track_id=audio_track-1
  let subtitle_track_id=subtitle_track-1
  subtitle_track_ext=""
  video_track_ext=""  
  audio_track_ext=""
  subtitle_track_type=`echo $subtitle_track_info | grep "S_TEXT"`
  if [ -n "$subtitle_track_type" ]
  then
    subtitle_track_ext="srt"
  fi
  video_track_type=`echo $video_track_info | grep "h.264"`
  if [ -n "$video_track_type" ]
  then
    video_track_ext="h264"
  fi
  audio_track_type=`echo $audio_track_info | grep "A_AC3"`
  if [ -n "$audio_track_type" ] 
  then
    audio_track_ext="ac3"
  fi
  audio_track_type=`echo $audio_track_info | grep "A_AAC"`
  if [ -n "$audio_track_type" ] 
  then
    audio_track_ext="aac"
  fi
  audio_track_type=`echo $audio_track_info | grep "A_DTS"`
  if [ -n "$audio_track_type" ] 
  then
    audio_track_ext="dts"
  fi
  audio_track_type=`echo $audio_track_info | grep "A_MPEG"`
  if [ -n "$audio_track_type" ] 
  then
    audio_track_ext="mpg"
  fi

  if [ -n "$video_track_ext" ] 
  then
    echo -n .
    mkvextract $quite1 tracks "$input" ${video_track_id}:video.${video_track_ext}
  fi
  if [ -n "$audio_track_ext" ] 
  then
    echo -n .
    mkvextract $quite1 tracks "$input" ${audio_track_id}:audio.${audio_track_ext}
  fi
  if [ -n "$subtitle_track_ext" ] 
  then
    echo -n .
    mkvextract $quite1 tracks "$input" ${subtitle_track_id}:subtitle.${subtitle_track_ext}
  fi

  echo -n .
  MP4Box $quite2 -add video.${video_track_ext} -add audio.${audio_track_ext} "$base.mp4"
  
  rm video.${video_track_ext}
  rm audio.${audio_track_ext}
  mv subtitle.${subtitle_track_ext} ${base}.${subtitle_track_ext}
