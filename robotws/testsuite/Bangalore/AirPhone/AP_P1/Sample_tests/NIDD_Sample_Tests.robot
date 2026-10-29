*** Settings ***
Documentation     This file contains sample testcases which upload SCF with latest NIDD changes

Library    OperatingSystem
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    ${CURDIR}/../../QT/resources/ute/python_keywords.py
Library    ${CURDIR}/../../QT/resources/ute/NIDD_update.py

*** Variables ***
${user_token}                         ${EMPTY}
${topology_config_base_url}           https://gitlabe2.ext.net.nokia.com
${topology_config_project_id}         39803
${topology_label}                     ${EMPTY}
${topology_variant}                   ${EMPTY}
${gnb_ip}                             192.168.255.129
&{GNB}                                Ip=${gnb_ip}    Username=toor4nsn
...                                   Password=oZPS0POrRieRtu    Connection=Gnb
${scf_path}                           ${EMPTY}
${auto_merge}                        false

*** Test Cases ***
SCF upload with Latest NIDD without Test
    [Documentation]    This Testcase can be used when we already have the SCF which we want to update
    ...    We just pass the location of the file which we want to upload denoted in the variable ${scf_path}
    ...    Mandatory variables needed to push the correct file to the correct location
    ...    `topology_label` - The topology value which is same as the base dir like 'CLOUD_5G_I_LO_AP_LO'
    ...    `topology_variant` - The variant where the file is intended for
    ...    `auto_merge` - Has to be set to true if you want the merge to be automatic
    ...    `user_token` - The API token for the user that is to be used for this MR
    Local SCF upload to topologyconfig    ${scf_path}

SCF upload after install
    [Documentation]    This Testcase can be used when the proper GNB BUILDS are installed to get the latest NIDD SCF file.
    ...    After successful install this test case can be run to get the current SCF file from the TL,
    ...    and then use that file to create the MR.
    ...    Mandatory variables needed to push the correct file to the correct location
    ...    `topology_label` - The topology value which is same as the base dir like 'CLOUD_5G_I_LO_AP_LO'
    ...    `topology_variant` - The variant where the file is intended for
    ...    `auto_merge` - Has to be set to true if you want the merge to be automatic
    ...    `user_token` - The API token for the user that is to be used for this MR
    Get SCF From TL
    Check NIDD and make update on topologyconfigs repo

*** Keywords ***
Check NIDD and make update on topologyconfigs repo
    Clone and Configure topologyconfig repo
    ${scfc_xml_repo}    Set Variable    ${AP_configs}/${topology_label}/SBTS00/${topology_variant}/scfc.xml
    ${scfc_repo_path}    Set Variable    ${topology_label}/SBTS00/${topology_variant}/scfc.xml
    ${nidd1_scf_repo}    get_nidd_version_from_scf_file    ${scfc_xml_repo}    1
    ${nidd1_scf_tl}    get_nidd_version_from_scf_file    ${scfc_xml_tl}    1
    ${nidd2_scf_repo}    get_nidd_version_from_scf_file    ${scfc_xml_repo}    2
    ${nidd2_scf_tl}    get_nidd_version_from_scf_file    ${scfc_xml_tl}    2
    ${install_cmd}    Catenate    sudo chown ute:ute /etc/apt/sources.list.d/debian_repo.list &&
    ...    echo "deb [ arch=amd64 ] http://repo.wroclaw.nsn-rdnet.net/debian buster main" >> /etc/apt/sources.list.d/debian_repo.list &&
    ...    sudo chown root:root /etc/apt/sources.list.d/debian_repo.list && sudo sudo apt-get update && sudo apt-get install dos2unix
    Run And Return Rc And Output    ${install_cmd}
    ${file_cmd}    Catenate    dos2unix ${scfc_xml_tl}
    Run And Return Rc And Output    ${file_cmd}
    ${nidd_condition}  Catenate
    ...    ('${nidd1_scf_tl}' > '${nidd1_scf_repo}' and 'error' not in '${nidd1_scf_repo}'
    ...    and 'error' not in '${nidd1_scf_tl}' and '${nidd1_scf_repo}' != '' and '${nidd1_scf_tl}' != '')
    ...    or ('${nidd2_scf_tl}' > '${nidd2_scf_repo}' and 'error' not in '${nidd2_scf_repo}'
    ...    and 'error' not in '${nidd2_scf_tl}' and '${nidd2_scf_repo}' != '' and '${nidd2_scf_tl}' != '')
    ${nidd_condition}    Evaluate    ${nidd_condition}
    ${nidd_value}    Get NIDD version    ${nidd1_scf_repo}    ${nidd1_scf_tl}    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    Log To Console    Nidd version ${nidd_value}
    Log To Console    Nidd condition ${nidd_condition}
    Run And Return Rc And Output    echo "" >> ${scfc_xml_tl}
    Run Keyword If    ${nidd_condition}    update_topologyconfig_repo    auto_merge_flag=${auto_merge}    URL=${topology_config_base_url}
    ...    private_token=${user_token}    project_id=${topology_config_project_id}
    ...    branch_name=${nidd_value}_${topology_label}_${topology_variant}
    ...    repo_file_path=${scfc_repo_path}    tl_file_path=${scfc_xml_tl}    nidd_version=${nidd_value}
    ...    topology=${topology_label}_${topology_variant}
    ...    ELSE     Log    NIDD version is the same before and after commissioning, no need to update SCF on repo.

