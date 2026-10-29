*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_feature_status.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Library   taf.rfrl.cbts.utilities.generic_utils
Resource  taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource  taf/rfrl/cbts/robot/vdu/vdu_operations.robot

*** Variables ***
@{prompt_match_ru_list}  AVQC  AVQL  AQQJ  AVQA  AVQD

*** Keywords ***
Manual_Siso_PM_5G_uDTX
    [Documentation]
    ...    *****************
    ...    [TEST DESCRIPTION] The feature 5GC000430 achieve energy savings through PA switch off for the duration on OFDM symbol
    ...    when there are no symbols to be send in that time slot. Through such micro-saving considerable amount of power can be saved.
    ...    [TEST PRECONDITIONS] microDTX parameter can only be equal to TRUE, if  either NRCELL.cellTechnology is equal to 1 (corresponding to TDD)
    ...    and NRCELL.nrarfcn <= 2016666 (cmWave TDD RUs) or NRCELL.cellTechnology is equal to 0 (corresponding to FDD)
    ...    If this parameter is equal to TRUE, then NRBTS.actGeneralConnectivityBronze must be equal to TRUE

    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | ru_family_type | Yes | The RU family type. Default is 'rf7',it should be made1,made2,rf7. |
    ...    | power_range | No | The power change range between power off and power on. Default is 0.13. |
    ...    | ERROR_RANGE | No | The error range when power off . Default is 0.05. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...    | ru_index | No | The RU index. Default is 1. |
    ...    | suite_name | No | The suite name. Default is 'default'. |
    ...    | with_call | No | A flag indicating if there is a call. Default is True. |
    ...    | test_name | No | The test name. Default is 'default'. |
    ...    | l3_avg_rate | No | The L3 average rate. Default is 0.1,this is the checkpoint Max TPut (±10%). |
    ...    | l3_min_rate | No | The L3 minimum rate. Default is 0.1. |
    ...    | nrgrp_id | No | The NR group ID. Default is 1. |
    ...    | uDTX_work_time | No | The uDTX work time. Default is '300s'. |

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

    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.30.2024 - - Created ticket:https://jiradc.ext.net.nokia.com/browse/REX-19698
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${ru_family_type}=rf7  ${power_change_range}=0.13   ${ERROR_RANGE}=0.05
    ...   ${vdu_index}=0    ${gnb_index}=0   ${suite_name}=default    ${with_call}=True
    ...  ${test_name}=default  ${l3_avg_rate}=0.1  ${l3_min_rate}=0.1  ${nrgrp_id}=1   ${uDTX_work_time}=300s
     ${rmods_ids}=    Get RMOD ID List By RESTAPI
    log to console   \nget ru list...${rmods_ids}
    log to console   \n Prepare for uDTX Ru Power Measurement make actPowerMeter open
    Cloud Prepare for uDTX Ru Power Measurement  nrgrp_id=${nrgrp_id}  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    log to console  \n Step1: Set 5GC000430 Feature Disable
    Cloud Modify 5GC000430 Status  actMicroDTXAdvanced=false  actMicroDTX=false
    sleep    ${uDTX_work_time}
    log to console  \n Step2: Note RU Power After Set 5GC000430 Feature Disable
    @{RMODs_Power_uDTX_disable}  Create List
    FOR  ${ru_index}  IN  @{rmods_ids}
        ${RMOD_Power_uDTX_disable}  Cloud Get RMOD Avg Power Measurement  prompt_match_ru_list=${prompt_match_ru_list}
        ...   ru_index=${ru_index}  ru_family_type=${ru_family_type}
        ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
        append to list  ${RMODs_Power_uDTX_disable}  ${RMOD_Power_uDTX_disable}
    END
    log to console  \n Step3: Set 5GC000430 Feature Enable
    Cloud Modify 5GC000430 Status  actMicroDTXAdvanced=false  actMicroDTX=true
    sleep    ${uDTX_work_time}
    log to console  \n Step4: Note RU Power After Set 5GC000430 Feature Enable
    @{RMODs_Power_uDTX_enable}  Create List
    FOR  ${ru_index}  IN  @{rmods_ids}
        ${RMOD_Power_uDTX_enable}    Cloud Get RMOD Avg Power Measurement  prompt_match_ru_list=${prompt_match_ru_list}
        ...  ru_index=${ru_index}  ru_family_type=${ru_family_type}
        ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
        append to list  ${RMODs_Power_uDTX_enable}  ${RMOD_Power_uDTX_enable}
    END
    log to console  \n Step5: Perform L3Call with DL and UL data
    ${cell_index_list}   vDU Get Cell List From Webem
    Run Keyword If  ${with_call}   Cloud UE L3 Call And Throughput  cell_list=${cell_index_list}    test_name=${test_name}
    ...   suite_name=${suite_name}   l3_avg_rate=${l3_avg_rate}     l3_min_rate=${l3_min_rate}
    log to console  \n Step6:  Disable uDTX (actMicroDtx) and check the power consumption
    Cloud Modify 5GC000430 Status   actMicroDTXAdvanced=false  actMicroDTX=false
    sleep    ${uDTX_work_time}
    log to console  \n Step7: Note the values of RU power consumption When uDTX is disabled, And Compare the power consumption with step 2
    @{RMODs_Power_uDTX_disable_again}  Create List
    FOR  ${ru_index}  IN  @{rmods_ids}
        ${RMOD_Power_uDTX_disable_again}  Cloud Get RMOD Avg Power Measurement  prompt_match_ru_list=${prompt_match_ru_list}
        ...  ru_index=${ru_index}  ru_family_type=${ru_family_type}
        ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}
        append to list  ${RMODs_Power_uDTX_disable_again}  ${RMOD_Power_uDTX_disable_again}
    END
    log to console  \n Step8: Perform L3Call with DL and UL data
    Run Keyword If  ${with_call}   Cloud UE L3 Call And Throughput  cell_list=${cell_index_list}    test_name=${test_name}
    ...   suite_name=${suite_name}   l3_avg_rate=${l3_avg_rate}     l3_min_rate=${l3_min_rate}
    ${rmod_power_num}  Get Length  ${RMODs_Power_uDTX_enable}
    log to console  \n Step9: compare ru power consumption  when uDTX_enable and uDTX_disable
    FOR  ${ru_index}  IN RANGE  0   ${rmod_power_num}
        Check uDTX Power Change    ${RMODs_Power_uDTX_disable[${ru_index}]}    ${RMODs_Power_uDTX_enable[${ru_index}]}  ${power_change_range}
        Check uDTX Power Change    ${RMODs_Power_uDTX_disable_again[${ru_index}]}    ${RMODs_Power_uDTX_disable[${ru_index}]}
        ...   ${power_change_range}  ${ERROR_RANGE}  true
    END

