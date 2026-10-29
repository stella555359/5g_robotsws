*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Variables ***
${RECOVERY_TIMEOUT}   1200   #Time for SBTS to recover.

*** Keywords ***
TC__WebEM__Legacy_Enhanced_RAT_reset_for_LTE_with_actRatResetEnhancement_parameter
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26167
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  In this test case the operator will check and trigger legacy/enhanced RAT reset for LTE with actRatResetEnhancement parameter.
    ...  In step1 the parameter actRatResetEnhancement is set to false and executes legacy RAT reset (RAT hard reset) for LTE.
    ...  After Hard Rat Reset all verifications are done.The cells affected, BBMODs with LTE RAT and RMODs from BBMODs are
    ...  verified. In this case BBMODs of type ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF with LTE RAT are affected and they are disabled.
    ...  If NR cells are NSA (not stand alone), then they are affected. In every step they are verified to be disabled.
    ...  Also, all cells on LTE RAT are affected and they are disabled.
    ...  Check that the other components are enabled.
    ...  In step2 the parameter actRatResetEnhancement is set to false and executes RAT reset for LTE.
    ...  In this case BBMODs of type ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF with LTE RAT are affected and they are disabled.
    ...  Cells affected are disabled, LTE cells plus NR (NSA) cells.
    ...  Check that the other components are enabled.
    ...  In step3 the parameter actRatResetEnhancement is set to true and legacy RAT reset (RAT hard reset) for LTE is executed.
    ...  In this case BBMODs of type ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF with LTE RAT are affected and they are disabled.
    ...  Cells affected are disabled, LTE cells plus NR (NSA) cells.
    ...  Check that the other components are enabled.
    ...  In step4 the parameter actRatResetEnhancement is set to true and executes RAT reset for LTE.
    ...  In this case only cells are affected and they are disabled, LTE cells plus NR(NSA) cells.
    ...  Check that the other components are enabled.
    ...  The parameter actRatResetEnhancement is set to false.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26167 - Initial TAT creation

    Set Tags    CA-WebEM    OWNER-lucian.ivanescu@nokia.com    AUTHOR-cristina.adam@nokia.com
    ...    MAINTAINER-cristina.adam@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS24R2
    ...    FEATURE-CB008880

    Step0: Set parameters
    Step1: Set actRatResetEnhancement to false and perform LTE RAT hard reset
    Step2: Set actRatResetEnhancement to false and perform LTE RAT reset
    Step3: Set actRatResetEnhancement to true and perform LTE RAT hard reset
    Step4: Set actRatResetEnhancement to true and perform LTE RAT reset
    Step5: Check unexpected alarms on BTS

Step0: Set parameters
    Log  \nStep0: Set parameters  console=true
    ${BTS_ID}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    ${bbmods_lte_rat}  ${BBMODS_AFFECTED}  Get BBMODs with LTE RAT
    Set Test Variable  ${BBMODS_AFFECTED}
    ${rmods_on_bbmods}  ${RMODS_AFFECTED}  Get RMODs from BBMODs  ${bbmods_lte_rat}
    Set Test Variable  ${RMODS_AFFECTED}
    ${CELLS_AFFECTED}  Get cells affected
    Set Test Variable  ${CELLS_AFFECTED}
    Remove Values From List  ${bbmods_lte_rat}  @{BBMODS_AFFECTED}
    Set Test Variable  ${BBMODS_LTE_RAT_UNAFFECTED}  ${bbmods_lte_rat}
    Remove Values From List  ${rmods_on_bbmods}  @{RMODS_AFFECTED}
    Set Test Variable  ${RMODS_UNAFFECTED}  ${rmods_on_bbmods}
    ${BEFORE_ACTIVE_ALARM}  Get Active Alarms from WebEM
    Set Test Variable  ${BEFORE_ACTIVE_ALARM}

Step${index}: Set actRatResetEnhancement to ${value} and perform LTE RAT hard reset
    Log  \nStep${index}: Set actRatResetEnhancement to ${value} and perform LTE RAT hard reset  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actRatResetEnhancement  operation=update
    ...  value=${value}  skip_parameter_relation_errors=True  timeout=180
    Log  Performing LTE Hard Reset.  console=true
    Wait until keyword succeeds  30  5  Click Element
    ...  locator=//*[@id="main-view"]/div/div[1]/div[1]/div/div[2]/cells-delivery/cells-status[2]/div/div[2]/ui-button/button/i
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

Step${index}: Set actRatResetEnhancement to ${value} and perform LTE RAT reset
    Log  \nStep${index}: Set actRatResetEnhancement to ${value} and perform LTE RAT reset  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actRatResetEnhancement  operation=update
    ...  value=${value}  skip_parameter_relation_errors=True  timeout=180
    Log  Performing LTE Reset.  console=true
    Wait until keyword succeeds  30  5  Click Element
    ...  locator=//*[@id="main-view"]/div/div[1]/div[1]/div/div[2]/cells-delivery/cells-status[2]/div/div[2]/ui-button/button/i
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

Step5: Check unexpected alarms on BTS
    Log  \nStep5: Check unexpected alarms on BTS  console=true
    ${after_active_alarm}  Get Active Alarms from WebEM
    Dictionaries Should Be Equal  ${BEFORE_ACTIVE_ALARM}  ${after_active_alarm}  msg=Unexpected faults or alarms are on the SBTS.

