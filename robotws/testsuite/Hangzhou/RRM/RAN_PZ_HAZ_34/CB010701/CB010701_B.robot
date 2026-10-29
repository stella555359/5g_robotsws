*** Settings ***
Force Tags    PY36
Documentation     author: qingqing.zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB010701-AA

Resource    ./Resources/CB010701_common_keywords.robot
Variables    ./Resources/CB010701_variables.py


Suite Setup   Run Keywords     Common Suite Setup for COAM
...             AND    Get sagnb release    host=${bts_host}
...             AND    Common Case TestLine Setup prepare
...             AND    Common Case TestLine Setup for gnb2

Suite Teardown   Run Keywords
...              Run Keyword And Ignore Error    Common Suite Teardown for COAM
...              AND    Common Case TestLine Setup recover    AND
...              Adjust gNB_RU Attenuation for 2gnb

*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/SCF/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${tl_scf}    SCF_GNB2_
${interface1}    br1
${expected_tput_ul_T}    120
${expected_tput_ul_T_2TX}    93
${expected_tput_ul_F_bad}    60
${expected_tput_ul_T_100M_bad}    5
${expected_tput_ul_T_100M}    70
${expected_tput_ul_F}    105
${expected_tput_ul_T_good}    180
${expected_tput_dl_T_bad}   150
${expected_tput_dl_F_bad}   10
${expected_tput_dl_F}   40
${expected_tput_dl_T}   215
${expected_tput_dl_T_pcell}   100
${expected_tput_dl_T_scell}   40
${logname_B1_001_attach}    B_B1_001_attach_1208_3TX.pcap
${logname_B1_001_attach1}    B_B1_001_attach1_1208_3TX.pcap
${logname_FDD_to_TDD_failed}    B_B1_001_FDD_change_to_TDD_failed.pcap
${logname_FDD_to_TDD_successful}    B_B1_001_TDD_change_to_FDD_successful.pcap
${logname_B3_001_attach}    B_B3_001_attach_1208_3TX.pcap
${logname_TDD_RSRP_to_bad}    B_B3_001_TDD_RSRP_from_good_to_bad.pcap
${biplog_bad_RSRP}    l1l2bip_bad_RSRP/l1l2bip_bad_RSRP.pcap
${biplog_good_RSRP}    l1l2bip_good_RSRP/l1l2bip_good_RSRP.pcap
@{allow_fault_list}    4098    62003    7311    7307
*** Test Cases ***
[1]CB010701_ET_B_B1_001_A1_based_Scell_Change_fail_for_FT_UL_CA_2CCs_with_3Tx
    [Documentation]
    ...    This user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
    ...    type A with feature enabled for FDD + TDD FR1 scenario.
    [Tags]    classical
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify Parameters for Cases   gnb_index=${1}    Add_Mo_Online=${PARAMETERS_ONLINE_ADD_GNB2_B_B1_001_pre}
    ...    Add_Para_Online=${PARAMETERS_TO_ADD_Parametre_GNB2_B_B1_001}    Modify_Para_Online=${PARAMETERS_ONLINE_MODIFY_GNB2_B_B1_001}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${20}    gnb2_cell3_value4=${20}
    MTK UE reboot
    Wait until keyword succeeds    4x   10s    MTK UE Down all ccmni
    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
    bollinger attach and collect log    logname=${logname_B1_001_attach}
    Check wireshark log for 2CC    logname=${logname_B1_001_attach}    scell_index=${1}    pcell_index=${31}
    Start DLUL traffic and check throughput   logname=${logname_B1_001_attach}
    ...    scellid=1   pcellid=31    tput_dl_pcell=${expected_tput_dl_T_bad}    tput_dl_scell=${expected_tput_dl_F_bad}
    ...    tput_ul_pcell=${expected_tput_ul_T}     tput_ul_scell=${expected_tput_ul_F}    duration=10s
    Start BTSlogs Collection
    Scell change and collect log    logname=${logname_FDD_to_TDD_failed}
    Stop Btslogs Collection
    Start DLUL traffic and check throughput
    ...    scellid=1   pcellid=31    tput_dl_pcell=${expected_tput_dl_T_bad}    tput_dl_scell=${expected_tput_dl_F_bad}
    ...    tput_ul_pcell=${expected_tput_ul_T}     tput_ul_scell=${expected_tput_ul_F}    duration=10s
    Check scell TDD to FDD failed    logname=${logname_FDD_to_TDD_failed}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_ONLINE_MODIFY_B_B1_001_weight}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${20}    gnb2_cell3_value4=${20}
    Start DLUL traffic and check throughput
    ...    scellid=1   pcellid=31    tput_dl_pcell=${expected_tput_dl_T_bad}    tput_dl_scell=${expected_tput_dl_F_bad}
    ...    tput_ul_pcell=${expected_tput_ul_T}     tput_ul_scell=${expected_tput_ul_F}    duration=10s
    Scell change and collect log    logname=${logname_FDD_to_TDD_successful}    PA_value=${10}
    Check scell FDD to TDD successful    logname=${logname_FDD_to_TDD_successful}
    Start DLUL traffic and check throughput
    ...    scellid=3    pcellid=31    tput_dl_pcell=${expected_tput_dl_T_pcell}    tput_dl_scell=${0}
    ...    tput_ul_pcell=${expected_tput_ul_T_2TX}    tput_ul_scell=${0}    duration=30s
    Stop UE DLUL traffic    ue_index=${-1}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}    AND
    ...    Run Keyword And Ignore Error    Case Teardown

