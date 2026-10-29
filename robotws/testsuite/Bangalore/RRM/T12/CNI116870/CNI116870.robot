*** Settings ***
Documentation   :copyright: Nokia
...             :author   : bkapatel
...             :contact  : bhakti.ka_patel@nokia.com
Resource    ./resources/Keywords/CNI116870_KW.robot
Suite Setup       Updated Suite Setup
Suite Teardown    Common Suite Teardown


*** Variables ***
${UE}       51
${QOS2}     2
${QOS3}     3
@{counters}      M55350C10001  M55350C10002  M55350C10003  M55350C10004  M55350C10005
...             M55350C10006  M55350C10007  M55350C10008  M55350C10009  M55350C10010
${MIN_VALUE}     7
${MAX_VALUE}    20


*** Test Cases ***
[1][1.0] CNI-116870_01_Verify_BINlevel_counter_to_measure_inactivity_or_muteness_in_UL_FDD_for_VoNR_call
    [Tags]    QC_60601   QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Prepare for the case
    Wait For Next Full Pm Interval
    Establish PDU session and register UE      ${UE}
    Modify PDU session to add Qos     ${UE}    ${QOS2}
    Modify PDU session to add Qos     ${UE}    ${QOS3}
    Start and Verify RTP data     ${UE}    ${period}
    Start and Verify TCP data    ${UE}
    Start and Verify UDP data     ${UE}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify counters    ${pm_counter_file}
    UE Deregistration    ${UE}


*** Keywords ***
Verify counters
    [Arguments]    ${pm_counter_file}
    FOR    ${i}   IN RANGE    0    10
        ${counter}    get_latest_pm_counter_value
        ...    counter_id=${counters}[${i}]
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    filepath=${pm_counter_file}
        log to console    \n Verifying counter ${counters}[${i}]
        variable should be in range      ${counter}
    END

Variable Should Be In Range
    [Arguments]  ${variable}  ${min_value}=${MIN_VALUE}  ${max_value}=${MAX_VALUE}
    Run Keyword If  ${variable} < ${min_value} or ${variable} > ${max_value}
    ...  Fail  ${variable} is not in range ${min_value} to ${max_value}
    Log to console    \n${variable} is within the range ${min_value} to ${max_value}
