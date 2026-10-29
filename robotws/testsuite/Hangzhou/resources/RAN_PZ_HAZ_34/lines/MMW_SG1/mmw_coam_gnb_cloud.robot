*** Settings ***
Documentation    This is used for CU commission
...    [Obsoleted] This file is not maintained in furture. Please do not use it for new cases
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_cloud.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Library     taf.transport.ssh    WITH NAME    csn
Library     ./lib/string_list.py
Library    taf.selenium.gnb.oam.coam.cu   WITH NAME   coam_cu

*** Variables ***
${COMMISSION_FOLDER_PATH}    ${commissionings_path}       # This parameter is open by taf to indicate the absolute path for commission folder

*** Keywords ***
Get stream version from CI parameter
    [Documentation]  Author: Ding Binmei
    ...              Description: ${AF_PATH}: variable provided by CI team while executing robot cases:
    ...                            Example input: https://artifactory-hz1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/
    ...                                           System_Release/12.400.854/AirFrameVirtualized-12.400.854.qcow2
    ...             Return stream with 0.200/12.200, which are used for locate CU SCF template path
    @{list_items}    Split String    string=${AF_PATH}    separator=/
    ${stream_version}    set variable    ${list_items[-2]}
    ${is_SBTS_sw}    Run keyword and return status    Should contain    ${stream_version}    SBTS
    Return from keyword if  ${is_SBTS_sw}==${True}    SBTS
    @{list_stream}    Get regexp matches    ${stream_version}    (^\\d+.\\d+).    1
    ${stream}    set variable    ${list_stream[0]}
    ${stream}    Set variable if    '${stream}'=='0.400'    0.200
    ...    '${stream}'=='12.400'    12.200
    ...    '${stream}'=='14.400'    14.200
    ...    unsupported stream
    [Return]  ${stream}

Get SCF template path for CU
    [Documentation]  Author: Ding Binmei
    ...    If your case naming rule is different, please re-generate with new path
    ${stream}    Get stream version from CI parameter
    ${cu_scf_template_path}    Join path    ${COMMISSION_FOLDER_PATH}    HGZ/${testline_name}/SCF_${stream}_CU.xml
    [Return]  ${cu_scf_template_path}

Modify CU and DU parameter commission and onair
    [Documentation]    Author: Wang Yixiang
    [Arguments]     ${cu_scf_parameters_list}    ${du_scf_parameters_list}
    ...    ${cu_scf_template_path}    ${du_scf_template_path}
    ...    ${local_scf_path}=${SUITE_LOG_PATH}    ${cu_timeout}=8min    ${du_timeout}=20min    ${du_index_list}=${0}
    ...    ${is_pdl_checking_needed}=${True}
    ${default_cu_scf_file_path}    Copy file    ${cu_scf_template_path}    ${local_scf_path}
    ${default_du_scf_file_path}    Copy file    ${du_scf_template_path}    ${local_scf_path}

    ${modified_cu_scf_file_path}    run keyword if    ${cu_scf_parameters_list}!=${None}    coam_gnb_classical.COAM Modify scf file
    ...    scf_file_path=${default_cu_scf_file_path}
    ...    scf_parameters_list=${cu_scf_parameters_list}
    ...    ELSE    set variable    ${default_cu_scf_file_path}
    ${modified_du_scf_file_path}    run keyword if    ${du_scf_parameters_list}!=${None}    coam_gnb_classical.COAM Modify scf file
    ...    scf_file_path=${default_du_scf_file_path}
    ...    scf_parameters_list=${du_scf_parameters_list}
    ...    ELSE    set variable    ${default_du_scf_file_path}

    Log to console    Start to CU and DU commission, please wait...
    CU Full Commission  path_of_commission_file=${modified_cu_scf_file_path}    wait_active=${False}
    ${commission_result}    run keyword and return status    DU Commission with scf file    scf_file_path=${modified_du_scf_file_path}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}

    run keyword if    '${is_pdl_checking_needed}' == '${False}'    should be true    '${commission_result}' == '${True}'
    run keyword if    '${is_pdl_checking_needed}' == '${True}' and '${commission_result}' == '${false}'
    ...    log to console    there is some error when do commission. please check. then there will be one cases failed due to this error.
    run keyword if    '${is_pdl_checking_needed}' == '${True}' and '${commission_result}' == '${True}'
    ...    log to console    commission passed with PDL validation success.

