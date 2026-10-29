*** Settings ***
Documentation  :copyright: Nokia
...  :authors: Wojciech Peciak
...  :contact: wojciech.peciak@nokia.com

Library   taf.config.scf
Library   ta5g_tshark
Library   ta5g_ue_mobility
Library   ta5g_admin_operations
Library   ta5g_cell_operations
Resource  ../../../resources/ca_IWK.robot
Resource  ../../../resources/ca_INTER_RAT.robot
Resource  ../../../resources/cloud_bts.robot

*** Keywords ***
Prepare vCU Delta Scfs For CB010369_CB008225 Activate And Deactivate
    [Documentation]
    ...  KW calculates delta JSON files to preform activation and deactivation of features on vCU.
    ...  Minimal delta requires to activate CB010369 and interfreqncy handover A3 measurement on vCU
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Prepare vCU Delta Scfs For CB010369_CB008225 Activate And Deactivate

    Load SCF  ${LOG_PATH}/misc_logs/vCU_SCF_original.xml

    Modify SCF Element  value=true  dist_name=${NRBTS_DIST_NAME}  p_name=actSpidRfspInactTimers
    Modify SCF Element  value=rsrp  dist_name=${NRHOIF_DIST_NAME}   p_name=a3MeasEnabled

    Save SCF  ${LOG_PATH}/misc_logs/vCU_SCF_modified.xml
    Calculate Delta Between SCFs
    ...  ${LOG_PATH}/misc_logs/vCU_SCF_original.xml
    ...  ${LOG_PATH}/misc_logs/vCU_SCF_modified.xml
    ...  CB010369_And_Ho_Activation_Vcu


Prepare vDU Delta Scfs For CB010369_CB008225 Activate And Deactivate
    [Documentation]
    ...  KW calculates delta JSON files to preform activation and deactivation of features on vDU.
    ...  Minimal delta requires to deactivate powersaving feature on used cells in vDU
    ...
    ...  | **Author:** wojciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...  Prepare vDU Delta Scfs For CB010369_CB008225 Activate And Deactivate

    Load SCF  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml

    ${modification_strings} =  Create List
    ...  modify:NRPGRP-${NR_CELL_ID_ORIGIN}$:lbpsPeriodList:lbpsSuspended=suspended
    ...  modify:NRPGRP-${NR_CELL_ID_TARGET}$:lbpsPeriodList:lbpsSuspended=suspended
    Perform SCF Modification  modification_strings=@{modification_strings}

    Save SCF  ${LOG_PATH}/misc_logs/vDU_SCF_modified.xml
    Calculate Delta Between SCFs
    ...  ${LOG_PATH}/misc_logs/vDU_SCF_original.xml
    ...  ${LOG_PATH}/misc_logs/vDU_SCF_modified.xml
    ...  Power_Saving_Deactivation_Vdu


Toggle CB010369 On Vcu And Vdu
    [Documentation]
    ...  Toggles CB010369 ativation/deactivation via performin delta recommissioning of vDU and vCU.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | state                  | No   | Expected state of CB010369 Preconditions                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Toggle CB010369 On Vcu And Vdu  state=Activate

    [Arguments]  ${state}=Activate

    Log  Toggle CB010369 On Vcu And Vdu - state:${state}  console=True

    ${file_name} =  Set Variable If  '${state}' == 'Activate'
    ...    CB010369_And_Ho_Activation_Vcu.json
    ...    CB010369_And_Ho_Activation_Vcu_revert.json
    Connect To VCU
    Log  Performing recommissioning on vCU...  console=True
    vcu.Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/${file_name}
    Verify CB010369 And Ho Delta On VCU  expected_state=${state}
    Log  Update on vCU finished.  console=True

    ${file_name} =  Set Variable If  '${state}' == 'Activate'
    ...    Power_Saving_Deactivation_Vdu.json
    ...    Power_Saving_Deactivation_Vdu_revert.json
    Connect To VDU
    Log  Performing recommissioning on vDU...  console=True
    vdu.Perform Delta Recommissioning  ${LOG_PATH}/misc_logs/${file_name}
    Verify CB010369 Preconditions On VDU  expected_state=${state}
    Log  Update on vDU finished.  console=True

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vcu.Disconnect
    ...  AND  Run Keyword And Ignore Error  vdu.Disconnect


