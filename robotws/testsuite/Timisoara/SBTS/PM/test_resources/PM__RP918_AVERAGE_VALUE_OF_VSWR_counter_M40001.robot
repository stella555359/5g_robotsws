*** Settings ***
Documentation
    ...  Purpose of this test case is to verify basic funcitonality which allows to collect VSWR common counter 40001 counter to PM file

Library  taf.collectors.pmcounters
Library  ../../common_resources/python_resources/PM/PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001.py
Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${SCF_FILE_NAME}  scf.xml
${MOC_1}  MNL-1/MNLENT-1/PMCADM-1
${MOC_2}  MNL-1/MNLENT-1/PMMNL-1
${PARAMETER_VALUE}  15
# value to which the parameters (reportingIntervalPm and mtSBTSAntennaLine) will be changed


*** Keywords ***
TC__PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 08.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28361 - Fix setting scalar variable
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-jakub.sikora@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_vrf  PHASE-CRT  FEATURE-RP001145_RP000918;RP001486_RP000918

    Step 0: Preconditions
    Step 1: Get Pm Counters File
    Step 2: Check If Counter AVERAGE VALUE OF VSWR Is Reported For Each Ant With Tx


Step 0: Preconditions
    [Documentation]
    ...  In this step test check and save reportingIntervalPM,
    ...  prepare two delta one to change parameter that test needed and second one to restore bts
    ...  first delta is used for recommissioning in this step

    Log  \nStep 0: Preconditions  console=true
    Set Test Variable  ${FILE_DIR}  ${BTS_FILES}/pm_counters
    coam.Get Current Scf File  ${BTS_FILES}  scf_to_setup.xml  with_auto_configured_parameters=${TRUE}
    Setup Pm  scf_path=${BTS_FILES}/scf_to_setup.xml
    ${current_reporting_interval_in_seconds}  Get Reporting Interval
    ${current_reporting_interval_in_minutes}  Evaluate  int(${current_reporting_interval_in_seconds}/60)
    Set Test Variable  ${CURRENT_REPORTING_INTERVAL_PM_IN_MINUTES}  ${current_reporting_interval_in_minutes}
    Set Test Variable  ${REPORTING_INTERVAL_PM_MOD}  ${False}

    ${bts_connection}  coam.Connect_to
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}
    ${n_rexist}  Run Keyword And Return Status
    ...  coam.Assert Any  NRCEL
    ${lt_eexist}  Run Keyword And Return Status
    ...  coam.Assert Any  LNCEL
    ${bts_id}  Admin Get BTS ID
    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${BTS_ID}
    Set Test Variable  ${LNBTS_ID}
    ${bts_info}  coam.Get Bts Info
    Run Keyword If  ${n_rexist}
    ...  Set Test Variable  ${NRBTS_ID}  ${bts_info['nrBtsId']}

    ${delta_id}  Set Variable  parameters_change
    coam.Create Delta  ${delta_id}
    Set Test Variable  ${DELTA_ID}  ${delta_id}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/${MOC_1}  reportingIntervalPm  ${PARAMETER_VALUE}min  ${DELTA_ID}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/${MOC_2}  mtSBTSAntennaLine  ${PARAMETER_VALUE}min  ${DELTA_ID}
    Log  reportingIntervalPm was changed from value ${CURRENT_REPORTING_INTERVAL_PM_IN_MINUTES}min to value ${PARAMETER_VALUE}min  console=true
    Log  mtSBTSAntennaLine was set to value ${PARAMETER_VALUE}min  console=true
    Run Keyword If  ${lt_eexist}
    ...  Append LTE Parameters To Delta
    Run Keyword If  ${n_rexist}
    ...  Append 5G Parameters To Delta
    coam.Get Delta  ${DELTA_ID}
    coam.Save Delta  ${BTS_FILES}/delta_change.json  ${DELTA_ID}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_change.json  skip_parameter_relation_errors=True
    Log  Check BTS status after delta recommissioning  console=true
    Wait Until Keyword Succeeds  10m  10s
    ...  Admin Check All Required State
    Set Test Variable  ${REPORTING_INTERVAL_PM_MOD}  ${True}

    ${delta_id_2}  Set Variable  parameters_change_back
    coam.Create Delta  ${delta_id_2}
    Set Test Variable  ${DELTA_ID_2}  ${delta_id_2}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm
    ...  ${CURRENT_REPORTING_INTERVAL_PM_IN_MINUTES}min  ${DELTA_ID_2}
    coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMMNL-1  mtSBTSAntennaLine  60min  ${DELTA_ID_2}
    Run Keyword If  ${lt_eexist}
    ...  Restore LTE Parameters
    Run Keyword If  ${n_rexist}
    ...  Restore 5G Parameters
    coam.Get Delta  ${DELTA_ID_2}
    coam.Save Delta  ${BTS_FILES}/delta_change_back.json  ${DELTA_ID_2}


Step 1: Get Pm Counters File
    [Documentation]
    ...  In this step test waiting 15min after recommissioning and next Collect PM Counters

    Log  \nStep 1: Get Pm Counters File  console=true
    Log  Waiting ${PARAMETER_VALUE}m 30s after reportingIntervalPm change  console=true
    Sleep  ${PARAMETER_VALUE}m 5s
    Collect PM Counters
    @{files}  OperatingSystem.List Files In Directory  ${FILE_DIR}  *.xml  absolute
    Set Test Variable  ${PM_COUNTER_NAME}  ${files}[0]


