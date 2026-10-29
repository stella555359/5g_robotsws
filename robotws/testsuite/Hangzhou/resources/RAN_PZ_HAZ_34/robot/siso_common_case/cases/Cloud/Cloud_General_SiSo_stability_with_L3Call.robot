*** Settings ***
Library           taf.rfrl.cbts.utilities.tl_config   WITH NAME  tl_config
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot


*** Keywords ***
Cloud_General_SiSo_stability_with_L3Call
    [Documentation]    *****************
    ...    - [TEST PURPOSE] The purpose of this keyword is to verify the stability of the SiSo system during long duration
    ...    run and test for possible throughput and latency degradation.
    ...    - [TEST PROCEDURE] The test procedure is as follows:
    ...        1. Reset the vCU and wait until cell on air.
    ...        2. Reset the vDUs and wait until cell on air.
    ...        3. Get the cell list for vDU.
    ...        4. Obtain the UE list for the given cell list.
    ...        5. Generate peak information with given parameters.
    ...        6. Execute the Cloud UE L3 Call Procedure.
    ...    - [EXPECTED RESULTS]
    ...        The SiSo system maintains stability during the long duration run; 
    ...        throughput and latency remain within acceptable limits.

    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | scf_path | No | The SCF path. |
    ...    | dl_tp | No | The downlink throughput. |
    ...    | ul_tp | No | The uplink throughput. |
    ...    | stability_l3_duration | No | The duration for L3 stability. |
    ...    | check_wait_time | No | The check wait time. |
    ...    | target_avg_percent | No | The target average percent. |
    ...    | min_percent | No | The minimum percent. |
    ...    | mobile_network_system | No | The mobile network system (NR or LTE). |
    
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 27.05.2024 - - Created
    ...    *******************
    ...    * Owner: shifu.lan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_T04
    ...    *******************
    [Arguments]  ${scf_path}=${Golden_VDU_SCF_Path}    ${dl_tp}=300  ${ul_tp}=30    ${stability_l3_duration}=${21600}
    ...    ${check_wait_time}=60    ${target_avg_percent}=0.5    ${min_percent}=0.3
    ...    ${mobile_network_system}=NR    ${gnb_index}=${0}

    Cloud Reset VCU And Check Cell On Air    need_check_on_air=${True}    gnb_index=${gnb_index}
    ${vdu_number}   tl_config.get_vdu_number    ${gnb_index}
    FOR  ${vdu_index}   IN RANGE    ${vdu_number}
        Cloud Reset vDU and Check Cell On Air   need_check_on_air=${True}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    END

    ${cell_list}    Cloud Get Cells Id List
    ${ue_index_list}    ${cell_id_list}    Obtain UE List for Given Cell List    cell_list=${cell_list}
    ...    scf_path=${scf_path}    mobile_network_system=${mobile_network_system}
    ${cell_and_peak_info}    Cloud Generate Peak Information with Given Params    cell_id=${cell_id_list[0]}
    ...    dl_tp=${dl_tp}    ul_tp=${ul_tp}    duration=${stability_l3_duration}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    Cloud UE L3 CAll Procedure    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
    ...    check_wait_time=${check_wait_time}    duration=${stability_l3_duration}
