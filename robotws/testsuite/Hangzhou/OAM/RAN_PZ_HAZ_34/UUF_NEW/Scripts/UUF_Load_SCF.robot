*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library     BuiltIn
Library     String
Library     Process
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     taf.sbts.oam.coam.admin   WITH NAME   coam
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info

*** Variables ***
${testline_name}    UUF4ALL
${webem_addr}       192.168.255.129
${webem_username}   Nemuadmin
${webem_password}   nemuuser
${ssh_addr}         192.168.255.129
${ssh_username}     toor4nsn
${ssh_password}     oZPS0POrRieRtu

${scf_path}
${package_path}
${dual_core_flag}
${moran_flag}
${netact_host_list}
${vm_ip}
${service_user}
${service_password}
${dist_name}

*** Test Cases ***
UUF Load SCF
    OperatingSystem.Create File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Start UUF Load SCF Process......\n

    # Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword If   ${dual_core_flag}   Dual Core Start Sync ADMIN
    Run Keyword If   ${dual_core_flag}   Dual Core SystemModules Detected

    COAM Load SCF


    # ${fault23}   Wait Until Keyword Succeeds   30m   2m   COAM RU Detected And Fault23 Appeared
    # Sleep   30s
    # COAM Wait Software Update Possible
    # Wait Until Keyword Succeeds   2x   2m   Run Keyword If   ${fault23}   COAM SWM Update

    Wait Until Keyword Succeeds   6x   6m   COAM Wait RU Detected And Check Fault23 And SWM Update

    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Start Check Cell Status...\n
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   20m   1m   COAM Check Cell Status
    Run Keyword And Ignore Error   COAM Check NMS Status

    [Teardown]   Common Teardown




*** Keywords ***
Common Teardown
    Run Keyword And Ignore Error   coam.collect_im_snapshot
    ...   target_file_name=${OUTPUT_DIR}/IMS2_UUF_Load_SCF_Result.ims2   timeout=${300}   connection=${testline_name}

    Run Keyword And Ignore Error   COAM Logout
    # Run Keyword And Ignore Error   Block or Recovery NetAct Connection By iptables   action=Recovery
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   UUF_Load_SCF_Result_${TEST_STATUS}\n


COAM Login
    coam.connect_to
    ...   bts_host=${webem_addr}
    ...   bts_port=${443}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${OUTPUT_DIR}
    ...   trim_logs=${True}
    ...   name=${testline_name}

COAM Logout
    coam.teardown   connection=${testline_name}


COAM Wait Software Update Possible
    [Arguments]   ${bts_ready}=${True}   ${readiness_timeout}=${3600}   ${timeout}=${3700}
    coam.wait_sw_update_possible
    ...   bts_ready=${bts_ready}
    ...   readiness_timeout=${readiness_timeout}
    ...   timeout=${timeout}
    ...   connection=${testline_name}


COAM Modify MORAN actIndSwUpgradeForSharedRU
    Return From Keyword If   not ${moran_flag}

    ${scf_content}   XML.Parse XML   ${scf_path}
    Set Elements Text   ${scf_content}   text=false
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]/p[@name="actIndSwUpgradeForSharedRU"]
    XML.Save Xml   source=${scf_content}   path=${scf_path}


COAM Load SCF
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Perform SCF Started...\n
    Run Keyword If   ${moran_flag}   COAM Modify MORAN actIndSwUpgradeForSharedRU
    coam.perform_commissioning
    ...   scf_file=${scf_path}
    ...   skip_parameter_relation_errors=${True}
    ...   should_activate=${True}
    ...   timeout=${600}
    ...   connection=${testline_name}
    Run Keyword And Ignore Error   COAM Logout
    Sleep   10s
    Wait Until Keyword Succeeds   15m   1m   COAM Login
    Sleep   30s
    Run Keyword And Ignore Error   COAM Check NMS Status
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   COAM Logout
    ...   AND
    ...   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Perform SCF Result: ${KEYWORD_STATUS}\n


