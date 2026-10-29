*** Settings ***
Documentation    This is common keywords for siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: Lin Stella
...              Contact: stella.lin@nokia-sbell.com
...              Squard: HZ SG6

Library    Collections
Library    ArchiveLibrary
Library    taf.pdu       WITH NAME    pdu
Library    taf.gnb.oam.coam.admin    WITH NAME    coam
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    gnb_classical_hangzhou.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Variables    ../../../../resources/RAN_PZ_HAZ_34/robot/bts/common/gnb_ru_variable.py
Library      ../python/os_operation.py

*** Variables ***
@{ALLOWED_FAULT}

*** Keywords ***
Connect to RU With Allocated IP
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]  ${ru_index}=${1}   ${ru_alias}=RU   ${asik_alias}=ASIK Master   ${connection}=GNB_OAM
    ...          ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
	${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}  gnb_classical_hangzhou.Get RU IP Address Via File FRIps  ru_serial_number=${ru_info['serialNumber']}  connection=${asik_alias}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU Via FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...                                         ru_index=${ru_index}
    ...                                         coam_connection=${connection}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${asik_alias}

Connect To RU By ServiceAccount
    [Documentation]   Auther: jiangjing.lin@nokia-sbell.com
    ...               Description: log in ru with service accout, then add sudo for service account
    [Arguments]  ${ru_ip_addr}    ${service_username}    ${service_password}    ${root_username}    ${root_password}
    ...    ${container_alias}=Container    ${service_alias}=SERVICE    ${ru_alias}=RU
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${service_username}
    ...               password=${service_password}
    ...               alias=${service_alias}
    ...               proxy=${container_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${service_alias}
    ${channel_service}    Call Method    ${connection_service}    invoke_shell
    Call Method    ${channel_service}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel_service}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${port}    get_idle_port    connection=${connection_service}
    ${time}  get time  epoch
    ${start_sshd}    Set Variable    sudo /usr/sbin/sshd -p ${port} -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug_${time}.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel_service}    send    ${start_sshd}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel_service}    recv    ${65535}
    ${get_sshd_port}    Set Variable    ps -ef|grep sshd|grep -v grep|grep 'PermitRootLogin yes'|awk '{print $7}'
    Call Method    ${channel_service}    send    ${get_sshd_port}\n
    Sleep    3 sec
    ${output}    Call Method    ${channel_service}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${output}=    Split String    ${output}    \r\n
    ${port}    set variable    ${output[1]}
    Call Method    ${channel_service}    close
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${root_username}
    ...               password=${root_password}
    ...               port=${port}
    ...               alias=${ru_alias}
    ...               proxy=${service_alias}

Connect To RU Via FHNET Container
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    ...               Description: Connect To RU Via FHNET Container
    ...               ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    ...               eth0(FHNET) ip is 192.168.255.254
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...            ${ru_index}=${1}
    ...            ${coam_connection}=GNB_OAM
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    ${version_active_sw}    Coam Get Active SW Version    connection=${coam_connection}
    ${release}    Coam Get program version based on gNB active version    version_active_sw=${version_active_sw}
    ${ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}    connection=${coam_connection}
    ${radio_type}    set variable    &{ru_info}[productName]
    Run keyword if    '${release}' in @{release_need_service_account} and '${radio_type}' in @{ru_login_with_service_account}
    ...    Connect To RU By ServiceAccount
    ...            ru_ip_addr=${ru_ip_addr}
    ...            service_username=${service_username}
    ...            service_password=${service_password_${release}}
    ...            root_username=${root_username}
    ...            root_password=${root_password}
    ...            container_alias=${container_alias}
    ...            ru_alias=${ru_alias}
    ...    ELSE    Run Keyword    csn.connect to
    ...                      hostname=${ru_ip_addr}
    ...                      username=${ru_username}
    ...                      password=${ru_password}
    ...                      alias=${ru_alias}
    ...                      proxy=${container_alias}

Get FHNET Container ID
    [Arguments]    ${asik_alias}=ASIK Master
    ${hostname}=    csn.execute    command=hostname    connection=${asik_alias}
    ${container_id}=    Set Variable If    'fct-0a' in '''${hostname}''' or 'asc-0a' in '''${hostname}'''    0x1018
    ...    'fct-4a' in '''${hostname}'''    0x2018    None
    [Return]   ${container_id}

Get Cell Status
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...               Description: return cell status info DICT.
    ...                            Key are availabilityStatus,administrativeState,operationalState
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${cell_idx}   Convert To Integer   ${cell_idx}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}',
    ...                         'blockingState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["blockingState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

