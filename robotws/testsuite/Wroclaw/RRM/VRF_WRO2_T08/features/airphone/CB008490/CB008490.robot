*** Settings ***
Documentation   :copyright: Nokia
...             :authors: Dariusz Maciocha
...             :contact:dariusz.maciocha@nokia.com

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/feature_keywords.robot
Library     ta5g_syslog
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008490/resources/CB008490_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library     testsuite/Wroclaw/RRM/resources/syslog_checker.py
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/airphone/CB008490/resources/test_variables.py

Suite Setup       Start Interfaces And Add Cplane Debug Logs
Test Teardown     Teardown
*** Variables ***
${SCFC_SN}=                 scf_GC.xml
${IPHY}=                    ${CURDIR}/config/iphy_GC.xml
${EGATE}=                   ${CURDIR}/config/cfg_GC.cfg
${DELTA_TRACKINGAREA_DN}=    delta_GC.json
${DELTA_UNLOCK_2_CELLS_AND_2_NEW_CELLS}=    Delta_Unlock_2_and_Add_2_NRDC_Cells_on_SN.json
${DELTA_ADD_2_NEW_CELLS}=    Delta_GA_201_adding_NR_DC_SN_cells.json
${DELTA_NRCELL_5}=    delta_add_NRCELL_5.json
${DELTA_NRCELL_6}=    delta_add_NRCELL_6.json
@{swconfig_flag}=    0x890099=250 #rdOverwriteRandomizedTimers

*** Test Cases ***
CB008490_GA_B201_Activation_Of_Multiple_NR-DC-SN_And_NSA_Cells_Configured_At_gNB_Startup_And_Dynamically_Added_Multiple
    [Tags]  QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Setup
    ...    iphy=${CURDIR}/config/iphy_GA_201.xml
    ...    scfc=scf_GA_B201.xml
    ...    egate=${CURDIR}/config/cfg_GA_201.cfg
    ...    xn_establish=${False}
    ...    skip_errors=${True}
    ${TEST_QC_ID}=  Set Test ID
    Set Tags    ${TEST_QC_ID}
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_ADD_2_NEW_CELLS}
    Send Delta Commissioning With Fixer    ${delta}    skip_parameter_relation_errors=${True}
    Sleep     100s    Waiting For All Messages About All Cells In OnAir State
    Establish X2 Link    enb=1    gnb=3
    Establish Xn Link    source_gnb_id=2    target_gnb_id=3
    Establish Xn Link    source_gnb_id=4    target_gnb_id=3
    Verify Scenario Messages    ${GA_MSGS}

CB008490_GB_101_Dynamic_Addition_Of_NR-DC-SN_Cells_After_Xn_Link_Establishment
    [Tags]  QCD_MN_RAN  QCP_RAN_VRF
    [Setup]    Setup
    ...    iphy=${CURDIR}/config/iphy_GB.xml
    ...    scfc=scf_SN_GB_B1.xml
    ...    egate=${CURDIR}/config/cfg_GB.cfg
    ${TEST_QC_ID}=  Set Test ID
    Set Tags    ${TEST_QC_ID}
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_UNLOCK_2_CELLS_AND_2_NEW_CELLS}
    Send Delta Commissioning With Fixer    ${delta}    skip_parameter_relation_errors=${True}
    Sleep     100s    Waiting For All Messages About All Cells In OnAir State
    Verify Scenario Messages    ${GB_MSGS}

CB008490-GC_EC201_EC2_Recovery_after_failure_of_NG-RAN_Node_Configuration_Update_procedure_with_MN_gNB
    [Setup]    Setup
    ...    iphy=${CURDIR}/config/iphy_GB.xml
    ...    scfc=scf_GC.xml
    ...    egate=${CURDIR}/config/cfg_GB.cfg
    Execute Egate Command
    ...    cmd=gnb_xn_ngran_conf_update_param id=2 action=drop nth=1 action=drop nth=2 action=drop nth=3 action=force_failure nth=4
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_TRACKINGAREA_DN}
    Send Delta Commissioning With Fixer    ${delta}    skip_parameter_relation_errors=${True}
    Sleep    30s    Wait For NGRANNodeConfigurationUpdateFailure
    Execute Egate Command    cmd=xn_gnb_link_up gnb=2 target=3
    Sleep    2s    Wait For Setup Xn Link
    Verify Scenario Messages    ${GC_MSGS}

