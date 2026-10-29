*** Settings ***
Documentation    ...
#Suite Setup    Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF1}    swconfig_param=${SWCONF}  iphy_file=${IPHYFILE}
#...            AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    Owner_nilei
#...               SBTS00    SBTS23R1    SBTS22R4    CN1_SG06    CB006137
#Resource          ./../CB008015/resources/CB008015_lib.robot
#
#*** Variables ***
#${SCF_PATH}           ${CURDIR}/config
#${FULL_SCF1}          CB006137_BO_AB101.xml
#${FULL_SCF2}          CB006137_BO_AB201.xml
#${FULL_SCF3}          CB006137_BO_AB204.xml
#${IPHYFILE}           ${CURDIR}/config/WTS/iphy_1F_1T_LOO.xml
#${SWCONF}             0x58056B=1
#${WTS_LOCAL}          ${CURDIR}/config/WTS
#${WTS_DIR}            /opt/wts/latest/
#${WTS_CFG}            CB006137_BO_AB_Nina.cfg
#${WTS_AP_XML}         airphone.xml
#${REORDERING_WINDOW_SIZE}    500
#${REORDERING_TIMER}          300
#${UE_ID}      3
#${SCELL_ID}   50
#
#
#*** Test Cases ***
#CB006137_ET_AB101_BO_Verify_UCI_Over_PUSCH_On_Pcell_By_RAD_With_PDU_Setup_Not_Together_With_ICS_Blind_Scell_Addition_And_Activation_With_Non_BF
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...               AND    Common Test Setup
#    ...               AND    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#    SA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_ID}    1
#    Start SA DLUL Big Traffic Internal For UE
#    Sleep    40s    reason=wait for dl traffic stable
#    #Capture Convert Format Ttitrace With Streaming Mode    2s
#    Check TP On Target    ${UE_ID}    0    1    525    85
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ${UE_ID}
#
#CB006137_ET_AB201_BO_Verify_Ul256Qam_With_Blind_Scell_Addition_And_Activation_With_BF_And_RefineBeam_Disable
#    [Setup]    Run Keywords    Full Commission With SCF File    ${FULL_SCF2}
#    ...               AND    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...               AND    Common Test Setup
#    ...               AND    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#    SA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_ID}    1
#    Start SA DLUL Big Traffic Internal For UE
#    Sleep    40s    reason=wait for dl traffic stable
#    #Capture Convert Format Ttitrace With Streaming Mode    2s
#    Check TP On Target    ${UE_ID}    0    1    525    85
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#    SA 5G Detach    ${UE_ID}
#
#CB006137_ET_AB204_BO_Verify_Ul256Qam_With_Blind_Scell_Addition_And_Activation_With_BF_With_5GC002200_Enable
#    [Setup]    Run Keywords    Full Commission With SCF File    ${FULL_SCF3}
#    ...               AND    Run Keyword And Ignore Error    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...               AND    Common Test Setup
#    ...               AND    Set Reordering Timer    ${REORDERING_WINDOW_SIZE}    ${REORDERING_TIMER}
#
#    SA Attach    ${UE_ID}
#    Check SA Scell PhysicalID With UE ID    ${UE_ID}    ${SCELL_ID}    1
#    Start SA DLUL Big Traffic Internal For UE
#    Sleep    40s    reason=wait for dl traffic stable
#    #Capture Convert Format Ttitrace With Streaming Mode    2s
#    Check TP On Target    ${UE_ID}    0    1    520    80
#    SA Stop Data Traffic Internal    ${UE_ID}    pdu_id=1
#
#
#*** Keywords ***
#SA Attach
#    [Arguments]    ${sa_ue_id}
#    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
#    ...    ue_register
#    ...    set_pdu_param
#    ...    ue_pdu_session_setup
#    SA 5G Attach    ue_id=${sa_ue_id}
#    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
#    SA 5G PDU Session Setup    ue_id=${sa_ue_id}
#
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=100   trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=600   trf_id=1
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
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}   ${target_ulsum_tp}
#    ${pcell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    pcell    ${pcell_index}
#    ${scell_dlTP}    Get CA Cell Average Throughput    ${ueId}    dl    scell    ${scell_index}
#    ${dlsum_tp}    evaluate    ${pcell_dlTP}+${scell_dlTP}
#    Log To Console    DL Troughput is ${dlsum_tp}    console=True
#    Should Be True    ${dlsum_tp}>=${target_dlsum_tp}
#    ${pcell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    pcell    ${pcell_index}
#    ${scell_ulTP}    Get CA Cell Average Throughput    ${ueId}    ul    scell    ${scell_index}
#    ${ulsum_tp}    evaluate    ${pcell_ulTP}+${scell_ulTP}
#    Log To Console    UL Troughput is ${ulsum_tp}    console=True
#    Should Be True    ${ulsum_tp}>=${target_ulsum_tp}
