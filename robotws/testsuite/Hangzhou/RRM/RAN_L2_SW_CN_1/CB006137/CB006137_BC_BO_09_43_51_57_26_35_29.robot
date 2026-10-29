*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${SWCONFIG_PARAM}
...               AND    Suite Setup Copy WTS Config Files From QT
Suite Teardown    Common Suite Teardown
Force Tags        CLOUD_5G_I_BOO_AP_LOO    FR1    CRT    RAN_5G_TDD    Owner_fanjin    PRI-High
...               SBTS00    RAN_5G
Resource          resources/CB006137_BC_resource.robot

*** Variables ***
${SWCONFIG_PARAM}        0x580591=0;0x58056B=1
${SCF_PATH}              ${CURDIR}/config
${INI_FULL_SCF}          scfc_ini.xml
${DELTA_FILE}            Delta_Conf_CB006137_DMRS_FDM.json
${WTS_LOCAL}             ${CURDIR}/config/WTS
${WTS_CFG_6137_FULL}     basic_setup_6137_BC43_BC51.cfg
@{LOG_NAME_LIST}         btsLog
${UE_ID}                 1
${PCELL_PCI}             50
${SCELL_PCI}             52
${GNB_ID}                2
${PCELL_ID}              1
${DL_TRF}                650
${UL_TRF}                175
${DL_PEAK}               100
${UL_PEAK}               50
${RSRP}                  105
${RSRQ}                  105
${FILTER_043}            uldata_puschreceivereq
@{COLUMN_NAME_043}       UlData_puschReceiveReqGrant_t.numOfDmrsCdmGroupWithoutData
${FILTER_035}            uldata_puschreceivereq
@{COLUMN_NAME_035}       UlData_puschReceiveReqGrant_t.ulDmrsMappingType
${SCFC_CASE43}           Delta_Conf_CB006137_DMRS_FDM.json
${SCFC_CASE51}           FULL_CB006137_MRC_SCFC.xml
${SCFC_CASE09}           FULL_CB006137_FULLPOWER_SCFC.xml
${SCFC_CASE57}           FULL_CB006137_GBR_SCFC.xml
${SCFC_CASE26}           Delta_Conf_CB006137_ACSI.json
${SCFC_CASE35}           Delta_Conf_CB006137_TypeA.json
${SCFC_CASE29}           Delta_Conf_CB006137_Reestablishment.json
${UE_ID_PW0}             8
${UE_ID_PW1}             9
${UE_ID_PW2}             10
${COUNTER_PATH_NAME}     RACCU
@{PM_EXPEC_VALUES}       M55114C01501    0    M55114C01502    0    M55114C01503    0    
${PM_PCELL}              1
${PM_SCELL}              3
@{PM_57}                 M55310C03001    10000000    M55310C04001    100000
${COUNTER_57}            NLRLC
@{PM_DU_29}              M55127C00501    1    M55127C00503    1    M55127C00510    1    M55127C00512    1
${ABBR_DU_29}            NRRCD
@{PM_CU_29}              M55124C00503    1    M55124C00510    1    M55124C00505    1    M55124C00512    1
...                      M55124C00515    0    M55124C00516    2    M55124C00517    0    M55124C00519    2
${ABBR_CU_29}            NRRCC
${UE_ID_21}              21
${COUNTER_GBR}           NCADU
@{PM_GBR_PCELL}          M55316C14001    10000000    M55316C14003    100000
@{PM_GBR_SCELL}          M55316C14002    10000000    M55316C14004    100000
${REESTABLISH_CAUSE1}    otherFailure
${REESTABLISH_CAUSE2}    reconfigurationFailure
#TC29                    
&{COUNTER1_INFO}         counter_id=M55127C00501    counter_path=BTS/NRBTS-1/NRDU-1/NRRCD    min_value=0    max_value=2
&{COUNTER2_INFO}         counter_id=M55127C00503    counter_path=BTS/NRBTS-1/NRDU-1/NRRCD    min_value=0    max_value=2
&{COUNTER3_INFO}         counter_id=M55127C00510    counter_path=BTS/NRBTS-1/NRDU-1/NRRCD    min_value=0    max_value=2
&{COUNTER4_INFO}         counter_id=M55127C00512    counter_path=BTS/NRBTS-1/NRDU-1/NRRCD    min_value=0    max_value=2
&{COUNTER5_INFO}         counter_id=M55124C00503    counter_path=CELLS/NRCELL-1/NRRCC    min_value=0    max_value=2
&{COUNTER6_INFO}         counter_id=M55124C00510    counter_path=CELLS/NRCELL-1/NRRCC    min_value=0    max_value=2
&{COUNTER7_INFO}         counter_id=M55124C00505    counter_path=CELLS/NRCELL-1/NRRCC    min_value=0    max_value=2
&{COUNTER8_INFO}         counter_id=M55124C00512    counter_path=CELLS/NRCELL-1/NRRCC    min_value=0    max_value=2
&{COUNTER9_INFO}         counter_id=M55124C00515    counter_path=CELLS/NRCELL-1/NRRCC    max_value=1
&{COUNTER10_INFO}        counter_id=M55124C00516    counter_path=CELLS/NRCELL-1/NRRCC    min_value=1    max_value=3
&{COUNTER11_INFO}        counter_id=M55124C00517    counter_path=CELLS/NRCELL-1/NRRCC    max_value=1
&{COUNTER12_INFO}        counter_id=M55124C00519    counter_path=CELLS/NRCELL-1/NRRCC    max_value=1
@{COUNTER_LIST}          ${COUNTER1_INFO}    ${COUNTER2_INFO}    ${COUNTER3_INFO}    ${COUNTER4_INFO}    ${COUNTER5_INFO}    ${COUNTER6_INFO}
...                      ${COUNTER7_INFO}    ${COUNTER8_INFO}    ${COUNTER9_INFO}    ${COUNTER10_INFO}    ${COUNTER11_INFO}    ${COUNTER12_INFO}
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB006137_ET_BC043_Single_UE_UL_CA_Call_With_PUSCH_Data_And_DMRS_FDM_Without_DFT_S_OFDM_On_ABIO
    [Tags]    case_BC_43    Owner_fanjin
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE43}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    SA UE Attach    ${UE_ID}
    Scell Addition With CoverbaseA1 Rsrp And ULDL TPUT Value    ${UE_ID}    ${RSRP}    ${RSRQ}    ${SCELL_PCI}
    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK}    ${UL_PEAK}
    Capture And Covert BIP To Csv    ${FILTER_043}    ${COLUMN_NAME_043}
    Verify Case Check Point    BC043    CB006137_BC043_DMRS_FDM.ini    i
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

