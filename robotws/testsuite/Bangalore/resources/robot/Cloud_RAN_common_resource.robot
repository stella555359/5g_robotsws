*** Settings ***
Documentation       Keywords for vDU/vCU CNF automation, this is created during T04 CIT automation
...                 Author: sudarshan.kanapuram@nokia.com

Library             taf.nms.netact
Library             testsuite.Bangalore.resources.python.downloadwftpackage_cnf.DownloadWftPackageCnf


*** Keywords ***
Setup Mantaray Node
    [Documentation]    Creates a temporary NetAct ssh connection. Supported services: cmwas, fmwas, itsmwas, nwi3, cls-services, cls-db
    [Arguments]
    ...    ${service}=${EMPTY}
    ...    ${hostname}=${EMPTY}
    ...    ${username}=${EMPTY}
    ...    ${password}=${EMPTY}
    ...    ${alias}=default
    Add Node    ${service}    ${hostname}    ${username}    ${password}    alias=${alias}
    RETURN    ${alias}

CNF_builds_import_to_netact
    [Documentation]    Imports vDU build to Mantaray.
    [Arguments]    ${cnf_sw_version}=${EMPTY}    ${sw_dir_path}=${EMPTY}    ${alias}=default
    ${sw_file_path}=    Join Path    ${sw_dir_path}    ${cnf_sw_version}
    Log to console    --\n Importing software build: ${cnf_sw_version}, Wait for 20 mins \n--
    Import Build    ${sw_file_path}.zip    mo_type=CNF    alias=${alias}
    ${import_status}=    Is Imported    ${cnf_sw_version}    mo_type=CNF    alias=${alias}
    Log to console    --\n software build imported status:    ${import_status}\n--

CNF_upgrade
    [Documentation]    Creates vDU upgrade plan in Mantaray and upgrades vDU CNF to required SW version.
    [Arguments]
    ...    ${cnf_sw_version}=${EMPTY}
    ...    ${cnf_mo}=${EMPTY}
    ...    ${cnf_upd_plan_name}=${EMPTY}
    ...    ${cnf_rolbk_plan_name}=${EMPTY}
    ...    ${alias}=default
    ${cnf_ugd_plan}=    create_cnf_upgrade_plan    plan_name=${cnf_upd_plan_name}    dist_names=${cnf_mo}
    ...    cnf_sw_id=${cnf_sw_version}    alias=${alias}
    Log    \n${cnf_ugd_plan}    console=${TRUE}
    ${cnf_ugd_plan1}=    upgrade_cnf    plan_name=${cnf_upd_plan_name}    rollback_plan_name=${cnf_rolbk_plan_name}
    ...    alias=${alias}    download_ru_sw=False
    Log    \n${cnf_ugd_plan1}    console=${TRUE}


Download CNF SW Build
    [Documentation]    This keyword downloads vDU and vCU SW build version updated in Var file.
    [Arguments]    ${cnf_sw_version}=${EMPTY}    ${download_path}=${EMPTY}
    ${cnf_prefix}=    Evaluate    "${cnf_sw_version}".split("_")[0]
    Log to console    --\n ${cnf_prefix} biuld download Start \n--
    Download Cnf Sw File    ${cnf_prefix}    ${cnf_sw_version}    ${download_path}
    Log to console    --\n ${cnf_prefix} biuld download End \n--

Delete Mantaray Node
    [Arguments]    ${service}=${EMPTY}    ${alias}=default
    Delete Node    ${service}    alias=${alias}
    Clean All    alias=${alias}
