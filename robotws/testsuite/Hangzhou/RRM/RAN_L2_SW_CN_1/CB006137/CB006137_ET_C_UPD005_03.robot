*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF}    swconfig_param=${SWCONF}    iphy_file=${IPHYFILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SG06    CB006137
#Resource          ./../CB008015/resources/CB008015_lib.robot
#Resource          resources/6137_BO_lib.robot
#
#*** Variables ***
#${SCF_PATH}                  ${CURDIR}/config
#${FULL_SCF}                  CB006137_AC_BO_UPD005_03.xml
#${IPHYFILE}                  ${CURDIR}/config/WTS/iphy_1F_1T.xml
#${SWCONF}                    0x58056B=1
#${WTS_LOCAL}                 ${CURDIR}/config/WTS
#${WTS_DIR}                   /opt/wts/latest/
#${WTS_CFG}                   CB006137_UPD005_03.cfg
#${WTS_AP_XML}                airphone.xml
#${UE_ID}                     3
#${SCELL_ID}                  50
#${PCELL_ID}                  51
#
#*** Test Cases ***
#CB006137_ET_C_UPD005_03_Both_UMNonGBRbearer_AMNonGBRbearer_Scell_Addition_With_ULCA
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...    AND    Common Test Setup
#    SA 5G CA Attach    ${UE_ID}
#    Trigger 5QI 5 Setup    ${UE_ID}
#    Trigger A1 Scell Addition    ${UE_ID}    100    ${PCELL_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_ID}    1
#    Start SA UM Non GBR Bearer DL And UL Traffic    ueId=${UE_ID}    qfi_id=2    dl_trf=100    ul_trf=100
#    Capture Convert Format Ttitrace With Streaming Mode    2s
#    Check TP On Target    ${UE_ID}    0    1    90    85
#    SA 5G Detach    ${UE_ID}
#
#*** Keywords ***
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=100    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=600    trf_id=1
#
#Start SA DL Big Traffic Internal
#    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
#    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
#    ${dl_times}    Evaluate    int(${mbps}/${175})
#    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
#    \    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=175    trf_id=${t_time}
#    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
#    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${last_mbps}    trf_id=${dl_times+1}
#
#Check TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${dlsum_tp}    Evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
#    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    ${ulsum_tp}    Evaluate    ${pcell_ulTP}+${scell_ulTP}
#    Log To Console    UL Troughput is ${ulsum_tp}    console=True
#    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}
#
#Start SA UM Non GBR Bearer DL And UL Traffic
#    [Arguments]    ${ueId}    ${qfi_id}    ${dl_trf}    ${ul_trf}
#    Log To Console    Start VONR DL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=tcp
#    Log To Console    Start VONR UL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=tcp
#    Sleep    5s    reason=wait DL/UL traffic is stable
