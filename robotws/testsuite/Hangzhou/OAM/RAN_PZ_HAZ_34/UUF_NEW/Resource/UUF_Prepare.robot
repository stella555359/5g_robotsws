*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
UUF Prepare Load Build
    Log To Console   //TODO: UUF Prepare Load Build

    # UPGRADE_BUILD_INFO_DICT = {
    #     enb: {
    #         source: {
    #             path:
    #             version:
    #             release:
    #         },
    #         target: {
    #             path:
    #             version:
    #             release:
    #         }
    #     },
    #     gnb: {
    #         source: {
    #             path:
    #             version:
    #             release:
    #         },
    #         target: {
    #             path:
    #             version:
    #             release:
    #         }
    #     }
    # }
    # Check gnb target build exist in NetAct
    #     ->  only check when upgrade by NetAct

    #############################################

    ${gnb_target_version}   Get Variable Value   ${upgrade_version}   ${EMPTY}
    ${gnb_target_version_not_empty}   Evaluate
    ...   "${gnb_target_version}"!="${EMPTY}" and "${gnb_target_version}"!="${None}" and "${gnb_target_version}"!="no"
    ${gnb_target_path}   Run Keyword If   ${gnb_target_version_not_empty}
    ...   Download Classical Common Package   package_version=${gnb_target_version}
    ...   ELSE   Set Variable   ${EMPTY}
    ${gnb_target_release}   Run Keyword If   ${gnb_target_version_not_empty}
    ...   Get Release From Packge TargetBD   package_path=${gnb_target_path}
    ...   ELSE   Set Variable   ${EMPTY}
    ${gnb_target}   Create Dictionary   version=${gnb_target_version}   path=${gnb_target_path}   release=${gnb_target_release}


    ${gnb_testpackage_version}   Set Variable If   ${gnb_target_version_not_empty}   ${gnb_target_version}T1   ${EMPTY}
    ${gnb_testpackage_version_not_empty}   Evaluate
    ...   "${gnb_testpackage_version}"!="${EMPTY}" and "${gnb_testpackage_version}"!="${None}" and "${gnb_testpackage_version}"!="no"
    ${gnb_testpackage_path}   Run Keyword If   ${gnb_testpackage_version_not_empty} and "${UUF_FUNCTION}" == "reset"
    ...   Download Classical Common Package   package_version=${gnb_testpackage_version}   test_package=T1
    ...   ELSE   Set Variable   ${EMPTY}
    ${gnb_testpackage_release}   Run Keyword If   ${gnb_testpackage_version_not_empty} and "${UUF_FUNCTION}" == "reset"
    ...   Get Release From Packge TargetBD   package_path=${gnb_testpackage_path}
    ...   ELSE   Set Variable   ${EMPTY}
    ${gnb_testpackage}   Create Dictionary   version=${gnb_testpackage_version}   path=${gnb_testpackage_path}   release=${gnb_testpackage_release}



    ${enb_target_version}   Get Variable Value   ${enb_target_version}   ${EMPTY}
    ${enb_target_version_not_empty}   Evaluate
    ...   "${enb_target_version}"!="${EMPTY}" and "${enb_target_version}"!="${None}" and "${enb_target_version}"!="no"

    ${enb_target_path}   Run Keyword If   ${enb_target_version_not_empty}
    ...   Download Classical Common Package   package_version=${enb_target_version}
    ...   ELSE   Set Variable   ${EMPTY}
    ${enb_target_release}   Run Keyword If   ${enb_target_version_not_empty}
    ...   Get Release From Packge TargetBD   package_path=${enb_target_path}
    ...   ELSE   Set Variable   ${EMPTY}
    ${enb_target}   Create Dictionary   version=${enb_target_version}   path=${enb_target_path}   release=${enb_target_release}


    ${enb_testpackage_version}   Set Variable If   ${enb_target_version_not_empty}   ${enb_target_version}T1   ${EMPTY}
    ${enb_testpackage_version_not_empty}   Evaluate
    ...   "${enb_testpackage_version}"!="${EMPTY}" and "${enb_testpackage_version}"!="${None}" and "${enb_testpackage_version}"!="no"
    ${enb_testpackage_path}   Run Keyword If   ${enb_testpackage_version_not_empty} and "${UUF_FUNCTION}" == "reset"
    ...   Download Classical Common Package   package_version=${enb_testpackage_version}   test_package=T1
    ...   ELSE   Set Variable   ${EMPTY}
    ${enb_testpackage_release}   Run Keyword If   ${enb_testpackage_version_not_empty} and "${UUF_FUNCTION}" == "reset"
    ...   Get Release From Packge TargetBD   package_path=${enb_testpackage_path}
    ...   ELSE   Set Variable   ${EMPTY}
    ${enb_testpackage}   Create Dictionary   version=${enb_testpackage_version}   path=${enb_testpackage_path}   release=${enb_testpackage_release}


    ${origin_version}   Get Variable Value   ${origin_version}   ${EMPTY}
    ${gnb_source}   Run Keyword If
    ...   "${origin_version}"!="${EMPTY}" and "${origin_version}"!="${None}" and "${origin_version}"!="no"
    ...   Create Dictionary   version=${origin_version}
    ...   ELSE   Create Dictionary   version=${EMPTY}

    ${enb_source_version}   Get Variable Value   ${enb_source_version}   ${EMPTY}
    ${enb_source}   Run Keyword If
    ...   "${enb_source_version}"!="${EMPTY}" and "${enb_source_version}"!="${None}" and "${enb_source_version}"!="no"
    ...   Create Dictionary   version=${enb_source_version}
    ...   ELSE   Create Dictionary   version=${EMPTY}


    ${upgrade_build_info_str}   Catenate   SEPARATOR=
    ...   {
    ...       "gnb": {
    ...           "source": ${gnb_source},
    ...           "target": ${gnb_target},
    ...           "testpackage": ${gnb_testpackage},
    ...       },
    ...       "enb": {
    ...           "source": ${enb_source},
    ...           "target": ${enb_target},
    ...           "testpackage": ${enb_testpackage},
    ...       },
    ...   }


    ${UPGRADE_BUILD_INFO_DICT}   Evaluate   ${upgrade_build_info_str}
    Set Suite Variable   ${UPGRADE_BUILD_INFO_DICT}
    Log To Console   UPGRADE_BUILD_INFO_DICT: ${UPGRADE_BUILD_INFO_DICT}


