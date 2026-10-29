*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com
Library   taf.gnb.oam.coam.cu   WITH NAME   coam_cu
Library   Collections
Library   OperatingSystem
Library   DateTime
Library   String

*** Variables ***

*** Keywords ***
#Cloud COAM CU Keywords
COAM Cloud CU Login
    [Documentation]   COAM Cloud CU Login
    ...    Author: yin.4.chen@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | host | no | Cloud Host |
    ...   | username | no | WEBEM Username |
    ...   | password | no | WEBEM Password |
    [Arguments]   ${host}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    ...   ${port}=${8081}   ${cu_version}=cuoam_23r2
    coam_cu.connect_to
    ...   host=${host}
    ...   port=${port}
    ...   username=${username}
    ...   password=${password}
    ...   cu_version=${cu_version}
    ...   secure=${False}
    ...   login_disabled=${False}

COAM Cloud CU Logout
    [Documentation]   COAM Cloud CU Logout
    ...    Author: yin.4.chen@nokia-sbell.com
    Run Keyword And Ignore Error   coam_cu.disconnect

COAM Cloud CU Backup Current SCF
    [Documentation]   COAM Cloud CU Backup Current SCF
    ...    Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${path}=${OUTPUT_DIR}/old_commission.xml
    coam_cu.get_current_plan_file   path=${path}

COAM Cloud CU Backup All Plan SCF
    [Documentation]   COAM Cloud CU Backup All Plan SCF
    ...    Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${scf_dir}=${OUTPUT_DIR}
    @{plan_infos}   coam_cu.get_plan_info
    @{plan_files_name}   Create List
    FOR   ${plan_info}   IN   @{plan_infos}
       ${plan_id}   Set Variable   ${plan_info.to_dict()['plan_id']}
       coam_cu.get_plan_file   plan_id=${plan_id}   path=${scf_dir}/${plan_id}.xml
       Append To List   ${plan_files_name}   ${scf_dir}/${plan_id}.xml
    END
    [Return]   ${plan_files_name}

COAM Cloud CU Upload Plan File
    [Documentation]   COAM Cloud CU Upload Plan File
    ...    Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission.xml
    ${plan_info}   coam_cu.upload_plan_file   path_to_plan_file=${scf_path}
    ${plan_id}   Set Variable   ${plan_info.to_dict()['plan_id']}
    [Return]   ${plan_id}

COAM Cloud CU Activate Plan File
    [Documentation]   COAM Cloud CU Activate Plan File
    ...    Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${plan_id}
    coam_cu.plan_activation   plan_id=${plan_id}

COAM Cloud CU Perform Commission
    [Documentation]   COAM Cloud CU Perform Commission
    ...    Author: yin.4.chen@nokia-sbell.com
    [Arguments]   ${scf_path}=${OUTPUT_DIR}/old_commission.xml
    ${plan_id}   COAM Cloud CU Upload Plan File   scf_path=${scf_path}
    COAM Cloud CU Activate Plan File   ${plan_id}

# COAM Cloud CU Perform Commission
#     [Arguments]   ${scf_path}
#     ${info}   coam_cu.perform_commissioning   path_to_plan_file=${scf_path}
#     [Return]   ${info}

# COAM Cloud CU Get Active Alarms
#     ${active_alarms}   coam_cu.get_active_alarms   timeout=${30}
#     [Return]   ${active_alarms}

# COAM Cloud CU Get BTS Info
#     ${bts_info}   coam_cu.get_bts_info
#     [Return]   ${bts_info}

# COAM Cloud CU Get Active Software Version
#     ${sw_version}   coam_cu.get_active_software_version
#     [Return]   ${sw_version}

# COAM Cloud CU Get All VM
#     ${vms_info}   coam_cu.get_vms
#     [Return]   ${vms_info}

# COAM Cloud CU Get Cell Status
#     ${cell_status}   coam_cu.get_cells_statuses
#     [Return]   ${cell_status}
