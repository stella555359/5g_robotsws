*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF_HAZ4_T11    CB009928    owner_peafu
Resource          ./../CUDU_L2/common_setup_teardown.robot

Documentation
...     CB009928_A_B1

*** Variables ***
${SCF_PATH}         ${CURDIR}/Config/
${SCFC_FILE}        SCF_9928.xml
${LOCAL_WTS_DIR}    ${CURDIR}/Config/wts
${WTS_DIR}          /opt/iphy/latest
${IPHY_XML}         ${CURDIR}/Config/wts/iphy_CB009928.xml
${WTS_CFG}          9928.cfg
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
CB009928_A_B1_101_A1_measurement_based_Pcell_switch_from_T_to_T_SA_DL_3CC_CA
    [Setup]    Run Keywords    Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}
    ...    AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...    AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...    AND    Common Test Setup
    SA UE Attach And Scell Addition
    NSA UE Attach And Check Scell Addition
    Setup Traffic
    Check Tput Before Pcell Switch    1
    Save Snapshot Log    log_id=1
    A1 Based Pcell Switch
    A2 Based Pcell Switch
    Check Tput After Pcell Switch     2
    Save Snapshot Log    log_id=2

*** Keywords ***
SA UE Attach And Scell Addition
    SA 5G CA Attach    ${UE_ID_1}    pdu_id=1
    Send A1 Report    ${UE_ID_1}    srsrp_nr=120    phycell_id=50    meas_id=1
    SA 5G CA Attach    ${UE_ID_2}    pdu_id=1
    Send A1 Report    ${UE_ID_2}    srsrp_nr=120    phycell_id=50    meas_id=1
    SA 5G CA Attach    ${UE_ID_3}    pdu_id=1
    Send A1 Report    ${UE_ID_3}    srsrp_nr=120    phycell_id=50    meas_id=1
    SA 5G CA Attach    ${UE_ID_4}    pdu_id=1
    Send A1 Report    ${UE_ID_4}    srsrp_nr=120    phycell_id=51    meas_id=1


NSA UE Attach And Check Scell Addition
    NSA UE Attach    ${UE_ID_81}    ${GNB_ID}    1    ${BEARER_ID}
    Trigger A1 Scell Addition    ${UE_ID_81}    120    50
    NSA UE Attach    ${UE_ID_82}    ${GNB_ID}    1    ${BEARER_ID}
    Trigger A1 Scell Addition    ${UE_ID_82}    120    50
    NSA UE Attach    ${UE_ID_83}    ${GNB_ID}    1    ${BEARER_ID}
    Trigger A1 Scell Addition    ${UE_ID_83}    120    50
    NSA UE Attach    ${UE_ID_84}    ${GNB_ID}    3    ${BEARER_ID}
    Trigger A1 Scell Addition    ${UE_ID_84}    120    51

NSA UE Attach
    [Arguments]    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}
    NSA LTE Attach    ${ue_id}
    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${cell_id}    ${BEARER_ID}


Start DLUL Traffic
    [Arguments]    ${ue}    ${dl_trf}    ${ul_trf}
    Start SA UE Big DL Traffic Internal    ${ue}    ${dl_trf}
    Start SA UE Big UL Traffic Internal    ${ue}    ${ul_trf}

Setup Traffic
    Log To Console    start DL and UL Traffic
    Start DLUL Traffic    ${UE_ID_1}    dl_trf=700    ul_trf=100
    Start DLUL Traffic    ${UE_ID_2}    dl_trf=700    ul_trf=100
    Start DLUL Traffic    ${UE_ID_3}    dl_trf=700    ul_trf=100
    Start DLUL Traffic    ${UE_ID_4}    dl_trf=700    ul_trf=100
    Start NSA Traffic
    Sleep    20s    reason=Wait For Data Transmission

