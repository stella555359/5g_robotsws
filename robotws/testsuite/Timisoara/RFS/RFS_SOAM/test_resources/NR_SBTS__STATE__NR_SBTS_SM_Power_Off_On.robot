*** Settings ***
Documentation    TC__NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On
Variables    tc_variables/nr_sbts__state__nr_sbts_sm_power_off_on_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${actTempRadioMaster}                 # Allow slave BTS in RF Sharing to temporarily take over the radio master role,
                                      # possible values: empty (by default), true or false
${tempRadioMasterTriggerTime}         # Integer value for tempRadioMasterTriggerTime to be commissioned
${tempRadioMasterRecovTime}           # Integer value for tempRadioMasterRecovTime to be commissioned
${first_techno_powered_on}     BOTH   # Specify which techno should be powered on first. Possible values: NR, SBTS, BOTH (default).
                                      # In cases BOTH, and NR, parameters actTempRadioMaster, tempRadioMasterTriggerTime, tempRadioMasterRecovTime
                                      #  will not be changed (Temporary Radio Master N/A).
                                      # Also be aware that in the case of NR, parameter actforceautoreset must be set to false
${NR_RESET_WRN_THR}            540    # Compared with the time spent between NR SM Power ON and last cell up.
                                      # If exceeds NR_RESET_WRN_THR, test verdict will be failed and snapshot collected
                                      # Default value: in accordance with KPI 3 specifications
${NR_MAX_WAIT_TIME}            900    # Maximum time for wait of NR BTS OnAir
${SBTS_RESET_WRN_THR}          600    # If SBTS power on exceeds SBTS_RESET_WRN_THR, test verdict passed with restriction and snapshot collected
${SBTS_MAX_WAIT_TIME}          900    # Maximum time for wait of SBTS BTS OnAir
${GRACEFUL_CELL_SHUTDOWN}      True   # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-19154
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for NR and SBTS SMs Power Off/On
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - perform Power Off/On operation on NR and SBTS SMs in 3 possible cases:
    ...     - Case 1 - Power OFF NR, SBTS. Power ON NR, SBS - perform required checks
    ...     - Case 2 - Power OFF NR, SBTS. Power ON NR, then Power on SBS - perform required checks
    ...     - Case 3 - Power OFF NR, SBTS. Power ON SBTS, then Power on NR - perform required checks
    ...  - check reset behavior on NR and SBTS based on IMS info as follows:
    ...    - NR site: reset number is 1 (2 for Case 2)
    ...    - SBTS site: reset number is 1
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: NR SBTS SMs Power Off/On operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.03.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19154 -[NR][P15]Create new automated test NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On
    ...  - 20.05.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19513 -
    ...  LL_RFSharing-SlaveBTSTemporaryRadioMaster-MasterBTSRadioMasterBack improvements
    ...  - 11.06.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19424 -
    ...  Use generic hran_admin KW "Admin Get Shared And Dedicated RM List for Master and Slave" in all TCs
    ...  - 07.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19759 -
    ...  Increase time for :KPI1a${NR_RESET_WRN_THR} KPI#3${NR_RESET_WRN_THR} for NRL and NR automated TCs
    ...  - 26.08.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20022 - [Refactoring] RFS,RFS_SOAM refactoring of code handling PDU
    ...  - 25.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20503 - [Cloud] [NRL/SBTS] Cloud behavior Reset Time WRN threshold per Tech
    ...  - 23.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20865 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NR_SBTS
    ...  - 08.04.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21146 - [5G][NR][SBTS]NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On need to be updated
    ...  - 12.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21303 - [Legacy][taf.sbts.oam.coam.admin] Udate & test TC NR_SBTS
    ...  - 14.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NR_SBTS
    ...  - 14.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21776 - [5G][Legacy][RFSplit] Test NRSBTS Common Part (hran_ta)
    ...  - 22.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22646 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NR-SBTS part
    ...  - 20.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23356 - [5G] Recovery procedure (power off/on) failed on NR-SBTS
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 03.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23925 - [5G][TC review][NR-SBTS] Remove Cells "AdministrativeState" check in
    ...  all NR-SBTS robots
    ...  - 30.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24513 - [5G] Update scenarios to take reset number from ims2 power off/on tests
    ...  - NR_SBTS,general - with TAT-24512
    ...  - 02.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25803 - [5G][TC review] Possibility to perform power off/on for both Cores
    ...  (Dual Core BTS) for NR_SBTS_Power_off_on
    ...  - 20.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26449 - [5G] NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On test should be enhanced
    ...  for teardown scenario
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 29.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27827 - [CNI-127210]Remove EXPECTED "No usable time reference available"
    ...  alarm from NR_SBTS_SM_Power _OFF/ON
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-19154_NR_SBTS__STATE__NR_SBTS_SM_Power_Off_On.png

    Set Tags    CA-STATE    OWNER-geraldina.isfan@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-5G19,SBTS19

    TC parameters check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check PDU definition and reachability
    Step 4: Activate SBTS Temporary Radio Master Feature
    Step 5: Power OFF NR and SBTS SMs
    Step 6: Power ON NR and SBTS SMs
    Step 7: Check final all BTS state
    Step 8: Check final all BTS alarms
    Step 9: Check NR and SBTS reset behavior based on IMS info
    Step 10: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