Get Cell Group Status Via WEBUI
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]   ${cell_group_idx}=${0}     ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    COAM Navigate to login page via webUI    download_dir=${download_dir}    timeout=${timeout}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_group_status}    selenium_coam.get_cell_group_status    cell_group_idx=${cell_group_idx}
    [Return]   ${cell_group_status}
    [Teardown]  COAM selenium logout

Perform BTS Site Reset
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site
    [Teardown]  COAM selenium logout

Perform Cell Lock
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cell_idx}=${1}    ${download_dir}=${TS_CASE_LOG_PATH}
    ${cell_idx}  Convert To Integer    ${cell_idx}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.lock_cell    cell_idx=${cell_idx}
    Sleep   30 sec
    [Teardown]  COAM selenium logout

Perform Cell Unlock
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cell_idx}=${1}    ${download_dir}=${TS_CASE_LOG_PATH}
    ${cell_idx}  Convert To Integer    ${cell_idx}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.unlock_cell    cell_idx=${cell_idx}
    Sleep  30 sec
    [Teardown]  COAM selenium logout

Perform Cell Group Lock
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cell_group_idx}=${0}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.lock_cell_group    cell_group_idx=${cell_group_idx}
    Sleep   30 sec
    [Teardown]  COAM selenium logout

Perform Cell Group Unlock
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cell_group_idx}=${0}    ${download_dir}=${TS_CASE_LOG_PATH}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.unlock_cell_group    cell_group_idx=${cell_group_idx}
    Sleep   30 sec
    [Teardown]  COAM selenium logout

Perform RU Lock
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.lock_ru  ru_index=${ru_index}
    Sleep   30 sec
    [Teardown]  COAM selenium logout

Perform RU Unlock
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}  ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    selenium_coam.unlock_ru  ru_index=${ru_index}
    Sleep   30 sec
    [Teardown]  COAM selenium logout

Perform RU Reset
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    selenium_coam.reset_ru  ru_index=${ru_index}
    [Teardown]  COAM selenium logout

Perform RU Power Off
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    ${ru_index}    Convert to integer    ${ru_index}
    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_off    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}
    BuiltIn.Log    Reset RU via Power off and Power On.

Perform RU Power On
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.__class__.__name__}
    ${ru_index}    Convert to integer    ${ru_index}
    ${ru_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.pdu.addr}
    ${ru_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${ru_index}-1].pdu_port.port_no}
    pdu.setup_pdu    model=${model}    host=${ru_pdu_ip}    alias=ru_pdu_${ru_index}
    pdu.power_on    port=${ru_pdu_port}    pdu_device=ru_pdu_${ru_index}

Perform Site Power Off
    [Documentation]   Auther: journey.jin@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_off    port=${gnb_pdu_port}    pdu_device=gnb_pdu
    BuiltIn.Log    Reset Site via Power off and Power On.

Perform Site Power On
    [Documentation]   Auther: journey.jin@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${model}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].pdu_port.pdu.__class__.__name__}
    ${gnb_pdu_ip}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].pdu_port.pdu.addr}
    ${gnb_pdu_port}=  set variable  ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].pdu_port.port_no}
    pdu.setup_pdu    model=${model}   host=${gnb_pdu_ip}    alias=gnb_pdu
    pdu.power_on    port=${gnb_pdu_port}    pdu_device=gnb_pdu

RU Should Be Locked
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['administrativeState']}    Locked
                                  ...  msg=Current RU administrativeState is not in locked status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['operationalState']}       Enabled
                                  ...  msg=Current RU operationalState is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['proceduralStatus']}       configured
                                  ...  msg=Current RU proceduralStatus is not in configured status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}     Online
                                  ...  msg=Current RU availabilityStatus is not in Online status    ignore_case=${True}

RU Should Be Unlocked
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['administrativeState']}     Unlocked
                                  ...  msg=Current RU administrativeState is not in Unlocked status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['operationalState']}       Enabled
                                  ...  msg=Current RU operationalState is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['proceduralStatus']}       configured
                                  ...  msg=Current RU proceduralStatus is not in configured status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}      Online
                                  ...  msg=Current RU availabilityStatus is not in Online status    ignore_case=${True}

RU Should Be Offline
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}       Disabled
                                  ...  msg=Current RU operationalStatus is not in Disabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}     Offline
                                  ...  msg=Current RU availabilityStatus is not in Offline status    ignore_case=${True}

RU Should Be Online
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}    Enabled
                                  ...  msg=Current RU operationalStatus is not in Enabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    Online
                                  ...  msg=Current RU availabilityStatus is not in Online status    ignore_case=${True}

RU Should Be Power Off
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState']}    Disabled
                                  ...  msg=Current RU operationalStatus is not in Disabled status    ignore_case=${True}
    Should be equal as strings    ${ru_status['status']['availabilityStatus']}    NotInstalled
                                  ...  msg=Current RU availabilityStatus is not in NotInstalled status    ignore_case=${True}

