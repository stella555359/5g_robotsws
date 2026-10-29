*** Settings ***
Library     OperatingSystem
Library     taf.fdsw.rc    WITH NAME    fdswrc
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot

Documentation    This is common keywords for siso related UUF cases in ute cloud
...              Please do not modify the file without notification to author

*** Variables ***
#${TEST_ITERATION}=                     1
#${5G_SOURCE_SW}=    	SBTS00_ENB_9990_240507_000009
#${5G_TARGET_SW}=    	SBTS00_ENB_9999_240514_000008
${5G_SOURCE_SW}=                       ${None}
${5G_TARGET_SW}=                       ${None}
${CUSTOM_ALARMS}=                      4654   4655   61524   61649   61652
${REMOTE_VM_IP}=                       ${None}
${REMOTE_MPLANE}=                      ${None}
${LABEL}=                              ${None}
${HOSTNAME}=                           ${None}
${CRITICAL_FAULTS}=                    @{EMPTY}
${SHOULD_BE_REPORTED}=                 ${False}
${REPORT_SW}=                          ${None}
${CUSTOMERS_LIST}=                     Generic
${5G_TARGET_SW_PATH}=                  ${None}
${4G_SOURCE_SW}=                       ${None}
${4G_TARGET_SW}=                       ${None}
${4G_TARGET_SW_PATH}=                  ${None}
${USE_TEST_PACKAGES}=                  ${False}
${USE_BUILDS_STORAGE}=                 ${False}
${RESTORE_TARGET_SW}=                  ${True}
${REMOTE_NODE_UPDATE}=                 ${False}
${USE_REMOTE_NODE}=                    ${True}
${DOWNLOAD_PATH}=                      ${None}
${LOCAL_NODE_ATTACH_TEST_KEYWORD}=     ${None}
${REMOTE_NODE_ATTACH_TEST_KEYWORD}=    ${None}
${PERFORM_UBOOT_DOWNGRADE}=            ${True}
${DISABLE_SYSLOG_CHECK}=               ${False}
${USER_SUSPICIOUS_PRINTS}=             @{EMPTY}
${REPORT_COMMENT}=                     ${None}
${QC_DOMAIN}=                          ${None}
${QC_PROJECT}=                         ${None}
${QC_ID}=                              ${None}
# Artifactory Authentication Token for Hz1 server
${ARTIFACTORY_TOKEN}=                  cmVmdGtuOjAxOjE3OTM4NjQ4MzE6VDhEWGd5U1MwMUsxYmFjdjVUYzFoNUlVRmdu
# Syslog ignored prints for CSV4ALL
@{IGNORED_PRINTS}                      is not defined in SysinfoQuota.xml. Please contact the owner
# CSV4ALL Variables
${rp_ca}                      VRF_SiSo
${rp_location}                VRF_HAZ
${rp_organization}            VRF_HAZ_T04
&{node}                    node_alias=uuf_gnb    testline_object=${tl.gnbs[0]}    source_sw=${5G_SOURCE_SW}    target_sw=${5G_TARGET_SW}
...    critical_alarms=${CRITICAL_FAULTS}    custom_allowed_alarms=${CUSTOM_ALARMS}    syslog_ignored_prints=${IGNORED_PRINTS}
@{nodes}                  ${node}

*** Keywords ***
General_UUF_in_UTE_cloud
    [Documentation]
        ...    *****************
    ...    Feature Owner: Fang Yi
    ...    Resolve FID30 caused by CB012098,please refer to https://jiradc.ext.net.nokia.com/browse/WESTLAKE-10614
    ...    *****************
    ...    [TEST DESCRIPTION] The test case is to verify that UUF in ute cloud is successful.
    ...    ******************
    ...    [TEST PARAMETERS]
    ...    - TEST_ITERATION: The number of test iteration
    ...    ******************
    ...    [TEST STEPS]
    ...    1. Upgrade SW to the source version
    ...    2. Loop upgrade SW to the target version and rollback to the source version
    ...    ******************
    ...    [TEST AUTHOR]
    ...    - Created by: Mengting Li
    ...    - Date: 05.15.2024
    ...    ******************
    ...    [TEST HISTORY]
    ...    - Known PR767758: FID:4589 Unit power reset
    ...    ******************
    [Arguments]    ${TEST_ITERATION}=1
    ${5G_SOURCE_SW}=    run keyword if    '${5G_SOURCE_SW}'=='${None}'    Get Source SW
    ...    ELSE    set variable    ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    run keyword if    '${5G_TARGET_SW}'=='${None}'    Get Target SW
    ...    ELSE    set variable    ${5G_TARGET_SW}
    set suite variable    ${5G_TARGET_SW}
    log to console   \n***upgrade SW to the source version start***\n
    Software Update to the Source Version    source_sw=${5G_SOURCE_SW}
    log to console   \n***upgrade SW to the source version done***\n
    Modify Params before SW UPGRADE
    Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    CSV4ALL_SW_UPGRADE_COMMON_CASE
    ...    test_iteration=${TEST_ITERATION}
    ...    5g_source_sw=${5G_SOURCE_SW}
    ...    5g_target_sw=${5G_TARGET_SW}
    Start Btslog With Path Check