Start NSA Traffic
    Log To Console    start NSA Traffic
    NSA Start DL Traffic    ${UE_ID_81}    ${BEARER_ID}    100    1
    NSA Start DL Traffic    ${UE_ID_82}    ${BEARER_ID}    100    1
    NSA Start DL Traffic    ${UE_ID_83}    ${BEARER_ID}    100    1
    NSA Start DL Traffic    ${UE_ID_84}    ${BEARER_ID}    100    1
    FOR    ${ue_id}    IN    @{NSA_UE_ID_LIST}
        NSA Start UL Traffic    ${ue_id}    ${BEARER_ID}    15
    END



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
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    pcell    0    30
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    1    50
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    scell    2    10
    Check CA UE Pcell Scell Cell TPut On Target    2    ul    pcell    0    5
    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    30
    Check CA UE Pcell Scell Cell TPut On Target    3    dl    scell    1    50
    Check CA UE Pcell Scell Cell TPut On Target    3    dl    scell    2    10
    Check CA UE Pcell Scell Cell TPut On Target    3    ul    pcell    0    5
    Check CA UE Pcell Scell Cell TPut On Target    4    dl    pcell    0    3
    Check CA UE Pcell Scell Cell TPut On Target    4    dl    scell    1    60
    Check CA UE Pcell Scell Cell TPut On Target    4    dl    scell    2    50
    Check CA UE Pcell Scell Cell TPut On Target    4    ul    pcell    0    20
    Check CA UE Pcell Scell Cell TPut On Target    81    dl    pcell    8    30
    Check CA UE Pcell Scell Cell TPut On Target    81    dl    scell    9    50
    Check CA UE Pcell Scell Cell TPut On Target    81    ul    pcell    8    5
    Check CA UE Pcell Scell Cell TPut On Target    82    dl    pcell    8    30
    Check CA UE Pcell Scell Cell TPut On Target    82    dl    scell    9    50
    Check CA UE Pcell Scell Cell TPut On Target    82    ul    pcell    8    5
   	Check CA UE Pcell Scell Cell TPut On Target    83    dl    pcell    8    30
    Check CA UE Pcell Scell Cell TPut On Target    83    dl    scell    9    10
    Check CA UE Pcell Scell Cell TPut On Target    83    ul    pcell    8    10
   	Check CA UE Pcell Scell Cell TPut On Target    84    dl    pcell    8    3
    Check CA UE Pcell Scell Cell TPut On Target    84    dl    scell    9    60
    Check CA UE Pcell Scell Cell TPut On Target    84    ul    pcell    8    10


A1 Based Pcell Switch
    A1 Based Pcell Switch For UE1
    A1 Based Pcell Switch For UE2
    A1 Based Pcell Switch For UE81
    A1 Based Pcell Switch For UE83

A2 Based Pcell Switch
    A2 Based Pcell Switch For UE3
    A2 Based Pcell Switch For UE4
    A2 Based Pcell Switch For UE82
    A2 Based Pcell Switch For UE84

Check Tput After Pcell Switch
    [Arguments]    ${log_id}
    Sleep    10s    reason=wait for traffic stable
    Run Keyword And Ignore Error    Capture Logs And Check TTitrace    ${log_id}
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    75
    Check CA UE Pcell Scell Cell TPut On Target    2    dl    pcell    0    28
    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    75
    Check CA UE Pcell Scell Cell TPut On Target    4    dl    pcell    0    190
    Check CA UE Pcell Scell Cell TPut On Target    81    dl    pcell    8    75
    Check CA UE Pcell Scell Cell TPut On Target    82    dl    pcell    8    75
    Check CA UE Pcell Scell Cell TPut On Target    83    dl    pcell    8    28
    Check CA UE Pcell Scell Cell TPut On Target    84    dl    pcell    8    95


