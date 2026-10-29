*** Settings ***
Documentation    For Top50

Library           taf.sw.scout    WITH NAME    scout
Library           ute_reporting_portal


*** Variables ***
${SEND_REP_PYTHON_CODE_PATH_11}
    ...    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/UploadTCDataToRep_Top50.py



*** Keywords ***
Report To Rep
    [Arguments]    ${case_name}    ${qc_id}    ${build}    ${parameter_1}    ${testline}    ${status}
    ...    ${qc_domain}=MN_RAN    ${qc_project}=RAN_VRF    ${ca}=RAN_PZ_HAZ_1
    log    Report to Reporting Portal    console=${True}
    log    ${status}
    log    ${parameter_1}
#    ${result}    run keyword and return status    List Should Not Contain Value     ${status}    failed
#    return from keyword if    ${result}==${False}
#    ${case_result}    set variable if    ${result}==${True}    pass    else    failed
    ${case_result}    Set Variable    ${status}
    ${scf_id_status}    ${scf_id}    Run Keyword And Ignore Error
    ...    Report_To_Reporting_Portal_With_ConfigID.Get SCF Internal Id By Scout    bts_id=${testline}
    ${scf_id}    Set Variable If    "${scf_id_status}" == "PASS"    ${scf_id}    ${None}
#    ${str1}    set variable    python ${SEND_REP_PYTHON_CODE_PATH_11} '${qc_domain}' '${qc_project}' '${ca}'
#    ${str2}    set variable    '${case_name}' '${case_result}' '${build}' '${testline}' '${qc_id}' '${parameter_1}' '${scf_id}'
#    ${send_cmd}    Catenate    ${str1} ${str2}
#    ${ret}    OperatingSystem.Run    ${send_cmd}
#    Log To Console    ${ret}
    ${link_to_reporting_portal}=
    ...  ute_reporting_portal.report to rp
    ...  name=${case_name}
    ...  result=${case_result}
    ...  ca=${ca}
    ...  testline=${testline}
    ...  build=${build}
    ...  qc_domain=${qc_domain}
    ...  qc_project=${qc_project}
    ...  qc_id=${qc_id}
    #...  comment=${comment}
    ...  tc_execution_id=${scf_id}
    Log To Console    ${link_to_reporting_portal}


Get SCF Internal Id By Scout
    [Arguments]    ${bts_id}=${TESTLINE_NAME}    ${no_ute}=${True}
    [Documentation]    This kw is used to get scf id from scout by testline id
    ...    Author: Xu Yuyan
    ...    | Input Parameters | Man. | Description |
    ...    | testline_name | yes | use the scout testline id ,usually is bts id |
    ...    | internal | yes | if you use CM single run or auto trigger, please set False |
    ...
    ...    | Return Value | Description |
    ...    | scf_id | the internal id from scout |
    ...
    ...    Example
    ...    | Get SCF Internal Id By Scout | testline_name=6141 |
    [Timeout]    3 minutes
    scout.setup_scout    ${bts_id}
    ${scf_id}    scout.request_scf    use_scout_internal_id=${no_ute}
    Log to Console    scf id is: ${scf_id}
    [Teardown]    scout.teardown_scout_api
    [Return]    ${scf_id}