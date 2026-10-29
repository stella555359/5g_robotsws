*** Settings ***
Documentation    ...
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Resource          ./resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}        ${CURDIR}/config
#${FULL_SCF}        8015_full_scfc_AP_LOO3.xml
#${DELTA_SCF11}       Delta_8015_B_11.json
#${DELTA_SCF19}       Delta_8015_B_19.json
#${IPHYFILE}        ${CURDIR}/config/wts/iphy_4F_2T_AP_LOO.xml
#${SWCONF}          0x58012d=4
#${WTS_LOCAL}       ${CURDIR}/config/wts
#${WTS_CFG2}        8015_B_011_019_LOO.cfg
#${WTS_AP_XML}      airphone.xml
#@{LIST_UE_ID11}      1    11
#@{LIST_UE_ID19}      3    2    6    7
#@{LIST_CELL_ID}      55    52    54
#@{LIST_SCELL_ID}      55    52    51
#
#*** Test Cases ***
#CB008015_B_011_Scell_Selection_Different_Cellload_And_BW_Same_Weight_Of_CovbasedA1_Scell_Addition
#    [Tags]        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#    ...               SBTS00     CN1_SG06    CB008015
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHYFILE}
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
#    [Tags]        CLOUD_5G_I_BOO_AP_LOO    CIT    RAN_5G_TDD    RAN_5G    Owner_nilei
#    ...               SBTS00     CN1_SG06    CB008015
#    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}   swconfig_param=${SWCONF}    iphy_file=${IPHYFILE}
#    ...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG2}
#    ...               AND    Delta Commission    delta_scf=${DELTA_SCF19}
#    ...               AND    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2    wts_cfg_file=${WTS_CFG2}
#    ...               AND    Common Test Setup
#
#    Attach 4 CA UE And Check Scell Addition Successful
#    Start SA DLUL Big Traffic Internal For 4UE
#    Sleep    40s    reason=wait for dl traffic stable
#    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id\=2,3,6,7 type\=pusch,pdsch scell\=0-5
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
#    Sleep    2s    reason=wait for catch logs
#    Capture BIP Log By Admin Method    capture_time=1s
#
#Stop SA DLUL Big Traffic Internal
#    [Arguments]    @{LIST_UE_ID19}
#    [Documentation]    this keyword is to stop all traffic.
#    FOR    ${UE_ID}    IN    @{LIST_UE_ID19}
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    END
#
#Check SA UE Throughput For 2UE
#    Check TP On Target    1    0    1    500    50
#    Check TP On Target    11    0    1    500    30
#
#Check SA UE Throughput For 4UE
#    Check TP On Target    3    0    1    245    20
#    Check TP On Target    2    0    1    105    10
#    Check TP On Target    6    0    1   245    40
#    Check TP On Target    7    0    1    105    10
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
