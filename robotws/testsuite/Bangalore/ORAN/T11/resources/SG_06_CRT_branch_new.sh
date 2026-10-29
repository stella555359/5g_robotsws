#!/bin/bash
#Author : Rakshith.b@nokia.com

#Usage:

#Example 1 : Update both active, passive build and execute CRT cases
#			./SG_06_RIC_CRT.sh <Active_build> <Passive_build>
# 			./SG_06_NSA_CRT.sh SBTS00_ENB_9999_220817_000007 SBTS00_ENB_9999_220808_000006

#Example 2 : Update only active and and execute CRT cases
#			./SG_06_RIC_CRT.sh <Active_build>
# 			./SG_06_NSA_CRT.sh SBTS00_ENB_9999_220808_000006

#Example 3 : Execute CRT cases in current active build of gnb
# 			./SG_06_NSA_CRT.sh

#######################################

Clean_workspace() {
	if [[ $Clean_robot_workspace == Yes ]]; then
		git reset --hard
		git clean -d -f
	fi
	rm -r $logs_path/Latest_robot_logs
    mkdir $logs_path/Latest_robot_logs
}

Check_and_update_Build() {
	if [[ "$#" -eq 0 ]];then
		Active_SW=SBTS_Build
		Branch=None
		echo No build specified, continuing execution with current active build of gnb
		echo Logs will not be copied EMC path !!!!
	fi
	Check_branch
	if [[ "$#" -eq 2 ]];then
		update_build_LTE $Passive_SW
		update_build $Passive_SW
		update_build_LTE $Active_SW
		update_build $Active_SW
	elif [[ "$#" -eq 1 ]];then
		echo No passive build specified, checking active build version
		update_build_LTE $Active_SW
		update_build $Active_SW
	fi
}

update_build() {
	echo Updating software of gnb to $1
	$python_path -m robot -v Build:$1 -L TRACE -d $logs_path/$1/$TIMESTAMP/Build_upgrade/ -b debug.log -l  $logs_path/$1/$TIMESTAMP/Build_upgrade_log.html -o $logs_path/$1/$TIMESTAMP/Build_upgrade.xml -r $logs_path/$1/$TIMESTAMP/Build_upgrade_report.html $tc_dir/resources/Build_upgrade.robot
	OUT=$?
    cp $logs_path/$1/$TIMESTAMP/Build_upgrade_log.html $logs_path/Latest_robot_logs/Build_upgrade_log.html
    cp $logs_path/$1/$TIMESTAMP/Build_upgrade.xml $logs_path/Latest_robot_logs/Build_upgrade.xml
    cp $logs_path/$1/$TIMESTAMP/Build_upgrade_report.html $logs_path/Latest_robot_logs/Build_upgrade_report.html
    if [[ $OUT -eq 0 ]];then
		echo Software upgrade to $1 successful
	else
	   echo Software upgrade to $1 failed, Exiting execution sequence
	   exit 1
	fi
}

Check_branch() {
	Branch=$(echo $Active_SW | cut -d'_' -f1)
	if [[ $Branch == SBTS00 ]]; then
		Branch=Trunk
	elif [[ $Branch == SBTS ]]; then
		Branch=None
	fi
	echo Active software : $Active_SW
	echo Branch : $Branch
	Build_branch=`echo "$Branch" | sed -e 's/SBTS//'`
	TIMESTAMP=$(date +%Y_%m_%d_%H_%M)
	results_path=$logs_path/$Active_SW/$TIMESTAMP
	EMC_path=/home/ute/EMC_Logs/$Build_branch/Regression/RAN_PZ_BLR/RAN_PZ_BLR_6_SG/SG06_ORAN/
}

