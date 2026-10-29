*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Resource          ./resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}        ${CURDIR}/config
#${FULL_SCF}        8015_full_scfc.xml
#${FULL_SCF2}        8015_B_011_SCF.xml
#${DELTA_SCF11}       Delta_8015_B_11.json
#${DELTA_SCF19}       Delta_8015_B_19.json
#${IPHYFILE}        ${CURDIR}/config/wts/iphy_4F_2T.xml
#${IPHYFILE2}        ${CURDIR}/config/wts/8015_B_011_iphy.xml
#${WTS_LOCAL}       ${CURDIR}/config/wts
#${WTS_DIR}         /opt/wts/latest/
#${WTS_CFG}         basic_8015_Nina.cfg
#${WTS_CFG2}         8015_B_011.cfg
#${WTS_AP_XML}      airphone.xml
#@{LIST_UE_ID11}      1    11
#@{LIST_UE_ID19}      5    3    11    6
#@{LIST_CELL_ID}      55    52    54
#@{LIST_SCELL_ID}      55    52    51
#
#*** Test Cases ***
#CB008015_B_011_Scell_Selection_Different_Cellload_And_BW_Same_Weight_Of_CovbasedA1_Scell_Addition
#    [Tags]        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#    ...               SBTS00     CN1_SG06    CB008015
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF2}    iphy_file=${IPHYFILE2}
#    ...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG2}
#    ...               AND    Delta Commission    delta_scf=${DELTA_SCF11}
#    ...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2    wts_cfg_file=${WTS_CFG2}
#    ...               AND    Common Test Setup
#
#    Attach 2 CA UE And Check Scell Addition Successful
#    Start SA DLUL Big Traffic Internal For 2UE
#    Sleep    40s    reason=wait for dl traffic stable
#    Check SA UE Throughput For 2UE
#    SA Stop Data Traffic Internal    ${LIST_UE_ID11}[0]    pdu_id=1
#    SA Stop Data Traffic Internal    ${LIST_UE_ID11}[1]    pdu_id=1
#
#CB008015_B_019_Verify_4_UEs_Of_Mix_CA_Mode_And_TDDCell_T1_As_Pcell_With_Blind_SCell_Addition_Method_When_SA
#    [Tags]        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CIT    RAN_5G_TDD    RAN_5G    Owner_nilei
#    ...               SBTS00     CN1_SG06    CB008015
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF}    iphy_file=${IPHYFILE}
#    ...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#    ...               AND    Delta Commission    delta_scf=${DELTA_SCF19}
#    ...               AND    Reboot TL And Check Configured
#    ...               AND    Suite Setup Start WTS And Check OnAir    enb_id=2    gnb_id=1
#    ...               AND    Common Test Setup
#
#    Attach 4 CA UE And Check Scell Addition Successful
#    Start SA DLUL Big Traffic Internal For 4UE
#    Sleep    40s    reason=wait for dl traffic stable
#    Check SA UE Throughput For 4UE
#    Stop SA DLUL Big Traffic Internal    @{LIST_UE_ID19}
#
#*** Keywords ***
#Attach 2 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 2 CA UE:
#    ...    Fdd cell1:10MHz DSS, Fdd cell5:10MHz, Tdd cell3:60MHz, Tdd cell6 60MHz
#    ...    UE1 Fdd cell1+Tdd cell3
#    ...    UE11 Tdd cell6+Fdd cell5
#    SA Attach    ${LIST_UE_ID11}[0]
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID11}[0]    @{LIST_CELL_ID}[1]    1
#    SA Attach    ${LIST_UE_ID11}[1]
#    Trigger A1 Scell Addition    ${LIST_UE_ID11}[1]    100    @{LIST_CELL_ID}[0]
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID11}[1]    @{LIST_CELL_ID}[2]    1
#
#Attach 4 CA UE And Check Scell Addition Successful
#    [Documentation]    This keyword is to attach 4 CA UE:
#    ...    Fdd cell2:10MHz, Tdd cell3:60MHz, Tdd cell6 60MHz
#    ...    UE5 Tdd cell3+Tdd cell6
#    ...    UE3 Fdd cell2+Tdd cell3
#    ...    UE11 Tdd cell6+Tdd cell3
#    ...    UE6 Tdd cell3+Fdd cell2
#    SA Attach    ${LIST_UE_ID19}[0]
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID19}[0]    @{LIST_SCELL_ID}[0]    1
#    SA Attach    ${LIST_UE_ID19}[1]
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID19}[1]    @{LIST_SCELL_ID}[1]    1
#    SA Attach    ${LIST_UE_ID19}[2]
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID19}[2]    @{LIST_SCELL_ID}[1]    1
#    SA Attach    ${LIST_UE_ID19}[3]
#    Check SA Scell PhysicalID With UE ID    ${LIST_UE_ID19}[3]    @{LIST_SCELL_ID}[2]    1
#
#Start SA DLUL Big Traffic Internal For 2UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID11}[0]    pdu_id=1    mbps=600   trf_id=1
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID11}[1]    pdu_id=1    mbps=600   trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID11}[0]    pdu_id=1    mbps=60    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID11}[1]    pdu_id=1    mbps=60    trf_id=1
#
#Start SA DLUL Big Traffic Internal For 4UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID19}[0]    pdu_id=1    mbps=255   trf_id=1
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID19}[1]    pdu_id=1    mbps=115   trf_id=1
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID19}[2]    pdu_id=1    mbps=255   trf_id=1
#    SA Start DL Traffic Internal    ue_id=${LIST_UE_ID19}[3]    pdu_id=1    mbps=115   trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID19}[0]    pdu_id=1    mbps=30    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID19}[1]    pdu_id=1    mbps=20    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID19}[2]    pdu_id=1    mbps=60    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${LIST_UE_ID19}[3]    pdu_id=1    mbps=30    trf_id=1
#
#Stop SA DLUL Big Traffic Internal
#    [Arguments]    @{LIST_UE_ID19}
#    [Documentation]    this keyword is to stop all traffic.
#    FOR    ${UE_ID}    IN    @{LIST_UE_ID19}
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    END
#
#Check Tput Per UE
#    [Arguments]    ${ueId}    ${dlTput}    ${ulTput}
#    [Documentation]    this keyword is to check UE Tput by 2 ways.
#    Wait Until Keyword Succeeds    30s    5s    SA UE Check Throughput    ${ueId}    ${dlTput}    ${ulTput}
#
#Check TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_sum_tp}
#    ${pcell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_TP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${sum_tp}    Evaluate    ${pcell_TP}+${scell_TP}
#    Log To Console    DL Troughput is ${sum_tp}    console=True
#    Should Be True    ${sum_tp}>=${target_sum_tp}
#
#Check UE Total Tput11
#    Check TP On Target    1    0    1    350
#    Check TP On Target    11    0    1    500
#
#Check UE Total Tput19
#    Check TP On Target    5    0    1    220
#    Check TP On Target    3    0    1    90
#    Check TP On Target    11    0    1   220
#    Check TP On Target    6    0    1    90
#
#Check SA UE Throughput For 2UE
#    [Documentation]    this keyword is to check tput for 2UE
#    Check UE Total Tput11
#    Check Tput Per UE    ueId=${LIST_UE_ID11}[0]    dlTput=350    ulTput=50
#    Check Tput Per UE    ueId=${LIST_UE_ID11}[1]    dlTput=500    ulTput=30
#
#Check SA UE Throughput For 4UE
#    [Documentation]    this keyword is to check tput for 4UE
#    Check UE Total Tput19
#    Check Tput Per UE    ueId=${LIST_UE_ID19}[0]    dlTput=140   ulTput=20
#    Check Tput Per UE    ueId=${LIST_UE_ID19}[1]    dlTput=60   ulTput=5
#    Check Tput Per UE    ueId=${LIST_UE_ID19}[2]    dlTput=140   ulTput=40
#    Check Tput Per UE    ueId=${LIST_UE_ID19}[3]    dlTput=60   ulTput=10
#
