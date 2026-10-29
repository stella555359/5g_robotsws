*** Settings ***
Documentation    ...
#Documentation
#Resource    ./Resources/CB009059_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CN1_SG09_SM2
#...                RAN_5G    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT
#
#*** Variables ***
#${UE_ID}               1
#${PDU_ID}              1
#${Egatelog_path}       ${CURDIR}
#${LOCAL_WTS_DIR}       ${CURDIR}/Config
#${SCF_DIR}             ${CURDIR}/Config
#${BB01_IPHY}           ${LOCAL_WTS_DIR}/iphy.xml
#${BB01_SCF}            ${SCF_DIR}/SCF_9059_BB01.xml
#${BB06_SCF}            ${SCF_DIR}/SCF_9059_BB06.xml
#${WTS_CFG_BB06}        basic_setup_BB06.cfg
#${WTS_CFG_BB01}        basic_setup_BB01.cfg
#${RD}                  0x4B000F=1
#${force_reboot}        ${True}
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#*** Test Cases ***
#CB009059-BB-01_Verify_CB009059_Interaction_with_UL_CA_with_lch-ToSCellRestriction_capability
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
#    ...      Config two DRBs, one is FR1 CA eligible,another is Not FR1 CA eligible.
#    ...      UE support lch-ToSCellRestriction capability.
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-1 with DRB-1 and DRB-2.
#    ...      Step2: Start full DL and UL traffic.
#    ...    Check point:
#    ...      1. In step1,UE is attached to Cell-1 and in 2CC DL/UL CA with Cell-2 as the SCell with 2 DRBs during the UE context setup.
#    ...      2. Data transmission for DRB-1 non-GBR DL/UL data is on the PCell and SCell.
#    ...          Data transmission for DRB-2 DL/UL non-GBR data is only on the PCell.
#    [Tags]    case_BB01    Manual_xinwang    TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_BB01}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${BB01_SCF}    iphy_file=${BB01_IPHY}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=${PDU_ID}
#    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
#    SA 5G PDU Session Setup    ${UE_ID}    pdu_id=${PDU_ID}
#    #checkpoint1
#    Check DRB Infos    lc_id=4    drb_id=4
#    Check DRB Infos    lc_id=5    drb_id=5
#    #step2
#    Send Throuput over DRB1
#    Send Throuput over DRB2
#    #checkpoint2
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check DRB Traffic From TTItrace For BB01
#
#CB009059-BB-06_Verify_CA_Release_with_UL_CA_when_no_FR1_CA_eligible
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
#    ...      Config 3 DRBs, one is FR1 CA eligible,another is Not FR1 CA eligible,the third is FR1 CA incompatible
#    ...      UE support lch-ToSCellRestriction capability.
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-1 with DRB-1 and DRB-2.
#    ...      Step2: Start full DL and UL traffic.
#    ...      3. Setup PDU session 2 that mapping Qos flow to DRB-3.
#    ...      4. Delete PDU session 2.
#    ...    Check point:
#    ...      1. In step1,UE is attached to Cell-1 and in 3CC DL/2CCUL with 2 DRBs during the UE context setup.
#    ...      2. In step2 Data transmission for DRB-1 non-GBR DL/UL data is on the PCell and SCell.
#    ...          Data transmission for DRB-2 DL/UL non-GBR data is only on the PCell.
#    ...      3.In step3 DRB-3 is established using the NRDRB-3 instance settings.CA is released.
#    ...      4.In step4,CA is actived, same test result as step1 and step2.
#    [Tags]    case_BB06    Manual_junyihu    TA_junyihu    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_BB06}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${BB06_SCF}    iphy_file=${BB01_IPHY}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1
#    #Set UEC Reordering Timer
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=${PDU_ID}
#    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
#    SA 5G PDU Session Setup    ${UE_ID}    pdu_id=${PDU_ID}
#    #checkpoint1
#    Check DRB Infos    lc_id=4    drb_id=4
#    Check DRB Infos    lc_id=5    drb_id=5
#    #step2
#    #Send Throuput
#    Send Throuput over DRB1
#    Send Throuput over DRB2
#    UE Tput Status
#    #checkpoint2
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check DRB Traffic    BB06
#    #step 3 and checkpoint3
#    Wait Until PM Counter Update    5min    0
#    Setup PDU2 Establish DRB3 Check CA Release
#    UE Tput Status
#    Check PM Counter For BB06
#    #step 4 and checkpoint4
#    Delete PDU2 CA Active
#    UE Tput Status
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check DRB Traffic    BB06
#
#
#*** Keywords ***
#Check DRB Traffic From TTItrace For BB01
#    Check DRB On The Cell    52    4.0    dl
#    Check DRB On The Cell    52    5.0    dl
#    Check DRB On The Cell    60    4.0    dl
#    Check DRB Not On The Cell    60    5.0    dl
#    Check DRB On The Cell    52    4.0    ul
#    Check DRB On The Cell    52    5.0    ul
#    Check DRB On The Cell    60    4.0    ul
#    Check DRB Not On The Cell    60    5.0    ul
#
#Check PM Counter For BB06
#    Wait Until PM Counter Update    5min    0
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55118C00034    CELLS/NRCELL-11/NCAC    2    4
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55118C00035    CELLS/NRCELL-11/NCAC    2    4
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55118C00042    CELLS/NRCELL-11/NCAC    0    2
#    Wait Until Keyword Succeeds    5min    10s    Check PM Counter Latest Value From Admin    M55118C00043    CELLS/NRCELL-11/NCAC    0    2