Modify Params before SW UPGRADE
    log to console    \nModify Params before SW UPGRADE
    selenium login and disable screen lock
    Modify Parameter if Need Modify    dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate configuration data validation during SW upgrade
    ...    new_value=true
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${False}    timeout=${300}
    [Teardown]  selenium logout and close browser

CSV4ALL_SW_UPGRADE_COMMON_CASE
    [Arguments]    ${test_iteration}=1    ${5g_source_sw}=${5G_SOURCE_SW}    ${5g_target_sw}=${5G_TARGET_SW}    ${call_method}=${None}
    ${testline_name}    Get Testline Name
    Set To Dictionary    ${node}    source_sw=${5g_source_sw}    target_sw=${5g_target_sw}    testline_scout_name=${testline_name}
    CSV4AllTestCases.e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${node}
    ...    iterations_per_node=${test_iteration}
    ...    report=${True}                         # default value, to be replaced with variable if needed
    ...    calculate_kpi=${True}                  # default value, to be replaced with variable if needed
    ...    kpi_targets=${None}                    # default value, to be replaced with variable if needed
    ...    use_dcap=${False}                      # default value, to be replaced with variable if needed
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    report_comment=${None}                 # default value, to be replaced with variable if needed
    ...    sw_build=${None}                       # default value, to be replaced with variable if needed
    ...    topology=${None}                       # default value, to be replaced with variable if needed
    ...    use_external_storage=${False}          # default value, to be replaced with variable if needed
    ...    download_path=/home/ute
    ...    use_testpackage=${False}               # default value, to be replaced with variable if needed
    ...    restore_to_target_sw=${True}           # default value, to be replaced with variable if needed
    ...    stop_test_after_fail=${False}          # default value, to be replaced with variable if needed
    ...    artifactory_location=espoo2               # default value, to be replaced with variable if needed
    ...    package_suffix=A54                     # default value, to be replaced with variable if needed
    ...    synchronize_software_on_passive=${False}  # default value, to be replaced with variable if needed
    ...    yaft_path=/home/ute                    # default value, to be replaced with variable if needed
    ...    virtualenv_dir=${None}                 # default value, to be replaced with variable if needed
    ...    rollback_reverse_order=${False}        # default value, to be replaced with variable if needed
    ...    l3_call_method=${call_method}

UUF4ALL_SW_UPGRADE_COMMON_CASE
    [Arguments]    ${test_iteration}=1    ${5g_source_sw}=${5G_SOURCE_SW}    ${5g_target_sw}=${5G_TARGET_SW}
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${test_iteration}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          report_sw=${REPORT_SW}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5g_source_sw}
    ...          5g_target_sw=${5g_target_sw}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_test_packages=${USE_TEST_PACKAGES}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          download_path=${DOWNLOAD_PATH}
    ...          local_node_attach_test_keyword=${LOCAL_NODE_ATTACH_TEST_KEYWORD}
    ...          remote_node_attach_test_keyword=${REMOTE_NODE_ATTACH_TEST_KEYWORD}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${QC_ID}

