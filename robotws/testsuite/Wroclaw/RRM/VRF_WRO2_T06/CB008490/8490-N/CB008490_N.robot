*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[LO][LO]_AP_[LOO]

Documentation   :copyright: Nokia
...             :authors: Magdalena Mlynarska, Marta Klukas
...             :contact: magdalena.mlynarska@nokia.com, marta.klukas@nokia.com

Resource       ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource       ../resources/feature_keywords.robot
Resource       testsuite/Wroclaw/RRM/resources/airphone/wro_2/keywords/traffic.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/keywords.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/Error_finder.robot
Library        ../resources/KeywordsCB008490.py
Library        ta5g_file_system
Library        ta5g_pm_counters
Library        ta5g_ue_measurements
Library        ../../resources/multignb_variables.py
Library        ../../resources/syslog_collector.py
Library        testsuite/Wroclaw/RRM/resources/scout_report.py

Suite Setup        Enable C-Plane Debug Logs       with_reboot=${false}

Suite Teardown     Compress Test Logs

*** Variables ***
${SCFC_GNB_MN}=             scfc_MN_tc1.xml
${SCFC_GNB_SN}=             scfc_SN_tc1.xml
${SCFC_GNB_MN_TC2}=         scfc_MN_tc2.xml
${SCFC_GNB_SN_TC2}=         scfc_SN_tc2.xml
${IPHY_TC1}=                ${CURDIR}/config/iphy_MN_AHFIB_AHLOA_AEHC_SN_AWEWB_tc1.xml
${IPHY_TC2}=                ${CURDIR}/config/iphy_MN_AHFIB_AHLOA_AEHC_SN_AWEWB_tc2.xml
${CFG_TC1}=                 ${CURDIR}/config/cfg_MN_n66A_n71A_n41_2A_SN_n260I_tc1.cfg
${cfg_tc2}=                 ${CURDIR}/config/cfg_MN_n66A_n71A_n41_2A_SN_n260I_tc2.cfg
${amf_id}=                  1
${ue1}=                     1
${ue2}=                     2
@{MN_Cells}=                1    2    3    4
@{MN_PCell}=                1
@{MN_SCells}=               2    3    4
@{MN_Cells_TC2}=            1    2    3    4
@{SN_Cells_TC2}=            5    6    7    8
@{MN_Cells_0_After_TC2}=    2    3    4
@{SN_Cells_0_After_TC2}=    7    8
${delta_maxNumOfNrDcSnUsers_0}=    delta_maxNumOfNrDcSnUsers.json
${rollback_maxNumOfNrDcSnUsers}=    rollback_maxNumOfNrDcSnUsers.json
${delta_thresholdA1}=    delta_threshold_A1.json
${rollback_thresholdA1}=    rollback_threshold_A1.json
${delta_actBufferBasedSCellAddition}=    delta_actBufferBasedSCellAddition_tc1.json
@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST}=    M55116C00023    M55116C00027    M55118C00042    M55118C00043    M55118C10503
...    M55118C10504    M55118C00083    M55118C00084    M55118C11095    M55118C11096    M55118C10505    M55118C10506    M55118C00085    M55118C00086
@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST_TC2_MN}=    M55125C00030    M55138C00039    M55156C00005    M55161C00004    M55195C00001
@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST_TC2_SN}=    M55138C00040    M55156C00030    M55161C00006    M55195C00002
@{NEW_COUNTERS_TO_INCREMENT_AFTER_TEST_WITH_VALUE_1}=    M55116C00023    M55116C00027    M55118C10503    M55118C10504    M55118C11095    M55118C11096
...    M55118C10505    M55118C10506    M55118C00085    M55118C00086
@{NEW_COUNTERS_TO_INCREMENT_AFTER_TEST_WITH_VALUE_2}=    M55118C00042    M55118C00043
@{NEW_COUNTERS_TO_INCREMENT_AFTER_TEST_WITH_VALUE_4}=    M55118C00083    M55118C00084
@{NEW_COUNTERS_TO_INCREMENT_AFTER_TEST_WITH_VALUE_0}=    M55116C00023    M55116C00027    M55118C00042    M55118C00043    M55118C10503
...    M55118C10504    M55118C00083    M55118C00084    M55118C11095    M55118C11096    M55118C10505    M55118C10506    M55118C00085    M55118C00086

