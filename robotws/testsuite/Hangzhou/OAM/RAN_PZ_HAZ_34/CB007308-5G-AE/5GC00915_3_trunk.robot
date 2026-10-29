# *** Settings ***
# Documentation     author: Zhang Jin
# ...               contact: jin.2.zhang@nokia-sbell.com
# ...               squad group: SG_05
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ASOE_AEQY_ENB    STATE_SW_UPLOADED
# ...   PY36
# 
# 
# Resource          resources/override_keywords.robot
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           taf.selenium.mobile.sbts    WITH NAME    classical
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup       Case Suite Setup
# Suite Teardown    Case Suite Teardown
# 
# 
# *** Variables ***
# #5GC00915_3\CB006147_1\CB006147_2 variables
# ${path_actCli_feature}          /MRBTS-${mrbts_value}/RAT-1/BTS_L-*/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-*/MNL_A-1/MNLENT_A-1/FEATCADM_A-1
# ${path_SFP}                     /MRBTS-1/RAT-1/RUNTIME_VIEW-${r_id}/MRBTS_R-${r_id}/EQM_R-${r_id}/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1
# ${delta_activate_actCli}=               ${CURDIR}/resources/Delta_Activate_ActCli.json
# ${delta_deactivate_actCli}=             ${CURDIR}/resources/Delta_Deactivate_ActCli.json
# ${ADMIN_CLI_scripts_path}=              ${CURDIR}/scripts
# 
# 
# #5GC001930_03 variables
# ${device_name}    One Plus 8
# ${TS_CASE_LOG_PATH}    /home/ute
# ${browser_alias_firefox}     myDriver_firefox
# ${browser_alias_firefox2}    myDriver_firefox2
# ${browser_alias_firefox3}    myDriver_firefox3
# ${virtual_display}    ${True}
# 
# *** Test Cases ***
# [1]CB007308-5G-AE_5GC00915_3_Sfp_management
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2
#     [Setup]  5GC00915_3 case setup
#     Start Agent CLI is successfully
#     sleep    20s
#     SFP data management
#     [Teardown]    5GC00915_3 case teardown
# 
# [1]CB007308-5G-AE-5GC001930_03_SW_Information_and_rollback
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2
#     [Setup]    1930_Setup
#     classical.disable_message_box    sbts=coam_firefox
# 
#     sleep    3s
#     ${sw_ver_firefox_mo}    classical.check_current_software_version    sbts=coam_firefox
#     ${sw_ver_firefox_computer}    selenium_coam.check_current_software_version
#     Should Be Equal As Strings    &{sw_ver_firefox_mo}[Active]    &{sw_ver_firefox_computer}[Active]
# 
# 
#     classical.software_rollback     sbts=coam_firefox
#     sleep    300s
#     classical.close_browser    sbts=coam_firefox
# 
# 
#     wait until keyword succeeds   10 min   5 sec    Du login page via webUI
# 
#     classical.create_firefox_browser
#     ...    name=${browser_alias_firefox2}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    screenshot_dir=${TS_CASE_LOG_PATH}
#     ...    virtual_display=${virtual_display}
#     ...    device_name=${device_name}
#     classical.set_scope    alias=${browser_alias_firefox2}    scope=suite
# 
#     Setup_coam_mobile    browser_alias=${browser_alias_firefox2}    coam_alias=coam_firefox
#     classical.enable_virtual_display
#     Login_mobile_Webem    coam_alias=coam_firefox
#     sleep  60s
# 
#     ${var2}    classical.start_up_view_window_exists      sbts=coam_firefox
#     log  ${var2}
#     run keyword if    ${var2} == True
#     ...    classical.close_start_up_view_window     sbts=coam_firefox
#     ${sw_ver}    classical.check_current_software_version     sbts=coam_firefox
# 
# 
#     ${var7}    selenium_coam.start_up_view_window_exists
#     log  ${var7}
#     run keyword if    ${var7} == True
#     ...    selenium_coam.close_start_up_view_window
#     ${sw_ver_firefox_computer2}     selenium_coam.check_current_software_version
# 
#     Should Be Equal As Strings    &{sw_ver}[Active]    &{sw_ver_firefox_computer2}[Active]
#     Should Be Equal As Strings    &{sw_ver_firefox_mo}[Passive]    &{sw_ver}[Active]
#     Should Be Equal As Strings    &{sw_ver_firefox_mo}[Active]    &{sw_ver}[Passive]
# 
# 
# 
# 
#     classical.software_rollback     sbts=coam_firefox
#     sleep    300s
#     classical.close_browser    sbts=coam_firefox
# 
# 
#     wait until keyword succeeds   10 min   5 sec     Du login page via webUI
#     classical.create_firefox_browser
#     ...    name=${browser_alias_firefox3}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    screenshot_dir=${TS_CASE_LOG_PATH}
#     ...    virtual_display=${virtual_display}
#     ...    device_name=${device_name}
#     classical.set_scope    alias=${browser_alias_firefox3}    scope=suite
# 
#     Setup_coam_mobile    browser_alias=${browser_alias_firefox3}    coam_alias=coam_firefox
#     classical.enable_virtual_display
#     Login_mobile_Webem    coam_alias=coam_firefox
#     sleep  60s
# 
#     ${var2}    classical.start_up_view_window_exists      sbts=coam_firefox
#     log  ${var2}
#     run keyword if    ${var2} == True
#     ...    classical.close_start_up_view_window     sbts=coam_firefox
#     ${sw_ver}    classical.check_current_software_version     sbts=coam_firefox
# 
# 
#     ${var7}    selenium_coam.start_up_view_window_exists
#     log  ${var7}
#     run keyword if    ${var7} == True
#     ...    selenium_coam.close_start_up_view_window
#     ${sw_ver_firefox_computer2}     selenium_coam.check_current_software_version
# 
#     Should Be Equal As Strings    &{sw_ver}[Active]    &{sw_ver_firefox_computer2}[Active]
#     Should Be Equal As Strings    &{sw_ver_firefox_mo}[Active]    &{sw_ver}[Active]
#     Should Be Equal As Strings    &{sw_ver_firefox_mo}[Passive]    &{sw_ver}[Passive]
#     [Teardown]   1930_Teardown
# 
# [1]CB007308-5G-AE_CB006147_1_Lock_Unlock_SFP_BBMOD
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2
#     [Setup]  5GC00915_3 case setup
#     Create SFP Lane
#     Lock LANE by CLI is performed successfully
#     sleep    3s
#     Unlock LANE by CLI is performed successfully
#     sleep    120s
#     ADMIN Wait Until BTS OnAir
#     Lane lock and unlock in Detailed Site View    connector_name="Connector ${sfp_connector}"
#     [Teardown]  CB006147_1 case teardown
# 
# 
# [1]CB007308-5G-AE_CB006147_2_Parameters_check_for_transmission
#     [Tags]    CRT_TRUNK    CRT_22R1    CRT_22R2
#     [Setup]  5GC00915_3 case setup
#     SFP info Should not include Max transmission rate and Transmission distance
#     [Teardown]  5GC00915_3 case teardown
# 
# *** Keywords ***
# # special KW for 5GC00915_3 case
# 5GC00915_3 case setup
#     robot_common_operations.Common case Setup
#     Prepare environment
#     ADMIN Wait Until BTS OnAir
# 
# 5GC00915_3 case teardown
#     robot_common_operations.Common case Teardown
#     ADMIN Wait Until BTS OnAir
#     Teardown environment
# 
# # special KW for 5GC001930_03 case
# 1930_Setup
#     robot_common_operations.Common case Setup
#     Du Check cell on air via WebUI
#     Create_firefox_browser
#     Setup_coam_mobile    browser_alias=${browser_alias_firefox}    coam_alias=coam_firefox
#     Du login page via webUI
#     classical.enable_virtual_display
#     Login_mobile_Webem    coam_alias=coam_firefox
# 
# 
# 1930_Teardown
#     robot_common_operations.Common case Teardown
#     Logout_mobile_Webem    coam_alias=coam_firefox
#     sleep    2s
#     classical.disable_virtual_display
#     DU COAM selenium logout
#     CI_interface.Common Case Teardown
#     Teardown_mobile_Webem    coam_alias=coam_firefox
#     Wait Until Keyword Succeeds    15min    10s    Du Check cell on air via WebUI
# 
# 
# Create_firefox_browser
#     classical.create_firefox_browser
#     ...    name=${browser_alias_firefox}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    screenshot_dir=${TS_CASE_LOG_PATH}
#     ...    virtual_display=${virtual_display}
#     ...    device_name=${device_name}
#     classical.set_scope    alias=${browser_alias_firefox}    scope=suite
# 
# Create_chrome_browser
#     classical.create_chrome_browser
#     ...    name=${browser_alias_chrome}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    screenshot_dir=${TS_CASE_LOG_PATH}
#     ...    virtual_display=${virtual_display}
#     ...    device_name=${device_name}
#     classical.set_scope    alias=${browser_alias_chrome}    scope=suite
# 
# Setup_coam_mobile
#     [Arguments]    ${browser_alias}    ${coam_alias}
#     classical.setup_sbts
#     ...    browser=${browser_alias}
#     ...    alias=${coam_alias}
# 
# Login_mobile_Webem
#     [Documentation]    login to mobile webem
#     [Arguments]    ${coam_alias}
#     classical.login
#     ...    url=https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#     ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     ...    sbts=${coam_alias}
# 
# Logout_mobile_Webem
#     [Documentation]    logout mobile webem
#     [Arguments]    ${coam_alias}
#     classical.logout
#     ...    sbts=${coam_alias}
# 
# 
# Teardown_mobile_Webem
#     [Arguments]    ${coam_alias}
#     classical.teardown_sbts
#     ...    sbts=${coam_alias}
# 
# # special KW for CB006147_1 case
# CB006147_1 case teardown
#     ADMIN Wait Until BTS OnAir
#     Teardown environment for CB006147_1
# 
# Case Suite Setup
#     CI_interface.Common Suite Setup
#     robot_common_operations.Common Suite Setup
# 
# Case Suite Teardown
#     CI_interface.Common Case Teardown
#     robot_common_operations.Common Suite Teardown
# 
# 
# 
# 