Get BBMODs with LTE RAT
    ${bbmod_id_list}  Get Ids For All  BBMOD
    ${bbmods_with_LTE}  Create list
    ${bbmods_affected}  Create list
    FOR  ${bbmod}  IN  @{bbmod_id_list}
       ${bbmod_parameters}  Get parameters for  BBMOD  ${bbmod}
       ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${bbmod}
       ${status}  Verify if list contains string value  ${cells_on_bbmod}
       Run keyword if  ${status}
       ...  Append to list  ${bbmods_with_LTE}  ${bbmod}
       ${status_productName}  Run keyword and return status  Should Match Regexp   ${bbmod_parameters}[productName]  (ABIO|ABIP|ABIQ|ABIN|ASOE|ASOF)
       Run keyword if  ${status} and ${status_productName}
       ...  Append to list  ${bbmods_affected}  ${bbmod}
    END
    ${status}  Run keyword and return status  Should not be empty  ${bbmods_with_LTE}
    Run keyword unless  ${status}
    ...  Log  There is no LTE RAT.  console=true
    [Return]  ${bbmods_with_LTE}  ${bbmods_affected}

Get RMODs from BBMODs
    [Arguments]  ${bbmod_list}
    ${rmods}  Create list
    ${rmods_affected}  Create list
    FOR  ${bbmod}  IN  @{bbmod_list}
      ${cablink_list}  query infomodel  get list //CABLINK_R-* is [firstEndpointDN=${bbmod}]
      ${cablink_ports}  Get RMOD from cablinks  ${cablink_list}
      Append to list  ${rmods}  @{cablink_ports}
      ${bbmod_parameters}  Get parameters for  BBMOD  ${bbmod}
      ${status_productName}  Run keyword and return status  Should Match Regexp   ${bbmod_parameters}[productName]  (ABIP|ABIN|ABIL)
      Run keyword if  ${status_productName}
      ...  Append to list  ${rmods_affected}  @{cablink_ports}
    END
    [Return]  ${rmods}  ${rmods_affected}

Get RMOD from cablinks
    [Arguments]  ${cablink_list}
    ${cablink_ports}  create list
    FOR  ${cablink}  IN  @{cablink_list}
      Append to list  ${cablink_ports}   ${cablink}[secondEndpointDN]
    END
    [Return]  ${cablink_ports}

Verify if list contains string value
    [Arguments]  ${list}
    FOR  ${item}  IN  @{list}
      ${lte_cell_status}  Run keyword and return status  Should contain  ${item}  LNCEL
      Run keyword if  ${lte_cell_status}
      ...  Return From Keyword  ${TRUE}
    END
    [Return]  ${FALSE}

Get cells affected
    ${lte_cells}  Get Ids For All  LNCEL
    ${status}  Run keyword and return status  Element Should Be Visible  //div[contains(@title, 'NG link status: inactive')]
    ${status_amf}  Run keyword and return status  Element Should Not Be Visible  locator=//div[@class="block-headers" and contains(@title, "AMF 1")]
    ${nr_cells}  Run keyword if  ${status} or ${status_amf}
    ...  Get Ids For All  NRCEL
    ...  ELSE
    ...  Create list
    ${cells_affected_list}  Combine Lists  ${lte_cells}  ${nr_cells}
    [Return]  ${cells_affected_list}

Check affected components to be operationalState
    [Arguments]  ${operationalState}  ${index}
    Check parameters status for cells  ${CELLS_AFFECTED}  operationalState=${operationalState}
    Log  Affected cells ${CELLS_AFFECTED} are ${operationalState}.  console=true
    Run keyword if  ${index}==1 or ${index}==2 or ${index}==3  Run keywords
    ...  Check parameters status for list of BBMODs  ${BBMODS_AFFECTED}  operationalState=${operationalState}
    ...  AND  Log  Affected BBMODs ${BBMODS_AFFECTED} are ${operationalState}.  console=true
    ...  ELSE  Run keywords
    ...  Check parameters status for list of BBMODs  ${BBMODS_AFFECTED}  operationalState=${Enabled_}
    ...  AND  Log  Affected BBMODs ${BBMODS_AFFECTED} are ${Enabled_}.  console=true
    Check parameters status for list of BBMODs  ${BBMODS_LTE_RAT_UNAFFECTED}  operationalState=${Enabled_}
    Log  BBMODs unaffected with LTE RAT have operationalState=${Enabled_}.  console=true
    Run keyword if  ${index}==4
    ...  Check RMODs affected to be operationalState  ${RMODS_AFFECTED}  ${Enabled_}
    ...  ELSE
    ...  Check RMODs affected to be operationalState  ${RMODS_AFFECTED}  ${Disabled_}
    Check RMODs affected to be operationalState  ${RMODS_UNAFFECTED}  ${Enabled_}

Check RMODs affected to be operationalState
    [Arguments]    ${rmods_list}  ${operationalState}
    FOR  ${rmod_dn}  IN  @{rmods_list}
      Assert  RMOD  ${rmod_dn}  parameters=operationalState=${operationalState}
    END
    Log  Rmods with LTE cells have operationalState=${operationalState}.  console=true

TC Setup
    Common Test Setup
    WebEM Setup

TC Teardown
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actRatResetEnhancement  operation=update
    ...  value=false  skip_parameter_relation_errors=True  timeout=180
    WebEM Teardown
    Common Test Teardown
