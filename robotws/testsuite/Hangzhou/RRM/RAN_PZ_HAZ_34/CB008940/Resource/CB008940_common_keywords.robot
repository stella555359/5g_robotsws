*** Settings ***
Documentation     author: Chen Helen
...               contact: helen.1.chen@nokia-sbell.com
...               squad group: MMW_02


Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource          ../../CB006915/resources/CB006915_common_keywords.robot

*** Variables ***
@{dl_counter_id}   M55308C10001    M55308C10003    M55308C10005
@{dl_counter_full_path}    [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_USED_PDSCH
...             [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_AVAIL_PDSCH
...             [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_AVAIL_PDSCH_BB_POOL
@{ul_counter_id}   M55308C10002    M55308C10004    M55308C10006
@{ul_counter_full_path}    [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_USED_PUSCH
...             [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_AVAIL_PUSCH
...             [TL169_ECPRI_SA] MRBTS-11332/NRBTS-11332/NRCELL-1/NCELA/PRB_AVAIL_PUSCH_BB_POOL
*** Keywords ***
Check_DL_Pool_Counter
    ${PM_counter_PRB_USED_PDSCH}    Check PM counter from webui
    ...    counter_id=${dl_counter_id}[0]    full_path=${dl_counter_full_path}[0]
    ${PM_counter_PRB_AVAIL_PDSCH}    Check PM counter from webui
    ...    counter_id=${dl_counter_id}[1]    full_path=${dl_counter_full_path}[1]
    ${PM_counter_PRB_AVAIL_PDSCH_BB_POOL}    Check PM counter from webui
    ...    counter_id=${dl_counter_id}[2]    full_path=${dl_counter_full_path}[2]
    ${PM_counter_difference_value1}    Compare_Two_Counters_Value
    ...    counter1=${PM_counter_PRB_USED_PDSCH}    counter2=${PM_counter_PRB_AVAIL_PDSCH}
    ${PM_counter_difference_value2}    Compare_Two_Counters_Value
    ...    counter1=${PM_counter_PRB_AVAIL_PDSCH}    counter2=${PM_counter_PRB_AVAIL_PDSCH_BB_POOL}
    should be true    ${PM_counter_difference_value1} > 0
    should be true    ${PM_counter_difference_value2} == 0

Check_UL_Pool_Counter
    ${PM_counter_PRB_USED_PUSCH}    Check PM counter from webui
    ...    counter_id=${ul_counter_id}[0]    full_path=${ul_counter_full_path}[0]
    ${PM_counter_PRB_AVAIL_PUSCH}    Check PM counter from webui
    ...    counter_id=${ul_counter_id}[1]    full_path=${ul_counter_full_path}[1]
    ${PM_counter_PRB_AVAIL_PUSCH_BB_POOL}    Check PM counter from webui
    ...    counter_id=${ul_counter_id}[2]    full_path=${ul_counter_full_path}[2]
    ${PM_counter_difference_value1}    Compare_Two_Counters_Value
    ...    counter1=${PM_counter_PRB_USED_PUSCH}    counter2=${PM_counter_PRB_AVAIL_PUSCH}
    ${PM_counter_difference_value2}    Compare_Two_Counters_Value
    ...    counter1=${PM_counter_PRB_AVAIL_PUSCH}    counter2=${PM_counter_PRB_AVAIL_PUSCH_BB_POOL}
    should be true    ${PM_counter_difference_value1} > 0
    #should be true    ${PM_counter_difference_value2} == 0

Compare_Two_Counters_Value
    [Arguments]    ${counter1}    ${counter2}
    ${length1}    Get Length    ${counter1}
    ${length2}    Get Length    ${counter2}
    ${difference_value}    set variable    ${0}
    ${length}    Set Variable If    ${length1} > ${length2}    ${length2}    ${length1}
    ${sum_counter1}    set variable    ${0}
    ${counter1_result_value}    Get Dictionary Values    ${counter1}
    log to console    ${counter1_result_value}
    FOR    ${i}    IN RANGE    1    ${length}
        ${sum_counter1}    Evaluate    ${sum_counter1} + ${counter1_result_value[${i}]}
    END
    ${sum_counter2}    set variable    ${0}
    ${counter2_result_value}    Get Dictionary Values    ${counter2}
    log to console    ${counter2_result_value}
    FOR  ${i}  IN RANGE    1    ${length}
        ${sum_counter2}    Evaluate    ${sum_counter2} + ${counter2_result_value[${i}]}
    END
    ${difference_value}    Evaluate    ${sum_counter2} - ${sum_counter1}
    [Return]    ${difference_value}