Get Release From Packge TargetBD
    [Arguments]   ${package_path}
    ${output}   OperatingSystem.Run   command=unzip -l ${package_path} | grep -i TargetBD | awk '{print $4}'
    ${output}   Strip String   ${output}
    ${list}   Split String   ${output}   _
    Should Contain   ${list[2]}   SBTS
    [Return]   ${list[2]}

Get Release From Packge TargetBD Remote
    [Arguments]   ${remote_package_path}   ${hostname}   ${username}   ${password}   ${connection}
    csn.Connect To   hostname=${hostname}   username=${username}   password=${password}   alias=${connection}
    ${output}   csn.Execute   command=unzip -l ${remote_package_path} | grep -i TargetBD | awk '{print $4}'   connection=${connection}
    ${output}   Strip String   ${output}
    ${list}   Split String   ${output}   _
    Should Contain   ${list[2]}   SBTS
    [Return]   ${list[2]}
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${connection}


UUF Switch To Specified Load Build
    [Arguments]   ${upgrade_sequence}=${UPGRADE_SEQUENCE}   ${package_type}=source
    FOR   ${testline}   IN   @{upgrade_sequence}
        Run Keyword And Ignore Error
        ...   Single Testline Switch To Specified Load Build   testline=${testline}   package_type=${package_type}
    END

    ${UUF_FUNCTION}   Get Variable Value   ${UUF_FUNCTION}   reset
    Run Keyword And Ignore Error   Run Keyword If   not ${DEBUG}   Run Keyword If
    ...   "${TESTLINE_IDENTITY}" in ${DOWNGRADE_FIRMWARE_TL} and "${UUF_FUNCTION}"!="reset" and ("${TEST_MODE}"=="UUF" or "${TEST_MODE}"=="PR")
    ...   UUF Downgrade Firmware   downgrade_sequence=${upgrade_sequence}

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   UUF Check Testlines Status   wait_gps=${True}
    ...   AND
    ...   UUF Recovery Action
    ...   AND
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="PASS" and "${package_type}"=="source"   UUF Remove Specified Load Build


