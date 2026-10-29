*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1 Power Off Radio
...  Radio power off is executed on PDU
...  Check state of rest of radio in configuration, including chain relation,
...  which means that radio connected after tested radio also should not be visible,
...  Check Cell states - affected and not affected, Check alarm required after power off radio:
...  During shutdown, for RU CPRI, HW family: RF5.1, expected FID: 1815
...  During shutdown, for DyingGaspAlarm active expected fault: R&D 4774 visible in UDP/IMS Logs and FID 10 with "RU Power Loss"
...  During shutdown, for DyingGaspAlarm inactive expected fault: FID 1972 and FID 10 without "RU Power Loss"
...
...  Step 2 Power On Radio
...  Radio power on is executed on PDU
...  Check state of rest of radio in configuration, including chain relation,
...  which means that radio connected after tested radio also should be visible,
...  Check Cell states - affected and not affected, Check alarm required after power on radio:
...  Expected FID: 4589 is visible (supported RU family: RF_Gen4_HF, RF_Gen5_HF, RF5.1, RF6.2, RF7.1)
...  Time of radio startup is verified.
...
...  Detailed user's parameter description:
...  'KPI_REF_DICT' is a complex dictionary for calculating kpi54a and kppi54b and printing results. Example structure:
...
...  KPI_REF_DICT = {
...    'ru_sn': {'kpi54a': ['ref_time', 'tc_verdict'], 'kpi54b': ['ref_time', 'tc_verdict']},
...    'ru_sn': {'kpi54b': ['ref_time', 'tc_verdict'], 'kpi54b': ['ref_time', 'tc_verdict']}
...   }
...
...  Example of usage:
...  @{kpi54a_ru1}  125  ${TRUE}
...  @{kpi54b_ru1}  105  ${TRUE}
...  &{kpis_ru1}  kpi54a=@{kpi54a_ru1}  kpi54b=@{kpi54b_ru1}
...  &{KPI_REF_DICT}  <ru_sn>=&{kpis_ru1}
...
...  Allowed values in 'KPI_REF_DICT' (dictionary is empty by default whioch means that kpis are only printed for all RUs):
...  ru_sn (radio serial number; if ru_sn missing in dictionary, calculated kpi is only printed to cosole)
...  tc_verdict (user switch that allows to fail or not TC when calculated statrtup time exceeds 'ref_time';
...  calculated kpi is printed to console) = ${TRUE}/${FALSE}
...  ref_time (expected max time for radio to start-up;
...  if 'None' used, tc_verdict is skipped and calculated kpi is only printed to cosole) = int values/None
...
...  'CUSTOM_RADIO_UNIT_LIST' - user can add personalized list of serialNumbers for testing
...  'DYINGGASP_USER_SWITCH' - user can switch off dyingGaspAlarm verification on demand when any limitation is met.
...  list of all limitations is available in QC TC description.
...  'SKIP_KPIs' - custom switch to skip completely KPI mechanism
...  'FAULT_10_TIMEOUT' - custom timeout until fault 10 appears; if not set 200s is used
...  'RADIO_AVAILABILITY_TIMEOUT' - custom timeout for states/faults check after radio power on
...
...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
...  NOTE. Feature CB005763 limitations:
...  1. With ABIL, the feature is limitted to CPRI/FDD only; the feature doesn't support eCPRI/TDD on ABIL.
...  2. This feature heavily depends on the capabilities of the radio hardware. For CPRI radios, when the RU loses power,
...     the PSU can sustain supply for at least 1 ms, RU can send at least 15 consecutive hyperframes with power loss alarm.
...     For eCPRI radios, when the RU loses power, the PSU can sustain supply for at least 400 µs,
...     RU can send at least one ethernet message with power loss alarm.
...  3. RF family ScRMTDr6.1_2T2R, FRMTDr5.1a_1_8T8R, and FRMTDr5.1_2T2R are not supported for RF chaining, making them out of scope as well.
...  4. For the RF family FRMr5.1_1_6T6R (eg. AREA), the Dying Gasp alarm cannot be reported in the following
...     scenarios due to RU hardware limitations:
...     i. When in RF standalone configuration with the link connected to RF OPT3.
...     ii. When in RF sharing or RF split configuration with the primary link connected to RF OPT3.
...  5. With eCPRI M-Plane resilience feature enabled (CB005833), upon link failure and until switchover to the redundant link is complete,
...     there is no guarantee that dying gasp message will be successfully delivered to the DU.
...  6. The FHS does not monitor or report PSU alarm sent by a CPRI-N radio directly connected to it.
...  7. For the MAA Rel 6.2 RF Family, RU Dying Gasp Alarm won't be transmitted when RU is in Deep Sleep Mode.
...
...  Please also always check if your rmods supports dying gasp alarm. Table is available under:
...  https://nokia.sharepoint.com/:x:/r/sites/ASCOP/_layouts/15/Doc.aspx?sourcedoc=%7BCBAC57CE-BC3D-4BAB-B798-7A940B1A44FA%7D&file=
...  Radios_DyingGaspAlarm_Support.xlsx&action=default&mobileredirect=true

