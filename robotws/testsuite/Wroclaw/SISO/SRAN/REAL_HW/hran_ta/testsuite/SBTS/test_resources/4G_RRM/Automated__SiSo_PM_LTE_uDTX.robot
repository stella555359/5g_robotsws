*** Settings ***
Documentation
...  general resources

Library    DateTime
Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../testsuite/SBTS/test_resources/5G_RRM/Automated__SiSo_5G_uDTX.robot

*** Variables ***
${TEST_CELL_ID}                ${EMPTY}    # LNCEL Number for example 15557,15558 if empty test is activated MicroDtx for all LNCEL.
${RECOMMISSIONING_TIMEOUT}     600         # Timeout for recommissioning procedure
${node}  default

*** Keywords ***
TC__SiSo_PM_LTE_uDTX
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is check impact of feature microDTX on LTE cells.
    ...  The test is related to the project: energy efficiency and was created as a refactoring of existing tests using
    ...  microDTX: Micro discontinuous transmission - Power saving.
    ...  Test case involves activate and deactivate feature, checks RM with HW release <5.1, 5.1 and 6.2.
    ...  Feature is activate when parameter 'actMicroDtx' and 'allowTrafficConcentrarion' are set on 'True'.
    ...  Parameters of 5G microDTX need to be deactivated - 'actMicroDTX' and 'actMicroDTXAdvanced'
    ...  are disabled during the test. From 25R1 release modyfication is done via Vendor File
    ...  and checking statuses of parameters is done by Info Model Viewer.
    ...  Test case checks if RMOD's power is lower, when feature is activated.
    ...  Additionally PM counters are collected and veryfied - values of counters should be different depend of MicroDtx's status:
    ...  - activated: values are in range 1-99
    ...  - deactivated: values for RM with HW release <5.1 are no visible (counter M8010C93);
    ...  values for RM with HW release <5.1 are 0 (M8010C94).
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.01.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-39283 - Initial creation
    ...  - 24.06.2024 - implementing 5G microDTX deactivation: parameters 'actMicroDTX' and 'actMicroDTXAdvanced'
    ...  - 06.08.2024 - implementing a new way to modification of parameters 5G µDTX 'actMicroDTX' and 'actMicroDTXAdvanced' -
    ...    from 25R1 release is done via vendor file (CB0013258)

    Set Tags    CA-4G_RRM    OWNER-malgorzata.piecyk-celuch@nokia.com    AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...    MAINTAINER-malgorzata.piecyk-celuch@nokia.com    PHASE-CRT    SW-SBTS24
    ...    FEATURE-CNI-110111  CB0013258

    Automated__SiSo_PM_LTE_uDTX.Step 1: Test Case Preconditions
    Step 2: Check MicroDTX status and activate MicroDTX
    Step 3: Check MicroDTX counters value when MicroDTX is activated
    Step 4: Check RMOD power consumption when MicroDTX is activated
    Step 5: Deactivate MicroDtx - SBTS recommissioning
    Step 6: Check MicroDTX counters value when MicroDTX is deactivated
    Step 7: Check RMOD power consumption when MicroDTX is deactivated and compare
    Restore MicroDTX to initial status


