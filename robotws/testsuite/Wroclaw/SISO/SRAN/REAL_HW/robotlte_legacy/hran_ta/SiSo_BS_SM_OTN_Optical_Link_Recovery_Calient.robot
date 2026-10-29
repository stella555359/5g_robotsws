*** Settings ***

Resource    resources/ca_Recovery_link_break.robot

*** Variables ***
${OTN_OBSAI_RECOVERY_TIME}    20000
${SISO_L3_CALL}               False

*** Keywords ***
TC_SiSo_BS_SM_OTN_Optical_Link_Recovery_Calient
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-6205
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Variable {loc_link_break_min} and {loc_link_brak_max} describe boundaries in which break time will be choose,
    ...  {loc_sn_rf_test} refers to RF serial number which will be tested.
    ...  {switch_port_link_break} It is variable port number of optical switch Calient for breaking optical connection of tested radio
    ...  {ip_switch_tl1} ip adress of optical switch
    ...
    ...  Examples of variables:
    ...  loc_link_break_min=0  loc_link_break_max=10000  break time in ms
    ...  loc_sn_rf_test=L1131610437
    ...  ip_switch_tl1=10.42.201.14
    ...  switch_port_link_break=4.4.1
    ...
    ...  ${OTN_OBSAI_RECOVERY_TIME}  20000  #default value of otnObsaiRecoveryPeriod which is checking in test, variable can be changed
    ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...  *****************
    ...  History of change
    ...  *****************
    ...
    Common Test Setup
    Logging With Timestamp
    ...  message=TC_SiSo_BS_SM_OTN_Optical_Link_Recovery_Calient will be executed
    ...  style=ONGOING
    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT

    Set Test Variable  ${LOC_LINK_BREAK_MIN}  ${loc_link_break_min}
    Set Test Variable  ${LOC_LINK_BREAK_MAX}  ${loc_link_break_max}
    Set Test Variable  ${LOC_SN_RF_TEST}  ${loc_sn_rf_test}
    Set Test Variable  ${IP_SWITCH_TL1}  ${ip_switch_tl1}
    Set Test Variable  ${SWITCH_PORT_LINK_BREAK}  ${switch_port_link_break}

    Precondition For OTN Optical Link Recovery With Calient
    FOR  ${out_run_number}  IN  @{REPETITION_LIST}
      Step 1: Perform Optical Link Break OTN With Calient  ${out_run_number}
      Step 2: Check Correct States After Optical Link Break OTN With Calient  ${out_run_number}
      Step 3: Recover Inisial Setup  ${out_run_number}
    END
    Postcondition For OTN Optical Link Recovery With Calient
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Teardown Optical Switch TL1  AND
    ...  Run Keyword If  not ${TEST_STATUS}  Collect Snapshot  target_file_name=${cfg['test_logs_path']}/Snapshot.zip  connection=${BTS_ID}  AND
    ...  Run Keyword If  not ${TEST_STATUS}  Reset Site  alias=${BTS_ID}  AND
    ...  Common Test Teardown

Precondition For OTN Optical Link Recovery With Calient
    Log  === Precondition For OTN Optical Link Recovery With Calient ===  console=${TRUE}
    Set Test Variable  ${TEST_STATUS}  ${False}
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    Optical Switch Setup TL1  switch_ip=${IP_SWITCH_TL1}
    Checking The Correct Values Of The OTN parameters
    Get Information About Tested RF
    Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS
    Set Test Variable  ${PASS_COUNT}  ${0}

Step 1: Perform Optical Link Break OTN With Calient
    [Arguments]  ${out_run_number}
    Log  Test no. ${out_run_number}  console=${TRUE}
    Log  === Step 1: Perform Optical Link Break OTN With Calient ===  console=${TRUE}
    Create Directory  ${cfg['test_logs_path']}/${out_run_number}
    Logging Multinode Start  ${cfg['test_logs_path']}/${out_run_number}
    Verify Multi BTS State
    Verify Alarms On All Nodes
    ${LINK_BREAK_DURATION}=  Evaluate  random.randint(${LOC_LINK_BREAK_MIN},${LOC_LINK_BREAK_MAX})  random
    Set Test Variable  ${LINK_BREAK_DURATION}
    ${RF_RESET_ACCEPT_BEFORE_BREAK}=  Check If RMOD reset accepted  ${LOC_SN_RF_TEST}  ${LINK_BREAK_DURATION}
    Set Test Variable  ${RF_RESET_ACCEPT_BEFORE_BREAK}
    Log  Optical Link Break started !!! Will last ${LINK_BREAK_DURATION}ms  console=${TRUE}
    Link Flapping TL1  flap_lowperiod=${LINK_BREAK_DURATION}  flap_ports=${SWITCH_PORT_LINK_BREAK}
    Sleep  ${LINK_BREAK_DURATION}ms
    Log  Optical Link Break STOPED !!!  console=${TRUE}