Cell Should Be Locked
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Disabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Offline
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Locked

Cell Should Be Unlocked
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Online
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked

Cell Should Be Disabled
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings   ${subcell_status["operationalState"]}   Disabled
#    Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}  Failed

Cell Should Be Enabled
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings   ${subcell_status["operationalState"]}   Enabled
    Should Be Equal As Strings   ${subcell_status["availabilityStatus"]}  Online

Cell Should Be Blocked
    [Documentation]   Author: lanwen.cai@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=20   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Disabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Offline
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked
    Should Be Equal As Strings  ${subcell_status["blockingState"]}  Blocked

Cell Should Be UnBlocked
    [Documentation]   Author: lanwen.cai@nokia-sbell.com
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=20   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   Enabled
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  Online
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  Unlocked
    Should Be Equal As Strings  ${subcell_status["blockingState"]}  Unblocked

Cell Group Should Be Locked
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]   ${cell_group_idx}=${0}   ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${cell_group_status}    Get Cell Group Status Via WEBUI    cell_group_idx=${cell_group_idx}   download_dir=${download_dir}    timeout=${timeout}
    Should Be Equal As Strings     ${cell_group_status}   Lock

Cell Group Should Be Unlocked
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]   ${cell_group_idx}=${0}   ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${cell_group_status}    Get Cell Group Status Via WEBUI    cell_group_idx=${cell_group_idx}  download_dir=${download_dir}    timeout=${timeout}
    Should Be Equal As Strings     ${cell_group_status}   Unlock

Capture RFSW Log On RU
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]     ${connection}=RU
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${rfsw_log_path}    Set Variable    /ram/rfsw_log_${timestamp}.zip
    csn.execute     cd /usr/bin;ccsShell.sh log -a -z ${rfsw_log_path}    connection=${connection}
    [Return]     ${rfsw_log_path}

Download RU File To TestPC
    [Documentation]  Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_file_path}    ${connection}=RU   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_file_name}    Set Variable    @{ru_file_path.split('/')}[-1]
    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
    ...                                          remote_path=${ru_file_path}
    ...                                          local_path=${download_dir}/${ru_file_name}
    ...                                          connection=${connection}
    csn.execute      command=rm -rf ${ru_file_path}    connection=${connection}
    ${local_file_path}   Join Path    ${download_dir}    ${ru_file_name}
    [Return]   ${local_file_path}

Get RFSW Log File List On RU
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]     ${connection}=RU    ${download_dir}=${TS_CASE_LOG_PATH}
    ${rfsw_log_path_on_ru}   Capture RFSW Log On RU    connection=${connection}
    ${rfsw_log_path_on_testPC}    Download RU File To TestPC    ru_file_path=${rfsw_log_path_on_ru}
    ...                                                         connection=${connection}
    ...                                                         download_dir=${download_dir}
    ${unzip_result}    Run     unzip -l ${rfsw_log_path_on_testPC} |tail -n +2
    ${vaild_lines}      Get Lines Matching Regexp    ${unzip_result}     \\d+11_.*    partial_match=true
    ${rfsw_log_names}    Get Regexp Matches      ${vaild_lines}    ([2-9]011)?_.*
    [Return]   ${rfsw_log_names}

Get RFSW Log File List On Snapshot
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]   ${ru_index}=${1}    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM    ${timeout}=600
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    Run   rm -rf ${snapshot_zip_file_path}
    coam.get_snapshot    target_file_name=${snapshot_zip_file_path}   timeout=${timeout}   connection=${connection}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    Run   rm -rf ${snapshot_unzip_file_path}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${rfsw_log_names}   Get Regexp Matches   ${output}   BTS\\_${serial_number}\\_.*
    [Return]    ${rfsw_log_names}

Get RFSW Log File List On Snapshot via webUI
    [Documentation]   Author: Ding Binmei
    [Arguments]   ${ru_index}=${1}    ${snapshot_path}=${TS_CASE_LOG_PATH}  ${connection}=GNB_OAM
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${serial_number}  Set Variable    ${ru_info['serialNumber']}
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_zip_file_path}    COAM Save snapshot via webUI    download_dir=${snapshot_path}
    ${snapshot_unzip_file_path}    Join Path    ${snapshot_path}    snapshot_${timestamp}
    extract zip file    ${snapshot_zip_file_path}    ${snapshot_unzip_file_path}
    ${output}   OperatingSystem.get file    ${snapshot_unzip_file_path}/snapshot_file_list.txt
    ${rfsw_log_names}   Get Regexp Matches   ${output}   BTS\\_${serial_number}\\_.*
    [Return]    ${rfsw_log_names}

