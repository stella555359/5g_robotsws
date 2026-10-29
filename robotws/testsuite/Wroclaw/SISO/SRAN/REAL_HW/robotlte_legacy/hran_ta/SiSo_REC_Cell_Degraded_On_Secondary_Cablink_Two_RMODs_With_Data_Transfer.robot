*** Settings ***
Documentation
...  Test -> SiSo_REC_Cell_Degraded_On_Secondary_Cablink_Two_RMODs_With_Data_Transfer

Resource     resources/ca_recovery.robot
Resource     resources/ca_Recovery_link_break.robot

*** Variables ***
${RMOD_SN}                                            # Tested RMOD s/n
&{CABLINK_1}                                          # Switch ports with connected RMOD Cablinks, dictionary key=value
&{CABLINK_2}                                          # Switch ports with connected RMOD Cablinks, dictionary key=value
${OPT_IP}                                             # 10.42.170.12
${OPT_VENDOR}                                         # Leoni
${OPT_MODEL}                                          # mol 5x(2x6)
@{OPTICAL_PORTS_PASS}    &{CABLINK_1}  &{CABLINK_2}   # list of dictionaries representing tested cablinks

*** Keywords ***
TC__SiSo_REC_Cell_Degraded_On_Secondary_Cablink_Two_RMODs_With_Data_Transfer
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-22715
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check whether data transfer is available on degraded cell or not (LTE and 5G).
    ...  Only cells from selected 'CABLINKS' are tested.
    ...  Link break is performed only on Secondary cablink.
    ...
    ...  Naming covention on Leoni optical switch 'mol 5x(2x6)':
    ...  |---------------------------------------------------------------------|
    ...  |      GROUP 1                 GROUP 2                 GROUP 3	       |
    ...  |  Com  Ch1 Ch2 Ch3        Com  Ch1 Ch2 Ch3        Com  Ch1 Ch2 Ch3   |
    ...  |                                                                     |
    ...  |      GROUP 4                 GROUP 5                                |
    ...  |  Com  Ch1 Ch2 Ch3        Com  Ch1 Ch2 Ch3                           |
    ...  |---------------------------------------------------------------------|
    ...
    ...  Setting 'CABLINK_X' dictionary example:
    ...  &{CABLINK_1}  gr=${1}  ch=${2}  sfp_sn=VF1821003AL
    ...
    ...  Above example means: 'Com' and 'ch2' from 'GROUP1' are responsible for link break, 'sfp_sn' is a serial_num of rmods sfp
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.04.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-22715 - Initial creation

    Set Tags    CA-REC    OWNER-daniel.bartkowiak@nokia.com    AUTHOR-daniel.bartkowiak@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    PHASE-CRT
    ...    FEATURE-CB006581
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_REC_Cell_Degraded_On_Secondary_Cablink_Two_RMODs_With_Data_Transfer will be executed
  ...  style=ONGOING

    Preconditions Secondary Link Break
    step1: Secondary Linkbreak Execution
    step2: Secondary Linkbreak Data Transfer
    step3: Secondary Linkbreak Recovery

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}
    ...  AND  Run Keyword If  "${KEYWORD STATUS}"=="FAIL" and ${SWITCH_CONNECTED}  Recover Secondary Link
    ...  AND  Bring Back BTS To Onair State  connection=${node}
    ...  AND  Common Test Teardown

