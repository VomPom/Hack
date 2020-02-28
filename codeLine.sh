########################################################
#
# Created by julis.wang on 2020/02/28
#
# Description : 统计本地代码提交行数
#
########################################################

#!/bin/bash

users_name=("julis" "julis.wang" "julis.wang.hp")                   #考虑到每个人的账号可能有很多个，所以定义成数组

filter_path=("Backend" "test" "sdk" "fork" "BeiBeiProject"
	"JW" "beibei_identify" "beidai_component" "beidian-module")     #过滤一些不需要去遍历的文件夹

export index=0             
export add_line_count=0                                             #添加的line总行数
export remove_line_count=0                                          #删除的总行数

export array_git_repositories=()    #用于记录仓库名
export add_code=()                  #记录所有用户对某个库的添加的行数
export remove_code=()               #记录所有用户对某个库的删除的行数

#判断是否需要过滤该目录
function is_fileter_dir() {
	for i in "${!filter_path[@]}"; do
		if [ $1 == "${filter_path[$i]}" ]; then
			return 1
		fi
	done
	return 0
}
#对命令执行的返回值进行数据切割
function get_add_remove_count() {
	string=$1
	array=(${string//,/ })
	for var in ${array[@]}; do
		echo $var
	done

}
#获取该用户在该文件夹下的提交代码数
function get_user_line() {
	output=$(git log --author=${1} --pretty=tformat: --numstat | awk '
    {add += $1; subs += $2; loc += $1 - $2 } END { printf "%s,%s,%s\n", add, subs, loc }' -)
	get_add_remove_count $output
}

#遍历每个用户名
function trans_every_user() {
	for i in "${!users_name[@]}"; do
		get_user_line "${users_name[$i]}"
	done
	cd ..
}

# 整体流程，从文件夹出发
for path in `ls -l $(dirname $0)|awk -F " " '{print $9}'`
do
    if [ -d $path ]
    then
        is_fileter_dir $path
        if [ $? == 1 ]
        then
            echo "<=========过滤了【"$path"】======>"
            else
            echo "<=========获取【"$path"】的Git代码提交数据======>"
            array_git_repositories=(${array_git_repositories[@]} $path)

            cd $path
            trans_every_user
        fi
    fi
done

echo '================================================================================='
echo "                           本次共遍历【"${#array_git_repositories[@]}"】个仓库                      "
echo '================================================================================='
for ((i=0;i<${#array_git_repositories[@]};i++))
do
    echo ${array_git_repositories[$i]}
done
#echo $add_line_count
echo '================================================================================='