Verify RFSW Log Include In Snapshot
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    ...    is_get_snapshot_via_selenium: if set to ${True} use selenium for collect, if ${False} use rest api
    [Arguments]   ${ru_index}=${1}   ${ru_alias}=RU   ${connection}=GNB_OAM   ${snapshot_path}=${TS_CASE_LOG_PATH}    ${timeout}=600
    ...    ${is_get_snapshot_via_selenium}=${False}
    ${log_on_ru}   Get RFSW Log File List On RU   connection=${ru_alias}    download_dir=${snapshot_path}
    ${log_on_snapshot}   Run keyword if    ${is_get_snapshot_via_selenium}
    ...    Get RFSW Log File List On Snapshot via webUI    ru_index=${ru_index}    snapshot_path=${snapshot_path}    connection=${connection}
    ...    ELSE    Get RFSW Log File List On Snapshot  ru_index=${ru_index}    snapshot_path=${snapshot_path}    connection=${connection}
    ...        timeout=${timeout}
    ${not_include_list}    Create List
    FOR  ${item}  IN  @{log_on_ru}
       ${status}  Run Keyword And Return Status  Should Contain Match   ${log_on_snapshot}   regexp=.*${item}.*
       Run Keyword If  ${status}==${False}     Append to List    ${not_include_list}     ${item}
    END
    ${length}    Get Length    ${not_include_list}
    Should Be Equal As Integers   ${length}   ${0}   msg=Item ${not_include_list} not include in snapshot logs

Verify CPRI Register Vaule On RU
    [Arguments]  ${register}  ${expect_value}   ${connection}=RU
    ${register_value}   csn.execute     /sbin/devmem ${register}     connection=${connection}
    Should Contain  ${register_value}   ${expect_value}

Wait For Expect Fault Present
    [Documentation]   Auther: stella.lin@nokia-sbell.com
    ...               Description: wait expected fault to present
    ...               :param faultId<int|str>
    ...               :param timeout<str>: sec
    ...               :param source<str>: optional, full or partly match
    ...                 eg. MRBTS-75/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...                     CABINET_R-1/SMOD_R-1
    ...                     SMOD_R-1
    ...               :param connection<str>:coam admin alias
    [Arguments]   ${faultId}   ${timeout}   ${source}=${None}   ${connection}=GNB_OAM    ${du_index}=0
    ...            ${is_need_to_setup_gnb_connection}=${True}
    Log to console    Wait For Expect Fault Present
    Wait Until Keyword Succeeds   ${timeout} sec   5 sec    Expect Fault Should Present
    ...                                                     faultId=${faultId}
    ...                                                     source=${source}
    ...                                                     connection=${connection}
    ...                                                     du_index=${du_index}
    ...                                                     is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}

Wait For Expect Fault To Disappear
    [Documentation]   Auther: stella.lin@nokia-sbell.com
    ...               Description: wait expected fault to disappear
    ...               :param faultId<int|str>
    ...               :param timeout<str>: sec
    ...               :param source<str>: optional, full or partly match
    ...                 eg. MRBTS-75/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...                     CABINET_R-1/SMOD_R-1
    ...                     SMOD_R-1
    ...               :param connection<str>:coam admin alias
    [Arguments]   ${faultId}   ${timeout}   ${source}=${None}   ${connection}=GNB_OAM
    ...            ${du_index}=0
    ...            ${is_need_to_setup_gnb_connection}=${True}
    Log to console    Wait For Expect Fault To Disappear
    Wait Until Keyword Succeeds   ${timeout} sec   5 sec    Expect Fault Should Absent
    ...                                                     faultId=${faultId}
    ...                                                     source=${source}
    ...                                                     connection=${connection}
    ...                                                     du_index=${du_index}
    ...                                                     is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}

Expect Fault Should Present
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
    ...               add ${alarm['configObjectName']} due to some object don't have runtime object by zheng.4.liu@nokia-sbell.com
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}    ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}
    ${faultId}    Convert To Integer    ${faultId}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${connection}    Set variable if  '${du_index}'=='0'    ${connection}    ${connection}_du${du_index}
    Run keyword if    ${has_cbts} and ${is_need_to_setup_gnb_connection}
    ...    Cloud DU connect to gnb coam via ssl
    ...        connection=${connection}    du_index=${du_index}
    ...    ELSE IF    '${has_cbts}'=='${False}' and ${is_need_to_setup_gnb_connection}
    ...      Connect to gnb coam via ssl    connection=${connection}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Absent
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    [Arguments]   ${faultId}   ${source}=${None}   ${connection}=GNB_OAM
    ...    ${du_index}=0    ${is_need_to_setup_gnb_connection}=${True}
    ${status}    Run Keyword And Return Status   Expect Fault Should Present   faultId=${faultId}
    ...                                                                        source=${source}
    ...                                                                        connection=${connection}
    ...                                                                        du_index=${du_index}
    ...                                                                        is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
    Run Keyword If  ${status}==${True}   Fail   faultId ${faultId} reported by source ${source} is still present on gnb.