UUF Remove Specified Load Build
    Log To Console   DOWNLOAD_PACKAGE_VM_LIST: ${DOWNLOAD_PACKAGE_VM_LIST}

    Return From Keyword If   ${DEBUG}

    FOR   ${vm_detail}   IN   @{DOWNLOAD_PACKAGE_VM_LIST}
        ${hostname}   Set Variable   ${vm_detail['test_pc_addr']}
        ${username}   Set Variable   ${vm_detail['test_pc_username']}
        ${password}   Set Variable   ${vm_detail['test_pc_password']}
        ${version_path}   Set Variable   ${vm_detail['package_path']}
        ${connection}   Set Variable   ${vm_detail['connection']}

        Run Keyword If   "${hostname}"=="localhost"
        ...      Delete Classical Common Package   version_path=${version_path}
        ...   ELSE
        ...      Delete Classical Common Package In Remote Server
        ...         version_path=${version_path}   hostname=${hostname}   username=${username}   password=${password}   connection=${connection}
    END


Single Testline Switch To Specified Load Build
    [Arguments]   ${testline}   ${package_type}

    @{testline_list}   Create List   ${testline}

    ${upgrade_type}   Check Testline Upgrade Type And Prepare Package   testline=${testline}   package_type=${package_type}

    # Run Keyword If   "${package_type}"=="source" and "${upgrade_type}"!="enb_source_empty"
    # ...   Check Single Testlie SCF Exit    testline=${testline}   package_type=${package_type}

    Log to Console   Switch ${testline} To ${package_type} By ${upgrade_type}
    Run Keyword If   "${upgrade_type}"=="direct_upgrade"
    ...   Single Testline Upgrade Direct   testline=${testline}   package_type=${package_type}
    ...   ELSE IF   "${upgrade_type}"=="rollback_upgrade"
    ...   Single Testline Upgrade Rollback   testline=${testline}   package_type=${package_type}
    ...   ELSE IF   "${upgrade_type}"=="delete_config_upgrade"
    ...   Single Testline Upgrade Delete Config   testline=${testline}   package_type=${package_type}
    ...   ELSE IF   "${upgrade_type}"=="fdsw_upgrade"
    ...   Single Testline Upgrade FDSW   testline=${testline}   package_type=${package_type}
    ...   ELSE IF   "${upgrade_type}"=="tmo_decoupling"
    ...   Log To Console   TMO Decoupling Skip Upgrade!
    ...   ELSE IF   "${upgrade_type}"=="enb_source_empty"
    ...   Log To Console   ENB Source Version Empty Skip Upgrade!

    Run Keyword If   "${upgrade_type}"!="tmo_decoupling" and "${upgrade_type}"!="enb_source_empty"
    ...   Log to Console   Switch ${testline} To ${package_type} Finished!\n

    [Teardown]   Run Keyword And Ignore Error   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"
    ...   UUF Catch Snapshot   testline_list=${testline_list}   log_dir=${OUTPUT_DIR}/${SUITE_NAME}
    ...   prefix=FAIL_Switch_Build


