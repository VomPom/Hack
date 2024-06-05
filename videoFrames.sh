#!/bin/bash

input_file=$1
output_file=$2

ffprobe -show_frames -select_streams v -of xml "$input_file" > "$output_file"
