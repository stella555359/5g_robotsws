*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library      taf.selenium.sbts    WITH NAME    selenium_coam
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/nr_feature_on.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
*** Variables ***

*** Keywords ***
Manual_Siso_PM_5G_uDTX
    [Documentation]
    ...    *****************
    ...    [TEST DESCRIPTION] The feature 5GC000430 achieve energy savings through PA switch off for the duration on OFDM symbol
    ...    when there are no symbols to be send in that time slot. Through such micro-saving considerable amount of power can be saved.
    ...    [TEST PRECONDITIONS] microDTX parameter can only be equal to TRUE, if  either NRCELL.cellTechnology is equal to 1 (corresponding to TDD)
    ...    and NRCELL.nrarfcn <= 2016666 (cmWave TDD RUs) or NRCELL.cellTechnology is equal to 0 (corresponding to FDD)
    ...    If this parameter is equal to TRUE, then NRBTS.actGeneralConnectivityBronze must be equal to TRUE
    ...    *****************
    ...    [TEST STEPS]
    ...    1. Check power consumption with uDTX (actMicroDtx) disabled on OnAir state, to check uDTX is false and Note the power consumption
    ...    2. Note the values of RU power consumption
    ...    3. Enable uDTX (actMicroDtx) and check the power consumption
    ...    4. Note the values of RU power consumption When uDTX is enabled,And Compare the power consumption with step 2
    ...    5. Perform L3Call with DL and UL data, Max TPut (±10%) reached and stable for time described in test duration .
    ...    6. Disable uDTX (actMicroDtx) and check the power consumption
    ...    7. Note the values of RU power consumption When uDTX is disabled, And Compare the power consumption with step 2
    ...    8. Perform L3Call with DL and UL data,Max TPut (±10%) reached and stable for time described in test duration .

    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_type | yes | the parameter should be nr or lte, this is defined by yourself. |

    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.15.2024 - - Created ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1902
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${cell_type}   ${ru_index}=${1}  ${with_call}=${False}   ${with_peak}=${False}  ${ue_num_each_call}=1
    ...   ${4G_check}=${False}     ${dl_tp}=300  ${ul_tp}=20  ${connection}=GNB_OAM
    ...    ${duration}=${120}    ${dl_exp}=300    ${ul_exp}=20    ${actual_rate}=0.1
    ...    ${interval}=10s  ${target_avg_percent}=0.1    ${min_percent}=0.1   ${ue_dl_layer}=4
    ...   ${ue_ul_layer}=1    ${suite_name}=default    ${test_name}=default
    ...   ${power_change_range}=0.13    ${TP_Change_range}=0.1   ${ERROR_RANGE}=0.05
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Prepare for uDTX Ru Power Measurement   cell_type=${cell_type}
    Run Keyword If  "${cell_type}"=="nr"   NR Feature CB007511 OFF and Check
    log to console  \n Step1: Set 5GC000430 Feature Disable
    NR Feature 5GC000430 Set and Check Common  actMicroDTXAdvanced=false  actMicroDTX=false  cell_type=${cell_type}
    sleep   300s
    log to console  \n Step2: Note RU Power After Set 5GC000430 Feature Disable
    ${RMOD_Power_uDTX_disable}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    log to console  \n Step3: Set 5GC000430 Feature Enable
    NR Feature 5GC000430 Set and Check Common  actMicroDTXAdvanced=false  actMicroDTX=true  cell_type=${cell_type}
    sleep   300s
    log to console  \n Step4: Note RU Power After Set 5GC000430 Feature Enable
    ${RMOD_Power_uDTX_enable}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    log to console  \n Step5: Perform L3Call with DL and UL data
    ${cell_id_list}    Get All Cell Id    ${ru_index}    cell_type=${cell_type}
    ${cell_avg_tput_uDTX_enable}   Run Keyword If  "${cell_type}"=="nr" and ${with_call}   UE L3 Call And Get Avg Tput
    ...    cell_id_list=${cell_id_list}  ue_num_each_call=${ue_num_each_call}  flag=average
    ...  connection=${connection}  duration=${duration}  suite_name=${suite_name}  test_name=${test_name}  ue_ul_layer=${ue_ul_layer}
    ...   with_peak=${with_peak}  dl_tp=${dl_tp}  ul_tp=${ul_tp}  dl_exp=${dl_exp}  ul_exp=${ul_exp}  ue_dl_layer=${ue_dl_layer}
    ...  target_avg_percent=${target_avg_percent}  min_percent=${min_percent}  actual_rate=${actual_rate}  4G_check=${4G_check}
    ...  ELSE IF   "${cell_type}"!="nr" and ${with_call}      Simple UE L3 Call And Throughput    cell_list=${cell_id_list}
    ...                                 ue_num_for_call_per_cell=${ue_num_each_call}
    ...                                 dl_tp=${dl_tp}
    ...                                 ul_tp=${ul_tp}
    ...                                 duration=${duration}
    ...                                 target_avg_percent=${target_avg_percent}
    ...                                 min_percent=${min_percent}
    log to console  \n Step6:  Disable uDTX (actMicroDtx) and check the power consumption
    NR Feature 5GC000430 Set and Check Common  actMicroDTXAdvanced=false  actMicroDTX=false  cell_type=${cell_type}
    sleep   300s
    log to console  \n Step7: Note the values of RU power consumption When uDTX is disabled, And Compare the power consumption with step 2
    ${RMOD_Power_uDTX_disable_again}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=15min
    log to console  \n Step8: Perform L3Call with DL and UL data
    ${cell_avg_tput_uDTX_disable}   Run Keyword If  "${cell_type}"=="nr" and ${with_call}   UE L3 Call And Get Avg Tput
    ...    cell_id_list=${cell_id_list}  ue_num_each_call=${ue_num_each_call}  flag=average
    ...  connection=${connection}  duration=${duration}  suite_name=${suite_name}  test_name=${test_name}  ue_ul_layer=${ue_ul_layer}
    ...   with_peak=${with_peak}  dl_tp=${dl_tp}  ul_tp=${ul_tp}  dl_exp=${dl_exp}  ul_exp=${ul_exp}  ue_dl_layer=${ue_dl_layer}
    ...  target_avg_percent=${target_avg_percent}  min_percent=${min_percent}  actual_rate=${actual_rate}  4G_check=${4G_check}
    ...  ELSE IF   "${cell_type}"!="nr" and ${with_call}      Simple UE L3 Call And Throughput    cell_list=${cell_id_list}
    ...                                 ue_num_for_call_per_cell=${ue_num_each_call}
    ...                                 dl_tp=${dl_tp}
    ...                                 ul_tp=${ul_tp}
    ...                                 duration=${duration}
    ...                                 target_avg_percent=${target_avg_percent}
    ...                                 min_percent=${min_percent}
    Check uDTX Power Change    ${RMOD_Power_uDTX_disable}    ${RMOD_Power_uDTX_enable}  ${power_change_range}
    Check uDTX Power Change    ${RMOD_Power_uDTX_disable_again}    ${RMOD_Power_uDTX_disable}  ${power_change_range}  ${ERROR_RANGE}  true
    [Teardown]  selenium logout and close browser

