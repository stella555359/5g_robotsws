*** Settings ***
Documentation
...  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3959161/
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1 Baseband Module Reset
...  Perform baseband module reset without graceful shutdown from Admin API with desired procedure timeout.
...  Selected baseband module serial numbers are going to be tested.
...
...  Step 2 BTS Availability Check After Baseband Module Reset
...  Checking all cells, modules and faults. After that if are incorrect test fail, otherwise test pass.
...  KPIbbmodreset is gathered and varificated on user demand.
...
...  possible variables available to set by user:
...  'BBMOD_STARTUP_TIMEOUT'  ( seconds )-   startup site reset time defined for tested configuration,
...  if not provided default value from varaibles file will be use, - seconds
...  'CUSTOM_EXPECTED_BBMOD_RESET_TIME'  ( seconds ) -  expected value for startup kpi1c,
...  if not provided testcase will not use startup value as verdict
...  'CUSTOM_KPI_CALCULATION'  -  (${TRUE} or ${FALSE}) - user can disable kpi calculation
...  'BB_LIST' - user can select desired sn of BBMOD for testing. If not set all BBMODs are taken.
...
...  Disclaimer: Exceptionaly this TC is imported in testcase 'SiSo_STARTUP_Site_Reset_With_Graceful_Shutdown.robot'
...  for reuse purposes. If any corrections needed consider verification in both TCs.
...
...  NOTE. If test used with OBSAI RUs (dual link), fault 1811 Warning can appear. Please adjust accordingly your TS allowed faults.
...
...  ******************
...  History of changes
...  ******************
...  - 07.05.2024 - Initial creation
...  - 16.10.2024 - Correction according Graceful Cell Shutdown - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-12347
...  - 26.11.2024 - Adding documentation extension regarding fault 1811 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-48966

*** Variables ***
${BBMOD_STARTUP_TIMEOUT}
#${CUSTOM_EXPECTED_BBMOD_RESET_TIME}
${CUSTOM_KPI_CALCULATION}=  ${TRUE}
@{BB_LIST}

*** Keywords ***
Automated_SiSo_BTS_Startup_Multiple_Baseband_Module_Reset
    Set Tags  AUTHOR-daniel.bartkowiak@nokia.com  MAINTAINER-daniel.bartkowiak@nokia.com
    Common Test Setup
    ${bb_modules_dict}=  Baseband Module Reset Preconditions
    FOR  ${bb_sn}  IN  @{bb_modules_dict}
      Step 1 Baseband Module Reset  bb_dict=${bb_modules_dict['${bb_sn}']}  bb_sn=${bb_sn}  graceful=${FALSE}
      Step 2 BTS Availability Check After Baseband Module Reset  bts=${bb_modules_dict['${bb_sn}']['bb_bts']}  bb_sn=${bb_sn}
    END
    [Teardown]  Common Test Teardown

Step 1 Baseband Module Reset
    [Arguments]  ${bb_dict}  ${bb_sn}  ${graceful}
    Logging With Timestamp
    ...  message=Step 1 Baseband Module Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Baseband module reset for ${bb_sn} will be executed. Graceful Shutdown is ${graceful}. Please wait...
    ...  style=ONGOING
    ${bb_reset_status}  ${bb_reset_response}=  Run Keyword And Ignore Error   admin.Reset Unit
    ...  dist_name=${bb_dict['bb_distname']}
    ...  reset_type=Warm
    ...  detailed_output=True
    ...  graceful_cell_shutdown=${graceful}
    ...  timeout=${BBMOD_STARTUP_TIMEOUT}
    ...  connection=${bb_dict['bb_bts']}
    Run Keyword If  '${bb_reset_status}'=='FAIL'  Run Keywords  Logging With Timestamp
    ...  message=Baseband module reset for ${bb_sn} failed. Graceful Shutdown is ${graceful}. Response from API: ${bb_reset_response}
    ...  style=ERROR
    ...  AND  Fail  Baseband module reset for ${bb_sn} failed. Graceful Shutdown is ${graceful}. Response from API: ${bb_reset_response}
    Logging With Timestamp
    ...  message=Baseband module reset for ${bb_sn} finished. Graceful Shutdown is ${graceful}. Response from API: ${bb_reset_response}
    ...  style=DONE