COAM RU Detected And Fault23 Appeared
    ${hw_info}   coam.get_detected_hw_info   connection=${testline_name}
    ${rmod_status_list}   Create List
    FOR   ${rmod}   IN   @{hw_info['radioModules']['rmod']}
        Append To List   ${rmod_status_list}   ${rmod['status']['proceduralStatus'].lower()}
    END
    List Should Not Contain Value   ${rmod_status_list}   not initialized


    ${ru_not_initializing}   Run Keyword And Return Status   List Should Not Contain Value   ${rmod_status_list}   initializing
    ${ru_configured}   Run Keyword And Return Status   List Should Contain Value   ${rmod_status_list}   configured
    Return From Keyword If   ${ru_not_initializing} and ${ru_configured}   ${False}


    ${active_alarms}   coam.get_active_alarms   connection=${testline_name}   timeout=${30}
    ${fault_list}   Create List
    FOR   ${active_alarm}    IN   @{active_alarms}
        ${faultId}   Get Variable Value   ${active_alarm['faultId']}   ${EMPTY}
        Continue For Loop If   "${faultId}"=="${EMPTY}"
        Append To List   ${fault_list}   ${faultId}
    END
    List Should Contain Value   ${fault_list}   ${23}
    [Return]   ${True}


COAM SWM Update
    Log To Console   Start Software Updating...
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Start Software Updating...\n

    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${3600}   connection=${testline_name}
    Log To Console   Software Update Finished, Waiting For Resetting...
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Software Update Finished, Waiting For Resetting...\n

    Run Keyword And Ignore Error   COAM Logout
    Sleep   3m
    Wait Until Keyword Succeeds   15m   1m   COAM Login

    Log To Console   Reset finished!
    Log To Console   COAM SWM Update Done!
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Reset finished!\n

    [Teardown]   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Start Software Updating Result: ${KEYWORD_STATUS}\n


COAM Wait RU Detected And Check Fault23 And SWM Update
    Wait Until Keyword Succeeds   5m   1m   COAM Login
    ${fault23}   Wait Until Keyword Succeeds   15m   2m   COAM RU Detected And Fault23 Appeared
    Sleep   10s
    COAM Wait Software Update Possible

    Run Keyword If   ${fault23}   COAM SWM Update
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


COAM Check Cell Status
    ${bts_info}   coam.get_bts_info   connection=${testline_name}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

    # ${cell_list}   get_cell_status_list   connection=${testline}

    FOR   ${cell}   IN   @{cell_list}
        ${operationalState}   Get Variable Value   ${cell['status']['operationalState']}   N/A
        Run Keyword If   "${operationalState}"!="N/A"
        ...   Should Be Equal   ${operationalState.lower()}   enabled
    END
    [Teardown]   Run Keyword If   "${KEYWORD_STATUS}"=="PASS"
    ...   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Check Cell Status Result: ${KEYWORD_STATUS}\n


# ==============================================================================================================================================
# ==============================================================================================================================================
# ==============================================================================================================================================
# Dual Core
Dual Core Start Sync Selenium
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Dual Core Env Start Sync...\n

    selenium_sbts.enable_virtual_display

    ${plug_and_play}   Evaluate   {"modal_name":"Plug and Play", "button":"Cancel", "timeout": 10}
    ${additional_hardware_detected}   Evaluate   {"modal_name":"Additional hardware detected", "button":"Start sync", "timeout": 10}

    ${modal_action_configurations}   Create List   ${plug_and_play}   ${additional_hardware_detected}
    selenium_sbts.login
    ...   url=https://${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   modal_action_configurations=${modal_action_configurations}
    ...   alias=${testline_name}

    Run Keyword and Ignore Error   selenium_sbts.disable_message_box   sbts=${testline_name}
    Run Keyword and Ignore Error   selenium_sbts.disable_screen_lock   sbts=${testline_name}

    ${exists}   selenium_sbts.start_up_view_window_exists   sbts=${testline_name}
    Run Keyword If   ${exists}   selenium_sbts.close_start_up_view_window   sbts=${testline_name}

    Run Keyword And Ignore Error   selenium_sbts.continue_after_plug_and_play_modal_appear   sbts=${testline_name}

    # selenium_sbts.load_commissioning_file_and_check_load_status
    # ...   file_path=${scf_path}
    # ...   sbts=${testline_name}
    # ...   timeout=${300}

    # selenium_sbts.activate_plan   sbts=${testline_name}   timeout=${300}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   selenium_sbts.logout   sbts=${testline_name}   AND
    ...   Run Keyword And Ignore Error   selenium_sbts.close_browser   sbts=${testline_name}   AND
    ...   Run Keyword And Ignore Error   selenium_sbts.disable_virtual_display   AND
    ...   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Dual Core Env Start Sync Result: ${KEYWORD_STATUS}\n


