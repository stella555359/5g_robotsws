*** Settings ***
Library       taf.sbts.oam.coam.admin    WITH NAME    coam
Library       taf.sw.scout     WITH NAME    scout
Library       ../../python/mantaray_handler.py    WITH NAME    Mantaray_handler
Library       taf.sw.reporting_portal    WITH NAME    rp
Resource      NetAct.resource
Resource      ../Common_keywords.resource
Variables     ../variables/Mantaray_variables.py

*** Keywords ***
SW Upgrade Rollback Via MantaRay Keyword
    [Documentation]    Performing UUF upgrade through the mantaray server. Add SW Rollback when non 24R2 not available
    @{target_sws}    Create List    ${Target_Build}
    IF   @{target_sws} == ${None}    Fail    Target Sw Build is Empty
    IF    ('${abbr_SW_stream}' != 'SBTS24R2' or '${abbr_SW_stream}' != 'SBTS24R3')
        Set Test Variable   ${RP_QC_PROJECT}     ${qc_project_vrf}
        Set Test Variable    ${QC_Project}    ${qc_project_vrf}
    ELSE
        Set Test Variable    ${RP_QC_PROJECT}     ${qc_project_st}
        Set Test Variable    ${QC_Project}        ${qc_project_st}
    END
    Set Test Variable    ${source_build}    ${Source_Build}
    Common_keywords.do_source_sw_as_active_sw    5G_SOURCE_SW=${source_build}
    ${test_line_name}    Mantaray_handler.Get Hostname From Machine
    Set Test Variable    ${RP_TESTLINE}    ${test_line_name}
    Mantaray_swbuild_integration    artifactory_base_url=${artifactory_url}
    ...    Builds=@{target_sws}    remote_ip=${node_14_VM_ip}
    Sleep    10s
    Wait Until Keyword Succeeds   15m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    Run Keyword And Ignore Error   COAM Logout
    NetAct.UUF CM Upload
    NetAct.UUF FM manual upload
    NetAct.UUF CM Provision
    FOR   ${iteration}   IN RANGE  ${iterations}
        ${Execution_status}    UUF Operation    iteration=${iteration}
    END
    IF  '${Execution_status}' == 'True'  BuiltIn.Log To Console    [ INFO ]: UUF Performed Successfully.
    [Teardown]   Run Keyword And Ignore Error   COAM Logout

UUF Operation
    [Documentation]    :UUF Operation
    [Arguments]    ${iteration}
    BuiltIn.Log To Console    [ INFO ]: UUF Iteration count: ${iteration}
    Upgrade_build_from_Mantaray_and_check_cells_are_onair
    ${target_build}    UUF Get Active SW Version
    Rollback_to_source_build
    ${Reserved_build}    UUF Get Active SW Version
    [Teardown]    Mantaray Report To Reporting Portal Upgrade
    ...    RP_UUF_TEST=True
    ...    verdict=passed
    ...    build=${target_build}
    ...    reserve_build=${Reserved_build}

    RETURN    ${True}

Upgrade_build_from_Mantaray_and_check_cells_are_onair
    [Documentation]   Upgrade build from mantaray server and verfiying BTS cells status

    ${operation_id}   Wait Until Keyword Succeeds   3x   10s
    ...   Selenium NetAct SWM Operation   dist_name=${dist_name}   operation=Download   package_version=${package_version}
    Log To Console   Download operation_id: ${operation_id}
    Wait Until Keyword Succeeds   60m   1m   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}
    ${operation_id}   Wait Until Keyword Succeeds   3x   10s
    ...   Selenium NetAct SWM Operation   dist_name=${dist_name}   operation=Activation   package_version=${package_version}
    Log To Console   Activation operation_id: ${operation_id}
    Wait Until Keyword Succeeds   20m   1m   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}
    Wait Until Keyword Succeeds   15m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    Run Keyword And Ignore Error   COAM Logout

Rollback_to_source_build
    [Documentation]  performing Rollback scenarios
    ${operation_id}   Wait Until Keyword Succeeds   3x   10s
    ...   Selenium NetAct SWM Operation   dist_name=${dist_name}   operation=Rollback
    Log To Console   Rollback operation_id: ${operation_id}
    Wait Until Keyword Succeeds   60m   1m   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}
    Wait Until Keyword Succeeds   15m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    Run Keyword And Ignore Error   COAM Logout