Check Testline Upgrade Type And Prepare Package
    [Arguments]   ${testline}   ${package_type}

    ${testline_type}   ${testline_index}   Set Variable   @{testline.split('_')}
    ${enb_source_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['source']['version']}   ${EMPTY}
    Return From Keyword If
    ...   "${testline_type}"=="enb" and "${package_type}"=="source" and "${enb_source_version}"=="${EMPTY}"
    ...   enb_source_empty

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}


    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Set Variable   ${software_dict['active_version']}
    ${active_release}   Set Variable   ${software_dict['active_release']}
    ${passive_version}   Set Variable   ${software_dict['passive_version']}
    ${passive_release}   Set Variable   ${software_dict['passive_release']}


    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}

    Run Keyword If   "${active_version}"=="${package_version}"
    ...   Set To Dictionary   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']}   release=${active_release}

    Run Keyword If   "${passive_version}"=="${package_version}"
    ...   Set To Dictionary   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']}   release=${passive_release}

    # Chek TMO DECOUPLING
    ${enb_target_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['target']['version']}   ${EMPTY}
    ${enb_source_version}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['source']['version']}   ${EMPTY}
    ${TMO_DECOUPLING_PREPARE}   Catenate
    ...   "${testline_type}"=="enb"
    ...   and ${TMO_DECOUPLING}
    ...   and "${active_version}"=="${enb_target_version}"
    ...   and "${passive_version}"=="${enb_source_version}"
    Return From Keyword If   ${TMO_DECOUPLING_PREPARE}   tmo_decoupling


    Return From Keyword If   "${active_version}"=="${package_version}"   direct_upgrade
    Return From Keyword If   "${passive_version}"=="${package_version}"   rollback_upgrade


    ${package_path}   Download Classical Common Package   package_version=${package_version}
    ${package_release}   Get Release From Packge TargetBD   package_path=${package_path}
    Set To Dictionary   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']}   path=${package_path}   release=${package_release}
    Log To Console   UPGRADE_BUILD_INFO_DICT: ${UPGRADE_BUILD_INFO_DICT}

    ${gnb_target_path}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['gnb']['target']['path']}   ${EMPTY}
    ${enb_target_path}   Get Variable Value   ${UPGRADE_BUILD_INFO_DICT['enb']['target']['path']}   ${EMPTY}
    ${is_source_not_equal_with_target}   Set Variable If   "${package_path}"!="${gnb_target_path}" and "${package_path}"!="${enb_target_path}"
    ...   ${True}   ${False}
    ${vm_detail}   Create Dictionary
    ...   test_pc_addr=localhost
    ...   test_pc_username=None
    ...   test_pc_password=None
    ...   package_path=${package_path}
    ...   connection=None
    Run Keyword If   ${is_source_not_equal_with_target}   Append To List   ${DOWNLOAD_PACKAGE_VM_LIST}   ${vm_detail}
    Run Keyword If   ${is_source_not_equal_with_target}   Set Suite Variable   ${DOWNLOAD_PACKAGE_VM_LIST}

    Return From Keyword If   "${active_release}"<="${package_release}"   direct_upgrade
    Return From Keyword If   "${passive_release}"<="${package_release}"   rollback_upgrade

    ${upgrade_type}   Set Variable If
    ...   "${testline_type}"=="gnb"   delete_config_upgrade
    ...   "${testline_type}"=="enb"   delete_config_upgrade
    Return From Keyword If   "${active_release}">"${package_release}" and "${passive_release}">"${package_release}"   ${upgrade_type}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Single Testline Upgrade Direct
    [Arguments]   ${testline}   ${package_type}
    Log To Console   Start To Single Testline Upgrade Direct

    Return From Keyword If   ${DEBUG}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}

    ${common_units}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${lmp_addr}   Get Variable Value   ${common_units[0]['lmp_addr']}
    ${test_pc_addr}   Get Variable Value   ${common_units[0]['test_pc_addr']}
    ${test_pc_username}   Get Variable Value   ${common_units[0]['test_pc_username']}
    ${test_pc_password}   Get Variable Value   ${common_units[0]['test_pc_password']}

    ${lmp_login}   Run Keyword If   "${test_pc_addr}"=="${None}" or "${test_pc_addr}"==""   Set Variable   ${False}
    ...   ELSE
    ...   Run Keyword And Return Status
    ...   COAM Remote Login   bts_host=${lmp_addr}   username=${webem_username}   password=${webem_password}
    ...   remote_host=${test_pc_addr}   remote_host_username=${test_pc_username}   remote_host_password=${test_pc_password}
    ...   connection=${testline}

    Run Keyword If   not ${lmp_login}   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}

    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Set Variable   ${software_dict['active_version']}
    ${active_release}   Set Variable   ${software_dict['active_release']}
    Return From Keyword If   "${active_version}"=="${package_version}"

    Run Keyword And Ignore Error   UUF Disable Validation On Upgrade   testline=${testline}

    Log To Console   Start Software Update...
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['path']}
    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${5400}   connection=${testline}

    Run Keyword If   not ${lmp_login}   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Run Keyword And Ignore Error   COAM Remote Logout   connection=${testline}

    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    Log To Console   Software Update Finished. Waiting For Reconnection...

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Log To Console   Reconnected.
    # # UUF Wait Times For Cell OnAir   testline=${testline}

    ${release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['release']}
    # Run Keyword If   "${active_release}"=="${release}"   UUF Wait Times For Cell OnAir   testline=${testline}
    # Return From Keyword If   "${active_release}"=="${release}"

    Log To Console   Waiting For SCF Commission.
    ${scf_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/SCF_${release}_${testline}.xml
    Wait Until Keyword Succeeds   20m   1m   COAM SCF Commission   filepath=${scf_path}   connection=${testline}
    Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    Log To Console   SCF Commission Finished. Waiting For Reconnection...

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Log To Console   Reconnected.
    UUF Wait Times For Cell OnAir   testline=${testline}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Single Testline Upgrade Rollback
    [Arguments]   ${testline}   ${package_type}
    Log To Console   Start To Single Testline Upgrade Rollback

    Return From Keyword If   ${DEBUG}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    ${ssh_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['ssh_addr']}

    ${common_units}   Get Variable Value   ${ALL_CONFIG_INIT['${testline}']['common_units']}
    ${lmp_addr}   Get Variable Value   ${common_units[0]['lmp_addr']}
    ${test_pc_addr}   Get Variable Value   ${common_units[0]['test_pc_addr']}
    ${test_pc_username}   Get Variable Value   ${common_units[0]['test_pc_username']}
    ${test_pc_password}   Get Variable Value   ${common_units[0]['test_pc_password']}

    COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Log To Console   Start Software Rollback...
    coam.rollback_software   connection=${testline}   timeout=${600}
    Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    Log To Console   Software Rollback Finished. Waiting For Reconnection...

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Log To Console   Reconnected.

    UUF Wait Times For Cell OnAir   testline=${testline}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}
    ${software_dict}   UUF Get Software Version   testline=${testline}
    ${active_version}   Set Variable   ${software_dict['active_version']}
    ${active_release}   Set Variable   ${software_dict['active_release']}
    Return From Keyword If   "${active_version}"=="${package_version}"

    Run Keyword And Ignore Error   COAM Logout   connection=${testline}

    ${lmp_login}   Run Keyword If   "${test_pc_addr}"=="${None}" or "${test_pc_addr}"==""   Set Variable   ${False}
    ...   ELSE
    ...   Run Keyword And Return Status
    ...   COAM Remote Login   bts_host=${lmp_addr}   username=${webem_username}   password=${webem_password}
    ...   remote_host=${test_pc_addr}   remote_host_username=${test_pc_username}   remote_host_password=${test_pc_password}
    ...   connection=${testline}

    Run Keyword If   not ${lmp_login}   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    Run Keyword And Ignore Error   UUF Disable Validation On Upgrade   testline=${testline}

    Log To Console   Start Software Upgrade...
    ${package_path}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['path']}
    coam.update_software   sw_package=${package_path}   should_activate=${True}   timeout=${5400}   connection=${testline}

    Run Keyword If   not ${lmp_login}   Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Run Keyword And Ignore Error   COAM Remote Logout   connection=${testline}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    Log To Console   Software Update Finished. Waiting For Reconnection...

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Log To Console   Reconnected.

    # #    UUF Wait Times For Cell OnAir   testline=${testline}
    ${release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['release']}
    # Run Keyword If   "${active_release}"=="${release}"   UUF Wait Times For Cell OnAir   testline=${testline}
    # Return From Keyword If   "${active_release}"=="${release}"

    Log To Console   Waiting For SCF Commission.
    ${scf_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/SCF_${release}_${testline}.xml
    Wait Until Keyword Succeeds   20m   1m   COAM SCF Commission   filepath=${scf_path}   connection=${testline}
    Run Keyword And Ignore Error   COAM Logout   connection=${testline}
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1m   10s   Check Connection Status   ip_address=${ssh_addr}   status=disconnect
    Log To Console   SCF Commission Finished. Waiting For Reconnection...

    Wait Until Keyword Succeeds   20m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}
    Log To Console   Reconnected.

    UUF Wait Times For Cell OnAir   testline=${testline}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Single Testline Upgrade Delete Config
    [Arguments]   ${testline}   ${package_type}
    Log To Console   Start To Single Testline Upgrade Delete Config

    Return From Keyword If   ${DEBUG}

    ${common_units}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['common_units']}

    FOR   ${common_unit}   IN   @{common_units}
        ${common_unit_index}   Set Variable   ${common_unit['index']}
        ${test_pc_addr}   Set Variable   ${common_unit['test_pc_addr']}
        ${test_pc_username}   Set Variable   ${common_unit['test_pc_username']}
        ${test_pc_password}   Set Variable   ${common_unit['test_pc_password']}

        ${testline_type}   ${testline_index}   Split String   ${testline}   _
        ${package_version}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['version']}

        ${package_path}   Download Classical Common Package In Remote Server
        ...   package_version=${package_version}
        ...   hostname=${test_pc_addr}
        ...   username=${test_pc_username}
        ...   password=${test_pc_password}
        ...   connection=test_pc_${testline}_unit_${common_unit_index}
        Set To Dictionary   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']}   path=${package_path}

        ${vm_detail}   Create Dictionary
        ...   test_pc_addr=${test_pc_addr}
        ...   test_pc_username=${test_pc_username}
        ...   test_pc_password=${test_pc_password}
        ...   package_path=${package_path}
        ...   connection=test_pc_${testline}_unit_${common_unit_index}
        Append To List   ${Download_Package_VM_List}   ${vm_detail}
        Set Suite Variable   ${Download_Package_VM_List}

    END

    Single Testline Install TAF   testline=${testline}

    Start Process Async UUF Switch Build   testline=${testline}   package_type=${package_type}

    ${webem_addr}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_addr']}
    ${webem_username}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_username']}
    ${webem_password}   Set Variable   ${ALL_CONFIG_INIT['${testline}']['webem_password']}
    Wait Until Keyword Succeeds   5m   1m
    ...   COAM Login
    ...   bts_host=${webem_addr}
    ...   username=${webem_username}
    ...   password=${webem_password}
    ...   alias=${testline}

    # UUF NetAct Integration
    # Run Keyword And Ignore Error   Wait Until Keyword Succeeds   3x   10s
    # ...   UUF NetAct Integration   testline=${testline}
    # # Sync Passive
    # Run Keyword And Ignore Error   COAM Software Passive synchronize   testline=${testline}

    UUF Wait Times For Cell OnAir   testline=${testline}

    [Teardown]   Run Keyword And Ignore Error   COAM Logout   connection=${testline}