Step 2: Check Correct States After Optical Link Break OTN With Calient
    [Arguments]  ${out_run_number}
    Log  === Step 2: Check Correct States After Optical Link Break OTN With Calient ===  console=${TRUE}
    Veryfication For Optical Recovery Link Break  ${out_run_number}

Step 3: Recover Inisial Setup
    [Arguments]  ${out_run_number}
    Log  === Step 3: Recover Inisial Setup ===  console=${TRUE}
    ${status}=  Run Keyword And Return Status  Verify Multi BTS State
    Run Keyword If  not ${status}  Run Keywords  Reset Site  alias=${BTS_ID}  AND  Verify Multi BTS State
    Verify Alarms On All Nodes
    Logging Multinode Stop  ${cfg['test_logs_path']}/${out_run_number}  status=PASS

Postcondition For OTN Optical Link Recovery With Calient
    Log  === Postcondition For OTN Optical Link Recovery With Calient ===  console=${TRUE}
    ${repetition_list_length}=  Get Length  ${REPETITION_LIST}
    ${pass_ratio}=  Evaluate  ${PASS_COUNT}/${repetition_list_length}*100
    ${test_status}=  Run Keyword And Return Status  Should Be True  ${pass_ratio}>=95
    Set Test Variable  ${TEST_STATUS}  ${test_status}
    Run Keyword If  ${TEST_STATUS}  Log  Test PASSED. Pass ratio ${pass_ratio}%  console=${TRUE}
    ...       ELSE  Fail  Pass ratio not accepted -> ${pass_ratio}%

Checking The Correct Values Of The OTN parameters
    Get Current SCF File  ${cfg['test_logs_path']}  SCF_Precondition.xml  connection=${BTS_ID}
    ${featcadm_class_name}=  Set Variable  com.nokia.srbts.mnl:FEATCADM
    ${featcadm_dist_name}=  Set Variable  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${act_obsai_otn_value}=  Check Parameter Value From Scf  ${featcadm_class_name}  ${featcadm_dist_name}  actObsaiOTNRecovery
    ${act_obsai_period_value}=  Check Parameter Value From Scf  ${featcadm_class_name}  ${featcadm_dist_name}  otnObsaiRecoveryPeriod
    Run Keyword If  "${act_obsai_otn_value}"=="true"  Log To Console  ObsaiOTNRecovery activated.
    Run Keyword If  not "${act_obsai_otn_value}"=="true"  Fail  ObsaiOTNRecovery not activated, test failed.
    Run Keyword If  "${act_obsai_period_value}"=="${OTN_OBSAI_RECOVERY_TIME}"
    ...  Log  Value of parameter otnObsaiRecoveryPeriod is correct.  console=${TRUE}
    Run Keyword If  not "${act_obsai_period_value}"=="${OTN_OBSAI_RECOVERY_TIME}"  Fail
    ...  Value of otnObsaiRecoveryPeriod is different than ${OTN_OBSAI_RECOVERY_TIME}, test failed.

