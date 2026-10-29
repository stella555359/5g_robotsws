*** Settings ***
Documentation
...  The purpose of this test case is verification influence Energy Saving Mode on 4G, 5G cells.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Library     taf.selenium.sbts  WITH NAME  selenium_coam

*** Variables ***
${RMOD_SN}           # list of tested RMOD's serial numbers separated by a comma eg. EA200262091,BL1909V001Y - fill by tester
${LTE_CELL_ID}       # LNCEL Number for example 15557,15558 if empty test is activated MicroDtx for all LNCEL - fill by tester
${5G_CELL_ID}        # NRCEL Number for example 15557,15558 if empty test is activated MicroDtx for all LNCEL - fill by tester
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password
${node}  default
${SKIP_LTE}  False
${SKIP_5G}  False
${EXTENDED_SLEEP_TIME}  0
@{RADIOS_NOT_SUPPORTING_DEEPSLEEP_SN_LIST}  @{EMPTY}  # list of RMOD's serial numbers which do not support DEEPSLEEP mode

*** Keywords ***
TC__SiSo_PM_of_Cell_Availability_monitoring_with_Energy_Efficiency_Enhancement
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is verification influence Energy Saving Mode on 4G, 5G cells.
    ...  Cells are switched-off (LTE1103, 5GC000431) and after the expected statuses appear:
    ...  operationalState=disabled, availabilityStatus=off line specific counters are get and verified:
    ...
    ...  4G Counters:
    ...  SAMPLES_CELL_POWER_SAVING (M8020C7) - indicates the number of samples when the cell is in the "power saving mode",
    ...  it is incremented by 1 approx. every second when the cell: OperationalState=disabled, EnergySavingState=energySaving.
    ...  SAMPLES_CELL_PLAN_UNAVAIL (M8020C4) - indicates the number of samples when the cell is unavailable due to any planned event,
    ...  it is incremented by 1 approx. every second when the cell state changes to: AdministrativeState=locked, EnergySavingState=energySaving.
    ...
    ...  M8020C7 and M8020C4 should be similar (the permissible difference between them is a maximum of 2).
    ...
    ...  5G Counters:
    ...  SAMPLES_NR_CELL_POWER_SAVING (M55601C00501) - number of samples when the NR cell is in the "power saving mode" state,
    ...  it is incremented by 1 approx. every second when the NR cell: operationalState=disabled, energySavingState=energySaving.
    ...  NR_CELL_PLAN_UNAVAIL_SAMPLES (M55601C01001) - number of samples when the NR cell is unavailable due to any operator-planned event,
    ...  it is incremented by 1 every second when an NR cell is unavailable because of e.g.: administrativeState=Locked.
    ...  NR_CELL_AVAIL_CHNG_TO (M55601C00503) - number of cell state changes to available,
    ...  it is incremented immediately when a new state is reached.
    ...
    ...  According to EDA 03759924 verification of additional counters has been added:
    ...  CHNG_TO_NR_CELL_POWER_SAVING (M55601C00502) - number of NR cell state changes to "power saving mode",
    ...  incremented by 1 when the NR cell: operationalState=disabled, energySavingState=energySaving.
    ...  NR_CELL_UNPLAN_UNAVAIL_SAMPLES (M55601C01003) - number of samples when the NR cell is unavailable due to any unplanned event,
    ...  it is incremented by 1 approx. every second when an NR cell is unplanned unavailable, expected value is 0.
    ...  NR_CELL_UNPLAN_UNAVAIL_CHNG_TO (M55601C01004) - number of times when a NR cell becomes unavailable due to any unplanned event,
    ...  it is incremented by 1 when NR cell becomes unplanned unavailable, expected value is 0.
    ...
    ...  M55601C00501 and M55601C01001 should be similar (the permissible difference between them is a maximum of 2).
    ...  NR_CELL_AVAIL_CHNG_TO (M55601C00503) should be equal to the number of cell status changes to 'available'.
    ...
    ...  It is required that the following parameters are completed in the configuration by the Tester:
    ...  actNrLBPowerSaving=True
    ...  actLBPowerSaving=True
    ...  EnergySavingMode=DeepSleep
    ...  miNrCellAvailability=30min
    ...  mtCellAvailability=30min
    ...  For 4G objects: PSGRP-0, PSGRP-1, etc. must be created with all mandatory parameters needed to perform switch-off cells,
    ...  need also contain all testing cells (lbpsPeriodList). One object PSGRP corresponds to one RMOD.
    ...  For 5G objects: NRPGRP-0, NRPGRP-1, etc. must be created with all mandatory parameters needed to perform switch-off cells,
    ...  need also contain all testing cells (lbpsPeriodList). One object NRPGRP corresponds to one RMOD.
    ...  In objects NRPGRP, PSGRP one 'Structure' needs to exist with filled parameters:
    ...  lbpsDayOfWeek, lbpsDuration, lbpsStartTimeHour, lbpsStartTimeMinute, lbpsSuspended.
    ...  NOTE. The parameter lbpsDuration should be set to value 15 (minutes) in every NRPGRP/PSGRP object.
    ...
    ...  During test execution the following parameters in objects: NRPGRP, PSGRP will be updated:
    ...  lbpsDayOfWeek, lbpsStartTimeHour, lbpsStartTimeMinute.
    ...
    ...  If the tester wants to test only LTE or 5G cells, the tester should set the following variables:
    ...  For skipping LTE: ${SKIP_LTE}  True
    ...  For skipping 5G:  ${SKIP_5G}  True
    ...
    ...  If the waiting time to RMODS to go to SLEEP mode is too low, tester should extend the time
    ...  by seting the variable ${EXTENDED_SLEEP_TIME} to desired value in minutes. e.g. ${EXTENDED_SLEEP_TIME}  5
    ...  NOTE. O-RAN radios do not support DEEPSLEEP mode, so user should add them to @{RADIOS_NOT_SUPPORTING_DEEPSLEEP_SN_LIST}
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-5707 - Initial creation
    ...  - 04.11.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-10465 - EDA 03759924 implementation
    ...  - 21.05.2025 - Added posibility to test only LTE or 5G cells
    ...  - 25.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-49344 - change of service around midnight
    ...  - 11.06.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-32475 - fix for AWHQN

    Set Tags  CA-BS-RF  OWNER-malgorzata.piecyk-celuch@nokia.com  AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...  MAINTAINER-malgorzata.piecyk-celuch@nokia.com  PHASE-CRT  SW-SBTS25  BS-RF  CB013240  EDA03759924

    Step 1: Test Case Preconditions
    Step 2: Perform Switch-Off Cells
    Step 3: Get And Verify Counters


