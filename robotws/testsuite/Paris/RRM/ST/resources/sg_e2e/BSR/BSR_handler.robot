*** Settings ***
Documentation   Suite description

Library         OperatingSystem
Library         taf.transport.ssh                           WITH NAME   ssh
Library         ${CURDIR}/../gnbcOamAdmin.py                WITH NAME   gnbAdmin

*** Keywords ***
Get Local BSR cmW File
    [Documentation]   Useful keyword to download bsr file from artifactory repository to VM
    [Arguments]     ${cust_bsr_name}
    ${url_repos}=         Set Variable     http://artifactory-espoo1.ext.net.nokia.com/artifactory/mnpute-rotta-local/resources_sg_e2e/cmW/BSR
    ${local_dir}=         Set Variable     ${res_path}/bsr
    ${is_exist}=          run keyword and return status    Directory Should Exist     ${local_dir}
    Run Keyword If    '${is_exist}'=='False'
    ...                Create Directory    ${local_dir}

    ${local_bsr_path}    Set variable    ${local_dir}/${cust_bsr_name}.zip
    ${is_exist}=    run keyword and return status    File Should Exist     ${local_bsr_path}
    Run Keyword If    '${is_exist}'=='True'
    ...                Remove File    ${local_bsr_path}

    #check if the file exist
    ${cmd}    catenate    curl --head --silent ${url_repos}/${cust_bsr_name}.zip | head -n 1
    ${resp}     Run   timeout 5 ${cmd}
    Should Contain    ${resp}    200 OK
    ...    FAIL    URL ${url_repos}/${cust_bsr_name}.zip doesn't exist or server down.

    # Download of the file.
    ${cmd}      catenate         cd ${local_dir} && timeout 60 wget ${url_repos}/${cust_bsr_name}.zip
    ${resp}     Run         ${cmd}

    [Return]    ${cust_bsr_name}    ${local_bsr_path}


Load BSR File For Test
    [Documentation]    This Keywod will load a BSR File
    ...                for more info refer to taf.gnb.oam.coam.admin Library
    [Arguments]        ${file_path}

    ${bts_host}=    Set Variable If   '${GNB_Architecture}' == 'CLOUD'
    ...                   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                   ${tl.gnbs[0].cu.oam_http_connection_details.addr}

    gnbAdmin.connect to   bts_host=${bts_host}

    gnbAdmin.load_BSR_file    sw_package=${file_path}

    [Teardown]    gnbAdmin.teardown
