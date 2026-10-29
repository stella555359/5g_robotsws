*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11       owner_qiaren
Resource          ./../CUDU_L2/common_setup_teardown.robot

Documentation
...     9928 test interwork With 11080

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                CB009928_iwk_6cc_refine.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB009928_iwk_6cc_refine.xml
${WTS_CFG}                  CB009928_iwk_6cc_refine.lua

${UE_1}                     1
${UE_3}                     3
${PDU_ID}         1
${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
${CELL7_UE_ENDNUM}          60
${CELL2_UE_ENDNUM}          260
${CELL7_CA_UE_ENDNUM}         20
${CELL2_CA_UE_ENDNUM}          220
${6CC_NUM}                  6
@{3T3F_DL_TPUT_LIST}        0.5    1    1    1    1    1
@{2T4F_DL_TPUT_LIST}        1    1    1    1    1    1
@{2CC_UL_TPUT_LIST}         0.5    0.5
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
${FILTER1}                  "0", "0,0", "0,0,0", "0,0,0,0", "0,0,0,0,0"
@{HARQU_LIST}    UlData_UePuschReceiveRespHarqUL1sw_t.crc    UlData_UePuschReceiveRespHarqUL1sw_t.dtx
@{HARQD_LIST}    UlData_puschReceiveRespHarqDGrantsL1sw_t.ackCrcCheck    UlData_puschReceiveRespHarqDGrantsL1sw_t.dtxAckMoreThan1Bit
@{RESPPS_LIST}    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    ...    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
${COUNTER_LIST}           M55118C00053    M55118C00001    M55118C00004
&{COUNTER_INFO_1}             cell_id=7    MO_name=NCADU    counter_ids_list=${COUNTER_LIST}
&{COUNTER_INFO_2}             cell_id=6    MO_name=NCADU    counter_ids_list=${COUNTER_LIST}
@{COUNTER_CHECK}        ${COUNTER_INFO_1}    ${COUNTER_INFO_2}

&{A1counter_succ}               counter_id=M55145C02002    counter_path=CELLS/NRCELL-7/MCC-311/MNC-489/NRANS
&{A2counter_succ}               counter_id=M55145C03002    counter_path=CELLS/NRCELL-2/MCC-311/MNC-489/NRANS


*** Test Cases ***
CB009928_A_B1_101_A1_measurement_based_Pcell_switch_from_T_to_T_SA_DL_3CC_CA
     [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
#    Create Suite Directory
#    Create Test Directory
#    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
#    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}     save_egate=${True}
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
    Cell7_Ues_Attach
    Cell2_Ues_Attach
    Multi-ue GBR NONGBR bear setup
    Start traffic for all UEs
    Trigger A1 Scell Addition For CA UE
    ${PM_counter_file}    download 2min PM counter file    	${TEST_LOG_DIRECTORY}
    ${get KPI NR_5096f}    get KPI NR_5096f    ${PM_counter_file}    cell_id=2
    ${get KPI NR_5101b}    get KPI NR_5101b    ${PM_counter_file}    cell_id=2
    ${get KPI NR_5096f}    get KPI NR_5096f    ${PM_counter_file}    cell_id=7
    ${get KPI NR_5101b}    get KPI NR_5101b    ${PM_counter_file}    cell_id=7
    A1 Based Pcell Switch For cell7 UE
    A2 Based Pcell Switch For cell2 UE
    Trigger A1 Scell Addition For CA UE switch
    Wait Until Keyword Succeeds    10min    1min    Check PM Counter Updated
    ${PM_counter_file_2}    download 2min PM counter file    	${TEST_LOG_DIRECTORY}
    ${get KPI NR_5096f}    get KPI NR_5096f    ${PM_counter_file_2}    cell_id=6
    ${get KPI NR_5101b}    get KPI NR_5101b    ${PM_counter_file_2}    cell_id=6
    ${get KPI NR_5096f}    get KPI NR_5096f    ${PM_counter_file_2}    cell_id=7
    ${get KPI NR_5101b}    get KPI NR_5101b    ${PM_counter_file_2}    cell_id=7

*** Keywords ***
Configure IP For UEC2
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3

Cell2_Ues_Attach
    FOR    ${ue_id}    IN RANGE    201    ${CELL2_UE_ENDNUM}+1
        Single Ue Attach    ${ue_id}    ${AMF2_REGION}
    END

Cell7_Ues_Attach
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_UE_ENDNUM}+1
        Single Ue Attach    ${ue_id}    ${AMF1_REGION}
    END

Trigger A1 Scell Addition For CA UE
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_CA_UE_ENDNUM}+1
        Send A1 report    ${ue_id}   120    56    1
        sleep    2s
    END
    FOR    ${ue_id}    IN RANGE    201    ${CELL2_CA_UE_ENDNUM}+1
        Send A1 report    ${ue_id}   120    51    1
        sleep    2s
    END

