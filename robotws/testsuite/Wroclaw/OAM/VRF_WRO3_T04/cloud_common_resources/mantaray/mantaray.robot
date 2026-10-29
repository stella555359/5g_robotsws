*** Settings ***
Documentation    Keywords to perform varius operations with Mantaray NMS labs.
...              Author:    Klaudyna Piechocka
...              Contact:   klaudyna.piechocka@nokia.com

Library     taf.nms.netact          WITH NAME    nms
Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     ./mantaray.py
Library     SSHLibrary
Library     taf.sw.graylog    WITH NAME    graylog

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../cloud_common_resources/connections/connections.robot
Resource    ../../../cloud_common_resources/certificates/certificates.robot

*** Variables ***
${NMS_USERNAME}        omc
${NMS_PASSWORD}        Medsql!_1893
${PLAN_NAME}           single_plan
${PLAN_NAME_MULTI}     multi_plan
${NMS_ROOT_USER}       root
${NMS_ROOT_PASS}       arthur
${GRAYLOG_USER}=       admin
${GRAYLOG_PASS}=       adminpassword
#IPs of Bangalore NMS Labs (cmwas nodes):
&{SRNCLABS}=    srnclab1015=10.41.146.134
...             srnclab1016=10.41.146.167
...             srnclab1025=10.41.148.15
...             srnclab1045=10.43.48.123
...             srnclab1027=10.41.148.99
...             srnclab1028=10.41.148.139
&{siem_node}    srnclab1015=10.41.146.82
...             srnclab1025=10.41.148.33
...             srnclab1045=10.43.48.120
...             srnclab1044=10.43.48.82
...             srnclab2010=10.82.47.131

${SRNLAB_CA}           CN=srnblrna1
${SRNLAB_CA_IP}        10.96.129.254
${SRNLAB_CA_REFNUM}    56215
${SRNLAB_CA_PSK}       X2gd-4PJa-QLo2-rk9k
${CA_SERVER_PATH}      pkix
${CA_DEFAULT_PORT}     8080
@{TLS1_3_PARAMS}       ${TRUE}            ${FALSE}        forced
@{TLS1_2_PARAMS}       ${FALSE}           ${TRUE}         forced
&{TLS_VERSIONS}                1_3=${TLS1_3_PARAMS}
...                            1_2=${TLS1_2_PARAMS}
${MAX_LAB_RETRIES}     3

*** Keywords ***
Integrate Cloud BTS with NMS Lab without TLS
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and integrates vCU/vDU to it.
    ...                                After integration node is deleted
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                                hw_type = vDU / vCU
    ...                                expected_status = Succeeded / Ongoing / N/A
    ...                                pre-connection = usefull if you want to integrate second vCU (georesiliency TL)
    ...                Author:         damian.kotula@nokia.com
    [Arguments]       ${LAB_NAME}=${NONE}    ${hw_type}=${NONE}   ${username}=${NMS_USERNAME}
    ...               ${password}=${NMS_PASSWORD}  ${expected_status}=Succeeded
    ...               ${pre-connection}=${NONE}    ${preferred_lab}=${NONE}
    ...               ${nidd_check}=False          ${sw_release}=${NONE}
    Deintegrate BTS from Mantaray Labs
    @{excluded_labs}      Create List
    ${release_version}=   Run Keyword If    '${sw_release}'=='${NONE}'    _Get Active SW For NMS Integration    hw_type=${hw_type}
    ...                   ELSE    Set Variable    ${sw_release}
    FOR    ${i}    IN RANGE    ${MAX_LAB_RETRIES}
        ${LAB_NAME1}    ${NMS_IP1}    Run Keyword If    '${nidd_check}'=='${True}'
        ...                           _Get Valid Netact Lab With NIDD    hw_type=${hw_type}    pre-conn=${pre-connection}
        ...                           preferred_lab=${preferred_lab}    sw_version=${release_version}    excluded_labs=${excluded_labs}
        ...                           ELSE    _Get Valid Netact Lab Without NIDD
        ...                           preferred_lab=${preferred_lab}    sw_version=${release_version}    excluded_labs=${excluded_labs}
        ${NMS_IP2}=      Run Keyword If     '${LAB_NAME}'!='${NONE}'    Get from Dictionary    ${SRNCLABS}    ${LAB_NAME}
        ${NMS_LAB_IP}    Set Variable If    '${LAB_NAME}'=='${NONE}'    ${NMS_IP1}    ${NMS_IP2}
        ${NMS_LAB}       Set Variable If    '${LAB_NAME}'=='${NONE}'    ${LAB_NAME1}    ${LAB_NAME}
        Log    ${hw_type} integration to Mantaray NMS started, lab ip=${NMS_LAB_IP}.    console=${True}
        IF    '${hw_type}'=='vDU'
            ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
            ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
            ${mrbts_id}=     Set Variable    ${MRBTS}
        ELSE IF    '${hw_type}'=='vCU'
            ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
            ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
            ${mrbts_id}=     Set Variable    ${MRBTS_CU}
        ELSE
            Fail    msg=hw_type doesn't exist
        END
        ${temp_conn}=    Run Keyword If     "${pre-connection}"=="${NONE}" and '${sw_release}'=='${NONE}'
        ...                                 Connect to ADMIN    hw_type=${hw_type}
        ...              ELSE IF            "${pre-connection}"!="${NONE}" and '${sw_release}'=='${NONE}'
        ...                                 Set Variable      ${pre-connection}
        ...              ELSE               Set Variable    ${NONE}
        Run Keyword If    '${sw_release}'=='${NONE}'    Change Parameter On BTS
        ...                                 dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
        ...                                 param_name=oamTls
        ...                                 param_value=off
        ...                                 hw_type=${hw_type}
        ...                                 pre-connection=${temp_conn}
        nms.Add Web URL                     ${NMS_LAB}lbwas.srnblr.nsn-rdnet.net    ${NMS_USERNAME}    ${NMS_PASSWORD}
        ...                                 alias=${NMS_LAB}
        Run Keyword and Ignore Error        nms.Delete Node    cmwas    alias=${NMS_LAB}
        nms.Add Node                        service_name=cmwas    hostname=${NMS_LAB_IP}    username=${username}    password=${password}
        ...                                 alias=${NMS_LAB}
        nms.Detect Nodes                    alias=${NMS_LAB}
        ${status}                           Run Keyword And Return Status    nms.Integrate Mrbts With Netact
        ...                                 release=${release_version}
        ...                                 mr=MRC-COMMON/MR-COMMON
        ...                                 mrbts_address=${mrbts_ip}
        ...                                 dist_name=${dist_name}
        ...                                 security_mode=no TLS
        ...                                 alias=${NMS_LAB}
        Run Keyword If                      '${sw_release}'=='${NONE}' and ${status}
        ...                                 Wait Until Keyword Succeeds    3 min    30 sec
        ...                                 Check NMS Status On Cloud BTS    expected_status=${expected_status}
        ...                                 hw_type=${hw_type}    pre-connection=${temp_conn}
        ...                                 ELSE IF  ${status}
        ...                                 Sleep    3min    reason=Wait until connection with MantaRay will be established
        Run Keyword If                      not ${status}
        ...                                 Run Keywords    Log    Integration with NMS with ${NMS_LAB} lab failed    console=true
        ...                                 AND    Append To List    ${excluded_labs}    ${NMS_LAB}
        ...                                 AND    Log to console    Excluded labs: ${excluded_labs}
        ...                                 AND    Continue For Loop
        Exit For Loop If                    ${status}
        Log    ${hw_type} integration to Mantaray NMS lab finished.    console=${True}
    END
    [Return]      ${NMS_LAB}
    [Teardown]    Run Keyword If    "${pre-connection}"=="${NONE}"and '${sw_release}'=='${NONE}'
    ...                              Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}

