*** Settings ***
Documentation    TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM
Variables    tc_variables/sbts__state__site_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of SBTS Block-Unblock BTS operations from WebEM, default value 3
${SBTS_RESET_WRN_THR}  600  # If SBTS Reset exceeds SBTS, test verdict passed with restriction and snapshot at the end of the test.
${SBTS_MAX_WAIT_TIME}  900  # Time (secs) spent between first cell down to last cell up on BTS; default value: in accordance with KPI1a
                            # specifications

*** Keywords ***
TC__SBTS__STATE__Site_Block_Unblock_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21901
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for Site Block-Unblock operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - perform Block/Unblock BTS operation on SBTS checking BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 1
    ...  - check final BTS state and alarms
    ...  Pass criteria: site block/unblock operations work as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21901 - [5G][RFSplit] RFS_BTS__STATE__SBTS_Block_Unblock_Site_from_WebEM
    ...  - 23.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22650 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - SBTS part
    ...  - 01.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24007
    ...  - [5G][TC review][RSplit] Please display FID50 alarm in SBTS__STATE__Site_Block_Unblock_from_WEBEM
    ...  - 09.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24193 - [5G][Reset Number ims2] Update SBTS STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 18.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26133 - [5G] New expected state after NR BTS block for
    ...  NR_SBTS__STATE__NR_BTS_BlockUnblock_from_WEBEM
    ...  - 02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27183 - [5G] Increase kpi from bts_block_unblock
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27410 - [5G] [Infomodel] - P1 - Eliminate usage of KW Infomodel "Get baseband
    ...  pool allocation mode info" in test-cases - after TAT-27401
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21901_SBTS__STATE__Site_Block_Unblock_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-cristinel.sava@nokia.com    AUTHOR-lia.caraiman@nokia.com    PHASE-QT    SW-22R1

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get initial baseband pool allocation mode info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Block BTS
        Step 5: Unblock BTS
        Step 6: Calculate reset time on BTS for iteration ${INDEX}
        Step 7: Check BTS reset time
        Step 8: Check final BTS state
        Step 9: Check final BTS alarms
        Step 10: Check BTS reset behavior based on IMS info
        Step 11: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

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

Step ${index}: Block BTS
    [Documentation]
    ...  Block BTS procedure is launched on SBTS . Check state and alarms.

    Log  Step ${index}: Block BTS  console=True
    Log  Perform "Block Site" operation on SBTS from Admin  console=True
    coam.Block  timeout=600  alias=${alias_local}
    Sleep  10s

    Log  Check SBTS states and alarms after Site Block:  console=True
    Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_Configured_}  ${Blocked_}  180  ${alias_local}
    Log  SBTS site - proceduralState: IntegratedToRAN|Configured, blockingState: Blocked, as expected!  console=True
    Log  SBTS "BTS blocked (50)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${${alias_local.upper()}_EXPECTED_ALARMS_50}
    ...  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  SBTS "BTS blocked (50)" alarm, found number: 1  console=True
    Log  SBTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Unblock BTS
    [Documentation]
    ...  Perform Unblock BTS operation on SBTS from ADMIN

    Log  Step ${index}: Unblock BTS  console=True
    Log  Perform "Unblock Site" operation on SBTS from ADMIN  console=True
    Get Current Time  sbts_initial
    Log  SBTS reset_start_time is: ${time_sbts_initial}  console=True
    Get Current Date UTC info  start
    coam.Unblock  timeout=600  alias=${alias_local}
    Get Current Date UTC info  end

Step ${index}: Calculate reset time on BTS for iteration ${CYCLE}
    Log  Step ${index}: Calculate reset time on on BTS for iteration ${CYCLE}  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${SBTS_MAX_WAIT_TIME}  ${alias_local}
    Get Current Time  sbts_final
    ${sbts_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_sbts_final}  ${time_sbts_initial}  number
    Export ResetTime Results  ${alias_local}  ${BTS Files}/Slave/ResetTimeInfo.txt  unblock_sm  sbts  ${CYCLE}  ${sbts_reset_elapsed_time}  ${EMPTY}
    Set Suite Variable  ${sbts_reset_elapsed_time}

Step ${index}: Check BTS reset time
    Log  Step ${index}: Check BTS reset time   console=True
    Check KPI  ${sbts_reset_elapsed_time}  ${SBTS_RESET_WRN_THR}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  Check BTS reset behavior based on IMS info. Reset behavior as expected if:
    ...  - reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias_local}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Particular Teardown
    Run Keyword And Continue On Failure  Admin Check if BTS is unblocked  ${alias_local}
    Export ResetTime Results Global

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