Dual Core Start Sync ADMIN
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${neighbor_dn}   coam.get_managed_objects   class_name=NEIGHBOR_NODE_R   timeout=${60}   connection=${testline_name}
    ${sync_status}   Run Keyword And Return Status   coam.start_sync   dist_name=${neighbor_dn[0]['distName']}   connection=${testline_name}
    Run Keyword If   not ${sync_status}   Fail   msg=COAM Dual Core Start Sync Failed!
    Sleep   10s
    Log To Console   COAM Dual Core Start Sync Succeeded!
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   COAM Logout
    ...   AND
    ...   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Dual Core Env Start Sync Result: ${KEYWORD_STATUS}\n


Dual Core SystemModules Detected
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    ${hw_info}   coam.get_detected_hw_info   connection=${testline_name}   timeout=${300}
    ${smod_number}   Get Length   ${hw_info["systemModules"]}
    Should Be True   ${smod_number} >= 2
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Block or Recovery NetAct Connection By iptables
    [Arguments]   ${action}=Recovery

    Return From Keyword If   "${netact_host_list}"=="" or "${netact_host_list}"=="${None}"

    @{HOST_LIST}   Split String   ${netact_host_list}   ,

    ${param}   Set Variable If
    ...   "${action}"=="Block"   -I
    ...   "${action}"=="Recovery"   -D
    ...   -D

    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline_name}
    FOR   ${ip_addr}   IN   @{HOST_LIST}
        csn.Execute   command=iptables ${param} INPUT -s ${ip_addr} -j DROP   connection=${testline_name}
        csn.Execute   command=iptables ${param} OUTPUT -s ${ip_addr} -j DROP   connection=${testline_name}
        csn.Execute   command=iptables ${param} INPUT -d ${ip_addr} -j DROP   connection=${testline_name}
        csn.Execute   command=iptables ${param} OUTPUT -d ${ip_addr} -j DROP   connection=${testline_name}
    END
    [Teardown]   csn.Disconnect   connection=${testline_name}


UUF SWM Upload
    Log To Console   //TODO: UUF SWM Upload

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    ${operation_id}   csn.Execute   command=swmCLI.sh -op start -t upload -dn PLMN-PLMN/${dist_name}   connection=NETACT_VM
    ${operation_id}   Strip String   ${operation_id}
    Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM

    Wait Until Keyword Succeeds   2m   10s
    ...   swmCLI Check NetAct SWM Operation By Operation ID   operation_id=${operation_id}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM


swmCLI Check NetAct SWM Operation By Operation ID
    [Arguments]   ${operation_id}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    ${output}   csn.Execute   command=swmCLI.sh -op operation-status -id ${operation_id}   connection=NETACT_VM

    ${operation_list}   Split To Lines  ${output}

    ${operation_status}   Evaluate   [i for i in ${operation_list} if i.find("PLMN-PLMN/${dist_name},")!=-1]
    Run Keyword If   len(${operation_status})==0   Fail   msg=NetAct Operation Don't Exist.

    ${operation_status}   Get Variable Value   ${operation_status[0]}
    ${operation_status_list}   Split String   ${operation_status}   ,

    ${operation_status}   Evaluate   [i.strip() for i in ${operation_status_list}]
    ${MO_DN}   Set Variable   ${operation_status[0]}
    ${TASK_TYPE}   Set Variable   ${operation_status[1]}
    ${TASK_STATUS}   Set Variable   ${operation_status[2]}

    Should Contain Any   ${TASK_STATUS}   SUCCESS   TIMEOUT_SUCCESS


    [Teardown]   csn.Disconnect   connection=NETACT_VM