Software Update to the Source Version
    [Arguments]    ${source_sw}    ${timeout}=${600}    ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds   3x   10s   Connect to gnb coam via ssl
    ${Current_SW_version}=    Check the current SW version
    run keyword and ignore error    COAM Teardown gnb connections
    return from keyword if    '${Current_SW_version}'=='${source_sw}'
    ${Passive_SW_version}=    Check the Passive SW version
    IF    '${Passive_SW_version}'=='${source_sw}'
        Log To Console   Start Rollback Source Software...
        AlarmWatchdog.add_allow_alarms    fault_id=23
        ${rollback_status}    Run Keyword And Return Status    coam.rollback_software    timeout=${timeout}    connection=${connection}
        IF  not ${rollback_status}
            FAIL  Software rollback was not performed.
        END
        Sleep    5min  # Wait for software rollback success
        # Connection was invalid after software rollback, need to manually reconnect
        Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
        Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=${connection}

        Log To Console    \nstart check fault 23 appear
        ${ru_version_mismatch}    Run Keyword And Return Status    Wait For Expect Fault Present  faultId=23   timeout=${300}
        IF    ${ru_version_mismatch}
            Log To Console    \nFault 23 appears, upgrade software again to fix RU version mismatch
            ${package_path}=   Download Classical SW Package    package_version=${source_sw}    package_folder=/home/ute
            Perform SW Update    package=${package_path}    connection=${connection}
            Wait Until Keyword Succeeds   10min   30s   Connect to gnb coam via ssl
            Log To Console    \nstart check fault 23 disappear
            Wait For Expect Fault To Disappear  faultId=23   timeout=${timeout}
        END
        COAM Wait gnb And Cells ready    timeout=15 min
        AlarmWatchdog.remove_allow_alarms    fault_id=23
        Log To Console   Rollback Source Software Finished.
    ELSE
        Log To Console   Start Source Software Update From Console Mode...
        ${package_path}=   Download Classical SW Package    package_version=${source_sw}    package_folder=/home/ute
        Coam Admin Reset Configuration
        AlarmWatchdog.add_allow_alarms    fault_id=23
        Upgrade Software From Console Mode    package_path=${package_path}    scf_path=${Case_SCF_Path}
        AlarmWatchdog.remove_allow_alarms    fault_id=23
        Log To Console   Update Source Software From Console Mode Finished.
    END

    Check site status after SW version update    source_sw=${source_sw}
    Log To Console   Source Software Update Finished.
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections

Coam Admin Reset Configuration
    [Arguments]    ${timeout}=${600}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds   3x   10s   Connect to gnb coam via ssl
    Log To Console    \nStart configuration reset!
    coam.reset_configuration    timeout=${timeout}    connection=${connection}
    Sleep    5m    reason=wait for rru check
    Log To Console    \nFinish configuration reset!
    Run Keyword And Ignore Error    COAM Teardown gnb connections

Upgrade Software From Console Mode
    [Arguments]    ${package_path}    ${scf_path}=${None}    ${timeout}=${1800}    ${connection}=GNB_OAM
    ...    ${fdswrc_connection}=Rescue_Console_Connection
    ...    ${host}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    [Documentation]    Author: Shifu Lan
    ...    Description: Upgrade software from console mode after reset configuration until BTS site onair
    Log To Console    \nStart Upgrade Software From Console Mode
    fdswrc.connect_to    ip_address=${host}    port=443    username=${username}    password=${password}    name=${fdswrc_connection}
    ${active_part_id}    fdswrc.get_active_sw_partition    connection=${fdswrc_connection}
    fdswrc.software_update    sw_pkg_path=${package_path}    timeout=${timeout}    activate=True
    ...    sw_slot_id=${active_part_id}    connection=${fdswrc_connection}
    Sleep    2min

    Wait Until Keyword Succeeds   10min   30s   Connect to gnb coam via ssl
    ${scf_path_after_upgrade}    Set Variable If    '${scf_path}'!='None'    ${scf_path}    ${Case_SCF_Path}
    COAM Commission with scf file  scf_file_path=${scf_path_after_upgrade}    timeout=${720}    connection=${connection}
    Sleep    5min
    Log To Console    \nstart check fault 23 appear
    ${ru_version_mismatch}    Run Keyword And Return Status    Wait For Expect Fault Present  faultId=23   timeout=${300}
	IF    ${ru_version_mismatch}
        Log To Console    \nFault 23 appears, upgrade software again to fix RU version mismatch
        Perform SW Update    package=${package_path}    connection=${connection}
        Wait Until Keyword Succeeds   10min   30s   Connect to gnb coam via ssl
        Log To Console    \nstart check fault 23 disappear
        Wait For Expect Fault To Disappear  faultId=23   timeout=${timeout}
    END
    COAM Wait gnb And Cells ready    timeout=15 min
    Add Gnb Rad Flag For Syslog

Check site status after SW version update
    [Arguments]    ${source_sw}
    Wait Until Keyword Succeeds   3x   10s   Connect to gnb coam via ssl
    Log To Console   Check site status after software update
    Wait Until Keyword Succeeds   10m   10s   Verify all cells should be onair
    Log To Console   Check site version after software update
    ${Current_SW_version}=    Check the current SW version
    should be true    '${Current_SW_version}'=='${source_sw}'
    Log To Console   Check site active alarm after software update
    Check Truck Roll after target SW version update
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    Log To Console   Check site history alarm after software update
    &{fault_23}     Create Dictionary     faultId=${23}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_23}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    run keyword if    '${5G_TARGET_SW}'=='${source_sw}'    should be true    ${history_alarm_status}
    run keyword if    '${alarm_status}'=='${False}' or '${history_alarm_status}'=='${False}'    run keywords
    ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM    AND
    ...    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    [Teardown]   Run Keyword And Ignore Error   COAM Teardown gnb connections

