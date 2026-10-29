#/bin/bash
case_name=$1
sub_folder=$2
i=$3
testline_id=$4
custm_param=$5
SRNCLAB=$6
currentTime=$(date "+%Y-%m-%d_%H-%M-%S")
python -m robot --pythonpath /home/ute/MN/UTE/robotws -V /home/ute/testline_configuration/10_5_UTESRAN$testline_id/ -V /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/test_line_specific/SBTS_SYVE_$testline_id/My_Variables.py -V /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/test_line_specific/Variables/NetActs.py -v $custm_param -v CONFIGURATION:Hangzhou.10_5_UTESRAN$testline_id -v SRNCLAB:$SRNCLAB -v ENB_BRANCH:SBTS00 -L TRACE -b debug.log -o output.xml  -d /home/ute/test_results/Repeat_Cases_Log/"$case_name"_"R$i"_"$currentTime" /home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/$sub_folder/$case_name.robot