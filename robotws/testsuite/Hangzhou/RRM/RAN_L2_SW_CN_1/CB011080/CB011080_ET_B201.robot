*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11    CB011080    owner_suxu
Resource          resources/CB011080_resource.robot

Documentation
...     CB011080 multi-UEs case

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                Full_SCF_CB011080_B201.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080.xml
${WTS_CFG}                  20UE_3T3F_20UE_2T4F_CB011080.lua
${SWCONFIG_AP}              0x5C0009=2
${CELL7_UE_ENDNUM}          9
${CELL6_UE_ENDNUM}          29
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3
${FILTER1}                  "0", "0,0", "0,0,0", "0,0,0,0", "0,0,0,0,0"
${6CC_NUM}                  6
@{3T3F_DL_TPUT_LIST}        1    1    1    1    1    1
@{2T4F_DL_TPUT_LIST}        1    1    1    1    1    1
@{2CC_UL_TPUT_LIST}         6    8
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
@{6CC_SCELL_PCI_2T4F}       50    51    52    53    56
@{HARQU_LIST}    UlData_UePuschReceiveRespHarqUL1sw_t.crc    UlData_UePuschReceiveRespHarqUL1sw_t.dtx
@{HARQD_LIST}    UlData_puschReceiveRespHarqDGrantsL1sw_t.ackCrcCheck    UlData_puschReceiveRespHarqDGrantsL1sw_t.dtxAckMoreThan1Bit
@{RESPPS_LIST}    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    ...    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck

*** Test Cases ***
CB011080_ET_B201_Verify_Multiple_Ues_6CCs_DL_2CCs_UL_CA
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    swconfig_param_AP=${SWCONFIG_AP}
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
    Cell7_Ue_Attach
    Cell6_Ue_Attach
    AllUe_Start_DL_UL_Traffic
    Run Keyword And Continue On Failure    Check_All_Ue_Tput
    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=1
    Check DTX And ACKNACK From BipLog    1
    AllUe_Stop_DL_UL_Traffic

*** Keywords ***
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

Cell6_Ue_Attach
    FOR    ${ue_id}    IN RANGE    21    ${CELL6_UE_ENDNUM}
        Single Ue Attach    ${ue_id}    ${AMF2_REGION}
    END
    #\    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${6CC_SCELL_PCI_2T4F}    ${6CC_NUM}

Cell7_Ue_Attach
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_UE_ENDNUM}
        Single Ue Attach    ${ue_id}    ${AMF1_REGION}
    END
    #\    Check SA All Scell PhysicalID With UE ID    ${ue_id}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}

AllUe_Start_DL_UL_Traffic
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_UE_ENDNUM}
         SA Start DL Traffic Internal    ${ue_id}    1    180    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    30    trf_id=1
    END
    FOR    ${ue_id}    IN RANGE    21    ${CELL6_UE_ENDNUM}
         SA Start DL Traffic Internal    ${ue_id}    1    185    trf_id=1
         sleep    0.5s
         SA Start UL Traffic Internal    ${ue_id}    1    29    trf_id=1
    END
    sleep    25s

AllUe_Stop_DL_UL_Traffic
    FOR    ${ue_id}    IN RANGE    1    ${CELL7_UE_ENDNUM}
         SA Stop Data Traffic Internal    ${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    21    ${CELL6_UE_ENDNUM}
         SA Stop Data Traffic Internal    ${ue_id}
    END

Check_All_Ue_Tput
    [Documentation]    This keyword is to verify multi-UEs
    ${uestats_dltput}    Set Variable    0
    ${uestats_ultput}    Set Variable    0
    FOR    ${id}    IN RANGE    1    ${CELL7_UE_ENDNUM}
         ${uedltput}=    Check UE DL All Pcell Scell TPut Uestats    ${id}    ${3T3F_DL_TPUT_LIST}    ${6CC_NUM}
         ${ueultput}=    Check UE 2CCUL Pcell Scell TPut Uestats    ${id}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
         ${uestats_dltput}    Evaluate    ${uestats_dltput}+${uedltput}
         ${uestats_ultput}    Evaluate    ${uestats_ultput}+${ueultput}
         Log To Console    UE${id}'s uestats dl tput=${uedltput} Mbps
         Log To Console    UE${id}'s uestats ul tput=${ueultput} Mbps
    END

    FOR    ${id}    IN RANGE    21    ${CELL6_UE_ENDNUM}
         ${uedltput}=    Check UE DL All Pcell Scell TPut Uestats    ${id}    ${2T4F_DL_TPUT_LIST}    ${6CC_NUM}
         ${ueultput}=    Check UE 2CCUL Pcell Scell TPut Uestats    ${id}    ${2CC_UL_TPUT_LIST}    ${6CC_NUM}
         ${uestats_dltput}    Evaluate    ${uestats_dltput}+${uedltput}
         ${uestats_ultput}    Evaluate    ${uestats_ultput}+${ueultput}
         Log To Console    UE${id}'s uestats dl tput=${uedltput} Mbps
         Log To Console    UE${id}'s uestats ul tput=${ueultput} Mbps
    END
    Log To Console    all UE's uestats dl tput=${uestats_dltput} Mbps
    Log To Console    all UE's uestats ul tput=${uestats_ultput} Mbps
