*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
Start Process Async UUF Switch Build
    [Arguments]   ${testline}   ${package_type}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}

    # Log To Console   Backup ${testline} NE3S Configuration Starting...
    # FOR   ${common_unit}   IN   @{common_units}
    #     Single Common Unit Backup NE3S Configuration   testline=${testline}   common_unit=${common_unit}
    # END
    # Log To Console   Backup ${testline} NE3S Configuration Finished...

    Log To Console   Remove ${testline} Configuration Starting...
    FOR   ${common_unit}   IN   @{common_units}
        Single Common Unit Remove Configuration   testline=${testline}   common_unit=${common_unit}
    END
    FOR   ${common_unit}   IN   @{common_units}
        Single Common Unit Reboot   testline=${testline}   common_unit=${common_unit}
    END
    Log To Console   Remove ${testline} Configuration Finished.

    Log To Console   Upgrade ${testline} To ${package_type} Bulid Starting...
    FOR   ${common_unit}   IN   @{common_units}
        Async Single Common Unit Switch Build   testline=${testline}   common_unit=${common_unit}   package_type=${package_type}
    END
    ${Fatal_Error}   Wait Until Keyword Succeeds   60m   1m
    ...   Async Single Testline Check Robot Process Finished
    ...      testline=${testline}
    ...      process_name=UUF_Switch_Build
    Run Keyword If   "${Fatal_Error}"=="Fatal_Error"   Fail   msg=[ERROR] Upgrade ${testline} To ${package_type} Bulid Failed.
    Log To Console   Upgrade ${testline} To ${package_type} Bulid Finished.

    Log To Console   Load ${testline} SCF And Clear Fault23 Starting...
    Async Single Testline Load SCF   testline=${testline}   package_type=${package_type}
    ${Fatal_Error}   Wait Until Keyword Succeeds   90m   2m
    ...   Async Single Common Unit Check Robot Process Finished
    ...      testline=${testline}
    ...      common_unit=${common_units[0]}
    ...      process_name=UUF_Load_SCF
    Run Keyword If   "${Fatal_Error}"=="Fatal_Error"   Fail   Async Single Testline Load SCF   testline=${testline}   package_type=${package_type}
    Run Keyword If   "${Fatal_Error}"=="Fatal_Error"   Fail   msg=[ERROR] Load ${testline} SCF And Clear Fault23 Failed.
    Log To Console   Load ${testline} SCF And Clear Fault23 Finished.\n

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error
    ...      Async Single Testline Download Robot Process Logs
    ...         testline=${testline}
    ...         process_name=UUF_Switch_Build
    ...   AND
    ...   Run Keyword And Ignore Error
    ...      Async Single Common Unit Download Robot Process Logs
    ...         testline=${testline}
    ...         common_unit=${common_units[0]}
    ...         process_name=UUF_Load_SCF

# # =========================================================================================================================================
# # Remove Ne3s Configuration on Common Unit
# Single Common Unit Backup NE3S Configuration
#     [Arguments]   ${testline}   ${common_unit}
#     ${common_unit_index}   Set Variable   ${common_unit['index']}
#     ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
#     ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
#     ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

#     ${lmp_addr}   Set Variable   ${common_unit['lmp_addr']}
#     ${lmp_username}   Set Variable   ${common_unit['lmp_username']}
#     ${lmp_password}   Set Variable   ${common_unit['lmp_password']}

#     ${testpc_connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}
#     ${lmp_connection}   Set Variable   lmp_${testline}_unit_${common_unit_index}

#     csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${testpc_connection}
#     csn.Connect To   hostname=${lmp_addr}  username=${lmp_username}  password=${lmp_password}  alias=${lmp_connection}  proxy=${testpc_connection}

#     OperatingSystem.Create Directory   ${OUTPUT_DIR}/${lmp_connection}
#     csn.Download File
#     ...   remote_path=/ffs/run/config/safe/account/ws.json
#     ...   local_path=${OUTPUT_DIR}/${lmp_connection}/ws.json
#     ...   connection=${lmp_connection}
#     csn.Download File
#     ...   remote_path=/ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
#     ...   local_path=${OUTPUT_DIR}/${lmp_connection}/ne3sadaptdata.db
#     ...   connection=${lmp_connection}