Trigger A1 Scell Addition For CA UE switch
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_CA_UE_ENDNUM}+1
        Send A1 report    ${ue_id}   120    55    11
        sleep    2s
    END
    FOR    ${ue_id}    IN RANGE    201    ${CELL2_CA_UE_ENDNUM}+1
        Send A1 report    ${ue_id}   120    56    10
        sleep    2s
    END

Multi-ue GBR NONGBR bear setup
    FOR    ${ue_id}    IN RANGE    1    20+1
         Trigger GBR bear Setup    ${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    201    220+1
         Trigger GBR bear Setup    ${ue_id}
    END
#    FOR    ${ue_id}    IN RANGE    11    60+1
#         Trigger NONGBR bear Setup    ${ue_id}
#    END
#    FOR    ${ue_id}    IN RANGE    211    260+1
#         Trigger NONGBR bear Setup    ${ue_id}
#    END

Start traffic for all UEs
    #Start SA UE Big DL Traffic Internal    ${UE_1}    700
    #SA Start UL Traffic Internal    ${UE_1}     1    60
    FOR    ${ue_id}    IN RANGE    1    5+1
         SA Start DL Traffic Internal    ${ue_id}    1    100    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    10    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    201    205+1
         SA Start DL Traffic Internal    ${ue_id}    1    100    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    10    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    6    60+1
         SA Start DL Traffic Internal    ${ue_id}    1    10    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    206    260+1
         SA Start DL Traffic Internal    ${ue_id}    1    10    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    5    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    1    20+1
        Start SA GBR DL And UL Traffic    ueId=${ue_id}    dl_trf=1    ul_trf=1
    END
    FOR    ${ue_id}    IN RANGE    201    220+1
        Start SA GBR DL And UL Traffic    ueId=${ue_id}    dl_trf=1    ul_trf=1
    END
#    FOR    ${ue_id}    IN RANGE    11    60+1
#        Start SA NONGBR DL And UL Traffic    ueId=${ue_id}    dl_trf=1    ul_trf=1
#    END
#    FOR    ${ue_id}    IN RANGE    211    260+1
#        Start SA NONGBR DL And UL Traffic    ueId=${ue_id}    dl_trf=1    ul_trf=1
#    END

A1 Based Pcell Switch For cell7 UE
    Log To Console    UE attach to cell6
    FOR    ${i}    IN RANGE    1    20+1
        #Switch from T1 to T2
        Log To Console    UE1 Trigger A1 Pcell switch ...
        ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.6 performed
#        ute_wtssim.Execute Egate Command    cmd=trace uec=1 protocol=nr_rrc on
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ue_measurement_send_nr id\=${i} event\=A1 scell\=5 scell_rsrp\=102 meas_id\=3    pass_regexp=${pattern}    timeout=2min
        ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#        ute_wtssim.Execute Egate Command    cmd=trace uec=1 protocol=nr_rrc off
        Log To Console    \n${output}
        Log    UE${i} Trigger A1 Pcell switch is OK
    END

A2 Based Pcell Switch For cell2 UE
    #Switch from T1 to T2
    FOR    ${i}    IN RANGE    201    220+1
        Log To Console    UE Trigger A2 Pcell switch cell7...
        ${pattern}    Set Variable    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.7 performed
#        ute_wtssim.Execute Egate Command    cmd=trace uec=1 protocol=nr_rrc on
        ${FIRST_COMMAND}=    Set Variable    ue_measurement_send_nr id=${i} meas_id=8 event=A2 srsrp_nr=11 srsrq_nr=11 scell=5
        ${LAST_COMMAND}=    Set Variable    scell_rsrp=100 scell_rsrq=100 scell=4 scell_rsrp=60 scell_rsrq=60
        ${FULL_COMMAND}=    Set Variable    ${FIRST_COMMAND} ${LAST_COMMAND}
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${FULL_COMMAND}    pass_regexp=${pattern}    timeout=2min
        ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
#        ute_wtssim.Execute Egate Command    cmd=trace uec=1 protocol=nr_rrc off
        Log To Console    \n${output}
        Log    UE${i} Trigger A2 Pcell switch is OK
    END

Check_All_Ue_Tput
    [Documentation]    This keyword is to verify multi-UEs
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE}    ${3T3F_DL_TPUT_LIST}    ${6CC_NUM}
    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${UE_1}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
    FOR    ${ue_id}    IN RANGE    2    ${CELL7_UE_ENDNUM}
        SA Check UE Cell TPut On Target    ${ue_id}    1    dl    0
        SA Check UE Cell TPut On Target    ${ue_id}    1    ul    0
    END
    FOR    ${ue_id}    IN RANGE    201    ${CELL6_UE_ENDNUM}
        SA Check UE Cell TPut On Target    ${ue_id}    1    dl    0
        SA Check UE Cell TPut On Target    ${ue_id}    1    ul    0
    END

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