Integrate Cloud BTS with NMS Lab with TLS
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and integrates vCU/vDU to it.
    ...                                After integration node is deleted
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                                hw_type = vDU / vCU
    ...                                expected_status = Succeeded / Ongoing / N/A
    ...                                pre-connection = usefull if you want to integrate second vCU (georesiliency TL)
    ...                Author:         damian.kotula@nokia.com
    [Arguments]       ${LAB_NAME}=${NONE}    ${hw_type}=${NONE}    ${cert_type}=RSA    ${tls_version}=1_2
    ...               ${username}=${NMS_USERNAME}    ${password}=${NMS_PASSWORD}    ${expected_status}=Succeeded
    ...               ${pre-connection}=${NONE}      ${preferred_lab}=${NONE}   ${nidd_check}=False
    Deintegrate BTS from Mantaray Labs
    @{excluded_labs}      Create List
    ${release_version}=    Wait Until Keyword Succeeds    3min    5s    _Get Active SW For NMS Integration
    ...                                                                 hw_type=${hw_type}
    FOR    ${i}    IN RANGE    ${MAX_LAB_RETRIES}
        ${LAB_NAME1}    ${NMS_IP1}    Run Keyword If    '${nidd_check}'=='${True}'
        ...                           _Get Valid Netact Lab With NIDD    hw_type=${hw_type}    pre-conn=${pre-connection}
        ...                           preferred_lab=${preferred_lab}    sw_version=${release_version}    excluded_labs=${excluded_labs}
        ...                           ELSE    _Get Valid Netact Lab Without NIDD   preferred_lab=${preferred_lab}
        ...                           sw_version=${release_version}    excluded_labs=${excluded_labs}
        ${NMS_IP2}=      Run Keyword If     '${LAB_NAME}'!='${NONE}'    Get from Dictionary    ${SRNCLABS}    ${LAB_NAME}
        ${NMS_LAB_IP}    Set Variable If    '${LAB_NAME}'=='${NONE}'    ${NMS_IP1}    ${NMS_IP2}
        ${NMS_LAB}       Set Variable If    '${LAB_NAME}'=='${NONE}'    ${LAB_NAME1}    ${LAB_NAME}
        Log    ${hw_type} integration to Mantaray NMS started, lab ip=${NMS_LAB_IP}.    console=${True}
        ${temp_conn}=        Run Keyword If    "${pre-connection}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
        ...                  ELSE    Set Variable      ${pre-connection}
        _Setup certificates for MantaRay    ${cert_type}    ${tls_version}    ${hw_type}    pre-conn=${temp_conn}
        IF    '${hw_type}'=='vDU'
            ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
            ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
        ELSE IF    '${hw_type}'=='vCU'
            ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
            ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
        ELSE
            Fail    msg=hw_type doesn't exist
        END
        nms.Add Web URL                     ${NMS_LAB}lbwas.srnblr.nsn-rdnet.net    ${NMS_USERNAME}    ${NMS_PASSWORD}
        ...                                 alias=${NMS_LAB}
        Run Keyword and Ignore Error        nms.Delete Node    cmwas    alias=${NMS_LAB}
        nms.Add Node                        service_name=cmwas    hostname=${NMS_LAB_IP}    username=${username}    password=${password}
        ...                                 alias=${NMS_LAB}
        nms.Detect Nodes                    alias=${NMS_LAB}
        ${status}                           Run Keyword And Return Status    nms.Integrate Mrbts With Netact
        ...                                 release=${release_version}
        ...                                 mr=MRC-COMMON/MR-COMMON
        ...                                 mrbts_address=${mrbts_ip}
        ...                                 dist_name=${dist_name}
        ...                                 security_mode=TLS
        ...                                 alias=${NMS_LAB}
        Run Keyword If                      ${status}
        ...                                 Wait Until Keyword Succeeds    3 min    30 sec
        ...                                 Check NMS Status On Cloud BTS    expected_status=${expected_status}
        ...                                 hw_type=${hw_type}    pre-connection=${temp_conn}
        ...                                 ELSE IF  ${status}
        ...                                 Sleep    3min    reason=Wait until connection with MantaRay will be established
        Run Keyword If                      not ${status}
        ...                                 Run Keywords    Log    Integration with NMS with ${NMS_LAB} lab failed    console=true
        ...                                 AND    Append To List    ${excluded_labs}    ${NMS_LAB}
        ...                                 AND    Log to console    Excluded labs: ${excluded_labs}
        ...                                 AND    Continue For Loop
        Exit For Loop If                    ${status}
        Log  ${hw_type} integration to Mantaray NMS lab finished.    console=${True}
    END
    [Return]      ${NMS_LAB}
    [Teardown]    Run Keyword If    "${pre-connection}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=${hw_type}