CB006137_ET_BC051_Single_UE_UL_CA_Call_With_4Rx_IRC_For_TDD_FR1_Cell_On_ABIO
    [Tags]    case_BC_51    Owner_zbu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE51}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    SA UE Attach    ${UE_ID}
    Scell Addition With CoverbaseA1 Rsrp And ULDL TPUT Value    ${UE_ID}    ${RSRP}    ${RSRQ}    ${SCELL_PCI}
    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK}    ${UL_PEAK}
    SA 5G Detach    ${UE_ID}
    Save Egate Log    ${TEST_LOG_DIRECTORY}
    Verify Case Check Point    BC051    CB006137_BC_MRC.ini    p
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

CB006137_ET_BC009_Full_TX_Power_In_Uplink_Transmission_Support_With_UE_Capability_FullPwrMode_0_Over_UL_CA_Call
    [Tags]    case_BC_09    Owner_zbu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE09}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    SA UE Attach    ${UE_ID_PW0}
    SA UE Attach    ${UE_ID_PW1}
    SA UE Attach    ${UE_ID_PW2}
    Wait Until Keyword Succeeds    360s    120s    Get And Verify PM Counters    ${PM_PCELL}    ${COUNTER_PATH_NAME}    ${PM_EXPEC_VALUES}    
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

CB006137_ET_BC057_UL_CA_Call_With_GBR_SA_And_Scell_Blind_With_UE_Capability_Support_Lch_ToSCellRestriction_On_ABIO
    [Tags]    case_BC_57    Owner_zbu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE57}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    Multi PDUs Establishment    ${UE_ID_21}
    GBR And VONR Establishment And ULDL Tput
    Wait Until Keyword Succeeds    600s    120s    Get And Verify PM Counters    ${PM_PCELL}    ${COUNTER_57}    ${PM_57}
    Wait Until Keyword Succeeds    600s    120s    Get And Verify PM Counters    ${PM_PCELL}    ${COUNTER_GBR}    ${PM_GBR_PCELL}
    Wait Until Keyword Succeeds    600s    120s    Get And Verify PM Counters    ${PM_SCELL}    ${COUNTER_GBR}    ${PM_GBR_SCELL}    
    [Teardown]    Common Test Teardown