Verify CB010369 And Ho Delta On Vcu
    [Documentation]
    ...  Verify if changes for CB010369 were activated/deactivated on BTS after delta recommissioning on vCU.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | expected_value         | Yes  | Expected state of CB010369 Preconditions                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify CB010369 Preconditions On Vcu  expected_state=Activate

    [Arguments]  ${expected_state}

    ${expected_actSpidRfspInactTimers} =  Set Variable If  '${expected_state}' == 'Activate'  true  false
    ${actSpidRfspInactTimers} =  Get VCU Simple Parameter Value  dist_name=${NRBTS_DIST_NAME}  param_name=actSpidRfspInactTimers
    Should Be True  '${actSpidRfspInactTimers}' == '${expected_actSpidRfspInactTimers}'
    ...  msg=Value for actSpidRfspInactTimers (${actSpidRfspInactTimers}) on vCU is different than expected (${expected_actSpidRfspInactTimers}).

    ${expected_a3MeasEnabled} =  Set Variable If  '${expected_state}' == 'Activate'  rsrp  none
    ${a3MeasEnabled} =  Get VCU Simple Parameter Value  dist_name=${NRHOIF_DIST_NAME}  param_name=a3MeasEnabled
    Should Be True  '${a3MeasEnabled}' == '${expected_a3MeasEnabled}'
    ...  msg=Value for a3MeasEnabled (${a3MeasEnabled}) on vCU is different than expected (${expected_a3MeasEnabled}).

    Log  CB010369 And Ho check on vCU successful.  console=True


Verify CB010369 Preconditions On Vdu
    [Documentation]
    ...  Verify if changes for CB010369 were activated/deactivated on BTS after delta recommissioning on vDU.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | expected_value         | Yes  | Expected state of CB010369 Preconditions                              |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify CB010369 Preconditions On Vdu  expected_state=Activate

    [Arguments]  ${expected_state}

    Connect To VDU
    ${expected_lbpsSuspended} =  Set Variable If  '${expected_state}' == 'Activate'  suspended  notSuspended
    ${lbpsSuspended} =  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${ORIGIN_CELL_NRPGRP_DIST_NAME}
    ...  para_name=lbpsPeriodList/0/lbpsSuspended
    ${msg} =  Catenate  Value for lbpsPeriodList/0/lbpsSuspended (${lbpsSuspended})
    ...  on ORIGIN cell at vDU is different than expected (${expected_lbpsSuspended}).
    Should Be True  '${lbpsSuspended}' == '${expected_lbpsSuspended}'
    ...  msg=${msg}

    ${lbpsSuspended} =  vdu.Search Parameter Of Current Plan
    ...  mo_dn=${TARGET_CELL_NRPGRP_DIST_NAME}
    ...  para_name=lbpsPeriodList/0/lbpsSuspended
    ${msg} =  Catenate  Value for lbpsPeriodList/0/lbpsSuspended (${lbpsSuspended})
    ...  on TARGET cell at vDU is different than expected (${expected_lbpsSuspended}).
    Should Be True  '${lbpsSuspended}' == '${expected_lbpsSuspended}'
    ...  msg=${msg}

    Log  Verify CB010369 Preconditions On VDU successful.  console=True
    [Teardown]    Run Keyword And Ignore Error  vdu.Disconnect


Configure AMF On WTS
    [Documentation]
    ...  Umbrela KW to trigger CB010369 and CB008225 activation for given UE on simulted AMF.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Configure AMF On WTS

    Log  Configuring AMF...  console=True
    Configure AMF For CB010369
    Configure AMF For CB008225
    Log  AMF configured  console=True


Configure AMF For CB010369
    [Documentation]
    ...  KW confgires simulted ue specific settings at egate's AMF in order to activate CB010369.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Configure AMF For CB010369

    Execute Egate Command
    ...  cmd=amf_ue_ics_param id=1 ue=${UE_ID} indexToRFSP=${INDEX_TO_RFSP}


Configure AMF For CB008225
    [Documentation]
    ...  KW confgires simulted ue specific settings at egate's AMF in order to activate CB008225.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Configure AMF For CB008225

    Connect To VDU
    ${mcc} =  vdu.Search Parameter Of Current Plan
    ...  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPLMN-${PLMN_ID}
    ...  para_name=mcc
    ${mnc} =  vdu.Search Parameter Of Current Plan
    ...  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPLMN-${PLMN_ID}
    ...  para_name=mnc

    ${cmd}=  Catenate
    ...  amf_ue_ics_param id=1 ue=${UE_ID} core_network_assistance_info=on ue_identity_index_value=1
    ...  ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=${mcc}:${mnc} tac_id=${TAC}
    Execute Egate Command  ${cmd}

    [Teardown]  Run Keyword And Ignore Error  vdu.Disconnect


