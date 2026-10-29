*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB008015    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_zhachen    CN1_SQ6    SBTS00    SBTS23R1    SBTS22R4
#Resource          resources/CB008015_lib.robot
#Resource          ./../CUDU_L2/common_dss_command.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 8015_full_scfc_AP_LOO2.xml
#${DELTA_SCFC}                Delta_8015_E008_AP_LOO2.json
#${IPHY_XML}                  ${CURDIR}/config/wts/iphy_4F_2T_AP_LOO.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts
#${WTS_CFG}                   basic_8015_AP_LOO2.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${CA_UE_LIST}                9,10,3,5
#
#*** Test Cases ***
#CB008015_ET_E_008_Mix_CA_Mode_MultiUE_With_A1_RSRP_ABIO
#    Attach 4 CA UE And Check Scell Addition Successful
#    Start SA DL Big Traffic Internal    ue_id=9    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=10    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=3    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    CA UE Start UL Traffic And Check Tput    sa_ue_list=${CA_UE_LIST}
#
#*** Keywords ***
#Suite Setup Make TL Ready
#    Suite Setup Update GNB     scf_file=${FULL_SCFC}       iphy_file=${IPHY_XML}
#    #Suite Setup Update GNB
#    Delta Commission With SCF File     ${DELTA_SCFC}
#    Verify Coam Site Is Ready
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir
#
#Attach 4 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:10MHz DSS, Fdd cell2:10MHz, Tdd cell3 60MHz
#    ...    UE9 Fdd cell5+Tdd cell3
#    ...    UE10 Fdd cell5+Fdd cell2
#    ...    UE3 Fdd cell2+Fdd cell5
#    ...    UE5 Tdd cell3+Fdd cell5
#    SA Attach    sa_ue_id=9
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=9    pcell_id=54    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=9    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=10
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=10    pcell_id=54    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=10    scell_physicalid=51    scell_index=1
#    SA Attach    sa_ue_id=3
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=3    pcell_id=51    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=3    scell_physicalid=54    scell_index=1
#    SA Attach    sa_ue_id=5
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=5    pcell_id=52    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=5    scell_physicalid=54    scell_index=1
#
#CA UE Start UL Traffic And Check Tput
#    [Arguments]    ${sa_ue_list}
#    [Documentation]    this keyword is to start ul udp traffic, then check tput
#    @{ue_list}    Split String    ${sa_ue_list}    ,
#    : FOR    ${t_ue_id}    IN    @{ue_list}
#    \    SA Start UL Traffic Internal    ue_id=${t_ue_id}    pdu_id=1    mbps=40    trf_id=1
#    #Sleep    40s    reason=Wait for TP collection...
#    Check TP On Target    9    0    1    140    20
#    Check TP On Target    10    0    1    50    20
#    Check TP On Target    3    0    1    50    20
#    Check TP On Target    5    0    1    280    20
#
#Check TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    Sleep    30s    reason=Wait for TP collection...
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    0
#    Log To Console    UL Troughput is ${pcell_ulTP}    console=True
#    Should Be True    ${pcell_ulTP}>=${target_ulsum_tp}
#
#
