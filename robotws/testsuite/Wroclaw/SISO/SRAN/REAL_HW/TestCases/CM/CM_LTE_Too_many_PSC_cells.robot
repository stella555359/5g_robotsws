*** Settings ***
Documentation
    ...  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-17599
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  PRECONDITIONS:
    ...  The test supports one-BTS solution at the moment. In case new configurations are supported by CB013164
    ...  review of the steps will be required to adjust the tests.
    ...
    ...  The following parameter setting shall be used:
    ...  - EQM/APEQM/CABINET/BBMOD/useFullCapacity shall be set to 'true' for both baseband boards.
    ...  - EQM/APEQM/CABINET/BBMOD/bbCardUsage shall be set to '2' for both baseband boards.
    ...  - Manual allocation of cells to pools and/or baseband boards shall not be used (bbPoolAllocMode = automatic)
    ...  - None of the cells shall be within an UL CoMP cell list and UL CoMP shall not be activated (actCoMp = 'disabled')
    ...  - For all the cells actOtdoa shall be set to 'false'.
    ...  - eMBMS services including public safety bearers shall be neither configured nor activated
    ...    (actMBMSPS = 'false' & actPubSafetyBearers = 'false').
    ...  - bbPoolAllocPrioList shall be empty. (shall not contain any allocCriterion value)
    ...  - actLBPowerSaving shall be set to 'true'
    ...  - lbpsLastCellSOEnabled for all power saving groups shall be set to 'false'
    ...  - actLBBbPowerSaving shall be set to 'true'
    ...  All cells On air, no unexpected alarms on BTS.
    ...
    ...  Step 1 Preconditions For Automated SiSo CM LTE Too Many PSC Cells
    ...    Check required parameters and prepare variables needed for the test.
    ...  Step 2 Delta Recommissioning Too Many PSC Cells
    ...    Perform delta recommissioning to set PSGRP priority for all cells.
    ...  Step 3 Reset Site & Check States For PSC Cells
    ...    Reset site and check whether PSC cells are listed under the correct baseband pool.
    ...  Step 4 Perform L3 Call For PSC Cells
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.01.2025 - Initial creation

Resource  ./../../Resources/Robot/SM.robot
Resource  ./../../Resources/Robot/scfc.robot
Resource  ./CM_PSGRP.resource
Resource  ./../../Resources/Robot/variables_preparation.robot

*** Variables ***
${ABIA_SERIAL_NUMBERS}          # Mandatory: serial numbers of ABIAs chosen by the tester

*** Keywords ***
TC__CM_LTE_Too_Many_PSC_Cells
    Set Tags  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=Automated SiSo CM LTE PSGRP Priority for every node on list: @{CFG.active_bts_list} will be executed
    ...  style=ONGOING

    Step 1 Preconditions For Automated SiSo CM LTE Too Many PSC Cells
    Step 2 Delta Recommissioning Too Many PSC Cells
    Step 3 Reset Site & Check States For PSC Cells
    Step 4 Perform L3 Call For PSC Cells
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Recovery Recommissioning For PSC And NPSC Cells  ${CFG.active_bts_list[0]}
    ...  AND  Run Keyword And Ignore Error  Common Test Teardown

