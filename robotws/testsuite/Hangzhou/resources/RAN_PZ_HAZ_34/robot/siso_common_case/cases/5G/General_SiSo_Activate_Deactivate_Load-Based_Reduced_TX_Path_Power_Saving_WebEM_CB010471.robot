*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/energy_efficiency.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot


*** Keywords ***
General_SiSo_Activate_Deactivate_Load-Based_Reduced_TX_Path_Power_Saving_WebEM_CB010471
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to activate and Deactivate CB10471,
    ...    activate feature gNB will reset,after that reach onAir state without alarms
    ...    Deactivate feature gNB will not reset
    ...    suite for AVQC 1s-2cc,1NRGRP
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.22.2024 - - Created
    ...    ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1588?filter=-1
    ...    - 02.28.2024 - - Created
    ...    ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1708
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock
    ${modify_parameters}   Set CB010471 modify parameters list    actNrLBPowerSaving=false  actNrLBmMimoRTXPowerSaving=false
    ...   actNrMixedSOMethod=false   lbpsSOMethod=cell switch off   actLbpsCtrlLogicEnh=false
    ...   actNrExtCellSOMethod=false   actCoordinated4g5gPowerSaving=disabled
    Modify Parameters On Webem    modify_params=${modify_parameters}
    ${ru_index_list}    Get RU index list    connection=${connection}
    Set Test Variable    ${ru_index_list}
    ${cell_list}    get all cell id
    Set Test Variable    ${cell_list}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Online    ru_index=${ru_index}
    END
    COAM Wait gnb And Cells ready    timeout=15 min
    ${modify_parameters}   Set energySavingMode and actNrLBPowerSaving    ru_index_list=${ru_index_list}
    Modify Parameters On Webem    modify_params=${modify_parameters}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    modify NRPGRP parameter
    # WESTLAKE-10935 due to CB013258-actMicroDTX becomes hidden parameter and default value is true
    # Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    # ...    filter_param=Activate micro discontinued transmission    abbr=actMicroDTX    new_value=true
    ${modify_parameters}   Set CB010471 modify parameters list
    Modify Parameters On Webem    modify_params=${modify_parameters}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline    ru_index=${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_index_list}
        Wait Until Keyword Succeeds    5min    5s    RU Should Be Online    ru_index=${ru_index}
    END
    COAM Wait gnb And Cells ready    timeout=15 min
    Prepare For CB010471
    COAM Wait gnb And Cells ready    timeout=15 min
    Wait Until Keyword Succeeds    10min    20s    Check All Cells In Energysaving
    Wait Until Keyword Succeeds    10min    20s    Check All Cells In Energysaving   energy_saving_state=notenergysaving
    ${ue_num_each_call}    Get Tput ue Number    given_num=4
    Get UE From Init File and Make call    cell_list=${cell_list}  ue_num_each_call=${ue_num_each_call}
    [Teardown]  Selenium Logout And Close Browser

modify NRPGRP parameter
    [Arguments]    ${NRPGRP_index}=1   ${lbpsLastCellSOEnabled}=${true}   ${lbpsLoadCalcMethod}=Max(G, C, P)
    ...   ${lbpsSOffTrRule}=MaxValueMethod  ${lbpsSOnTrRule}=MinValueMethod    ${connection}=GNB_OAM
    ...   ${lbpsLastCellMinLoad}=0   ${lbpsLastCellRTXMinLoad}=20  ${lbpsMonWinForCellSOff}=300
    ...   ${lbpsRTXSOffTime}=60
    ${stream}    get stream from version    version=${Active_SW_version}    convert_to_trunk=${False}
    IF    '${stream}' >= 'SBTS25R3'
        ${lbpsLoadCalcMethod}    Set Variable    Max(G_N_combined, P)
        ${lbpsSOffTrRule}    Set Variable    SlidingAverageMethod
    END
    ${modify_params}  create list
    ${lbpsLastCellSOEnabled_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsLastCellSOEnabled  value=${lbpsLastCellSOEnabled}
    ${lbpsLoadCalcMethod_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsLoadCalcMethod  value=${lbpsLoadCalcMethod}
    ${lbpsSOffTrRule_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsSOffTrRule  value=${lbpsSOffTrRule}
    ${lbpsSOnTrRule_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsSOnTrRule  value=${lbpsSOnTrRule}
    ${lbpsLastCellMinLoad_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsLastCellMinLoad  value=${lbpsLastCellMinLoad}
    ${lbpsLastCellRTXMinLoad_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsLastCellRTXMinLoad  value=${lbpsLastCellRTXMinLoad}
    ${lbpsMonWinForCellSOff_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsMonWinForCellSOff  value=${lbpsMonWinForCellSOff}
    ${lbpsRTXSOffTime_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsRTXSOffTime  value=${lbpsRTXSOffTime}
    append to list  ${modify_params}    ${lbpsLastCellSOEnabled_dic}    ${lbpsLoadCalcMethod_dic}    ${lbpsSOffTrRule_dic}    ${lbpsSOnTrRule_dic}
    ...    ${lbpsLastCellMinLoad_dic}    ${lbpsLastCellRTXMinLoad_dic}    ${lbpsMonWinForCellSOff_dic}    ${lbpsRTXSOffTime_dic}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${modify_params}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    ...   timeout=360
    [Return]    ${modify_params}

Prepare For CB010471
    [Arguments]   ${connection}=GNB_OAM
    ${lbps_period_list}   Update Parameter LbpsPeriodList With Current Time   lbpsDuration=10
    ${lbps_cell_list}   modify lbpsCellList parameter
    ${parameter_list}   combine lists  ${lbps_period_list}  ${lbps_cell_list}
    ${delta_file}=   coam_parameter.create_update_parameters_delta  parameters=${parameter_list}  connection=${connection}
    coam_parameter.perform_scf_delta_commission  delta_file=${delta_file['updated']}    connection=${connection}
    COAM Wait gnb And Cells ready    timeout=15 min

modify lbpsCellList parameter
    [Arguments]  ${NRPGRP_index}=1  ${lbpsCellSOOrder_high}=${60}    ${lbpsCellSOOrder_low}=${80}    ${lbpsUseExtConfig}=${False}
    ${lbpsCellList}    Create List
    FOR    ${cell_id}    IN    @{cell_list}
        IF    ${cell_id}==${1}
            ${lbpsCellSOOrder}    Set Variable    ${lbpsCellSOOrder_high}
        ELSE
            ${lbpsCellSOOrder}    Set Variable    ${lbpsCellSOOrder_low}
        END
        Log To Console   \nStart set lbps cell-${cell_id} list lbpsUseExtConfig:${lbpsUseExtConfig}, lbpsCellSOOrder:${lbpsCellSOOrder}
        ${lbpscell}    Create Dictionary    lbpsCellSOOrder=${lbpsCellSOOrder}    lbpsUseExtConfig=${lbpsUseExtConfig}    nrCellId=${cell_id}
        Append To List    ${lbpsCellList}    ${lbpscell}
    END
    ${lbpsCell_dict}    Create Dictionary    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRPGRP-${NRPGRP_index}
    ...    parameter=lbpsCellList    value=${lbpsCellList}
    ${lbps_cell_list_params}     Create List    ${lbpsCell_dict}
    [Return]    ${lbps_cell_list_params}