Step 1: Test Case Preconditions
    Log  ${\n}Step 1: Test Case Preconditions  console=True
    Log       -------------------------------${\n}  console=True

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}
    Set Test Variable  ${FEATCADM_OBJECT}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    ${par_actPowerMeter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${par_actPowerMeter}
    ${apm_status}  Evaluate Xpath  ${scfc_xml}
    ...     string(.//managedObject[@distName="MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1"]/p[@name='actPowerMeter']/text())
    Set Test Variable  ${ACTPOWERM_STATUS}  ${apm_status}

    Run Keyword If  '${ACTPOWERM_STATUS}'=='False'  Run Keywords
    ...  Log  actPowerMeter is set to False, recommissioning to True...  console=True
    ...  AND  admin.Perform Parameter Recommissioning  ${FEATCADM_OBJECT}  actPowerMeter  update  true  alias=${node}
    ...  ELSE  Log  actPowerMeter already set to True, recommissioning not needed  console=True

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=120  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log  ${\n}All cells are onAir!    console=True
    ...  ELSE  Run Keywords
    ...  Log  Cells are not onAir!  console=True
    ...  AND  Fail  ${\n}Cells are not onAir!

    Log  ${\n}Getting information about cells and counters${\n}  console=True

    ${cells_id}  Run Keyword If  '${TEST_CELL_ID}'=='${EMPTY}'  Automated__SiSo_PM_LTE_uDTX.Create LNCEL List
    ...  ELSE  Convert LNCEL List
    Set Test Variable  ${CELLS_ID}

    @{cell_list_with_hw_less_than_5_1}  Create List
    @{cell_list_with_hw_more_than_5_1}  Create List
    Set Test Variable  ${CELL_LIST_WITH_HW_LESS_THAN_5_1}
    Set Test Variable  ${CELL_LIST_WITH_HW_MORE_THAN_5_1}
    @{rmods_lte}  Create List
    FOR  ${test_cell}  IN  @{CELLS_ID}
        ${cell_rmods}=  Get RMODS For Cell  ${test_cell}
        ${rmods_lte}=  Combine Lists  ${rmods_lte}  ${cell_rmods}
    END
    Set Test Variable  ${RMODS_LTE}
    FOR  ${items}  IN  @{RMODS_LTE}
        ${rmod_dn}  Get From Dictionary  ${items}  RMOD
        ${cell_id}  Get From Dictionary  ${items}  LNCEL
        ${rmod_id}  Query Infomodel  get object ${rmod_dn}
        ${hw_release}  Set Variable  ${rmod_id.radioModuleHwReleaseCode}
        ${hw_release}  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${hw_release}').group(0)  re
        ${status_hw_release}  Run Keyword And Return Status  Should Be True  '${hw_release}'>='5.1'
        Run Keyword If  '${status_hw_release}'=='True'
        ...  Run Keywords
        ...  Log  HW release is equal or higher than 5.1, for cell:${cell_id} counters: M8010C94 will be collected !  console=True
        ...  AND  Append To List  ${CELL_LIST_WITH_HW_MORE_THAN_5_1}  ${cell_id}
        ...  ELSE  Run Keywords
        ...  Log  HW release is less than 5.1, for cell:${items} counters: M8010C93 will be collected !  console=True
        ...  AND  Append To List  ${CELL_LIST_WITH_HW_LESS_THAN_5_1}  ${cell_id}
    END

    ${new_counters_path}  Check If Current Build Is Newer Than  SBTS24R2_ENB_9999_231220_000004  alias=${node}
    Set Test Variable  ${NEW_COUNTERS_PATH}

    ${dtx_modification_new_way}  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240718_000010  alias=${node}
    Set Test Variable  ${DTX_MODIFICATION_NEW_WAY}

    Log  ${\n}Checking if 5G MicroDtx needs to be disabled  console=True
    ${5G_info}  admin.Get parameters for all  NRCEL  alias=${node}
    ${5G_availability}  Run Keyword And Return Status  Should Contain  ${5G_info[0].id}  NRBTS
    Run Keyword If  '${5G_availability}'=='True'  Run Keywords
    ...  Log  There are NRCEL(s) on BTS, disabling MicroDtx for 5G will be performed  console=True
    ...  AND  Deactivate 5G MicroDtx
    ...  ELSE  Log  There is no need to disable 5G MicroDtx${\n}  console=True
    Set Test Variable  ${5G_AVAILABILITY}

Deactivate 5G MicroDtx
    Run Keyword If  '${DTX_MODIFICATION_NEW_WAY}'=='True'  Deactivate 5G MicroDtx By Vendor File
    ...  ELSE  Deactivate 5G MicroDtx By SCF

Deactivate 5G MicroDtx By Vendor File
    Automated__SiSo_5G_uDTX.Check Status Of Default Parameters From Vendor File
    admin.Get Current Scf File  local_dir_path=${TestFiles}/selenium/Vendor_File_Catalog  file_name=SCF_conf.xml  export_type=configuration
    Automated__SiSo_5G_uDTX.Selenium Logout And Close Browser
    Automated__SiSo_5G_uDTX.5G DTX Parameters Modification By Vendor File  vf_dtx_value=false

Deactivate 5G MicroDtx By SCF
    Log  Checking and updating values of parameters actMicroDTX and actMicroDTXAdvanced  console=True
    Automated__SiSo_5G_uDTX.Check Status Of Default Parameters From SCF

    Run Keyword If  '${ACTMICRODTX_DEFAULT_STATUS}'=='true'  Run Keywords
    ...  Log  5G MicroDTX is activated!  console=True
    ...  AND  5G MicroDTX - SBTS recommissioning  scf_dtx_value=false
    ...  ELSE
    ...  Log  5G MicroDTX is deactivated!  console=True

Step 2: Check MicroDTX status and activate MicroDTX
    Log  ${\n}Step 2: Check MicroDTX status and activate MicroDTX  console=True
    Log       ---------------------------------------------------${\n}  console=True

    ${initial_dict_aTC_status}  Automated__SiSo_5G_uDTX.Check Status Of allowTrafficConcentration
    ${initial_dict_lte_dtx_status}  Automated__SiSo_5G_uDTX.Check Status Of LTE microDTX
    Set Test Variable  ${INITIAL_DICT_ATC_STATUS}
    Set Test Variable  ${INITIAL_DICT_LTE_DTX_STATUS}
    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

    Log  Check status of LTE MicroDTX and activate it  console=True
    @{cell_to modify}  Create List
    admin.Create Delta
    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_LTE_DTX_STATUS.keys()}  ${INITIAL_DICT_LTE_DTX_STATUS.values()}
        ${status_lte_DTX}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  true
        Run Keyword If  '${status_lte_DTX}'=='False'  Run Keywords
        ...  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  actMicroDtx  true
        ...  AND  Append To List  ${cell_to modify}  ${test_cell_keys}
        ...  AND  Log  Parameter actMicroDtx for ${test_cell_keys} will be activated  console=True
    END

    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_ATC_STATUS.keys()}  ${INITIAL_DICT_ATC_STATUS.values()}
        ${status_aTC}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  true
        Run Keyword If  '${status_aTC}'=='False'  Run Keywords
        ...  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  allowTrafficConcentration  true
        ...  AND  Append To List  ${cell_to modify}  ${test_cell_keys}
        ...  AND  Log  Parameter allowTrafficConcentration for ${test_cell_keys} will be activated  console=True
    END
    ${is_list_empty}  Run Keyword And Return Status  Should Be Empty  ${cell_to modify}
    Run Keyword If  '${is_list_empty}'=='False'  Run Keywords
    ...  Automated__SiSo_5G_uDTX.Perform recommissioning
    ...  AND  Perform Site Reset
    ...  ELSE  Run Keywords  Log  LTE MicroDTX is activated!  console=True
    ...  AND  Perform Site Reset
    admin.Remove Delta

    Log  ${\n}Checking if MicroDTX is activated for tested cells  console=True
    ${dict_status_dtx}  Automated__SiSo_5G_uDTX.Check Status Of LTE microDTX
    ${dict_status_aTC}  Automated__SiSo_5G_uDTX.Check Status Of allowTrafficConcentration
    ${dtx_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_dtx}  false
    ${aTC_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_aTC}  false
    Run Keyword If  '${dtx_status}'=='True' and '${aTC_status}'=='True'
    ...  Log  MicroDTX is activated properly!  console=True
    ...  ELSE  Run Keywords
    ...  Log  MicroDTX for is not activated properly!  console=True
    ...  AND  Fail  MicroDTX for is not activated properly!

