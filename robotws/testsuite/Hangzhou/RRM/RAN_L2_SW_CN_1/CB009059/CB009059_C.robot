*** Settings ***
Documentation
Resource    ./Resources/CB009059_resource.robot
Resource    ./../CUDU_L2/common_setup_teardown.robot
Resource    ./../CUDU_L2/common_SA_ue_command.robot
Resource    ./../CUDU_L2/common_CA.robot
Resource    ./../CB006137/resources/CB006137_BB_resource.robot
Test Teardown    Common Test Teardown 2
Suite Teardown    Common Suite Teardown 2
Force Tags        CLOUD_5G_I_LO_AP_LO    SBTS00    CN1_SG09_SM2
...                RAN_5G    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE    CRT

*** Variables ***
${UE_ID}               1
${PDU_ID}              1
${Egatelog_path}       ${CURDIR}
${LOCAL_WTS_DIR}       ${CURDIR}/Config
${SCF_DIR}             ${CURDIR}/Config
${IPHY}                ${LOCAL_WTS_DIR}/iphy.xml
${SCF_C03}             ${SCF_DIR}/SCF_9059_C03.xml
${WTS_CFG_C03}         basic_setup_C03.cfg
${WTS_CFG_C02}         basic_setup_C02.cfg
${SCF_C02}             ${SCF_DIR}/SCF_9059_C02.xml
${C09_SCF}             ${SCF_DIR}/SCF_9059_C09.xml
${C08_SCF}            ${SCF_DIR}/SCF_9059_C08.xml
${WTS_CFG_C09}         basic_setup_C09.cfg
${WTS_CFG_C08}        basic_setup_C08.cfg
${SCF_C12}             ${SCF_DIR}/SCF_9059_C12.xml
${WTS_CFG_C12}         basic_setup_C12.cfg
${SCF_C05}             ${SCF_DIR}/SCF_9059_C05.xml
${WTS_CFG_C05}         basic_setup_C05.cfg
${RD}                  0x4B000F=1
${RD2}                 0x4B000F=1;0x5b0237=0x1
${force_reboot}        ${True}
${PDU_DRB_1}           ('1', '4')
${PDU_DRB_2}           ('2', '5')
@{dlonly_scell_index}         1    2    3
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***

#CB009059-C-02_Verify_ICS_and_SCell_Addition_with_at_least_one_FR1_CA_eligible_DRB_and_UM_RLC_mode_DRB_Not_FR1_CA_eligible_on_multi_PDU_session
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA.
#    ...      Config two DRBs: DRB1 is FR1 CA eligible and AM RLC mode; DRB2 is Not FR1 CA eligible and UM RLC mode.
#    ...      UE doesn't support lch-ToSCellRestriction capability.
#    ...      CB008311 enabled:
#    ...          NRBTS.actBufferBasedSCellAddition = oneShot_Dl_Fr1, sCellDeactivationTimerGNB = ms1280
#    ...          actSCellReleaseForInactiveSCell = timer_based_Fr1, sCellInactivityReleaseTimer = 5s
#    ...    Test Steps:
#    ...      Step1: UE attaches to Cell-1 and the gNB establishes 2 PDU session with 2 DRBs during the UE context setup.
#    ...      Step2: Start full DL traffic over DRB-2.
#    ...      Step3: Start full DL traffic over DRB-1.
#    ...    Check point：
#    ...      1. In step1, UE is attached to Cell-1 with 2 DRB during the UE context setup
#    ...      2. In step2, UE is not in CA.
#    ...      3. In step3,
#    ...          - gNB-DU has sent DL buffer monitoring criterion notification due to DRB-1 data volume.
#    ...          - The gNB configures the UE with 4CC DL CA with Cell-2, Cell-3 and Cell-4 as SCells.
#    ...          - DRB-1 non-GBR DL data is scheduled on the PCell and at least one SCell.
#    ...          - DRB-2 DL non-GBR data is scheduled only on the PCell.
#    [Tags]    case_C02    Manual_Susie    TA_Susie
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_C02}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_C02}    iphy_file=${IPHY}   
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1 
#    SA 5G Attach    ue_id=${UE_ID}
#    Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    Setup PDU Session    ${UE_ID}    pdu_id=1
#    Execute Egate Command    cmd=qosflow_modify qos_flow=2 default=on
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=2
#    Setup PDU Session    ${UE_ID}    pdu_id=2
#    #checkpoint1
#    Check PDU And DRB Infos    ${PDU_DRB_1}
#    Check PDU And DRB Infos    ${PDU_DRB_2}
#    #step2
#    Send Throuput over DRB2    ue_id=1    pdu_id=2    qfi=1
#    #checkpoint2
#    Check Whether UE In CA Mode
#    #step3
#    Start SA UE Big DL Traffic Internal    ${UE_ID}    1500
#    Sleep    10s        reason=Wait for traffic
#    #checkpoint3
#    common_CA.Verify Scells Are Activation    3
#    Traffic Display
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check Traffic Of DRB For The Cell    CB009059_C02_DL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl

#CB009059-C-03_Verify_ICS_and_SCell_Addition_with_at_least_one_FR1_CA_eligible_DRB_with_UM_RLC_mode
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
#    ...      Config two DRBs, both are FR1 CA eligible. DRB1 is configured with AM RLC mode while DRB2 is with UM RLC mode.
#    ...      UE doesn't support lch-ToSCellRestriction capability.
#    ...      CB008311 enabled:
#    ...          NRBTS.actBufferBasedSCellAddition = oneShot_Dl_Fr1, sCellDeactivationTimerGNB = ms1280
#    ...          actSCellReleaseForInactiveSCell = timer_based_Fr1, sCellInactivityReleaseTimer = 5s
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-1, DRB-1 and DRB-2 are established.
#    ...      Step2: Start full DL traffic over DRB-2.
#    ...      Step3: Change traffic to small data traffic to deactivate scell.
#    ...      Step4: Repeat step2 and step3 some times.
#    ...      Step5: Start full DL traffic over DRB-1.
#    ...    Check point:
#    ...      1. Step1, UE is attached with 2 DRBs established.
#    ...      2. Step2, 3 Scells are activated, and DRB2 has traffic on both Pcell and Scells.
#    ...      3. Step3, 3 Scells are deactivated, and DRB2 has traffic only on Pcell.
#    ...      4. Step5, 3 Scells are activated, both DRB1 and DRB2 has traffic on Pcell and Scells.
#    [Tags]    case_C03    Manual_lilidong    TA_lilidong    AP_REG
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_C03}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_C03}    iphy_file=${IPHY}   
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
#    #step2/3/4
#    Robustness Testing For Traffic Increase And Decrease    scell_num=3    qfi_id=2    times=5
#    Start SA UE Big DL Traffic Internal    ue_id=${UE_ID}    mbps=525    qfi_id=2
#    #checkpoint2/3
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check Traffic Of DRB For The Cell    CB009059_C03_DRB2_DL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/1/    dl
#    #step5
#    Start SA UE Big DL Traffic Internal    ue_id=${UE_ID}    mbps=350    qfi_id=1
#    #checkpoint4
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2/
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2/
#    Check Traffic Of DRB For The Cell    CB009059_C03_DRB1_2_DL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/2/    dl
#    SA 5G Detach    ue_id=${UE_ID}