Deintegrate Cloud BTS from NMS Lab
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and deintegrates vCU/vDU
    ...                                from this lab. After deintegration node is deleted.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                                hw_type = vDU / vCU
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${LAB_NAME}    ${hw_type}=${NONE}
    IF    '${hw_type}'=='vDU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
    ELSE IF    '${hw_type}'=='vCU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
        ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    nms.Detect Nodes    alias=${LAB_NAME}
    nms.Deintegrate Mrbts From Netact    dist_name=${dist_name}    alias=${LAB_NAME}
    nms.Delete Node  fmwas    alias=${LAB_NAME}
    nms.Delete Node  cmwas    alias=${LAB_NAME}
    nms.Clean All        alias=${LAB_NAME}
    Log    ${hw_type} deintegration from Mantaray NMS lab finished.    console=${True}
    [Teardown]    Run Keyword And Ignore Error   nms.Delete Node    cmwas    alias=${LAB_NAME}

Deintegrate BTS from Mantaray Labs
    [Documentation]    Description:    This KW deintegrate all labs as prerequisite.
    ...                Author:         jagoda.kubacka@nokia.com
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=srnclab*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    FOR  ${lab_file}  IN  @{randomized_list}
        Run Keyword And Ignore Error    Import Variables  ${CURDIR}/config/netact/${lab_file}
        Run Keyword And Ignore Error    nms.Add Node         cmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Deintegrate Mrbts From Netact    dist_name=PLMN-PLMN/MRBTS-${MRBTS_CU}
        ...                             alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Delete Node      fmwas    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Delete Node      cmwas    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Clean All        alias=deintegrate_${lab_file}
    END
    FOR  ${lab_file}  IN  @{randomized_list}
        Run Keyword And Ignore Error    Import Variables  ${CURDIR}/config/netact/${lab_file}
        Run Keyword And Ignore Error    nms.Add Node         cmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Deintegrate Mrbts From Netact    dist_name=PLMN-PLMN/MRBTS-${MRBTS}
        ...                             alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Delete Node      fmwas    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Delete Node      cmwas    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Clean All        alias=deintegrate_${lab_file}
    END

Get Active Alarms From Cloud BTS via MantaRay
    [Arguments]    ${LAB_NAME}    ${hw_type}=${NONE}
#    ...            ${MRBTS_ID}=${BTS_ID}
    IF    '${hw_type}'=='vDU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
    ELSE IF    '${hw_type}'=='vCU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
        ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    ${netact_alarms}    nms.get_alarms
    ...    dist_name=${dist_name}
    ...    alias=${LAB_NAME}
    Log    ${netact_alarms}    console=true
    ${x}=    extract_alarms    ${netact_alarms}
    [Return]    ${x}

