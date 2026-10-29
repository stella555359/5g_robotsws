*** Settings ***
Documentation    TC__NR_NR__CM__NR_ALD_Planned_Recommissioning
Variables    tc_variables/nr_nr__cm__nr_ald_planned_recommissioning_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${NR_BTS}  Master  #  Specify on which BTS to perform recommissioning procedure: Master or Slave, default value Master
${NR_COMMISSIONING_SCF}  # Absolute path for recommissioning SCF file (i.e. /home/ute/btsauto/SCF_01_SBTS19.xml).
${NR_INITIAL_SCF_RECOVERY}  True  # Recovery BTS configuration by recommissioning with initial SCF
${REPEAT_COUNTER}  3  # Number of BTS recommissioning operations, default value 3
                      # taken into account only if ${NR_INITIAL_SCF_RECOVERY} set on True
${NR_SCF_VALIDATION}  True  # Validate NR SCF; can be True or False
${NR_MAX_WAIT_TIME}  900  # Maximum time to wait of BTS OnAir
${NR_RESET_WRN_THR}  648  # Time from first cell down to last cell up. Default value in line with KPI 1a specifications

*** Keywords ***
TC__NR_NR__CM__NR_ALD_Planned_Recommissioning
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21343
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-NR test case for NR ${NR_BTS} recommissioning, ${NR_BTS} may be Master or Slave, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3).
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR BTS
    ...  - get initial RESET info from blackbox files for both NR BTS
    ...  - perform SCF recommissioning operation on NR ${NR_BTS}
    ...  - check reset behavior on both NR based on initial and final RESET info as follows:
    ...    - NR ${NR_BTS} site: reset number is 1
    ...    - NR peer site: reset number is 0
    ...  - check final state and alarms for both NR BTS
    ...
    ...  Pass criteria: NR ${NR_BTS} recommissioning procedure works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 02.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21343 - [5G] NR_NR_MASTER_Planned_RET_Recommissioning
    ...  - 30.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21401 -
    ...  [Legacy] taf.sbts.oam.coam.admin refactoring for collect_scf -> get_current_scf_file
    ...  - 15.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21807 - [5G] Refactoring due to stateInfo changes: NR_NR
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21779 - [5G][Legacy][RFSplit] Test SBTSGSM Common Part (hran_ta)
    ...  - 24.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23838 - [5G][TC review][NR-NR] Remove "regex" word from cell/RM/BBMode state
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21343_NR_NR__CM__NR_ALD_Planned_Recommissioning.png

    Set Tags    CA-STATE    OWNER-adrian.beta@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS21B

    TC Parameter Check
    Step 1: Check initial NR Master state
    Step 2: Check initial NR Slave state
    Step 3: Check initial NR Master alarms
    Step 4: Check initial NR Slave alarms
    Step 5: Get and check initial ALD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform NR ${NR_BTS} Recommissioning
        Step 7: Get and check final ALD info
        Step 8: Check final NR Master state
        Step 9: Check final NR Slave state
        Step 10: Check final NR Master alarms
        Step 11: Check final NR Slave alarms
        Step 12: Check NR reset behavior
        Step 13: Check final number and state of Cells and RMs
        Run Keyword If  ${NR_INITIAL_SCF_RECOVERY}
        ...  NR ${NR_BTS} Initial SCF Recovery
        ...  ELSE
        ...  Exit For Loop
    END

TC Parameter Check
    Run Keyword If  '${NR_BTS}' in ['Master','Slave']  Run Keywords
    ...  Log  =======================================================  console=True
    ...  AND  Log  ***** Test will perform NR ${NR_BTS} Recommissioning *****  console=True
    ...  AND  Log  =======================================================  console=True
    ...  ELSE  Run Keywords
    ...  Log  Please set one of following values for test argument \${NR_BTS}: Master or Slave  level=ERROR
    ...  AND  Fail  Improper value for argument!