*** Test Cases ***
CB008490_SR_N_NC_FC_Scell_addition_NR-DC_setup_NR-DC_bearer_takeback_bufferbased_scell_addition
    [Setup]            Run Keywords    Update And Put Iphy Xml         input_filepath=${IPHY_TC1}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${SCFC_GNB_SN}
    ...                remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${SCFC_GNB_MN}
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Reach Onair    lua_cfg=${CFG_TC1}    remote_hosts=${REMOTE_HOSTS}
    ...    AND         Setup multigNB devices aliases

    Verify If Counters Were Not Incremented For All Cells On MN gNB Before Test
    Wait For Next Full Pm Interval
    Attach Ue    ue_id=${ue1}
    Establish PDU Session    ue_id=${ue1}    pdu_id=1    gw_id=1
    Trigger PDU Session Modify Procedure For UE1 With PDU1 And QoS Flow ID Eq 3
    Wait 1s For The Environment To Stabilize
    Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add For UE1
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=1    phycell_id=51    srsrp_nr=85    event=A1
    Wait 1s For The Environment To Stabilize
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=2   phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 meas NR-DC Setup After A1 meas SCell Add For UE1
    Verify RRC After NR-DC Setup For UE1 With CA  ue_id=${ue1}    num_of_scells=3
    Attach Ue    ue_id=${ue2}
    Establish PDU Session    ue_id=${ue2}    pdu_id=2    gw_id=2
    Trigger PDU Session Modify Procedure For UE2 With PDU2 And QoS Flow ID Eq 3
    Wait 1s For The Environment To Stabilize
    Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add For UE2
    Send Ue Measurement Nr    ue_id=${ue2}    meas_id=1    phycell_id=51    srsrp_nr=85    event=A1
    Wait 1s For The Environment To Stabilize
    Send Ue Measurement Nr    ue_id=${ue2}    meas_id=2   phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For A4 meas NR-DC Setup After A1 meas SCell Add For UE2
    Verify RRC After NR-DC Setup For UE2 With CA     ue_id=${ue2}    num_of_scells=1
    Find Scfc And Send Delta Commissioning   scfc_filename=${delta_actBufferBasedSCellAddition}
    Set Expected Message Flow On MN And SN Side For NR-DC Bearer Takeback Triggered By RLF For UE1
    Trigger RRC SCGFailureInformation With FailureType Set To T310-Expiry
    Verify Expected Message Flow On MN And SN Side For NR-DC Bearer Takeback Triggered By RLF For UE1
    Verify RRC After RLF For UE1  ue_id=${ue1}
    Wait 6s For The Environment To Stabilize
    Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd For UE1
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=10    phycell_id=51    srsrp_nr=85    event=A1
    Wait 2s For The Environment To Stabilize
    Send Ue Measurement Nr    ue_id=${ue1}    meas_id=11    phycell_id=52    nrsrp_nr=60    event=A4
    Send Data Traffic For UE1 With Two QFI
    Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd For UE1
    Verify RRC After A4 Meas ND-DC And A1 Meas SCell Add With BufferBasedSCellAdd For UE1    ue_id=${ue1}
    ${pm_counter_file_after_test}=    Get Next Unpacked Full Pm Counters File
    Set Suite Variable    ${pm_counter_file_after_test}
    Verify That New Counters Are Incremented After Test On MN Side
    Reset Site And Verify That Counters Are Reset For TC1
    [Teardown]         Run Keywords    Find Errors    remote_host=True
                   ...    AND         Add Scout Scf Id To Test Data
                   ...    AND         Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
                   ...    AND         Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
                   ...    AND         Collect Selected Debug Files
                   ...                output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
                   ...                omit_collectors=sos_report
                   ...    AND         Get BTS Snapshot
                   ...                output_filepath=${OUTPUT_DIR}/${TEST_NAME}/remote_host_bts_snapshot.zip
                   ...                remote_host=${REMOTE_HOST_1_IP}

CB008490_SR_N_NC_FC_NR-DC_setup_bearer_takeback_scell_addition_unsuccessful_NR-DC_setup_scell_addition_A4_during_scell_change
    [Setup]            Run Keywords    Update And Put Iphy Xml         input_filepath=${IPHY_TC2}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${SCFC_GNB_SN_TC2}
    ...                remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Find Scfc And Fix And Send Full Commissioning
    ...                scfc_filename=${SCFC_GNB_MN_TC2}
    ...    AND         Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}    remote_host=${REMOTE_HOST_1_IP}
    ...    AND         Reach Onair    lua_cfg=${cfg_tc2}    remote_hosts=${REMOTE_HOSTS}
    ...    AND         Setup multigNB devices aliases


    Verify If Counters Were Not Incremented For All Cells On Both Nodes
    Wait For Next Full Pm Interval