...
...  ******************
...  History of changes
...  ******************
...  - 08.04.2025 - Initial creation

Resource  ./../../Resources/Robot/SITE.robot
Resource  ./../../Resources/Robot/KPI.robot

*** Variables ***
${KPI_REF_DICT}                  &{EMPTY}    # dictionary with parameters for KPI control
${DYINGGASP_USER_SWITCH}         ${TRUE}     # user can turn off dyinggasp verification in case of any limitation
${SKIP_KPIs}                     ${FALSE}    # user can skip completely KPI mechanism
#@{CUSTOM_RADIO_UNIT_LIST}                   # custom radio list for testing (if empty all radios are tested)
#${FAULT_10_TIMEOUT}                         # fault 10 timeout (default 200s), set in TC setup if other timeout needed
#${RADIO_AVAILABILITY_TIMEOUT}               # timeout for radio to go onair (default 720s), set in TC setup if other timeout needed

*** Keywords ***

TC__STARTUP_Radio_Multiple_Power_Reset
    Common Test Setup
    ${radio_list}=  Radio Power Reset Preconditions
    FOR  ${ru_sn}  IN  @{radio_list}
      Step 1 Power Off Radio  ${ru_sn}
      Step 2 Power On Radio  ${ru_sn}
    END
    [Teardown]  Run Keywords  Common Test Teardown
    ...  AND  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Logging With Timestamp
    ...  message=TC FAILED. Please check limitations and dying gasp alarm support for specific RMODS before creating pronto.
    ...  style=ERROR

Radio Power Reset Preconditions
    [Documentation]  Keyword prepares precondition timeouts and returns final radio list for testing
    ${ims_dir}=  Run Keyword If  ${ITERATION}==0  Set Variable  ${CFG['test_logs_path']}
    ...  ELSE  Set Variable  ${CFG['test_logs_path']}/Loop_${ITERATION}
    Set Test Variable  ${IMS_DIR}  ${ims_dir}
    ${file_not_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Not Exist  ${CFG['test_logs_path']}/KPI_results.txt
    IF  ${file_not_exists} and not ${SKIP_KPIs}  Create File  ${CFG['test_logs_path']}/KPI_results.txt
    IF  ${ITERATION}!=0  Run Keyword And Ignore Error
    ...  Append To File
    ...  path=${CFG['test_logs_path']}/KPI_results.txt
    ...  content=+++++ LOOP ${ITERATION} +++++${\n}
    ${all_radio_list}=  Get Dictionary Keys  ${CFG['RF_INFO']}
    ${radio_status}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_RADIO_UNIT_LIST}
    ${radio_list}=  Set Variable If  ${radio_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${all_radio_list}
    [Return]  ${radio_list}

Step 1 Power Off Radio
    [Arguments]  ${ru_sn}
    Logging With Timestamp
    ...  message=Step 1 Power Off Radio
    ...  style=STEP
    ...  frame=${TRUE}
    ${bts_id_for_ru}  ${ru_runtime_distname}=  SITE Get RU Node Data  ${ru_sn}
    SITE Perform RU Power Remove  ru_sn=${ru_sn}  gasp_alarm_user_switch=${DYINGGASP_USER_SWITCH}
    SITE Verify RU Power Remove Insert State
    ...  bts_id=${bts_id_for_ru}
    ...  dist_name=${ru_runtime_distname}
    ...  state=Remove
    ...  timeout=${FAULT_10_TIMEOUT}
    SITE Verify RU Power Remove Insert State For Chain RUs
    ...  bts_id=${bts_id_for_ru}
    ...  ru_sn=${ru_sn}
    ...  state=Remove
    ...  timeout=${FAULT_10_TIMEOUT}
    SITE Verify RU Power Remove Insert Cells State
    ...  bts_id=${bts_id_for_ru}
    ...  ru_sn=${ru_sn}
    ...  state=Remove
    ...  timeout=${FAULT_10_TIMEOUT}
    SITE Verify RU Power Remove Insert Alarms
    ...  ru_bts_id=${bts_id_for_ru}
    ...  ru_sn=${ru_sn}
    ...  state=Remove
    ...  timeout=${FAULT_10_TIMEOUT}
    ...  gasp_alarm=${IS_DYINGGASPALARM}
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}'!='PASS'  SITE Perform RU Power Insert  ru_sn=${ru_sn}