Step 2: Check If Counter AVERAGE VALUE OF VSWR Is Reported For Each Ant With Tx
    [Documentation]
    ...  In this step test Check If Counter AVERAGE VALUE OF VSWR Is Reported For Each Ant With Tx
    ...  using PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001.py

    Log  \nStep 2: Check If Counter AVERAGE VALUE OF VSWR Is Reported For Each Ant With Tx  console=true
    coam.Get_Current_Scf_File  local_dir_path=${FILE_DIR}  file_name=${SCF_FILE_NAME}
    Check_value_of_counter_M40001C0_for_each_tx_antenna  scf_file_path=${FILE_DIR}/${SCF_FILE_NAME}  pm_counter_file_path=${PM_COUNTER_NAME}


Collect PM Counters
    [Documentation]
    ...  This KW Collect PM Counters
    [Arguments]  ${host}=192.168.255.129  ${user}=Nemuadmin  ${password}=nemuuser  ${port}=443  ${xml_files_left}=1

    ${name}  Fetch From Right  ${FILE_DIR}  /
    ${webservice}  Create Dictionary  host=${host}  user=${user}  password=${password}  port=${port}
    taf.collectors.pmcounters.Create PM Collector  name=${name}  webservice=${webservice}
    taf.collectors.pmcounters.Setup Collectors  names=${name}
    taf.collectors.pmcounters.Collect Collectors  names=${name}  target_dir=${BTS_FILES}
    Run  find ${FILE_DIR} -name '*.xml' | sort -nk1 | head -n -${xml_files_left} | xargs rm -rf

    [Teardown]  taf.collectors.pmcounters.Teardown Collectors  names=${name}


Check If Back To Previous ReportingInervalPm Needed
    [Documentation]
    ...  In this KW check if back to previous reportingInervalPm needed if yes delta2 will be recommissioning

    Run Keyword If  ${REPORTING_INTERVAL_PM_MOD}
    ...  Run Keywords
    ...  Log  ReportingIntervalPm back to ${CURRENT_REPORTING_INTERVAL_PM_IN_MINUTES}min  console=true
    ...  AND
    ...  coam.Perform Delta Recommissioning  ${BTS_FILES}/delta_change_back.json  skip_parameter_relation_errors=True
    ...  AND
    ...  Set Test Variable  ${REPORTING_INTERVAL_PM_MOD}  ${False}
    ...  AND
    ...  Wait Until Keyword Succeeds  20m  10s
    ...  Admin Check All Required State


Append LTE Parameters To Delta
    [Documentation]
    ...  This KW appends to delta parameters which trigger VSWR measurements for LTE

    ${cell_lte_list}  coam.Get Ids For All  LNCEL  timeout=120  connection=${BTS_CONNECTION}
    ${list_with_cell_number_id}  Create List
    FOR  ${lte_cell}  IN  @{cell_lte_list}
        ${lte_cell_nr}  Fetch From Right  ${lte_cell}  -
        Append To List  ${list_with_cell_number_id}  ${lte_cell_nr}
    END
    Set Test Variable  @{LIST_WITH_CELL_NUMBER_ID}
    FOR  ${cell_number}  IN  @{LIST_WITH_CELL_NUMBER_ID}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_number}  dlInterferenceEnable  true  ${DELTA_ID}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_number}  dlInterferenceLevel  100  ${DELTA_ID}
    END
    Log  dlInterferenceEnable was changed from false to true  console=true
    Log  dlInterferenceLevel was set to value 100  console=true


Append 5G Parameters To Delta
    [Documentation]
    ...  This KW appends to delta parameters which trigger VSWR measurements for 5G

    ${cell_nr_list}  coam.Get Ids For All  NRCEL  timeout=120  connection=${BTS_CONNECTION}
    ${list_with_n_rcell_number_id}  Create List
    FOR  ${nr_cell}  IN  @{cell_nr_list}
        ${nr_cell_nr}  Fetch From Right  ${nr_cell}  -
        Append To List  ${list_with_n_rcell_number_id}  ${nr_cell_nr}
    END
    Set Test Variable  @{LIST_WITH_NRCELL_NUMBER_ID}
    FOR  ${cell_number}  IN  @{LIST_WITH_NRCELL_NUMBER_ID}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_number}  targetTotalLoad  100  ${DELTA_ID}
    END
    Log  targetTotalLoad was set to value 100  console=true


Restore LTE Parameters
    [Documentation]
    ...  This KW restores to delta LTE parameters which were changed

    FOR  ${cell_number}  IN  @{LIST_WITH_CELL_NUMBER_ID}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_number}  dlInterferenceEnable  false  ${DELTA_ID_2}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_number}  dlInterferenceLevel  0  ${DELTA_ID_2}
    END


Restore 5G Parameters
    [Documentation]
    ...  This KW restores to delta 5G parameters which were changed

    FOR  ${cell_number}  IN  @{LIST_WITH_NRCELL_NUMBER_ID}
        coam.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_number}  targetTotalLoad  0  ${DELTA_ID_2}
    END


Custom Test Teardown
    Log  \nCustom Test Teardown  console=true
    Check If Back To Previous ReportingInervalPm Needed
    coam.Remove Delta  ${DELTA_ID}
    coam.Remove Delta  ${DELTA_ID_2}
    Common Test Teardown


TC Setup
    Common Test Setup


TC Teardown
    Custom Test Teardown