#UE1
    Attach Ue    ue_id=1
    Establish PDU Session    ue_id=1    pdu_id=1    gw_id=1
    Trigger PDU Session Modify Procedure For UE1 with PDU1 And QoS Flow ID Eq 3
    Wait 1s For PDU Session To Modify
    Establish PDU Session    ue_id=1    pdu_id=2    gw_id=2
    Trigger PDU Session Modify Procedure For UE1 with PDU2 And QoS Flow ID Eq 1
    Wait 1s For Measurement To Configure
    Set Expected Message Flow For NRDC Setup For UE1
    Send Ue Measurement Nr    ue_id=1    meas_id=2    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For NRDC Setup For UE1
    Verify NRDC Setup For UE1 For RRCReconfiguration_1

#UE2
    Attach Ue    ue_id=2
    Establish PDU Session    ue_id=2    pdu_id=1    gw_id=3
    Trigger PDU Session Modify Procedure For UE2 with PDU1 And QoS Flow ID Eq 3
    Wait 1s For PDU Session To Modify
    Establish PDU Session    ue_id=2    pdu_id=2    gw_id=4
    Trigger PDU Session Modify Procedure For UE2 with PDU2 And QoS Flow ID Eq 1
    Wait 1s For Measurement To Configure
    Set Expected Message Flow For NRDC Setup For UE2
    Send Ue Measurement Nr    ue_id=2    meas_id=2    phycell_id=52    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For NRDC Setup For UE2
    Verify NRDC Setup For UE2 For RRCReconfiguration_1

    Wait 30s For Stability Check
    Set Expected Message Flow For QoS Flow Deletion And SCell Addition For UE1
    UE1 Sends A1 Measurement For Scell Addition With Action
    Trigger PDU#2 Session Deletion Procedure For UE1 And QoS Flow ID Eq 2
    Verify Expected Message Flow For QoS Flow Deletion And SCell Addition For UE1
    Verify Successfull QoS Flow Deletion And SCell Addition For UE1

    Find Scfc and Send Delta Commissioning Retrying After Errors    scfc_filename=${delta_maxNumOfNrDcSnUsers_0}    remote_host=${REMOTE_HOST_1_IP}
    Set Expected Message Flow For RRC Reconfiguration To Configure For UE1
    Verify Expected Message Flow For RRC Reconfiguration To Configure For UE1
    Verify Successfull A4 Measurement Configuration For UE1

    Set Expected Message Flow For Unsuccessful NRDC Setup For UE1
    Send Ue Measurement Nr    ue_id=1    meas_id=10    phycell_id=52    nrsrp_nr=80    event=A4
    Verify Expected Message Flow For Unsuccessful NRDC Setup For UE1
    Verify Unsuccessful NRDC Setup For UE1

    Find Scfc and Send Delta Commissioning Retrying After Errors   scfc_filename=${delta_thresholdA1}
    Set Expected Message Flow For RRC Reconfiguration To Configure For UE1
    Verify Expected Message Flow For RRC Reconfiguration To Configure For UE1

    Set Expected Message Flow For SCell Addition For UE1
    Send Ue Measurement Nr    ue_id=1    meas_id=14    srsrp_nr=75    event=A1
    Verify Expected Message Flow For SCell Addition For UE1
    Verify SCell Addition For UE1

    Set Expected Message Flow For SCell Change And Then PSCell Addition For UE1
    Send Ue Measurement Nr    ue_id=1    meas_id=21    srsrp_nr=90    event=A1
    Send Ue Measurement Nr    ue_id=1    meas_id=16    phycell_id=53    nrsrp_nr=60    event=A4
    Verify Expected Message Flow For SCell Change And Then PSCell Addition For UE1
    Verify SCell Change For UE1
    Verify Scell Release For UE1
    Verify NRDC Setup For UE1 For RRCReconfiguration_3

    Verify That Counters Increment Accordingly After Test
    Reset Site And Verify That Counters Are Reset For TC2

    [Teardown]            Run Keywords
    ...                   Find Scfc and Send Delta Commissioning Retrying After Errors   scfc_filename=${rollback_maxNumOfNrDcSnUsers}
    ...                   remote_host=${REMOTE_HOST_1_IP}
    ...    AND            Find Scfc and Send Delta Commissioning Retrying After Errors   scfc_filename=${rollback_thresholdA1}
    ...    AND            Add Scout Scf Id To Test Data
    ...    AND            Find Errors    remote_host=True
    ...    AND            Teardown Egate And Collect Logs    logs_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND            Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...    AND            Collect Selected Debug Files
    ...                   output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    ...                   omit_collectors=sos_report
    ...    AND            Get BTS Snapshot
    ...                   output_filepath=${OUTPUT_DIR}/${TEST_NAME}/remote_host_bts_snapshot.zip
    ...                   remote_host=${REMOTE_HOST_1_IP}