Local SCF upload to topologyconfig
    [Arguments]    ${scf_path}
    Clone and Configure topologyconfig repo
    ${scfc_xml_repo}    Set Variable    ${AP_configs}/${topology_label}/SBTS00/${topology_variant}/scfc.xml
    ${scfc_repo_path}    Set Variable    ${topology_label}/SBTS00/${topology_variant}/scfc.xml
    ${install_cmd}    Catenate    sudo chown ute:ute /etc/apt/sources.list.d/debian_repo.list &&
    ...    echo "deb [ arch=amd64 ] http://repo.wroclaw.nsn-rdnet.net/debian buster main" >> /etc/apt/sources.list.d/debian_repo.list &&
    ...    sudo chown root:root /etc/apt/sources.list.d/debian_repo.list && sudo sudo apt-get update && sudo apt-get install dos2unix
    Run And Return Rc And Output    ${install_cmd}
    ${file_cmd}    Catenate    dos2unix ${scf_path}
    Run And Return Rc And Output    ${file_cmd}
    ${nidd1_scf_local}    get_nidd_version_from_scf_file    ${scf_path}    1
    ${nidd2_scf_local}    get_nidd_version_from_scf_file    ${scf_path}    2
    ${nidd1_scf_repo}    get_nidd_version_from_scf_file    ${scfc_xml_repo}    1
    ${nidd2_scf_repo}    get_nidd_version_from_scf_file    ${scfc_xml_repo}    2
    ${nidd_value}    Get NIDD version    ${nidd1_scf_repo}    ${nidd1_scf_local}    ${nidd2_scf_repo}    ${nidd2_scf_local}
    Log To Console    Nidd version ${nidd_value}
    ${nidd_condition}    Catenate
    ...    ('${nidd1_scf_repo}' not in '${nidd1_scf_local}' and 'error' not in '${nidd1_scf_repo}'
    ...    and 'error' not in '${nidd1_scf_local}' and '${nidd1_scf_repo}' != '' and '${nidd1_scf_local}' != '')
    ...    or ('${nidd2_scf_repo}' not in '${nidd2_scf_local}' and 'error' not in '${nidd2_scf_repo}'
    ...    and 'error' not in '${nidd2_scf_local}' and '${nidd2_scf_repo}' != '' and '${nidd2_scf_local}' != '')
    ${nidd_condition}    Evaluate    ${nidd_condition}
    Run And Return Rc And Output    echo "" >> ${scf_path}
    Run Keyword If    ${nidd_condition}    update_topologyconfig_repo    auto_merge_flag=${auto_merge}    URL=${topology_config_base_url}
    ...    private_token=${user_token}    project_id=${topology_config_project_id}
    ...    branch_name=${nidd_value}_${topology_label}_${topology_variant}
    ...    repo_file_path=${scfc_repo_path}    tl_file_path=${scf_path}    nidd_version=${nidd_value}
    ...    topology=${topology_label}_${topology_variant}
    ...    ELSE     Log    NIDD version is the same before and after commissioning, no need to update SCF on repo.

Clone and Configure topologyconfig repo
    Set Suite Variable             ${AP_configs}     ${EXECDIR}/topologyconfigs
    ${command}    Catenate    rm -rf ${AP_configs} &&
    ...    git clone git@gitlabe2.ext.net.nokia.com:uca/ran/topology-configs.git ${AP_configs}
    ${rc_clone}    ${output_clone}    Run And Return Rc And Output    ${command}
    Should Be Equal As Integers    ${rc_clone}    0    msg=git clone command failed with error code ${rc_clone}
    ${command}    Catenate    cd ${AP_configs} && git checkout master && git pull origin
    ...    && git config user.email I_MN_5G_AIRPHONE_CI@nokia.com && git config user.name ca_5gair
    Run And Return Rc And Output    ${command}

Get SCF From TL
    Set Suite Variable    ${scfc_xml_tl}    ${OUTPUT_DIR}/gnb_coam_scf.xml
    ${path}               ${file}    Split Path    ${scfc_xml_tl}
    CoamAdmin.Connect To    bts_host=${GNB.Ip}
    CoamAdmin.Get Current Scf File    ${path}    ${file}
    File Should Exist                 ${scfc_xml_tl}
    [Teardown]    CoamAdmin.Teardown

Get NIDD version
    [Arguments]    ${nidd1_scf_repo}    ${nidd1_scf_tl}    ${nidd2_scf_repo}    ${nidd2_scf_tl}
    ${nidd_value}    Evaluate    '${nidd1_scf_tl}' if ('${nidd1_scf_tl}' > '${nidd1_scf_repo}') else None
    ${nidd_value}    Evaluate
    ...    '${nidd2_scf_tl}' if ('${nidd_value}' == 'None' and ('${nidd2_scf_tl}' > '${nidd2_scf_repo}')) else '${nidd_value}'
    [Return]    ${nidd_value}