Step 2 Power On Radio
    [Arguments]  ${ru_sn}
    Logging With Timestamp
    ...  message=Step 2 Power On Radio
    ...  style=STEP
    ...  frame=${TRUE}
    ${bts_id_for_ru}  ${ru_runtime_distname}=  SITE Get RU Node Data  ${ru_sn}
    ${ru_startup_start_date}=  SITE Perform RU Power Insert  ru_sn=${ru_sn}
    ${ru_status}=  Run Keyword And Return Status  SITE Verify RU Power Remove Insert State
    ...  bts_id=${bts_id_for_ru}
    ...  dist_name=${ru_runtime_distname}
    ...  state=Insert
    ...  timeout=${RADIO_AVAILABILITY_TIMEOUT}
    ${chain_status}=  Run Keyword And Return Status  SITE Verify RU Power Remove Insert State For Chain RUs
    ...  bts_id=${bts_id_for_ru}
    ...  ru_sn=${ru_sn}
    ...  state=Insert
    ...  timeout=${RADIO_AVAILABILITY_TIMEOUT}
    ${cell_status}=  Run Keyword And Return Status  SITE Verify RU Power Remove Insert Cells State
    ...  bts_id=${bts_id_for_ru}
    ...  ru_sn=${ru_sn}
    ...  state=Insert
    ...  timeout=${RADIO_AVAILABILITY_TIMEOUT}
    ${fault_status}=  Run Keyword And Return Status  SITE Verify RU Power Remove Insert Alarms
    ...  bts_id=${bts_id_for_ru}
    ...  ru_sn=${ru_sn}
    ...  state=Insert
    ...  timeout=${RADIO_AVAILABILITY_TIMEOUT}
    ...  gasp_alarm=${IS_DYINGGASPALARM}
    ${is_kpi_ref_dict}=  Run Keyword And Return Status  Variable Should Exist  ${KPI_REF_DICT['${ru_sn}']}
    ${calc_dict}=  Set Variable If  ${is_kpi_ref_dict}  ${KPI_REF_DICT['${ru_sn}']}  &{EMPTY}
    IF  '${ru_startup_start_date}'!='${0}' and not ${SKIP_KPIs}
      kpi.Clear Results
      ${kpi_result_dict}=  KPI Execute Calculation For KPI54a KPI54b
      ...  ru_startup_start_date=${ru_startup_start_date}
      ...  bts_id=${bts_id_for_ru}
      ...  ims_directory=${IMS_DIR}
      ...  calc_dict=${calc_dict}
      KPI Report Results  kpi_result_dict=${kpi_result_dict}
      KPI Save KPI Calculations To File
      ...  file_path=${CFG['test_logs_path']}/KPI_results.txt
      ...  kpi_result_dict=${kpi_result_dict}
      ...  bts_id=${bts_id_for_ru}
      ...  object_dscrp=Radio ${ru_sn}
    ELSE
      Logging With Timestamp
      ...  message=KPIs were no calculated. Parameter SKIP_KPIs is ${SKIP_KPIs}
    END
    ${step_status}=  Evaluate
    ...  "${ru_startup_start_date}" != "${0}" and ${ru_status} and ${chain_status} and ${cell_status} and ${fault_status}
    IF  not ${step_status}
      Logging With Timestamp
      ...  message="Step 2 Power On Radio" critical failure for radio ${ru_sn} occured. Stopping test.
      ...  style=ERROR
      Fail  "Step 2 Power On Radio" critical failure for radio ${ru_sn} occured. Stopping test.
    END
    [Teardown]  Run Keyword If  '${KEYWORD STATUS}'!='PASS'  SITE Perform RU Power Insert  ru_sn=${ru_sn}