Unexpect Alarm Should Not Exist
    [Documentation]   Auther: stella.lin@nokia-sbell.com
    ...               Description: check unexpect alarm exist or not ,if yes, save it to file
    ...               :param allowed_faults<list>: list contains dictionary, dict keys can be only faultId or faultId with source
    ...                    eg. [{"faultId":7300}]
    ...                        [{"faultId":61524,"source":"/SMOD_R-1"}]
    ...                        [{"faultId":61524,"source":"CABINET-1/SMOD_R-1"},{"faultId":7300}]
    ...               :param log_path<str>: saved alarm to path , default is testcase log path.
    ...               :param connection<str>：coam admin connection , default is GNB_OAM
    [Arguments]   ${allowed_faults}
    ...           ${file_path}=${TS_CASE_LOG_PATH}
    ...           ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${active_alarms_num}     Get Length    ${active_alarms_list}
    ${unexpect_alarms}    Create List
    FOR  ${alarm}  IN  @{active_alarms_list}
       Exit For Loop If   ${active_alarms_num}==${0}
       ${status}   Run Keyword And Return Status   Check Alarm Is Allowed
       ...                                         allowed_alarm_list=${allowed_faults}
       ...                                         check_alarm=${alarm}
       Run Keyword If   ${status}==${False}    Append To List    ${unexpect_alarms}   ${alarm}
    END
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/unexpect_active_alarms_${timestamp}.txt
    ${alarm_num}   Get Length   ${unexpect_alarms}
    Run Keyword If  ${alarm_num}!=${0}    Run   command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR  ${alarm}  IN  @{unexpect_alarms}
        Exit For Loop If  ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If   ${alarm_num}!=${0}   fail   ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}

