*** Settings ***
Documentation    TC__SBTS__CM__BBMOD_reconfiguration
Variables    tc_variables/sbts__cm__bbmod_reconfiguration_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                   3  # Number of BBMOD reconfiguration operations, default value 3
${BBMOD_SN_list}                       # List of BBMOD serial number used for BBMOD reconfiguration; values are separated by comma
${BBMOD_bbmodBoardConfigType_list}     # List of values for BBMOD parameter bbmodBoardConfigType used for reconfiguration; each bbmodConfigType value
                                       # from this list is for the corresponding BBMOD SN from ${BBMOD_SN_list}; values are separated by comma

*** Keywords ***
TC__SBTS__CM__BBMOD_reconfiguration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22109
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for BBMOD reconfiguration implying parameter bbmodBoardConfigType commissioning, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check BBMOD serial number availability corelated with ABIO type
    ...  - check initial BTS state and alarms
    ...  - perform BBMOD reconfiguration implying parameter bbmodBoardConfigType commissioning
    ...  - check BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 0
    ...  - perform BTS commissioning to recover initial configuration
    ...  Pass criteria: BTS Commissioning successfully, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22109 - [5G][RFSPLIT] RFS_BTS__STATE__SBTS_ABIO_reconfiguration
    ...  - 23.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22650 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - SBTS part
    ...  - 24.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22599 -
    ...  [5G][CNI-64298] Impact in specific SBTS, LL TCs and hran_infomodel, rfs_frame_rfs_common
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24842 -
    ...  [5G][Reset Number ims2] Update SBTS CM scenarios to take reset number from ims2 - P2
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22109_SBTS__CM__BBMOD_reconfiguration.png

    Set Tags    CA-CM    OWNER-cristinel.sava@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R1

    TC parameter check
    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Get initial date UTC info
        Step 4: Perform BBMOD reconfiguration
        Step 5: Check final BTS state
        Step 6: Check final BTS alarms
        Step 7: Get final date UTC info
        Step 8: Check BTS reset behavior based on IMS info
        Step 9: Check final number and state of Cells and RMs
        Step 10: Perform BTS commissioning
    END

    [Teardown]  Particular Teardown

TC parameter check
    [Documentation]
    ...  KW used to check rightness of test argument info

    Log  TC parameter check  console=True
    Check BTS BBMOD configuration
    Check BTS BBMOD bbmodBoardConfigType parameter

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

Step ${index}: Get ${when} date UTC info
    Log  Step ${index}: Get ${when} date UTC info  console=True
    Get Current Date UTC info  ${when}

Step ${index}: Perform BBMOD reconfiguration
    [Documentation]
    ...  Perform BBMOD reconfiguration implying parameter bbmodBoardConfigType commissioning

    Log  Step ${index}: Perform BBMOD reconfiguration  console=True
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled

    ${year}  ${month}  ${day}  ${hour}  ${min}  ${sec}=  Get Time  format=year,month,day,hour,min,sec
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}_${sec}
    ${delta_id}=  Set Variable  BBMOD_${timestamp}
    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True

    Log  Append BBMOD info to Delta:  console=True
    FOR  ${item1}  ${item2}  IN ZIP  ${BBMOD_SN_list}  ${BBMOD_bbmodBoardConfigType_list}
       ${BBMOD_ID}=  Get From Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${item1}
       ${BBMOD_SCF_DN}=  Get BBMOD SCF DN  ${BBMOD_ID}  ${alias_local}
       Log  BBMOD SN ${item1}:\n - dist_name: ${BBMOD_SCF_DN}\n - parameter: bbmodBoardConfigType\n - value: ${item2}  console=True
       Append Parameter Update To Delta  dist_name=${BBMOD_SCF_DN}  parameter=bbmodBoardConfigType  value=${item2}  delta_id=${delta_id}
    END

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning JSON file ${delta_id}  console=True
    coam.Perform Delta Recommissioning  delta_file=${delta_file}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias_local}
    Sleep  60s
    FOR  ${item1}  ${item2}  IN ZIP  ${BBMOD_SN_list}  ${BBMOD_bbmodBoardConfigType_list}
       ${BBMOD_ID}=  Get From Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${item1}
       ${BBMOD_SCF_DN}=  Get BBMOD SCF DN  ${BBMOD_ID}  ${alias_local}
       ${BBMOD_bbmodBoardConfigType_value}=  Get bbmodBoardConfigType parameter value  ${BBMOD_ID}  ${alias_local}
       Run Keyword If  '${BBMOD_bbmodBoardConfigType_value}' == '${item2}'
       ...  Log  BBMOD SN ${item1} reconfiguration successfully performed - bbmodBoardConfigType: ${BBMOD_bbmodBoardConfigType_value}  console=True
       ...  ELSE  Run Keywords
       ...  Log  BBMOD SN ${item1} reconfiguration failed, bbmodBoardConfigType: ${BBMOD_bbmodBoardConfigType_value}  level=ERROR
       ...  AND  Fail  BBMOD SN ${item1} reconfiguration failed
    END
    Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True

    Log  Check BTS cell(s) state after BBMOD(s) reconfiguration:  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias_local}
    Log  All BTS cell(s) - ${CELL_state_enabled}  console=True

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

