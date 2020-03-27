#添加需要修改setting.gradle的业务库
biz_path=(
	# "beidian_compat"
	# "beidian_discovery"
	# "beidian_home"
	 "beidian_live"
	# "beidian_message"
	# "beidian_mine"
	# "beidian_trade"
	# "beidian_store"
)
#旧的版本号
biz_original_versions=()
#统计新的修改
biz_new_versions=()

#记录当前的位置
export index=0
export jcq_id=0

if [ ! -n "$1" ]; then
	echo "请输入对应集成区编号"
	exit
else
	echo "输入的集成区编号为====>【"$1"】"
	jcq_id=$1
fi

function get_old_version() {
	cd $1
	echo "<=========得到【"${PWD##*/}"】的集成区编号======>"
	var=$(cat settings.gradle)
	old_version=$(echo $var | sed 's/.*JI_CHENG_QU_\([0-9]*\)&.*/\1/g')
	biz_original_versions[$index]=$old_version
	echo $old_version
    if [ $jcq_id -gt $old_version ]; then
       sed -i '' "s/$old_version/$jcq_id/g" settings.gradle
    fi
	
}

for i in "${!biz_path[@]}"; do
	if [ -d ${biz_path[$i]} ]; then
		index=$i #用于记录当前在第几个文件夹下处理
		get_old_version ${biz_path[$i]}
		cd ..
	fi
done

echo '==============================================================================='
echo "                  本次共修改了【"${#biz_path[@]}"】个仓库   by julis.wang      "
echo '==============================================================================='
printf "%-30s %10s %10s %10s\n" "Folder" "OLD" "NEW" "HIGHER"
echo '-------------------------------------------------------------------------------'

for ((i = 0; i < ${#biz_path[@]}; i++)); do
	isHigher="NO"
	if [ $jcq_id -gt ${biz_original_versions[$i]} ]; then
		isHigher="YES"
	fi
	printf "%-30s %10s =====> %s %10s\n" ${biz_path[$i]} ${biz_original_versions[$i]} $jcq_id $isHigher
done

echo '==============================================================================='