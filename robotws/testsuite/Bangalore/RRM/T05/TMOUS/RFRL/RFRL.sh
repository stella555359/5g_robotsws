#!/bin/bash
#Author : Rakshith.b@nokia.com

Print_parameters() {

	echo -e "========================================================================================================================"
	echo -e "PARAMETERS:\n========================================================================================================================"
	echo Source SW build=$Source_SW_build
	echo Target SW build=$Target_SW_build
	echo Robot options=$Robot_options
	echo Remove older logs=$Remove_older_logs
	echo RFRL Script path=$UUF_script_path
	echo UUF path=$UUF_path
	echo Log path path=$UUF_path/$Target_SW_build
    echo SCF path=$SCF_path
	echo Robot result path=$Result_path
    echo Jenkins path=$Jenkins_path
}

Verify_parameters() {

	Print_parameters
	if ! [[ $Target_SW_build ]] || ! [[ $Source_SW_build ]]; then
    	echo -e "========================================================================================================================"
		echo -e "Source or Target build not provided !!!!!!!!!"
		echo -e "========================================================================================================================"
		exit 1
	fi
    if [[ $Robot_options =~ "-e" ]] && [[ $Robot_options =~ "-i" ]] ; then
    	echo -e "========================================================================================================================"
		echo -e "-e and -i options cannot be used together in robot command !!!!!!!!!"
		echo -e "========================================================================================================================"
		exit 1
    fi
	Set_parameters
	Get_branch
}

Check_VM_space() {

	Delete_older_logs
	echo -e "========================================================================================================================"
	echo -e "Checking space in VM :"
	df -h
    Create_dir
}

