*** Settings ***
Documentation    TC__SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
Variables   tc_variables/sbts__cm__re-commissioning_of_parameter_not_implying_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                                             # Number of BTS Re-Commissioning operations, default value 3
${BTS_NAME_LIST}  BTS_NAME_AUTO1, BTS_NAME_AUTO2                 # List of selectable btsName parameter values to be commissioned
                                                                 # separated by comma. By default: BTS_NAME_AUTO1, BTS_NAME_AUTO2
${BTS_SCF_VALIDATION}     True     # Validate SCF; can be True or False
*** Keywords ***
TC__SBTS__CM__Re-Commissioning_of_parameter_not_implying_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21393
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for Recomissioning parameter not implying reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get and display value of parameter bbpoolAllocMode
    ...  - get initial value of btsName
    ...  - Perform Parameter Recommissioning by changing value of btsName
    ...  - check BTS reset behavior based on IMS info: reset number is 0
    ...  - return btsName to its initial value by another recommissioning
    ...  - check final BTS state and alarms
    ...  Pass criteria: recommissiong operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21393 -
    ...  [5G][RFSplit][CB006051] RFS_SBTS_LTE_LTE_Commissioning_Recommissioning_Split_RF_with parameter which doesn't require reset - TC delivery
    ...  - 23.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22650 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - SBTS part
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24842 - [5G][Reset Number ims2] Update SBTS CM ... scenarios to take reset
    ...  number from ims2 - P2
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27410 - [5G] [Infomodel] - P1 - Eliminate usage of KW Infomodel "Get baseband
    ...  pool allocation mode info" in test-cases - after TAT-27401
    ...  - 21.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27665 -
    ...  [5G] [SCF check] - P1 - SBTS - Include SCF validation with hardware check in CM Tests
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image::
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21393_SBTS_Recomissioning_Change_Of_Parameter_Not_Implying_Reset.png

    Set Tags    CA-CM    OWNER-adrian.ierulescu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS22R1

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get initial baseband pool allocation mode info
    Step 4: Get initial btsName
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Get initial date UTC info
        Step 6: Perform BTS Commissioning to change btsName
        Step 7: Check final BTS state
        Step 8: Check final BTS alarms
        Step 9: Get final date UTC info
        Step 10: Check BTS reset behavior based on IMS info
        Step 11: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS alarms  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get initial baseband pool allocation mode info
    [Documentation]
    ...  Get initial baseband pool allocation mode info

    Log  Step ${index}: Get initial baseband pool allocation mode info   console=True
    Get baseband pool allocation mode info from SCF  alias=${alias_local}

Step ${index}: Get initial btsName
    [Documentation]
    ...  Get initial btsName

    Log  Step ${index}: Get initial btsName   console=True

    ${btsName}=  Get btsName from SCF
    Set Test Variable  ${btsName_initial}  ${btsName}
    Log  Initial BTS btsName: ${btsName_initial}  console=True
    Log  btsName selection list for BTS Commissioning: ${BTS_NAME_LIST}  console=True
    ${BTSNAME_LIST_strip}=  Strip String  ${BTS_NAME_LIST}
    ${BTSNAME_LIST_strip}=  Evaluate  '${BTSNAME_LIST_strip}'.replace(', ',',')
    ${BTSNAME_LIST}=  Split String  ${BTSNAME_LIST_strip}  ,
    Set Test Variable  ${BTSNAME_LIST}

Step ${index}: Perform BTS Commissioning to change btsName
    [Documentation]
    ...  Perform BTS Commissioning to change btsName

    Log  Step ${index}: Perform BTS Commissioning to change btsName  console=True
    ${btsName_before}=  Get btsName from SCF
    FOR   ${item}  IN  @{BTSNAME_LIST}
        Run Keyword If  '${item}' != '${btsName_before}'  Run Keywords
        ...  Set Test Variable  ${btsName_change}  ${item}
        ...  AND  Exit For Loop
    END
    Log  Selected BTS btsName for BTS Commissioning: ${btsName_change}  console=True

    BTS Commissioning for btsName change  ${btsName_change}

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info.
    ...  Reset behavior as expected if: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}  remove_ims_file=False

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

BTS Commissioning for btsName change
    [Arguments]   ${btsName_value}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}
    ${scf_file_parsed}=  Parse xml  ${BTS_scf}
    ${MO_items}=  Get Element Attributes  ${scf_file_parsed}  .//managedObject[@class="com.nokia.srbts:MRBTS"]
    ${SCF_dn}=  Set Variable  ${MO_items['distName']}
    Set Test Variable  ${SCF_dn}

    Log  Perform BTS Commissioning  console=True
    coam.Perform Parameter Recommissioning  dist_name=${SCF_dn}  parameter=btsName  operation=update  value=${btsName_value}
    ...  skip_parameter_relation_errors=True  should_activate=True  alias=${alias_local}
    Sleep  30s

    ${btsName_after}=  Get btsName from SCF
    Log  BTS btsName after BTS Commissioning: ${btsName_after}  console=True
    Run Keyword If  '${btsName_after}' == '${btsName_value}'
    ...  Log  BTS Commissioning successfuly performed  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS Commissioning failed  level=ERROR
    ...  AND  Fail  BTS Commissioning failed

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias_local}

Get btsName from SCF
    [Documentation]
    ...  Get btsNmae from SCF

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias_local}
    ${scf_file_parsed}=  Parse xml  ${BTS_scf}
    ${MO}=  Set Variable  .//managedObject[@class="com.nokia.srbts:MRBTS"]/p[@name="btsName"]
    ${btsName}=  Get Element Text  ${scf_file_parsed}  ${MO}
    [Return]  ${btsName}

Recover initial btsName
    ${btsName_final}=  Get btsName from SCF
    Run Keyword If  '${btsName_final}' == '${btsName_initial}'
    ...  Log  BTS btsName: ${btsName_initial}, no recover action needed  console=True
    ...  ELSE  Run Keywords
    ...  BTS Commissioning for btsName change  ${btsName_initial}
    ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial btsName

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
