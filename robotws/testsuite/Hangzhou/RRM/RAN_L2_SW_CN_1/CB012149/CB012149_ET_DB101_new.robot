*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11       owner_qiaren
Resource          ./../CUDU_L2/common_setup_teardown.robot

Documentation
...     12149  interwork With 11080

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                CB012149_ET_DB101_SCFC_new.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/WTS/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/WTS/iphy_CB012149_iwk_6cc.xml
${WTS_CFG}                  CB012149_new_case.lua

${UE_1}                     1
${UE_3}                     3
${PDU_ID}         1
${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
${CELL7_UE_ENDNUM}          40
${CELL6_UE_ENDNUM}          240
${CELL7_CA_UE_ENDNUM}         20
${CELL6_CA_UE_ENDNUM}          220
${6CC_NUM}                  6
@{3T3F_DL_TPUT}        0.5    1    1    1    1    1
@{2T4F_DL_TPUT_LIST}        1    1    1    1    1    1
@{UL_TPUT_LIST}         0.1    0.1
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
${FILTER1}                  "0", "0,0", "0,0,0", "0,0,0,0", "0,0,0,0,0"
@{HARQU_LIST}    UlData_UePuschReceiveRespHarqUL1sw_t.crc    UlData_UePuschReceiveRespHarqUL1sw_t.dtx
@{HARQD_LIST}    UlData_puschReceiveRespHarqDGrantsL1sw_t.ackCrcCheck    UlData_puschReceiveRespHarqDGrantsL1sw_t.dtxAckMoreThan1Bit
@{RESPPS_LIST}    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    ...    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
@{COUNTER_LIST}           M55118C00053    M55118C00001    M55118C00004
&{COUNTER_INFO_1}             cell_id=7    MO_name=NCAC    counter_ids_list=${COUNTER_LIST}
&{COUNTER_INFO_2}             cell_id=6    MO_name=NCAC    counter_ids_list=${COUNTER_LIST}
@{COUNTER_CHECK}        ${COUNTER_INFO_1}    ${COUNTER_INFO_2}

${A2_COMMAND}   ue_measurement_send_nr  id\=3 meas_id\=9 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=5 scell_rsrp\=100 scell_rsrq\=100
...    scell\=4 scell_rsrp\=60 scell_rsrq\=60


*** Test Cases ***
CB012149_ET_DB101_1T_1F_Tx_Switching_UL_Data_Scheduling_With_CB006086_And_5GC002396
     [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
    Cell7_Ues_Attach_Start_traffic
    Cell6_Ues_Attach_Start_traffic
    Multi-ue VONR setup
    Start traffic for VONR UEs
    Run Keyword And Continue On Failure    Check_All_Ue_Tput
    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=1
    Check DTX And ACKNACK From BipLog    1
    Wait Until PM Counter Update
    Wait Until Keyword Succeeds    10min    2min    Check PM Counters

*** Keywords ***
Configure IP For UEC2
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3

Cell7_Ues_Attach_Start_traffic
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_UE_ENDNUM}
        Single Ue Attach    ${ue_id}    ${AMF1_REGION}
    END
    #\    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${6CC_SCELL_PCI_2T4F}    ${6CC_NUM}
    Send A1 report    ${UE_1}   120    56    1
    Start SA UE Big DL Traffic Internal    ${UE_1}    600
    SA Start UL Traffic Internal    ${UE_1}     1    60
    FOR    ${ue_id}    IN RANGE    2    ${${CELL7_CA_UE_ENDNUM}}
         Send A1 report    ${ue_id}   120    56    1
         SA Start DL Traffic Internal    ${ue_id}    1    80    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    ${CELL7_CA_UE_ENDNUM}    ${CELL7_UE_ENDNUM}
         SA Start DL Traffic Internal    ${ue_id}    1    30    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
    END

Cell6_Ues_Attach_Start_traffic
    FOR    ${ue_id}    IN RANGE    201    ${CELL6_UE_ENDNUM}
        Single Ue Attach    ${ue_id}    ${AMF2_REGION}
    END
    FOR    ${ue_id}    IN RANGE    201    ${CELL6_CA_UE_ENDNUM}
         Send A1 report    ${ue_id}   120    55    1
         SA Start DL Traffic Internal    ${ue_id}    1    80    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    ${CELL6_CA_UE_ENDNUM}    ${CELL6_UE_ENDNUM}
         SA Start DL Traffic Internal    ${ue_id}    1    30    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
    END

Multi-ue VONR setup
    FOR    ${ue_id}    IN RANGE    11    20
         Trigger 5QI 5 Setup    ${ue_id}
         Trigger 5QI 1 Setup    ${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    211    220
         Trigger 5QI 5 Setup    ${ue_id}
         Trigger 5QI 1 Setup    ${ue_id}
    END

Start traffic for VONR UEs
    FOR    ${ue_id}    IN RANGE    11    20
        Start SA VONR GBR DL And UL Traffic    ueId=${ue_id}    qfi_id=3    dl_trf=2    ul_trf=1
    END
    FOR    ${ue_id}    IN RANGE    211    220
        Start SA VONR GBR DL And UL Traffic    ueId=${ue_id}    qfi_id=3    dl_trf=2    ul_trf=1
    END

Check_All_Ue_Tput
    [Documentation]    This keyword is to verify multi-UEs
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${3T3F_DL_TPUT}    ${6CC_NUM}
    Wait Until Keyword Succeeds    30s    5s    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${UL_TPUT_LIST}    ${6CC_NUM}
    FOR    ${ue_id}    IN RANGE    2    ${CELL7_UE_ENDNUM}
        SA Check UE Cell TPut On Target    ${ue_id}    1    dl    0
        SA Check UE Cell TPut On Target    ${ue_id}    1    ul    0
    END
    FOR    ${ue_id}    IN RANGE    201    ${CELL6_UE_ENDNUM}
        SA Check UE Cell TPut On Target    ${ue_id}    1    dl    0
        SA Check UE Cell TPut On Target    ${ue_id}    1    ul    0
    END

Check PM Counters
    ${counter_check_dict}    Get Multi Cells Multi PM Counters Max Values With Admin    ${COUNTER_CHECK}
    Run Keyword And Continue On Failure    Should Be True    ${counter_check_dict.cell7.M55118C00053}>=1
    Run Keyword And Continue On Failure    Should Be True    ${counter_check_dict.cell7.M55118C00001}>=1
    Run Keyword And Continue On Failure    Should Be True    ${counter_check_dict.cell7.M55118C00004}>=1
    Run Keyword And Continue On Failure    Should Be True    ${counter_check_dict.cell6.M55118C00053}==0
    Run Keyword And Continue On Failure    Should Be True    ${counter_check_dict.cell6.M55118C00001}>=1
    Run Keyword And Continue On Failure    Should Be True    ${counter_check_dict.cell6.M55118C00004}>=1



Send A1 report
    [Arguments]    ${ue_id}    ${srsrp_nr}=70    ${phycell_id}=50    ${meas_id}=1
    [Documentation]    This keyword is to trigger A1 scell added.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | the id of ue |
    ...    | srsrp_nr | Yes | the value of srsrp_nr |
    ...    | phycell_id | Yes | phycell id of the cell |
    ...
    ...    Examples:
    ...    | Send A1 report | 1 | 70 | 50 |
    ute_wtssim.Execute Egate Command
    ...    ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} phycell_id\=${phycell_id}

Single Ue Attach
    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
    Log To Console    UE${ue_id} Start Attach...
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${PDU_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=${ue_id} registered_amf\=${MCC}:${MNC}|${amf_region}
    #Sleep    0.5s    reason=wait for taking effect
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${PDU_ID} ue=${ue_id} nwslice=1
    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes

 Check DTX And ACKNACK From BipLog
    [Arguments]    ${logId}=1
    Convert BIP Msg To CSV File    ${logId}    uldata_puschreceiverespharqul1sw    ${HARQU_LIST}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqul1sw    UlData_UePuschReceiveRespHarqUL1sw_t.crc    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqul1sw    UlData_UePuschReceiveRespHarqUL1sw_t.dtx    ${FILTER1}
    Convert BIP Msg To CSV File    ${logId}    uldata_puschreceiverespharqdl1sw    ${HARQD_LIST}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqdl1sw
    ...    UlData_puschReceiveRespHarqDGrantsL1sw_t.ackCrcCheck    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqdl1sw
    ...    UlData_puschReceiveRespHarqDGrantsL1sw_t.dtxAckMoreThan1Bit    ${FILTER1}

    Convert BIP Msg To CSV File    ${logId}    uldata_puschreceiverespps    ${RESPPS_LIST}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.dtx    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ${FILTER1}
    #Convert BIP Msg To CSV File    ${logId}    uldata_pucchreceiverespharqd    UlData_pucchReceiveRespHarqDPucchResource_t.crc
    #...    UlData_pucchReceiveRespHarqDPucchResource_t.dtx
    #Check Rate in Bip Per Field    ${logId}    uldata_pucchreceiverespharqd    UlData_pucchReceiveRespHarqDPucchResource_t.crc
    #Check Rate in Bip Per Field    ${logId}    uldata_pucchreceiverespharqd    UlData_pucchReceiveRespHarqDPucchResource_t.dtx

Convert BIP Msg To CSV File
    [Arguments]    ${log_id}    ${msg_name}    ${field_list}
    ${filter}=    Set Variable    ${msg_name}
    ${csv_title_list}    Create List    3gpp.sfn    3gpp.slot
    FOR    ${field}    IN    @{field_list}
        Collections.Append To List    ${csv_title_list}    ${field}
    END

    Convert BIP To CSV By MCShark   ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/${msg_name}.csv    ${filter}    ${csv_title_list}

Check Rate in Bip Per Field
    [Arguments]    ${log_id}    ${msg_name}    ${field}    ${matchReg}    ${rate}=0.05
    Log To Console    \nCheck Rate in Bip ${msg_name} Per Field ${field}.
    Log To Console    \nCheck matchReg=${matchReg} ......
    ${data_list1}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/${msg_name}.csv    ${field}    [${matchReg}]    except    no
    ${fail_number}    Get Length    ${data_list1}
    ${data_list2}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${TEST_LOG_DIRECTORY}/${log_id}/${msg_name}.csv    ${field}    [${matchReg}]    include    no
    ${ok_number}    Get Length    ${data_list2}
    ${total_number}    Evaluate    ${fail_number}+${ok_number}
    Log To Console    fail_number=${fail_number}, ok_number=${ok_number}, total_number=${total_number}
    ${checkRate}    Evaluate    float(${fail_number})/(${total_number})
    Log To Console    ${field} Fail Rate is ${checkRate}
    Should Be True    ${checkRate}<${rate}

Trigger 5QI 5 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 5 Setup | 1 |
    Log To Console    start 5QI-5 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:2 5QI:5    partial_match=${true}
    Log To Console    ${output}

Trigger 5QI 1 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:3 5QI:1    partial_match=${true}
    Log To Console    ${output}

Start SA VONR GBR DL And UL Traffic
    [Arguments]    ${ueId}    ${qfi_id}    ${dl_trf}    ${ul_trf}
    Log To Console    Start VONR DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
    Log To Console    Start VONR UL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
    Sleep    5s    reason=wait DL/UL traffic is stable


Get Multi Cells Multi PM Counters Max Values With Admin
    [Arguments]    ${counter_info_list}    ${bts_id}=1
    [Documentation]    This keyword is to get the latest counter value for multi cell multi same pm counters.
    ...                    Setup admin once in this keyword.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_info_list} | YES | a list for counter info, the element should be include cell_id, MO_name and counter_ids_list |
    ...
    ...    | Return | a dict with counter_id and the latest value |
    ...
    ...    Examples:
    ...    | @{test_counter_list} |  | M55136C00001 | M55136C00002 | M55136C00003 | M55136C00004 | M55136C00005 |
    ...    | &{counter_info_1} |  | cell_id=1 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_2} |  | cell_id=2 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | &{counter_info_3} |  | cell_id=3 | MO_name=LTEMG | counter_ids_list=${test_counter_list} |
    ...    | @{counter_info_list} |  | ${counter_info_1} | ${counter_info_2} | ${counter_info_3} |
    ...    | ${counter_value_dict} | Get Multi Cells Same Mo Multi PM Counters Latest Values With Admin | ${counter_info_list} |
    ...    | Should be True | ${counter_value_dict.Cell1.M55136C00001}>1
    Sleep    20s
    ${counter_value_dict}    Create Dictionary
    ${counter_ids}    Evaluate    ','.join(${counter_info_list[0].counter_ids_list})
    ${counter_id_value_dict}    Create Dictionary
    COAM.Setup Admin
    ${counter_dict}    COAM.Get Pm Counters    ${counter_ids}    timeout=5min
    FOR    ${counter_info}    IN    @{counter_info_list}
        ${counter_id_value_dict}    _Get Max Counter From Counter Dictionary    ${counter_dict}    ${counter_info.cell_id}
        ...    ${counter_info.MO_name}    ${counter_info.counter_ids_list}    ${bts_id}
        Set To Dictionary    ${counter_value_dict}    cell${counter_info.cell_id}    ${counter_id_value_dict}
    END
    [Return]    ${counter_value_dict}