Change Multiple Parameters with NMS
    [Documentation]    Description:    KW to change multiple parameters usung MantaRay lab
    ...                Input:          MOC_DN = destinguished name of managed object
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                                kwargs = parameters and values in format name=value
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${MOC_DN}    ${LAB_NAME}    &{kwargs}
    Run Keyword and Ignore Error    Delete plan     ${PLAN_NAME_multi}     alias=${LAB_NAME}
    ${plan_conf}=    Create Plan Configuration    ${PLAN_NAME_multi}   new plan    alias=${LAB_NAME}
    ${meta_class}     ${meta_version}    ${parameters}=    _Get Actual Configuration MO Data   ${MOC_DN}    ${LAB_NAME}
    ${managed_object}=    Create Managed Object    ${plan_conf}    ${meta_class}    ${meta_version}    PLMN-PLMN/${MOC_DN}    UPDATE
    ...                                            alias=${LAB_NAME}    &{kwargs}
    Wait Until Keyword Succeeds    5x    30s    Provision Plan
    ...    plan_name=${PLAN_NAME_MULTI}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate    ignore_errors=False    alias=${LAB_NAME}    timeout=1200
    [Teardown]    Delete Plan Configuration    ${plan_conf}


Change Parameter with NMS
    [Documentation]    Description:    KW to change single parameter usung MantaRay lab
    ...                Input:          MOC_DN = destinguished name of managed object
    ...                                param_name = abbreviated name of the parameter
    ...                                param_value = planned value of the parameter
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${MOC_DN}    ${param_name}    ${param_value}    ${LAB_NAME}
    Run Keyword and Ignore Error    Delete plan     ${PLAN_NAME}     alias=${LAB_NAME}
    ${plan_conf}=    Wait Until Keyword Succeeds  5x    30s    Create Plan Configuration    ${PLAN_NAME}   new plan    alias=${LAB_NAME}
    ${meta_class}     ${meta_version}    ${parameters}=    _Get Actual Configuration MO Data   ${MOC_DN}    ${LAB_NAME}
    ${managed_object}=    Create Managed Object    ${plan_conf}    ${meta_class}    ${meta_version}    PLMN-PLMN/${MOC_DN}    UPDATE
    ...                                            alias=${LAB_NAME}    ${param_name}=${param_value}
    Wait Until Keyword Succeeds    5x    30s    Provision Plan
    ...    plan_name=${PLAN_NAME}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate    ignore_errors=False    alias=${LAB_NAME}    timeout=1200
    [Teardown]    Delete Plan Configuration    ${plan_conf}

Check NMS Status On Cloud BTS
    [Documentation]    Description:    Checks status of NMS integration. Fails if status is not as expected,
    ...                Input:          expected_status = Succeeded / Ongoing / N/A
    ...                                hw_type = vDU / vCU
    ...                                pre-connection = usefull if you want to integrate second vCU (georesiliency TL)
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${expected_status}=Succeeded    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-connection}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
    ...                ELSE    Set Variable      ${pre-connection}
    IF    '${hw_type}'=='vDU' and "${pre-connection}"=="${NONE}"
        ${nms_status}=    vdu_admin.Get Nms    vdu_connection=${temp_conn}
        Run Keyword And Ignore Error    Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}
        Should Be True    "${nms_status['downlink_from_nms']}"=="${expected_status}"
        ...    msg=Downlink from NMS is ${nms_status['downlink_from_nms']}, expected ${expected_status}.
        Should Be True    "${nms_status['uplink_to_nms']}"=="${expected_status}"
        ...    msg=Uplink to NMS is ${nms_status['uplink_to_nms']}, expected ${expected_status}.
    ELSE IF    '${hw_type}'=='vDU' and not "${pre-connection}"=="${NONE}"
        ${nms_status}=    vdu_admin.Get Nms    vdu_connection=${temp_conn}
        Should Be True    "${nms_status['downlink_from_nms']}"=="${expected_status}"
        ...    msg=Downlink from NMS is ${nms_status['downlink_from_nms']}, expected ${expected_status}.
        Should Be True    "${nms_status['uplink_to_nms']}"=="${expected_status}"
        ...    msg=Uplink to NMS is ${nms_status['uplink_to_nms']}, expected ${expected_status}.
    ELSE IF    '${hw_type}'=='vCU' and "${pre-connection}"=="${NONE}"
        ${nms_status}=    vcu_admin.Get Nms    connection=${temp_conn}
        Run Keyword And Ignore Error    Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}
        Should Be True    "${nms_status['downlink_from_nms']}"=="${expected_status}"
        ...    msg=Downlink from NMS is ${nms_status['downlink_from_nms']}, expected ${expected_status}.
        Should Be True    "${nms_status['uplink_to_nms']}"=="${expected_status}"
        ...    msg=Uplink to NMS is ${nms_status['uplink_to_nms']}, expected ${expected_status}.
    ELSE IF    '${hw_type}'=='vCU' and not "${pre-connection}"=="${NONE}"
        ${nms_status}=    vcu_admin.Get Nms    connection=${temp_conn}
        Should Be True    "${nms_status['downlink_from_nms']}"=="${expected_status}"
        ...    msg=Downlink from NMS is ${nms_status['downlink_from_nms']}, expected ${expected_status}.
        Should Be True    "${nms_status['uplink_to_nms']}"=="${expected_status}"
        ...    msg=Uplink to NMS is ${nms_status['uplink_to_nms']}, expected ${expected_status}.
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    [Teardown]    Run Keyword If    "${pre-connection}"=="${NONE}"    Disconnect from ADMIN
    ...                                                               connection=${temp_conn}    hw_type=${hw_type}