Backup And Delete NE3S File
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline_name}
    csn.Download File
    ...   remote_path=/ffs/run/config/safe/account/ws.json
    ...   local_path=${OUTPUT_DIR}/ws.json
    ...   connection=${testline_name}
    csn.Download File
    ...   remote_path=/ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
    ...   local_path=${OUTPUT_DIR}/ne3sadaptdata.db
    ...   connection=${testline_name}

    ${remote_dir}   Set Variable   /ffs/run/config/ne3sadapt/managers
    ${local_dir}   Set Variable   ${OUTPUT_DIR}/managers
    OperatingSystem.Create Directory   ${local_dir}

    ${output}   csn.Execute   command=ls /ffs/run/config/ne3sadapt/managers   connection=${testline_name}
    Log To Console   ${output}
    ${file_list}   Split String   ${output}   \r\n
    ${file_list}   Evaluate   [file.strip() for file in ${file_list} if file!=""]
    Log To Console   ${file_list}
    @{managers_file_list}   Create List
    FOR   ${file_name}   IN   @{file_list}
        &{managers_file_save}   Create Dictionary
        ${remote_path}   Set Variable   ${remote_dir}/${file_name}
        ${local_path}   Set Variable   ${local_dir}/${file_name}
        Set To Dictionary   ${managers_file_save}   remote_path=${remote_path}   local_path=${local_path}
        Append To List   ${managers_file_list}   ${managers_file_save}

        Run Keyword And Ignore Error   csn.Download File
        ...   remote_path=${remote_path}
        ...   local_path=${local_path}
        ...   connection=${testline_name}
    END

    Log To Console   ${managers_file_list}
    Set Suite Variable   ${MANAGERS_FILE_LIST}


    # csn.Execute   command=mount -o rw,remount /ffs/stb   connection=${testline_name}
    # csn.Execute   command=rm -rf /ffs/stb/config/safe/account/ws.json   connection=${testline_name}
    # csn.Execute   command=rm -rf /ffs/stb/config/ne3sadapt/configs/ne3sadaptdata.db   connection=${testline_name}
    # csn.Execute   command=rm -rf /ffs/stb/config/ne3sadapt/managers/*   connection=${testline_name}


    csn.Execute   command=rm -rf /ffs/run/config/safe/account/ws.json   connection=${testline_name}
    csn.Execute   command=rm -rf /ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db   connection=${testline_name}
    csn.Execute   command=rm -rf /ffs/run/config/ne3sadapt/managers/*   connection=${testline_name}

    [Teardown]   csn.Disconnect   connection=${testline_name}


Recover NE3S File
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline_name}
    csn.Upload File
    ...   remote_path=/ffs/run/config/safe/account/ws.json
    ...   local_path=${OUTPUT_DIR}/ws.json
    ...   connection=${testline_name}

    csn.Upload File
    ...   remote_path=/ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
    ...   local_path=${OUTPUT_DIR}/ne3sadaptdata.db
    ...   connection=${testline_name}

    FOR   ${managers_file}   IN   @{MANAGERS_FILE_LIST}
        ${remote_path}   Set Variable   ${managers_file["remote_path"]}
        ${local_path}   Set Variable   ${managers_file["local_path"]}
        Run Keyword And Ignore Error   csn.Upload File
        ...   remote_path=${remote_path}
        ...   local_path=${local_path}
        ...   connection=${testline_name}
    END

    [Teardown]   csn.Disconnect   connection=${testline_name}


COAM Reset Site
    coam.reset_site   connection=${testline_name}   wait_for_reconnection=${True}   timeout=${900}


COAM Check NMS Status
    ${output}   coam.get_nms_state   connection=${testline_name}
    ${oamTlsStatus}   Get Variable Value   ${output[0]["oamTlsStatus"]}
    ${uplinkToNMS}   Get Variable Value   ${output[0]["uplinkToNMS"]}
    ${downlinkFromNMS}   Get Variable Value   ${output[0]["downlinkFromNMS"]}
    # Should Not Be Equal   ${oamTlsStatus.lower()}   notapplicable
    # Should Not Be Equal   ${uplinkToNMS.lower()}   notapplicable
    # Should Contain   ${oamTlsStatus.lower()}   secured
    # Should Contain   ${uplinkToNMS.lower()}   secured
    # Should Not Contain   ${oamTlsStatus.lower()}   notconnected
    # Should Not Contain   ${uplinkToNMS.lower()}   notconnected


COAM Synchronize Passive Software Build
    coam.passive_synchronize   copy_to_passive=${0}   connection=${testline_name}   timeout=${900}