*** Keywords ***
Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=160
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=160
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=50
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=160
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=160
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=ul    mbps=50

Trigger PDU#${pdu_id:\d+} Session Deletion Procedure For UE${ue_id:\d+} And QoS Flow ID Eq ${qos_id:\d+}
    Execute Egate Command
    ...     cmd=amf_ue_pdu_modify_param id=1 action=override_ie qos_flow_to_del_cause=RN_release_due_to_5gc_generated_reason
    Modify PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    qos_to_del=${qos_id}

UE${ue_id:\d+} Sends A1 Measurement For Scell Addition With Action
    Enable Skipping QoS Validation For The UE${ue_id}
    Execute Egate Command    cmd=ue_schedule_measurement_send_nr id=${ue_id} action=DELAY_TILL_NR_RRC_RECONF meas_id=6 event=A1 srsrp_nr=80

#Message Flows for TC1
Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add For UE${ue_id:\d+}
    Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Addition On MN Side For UE${ue_id} GNB2
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue_id} GNB3

Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add For UE${ue_id:\d+}
    Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Addition On MN Side For UE${ue_id} GNB2
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE${ue_id} GNB3

Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd For UE1
    Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd On MN Side For UE1 GNB2
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB3

Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd For UE1
    Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd On MN Side For UE1 GNB2
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB3

Set Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Set expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    uECtxMod=2    rrcReconf=1   rrcReconfCompl=1     sNnodeAddPrep=1
    ...   bearerCtxMod=2   xnUAddressInd=1    sNStatusTransfer=1      pduSessResModInd=1    F1APprivateMSg=1

Verify Expected Message Flow For A4 Meas NR-DC Setup After A1 Meas SCell Add With BufferBasedSCellAdd On MN Side For UE${ue_id:\d+} GNB${gnb_id:\d+}
    Verify expected message flow   ue_id=${ue_id}    gnb_id=${gnb_id}    uECtxMod=2    rrcReconf=1    rrcReconfCompl=1     sNnodeAddPrep=1
    ...   bearerCtxMod=2   xnUAddressInd=1    sNStatusTransfer=1      pduSessResModInd=1    F1APprivateMSg=1

Set Expected Message Flow On MN And SN Side For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+}
     Set Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id} GNB2
     Set Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id} GNB3

Verify Expected Message Flow On MN And SN Side For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+}
     Verify Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id} GNB2
     Verify Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id} GNB3

Set Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+} GNB2
     Set expected message flow     ue_id=${ue_id}  gnb_id=2   SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1     XNAPuECtxRelease=1
     ...    rrcReconf=1    rrcReconfCompl=1    pduSessResModInd=1

Verify Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+} GNB2
     Verify expected message flow    ue_id=${ue_id}    gnb_id=2    SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1
     ...    XNAPuECtxRelease=1    rrcReconf=1    rrcReconfCompl=1    pduSessResModInd=1

Set Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+} GNB3
     Set expected message flow     ue_id=${ue_id}  gnb_id=3   SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1     XNAPuECtxRelease=1

Verify Expected Message Flow For NR-DC Bearer Takeback Triggered By RLF For UE${ue_id:\d+} GNB3
     Verify expected message flow    ue_id=${ue_id}    gnb_id=3  SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1
     ...    XNAPuECtxRelease=1

Verify RRC After NR-DC Setup For UE1 With CA
    [Arguments]    ${ue_id}    ${num_of_scells}
     Verify In RRC RRCReconfiguration_1 Out Of 3 That List sCellToAddModList Has ${num_of_scells} Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List sCellToReleaseList Has ${num_of_scells} Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List measIdToRemoveList Has 3 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List reportConfigToRemoveList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List measIdToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_3 Out Of 3 That List measIdToRemoveList Has 5 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_3 Out Of 3 That secondaryCellGroup Is Present For UE${ue_id}
     Verify In RRC RRCReconfigurationComplete_3 Out Of 3 That nr-SCG-Response Is Present For UE${ue_id}

Verify RRC After NR-DC Setup For UE2 With CA
    [Arguments]    ${ue_id}    ${num_of_scells}
     Verify In RRC RRCReconfiguration_1 Out Of 3 That frequencyInfoDL Is Present For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 3 That frequencyInfoUL Is Present For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 3 That List sCellToAddModList Has ${num_of_scells} Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List sCellToReleaseList Has ${num_of_scells} Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List measIdToRemoveList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List reportConfigToRemoveList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_2 Out Of 3 That List measIdToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_3 Out Of 3 That List measIdToRemoveList Has 5 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_3 Out Of 3 That secondaryCellGroup Is Present For UE${ue_id}
     Verify In RRC RRCReconfigurationComplete_3 Out Of 3 That nr-SCG-Response Is Present For UE${ue_id}