Check If Local ATL Is Configured
    [Documentation]    Description:    This KW opens checks if ATL are redirected to local directory
    ...                Input:          NMS_LAB = lab BTS is integrated with
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]       ${LAB_NAME}
    Log    Log to graylog node and check if ATL is redirected    console=true
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${LAB_NAME}
    SSHLibrary.Open Connection   host=${atl_node_ip}
    SSHLibrary.Login             username=${NMS_ROOT_USER}       password=${NMS_ROOT_PASS}
    SSHLibrary.Write             ls /var/log
    Sleep    2
    ${output}=         SSHLibrary.Read
    ${status}=         Run Keyword And Return Status   Should Contain  ${output}     slc_syslog.log
    IF    '${status}'=='False'
           SSHLibrary.Write    /opt/oss/NSN-slc/bin/siem.sh add --local localOutput file=/var/log/slc_syslog.log size=1000 rotate=5
           SSHLibrary.Read Until    *Configuring SIEM*
    END
    [Teardown]    SSHLibrary.close all connections

Clear ATL
    [Documentation]    Description:    This KW clears ATL file
    ...                Input:          NMS_LAB = lab BTS is integrated with
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]       ${LAB_NAME}
    Log    Log to graylog node and check if ATL is redirected    console=true
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${LAB_NAME}
    SSHLibrary.Open Connection   host=${atl_node_ip}
    SSHLibrary.Login             username=${NMS_ROOT_USER}       password=${NMS_ROOT_PASS}
    SSHLibrary.Write             cat /dev/null > /var/log/slc_syslog.log
    [Teardown]    SSHLibrary.close all connections

Gather ATL for BTS
    [Documentation]    Description:    This KW clears ATL file
    ...                Input:          NMS_LAB = lab BTS is integrated with
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]       ${LAB_NAME}    ${hw_type}=${NONE}
    Log    Log to graylog node and check if ATL is redirected    console=true
        IF    '${hw_type}'=='vDU'
        ${BTS_ID}=    Set Variable    MRBTS-${MRBTS}
    ELSE IF    '${hw_type}'=='vCU'
        ${BTS_ID}=    Set Variable    MRBTS-${MRBTS_CU}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${LAB_NAME}
    SSHLibrary.Open Connection   host=${atl_node_ip}
    SSHLibrary.Login             username=${NMS_ROOT_USER}       password=${NMS_ROOT_PASS}
    SSHLibrary.Write    cat /var/log/slc_syslog.log | grep ${BTS_ID}
    Sleep    5
    ${ATL}=    SSHLibrary.read
    [Return]    ${ATL}
    [Teardown]    SSHLibrary.close all connections

Get PM Counters from Mantaray
    [Arguments]    ${mrbts_id}
    ...            ${technology}=SBTS-Nokia Multi Radio Transceiver Station
    ...            ${measurement}=IP filtering Statistics
    ...            ${counters}=ALL
    ...            ${filter_by}=MRBTS
    ...            ${object_aggregation}=PLMN/MRBTS/TNLSVC/TNL/IPNO
    ...            ${time_aggregation}=RAW
    ...            ${time_filter}=today
    ...            ${alias}=${None}
    ${result}      nms.get_pm_counters    technology=${technology}
    ...            measurement=${measurement}
    ...            counters=${counters}
    ...            filter_by=${filter_by}
    ...            mo_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...            object_aggregation=${object_aggregation}
    ...            time_aggregation=${time_aggregation}
    ...            time_filter=${time_filter}
    ...            alias=${alias}
    [Return]       ${result}

Activate CNUM user
    [Arguments]    ${LAB_NAME}    ${hw_type}=${NONE}
    IF    '${hw_type}'=='vDU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
        ${mrbts_ip}=     Set Variable    ${LMP_VDU_IP}
    ELSE IF    '${hw_type}'=='vCU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
        ${mrbts_ip}=     Set Variable    ${LMP_VCU_IP}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    nms.Activate CNUM
    ...    ne_id_value=${dist_name}
    ...    ip_type=IPv4
    ...    alias=${LAB_NAME}

Deactivate CNUM
    [Arguments]    ${LAB_NAME}    ${hw_type}=${NONE}
    IF    '${hw_type}'=='vDU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS}
    ELSE IF    '${hw_type}'=='vCU'
        ${dist_name}=    Set Variable    PLMN-PLMN/MRBTS-${MRBTS_CU}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    nms.Deactivate CNUM
    ...    ne_id_value=${dist_name}
    ...    ne_id_type=dn
    ...    alias=${LAB_NAME}

Setup Graylog
    [Documentation]    Description:    Setup Graylog API. To be executed before operations that will generate ATL logs.
    ...                Input:          lab_name = lab BTS is integrated with
    ...                                graylog_addr = address of graylog paired with given lab_name,
    ...                                               by default graylog from srnclab2010
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${lab_name}    ${graylog_addr}=10.99.102.48
    ...                ${graylog_username}=${GRAYLOG_USER}    ${graylog_password}=${GRAYLOG_PASS}
    graylog.setup_graylog_api    url=http://${graylog_addr}:9000/
    ...                          username=${graylog_username}    password=${graylog_password}
    ...                          api_token=${EMPTY}    version=3.3    alias=${lab_name}_graylog