CB008490_GF_EC202_ALT1_Failure_Of_Dynamic_Addition_Of_NR-DC-SN_Cells_Failure_Of_NG-RAN_Node_Configuration_Update
    [Setup]    Setup
    ...    iphy=${CURDIR}/config/iphy_GB.xml
    ...    scfc=scf_SN_GB_B1.xml
    ...    egate=${CURDIR}/config/cfg_GB.cfg
    ...    pm_counters=${True}
    Execute Egate Command
    ...    cmd=gnb_xn_ngran_conf_update_param id=2 action=drop nth=1 action=drop nth=2 action=drop nth=3 action=send_error_indication nth=4
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_UNLOCK_2_CELLS_AND_2_NEW_CELLS}
    Send Delta Commissioning With Fixer    ${delta}    skip_parameter_relation_errors=${True}
    Sleep    30s    Wait For ErrorIndication
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Scenario Messages    ${GF_202_MSGS}
    Verify Any Counters In File
        ...    M55126C00003    2      XN_SETUP_REQUEST_RECEIVED
        ...    M55126C00004    2      XN_SETUP_RESPONSE_SENT
        ...    M55126C00015    1      XN_ERROR_INDICATION_RECEIVED
        ...    M55126C00029    >4      XN_NGRAN_CONF_UPDATE_SENT
        ...    M55126C00030    >1      XN_NGRAN_CONF_UPDATE_ACK_RCVD
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3
        ...    file_path=${pm_counter_file}
    Verify Any Counters In File
        ...    M55117C00528    5      F1_DU_CU_CNF_UPD_ATT
        ...    M55117C00529    5      F1_DU_CU_CNF_UPD_ACT
        ...    M55117C00550    10     F1_DU_DU_CNF_UPD_ACK
        ...    M55117C00547    4      F1_DU_DU_CNF_UPD_ACT
        ...    M55117C00533    5      F1_DU_CU_CNF_UPD_SUC_ACT
        ...    M55117C00532    5      F1_DU_CU_CNF_UPD_SUC
        ...    M55117C00529    5      F1_DU_CU_CNF_UPD_ACT
        ...    M55117C00528    5      F1_DU_CU_CNF_UPD_ATT
        ...    M55150C00024    5      F1_CU_CU_CNF_UPD_ACT_SENT
        ...    M55117C00532    5      F1_CU_CU_CNF_UPD_SUCS
        ...    M55150C00027    5      F1_CU_CU_CNF_UPD_SUCS_ACT
        ...    M55150C00040    10     F1_CU_DU_CNF_UPD_RCVD
        ...    M55150C00041    4      F1_CU_DU_CNF_UPD_ACT_RCVD
        ...    M55150C00043    10     F1_CU_DU_CNF_UPD_ACK_SENT
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRDU-1
        ...    file_path=${pm_counter_file}

CB008490_GF_EC301_ALT_1_Unsuccessful_NG-RANodeConfigurationUpdate_After_NR-DC-SN_Lock_Cell_Operation
    [Setup]    Setup
    ...    iphy=${CURDIR}/config/iphy_GB.xml
    ...    scfc=scf_SN_GB_B1.xml
    ...    egate=${CURDIR}/config/cfg_GB.cfg
    Perform Parameter Commissioning    parameter=maxXnNgRanCfUpRetry    value=1    dist_name=MRBTS-3/NRBTS-3
    ...    skip_parameter_relation_errors=False
    Execute Egate Command
    ...    cmd=gnb_xn_ngran_conf_update_param id=2 action=drop nth=1 action=drop nth=2
    Perform Parameter Commissioning    parameter=administrativeState    value=Locked    dist_name=MRBTS-3/NRBTS-3/NRCELL-2
    ...    skip_parameter_relation_errors=False
    Sleep    30s    Wait For SCTP Connection Close
    Verify Scenario Messages    ${GF_302_MSGS}
    Verify Scenario Messages    ${GF_SCTP_MSGS}    >=

