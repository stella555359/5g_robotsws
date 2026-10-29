** Settings ***
Documentation
    ...     [Procedure]             "N-2, N-1 to N update and rollback"
    ...     [Date]                  "24-01-24"
    ...     [Author]                "N Arun Kumar"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Upgrade Rollback"
    ...     [Feature_ID]            "SMTRS-32059"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "PET testline"
    ...     [Config]                "Load 23R3 and make stable"

Suite Setup       Setup Oamops
Suite Teardown    Teardown Oamops
Variables         ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/resources/common_keywords_PET.robot
Resource        ${CURDIR}/resources/common_keywords.robot
Resource        ${CURDIR}/resources/call_verify.robot

*** Variables ***
${Trunk}       Trunk_ENB
${25R3}        SBTS25R3
${25R2}        SBTS25R2
${expected_alarms}      [4655, 4654, 4459, 61649, 61524, 61652, 4656, 4681, 4592,7304]
${unexpected_alarms}        [6450, 10, 61644, 1850, 4082]
${counter_analysis_file_name}       rp000589_counters_analysis.json

*** Test Cases ***
[1][1]PET_N-2_N-1_to_N_update and rollback
###########    Load 25R2 by removing sw config from BTS   ##################
    Load 25R2
    Perform 25R2 Commissioning
    Auto Upgrade Build      ${25R2}
    Check Mplane Connectivity
    Check BTS Status
    Collect list of Alarms Before Upgrade
    Verify PM counters
    Verify ET Calls
    Verify PM counters
    Delete Old Builds
###########   Load trunk (N-2 to N upgrade)  #################################
    Auto Upgrade Build      ${Trunk}
    Check Mplane Connectivity
    Check BTS Status
    Verify Unexpected alarms After Upgrade
    Verify PM counters
    Verify ET Calls
    Verify PM counters
    Rollback BTS Software
    Check Mplane Connectivity
    Check BTS Status
    Collect list of Alarms Before Upgrade
    Delete Old Builds
############    Load 25R3 (N-2 to N-1)   ######################################
    Auto Upgrade Build      ${25R3}
    Check Mplane Connectivity
    Check BTS Status
    Verify Unexpected alarms After Upgrade
    Verify PM counters
    Verify ET Calls
    Verify PM counters
    Collect list of Alarms Before Upgrade
    Delete Old Builds
#########    Load trunk (N-1 to N)    #############################################
    Auto Upgrade Build      ${Trunk}
    Check Mplane Connectivity
    Verify Unexpected alarms After Upgrade
    Verify PM counters
    Verify ET Calls
    Verify PM counters
    Check BTS Status
    Delete Old Builds
*** Keywords ***

Delete Old Builds
    Run     cd /home/ute/fw_user_path/testcases/SMTRS-32059/execution_logs/
    Run     rm *.Zip

Check Mplane Connectivity
    Setup Remote Access     remote_device=mplane
    [Teardown]          Teardown Remote Access          alias=default

Verify PM counters
    sleep   120
    PM Counters Start      analysis=verify_ip_counters      counter_analysis_file=${counter_analysis_file_name}

Perform 25R2 Commissioning
    Perform Commissioning       scf_file=${25R2_SCF}     verify_bts_status=${False}     timeout=600     alias=default
    ...     skip_parameter_relation_errors=True
	Sleep   600

Upgrade BTS software to latest software
	[Arguments]    ${profile}
	${Build_name}=       Run     ls -lrt /home/ute/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/SMTRS-32059/Build/${profile}
    ...     | awk 'END{print}' | awk '{print $9}'
	Perform Software Download And Update      package=/home/ute/robotws/testsuite/Bangalore/TRS/E2E_BTS_TRS_FW/fw_user_path/testcases/
    ...     SMTRS-32059/Build/${profile}      activate_sw=true      update_timeout=3000        wait_for_bts_to_be_ready=1800
    Sleep    120

Auto Upgrade Build
    [Arguments]    ${Build}
    Perform Software Download And Update        package=auto        wft_profile=${Build}       activate_sw=true        timeout=800
    sleep   600

Rollback BTS Software
    Rollback Software       verify_bts_status=${False}      is_config_reset=false       timeout=600
    Sleep       60

Check BTS Status
    sleep   120
    Verify Bts Status       should_be_onair=${True}     wait_for=60        timeout=60       alias=default
    sleep   120

Load 25R2
    #delete sw config from BTS
    Setup Remote Access     remote_device=bts    alias=bts
    Execute Interactive Remote Command     command= rm -rf /ffs/run/config     alias=bts
    Execute Interactive Remote Command     command= reboot     alias=bts
    Teardown Remote Access  alias=bts
    Sleep   1000
    Auto Upgrade Build      ${25R2}

Collect list of Alarms Before Upgrade
    sleep   120
    ${alarms_before_upgrade}             Verify Alarm       timeout=300
    Set Suite Variable       ${alarms_before_upgrade}        ${alarms_before_upgrade}

Verify Unexpected alarms After Upgrade
    sleep   120
    Verify Alarm      prev_alarms=${alarms_before_upgrade}      timeout=300