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
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info

*** Variables ***
${testline_name}    UUF4ALL
${webem_addr}       192.168.255.129
${webem_username}   Nemuadmin
${webem_password}   nemuuser
${ssh_addr}         192.168.255.129
${ssh_username}     toor4nsn
${ssh_password}     oZPS0POrRieRtu

${package_path}
${package_version}

*** Test Cases ***
UUF Switch Build
    OperatingSystem.Create File   ${OUTPUT_DIR}/UUF_Switch_Build_Result   Start UUF Switch Build Process...\n

    Wait Until Keyword Succeeds   15m   30s   COAM Login
    Wait Until Keyword Succeeds   10m   1m   COAM Check Hardware Status
    Wait Until Keyword Succeeds   3x   5m   COAM SWM Update
    Wait Until Keyword Succeeds   10m   1m   COAM Check Hardware Status
    # Run Keyword And Ignore Error   COAM Logout

    Run Keyword And Ignore Error   Remove Passive Software Build
    # Run Keyword And Ignore Error   Reboot After Remove Passive Software Build
    # Sleep   2m
    # Wait Until Keyword Succeeds   15m   30s   COAM Login
    # Wait Until Keyword Succeeds   10m   1m   COAM Check Hardware Status

    [Teardown]   Common Teardown


*** Keywords ***
Common Teardown

    Run Keyword And Ignore Error   coam.collect_im_snapshot
    ...   target_file_name=${OUTPUT_DIR}/IMS2_UUF_Switch_Build_Result.ims2   timeout=${300}   connection=${testline_name}

    Run Keyword And Ignore Error   COAM Logout
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Switch_Build_Result   UUF_Switch_Build_Result_${TEST_STATUS}\n


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


COAM Reset Site
    coam.reset_site   connection=${testline_name}   wait_for_reconnection=${True}   timeout=${900}


COAM Check Hardware Status
    ${hw_info}   coam.get_detected_hw_info   connection=${testline_name}
    # @{bbmod_info_list}   Create List
    # FOR   ${bbmod_info}   IN   @{hw_info['basebandModules']}
    #    Append To List   ${bbmod_info_list}   ${bbmod_info['status']}
    # END
    # @{smod_info_list}   Create List
    FOR   ${smod_info}   IN   @{hw_info['systemModules']}
       # Append To List   ${smod_info_list}   ${smod_info['status']}
       Should Be Equal   ${smod_info['status']['operationalState'].lower()}   enabled
    END
    Sleep   1m


COAM SWM Update
    Log To Console   Start Software Updating...
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Switch_Build_Result   Start Software Updating...\n

    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${3600}   connection=${testline_name}
    Log To Console   Software Update Finished, Waiting For Resetting...
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Switch_Build_Result   Software Update Finished, Waiting For Resetting...\n

    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    # Sleep   3m
    Wait Until Keyword Succeeds   15m   30s   COAM Login

    # ${software_dict}   UUF Get Software Version   testline=${testline_name}
    # ${active_version}   Set Variable   ${software_dict['active_version']}
    # Should Be Equal   ${package_version}   ${active_version}

    Log To Console   Reset finished!
    Log To Console   COAM SWM Update Done!
    OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Switch_Build_Result   Reset finished!\n

    [Teardown]   OperatingSystem.Append To File   ${OUTPUT_DIR}/UUF_Switch_Build_Result   Start Software Updating Result: ${KEYWORD_STATUS}\n


Check Connection Status
    [Arguments]   ${ip_address}   ${status}=disconnect
    Log To Console   Check Connection Status: ${status}
    Run Keyword And Ignore Error   OperatingSystem.Run   sudo chmod +s /usr/bin/ping
    ${result}   OperatingSystem.Run   command=timeout 2s ping -c 1 ${ip_address} > /dev/null 2>&1; echo $?
    ${result}   Strip String   ${result}
    Run Keyword If   "${status}"=="disconnect"   Should Not Be True   "${result}"=="0"
    Run Keyword If   "${status}"=="connect"   Should Be True   "${result}"=="0"


# =========================================================================================================================================
UUF Get Software Version
    [Arguments]   ${testline}
    ${sw_info}   coam.get_software_info   connection=${testline}   timeout=${60}
    ${active}   Set Variable   ${sw_info['Active SW version']}
    ${passive}   Set Variable   ${sw_info['Passive SW version']}
    ${planned}   Set Variable   ${sw_info['Planned SW version']}

    ${active}   Set Variable If   "${active}"!="${None}" and "${active}"!=""   ${active}   None
    ${passive}   Set Variable If   "${passive}"!="${None}" and "${passive}"!=""   ${passive}   None
    ${planned}   Set Variable If   "${planned}"!="${None}" and "${planned}"!=""   ${planned}   None

    ${active_version}   ${active_release}   Run Keyword If   "${active}"!="${None}" and "${active}"!=""
    ...   Transfer Trunk Software Version   software_version=${active}
    ...   ELSE   Set Variable   None   None
    ${passive_version}   ${passive_release}   Run Keyword If   "${passive}"!="${None}" and "${passive}"!=""
    ...   Transfer Trunk Software Version   software_version=${passive}
    ...   ELSE   Set Variable   None   None
    ${planned_version}   ${planned_release}   Run Keyword If   "${planned}"!="${None}" and "${planned}"!=""
    ...   Transfer Trunk Software Version   software_version=${planned}
    ...   ELSE   Set Variable   None   None

    ${software_dict}   Create Dictionary
    ...   active_version=${active_version}
    ...   passive_version=${passive_version}
    ...   planned_version=${planned_version}
    ...   active_release=${active_release}
    ...   passive_release=${passive_release}
    ...   planned_release=${planned_release}

    [Return]   ${software_dict}

Transfer Trunk Software Version
    [Arguments]   ${software_version}
    ${list}   Split String   ${software_version}   _
    ${prefix}   Set Variable   ${list[0]}
    Return From Keyword If   "${prefix}"=="LN"   ${software_version}

    ${release}   Set Variable If
    ...   '${list[2]}'=='0000'   ${list[0]}
    ...   '${list[2]}'=='9999'   SBTS00
    ...   '${list[2]}'=='9990'   SBTS00
    ...   SBTS00

    ${new_software}   Replace String   ${software_version}   ${prefix}   ${release}
    [Return]   ${new_software}   ${prefix}


# =========================================================================================================================================
Remove Passive Software Build
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline_name}
    csn.Execute   command=mount -o rw,remount /ffs/stb   connection=${testline_name}
    csn.Execute   command=rm -rf /ffs/stb/*   connection=${testline_name}
    # csn.Execute   command=rm -rf /ffs/run/config/*   connection=${testline_name}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline_name}


Reboot After Remove Passive Software Build
    csn.Connect to   hostname=${ssh_addr}   username=${ssh_username}   password=${ssh_password}   alias=${testline_name}
    csn.Send Command   command=reboot   connection=${testline_name}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${testline_name}


Synchronize Passive Software Build
    Run Keyword And Ignore Error   coam.passive_synchronize   copy_to_passive=${0}   connection=${testline_name}   timeout=${900}