A1 Based Pcell Switch For UE1
    #Switch from T1 to T2
    Log To Console    UE1 Trigger A1 Pcell switch ...
    ${pattern}    Set Variable    UE1: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=1 event\=A1 scell\=1 scell_rsrp\=102 meas_id\=2    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE1 Trigger A1 Pcell switch is OK

A1 Based Pcell Switch For UE2
    #Switch from T1 to F1
    Log To Console    UE2 Trigger A1 Pcell switch ...
    ${pattern}    Set Variable    UE2: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=2 event\=A1 scell\=2 scell_rsrp\=102 meas_id\=3    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE2 Trigger A1 Pcell switch is OK

A1 Based Pcell Switch For UE81
    #Switch from T1 to T2
    Log To Console    UE81 Trigger A1 Pcell switch ...
    ${pattern}    Set Variable    UeId:80,BwpId:1, pcid:52, scellIdx:8
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=81 event\=A1 scell\=9 scell_rsrp\=100 meas_id\=3    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE81 Trigger A1 Pcell switch is OK

A1 Based Pcell Switch For UE83
    #Switch from T1 to F1
    Log To Console    UE83 Trigger A1 Pcell switch ...
    ${pattern}    Set Variable    UeId:82,BwpId:1, pcid:51, scellIdx:8
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=83 event\=A1 scell\=9 scell_rsrp\=100 meas_id\=2    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE83 Trigger A1 Pcell switch is OK


A2 Based Pcell Switch For UE3
    #Switch from T1 to T2
    Log To Console    UE3 Trigger A2 Pcell switch ...
    ${pattern}    Set Variable    UE3: Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    ute_wtssim.Execute Egate Command    ue_measurement_send_nr id\=3 event\=A2 srsrp_nr\=50 meas_id\=4
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=3 event\=A1 scell\=1 scell_rsrp\=102 meas_id\=2    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE3 Trigger A2 Pcell switch is OK

A2 Based Pcell Switch For UE4
    #Switch from F1 to T1
    Log To Console    UE4 Trigger A2 Pcell switch ...
    ${pattern}    Set Variable    UE4: Intra-eNB handover from EXT_ENB-2.3 to EXT_ENB-2.1 performed
    ute_wtssim.Execute Egate Command    ue_measurement_send_nr id\=4 event\=A2 srsrp_nr\=50 meas_id\=3
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=4 event\=A1 scell\=1 scell_rsrp\=102 meas_id\=2    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE4 Trigger A2 Pcell switch is OK

A2 Based Pcell Switch For UE82
    #Switch from T1 to T2
    Log To Console    UE82 Trigger A2 Pcell switch ...
    ${pattern}    Set Variable    UeId:81,BwpId:1, pcid:52, scellIdx:8
    ute_wtssim.Execute Egate Command
    ...    ue_measurement_send_nr id\=82 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=9 scell_rsrp\=90 scell_rsrq\=90 meas_id\=2
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=82 event\=A1 scell\=9 scell_rsrp\=102 meas_id\=3    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE82 Trigger A2 Pcell switch is OK

A2 Based Pcell Switch For UE84
    #Switch from F1 to T1
    Log To Console    UE84 Trigger A2 Pcell switch ...
    ${pattern}    Set Variable    UeId:83,BwpId:1, pcid:50, scellIdx:8
    ute_wtssim.Execute Egate Command
    ...    ue_measurement_send_nr id\=82 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=9 scell_rsrp\=90 scell_rsrq\=90 meas_id\=2
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=84 event\=A1 scell\=9 scell_rsrp\=82 meas_id\=3    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE84 Trigger A2 Pcell switch is OK

Save Snapshot Log
    [Arguments]    ${log_id}    ${log_dir}=${TEST_LOG_DIRECTORY}
    [Documentation]    This keyword is to save snapshot log from admin.
    Log To Console    Save Snapshot Log...
    Run Keyword And Ignore Error    COAM.Setup Admin
    COAM.Collect Snapshot    ${log_dir}//Snapshot_${log_id}.zip
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
