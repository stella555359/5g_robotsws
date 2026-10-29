*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11    CB011080    owner_suxu
Resource          resources/CB011080_resource.robot

Documentation
...     9928 test interwork With 11080

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                Full_SCF_CB011080_C403.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB011080_C403.xml
${WTS_CFG}                  CB011080_C403.lua
${SWCONFIG_GNB}             0x580477=2;0x580264=0x1F
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3
${6CC}                      6
${UE1_3T3F}                 1
${CELL5_UEC1_END}           4
${CELL5_UEC2_END}           9

@{3T3F_DL_TPUT_LIST}        50    10    30    45    50    50
@{2CC_UL_TPUT_LIST}         5    7
@{6CC_SCELL_PCI_3T3F}       51    52    53    55    56
${UL_PATTERN_ID}            1357,1276,0,0,1357,1276,0,0,1357,1276,0,0,1357,1276,0,0

*** Test Cases ***
CB011080_ET_C403_Verify_6CC_IWK_UL_AND_DL_SRS_Based_Beamforming
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    swconfig_param=${SWCONFIG_GNB}
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true
    Set SRS Testmode    profile_id=3    init_pos=1
    Cell5_UEs_Attach
    Start DL Data Transfer For All UEs
    Start UL Data Transfer For All UEs
    Run Keyword And Continue On Failure    Check_All_UEs_Throughput
    Capture BIP Log By Admin Method    capture_time=3s    log_subdir=BIP/1
    Check Srsreceivereq With A2A    BIP/1    srsreceivereq_C403.ini
    Check overlap Symbols From Wirshark    /BIP/1    52    13,13
    Check PatternID From Wirshark    /BIP/1    54    uldata_puschreceivereq    UlData_eCpriConfigStruct_t.patternId_item    ${UL_PATTERN_ID}
    Check PatternID From Wirshark    /BIP/1    54    dldata_pdschsendreql1sw    DlData_PdschGrantL1sw.patternId_item    1356,1352
    Capture And Check TTitrace Logs    1    0.3
    AllUe_Stop_DL_UL_Traffic

*** Keywords ***
Cell5_UEs_Attach
    FOR    ${ueId}    IN RANGE    1    ${CELL5_UEC1_END}
         CUDU L2 Send Action To GNB    ue_id=${ueId}   testmode=ue_srs_beam_pos    action=activate    profile_id=3
         Single Ue Attach    ${ueId}    ${AMF1_REGION}
    END

    FOR    ${ueId}    IN RANGE    6    ${CELL5_UEC2_END}
         CUDU L2 Send Action To GNB    ue_id=${ueId}   testmode=ue_srs_beam_pos    action=activate    profile_id=3
         Single Ue Attach    ${ueId}    ${AMF2_REGION}
    END

AllUe_Stop_DL_UL_Traffic
    FOR    ${ueId}    IN RANGE    1    ${CELL5_UEC1_END}
         SA Stop Data Traffic Internal    ${ueId}
    END
    FOR    ${ueId}    IN RANGE    6    ${CELL5_UEC2_END}
         SA Stop Data Traffic Internal    ${ueId}
    END

Check_All_UEs_Throughput
    [Documentation]    This keyword is to verify multi-UEs throughput
    ${uestats_dltput}    Set Variable    0
    ${uestats_ultput}    Set Variable    0
    FOR    ${id}    IN RANGE    1    ${CELL5_UEC1_END}
         ${uedltput}=    Check UE DL All Pcell Scell TPut Uestats    ${id}    ${3T3F_DL_TPUT_LIST}    ${6CC}
         ${ueultput}=    Check UE 2CCUL Pcell Scell TPut Uestats    ${id}    ${2CC_UL_TPUT_LIST}    ${6CC}
         Log To Console    UE${id}'s uestats dl tput=${uedltput} Mbps
         Log To Console    UE${id}'s uestats ul tput=${ueultput} Mbps
         ${uestats_dltput}    Evaluate    ${uestats_dltput}+${uedltput}
         ${uestats_ultput}    Evaluate    ${uestats_ultput}+${ueultput}
    END

    FOR    ${id}    IN RANGE    6    ${CELL5_UEC2_END}
         ${uedltput}=    Check UE DL All Pcell Scell TPut Uestats    ${id}    ${3T3F_DL_TPUT_LIST}    ${6CC}
         ${ueultput}=    Check UE 2CCUL Pcell Scell TPut Uestats    ${id}    ${2CC_UL_TPUT_LIST}    ${6CC}
         Log To Console    UE${id}'s uestats_ dl tput=${uedltput} Mbps
         Log To Console    UE${id}'s uestats_ ul tput=${ueultput} Mbps
         ${uestats_dltput}    Evaluate    ${uestats_dltput}+${uedltput}
         ${uestats_ultput}    Evaluate    ${uestats_ultput}+${ueultput}
    END
    Log To Console    all UE's uestats dl tput=${uestats_dltput} Mbps
    Log To Console    all UE's uestats ul tput=${uestats_ultput} Mbps

Start DL Data Transfer For All UEs
    FOR    ${ueId}    IN RANGE    1    ${CELL5_UEC1_END}
         Start SA UE Big DL Traffic Internal    ${ueId}    350
         sleep    0.5s
    END
    FOR    ${ueId}    IN RANGE    6    ${CELL5_UEC2_END}
         Start SA UE Big DL Traffic Internal    ${ueId}    350
         sleep    0.5s
    END

Start UL Data Transfer For All UEs
    FOR    ${ueId}    IN RANGE    1    ${CELL5_UEC1_END}
         Start SA UE Big UL Traffic Internal    ${ueId}    25
         sleep    0.5s
    END
    FOR    ${ueId}    IN RANGE    6    ${CELL5_UEC2_END}
         Start SA UE Big UL Traffic Internal    ${ueId}    25
         sleep    0.5s
    END
    Sleep    25s    reason=wait 25s for traffic statble
