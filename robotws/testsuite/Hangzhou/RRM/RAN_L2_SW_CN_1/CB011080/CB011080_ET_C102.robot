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
${SCFC_FILE}                Full_SCF_CB011080_C102.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080.xml
${WTS_CFG}                  basic_CB011080_C102.lua
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3
${6CC}                      6
${UE1_3T3F}                 1
${UE2_2T4F}                 2
${UE3_1T1F}                 3
${UE4_2T}                   4
${UE5_3T}                   5
${UE6_2T1F}                 6
${UE7_1T2F}                 7
${UE8_3T1F}                 8
${UE9_2T2F}                 9
${UE10_1T3F}                10
${UE11_3T2F}                11
${UE12_2T3F}                12
${UE13_1T4F}                13
${FILTER1}                  "0", "0,0", "0,0,0", "0,0,0,0", "0,0,0,0,0"
@{3T3F_DL_TPUT_LIST}        10    5    10    10    30    10
@{2T4F_DL_TPUT_LIST}        10    100    5    10    10    40
@{1T1F_DL_TPUT_LIST}        10    10
@{2T_DL_TPUT_LIST}          10    10
@{3T_DL_TPUT_LIST}          10    40    10
@{2T1F_DL_TPUT_LIST}        10    10    10
@{1T2F_DL_TPUT_LIST}        10    10    10
@{3T1F_DL_TPUT_LIST}        10    10    40    10
@{2T2F_DL_TPUT_LIST}        10    10    10    10
@{1T3F_DL_TPUT_LIST}        10    3    10    10
@{3T2F_DL_TPUT_LIST}        10    10    10    40    10
@{2T3F_DL_TPUT_LIST}        10    5    10    10    10
@{1T4F_DL_TPUT_LIST}        10    100    5    10    10
@{2CC_UL_TPUT_LIST}         6    8
@{2CC_UL_TPUT_LIST2}        20    50
@{NONCA_ULTPUT_LIST}        6    0

@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55
@{6CC_SCELL_PCI_2T4F}       50    51    52    53    56
@{2CC_SCELL_PCI_1T1F}       52
@{2CC_SCELL_PCI_2T}         55
@{3CC_SCELL_PCI_3T}         54    55
@{3CC_SCELL_PCI_2T1F}       52    55
@{3CC_SCELL_PCI_1T2F}       52    53
@{4CC_SCELL_PCI_3T1F}       52    54    55
@{4CC_SCELL_PCI_2T2F}       52    53    55
@{4CC_SCELL_PCI_1T3F}       51    52    53
@{5CC_SCELL_PCI_3T2F}       52    53    54    55
@{5CC_SCELL_PCI_2T3F}       51    52    53    55
@{5CC_SCELL_PCI_1T4F}       50    51    52    53

*** Test Cases ***
CB011080_ET_C102_Verify_3T3F_6CC_IWK_With_Legacy_CA
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
    Attach_All_CA_UEs
    Start DL Data Transfer For All UEs
    Start UL Data Transfer For All UEs
    Run Keyword And Continue On Failure    Get All UEs Total Throughput Multi Times
    Capture BIP Log By Admin Method    capture_time=2s    log_subdir=1
    Check DTX And ACKNACK From BipLog    1
    AllUe_Stop_DL_UL_Traffic

*** Keywords ***
Check DTX And ACKNACK From BipLog
    [Arguments]    ${logId}=1
    Convert BIP To CSV By MCShark For Bip Msg    ${logId}    uldata_puschreceiverespharqul1sw
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqul1sw    UlData_UePuschReceiveRespHarqUL1sw_t.crc    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqul1sw    UlData_UePuschReceiveRespHarqUL1sw_t.dtx    ${FILTER1}
    Convert BIP To CSV By MCShark For Bip Msg    ${logId}    uldata_puschreceiverespharqdl1sw
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqdl1sw
    ...    UlData_puschReceiveRespHarqDGrantsL1sw_t.ackCrcCheck    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespharqdl1sw
    ...    UlData_puschReceiveRespHarqDGrantsL1sw_t.dtxAckMoreThan1Bit    ${FILTER1}

    Convert BIP To CSV By MCShark For Bip Msg    ${logId}    uldata_puschreceiverespps
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.dtx    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ${FILTER1}
    Check Rate in Bip Per Field    ${logId}    uldata_puschreceiverespps    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ${FILTER1}
    #Convert BIP To CSV By MCShark For Bip Msg    ${logId}    uldata_pucchreceiverespharqd    UlData_pucchReceiveRespHarqDPucchResource_t.crc
    #...    UlData_pucchReceiveRespHarqDPucchResource_t.dtx
    #Check Rate in Bip Per Field    ${logId}    uldata_pucchreceiverespharqd    UlData_pucchReceiveRespHarqDPucchResource_t.crc    ${FILTER1}
    #Check Rate in Bip Per Field    ${logId}    uldata_pucchreceiverespharqd    UlData_pucchReceiveRespHarqDPucchResource_t.dtx    ${FILTER1}

Attach_All_CA_UEs
    Single Ue Attach    ${UE1_3T3F}    ${AMF1_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE1_3T3F}    ${6CC_SCELL_PCI_3T3F}    ${6CC}
    Single Ue Attach    ${UE2_2T4F}    ${AMF1_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE2_2T4F}    ${6CC_SCELL_PCI_2T4F}    ${6CC}
    FOR    ${id}    IN RANGE    3    8
         Single Ue Attach    ${id}    ${AMF1_REGION}
    END
    FOR    ${id}    IN RANGE    8    14
         Single Ue Attach    ${id}    ${AMF2_REGION}
    END

AllUe_Stop_DL_UL_Traffic
    FOR    ${ueId}    IN RANGE    1    14
         SA Stop Data Traffic Internal    ${ueId}
    END

