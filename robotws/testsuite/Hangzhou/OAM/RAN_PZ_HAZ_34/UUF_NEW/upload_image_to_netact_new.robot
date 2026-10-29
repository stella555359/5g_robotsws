*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    ./Resource/Common.robot

*** Variables ***
${netact_nodeip}
${version}


${package_folder}   /home/ute/Downloads
${remote_package_folder}   /d/oss/global/swmanager/swm_temp


*** Test Cases ***
Upload Image to NetAct
    # Log To Console   //TODO: Upload Image to NetAct
    # Upload Package To NetAct Backend

    # Log To Console   Wait Package Exist On NetAct WEB Page.
    # Sleep   5m
    # Wait Until Keyword Succeeds   15m   1m   Check Package Exist On NetAct WEBEM

    # [Teardown]   Run Keyword And Ignore Error   Clear Package On NetAct Backend
    ${package_version}   Get Variable Value   ${version}   ${EMPTY}
    ${vm_ip}   Get Variable Value   ${netact_nodeip}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["ssh_password"]}   ${EMPTY}
    ${connection}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["name"]}   NetAct
    ${alias}   Get Variable Value   ${netact_nodeip}   nms

    Run Keyword If   "${vm_ip}"=="${EMPTY}" or "${package_version}"=="${EMPTY}"   Fatal Error

    nms.add_node   service_name=cmwas   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}

    # ${isImported}   nms.is_imported   version_id=${package_version}   mo_type=MRBTS   alias=${alias}
    ${imported_builds}   nms.get_list_of_imported_builds   mo_type=MRBTS   alias=${alias}
    Log To Console   Imported builds: ${imported_builds}
    ${isImported}   Is Package Already imported   ${imported_builds}   ${package_version}
    Run Keyword If   ${isImported}   Log To Console   Software Build ${package_version} Already Exist. Skip Upload Package.
    Pass Execution If   ${isImported}   Software Build ${package_version} Already Exist. Exit Upload Package.


    ${status}   ${remote_package_path}   Run Keyword And Ignore Error   Download Classical Common Package In Remote Server
    ...   hostname=${vm_ip}   username=${service_user}   password=${service_password}   connection=${connection}
    ...   package_version=${package_version}   remote_package_folder=${remote_package_folder}
    Log To Console   Download Classical Common Package In NetAct Remote Server Status: ${status}

    ${remote_package_path}   Run Keyword If   "${status}"=="FAIL"   Download Classical Common Package Local And Upload To Remote Server
    ...   hostname=${vm_ip}   username=${service_user}   password=${service_password}   connection=${connection}
    ...   package_version=${package_version}   package_folder=${package_folder}   remote_package_folder=${remote_package_folder}
    ...   ELSE   Set Variable   ${remote_package_path}

    Log To Console   ${remote_package_path}

    ${release_status}   ${package_release}   Run Keyword And Ignore Error   Get Release From Packge TargetBD Remote
    ...   remote_package_path=${remote_package_path}
    ...   hostname=${vm_ip}   username=${service_user}   password=${service_password}
    ...   connection=${connection}

    nms.import_build   build_or_file_path=${package_version}.zip   mo_type=MRBTS   alias=${alias}   clean_temp_storage=${True}
    ${imported_builds}   nms.get_list_of_imported_builds   mo_type=MRBTS   alias=${alias}
    Log To Console   Imported builds: ${imported_builds}

    Run Keyword If   "${release_status}"=="FAIL"   Fail   Get build release status failed
    ${package_version}   Replace String   ${package_version}   SBTS00   ${package_release}
    ${isImported}   nms.is_imported   version_id=${package_version}   mo_type=MRBTS   alias=${alias}
    Log To Console   isImported: ${isImported}

    [Teardown]   Run Keyword And Ignore Error   nms.clean_all   alias=${alias}


*** Keywords ***
Is Package Already imported
    [Arguments]   ${builds}   ${package_version}
    ${version_pre}   Evaluate   '${package_version}'.split('_')[0]
    ${version_no_trunk_pre}    Replace String   ${package_version}   SBTS00_   ${EMPTY}
    ${result_no_trunk_pre}   Evaluate    any('${version_no_trunk_pre}' in item for item in ${builds})
    ${result}   Evaluate    any('${package_version}' in item for item in ${builds})
    ${result}   Set Variable If   "${version_pre}"=="SBTS00" and ${result_no_trunk_pre}==${True} and ${result}==${False}   ${True}
    [Return]   ${result}

# Upload Package To NetAct Backend
#     ${vm_ip}   Get Variable Value   ${netact_nodeip}   ${EMPTY}
#     ${package_version}   Get Variable Value   ${version}   ${EMPTY}
#     ${service_user}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["ssh_username"]}   ${EMPTY}
#     ${service_password}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["ssh_password"]}   ${EMPTY}
#     ${connection}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["name"]}   NetAct
#     Run Keyword If   "${vm_ip}"=="${EMPTY}" or "${package_version}"=="${EMPTY}"   Fatal Error


#     ${status}   ${remote_package_path}   Run Keyword And Ignore Error   Download Classical Common Package In Remote Server
#     ...   hostname=${vm_ip}   username=${service_user}   password=${service_password}   connection=${connection}
#     ...   package_version=${package_version}   remote_package_folder=${remote_package_folder}
#     Log To Console   Download Classical Common Package In NetAct Remote Server Status: ${status}