Preconditions Secondary Link Break
    Log to console  ---------------------------------------
    Log to console  Preconditions Secondary Link Break
    Log to console  ---------------------------------------${\n}
    Set Test Variable  ${node}  ${cfg['RF_INFO']['${RMOD_SN}']['scf_btsid_primary']}
    ${secondary_sfp_sn}  ${TESTED_RMOD}  ${cablink_dn}=  Find Secondary Link, Rmod and Cablink  connection=${node}
    ${CABLINK}=  Select Secondary Cablink For Link Break  ${secondary_sfp_sn}
    Set To Dictionary  ${CABLINK}  blocking_port=${4}
    ${cells_dict}=  Create Cablinks Dictionary With Affected Cells Lists  ${node}
    ${any_cells_in_link}=  Run Keyword And Return Status  Set Test Variable  ${TESTED_CELLS}  ${cells_dict['${cablink_dn}']}
    Run Keyword If  not ${any_cells_in_link}  Run Keywords  Log To Console  Secondary link ${cablink_dn} handles no cells. Please Add cells.
    ...  AND  Fail  Secondary link ${cablink_dn} handles no cells. Please Add cells.
    ${status}  ${msg}=  Run Keyword And Ignore Error  switch.Setup Optical Switch
    ...  optical_switch=${OPT_VENDOR}  model=${OPT_MODEL}  addr=${OPT_IP}  alias=${OPT_VENDOR}
    Run Keyword If  '${status}'=='PASS'  Set Test Variable  ${SWITCH_CONNECTED}  ${TRUE}
    ...  ELSE  Run Keywords  Set Test Variable  ${SWITCH_CONNECTED}  ${FALSE}
    ...  AND  Log   Optical switch setup failed. Check connection parameters and try again. Test failed!  console=${TRUE}
    ...  AND  Fail  Optical switch setup failed. Check connection parameters and try again. Test failed!

    ${gncel_list}=   admin.Get Ids For All    GNCEL    connection=${node}
    ${wncel_list}=   admin.Get Ids For All    WNCEL    connection=${node}
    ${lncel_list}=   admin.Get Ids For All    LNCEL  search_for_iot_cells=${True}  connection=${node}
    ${nrcel_list}=   admin.Get Ids For All    NRCEL    connection=${node}
    ${rmod_list}=    admin.Get Ids For All    RMOD     connection=${node}
    ${smod_list}=    admin.Get Ids For All    SMOD     connection=${node}
    ${bbmod_list}=   admin.Get Ids For All    BBMOD    connection=${node}
    ${BTS_COMPONENTS}=  Combine Lists  ${gncel_list}  ${wncel_list}  ${lncel_list}  ${nrcel_list}
    ...  ${rmod_list}  ${smod_list}  ${bbmod_list}
    Remove Values From List  ${BTS_COMPONENTS}  ${TESTED_RMOD}
    FOR  ${cell}  IN  @{TESTED_CELLS}
      Remove Values From List  ${BTS_COMPONENTS}  ${cell}
    END

    Set Test Variable  ${BTS_COMPONENTS_ONAIR}  ${BTS_COMPONENTS}
    Set Test Variable  ${TESTED_RMOD}
    Set Test Variable  ${TESTED_CELLS}
    Set Test Variable  ${CABLINK}
    Log To Console  Preconditions passed

step1: Secondary Linkbreak Execution
    Log to console  -------------------------------------
    Log to console  step1: Secondary Linkbreak Execution
    Log to console  -------------------------------------${\n}
    Set Channels On Optical Switch For Secondary Link  link_break=true  opt_alias=${OPT_VENDOR}
    ${alarm4003_status}=  Run Keyword And Return Status    admin.Assert Alarm Active  faultId=4003  timeout=180  connection=${node}
    Run Keyword If  not ${alarm4003_status}  Run Keywords  Log  Expected Fault 4003 was not activated!
    ...  AND  Fail  Fault 4003 was not found
    Log  Expected Fault 4003 is visible  console=${TRUE}
    Wait Until Keyword Succeeds  120s  10s  Check If Tested Cells Degraded  ${TESTED_CELLS}  connection=${node}
    Log  Following cells are correctly degraded:${\n}${TESTED_CELLS}  console=${TRUE}

step2: Secondary Linkbreak Data Transfer
    Log to console  ------------------------------------------
    Log to console  step2: Secondary Linkbreak Data Transfer
    Log to console  ------------------------------------------${\n}
    ${specific_cells}=  Prepare Tested Cell Ids  ${TESTED_CELLS}  connection=${node}
    SiSo L3 Call  ${specific_cells}