_Get Max Counter From Counter Dictionary
    [Arguments]    ${counter_dict}    ${cell_id}    ${MO_name}    ${counter_ids_list}    ${bts_id}=1
    ${counter_id_value_dict}    Create Dictionary
    ${mo_list}    Split String    ${MO_name}    /
    ${status}    ${value}    Run Keyword And Ignore Error    Evaluate    &{counter_dict}['BTS']['CELLS']['NRCELL-${cell_id}']
    ${counter_dict}    Run Keyword If    '${status}'=='PASS'
    ...    Set Variable    ${counter_dict['BTS']['CELLS']['NRCELL-${cell_id}']}
    ...    ELSE IF    '${status}'=='FAIL'    Set Variable    ${counter_dict['BTS']['MRBTS-1']['NRBTS-${bts_id}']['NRCELL-${cell_id}']}
    ${type}    Evaluate    type(${counter_dict})
    FOR    ${node}    IN    @{mo_list}
        ${counter_dict}    Get From Dictionary    ${counter_dict}    ${node}
    END
    FOR    ${counter_id}    IN    @{counter_ids_list}
        ${counter_value_dict}    Get From Dictionary    ${counter_dict}    ${counter_id}
        ${counter_value_list}    Get Dictionary Values    ${counter_value_dict}
        ${max_counter_value}    Evaluate    max(${counter_value_list})
        Set To Dictionary    ${counter_id_value_dict}    ${counter_id}    ${max_counter_value}
    END
    [Return]    ${counter_id_value_dict}