[1]CB010701_ET_B_B3_001_IWK_with_CB006086_for_FT_UL_CA_2CCs_with_3Tx
    [Documentation]
    ...    This user scenario describes the single UE peak throughput when FDD cell is configured with PUSCH mapping
    ...    type B with feature enabled for TDD FR1 + FDD scenario.
    [Tags]    classical
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4098,62003,7311,7307
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_ONLINE_MODIFY_GNB1_B_B3_001}
    MTK UE reboot
    Wait until keyword succeeds    4x   10s    MTK UE Down all ccmni
    MTK prepare UE    ue_type=${ue_type}    ue_index=${-1}
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${10}    gnb2_cell3_value4=${10}
    bollinger attach and collect log    logname=${logname_B3_001_attach}
    Check wireshark log for 2CC    logname=${logname_B3_001_attach}
    Start BTSlogs Collection
    TDD RSRP change with traffic and collect bip   logname=${logname_B3_001_attach}
    Stop Btslogs Collection
    Check the FDD symbol mute    biplog=${biplog_bad_RSRP}
    Check the FDD symbol not mute    biplog=${biplog_good_RSRP}
    [Teardown]    run keywords
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${-1}    AND
    ...    Run Keyword And Ignore Error    Case Teardown


*** Keywords ***
Common Case TestLine Setup for gnb2
    Modify SCF first then Perform Commission    gnb_index=${1}    scf_file_name=${tl_scf}${release_info}.xml
    ...    MOsToAdd=${MOS_ADD_GNB2}    ParameterToDelete=${PARAMS_TO_delete_AA_B4_001}
    ...    ParamterToModify=${PARAMETERS_ONLINE_MODIFY_GNB2_B}     ListToAdd=${LIST_TO_ADD_AA_B3_001}
    Modify Parameters for Cases   gnb_index=${1}    Modify_Para_Online=${PARAMETERS_MODIFY_GNB2_FOR_UL}

Scell change and collect log
    [Arguments]    ${logname}    ${gnb_index}=${1}    ${PA_value}=${0}
    Start capture gNB log on master    filename=${logname}    gNB_index=${gnb_index}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${PA_value}   gnb2_cell3_value2=${PA_value}
    ...    gnb2_cell3_value3=${PA_value}   gnb2_cell3_value4=${PA_value}
    sleep    2s
    Stop and download the Logs    filename=${logname}   gNB_index=${gnb_index}
    [Teardown]    Run Keyword And Ignore Error    Stop and download the Logs    filename=${logname}   gNB_index=${gnb_index}

Check scell FDD to TDD successful
    [Arguments]    ${logname}
    Log    Check scell FDD to TDD successful
    ${measId}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 13 && nr-rrc.measId
    ...    xpath=.//nr-rrc.criticalExtensions
    Should be equal    ${measId}[0]    0
    Check wireshark log for 2CC    logname=${logname}    scell_index=${3}    pcell_index=${31}

Check scell TDD to FDD failed
    [Arguments]    ${logname}
    Log    Check scell TDD to FDD successful
    ${measId}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 13 && nr-rrc.measId
    ...    xpath=.//nr-rrc.criticalExtensions
    Should Contain X Times    ${measId}    0     4
    ${scell}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode ==7 and nr-rrc.sCellToAddModList == 1
    ...    xpath=.//nr-rrc.physCellId
    Should be empty    ${scell}