update_build_LTE() {
	echo Updating software of LTE site $LTE_Mplane_IP to $1
	$python_path -m robot -v Build:$1 -v BTS_IP:$LTE_Mplane_IP -d $logs_path/$1/$TIMESTAMP/Build_upgrade_LTE/ -b debug.log -L TRACE -l $logs_path/$1/$TIMESTAMP/LTE_Build_upgrade_log.html -o $logs_path/$1/$TIMESTAMP/LTE_Build_upgrade.xml -r $logs_path/$1/$TIMESTAMP/LTE_Build_upgrade_report.html $tc_dir/resources/Build_upgrade.robot
	OUT=$?
	if [[ $OUT -eq 0 ]];then
		echo Software upgrade to $1 successful
	else
	   echo Software upgrade to $1 failed, Exiting execution sequence
	   exit 1
	fi
    cp $logs_path/$1/$TIMESTAMP/LTE_Build_upgrade_log.html $logs_path/Latest_robot_logs/LTE_Build_upgrade_log.html
    cp $logs_path/$1/$TIMESTAMP/LTE_Build_upgrade.xml $logs_path/Latest_robot_logs/LTE_Build_upgrade.xml
    cp $logs_path/$1/$TIMESTAMP/LTE_Build_upgrade_report.html $logs_path/Latest_robot_logs/LTE_Build_upgrade_report.html
}

Execute_testcase() {
	Testcase=`echo $1 | sed -e 's/.robot//'`
    Check_Testcase_status $Testcase
    if [[ $Testcase_status == FAIL ]];then
		echo Executing testcase : $Testcase
		$python_path -m robot -V $CONFIG_FILE -d $results_path/$1 -L TRACE -b debug.log -l $results_path/$1/$Testcase'_log.html' -o $results_path/$1/$Testcase.xml -r $results_path/$1/$Testcase'_report.html' $tc_dir/$1
		OUT=$?
		if [[ $OUT -eq 0 ]];then
			echo Testcase $1 passed
        	cp $results_path/$1/$Testcase'_log.html' $results_path/$Testcase'_Pass_log'.html
			Passed_TC+=( $1 )
		else
			echo Testcase $1 failed
        	cp $results_path/$1/$Testcase'_log.html' $results_path/$Testcase'_Fail_log'.html
			Failed_TC+=( $1 )
		fi
        cp $results_path/$1/$Testcase'_report.html' $results_path/$Testcase'_report.html'
        cp $results_path/$1/$Testcase.xml $results_path/$Testcase'_output'.xml
		Copy_logs_to_EMC $1
		if [[ $Update_to_RP == Yes ]];then
#			/opt/ute/python3/bin/ute_reporting_portal send -ro $results_path/$1/$Testcase.xml -tl $Scout_ID -ca RAN_PZ_BLR -p CRT -l $Test_line_name
            ute_reporting_portal send -ro $results_path/$1/$Testcase.xml -tl $Scout_ID -ca VRF_BLR1 -p CRT -l $Test_line_name --sw_version=$Active_SW
		fi
    fi
}


Check_Testcase_status() {
	if [[ $Rerun_passed_TC == No && $Branch != None ]];then
		echo Checking if $1 testcase passed
		echo $(find $logs_path/$Active_SW -name $1'*' -and -name '*Pass_log.html')
        status=$(find $logs_path/$Active_SW -name $1'*' -and -name '*Pass_log.html' | awk '{print NR}'| sed -n '$p' | wc -l)
        if [[ $status == 1 ]]; then
        	Testcase_status=PASS
            echo Testcase $1 passed in previous execution
        else
        	Testcase_status=FAIL
        fi
    else
    	Testcase_status=FAIL
	fi
}

Copy_logs_to_EMC() {
	if ! [ -d "$EMC_path" ]; then
		cd /home/ute/
		sudo mkdir /home/ute/EMC_Logs
		sudo mount 10.43.207.2:/ORAN/crt /home/ute/EMC_Logs
		cd $workspace
	fi
	if [[ $Branch != None ]]; then
		#echo Compression log files
		#cd $results_path/$1 && zip -r $results_path/$1.zip ./*
		echo Copying folder $logs_path/$Active_SW/ to EMC path $EMC_path
		python $tc_dir/resources/moving_logs_EMC.py $CONFIG_FILE $Site_Config $logs_path/$Active_SW/ $EMC_path
	else
		echo Build not specified, logs will not be copied to EMC path
	fi
}

