*** Settings ***
Resource    Resources/CB011039_common_keyword.robot
Variables    Resources/CB011039_variables.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Force Tags    RAN_5G   RAN_5G_TDD   STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOB1_AQHA_AHPH_2xAHPF   SBTS00   CRT
...   PY39

Suite Setup    CB011039 Test Case Suit Setup

*** Variables ***
${tl_scf_dir_path}     commissionings/HGZ


*** Test Cases ***
[1]CB011039_G_3_CB011039_SR_G_003_Radio_Module_snapshot_collection_during_fail_safe_mode_AHPH
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    AlarmWatchdog.add_allow_alarms    fault_id=${faults_list}
    CB011039_Enable_fail_safe_mode_via_enable_command
    Check Logs Detail when RU in Fail Safe Mode
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    ${version}=    Set Variable If
    ...     '${stream}'=='SBTS24R3'        SBTS24R3
    ...     '${stream}'=='SBTS25R1'        SBTS25R1
    ...     '${stream}'=='SBTS25R3'        SBTS25R3
    ...     '${stream}'=='SBTS25R2'        SBTS25R2
    ...     SBTS00
    ${prefix_name}    Set Variable If   '${version}'=='SBTS24R3' or '${version}'=='SBTS25R1'    BTS    BTS${mrbtsID}
    Verify RFSW Log Include In Snapshot    ru_alias=RU_2    ru_index=2    prefix_name=${prefix_name}
    [Teardown]    CB011039_Case_Teardown_via_disable_command

[1]CB011039_H_13_CB011039_SR_H_001_Radio_Module_online_dignostics_test_during_fail_safe_mode_AQHA
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    ...                                                       scf_path=${tl_scf_dir_path}/${testline_name}/SCF_SBTS24R3_980.xml
    AlarmWatchdog.add_allow_alarms    fault_id=${faults_list}
	CB011039_Enable_fail_safe_mode_via_suspend_node
    Check Logs Detail when RU in Fail Safe Mode    ru_index=1
	CB011039 Diagnostic Check
	CB011039 trigger RU Input Voltage High
	CB011039 Diagnostic Check    checkPoints=${CB011039_CheckPoint10_NOK}
    [Teardown]    CB011039_Case_Teardown_via_restore_node
