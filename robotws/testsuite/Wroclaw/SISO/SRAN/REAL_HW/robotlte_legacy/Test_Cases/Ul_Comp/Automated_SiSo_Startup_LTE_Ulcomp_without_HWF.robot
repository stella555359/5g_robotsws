*** Settings ***
Documentation
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak


Library     taf.sbts.oam.coam.admin  WITH NAME  admin

Resource    ./Ul_Comp_common.robot
*** Variables ***
${SINGLE_NODE}    ${False}    #set in robot suite to TRUE in order to test only 1 node on testline. Need to add additional
# variable  eg.  ${SINGLE_NODE_NUMBER}    1404
*** Keywords ***
Startup Ul Comp Without HWF
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The test case checks the startup without HWF on a BTS with UL CoMP activated.
    ...  Such test case simulates a situation when a Customer executed a SW update between branches  e. g. from branch N to N+2.
    ...  
    ...  UL CoMP (either Fixed, Flexible or Basic) needs to be configured on the BTS prior running the test.
    ...  Epic:  https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-33921
    ...
    ...  History of change
    ...  *****************
    ...   27.02.2024 - Initial creation
  Common Test Setup
  Logging With Timestamp
  ...  message=Startup Ul Comp Without HWF
  ...  style=ONGOING
  Set Tags
  ...    OWNER-szymon.przybylak@nokia.com
  ...    AUTHOR-szymon.przybylak@nokia.com
  ...    MAINTAINER-szymon.przybylak@nokia.com
  Startup Ul Comp Without HWF All Steps
  [Teardown]  Run Keywords
  ...  Restore Mandatory Flags
  ...  AND  Common Test Teardown


Startup Ul Comp Without HWF All Steps
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        Precondition UlComp  node=${node}
    END
    FOR  ${node}  IN  @{cfg.active_bts_list}
        Run Keyword If    ${SINGLE_NODE}    Continue For Loop If    '${node}'!='${SINGLE_NODE_NUMBER}'
        step1: Remove HWF File
        step2: Perform Site Reset    node=${node}
    END

step1: Remove HWF File
    Log To Console  ${\n}=== Step 1: Remove HWF File  console=True
    Append To List    ${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}   0x4F0214=0x0
    Compare And Upload Swconfig
    Set Test Variable   @{CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}     @{EMPTY}

step2: Perform Site Reset
  [Arguments]    ${node}
  Set Test Variable    ${flag_visible}    ${False}
  Log To Console  ${\n}=== Step 2: Perform Site Reset  console=True
  FOR  ${bts}  IN  @{cfg.active_bts_list}
    Execute Reset On Node  ${bts}
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
    Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
    Verify Unexpected And Historical Alarms  alias=${bts}
  END
  ${RD_flags}=    Get Bts Rad Parameters    parameters_type=Applied    timeout=90    connection=${node}
  FOR    ${item}    IN    @{RD_flags}
      ${dict_values_list}=    Get Dictionary Values    ${item}
      Log    ${dict_values_list}
      Run Keyword If    '${dict_values_list[0]}'=='0x4f0214' and '${dict_values_list[1]}'=='0x0'
      ...    Run Keywords   Set Test Variable    ${flag_visible}    ${True}
      ...    AND    Exit For Loop
  END
  Run Keyword If  not ${flag_visible}    Fail    msg=HWF was not removed from BTS. Flag 0x4F0214 was not 0.
  Log To Console     ${\n}=========== Remove HWF file flag present ==============

Restore Mandatory Flags
    Log To console     ${\n}Restoring Mandatory Flags    console=True
    Compare And Upload Swconfig
    FOR  ${bts}  IN  @{cfg.active_bts_list}
      Execute Reset On Node  ${bts}
      CM BTS Admin Not Available
      ...  node=${bts}
      ...  timeout=120
      Verify BTS State  ${bts}  ${CONFIGURATION_STARTUP_TIMEOUT}
      Verify Unexpected And Historical Alarms  alias=${bts}
    END