Get Target Cell Parameter
    [Documentation]
    ...  Checks state of NR cells from vDU for lock operation.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | parameter_name         | Yes  | Abbreviation of paramter on cell MO at vDU                       |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Get Target Cell Parameter  parameter_name=actRrcInactState

    [Arguments]  ${parameter_name}

    Connect To VDU
    ${parameter_value} =  vdu.Search Parameter Of Current Plan
    ...  mo_dn=MRBTS-${VDU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_TARGET}
    ...  para_name=${parameter_name}

    [Teardown]  Run Keyword And Ignore Error  vdu.Disconnect
    [Return]  ${parameter_value}


Verify Nrbts Mo Value On VCU
    [Documentation]
    ...  KW gets Nrbts Mo Value from vCU and validates it against expected value.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | param_name             | Yes  | Abbreviation of paramter on cell MO at vDU.                      |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | expected_value         | Yes  | Expected value of given parameter.                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify Nrbts Mo Value On VCU  param_name=actInterFreqHoSA  expected_value=true

    [Arguments]  ${param_name}  ${expected_value}
    ${param_value} =  Get VCU Simple Parameter Value  dist_name=${NRBTS_DIST_NAME}  param_name=${param_name}
    Should Be True  '${param_value}' == '${expected_value}'
    ...  msg=Value for ${param_name} (${param_value}) on vCU is different than expected (${expected_value}).


Verify Preconditions For CB010369 TC On VCU
    [Documentation]
    ...  Checks main preconditions for CB010369 to be active before the test phase.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify Preconditions For CB010369 TC On VCU

    Log  \n==== Verify Preconditions For CB010369 TC On VCU ====  console=True

    Verify Nrbts Mo Value On VCU  param_name=actInterFreqHoSA  expected_value=true
    Verify Nrbts Mo Value On VCU  param_name=actRfspIndex  expected_value=true
    Verify Nrbts Mo Value On VCU  param_name=actRrcInactState  expected_value=intra-gNB
    Verify Nrbts Mo Value On VCU  param_name=outOfConnectedPreference  expected_value=inactive
    Verify Nrbts Mo Value On VCU  param_name=rrcInactPreferredStateEnabled  expected_value=true
    Verify Nrbts Mo Value On VCU  param_name=activityNotificationLevelSA  expected_value=ue

    ${a3MeasEnabled} =  Get VCU Simple Parameter Value
    ...  dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_ORIGIN}
    ...  param_name=a3MeasEnabled
    Should Be True  '${a3MeasEnabled}' == 'rsrp'
    ...  msg=Value for a3MeasEnabled (${a3MeasEnabled}) on vCU is different than expected (rsrp).

    ${lcrId} =  Get VCU Simple Parameter Value
    ...  dist_name=MRBTS-${VCU_MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID_ORIGIN}/NRREL-1
    ...  param_name=lcrId
    Should Be True  '${lcrId}' == '${NR_CELL_ID_TARGET}'
    ...  msg=Value for lcrId (${lcrId}) on vCU is different than expected (${NR_CELL_ID_TARGET}).

    Log  CB010369 And Ho check on vCU successful.  console=True


Wait For Target Cell State Due To Power Saving
    [Documentation]
    ...  Waits for given state of NR cell from vDU for current power saving settings.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | expected_state         | No   | Expected operational_state of target cell in WebEM                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Wait For Target Cell State Due To Power Saving  enabled

    [Arguments]    ${expected_state}=enabled
    Log  \n==== Wait For Target Cell To Be ${expected_state}, Due To Settings Of Energysaving ====  console=True
    Wait Until Keyword Succeeds  300s  10s
    ...  Check Single Cell Vdu Aic
    ...    cell_id=${NR_CELL_ID_TARGET}
    ...    search_key=operational_state
    ...    expected_state=${expected_state}


Perform HO Meas Type A3
    [Documentation]
    ...  KW used to perform inter-frequency HO with simulated UE based on A3 measurement.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | ue                     | Yes  | ID of simulated Ue.                                                   |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | tgt_phycell_id         | Yes  | Ho target cell physical ID.                                           |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | tgt_cell_ssb_frequency | Yes  | HO target cell ssb frequency.                                         |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Perform HO Meas Type A3  1  52  632928

    [Arguments]  ${ue}  ${tgt_phycell_id}  ${tgt_cell_ssb_frequency}
    Log  \nHandover is performed...  console=True
    ${prepare_command}=  Catenate
    ...  ue_ho_nr ue_id\=${ue} meas_type\=A3
    ...  tgt_phycell_id\=${tgt_phycell_id} tgt_cell_ssb_frequency\=${tgt_cell_ssb_frequency}
    Execute Egate Command And Wait For Data
    ...  cmd=${prepare_command}
    ...  pass_regexp=message c1 : rrcReconfigurationComplete
    Execute EGATE Command  cmd=ue_disp id=${UE_ID}