#CB009059-C-05_Verify_Interaction_with_UL_CA_and_UM_RLC_mode_DRB
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
#    ...      Config two DRBs, both are FR1 CA eligible. DRB1 is configured with AM RLC mode while DRB2 is with UM RLC mode.
#    ...      UE doesn't support lch-ToSCellRestriction capability.
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-1, DRB-1 and DRB-2 are established.
#    ...      Step2: Start full UL traffic over DRB-2.
#    ...      Step3: Change traffic to small data traffic to deactivate scell.
#    ...      Step4: Start DL traffic over DRB-2.
#    ...      Step5: Start full DL and UL traffic over DRB-1 and DRB-2.
#    ...    Check point：
#    ...      1. Step1, UE is attached with 2 DRBs established.
#    ...      2. Step2, 2CC DL/2CC UL configured and DRB-2 non-GBR UL data is scheduled on the PCell and SCells.
#    ...      3. Step3, Scell deactivated.
#    ...      4. Step4, DRB-2 non-GBR DL data is scheduled on the PCell and SCells.
#    ...      5. Step5, DRB-1 and DRB-2 non-GBR DL data is scheduled on the PCell and SCells.

#    [Tags]    case_C05    Manual_xinwang    TA_xinwang
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_C05}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_C05}    iphy_file=${IPHY}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1
#    SA 5G Attach    ue_id=${UE_ID}
#    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    Setup PDU Session    ${UE_ID}    pdu_id=1
#    #checkpoint1
#    Check DRB Infos    lc_id=4    drb_id=4
#    Check DRB Infos    lc_id=5    drb_id=5
#    #step2
#    Send Throuput over DRB2 ULonly
#    #checkpoint2
#    common_CA.Verify Scells Are Activation    1
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check Traffic Of DRB For The Cell    CB009059_C05_UL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    ul
#    #step3
#    SA Stop Data Traffic Internal ForQfi2    ue_id=${UE_ID}    pdu_id=1
#    Sleep    10s        reason=Wait for traffic stop
#    #checkpoint3
#    Verify Scell Deactivated
#    #step4
#    Send Throuput over DRB2 DLonly
#    #checkpoint4
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check Traffic Of DRB For The Cell    CB009059_C05_DL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl
#    #step5
#    Send Throuput over DRB1
#    #checkpoint5
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check Traffic Of DRB For The Cell    CB009059_C05_UL_Drb_DRB1.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    ul
#    Check Traffic Of DRB For The Cell    CB009059_C05_DL_Drb_DRB1.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl

CB009059-C-08_Verify_Interaction_with_UL_CA_and_UM_RLC_mode_DRB_with_lch-ToSCellRestriction_capability
    [Documentation]
    ...    Precondition:
    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
    ...      Config two DRBs, one is FR1 CA eligible,another is Not FR1 CA eligible.
    ...      UE support lch-ToSCellRestriction capability.
    ...      NRBTS.sCellActivationMethod=blind
    ...      NRBTS.actBufferBasedSCellAddition = disabled
    ...    Test Steps:
    ...      Step1: UE attach to Cell-1 with DRB-1(configured as FR1 CA eligible)and DRB-2(configured as Not FR1 CA eligible).
    ...      Step2: Start full DL and UL traffic.
    ...    Check point:
    ...      1. In step1,UE is attached to Cell-1 and in 2CC DL/UL CA with Cell-2 as the SCell with 2 DRBs during the UE context setup.
    ...      2. Data transmission for DRB-1 non-GBR DL/UL data is on the PCell and SCell.
    ...         Data transmission for DRB-2 DL/UL non-GBR data is only on the PCell.
    [Tags]    case_C08    Manual_abbyw    TA_abbyw
    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_C08}
    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${C08_SCF}    iphy_file=${IPHY}
    ...               swconfig_param=${RD}
    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
    ...        AND    Common Test Setup 2
    #step1
    SA 5G Attach    ue_id=${UE_ID}
    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=${PDU_ID}
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2
    SA 5G PDU Session Setup    ${UE_ID}    pdu_id=${PDU_ID}
    #checkpoint1
    Check DRB Infos    lc_id=4    drb_id=4
    Check DRB Infos    lc_id=5    drb_id=5
    #step2
    Send Throuput over DRB1
    Send Throuput over DRB2
    #checkpoint2
    Start Ttitrace With Streaming Mode
    Sleep    2s        reason=Wait for log
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
    Check DRB Traffic    C08