Check Alarm Is Allowed
    [Documentation]   Auther: stella.lin@nokia-sbell.com
    ...               Description: used in keyword <<< Unexpect Alarm Should Not Exist >>>
    [Arguments]   ${allowed_alarm_list}     ${check_alarm}
    ${allowed_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{allowed_alarm_list}
        ${check_source}   ${source_value}   Run Keyword And Ignore Error    Set Variable   ${alarm['source']}
        ${allowed_status}    Run Keyword And Return Status    Run Keywords
        ...                  Should Be Equal    ${check_alarm['faultId']}    ${alarm['faultId']}  AND
        ...                  Run Keyword If  '${check_source}'=='PASS'
        ...                                   Should Contain     ${check_alarm['notifier']}   ${source_value}
        Exit For Loop If   ${allowed_status}
    END
    Run Keyword If  ${allowed_status}==${False}  Fail  faultId ${check_alarm['faultId']} reported by ${check_alarm['notifier']} not allowed

COAM get actual ru sw version from RU
    [Documentation]    Author: Ding Binmei
    ...                Description: Get actual RU sw version from RU
    [Arguments]  ${ru_alias}=RU
    ${cmd_get_ru_build_version}    set variable    cat /etc/version
    ${output_ru_build_version}    csn.execute    command=${cmd_get_ru_build_version}    connection=${ru_alias}
    ${ru_build_version}    Fetch from left   string=${output_ru_build_version}    marker=${SPACE}
    ${ru_build_version}    Strip string    ${ru_build_version}
    Should not be empty    ${ru_build_version}    msg=Fail to get ru build version from RU
    [Return]  ${ru_build_version}

COAM get expected ru sw version from target BD file
    [Documentation]  Author: Ding Binmei
    ...              Description: Get expected RU sw version from ASIK
    ...              ${ru_resource_build_key}: Should be the resourceBuildKey value in the TargetBD*.xml file under folder /ffs/run on ASIK
    ...                                        Example value: LTX_AEQB
    [Arguments]    ${ru_resource_build_key}    ${asik_alias}=ASIK Master
    ${cmd_get_target_bd_file}    set variable    ls /ffs/run/TargetBD*.xml
    ${target_bd_file_path}    csn.execute    command=${cmd_get_target_bd_file}    connection=${asik_alias}
    ${target_bd_file_path}    Strip string    ${target_bd_file_path}
    ${cmd_get_exp_ru_build_version}    set variable    more ${target_bd_file_path}|grep 'hwResource resourceBuildKey="${ru_resource_build_key}'
    ${output_ru_build_version}    csn.execute    command=${cmd_get_exp_ru_build_version}    connection=${asik_alias}
    @{ru_build_version}    Get Regexp matches    ${output_ru_build_version}    resourceSWVersion="(.*)"    1
    Should not be empty    ${ru_build_version[0]}    msg=Fail to get ru build version from ${target_bd_file_path} on ASIK
    [Return]  ${ru_build_version[0]}

COAM verify ru sw version
    [Documentation]    Author: Ding Binmei
    ...                Description: Version ru sw version. Compare the active sw version on RU with the expected version in the TargetBD*.xml file
    ...                             under folder /ffs/run on ASIK
    ...              ${ru_resource_build_key}: Should be the resourceBuildKey value in the TargetBD*.xml file under folder /ffs/run on ASIK
    ...                                        Example value: LTX_AEQB
    [Arguments]  ${ru_resource_build_key}    ${asik_alias}=ASIK Master    ${ru_alias}=RU
    ${act_ru_sw_version}    COAM get actual ru sw version from RU    ru_alias=${ru_alias}
    ${exp_ru_sw_version}    COAM get expected ru sw version from target BD file    ru_resource_build_key=${ru_resource_build_key}
    ...                             asik_alias=${asik_alias}
    Should be equal as strings    ${act_ru_sw_version}    ${exp_ru_sw_version}    msg=Verify for ru sw version failed.

COAM get all ru detail info
    [Documentation]  Author: Ding Binmei
    ...              Description: Get all RU detail info
    ...              Return with a dict with all RU info included, keys are the ru_index, values are the detail ru info
    [Arguments]    ${connection}=GNB_OAM
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${config_rmod}    Set variable    ${RU['id']['configuration']}
        ${rmod_index}    Fetch from right    ${config_rmod}    RMOD-
        Set to dictionary    ${dict_RUs_detail_info}    ${rmod_index}    ${RU}
    END
    [Return]  ${dict_RUs_detail_info}

COAM get ru detial info by ru index
    [Documentation]  Author: Ding Binmei
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${ru_index}    Convert to string    ${ru_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${status}    Run Keyword And Return Status    Should Contain   '${RU}'   RMOD-${ru_index}
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_RUs_detail_info}    ${ru_index}    ${RU}
    END
    [Return]  ${dict_RUs_detail_info['${ru_index}']}


COAM verify ru detail info via rest api
    [Documentation]  Author: Ding Binmei
    ...              Description: Verify for RU type, RU product code and RU serial number info
    ...                           ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]  ${ru_type}    ${ru_product_code}    ${ru_serial_number}    ${ru_index}=1    ${connection}=GNB_OAM
    &{dict_ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}    connection=${connection}
    Run keyword and continue on failure    Should be equal as strings  ${dict_ru_info['productName']}    ${ru_type}
    ...    msg=Validate for RU type failed. Exp: ${ru_type}, Act: ${dict_ru_info['productName']}
    Run keyword and continue on failure    Should be equal as strings  ${dict_ru_info['productCode']}    ${ru_product_code}
    ...    msg=Validate for RU type failed. Exp: ${ru_product_code}, Act: ${dict_ru_info['productCode']}
    Run keyword and continue on failure    Should be equal as strings  ${dict_ru_info['serialNumber']}    ${ru_serial_number}
    ...    msg=Validate for RU type failed. Exp: ${ru_serial_number}, Act: ${dict_ru_info['serialNumber']}

COAM get cell specific info
    [Documentation]  Author: Ding Binmei
    ...              Description: Get cell specific info by cell id
    ...              ${cell_id}: should be int number, start from 1...
    ...              Return a dict with cell detail info:
    ...                 {'band': 'n257', 'chBw': '100MHz', 'nrarfcn': 2059003, 'physCellId': 70,
    ...                 'status': {'administrativeState': 'Unlocked', 'availabilityStatus': 'Online', 'blockingState': 'Unblocked',
    ...                        'operationalState': 'Enabled', 'proceduralStatus': 'configured', 'usageState': 'Active'}, 'technology': 'TDD'}
    [Arguments]    ${cell_id}=1    ${mr_bts_id}=${tl.gnbs[0].instance_id}    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    Log to console    COAM get cell specific info...
    ${cell_info}    coam.get_cell_specific_info    cell_id=MRBTS-${mr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_id}    connection=${connection}
    [Return]    ${cell_info}

