*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF_HAZ4_T11    CB009928    owner_peafu
Resource          ./../CUDU_L2/common_setup_teardown.robot


*** Variables ***
${SCF_PATH}         ${CURDIR}/Config/
${SCFC_FILE}        SCF_9928_VONR.xml
${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts
${WTS_DIR}          /opt/iphy/latest
${IPHY_XML}         ${CURDIR}/Config/wts/iphy_CB009928.xml
${WTS_CFG}          9928_VONR.cfg
${UE_ID_1}          1
${UE_ID_2}          2
${UE_ID_3}          3
${UE_ID_4}          4
${UE_ID_81}         81
${UE_ID_82}         82
${UE_ID_83}         83
${UE_ID_84}         84
@{NSA_UE_ID_LIST}    81    82    83    84
${GNB_ID}           2
${BEARER_ID}        2
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB009928_A_B1_103_A1_measurement_based_Pcell_switch_from_T_to_T_SA_DL_3CC_CA_IWK_VoNR
    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...    AND    Common Test Setup
    SA UE Attach And Scell Addition 
	Setup Traffic
    Check Tput Before Pcell Switch    1  
	Save Snapshot Log    log_id=1
    Trigger 5QI 5 Setup    ${UE_ID_1} 
	Trigger 5QI 1 Setup    ${UE_ID_1}
	Start SA VONR GBR DL And UL Traffic    ueId=${UE_ID_1}    qfi_id=3    dl_trf=20    ul_trf=10
	Wait Until Keyword Succeeds    15s    5s    SA UE Check Throughput     ${UE_ID_1}    dl_tp_threshold=10    ul_tp_threshold=0.5    qfi=3
    A1 Based Pcell Switch For UE1	
	Wait Until Keyword Succeeds    15s    5s    SA UE Check Throughput     ${UE_ID_1}    dl_tp_threshold=10    ul_tp_threshold=0.5    qfi=3
    Check Tput After Pcell Switch     2
	Save Snapshot Log    log_id=2

*** Keywords ***
SA UE Attach And Scell Addition
    SA 5G CA Attach    ${UE_ID_1}    pdu_id=1
	Send A1 Report    ${UE_ID_1}    srsrp_nr=120    phycell_id=50    meas_id=1  

Start DLUL Traffic
    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}
    Start SA UE Big DL Traffic Internal    ${ue}    ${dl_trf}
    Start SA UE Big UL Traffic Internal    ${ue}    ${ul_trf}

Setup Traffic
    Log To Console    start DL and UL Traffic
    Start DLUL Traffic    ${UE_ID_1}    dl_trf=700    ul_trf=100
	Sleep    20s    reason=Wait For Data Transmission


Capture Logs And Check TTitrace
    [Arguments]    ${log_idx}
    CUDU L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=0.2
    CUDU L2 Check DTXNACK Rate    log_id=${log_idx}
    CUDU L2 Check UL DTXCRC Rate    log_id=${log_idx}

Check Tput Before Pcell Switch
    [Arguments]    ${log_id}
    Sleep    10s    reason=wait for traffic stable
    Run Keyword And Ignore Error    Capture Logs And Check TTitrace    ${log_id}
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    30
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    1    50
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    scell    2    10
    Check CA UE Pcell Scell Cell TPut On Target    1    ul    pcell    0    5	
	
Check Tput After Pcell Switch
    [Arguments]    ${log_id}
    Sleep    10s    reason=wait for traffic stable
    Run Keyword And Ignore Error    Capture Logs And Check TTitrace    ${log_id}	
	Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    75

	

A1 Based Pcell Switch For UE1
    #Switch from T1 to T2
    Log To Console    UE1 Trigger A1 Pcell switch ...
    ${pattern}    Set Variable    UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data  
    ...    ue_measurement_send_nr id\=1 event\=A1 scell\=1 scell_rsrp\=102 meas_id\=2    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE1 Trigger A1 Pcell switch is OK
	

Start SA VONR GBR DL And UL Traffic
    [Arguments]    ${ueId}    ${qfi_id}    ${dl_trf}    ${ul_trf}
    Log To Console    Start VONR DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${dl_trf} dir=dl protocol=udp
    Log To Console    Start VONR UL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ueId} pdu=1 qfi\=${qfi_id} trf_id=1 mbps\=${ul_trf} dir=ul protocol=udp
    Sleep    5s    reason=wait DL/UL traffic is stable
	
Save Snapshot Log
    [Arguments]    ${log_id}    ${log_dir}=${TEST_LOG_DIRECTORY}    
    [Documentation]    This keyword is to save snapshot log from admin.
    Log To Console    Save Snapshot Log...
    Run Keyword And Ignore Error    COAM.Setup Admin
    COAM.Collect Snapshot    ${log_dir}//Snapshot_${log_id}.zip
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
	
Trigger 5QI 5 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 5 Setup | 1 |
    Log To Console    start 5QI-5 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:2 5QI:5    partial_match=${true}
    Log To Console    ${output}

Trigger 5QI 1 Setup
    [Arguments]    ${ue_id}
    [Documentation]    This keyword is used to simulate PDU session setup on 5G-NR side.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | Trigger 5QI 1 Setup | 1 |
    Log To Console    start 5QI-1 Setup for UE${ue_id}...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Added QosFlow with QFI:3 5QI:1    partial_match=${true}
    Log To Console    ${output}
	