CB006137_ET_BC026_Single_UE_UL_CA_Call_With_Aperiodic_CSI_Handling_For_UE_Configured_With_FDD_TDD_FR1_UL_CA_With_Scell_Release
    [Tags]    case_BC_26    Owner_xiaothan
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE26}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    SA UE Attach    ${UE_ID}
    Scell Addition With CoverbaseA1 Rsrp And ULDL TPUT Value    ${UE_ID}    ${RSRP}    ${RSRQ}    ${SCELL_PCI}
    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK}    ${UL_PEAK}
    Capture And Decode TTitrace
    Check Acsi In TTitrace    ${TEST_LOG_DIRECTORY}/ttitrace/1
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

CB006137_ET_BC035_Single_UE_UL_CA_Call_With_PUSCH_Mapping_Type_A_Without_DFT_S_OFDM_On_ABIO
    [Tags]    case_BC_35    Owner_xiaothan
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE35}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    SA UE Attach    ${UE_ID}
    Scell Addition With CoverbaseA1 Rsrp And ULDL TPUT Value    ${UE_ID}    ${RSRP}    ${RSRQ}    ${SCELL_PCI}
    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK}    ${UL_PEAK}
    Capture And Covert BIP To Csv    ${FILTER_035}    ${COLUMN_NAME_035}
    Verify PUSCH Mapping TypeA
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

CB006137_ET_BC029_Single_UE_Reestablish_F_T_ULCA_A1Based_ABIO
    [Tags]    case_BC_29    Owner_naliu
    [Setup]    Run Keywords    Test Setup Update GNB    scf_file=${SCFC_CASE29}
    ...    AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Suite Setup Start WTS And Check OnAir    wts_cfg_file=${WTS_CFG_6137_FULL}
    ...    AND    Common Test Setup
    SA UE Attach    ${UE_ID}
    Trigger A1 Scell Addition    ${UE_ID}    ${RSRP}    ${PCELL_PCI}
    Start ULDL Traffic And Check The Tput    ${UE_ID}    ${DL_TRF}    ${UL_TRF}    ${DL_PEAK}    ${UL_PEAK}
    Wait PM counter clear
    Triger UE Reestablishment    ${UE_ID}    ${GNB_ID}    ${PCELL_ID}    ${REESTABLISH_CAUSE1}
    Trigger A1 Scell Addition    ${UE_ID}    ${RSRP}    ${PCELL_PCI}
    Check PCell And SCell DLUL Tput    ${UE_ID}    ${DL_PEAK}    ${UL_PEAK}
    Triger UE Reestablishment    ${UE_ID}    ${GNB_ID}    ${PCELL_ID}    ${REESTABLISH_CAUSE2}
    Trigger A1 Scell Addition    ${UE_ID}    ${RSRP}    ${PCELL_PCI}
    Check PCell And SCell DLUL Tput    ${UE_ID}    ${DL_PEAK}    ${UL_PEAK}
    PM Counter Check
    [Teardown]    Test Teardown Recover Env    scf_file=${scf_test_bak_file}

*** Keywords ***
Wait PM counter clear
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Sleep    ${time}
PM Counter Check
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Sleep    ${time}
    Check Multi PM Counters Latest Value From Admin    ${COUNTER_LIST}

Verify Case Check Point
    [Arguments]    ${Case_Folder}    ${Check_File}    ${Check_Type}
    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}${Case_Folder}${/}${Check_File}    ${Check_Type}
    ...    save_log_directory=${TEST_LOG_DIRECTORY}

GBR And VONR Establishment And ULDL Tput
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=21 pdu\=1 qosflows_to_add\=2 by\=amf
    Wait AP Command Executed
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue\=21 pdu\=1 qosflows_to_add\=3 by\=amf
    Wait AP Command Executed
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=21 pdu\=1 qfi\=3 dir\=dl trf_id\=1 mbps\=5 seconds\=6000
    Wait AP Command Executed
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=21 pdu\=1 qfi\=3 dir\=ul trf_id\=1 mbps\=20 seconds\=6000

Wait AP Command Executed
    Sleep    1s    reason=wait for APH execution

Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=2
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Check Acsi In TTitrace
    [Arguments]    ${csv_file_path}
    A2A Check CSV Table    ${CURDIR}/A2A/ttitrace_BC026_ACSI.ini    output_ul.csv    ${csv_file_path}

Verify PUSCH Mapping TypeA
    Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}CB006137_BC035_PUSCH_Mapping_TypeA.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY}

Triger UE Reestablishment
    [Arguments]    ${ue_id}=1    ${gnb_id}=2    ${cell_id}=1    ${cause}=otherFailure
    ute_wtssim.Execute Egate Command    cmd=ue_rrc_reestablish id=${ue_id} gnb=${gnb_id} cell=${cell_id} cause=${cause}
    Log To Console    reestablishment triggerred
    Sleep    3s    reason=wait for ue recovery