#     ${remote_dir}   Set Variable   /ffs/run/config/ne3sadapt/managers
#     ${local_dir}   Set Variable   ${OUTPUT_DIR}/${lmp_connection}/managers
#     OperatingSystem.Create Directory   ${local_dir}

#     ${output}   csn.Execute   command=ls /ffs/run/config/ne3sadapt/managers   connection=${lmp_connection}
#     ${file_list}   Split String   ${output}   \r\n
#     ${file_list}   Evaluate   [file.strip() for file in ${file_list} if file!=""]
#     @{managers_file_list}   Create List
#     FOR   ${file_name}   IN   @{file_list}
#         &{managers_file_save}   Create Dictionary
#         ${remote_path}   Set Variable   ${remote_dir}/${file_name}
#         ${local_path}   Set Variable   ${local_dir}/${file_name}
#         Set To Dictionary   ${managers_file_save}   remote_path=${remote_path}   local_path=${local_path}
#         Append To List   ${managers_file_list}   ${managers_file_save}

#         Run Keyword And Ignore Error   csn.Download File
#         ...   remote_path=${remote_path}
#         ...   local_path=${local_path}
#         ...   connection=${lmp_connection}
#     END

#     Log To Console   ${managers_file_list}
#     Set Suite Variable   ${MANAGERS_FILE_LIST}

#     csn.Execute   command=rm -rf /ffs/run/config/safe/account/ws.json   connection=${lmp_connection}
#     csn.Execute   command=rm -rf /ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db   connection=${lmp_connection}
#     csn.Execute   command=rm -rf /ffs/run/config/ne3sadapt/managers/*   connection=${lmp_connection}


#     [Teardown]   Run Keywords
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${lmp_connection}   AND
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