Step ${index}: Perform BTS commissioning
    [Documentation]
    ...  KW used to recover initial BTS configuration by SCF commissioning

    [Timeout]  30 min
    Log  Step ${index}: Perform BTS commissioning  console=True
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled

    Log  Perform BTS commissioning with initial SCF  console=True
    ${BTS_ID}=  Get Id For Current  class_name=BTS  connection=${alias_local}
    coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${${alias_local.lower()}_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  connection=${alias_local}
    Sleep  60s
    ${BTS_recover}=  Set Variable  ${True}
    FOR  ${item}  IN  @{BBMOD_SN_list}
       ${BBMOD_ID}=  Get From Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${item}
       ${bbmodBoardConfigType_final}=  Get bbmodBoardConfigType parameter value  ${BBMOD_ID}  ${alias_local}
       ${bbmodBoardConfigType_initial}=  Get From Dictionary  ${BBMOD_SN_bbmodBoardConfigType_dict_initial}  ${item}
       ${BTS_recover}=  Set Variable If  '${bbmodBoardConfigType_final}' != '${bbmodBoardConfigType_initial}'  ${False}  ${BTS_recover}
    END

    Run Keyword If  ${BTS_recover}
    ...  Log  BTS commissioning with initial SCF successfully performed  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS commissioning with initial SCF failed  level=ERROR
    ...  AND  Fail  BTS commissioning with initial SCF failed

    Log  Check BTS cell(s) state after BTS commissioning:  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias_local}
    Log  All BTS cell(s) - ${CELL_state_enabled}  console=True