Step 1 Preconditions For Automated SiSo CM LTE Too Many PSC Cells
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Automated SiSo CM LTE Too Many PSC Cells
    ...  style=STEP
    ...  frame=${TRUE}
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${bts_info}=  admin.Get BTS Info  connection=${bts_id}
    ${bbmod_dns}  ${bbmod_internal_dns}  ${bbmod_ids}  ${bbmod_cell_mapping}  ${bbmod_conf_int_dict}=
    ...  Get Variables For Tested BBMODs  ${bts_id}  ${bts_info}  ${ABIA_SERIAL_NUMBERS}
    Log Dictionary  ${bbmod_cell_mapping}
    Set Test Variable  ${BBMOD_DNS}  ${bbmod_dns}
    Set Test Variable  ${BBMOD_INTERNAL_DNS}  ${bbmod_internal_dns}
    Set Test Variable  ${BBMOD_CELL_MAPPING}  ${bbmod_cell_mapping}
    Set Test Variable  ${BBMOD_CONF_INT_DICT}  ${bbmod_conf_int_dict}
    ${all_cells_on_tl}  ${node_cells_dict}  ${nr_cells}  ${lte_cells}  ${wcdma_cells}  ${gsm_cells}=  Create All Cells DNs List
    Set Test Variable  ${LTE_CELLS}  ${lte_cells}
    Set Test Variable  ${NODE_CELLS_DICT}  ${node_cells_dict}
    ${mrbts_parameters}=  admin.Get Parameter By Distname
    ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ...  connection=${BTS_ID}
    Check Precondition Parameters For PSGRP Tests
    ...  ${bts_id}  ${bbmod_dns}  ${bbmod_internal_dns}  ${node_cells_dict}  ${bbmod_cell_mapping}
    Check Parameters From SCF For LTE Too Many PSC And NPSC Cells
    ...  ${bts_id}  ${bbmod_dns}  ${bbmod_internal_dns}  ${node_cells_dict}  ${bbmod_cell_mapping}
    ${cells_in_bbpool}=  Get ABIA BBPOOLs For Tested Cells  ${BBMOD_CELL_MAPPING}  ${node_cells_dict}  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Automated SiSo CM LTE Too Many PSC Cells
    ...  style=DONE

Step 2 Delta Recommissioning Too Many PSC Cells
    Logging With Timestamp
    ...  message=Step 2 Delta Recommissioning Too Many PSC Cells
    ...  style=STEP
    ...  frame=${TRUE}
    ${scf_file_path}=  admin.Get Current Scf File
    ...  local_dir_path=${TEST_LOGS_PATH}/TestFiles
    ...  file_name=test_current_scf_02
    ...  export_type=configurationAndRuntimeObjects
    ...  connection=${bts_id}
    ${bb_pool_alloc_prio_list}=  SCFC Get Attribute Value
    ...  scfc_file_path=${scf_file_path}
    ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}
    ...  attribute_name=bbPoolAllocPrioList
    Should Be Empty  ${bb_pool_alloc_prio_list}
    ${delta_part1}=  Set Variable  [{"distName":"MRBTS-${BTS_ID}/LNBTS-${BTS_ID}","operation":"update","parameters":[{"parameterName":
    ${delta_part2}=  Set Variable  "bbPoolAllocPrioList","value":[{"allocCriterion":"PSGRP priority","allocPriority":"5"}],"operation":"update"}]}]
    ${delta_json}=  Set Variable  ${delta_part1}${delta_part2}
    ${delta_recomm_status}=  Run Keyword And Return Status
    ...  admin.Perform Delta Recommissioning  ${delta_json}  skip_parameter_relation_errors=True  should_activate=True  connection=${BTS_ID}
    Wait Until Keyword Succeeds  10x  60  STATE Verify BTS states  node_id=${BTS_ID}
    Logging With Timestamp
    ...  message=Step 2 Delta Recommissioning Too Many PSC Cells
    ...  style=DONE

