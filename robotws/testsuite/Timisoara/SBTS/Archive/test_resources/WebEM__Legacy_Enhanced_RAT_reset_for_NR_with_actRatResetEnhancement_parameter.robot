*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Variables ***
${RECOVERY_TIMEOUT}   1200   #Time for SBTS to recover.

*** Keywords ***
TC__WebEM__Legacy_Enhanced_RAT_reset_for_NR_with_actRatResetEnhancement_parameter
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26168
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  In this test case the operator will check and trigger legacy/enhanced RAT reset for NR with actRatResetEnhancement parameter.
    ...  In step1 the parameter actRatResetEnhancement is set to false and executes legacy RAT reset (RAT hard reset) for NR.
    ...  After Hard Rat Reset all verification are done.The cells affected, BBMODs with NR RAT and RMODs from BBMODs are
    ...  verified. In this case BBMODs of type ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF with NR RAT are affected and they are disabled.
    ...  Also, all cells on NR RAT are affected and they are disabled. LTE cells on RMODs affected are disabled.
    ...  Check that the other components are enabled.
    ...  In step2 the parameter actRatResetEnhancement is set to false and executes RAT reset for NR.
    ...  In this case BBMODs of type ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF with NR RAT are affected and they are disabled.
    ...  Cells affected are disabled, NR cells plus LTE cells on RMODs affected.
    ...  BBMODs of type ABIP|ABIN|ABIL with linkModeConfiguration=True contain RMODs affected.
    ...  Check that the other components are enabled.
    ...  In step3 the parameter actRatResetEnhancement is set to true and executes legacy RAT reset (RAT hard reset) for NR.
    ...  In this case BBMODs of type ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF with NR RAT are affected and they are disabled.
    ...  Cells affected are disabled, NR cells plus LTE cells on RMODs affected.
    ...  Check that the other components are enabled.
    ...  In step4 the parameter actRatResetEnhancement is set to true and executes RAT reset for NR.
    ...  In this case only NR cells are affected and they are disabled.
    ...  Check that the other components are enabled.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26168 - Initial TAT creation
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-WebEM    OWNER-lucian.ivanescu@nokia.com    AUTHOR-cristina.adam@nokia.com
    ...    MAINTAINER-cristina.adam@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS24R2
    ...    FEATURE-CB008880

    Step0: Set parameters
    Step1: Set actRatResetEnhancement to false and perform NR RAT hard reset
    Step2: Set actRatResetEnhancement to false and perform NR RAT reset
    Step3: Set actRatResetEnhancement to true and perform NR RAT hard reset
    Step4: Set actRatResetEnhancement to true and perform NR RAT reset
    Step5: Check alarms on BTS


Step0: Set parameters
    Log  \nStep0: Set parameters  console=true
    Run keyword if  ${SCF_COUNT_NR}
    ...  Log  NR cells exist, test will be continue!  console=true
    ...  ELSE
    ...  Fail  NR cells does not exist!
    ${BTS_ID}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    ${bbmods_nr_rat}  ${BBMODS_AFFECTED}  Get BBMODs with NR RAT
    Set Test Variable  ${BBMODS_AFFECTED}
    ${rmods_on_bbmods}  ${RMODS_AFFECTED}  Get RMODs from BBMODs  ${bbmods_nr_rat}
    Set Test Variable  ${RMODS_AFFECTED}
    Remove Values From List  ${bbmods_nr_rat}  @{BBMODS_AFFECTED}
    Set Test Variable  ${BBMODS_NR_RAT_UNAFFECTED}  ${bbmods_nr_rat}
    ${CELLS_AFFECTED}  Get cells affected  ${rmods_on_bbmods}
    Set Test Variable  ${CELLS_AFFECTED}
    Remove Values From List  ${rmods_on_bbmods}  @{RMODS_AFFECTED}
    Set Test Variable  ${RMODS_UNAFFECTED}  ${rmods_on_bbmods}
    ${cells_on_bts}  Get all cells on bts
    Remove Values From List  ${cells_on_bts}  @{CELLS_AFFECTED}
    Set Test Variable  ${CELLS_UNAFFECTED}  ${cells_on_bts}
    ${BEFORE_ACTIVE_ALARM}  Get Active Alarms from WebEM
    Set Test Variable  ${BEFORE_ACTIVE_ALARM}

