#!/bin/bash

# 检查FFmpeg是否已经安装
if ! command -v ffmpeg &> /dev/null
then
    echo "FFmpeg could not be found, installing now..."
    sudo apt update
    sudo apt install ffmpeg
fi

# 设置视频文件夹路径
folder_path="/home/ubuntu/so"

# 输入推流服务器地址
echo "请输入你的推流服务器地址（例如：rtmp://bdy.live-push.bilivideo.com/live-bvc）："
read server_address

# 输入串流密钥
echo "请输入你的串流密钥（例如：?streamname=live_4758957_8940165&key=c836fb1b3b861746125de5bea4&schedule=rtmp&pflag=1）："
read stream_key

# 提示用户输入他们想要的视频码率
echo "请输入你希望的视频码率（例如：2000k 或 2M）："
read video_bitrate

# 提示用户输入他们想要的帧率
echo "请输入你希望的帧率（例如：30）："
read frame_rate

# 开始推流
while true
do
    for file in "$folder_path"/*
    do
        if [[ $file == *.mp4 ]] || [[ $file == *.avi ]] || [[ $file == *.mkv ]] || [[ $file == *.flv ]] || [[ $file == *.mov ]]
        then
            # 转码以应用新的码率和帧率
            ffmpeg -re -i "$file" -vcodec libx264 -acodec aac -b:a 192k -b:v $video_bitrate -r $frame_rate -f flv "$server_address/$stream_key"
            
            exit_code=$?
            if [ $exit_code -ne 0 ]; then
                echo "推流失败，错误码: $exit_code"
                # 在出错时中断循环
                break
            fi
        fi
    done
    
    if [ $exit_code -ne 0 ]; then
        echo "由于上述错误，脚本已停止。"
        exit
    fi
done