Step 3 Reset Site & Check States For PSC Cells
    Logging With Timestamp
    ...  message=Step 3 Reset Site & Check States.
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Resetting site...
    ...  style=ONGOING
    ${reset_response}=  Run Keyword And Continue On Failure  admin.Reset Site
    ...  timeout=600
    ...  connection=${BTS_ID}
    ...  wait_for_reconnection=True
    ...  detailed_output=True
    Wait Until Keyword Succeeds  600  30
	  ...  STATE Check Class States  class=LNCEL  node_id=${BTS_ID}
    Wait Until Keyword Succeeds  600  30  STATE Verify BTS Procedural State  OnAir  ${BTS_ID}
    Logging With Timestamp
    ...  message=The site has been reset.
    ...  style=DONE
    ${scf_file_path}=  admin.Get Current Scf File
    ...  local_dir_path=${TEST_LOGS_PATH}/TestFiles
    ...  file_name=test_current_scf_03
    ...  export_type=configurationAndRuntimeObjects
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Checking whether power group has the same number as baseband pool...
    ...  style=ONGOING
    ${cells_in_bbpool}=  Get ABIA BBPOOLs For Tested Cells  ${BBMOD_CELL_MAPPING}  ${NODE_CELLS_DICT}  ${bts_id}
    Logging With Timestamp
    ...  message=Checking whether power group has the same number as baseband pool finished.
    ...  style=DONE
    ${cells_in_first_pool}  ${cells_in_second_pool}=  Sort Cells According To First And Second BBPOOL  ${cells_in_bbpool}  ${BBMOD_DNS}
    Check Whether PSC Or NPSC On BBPOOL
    ...  ${BBMOD_DNS}  ${cells_in_bbpool}  ${cells_in_first_pool}  ${cells_in_second_pool}
    ...  ${BBMOD_NPSC_PSC_MAPPING}  ${BBMOD_CONF_INT_DICT}
    Logging With Timestamp
    ...  message=Step 3 Reset Site & Check States.
    ...  style=DONE

Step 4 Perform L3 Call For PSC Cells
    Logging With Timestamp
    ...  message=Step 4 Perform L3 Call For PSC Cells - to be introduced
    ...  style=STEP
    ...  frame=${TRUE}

Check Whether PSC Or NPSC On BBPOOL
    [Arguments]  ${bbmod_dns}  ${cells_in_bbpool}  ${cells_in_first_pool}  ${cells_in_second_pool}
    ...  ${bbmod_npsc_psc_mapping}  ${bbmod_conf_int_dict}
    Logging With Timestamp
    ...  message=Checking whether NPSC cells are listed under baseband pool #1...
    ...  style=ONGOING
    @{first_bbpool_list}=  Create List
    @{second_bbpool_list}=  Create List
    FOR  ${bbmod_dn}  IN  @{bbmod_dns}
      ${abia_no}=  Fetch From Right  ${bbmod_dn}  -
      ${bbmod_internal_dn}=  Get From Dictionary  ${bbmod_conf_int_dict}  ${bbmod_dn}
      @{npsc_cells_copy}=  Copy List  ${bbmod_npsc_psc_mapping['${bbmod_internal_dn}'][0]['npsc_cells']}
      ${npsc_count}=  Get Length  ${npsc_cells_copy}
      @{psc_cells_copy}=  Copy List  ${bbmod_npsc_psc_mapping['${bbmod_internal_dn}'][1]['psc_cells']}
      ${psc_count}=  Get Length  ${psc_cells_copy}
      FOR  ${cell_in_first_bbpool}  IN  @{cells_in_first_pool}
        ${bbpool}=  Get From Dictionary  ${cells_in_bbpool}  ${cell_in_first_bbpool}
        ${pool_number}=  Fetch From Right  ${bbpool}  -
        ${cell_no}=  Fetch From Right  ${cell_in_first_bbpool}  -
        ${cell_number}=  Convert To Integer  ${cell_no}
        @{character_list}=  Split String To Characters  ${pool_number}
        Run Keyword If  '${character_list[0]}'=='${abia_no}' and '${character_list[1]}'=='1'  Run Keywords
        ...  Append To List  ${first_bbpool_list}  ${cell_in_first_bbpool}
        ...  AND  Remove Values From List  ${npsc_cells_copy}  ${cell_number}
      END
      FOR  ${cell_in_second_bbpool}  IN  @{cells_in_second_pool}
        ${bbpool}=  Get From Dictionary  ${cells_in_bbpool}  ${cell_in_second_bbpool}
        ${pool_number}=  Fetch From Right  ${bbpool}  -
        ${cell_no}=  Fetch From Right  ${cell_in_second_bbpool}  -
        ${cell_number}=  Convert To Integer  ${cell_no}
        @{character_list}=  Split String To Characters  ${pool_number}
        Run Keyword If  '${character_list[0]}'=='${abia_no}' and '${character_list[1]}'=='2'  Run Keywords
        ...  Append To List  ${second_bbpool_list}  ${cell_in_second_bbpool}
        ...  AND  Remove Values From List  ${psc_cells_copy}  ${cell_number}
      END
    ${overflowing_npsc}=  Run Keyword And Return Status  Should Be Empty  ${npsc_cells_copy}
    ${overflowing_psc}=  Run Keyword And Return Status  Should Be Empty  ${psc_cells_copy}
    Run Keyword If  ${overflowing_npsc}==False and ${overflowing_psc}==False
    ...  Fail  "Overflowing cells NOT detected. Check configuration"
    Run Keyword If  ${overflowing_npsc}==False and ${overflowing_psc}==True
    ...  Check Whether Overflowing PSC Cells Fit In The Other BBPOOL
    ...  ${cells_in_first_pool}  ${cells_in_bbpool}  ${abia_no}
    ...  ${first_bbpool_list}  ${second_bbpool_list}  ${npsc_cells_copy}
    END
    Logging With Timestamp
    ...  message=Checking whether NPSC cells are listed under baseband pool #1 finished.
    ...  style=DONE
    Logging With Timestamp
    ...  message=Checking whether PSC cells are listed under baseband pool #2 finished.
    ...  style=DONE