Single Testline Upgrade FDSW
    [Arguments]   ${testline}   ${package_type}
    Log To Console   //TODO: Single Testline Upgrade FDSW
    Log To Console   ${testline}
    Log To Console   ${package_type}


Check Single Testlie SCF Exit
    [Arguments]   ${testline}   ${package_type}
    Return From Keyword If   ${DEBUG}

    ${testline_type}   ${testline_index}   Split String   ${testline}   _
    ${package_release}   Set Variable   ${UPGRADE_BUILD_INFO_DICT['${testline_type}']['${package_type}']['release']}
    ${scf_path}   Set Variable   ${GOLDEN_SCF_DIR}/TL${TESTLINE_IDENTITY}/SCF_${package_release}_${testline}.xml

    Log to Console   Start To Check ${testline} ${package_release} scf if exist in golden scf.
    ${scf_path_exist}     Run Keyword And Return Status    File Should Exist    ${scf_path}
    Run Keyword If   not ${scf_path_exist}    Fatal Error   msg=SCF_${package_release}_${testline}.xml not exist!


UUF Disable Validation On Upgrade
    [Documentation]   Disable actValidationOnUpgrade parameter to allow downgrade within same release
    ...   Parameter location: MRBTS-{mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    [Arguments]   ${testline}

    Log To Console   Disabling actValidationOnUpgrade: ${testline}

    ${FEATCADM_DN}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["FEATCADM_DN"]}   ${EMPTY}
    Return From Keyword If   "${FEATCADM_DN}"=="${EMPTY}"

    ${delta_file}   Catenate   SEPARATOR=
    ...   [{
    ...       "distName": "${FEATCADM_DN}",
    ...       "operation": "update",
    ...       "parameters": [{
    ...           "parameterName": "actValidationOnUpgrade",
    ...           "value": "false",
    ...           "operation": "update"
    ...       },{
    ...           "parameterName": "actTargetConfigPrep",
    ...           "value": "false",
    ...           "operation": "update"
    ...       }]
    ...   }]
    ${delta_file}   Set Variable   ${delta_file.replace("'","\"")}
    coam.perform_delta_recommissioning
    ...   delta_file=${delta_file}
    ...   skip_parameter_relation_errors=${False}
    ...   should_activate=${True}
    ...   timeout=${300}
    ...   connection=${testline}

    Log To Console   Disabled actValidationOnUpgrade ${testline} Successfully.