Mantaray_swbuild_integration
    [Arguments]    ${artifactory_base_url}    ${Builds}=@{target_sws}    ${remote_ip}=${node_14_VM_ip}
    OperatingSystem.Create Directory    path=${local_dir}
    BuiltIn.Log To Console    File is created folder name:${local_dir}
    ${download_status}    Mantaray_handler.Download Sbts Builds And Save In Target Path
    ...    artifactory_url=${artifactory_base_url}
    ...    local_dir=${local_dir}
    ...    target_swpath=@{Builds}
    Sleep    2s
    Run Keyword if   '${download_status}' == 'True'   BuiltIn.Log To Console   [ INFO ]: Build download successful.!
    Run Keyword if   '${download_status}' == 'True'   Mantaray_handler.Single Thread Function For File Transfer
    ...    remote_ip=${remote_ip}
    ...    local_swpath=${local_dir}
    ...    server_swpath=${remote_directory}
    BuiltIn.Log To Console    [ INFO ]:File moved to mantaray vm.!
    Mantaray_handler.Verify Swbuild Availability In Remote Machine
    ...    remote_ip=${remote_ip}
    ...    server_swpath=${remote_directory}
    ...    target_builds=@{Builds}
    Run Keyword if   '${download_status}' == 'True'    Mantaray_handler.Push Sw Form NetactVM Mantaray Server Via Taf
    ...    remote_ip=${remote_ip}
    ...    target_builds=@{Builds}

UUF Get Active SW Version 
    coam.connect_to
    ${Activesofwareversion}     coam.get_software_info    timeout=30
    Set Suite Variable    ${Activesoftware}    ${Activesofwareversion['Active SW version']}
    RETURN    ${Activesoftware}

COAM Login
    [Arguments]   ${bts_host}=${webem_addr}
    ...    ${username}=${webem_username}
    ...    ${password}=${webem_password}
    ...    ${bts_port}=${443}
    ...    ${log_dir}=${OUTPUT_DIR}
    ...    ${alias}=COAM
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
    RETURN   ${alias}

COAM Logout
    [Arguments]   ${connection}=COAM
    coam.teardown      connection=${connection}

COAM ADMIN Check Cell Onair
    [Arguments]   ${connection}=COAM
    ${bts_info}   coam.get_bts_info   connection=${connection}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

    FOR   ${cell}   IN   @{cell_list}
        ${operationalState}         Get Variable Value   ${cell['status']['operationalState']}      N/A
        ${usageState}               Get Variable Value   ${cell['status']['usageState']}            N/A
        ${proceduralStatus}         Get Variable Value   ${cell['status']['proceduralStatus']}      N/A
        ${administrativeState}      Get Variable Value   ${cell['status']['administrativeState']}   N/A
        ${availabilityStatus}       Get Variable Value   ${cell['status']['availabilityStatus']}    N/A

        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}       enabled
        # # Sometimes usageState=Idle
        #Run Keyword If   "${usageState}"!="N/A"
        #...   Should Be Equal   ${usageState.lower()}             active
        Run Keyword If   "${proceduralStatus}"!="N/A"
        ...   Should Be Equal   ${proceduralStatus.lower()}       configured
        Run Keyword If   "${administrativeState}"!="N/A"
        ...   Should Be Equal   ${administrativeState.lower()}    unlocked
        Run Keyword If   "${availabilityStatus}"!="N/A"
        ...   Should Not Be Equal   ${availabilityStatus.lower()}   degraded
    END

Temp_keyword
    Set Test Variable   ${RP_QC_PROJECT}     ${qc_project_vrf}
    Set Test Variable    ${RP_TESTLINE}    ${test_line_name}
    Mantaray Report To Reporting Portal    RP_UUF_TEST=True    verdict=passed
    ...    case_name=${TEST_NAME}

Mantaray Report To Reporting Portal Upgrade
    [Arguments]   ${RP_UUF_TEST}   ${verdict}    ${build}    ${reserve_build}

    ${CASE_TYPE}    Convert To String    Upgrade
    ${CUSTOMERS_LIST}   Convert To String    Reliance India
    ${BTS_TYPE}    Convert To String    SA
    ${testline_type}    Convert To String    ${RP_HW_ID}
    ${build}    Convert To String    ${build}
    ${Base_build}    Convert To String    ${reserve_build}
    ${link_to_reporting_portal}=
    ...  rp.report to rp
    ...  name=${TEST_NAME}
    ...  result=${verdict}
    ...  ca=${RP_CA}
    ...  testline=${RP_TESTLINE}
    ...  build=${build}
    ...  qc_domain=${RP_QC_DOMAIN}
    ...  qc_project=${RP_QC_PROJECT}
    ...  qc_id=${TEST_QC_ID}
    ...  comment=${RP_COMMENT}
    ...  uuf_test=${RP_UUF_TEST}
    ...  label=${testline_type}
    ...  parameter_1=${Base_build}
    # ...  upgrade_downtime=${KPI}
    # ...  starttime=${START_TIME}        # start time
    # ...  endtime=${END_TIME}
    ...  case_type=${CASE_TYPE}
    ...  ru_type=${RP_RU_TYPE}
    ...  sa/nsa_variant=${BTS_TYPE}
    ...  tdd/fdd_variant=${RP_TDD_FDD_VARIANT}
    ...  hw_id=${RP_HW_ID}
    ...  tool=MantaRay NM
    ...  customers=${CUSTOMERS_LIST}
    ...  tc_execution_id=${TC_EXE_ID}
    ...  location=${RP_LOCATION}
    ...  customer=${RP_Customer}

    BuiltIn.Log To Console  Reporting Portal Link: ${link_to_reporting_portal}
