*** Settings ***
Documentation   Utility which sends SCFs to external server

Resource  ../admin/admin.robot

Library  taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library  DateTime
Library  String

*** Variables ***
${regression_checker_url}   http://regression-checker.wroclaw.nsn-rdnet.net

*** Keywords ***
Send SCF To Server
    [Documentation]     Keyword to send active scf on gNB to Regression Checker.
    ...  ${gnb_state} - gNB State on which test suite is reserved in UTE cloud manager (e.g. GNB_COMMISSIONED,
    ...  SW_UPLOADED, ON_AIR itd.).
    [Arguments]        ${gnb_state}
    ${connection}      admin.Connect to admin

    ${scf_filename}    Build Filename
    ...                gnb_state=${gnb_state}
    ...                connection=${connection}

    ${scf}             coam_admin.get_current_scf_file
    ...                local_dir_path=${OUTPUT_DIR}
    ...                file_name=${scf_filename}
    ...                connection=${connection}

    ${endpoint_url}    Build Endpoint URL

    ${command}         Catenate  SEPARATOR=${SPACE}
    ...                          curl -s
    ...                               --location
    ...                               --request POST '${endpoint_url}'
    ...                               --form 'scf_file=@"${scf}"'

    ${result}          Run  ${command}
    Log Result         ${result}

    [Teardown]         admin.Disconnect from admin

Build Filename
    [Arguments]       ${gnb_state}  ${connection}
    ${testline_name}  Get Testline Name
    ${suite_name}     Replace String  ${SUITE_NAME}  ${SPACE}  _
    ${sw_version}     coam_admin.get_sw_version
    ...               connection=${connection}

    ${filename}       Set Variable
    ...               ${testline_name}-${suite_name}-${gnb_state}-${sw_version}.xml
    [Return]          ${filename}

Build Endpoint URL
    ${testline_name}  Get Testline Name
    ${endpoint_url}   Set Variable  ${regression_checker_url}/api/testlines/${testline_name}/upload-scf/
    [Return]          ${endpoint_url}

Get Testline Name
    ${testline_name}     Run  hostname
    ${testline_name}     Replace String  ${testline_name}  -  _
    [Return]             ${testline_name}

Log Result
    [Arguments]      ${result}
    ${result}        Evaluate   ${result}
    Log              ${result['msg']}
    ...              console=${TRUE}