Gather Logs from Graylog
    [Documentation]     Description:    Gather ATL logs directly from graylog.
    ...                 Input:          lab_name = lab BTS is integrated with
    ...                                 range_sec = how many seconds of logs should be gathered
    ...                                 range_from = offset of the start of logs gathering
    ...                                 filter = way of filter ATL logs, by default using MRBTS ID
    ...                                 fields = list of required fields, if empty all fields are gathered
    ...                 Output:         ATL logs from graylog
    ...                 Author:         patryk.tatarek@nokia.com
    [Arguments]         ${lab_name}    ${range_sec}    ${range_from}=0
    ...                 ${filter}=source:"PLMN-PLMN/MRBTS-${MRBTS}"    ${fields}=${EMPTY}
    ${offset}=          Evaluate    ${range_sec} + 3600    #Due to 1h time zone difference
    ${graylog_logs}=    graylog.query_messages    query=${filter}    range_from=${range_from}    timeout=60
    ...                 range_seconds=${offset}    graylog_api=${lab_name}_graylog    fields=${fields}
    [Return]            ${graylog_logs}

################################################ Supplementary Keywords ################################################
_Get Valid Netact Lab With NIDD
    [Arguments]  ${hw_type}    ${preferred_lab}=None    ${pre-conn}=${NONE}    ${excluded_labs}=None    ${sw_version}=None
    Log To Console  \nChecking for valid NetAct lab...
    ${valid_lab}        Set Variable  None
    ${nidd_baseline}    _Get NIDD From Cloud    hw_type=${hw_type}    pre-conn=${pre-conn}
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=srnclab*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    ${index}  Get Index From List  ${randomized_list}  ${preferred_lab}.py
    Run Keyword If  ${index}>=0  Run Keywords  Set List Value  ${randomized_list}  ${index}  ${randomized_list[0]}
    ...                                   AND  Set List Value  ${randomized_list}  0         ${preferred_lab}.py
    FOR  ${lab_file}  IN  @{randomized_list}
        Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${lab_file}
        ${current_lab_name}  Set Variable  ${lab_file[0:-3]}
        Run Keyword If  '${current_lab_name}' in ${excluded_labs}
        ...             Run Keywords    Log    Lab ${current_lab_name} is in the excluded list. Skipping.
        ...             AND    Continue For Loop
        Log    Checking ${current_lab_name} lab    console=True

        ${lab_pingable}       Run Keyword And Return Status  Wait Until Keyword Succeeds  10s  5s
        ...                   _Check If Host Is Reachable  IP=${NA_HOST}
        Run Keyword If        not ${lab_pingable}
        ...                   Run Keywords    Log    Lab ${current_lab_name} is not pingable. Skipping.
        ...                   AND    Continue For Loop

        ${sw_on_lab}          Run Keyword And Return Status    _Check SW supported on NMS Lab    host=${SW_INFO}
        ...                   user=${NA_USER}    password=${NA_PASS}    sw_version=${sw_version}
        Run Keyword If        not ${sw_on_lab}
        ...                   Run Keywords    Log    Lab ${current_lab_name} has no proper SW version. Skipping.
        ...                   AND    Continue For Loop


        ${login_possible}     _Check If SSH Login Is Possible  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        Run Keyword If        not ${login_possible}
        ...                   Run Keywords    Log    Lab ${current_lab_name} has no possibility to login. Skipping.
        ...                   AND    Continue For Loop

        ${nidd_on_lab}        _Check For NIDD Baseline On Netact Lab  ${nidd_baseline}
        ...                   ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        Run Keyword If        not ${nidd_on_lab}
        ...                   Run Keywords    Log    Lab ${current_lab_name} has no proper NIDD. Skipping.
        ...                   AND    Continue For Loop

        ${valid_lab}         Set Variable  ${lab_file[0:-3]}
        Exit For Loop If  '${valid_lab}'!='None'
    END
    Run Keyword If    '${valid_lab}'!='None'
    ...               Log    Lab ${valid_lab} is valid    console=True
    ...               ELSE    FAIL    msg=No lab supports actions
    [Return]          ${valid_lab}    ${NA_HOST}