Recovery env if case failed with operations
    [Documentation]    Author: Ding Binmei
    ...                Description: Intergration all recovery actions if case with operations failed
    ...                ${operation}: Supported values:  cell_group_unlock, cell_unlock, ru_unlock, ru_power_on, site_power_on
    ...                              if filled with other values, then no recovery action is needed
    [Arguments]    ${operation}=${None}    ${ru_index}=${1}    ${cell_index}=${1}    ${cell_group_index}=${0}
    Log to console    Recovery env if case failed with operations...
    Run keyword if    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'cell_group_unlock'
    ...        Perform cell group unlock via rest api    cellgrp_idx=${cell_group_index}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'cell_unlock'
    ...        Perform cell unlock via rest api    cell_idx=${cell_index}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'ru_unlock'
    ...        Perform RU Unlock    ru_index=${ru_index}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'ru_power_on'
    ...        Perform RU Power On    ru_index=${ru_index}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'site_power_on'
    ...        Perform Site Power On
    ...    ELSE    Log to console    No recovery action needed for operation ${operation}

Connect to all rus with allocated IP
    [Documentation]  Author: Ren Biyao
    ...    This keyword supports all establishment of rus via allocated IP.
    ...    2020-01-21 Ding Binmei: Return all ru alias
    ...    2020-02-18 Liu Zheng: get the ru list from init to cluster
    ...    2020-09-23 Yan Xin: all rus connection with multi-du scenario
    [Arguments]    ${connection}=GNB_OAM    ${du_index}=${0}    ${du_alias}=du_${du_index}
    connection_alias_store.Connect to Common Unit Master    du_index=${du_index}    alias=${du_alias}
    @{list_ru_alias}    Create list
    ${ru_index_list}    Get RU index list    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
      Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
      ...    asik_alias=${du_alias}    connection=${connection}
      Append to list    ${list_ru_alias}    RU_${ru_index}
    END
    [Return]  ${list_ru_alias}

Get RU index list
    [Documentation]  Author: Liu Zheng
    ...              Description: Support to check with multiple rmod
    [Arguments]    ${connection}=GNB_OAM
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    @{ru_index_list}    Create list
    FOR  ${ru}  IN  @{list_RUs}
        ${ru_index}    Fetch from right    ${ru['id']['configuration']}    -
        Append to list    ${ru_index_list}    ${ru_index}
    END
    [Return]    ${ru_index_list}

Disconnect ssh connections
    [Documentation]  Author: Ding Binmei
    ...              Description: Release all ssh aliass in ${list_alias}
    [Arguments]  ${list_alias}
    FOR    ${alias}    IN    @{list_alias}
      ssh.disconnect    connection=${alias}
    END

Du login page via webUI
    [Documentation]  Author: Wu Jerry
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    [Arguments]  ${download_dir}=/home/ute
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}
    selenium_coam.disable_message_box

Du Check cell on air via WebUI
    [Documentation]  Author: Wu Jerry
    ...              Description: Check if GNB is in cell on air status via webui
    [Arguments]    ${download_dir}=/home/ute
    Du login page via webUI    download_dir=${download_dir}
    ${bts_status}    selenium_coam.get_bts_status
    Should be equal as strings    ${bts_status}    On air    msg=GNB is not on air, Current status is ${bts_status}
    ...                      ignore_case=${True}
    [Teardown]    DU COAM selenium logout

Du Check cell on air via WebUI without login
    [Documentation]  Author: Wu Jerry
    ...              Description: Check if GNB is on air without login operation
    ${bts_status}    selenium_coam.get_bts_status
    Should be equal as strings    ${bts_status}    On air    msg=GNB is not on air, Current status is ${bts_status}
    ...                      ignore_case=${True}

Get MRBTS Id in COAM WebEM
    [Documentation]    Author: Wu Jerry
    ...    Description: get mrbts id
    ${btsid}    Wait Until Keyword Succeeds    2min    10s    selenium_coam.get_bts_id
    ${MRBTS_ID}    Set Variable    MRBTS-${btsid}
    [Return]    ${MRBTS_ID}

Backup DU SCF
    [Documentation]  Author: Charlotte Wu
    ...              Description: Backup DU SCF
    Du login page via webUI
    ${orig_btsName}=    selenium_coam.get_bts_name
    set global variable    ${orig_btsName}
    ${scf_path_org}=    selenium_coam.save_bts_configuration    save_configuration_type=${0}
    ${scf_path_org}=    Replace String    ${scf_path_org}    ${space}    \\${space}
    ${scf_path}=    Replace String    ${scf_path_org}    \\${space}    _
    run    mv ${scf_path_org} ${scf_path}
    [Teardown]    DU COAM selenium logout
    [Return]    ${scf_path}

Restore DU SCF
    [Documentation]  Author: Charlotte Wu
    ...              Description: Restore DU SCF
    [Arguments]    ${source_SCF_path}
    Du login page via webUI
    Load SCF without activation    ${source_SCF_path}
    Activate Plan
    [Teardown]    DU COAM selenium logout