Prepare for uDTX Ru Power Measurement
     [Arguments]    ${cell_type}=nr
    log to console   \n Prepare for uDTX Ru Power Measurement
    ${param_dic}  create dictionary  dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Power meter enabled  p_name=actPowerMeter  value=true
    ${modify_params}  create list  ${param_dic}
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}

NR Feature 5GC000430 Set and Check Common
    [Arguments]    ${actMicroDTXAdvanced}=false  ${actMicroDTX}=false  ${cell_type}=nr
    ...   ${ru_index}=1
    log to console
    ...   start set 5GC000430:${actMicroDTX}
    ${cell_id_list}    Run Keyword If  "${cell_type}"=="nr"  Create List   1
    ...   Get All Cell Id    ${ru_index}    cell_type=${cell_type}
    FOR  ${cell_id}  IN   @{cell_id_list}
        ${dist_name}  Set Variable If  "${cell_type}"=="nr"   MRBTS-${mrbtsID}/NRBTS-${nrbtsID}  MRBTS-${mrbtsID}/LNBTS-${nrbtsID}/LNCEL-${cell_id}
        ${p_name_prefix}  Set Variable If  "${cell_type}"=="nr"   DTX  Dtx
        ${filter_param}   Set Variable If  "${cell_type}"=="nr"  Activate micro discontinued transmission   Activate eNode B power saving - Micro DTX
        ${modify_params}  create list
        ${actMicroDTXAdvanced_dic}  create dictionary  dist_name=${dist_name}
        ...    filter_param=Activate micro discontinued transmission advanced  p_name=actMicroDTXAdvanced  value=${actMicroDTXAdvanced}
        ${actMicroDTX_dic}  create dictionary  dist_name=${dist_name}
        ...    filter_param=${filter_param}  p_name=actMicro${p_name_prefix}  value=${actMicroDTX}
        Run Keyword If  "${cell_type}"=="nr"  append to list  ${modify_params}  ${actMicroDTXAdvanced_dic}
        append to list  ${modify_params}  ${actMicroDTX_dic}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}

Check uDTX Power Change
    [Arguments]    ${power_off}    ${power_on}  ${power_range}=0.13  ${ERROR_RANGE}=0.05  ${is_same_settings}=false
    log to console  Check DTX Power Change
    ${power_change}    Evaluate    (${power_off}-${power_on})/${power_off}
    Run Keyword If    '${is_same_settings}'=='false'   Should Be True    ${power_change}>${power_range}
    ...    ELSE    Should Be True    ${power_change}<${ERROR_RANGE}
