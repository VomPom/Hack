########################################################
#
# Created by https://julis.wang on 2021/05/12
#
# Description : 一键逆向apk
#
########################################################

#!/bin/bash

#Path config
DEX2JAR_PATH=dex2jar-2.0/d2j-dex2jar.sh
CRF_PATH=cfr-0.151.jar
DEX_FOLDER_NAME=dex
JAR_FOLDER_NAME=jar
JAVA_FOLDER_NAME=java


########################################################
##### Handle input        
########################################################
input=$@
is_apk=0 #0 not apk 1 apk
cd $(dirname $input)
if echo "$input" | grep -q -E '\.apk'
then
	is_apk=1
else
	is_apk=0
fi

########################################################
##### start  dex2jar            
########################################################
script_path=$0;
dex2jar_path_dir=$(dirname "${script_path%*}") 
dex2jar_sh=$dex2jar_path_dir/$DEX2JAR_PATH

if [ $is_apk -eq 1 ];
then
    dex_floder_path=$DEX_FOLDER_NAME
    apk_path=$input
    apk_zip_path=$(basename -- $apk_path)
    apk_unpack_path=${apk_zip_path%.*}
    mkdir -p $apk_unpack_path
    mkdir -p $DEX_FOLDER_NAME
    tar -zxvf $apk_path -C $apk_unpack_path
    cp $apk_unpack_path/*.dex dex
else
     dex_floder_path=$input
fi

jar_path=$JAR_FOLDER_NAME
for dex in "$dex_floder_path/"*;
do
    jar_name=$(basename $dex)
    $dex2jar_sh "$dex" -o $jar_path/${jar_name%.*}.jar --force
done

########################################################
##### Start  cfr            
########################################################
java_path=$JAVA_FOLDER_NAME
for jar in "$JAR_FOLDER_NAME/"*;
do
    java_package_name=$(basename ${jar%.*})
    java -jar $dex2jar_path_dir/$CRF_PATH $jar --outputdir $java_path/$java_package_name
done