Step 1: Test Case Preconditions
    Log  ${\n}Step 1: Test Case Preconditions  console=True
    Log       -------------------------------${\n}  console=True

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    Log  Get RMOD(s) and cell(s) info  console=True
    ${radios_sn}  Split String  ${RMOD_SN}  ,
    &{rmods_info}  Create Dictionary
    FOR  ${test_radio}  IN  @{radios_sn}
        ${rmod_internal_id}  ${rmod_config_id}  Get RU Internal Dist And RU Configuration Dist  ${test_radio}  alias=${node}
        Set To Dictionary  ${rmods_info}  ${rmod_config_id}  ${rmod_internal_id}
    END
    Set Test Variable  ${RMODS_INFO}
    IF  not ${SKIP_LTE}
        ${lte_cells_id}  Run Keyword If  '${LTE_CELL_ID}'=='${EMPTY}'  Create CELL List  rat_cell=LNCEL
        ...  ELSE  Convert CELL List  ${LTE_CELL_ID}
        Set Test Variable  ${LTE_CELLS_ID}
    ELSE
        Log  ${\n}LTE cells will be skipped!  console=True
    END

#    ${lte_cells_id}  Run Keyword If  '${LTE_CELL_ID}'=='${EMPTY}'  Create CELL List  rat_cell=LNCEL
#    ...  ELSE  Convert CELL List  ${LTE_CELL_ID}
#    Set Test Variable  ${LTE_CELLS_ID}

    IF  not ${SKIP_5G}
      ${nr_cells_id}  Run Keyword If  '${5G_CELL_ID}'=='${EMPTY}'  Create CELL List  rat_cell=NRCEL
      ...  ELSE  Convert CELL List  ${5G_CELL_ID}
      Set Test Variable  ${NR_CELLS_ID}
    ELSE
        Log  ${\n}5G cells will be skipped!  console=True
    END