Step${index}: Set actRatResetEnhancement to ${value} and perform NR RAT hard reset
    Log  \nStep${index}: Set actRatResetEnhancement to ${value} and perform NR RAT hard reset  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actRatResetEnhancement  operation=update
    ...  value=${value}  skip_parameter_relation_errors=True  timeout=180
    Log  Performing NR Hard Reset.  console=true
    Wait until keyword succeeds  30  5  Click Element
    ...  locator=//*[@id="main-view"]/div/div[1]/div[1]/div/div[2]/cells-delivery/cells-status[1]/div/div[2]/ui-button/button/i
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[1]/div[1]  timeout=30
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button
    ${status}  Run keyword and return status  Wait until keyword succeeds  300s  5s
    ...  Check affected components to be operationalState  ${Disabled_}  ${index}
    Run keyword if  ${status}
    ...  Log  Affected components are ${Disabled_}.  console=true
    ...  ELSE
    ...  Fail  Affected components are no ${Disabled_}.
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20s  ca_SBTS_general.Admin Check All Required State
    Log  \nSBTS is onAir state.  console=true

Step${index}: Set actRatResetEnhancement to ${value} and perform NR RAT reset
    Log  \nStep${index}: Set actRatResetEnhancement to ${value} and perform NR RAT reset  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actRatResetEnhancement  operation=update
    ...  value=${value}  skip_parameter_relation_errors=True  timeout=180
    Log  Performing NR Reset.  console=true
    Wait until keyword succeeds  30  5  Click Element
    ...  locator=//*[@id="main-view"]/div/div[1]/div[1]/div/div[2]/cells-delivery/cells-status[1]/div/div[2]/ui-button/button/i
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[1]/div[1]  timeout=30
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    ${status}  Run keyword and return status  Wait until keyword succeeds  300s  5s
    ...  Check affected components to be operationalState  ${Disabled_}  ${index}
    Run keyword if  ${status}
    ...  Log  Affected components are ${Disabled_}.  console=true
    ...  ELSE
    ...  Fail  Affected components are no ${Disabled_}.
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20s  ca_SBTS_general.Admin Check All Required State
    Log  \nSBTS is onAir state.  console=true

Step5: Check alarms on BTS
    Log  \nStep5: Check alarms on BTS  console=true
    ${after_active_alarm}  Get Active Alarms from WebEM
    Dictionaries Should Be Equal  ${BEFORE_ACTIVE_ALARM}  ${after_active_alarm}  msg=Unexpected faults or alarms are on the SBTS.

Get BBMODs with NR RAT
    ${bbmod_id_list}  Get Ids For All  BBMOD
    ${bbmods_with_NR}  Create list
    ${bbmods_affected}  Create list
    FOR  ${bbmod}  IN  @{bbmod_id_list}
       ${bbmod_parameters}  Get parameters for  BBMOD  ${bbmod}
       ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${bbmod}
       ${status}  Verify if list contains string value  ${cells_on_bbmod}
       Run keyword if  ${status}
       ...  Append to list  ${bbmods_with_NR}  ${bbmod}
       ${status_productName}  Run keyword and return status  Should Match Regexp   ${bbmod_parameters}[productName]  (ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF)
       Run keyword if  ${status} and ${status_productName}
       ...  Append to list  ${bbmods_affected}  ${bbmod}
    END
    [Return]  ${bbmods_with_NR}  ${bbmods_affected}

Get RMODs from BBMODs
    [Arguments]  ${bbmod_list}
    ${rmods}  Create list
    ${rmods_affected}  Create list
    FOR  ${bbmod}  IN  @{bbmod_list}
      ${cablink_list}  query infomodel  get list //CABLINK_R-* is [firstEndpointDN=${bbmod}]
      ${cablink_ports}  ${sync_cublink}  Get RMOD from cablinks  ${cablink_list}
      Append to list  ${rmods}  @{cablink_ports}
      ${bbmod_parameters}  Get parameters for  BBMOD  ${bbmod}
      ${status_productName}  Run keyword and return status  Should Match Regexp   ${bbmod_parameters}[productName]  (ABIP|ABIN|ABIL)
      Run keyword if  ${status_productName}
      ...  Append to list  ${rmods_affected}  @{sync_cublink}
    END
    [Return]  ${rmods}  ${rmods_affected}

Get RMOD from cablinks
    [Arguments]  ${cablink_list}
    ${cablink_ports}  Create list
    ${sync_cablink}  Create list
    FOR  ${cablink}  IN  @{cablink_list}
      Append to list  ${cablink_ports}   ${cablink}[secondEndpointDN]
      ${status_sync}  Run keyword and return status  Should Match Regexp  '${cablink}[linkModeConfiguration]'  (true|True)
      Run keyword if  ${status_sync}
      ...  Append to list  ${sync_cablink}  ${cablink}[secondEndpointDN]
    END
    [Return]  ${cablink_ports}  ${sync_cablink}

