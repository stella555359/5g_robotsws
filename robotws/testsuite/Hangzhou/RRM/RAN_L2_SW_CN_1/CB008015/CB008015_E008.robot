*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready With DSS
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB008015    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_zhachen    CN1_SQ6    SBTS00    SBTS23R1    SBTS22R4
#Resource          resources/CB008015_lib.robot
#Resource          ./../CUDU_L2/common_dss_command.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 8015_full_scfc.xml
#${DELTA_SCFC}                Delta_8015_E008.json
#${IPHY_XML}                  ${CURDIR}/config/wts/iphy_4F_2T.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts
#${WTS_CFG}                   basic_8015_DSS.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${CA_UE_LIST}                1,2,3,5
#
#*** Test Cases ***
#CB008015_ET_E_008_Mix_CA_Mode_MultiUE_With_A1_RSRP_ABIO
#    Attach 4 CA UE And Check Scell Addition Successful
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=2    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=3    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    CA UE Start UL Traffic And Check Tput    sa_ue_list=${CA_UE_LIST}
#
#*** Keywords ***
#Suite Setup Make TL Ready With DSS
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Delta Commission With SCF File    ${DELTA_SCFC}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#    Setup XP LINK
#    Set LTE NR DSS Mode
#    Setup XP And Config Resource
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#Attach 4 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:10MHz DSS, Fdd cell2:10MHz, Tdd cell3 60MHz
#    ...    UE1 Fdd cell1+Fdd cell2
#    ...    UE2 Fdd cell1+Tdd cell3
#    ...    UE3 Fdd cell2+Fdd cell1
#    ...    UE5 Tdd cell3+Fdd cell1
#    SA Attach    sa_ue_id=1
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=1    pcell_id=50    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=2
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=2    pcell_id=50    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=2    scell_physicalid=51    scell_index=1
#    SA Attach    sa_ue_id=3
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=3    pcell_id=51    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=3    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=5
#    Trigger Scell Addition With CoverbaseA1 Rsrp    ue_id=5    pcell_id=52    rsrp=95    mea_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=5    scell_physicalid=50    scell_index=1
#
#CA UE Start UL Traffic And Check Tput
#    [Arguments]    ${sa_ue_list}
#    [Documentation]    this keyword is to start ul udp traffic, then check tput
#    @{ue_list}    Split String    ${sa_ue_list}    ,
#    : FOR    ${t_ue_id}    IN    @{ue_list}
#    \    SA Start UL Traffic Internal    ue_id=${t_ue_id}    pdu_id=1    mbps=40    trf_id=1
#    Check Tput Per UE    ueId=1    dlTput=121    ulTput=10    PcellDlTput=1    ScellDlTput=120
#    Check Tput Per UE    ueId=2    dlTput=21    ulTput=10    PcellDlTput=1    ScellDlTput=20
#    Check Tput Per UE    ueId=3    dlTput=16    ulTput=5    PcellDlTput=10    ScellDlTput=6
#    Check Tput Per UE    ueId=5    dlTput=106    ulTput=20    PcellDlTput=100    ScellDlTput=6
#
#Check Tput Per UE
#    [Arguments]    ${ueId}    ${dlTput}    ${ulTput}    ${PcellDlTput}    ${ScellDlTput}
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${PcellDlTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=1    target_tp=${ScellDlTput}
