*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im


*** Variables ***
${RU_crash_cmd}  kill -9
${recovery_count}  4


*** Keywords ***
Radio List Recovery Reset Counter Exceeded Cleared
  FOR  ${rf}  IN  @{CUSTOM_RADIO_UNIT_LIST}
    Execute Recovery Reset Counter Exceeded Cleared  ${rf}
  END

Execute Recovery Reset Counter Exceeded Cleared
  [Arguments]  ${rf}
  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${rf}
  ${rf_variant}=  Get From Dictionary  ${cfg.RF_INFO['${rf}']}  scf_variant
  ${prompt}=  Get From Dictionary  ${RF_PROMPT}  ${rf_variant}
  Add Allowed Alarms To Test  ${ru_bts_id}
  Reset Counter To Zero By Site Reset  ${rf}  ${ru_bts_id}
  FOR  ${iteration}  IN RANGE  ${recovery_count}
    Verify BTS State  ${ru_bts_id}
    Run Keyword And Continue On Failure  Generate Recovery Counter Increase
    ...  rf=${rf}
    ...  node=${ru_bts_id}
    ...  prompt=${prompt}
#  ${rf_counter_vaule}=  Read Recovery Counter From Radio  ${rf}  ${ru_bts_id}
    Run Keyword If
    ...  ${iteration+1} < ${recovery_count}
    ...  Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active
    ...  faultId=regex"1815|10"
    ...  timeout=120
    ...  alias=${ru_bts_id}
    ...  ELSE
    ...  Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active
    ...  faultId=1981, severity=Warning
    ...  alias=${ru_bts_id}
    Check IF RU Unit Was Reseted  ${ru_dist_name}  ${ru_bts_id}
#  sleep  60
    Verify BTS State  ${ru_bts_id}
    ${rf_counter_vaule}=  Read Recovery Counter From Radio
    ...  rf=${rf}
    ...  node=${ru_bts_id}
    ...  prompt=${prompt}
    Log  RF recovery counter value after RF error= ${rf_counter_vaule}
    Run Keyword If  ${iteration+1} < ${recovery_count}
    ...  Run Keyword And Continue On Failure  Should Be Equal  ${rf_counter_vaule}  ${iteration+1}
  END
  Verify BTS State  ${ru_bts_id}
  ${rf_counter_vaule}=  Read Recovery Counter From Radio
  ...  rf=${rf}
  ...  node=${ru_bts_id}
  ...  prompt=${prompt}
  Log  RF recovery counter value after RF Recovery= ${rf_counter_vaule}
  Run Keyword And Continue On Failure  Should Be Equal  ${rf_counter_vaule}  ${0}
  Run Keyword And Continue On Failure  admin.Assert No Unexpected Active Alarms  alias=${ru_bts_id}
  Run Keyword And Continue On Failure  admin.Assert No Unexpected Historical Alarms  alias=${ru_bts_id}

Check IF RU Unit Was Reseted
  [Arguments]  ${ru_dist_name}  ${ru_bts_id}
  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=RMOD
  ...  id=${ru_dist_name}
  ...  parameters=operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line|not\\s?installed"
  ...  timeout=20
  ...  connection=${ru_bts_id}

  Run Keyword And Continue On Failure
  ...  admin.Assert
  ...  class_name=RMOD
  ...  id=${ru_dist_name}
  ...  parameters=operationalState=regex"(?i)Enabled"
  ...  timeout=360
  ...  connection=${ru_bts_id}

Add Allowed Alarms To Test
  [Arguments]  ${ru_bts_id}
  Add Allowed Alarm  faultId=10  alias=${ru_bts_id}
  Add Allowed Alarm  faultId=4592, severity=Warning  alias=${ru_bts_id}
  Add Allowed Alarm  faultId=6351, severity=Warning  alias=${ru_bts_id}
  Add Allowed Alarm  faultId=1981, severity=Warning  alias=${ru_bts_id}
  Add Allowed Alarm  faultId=1815  alias=${ru_bts_id}

Reset Counter To Zero By Site Reset
  [Arguments]  ${rf}  ${ru_bts_id}
  Execute Reset On Node  ${ru_bts_id}
  Verify BTS State  ${ru_bts_id}
  ${rf_counter_vaule}=  Read Recovery Counter From Radio  ${rf}  ${ru_bts_id}
  Run Keyword And Continue On Failure  Should Be Equal  ${rf_counter_vaule}  ${0}
  Log  RF recovery counter value after Site Reset = ${rf_counter_vaule}

Generate Recovery Counter Increase
  [Arguments]  ${rf}  ${node}  ${prompt}=~#
  Open Connection To Radio Module With Serial Number
  ...  rmod_serial_number=${rf}
  ...  alias=${node}
  ${active_processes}=  Send Command and return output
  ...  command=ps
  ...  prompt=${prompt}
  ${active_processes}=  Split To Lines  ${active_processes}
  FOR  ${line}  IN  @{active_processes}
    ${status}  ${match_line}=  Run Keyword And Ignore Error
    ...  Should Match Regexp  ${line}  assam::instance
    ${final_match_line}=  Set Variable If  '${status}'!='FAIL'  ${line}
    Exit For Loop If  '${status}'!='FAIL'
  END
  ${final_match_line}=  Split String
  ...  string=${final_match_line}
  ...  separator=${SPACE}
  ${active_processes}=  Send Command and return output
  ...  command=${RU_crash_cmd} '${final_match_line}[1]'
  [Teardown]  Close SSH Connection

Remove Known Host File
  [Arguments]  ${bts_id}
  Setup Enb Fsm Access  remote_host=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
  Wait For Host Ssh  host=192.168.255.1  timeout=240  remote_host=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
  Run Keyword And Ignore Error  execute_command_on_enb  cmd=rm /user/toor4nsn/.ssh/known_hosts

  [Teardown]  Teardown Enb Fsm Access

Read Recovery Counter From Radio
  [Arguments]  ${rf}  ${node}  ${prompt}=~#
  Run Keyword And Ignore Error  Remove Known Host File  ${node}
  Open Connection To Radio Module With Serial Number
  ...  rmod_serial_number=${rf}
  ...  alias=${node}
  ${rf_counter_vaule}=  Send Command and return output
  ...  command=pssreboot -r r
  ...  prompt=${prompt}
  ${rf_counter_vaule}=  Get Line  ${rf_counter_vaule}  0
  ${rf_counter_vaule}=  Convert To Integer  ${rf_counter_vaule}
  [Teardown]  Close SSH Connection
  [Return]  ${rf_counter_vaule}