Check Whether Overflowing PSC Cells Fit In The Other BBPOOL
    [Arguments]  ${cells_in_first_pool}  ${cells_in_bbpool}  ${abia_no}
    ...  ${first_bbpool_list}  ${second_bbpool_list}  ${npsc_cells_copy}
      FOR  ${cell_in_first_bbpool}  IN  @{cells_in_first_pool}
        ${bbpool}=  Get From Dictionary  ${cells_in_bbpool}  ${cell_in_first_bbpool}
        ${pool_number}=  Fetch From Right  ${bbpool}  -
        ${cell_no}=  Fetch From Right  ${cell_in_first_bbpool}  -
        ${cell_number}=  Convert To Integer  ${cell_no}
        @{character_list}=  Split String To Characters  ${pool_number}
        Run Keyword If  '${character_list[0]}'=='${abia_no}' and '${character_list[1]}'=='1'  Run Keywords
        ...  Append To List  ${first_bbpool_list}  ${cell_in_first_bbpool}
        ...  AND  Remove Values From List  ${npsc_cells_copy}  ${cell_number}
      END
    ${npsc_count}=  Get Length  ${first_bbpool_list}
    ${psc_count}=  Get Length  ${second_bbpool_list}
    ${overflowing_psc_count}=  Evaluate  ${psc_count} - 6
    ${available_space_in_first_bbpool}=  Evaluate  6 - ${npsc_count}
    Run Keyword If  ${overflowing_psc_count} > 0
    ...  Logging with timestamp  message="Overflowing PSC cells detected: ${overflowing_psc_count}"
    Run Keyword If  ${overflowing_psc_count} > 0
    ...  Logging with timestamp  message="Available space in BBPOOL #1: ${available_space_in_first_bbpool}"
    ${available_space_left_in_first_bbpool}=  Evaluate  ${available_space_in_first_bbpool} - ${overflowing_psc_count}
    ${status}=  Evaluate  ${available_space_left_in_first_bbpool} >= 0
    Run Keyword If  ${status}==True
    ...  Logging with timestamp  message=Available space left in BBPOOL #1: ${available_space_left_in_first_bbpool}
    ...  ELSE  Fail  Not enough space in BBPOOL #1 to move all overflowing PSC cells. Check configuration.