# =========================================================================================================================================
# Remove Configuration on Common Unit
Single Common Unit Remove Configuration
    [Arguments]   ${testline}   ${common_unit}
    # # Clear Common Unit Configuration
    ${common_unit_index}   Set Variable   ${common_unit['index']}
    ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
    ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

    ${lmp_addr}   Set Variable   ${common_unit['lmp_addr']}
    ${lmp_username}   Set Variable   ${common_unit['lmp_username']}
    ${lmp_password}   Set Variable   ${common_unit['lmp_password']}


    ${testpc_connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}
    ${lmp_connection}   Set Variable   lmp_${testline}_unit_${common_unit_index}

    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${testpc_connection}
    csn.Connect To   hostname=${lmp_addr}  username=${lmp_username}  password=${lmp_password}  alias=${lmp_connection}  proxy=${testpc_connection}


    csn.Execute   command=mount -o rw,remount /ffs/stb   connection=${lmp_connection}
    csn.Execute   command=rm -rf /ffs/stb/*   connection=${lmp_connection}

    csn.Execute   command=rm -rf /ffs/run/config/*   connection=${lmp_connection}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${lmp_connection}   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}

# =========================================================================================================================================
# Reboot Common Unit
Single Common Unit Reboot
    [Arguments]   ${testline}   ${common_unit}
    # # Reset Common Unit
    ${common_unit_index}   Set Variable   ${common_unit['index']}
    ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
    ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

    ${lmp_addr}   Set Variable   ${common_unit['lmp_addr']}
    ${lmp_username}   Set Variable   ${common_unit['lmp_username']}
    ${lmp_password}   Set Variable   ${common_unit['lmp_password']}

    ${testpc_connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}
    ${lmp_connection}   Set Variable   lmp_${testline}_unit_${common_unit_index}

    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${testpc_connection}
    csn.Connect To   hostname=${lmp_addr}  username=${lmp_username}  password=${lmp_password}  alias=${lmp_connection}  proxy=${testpc_connection}

    csn.Send Command   command=reboot   connection=${lmp_connection}
    # csn.Send Command   command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN   connection=${lmp_connection}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${lmp_connection}   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}


# =========================================================================================================================================
# Upgrade on Each Common Unit
Async Single Common Unit Switch Build
    [Arguments]   ${testline}   ${common_unit}   ${package_type}
    ${common_unit_index}   Set Variable   ${common_unit['index']}
    ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
    ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}


    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['path']}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}

    ${connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}

    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${connection}
    csn.Execute   command=rm -rf /home/ute/UUF4ALL/UUF_Switch_Build*   connection=${connection}
    csn.Execute   command=mkdir -p /home/ute/UUF4ALL/UUF_Switch_Build   connection=${connection}
    csn.Upload File
    ...   local_path=${CURDIR}/../Scripts/UUF_Switch_Build.robot
    ...   remote_path=/home/ute/UUF4ALL/UUF_Switch_Build/UUF_Switch_Build.robot
    ...   connection=${connection}

    ${command}=   Catenate   SEPARATOR=
    ...   source /home/ute/CIENV/${TESTLINE_NAME}/bin/activate;
    ...   cd /home/ute/UUF4ALL/UUF_Switch_Build;
    ...   robot -L trace
    ...   ${SPACE}-v testline_name:${TESTLINE_NAME}
    ...   ${SPACE}-v package_path:${package_path}
    ...   ${SPACE}-v package_version:${package_version}
    ...   ${SPACE}UUF_Switch_Build.robot &> /home/ute/UUF4ALL/UUF_Switch_Build/UUF_Switch_Build_ConsoleOutput &

    csn.Send Command   command=${command}   connection=${connection}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

# =========================================================================================================================================
# Load SCF, Check Fault 23, Upgrade, Wait Onair
Async Single Testline Load SCF
    [Arguments]   ${testline}   ${package_type}

    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${common_units_number}   Get Length   ${common_units}
    ${dual_core_flag}   Set Variable If   ${common_units_number} == 2   ${True}   ${False}

    ${common_unit_index}   Set Variable   ${common_units[0]['index']}
    ${test_pc_addr}   Set Variable   ${common_units[0]['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${common_units[0]['test_pc_username']}
    ${test_pc_password}   Set Variable   ${common_units[0]['test_pc_password']}


    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['path']}
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}
    ${release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['release']}
    ${scf_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/SCF_${release}_${testline}.xml

    ${moran_flag}   Set Variable If   ${isMoRAN} and "${testline_type}"=="gnb"   ${True}   ${False}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}


    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${testline}
    csn.Execute   command=rm -rf /home/ute/UUF4ALL/UUF_Load_SCF*   connection=${testline}
    csn.Execute   command=mkdir -p /home/ute/UUF4ALL/UUF_Load_SCF   connection=${testline}
    csn.Upload File
    ...   local_path=${CURDIR}/../Scripts/UUF_Load_SCF.robot
    ...   remote_path=/home/ute/UUF4ALL/UUF_Load_SCF/UUF_Load_SCF.robot
    ...   connection=${testline}

    ${remote_scf_path}   Set Variable   /home/ute/UUF4ALL/UUF_Load_SCF/SCF_${release}_${testline}.xml
    csn.Upload File
    ...   local_path=${scf_path}
    ...   remote_path=${remote_scf_path}
    ...   connection=${testline}

    ${netact_host_list}   Convert To String   ${NetAct_HOST_LIST}
    ${netact_host_list}   Remove String   ${netact_host_list}   ${SPACE}   [   ]   '

    ${command}=   Catenate   SEPARATOR=
    ...   source /home/ute/CIENV/${TESTLINE_NAME}/bin/activate;
    ...   cd /home/ute/UUF4ALL/UUF_Load_SCF;
    ...   robot -L trace
    ...   ${SPACE}-v testline_name:${TESTLINE_NAME}
    ...   ${SPACE}-v dual_core_flag:${dual_core_flag}
    ...   ${SPACE}-v moran_flag:${moran_flag}
    ...   ${SPACE}-v scf_path:${remote_scf_path}
    ...   ${SPACE}-v package_path:${package_path}
    ...   ${SPACE}-v netact_host_list:${netact_host_list}
    ...   ${SPACE}-v vm_ip:${vm_ip}
    ...   ${SPACE}-v service_user:${service_user}
    ...   ${SPACE}-v service_password:${service_password}
    ...   ${SPACE}-v dist_name:${dist_name}
    ...   ${SPACE}UUF_Load_SCF.robot &> /home/ute/UUF4ALL/UUF_Load_SCF/UUF_Load_SCF_ConsoleOutput &

    csn.Send Command   command=${command}   connection=${testline}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}

# # =========================================================================================================================================
# # Single Common Unit Recover NE3S Configuration
# Single Common Unit Recover NE3S Configuration
#     [Arguments]   ${testline}   ${common_unit}
#     ${common_unit_index}   Set Variable   ${common_unit['index']}
#     ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
#     ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
#     ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

#     ${lmp_addr}   Set Variable   ${common_unit['lmp_addr']}
#     ${lmp_username}   Set Variable   ${common_unit['lmp_username']}
#     ${lmp_password}   Set Variable   ${common_unit['lmp_password']}

#     ${testpc_connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}
#     ${lmp_connection}   Set Variable   lmp_${testline}_unit_${common_unit_index}

#     csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${testpc_connection}
#     csn.Connect To   hostname=${lmp_addr}  username=${lmp_username}  password=${lmp_password}  alias=${lmp_connection}  proxy=${testpc_connection}

#     csn.Upload File
#     ...   remote_path=/ffs/run/config/safe/account/ws.json
#     ...   local_path=${OUTPUT_DIR}/${lmp_connection}/ws.json
#     ...   connection=${lmp_connection}

#     csn.Upload File
#     ...   remote_path=/ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
#     ...   local_path=${OUTPUT_DIR}/${lmp_connection}/ne3sadaptdata.db
#     ...   connection=${lmp_connection}

#     FOR   ${managers_file}   IN   @{MANAGERS_FILE_LIST}
#         ${remote_path}   Set Variable   ${managers_file["remote_path"]}
#         ${local_path}   Set Variable   ${managers_file["local_path"]}
#         Run Keyword And Ignore Error   csn.Upload File
#         ...   remote_path=${remote_path}
#         ...   local_path=${local_path}
#         ...   connection=${lmp_connection}
#     END

#     [Teardown]   Run Keywords
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${lmp_connection}   AND
#     ...   Run Keyword And Ignore Error   csn.Disconnect   connection=${testpc_connection}



# =========================================================================================================================================
# Check Process Done
Async Single Testline Check Robot Process Finished
    [Arguments]   ${testline}   ${process_name}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    @{Fatal_Error_List}   Create List
    FOR   ${common_unit}   IN   @{common_units}
        ${Fatal_Error}   Async Single Common Unit Check Robot Process Finished
        ...   process_name=${process_name}   testline=${testline}   common_unit=${common_unit}
        Append To List   ${Fatal_Error_List}   ${Fatal_Error}
    END
    Return From Keyword If   "Fatal_Error" in ${Fatal_Error_List}   Fatal_Error

Async Single Common Unit Check Robot Process Finished
    [Arguments]   ${testline}   ${common_unit}   ${process_name}
    ${common_unit_index}   Set Variable   ${common_unit['index']}
    ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
    ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

    ${connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}

    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${connection}

    ${status}   csn.Execute   command=cat /home/ute/UUF4ALL/${process_name}/${process_name}_Result   connection=${connection}
    ${process_failed}   Run Keyword And Return Status   Should Contain   ${status}   ${process_name}_Result_FAIL
    Return From Keyword If   ${process_failed}   Fatal_Error
    # Run Keyword If   ${process_failed}   Fatal Error
    Should Contain   ${status}   ${process_name}_Result_PASS

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}

Async Single Testline Download Robot Process Logs
    [Arguments]   ${testline}   ${process_name}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    FOR   ${common_unit}   IN   @{common_units}
        Async Single Common Unit Download Robot Process Logs   process_name=${process_name}   testline=${testline}   common_unit=${common_unit}
    END

Async Single Common Unit Download Robot Process Logs
    [Arguments]   ${testline}   ${common_unit}   ${process_name}
    ${common_unit_index}   Set Variable   ${common_unit['index']}
    ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
    ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
    ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

    ${connection}   Set Variable   test_pc_${testline}_unit_${common_unit_index}

    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${connection}

    csn.Execute   command=rm -rf /home/ute/UUF4ALL/${process_name}/admin_api_*   connection=${connection}
    csn.Execute   command=cd /home/ute/UUF4ALL/; tar -cvf ${process_name}.zip ${process_name}/   connection=${connection}
    csn.Download File
    ...   remote_path=/home/ute/UUF4ALL/${process_name}.zip
    ...   local_path=${OUTPUT_DIR}/${process_name}_${connection}.zip
    ...   connection=${connection}
    ...   timeout=${300}
    csn.Execute   command=rm -rf /home/ute/UUF4ALL/${process_name}*   connection=${connection}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}