Step 3: Check MicroDTX counters value when MicroDTX is activated
    Log  ${\n}Step 3: Check MicroDTX counters value when MicroDTX is activated  console=True
    Log       ----------------------------------------------------------------${\n}  console=True

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  15  15
    Log  Waiting for ${time_to_sleep} minutes to Get Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !${\n}  console=True
    Sleep  ${time_to_sleep} minutes

    Get And Verify M8010C94 Counters  dtx_on=True
    Log  ------------------------------------------------${\n}  console=True

    Get And Verify M8010C93 Counters  dtx_on=True

Step 4: Check RMOD power consumption when MicroDTX is activated
    Log  ${\n}Step 4: Check RMOD power consumption when MicroDTX is activated  console=True
    Log  ---------------------------------------------------------------${\n}  console=True

    ${CELL_RMOD_POWER}  Create List  @{EMPTY}
    Set Test Variable  ${CELL_RMOD_POWER}
    ${measurements}  admin.Get Measurements
    FOR  ${items}  IN  @{rmods_lte}
        ${rmod_dn}  Get From Dictionary  ${items}  RMOD
        ${rmod_number}  Fetch From Right  ${rmod_dn}  /
        ${power_DTX_activated}  Rmod Get Measurement  ${measurements}  ${rmod_number}
        ${cell_id}  Get From Dictionary  ${items}  LNCEL
        ${dict}  Create Dictionary  LNCEL=${cell_id}  RMOD=${rmod_dn}  P_mdtx[W]=${power_DTX_activated}
        Log  ${dict}  console=True
        Append To List  ${CELL_RMOD_POWER}  ${dict}
    END