CB008490_GH_B101_Aggregating_Subsequent_Cell_Operations_Into_Single_NGRANNodeConfigurationUpdate
    [Setup]    Run Keywords    Backup And Modify Swconfig File    parameters_list=@{swconfig_flag}
    ...    AND    Setup
    ...    iphy=${CURDIR}/config/iphy_GB.xml
    ...    scfc=scf_SN_GB_B1.xml
    ...    egate=${CURDIR}/config/cfg_GB.cfg
    Perform Parameter Commissioning    parameter=administrativeState    value=Unlocked    dist_name=MRBTS-3/NRBTS-3/NRCELL-3
    ...    skip_parameter_relation_errors=False
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_NRCELL_5}
    Send Delta Commissioning With Fixer    ${delta}    skip_parameter_relation_errors=${True}
    Sleep    100s
    Perform Parameter Commissioning    parameter=administrativeState    value=Unlocked    dist_name=MRBTS-3/NRBTS-3/NRCELL-4
    ...    skip_parameter_relation_errors=False
    ${delta}=    Get Commissioning File For Enb Release Name    ${DELTA_NRCELL_6}
    Send Delta Commissioning With Fixer    ${delta}    skip_parameter_relation_errors=${True}
    Sleep    100s
    Verify Scenario Messages    ${GH_MSGS}

*** Keywords ***
Start Interfaces And Add Cplane Debug Logs
    Enable C-Plane Debug Logs       with_reboot=${false}
    Start Default Simulated Gnb Interface
    Start Vm Ethernet Interface    if_name=eth3:GNB2_NG    ip_with_mask=10.0.1.8/24
    Start Vm Ethernet Interface    if_name=eth3:GNB2_XN    ip_with_mask=10.0.1.9/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.1.6/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:GNB_4    ip_with_mask=10.0.2.100/24

Setup
    [Arguments]    ${iphy}    ${scfc}    ${egate}    ${xn_establish}=${True}    ${pm_counters}=${False}
    ...            ${skip_errors}=${False}
    Update And Put Iphy Xml         input_filepath=${iphy}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scfc}    skip_relation_errors=${skip_errors}
    Enable Tshark Verification    logs_path=${OUTPUT_DIR}/${TEST_NAME}/${TSHARK_SUBDIR}
    Start Default Syslog For Enb And Iphy
    Reach OnAir Without Confirmation   lua_cfg=${egate}    x2_link_start=${false}
    IF    ${xn_establish}
        IF    ${pm_counters}
            Wait For Next Full Pm Interval
        END
        Establish Xn Link    source_gnb_id=2    target_gnb_id=3
        Establish Xn Link    source_gnb_id=4    target_gnb_id=3
    END

Teardown
    Add Scout Scf Id To Test Data
    Stop Default Syslog For Enb And Iphy
    Run Keyword If Test Failed    Get Bts Snapshot    ${OUTPUT_DIR}/${TEST_NAME}/Snapshot.zip
    Stop Default Processes And Gather Logs    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Run Keyword If Test Passed    Find Suspicious Logs

Verify Scenario Messages
    [Arguments]    ${MSGS}    ${relation_symbol}= ==
    FOR    ${msg}    IN    @{MSGS}
        ${length}=    Get Length    ${msg}
        IF    ${length} != 2    Verify Tcpdump Log    packet_filter=${msg}    relation_symbol=${relation_symbol}
        ...    ELSE    Verify Tcpdump Log    packet_filter=${msg}[0]    number_of_messages=${msg}[1]    relation_symbol=${relation_symbol}
    END
