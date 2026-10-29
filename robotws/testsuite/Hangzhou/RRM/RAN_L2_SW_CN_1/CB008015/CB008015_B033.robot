*** Settings ***
Documentation    ...
#Suite Setup       Suite Setup Make TL Ready With DSS
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CB008015    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_suxu    CN1_SQ6
#Resource          resources/CB008015_lib.robot
#Resource          ./../CUDU_L2/common_dss_command.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config/
#${FULL_SCFC}                 8015_full_scfc.xml
#${DELTA_SCFC}                Delta_8015_B033.json
#${IPHY_XML}                  ${CURDIR}/config/wts/iphy_4F_2T.xml
#${LOCAL_WTS_DIR}             ${CURDIR}/config/wts
#${WTS_CFG}                   basic_8015_DSS.cfg
#${WTS_AP_XML}                airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${CA_UE_LIST}                1,5,6,11
#
#*** Test Cases ***
#CB008015_B_033_Bufferbase_CA_20MHz_DSS_4UE_SA
#    Attach 4 CA UE And Check Scell Addition Successful
#    Start SA DL Big Traffic Internal    ue_id=1    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=5    mbps=300
#    Start SA DL Big Traffic Internal    ue_id=6    mbps=150
#    Start SA DL Big Traffic Internal    ue_id=11    mbps=300
#    CA UE Start UL Traffic And Check Tput    sa_ue_list=${CA_UE_LIST}
#
#*** Keywords ***
#Suite Setup Make TL Ready With DSS
#    Suite Setup Update GNB    scf_file=${FULL_SCFC}    iphy_file=${IPHY_XML}
#    Run Keyword And Ignore Error    Delta Commission With SCF File    ${DELTA_SCFC}
#    Verify Coam Site Is Ready
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    Set WTS CFG LTE To 20MHz
#    Suite Setup Start WTS And Check OnAir With Workaround
#    Setup XP LINK
#    Set LTE NR DSS Mode
#    Setup XP And Config Resource
#    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#Attach 4 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell1:20MHz DSS, Tdd cell3:60MHz, Tdd cell6 60MHz
#    ...    UE1 Fdd cell1+Tdd cell3
#    ...    UE5 Tdd cell3+Tdd cell6
#    ...    UE6 Tdd cell3+Fdd cell1
#    ...    UE11 Tdd cell6+Tdd cell3
#    SA Attach    sa_ue_id=1
#    Check SA Scell PhysicalID With UE ID    ue_id=1    scell_physicalid=52    scell_index=1
#    SA Attach    sa_ue_id=5
#    Check SA Scell PhysicalID With UE ID    ue_id=5    scell_physicalid=55    scell_index=1
#    SA Attach    sa_ue_id=6
#    Check SA Scell PhysicalID With UE ID    ue_id=6    scell_physicalid=50    scell_index=1
#    SA Attach    sa_ue_id=11
#    Check SA Scell PhysicalID With UE ID    ue_id=11    scell_physicalid=52    scell_index=1
#
#CA UE Start UL Traffic And Check Tput
#    [Arguments]    ${sa_ue_list}
#    [Documentation]    this keyword is to start ul udp traffic, then check tput
#    @{ue_list}    Split String    ${sa_ue_list}    ,
#    : FOR    ${t_ue_id}    IN    @{ue_list}
#    \    SA Start UL Traffic Internal    ue_id=${t_ue_id}    pdu_id=1    mbps=50    trf_id=1
#    Check Tput Per UE    ueId=1    dlTput=60    ulTput=20    PcellDlTput=15    ScellDlTput=75
#    Check Tput Per UE    ueId=5    dlTput=150    ulTput=15    PcellDlTput=75    ScellDlTput=150
#    Check Tput Per UE    ueId=6    dlTput=75    ulTput=10    PcellDlTput=75    ScellDlTput=35
#    Check Tput Per UE    ueId=11    dlTput=145    ulTput=35    PcellDlTput=150    ScellDlTput=75
#
#Check Tput Per UE
#    [Arguments]    ${ueId}    ${dlTput}    ${ulTput}    ${PcellDlTput}    ${ScellDlTput}
#    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    25s    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=pcell    scell_index=0    target_tp=${PcellDlTput}
#    Check UE Pcell Scell TP On Target    ue_id=${ueId}    dir=dl    cell_type=scell    scell_index=1    target_tp=${ScellDlTput}
#
#Set WTS CFG LTE To 20MHz
#    ${file_path}    Set Variable    /opt/iphy/latest/${WTS_CFG}
#    @{old_params_list}    Create List    enb=2 bw=10MHz
#    @{new_params_list}    Create List    enb=2 bw=20MHz
#    Modify Text File    ${file_path}    ${old_params_list}    ${new_params_list}
