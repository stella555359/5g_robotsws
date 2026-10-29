*** Settings ***
Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description:

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB009823

*** Variables ***
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files/wts
${dl_tput}                       100
${ul_tput}                       100
@{SA_UE_List}                    1
@{SA_Scell_Index}                0
${RI_PWR}                        SEPARATOR=
...                              -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,-105,
...                              -99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47
${RI_PWR_2}                      SEPARATOR=
...                              -55,-60,-65,-70,-75,-80,-85,-90,-95,-100,-105,-110,-115,-115,-115,-115,-115,-115,
...                              -115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115,-115

*** Test Cases ***
CB009823_TC01_Verify_RIM_RS1_RS2_Transmission_and_detection_depending_on_RI_detection_5GC001116_4GP_0ms_Framework_1_NearCfg_realGnb_as_Aggressor
    [Documentation]    Verify_RIM_RS1_RS2_Transmission_and_detect_depending on RI detect_5GC001116_4GP_0ms_Framework_1_NearCfg_realGnb_as_Aggressor
    [Tags]    AP_REG    9823_TC01
    [Setup]    Generic Test Setup    feature=CB009823    cell_deployment=SA
    Register and Start Traffic For SA UEs    ${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    pdu=1
    Sleep    30s
    Validate throughput from UE stats for all UEs    ${SA_UE_List}    ${dl_tput}    ${ul_tput}    scell=${SA_Scell_Index}
    Generate Remote Interference    RI_PWR=${RI_PWR}
    Generate RIMRS
    Sleep    30s
    Validate interference UL tput    ${SA_UE_List}    ${ul_tput}    ${SA_Scell_Index}
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=1
    [Teardown]    Generic Test Teardown    feature=CB008285    sa_ue_list=${SA_UE_List}    scf_update=false

CB009823_TC02_Verify_RIM_RS1_RS2_Transmission_and_detection_depending_on RI detection_NearCfg_realGnb_both_victim_aggressor
    [Documentation]    Verify_RIM_RS1_RS2_Transmission_and_detect_depending_on RI detect_NearCfg_realGnb_both_victim_aggressor
    [Tags]    AP_REG    9823_TC02
    [Setup]    Generic Test Setup    feature=CB009823    cell_deployment=SA
    Register and Start Traffic For SA UEs    ${SA_UE_List}    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    pdu=1
    Sleep    30s
    Validate throughput from UE stats for all UEs    ${SA_UE_List}    ${dl_tput}    ${ul_tput}    scell=${SA_Scell_Index}
    Generate Remote Interference    RI_PWR=${RI_PWR_2}
    Generate RIMRS
    Sleep    30s
    Validate interference UL tput    ${SA_UE_List}    ${ul_tput}    ${SA_Scell_Index}
    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=1
    [Teardown]    Generic Test Teardown    feature=CB008285    sa_ue_list=${SA_UE_List}    scf_update=false


*** Keywords ***
Generate Remote Interference
    [Arguments]    ${RI_PWR}    ${profile_id}=7
    Execute Egate Command
    ...    cmd=remote_interference_testmode_nr profile_id\=${profile_id} start_symbol_position\=0 num_of_symbols\=32 noise_power_values\=${RI_PWR}
    Sleep    5s
    Execute Egate Command
    ...    cmd=cell_testmode_set_nr testmode\=remote_interference gnb\=2 cell_id\=1 profile_id\=${profile_id} action\=activate

Generate RIMRS
    [Arguments]    ${profile_id}=50    ${rsPattern1Period}=50
    ${rim_rs_profile1}=    Catenate    SEPARATOR=
    ...    rimrs_testmode_nr profile_id=${profile_id} config_mode=standalone victim_cell=1 aggressor_cell=1 rsSetId=12345 rimRsTxPower=-330
    ...    \ propagation_delay=16 rimRsType=rsType1 rsNearFarConfig=1 rsSetId=65432 propagation_delay=16 rimRsType=rsType2 numRsSetId=1
    ...    \ rsNearFarConfig=1 rsType1NScId=1,2,3,4 rsPattern1Period=${rsPattern1Period} rsPattern2Period=25 factorRsSequence=1 offsetRsSequence=1
    ...    \ startFreqOffsetForRs=2,50 repetitionRsType1=2 repetitionRsType2=2 numRsType1SetId=131072
    ...    \ rim_framework=framework_1 startRbForRs=2,50 rsType2NScId=5,6,7,8 factorRsSequenceRS2=1 offsetRsSequenceRS2=1
    Execute Egate Command     cmd=${rim_rs_profile1}
    Sleep    5s
    Execute Egate Command     cmd=cell_testmode_set_nr testmode\=rim_rs gnb\=2 cell_id\=1 profile_id\=${profile_id} action\=activate

Validate interference UL tput
    [Arguments]    ${ue_list}    ${expected_ul_tput}    ${scell}
    FOR    ${ue_id}    IN    @{ue_list}
        Log To Console    Going To Check UE stats for  UE: ${ue_id}
        ${ul_tput}    Get Throughput from all cells    ${ue_id}    scell=${scell}    type=pusch
        Average UE stats throughput Should Be Interfered    ${ul_tput}    ${expected_ul_tput}
    END

Average UE stats throughput Should Be Interfered
    [Arguments]    ${cell_total}    ${expected_tput}
    ${result_cell}    Evaluate    int(${expected_tput} * 0.5) >= int(${cell_total}) >= int(${expected_tput} * 0)
    Run Keyword If    not ${result_cell}    FAIL
    ...    msg = Total TPut is not as expected. cell: ${result_cell}
