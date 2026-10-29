*** Settings ***
Test Teardown     Common Test Teardown
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD   CRT    RAN_5G_TDD    RAN_5G
...               SBTS00    VRF4_SG11    CB012528    owner_qiaren
Resource          ./../CUDU_L2/common_setup_teardown.robot

Documentation
...     9928 test interwork With 11080

*** Variables ***
${SCF_PATH}                 ${CURDIR}/Config/
${SCFC_FILE}                CB009928_iwk_6cc_SCF.xml
${LOCAL_WTS_DIR}            ${CURDIR}/Config/wts/
${WTS_DIR}                  /opt/iphy/latest
${IPHY_XML}                 ${CURDIR}/Config/wts/iphy_CB009928_iwk_6cc.xml
${WTS_CFG}                  CB009928_iwk_6cc.lua
${SWCONFIG_PARAM_GNB}       0x890071=1;

${UE_1}                     1
${UE_3}                     3
${PDU_ID}         1
${MCC}                      311
${MNC}                      489
${AMF1_REGION}              1:2:2
${AMF2_REGION}              2:3:3
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

${6CC_NUM}                  6
@{6CC_DL_TPUT}         120    30    80    120    120    120
@{2CC_UL_TPUT_LIST}         11    30
@{6CC_SCELL_PCI_3T3F}       51    52    53    54    55

${A2_COMMAND}   ue_measurement_send_nr  id\=3 meas_id\=9 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=5 scell_rsrp\=100 scell_rsrq\=100
...    scell\=4 scell_rsrp\=60 scell_rsrq\=60


*** Test Cases ***
9928_TMO_CVR_003_test_plan
    [Setup]    Run Keywords      Suite Setup Update GNB    scf_file=${SCFC_FILE}    iphy_file=${IPHY_XML}    #swconfig_param=${SWCONFIG_PARAM_GNB}
    #[Setup]    Run Keywords      Suite Setup Update GNB    force_reboot=True
    ...        AND    Configure IP For UEC2
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir With Egate Log
    ...        AND    Common Test Setup
    ute_wtssim.Execute Egate Command    cmd=uec_l2_testmode_params fixed_csi_report\=true

    Single Ue Attach and Scell Add    ${UE_1}    ${AMF1_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_1}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
    Single Ue Attach and Scell Add    ${UE_3}    ${AMF2_REGION}
    Check SA All Scell PhysicalID With UE ID    ${UE_3}    ${6CC_SCELL_PCI_3T3F}    ${6CC_NUM}
    Start SA UE Big DL Traffic Internal    ${UE_1}    1000
    Start SA UE Big DL Traffic Internal   ${UE_3}    1000
    Start SA UE Big UL Traffic Internal    ${UE_1}    80
    Start SA UE Big UL Traffic Internal    ${UE_3}    80
    Sleep    30s    reason=wait 30s for traffic statble
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_1}    ${6CC_DL_TPUT}    ${6CC_NUM}
    Wait Until Keyword Succeeds    30s    5s    Check UE DL All Pcell Scell TP On Target For Single UE    ${UE_3}    ${6CC_DL_TPUT}    ${6CC_NUM}
    A1 Based Pcell Switch For UE1
    A2 Based Pcell Switch For UE3
    Check Tput After Pcell Switch    1

*** Keywords ***
Configure IP For UEC2
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
Single Ue Attach and Scell Add
    [Arguments]    ${ue_id}    ${amf_region}=1:2:2
    Log To Console    UE${ue_id} Start Attach...
    SA 5G Attach    ue_id=${ue_id}
    SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${PDU_ID}
    ute_wtssim.Execute Egate Command    cmd=ue_nr_rrc_setup_param id\=${ue_id} registered_amf\=${MCC}:${MNC}|${amf_region}
    #Sleep    0.5s    reason=wait for taking effect
    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_pdu_session_setup pdu=${PDU_ID} ue=${ue_id} nwslice=1
    ...    pass_regexp=setup/reestablishment complete    timeout=3minutes
    Send A1 Report    ${ue_id}    srsrp_nr=120    phycell_id=56    meas_id=1
    ute_wtssim.Execute Egate Command    sim_log_set flush

A1 Based Pcell Switch For UE1
    #Switch from T1 to T2
    Log To Console    UE1 Trigger A1 Pcell switch ...
    ${pattern}    Set Variable    UE1: Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.6 performed
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_measurement_send_nr id\=1 event\=A1 scell\=5 scell_rsrp\=102 meas_id\=3    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE1 Trigger A1 Pcell switch is OK
A2 Based Pcell Switch For UE3
    #Switch from T1 to T2
    Log To Console    UE3 Trigger A2 Pcell switch ...
    ${pattern}    Set Variable    UE3: Intra-eNB handover from EXT_ENB-2.7 to EXT_ENB-2.6 performed
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data     ${A2_COMMAND}    pass_regexp=${pattern}    timeout=2min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    UE3 Trigger A2 Pcell switch is OK

Check Tput After Pcell Switch
    [Arguments]    ${log_id}
    Sleep    10s    reason=wait for traffic stable
    Run Keyword And Ignore Error    Capture Logs And Check TTitrace    ${log_id}
    Check CA UE Pcell Scell Cell TPut On Target    1    dl    pcell    0    200
    Check CA UE Pcell Scell Cell TPut On Target    3    dl    pcell    0    200

Capture Logs And Check TTitrace
    [Arguments]    ${log_idx}
    CUDU L2 Capture And Decode TTitrace    log_id=${log_idx}    duration=0.2
    CUDU L2 Check DTXNACK Rate    log_id=${log_idx}
    CUDU L2 Check UL DTXCRC Rate    log_id=${log_idx}
