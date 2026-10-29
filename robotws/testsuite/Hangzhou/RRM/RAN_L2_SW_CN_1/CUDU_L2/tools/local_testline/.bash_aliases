export testline_name=`hostname|sed 's/-/_/g'`
export testline_config_path=/home/ute/testline_configuration/$testline_name/
export cn1_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1
export pz34_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34
export log_type=btslog
export log_path=/home/ute/test_logs
export decode=False
export SW_BRANCH=""
export NR_PHY_CELL_IDS=[]
#export testline_type=$(cat /opt/ute/reservation.json|python -c "import json; import sys; obj=json.load(sys.stdin); print(obj['topology'])")
#export gnb_v=$(cat /opt/ute/reservation.json|python -c "import json; import sys; obj=json.load(sys.stdin); print(obj['enb_build'])")
alias update="source /home/ute/.bashrc"
alias egate="ps aux|grep -E 'egate|edaemon';sudo pkill edaemon; sudo pkill egate ;cd /opt/iphy/latest; sudo ./edaemon --port 22222; ./egate --port 20000;"
alias hardreboot='cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline_config_path -d $log_path/test_log$(date +"%Y%m%d%I%M%p") hard_reboot.robot'
alias mybot='pybot -L trace -V $testline_config_path -d $log_path/test_log$(date +"%Y%m%d%I%M%p")'
alias fct='sshenb cat /proc/device-tree/module-identity/unit-id;echo'
alias asp='sshenb bsh 1:0 cat /proc/device-tree/module-identity/unit-id;echo'
alias rru='sshiphy cat /ffs/run/simmode/iphy.xml 2>/dev/null|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"'
#alias sendreport='/home/ute/test_repo/bin/ute_reporting_portal send -ie -ro output.xml  -tl $(hostname|sed "s/-/_/g") -v --sw_version "$gnb_v" -l "$testline_type"'
alias prepare="cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline_config_path -i case1 -d $log_path/test_log$(date +"%Y%m%d%I%M%p") prepare_testline.robot"
alias onair_make="cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline_config_path -i case1 -i case2 -d $log_path/test_log$(date +"%Y%m%d%I%M%p") prepare_testline.robot"
alias onair_check="cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline_config_path -i case3 -d $log_path/test_log$(date +"%Y%m%d%I%M%p") prepare_testline.robot"

alias getlog_env="echo 'log_type=${log_type};decode=${decode};SW_BRANCH=${SW_BRANCH};NR_PHY_CELL_IDS=${NR_PHY_CELL_IDS}'"
alias getlog='pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -v log_type:$log_type -v decode:${decode} $cn1_path/CUDU_L2/small_case/manual_collect_log_all.robot'
#alias getlog_decode='pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -v log_type:$log_type -v decode:True $cn1_path/CUDU_L2/small_case/manual_collect_log_all.robot'
#alias getlog_fast='robot -A /home/ute/testline_artifact.txt'
alias getlog_fast='pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -v log_type:$log_type -v decode:${decode} -v SW_BRANCH:${SW_BRANCH} -v NR_PHY_CELL_IDS:${NR_PHY_CELL_IDS} $cn1_path/CUDU_L2/small_case/manual_collect_log_all.robot'
alias get_resource_usage='pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -v log_type:$log_type $cn1_path/CUDU_L2/small_case/manual_collect_log_resource_usage.robot'
alias cd_log_path='cd ${log_path}/$(ls -1t ${log_path}|head -1)'

#echo cmd
alias cmd_mybot="echo 'pybot -L trace -V $testline_config_path'"
alias cmd_hardreboot="echo 'cd $cn1_path/CUDU_L2/tools; pybot -L trace -V $testline_config_path hard_reboot.robot'"
#alias cmd_sendreport="echo '/home/ute/test_repo/bin/ute_reporting_portal send -ie -ro output.xml  -tl $testline_name -v --sw_version $gnb_v -l $testline_type'"
alias cmd_nohup="echo 'nohup robot -V $testline_config_path -L trace test.robot > myout.file 2>&1 &'"
alias cmd_getlog="echo 'log_type=btslog,emil,ttitrace,bip,sherpa,snapshot;log_path=/home/ute/test_logs/test_logs/;getlog'"
alias cmd_getlog_detail="echo 'pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -v log_type:$log_type $cn1_path/CUDU_L2/small_case/manual_collect_log_all.robot'"
# case path of yuema
alias 1070="cd $cn1_path/5GC001070/;pwd"
alias 496="cd $cn1_path/5GC000496/;pwd"
alias 1208="cd $cn1_path/5GC001208/;pwd"
alias 2056="cd $cn1_path/5GC002056/;pwd"
alias 5750="cd $cn1_path/CB005750/;pwd"
alias 1808="cd $cn1_path/5GC001808/;pwd"
alias 2329="cd $cn1_path/5GC002329/;pwd"
alias 6137="cd $cn1_path/CB006137/;pwd"
alias 8311="cd $cn1_path/CB008311/;pwd"
alias 9854="cd $cn1_path/CB009854/;pwd"
alias 12149="cd $pz34_path/CB012149/;pwd"
alias cn1="cd $cn1_path;pwd"
alias pz34="cd $pz34_path;pwd"
alias cudu="cd $cn1_path/CUDU_L2/";
alias robotws="cd /home/ute/MN/UTE/robotws/"
alias qualcomm="pybot -L trace -V /home/ute/testline_configuration/7_5_UTE5G402T37324 --pythonpath /home/ute/MN/UTE/robotws -d $log_path/test_logs$(date +"%Y%m%d%I%M%p") /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB012149/CB012149_Qualcomm_Peak.robot"