Step 2 BTS Availability Check After Baseband Module Reset
    [Arguments]  ${bts}  ${bb_sn}
    Logging With Timestamp
    ...  message=Step 2 BTS Availability Check After Baseband Module Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site state verification after baseband module ${bb_sn} reset.
    ...  style=ONGOING
    CM BTS Admin Not Available
    ...  node=${bts}
    ...  timeout=120
    Run Keyword And Continue On Failure    STATE Verify BTS states
    ...  node_id=${bts}
    ...  expected_BTS_status=OnAir
    ...  HW_check=${TRUE}
    ...  cells_check=${TRUE}
    ...  scf_check=${FALSE}
    ...  timeout=${BBMOD_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=Site state verification after baseband module ${bb_sn} reset.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Site faults state verification after baseband module ${bb_sn} reset.
    ...  style=ONGOING
    FM Check Unexpected And Historical Faults
    ...  node_id=${bts}
    ...  delay=0
    Logging With Timestamp
    ...  message=Site faults verification after baseband module ${bb_sn} reset.
    ...  style=DONE
    Return From Keyword If  not ${CUSTOM_KPI_CALCULATION}
    Logging With Timestamp
    ...  message=KPI calculation start.
    ...  style=ONGOING
    admin.Collect Infomodel Log From Current Session
    ...  connection=${bts}
    ...  target_file_name=${TEST_LOGS_PATH}/BTSFiles/${bts}/ims_kpi_${bb_sn}.ims2
    ...  timeout=120
    kpi.Clear Results
    Run Keyword And Continue On Failure  kpi.Calculate Kpibbmodreset
    ...  ims_file_path=${TEST_LOGS_PATH}/BTSFiles/${bts}/ims_kpi_${bb_sn}.ims2
    ${kpibbmodreset}=  kpi.Get All Deltas  kpi_name=kpibbmodreset
    ${bb_reset_start_to_stop}=  Run Keyword And Continue On Failure  Set Variable  ${kpibbmodreset[0]}
    ${check_startup_time}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_EXPECTED_BBMOD_RESET_TIME}
    ${startup_values_comparison}=  Run Keyword If  ${check_startup_time}
    ...  Set Variable If  ${bb_reset_start_to_stop} > ${CUSTOM_EXPECTED_BBMOD_RESET_TIME}  Fail  Pass
    ${test_verdict_log_level}=  Set Variable If  '${startup_values_comparison}' == 'Fail'  WARN  INFO
    Run Keyword And Continue On Failure  Run Keyword If   "${startup_values_comparison}" == "Fail" and ${check_startup_time}
    ...  Run Keywords
    ...  Logging With Timestamp
    ...  message=Specified startup time (${CUSTOM_EXPECTED_BBMOD_RESET_TIME} seconds) exceeded. Executed startup time was: ${bb_reset_start_to_stop}
    ...  style=FAIL
    ...  AND
    ...  Fail  Specified startup time (${CUSTOM_EXPECTED_BBMOD_RESET_TIME} seconds) exceeded. Executed startup time was: ${bb_reset_start_to_stop}
    Logging With Timestamp
    ...  message=Time from reset procedure start to reset procedure stop (kpibbmodreset) = ${bb_reset_start_to_stop}.
    Run Keyword If  ${check_startup_time}
    ...  Logging With Timestamp    message=Expecterd time set by user = ${CUSTOM_EXPECTED_BBMOD_RESET_TIME}  level=${test_verdict_log_level}
    ${tmp_it_dict}=    Create Dictionary    &{EMPTY}
    Set To Dictionary    ${tmp_it_dict}
    ...  kpibbmodreset=${bb_reset_start_to_stop}
    ...  verdict=${startup_values_comparison}
    Logging With Timestamp   message=${tmp_it_dict}    console=${FALSE}  output_file=tc_verdicts_report.txt
    Logging With Timestamp
    ...  message=KPI calculation finished.
    ...  style=DONE