#    ${nr_cells_id}  Run Keyword If  '${5G_CELL_ID}'=='${EMPTY}'  Create CELL List  rat_cell=NRCEL
#    ...  ELSE  Convert CELL List  ${5G_CELL_ID}
#    Set Test Variable  ${NR_CELLS_ID}

    ${all_cells}  Create List
    FOR  ${distname}  IN  @{RMODS_INFO.values()}
       ${rmod_cells}  Get All Cells Mapping By RMOD Id  ${distname}
       ${all_cells}  Combine Lists  ${all_cells}  ${rmod_cells}
    END
    Set Test Variable  ${CELLS_DISTNAME_ID}  ${all_cells}

Step 2: Perform Switch-Off Cells
    Log  ${\n}Step 2: Perform Switch-Off Cells  console=True
    Log       --------------------------------  console=True

    Log  Set parameters Of PSGRP and NRPGRP and perform Switch-Off Cells${\n}  console=True
    ${hours}  ${minutes}  ${short_day}  ${final_time}  Set Time Components

    @{PowerSavingGroups_list}  Create List
    FOR  ${index}  IN RANGE  10
      IF  not ${SKIP_LTE}
          ${PSGRP_object}  Set Variable  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/PSGRP-${index}
          ${PSGRP_info}  admin.Get Parameter By Distname  ${PSGRP_object}  connection=${node}
          ${PSGRP_exist}  Evaluate  bool(${PSGRP_info})
          Run Keyword If  ${PSGRP_exist}  Append To List  ${PowerSavingGroups_list}  ${PSGRP_object}
      END
      IF  not ${SKIP_5G}
          ${NRPGRP_object}  Set Variable  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRPGRP-${index}
          ${NRPGRP_info}  admin.Get Parameter By Distname  ${NRPGRP_object}  connection=${node}
          ${NRPGRP_exist}  Evaluate  bool(${NRPGRP_info})
          Run Keyword If  ${NRPGRP_exist}  Append To List  ${PowerSavingGroups_list}  ${NRPGRP_object}
          ...  ELSE  Exit For Loop
      END
    END

    Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/selenium/PSG
    FOR  ${PSG_object}  IN  @{PowerSavingGroups_list}
      selenium_coam.Set Parameter Value  ${PSG_object}
      ...  filter_param=Load-based power saving day of week  abbr=lbpsDayOfWeek  new_value=${short_day}
      selenium_coam.Set Parameter Value  ${PSG_object}
      ...  filter_param=Load-based power saving start time hour  abbr=lbpsStartTimeHour  new_value=${hours}
      selenium_coam.Set Parameter Value  ${PSG_object}
      ...  filter_param=Load-based power saving start time minute  abbr=lbpsStartTimeMinute  new_value=${minutes}
    END
    selenium_coam.Validate Plan
    selenium_coam.Activate Plan
    Selenium Logout And Close Browser

    ${minutes_left}  Calculate Minutes For Wait  ${hours}  ${minutes}
    Log  ${\n}Waiting for ${minutes_left} minutes until cells switching-off will start proceed!  console=True
    Log  Verdict will be released at: ${final_time}${\n}  console=True
    Sleep  ${minutes_left} min

    Log  Wait until cells switch-off...  console=True
    FOR  ${cell}  IN  @{CELLS_DISTNAME_ID}
       ${cell_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  7 min  30 s  Check If Cell Is In Power Saving Mode  ${cell}
       Run Keyword If  '${cell_status}'=='True'
        ...  Log  ${cell} has correct status, is in power saving mode  console=True
        ...  ELSE  Run Keywords
        ...  Log  ${cell} has incorrect status, should in power saving mode${\n}  console=True
        ...  AND  Fail  ${cell} has incorrect status, should be in power saving mode
    END

    Sleep  6m  Waiting for SLEEP mode on RMOD(s)
    Log  Extended ${EXTENDED_SLEEP_TIME} minutes waiting for SLEEP mode on RMOD(s)  console=True
    Sleep  ${EXTENDED_SLEEP_TIME}m
    Log  ${\n}Checking power state of RMOD(s):${\n}  console=True
    FOR  ${rmod}  ${distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
       ${output}=  admin.Get Parameters For
       ...  class_name=RMOD
       ...  id_num=${distname}
       ...  connection=default
       IF  '${output['serialNumber']}' in @{RADIOS_NOT_SUPPORTING_DEEPSLEEP_SN_LIST}
         Log  ${rmod} doesn't support DEEPSLEEP mode. Verification skipped.  console=True
         Continue For Loop
       END
       Log  Checking ${rmod}, required power state is SLEEP - wait for verdict  console=True
       Wait Until Keyword Succeeds  3 min  20 s
       ...  Check Rmod Power State  distname=${distname}  expected_powerState=SLEEP
    END

Step 3: Get And Verify Counters
    Log  ${\n}Step 3: Get And Verify Counters  console=True
    Log       -------------------------------  console=True

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  15  15
    Log  Waiting for ${time_to_sleep} minutes to Get Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !${\n}  console=True
    Sleep  ${time_to_sleep} min

    IF  not ${SKIP_LTE}
      Get And Verify 4G Counters
    END
    Log  ------------------------------------------${\n}  console=True
    IF  not ${SKIP_5G}
      Get And Verify 5G Counters
    END

Get And Verify 4G Counters
    Log  ===== 4G counters will be collected! =====${\n}  console=True

    @{4G_counters_list}  Create List
    Append To List  ${4G_counters_list}  M8020C7  M8020C4

    @{M8020C7_val_list}  Create List
    @{M8020C4_val_list}  Create List
    Set Test Variable  @{M8020C7_VAL_LIST}
    Set Test Variable  @{M8020C4_VAL_LIST}

    FOR  ${counter_name}  IN  @{4G_counters_list}
      Log  --- Counter ${counter_name} will be collected and verified ---  console=True
      ${counter_dict}  admin.Get Pm Counters  ${counter_name}  alias=${node}
      Verify 4G counters  counter_name=${counter_name}  counter_dict=${counter_dict}
    END
    Compare Counters Values  first_values_list=${M8020C7_VAL_LIST}  second_values_list=${M8020C4_VAL_LIST}

Verify 4G counters
    [Arguments]  ${counter_name}  ${counter_dict}

    &{cells_PIM_dict}  Create Dictionary
    FOR  ${cell_id}  IN  @{LTE_CELLS_ID}
      ${LTE_object_dict}  Set Variable  ${counter_dict['BTS']['MRBTS-${BTS_ID}']['LNBTS-${BTS_ID}']['LNCEL-${cell_id}']}
      Set To Dictionary  ${cells_PIM_dict}  ${cell_id}  ${LTE_object_dict}
    END
    FOR  ${cell}  ${counters}  IN ZIP  ${cells_PIM_dict.keys()}  ${cells_PIM_dict.values()}
      ${counters_path_LTE_object}  Get Dictionary Values  ${counters}
      ${counters_path}  Get Dictionary Values  ${counters_path_LTE_object}[0]
      ${counters_name_with_values}  Get Dictionary Values  ${counters_path}[0]
      ${counters_name}  Get Dictionary Keys  ${counters_name_with_values}[0]
      ${values}  Get Dictionary Values  ${counters_name_with_values}[0]
      ${req_counters_status}  Run Keyword And Return Status  Should Contain Match  ${counters_name}  ${counter_name}
      Run Keyword If  '${req_counters_status}'=='False'  Log  There is no expected counters - ${counters_name}!
      ...  AND  Fail  There is no expected counters - ${counter_name}!${\n}
      ${counters_values}  _Unzip List Of Dicts  ${values}
      Check No Zero Value  ${counters_values}
      Run Keyword If  '${counter_name}'=='M8020C7'  Append To List  ${M8020C7_VAL_LIST}  ${counters_values}[-1]
      ...  ELSE IF  '${counter_name}'=='M8020C4'  Append To List  ${M8020C4_VAL_LIST}  ${counters_values}[-1]
      ...  ELSE  Run Keywords  Log  There is no required counter for analysis, TC failed!  console=True
      ...  AND  Fail  There is no required counter for analysis, TC failed!
    END

Get And Verify 5G Counters
    Log  ===== 5G counters will be collected! =====${\n}  console=True

    @{5G_counters_list}  Create List
    Append To List  ${5G_counters_list}  M55601C00501  M55601C01001  M55601C00503  M55601C00502  M55601C01003  M55601C01004

    @{M55601C00501_val_list}  Create List
    @{M55601C01001_val_list}  Create List
    Set Test Variable  @{M55601C00501_VAL_LIST}
    Set Test Variable  @{M55601C01001_VAL_LIST}

    FOR  ${counter_name}  IN  @{5G_counters_list}
      Log  --- Counter ${counter_name} will be collected and verified ---  console=True
      ${counter_dict}  admin.Get Pm Counters  ${counter_name}  alias=${node}
      Verify 5G counters  counter_name=${counter_name}  counter_dict=${counter_dict}
    END
    Compare Counters Values  first_values_list=${M55601C00501_VAL_LIST}  second_values_list=${M55601C01001_VAL_LIST}

Verify 5G counters
    [Arguments]  ${counter_name}  ${counter_dict}

    &{cells_PIM_dict}  Create Dictionary
    FOR  ${cell_id}  IN  @{NR_CELLS_ID}
      ${5G_object_dict}  Set Variable  ${counter_dict['BTS']['MRBTS-${BTS_ID}']['NRBTS-${BTS_ID}']['NRCELL-${cell_id}']}
      Set To Dictionary  ${cells_PIM_dict}  ${cell_id}  ${5G_object_dict}
    END
    FOR  ${cell}  ${counters}  IN ZIP  ${cells_PIM_dict.keys()}  ${cells_PIM_dict.values()}
      ${counters_name_with_values}  Get Dictionary Values  ${counters}
      ${counters_name}  Get Dictionary Keys  ${counters_name_with_values}[0]
      ${values}  Get Dictionary Values  ${counters_name_with_values}[0]
      ${req_counters_status}  Run Keyword And Return Status  Should Contain Match  ${counters_name}  ${counter_name}
      Run Keyword If  '${req_counters_status}'=='False'  Log  There is no expected counters - ${counters_name}!
      ...  AND  Fail  There is no expected counters - ${counter_name}!${\n}
      ${counters_values}  _Unzip List Of Dicts  ${values}
      Run Keyword If  not '${counter_name}'=='M55601C01003' and not '${counter_name}'=='M55601C01004'  Check No Zero Value  ${counters_values}
      Run Keyword If  '${counter_name}'=='M55601C00501'  Append To List  ${M55601C00501_VAL_LIST}  ${counters_values}[-1]
      ...  ELSE IF  '${counter_name}'=='M55601C01001'  Append To List  ${M55601C01001_VAL_LIST}  ${counters_values}[-1]
      ...  ELSE IF  '${counter_name}'=='M55601C00503' or '${counter_name}'=='M55601C00502'
      ...  Check If Counter Has Expected Value  ${counters_values}  expected_value=1
      ...  ELSE IF  '${counter_name}'=='M55601C01003' or '${counter_name}'=='M55601C01004'
      ...  Check If Counter Has Expected Value  ${counters_values}  expected_value=0
      ...  ELSE  Run Keywords  Log  There is no required counter for analysis, TC failed!  console=True
      ...  AND  Fail  There is no required counter for analysis, TC failed!
    END

Compare Counters Values
    [Arguments]  ${first_values_list}  ${second_values_list}
    Log  ${\n}Compare counters by checking if their values differ by a maximum of 2  console=True
    ${length}  Get Length  ${first_values_list}
    FOR  ${index}  IN RANGE  ${length}
        ${first_value_list}  Get From List  ${first_values_list}  ${index}
        ${second_value_list}  Get From List  ${second_values_list}  ${index}

        ${val_difference}  Evaluate  abs(${first_value_list}-${second_value_list}) <=2
        Run Keyword If  ${val_difference}  Log  The difference in values between counters is within the assumed range  console=True
        ...  ELSE  Run Keywords  Log  The difference in values between counters is out of range! TC failed!  console=True
        ...  AND  Fail  The difference in values between counters is out of range! TC failed!
    END

Check If Counter Has Expected Value
    [Arguments]  ${counters_values}  ${expected_value}
    Log  ${\n}Check if counter has correct value: ${expected_value}  console=True
    ${check_value}  Evaluate  ${counters_values}[-1]==${expected_value}
    Run Keyword If  'False' in '${check_value}'  Run Keywords
    ...  Fail  Counters value is not correct, should be ${expected_value}! TC failed!
    ...  AND  Log  Counters value is not correct, should be ${expected_value}! TC failed!  console=True
    ...  ELSE  Log  Counters value is correct: ${expected_value}!  console=True

Check No Zero Value
    [Arguments]  ${values}
    Log  ${\n}Check if counters values are positive number...  console=True
    ${positive_number}  Evaluate  ${values}[-1]!=0
    Run Keyword If  'False' in '${positive_number}'  Run Keywords
    ...  Fail  Counters value is zero! TC failed!
    ...  AND  Log  Counters value is zero! TC failed!  console=True
    ...  ELSE  Log  Counters value is correct!  console=True

_Unzip List Of Dicts
    [Arguments]  ${values}
    ${raw_list_all_values}  Create List
    FOR  ${item}  IN  @{values}
        ${all_values}  Get Dictionary Values  ${item}
        Append To List  ${raw_list_all_values}  ${all_values}
    END
    ${list_all_values}  Evaluate  [item for sublist in ${raw_list_all_values} for item in sublist]

    [Return]  ${list_all_values}

Get RU Internal Dist And RU Configuration Dist
    [Arguments]  ${rmod_sn}  ${alias}
    ${all_ru_params}  admin.Get FRM  60  ${alias}
    FOR  ${rmod}  IN  @{all_ru_params}
        Continue For Loop If  '${rmod_sn}'!='${rmod['serialNumber']}'
        ${rmod_internal_id}  Set Variable  ${rmod['id']['internal']}
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
    END
    [Return]  ${rmod_internal_id}  ${rmod_config_id}

Check If Cell Is In Power Saving Mode
    [Arguments]  ${cell}
    ${class_id}  Evaluate  '${cell}'.split('/')[-1].split('_')[0]
    Run Keyword If  '${class_id}'=='NRCELL'
    ...  admin.Assert  NRCEL  ${cell}  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled",
    ...  energySavingState=regex"(?i)energySaving"
    ...  ELSE
    ...  admin.Assert  ${class_id}  ${cell}  availabilityStatus=regex"(?i)off line", operationalState=regex"(?i)disabled",
    ...  energySavingState=regex"(?i)energySaving"

Set Time Components
    ${current_time}  Get Current Date  result_format=%H:%M
    ${current_day}  Get Current Date  result_format=%A
    ${hours}  Convert To Integer  ${current_time.split(':')[0]}
    ${minutes}  Convert To Integer  ${current_time.split(':')[1]}
    Run Keyword If  ${minutes}>=0 and ${minutes}<20  Set Test Variable  ${minutes}  31
    ...  ELSE IF  ${minutes}>=20 and ${minutes}<50  Run Keywords  Set Test Variable  ${minutes}  1  AND  Set Test Variable  ${hours}  ${hours+1}
    ...  ELSE IF  ${minutes}>=50  Run Keywords  Set Test Variable  ${minutes}  31  AND  Set Test Variable  ${hours}  ${hours+1}
    ...  ELSE  Log  Time can not be set properly, check logs  console=True

    ${hours}  Evaluate  ${hours}%24

    ${next_day}  Run Keyword If  ${hours}==0  Set Variable  False
    ...  ELSE  Set Variable  False
    @{days_of_week}  Create List  Monday  Tuesday  Wednesday  Thursday  Friday  Saturday  Sunday
    ${current_day_index}  Evaluate  @{days_of_week}.index("${current_day}")
    ${new_day_index}  Evaluate  (${current_day_index} + 1) % 7
    ${new_day}  Get From List  ${days_of_week}  ${new_day_index}
    ${current_day}  Run Keyword If  ${next_day}  Set Variable  ${new_day}  ELSE  Set Variable  ${current_day}

    ${short_day}  Set Variable  ${current_day[:3]}
    ${final_time}  Run Keyword If  ${minutes}<10  Set Variable  ${hours}:0${minutes}
    ...  ELSE  Set Variable  ${hours}:${minutes}
    [Return]  ${hours}  ${minutes}  ${short_day}  ${final_time}

Calculate Minutes For Wait
    [Arguments]  ${target_hours}  ${target_minutes}
    ${current_time}  Get Current Date  result_format=%H:%M
    ${current_hours}  Convert To Integer  ${current_time.split(':')[0]}
    ${current_minutes}  Convert To Integer  ${current_time.split(':')[1]}
    ${current_total_minutes}  Evaluate  ${current_hours}*60+${current_minutes}
    ${target_total_minutes}  Evaluate  ${target_hours}*60+${target_minutes}

    ${minutes_left}  Evaluate  ${target_total_minutes}-${current_total_minutes}
    ${minutes_left}  Run Keyword If  ${minutes_left}<0  Evaluate  ${minutes_left}+1440
    ...  ELSE  Set Variable  ${minutes_left}
    [Return]  ${minutes_left}

Create CELL List
    [Arguments]  ${rat_cell}
    @{CELLS_ID}  Create List  @{EMPTY}
    ${cells}  admin.Get Ids For All  ${rat_cell}  search_for_iot_cells=${True}
    FOR  ${cell}  IN  @{cells}
        ${cell}  Fetch From Right  ${cell}  -
        Append To List  ${CELLS_ID}  ${cell}
    END
    [Return]  ${cells_id}

Convert CELL List
    [Arguments]  ${cell_id}
    ${cells_id}  Split String  ${cell_id}  ,
    [Return]  ${cells_id}

Check Rmod Power State
    [Arguments]  ${distname}  ${expected_powerState}
    ${expected_powerState}  Set Variable  ${expected_powerState.upper()}
    ${param_dict}  admin.Get Parameters  ${distname}
    ${actual_powerState}  Set Variable  ${param_dict['powerState'].upper()}
    Run Keyword If  '${actual_powerState}'=='${expected_powerState}'
    ...  Log  RMOD has correct power state - ${expected_powerState}${\n}  console=True
    ...  ELSE  Fail  ${\n}RMOD has not required power state - ${expected_powerState}

Selenium Login And Disable Screen Lock
    [Arguments]  ${download_dir}=${EMPTY}
    selenium_coam.enable_virtual_display
    ${browser}  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  screenshot_dir=${download_dir}  name=firefox_browser
    ${sw_release}  admin.Get Sw Release Name
    selenium_coam.Login  ${WEBUI_URL}  ${WEBUI_NAME}  ${WEBUI_PWD}  download_dir=${download_dir}
    ...  screenshot_dir=${download_dir}  version=${sw_release}  browser=${browser}
    ${view_exists}  selenium_coam.Start Up View Window Exists
    Run Keyword If  ${view_exists}  selenium_coam.Close Start Up View Window
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser
    Run Keyword And Ignore Error  selenium_coam.logout
    Run Keyword And Ignore Error  selenium_coam.close_browser

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