TC parameters check
    Log  TC parameters check verification started  console=True
    Run keyword If  '${first_techno_powered_on.upper()}' not in 'NR, SBTS, BOTH'
    ...  Fail  Wrong value for first_techno_powered_on: ${first_techno_powered_on.upper()}. Accepted values: NR, SBTS, BOTH
    ${actTempRadioMaster}=  Set Variable  ${actTempRadioMaster.lower()}

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

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Keyword used to check if SM PDUs can be reached and their status

    Log  Step ${index}: Check PDU definition and reachability  console=True
    ${Master_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  Master
    Set Test Variable  ${Master_SM_PDU_if_name_list}
    ${status}=  Check BTS SMs PDU port status  ${Master_SM_PDU_if_name_list}  on
    Run Keyword if  ${status}
    ...  Log  NR SMs PDU port status as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for NR SMs is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for NR SMs is either not reachable or not switched on!

    ${Slave_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  Slave
    Set Test Variable  ${Slave_SM_PDU_if_name_list}
    ${status}=  Check BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  on
    Run Keyword if  ${status}
    ...  Log  SBTS SMs PDU port status as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for SBTS SMs is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for SBTS SMs is either not reachable or not switched on!

Step ${index}: Activate SBTS Temporary Radio Master Feature
    [Documentation]
    ...  Keyword used to activate SBTS Temporary Radio Master Feature in accordance with defined input parameters:
    ...  actTempRadioMaster, tempRadioMasterTriggerTime and tempRadioMasterRecovTime for the case when first TECHNO to be powered on is SBTS.
    ...  Otherwise no change is performed

    Log  Step ${index}: Activate SBTS Temporary Radio Master Feature  console=True
    ${BTS_actTempRadioMaster_initial}=  Get Activate Temporary Radio Master Role From Slave BTS  BTS_scf=${slave_scf_initial}  alias=Slave
    ${BTS_tempRadioMasterRecovTime_initial}  ${BTS_tempRadioMasterTriggerTime_initial}=
    ...  Get Activate Temporary Radio Master Timers From Slave BTS  BTS_scf=${slave_scf_initial}  alias=Slave
    Set Test Variable  ${BTS_actTempRadioMaster_initial}
    Set Test Variable  ${BTS_tempRadioMasterTriggerTime_initial}
    Set Test Variable  ${BTS_tempRadioMasterRecovTime_initial}
    Run Keyword If  '${first_techno_powered_on.upper()}' != 'SBTS'  Run Keywords
    ...  Log  First techno to be powered on set to ${first_techno_powered_on.upper()}. No parameter commissioning will be needed!  console=True
    ...  AND  Return From Keyword
    Set Activate Temporary Radio Master Role From Slave BTS  BTS_scf=${slave_scf_initial}  actTempRadioMaster=${actTempRadioMaster}  alias=Slave
    Set Activate Temporary Radio Master Timers On Slave BTS  BTS_scf=${slave_scf_initial}  tempRadioMasterRecovTime=${tempRadioMasterRecovTime}
    ...  tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime}  alias=Slave
    Log Long String  Test will be performed with the following parameter config: actTempRadioMaster: ${actTempRadioMaster.lower()}
    ...  tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime} tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}   console=True