Print_result() {
	echo Passed testcases: ${#Passed_TC[@]}
	for tc in "${Passed_TC[@]}"
		do
			echo -e ' \t '$tc
		done

	echo Failed testcases: ${#Failed_TC[@]}
	for tc in "${Failed_TC[@]}"
		do
			echo -e ' \t '$tc
		done
	echo Logs path : $results_path
    (cd $results_path; tar -cf - `find . -maxdepth 1 -name '*.html' `) | (cd $logs_path/Latest_robot_logs ; tar -xf -)
    (cd $results_path; tar -cf - `find . -maxdepth 1 -name '*.xml' `) | (cd $logs_path/Latest_robot_logs ; tar -xf -)

}

Retry_failed_testcase() {
	if [[ $Retry_Tc == Yes && ${#Failed_TC[@]} != 0 ]];then
		Retry_testcases=()
		for tc in "${Failed_TC[@]}"
			do
            	Retry_testcases+=( $tc )
			done
		Failed_TC=()
		for tc in "${Retry_testcases[@]}"
			do
				Testcase=`echo $tc | sed -e 's/.robot//'`
				echo Re-Executing testcase : $Testcase
				$python_path -m robot -V $CONFIG_FILE -L TRACE -d $results_path/Retry/$tc -b debug.log -l $results_path/Retry/$tc/$Testcase'_retry_log.html' -o $results_path/Retry/$tc/$Testcase'_retry.xml' -r $results_path/Retry/$tc/$Testcase'_retry_report.html' $tc_dir/$tc
				OUT=$?
				if [[ $OUT -eq 0 ]];then
					echo Testcase $tc passed
					cp $results_path/Retry/$tc/$Testcase'_retry_log.html' $results_path/$Testcase'_retry_Pass_log.html'
					Passed_TC+=( $Testcase )
					Merge_retry_logs $Testcase Pass
				else
					echo Testcase $tc failed-
					cp $results_path/Retry/$tc/$Testcase'_retry_log.html' $results_path/$Testcase'_retry_Fail_log.html'
					Failed_TC+=( $Testcase )
					Merge_retry_logs $Testcase Fail
				fi
				Copy_logs_to_EMC
            	cp $results_path/Retry/$tc/$Testcase'_retry_report.html' $results_path/$Testcase'_retry_report.html'
        		cp $results_path/Retry/$tc/$Testcase'_retry.xml' $results_path/$Testcase'_retry.xml'
				if [[ $Update_to_RP == Yes ]];then
					ute_reporting_portal send -ro $results_path/Retry/$tc/$Testcase'_retry.xml' -tl $Scout_ID -ca RAN_PZ_BLR -p CRT -l $Test_line_name --sw_version=$Active_SW
				fi
			done
	fi
}

Merge_retry_logs() {
	echo Merging result files
	$python_path -m robot.rebot --outputdir $results_path/Retry/$1.robot/ -R -l $results_path/$1_retry_$2_log.html $results_path/$1.robot/$1.xml $results_path/Retry/$1.robot/$1_retry.xml
	rm $results_path/$1_Fail_log.html
    rm $results_path/$1'_report.html'
    rm $results_path/$1'_output'.xml
}

################ Main function #######################

Active_SW=$1
Passive_SW=$2
Rerun_passed_TC=No
Clean_robot_workspace=No
Retry_Tc=Yes
Update_to_RP=Yes
Passed_TC=()
Failed_TC=()
logs_path=/home/ute/results
Scf_filename=Configuration_CURRENT.xml
Site_Config=ORAN/F1
#python_path=/opt/ute/python3/bin/python3.6
python_path=/home/ute/.pyenv/shims/python
workspace=/home/ute/robotws
tc_dir=./testsuite/Bangalore/ORAN/SG06/
CONFIG_FILE=/home/ute/testline_configuration/Bangalore/10-2-CLOUD1236/
LTE_Mplane_IP=10.63.48.81
Test_line_name=DUAL_CORE_SG06_CRT3
Scout_ID=10_2_CLOUD1236

cd $workspace
Clean_workspace
Check_and_update_Build $Active_SW $Passive_SW
#Execute_testcase CB007814_114DCAP/CB007814_ROHC_branch.robot
Execute_testcase CB007814_114DCAP/CB007814_SG01_branch.robot
#Execute_testcase CB009322/CB009322_General_branch.robot
Retry_failed_testcase
Print_result