#    run keyword and ignore error    Reset eNB site status     # workaround to save on air time
    COAM GNB Wait CU and DU cells are on air status    timeout=${cu_timeout}    du_timeout=${du_timeout}    du_index_list=${du_index_list}

Modify CU parameter and commission
    [Documentation]    Author: Wang Yixiang
    [Arguments]     ${scf_template_path}    ${scf_parameters_list}    ${local_scf_path}=${SUITE_LOG_PATH}
    Log to console    Start to modify CU scf files and commission, please wait..
    ${default_scf_file_path}    Copy file    ${scf_template_path}    ${local_scf_path}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file
    ...    scf_file_path=${default_scf_file_path}
    ...    scf_parameters_list=${scf_parameters_list}
    CU Full Commission  path_of_commission_file=${output_scf_file_path}

Perform Cloud DU reboot
    [Documentation]    Reboot of cloud du
    [Arguments]     ${gnb_index}=0    ${du_index}=0
    Cloud DU connect to gnb coam via ssl    gnb_index=${gnb_index}    du_index=${du_index}
    ${BTS_ID}    set variable    ${tl.gnbs[${gnb_index}].instance_id}
    log to console    Reboot of gNB${BTS_ID}_DU triggered
    coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM
    ${rc}=    Run and return rc    ping ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr} -w 10
    Should be equal as numbers    first=${0}    second=${rc}
    log to console    Reboot of gNB${BTS_ID}_DU finished!
    [Teardown]  COAM Teardown gnb connections

Perform Cloud CU reboot
    [Documentation]    author: Wang Yixiang
    ...    Reboot of cloud CU
    ...    taf lib:taf.gnb.oam.coam.cu.interface.py
    ...    reset_cu raise api exception, I have raise the issue to taf
    [Arguments]     ${gnb_index}=0
    CU Login    ${gnb_index}
    ${cu_info}   cu.reset_cu
    [Teardown]  run keyword and continue on failure    CU Logout

DU Commission with scf file
    [Documentation]  Author: Ding Binmei
    ...              Description: Do commission and verify commission status
    ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
    ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
    ...                                       otherwise will ignore this validation. Now it's default to ${True}
    [Arguments]  ${scf_file_path}    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}   Cloud DU connect to gnb coam via ssl   connection=GNB_OAM
    ...    ELSE    Connect to gnb coam via ssl    connection=GNB_OAM
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=GNB_OAM
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    ${pdl_validation_result}    set variable if
    ...    ${is_pdl_checking_needed}==${True} and '${result['validationResult']['pdlValidationResult']['status']}'!='OK'    ${False}
    ...    ${is_pdl_checking_needed}==${True} and '${result['validationResult']['pdlValidationResult']['status']}'=='OK'    ${True}
    ...    ${is_pdl_checking_needed}==${False}    ${None}
    Set suite variable    ${PDL_VALIDATION_RESULT}    ${pdl_validation_result}
    [Teardown]    COAM Teardown gnb connections    connection=GNB_OAM

Wait until ASOD cells are on air status
    [Documentation]  Author: journey.jin@nokia-sbell.com
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASOD status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
    Cloud DU connect to gnb coam via ssl
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair

COAM Check GNB ASOD status
    [Documentation]  Author: journey.jin@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB ASOD status
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_asods}    Set variable    ${hw_info['systemModules']}
    ${count_asods}    Get length    ${list_asods}
    Should be true    ${count_asods}>=${1}    msg=Check ASOD status failed as total ASOD number is less than 1
    FOR  ${asod}  IN  @{list_asods}
        Run keyword and continue on failure    Should be equal as strings    ${asod['status']['administrativeState']}    Unlocked
                                      ...  msg=Current ASOD administrativeState is not in Unlocked status    ignore_case=${True}
        Run keyword and continue on failure    Should be equal as strings    ${asod['status']['operationalState']}    Enabled
                                      ...  msg=Current ASOD operationalState is not in Enabled status    ignore_case=${True}
        Run keyword and continue on failure    Should be equal as strings    ${asod['status']['proceduralStatus']}    configured
                                      ...  msg=Current ASOD proceduralStatus is not in configured status    ignore_case=${True}
        Run keyword and continue on failure    Should be equal as strings    ${asod['status']['availabilityStatus']}    Online
                                      ...  msg=Current ASOD availabilityStatus is not in Online status    ignore_case=${True}
    END

COAM GNB Wait CU and DU cells are on air status
    [Documentation]    Author: Wang Yixiang     5G_PZ_MMW_HZ_1_SG
    ...    Ding Binmei: 2020-12-17: Refine keyword. Complete the checking for cloud BTS. Please switch to new keyword. This keyword
    ...                 is for compatibility
    ...    ${is_all_dus_checking_needed}: if ${True}, then will check all DUs defined in test line config file; Default to check for all DUs
    ...                                   if ${False}, then ${du_index_list} must be entered. Supported data types are string and list
    [Arguments]  ${timeout}=5 min    ${du_timeout}=20 min    ${du_index_list}=${0}    ${is_all_dus_checking_needed}=${True}
    coam_gnb_cloud.Cloud wait for gnb ready on both CU and DU    timeout=${du_timeout}    is_all_dus_checking_needed=${is_all_dus_checking_needed}
    ...    list_du_index=${du_index_list}

Reset eNB site status
    [Arguments]    ${eNB_asik_addr}=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=enblte
    enblte.reset_site    connection=enblte
    [Teardown]    Enblte close down    connection=enblte

CU SSH To OAM
    [Documentation]    Connect to cloud CU OAM VM. addr, username, password are from testline_configuration.
    ...  author:       yixiang.x.wang@nokia-sbell.com
    [Arguments]    ${alias}=CU_VM    ${gnb_index}=${0}
    csn.Connect to      hostname=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                 username=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...                 password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    ...                 alias=${alias}
    set test variable    ${alias}

Teardown SSH Connections
    [Documentation]    Connect to cloud CU OAM VM. addr, username, password are from testline_configuration.
    ...     author:yixiang.x.wang@nokia-sbell.com
    ...     example:
    ...     Teardown SSH Connections    alias=CU_VM
    ...     Teardown SSH Connections    alias=CU_VM,DU_VM
    [Arguments]    ${alias}=CU_VM
    @{alias_list}    string_list.string2list    input_str=${alias}
    FOR    ${alias_value}    IN    @{alias_list}
       csn.disconnect    connection=${alias_value}
    END

Create cOAM CU session
    [Documentation]  Author: Wang Yixiang, migrate from resources/common/coam_cu.robot
    ...              Description: Login into coam cu WebEM as Web Element Manager.
    ...              param url: str, url to coam cu WebEM
    ...              param username: str, username
    ...              param password: str, password
    ...              param browser: str, Default browser will be "Chrome", if user wants it to run via from Firefox
    ...              then then change the browser parameter to "Firefox"
    ...              param timeout: int, timeout for the element be available to click
    [Arguments]    ${gnb_id}=0   ${browser}=Chrome    ${timeout}=60
    coam_cu.enable_virtual_display
    coam_cu.login   url=https://${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.username}
    ...               password=${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.password}
    ...               browser=${browser}     timeout=${timeout}