Wait And Verify UE Transfer To RRC_Inactive At Ue and gNB Level
    [Documentation]
    ...  KW used to pasue execution until UE transition to RRC_Inactive is not detected. Detection and verification
    ...  is based on tshark message at UE level (RRC protocol) as well as at gNB level (e1ap protocol).
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Wait And Verify UE Transfer To RRC_Inactive At Ue and gNB Level

    Log  \nChecking HO packets ...  console=True
    Wait And Verify UE Transfer To RRC_Inactive
    Verify Ue Bearer Inactivity Detected At gNB


Wait And Verify UE Transfer To RRC_Inactive
    [Documentation]
    ...  KW used to pasue execution until UE transition to RRC_Inactive is not detected. Detection and verification
    ...  is based on tshark message at UE level (RRC protocol).
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Wait And Verify UE Transfer To RRC_Inactive

    Start Counting Packets And Wait For Given Packets Number
    ...  nr_of_packets=1
    ...  alias=${GNB_VCU_TCPDUMP_ALIAS}
    ...  timeout=180
    ...  packet_filter=${FILTER_RRC_INACTIVE_VERF_UE_LVL}


Verify Ue Bearer Inactivity Detected At gNB
    [Documentation]
    ...  Verify Ue transition to RRC_Inactive based on Bearer Inactivity Detected At gNB.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Verify Ue Bearer Inactivity Detected At gNB

    ${filter_RRC_Inactive_verf_gNB_lvl}=  Set Variable  e1ap.BearerContextInactivityNotification_element && e1ap.uE_Activity == 1
    Verify Tshark For Single Message
    ...  alias=${GNB_VCU_TCPDUMP_ALIAS}
    ...  packet_filter=${filter_RRC_Inactive_verf_gNB_lvl}
    ...  pcap_file_path=${LOG_PATH}/tshark/gnb_F1_E1_RRC.pcap


Measure Time For The Transition To RRC_Inactive
    [Documentation]
    ...  Measures time between two tshark packet indicating start and end of time gap for UE to go into RRC_Inactive
    ...  state.
    ...
    ...  | **Author:** wojecieh.peciak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...  | Parameter              | Man. | Description                                                           |
    ...  +========================+======+=======================================================================+
    ...  | locked_cell_id         | Yes  | ID of locked cell.                                                    |
    ...  +------------------------+------+-----------------------------------------------------------------------+
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Measure Time For The Transition To RRC_Inactive

    ${filter_IntraFreq_HO_completed}=  Set Variable  nr-rrc.rrcReconfigurationComplete_element && nr-rrc.rrc_TransactionIdentifier == 3
    ${time_difference}=  Time Between Two Tshark Messages
    ...  alias=${GNB_VCU_TCPDUMP_ALIAS}
    ...  filter1=${filter_IntraFreq_HO_completed}
    ...  filter2=${FILTER_RRC_INACTIVE_VERF_UE_LVL}
    ...  output_pdml_filepath1=${LOG_PATH}/tshark/nr_rrc_rrcReconfigurationComplete.pdml
    ...  output_pdml_filepath2=${LOG_PATH}/tshark/nr_rrc_suspendConfig.pdml
    ...  pcap_file_path=${LOG_PATH}/tshark/gnb_F1_E1_RRC.pcap
    [Return]  ${time_difference}


Ue Teardown
    [Documentation]
    ...  KW releses PDU session and deregisters simulated UE used in test
    ...
    ...  | **Author:** wojeciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Ue Teardown

    Run Keyword And Ignore Error  Release Pdu Session  ue_id=${UE_ID}  pdu_id=1
    Run Keyword And Ignore Error  Deregister Ue  ue_id=${UE_ID}


Reset AMF On WTS To Default
    [Documentation]
    ...  Resets to default UE specific settings on WTS simulated AMF
    ...
    ...  | **Author:** wojeciech.peciak@nokia.com
    ...
    ...  **Example of simple usage:**
    ...
    ...  .. code-block:: robotframework
    ...
    ...     Reset AMF On WTS To Default

    Execute Egate Command
    ...  cmd=amf_ue_ics_param id=1 ue=${UE_ID} reset