Step ${index}: Check ${when} NR ${alias} state
    [Documentation]
    ...  NR state is checked according to Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} NR ${alias} state  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}
    Log  NR ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} NR ${alias} alarms
    [Documentation]
    ...  NR alarms are compared with values from expected, ignored and critical alarms lists. NR alarms are get from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} NR ${alias} alarms  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${NR_${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${NR_${alias.upper()}_CRITICAL_ALARMS}
    Log  NR ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get and check ${when} ALD info
    [Documentation]
    ...  Get and check ALD info

    Log  Step ${index}:Get and check ${when} ALD info  console=True
    ${ALD_list}=  Get Ids For_All  ALD  connection=${NR_BTS}
    Set Test Variable  ${ALD_list_${when}}  ${ALD_list}
    ${ALD_count}=  Get Length  ${ALD_list}
    Set Test Variable  ${ALD_count_${when}}  ${ALD_count}
    Run Keyword If  '${when}' == 'initial'  Run Keyword If  ${ALD_count} == 0  Run Keywords
    ...  Log  No ALD present in BTS Runtime View before recommissioning procedure  console=True
    ...  AND  Return From Keyword
    Run Keyword If  '${when}' == 'initial'  Run Keyword If  ${ALD_count} != 0
    ...  Log  NR ${NR_BTS} ALD found: ${ALD_list}  console=True

    Run Keyword If  '${when}' == 'final'  Run Keyword If  ${ALD_count_final} > ${ALD_count_initial}
    ...  Log  ALD added in BTS Runtime View after recommissioning procedure  console=True
    Run Keyword If  '${when}' == 'final'  Run Keyword If  ${ALD_count_final} < ${ALD_count_initial}
    ...  Log  ALD removed in BTS Runtime View after recommissioning procedure  console=True
    Run Keyword If  '${when}' == 'final'  Run Keyword If  ${ALD_count_final} == ${ALD_count_initial}  Run Keywords
    ...  Log  No change ALD in BTS Runtime View after recommissioning procedure  level=ERROR
    ...  AND  Fail  Execution ended!

    ${ALD_state_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${ALD_state}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    Log  Get and check NR ${NR_BTS} ALD info and state  console=True
    ${BTS_info}=  Get BTS Info  connection=${NR_BTS}
    FOR  ${item}  IN  @{BTS_info['alds']}
        Log  ALD info and state for ${item['id']['internal']}:  console=True
        Log  ALD productCode: ${item['productCode']}  console=True
        Log  ALD serialNumber: ${item['serialNumber']}  console=True
        ${ALD_L_obj_status}=  Query Infomodel  check //ALD_L-* is [serialNumber=${item['serialNumber']}]
        ...  timeout=3  allow_negative_result=True  alias=${NR_BTS}
        ${ALD_L_obj_info}=  Run Keyword If  ${ALD_L_obj_status}
        ...  Query Infomodel  get object //ALD_L-* is [serialNumber=${item['serialNumber']}]  alias=${NR_BTS}
        Run Keyword If  ${ALD_L_obj_status}
        ...  Log  ALD deviceType: ${ALD_L_obj_info['deviceType']}  console=True
        Assert  class_name=ALD  id=${item['id']['internal']}
        ...  parameters=${ALD_state_check}  timeout=60  connection=${NR_BTS}
        Log  ALD status: ${ALD_state}  console=True
    END

Step ${index}: Perform NR ${NR_BTS} Recommissioning
    [Documentation]
    ...  Planned NR recommissioning with SCF file is triggered.

    [Timeout]  15 min
    Log  Step ${index}: Perform NR ${NR_BTS} Recommissioning  console=True

    Log  NR ${NR_BTS} SCF location: ${NR_COMMISSIONING_SCF}  console=True
    ${BTS_Id}=  Get Id For Current  class_name=BTS  connection=${NR_BTS}
    Set Test Variable  ${BTS_Id}
    Get Current Date UTC info  start
    coam.Perform Commissioning  bts_id=${BTS_Id}  scf_file=${NR_COMMISSIONING_SCF}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  connection=${NR_BTS}
    Log  NR ${NR_BTS} recommissioning has been performed!  console=True

    Get Current Time  nr_initial

    Run Keyword If  ${NR_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate NR SCF after Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  alias=${NR_BTS}
    ...  AND  Admin Validate SCF With Detected Hardware  alias=${NR_BTS}

    Check SW configuration did not change

    ${nr_first_cell_up_elapsed_time}=  Get NR first cell up time  ${time_nr_initial}  ${NR_MAX_WAIT_TIME}
    Log  Time until first cell up: ${nr_first_cell_up_elapsed_time}s  console=True
    ${nr_all_cells_up_elapsed_time}=  Get NR all cells up time  ${time_nr_initial}  ${nr_first_cell_up_elapsed_time}  ${NR_MAX_WAIT_TIME}
    Log  Time until all cells up: ${nr_all_cells_up_elapsed_time}s  console=True
    Check KPI  ${nr_all_cells_up_elapsed_time}  ${NR_RESET_WRN_THR}
    Get Current Date UTC info  end
Step ${index}: Check NR reset behavior
    [Documentation]
    ...  Final RESET info is compared with initial RESET info for both NR BTS
    ...  Reset behavior as expected in following conditions:
    ...  - NR ${NR_BTS} site: reset number is 1
    ...  - NR ${peer_NR_BTS} site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR reset behavior  console=True
    ${peer_NR_BTS}=  Set Variable If  '${NR_BTS}' == 'Master'  Slave  Master

    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${NR_BTS}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${peer_NR_BTS}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check SW configuration did not change
    [Documentation]
    ...  Extract Master and Slave active and passive SWs using Admin and compare to initial values. Fail if something changed

    ${current_active_SW_Master}  ${current_passive_SW_Master}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Master
    ${current_active_SW_Slave}  ${current_passive_SW_Slave}=  Wait Until Keyword Succeeds  5m  20s  Admin Get BTS SW Version  Slave
    ${initial_SW_list}=  Create List  ${Master active SW}  ${Master passive SW}  ${Slave active SW}  ${Slave passive SW}
    ${current_SW_list}=  Create List  ${current_active_SW_Master}  ${current_passive_SW_Master}
    ...  ${current_active_SW_Slave}  ${current_passive_SW_Slave}
    ${no_sw_change}=  Run Keyword And Return Status  Should Be Equal  ${initial_SW_list}  ${current_SW_list}
    Run Keyword If  not ${no_sw_change}  Run Keywords
    ...  Log Long String  SW configuration changed! Master SW active/passive: ${current_active_SW_Master}/${current_passive_SW_Master};
    ...  Slave SW active/passive: ${current_active_SW_Slave}/${current_passive_SW_Slave}  console=True
    ...  AND  Fail  SW configuration changed!

NR ${NR_BTS} Initial SCF Recovery
    [Documentation]
    ...  Planned NR recommissioning with initial SCF file is triggered.

    [Timeout]  15 min
    Log  NR ${NR_BTS} Initial SCF Recovery  console=True

    Log  Initial SCF location: ${${NR_BTS.lower()}_scf_initial}  console=True
    coam.Perform Commissioning  bts_id=${BTS_Id}  scf_file=${${NR_BTS.lower()}_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  connection=${NR_BTS}
    Log  NR ${NR_BTS} recommissioning with initial SCF has been performed!  console=True

    Get Current Time  nr_initial

    Run Keyword If  ${NR_SCF_VALIDATION}  Run Keywords
    ...  Log  Validate NR SCF after Recommissioning  console=True
    ...  AND  Admin Validate SCF TAF  alias=${NR_BTS}
    ...  AND  Admin Validate SCF With Detected Hardware  alias=${NR_BTS}

    Check SW configuration did not change

    ${nr_first_cell_up_elapsed_time}=  Get NR first cell up time  ${time_nr_initial}  ${NR_MAX_WAIT_TIME}
    Log  Time until first cell up: ${nr_first_cell_up_elapsed_time}s  console=True
    ${nr_all_cells_up_elapsed_time}=  Get NR all cells up time  ${time_nr_initial}  ${nr_first_cell_up_elapsed_time}  ${NR_MAX_WAIT_TIME}
    Log  Time until all cells up: ${nr_all_cells_up_elapsed_time}s  console=True
    Check KPI  ${nr_all_cells_up_elapsed_time}  ${NR_RESET_WRN_THR}

    ${ALD_list_recovery}=  Get Ids For_All  ALD  connection=${NR_BTS}

    Run Keyword If  '${ALD_list_recovery}' == '${ALD_list_initial}'
    ...  Log  NR ${NR_BTS} initial SCF recovery properly performed  console=True
    ...  ELSE  Run Keywords
    ...  Log  NR ${NR_BTS} initial SCF recovery failed  level=ERROR
    ...  AND  Fail  Execution ended!

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}

TC Teardown
    Common Test Teardown