Trigger GBR bear Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start GBR bear Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    Sleep    5s    reason=wait for traffic stable
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
	${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=4 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes

Trigger NONGBR bear Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start NONGBR bear Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=8 by=amf
    Sleep    5s    reason=wait for traffic stable
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
	${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=9 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
	${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=10 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes

Start SA GBR DL And UL Traffic
    [Arguments]    ${ueId}    ${dl_trf}    ${ul_trf}
    Log To Console    Start gbr Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=2 trf_id=2 mbps\=${dl_trf} dir=dl protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=3 trf_id=2 mbps\=${dl_trf} dir=dl protocol=udp
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=2 trf_id=2 mbps\=${ul_trf} dir=ul protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=3 trf_id=2 mbps\=${ul_trf} dir=ul protocol=udp
    Sleep    5s    reason=wait DL/UL traffic is stable


Start SA NONGBR DL And UL Traffic
    [Arguments]    ${ueId}    ${dl_trf}    ${ul_trf}
    Log To Console    Start nongbr Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=4 trf_id=5 mbps\=${dl_trf} dir=dl protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=5 trf_id=5 mbps\=${dl_trf} dir=dl protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=6 trf_id=5 mbps\=${dl_trf} dir=dl protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=4 trf_id=5 mbps\=${ul_trf} dir=ul protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=5 trf_id=5 mbps\=${ul_trf} dir=ul protocol=udp
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=6 trf_id=5 mbps\=${ul_trf} dir=ul protocol=udp
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
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=oam
    ${counter_dict}    TAF_ADMIN.Get Pm Counters    ${counter_ids}    timeout=5min    connection=oam
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

Check PM Counter Updated
    ${counter_value}    Get PM Counter Latest Value From Admin    ${A1counter_succ.counter_id}    ${A1counter_succ.counter_path}
	Should be True    ${counter_value}==20
	#ute_reporting_portal.Report Pm Counter         ${counter_att.counter_id}    ${counter_value}    Passed
	${counter_value}    Get PM Counter Latest Value From Admin    ${A2counter_succ.counter_id}    ${A2counter_succ.counter_path}
    Should be True    ${counter_value}==20
	#ute_reporting_portal.Report Pm Counter         ${counter_succ.counter_id}    ${counter_value}    Passed

get KPI NR_5096f
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_64TBL_MCS}    create list
    ${PDSCH_256TBL_MCS}    create list
    ${PDSCH_LowSE_MCS}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_1}   evaluate   1000+${num}
        ${counter_5}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C0${counter_1}    cell_id=${cell_id}
        append to list    ${PDSCH_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55366C0${counter_5}    cell_id=${cell_id}
        append to list    ${PDSCH_LowSE_MCS}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28
        ${counter_5}   evaluate   5000+${num}
	   ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C0${counter_5}    cell_id=${cell_id}
        append to list    ${PDSCH_256TBL_MCS}    ${result}
    END
    ${M55308C00001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00001    cell_id=${cell_id}
    ${M55308C00015}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00015    cell_id=${cell_id}
    ${M55308C00017}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00017    cell_id=${cell_id}
    ${M55304C00001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55304C00001    cell_id=${cell_id}
    ${M55308C10010}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C10010    cell_id=${cell_id}
    ${pdsch_mcs_total}    evaluate    sum(${PDSCH_64TBL_MCS})+sum(${PDSCH_256TBL_MCS})+sum(${PDSCH_LowSE_MCS})
    ${pdsch_slot}    evaluate    ${M55308C00001}+${M55308C00015}+${M55308C00017}
    ${MEAS_PERIOD}    evaluate    ${M55304C00001}*${M55308C10010}
    ${NR_5096f}    evaluate    8*${pdsch_mcs_total}*${pdsch_slot}/${MEAS_PERIOD}
    log to console    cellid_${cell_id} KPI NR_5096b pdsch tput is ${NR_5096f}
    [Return]    ${NR_5096f}

get KPI NR_5101b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${M55309C02001}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C02001    cell_id=${cell_id}
    ${M55308C02002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C02002    cell_id=${cell_id}
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00009    cell_id=${cell_id}
    ${M55308C00006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C00006    cell_id=${cell_id}
    ${ul_mac_sdu}    evaluate    8*${M55309C02001}
    ${meas}    evaluate    ${M55308C02002}*${M55308C00009} / ${M55308C00006}
    ${NR_5101b}    evaluate    ${ul_mac_sdu} / ${meas}
    log to console    cellid_${cell_id} KPI NR_5101b ul tp is ${NR_5101b}
    [Return]    ${NR_5101b}

download 2min PM counter file
    [Arguments]    ${log_dir}
    sleep    150s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
    [Return]    ${PM_counter_file}