Check Per UE Throughput
    [Arguments]    ${start}    ${end}    ${dltptList}    ${ultptList}    ${ccNum}
    FOR    ${id}    IN RANGE    ${start}    ${end}
         ${uedltput}=    Check UE DL All Pcell Scell TPut Uestats    ${id}    ${dltptList}    ${ccNum}
         ${ueultput}=    Check UE 2CCUL Pcell Scell TPut Uestats    ${id}    ${ultptList}    ${ccNum}
         Log To Console    UE${id}'s uestats dl tput=${uedltput} Mbps
         Log To Console    UE${id}'s uestats ul tput=${ueultput} Mbps
    END

Get All UEs Total Throughput Multi Times
    Wait Until Keyword Succeeds    30s    5s    Get All UEs Total Throughput

Get All UEs Total Throughput
    [Documentation]    This keyword is to get multi-UEs total dl and ul throughput
    Sleep    25s    reason=wait 25s for traffic statble
    Check Per UE Throughput    1    2    ${3T3F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST}    6
    Check Per UE Throughput    2    3    ${2T4F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST2}    6
    Check Per UE Throughput    3    4    ${1T1F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST}    2
    Check Per UE Throughput    4    5    ${2T_DL_TPUT_LIST}    ${NONCA_ULTPUT_LIST}    2
    Check Per UE Throughput    5    6    ${3T_DL_TPUT_LIST}    ${NONCA_ULTPUT_LIST}    3
    Check Per UE Throughput    6    8    ${1T2F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST}    3
    Check Per UE Throughput    8    11    ${1T3F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST}    4
    Check Per UE Throughput    11    13    ${2T3F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST}    5
    Check Per UE Throughput    13    14    ${1T4F_DL_TPUT_LIST}    ${2CC_UL_TPUT_LIST2}    5

Start DL Data Transfer For All UEs
    Start SA UE Big DL Traffic Internal    ${UE1_3T3F}    390
    Start SA UE Big DL Traffic Internal    ${UE2_2T4F}    580
    Start SA UE Big DL Traffic Internal    ${UE3_1T1F}    140
    Start SA UE Big DL Traffic Internal    ${UE4_2T}    150
    Start SA UE Big DL Traffic Internal    ${UE5_3T}    250
    Start SA UE Big DL Traffic Internal    ${UE6_2T1F}    200
    Start SA UE Big DL Traffic Internal    ${UE7_1T2F}    200
    Start SA UE Big DL Traffic Internal    ${UE8_3T1F}    300
    Start SA UE Big DL Traffic Internal    ${UE9_2T2F}    260
    Start SA UE Big DL Traffic Internal    ${UE10_1T3F}    210
    Start SA UE Big DL Traffic Internal    ${UE11_3T2F}    360
    Start SA UE Big DL Traffic Internal    ${UE12_2T3F}    280
    Start SA UE Big DL Traffic Internal    ${UE13_1T4F}    500

Start UL Data Transfer For All UEs
    Start SA UE Big UL Traffic Internal    ${UE1_3T3F}    28
    Start SA UE Big UL Traffic Internal    ${UE2_2T4F}    115
    Start SA UE Big UL Traffic Internal    ${UE3_1T1F}    28
    Start SA UE Big UL Traffic Internal    ${UE4_2T}    12
    Start SA UE Big UL Traffic Internal    ${UE5_3T}    12
    Start SA UE Big UL Traffic Internal    ${UE6_2T1F}    28
    Start SA UE Big UL Traffic Internal    ${UE7_1T2F}    28
    Start SA UE Big UL Traffic Internal    ${UE8_3T1F}    28
    Start SA UE Big UL Traffic Internal    ${UE9_2T2F}    28
    Start SA UE Big UL Traffic Internal    ${UE10_1T3F}    28
    Start SA UE Big UL Traffic Internal    ${UE11_3T2F}    28
    Start SA UE Big UL Traffic Internal    ${UE12_2T3F}    28
    Start SA UE Big UL Traffic Internal    ${UE13_1T4F}    115

Check All UEs DL Throughput
    Wait Until Keyword Succeeds    30s    6s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE1_3T3F}    ${3T3F_DL_TPUT_LIST}    6
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE2_2T4F}    ${2T4F_DL_TPUT_LIST}    6
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE3_1T1F}    ${1T1F_DL_TPUT_LIST}    2
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE4_2T}    ${2T_DL_TPUT_LIST}    2
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE5_3T}    ${3T_DL_TPUT_LIST}    3
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE6_2T1F}    ${2T1F_DL_TPUT_LIST}    3
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE7_1T2F}    ${1T2F_DL_TPUT_LIST}    3

    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE8_3T1F}    ${3T1F_DL_TPUT_LIST}    4
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE9_2T2F}    ${2T2F_DL_TPUT_LIST}    4
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE10_1T3F}    ${1T3F_DL_TPUT_LIST}    4
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE11_3T2F}    ${3T2F_DL_TPUT_LIST}    5
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE12_2T3F}    ${2T3F_DL_TPUT_LIST}    5
    Run Keyword And Continue On Failure    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE13_1T4F}    ${1T4F_DL_TPUT_LIST}    5

Check All UEs UL Throughput
    FOR    ${id}    IN RANGE    1    4
         ${ueultput}=    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${id}    ${2CC_UL_TPUT_LIST}    2
    END
    FOR    ${id}    IN RANGE    4    6
         ${ueultput}=    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${id}    ${NONCA_ULTPUT_LIST}    2
    END
    FOR    ${id}    IN RANGE    6    14
         ${ueultput}=    Check UE 2CCUL Pcell Scell TP On Target For Single UE    ${id}    ${2CC_UL_TPUT_LIST}    2
    END