#     ${remote_package_path}   Run Keyword If   "${status}"=="FAIL"   Download Classical Common Package Local And Upload To Remote Server
#     ...   hostname=${vm_ip}   username=${service_user}   password=${service_password}   connection=${connection}
#     ...   package_version=${package_version}   package_folder=${package_folder}   remote_package_folder=${remote_package_folder}
#     ...   ELSE   Set Variable   ${remote_package_path}

#     Log To Console   ${remote_package_path}

#     csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${connection}
#     csn.Execute   command=cd /d/oss/global/swmanager/swm_temp/;chmod 777 ${package_version}.zip   timeout=${60}   connection=${connection}
#     ${output}   csn.Execute   command=cd /d/oss/global/swmanager/swm_temp/;swmCLI.sh import --file ${package_version}.zip --mo-type MRBTS
#     ...   timeout=${1200}   connection=${connection}
#     Should Not Contain   ${output}   fail

#     # Wait Until Keyword Succeeds   10m   1m   Check Package on NetAct Backend   connection=${connection}
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


# # Check Package on NetAct Backend
# #     [Arguments]   ${connection}
# #     ${output}   csn.Execute    command=cd /var/opt/nokia/oss/global/swm/swm_arch;ls -al | grep ${package_version}
# #     ...   timeout=${60}   connection=${connection}
# #     Should Contain   ${output}   ${package_version}


# Clear Package On NetAct Backend
#     ${vm_ip}   Get Variable Value   ${netact_nodeip}   ${EMPTY}
#     ${package_version}   Get Variable Value   ${version}   ${EMPTY}
#     ${service_user}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["ssh_username"]}   ${EMPTY}
#     ${service_password}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["ssh_password"]}   ${EMPTY}
#     ${connection}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["name"]}   NetAct
#     Run Keyword If   "${vm_ip}"=="${EMPTY}" or "${package_version}"=="${EMPTY}"   Fatal Error

#     Log To Console   Clear Package ${package_version}.zip On NetAct Backend.
#     csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${connection}
#     csn.Execute   command=cd /d/oss/global/swmanager/swm_temp/;rm -rf ${package_version}.zip   connection=${connection}
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


# Check Package Exist On NetAct WEBEM
#     selenium_netact.enable_virtual_display

#     # Open NetAct Start Page
#     # Open Netact Start Page   url=${url}   username=${username}   password=${password}   showall=${false}
#     ${url}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["url"]}   ${EMPTY}
#     ${http_username}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["http_username"]}   ${EMPTY}
#     ${http_password}   Get Variable Value   ${netact_global_configuration["${netact_nodeip}"]["http_password"]}   ${EMPTY}

#     Return From Keyword If   "${netact_nodeip}"=="" or "${netact_nodeip}"=="${None}"

#     Run Keyword And Ignore Error
#     ...   selenium_netact.Set Download Dir   ${OUTPUT_DIR}
#     Wait Until Keyword Succeeds   3x   30s
#     ...   selenium_netact.Login   url=${url}   username=${http_username}   password=${http_password}
#     Sleep   2s

#     # Open Software Manager
#     Run Keyword And Ignore Error
#     ...   selenium_netact.wait_for_visibility   elem_xpath=//a[contains(@folder, 'configuration')]
#     selenium_netact.open_configuration_software_manager
#     selenium_netact.switch_to_page   page_name=Software Manager

#     # Click Software Archive
#     Wait Until Keyword Succeeds   3 times   10s   Run Keywords   selenium_netact.Click Button   //span[text()='Software Archive']
#     ...   AND   selenium_netact.wait_for_enable   elem_xpath=//input[@id='embTreeFrm:cccomboboxField']   timeout=600
#     Sleep   2s
#     selenium_netact.write_value_and_enter   //input[@id='embTreeFrm:cccomboboxField']   MRBTS
#     Wait Until Keyword Succeeds   3 times   10s   selenium_netact.wait_for_visibility
#     ...   elem_xpath=//*[@id='embTreeFrm:swTree:#REGULAR__PACKAGES#::remoteRepositoryTreeNode:mainRow']
#     Sleep   2s

#     #Expand ALL
#     selenium_netact.wait_for_visibility   elem_xpath=//input[@id='embTreeFrm:swTreeExpandAllButton']
#     selenium_netact.click_button   button_xpath=//input[@id='embTreeFrm:swTreeExpandAllButton']
#     Sleep   2s

#     # selenium_netact.wait_for_visibility   elem_xpath=//span[@id="embTreeFrm:pgdSwTree"]//label[contains(text(), "${version}")]
#     ${version_text}   selenium_netact.get_elem_text   elem_xpath=//span[@id="embTreeFrm:pgdSwTree"]//label[contains(text(), "${version}")]
#     Should Not Be Empty   ${version_text}

#     [Teardown]   Run Keywords
#     ...   Run Keyword And Ignore Error   Catch netact Screenshot by xpath   xpath=//body
#     ...   AND   Run Keyword And Ignore Error   selenium_netact.logout
#     ...   AND   Run Keyword And Ignore Error   selenium_netact.disable_virtual_display
