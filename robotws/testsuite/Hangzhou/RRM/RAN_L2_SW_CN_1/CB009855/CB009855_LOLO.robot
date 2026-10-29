*** Settings ***
Documentation    ...
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource    ./../CUDU_L2/common_log_capture.robot
Resource    ./Resources/CB009855_resource.robot
Force Tags        CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    SBTS00    CN1_SG09_SM2    RAN_5G    CRT

*** Variables ***
${LOCAL_WTS_DIR}     ${CURDIR}/Config
${SCF_PATH}          ${CURDIR}/Config
${SCF_9855_B8a_gnb1}    ${SCF_PATH}/SCF_B8a_gnb1.xml
${SCF_9855_B8a_gnb2}    ${SCF_PATH}/SCF_B8a_gnb2.xml
${IPHY_3T2F}        ${CURDIR}/Config/iphy_3T2F.xml
${WTS_CFG_B8a}           basic_setup_B8a.cfg
@{LOG_NAME_LIST}     btslog    egatelog
${force_reboot}      ${True}
${RD}                  0x4B000F=1;0x58057A=4;0x58057f=8192;0x58012d=2
${SCF_9855_B6a_gnb1}    ${SCF_PATH}/SCF_B6a_gnb1.xml
${SCF_9855_B6a_gnb2}    ${SCF_PATH}/SCF_B6a_gnb2.xml
${IPHY_4T6F}        ${CURDIR}/Config/iphy_4T6F.xml
${WTS_CFG_B6a}           basic_setup_B6a.cfg
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB009855-B8a_Verify_Interworking_with_inter-gNB_CA
    [Documentation]
    ...    CB009855 para:
    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
    ...    NRBTS/NRCELL. maxNumScellsDlFr1 is set to 4.
    ...                 scellAdditionMethod = blind
    ...                 scellActivationMethod = bufferBased
    ...                 scellDeactivationTimerGNB = ms1280
    ...   Test Steps:
    ...                 Step1. Attach UE to cell1_1, PDU session setup triggers blind SCell additio
    ...    Check points:
    ...                 1.UE is configured with 4CC CA with cell1_1 as PCell, cell2_1, cell2_2, cell2_3 as SCell(s).
    [Tags]    caseB8a    TA_Susie    Mannual_Susie
    Import Testline Variables For 2 GNBs
    Create Suite Directory
    Backup And Update Iphy Swconfig File    ${IPHY_3T2F}    ${RD}
    Modify Swconfig File Parameters for 2gnb
    log to console    Send scf to gnb2...
    Full Commission SCF File Through Mplane With Admin    ${SCF_9855_B8a_gnb2}    1    10.0.1.3
    log to console    Send scf to gnb1...
    Full Commission SCF File Through Mplane With Admin    ${SCF_9855_B8a_gnb1}    1    10.0.1.2
    Reboot TL And Check Configured For 2 GNBs
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_B8a}
    Sleep    60s    Wait for interGNB communication interface established stable
    Create Test Directory
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    Suite Setup Start WTS And Check OnAir    log=${False}    gnb_num=2
    Sleep    60s    Wait for interGNB communication interface established stable
    Attach UE And Start Traffic For B8a    1
    [Teardown]    Common Test Teardown 2

#CB009855-B6a-01_Verify_Interworking_with_Intra-frequency_Inter-gNB_handover_based_on_A3_or_A5_measurements
#    [Documentation]
#    ...    CB009855 para:
#    ...    NRBTS/NRDU. carrierAggregationSupportList contains an entry set to “700: ca_Fr1Tdd_Any_Sa”; AND
#    ...    NRBTS/NRCELL. maxNumScellsDlFr1 is set to 4.
#    ...                 scellAdditionMethod = blind
#    ...                 scellActivationMethod = bufferBased
#    ...                 scellDeactivationTimerGNB = infinity
#    ...   Test Steps:
#    ...                 Step1. Attach UE to cell1_4, PDU session setup triggers blind SCell addition
#    ...                 Step2. Trigger enough DL traffic to active Scells and start UL traffic
#    ...                 Step3. Handover to cell2-9
#    ...    Check points:
#    ...                 1.Attach successfully
#    ...                 2.4 Scells activate successfully
#    ...                 2.Handover to cell2-9 and DL/UL traffic is normal
#    [Tags]    caseB6a    TA_xinwang    Mannual_xinwang
#    Import Testline Variables For 2 GNBs
#    Create Suite Directory
#    Backup And Update Iphy Swconfig File    ${IPHY_4T6F}    ${RD}
#    log to console    Send scf to gnb2...
#    Full Commission SCF File Through Mplane With Admin    ${SCF_9855_B6a_gnb2}    1    10.0.1.3
#    log to console    Send scf to gnb1...
#    Full Commission SCF File Through Mplane With Admin    ${SCF_9855_B6a_gnb1}    1    10.0.1.2
#    Reboot TL And Check Configured For 2 GNBs
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}    wts_cfg_file=${WTS_CFG_B6a}
#    Sleep    60s    Wait for interGNB communication interface established stable
#    Create Test Directory
#    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
#    Suite Setup Start WTS For B6a
#    Sleep    60s    Wait for interGNB communication interface established stable
#    Attach UE And Start Traffic For B6a    1
#    Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition
#    Wait Untill Scell Activated    4    2
#    [Teardown]    Common Test Teardown 2

*** Keywords ***
Attach UE And Start Traffic For B8a
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    Sleep    1s    wait for stable
    #step1
    CB009855_resource.Check Whether UE In CA Mode    1    5
    Run Keyword And Continue On Failure    Start DL Traffic    1    12
    Run Keyword And Continue On Failure    Start UL Traffic    1    1
    Wait Untill Scell Activated    3    1
    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell
    Stop DL Traffic    1    12
    Stop UL Traffic    1    1
    Sleep    3s    wait traffic stop..
    Wait Untill Scell Deactivated    3    1

Attach UE And Start Traffic For B6a
    [Arguments]    ${UE_ID}
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${UE_ID}
    #step1
    Run Keyword And Continue On Failure    Start DL Traffic    1    4
    Run Keyword And Continue On Failure    Start UL Traffic    1    1
    Sleep    10s    wait traffic average
    Traffic Display
    Wait Untill Scell Activated    4    1
    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell    1    4    600



Send A3 MR to trigger interGNB intraFreqHo with blind Scell Addition
    [Arguments]    ${ue_id}=1    ${target_pci}=58
    ${command}    Set Variable    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=10 phycell_id=${target_pci} nrsrp_nr=40
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Inter-eNB handover from EXT_ENB-2.4 to EXT_ENB-3.9 performed    timeout=3min
    Wait Until Keyword Succeeds    60s    5s    Check Traffic On Pcell and Scell    1    4    600


Suite Setup Start WTS For B6a
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS    ${WTS_CFG_B6a}
    UE SIB Decoding Should Be Successful
    Check All Cells Received SIB2


Modify Swconfig File Parameters for 2gnb
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'echo "0x4B000F=1">>/ffs/run/swconfig.txt'
	Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@10.0.1.3 'crasign /ffs/run/swconfig.txt'

Traffic Display
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pdsch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
    sleep    5s    #for traffic
    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command And Wait For Data    cmd=ue_stats_nr id=1 type=pusch scell=0-4
    ...    pass_regexp=CellIndex-0    timeout=60s