TDD RSRP change with traffic and collect bip
    [Arguments]    ${logname}=NULL
    ...    ${dl_throughput}=${Send_Tput_DL}    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${-1}
    ...    ${dl_port}=${DL_PORT}    ${gnb_index}=${1}    ${seg_size}=1180
    ...    ${dl_length}=1024B    ${duration}=30s
    run keyword If    '${logname}'!='NULL'
    ...    Start UE DLUL traffic MTK    dl_port=${dl_port}    dl_throughput=${dl_throughput}    ul_throughput=${ul_throughput}
    ...    seg_size=${seg_size}    ue_index=${ue_index}    dl_length=${dl_length}    logname=${logname}
    Start capture gNB log on master    filename=${logname_TDD_RSRP_to_bad}    gNB_index=${gnb_index}
    Sleep    2s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${55}    gnb2_cell3_value4=${55}
    Sleep    2s
    Stop and download the Logs    filename=${logname_TDD_RSRP_to_bad}   gNB_index=${gnb_index}
    Check maxrank for TDD    logname=${logname_TDD_RSRP_to_bad}
    Check 2CC DLUL tput    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F_bad}    tput_dl_scell=${expected_tput_dl_T_bad}
    ...    tput_ul_pcell=${expected_tput_ul_F_bad}    tput_ul_scell=${expected_tput_ul_T_100M_bad}    duration=${duration}
    Collect Interface Mirroring Bip Collector from WEBUI    gnb_index=${gnb_index}    times=1s    target_file_name=l1l2bip_bad_RSRP
    ${biplog_bad_RSRP}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=l1l2bip_bad_RSRP
    Sleep    5s
    Adjust gNB_RU Attenuation for 2gnb    gnb2_cell1_value1=${0}    gnb2_cell1_value2=${0}    gnb2_cell1_value3=${0}
    ...    gnb2_cell1_value4=${0}    gnb2_cell3_value1=${10}    gnb2_cell3_value4=${10}
    Sleep    2s
    Check 2CC DLUL tput    scellid=31    pcellid=1    tput_dl_pcell=${expected_tput_dl_F}    tput_dl_scell=${expected_tput_dl_T}
    ...    tput_ul_pcell=${expected_tput_ul_F}    tput_ul_scell=${expected_tput_ul_T_good}    duration=${duration}
    Collect Interface Mirroring Bip Collector from WEBUI    gnb_index=${gnb_index}    times=1s    target_file_name=l1l2bip_good_RSRP
    ${biplog_good_RSRP}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=l1l2bip_good_RSRP
    Stop UE DLUL traffic    ue_index=${-1}
    [Teardown]    Run Keyword And Ignore Error    Stop and download the Logs    filename=${logname_TDD_RSRP_to_bad}   gNB_index=${gnb_index}

Check maxrank for TDD
    [Arguments]    ${logname}
    Log    Check scell maxrank for TDD
    ${maxRank}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 12 && nr-rrc.maxRank
    ...    xpath=.//nr-rrc.maxRank
    Should be equal    ${maxRank}[0]    2

Check the FDD symbol mute
    [Arguments]    ${biplog}
    ###check TDD slot 9 and 19 send ASR
    ${Symbol_ASRS}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 1) && (UlData_puschReceiveReqGrant_t.numOfPuschSymbols == 13)
    ...    xpath=.//UlData_puschReceiveReqSubcell_t.slotForProcessing
    Should Not Contain Any    ${Symbol_ASRS}    4    14
    Should Contain    ${Symbol_ASRS}    9    19
    ${Symbol_ASRS}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 1) && (UlData_puschReceiveReqGrant_t.numOfPuschSymbols == 14)
    ...    xpath=.//UlData_puschReceiveReqSubcell_t.slotForProcessing
    Should Contain Any    ${Symbol_ASRS}    4    9    14    19
    ###check FDD slot 4 and 9 mute
   ${Symbol_slot4}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 2) && (UlData_puschReceiveReqSubcell_t.slotForProcessing == 4)
    ...    xpath=.//UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    Should be Equal    ${Symbol_slot4}[0]    13
    Should Not Contain    ${Symbol_slot4}    14
    ${Symbol_slot9}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 2) && (UlData_puschReceiveReqSubcell_t.slotForProcessing == 9)
    ...    xpath=.//UlData_puschReceiveReqGrant_t.numOfPuschSymbols
    Should be Equal    ${Symbol_slot9}[0]    13
    Should Not Contain    ${Symbol_slot9}    14

Check the FDD symbol not mute
    [Arguments]    ${biplog}
    ${Symbol_ASRS}=     Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 1) && (UlData_puschReceiveReqGrant_t.numOfPuschSymbols == 13)
    ...    xpath=.//UlData_puschReceiveReqSubcell_t.slotForProcessing
    Should be empty    ${Symbol_ASRS}
    ${Symbol_mute}=   Check wireshark log    logname=${biplog}
    ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 2) && (UlData_puschReceiveReqGrant_t.numOfPuschSymbols == 13)
    ...    xpath=.//UlData_puschReceiveReqSubcell_t.slotForProcessing
    Should be empty    ${Symbol_mute}