step3: Secondary Linkbreak Recovery
    Log to console  ------------------------------------
    Log to console  step3: Secondary Linkbreak Recovery
    Log to console  ------------------------------------${\n}
    Set Channels On Optical Switch For Secondary Link  opt_alias=${OPT_VENDOR}
    admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${cfg.test_logs_path}/ims_for_cells_check.ims2  timeout=300  connection=${node}
    Check If BTS Components Were Unchanged  ${cfg.test_logs_path}/ims_for_cells_check.ims2  ${BTS_COMPONENTS_ONAIR}

Set Channels On Optical Switch For Secondary Link
    [Documentation]  KW performs Link break on Leoni switch when 'link_break' is set to 'true', defaul value 'false'
    ...  'link_break=true' ->  'Com' channel is redirected to 'empty' port
    ...  'link_break=false' -> 'Com' channel is redirected to 'ch' port	from ${CABLINK}
    [Arguments]  ${opt_alias}  ${link_break}=false
    ${switch_ports}=  Run Keyword If  '${link_break}'=='true'  Create Dictionary  ${CABLINK['gr']}=${CABLINK['blocking_port']}
    ...  ELSE  Create Dictionary  ${CABLINK['gr']}=${CABLINK['ch']}
    ${status}  ${msg}=  Run Keyword And Ignore Error  switch.Set Optical Switch Channels  ${switch_ports}  ${opt_alias}
    ${opt_inf}=  switch.Get Optical Switch Channels  ${opt_alias}
    Run Keyword If  "${status}"=="FAIL"  Run Keywords
    ...  Log  Error occured while setting optical switch. Check TC variables.${\n}Actual Switch status:${\n}${opt_inf}  console=${TRUE}
    ...  AND  Fail  Error occured while setting optical switch. Check TC variables.${\n}Actual Switch status:${\n}${opt_inf}

Recover Secondary Link
    Set Channels On Optical Switch For Secondary Link  opt_alias=${OPT_VENDOR}
    switch.Teardown  ${OPT_VENDOR}

Find Secondary Link, Rmod and Cablink
    [Arguments]  ${connection}=default
    ${sfps}=  admin.Get Sfp Links  connection=${connection}
    ${bts_inf}=  admin.Get Bts Info  connection=${connection}
    ${cond_1}=  Set Variable  cablink['linkMode']['synchronization']==False
    FOR  ${sfp}  IN  @{sfps['connected']}
      ${is_sn}=  Evaluate
      ...  ['True' for port in ${OPTICAL_PORTS_PASS} if port['sfp_sn']=='${sfp['details']['hardwareParameters']['serialNumber']['source']}']
      ${is_secondary}=  Run Keyword If  'True' in ${is_sn}  Evaluate
      ...  ['True' for cablink in ${bts_inf['cables']} if cablink['id']['internal'] in '${sfp['link']['distName']}' and ${cond_1}]
      ...  ELSE  Create List
      Exit For Loop If  'True' in ${is_secondary}
    END
    Run Keyword If  'True' not in ${is_secondary}  Run Keywords
    ...  Log to Console  Fail, primary link not found. Please check if 'sfp_sn' is declared correctly
    ...  AND  Fail  Secondary link not found. Please check if 'sfp_sn' is declared correctly
    [Return]   ${sfp['details']['hardwareParameters']['serialNumber']['source']}
    ...        ${sfp['parent']['source']['distName']}
    ...        ${sfp['link']['distName']}

Select Secondary Cablink For Link Break
    [Arguments]  ${sn}
    FOR  ${cable}  IN  @{OPTICAL_PORTS_PASS}
      Return From Keyword If  '${cable['sfp_sn']}'=='${sn}'  ${cable}
    END

