*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
COAM Enable KPI Trigger Flag
    # COAM Login

    ${ENABLE_FEATURE_FLAG}   Convert To String   ${ENABLE_FEATURE_FLAG}
    ${ENABLE_FEATURE_FLAG}   Set Variable   ${ENABLE_FEATURE_FLAG.replace("'","\"")}

    coam.perform_delta_recommissioning
    ...   delta_file=${ENABLE_FEATURE_FLAG}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=COAM

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Disable KPI Trigger Flag
    # COAM Login

    ${DISABLE_FEATURE_FLAG}   Convert To String   ${DISABLE_FEATURE_FLAG}
    ${DISABLE_FEATURE_FLAG}   Set Variable   ${DISABLE_FEATURE_FLAG.replace("'","\"")}

    coam.perform_delta_recommissioning
    ...   delta_file=${DISABLE_FEATURE_FLAG}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=COAM

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Remove Trigger Formula Parameters
    # COAM Login

    ${REMOVE_TRIGGERING_FORMULA}   Convert To String   ${REMOVE_TRIGGERING_FORMULA}
    ${REMOVE_TRIGGERING_FORMULA}   Set Variable   ${REMOVE_TRIGGERING_FORMULA.replace("'","\"")}

    coam.perform_delta_recommissioning
    ...   delta_file=${REMOVE_TRIGGERING_FORMULA}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=COAM

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Update PM Enable Parameters
    # COAM Login

    ${PM_ENABLE_PARAMETER}   Convert To String   ${PM_ENABLE_PARAMETER}
    ${PM_ENABLE_PARAMETER}   Set Variable   ${PM_ENABLE_PARAMETER.replace("'","\"")}

    coam.perform_delta_recommissioning
    ...   delta_file=${PM_ENABLE_PARAMETER}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=COAM

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Check PM Counter List
    [Arguments]   ${counter_ids}
    # COAM Login

    ${counter_details}   coam.get_pm_counters   timeout=${120}   connection=COAM
    ...   counter_ids=${counter_ids}

    ${counter_exist}   check_all_counter_exist   counter_details=${counter_details}   counter_ids=${counter_ids}
    Run Keyword If   not ${counter_exist}   FAIL   msg=Counter Not Reported.

    # Log To Console   ${counters}

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Check Specific PM Counter List
    [Arguments]   ${counter_ids}
    # COAM Login

    ${check_counter_list}   Split String   ${counter_ids}   ,
    ${define_counter_list}   Split String   ${SPECIFIC_COUNTER_LIST}   ,

    ${specific_counter_exist}   Evaluate   any(counter in ${define_counter_list} for counter in ${check_counter_list})
    Return From Keyword If   not ${specific_counter_exist}   ${True}


    ${status}   ${counter_details}   Run Keyword And Ignore Error   coam.get_pm_counters   timeout=${120}   connection=COAM
    ...   counter_ids=${counter_ids}
    Return From Keyword If   "${status}"=="FAIL"   ${False}

    ${counter_exist}   check_all_counter_exist   counter_details=${counter_details}   counter_ids=${counter_ids}

    # Log To Console   ${counters}

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout
    [Return]   ${counter_exist}


COAM Update Trigger Formula Parameters
    [Arguments]   ${triggering_formula}
    # COAM Login

    ${triggering_formula}   Convert To String   ${triggering_formula}
    ${triggering_formula}   Set Variable   ${triggering_formula.replace("'","\"")}

    coam.perform_delta_recommissioning
    ...   delta_file=${triggering_formula}
    ...   skip_parameter_relation_errors=${false}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=COAM

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Check Fault List
    [Arguments]   ${fault_list}
    # COAM Login

    ${active_fault_id}   COAM Get Active Fault ID

    List Should Contain Sub List   ${active_fault_id}   ${fault_list}

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Check Fault List Clear
    [Arguments]   ${fault_list}
    # COAM Login

    ${active_fault_id}   COAM Get Active Fault ID

    Should Not Contain Any   ${active_fault_id}   @{fault_list}

    # [Teardown]   Run Keyword And Ignore Error   COAM Logout