Cloud Prepare for uDTX Ru Power Measurement
    [Arguments]  ${nrgrp_id}=1  ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    *****************
    ...    This keyword is used to prepare for the uDTX Ru Power Measurement.
    ...    - [Keyword Details]
    ...    It constructs the delta data for delta commissioning and creates a list of all delta data.
    ...    It performs a fast delta commission with the delta data list.
    ...    It waits until all cells are on air for all vDUs.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | nrgrp_id | No | The NR group ID. Default is 1. |
    ...    | vdu_index | No | The vDU index. Default is 0. |
    ...    | gnb_index | No | The gNB index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 30.05.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************

    log to console   \n Prepare for uDTX Ru Power Measurement
    ${actPowerMeter_delta_data}=  generic_utils.construct_delta_data_for_delta_commissioning
    ...  mo_dn=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  operation_type=update
    ...  actPowerMeter=true
    ${all_delta_data_list}=  create list   ${actPowerMeter_delta_data}
    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
    Wait Until Keyword Succeeds    15min    5s    All Cells Should Be Onair For All vDUs

Check uDTX Power Change
    [Arguments]    ${power_off}    ${power_on}  ${power_range}=0.13  ${ERROR_RANGE}=0.05  ${is_same_settings}=false
    [Documentation]    *****************
    ...    This keyword is designed to check the power change when uDTX is enabled or disabled.
    ...    - [Keyword Details]
    ...    It calculates the power change and checks if it is within the expected range.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | power_off | Yes | The power when uDTX is off. |
    ...    | power_on | Yes | The power when uDTX is on. |
    ...    | power_range | No | The power change range between power off and power on. Default is 0.13. |
    ...    | ERROR_RANGE | No | The error range when power off . Default is 0.05. |
    ...    | is_same_settings | No | A flag indicating if the settings are the same. Default is false. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 30.05.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************

    log to console  Check DTX Power Change
    ${power_change}    Evaluate    (${power_off}-${power_on})/${power_off}
    Run Keyword If    '${is_same_settings}'=='false'   Should Be True    ${power_change}>${power_range}
    ...    ELSE    Should Be True    ${power_change}<${ERROR_RANGE}
