*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${Full_SCF}    swconfig_param=${SWCONF}    iphy_file=${IPHYFILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    CB009169    CRT    RAN_5G    RAN_5G_TDD
#...               Owner_nilei    CN1_SQ6    SBTS00    SBTS23R3
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${SCF_PATH}         ${CURDIR}/Config
#${FULL_SCF}         CB009169_LOO_BC302.xml
#${IPHYFILE}         ${CURDIR}/Resources/wts/iphy_LOO1T1F_BC302.xml
#${SWCONF}           0x580692=1
#${WTS_LOCAL}        ${CURDIR}/Resources/wts
#${WTS_DIR}          /opt/wts/latest/
#${WTS_CFG}          CB009169_LOO_BC302.cfg
#${WTS_AP_XML}       airphone.xml
#${UE_ID1}           1
#${UE_ID2}           2
#${SCELL_ID}         51
#&{COUNTER1_INFO}    counter_id=M55910C00002    counter_path=CELLS/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG    min_value=42    max_value=47
#&{COUNTER2_INFO}    counter_id=M55910C00002    counter_path=CELLS/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG   min_value=53    max_value=57
#&{COUNTER3_INFO}    counter_id=M55910C00002    counter_path=CELLS/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG    min_value=42    max_value=47
#&{COUNTER4_INFO}    counter_id=M55910C00002    counter_path=CELLS/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG    min_value=53    max_value=57
#@{COUNTER_LIST}     ${COUNTER1_INFO}    ${COUNTER2_INFO}    ${COUNTER3_INFO}    ${COUNTER4_INFO}
#
#*** Test Cases ***
#CB009169_ET_BC302_FR1_TDD_FDD_UL_2CC_A1_ScellAdd_BufferBaseScellAct_SliceAware_MultiDRB_IWK8132
#    [Setup]    Run Keywords    Suite Setup Start WTS And Check OnAir    enb_id=1    gnb_id=2
#    ...    AND    Common Test Setup
#    SA Attach    ${UE_ID1}    1    1
#    Check SA Scell PhysicalID With UE ID    ${UE_ID1}    ${SCELL_ID}    1
#    SA Attach    ${UE_ID2}    2    2
#    Check SA Scell PhysicalID With UE ID    ${UE_ID1}    ${SCELL_ID}    1
#    Start SA DLUL Big Traffic Internal For UE
#    Check TP On Target    ${UE_ID1}    0    1    330    70
#    Check TP On Target    ${UE_ID2}    0    1    420    70
#    Check PM Counter Slice TP
#    Check PM Counter Target Share
#
#*** Keywords ***
#SA Attach
#    [Arguments]    ${sa_ue_id}    ${pdu_id}    ${slice_id}
#    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
#    ...    ue_register
#    ...    set_pdu_param
#    ...    ue_pdu_session_setup
#    SA 5G Attach    ue_id=${sa_ue_id}
#    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=${pdu_id}
#    SA 5G Slice PDU Session Setup    ue_id=${sa_ue_id}    pdu_id=${pdu_id}    slice_id=${slice_id}
#    Trigger A1 Scell Addition    ${sa_ue_id}    100    50
#
#Start SA DLUL Big Traffic Internal For UE
#    [Documentation]    this keyword is to start all traffic.
#    SA Start UL Traffic Internal    ue_id=${UE_ID1}    pdu_id=1    mbps=100    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID1}    pdu_id=1    mbps=450    trf_id=1
#    SA Start UL Traffic Internal    ue_id=${UE_ID2}    pdu_id=2    mbps=100    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID2}    pdu_id=2    mbps=450    trf_id=1
#
#Check TP On Target
#    [Arguments]    ${ueId}    ${pcell_index}    ${scell_index}    ${target_dlsum_tp}    ${target_ulsum_tp}
#    Sleep    40s    reason=Wait for TP collection...
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
#Check PM Counter Slice TP
#    [Documentation]    this keyword is to Check PM Counter Slice TP.
#    Wait Until PM Counter Update    5min    2
#    ${counter1_info}    Get PM Counter Latest Value From Admin    M55910C00001    CELLS/NRCELL-1/NRRESOURCEGROUP-1/NCUPNRG
#    ${counter2_info}    Get PM Counter Latest Value From Admin    M55910C00001    CELLS/NRCELL-1/NRRESOURCEGROUP-2/NCUPNRG
#    ${counter3_info}    Get PM Counter Latest Value From Admin    M55910C00001    CELLS/NRCELL-2/NRRESOURCEGROUP-1/NCUPNRG
#    ${counter4_info}    Get PM Counter Latest Value From Admin    M55910C00001    CELLS/NRCELL-2/NRRESOURCEGROUP-2/NCUPNRG
#    ${counter5_info}    Get PM Counter Latest Value From Admin    M55308C10013    CELLS/NRCELL-1/NCELA
#    ${counter6_info}    Get PM Counter Latest Value From Admin    M55308C10013    CELLS/NRCELL-2/NCELA
#    ${cell1_slice1_value}    Evaluate    float(${counter1_info})/float(${counter5_info})
#    Should Be True    ${cell1_slice1_value}>0.41
#    ${cell1_slice2_value}    Evaluate    float(${counter2_info})/float(${counter5_info})
#    Should Be True    ${cell1_slice2_value}>0.53
#    ${cell2_slice1_value}    Evaluate    float(${counter3_info})/float(${counter6_info})
#    Should Be True    ${cell2_slice1_value}>0.41
#    ${cell2_slice2_value}    Evaluate    float(${counter4_info})/float(${counter6_info})
#    Should Be True    ${cell2_slice2_value}>0.53
#
#Check PM Counter Target Share
#    [Documentation]    this keyword is to Check PM Counter M55910C00002.
#    Wait Until PM Counter Update    5min    3
#    Check Multi PM Counters Latest Value From Admin    ${COUNTER_LIST}
#
#SA 5G Slice PDU Session Setup
#    [Arguments]    ${ue_id}    ${pdu_id}=1    ${slice_id}=1
#    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
#    ...    Expected output is: " Initial Context Setup Successful " on eGate.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    Example:
#    ...    | SA 5G PDU Session Setup | 1 |
#    Log To Console    start 5G PDU Session Setup...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${slice_id} gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#Capture BIP Log
#    [Arguments]    ${log_id}    ${timer}=3
#    Start Gnb BIP Log
#    Sleep    ${timer}s
#    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY}/${log_id}
#    OperatingSystem.Run
#    ...    mergecap -a -w ${TEST_LOG_DIRECTORY}/${log_id}/mirroring_L2L1_eths3.pcap ${TEST_LOG_DIRECTORY}/${log_id}/mirroring_L2L1_eths3*.pcap
#
#Capture And Decode TTitrace When NACKFLOOD Trigger
#    Start Ttitrace With Streaming Mode
#    Sleep    3s    reason=Wait for log collection...
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/BC403
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/BC403
