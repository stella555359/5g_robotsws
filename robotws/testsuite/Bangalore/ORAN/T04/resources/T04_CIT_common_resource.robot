*** Settings ***
Documentation       Keywords for vDU/vCU CNF automation, this is created during T04 CIT automation
...                 Author: sudarshan.kanapuram@nokia.com

Library             taf.nms.netact
Library             testsuite.Bangalore.resources.python.downloadwftpackage_cnf.DownloadWftPackageCnf
Resource            ./testsuite/Bangalore/resources/robot/Cloud_RAN_common_resource.robot
Variables           ./testsuite/Bangalore/ORAN/T04/resources/T04_CIT_parameters.py


*** Variables ***
${var_file_path}    /home/ute/robotws/testsuite/Bangalore/ORAN/T04/resources/T04_CIT_parameters.py


*** Keywords ***
Fetch Promoted CNF SW Build Info
    [Documentation]    This keyword is specific to CIT runs, used to fetch vDU/vCU build IDs only.
    ${vdu}    ${vcu}=    Fetch And Prepare Builds
    Set Suite Variable    ${vdu_sw_version}    ${vdu}
    Set Suite Variable    ${vcu_sw_version}    ${vcu}
    Log    vDU ID: ${vdu_sw_version}
    Log    vCU ID: ${vcu_sw_version}
    Update Plan Variable    ${var_file_path}    vdu_sw_version    ""    ${vdu}    True
    Update Plan Variable    ${var_file_path}    vcu_sw_version    ""    ${vcu}    True

Update Parameter file with build info
    [Documentation]    This keyword updates required parameters dynamically in Var file.
    ${vdu_num}=    Extract Build Number    ${vdu_sw_version}
    ${vcu_num}=    Extract Build Number    ${vcu_sw_version}
    ${combined}=    Evaluate    f"vCU_sw_ugd_{${vcu_num}}"
    Set Suite Variable    ${vcu_upd_plan_name}    ${combined}
    ${combined}=    Evaluate    f"vCU_sw_rol_{${vcu_num}}"
    Set Suite Variable    ${vcu_rolbk_plan_name}    ${combined}
    ${combined}=    Evaluate    f"vDU_sw_ugd_{${vdu_num}}"
    Set Suite Variable    ${vdu_upd_plan_name}    ${combined}
    ${combined}=    Evaluate    f"vDU_sw_rol_{${vdu_num}}"
    Set Suite Variable    ${vdu_rolbk_plan_name}    ${combined}
    Log    vDU ID: ${vcu_upd_plan_name}
    Log    vDU ID: ${vdu_upd_plan_name}
    Update Plan Variable    ${var_file_path}    vcu_upd_plan_name    vCU_sw_ugd_    ${vcu_num}
    Update Plan Variable    ${var_file_path}    vcu_rolbk_plan_name    vCU_sw_rol_    ${vcu_num}
    Update Plan Variable    ${var_file_path}    vdu_upd_plan_name    vDU_sw_ugd_    ${vdu_num}
    Update Plan Variable    ${var_file_path}    vdu_rolbk_plan_name    vDU_sw_rol_    ${vdu_num}

Compare_existing_CNF_VDU_VCU_SW_Ver
    [Documentation]    Compares existing vDU and vCU SW version with versions updated in variable file.
    Log To Console    \n --Connecting vDU-- \n
    admindu.Connect To    host=${host_vDU}    port=${PORT}    connection_name=vDU    username=${USER}
    ...    password=${PWD}    secure=True    timeout=300
    admincu.Connect To    host=${host_vCU}    port=${PORT}    alias=vCU    username=${USER}    password=${PWD}
    ...    secure=True    alias=vCU    timeout=300
    ${vdu_cur}=    admindu.get_vdu_state_data    vDU
    ${vdu_cur}=    Set Variable    ${vdu_cur['software_version']}
    ${vcu_cur}=    admincu.get_active_software_version    vCU
    ${vdu_prefix}=    Evaluate    "${vdu_sw_version}".split("_")[0]
    ${vcu_prefix}=    Evaluate    "${vcu_sw_version}".split("_")[0]
    ${vdu_cur}=    Evaluate    "${vdu_prefix}" + "_" + "${vdu_cur}".split("_", 1)[1]
    ${vcu_cur}=    Evaluate    "${vcu_prefix}" + "_" + "${vcu_cur}".split("_", 1)[1]
    Log To Console    vDU ID: ${vdu_cur}
    Log To Console    vDU ID: ${vcu_cur}
    ${vdu_prefix}=    Evaluate    "${vdu_sw_version}".split("_")[0]
    ${vdu_prefix}=    Evaluate    "${vdu_sw_version}".split("_")[0]
    IF    "${vdu_cur}-amd64" == "${vdu_sw_version}" and "${vcu_cur}-amd64" == "${vcu_sw_version}"
        ${result}=    Set Variable    ${TRUE}
    ELSE
        ${result}=    Set Variable    ${FALSE}
    END
    RETURN    ${result}

Suite Precondition
    ${NETACT_NAME}=    Setup Mantaray Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    ${NETACT_NAME}
    Log to console    --\n CNF operations started \n--
    # below KW is only used for CIT runs
    Fetch Promoted CNF SW Build Info
    ${check}=    Compare_existing_CNF_VDU_VCU_SW_Ver
    IF    not ${check}
        Update Parameter file with build info
        Download CNF SW Build    ${vdu_sw_version}    ${download_path}
        Download CNF SW Build    ${vcu_sw_version}    ${download_path}
        CNF_builds_import_to_netact    ${vcu_sw_version}    ${download_path}    ${connection}
        CNF_builds_import_to_netact    ${vdu_sw_version}    ${download_path}    ${connection}
        CNF_upgrade
        ...    ${vcu_sw_version}
        ...    ${vcu_mo}
        ...    ${vcu_upd_plan_name}
        ...    ${vcu_rolbk_plan_name}
        ...    ${connection}
        CNF_upgrade
        ...    ${vdu_sw_version}
        ...    ${vdu_mo}
        ...    ${vdu_upd_plan_name}
        ...    ${vdu_rolbk_plan_name}
        ...    ${connection}
        Log to console    --\n CNF operations check: ${check} \n--
    END

    Log to console    --\n CNF operations check: ${check} \n--

Suite Postcondition
    Delete Mantaray Node    cmwas    ${NETACT_NAME}