Verify RRC After RLF For UE1
    [Arguments]    ${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToAddModList Has 1 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That mrdc-SecondaryCellGroupConfig Has 'release' For UE${ue_id}

Verify RRC After A4 meas ND-DC And A1 meas SCell Add With BufferBasedSCellAdd For UE1
    [Arguments]    ${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToRemoveList Has 5 Element/s For UE${ue_id}
     Verify In RRC RRCReconfiguration_1 Out Of 1 That secondaryCellGroup Is Present For UE${ue_id}
     Verify In RRC RRCReconfigurationComplete_1 Out Of 1 That nr-SCG-Response Is Present For UE${ue_id}

#Message Flows for TC2
Set Expected Message Flow For NRDC Setup For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    sNnodeAddPrep=1    xnUAddressInd=1    rrcReconf=1    rrcReconfCompl=1    sNnodeReconfCompl=1
    ...    pduSessResModInd=1

Verify Expected Message Flow For NRDC Setup For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    sNnodeAddPrep=1    xnUAddressInd=1    rrcReconf=1    rrcReconfCompl=1    sNnodeReconfCompl=1
    ...    pduSessResModInd=1

Verify NRDC Setup For UE${ue_id:\d+} For RRCReconfiguration_${x:\d+}
    Verify In RRC RRCReconfiguration_${x} Out Of ${x} That secondaryCellGroup Is Present For UE${ue_id}
    Verify In RRC RRCReconfiguration_${x} Out Of ${x} That List measIdToRemoveList Has 5 Element/s For UE${ue_id}
    Verify In RRC RRCReconfigurationComplete_${x} Out Of ${x} That nr-SCG-Response Is Present For UE${ue_id}

Set Expected Message Flow For QoS Flow Deletion And SCell Addition For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    pduSessResMod=1    SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1
    ...    rrcReconf=3    rrcReconfCompl=3    XNAPuECtxRelease=1

Verify Expected Message Flow For QoS Flow Deletion And SCell Addition For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    pduSessResMod=1    SNodeReleaseRequest=1    xnUAddressInd=1    sNStatusTransfer=1
    ...    rrcReconf=3    rrcReconfCompl=3    XNAPuECtxRelease=1

Verify Successfull QoS Flow Deletion And SCell Addition For UE${ue_id:\d+}
    Verify In NGAP PDUSessionResourceModifyRequest_1 Out Of 1 That QosFlowListWithCause Has qosFlowIdentifier Set To 1 For AMF${amf_id}
    Verify In NGAP PDUSessionResourceModifyRequest_1 Out Of 1 That radioNetwork Is Set To 'release-due-to-5gc-generated-reason' For AMF${amf_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List measIdToAddModList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That mrdc-SecondaryCellGroupConfig Contains release For UE${ue_id}
    Verify In NGAP PDUSessionResourceModifyResponse_1 Out Of 1 That PDUSessionResourceModifyListModRes Has pDUSessionID Set To 2 For AMF${amf_id}
    Verify In RRC RRCReconfiguration_3 Out Of 3 That List sCellToAddModList Has 3 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_3 Out Of 3 That List measObjectToAddModList Has 3 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_3 Out Of 3 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_3 Out Of 3 That List measIdToAddModList Has 3 Element/s For UE${ue_id}

Set Expected Message Flow For RRC Reconfiguration To Configure For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    timeout=120    rrcReconf=1    rrcReconfCompl=1

Verify Expected Message Flow For RRC Reconfiguration To Configure For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    timeout=120    rrcReconf=1    rrcReconfCompl=1

Verify Successfull A4 Measurement Configuration For UE${ue_id:\d+}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToAddModList Has 4 Element/s For UE${ue_id}

Set Expected Message Flow For Unsuccessful NRDC Setup For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}    sNnodeAddPrepFail=1    rrcReconf=1    rrcReconfCompl=1

Verify Expected Message Flow For Unsuccessful NRDC Setup For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}    sNnodeAddPrepFail=1    rrcReconf=1    rrcReconfCompl=1

Verify Unsuccessful NRDC Setup For UE${ue_id:\d+}
   Verify In RRC RRCReconfiguration_1 Out Of 1 That List sCellToReleaseList Has 3 Element/s For UE${ue_id}
   Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToRemoveList Has 3 Element/s For UE${ue_id}
   Verify In RRC RRCReconfiguration_1 Out Of 1 That List reportConfigToRemoveList Has 1 Element/s For UE${ue_id}
   Verify In RRC RRCReconfiguration_1 Out Of 1 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
   Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToAddModList Has 1 Element/s For UE${ue_id}
   Verify In XNAP SNodeAdditionRequestReject_1 Out Of 1 That radioNetwork Is Set To 'no-radio-resources-available' For GNB2

Set Expected Message Flow For SCell Addition For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}   rrcReconf=1    rrcReconfCompl=1