Delete_older_logs() {

	echo -e "========================================================================================================================"
    echo -e "Deleting files older than 14 days from log path :"
    echo "Executing command: find /home/ute/Results/${JOB_NAME}/* -cmin +21600 -print | xargs rm -rf"
    find /home/ute/Results/${JOB_NAME}/* -cmin +21600 -print | xargs rm -rf
    echo "Executing command: find ${WORKSPACE}/* -cmin +21600 -print | xargs rm -rf"
    find ${WORKSPACE}/* -cmin +21600 -print | xargs rm -rf
    if [[ $Remove_older_logs == YES ]] ; then
		echo -e "Deleting all files in path $UUF_path/"
        echo "Executing command: rm -r $UUF_path/"
		rm -r $UUF_path/*
	fi
}

Create_dir() {

	if ! [ -d "$UUF_path/$Target_SW_build" ]; then
		mkdir -p $UUF_path/$Target_SW_build
	fi

	if ! [ -d "$Result_path" ]; then
		mkdir -p $Result_path
	fi
	mkdir $Jenkins_path
}

Upgrade_scripts() {

	if [[ $Upgrade_script == YES ]]; then
    	echo -e "Checking and upgrading to latest csv4all scripts"
		pip install --upgrade taf.rfrl.csv4all > $UUF_path/pip_upgrade.txt
    fi
}

Set_parameters() {

	Set_build_parameters YES
	if [[ $Robot_options =~ "-i sw_upgrade" ]] || [[ $Robot_options == "" ]] ; then
    	Set_build_parameters YES
    elif [[ $Robot_options =~ "-e sw_upgrade" ]] ; then
    	Set_build_parameters NO
    elif [[ $Robot_options =~ "-e" ]] ; then
    	Set_build_parameters YES
    elif [[ $Robot_options =~ "-i" ]] && ! [[ $Robot_options =~ "sw_upgrade" ]]; then
    	Set_build_parameters NO
    fi
    echo -e "Rollback build and Download Build set to $Rollback_build"
}

Set_build_parameters() {

	Rollback_build=$1
	Download_Build=$1
}

Download_build_check() {

	echo -e "========================================================================================================================"
    cd $UUF_path
	if [[ $Download_Build == YES ]] && ! [ -f $UUF_path/"$Target_SW_build"_release_BTSSM_downloadable_A54.zip ]; then
	  echo -e "Build not found, Download_Build set to YES, \nDownloading the build in path $UUF_path"
	  wget_cmd="wget -o $UUF_path/wget_download_log.txt https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/$Branch/$Target_SW_build/"$Target_SW_build"_release_BTSSM_downloadable_A54.zip"
	  echo -e "Executing command: $wget_cmd"
	  $wget_cmd
	  if [ -f $UUF_path/"$Target_SW_build"_release_BTSSM_downloadable_A54.zip ]; then
		echo "Build download successful, log : $UUF_path/wget_download_log.txt"
	  else
		echo -e "Build download failed"
		cat $UUF_path/wget_download_log.txt
		exit 1  	
	  fi	
	elif [ -f $UUF_path/"$Target_SW_build"_release_BTSSM_downloadable_A54.zip ]; then
	  echo -e "Build already available in VM"
	elif [[ $Download_Build != YES ]]; then
	  echo -e "Download_Build set to NO, Build will not be downloaded"
	fi
}

Get_branch() {

	Branch=$(echo $Target_SW_build | cut -d'_' -f1)
	Build_branch=`echo "$Branch" | sed -e 's/SBTS//'`
	if [[ $Branch == SBTS00 ]]; then
		Build_branch=trunk
	fi
	echo Target build Branch : $Build_branch
}

Check_build() {

	if [[ $Rollback_build == YES ]] ; then
		#Rollback_BTS_build
        Verify_BTS_Source_build
        Download_build_check
	fi
}

Rollback_BTS_build() {

	echo -e "========================================================================================================================"
    cd $Execution_path
	Execution_cmd="robot -v Build:$Source_SW_build -T -L TRACE -d $Result_path/Build_rollback -b debug.log -l Build_Rollback_log.html -o Build_Rollback.xml -r Build_Rollback_report.html -t Rollback_BTS_software $Script_path/Build_Upgrade_Rollback.robot"
	echo "Executing command: $Execution_cmd"
	$Execution_cmd
	OUT=$?
	find $Result_path/Build_rollback -maxdepth 1 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Jenkins_path
	if [[ $OUT -eq 0 ]];then
		echo -e '\n'Software rollback to $Source_SW_build successful
	else
	   echo -e '\n'Software rollback to $Source_SW_build failed, Exiting execution sequence
	   exit 1
	fi
}

Verify_BTS_Source_build() {

	Source_Branch=$(echo $Source_SW_build | cut -d'_' -f1)
    SCF_File=$SCF_path/SCF_$Source_Branch.xml
	echo SCF File=$SCF_File
    if ! test -e $SCF_File; then
		echo -e "========================================================================================================================"
		echo -e "SCF file not provided, upgrade build in BTS will not be executed !!!!!!!!!"
		echo -e "========================================================================================================================"
		exit 1
	fi
    cd $Execution_path
	Execution_cmd="robot -v Build:$Source_SW_build -v SCF_file:$SCF_File -T -L TRACE -d $Result_path/Verify_BTS_Source_build -b debug.log -l Verify_BTS_Source_build_log.html -o Verify_BTS_Source_build.xml -r Verify_BTS_Source_build_report.html -t Verify_active_passive_and_Upgrade_BTS_software $Script_path/Build_Upgrade_Rollback.robot"
	echo "Executing command: $Execution_cmd"
	$Execution_cmd
	OUT=$?
	find $Result_path/Verify_BTS_Source_build -maxdepth 1 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Jenkins_path
	if [[ $OUT -eq 0 ]];then
		echo -e '\n'Software rollback to $Source_SW_build successful
	else
	   echo -e '\n'Software rollback to $Source_SW_build failed, Exiting execution sequence
	   exit 1
	fi
}

Verify_Target_build() {

	echo -e "========================================================================================================================"
    cd $Execution_path
	Execution_cmd="robot -v Build:$Target_SW_build -T -L TRACE -d $Result_path/Build_verification -b debug.log -l Build_verify_log.html -o Build_verify.xml -r Build_verify_report.html -t Verify_BTS_software $Script_path/Build_Upgrade_Rollback.robot"
	echo "Executing command: $Execution_cmd"
	$Execution_cmd
	OUT=$?
    find $Result_path/Build_verification -maxdepth 2 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Jenkins_path
	if [[ $OUT -eq 0 ]];then
		echo -e '\n'Build verification successful
	else
		echo -e '\n'Build verification failed, Exiting execution sequence
   	exit 1
	fi
}

Execute_RFRL() {

	Check_build
	cd $UUF_path/$Target_SW_build
	if [[ $Rollback_build == YES ]] ; then
    	echo -e "========================================================================================================================"
		Execution_cmd="robot -L trace -T -b debug.log -i sw_upgrade -V /home/ute/testline_configuration/$(hostname) -v INITIAL_SW:$Source_SW_build -v TARGET_SW:$Target_SW_build -l RFRL_log_upgrade.html -o RFRL_upgrade.xml -r RFRL_report_upgrade.html $UUF_script_path/RFRL_suite_$Build_branch.robot"
		echo "Executing command: $Execution_cmd"
		$Execution_cmd
		OUT=$?
        if [[ $OUT -eq 0 ]];then
			Passed_TC+=( sw_upgrade )
		else
			Failed_TC+=( sw_upgrade )
		fi
	fi
    
    find $UUF_path/$Target_SW_build -maxdepth 1 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Jenkins_path
    find $UUF_path/$Target_SW_build -maxdepth 1 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Result_path
    
    Value=$(echo $Robot_options | tr -d ' ')
    if [[ $Value != -isw_upgrade ]] ; then
		Verify_Target_build
    	cd $UUF_path/$Target_SW_build
    	echo -e "========================================================================================================================"
		Execution_cmd="robot -L trace -T -b debug.log $Robot_options -e sw_upgrade -V /home/ute/testline_configuration/$(hostname) -v INITIAL_SW:$Source_SW_build -v TARGET_SW:$Target_SW_build -l RFRL_log.html -o RFRL.xml -r RFRL_report.html $UUF_script_path/RFRL_suite_$Build_branch.robot"
		echo "Executing command: $Execution_cmd"
		$Execution_cmd
		OUT=$?
        if [[ $OUT -eq 0 ]];then
			Passed_TC+=( e_sw_upgrade )
		else
			Failed_TC+=( e_sw_upgrade )
		fi

		find $UUF_path/$Target_SW_build -maxdepth 1 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Jenkins_path
        find $UUF_path/$Target_SW_build -maxdepth 1 -mindepth 1 -name '*log*.html' |xargs -i cp {} $Result_path
    fi
    
	echo Robot logs copied to path $Result_path
	echo -e "========================================================================================================================"
	if [[ ${#Failed_TC[@]} -eq 0 ]];then
		echo "Execution Successful"
		echo -e "========================================================================================================================"
	else
		echo "Execution failed"
		echo -e "========================================================================================================================\n"
        exit 1
	fi
}

################ Main function #######################

Source_SW_build=SBTS24R3_ENB_0000_000608_000010
Target_SW_build=SBTS00_ENB_9999_250209_000008
Robot_options="-i sw_upgrade -i site_reset"
Remove_older_logs=Yes
RFRL_library=CSV4ALL


JOB_NAME=Local
BUILD_NUMBER=$(date '+%Y_%m_%d_%H_%M_%S')
WORKSPACE=/home/ute/Results/${JOB_NAME}/$Target_SW_build

Source_SW_build=$(echo $Source_SW_build | tr -d ' ')
Target_SW_build=$(echo $Target_SW_build | tr -d ' ')
Passed_TC=()
Failed_TC=()

RFRL_library=CSV4ALL
Result_path=/home/ute/Results/${JOB_NAME}/$Target_SW_build/BUILD_${BUILD_NUMBER}
RFRL_path=/home/ute/RFRL_Scripts
UUF_script_path=$RFRL_path/$RFRL_library
SCF_path=$RFRL_path/SCF
UUF_path=/home/ute/UUF_SW
Script_path=/home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/T05/TMOUS
Jenkins_path=${WORKSPACE}/BUILD_${BUILD_NUMBER}/
Execution_path=/home/ute/MN/UTE/robotws
Upgrade_script=YES

Verify_parameters
Check_VM_space
Upgrade_scripts
Execute_RFRL