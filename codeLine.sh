########################################################
#
# Created by https://julis.wang on 2020/02/28
#
# Description : 统计本地代码提交行数
#
########################################################

#!/bin/bash

#这里添加你的git常用用户名。考虑到每个人的账号可能有很多个，所以定义成数组
users_name=("julis" "julis.wang" "julis.wang.hp")      

#过滤一些不需要去遍历的文件夹
filter_path=("Backend" "test" "sdk" "fork" "BeiBeiProject")     




########################################################
# 以下代码不需动                       
########################################################

export index=0             			#记录当前的位置
export add_line_count=0             #添加的line总行数
export remove_line_count=0          #删除的总行数

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
	if [ ! ${array[0]} ]; then
  		add_line=0
	else
  		add_line=${array[0]}
	fi
	
	if [ ! ${array[1]} ]; then
  		remove_line=0
	else
  		remove_line=${array[1]}
	fi

	if [ ! ${add_code[$index]} ]; then
  		add_code[$index]=0
	
	fi
	if [ ! ${remove_code[$index]} ]; then
  		remove_code[$index]=0
	
	fi
	remove_code[$index]=`expr ${remove_code[$index]} + $remove_line`
	add_code[$index]=`expr ${add_code[$index]} + $add_line`

	echo "用户"$2"添加了="$add_line"行 删除了"$add_line"行"
	
}
#获取该用户在该文件夹下的提交代码数
function get_user_line() {
	# output分别去接收 该文件夹下的提交以及删除行数
	output=$(git log --author=${1} --pretty=tformat: --numstat | awk '
    {add += $1; subs += $2; loc += $1 - $2 } END { printf "%s,%s,%s\n", add, subs, loc }' -)
	get_add_remove_count $output ${1}
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
			index=${#array_git_repositories[@]} #用于记录当前在第几个文件夹下处理
            array_git_repositories=(${array_git_repositories[@]} $path)
			
            cd $path
            trans_every_user
        fi
    fi
done
all_add_line=0
all_remove_line=0
echo '==============================================================================='
echo "                  本次共统计了【"${#array_git_repositories[@]}"】个仓库   by julis.wang      "
echo '==============================================================================='
printf "%-30s %10s %10s %10s\n" "Folder" "Add" "Remove" "All"
echo '-------------------------------------------------------------------------------'
for ((i=0;i<${#array_git_repositories[@]};i++))
do
	all_add_line=`expr $all_add_line + ${add_code[$i]}`
	all_remove_line=`expr $all_remove_line + ${remove_code[$i]}`
	printf "%-30s %10s %10s %10s\n" ${array_git_repositories[$i]} ${add_code[$i]} ${remove_code[$i]} `expr ${add_code[$i]} - ${remove_code[$i]}`
done
echo '-------------------------------------------------------------------------------'
printf "%-30s %10s %10s %10s\n" "Total" $all_add_line $all_remove_line `expr $all_add_line - $all_remove_line`
echo '==============================================================================='
