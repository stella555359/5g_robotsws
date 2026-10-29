#! set -eEuo pipefail


get_gnb_version(){
    gnb_v=$(sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129 ls /ffs/run/TargetBD_*.xml|awk -F 'TargetBD_|.xml' '{print $2}' )
    echo "gnb version: ${gnb_v}"
    gnbp3=$(echo "${gnb_v}"|awk -F '_' '{print $3}')
    gnbp4=$(echo "${gnb_v}"|awk -F '_' '{print $4}')
    gnbp5=$(echo "${gnb_v}"|awk -F '_' '{print $5}')
    if [ $gnbp3 = 9999 ];then
    gnb_v="SBTS00_ENB_${gnbp3}_${gnbp4}_${gnbp5}"
    fi
    echo ${gnb_v}
}
get_gnb_version
echo log1:gnb version: ${gnb_v}

#sw_version=$(get_gnb_version)
#echo log2:gnb version: ${sw_version}
wget -r -np -nH https://artifactory-hz1.int.net.nokia.com/artifactory/mcshark-local/${gnb_v}/
ls -al ./artifactory/mcshark-local/${gnb_v}/
cp ./artifactory/mcshark-local/${gnb_v}/