Verify Expected Message Flow For SCell Addition For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}   rrcReconf=1    rrcReconfCompl=1

Verify SCell Addition For UE${ue_id:\d+}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List sCellToAddModList Has 2 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToRemoveList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List reportConfigToRemoveList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List measObjectToAddModList Has 2 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List reportConfigToAddModList Has 2 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 1 That List measIdToAddModList Has 3 Element/s For UE${ue_id}

Set Expected Message Flow For SCell Change And Then PSCell Addition For UE${ue_id:\d+}
    Set expected message flow    ue_id=${ue_id}   rrcReconf=3    rrcReconfCompl=3    sNnodeAddPrep=1    xnUAddressInd=1    sNStatusTransfer=1
    ...    sNnodeReconfCompl=1    pduSessResModInd=1

Verify Expected Message Flow For SCell Change And Then PSCell Addition For UE${ue_id:\d+}
    Verify expected message flow    ue_id=${ue_id}   rrcReconf=3    rrcReconfCompl=3    sNnodeAddPrep=1    xnUAddressInd=1    sNStatusTransfer=1
    ...    sNnodeReconfCompl=1    pduSessResModInd=1

Verify SCell Change For UE${ue_id:\d+}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List sCellToAddModList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List sCellToReleaseList Has 2 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List measIdToRemoveList Has 3 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List reportConfigToRemoveList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List measObjectToRemoveList Has 2 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List measObjectToAddModList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_1 Out Of 3 That List measIdToAddModList Has 1 Element/s For UE${ue_id}

Verify Scell Release For UE${ue_id:\d+}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That List sCellToReleaseList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That List reportConfigToRemoveList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That List measIdToRemoveList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That List reportConfigToAddModList Has 1 Element/s For UE${ue_id}
    Verify In RRC RRCReconfiguration_2 Out Of 3 That List measIdToAddModList Has 1 Element/s For UE${ue_id}

#counters keywords
Verify If Counters Were Not Incremented For All Cells On MN gNB Before Test
    FOR    ${cell_index}    IN    @{MN_Cells}
        Verify If Counters Were Not Incremented
        ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST}
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_index}
        ...    remote_host=None
    END

Verify If Counters Were Not Incremented For All Cells On Both Nodes
    Verify If Counters Were Not Incremented For All Cells On MN
    Verify If Counters Were Not Incremented For All Cells On SN

Verify If Counters Were Not Incremented For All Cells On ${gnb_type:\S+}
    ${local_moid}=    Set Variable If    '${gnb_type}'=='MN'    PLMN-PLMN/MRBTS-1/NRBTS-2    PLMN-PLMN/MRBTS-3/NRBTS-3
    ${remote_host}=    Set Variable If    '${gnb_type}'=='MN'    None    ${REMOTE_HOST_1_IP}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File    remote_host=${remote_host}
    FOR    ${cell_index}    IN    @{${gnb_type}_Cells_TC2}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST_TC2_${gnb_type}}
        ...    value=0
        ...    local_moid=${local_moid}/NRCELL-${cell_index}
        ...    filepath=${pm_counter_file}
    END

Verify If Counters Were Not Incremented For Specific Cells On ${gnb_type:\S+}
    ${local_moid}=    Set Variable If    '${gnb_type}'=='MN'    PLMN-PLMN/MRBTS-1/NRBTS-2    PLMN-PLMN/MRBTS-3/NRBTS-3
    ${remote_host}=    Set Variable If    '${gnb_type}'=='MN'    None    ${REMOTE_HOST_1_IP}
    FOR    ${cell_index}    IN    @{${gnb_type}_Cells_0_After_TC2}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST_TC2_${gnb_type}}
        ...    value=0
        ...    local_moid=${local_moid}/NRCELL-${cell_index}
        ...    filepath=${pm_counter_file_After_test_${gnb_type}}
    END

Verify That New Counters Are Incremented After Test On MN Side
      ${pm_counter_file_after_test}=    Get Next Unpacked Full Pm Counters File
      Verify That New Counters Are Incremented After Test And Have Value Eq 1 For PCell
      Verify That New Counters Are Incremented After Test And Have Value Eq 2 For PCell
      Verify That New Counters Are Incremented After Test And Have Value Eq 4 For PCell
      Verify That New Counters Are Incremented After Test And Have Value Eq 0 For SCells