Verify if list contains string value
    [Arguments]  ${list}
    FOR  ${item}  IN  @{list}
      ${nr_cell_status}  Run keyword and return status  Should contain  ${item}  NRCELL
      Run keyword if  ${nr_cell_status}
      ...  Return From Keyword  ${TRUE}
    END
    [Return]  ${FALSE}

Get cells affected
    [Arguments]  ${rmods_list}
    ${cells_affected_list}  Create list
    ${NR_CELLS}  Get Ids For All  NRCEL
    Set test variable  ${NR_CELLS}
    Append to list  ${cells_affected_list}  @{NR_CELLS}
    FOR  ${rmod_dn}  IN  @{rmods_list}
      ${cells_on_module_dns}  coam.Get cell mapping by module id  ${rmod_dn}
      ${status}  Run keyword and return status  List Should Contain Value   ${RMODS_AFFECTED}  ${rmod_dn}
      ${lte_cells_affcted}  Run keyword if  ${status}
      ...  Get LTE cells affected from RMOD  ${rmod_dn}
      Run keyword if  ${lte_cells_affcted} != ${None}
      ...  Append to list  ${cells_affected_list}  @{lte_cells_affcted}
    END
    [Return]  ${cells_affected_list}

Check affected components to be operationalState
    [Arguments]  ${operationalState}  ${index}
    ${unaffected_cells}  Run keyword if  ${index}==4
    ...  Get cells unless NR cells
    Run keyword if  ${index}==1 or ${index}==2 or ${index}==3
    ...  Check parameters for the first three steps  ${operationalState}
    ...  ELSE
    ...  Check parameters for fourth step  ${operationalState}  ${unaffected_cells}
    Log  Unaffected cells on bts are enbaled.  console=true
    Check parameters status for list of BBMODs  ${BBMODS_NR_RAT_UNAFFECTED}  operationalState=${Enabled_}
    Log  BBMODs unaffected with NR RAT have operationalState=${Enabled_}.  console=true
    Check RMODs affected to be operationalState  ${RMODS_UNAFFECTED}  ${Enabled_}
    Log  RMODs with NR cells on bts are enbaled.  console=true

Check parameters for the first three steps
    [Arguments]  ${operationalState}
    Check parameters status for cells  ${CELLS_AFFECTED}  operationalState=${operationalState}
    Check parameters status for list of BBMODs  ${BBMODS_AFFECTED}  operationalState=${operationalState}
    Check RMODs affected to be operationalState  ${RMODS_AFFECTED}  ${operationalState}
    Log  Cells affected, BBMODs affected and RMODs affected are disabled.  console=true
    Check parameters status for cells  ${CELLS_UNAFFECTED}  operationalState=${Enabled_}

Check parameters for fourth step
    [Arguments]  ${operationalState}  ${unaffected_cells}
    Check parameters status for cells  ${NR_CELLS}  operationalState=${operationalState}
    Check parameters status for list of BBMODs  ${BBMODS_AFFECTED}  operationalState=${Enabled_}
    Check RMODs affected to be operationalState  ${RMODS_AFFECTED}  ${Enabled_}
    Log  NR cells are disabled, BBMODs affected and RMODs affected are enabled.  console=true
    Check parameters status for cells  ${unaffected_cells}  operationalState=${Enabled_}

Check RMODs affected to be operationalState
    [Arguments]    ${rmods_list}  ${operationalState}
    FOR  ${rmod_dn}  IN  @{rmods_list}
      Assert  RMOD  ${rmod_dn}  parameters=operationalState=${operationalState}
    END

Get LTE cells affected from RMOD
    [Arguments]  ${rmod_dn}
    ${lte_cells_affcted}  Create list
    ${cells_on_module_dns}  coam.Get cell mapping by module id  ${rmod_dn}
    FOR  ${cell}  IN  @{cells_on_module_dns}
      ${cell_status}  Run keyword and return status  Should contain  ${cell}  LNCEL
      Run keyword if  ${cell_status}
      ...  Append to list  ${lte_cells_affcted}  ${cell}
    END
    [Return]  ${lte_cells_affcted}

Get cells unless NR cells
    ${all_cells}  Get all cells on bts
    Remove Values From List  ${all_cells}  @{NR_CELLS}
    [Return]  ${all_cells}

Get all cells on bts
    ${list_all_rat}  Create list  NRCEL  LNCEL  WNCEL  GNCEL
    ${cells_list}  Create list
    FOR  ${cell_class_name}  IN  @{list_all_rat}
      ${cell_on_rat}   Get ids for all  ${cell_class_name}
      Append to list  ${cells_list}  @{cell_on_rat}
    END
    [Return]  ${cells_list}

TC Setup
    Common Test Setup  tc_name=WebEM__Legacy_Enhanced_RAT_reset_for_NR
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common Test Teardown
