*** Settings ***
Documentation    TC__NRL__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset
Variables    tc_variables/nrl__cm__re-comissioning_nr_change_of_parameter_not_implying_reset.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                              # Number of NR Re-Commissioning operations, default value 3
${BTS_NAME_LIST}  BTS_NAME_AUTO1, BTS_NAME_AUTO2  # List of selectable btsName parameter values to be commissioned
                                                  # separated by comma. By default: BTS_NAME_AUTO1, BTS_NAME_AUTO2
${NR_SCF_VALIDATION}           True   # Validate NR SCF; can be True or False

*** Keywords ***
TC__NRL__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21558
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for Re-Comissioning_NR_change_of_parameter_not_implying_reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - get initial value of btsName
    ...  - Perform Parameter Recommissioning by changing value of btsName
    ...  - get final RESET info from blackbox file
    ...  - check NR and LTE reset behavior: reset number is 0
    ...  - return btsName to its initial value by another recommissioning
    ...  - check final NR and LTE state and alarms
    ...  Pass criteria: recommissiong operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21558 -
    ...  [5G][MT] New NRL scenario NRL_Recomissioning_NR_parameter_change_without_implying_reset
    ...  - 17.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24698 - [5G][Reset Number ims2] Update NRL CM ... scenarios to take reset
    ...  number from ims2 - P2
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 18.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27664 -
    ...  [5G] [SCF check] - P0 - NRL- Include SCF validation with hardware check in CM Tests
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21558_NRL__CM__Re-Comissioning_NR_change_of_parameter_not_implying_reset.png
    ...

    Set Tags    CA-CM    OWNER-mihai-silviu.dumbrava@nokia.com    AUTHOR-mihai-silviu.dumbrava@nokia.com    PHASE-QT    SW-22R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get initial NR btsName
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Get initial date UTC info
        Step 5: Perform NR BTS Commissioning to change btsName
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Get final date UTC info
        Step 9: Check NR and LTE reset behavior based on IMS info
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get initial NR btsName
    [Documentation]
    ...  Get initial btsName

    Log  Step ${index}: Get initial btsName   console=True

    ${btsName}=  Get btsName from SCF  Master
    Set Test Variable  ${btsName_initial}  ${btsName}
    Log  Initial NR BTS btsName: ${btsName_initial}  console=True
    Log  btsName selection list for NR BTS Commissioning: ${BTS_NAME_LIST}  console=True
    ${BTSNAME_LIST_strip}=  Strip String  ${BTS_NAME_LIST}
    ${BTSNAME_LIST}=  Split String  ${BTSNAME_LIST_strip}  ,${SPACE}
    Set Test Variable  ${BTSNAME_LIST}

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: Perform NR BTS Commissioning to change btsName
    [Documentation]
    ...  Perform NR BTS Commissioning to change btsName

    Log  Step ${index}: Perform NR BTS Commissioning to change btsName  console=True
    ${btsName_before}=  Get btsName from SCF  Master
    FOR   ${item}  IN  @{BTSNAME_LIST}
        Run Keyword If  '${item}' != '${btsName_before}'  Run Keywords
        ...  Set Test Variable  ${btsName_change}  ${item}
        ...  AND  Exit For Loop
    END
    Log  Selected NR BTS btsName for NR BTS Commissioning: ${btsName_change}  console=True

    NR BTS Commissioning for btsName change  ${btsName_change}

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    [Timeout]  10 min
    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False

Get btsName from SCF
    [Documentation]
    ...  Get btsName from SCF

    [Arguments]  ${alias}
    ${bts_eq}=  coam.Get Parameters For all  BTS  ${alias}
    ${btsName}=  Set Variable  ${bts_eq[0].btsName}
    [Return]  ${btsName}

NR BTS Commissioning for btsName change
    [Arguments]   ${btsName_value}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=Master
    ${scf_file_parsed}=  Parse xml  ${BTS_scf}
    ${MO_items}=  Get Element Attributes  ${scf_file_parsed}  .//managedObject[@class="com.nokia.srbts:MRBTS"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Set Test Variable  ${SCF_dn}

    Log  Perform NR BTS Commissioning  console=True
    coam.Perform Parameter Recommissioning  dist_name=${SCF_dn}  parameter=btsName  operation=update  value=${btsName_value}
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=Master
    Sleep  30s

    ${btsName_after}=  Get btsName from SCF  Master
    Log  NR BTS btsName after NR BTS Commissioning: ${btsName_after}  console=True
    Run Keyword If  '${btsName_after}' == '${btsName_value}'
    ...  Log  NR BTS Commissioning successfuly performed  console=True
    ...  ELSE  Run Keywords
    ...  Log  NR BTS Commissioning failed  level=ERROR
    ...  AND  Fail  NR BTS Commissioning failed

    Run Keyword If  ${NR_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=Master

Recover initial btsName
    ${btsName_final}=  Get btsName from SCF  Master
    Run Keyword If  '${btsName_final}' == '${btsName_initial}'
    ...  Log  NR BTS btsName: ${btsName_initial}, no recover action needed  console=True
    ...  ELSE  Run Keywords
    ...  NR BTS Commissioning for btsName change  ${btsName_initial}
    ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  Master

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial btsName
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown