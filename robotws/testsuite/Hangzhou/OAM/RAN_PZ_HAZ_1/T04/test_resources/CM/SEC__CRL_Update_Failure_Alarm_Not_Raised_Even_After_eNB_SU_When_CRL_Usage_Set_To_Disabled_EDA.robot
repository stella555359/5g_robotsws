*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${primaryCRLDP}    http://10.92.49.71:8080/crl-as-der/currentcrl-2553099.crl?id=2553099
${wrong_primaryCRLDP}    http://1.1.1.1:8080/crl-as-der/currentcrl-1572682.crl?id=1572682
${serverIpAddressPrimary}    10.110.23.119
${wft_api_url}    https://wft.int.net.nokia.com:8091/ALL/api/v1/build_branch.json

*** Keywords ***
SEC__CRL_Update_Failure_Alarm_Not_Raised_Even_After_eNB_SU_When_CRL_Usage_Set_To_Disabled_EDA
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...     Config CRL With Wrong Adress And Set Usage Enable
    ...     Do CRL Update And Check Fault 61074 Raised
    ...     Disable CRL Usage And Check Fault 61074 Cancelled
    ...     Upgrade SW To Latest One
    ...     Check CRL Usage And Fault 61074 Not Raised After SW Upgrade
    ...  Pass criteria: No CRL update.(CRL update not allowed) and no CRL alarm raised when CRL usage is disabled, even after software upgrade.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 08.03.2023 - Commit to GIT
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Config CRL With Wrong Adress And Set Usage Enable
    Step 2: Do CRL Update And Check Fault 61074 Raised
    Step 3: Disable CRL Usage And Check Fault 61074 Cancelled
    Step 4: Upgrade SW To Latest One
    Step 5: Check CRL Usage And Fault 61074 Not Raised After SW Upgrade

Step ${index}: Config CRL With Wrong Adress And Set Usage Enable
    Log To Console    Step ${index}: Config CRL With Wrong Adress And Set Usage Enable
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    Set Test Variable    ${scf_xml}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    -
    Set Test Variable    ${mrbts_id}
    ${CRLDPCONFIG_count}    L_XML.Get Element Count   ${scf_xml}   .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1"]
    ${DNS_count}    L_XML.Get Element Count    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/DNS-1"]
    Set Test Variable   ${CRLDPCONFIG_count}
    Set Test Variable   ${DNS_count}
    ${operation_CRLDPCONFIG}    Set Variable If    ${CRLDPCONFIG_count}==${0}    create    update
    ${operation_DNS}    Set Variable If    ${DNS_count}==${0}    create    update
    ${json_tmp1}    Set Variable    [{"distName": "MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1", "operation": "update", "parameters": [{"parameterName":
    ${json_tmp2}    Set Variable    "distributionPointSource", "operation": "update", "value": "Configuration_parameter"},
    ${json_tmp3}    Set Variable    {"parameterName": "usageEnabled", "operation": "update", "value": "Enabled"}]},
    ${json_tmp4}    Set Variable    {"distName": "MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1", "operation": "${operation_CRLDPCONFIG}",
    ${json_tmp5}    Set Variable    "parameters":[{"parameterName": "primaryCRLDP", "operation": "update", "value": "${wrong_primaryCRLDP}"}]},
    ${json_tmp6}    Set Variable    {"distName": "MRBTS-${mrbts_id}/MNL-1/MNLENT-1/DNS-1", "operation": "${operation_DNS}", "parameters":
    ${json_tmp7}    Set Variable    [{"parameterName": "serverIpAddressPrimary", "operation": "update", "value": "${serverIpAddressPrimary}"}]}]
    ${param_json}    Set Variable    ${json_tmp1}${json_tmp2}${json_tmp3}${json_tmp4}${json_tmp5}${json_tmp6}${json_tmp7}
    coam.Perform Delta Recommissioning    ${param_json}    True

Step ${index}: Do CRL Update And Check Fault 61074 Raised
    Log To Console     Step ${index}: Do CRL Update And Check Fault 61074
    ${status}    Run Keyword And Return Status    coam.Update Certificate Revocation List    3GPP    10m
    Should Not Be True   ${status}
    Wait Until Keyword Succeeds    3x    5s    coam.Assert Alarm Active    alarmId=7220     faultId=61074

Step ${index}: Disable CRL Usage And Check Fault 61074 Cancelled
    Log To Console     Step ${index}: Disable CRL Usage And Check Fault 61074 Cancelled
    ${json_tmp1}    Set Variable    [{"distName": "MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1","operation": "update","parameters": [{"parameterName":
    ${json_tmp2}    Set Variable    "usageEnabled","operation": "update","value": "Disabled"}]}]
    ${param_json}    Set Variable    ${json_tmp1}${json_tmp2}
    coam.Perform Delta Recommissioning    ${param_json}    True
    Check WebEM After Modify Parameters    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1    usageEnabled=Disabled
    Wait Until Keyword Succeeds    3x    5s    coam.Assert Alarm Inactive    alarmId=7220     faultId=61074

Step ${index}: Upgrade SW To Latest One
    Log To Console    Step ${index}: Upgrade SW To Latest One
    ${target_build}    Fetch Lastest SBTS SW Build
    Download SBTS SW Build    ${target_build}
    Admin Upgrade SBTS SW     ${target_build}

Step ${index}: Check CRL Usage And Fault 61074 Not Raised After SW Upgrade
    Log To Console    Step ${index}: Check CRL Usage And Fault 61074 Not Raised After SW Upgrade
    Check WebEM After Modify Parameters    MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1    usageEnabled=Disabled
    ${status}    ${msg}    Run Keyword And Ignore Error    coam.Update Certificate Revocation List    3GPP    10m
    Should Be True   '${status}'=='FAIL'
    Should Contain    ${msg}    Rejected
    Log To Console    \nWaiting for 1h...........
    Sleep   60m
    Log To Console    \nEnd of 1h Waiting...........
    coam.Assert Alarm Inactive    alarmId=7220     faultId=61074
    ${rawnAlarmHistory}    coam.Get Raw Alarm History File
    Should Not Contain    ${rawnAlarmHistory}    (61074)\tEFaultId_CrlUpdateFailure

Fetch Lastest SBTS SW Build
    ${json_tmp1}    Set Variable    {"page": "1","items": "1","sorting_field": "created_at","sorting_direction": "DESC","group_by":
    ${json_tmp2}    Set Variable    "","group_by_processor": "","columns": {"0": {"id": "version"},"1": {"id": "delivery_date"},"2":{"id":
    ${json_tmp3}    Set Variable    "promotion_status_td"}},"projects": ["ALL"],"view_filters_attributes": {"0": {"column": "branch.title",
    ${json_tmp4}    Set Variable    "operation":"eq","value": "SBTS00","parameter": ""},"1": {"column": "quicktest.result","operation": "start",
    ${json_tmp5}    Set Variable    "value":"released","parameter": ""}},"access_key": "WoQ1OI0ImBDwwLUvNVVreWnJ34omNxqfvxs9Fdbi"}
    ${param_json}    Set Variable    ${json_tmp1}${json_tmp2}${json_tmp3}${json_tmp4}${json_tmp5}
    OperatingSystem.Create File    ${TestFiles}/params.json    ${param_json}
    ${output_json}    Set Variable    ${TestFiles}/response.json
    OperatingSystem.Run
    ...    curl -H 'Accept: application/json' -H 'Content-Type:application/json' -d@${TestFiles}/params.json ${wft_api_url} -o ${output_json}
    ${file_content}    OperatingSystem.Get File    ${output_json}
    ${file_content}    Replace String     ${file_content}    false    'false'
    ${response_dic}    Evaluate     ${file_content}
    ${target_build}    Set Variable    ${response_dic['items'][0]['version']}
    [Return]    ${target_build}

Recovery CRL Configuration
    ${json_tmp1}    Set Variable    [{"distName": "MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1","operation": "update","parameters": [{"parameterName":
    ${json_tmp2}    Set Variable    "usageEnabled","operation": "update","value": "Enabled"}]},
    ${json_tmp3}    Set Variable    {"distName": "MRBTS-${mrbts_id}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1","operation": "update","parameters":
    ${json_tmp4}    Set Variable    [{"parameterName": "primaryCRLDP","operation": "update","value": "${primaryCRLDP}"}]}]
    ${param_json}    Set Variable    ${json_tmp1}${json_tmp2}${json_tmp3}${json_tmp4}
    coam.Perform Delta Recommissioning    ${param_json}    True

CaseTearDown
    Log    CaseTearDown    console=True
    Recovery CRL Configuration
    Common Test Teardown SBTS    never