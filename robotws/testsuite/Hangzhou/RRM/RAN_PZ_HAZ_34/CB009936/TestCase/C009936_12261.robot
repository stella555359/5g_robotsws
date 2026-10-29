*** Settings ***
Force Tags    PY36
Documentation     author: qingqing zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008140-AB

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_Case_Step.robot

Suite Setup    Run Keywords
...               robot_common_operations.Common Suite Setup
...               AND    Common Suite Setup for COAM
...               AND    Common Case TestLine Setup for gnb1

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/SCF/
${expected_tput_ul_60M}    64
${filename_gnb1_12261_attach}    CB009936_CB012261_attach.pcap
@{allow_fault_list}    4098    62003    7311    7307
${biplog_UL}    l1l2bip_ul/l1l2bip_ul.pcap
*** Test Cases ***
[1]CB009936_CB012261_SR_B_03_B1-Controlling_number_of_PRBs_available_for_PUSCH_when_FDAGC_PRACH_algorithm_is_enabled_and_disabled
    [Documentation]
    ...    This case is check bip when enable actPrachMultiplexingLevel
    [Tags]    classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Prepare MultiUE with client
    MCS SETUP AND SET ATT for dingli_UE    gnb_cell1_PA_value_dingli_UE0=${25}
    ...    gnb_cell1_PA_value_dingli_UE1=${25}
    Two UEs Attach and check tput    filename=${filename_gnb1_12261_attach}
    ...    tput_ul_expect=${expected_tput_ul_60M}
    [Teardown]    Common Case Teardown for COAM

*** Keywords ***
Common Case TestLine Setup for gnb1
    ${release_info}    Get sagnb release
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...    golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}.xml
    ...    ParameterToDelete=${PARAMS_TO_delete_GNB1_12261}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_12261}    ListParamterToModify=${LIST_TO_modify_GNB1_12261}
    ...    ListToAdd=${LIST_TO_ADD_GNB1_12261}    skip_parameter_relation_errors=False

Two UEs Attach and check tput
    [Arguments]    ${filename}    ${tput_ul_expect}=${expected_tput_ul_60M}
    Two UEs attach and collect log    filename=${filename}
    Start UL Data Transfer with pioneer client    ues_index=${${0},${2}}
    Check traffic with pioneer client with pioneer client    tput_target=${tput_ul_expect}    ues_index=${${0},${2}}
    Collect Interface Mirroring Bip Collector from WEBUI    gnb_index=${gnb_index}    times=1s    target_file_name=l1l2bip_ul
    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=l1l2bip_ul
    Check the two UE pusch    biplog=${biplog_UL}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Stop UL Data Transfer with pioneer client    ues_index=${${0},${2}}
    ...    AND    Run Keyword And Ignore Error    Detach MultiUE    ue=${uegroup}
    ...    AND    Run Keyword And Ignore Error    client.stoplog      service=pioneer

Two UEs attach and collect log
    [Arguments]    ${filename}    ${gNB_index}=${0}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
    MultiUEs Attach with client    apn=weistatic
    Sleep    5s
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

Check the two UE pusch
    [Arguments]    ${biplog}
    ###get SFN
    ${SFN}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq||uldata_prachreceivereq) && (3gpp.subcellid == 0 ||3gpp.subcellid == 1) && (3gpp.slot == 19)
    ...    xpath=.//UlData_prachReceiveReqSubcell_t.sfnForProcessing
    ###get two UEs pusch PRB num
    ${UEs_pusch}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 0 ||3gpp.subcellid == 1) && (3gpp.slot == 19) && (3gpp.sfn == ${SFN}[1])
    ...    xpath=.//UlData_puschReceiveReqGrant_t.startPrb
    ${UE1_pusch_start}    Set Variable    ${UEs_pusch}[0]
    ${UE2_pusch_start}    Set Variable    ${UEs_pusch}[1]
    ${UEs_numofpusch}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 0 ||3gpp.subcellid == 1) && (3gpp.slot == 19) && (3gpp.sfn == ${SFN}[1])
    ...    xpath=.//UlData_puschReceiveReqGrant_t.numOfPrb
    ${UE1_pusch_num}    Set Variable    ${UEs_numofpusch}[0]
    ${UE2_pusch_num}    Set Variable    ${UEs_numofpusch}[1]
    ###get prach prb
    ${prachPrbOffset}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_prachreceivereq) && (3gpp.subcellid == 0 ||3gpp.subcellid == 1) && (3gpp.slot == 19) && (3gpp.sfn == ${SFN}[1])
    ...    xpath=.//UlData_prachReceiveReqSubcell_t.prachPrbOffset
    Run Keyword If    ${UE1_pusch_start} < ${UE2_pusch_start}    Run Keywords
    ...    Should be True    ${${UE1_pusch_start}+${UE1_pusch_num}} == ${prachPrbOffset}[0]
    ...    AND    Should be True    ${${prachPrbOffset}[0]+${12}} == ${UE2_pusch_start}
    ...    ELSE    Run Keywords    Should be True    ${${UE2_pusch_start}+${UE2_pusch_num}} == ${prachPrbOffset}[0]
    ...    AND    Should be True    ${${prachPrbOffset}[0]+${12}} == ${UE1_pusch_start}