Load SCF without activation
    [Documentation]  Author: Charlotte Wu
    ...              Description: Load SCF and validate the SCF
    [Arguments]    ${source_SCF_path}
    Run Keyword And Ignore Error    selenium_coam.continue_after_plug_and_play_modal_appear
    ${status}=    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${source_SCF_path}
    Should be True    ${status}

Activate Plan
    [Documentation]  Author: Charlotte Wu
    ...              Description: Activate Loaded SCF
    Log to console    Activeate plan...
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${300}

Validate Plan
    [Documentation]  Author: Charlotte Wu
    ...              Description: Validate Loaded SCF
    Log to console    Validate plan...
    selenium_coam.validate_plan

Reset Configuration
    [Documentation]  Author: Charlotte Wu
    ...              Description: Reset configuration and back to uncommissioned state
    ${status}=    selenium_coam.configuration_reset
    Should be true    '${status}'=='Execution succeeded'
    Wait until keyword succeeds    15 x    60 s
    ...  Check BTS state    BTS_status=Not commissioned
    selenium_coam.continue_after_plug_and_play_modal_appear

Check BTS state
    [Documentation]  Author: Charlotte Wu
    ...              Description: Check BTS status should be equal to the input value
    [Arguments]    ${BTS_status}=Not commissioned
    ${status}=    selenium_coam.get_bts_status
    Should Be Equal    ${status}    ${BTS_status}

Download Plan without activation
    [Documentation]  Author: Charlotte Wu
    ...              Description: Change the loaded plan to inactivated state
    Log to console    Download Plan without activation...
    selenium_coam.activate_plan    download_plan_without_activation=${True}    activate_plan_despite_errors=${True}

DU COAM selenium logout
    [Documentation]  Author: Charlotte Wu
    ...              Description: Disable virtual_display and logout webui.
    selenium_coam.logout
    Run Keyword And Ignore Error   selenium_coam.disable_virtual_display

Close DU start up window
    [Documentation]  Author: Charlotte Wu
    ...              Description: Close DU start up window if exists.
    [Arguments]    ${timeout}=${600}
    Log to console    Close DU start up window
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window    timeout=${timeout}

COAM Get nrcellid with the lcrid
    [Documentation]  Author: Feipeng Qian
    ...              Description: Get the nrcellid with the lcrid
    [Arguments]   ${lcrid}    ${gnb_index}=0    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    connection=GNB_OAM    bts_host=${bts_host}    username=${username}    password=${password}
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    ${number_of_cell_group_info}    get length    ${cell_info}
    FOR  ${index}  IN RANGE   ${number_of_cell_group_info}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
        ${nrCellId}    Get nrcellid in all cellgroup with the lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
        exit for loop if    '${nrCellId}'!='None'
    END
    [Return]    ${nrCellId}
    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with the lcrid
    [Documentation]  Author: Feipeng Qian
    ...              Description: Get the nrcellid in all cellgroup with the lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
        ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
        ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}

Coam Get Active SW Version
    [Documentation]  Author: Lin jiangjing
    ...              Description: Get the active sw version, the result is like SBTS21B_ENB_9999_210528_000013 and so on
    [Arguments]  ${connection}=GNB_OAM
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${sbts}    run keyword and return status     Should contain    ${sw_version}    SBTS
    return from keyword if    ${sbts}      ${sw_version}
    @{result}    string.split string    ${sw_version}    separator=_
    ${length}    Get Length    ${result}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     @{result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
         ${j} =    Evaluate    ${i} + ${2}
         ${build}    set variable    @{result}[${j}]
         ${build}    Run Keyword If    ${j} < 5    convert to integer    @{result}[${j}]    ELSE    set variable    @{result}[${j}]
         ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    [Return]   ${SW_vesion_tmp}

Coam Get program version based on gNB active version
    [Documentation]  Author: Lin jiangjing
    ...              Description: Get the release version, the rsult is like 21A, 21B, 22R1 and so on
    [Arguments]  ${version_active_sw}=${None}
    ${sbts_22R1}    run keyword and return status     Should contain    ${version_active_sw}    22R1
    return from keyword if    ${sbts_22R1}      22R1
    ${sbts_22R2}    run keyword and return status     Should contain    ${version_active_sw}    22R2
    return from keyword if    ${sbts_22R2}      22R2
    ${sbts_21b}    run keyword and return status     Should contain    ${version_active_sw}    21B
    return from keyword if    ${sbts_21b}      21B
    @{rest}    String.split string    string=${version_active_sw}    separator=.
    ${stream}    set variable    @{rest}[0].@{rest}[1]
    ${program_version}    set variable if    ${stream} in [9.1800]    20A
    ...    ${stream} in [10.1800]    20B
    ...    ${stream} in [11.800]    21A
    ...    Undefined
    [Return]    ${program_version}
