*** Settings ***
Resource   Common.robot

*** Variables ***

*** Keywords ***
Start Process Async UUF Switch Build
    [Arguments]   ${testline}   ${package_type}
    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}
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
    ${Fatal_Error}   Wait Until Keyword Succeeds   60m   1m
    ...   Async Single Common Unit Check Robot Process Finished
    ...      testline=${testline}
    ...      common_unit=${common_units[0]}
    ...      process_name=UUF_Load_SCF
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

    csn.Execute   command=rm -rf /ffs/run/config   connection=${lmp_connection}

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
    ...   local_path=${CURDIR}/../scripts/UUF_Switch_Build.robot
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


    csn.Connect To   hostname=${test_pc_addr}   username=${test_pc_username}   password=${test_pc_password}   alias=${testline}
    csn.Execute   command=rm -rf /home/ute/UUF4ALL/UUF_Load_SCF*   connection=${testline}
    csn.Execute   command=mkdir -p /home/ute/UUF4ALL/UUF_Load_SCF   connection=${testline}
    csn.Upload File
    ...   local_path=${CURDIR}/../scripts/UUF_Load_SCF.robot
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
    ...   ${SPACE}UUF_Load_SCF.robot &> /home/ute/UUF4ALL/UUF_Load_SCF/UUF_Load_SCF_ConsoleOutput &

    csn.Send Command   command=${command}   connection=${testline}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline}


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