#CB009059-C-09_Verify_Interaction_with_UL_CA_and_UM_RLC_mode_DRB_without_lch-ToSCellRestriction_capability
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA
#    ...      Config two DRBs, one is FR1 CA eligible,another is Not FR1 CA eligible.
#    ...      UE don't support lch-ToSCellRestriction capability.
#    ...
#    ...    Test Steps:
#    ...      Step1: UE attach to Cell-1 with DRB-1 and DRB-2.
#    ...      Step2: Start full DL and UL traffic.
#    ...    Check point：
#    ...      1. In step1,UE is attached to Cell-1 and in 5CC DL/UL CA with Cell-2 as the SCell.with 2 DRBs during the UE context setup.
#    ...      2. Data transmission for DRB-1 non-GBR DL/UL data is on the PCell and SCell.
#    ...         Data transmission for DRB-2 DL non-GBR data is only on the PCell,ul on pcell and scell.
#    [Tags]    caseC09    Manual_Junying    TA_Junying
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_C09}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${C09_SCF}    iphy_file=${IPHY}
#    ...               swconfig_param=${RD2}
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
#    Send Throuput over DRB2
#    Traffic Display
#    Send Throuput over DRB1
#    Traffic Display
#    #checkpoint2
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace
#    Check Traffic Of DRB For The Cell    CB009059_C09_DL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl
#    Check Traffic Of DRB For The Cell    CB009059_C09_DL_Drb_abnormal.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    dl
#    Check Traffic Of DRB For The Cell    CB009059_C09_UL_Drb.ini    ${TEST_LOG_DIRECTORY}/ttitrace/    ul

#CB009059-C-12_Verify_ICS_and_SCell_Addition_with_at_least_one_FR1_CA_eligible_DRB_and_one_FR1_CA_Incompatible_UM_RLC_DRB_on_multi_PDU_sessions
#    [Documentation]
#    ...    Precondition:
#    ...      CB009059 is enabled: NRBTS.actDrbProfileForCellAggrLevel = FR1_SA.
#    ...      Config two DRBs: DRB1 is FR1 CA eligible and AM RLC mode; DRB2 is 2:FR1 CA incompatible and UM RLC mode.
#    ...      CA (T+F+F+T) DL 4CC UL 2CC supported.
#    ...      CB008311 enabled:
#    ...          NRBTS.actBufferBasedSCellAddition = oneShot_Dl_Fr1, sCellDeactivationTimerGNB = ms1280
#    ...          actSCellReleaseForInactiveSCell = timer_based_Fr1, sCellInactivityReleaseTimer = 5s
#    ...    Test Steps:
#    ...      Step1: UE attaches to Cell-1 and the gNB establishes 2 PDU session with 2 DRBs during the UE context setup.
#    ...      Step2: Start full DL and UL traffic over DRB-2.
#    ...      Step3: Start full DL and UL traffic over DRB-1.
#    ...      Step4: Delete PDU session 2.
#    ...    Check point：
#    ...      1. In step1, UE is attached to Cell-1 with 2 DRB during the UE context setup
#    ...      2. In step2, UE is not in CA.
#    ...      3. In step3, UE is not in CA.
#    ...      3. In step4,
#    ...          - gNB-DU has sent DL buffer monitoring criterion notification due to DRB-1 data volume.
#    ...          - The gNB configures the UE with 4CC DL CA with Cell-2, Cell-3 and Cell-4 as SCells.
#    ...          - DRB-1 non-GBR DL data is scheduled on the PCell and at least one SCell.
#    [Tags]    case_C12    Manual_Cora    TA_Cora
#    [Setup]    Run Keywords    Set Test Variable    ${WTS_CFG}    ${WTS_CFG_C12}
#    ...        AND    Suite Setup Update GNB    force_reboot=${force_reboot}    scf_file=${SCF_C12}    iphy_file=${IPHY}
#    ...               swconfig_param=${RD}
#    ...        AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#    ...        AND    Suite Setup Start WTS And Check OnAir    log=${False}
#    ...        AND    Common Test Setup 2
#    #step1
#    SA 5G Attach    ue_id=${UE_ID}
#    Execute Egate Command    cmd=qosflow_modify qos_flow=1 default=on
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    Setup PDU Session    ${UE_ID}    pdu_id=1
#    Execute Egate Command    cmd=qosflow_modify qos_flow=3 default=on
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=2
#    Setup PDU Session    ${UE_ID}    pdu_id=2
#    #checkpoint1
#    Check PDU And DRB Infos    ${PDU_DRB_1}
#    Check PDU And DRB Infos    ${PDU_DRB_2}
#    #step2
#    Send Throuput over DRB2    ue_id=1    pdu_id=2    qfi=1
#    #step3
#    Send Throuput over DRB1
#    #checkpoint2 3
#    Check Whether UE In CA Mode
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/1
#    #step4
#    Execute Egate Command    cmd=ue_pdu_session_release ue=1 pdu=2
#    Sleep    3s        reason=Wait for log
#    #checkpoint4
#    common_CA.Verify Scells Are Activation    3
#    Traffic Display
#    Start Ttitrace With Streaming Mode
#    Sleep    2s        reason=Wait for log
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/2
#    Check DL DTXNACK Rate    ${TEST_LOG_DIRECTORY}/ttitrace/2
#    Check UL DTXCRC Rate    ${TEST_LOG_DIRECTORY}/ttitrace/2