Check BTS BBMOD configuration
    [Documentation]
    ...  KW used to check BTS BBMOD ABIO configuration and rightness of BBMOD SN test argument

    Log  Check BTS BBMOD configuration  console=True
    Log  List of BBMOD serial number selected for reconfiguration: ${BBMOD_SN_list}  console=True
    ${BBMOD_SN_list_strip}=  Strip String  ${BBMOD_SN_list}
    ${BBMOD_SN_list_strip}=  Evaluate  '${BBMOD_SN_list_strip}'.replace(', ',',')
    ${BBMOD_SN_list}=  Split String  ${BBMOD_SN_list_strip}  ,
    Set Test Variable  ${BBMOD_SN_list}

    ${BTS_BBMOD_ID_list}=  Get Ids For All  class_name=BBMOD  connection=${alias_local}
    ${BTS_BBMOD_ABIO_check}=  Set Variable  ${False}
    ${BTS_BBMOD_SN_ID_dict}=  Create Dictionary
    ${BTS_BBMOD_SN_PN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{BTS_BBMOD_ID_list}
        ${BBMOD_R_param_info}=  Get Parameters For  class_name=BBMOD  id_num=${item}  connection=${alias_local}
        Set To Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${BBMOD_R_param_info.serialNumber}  ${BBMOD_R_param_info.id}
        Set To Dictionary  ${BTS_BBMOD_SN_PN_dict}  ${BBMOD_R_param_info.serialNumber}  ${BBMOD_R_param_info.productName}
        ${BTS_BBMOD_ABIO_found}=  Run Keyword And Return Status  Should Contain  ${BBMOD_R_param_info.productName}  ABIO
        ${BTS_BBMOD_ABIO_check}=  Set Variable If  ${BTS_BBMOD_ABIO_found}  ${True}  ${BTS_BBMOD_ABIO_check}
    END
    Set Test Variable  ${BTS_BBMOD_SN_ID_dict}
    Set Test Variable  ${BTS_BBMOD_SN_PN_dict}
    Run Keyword If  not ${BTS_BBMOD_ABIO_check}  Run Keywords
    ...  Log  Improper BTS BBMOD configuration: no ABIO present  level=ERROR
    ...  AND  Fail  Improper BTS BBMOD configuration: no ABIO present
    ${BTS_BBMOD_SN_list}=  Get Dictionary Keys  ${BTS_BBMOD_SN_ID_dict}
    FOR  ${item}  IN  @{BBMOD_SN_list}
       Run Keyword If  '${item}' not in ${BTS_BBMOD_SN_list}  Run Keywords
       ...  Log  Improper value set for test argument \${BBMOD_SN_list}. Please set one of following value(s): ${BBMOD_SN_list}  level=ERROR
       ...  AND  Fail  Improper value set for test argument \${BBMOD_SN_list}
    END
    Log  Test will perform reconfiguration on following BBMOD(s):  console=True
    FOR  ${item}  IN  @{BBMOD_SN_list}
       ${BBMOD_ID}=  Get From Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${item}
       ${BBMOD_PN}=  Get From Dictionary  ${BTS_BBMOD_SN_PN_dict}  ${item}
       Log  BBMOD SN: ${item}  console=True
       Log  - ID: ${BBMOD_ID}\n - PN: ${BBMOD_PN}  console=True
    END

Check BTS BBMOD bbmodBoardConfigType parameter
    [Documentation]
    ...  KW used to check rightness of bbmodBoardConfigType test argument

    Log  Check BTS BBMOD bbmodBoardConfigType parameter  console=True
    ${BTS_bbmodBoardConfigType_list}=  Create List
    Append To List  ${BTS_bbmodBoardConfigType_list}  Auto  LTEFDD  LTETDD  NRFDD  NRTDD  LTEFDD_LTETDD  NRFDD_NRTDD  LTEFDD_NRFDD  LTETDD_NRTDD
    ...  LTETDD_NRFDD  LTEFDD_NRTDD

    Log  List of values for parameter bbmodBoardConfigType used for BBMOD reconfiguration: ${BBMOD_bbmodBoardConfigType_list}  console=True
    ${BBMOD_bbmodBoardConfigType_list_strip}=  Strip String  ${BBMOD_bbmodBoardConfigType_list}
    ${BBMOD_bbmodBoardConfigType_list_strip}=  Evaluate  '${BBMOD_bbmodBoardConfigType_list_strip}'.replace(', ',',')
    ${BBMOD_bbmodBoardConfigType_list}=  Split String  ${BBMOD_bbmodBoardConfigType_list_strip}  ,
    Set Test Variable  ${BBMOD_bbmodBoardConfigType_list}

    FOR  ${item}  IN  @{BBMOD_bbmodBoardConfigType_list}
       Run Keyword If  '${item}' not in ${BTS_bbmodBoardConfigType_list}  Run Keywords
       ...  Log  Improper value set for test argument \${BBMOD_bbmodBoardConfigType_list}. Please set one of following value(s): ${BBMOD_SN_list}
       ...  level=ERROR
       ...  AND  Fail  Improper value set for test argument \${BBMOD_bbmodBoardConfigType_list}
    END
    ${BBMOD_SN_bbmodBoardConfigType_dict}=  Create Dictionary
    FOR  ${item1}  ${item2}  IN ZIP  ${BBMOD_SN_list}  ${BBMOD_bbmodBoardConfigType_list}
       ${BBMOD_ID}=  Get From Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${item1}
       ${bbmodBoardConfigType_value}=  Get bbmodBoardConfigType parameter value  ${BBMOD_ID}  ${alias_local}
       Run Keyword If  '${bbmodBoardConfigType_value}' == '${item2}'  Run Keywords
       ...  Log Long String  Value set for test argument \${BBMOD_bbmodBoardConfigType_list} same as current configured.
       ...  Please set one of the following value(s):  ${BTS_bbmodBoardConfigType_list}  level=ERROR
       ...  AND  Fail  Improper value set for test argument \${BBMOD_bbmodBoardConfigType_list}
       Set To Dictionary  ${BBMOD_SN_bbmodBoardConfigType_dict}  ${item1}  ${bbmodBoardConfigType_value}
       Log  BBMOD SN: ${item1}  console=True
       Log  - initial bbmodBoardConfigType: ${bbmodBoardConfigType_value}\n - new bbmodBoardConfigType: ${item2}    console=True
    END
    Set Test Variable  ${BBMOD_SN_bbmodBoardConfigType_dict_initial}  ${BBMOD_SN_bbmodBoardConfigType_dict}

Get bbmodBoardConfigType parameter value
    [Arguments]  ${BBMOD_R_ID}  ${alias}
    ${BBMOD_SCF_DN}=  Get BBMOD SCF DN  ${BBMOD_R_ID}  ${alias}
    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${bbmodBoardConfigType_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${BBMOD_SCF_DN}
    ...  p_name=bbmodBoardConfigType
    ${bbmodBoardConfigType_count}=  Get Length  ${bbmodBoardConfigType_info_dict}
    ${bbmodBoardConfigType}=  Run Keyword If  ${bbmodBoardConfigType_count} > 0
    ...  Get From Dictionary  ${bbmodBoardConfigType_info_dict}  bbmodBoardConfigType
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${bbmodBoardConfigType}


Get BBMOD SCF DN
    [Documentation]
    ...  KW used to get BBMOD SCF distinguished name

    [Arguments]  ${BBMOD_R_ID}  ${alias}
    ${BTS_info}=  Get Bts Info  connection=${alias}
    FOR  ${item}  IN  @{BTS_info['basebandModules']}
        Exit For Loop If  '${item['id']['internal']}' == '${BBMOD_R_ID}'
    END
    [Return]  ${item['id']['configuration']}

Recover BTS initial configuration
    [Documentation]
    ...  KW used to recover initial BTS configuration by SCF commissioning

    ${BTS_recover}=  Set Variable  ${True}
    FOR  ${item}  IN  @{BBMOD_SN_list}
       ${BBMOD_ID}=  Get From Dictionary  ${BTS_BBMOD_SN_ID_dict}  ${item}
       ${bbmodBoardConfigType_final}=  Get bbmodBoardConfigType parameter value  ${BBMOD_ID}  ${alias_local}
       ${bbmodBoardConfigType_initial}=  Get From Dictionary  ${BBMOD_SN_bbmodBoardConfigType_dict_initial}  ${item}
       ${BTS_recover}=  Set Variable If  '${bbmodBoardConfigType_final}' != '${bbmodBoardConfigType_initial}'  ${False}  ${BTS_recover}
    END
    Return From Keyword If  ${BTS_recover}
    ${BTS_ID}=  Get Id For Current  class_name=BTS  connection=${alias_local}
    coam.Perform Commissioning  bts_id=${BTS_ID}  scf_file=${${alias_local.lower()}_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  connection=${alias_local}
    Log  BTS commissioning indicated  console=True

Particular Teardown
    Run Keyword And Continue On Failure  Recover BTS initial configuration

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