Check Truck Roll after target SW version update
    ${truck_roll_fault}   Create List    10    1806    4341    4352   4383
    ${active_alarms}    coam.get_active_alarms    timeout=${100}    connection=GNB_OAM
    FOR   ${active_alarm}    IN   @{active_alarms}
        Builtin.Log   ${active_alarm['faultId']}
        ${roll}    run keyword and return status   should not contain   ${truck_roll_fault}   ${active_alarm['faultId']}
        run keyword if    not ${roll}
        ...    fatal error    msg=Fault ${active_alarm['faultId']}, possible truck roll issue, case fail and stop!!!!!
    END

Check If SBTS Trunk
    [Arguments]  ${version}
    ${is_sbts_trunk}    run keyword and return status      Should Match Regexp    ${version}    .*_ENB_(9999|9990)_.*
	[Return]    ${is_sbts_trunk}

Convert SBTS Version
    [Arguments]  ${version}  ${is_trunk}=${True}
	IF    not ${is_trunk}    RETURN    ${version}
    ${stream}    Fetch From Left    ${version}    _
    ${converted_version}   Replace String    ${version}    ${stream}    SBTS00
    [Return]    ${converted_version}

Check the current SW version
    ${Active_SW_version} =    Get Active SW Version
    ${sbts_trunk}    Check If SBTS Trunk    version=${Active_SW_version}
    ${Current_SW_version}    Convert SBTS Version    version=${Active_SW_version}    is_trunk=${sbts_trunk}
    [Return]    ${Current_SW_version}

Check the Passive SW version
    [Arguments]  ${connection}=GNB_OAM
    Wait Until Keyword Succeeds   3x   10s   Connect to gnb coam via ssl
    ${software_info}=    coam.get_software_info     connection=${connection}
    ${Passive_SW_version} =    set variable    ${software_info['Passive SW version']}
    ${sbts_trunk}    Check If SBTS Trunk    version=${Passive_SW_version}
    ${Passive_SW_version}    Convert SBTS Version    version=${Passive_SW_version}    is_trunk=${sbts_trunk}
    [Return]    ${Passive_SW_version}

Check Site Connection Status
    [Arguments]   ${ip_address}=${tl.gnbs[${0}].cu.oam_ssh_connection_details.addr}   ${status}=disconnect
    Log To Console   Check Connection Status: ${status}
    ${result}   OperatingSystem.Run   command=timeout 2s ping -c 1 ${ip_address} > /dev/null 2>&1; echo $?
    ${result}   Strip String   ${result}
    Run Keyword If   "${status}"=="disconnect"   Should Not Be True   "${result}"=="0"
    Run Keyword If   "${status}"=="connect"   Should Be True   "${result}"=="0"

Download Classical SW Package
    [Arguments]   ${package_version}   ${package_folder}=/home/ute
    ${version_path}=    Check all packet path    package_version=${package_version}    package_folder=${package_folder}
    Return From Keyword If    "${version_path}"!="${EMPTY}"    ${version_path}
    ${version_path}   Set Variable   ${package_folder}/${package_version}.zip
    ${version_path}=    Start to download because no package found    package_version=${package_version}    version_path=${version_path}
    [Return]   ${version_path}

Check all packet path
    [Arguments]   ${package_version}   ${package_folder}=/home/ute
    ${version_path}   Set Variable   ${package_folder}/${package_version}.zip
    ${package_exist}=    Check Packet Exist    package_path=${version_path}
    Return From Keyword If    ${package_exist}    ${version_path}
    ${origin_path}   Set Variable   ${package_folder}/${package_version}_release_BTSSM_downloadable_A54.zip
    ${package_exist}=    Run Keyword If   not ${package_exist}
    ...    Check Packet Exist    package_path=${origin_path}
    Run Keyword If   ${package_exist}   OperatingSystem.Move File   ${origin_path}   ${version_path}
    Return From Keyword If    ${package_exist}    ${version_path}
    Log To Console   Package Do Not Exist, Need to Download Package!
    [Return]   ${EMPTY}

