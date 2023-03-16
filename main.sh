#!/bin/sh

function get_duration {
  ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1"
}

function trim_video {
  ffmpeg -i "$1" -ss "$2" -to "$3" -c:v libx264 -c:a aac -preset fast -crf 23 "$4"
}

function create_text_image {
  ffmpeg -f lavfi -i "color=c=$6:s=1280x720:d=$2" -vf "drawtext=text='$3':fontsize=$4:fontcolor=$5:x=(w-text_w)/2:y=(h-text_h)/2" "$1"
}

function concat_videos {
  printf "file '%s'\n" "${@:2}" > videos_to_concat.txt
  ffmpeg -f concat -safe 0 -i videos_to_concat.txt -c copy "$1"
  rm videos_to_concat.txt
}

function clean {
  rm "$trimmed_video" "$start_text" "$end_text"

}

function main {
  trim_video "$input_video" "$text_duration" "$trim_end" "$trimmed_video"
  create_text_image "$start_text" "$text_duration" "$text" "$font_size" "$font_color" "$background_color"
  create_text_image "$end_text" "$text_duration" "$text" "$font_size" "$font_color" "$background_color"
  concat_videos "$output_video" "$start_text" "$trimmed_video" "$end_text"
  clean
}


# IO
f_name="main.mp4"
input_dir="./input"
output_dir="./output"

input_video="$input_dir/$f_name"
output_video="$output_dir/$f_name"
trimmed_video="$output_dir/trimmed_video.mp4"
start_text="$output_dir/start_text.mp4"
end_text="$output_dir/end_text.mp4"

# New title.
text="NEW TITLE"
text_duration=3
font_size=52
font_color="black"
background_color="white"
resolution="1920x1080"

duration=$(get_duration "$input_video")
trim_end=$(echo "$duration - $text_duration" | bc)

main
