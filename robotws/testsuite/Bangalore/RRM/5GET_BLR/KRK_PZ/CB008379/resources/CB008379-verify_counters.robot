*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHOR ==
...      - Marek Kieltyka <marek.kieltyka@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     ta5g_pm_counters
Library     map_counter_values.py

*** Variables ***


*** Keywords ***
Check counters NRPMQAP-${pmqap_id}: AVE_NUMBER_OF_SA_RRC ${avg}, QFI_SETUP_ATT ${att}, QFI_SETUP_SUCC ${suc}, QFI_REL ${rel}, QFI_REL_NORMAL ${nor}
    [Documentation]
    ...  In order to verify proper counters for given 5QI in NRPMQAP,
    ...  check NRPMQAP.cfg5qiRange profiles in DevKr/CB008379/config/yaml_config/NRPMQAP_counter_profiles.yaml
    # temporary workaround before ta5g_pm_counter better implementation
    ${avg}=     map_single_counter_value_to_any_counter_value       ${avg}
    ${att}=     map_single_counter_value_to_any_counter_value       ${att}
    ${suc}=     map_single_counter_value_to_any_counter_value       ${suc}
    ${rel}=     map_single_counter_value_to_any_counter_value       ${rel}
    ${nor}=     map_single_counter_value_to_any_counter_value       ${nor}
    Verify any counters in file
    ...    M55161C00001    ${avg}    AVE_NUMBER_OF_SA_RRC_PMQAP
    ...    M55163C00001    ${att}    NG_FLOW_SETUP_ATT_TOT_PMQAP
    ...    M55163C00002    ${suc}    NG_FLOW_SETUP_SUCC_PMQAP
    ...    M55163C00003    ${rel}    NG_FLOW_REL_PMQAP
    ...    M55163C00004    ${nor}    NG_FLOW_REL_NORMAL_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-${pmqap_id}
    ...    file_path=${PM_COUNTERS}

Check VRAN counters NRPMQAP-${pmqap_id}: AVE_NUMBER_OF_SA_RRC ${avg},QFI_SETUP_ATT ${att},QFI_SETUP_SUCC ${suc},QFI_REL ${rel},QFI_REL_NORMAL ${nor}
    ${avg}=     map_single_counter_value_to_any_counter_value       ${avg}
    ${att}=     map_single_counter_value_to_any_counter_value       ${att}
    ${suc}=     map_single_counter_value_to_any_counter_value       ${suc}
    ${rel}=     map_single_counter_value_to_any_counter_value       ${rel}
    ${nor}=     map_single_counter_value_to_any_counter_value       ${nor}
    Verify CU counter value on NRCELL-1/NRPMQAP-${pmqap_id} for M55161C00001 - AVE_NUMBER_OF_SA_RRC_PMQAP equals ${avg}
    Verify CU counter value on NRCELL-1/NRPMQAP-${pmqap_id} for M55163C00001 - NG_FLOW_SETUP_ATT_TOT_PMQAP equals ${att}
    Verify CU counter value on NRCELL-1/NRPMQAP-${pmqap_id} for M55163C00002 - NG_FLOW_SETUP_SUCC_PMQAP equals ${suc}
    Verify CU counter value on NRCELL-1/NRPMQAP-${pmqap_id} for M55163C00003 - NG_FLOW_REL_PMQAP equals ${rel}
    Verify CU counter value on NRCELL-1/NRPMQAP-${pmqap_id} for M55163C00004 - NG_FLOW_REL_NORMAL_PMQAP equals ${nor}

Check counters: SA_DU_ADM_SUCC_GBR_BWP2 ${suc_f}, SA_DU_ADM_SUCC_GBR_BWP1 ${suc_p}, SA_DU_ADM_ATT_GBR_BWP2 ${att_f}, SA_DU_ADM_ATT_GBR_BWP1 ${att_p}
    Verify any counters in file
    ...    M55139C04508     ${suc_f}    SA_DU_ADM_SUCC_GBR_BWP2
    ...    M55139C04506     ${suc_p}    SA_DU_ADM_SUCC_GBR_BWP1
    ...    M55139C04507     ${att_f}    SA_DU_ADM_ATT_GBR_BWP2
    ...    M55139C04505     ${att_p}    SA_DU_ADM_ATT_GBR_BWP1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${PM_COUNTERS}


${option:(Wait and check)|(Check)} RTPM counters: AMF_SELECTION_ATT ${att}, AMF_SELECTION_SUCC ${succ}
    Log to console    RTPM counters: AMF_SELECTION_ATT ${att}, AMF_SELECTION_SUCC ${succ}
    Run keyword if      "${option}" == "Wait and check"
    ...         Wait For Interval And Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRCELL-1    counter_id=M55155C1    value=${att}     timeout=105       enb_id=1
    Run keyword if      "${option}" == "Check"
    ...         Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRCELL-1    counter_id=M55155C1    value=${att}           enb_id=1
    Verify Rtpm Counter Value And Report To Rp
    ...         object_name=NRCELL-1    counter_id=M55155C3    value=${succ}          enb_id=1