*** Keywords ***

Stop DL Traffic
    [Arguments]    ${trf_id}    ${qfi_id}    ${pdu_id}=1    ${dir}=bi
    FOR    ${index}    IN RANGE    1    ${trf_id}+1
        SA Stop Data Traffic Internal With Dedicated Trf    ue_id=${UE_ID}    trf_id=${index}    qfi_id=${qfi_id}
    END

Verfiy Scells Act And Deact Result
    [Arguments]    ${cell_nums}    ${action}    ${times}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to check whether scell activated or deactivated from egate Log.
    Log To Console    verify Scell Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    1    ${cell_nums}
    ${scell_action}    Set Variable    SCellIndex ${id} ${action} successfully.
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${match_list}     Get Regexp Matches    ${content}    ${scell_action}
    ${check_rst}    Get Length    ${match_list}
    Should Be True    ${check_rst}==${times}
    END

Robustness Testing For Traffic Increase And Decrease
    [Arguments]    ${scell_num}    ${qfi_id}    ${times}
    FOR    ${index}    IN RANGE    1    ${times}
        ${tmp_id}    Evaluate    int(${index}+4)
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${UE_ID} pdu=${PDU_ID} qfi=${qfi_id} trf_id=${tmp_id} mbps=1 dir=dl
        Start SA UE Big DL Traffic Internal    ue_id=${UE_ID}    mbps=500    qfi_id=${qfi_id}
        Wait Until Keyword Succeeds    3min    5s    Verfiy Scells Act And Deact Result    ${scell_num}+1    activated    ${index}
        Sleep    5s
        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=pcell    scell_index=0    target_tp=20
        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=1    target_tp=5
        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=2    target_tp=100
        Check CA UE Pcell Scell Cell TPut On Target    ue_id=1    dir=dl    cell_type=scell    scell_index=3    target_tp=100
        Stop DL Traffic    trf_id=4    qfi_id=${qfi_id}
        Sleep    25s
        ute_wtssim.Execute Egate Command    sim_log_set flush
        Verfiy Scells Act And Deact Result    ${scell_num}+1    deactivated    ${index}
    END