Verify That New Counters Are Incremented After Test And Have Value Eq ${x:\d+} For PCell
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
            ...    counter_id_list=@{NEW_COUNTERS_TO_INCREMENT_AFTER_TEST_WITH_VALUE_${x}}
            ...    value=${x}
            ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-@{MN_PCell}
            ...    filepath=${pm_counter_file_after_test}

Verify That New Counters Are Incremented After Test And Have Value Eq ${x:\d+} For SCells
    FOR    ${cell_index}    IN    @{MN_SCells}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST}
        ...    value=${x}
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_index}
        ...    filepath=${pm_counter_file_after_test}
    END

Verify If ${counter_id:\S+} Counter Has Value ${x:\d+} For PMQAP-${pmqap_id:\S+} And Cell-${cell_index:\d+} And ${gnb_type:\S+} GNB ${when:\S+} Test
    ${local_moid}=    Set Variable If    '${gnb_type}'=='MN'    PLMN-PLMN/MRBTS-1/NRBTS-2    PLMN-PLMN/MRBTS-3/NRBTS-3
    Run Keyword If    ('${counter_id}' == 'M55161C00004') or ('${counter_id}' == 'M55161C00006')
    ...     Verify If Any Pm Counter Is Bigger Than Given Value
            ...    counter_id=${counter_id}
            ...    value=${x}
            ...    local_moid=${local_moid}/NRCELL-${cell_index}
            ...    filepath=${pm_counter_file_${when}_test_${gnb_type}}
            ...    pmqap=${pmqap_id}
    ...    ELSE
    ...    Verify If Latest Pm Counter Has Exact Value
            ...    counter_id=${counter_id}
            ...    value=${x}
            ...    local_moid=${local_moid}/NRCELL-${cell_index}
            ...    filepath=${pm_counter_file_${when}_test_${gnb_type}}
            ...    pmqap=${pmqap_id}

Verify That Counters Increment Accordingly After Test
    ${pm_counter_file_during_test_MN}=    Get Next Unpacked Full Pm Counters File
    ${pm_counter_file_during_test_SN}=    Get Latest Unpacked Full Pm Counters File    remote_host=${REMOTE_HOST_1_IP}
    ${pm_counter_file_after_test_MN}=     Get Next Unpacked Full Pm Counters File
    ${pm_counter_file_after_test_SN}=     Get Next Unpacked Full Pm Counters File      remote_host=${REMOTE_HOST_1_IP}
    Set Suite Variable    ${pm_counter_file_During_test_MN}
    Set Suite Variable    ${pm_counter_file_During_test_SN}
    Set Suite Variable    ${pm_counter_file_After_test_MN}
    Set Suite Variable    ${pm_counter_file_After_test_SN}
    Verify PM Counters In PCell During Test
    Verify PM Counters In PCell After Test
    Verify PM Counters In PSCell On SN During Test
    Verify PM Counters In PSCell On SN After Test
    Verify PM Counters In Cell2 On SN After Test
    Verify If Counters Were Not Incremented For Specific Cells On MN
    Verify If Counters Were Not Incremented For Specific Cells On SN
    Wait For Next Full Pm Interval

Verify PM Counters In PCell During Test
    Verify If M55125C00030 Counter Has Value 1 For PMQAP-None And Cell-1 And MN GNB During Test
    Verify If M55156C00005 Counter Has Value 2 For PMQAP-None And Cell-1 And MN GNB During Test
    Verify If M55195C00001 Counter Has Value 2 For PMQAP-2 And Cell-1 And MN GNB During Test
    Verify If M55195C00001 Counter Has Value 2 For PMQAP-3 And Cell-1 And MN GNB During Test

Verify PM Counters In PCell After Test
    Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55138C00039
        ...    value_lower=350
        ...    value_higher=601
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
        ...    filepath=${pm_counter_file_after_test_MN}

    Verify If M55156C00005 Counter Has Value 2 For PMQAP-None And Cell-1 And MN GNB After Test
    Verify If M55195C00001 Counter Has Value 2 For PMQAP-2 And Cell-1 And MN GNB After Test
    Verify If M55195C00001 Counter Has Value 1 For PMQAP-3 And Cell-1 And MN GNB After Test
    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00004
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-1
        ...    filepath=${pm_counter_file_after_test_MN}
        ...    pmqap=1

    Verify If M55161C00004 Counter Has Value 500 For PMQAP-2 And Cell-1 And MN GNB After Test
    Verify If M55161C00004 Counter Has Value 250 For PMQAP-3 And Cell-1 And MN GNB After Test