Step 5: Deactivate MicroDTX - SBTS recommissioning
    Log  ${\n}Step 5: Deactivation MicroDTX is going  console=True
    Log       --------------------------------------${\n}  console=True

    Log  Updating parameters actMicroDtx=false and allowTrafficConcentration=false for LNCEL(s)${\n}  console=True
    admin.Create Delta
    FOR  ${test_cell}  IN  @{CELLS_ID}
        Log  MicroDTX of ${test_cell} is going to be deactivated  console=True
        admin.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}  actMicroDtx  false
        admin.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}  allowTrafficConcentration  false
    END
    Automated__SiSo_5G_uDTX.Perform recommissioning
    admin.Remove Delta

    Log  Checking if MicroDTX is deactivated for tested cells  console=True
    ${dict_status_dtx}  Automated__SiSo_5G_uDTX.Check Status Of LTE microDTX
    ${dict_status_aTC}  Automated__SiSo_5G_uDTX.Check Status Of allowTrafficConcentration
    ${dtx_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_dtx}  true
    ${aTC_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_aTC}  true
    Run Keyword If  '${dtx_status}'=='True' and '${aTC_status}'=='True'
    ...  Log  MicroDTX is deactivated properly!${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  MicroDTX for is not deactivated properly!  console=True
    ...  AND  Fail  MicroDTX for is not deactivated properly!

Step 6: Check MicroDTX counters value when MicroDTX is deactivated
    Log  ${\n}Step 6: Check MicroDTX counters value when MicroDTX is deactivated  console=True
    Log       ------------------------------------------------------------------${\n}  console=True

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  15  15
    Log  Waiting for ${time_to_sleep} minutes to Get Counters! ${\n}Verdict will be released at *${time_to_verdict}*!${\n}  console=True
    Sleep  ${time_to_sleep} minutes

    Get And Verify M8010C94 Counters  dtx_on=False
    Log  ------------------------------------------------${\n}  console=True

    Get And Verify M8010C93 Counters  dtx_on=False

Step 7: Check RMOD power consumption when MicroDTX is deactivated and compare
    Log  ${\n}Step 7: Check RMOD power consumption when MicroDTX is deactivated and compare  console=True
    Log       -----------------------------------------------------------------------------${\n}  console=True

    ${measurements}  admin.Get Measurements
    FOR  ${items}  IN  @{CELL_RMOD_POWER}
        ${rmod}  Get From Dictionary  ${items}  RMOD
        ${rmod_number}  Fetch From Right  ${rmod}  /
        ${power_DTX_deactivated}  Rmod Get Measurement  ${measurements}  ${rmod_number}
        ${power_DTX_activated}  Get From Dictionary  ${items}  P_mdtx[W]
        Set To Dictionary  ${items}  P[W]=${power_DTX_deactivated}
        Log  ${items}  console=True
        ${power_diff_status}  Evaluate  ${power_DTX_activated}+5 < ${power_DTX_deactivated}
        Run Keyword If  ${power_diff_status}
        ...  Log  Power is correct - higher after dectivating MicroDTX${\n}  console=True
        ...  ELSE  Run Keywords
        ...  Log  Power did not increase enough after deactivation of MicroDTX  console=True
        ...  AND  Fail  Power did not increase enough after deactivation of MicroDTX
    END

Restore MicroDTX to initial status
    Log  Restoring MicroDTX to initial status  console=True
    Log  ------------------------------------${\n}  console=True

    Log  ---Checking if LTE MicroDTX parameters need to be restore to initial status---  console=True
    admin.Create Delta
    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_LTE_DTX_STATUS.keys()}  ${INITIAL_DICT_LTE_DTX_STATUS.values()}
        ${status_dtx}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  false
        Run Keyword If  '${status_dtx}'=='True'
        ...  Log  Disabling of parameter actMicroDtx for ${test_cell_keys} is not needed  console=True
        ...  ELSE  Run Keywords
        ...  Log  Parameter actMicroDtx of ${test_cell_keys} is going to be activated  console=True
        ...  AND  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  actMicroDtx  true
    END

    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_ATC_STATUS.keys()}  ${INITIAL_DICT_ATC_STATUS.values()}
        ${status_aTC}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  false
        Run Keyword If  '${status_aTC}'=='True'
        ...  Log  Disabling of parameter allowTrafficConcentration for ${test_cell_keys} is not needed  console=True
        ...  ELSE  Run Keywords
        ...  Log  Parameter allowTrafficConcentration of ${test_cell_keys} is going to be activated  console=True
        ...  AND  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  allowTrafficConcentration  true
    END
    Automated__SiSo_5G_uDTX.Perform recommissioning
    admin.Remove Delta

    Log  === Checking if LTE MicroDTX is restored for tested cells ===  console=True
    ${dict_current_status_dtx}  Automated__SiSo_5G_uDTX.Check Status Of LTE microDTX
    ${list_current_status_dtx}  Get Dictionary Values  ${dict_current_status_dtx}
    ${list_initial_status_dtx_dict}  Get Dictionary Values  ${INITIAL_DICT_LTE_DTX_STATUS}

    ${dict_current_status_aTC}  Automated__SiSo_5G_uDTX.Check Status Of allowTrafficConcentration
    ${list_current_status_aTC}  Get Dictionary Values  ${dict_current_status_aTC}
    ${list_initial_status_aTC_dict}  Get Dictionary Values  ${INITIAL_DICT_ATC_STATUS}

    ${compare_dtx_lists}  Run Keyword And Return Status  Lists Should Be Equal  ${list_current_status_dtx}  ${list_initial_status_dtx_dict}
    ${compare_aTC_lists}  Run Keyword And Return Status  Lists Should Be Equal  ${list_current_status_aTC}  ${list_initial_status_aTC_dict}
    Run Keyword If  '${compare_dtx_lists}'=='True' and '${compare_aTC_lists}'=='True'
    ...  Log  Initial and current parameters of LTE MicroDTX have the same status!${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Initial and current parameters of LTE MicroDTX have different status!  console=True
    ...  AND  Fail  Initial and current parameters of LTE MicroDTX have different status!

    Run Keyword If  '${5G_AVAILABILITY}'=='True'  Automated__SiSo_5G_uDTX.Restore 5G MicroDTX

    Run Keyword If  'False' in '${ACTPOWERM_STATUS}'  Run Keywords
    ...  admin.Perform Parameter Recommissioning  ${FEATCADM_OBJECT}  actPowerMeter  update  false  alias=${node}
    ...  AND  Log  Parameter  'actPowerMeter'  back to initial status  console=True


Get And Verify M8010C94 Counters
    [Arguments]  ${dtx_on}
    Log  Checking if counters M8010C94 need to be collected...  console=True
    Run Keyword If  ${CELL_LIST_WITH_HW_MORE_THAN_5_1}
    ...  Get Pm Counters For HW With Release >5.1  ${dtx_on}
    ...  ELSE
    ...  Log  Counters M8010C94 for HW With Release >5.1 are no need to collect.${\n}  console=True

Get And Verify M8010C93 Counters
    [Arguments]  ${dtx_on}
    Log  Checking if counters M8010C93 need to be collected...  console=True
    Run Keyword If  ${CELL_LIST_WITH_HW_LESS_THAN_5_1}
    ...  Get Pm Counters For HW With Release <5.1  ${dtx_on}
    ...  ELSE
    ...  Log  Counters M8010C93 for HW With Release <5.1 are no need to collect.${\n}  console=True

Get Pm Counters For HW With Release >5.1
    [Arguments]  ${dtx_on}
    Log  Counters M8010C94 for HW With Release >5.1 will be collected!${\n}  console=True
    ${get_M8010C94_counters}  admin.Get Pm Counters  M8010C94  alias=${node}

    &{all_cells_dict}  Create Dictionary
    FOR  ${test_cell}  IN  @{CELL_LIST_WITH_HW_MORE_THAN_5_1}
         ${cell_dict}  Set Variable If
         ...  ${NEW_COUNTERS_PATH}
         ...  ${get_M8010C94_counters['BTS']['MRBTS-${BTS_ID}']['LNBTS-${BTS_ID}']['LNCEL-${test_cell}']}
         ...  ${get_M8010C94_counters['BTS']['CELLS']['LNCEL-${test_cell}']}
         Set To Dictionary  ${all_cells_dict}  ${test_cell}   ${cell_dict}
    END

    FOR  ${cell}  ${counters}  IN ZIP  ${all_cells_dict.keys()}  ${all_cells_dict.values()}
        ${counters_path_LTE_object}  Get Dictionary Values  ${counters}
        ${counters_path}  Run Keyword If  '${NEW_COUNTERS_PATH}'=='True'
        ...  Get Dictionary Values  ${counters_path_LTE_object}[0]
        ...  ELSE
        ...  Set Variable  ${counters_path_LTE_object}
        ${counters_name_with_values}  Get Dictionary Values  ${counters_path}[0]
        ${counters_name}  Get Dictionary Keys  ${counters_name_with_values}[0]
        ${values}  Get Dictionary Values  ${counters_name_with_values}[0]
        ${req_counters_status}  Run Keyword And Return Status  Should Contain Match  ${counters_name}  M8010C94
        Run Keyword If  '${req_counters_status}'=='True'
        ...  Log  Counters for LNCEL-${cell} were successfully collected!  console=True
        ...  ELSE
        ...  Fail  Collected PM Counters for LNCEL-${cell} don't contain expected counters!${\n}
        ${key}  Get Dictionary Keys  ${values}[0]
        ${str}  Set Variable  ${key}[-1]
        ${human_readable_timestamp}  Evaluate  (__import__('datetime').datetime.utcfromtimestamp(${str}).strftime('%Y-%m-%d %H:%M'))
        ${current_date}  Get Current Date  exclude_millis=True  result_format=%Y-%m-%d %H:%M
        ${subtracted_time}  Subtract Time From Date  ${current_date}  77 minutes  exclude_millis=True  result_format=%Y-%m-%d %H:%M
        ${counters_values}  _Unzip List Of Dicts  ${values}
        Run Keyword If  '${dtx_on}'=='True'  Run Keywords
        ...  Should Be Equal As Strings  ${subtracted_time}  ${human_readable_timestamp}
        ...  AND  Check Range Of Counters  ${counters_values}
        ...  ELSE
        ...  Check Zero Value  ${counters_values}
    END

Get Pm Counters For HW With Release <5.1
    [Arguments]    ${dtx_on}
    Log  Counters M8010C93 for HW With Release <5.1 will be collected!${\n}  console=True
    ${get_M8010C93_counters}  admin.Get Pm Counters  M8010C93  alias=${node}

    &{all_cells_dict}  Create Dictionary
    FOR  ${test_cell}  IN  @{CELL_LIST_WITH_HW_LESS_THAN_5_1}
         ${cell_dict}  Set Variable If
         ...    ${NEW_COUNTERS_PATH}
         ...    ${get_M8010C93_counters['BTS']['MRBTS-${BTS_ID}']['LNBTS-${BTS_ID}']['LNCEL-${test_cell}']}
         ...    ${get_M8010C93_counters['BTS']['CELLS']['LNCEL-${test_cell}']}
         Set To Dictionary  ${all_cells_dict}  ${test_cell}   ${cell_dict}
    END

    FOR  ${cell}  ${counters}  IN ZIP  ${all_cells_dict.keys()}  ${all_cells_dict.values()}
        ${counters_path_LTE_object}  Get Dictionary Values  ${counters}
        ${counters_path}  Run Keyword If  '${NEW_COUNTERS_PATH}'=='True'
        ...  Get Dictionary Values  ${counters_path_LTE_object}[0]
        ...  ELSE
        ...  Set Variable  ${counters_path_LTE_object}
        ${counters_name_with_values}  Get Dictionary Values  ${counters_path}[0]
        ${counters_name}  Get Dictionary Keys  ${counters_name_with_values}[0]
        ${values}  Get Dictionary Values  ${counters_name_with_values}[0]
        ${req_counters_status}  Run Keyword And Return Status  Should Contain Match  ${counters_name}  M8010C93
        Run Keyword If  '${req_counters_status}'=='True'
        ...  Log  Counters for LNCEL-${cell} were successfully collected!    console=True
        ...  ELSE
        ...  Fail  Collected PM Counters for LNCEL-${cell} don't contain expected counters!${\n}
        ${key}  Get Dictionary Keys  ${values}[0]
        ${str}  Set Variable  ${key}[-1]
        ${timestamp_items}  Get Dictionary Items  ${values}[0]
        ${timestamp_value}  Get From List  ${timestamp_items}  -1
        ${human_readable_timestamp}  Evaluate  (__import__('datetime').datetime.utcfromtimestamp(${str}).strftime('%Y-%m-%d %H:%M'))
        ${current_date}  Get Current Date  exclude_millis=True  result_format=%Y-%m-%d %H:%M
        ${subtracted_time}  Subtract Time From Date  ${current_date}  77 minutes  exclude_millis=True  result_format=%Y-%m-%d %H:%M
        ${counters_values}  _Unzip List Of Dicts  ${values}
        Run Keyword If  '${dtx_on}'=='True'  Run Keywords
        ...  Set Test Variable  ${M8010C93_VALUE_DTX_ACTIV}  ${timestamp_value}
        ...  AND  Should Be Equal As Strings  ${subtracted_time}  ${human_readable_timestamp}
        ...  AND  Check Range Of Counters  ${counters_values}
        ...  ELSE  Run Keywords
        ...  Set Test Variable  ${M8010C93_VALUE_DTX_DEACTIV}  ${timestamp_value}
        ...  AND  Check If Additional Timestamp Is Visible  ${human_readable_timestamp}  ${current_date}
        ...  AND  Check No Timestamp For M8010C93  ${human_readable_timestamp}  ${current_date}
    END
    [Return]  ${human_readable_timestamp}  ${current_date}  ${subtracted_time}

Check If Additional Timestamp Is Visible
    [Arguments]  ${human_readable_timestamp}  ${current_date}
    ${subtracted_time_disabled_dtx}  Subtract Time From Date  ${current_date}  92 minutes  exclude_millis=True  result_format=%Y-%m-%d %H:%M
    ${verdict}  Run Keyword And Return Status  Should Be Equal As Strings  ${subtracted_time_disabled_dtx}  ${human_readable_timestamp}
    Run Keyword If  '${verdict}'=='True'  Run Keywords
    ...  Log  Additional timestamp for counter M8010C93 is visible, checking values will be performed...  console=True
    ...  AND  Check M8010C93 Counters Value

Check No Timestamp For M8010C93
    [Arguments]  ${human_readable_timestamp}  ${subtracted_time}
    ${verdict}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${subtracted_time}  ${human_readable_timestamp}
    Run Keyword If  '${verdict}'=='True'
    ...  Log  There is no more visible value for counter M8010C93, as expected${\n}   console=True
    ...  ELSE  Run Keywords
    ...  Log  There is visible value for counter M8010C93, TC failed!  console=True
    ...  AND  Fail  There is visible value for counter M8010C93, TC failed!

Check M8010C93 Counters Value
    Log  Checking if counters value is not higher than values from activated MicroDTX${\n}
    ${value}  Evaluate  ${M8010C93_VALUE_DTX_ACTIV}>=${M8010C93_VALUE_DTX_DEACTIV}
    Run Keyword If  'False' in '${value}'  Run Keywords
    ...  Fail  Counters value for additional timestamp is higher than value from activated MicroDTX, TC failed!
    ...  AND  Log  Counters value for additional timestamp is higher than value from activated MicroDTX, TC failed!  console=True
    ...  ELSE  Log  Counters value for additional timestamp is lower than value from activated MicroDTX - correct!${\n}  console=True

Check Range Of Counters
    [Arguments]    ${values}
    Log  Checking if counters values are in required range...  console=True
    ${in_range}  Evaluate  (1<=${values}[-1]<=99)
    Run Keyword If  'False' in '${in_range}'  Run Keywords
    ...  Fail  Counters value is not in the required range <1; 99> !
    ...  AND  Log  Counters value is not in the required range <1; 99> !  console=True
    ...  ELSE  Log  Counters value is correct, in the required range <1; 99> !${\n}  console=True

Check Zero Value
    [Arguments]    ${values}
    Log  Checking if counters values are zero...  console=True
    ${check_zero}  Evaluate  ${values}[-1]==0
    Run Keyword If  'False' in '${check_zero}'  Run Keywords
    ...  Fail  Counters value is not zero!
    ...  AND  Log   Counters value is not zero!  console=True
    ...  ELSE  Log   Counters value is correct!${\n}  console=True

_Unzip List Of Dicts
    [Arguments]  ${values}
    ${raw_list_all_values}  Create List
    FOR  ${item}  IN  @{values}
        ${all_values}  Get Dictionary Values  ${item}
        Append To List  ${raw_list_all_values}  ${all_values}
    END
    ${list_all_values}  Evaluate  [item for sublist in ${raw_list_all_values} for item in sublist]

    [Return]  ${list_all_values}

Create LNCEL List
    @{CELLS_ID}=  Create List  @{EMPTY}
    ${lncels}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    FOR  ${lncel}  IN  @{lncels}
        ${lncel}=  Fetch From Right  ${lncel}  -
        Append To List  ${CELLS_ID}  ${lncel}
    END
    [Return]  ${cells_id}

Convert LNCEL List
    ${cells_id}=  Split String  ${TEST_CELL_ID}  ,
    [Return]  ${cells_id}

Get RMODS For Cell
    [Arguments]  ${test_lte_cell}
    @{lte_rmods}=  Create List  @{EMPTY}
    ${cells}=  SiSo Get LTE CELL-RM mapping list
    FOR  ${cell}  IN  @{cells}
        ${cell_id}=  Get From List  ${cell}    0
        ${cell_id}=  Fetch From Right  ${cell_id}  -
        ${rmods}=  Get From List   ${cell}    5
        ${lte_rmods}=  Get List RMOD for LNCEL  ${rmods}  ${lte_rmods}  ${cell_id}  ${test_lte_cell}
    END
    [Return]  ${lte_rmods}

Get List RMOD for LNCEL
    [Arguments]  ${rmods}  ${lte_rmods}  ${cell_id}  ${test_lte_cell}
    FOR  ${rmod}  IN  @{rmods}
        ${rmod}=  Get From List  ${rmod}   0
        ${rmod}=  Create Dictionary  LNCEL=${cell_id}  RMOD=${rmod}
        Run Keyword If  ${cell_id}==${test_lte_cell}  Append To List  ${lte_rmods}  ${rmod}
    END
    [Return]  ${lte_rmods}

Rmod Get Measurement
    [Arguments]  ${measurements}  ${rmod_number}
    FOR  ${measurement}  IN  @{measurements}
        ${rmod}=  Get Dictionary Keys  ${measurement}
        ${rmod}=  Get From List    ${rmod}    0
        ${rmod_r}=   Fetch From Right  ${rmod}  /
        ${rmod_power}  Run Keyword If  '${rmod_r}'=='${rmod_number}'  Get From Dictionary  ${measurement}  ${rmod}
        ${power}  Run Keyword If  '${rmod_r}'=='${rmod_number}'  Get From Dictionary  ${rmod_power}  power
        Exit For Loop If  '${rmod_r}'=='${rmod_number}'
     END
    [Return]  ${power}

Perform Site Reset
    Log  ${\n}Reset site will be performed!  console=True
    admin.Reset Site  timeout=600  connection=default

    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  30 s  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log  All cells are onAir!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Cells are not onAir!  console=True
    ...  AND  Fail  Cells are not onAir!
    Sleep  3 min


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}  Restore MicroDTX to initial status
    Common Test Teardown

