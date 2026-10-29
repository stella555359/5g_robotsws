*** Settings ***
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

*** Test Cases ***
UUF Load SCF
    OperatingSystem.Create File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Start UUF Load SCF Process......\n

    # Run Keyword If   ${dual_core_flag}   Dual Core Start Sync Selenium

    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword If   ${dual_core_flag}   Dual Core Start Sync ADMIN
    Run Keyword If   ${dual_core_flag}   Dual Core SystemModules Detected

    COAM Load SCF

    Run Keyword And Ignore Error   Block or Recovery NetAct Connection By iptables   action=Block

    ${fault23}   Wait Until Keyword Succeeds   30m   3m   COAM RU Detected And Fault23 Appeared

    Wait Until Keyword Succeeds   3x   5m   Run Keyword If   ${fault23}   COAM SWM Update

    Run Keyword And Ignore Error   Block or Recovery NetAct Connection By iptables   action=Recovery

    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Start Check Cell Status...\n
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   20m   1m   COAM Check Cell Status

    [Teardown]   Common Teardown




*** Keywords ***
Common Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Block or Recovery NetAct Connection By iptables   action=Recovery
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
    ...   name=${testline_name}

COAM Logout
    coam.teardown   connection=${testline_name}


COAM Modify MORAN actIndSwUpgradeForSharedRU
    Return From Keyword If   not ${moran_flag}

    ${scf_content}   XML.Parse XML   ${scf_path}
    Set Elements Text   ${scf_content}   text=false
    ...   xpath=cmData/managedObject[@class="com.nokia.srbts.eqm:RMOD"]/p[@name="actIndSwUpgradeForSharedRU"]
    XML.Save Xml   source=${scf_content}   path=${scf_path}


COAM Load SCF
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Perform SCF Started...\n
    Run Keyword If   ${moran_flag}   COAM Modify MORAN actIndSwUpgradeForSharedRU
    coam.perform_commissioning
    ...   scf_file=${scf_path}
    ...   skip_parameter_relation_errors=${True}
    ...   should_activate=${True}
    ...   timeout=${600}
    ...   connection=${testline_name}
    Run Keyword And Ignore Error   COAM Logout
    Sleep   1m
    Wait Until Keyword Succeeds   20m   1m   COAM Login
    [Teardown]   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Perform SCF Result: ${KEYWORD_STATUS}\n


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



COAM Check Cell Status
    ${bts_info}   coam.get_bts_info   connection=${testline_name}   timeout=${60}
    ${cell_info}   Run Keyword If   'requestMessage' in @{bts_info.keys()}
    ...   Set Variable   ${bts_info['requestMessage']['cells']}
    ...   ELSE   Set Variable   ${bts_info['cells']}
    ${cell_list}   Get Dictionary Values   ${cell_info}
    ${cell_list}   Evaluate   [item for sublist in ${cell_list} for item in sublist]

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
    ${neighbor_dn}   coam.get_managed_objects   class_name=NEIGHBOR_NODE_R   timeout=${60}   connection=${testline_name}
    ${sync_status}   Run Keyword And Return Status   coam.start_sync   dist_name=${neighbor_dn[0]['distName']}   connection=${testline_name}
    Run Keyword If   not ${sync_status}   Fail   msg=COAM Dual Core Start Sync Failed!
    Sleep   10s
    Log To Console   COAM Dual Core Start Sync Succeeded!
    [Teardown]   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Load_SCF_Result   Dual Core Env Start Sync Result: ${KEYWORD_STATUS}\n


Dual Core SystemModules Detected
    ${hw_info}   coam.get_detected_hw_info   connection=${testline_name}   timeout=${300}
    ${smod_number}   Get Length   ${hw_info["systemModules"]}
    Should Be True   ${smod_number} >= 2


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