Verify PM Counters In PSCell On SN During Test
    Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55138C00040
        ...    value_lower=250
        ...    value_higher=350
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-5
        ...    filepath=${pm_counter_file_during_test_SN}

    Verify If M55156C00030 Counter Has Value 2 For PMQAP-None And Cell-5 And SN GNB During Test
    Verify If M55161C00006 Counter Has Value 150 For PMQAP-2 And Cell-5 And SN GNB During Test
    Verify If M55161C00006 Counter Has Value 150 For PMQAP-3 And Cell-5 And SN GNB During Test
    Verify If M55195C00002 Counter Has Value 2 For PMQAP-2 And Cell-5 And SN GNB During Test
    Verify If M55195C00002 Counter Has Value 2 For PMQAP-3 And Cell-5 And SN GNB During Test

Verify PM Counters In PSCell On SN After Test
    Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55138C00040
        ...    value_lower=250
        ...    value_higher=301
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-5
        ...    filepath=${pm_counter_file_after_test_SN}

    Verify If M55156C00030 Counter Has Value 1 For PMQAP-None And Cell-5 And SN GNB After Test
    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00006
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-5
        ...    filepath=${pm_counter_file_after_test_SN}
        ...    pmqap=1

    Verify If M55161C00006 Counter Has Value 150 For PMQAP-2 And Cell-5 And SN GNB After Test
    Verify If M55161C00006 Counter Has Value 150 For PMQAP-3 And Cell-5 And SN GNB After Test
    Verify If M55195C00002 Counter Has Value 1 For PMQAP-2 And Cell-5 And SN GNB After Test
    Verify If M55195C00002 Counter Has Value 1 For PMQAP-3 And Cell-5 And SN GNB After Test

Verify PM Counters In Cell2 On SN During Test
    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55138C00040
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_during_test_SN}

    Verify If M55156C00030 Counter Has Value 0 For PMQAP-None And Cell-6 And SN GNB During Test

    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00006
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_during_test_SN}
        ...    pmqap=1

    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00006
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_during_test_SN}
        ...    pmqap=2

    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00006
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_during_test_SN}
        ...    pmqap=3

    Verify If M55195C00002 Counter Has Value 0 For PMQAP-2 And Cell-6 And SN GNB During Test
    Verify If M55195C00002 Counter Has Value 0 For PMQAP-3 And Cell-6 And SN GNB During Test

Verify PM Counters In Cell2 On SN After Test
    Verify If Any Pm Counter Is In Range Of Given Values
        ...    counter_id=M55138C00040
        ...    value_lower=250
        ...    value_higher=301
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_after_test_SN}

    Verify If M55156C00030 Counter Has Value 1 For PMQAP-None And Cell-6 And SN GNB After Test

    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00006
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_after_test_SN}
        ...    pmqap=1

    Verify If M55161C00006 Counter Has Value 150 For PMQAP-2 And Cell-6 And SN GNB After Test
    Verify If Latest Pm Counter Has Exact Value
        ...    counter_id=M55161C00006
        ...    value=0
        ...    local_moid=PLMN-PLMN/MRBTS-3/NRBTS-3/NRCELL-6
        ...    filepath=${pm_counter_file_after_test_SN}
        ...    pmqap=3

    Verify If M55195C00002 Counter Has Value 1 For PMQAP-2 And Cell-6 And SN GNB After Test
    Verify If M55195C00002 Counter Has Value 0 For PMQAP-3 And Cell-6 And SN GNB After Test

Verify That Counters Were Not Incremented After Reset Site And Have Value Eq ${x:\d+} For All MN Cells
        ${pm_counter_file_after_reset_site}=    Get Next Unpacked Full Pm Counters File
        Set Suite Variable    ${pm_counter_file_after_reset_site}
    FOR    ${cell_index}    IN    @{MN_Cells}
        Verify If Latest Pm Counters In Counter Id List Have Exact Value
        ...    counter_id_list=@{COUNTERS_NOT_TO_INCREMENT_BEFORE_AND_AFTER_TEST}
        ...    value=${x}
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-2/NRCELL-${cell_index}
        ...    filepath=${pm_counter_file_after_reset_site}
    END

Reset Site And Verify That Counters Are Reset For TC${tc_id:\d+}
    Trigger Site Reset    remote_host=None
    Wait For Testline Icmp Echo Replies And Ssh Services
    Trigger Site Reset    remote_host=${REMOTE_HOST_1_IP}
    Wait For Testline Icmp Echo Replies And Ssh Services
    Wait 601s For Counters To Show
    Run Keyword If    '${tc_id}' == '1'    Verify That Counters Were Not Incremented After Reset Site And Have Value Eq 0 For All MN Cells
    Run Keyword If    '${tc_id}' == '2'    Verify If Counters Were Not Incremented For All Cells On Both Nodes