Check Parameter Value From Scf
    [Arguments]  ${class_name}  ${dist_name}  ${parameter_name}
    ${out_parameter_value}=  Evaluate Xpath  ${cfg['test_logs_path']}/SCF_Precondition.xml
    ...  string(.//managedObject[@class="${class_name}" and @distName="${dist_name}"]/p[@name="${parameter_name}"])
    [Return]  ${out_parameter_value}

Check If RMOD reset accepted
    [Arguments]  ${rf_serial_number}  ${link_break_duration}
    ${tested_rf_cablinks_length}=  Length Of RF Cablink  ${rf_serial_number}
    ${status_cablink_length}=  Run Keyword And Return Status  Should Be True  ${tested_rf_cablinks_length}>30
    Run Keyword If  ${status_cablink_length}  Log  Cablink length is more than 30m. It's ${tested_rf_cablinks_length}m  console=${TRUE}
    ${status_break_duration}=  Run Keyword And Return Status  Should Be True  ${link_break_duration}>10000
    Run Keyword If  ${status_break_duration}  Log  RF link break is more than 10000ms  console=${TRUE}
    ${status_rf_reset}=  Run Keyword And Return Status  Should Be True  ${status_cablink_length}==${TRUE} or ${status_break_duration}==${TRUE}
    Run Keyword If  ${status_rf_reset}  Log  RF reset accepted  console=${TRUE}
    [Return]  ${status_rf_reset}

Length Of RF Cablink
    [Arguments]  ${rf_serial_number}
    ${rf_cablinks}=  Create RF Dictionary Fiber Length Description
    ${rf_cablink_length}=  Set Variable  ${rf_cablinks['${rf_serial_number}']['1']}
    [Return]  ${rf_cablink_length}

Get Information About Tested RF
    @{affected_rf_sn}=  Create List  ${LOC_SN_RF_TEST}
    ${chain_fr}=  Get From Dictionary  ${cfg['RF_INFO']['${LOC_SN_RF_TEST}']}  scf_chain_fr_affected_list
    ${notEmpty}=  Run Keyword And Return Status  Should Not Be Empty  ${chain_fr}
    Run Keyword If  ${notEmpty}  Append To List  ${affected_rf_sn}  ${chain_fr[0]}
    &{affected_rf}=  Create Dictionary
    FOR  ${rf_sn}  IN  @{affected_rf_sn}
      ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${rf_sn}
      Set To Dictionary  ${affected_rf}  ${rf_sn}=${ru_dist_name}
    END
    Set Test Variable  ${AFFECTED_RF}  ${affected_rf}

Create Affected Cell List for RMOD
    [Arguments]  ${ru_sn}
    ${gncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  gncelid
    ${wncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  wncelid
    ${lncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  lncelid
    ${nrcelid_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  nrcelid
    ${ru_cell_list}=  Create List
    Run Keyword If  "${gncell_list}" != "None"  Append To List  ${ru_cell_list}  @{gncell_list}
    Run Keyword If  "${wncell_list}" != "None"  Append To List  ${ru_cell_list}  @{wncell_list}
    Run Keyword If  "${lncell_list}" != "None"  Append To List  ${ru_cell_list}  @{lncell_list}
    Run Keyword If  "${nrcelid_list}" != "None"  Append To List  ${ru_cell_list}  @{nrcelid_list}
    ${ru_cell_affected_dict}=  Create Dictionary  gncelid=${gncell_list}
    ...                                           wncelid=${wncell_list}
    ...                                           lncelid=${lncell_list}
    ...                                           nrcelid=${nrcelid_list}
    [Return]  ${ru_cell_affected_dict}

Veryfication For Optical Recovery Link Break
    [Arguments]  ${out_run_number}
    Log  Checking RMODs operationalState  console=${TRUE}
    ${rf_state_enabled}=  Run Keyword And Return Status  Repeat Keyword  8s
    ...  Assert Every  class_name=RMOD  operationalState=regex"Enabled|enabled"  timeout=2  connection=${BTS_ID}
    Run Keyword If  ${rf_state_enabled}  Log  RMODs are in enabled state  console=${TRUE}
    ${fault_visible}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  15s  3s
    ...  Assert Alarm Active  faultId=10, severity=Critical  connection=${BTS_ID}
    Run Keyword If  ${fault_visible}  Log  Fault 10 visible after break !!  console=${TRUE}
    ${rf_status}=  Run Keyword And Return Status  Should Be True  ${rf_state_enabled} and not ${fault_visible}
    Verify Multi BTS State
    Verify Alarms On All Nodes
    ${rf_reset_accept_after_break}=  Check If RMOD reset accepted  ${LOC_SN_RF_TEST}  ${LINK_BREAK_DURATION}
    ${rf_reset_accept}=  Run Keyword And Return Status
    ...  Should Be True  ${RF_RESET_ACCEPT_BEFORE_BREAK}==${TRUE} or ${rf_reset_accept_after_break}==${TRUE}
    ${l3call_status}  Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}/${out_run_number}  ${BTS_ID}
    ...    ELSE  Log To Console  L3 Call skipped  console=True
    Run Keyword If  ${SISO_L3_CALL}  Run Keyword If  (${rf_status} or ${rf_reset_accept}) and ${l3call_status}  Pass Ratio Counter
    ...    ELSE  Run Keyword If  ${rf_status} or ${rf_reset_accept}  Pass Ratio Counter

Pass Ratio Counter
    ${PASS_COUNT}=  Evaluate  ${PASS_COUNT} + 1
    Set Test Variable  ${PASS_COUNT}