Check Packet Exist
    [Arguments]   ${package_path}
    ${file_exists}   Run Keyword and Return Status
    ...   OperatingSystem.File Should Exist   path=${package_path}
    ${targetBD}   Run Keyword If   ${file_exists}
    ...    OperatingSystem.Run   command=unzip -l ${package_path} | grep -i TargetBD | awk '{print $4}'
    ...    ELSE   Set Variable   ${EMPTY}
    ${fileIntegrity}   Run Keyword And Return Status   Should Not Be Empty   ${targetBD}
    run keyword and ignore error    Run Keyword If   not ${fileIntegrity}   OperatingSystem.Run   command=rm -rf ${package_path}
    [Return]   ${fileIntegrity}

Start to download because no package found
    [Arguments]   ${package_version}    ${version_path}
    Log To Console   Package Do Not Exist, Start to Download Package!
    ${package_download_link}   Get Download Package Link   package_version=${package_version}
    Log To Console   Package Download Link: ${package_download_link}
    OperatingSystem.Run   command=rm -f wget-log*

    # Check if download link is from hz1 server and add token authentication
    ${is_hz1_download}   Run Keyword And Return Status   Should Contain   ${package_download_link}   artifactory-hz1
    ${wget_command}   Set Variable If   ${is_hz1_download}
    ...   wget --no-check-certificate --header="Authorization: Bearer ${ARTIFACTORY_TOKEN}" -b ${package_download_link} -O ${version_path}
    ...   wget --no-check-certificate -b ${package_download_link} -O ${version_path}

    OperatingSystem.Run   command=${wget_command}
    Sleep   10s
    ${output}   OperatingSystem.Run   command=cat wget-log | head -n 20
    Should Contain   ${output}   Saving to
    ${output}   OperatingSystem.Run   command=cat wget-log | head -n 20
    Should Not Contain   ${output}   404 Not Found
    Wait Until Keyword Succeeds   90m   1m   Check Wget Process Done   package_name=${version_path}
    OperatingSystem.File Should Exist   path=${version_path}
    OperatingSystem.Run   command=rm -f wget-log*
    Log To Console   Download Classical Package Finished!
    Log To Console   Package Path: ${version_path}
    [Return]   ${version_path}

Get Download Package Link
    [Arguments]   ${package_version}
    @{wft_services}   Create Download All Link List   package_version=${package_version}
    ${package_download_link}   Set Variable   ${EMPTY}
    FOR   ${wft_service}   IN   @{wft_services}
       # Check if this is hz1 server that needs token authentication
       ${is_hz1}   Run Keyword And Return Status   Should Contain   ${wft_service}   artifactory-hz1

       # Use token authentication for hz1 server, regular test for others
       ${http_code}   Run Keyword If   ${is_hz1}
       ...   OperatingSystem.Run
       ...   command=echo $(curl -ksIL -H "Authorization: Bearer ${ARTIFACTORY_TOKEN}" -w "%\{http_code\}" -o /dev/null ${wft_service})
       ...   ELSE   OperatingSystem.Run   command=echo $(curl -ksIL -w "%\{http_code\}" -o /dev/null ${wft_service})

       ${package_download_link}   Set Variable If   '${http_code.find('200')}'!='-1'   ${wft_service}   ${EMPTY}
       Exit For Loop If   '${http_code.find('200')}'!='-1'
    END
    Run Keyword If   "${package_download_link}"=="${EMPTY}"
    ...   FAIL   msg=Package Version Don't Exist In ALL Download Link. Please Download Manually.
    [Return]   ${package_download_link}

Create Download All Link List
    [Arguments]   ${package_version}
    ${package_prefix}   Split String   ${package_version}   _
    ${package_prefix}   Set Variable   ${package_prefix[0]}
    # Only keep active servers: hz1 (with token auth) and espoo2 as backup
    @{wft_service_list}   Create List
    ...   https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
    ...   https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
    @{wft_services}   Create List
    FOR   ${wft_service}   IN   @{wft_service_list}
        ${wft_full_link_1}   Set Variable
        ...   ${wft_service}/${package_prefix}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_2}   Set Variable
        ...   ${wft_service}/${package_prefix}/${package_version}_release_BTSSM_downloadable_A54.zip
        ${wft_full_link_3}   Set Variable
        ...   ${wft_service}/SBTSCD00/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        Append To List   ${wft_services}   ${wft_full_link_1}   ${wft_full_link_2}   ${wft_full_link_3}
    END
    [Return]   ${wft_services}

Check Wget Process Done
    [Arguments]   ${package_name}
    ${output}   OperatingSystem.Run   command=cat wget-log | grep -i "saved"
    Should Contain   ${output}   ${package_name}