# for local testline
alias sshenb="sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.129"
alias sshiphy="sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1"
alias pybot='source /home/ute/test_repo/bin/activate; robot'
alias robot='source /home/ute/test_repo/bin/activate; robot'

# for capture log
export capture_tool_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/capture_log_tool
alias ttitrace='_ttitrace(){ cd $cn1_path/CUDU_L2/tools/capture_log_tool; pybot -L trace -d $log_path -v time:"$1" capture_ttitrace.robot;}; _ttitrace'
alias l2lottitrace='_l2lottitrace(){ cd $cn1_path/CUDU_L2/tools/capture_log_tool; pybot -L trace -d $log_path -v time:"$1" capture_L2LOL2HI_ttitrace.robot;}; _l2lottitrace'
alias bip='_bip(){ cd $cn1_path/CUDU_L2/tools/capture_log_tool; pybot -L trace -d $log_path -v time:"$1" capture_bip.robot;}; _bip'
alias setup_ttitrace="pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -i setup_all $cn1_path/CUDU_L2/small_case/manual_collect_log_ttitrace.robot"
alias setup_ttitrace_l2ps="pybot -L trace -V $testline_config_path -d $log_path/test_logs$(date +"%Y%m%d%I%M%p")/ -i setup_l2ps $cn1_path/CUDU_L2/small_case/manual_collect_log_ttitrace.robot"

# for filtering columns of ttitrace file
alias filter='Filter() { if [ ! -f "column_name.ini" ] || [ ! -f "get_specific_column.py" ]; then cp $cn1_path/CUDU_L2/tools/local_testline/{get_specific_column.py,column_name.ini} ./; fi;python ./get_specific_column.py $1;};Filter'

#help:
echo "-----Thank you for using cn1 fast cmd-----"
echo "fast cmd list:"
echo "hardreboot: hard reboot your testline with PB, PB info is read by $testline_config_path"
echo "mybot:      short for 'pybot -L trace -V $testline_config_path -d $log_path/test_logs/'"
echo "getlog:     collect many types of log once, supported log type:btslog,bip,ttitrace,sherpa,snapshot,emil"
echo "            default log type:$log_type, default log path:$log_path/test_logs; default ttitrace decode flag: decode:${decode}"
echo "            change log type method 1(chanage in current console): log=btslog,bip,ttitrace;getlog"
echo "            change log type method 2(change permanently): modify log in /home/ute/.bash_aliases;source /home/ute/.bashrc;getlog"
echo "getlog_fast: short for 'robot -A /home/ute/testline_artifact.txt'"
#echo "sendreport: short for ute_reporting_portal cmd,cd log path first, and then execute."
echo "egate:      short for 'sudo pkill edaemon; sudo pkill egate ;cd /opt/iphy/latest; sudo ./edaemon --port 22222; ./egate --port 20000;'"
echo "cn1,cudu,robotws: cd specific directory"
echo "cmd for copy artifact for getlog_fast: cp /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/small_case/testline_artifact.txt /home/ute/testline_artifact.txt"
echo "cmd for update alias file: cp /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/tools/local_testline/.bash_aliases ~/.bash_aliases;source ~/.bashrc"
echo "ttitrace *s: capture ttitrace log with streaming mode for *s, *s means the time need to capture"
echo "l2lottitrace *s: capture L2LO/L2HI ttitrace log with streaming mode for *s, *s means the time need to capture"
echo "bip *s: capture bip log with admin for *s, *s means the time need to capture"
echo "setup_ttitrace,setup_ttitrace_l2ps: make GNB tell ttitrace log to control pc, you can use tcpdump cmd to collect ttitrace "
echo "collecting ttitrace cmd: sudo tcpdump -i eth3 udp and dst 10.0.1.1 and dst port 5678  -w  tcpdump_ttitrace.pcap"
echo "parse ttitrace:source /opt/tti-dec/venv/bin/activate;python /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py ~/tcpdump_ttitrace.pcap excelCsv --optim"