_Get Valid Netact Lab Without NIDD
    [Arguments]      ${preferred_lab}=None    ${excluded_labs}=None    ${sw_version}=None
    Log To Console  \nChecking for valid NetAct lab...
    ${valid_lab}        Set Variable  None
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=srnclab*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    ${index}  Get Index From List  ${randomized_list}  ${preferred_lab}.py
    Run Keyword If  ${index}>=0  Run Keywords  Set List Value  ${randomized_list}  ${index}  ${randomized_list[0]}
    ...                                   AND  Set List Value  ${randomized_list}  0         ${preferred_lab}.py
    FOR  ${lab_file}  IN  @{randomized_list}
        Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${lab_file}
        ${current_lab_name}  Set Variable  ${lab_file[0:-3]}
        Run Keyword If  '${current_lab_name}' in ${excluded_labs}
        ...             Run Keywords    Log    Lab ${current_lab_name} is in the excluded list. Skipping.
        ...             AND    Continue For Loop
        Log    Checking ${current_lab_name} lab    console=True

        ${lab_pingable}       Run Keyword And Return Status  Wait Until Keyword Succeeds  10s  5s
        ...                   _Check If Host Is Reachable  IP=${NA_HOST}
        Run Keyword If        not ${lab_pingable}
        ...                   Run Keywords    Log    Lab ${current_lab_name} is not pingable. Skipping.
        ...                   AND    Continue For Loop

        ${sw_on_lab}          Run Keyword And Return Status    _Check SW supported on NMS Lab    host=${SW_INFO}
        ...                   user=${NA_USER}    password=${NA_PASS}    sw_version=${sw_version}
        Run Keyword If        not ${sw_on_lab}
        ...                   Run Keywords    Log    Lab ${current_lab_name} has no proper SW version. Skipping.
        ...                   AND    Continue For Loop


        ${login_possible}     _Check If SSH Login Is Possible  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        Run Keyword If        not ${login_possible}
        ...                   Run Keywords    Log    Lab ${current_lab_name} has no possibility to login. Skipping.
        ...                   AND    Continue For Loop

        ${valid_lab}          Set Variable  ${lab_file[0:-3]}
        Exit For Loop If     '${valid_lab}'!='None'
    END
    Run Keyword If    '${valid_lab}'!='None'
    ...               Log    Lab ${valid_lab} is valid    console=True
    ...               ELSE    FAIL    msg=No lab supports actions
    [Return]          ${valid_lab}    ${NA_HOST}

_Get Active SW For NMS Integration
    [Documentation]    Description:    Gets active SW version and converts it to format needed in NMS integration.
    ...                Input:          hw_type = vDU / vCU
    ...                Output:         SW version in format "25R1VDU"
    ...                Author:         damian.kotula@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    ${sw_version}    ${release}    ${is_trunk} =    connections.Get Software Version    hw_type=${hw_type}
    IF    '${hw_type}'=='vDU'
        RETURN    ${release}VDU
    ELSE IF    '${hw_type}'=='vCU'
        RETURN    ${release}VCU
    ELSE
        Fail    msg=hw_type doesn't exist
    END


_Get Actual Configuration MO Data
    [Documentation]    Description:    KW to get the actual configuration of given managed object from BTS using MantaRay
    ...                Input:          mo_id = destinguished name of managed object
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                Output:         meta_class, meta_version and parameters of managed object
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]     ${mo_id}    ${LAB_NAME}
    ${actual_conf}=    Get Actual Configuration     alias=${LAB_NAME}
    ${managed_object}=    Get Managed Object    ${actual_conf}    PLMN-PLMN/${mo_id}    alias=${LAB_NAME}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}

