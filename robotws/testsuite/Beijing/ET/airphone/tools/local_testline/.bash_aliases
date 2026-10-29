echo "alias file: V5.0,2021-11-10"
echo "simple L3 call cmd: egate,onair,attachue,startdata,showdata,stopdata,detachue"
echo "simple folder link cmd: cudu,wts,qt"
echo "simple get info cmd: fct,asp,rru,gnb,ap"
echo "simple gnb cmd: hardreboot,state,prepare"
echo "simple run case cmd: mybot,sendreport"
echo "case path of yuema: 1070,496,1208,2056,5750,1808"
echo "get cmd in detail: cmd_mybot,cmd_sendreport,cmd_state,cmd_prepare,cmd_hardreboot"
echo "get new version cmd: new_alias"
echo "global parameter: \$testline_name, \$testline"
export testline_name=`hostname|sed 's/-/_/g'`
export testline=/home/ute/testline_configuration/$testline_name
export cn1_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/
export https_proxy=10.144.1.10:8080; http_proxy=10.144.1.10:8080; ftp_proxy=10.144.1.10:8080
echo "global parameter:\$testline=${testline}"
echo "global parameter:\$testline_name=${testline_name}"
# testline_type=$(cat /opt/ute/reservation.json |awk -F, '{print $9}'|awk -F: '{print $2}'| sed 's/\"//g')
# sw_version=$(cat /opt/ute/reservation.json |awk -F, '{print $12}'|awk -F: '{print $2}'| sed 's/\"//g')
# alias cmd_hardreboot="echo 'cd $cn1_path/tools; pybot -L trace -V $testline hard_reboot.robot'"
# alias cmd_sendreport="echo 'ute_reporting_portal send -ie -ro output.xml -p UTE -ca 5G_SW_CN_1 -v -l ${testline_type} --sw_version ${sw_version} -tl ${testline_name}'"
# alias sendreport='ute_reporting_portal send -ie -ro output.xml -p UTE -ca 5G_SW_CN_1 -v -l ${testline_type} --sw_version ${sw_version} -tl ${testline_name}'

alias wts="cd /opt/iphy/latest/"
alias egate="ps aux|grep -E 'egate|edaemon';sudo pkill edaemon; sudo pkill egate ;cd /opt/iphy/latest; sudo ./edaemon --port 22222; ./egate --port 20000;"
alias checkonair='sshiphy grep -i "Cell Setup Completed" /tmp/APL3.log'
alias attachue='(sleep 5s;echo "ue_attach id=1";sleep 5s;echo "ue_dc_enb_start ue=1 target_gnb=2 target_cells=1 bearer=2 type=split_scg";sleep 5s;) | telnet 0 20000'
alias startdata='(sleep 5s;echo "trf_data_start ue=1 id=2 dir=dl trf_id=1 mbps=10";sleep 5s;echo "trf_data_start ue=1 id=2 dir=ul trf_id=2 mbps=5";sleep 5s;) | telnet 0 20000'
alias showdata='(sleep 5s;echo "bearer_stats ue=1 id=2 dir=dl";sleep 5s;echo "bearer_stats ue=1 id=2 dir=ul";sleep 5s;) | telnet 0 20000'
alias stopdata='(sleep 5s;echo "trf_data_stop ue=1 id=2 dir=dl trf_id=2";sleep 5s;echo "trf_data_stop ue=1 id=2 dir=ul trf_id=2";sleep 5s;) | telnet 0 20000'
alias detachue='(sleep 5s;echo "ue_detach id=1";sleep 5s;) | telnet 0 20000'
alias snapshort='echo "log -a -z snapshot_gnb.zip") | telnet 0 15007'
alias hardreboot='cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline hard_reboot.robot'
alias state='cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline check_gnb_state.robot'
alias cmd_state="echo 'cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline check_gnb_state.robot'"
alias myrobot='robot -L trace -V $testline'
alias dryrun='robot -L trace -V $testline --dryrun'
alias cmd_mybot="echo 'pybot -L trace -V $testline'"
alias fct='sshenb cat /proc/device-tree/module-identity/unit-id;echo'
alias asp='sshenb bsh 1:0 cat /proc/device-tree/module-identity/unit-id;echo'
alias gnb="sshenb find /ffs/run/TargetBD_*.xml|awk -F "TargetBD_" '{print $2}'|awk -F "." '{print $1}'"
alias ap="sshiphy find /ffs/run/TargetBD_*.xml|awk -F "TargetBD_" '{print $2}'|awk -F "." '{print $1}'"
alias rru='sshiphy cat /ffs/run/simmode/iphy.xml 2>/dev/null|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"'
alias prepare="cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline prepare_testline.robot;"
alias new_alias="cp /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline/.bash_aliases ~/.bash_aliases;source /home/ute/.bashrc"
#alias put_alias="cd ~; sshpass -p nokia123 scp /home/ute/.bash_aliases nokia@10.57.215.253:/home/nokia/LogServer/tools/"
alias local_chrome="/opt/google/chrome/chrome &"
alias set_proxy="export http_proxy=10.144.1.10:8080;export https_proxy=10.144.1.10:8080;export ftp_proxy=10.144.1.10:8080;env | grep '_proxy' | grep '8080'"
alias unset_proxy="unset https_proxy;unset http_proxy;unset ftp_proxy"
alias aria2c_16="aria2c -j 16 -x 16 -s 16 "

# echo cmd
alias cmd_x2="echo 'enb_x2_link_up enb=1 target=2'"
alias cmd_prepare="echo 'cd $cn1_path/tools; pybot -L trace -V $testline prepare_testline.robot;'"
alias cmd_new_alias="echo 'cd ~; sshpass -p nokia123 scp nokia@10.57.215.253:/home/nokia/LogServer/tools/.bash_aliases ./;source /home/ute/.bashrc'"
alias cmd_nohup="echo 'nohup robot -V $testline -L trace test.robot > myout.file 2>&1 &'"

# case path of yuema
alias 1070="cd $cn1_path/5GC001070/;pwd"


# case for Beijing
alias et="cd /home/ute/MN/UTE/robotws/testsuite/Beijing/et"
alias robotws="cd /home/ute/MN/UTE/robotws"
alias ap_tools="cd /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools"
alias update_ttitrace="cd /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline; sh update_ttitrace.sh; cd -"
alias update_wireshark="mkdir -p /home/ute/wireshark/; cd /home/ute/wireshark; rm *.*; sh /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline/update_wireshark.sh"
alias update_wireshark3.6="mkdir -p /home/ute/wireshark/; cd /home/ute/wireshark; rm *.*; sh /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline/update_wireshark3.6.sh"
alias update_mcshark="cd /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline; sh update_mcshark.sh; cd -"
alias update_mcshark3.4="cd /home/ute/MN/UTE/robotws/testsuite/Beijing/et/airphone/tools/local_testline; sh update_mcshark3.4.sh SBTS22R3_ENB_0000_000793; cd -"
alias pcap_to_txt="sh /home/ute/MN/UTE/robotws/testsuite/Beijing/et/common/resources/tools/pcap_to_txt_sh.robot"
alias emil_to_txt="sh /home/ute/MN/UTE/robotws/testsuite/Beijing/et/common/resources/tools/emil_to_txt_sh.robot"

# for local testline
alias sshenb="sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129"
alias sshgnb="sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129"
alias sshiphy="sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1"
alias sshap="sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1"