Step ${index}: Power OFF NR and SBTS SMs
    [Documentation]
    ...  Keyword is used to power off the NR and SBTS SMs.

    Log  Step ${index}: Power OFF NR and SBTS SMs  console=True

    ${NR_shared_RMOD_list}  ${SBTS_shared_RMOD_list}  ${NR_dedicated_RMOD_list}  ${SBTS_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    ${SBTS_shared_RMOD_count_tmp}=  Get Length  ${SBTS_shared_RMOD_list}
    Set Test Variable  ${SBTS_shared_RMOD_count}  ${SBTS_shared_RMOD_count_tmp}

    Log  Perform power off SBTS SMs  console=True
    ${status}=  Set BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  off
    Run Keyword If  ${status}
    ...  Log  SBTS SMs PDU port status off, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set SBTS SMs PDU port status off failed!  level=ERROR
    ...  AND  Fail  Set SBTS SMs PDU port status off failed!

    Log  Perform power off NR SMs  console=True
    ${status}=  Set BTS SMs PDU port status  ${Master_SM_PDU_if_name_list}  off
    Run Keyword If  ${status}
    ...  Log  NR SMs PDU port status off, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set NR SMs PDU port status off failed!  level=ERROR
    ...  AND  Fail  Set NR SMs PDU port status off failed!
    Log  Waiting 30 seconds after power off NR and SBTS SMs  console=True
    Sleep  30 sec

Step ${index}: Power ON NR and SBTS SMs
    [Documentation]
    ...  Keyword is used to power ON the NR and SBTS SMs. The order and the checks performed are decided depending on first techno powered on
    ...  and perform the checks accordingly, taking into account also the Temporary Radio Master Feature, in case first techno powered on is SBTS

    Log  Step ${index}: Power ON NR and SBTS SMs  console=True

    Run Keyword If  '${first_techno_powered_on.upper()}' == 'BOTH'
    ...  Run Keywords
    ...  Get Current Date UTC info  start
    ...  AND  Power ON SMs  techno=NR
    ...  AND  Power ON SMs  techno=SBTS
    ...  AND  Check both powered on at the same time behavior
    ...  ELSE IF  '${first_techno_powered_on.upper()}' == 'NR'
    ...  Run Keywords
    ...  Get Current Date UTC info  start
    ...  AND  Power ON SMs  techno=NR
    ...  AND  Perform checks and actions after power ON NR
    ...  AND  Power ON SMs  techno=SBTS
    ...  AND  Check NR powered on first behavior
    ...  ELSE IF  '${first_techno_powered_on.upper()}' == 'SBTS'  Run Keywords
    ...  Get Current Date UTC info  start
    ...  AND  Power ON SMs  techno=SBTS
    ...  AND  Perform checks and actions after power ON SBTS
    ...  AND  Power ON SMs  techno=NR
    ...  AND  Check SBTS powered on first behavior

Check both powered on at the same time behavior
    [Documentation]
    ...  Keyword is used to check behavior when both SMs are powered on at the same time

    Log  Check behavior when both SMs are powered on at the same time!  console=True

    Get Current Time  nr_initial
    Get Current Time  sbts_initial
    Log  Power on NR and SBTS SMs start time is: ${time_nr_initial}  console=True
    Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=180  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Sleep  120 sec

    Get Current Time  sbts_before_check
    ${sbts_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_sbts_before_check}  ${time_sbts_initial}  number
    ${sbts_first_cell_up_remained_time}=  BuiltIn.Evaluate  ${SBTS_MAX_WAIT_TIME}-${sbts_before_check_elapsed_time}
    ${sbts_first_cell_up_remained_time}=  Set Variable If  ${sbts_first_cell_up_remained_time} <= 0  5  ${sbts_first_cell_up_remained_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${sbts_first_cell_up_remained_time}  Slave
    Get Current Time  sbts_first_cell_up
    ${sbts_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_sbts_first_cell_up}  ${time_sbts_initial}  number
    Export ResetTime Results  Slave  ${BTS Files}/Slave/ResetTimeInfo.txt  power_on  sbts  ${EMPTY}  ${sbts_reset_elapsed_time}  ${EMPTY}
    Get Current Time  nr_before_check
    ${nr_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_nr_before_check}  ${time_nr_initial}  number
    ${nr_first_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_before_check_elapsed_time}
    ${nr_first_cell_up_remained_time}=  Set Variable If  ${nr_first_cell_up_remained_time} <= 0  5  ${nr_first_cell_up_remained_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${nr_first_cell_up_remained_time}  Master
    Get Current Time  nr_first_cell_up
    ${nr_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_first_cell_up}  ${time_nr_initial}  number
    Export ResetTime Results  Master  ${BTS Files}/Master/ResetTimeInfo.txt  power_on  nr  ${EMPTY}  ${nr_reset_elapsed_time}  ${EMPTY}

    ${nr_last_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_reset_elapsed_time}
    ${nr_last_cell_up_remained_time}=  Set Variable If  ${nr_last_cell_up_remained_time} <= 0  5  ${nr_last_cell_up_remained_time}

    Assert Every  NRCEL  operationalState=${Enabled_}  timeout=${nr_last_cell_up_remained_time}  alias=Master

    Get Current Time  nr_last_cell_up
    ${nr_all_cells_up_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_last_cell_up}  ${time_nr_initial}  number
    Add KPI Results in File  alias=Master  kpi_reported=KPI_3  kpi_log_file=${BTS Files}/Master/ResetTimeInfo.txt
    ...  info=nr_power_on_to_last_cell_up  cycle=${EMPTY}  event_value=${nr_all_cells_up_elapsed_time}
    Check KPI  ${nr_all_cells_up_elapsed_time}  ${NR_RESET_WRN_THR}

    Log  All NR and SBTS checks and actions after power ON NR and SBTS were successful!  console=True

Check NR powered on first behavior
    [Documentation]
    ...  Keyword is used to perform all needed checks and actions after power ON NR and power on SBTS also
    Log  Perform checks and actions after power ON SBTS too!  console=True

    Get Current Time  sbts_initial
    Log  Power on SBTS SMs start time is: ${time_sbts_initial}  console=True
    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=180  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Sleep  120 sec
    Get Current Time  sbts_before_check
    ${sbts_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_sbts_before_check}  ${time_sbts_initial}  number
    ${sbts_remained_time}=  BuiltIn.Evaluate  ${SBTS_MAX_WAIT_TIME}-${sbts_before_check_elapsed_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${sbts_remained_time}  Slave
    Get Current Time  sbts_final
    ${sbts_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_sbts_final}  ${time_sbts_initial}  number
    Export ResetTime Results  Slave  ${BTS Files}/Slave/ResetTimeInfo.txt  power_on  sbts  ${EMPTY}  ${sbts_reset_elapsed_time}  ${EMPTY}
    Check KPI  ${sbts_reset_elapsed_time}  ${SBTS_RESET_WRN_THR}

    Log  Checking alarm BTS Reset Required on NR!  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_RESET_REQUIRED}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  time=5 min
    Log  Checking alarm BTS Reset Required on NR succesful! Triggering NR Reset  console=True

    Get Current Time  nr_initial
    RFS Site Reset  wait_for_reconnection=True  connection=Master  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    Sleep  120 sec
    Get Current Time  nr_before_check
    ${nr_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_nr_before_check}  ${time_nr_initial}  number
    ${nr_first_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_before_check_elapsed_time}
    ${nr_first_cell_up_remained_time}=  Set Variable If  ${nr_first_cell_up_remained_time} <= 0  5  ${nr_first_cell_up_remained_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${nr_first_cell_up_remained_time}  Master
    Get Current Time  nr_first_cell_up
    ${nr_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_first_cell_up}  ${time_nr_initial}  number
    Export ResetTime Results  Master  ${BTS Files}/Master/ResetTimeInfo.txt  reset_sm  nr  ${EMPTY}  ${nr_reset_elapsed_time}  ${EMPTY}

    ${nr_last_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_reset_elapsed_time}
    ${nr_last_cell_up_remained_time}=  Set Variable If  ${nr_last_cell_up_remained_time} <= 0  5  ${nr_last_cell_up_remained_time}

    Assert Every  NRCEL  operationalState=${Enabled_}  timeout=${nr_last_cell_up_remained_time}  alias=Master

    Log  All NR and SBTS checks and actions after power ON NR and SBTS were successful!  console=True

Check SBTS powered on first behavior
    [Documentation]
    ...  Keyword is used to perform all needed checks and actions after power ON SBTS and power on NR also
    Log  Perform checks and actions after power ON NR too!  console=True

    Get Current Time  nr_initial
    Log  Power on NR SMs start time is: ${time_sbts_initial}  console=True
    Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    Sleep  120 sec
    Get Current Time  nr_before_check
    ${nr_before_check_elapsed_time}=  DateTime.Subtract Date from Date  ${time_nr_before_check}  ${time_nr_initial}  number
    ${nr_first_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_before_check_elapsed_time}
    ${nr_first_cell_up_remained_time}=  Set Variable If  ${nr_first_cell_up_remained_time} <= 0  5  ${nr_first_cell_up_remained_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${nr_first_cell_up_remained_time}  Master
    Get Current Time  nr_first_cell_up
    ${nr_reset_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_first_cell_up}  ${time_nr_initial}  number
    Export ResetTime Results  Master  ${BTS Files}/Master/ResetTimeInfo.txt  power_on  nr  ${EMPTY}  ${nr_reset_elapsed_time}  ${EMPTY}
    ${nr_last_cell_up_remained_time}=  BuiltIn.Evaluate  ${NR_MAX_WAIT_TIME}-${nr_reset_elapsed_time}
    ${nr_last_cell_up_remained_time}=  Set Variable If  ${nr_last_cell_up_remained_time} <= 0  5  ${nr_last_cell_up_remained_time}
    Assert Every  NRCEL  operationalState=${Enabled_}  timeout=${nr_last_cell_up_remained_time}  alias=Master
    Get Current Time  nr_last_cell_up
    ${nr_all_cells_up_elapsed_time}=  DateTime.Subtract Date From Date  ${time_nr_last_cell_up}  ${time_nr_initial}  number
    Add KPI Results in File  alias=Master  kpi_reported=KPI_3  kpi_log_file=${BTS Files}/Master/ResetTimeInfo.txt
    ...  info=nr_power_on_to_last_cell_up  cycle=${EMPTY}  event_value=${nr_all_cells_up_elapsed_time}
    Check KPI  ${nr_all_cells_up_elapsed_time}  ${NR_RESET_WRN_THR}

    Log  All NR and SBTS checks and actions after power ON NR and SBTS were successful!  console=True

Perform checks and actions after power ON NR
    [Documentation]
    ...  Keyword is used to perform all needed checks and actions after power ON NR

    Log  Perform checks and actions after power ON NR!  console=True

    ${NR_SM_count}=  Get length  ${Master_SM_PDU_if_name_list}
    ${MASTER_EXPECTED_ALARMS_REFERENCE_CLOCK_MISSING}=  Prepare expected alarms list
    ...  ${MASTER_EXPECTED_ALARMS_REFERENCE_CLOCK_MISSING_MORE_THAN_FIVE_MINUTES}  ${NR_SM_count}

    ${MASTER_IGNORED_ALARMS_FULL}=  Combine Lists  ${MASTER_IGNORED_ALARMS_4405}  ${MASTER_IGNORED_ALARMS}
    ${MASTER_EXPECTED_ALARMS_FULL}=  Create List  @{EMPTY}
    Append To List  ${MASTER_EXPECTED_ALARMS_FULL}  @{MASTER_EXPECTED_ALARMS}
    Append To List  ${MASTER_EXPECTED_ALARMS_FULL}  @{MASTER_EXPECTED_ALARMS_BEFORE_SBTS_SM_POWER_ON}
    Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    Sleep  120 sec
    Admin Check BTS Procedural and Blocking states  ${Configured_}  ${Unblocked_}  60  Master
    Append To List  ${MASTER_EXPECTED_ALARMS_FULL}  @{MASTER_EXPECTED_ALARMS_REFERENCE_CLOCK_MISSING}
    Log  Waiting 5 min for raise alarm completion  console=True
    Sleep  300s
    Log  NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True
    Log  NR "Reference clock missing in startup (4153)" alarm, expected number: ${NR_SM_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_FULL}  ignored_alarms=${MASTER_IGNORED_ALARMS_FULL}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR "Reference clock missing in startup (4153)" alarm, found number: ${NR_SM_count}, as expected!  console=True
    Log  NR "No X2 link available (7300)" alarm, found number: 1, as expected!  console=True
    Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1, as expected!  console=True
    Log  All NR checks and actions after power ON NR were successful!  console=True

Perform checks and actions after power ON SBTS
    [Documentation]
    ...  Keyword is used to perform all needed checks and actions after power ON SBTS

    Log  Perform checks and actions after power ON SBTS!  console=True

    Run Keyword If  '${actTempRadioMaster}' == 'false'  Fail  Not relevant to perform SBTS fist power ON scenario when actTempRadioMaster=false

    ${SLAVE_EXPECTED_ALARMS_FULL}=  Create List  @{EMPTY}
    ${SLAVE_CRITICAL_ALARMS_FULL}=  Create List  @{EMPTY}
    Append To List  ${SLAVE_EXPECTED_ALARMS_FULL}  @{SLAVE_EXPECTED_ALARMS}
    Append To List  ${SLAVE_CRITICAL_ALARMS_FULL}  @{SLAVE_CRITICAL_ALARMS}
    ${SLAVE_EXPECTED_ALARMS_TEMP_RADIO_MASTER_RMOD_FULL}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_TEMP_RADIO_MASTER_RMOD}
    ...  ${SBTS_shared_RMOD_count}
    Get Current Time  sbts_initial
    Log  Power on SBTS SMs start time is: ${time_sbts_initial}  console=True
    Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  timeout=180  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}
    Sleep  120 sec
    Get Current Time  sbts_final
    ${sbts_elapsed_time}=  DateTime.Subtract Date From Date  ${time_sbts_final}  ${time_sbts_initial}  number
    ${left_to_wait_until_5_mins}=  BuiltIn.Evaluate  300-${sbts_elapsed_time}
    Run Keyword If  ${left_to_wait_until_5_mins} > 0  Sleep  ${left_to_wait_until_5_mins}s
    ${SLAVE_EXPECTED_ALARMS_FIRST_CHECK}=  Create List  @{EMPTY}
    ${SLAVE_CRITICAL_ALARMS_FIRST_CHECK}=  Create List  @{EMPTY}
    Append To List  ${SLAVE_EXPECTED_ALARMS_FIRST_CHECK}  @{SLAVE_EXPECTED_ALARMS_FULL}
    Append To List  ${SLAVE_CRITICAL_ALARMS_FIRST_CHECK}  @{SLAVE_CRITICAL_ALARMS_FULL}
    Run Keyword If  ${tempRadioMasterTriggerTime} > 5
    ...  Run Keywords  Log Long String  tempRadioMasterTriggerTime is set to ${tempRadioMasterTriggerTime} min!
    ...  In this case on SBTS Temporary Radio Master should not be triggered!  console=True
    ...  AND  Append To List  ${SLAVE_CRITICAL_ALARMS_FIRST_CHECK}  @{SLAVE_EXPECTED_ALARMS_TEMP_RADIO_MASTER_RMOD_FULL}
    ...  ELSE  Run Keywords  Log Long String  tempRadioMasterTriggerTime is set to ${tempRadioMasterTriggerTime} min!
    ...  In this case on SBTS Temporary Radio Master should be triggered!  console=True
    ...  AND  Append To List  ${SLAVE_EXPECTED_ALARMS_FIRST_CHECK}  @{SLAVE_EXPECTED_ALARMS_TEMP_RADIO_MASTER_RMOD_FULL}
    Log  Check alarms on SBTS!  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_FIRST_CHECK}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS_FIRST_CHECK}  time=5 min
    Log  Check alarms on SBTS passed!  console=True
    Log  All SBTS checks and actions after power ON NR were successful!  console=True

Power ON SMs
    [Documentation]
    ...  Helper Keyword used to power ON one of the 2 SMs
    [Arguments]  ${techno}

    Log  ${techno} SMs will be powered ON!  console=True
    ${alias_techno}=  Set Variable If  '${techno}' == 'NR'  Master  '${techno}' == 'SBTS'  Slave  N/A
    ${status}=  Set BTS SMs PDU port status  ${${alias_techno}_SM_PDU_if_name_list}  on
    Run Keyword If  ${status}
    ...  Log  ${techno} SMs PDU port status on, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set ${techno} SMs PDU port status on failed!  level=ERROR
    ...  AND  Fail  Set ${techno} SMs PDU port status on failed!

Step ${index}: Check NR and SBTS reset behavior based on IMS info
    [Documentation]
    ...  NR and SBTS RESET info is checked based on IMS info. Reset behavior as expected in following conditions:
    ...  - NR site: reset number is 1 (or 2 in case NR powered on first - one extra reset performed)
    ...  - SBTS site: reset number is 1
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and SBTS reset behavior based on IMS info  console=True
    Get Current Date UTC info  end
    Log  BTS RESET UTC end timestamp: ${date_timestamp_end_UTC}  console=True
    ${expected_nr_reset_number}=  Set Variable If  '${first_techno_powered_on}' == 'NR'  2  1
    Get and check BTS RESET info from IMS file  expected_reset_number=${expected_nr_reset_number}  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Perform SBTS commissioning to initial scf
    [Documentation]
    ...  Helper Keyword used to return to initial SBTS config

    Log  Performing SBTS commissioning with initial scf  console=True
    ${bts_id}=  Get Id For Current  BTS  timeout=60  alias=Slave
    Set Test Variable  ${bts_id}
    coam.Perform Commissioning  bts_id=${bts_id}  scf_file=${slave_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  alias=Slave
    Log  SBTS commissioning has been performed  console=True

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

Particular Teardown
    Run Keyword And Continue On Failure  Recover BTS SMs PDU port status  ${Master_SM_PDU_if_name_list}  on  Master
    Run Keyword And Continue On Failure  Recover BTS SMs PDU port status  ${Slave_SM_PDU_if_name_list}  on  Slave
    Run Keyword And Continue On Failure  Export ResetTime Results Global
    Run Keyword And Continue On Failure  Perform SBTS commissioning to initial scf
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  Master
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  Slave
    Check all BTS cells availability status online

TC Teardown
    Common Test Teardown