_Setup certificates for MantaRay
    [Documentation]      Keyword configuring RSA certs for MantaRay
    [Arguments]          ${cert_type}    ${tls_version}    ${hw_type}    ${pre-conn}=${NONE}
    ${cert_conn}=        Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
    ...                  ELSE    Set Variable      ${pre-conn}
    IF    '${hw_type}'=='vDU'
        ${BTS_ID}=    Set Variable    MRBTS-${MRBTS}
    ELSE IF    '${hw_type}'=='vCU'
        ${BTS_ID}=    Set Variable    MRBTS-${MRBTS_CU}
    ELSE
        Fail    msg=hw_type doesn't exist
    END
    Configure CMP             ca_subject_name=${SRNLAB_CA}
    ...                       server_type=${cert_type}
    ...                       ca_server_host=${SRNLAB_CA_IP}
    ...                       server_path=${CA_SERVER_PATH}
    ...                       ca_server_port=${CA_DEFAULT_PORT}
    ...                       ee_subject_name=CN=${BTS_ID}
    ...                       hw_type=${hw_type}
    ...                       pre-connection=${cert_conn}
    Update CMP Server Settings    ref_number=${SRNLAB_CA_REFNUM}
    ...                           psk_key=${SRNLAB_CA_PSK}
    ...                           key_pool_type=${cert_type}
    ...                           hw_type=${hw_type}
    ...                           pre-connection=${cert_conn}
    Initialize Certificate   key_pool_type=${cert_type}    hw_type=${hw_type}    pre-connection=${cert_conn}
    IF          '${tls_version}'=='1_2'
         Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
         ...                         param_name=actEnableTLSv13
         ...                         param_value=${FALSE}
         ...                         hw_type=${hw_type}
         ...                         pre-connection=${cert_conn}
         Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
         ...                         param_name=tls12Enabled
         ...                         param_value=${TRUE}
         ...                         hw_type=${hw_type}
         ...                         pre-connection=${cert_conn}
         Wait Until Keyword Succeeds    5x    1min      Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
         ...                         param_name=actEnableTLSv13
         ...                         param_value=${FALSE}
         ...                         hw_type=${hw_type}
         ...                         pre-connection=${cert_conn}
         Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
         ...                         param_name=oamTls
         ...                         param_value=forced
         ...                         hw_type=${hw_type}
         ...                         pre-connection=${cert_conn}
    ELSE IF    '${tls_version}'=='1_3'
        Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                         param_name=actEnableTLSv13
        ...                         param_value=${TRUE}
        ...                         hw_type=${hw_type}
        ...                         pre-connection=${cert_conn}
        Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                         param_name=tls12Enabled
        ...                         param_value=${FALSE}
        ...                         hw_type=${hw_type}
        ...                         pre-connection=${cert_conn}
        Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...                         param_name=oamTls
        ...                         param_value=forced
        ...                         hw_type=${hw_type}
        ...                         pre-connection=${cert_conn}
    ELSE
        Fail    msg=tls_version is not supported
    END
    Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                         param_name=certTypeForTlsAuth
    ...                         param_value=RSA
    ...                         hw_type=${hw_type}
    ...                         pre-connection=${cert_conn}
    Change Parameter on BTS     dist_name=${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                         param_name=certTypeForTlsAuth
    ...                         param_value=RSA
    ...                         hw_type=${hw_type}
    ...                         pre-connection=${cert_conn}
    [Teardown]    Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                         connection=${cert_conn}    hw_type=${hw_type}


_Get NIDD From Cloud
    [Arguments]    ${hw_type}    ${pre-conn}=${NONE}
    ${conn}=        Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
    ...                  ELSE    Set Variable      ${pre-conn}
    ${MNL_R_info}  Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.get_parameters
    ...                              dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNL_R-1    connection=${conn}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.get_managed_object_parameters_of_current_plan    dist_name=MRBTS-${MRBTS}/MNL-1/MNL_R-1
    ...    vdu_connection=${conn}
    ...    ELSE    FAIL
    ${parameters}    Set Variable    ${MNL_R_info['parameters']}
    ${nidd_baseline}    Set Variable    ${EMPTY}
    FOR  ${item}  IN  @{parameters}
        ${if_contain}    Run Keyword and Return Status    Should Contain    ${item['simple_parameter']['name']}    infoModelVersion
        ${nidd_baseline}         Set Variable If    '${if_contain}'=='True'    ${item['simple_parameter']['value']}    ${nidd_baseline}
    END
    [Teardown]    Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                         connection=${conn}    hw_type=${hw_type}
    [Return]  ${nidd_baseline}

_Check If Host Is Reachable
    [Arguments]  ${IP}
    ${result}  Run  ping -c 5 -w 10 ${IP}
    ${status}=  Run Keyword And Return Status  Should Contain  ${result}  5 packets transmitted, 5 received
    Run Keyword If  ${status} == False  Fail  msg=Host is not pingable

_Check If SSH Login Is Possible
    [Arguments]  ${host}  ${user}  ${password}
    ${connection_attempt}  ${connection_result}  Run Keyword And Ignore Error  ssh.Connect To  ${host}  ${user}  ${password}
    Run Keyword If  '${connection_attempt}'=='PASS'  ssh.Disconnect  ${connection_result}
    ...                                       ELSE   Log To Console  ${connection_result}
    ${return_result}  Set Variable If  '${connection_attempt}'=='PASS'  ${TRUE}  ${FALSE}
    [Return]  ${return_result}

_Check For NIDD Baseline On Netact Lab
    [Arguments]  ${baseline}  ${host}  ${user}  ${password}
    ${command}  Set Variable  grep -R ${baseline} /d/oss/global/var/fastpass/BOM/FastPass
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Contain  ${output}  ${baseline}
    [Return]  ${match}


_Check If Services Are Running On Lab
    [Documentation]  Keyword returns False if any of the requested services is stopped.
    [Arguments]  ${services}  ${host}  ${user}  ${password}
    ${services_list}  Split String  ${services}  separator=,
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    FOR  ${service}  IN  @{services_list}
        ${output}  ssh.Execute  command=/opt/cpf/sbin/netact_status.sh status service ${service}  connection=${connection}
        ssh.Await Execution End  connection=${connection}  timeout=60s
        Return From Keyword If  'stopped' in $output or 'starting' in $output or 'frozen' in $output  ${FALSE}
    END
    Return From Keyword  ${TRUE}
    [Teardown]  ssh.Disconnect  ${connection}

_Check If Actions Are Supported On Lab
    [Arguments]  ${host}  ${user}  ${password}
    ${command}  Set Variable  grep -e 'Trunk' -e '[2-9][4-9]R[2-9]' -e 'PP1314' /etc/netact-release
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Not Be Empty  ${output}
    [Return]  ${match}

_Set NetAct Related Variables To None
    Set Suite Variable  ${LBWAS_NODE}  None
    Set Suite Variable  ${NA_HOST}     None
    Set Suite Variable  ${NA_USER}     None
    Set Suite Variable  ${NA_PASS}     None

_Check SW supported on NMS Lab
    [Arguments]  ${host}  ${user}  ${password}    ${sw_version}
    ${suffix}    Get Substring    ${sw_version}    -3
    ${sw}        Get Substring    ${sw_version}    4
    Run Keyword If    '${suffix}'=='VCU'
    ...               Set Variable    ${sw_version}    vCUCNF${sw}
    ...               Else IF    '${suffix}'=='VDU'
    ...               Set Variable    ${sw_version}    vDUCNF${sw}
    ${command}     Set Variable  /opt/oss/Nokia-fit/bin/query_fastpass_info.sh --all | grep ${sw_version}
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}    Run Keyword And Return Status    Should Not Be Empty    ${output}
    [Return]  ${match}
