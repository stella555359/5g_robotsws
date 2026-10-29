*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource  taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource  taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot

*** Variables ***

*** Keywords ***
Cloud_General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] This describes the user scenario when operator performs RF scan test on in online mode to check if there is RF
    ...    -  present in UL after installation/commissioning of a new site or when UL performance is degraded or degrading slowly over time.
    ...    -  This case is for Cloud 1S-1CC-8D4U And test Composite RX (HBFO) - All Antennas and  Carrier RX (FIR9) - All Antennas
    ...    - [PARAMETERS] ru_index,  vdu_index, gnb_index
    ...    - [TEST METHODOLOGY] The test case is executed by following the steps below:
    ...    - 1. reconfigure actRfiTesting parameter to TRUE..
    ...    - 2. Operator opens RF Monitoring – RF Scan view in Web Element Manager, select inputs and start RF scan test.
    ...    - 3. Composite Rx (HBF0) required inputs: Radio ID.
    ...    - 4. Carrier Rx (FIR9) required inputs: Radio ID+Cell ID.
    ...    - 5. Check the RF Scan responce info And Check the RF scan files.
    ...    - 6. reconfigure actRfiTesting parameter to FALSE.
    ...    - [TEST EXPECTED RESULT] rf scan responce info is succes and Composite Rx (HBF0)  rf scan files num is 14.
    ...    -   Carrier Rx (FIR9) rf scan files num is 2 for each cell for AVQL.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 05.06.2024 - - Created    https://jiradc.ext.net.nokia.com/browse/LEOPARD-2008
    ...    *******************
    ...    Owner：kaihui.fan@nokia-sbell.com
    [Arguments]   ${ru_index}=1   ${vdu_index}=0  ${gnb_index}=0  ${composite_files_count}=14  ${carrier_files_count}=2
    Set actRfiTesting Parameter   actRfiTesting=true
    Start RF Sniffing RF Scanning All  ru_index=${ru_index}
    ...   vdu_index=${vdu_index}   gnb_index=${gnb_index}  composite_files_count=${composite_files_count}
    ...   carrier_files_count=${carrier_files_count}
    [Teardown]   Run Keyword And Ignore Error  Set actRfiTesting Parameter   actRfiTesting=false

Set actRfiTesting Parameter
    [Arguments]   ${actRfiTesting}=true
    log to console    RF Scan activation parameter (actRfiTesting) set
    ${actRfiTesting_delta_data}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  operation_type=update
    ...  actRfiTesting=${actRfiTesting}
    ${all_delta_data_list}=  create list   ${actRfiTesting_delta_data}
    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
    Wait Until Keyword Succeeds    15 min    40 sec   All Cells Should Be Onair For All vDUs

Start RF Sniffing RF Scanning All
    [Arguments]   ${ru_index}=1  ${vdu_index}=0  ${gnb_index}=0  ${composite_files_count}=14  ${carrier_files_count}=2
    log to console     \nStart RF Sniffing RF Scanning All
    log to console  \nStart RF Sniffing RF Scanning Composite Rx (HBF0) - All Antennas and check result
    ${rfscan_dir_path}=  Set Variable  ${SAVE LOG DIRECTORY}/RFScan
    Create Directory  path=${rfscan_dir_path}
    ${rmod_runtime_dn}  ${ants_runtime_dn_list}  ${cell_list}  Cloud Get RU And Antennas Dist Name And Cells  ru_index=${ru_index}
    log to console   RF Scanning for Composite RX (HBFO) - All Antennas
    ${rfscan_path_Composite}   Cloud Start RF Scan And Check Scan File    rmod_dn=${rmod_runtime_dn}  capture_type=RX_COMBINED  all_antennas=True
    ...  ants_runtime_dns=${ants_runtime_dn_list}   antenna_panel=Full_Array
    ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=Composite_RX_HBF0_${ru_index}  files_count=${composite_files_count}
    log to console   RF Scanning for Carrier RX (FIR9) - All Antennas
    FOR  ${rmod_cell_id}  IN  @{cell_list}
        ${antenna_carrier}=  Set Variable  MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRCELL-${rmod_cell_id}
        ${rfscan_path_Composite}   Cloud Start RF Scan And Check Scan File    rmod_dn=${rmod_runtime_dn}  capture_type=RX_CARRIER  all_antennas=True
        ...  ants_runtime_dns=${ants_runtime_dn_list}   antenna_panel=Full_Array
        ...   antenna_carrier=${antenna_carrier}  files_count=${carrier_files_count}
        ...  rfscan_dir_path=${rfscan_dir_path}  rfscan_filename=Composite_RX_HBF0_${ru_index}_NRCELL_${rmod_cell_id}
    END