Get Baseband Module Runtime Distname
    [Arguments]  ${bts}  ${bb_sn}
    [Documentation]
    ...  Description:
    ...  KW returns runtime distname of BB card with specified serial number from desired bts. KW fails when bb card not found
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bts          | Yes   | ID of desired BTS                                                                             |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | bb_sn        | Yes   | BB card serial number to search for.                                                          |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+------------------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                                    |
    ...  +=====================+================================================================================================+
    ...  | dist_name           | String with runtime distname of BB card                                                        |
    ...  +---------------------+------------------------------------------------------------------------------------------------+

    ${bb_parameters_list}=  admin.Get Parameters For All  BBMOD  connection=${bts}
    FOR  ${key}  IN  @{bb_parameters_list}
      ${dist_name}=  Set Variable  ${key.id}
      Return From Keyword If  '${bb_sn}'=='${key.serialNumber}'  ${dist_name}
    END
    Logging With Timestamp
    ...  message=BBMOD ${bb_sn} not found on ${bts}.
    ...  style=ERROR
    Fail  BBMOD ${bb_sn} not found on ${bts}.

Get BTS For BBMOD
    [Arguments]  ${bb_sn}
    [Documentation]
    ...  Description:
    ...  KW returns id of BTS which BB belongs to. KW finds BTS ID based on CFG dictionary. If not found KW returns empty value.
    ...  Arguments:
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument     | Man.  | Description                                                                                   |
    ...  +==============+=======+===============================================================================================+
    ...  | bb_sn        | Yes   | BB card serial number to search for.                                                          |
    ...  +--------------+-------+-----------------------------------------------------------------------------------------------+
    ...  Return:
    ...  +---------------------+------------------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                                    |
    ...  +=====================+================================================================================================+
    ...  | id                  | String with runtime distname of BB card                                                        |
    ...  +---------------------+------------------------------------------------------------------------------------------------+

    FOR  ${id}  IN  @{CFG['NODES']}
      Return From Keyword If  '${bb_sn}' in ${CFG['NODES']['${id}']['scf_hw_bbmod_list']}  ${id}
    END
    ${id}=  Set Variable  ${EMPTY}
    [Return]  ${id}

Baseband Module Reset Preconditions
    [Documentation]
    ...  Description:
    ...  KW returns BB cards dictionary with required data used for further usage. Dictionary structure is:
    ...  key (bb_sn) and value (dictionary with distname and bts id). KW fails if BB card not found.
    ...  Return:
    ...  +---------------------+------------------------------------------------------------------------------------------------+
    ...  | Return Value        | Description                                                                                    |
    ...  +=====================+================================================================================================+
    ...  | bb_modules_dict     | Dictionary with BB card data (sn, distname, bts id)                                            |
    ...  +---------------------+------------------------------------------------------------------------------------------------+

    ${bb_list_status}=  Run Keyword And Return Status  Should Not Be Empty  ${BB_LIST}
    ${final_bb_list}=  Set Variable If  ${bb_list_status}  ${BB_LIST}  ${CFG['scf_hw_all_bbmod_list']}
    Logging With Timestamp
    ...  message=Baseband module reset TC for each ${final_bb_list} will be executed
    ...  style=ONGOING
    ${bb_modules_dict}=  Create Dictionary
    FOR  ${bb_sn}  IN  @{final_bb_list}
      ${bb_module_dict}=  Create Dictionary
      ${bb_bts}=  Get BTS For BBMOD  bb_sn=${bb_sn}
      Run Keyword If  '${bb_bts}'=='${EMPTY}'  Run Keywords  Logging With Timestamp
      ...  message=Baseband module ${bb_sn} not found in tested configuration
      ...  style=ERROR
      ...  AND  Fail  Baseband module ${bb_sn} not found in tested configuration
      ${bb_distname}=  SiSo_STARTUP_Baseband_Module_Reset.Get Baseband Module Runtime Distname  bts=${bb_bts}  bb_sn=${bb_sn}
      Set To Dictionary  ${bb_module_dict}  bb_bts=${bb_bts}  bb_distname=${bb_distname}
      Set To Dictionary  ${bb_modules_dict}  ${bb_sn}=${bb_module_dict}
    END
    [Return]  ${bb_modules_dict}
