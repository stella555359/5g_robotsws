*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Setup        Run Keywords    Delta Commission    delta_scf=${Delta_scf}
#...               AND    Suite Setup Start WTS And Check OnAir
#...               AND    Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_w13li
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SQ6    CB008015
#Resource          resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}      ${CURDIR}/config
#${FULL_SCF}      8015_full_scfc_AP_LOO.xml
#${DELTA_SCF}     Delta_8015_B_18.json
#${IPHY_FILE}     ${CURDIR}/config/wts/iphy_4F_2T_AP_LOO.xml
#${WTS_LOCAL}     ${CURDIR}/config/wts
#${WTS_CFG}       basic_8015_AP_LOO.cfg
#${WTS_AP_XML}    airphone.xml
#${WTS_DIR}       /opt/wts/latest
#
#*** Test Cases ***
#CB008015_B_018_Verify_4_UEs_Of_Mix_CA_Mode_And_FDDCell_F2_As_Pcell_With_Blind_SCell_Addition_Method_When_NSA
#    UE Attach
#    Start Traffic
#    Check UE Total Tput
#    UE Detach
#
#*** Keywords ***
#UE Attach
#    SA Attach    5
#    Check SA Scell PhysicalID With UE ID    5    51    1
#    NSA F+T CA UE Attach    82
#    Check SA Scell PhysicalID With UE ID    82    52    9
#    SA Attach    4
#    Check SA Scell PhysicalID With UE ID    4    54    1
#    SA Attach    9
#    Check SA Scell PhysicalID With UE ID    9    51    1
#
#UE Detach
#    SA 5G Detach    5
#    SA 5G Detach    4
#    SA 5G Detach    9
#    NSA LTE Detach    82
#
#Start Traffic
#    Start SA DL Big Traffic Internal    5    250
#    SA Start UL Traffic Internal    5    1    30
#    NSA Start DL Traffic    ue_id=82    bearer_id=2    mbps=175
#    SA Start DL Traffic Internal    4    1    175
#    SA Start UL Traffic Internal    4    1    30
#    SA Start DL Traffic Internal    9    1    175
#    SA Start UL Traffic Internal    9    1    30
#
#Check Tput
#    Check Pcell Scell TP On Target    5    0    1    170    10
#    Check Pcell Scell TP On Target    82    8    9    10    160
#    Check Pcell Scell TP On Target    4    0    1    10    20
#    Check Pcell Scell TP On Target    9    0    1    20    10
#
#Check Pcell Scell TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${pcell_tput}    ${scell_tput}
#    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    Log To Console    Pcell DL Troughput is ${pcell_TP}    console=True
#    Log To Console    Scell DL Troughput is ${scell_TP}    console=True
#    Should Be True    ${pcell_TP}>=${pcell_tput}
#    Should Be True    ${scell_TP}>=${scell_tput}
#
#NSA F+T CA UE Attach
#    [Arguments]    ${ueId}    ${gnbId}=2    ${cellId}=2    ${bearID}=2
#    NSA LTE Attach    ue_id=${ueid}
#    NSA 5G Attach    ue_id=${ueId}    gnb_id=${gnbId}    cell_id=${cellId}    bearer_id=${bearID}
#    Log To Console    ue${ueId} NSA rach successfully.
#
#Check UE Total Tput
#    Sleep    3s     reason=make sure Tput stable
#    Check Tput On Target Pcell Plus Scell    5    0    1    180
#    Check Tput On Target Pcell Plus Scell    82    8    9    170
#    Check Tput On Target Pcell Plus Scell    4    0    1    30
#    Check Tput On Target Pcell Plus Scell    9    0    1    30
