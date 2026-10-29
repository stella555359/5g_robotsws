*** Settings ***
Documentation     author: Wang binbin
...               contact: binbin.wang@nokia-sbell.com
...               squad group: SG_02
Suite Setup       679 Suite Setup
Suite Teardown    679 Suite TearDown
Force Tags        CB012238         PY36
Resource          Resources/CB012238_keywords.robot
Variables         Resources/CB012238_variables.py

*** Variables ***
${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs
${scf_path}          /home/ute/Downloads/SCF

*** Test Cases ***
[1][1.0] CB012238_B_301_Qos_fairness_slice_aware_scheduler_online_create_delete_RG_B203
    [Tags]    CB012238    CRT_trunk
    [Setup]    Case Setup CB012238
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/CB012238_scf.xml
    Run Keyword And Ignore Error        CB012238 UE attach and start traffic    host=${spark_ip}
    ...                                                                         port=${spark_port}
    ...                                                                         appserver=${appserver}
    ...                                                                         appserver_username=${appserver_username}
    ...                                                                         appserver_password=${appserver_password}
    Run Keyword And Ignore Error    CB012238 Check Counter Values    ${COUNTERS}    ${UNIQUE_PATH}
    Run Keyword And Ignore Error    CB012238 Ue Stop Ul Traffic                 host=${spark_ip}
    ...                                                                         port=${spark_port}
    [Teardown]    Run Keyword And Ignore Error   Recover test ENV    n=8    apn_address=mdrbnokiacom


*** Keywords ***
CB012238 check counter values
    [Arguments]    ${counters_id}    ${counters_unique_path}
    ${counter_values}    Run Keyword And Continue On Failure    Get BTS Counters From GNB    counters_id=${counters_id}
    ${rg1_used_dl}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[0]
    ${rg1_ratio_dl}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[1]
    ${rg1_used_ul}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[2]
    ${rg1_ratio_ul}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[3]
    ${rg2_used_dl}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[4]
    ${rg2_ratio_dl}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[5]
    ${rg2_used_ul}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[6]
    ${rg2_ratio_ul}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[7]
    ${cell10_avail_dl}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[8]
    ${cell10_avail_ul}     Get Latest Counters Values From GNB    ${counter_values}    ${counters_unique_path}[9]
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg1_ratio_dl}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg1_ratio_ul}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg2_ratio_dl}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0}<${rg2_ratio_ul}<${100}
    Run Keyword And Continue On Failure    Should Be True    ${0.61}<${rg1_used_dl}/${cell10_avail_dl}<${0.71}
    Run Keyword And Continue On Failure    Should Be True    ${0.61}<${rg1_used_ul}/${cell10_avail_ul}<${0.71}
    Run Keyword And Continue On Failure    Should Be True    ${0.28}<${rg2_used_dl}/${cell10_avail_dl}<${0.38}
    Run Keyword And Continue On Failure    Should Be True    ${0.28}<${rg2_used_ul}/${cell10_avail_ul}<${0.38}
