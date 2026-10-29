*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: keywords for enb upgrade

Library    OperatingSystem
Library    String

Library    taf.transport.ssh    WITH NAME    ssh
Library    ../python/DevNJ_eNB_rpc_client.py
Library    ../python/DevNJ_get_tl_configuration.py    WITH NAME    tl_configuration

*** Variables ***
${ENB_LOADSERVER_PATH}      /home/scpadm/SPACE/COMMON/Loads/ASIR
${ENB_PKG_LOCAL_PATH}       /home/ute/pkgload
${YAFT_PKG_LOCAL_PATH}      /home/ute/yaft

${ADDRESS}    ${tl.test_pcs[1].default_ssh_connection_details.addr}
${PORT}       8270

*** Keywords ***
#------------------Interface------------------
Install eNB VM RPC Server
    ssh.connect to    hostname=${ADDRESS}    username=${tl.test_pcs[1].default_ssh_connection_details.username}
    ...    password=${tl.test_pcs[1].default_ssh_connection_details.password}    alias=eNBRpcServer
    ${pip_opts}        Set Variable    --proxy http://87.254.212.120:8080 -i https://pypi.python.org/simple
    Run Keyword And Ignore Error    ssh.send_command    pip install robotremoteserver ${pip_opts}    connection=eNBRpcServer
    ssh.send_command    pip install taf.gnb.oam.coam.admin    connection=eNBRpcServer
    ssh.send_command    pip install moler    connection=eNBRpcServer
    ${robotws5g}        Set Variable    /home/ute/robotws5g
    ${robotws5g_git}    Set Variable    https://ca_MF_ST:Welcome123@wrgitlab.ext.net.nokia.com/RAN/robotws.git
    ${output}=    ssh.execute    rm -rf ${robotws5g} && git clone ${robotws5g_git} ${robotws5g}    connection=eNBRpcServer    timeout=600s
    Log To Console    ${output}

    ssh.send_command    pkill -f DevNJ_eNB_rpc_server.py    connection=eNBRpcServer
    Sleep    10s
    ssh.send_command  cd ${robotws5g} && python testsuite/Nanjing/OAM/Resources/python/DevNJ_eNB_rpc_server.py &   connection=eNBRpcServer
    Sleep    5s

    Run      pip install robotremoteserver ${pip_opts}
    ${output}=    Run      python -m robotremoteserver test http://${ADDRESS}:${PORT}
    Should Contain        ${output}    Remote server running at
    Should Not Contain    ${output}    No remote server running
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect    connection=eNBRpcServer

Setup Enb To Onair Status
    [Documentation]    The keyword upgrades enb and brings it to on air
    [Arguments]    ${build_version}=None
    ...            ${ip_address}=192.168.255.129
    Log To Console    checking if need upgrade...
    Log To Console    RPC server: http://${ADDRESS}:${PORT}
    ${install_enb}    ${target_build}=   _Check If Need To Updrade Enb    ${build_version}
    Log To Console    checked result: ${install_enb}
    Run Keyword If    '${install_enb}' != 'True'    _Perform Enb And Asir Commission    ${target_build}    ${ip_address}
    Run Keyword If    '${install_enb}' != 'True'    run_rpc_keyword    ${ADDRESS}    wait_for_onair    ip_addr=${ip_address}
    Return From Keyword If    '${install_enb}' != 'True'

    Log To Console    preparing env and upgrading enb to ${target_build}
    _Upgrade Enb And Commission    ${target_build}    ${ip_address}

    # wait enb on air
    Log To Console    waiting enb into on air...
    run_rpc_keyword    ${ADDRESS}    wait_for_onair    ip_addr=${ip_address}
    Log To Console  enb is already onair

# ------------------Internal use------------------
_Check If Need To Updrade Enb
    [Documentation]    This keyword checks if need to updrade enb
    ...    If a build version wasn't provided, the keyword will get the latest version from 5g-commission,
    ...    and compare it with the build version on asir
    ...    If a build version was provided, the keyword will compare it with the build version on asir
    ...    :param    ${build_version}     build, e.g.: SBTS20A_ENB_0000_001770_000000

    [Arguments]    ${build_version}=None
    ${current_build}=    Wait Until Keyword Succeeds     10x   1min    _Get Enb Current Build Version From BBU
    Log To Console    current build version is ${current_build}

    ${target_build}=     Run Keyword If    '${build_version}' == 'None'    _Get Enb Latest Build Version From Git    ${current_build}
    ...    ELSE    Set Variable    ${build_version}
    Log To Console    set target build: ${target_build}
    Run Keyword If    '${target_build}' == 'None'    Fail    cannot get latest build from git

    ${current_build_num}=   Get Substring    ${current_build}    -22
    ${target_build_num}=    Get Substring    ${target_build}     -22
    Log To Console   compare build number, ${target_build_num} and ${current_build_num}
    ${result}=    Set Variable If    '${current_build_num}' != '${target_build_num}'    ${True}    ${False}

    [Return]    ${result}    ${target_build}

_Upgrade Enb And Commission
    [Documentation]    This keyword upgrades enb by Yaft
    [Arguments]    ${build_version}
    ...            ${ip_address}=192.168.255.129
    # install enb asicli
    ${local_asicli_file}=    _Download Enb Asicli Package From Load Server    ${build_version}
    ${dest_asicli_dir}=      Set Variable    /opt/enb/asir
    run_rpc_keyword    ${ADDRESS}    prepare_asi_cli_env_for_enb     ${local_asicli_file}    ${dest_asicli_dir}

    # upgrade enb
    ${yaft_path}=       _Prepare Yaft Package
    ${enb_pkg_path}=    _Download Enb Package From Load Server    ${build_version}

    _Install Enb Via Yaft    ${yaft_path}     ${enb_pkg_path}    ${ip_address}

    Log To Console    wait eNB SSH connected
    ${result}=    run_rpc_keyword    ${ADDRESS}    waiting_for_site_response    ip_addr=${ip_address}
    Log To Console    site status: ${result}

    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    run_rpc_keyword
    ...    ${ADDRESS}    coam_admin_check_units_status_normal  basebandModules  ip_address=${ip_address}

    # plan enb commission
    Log To Console  starting perform eNB commission...
    ${enb_commission_path}=    _Get Enb Commission From Git     ${build_version}
    Wait Until Keyword Succeeds      6 min    30s    run_rpc_keyword    ${ADDRESS}    perform_enb_commissioning   ${enb_commission_path}

    Log To Console    wait eNB SSH connected
    run_rpc_keyword    ${ADDRESS}    waiting_for_site_response    ip_addr=${ip_address}

    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    run_rpc_keyword
    ...    ${ADDRESS}    coam_admin_check_units_status_normal      basebandModules    ip_address=${ip_address}
    Sleep  2min

    # upgrade enb via oam
    Log To Console   starting sw upgrade...
    ${result}=    run_rpc_keyword    ${ADDRESS}    sw_upgrade    ${enb_pkg_path}    bts_host=${ip_address}
    Log To Console   the result of sw updrade: ${result}

    Log To Console    wait eNB SSH connected
    run_rpc_keyword    ${ADDRESS}    waiting_for_site_response    ip_addr=${ip_address}

    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    run_rpc_keyword
    ...    ${ADDRESS}    coam_admin_check_units_status_normal      radioModules    ip_address=${ip_address}

    # plan asir commission
    Log To Console  Perform ASiR Commission After Load Upgrade
    ${asir_commission_path}=    _Get Enb Asir Commission From Git     ${build_version}
    _Perform Enb Asir Commission Fullfile     ${asir_commission_path}    ${dest_asicli_dir}

_Perform Enb And Asir Commission
    [Documentation]    This keyword only performs enb full commission, not including asir commissin
    [Arguments]    ${build_version}
    # perform enb commission
    Log To Console  starting perform eNB commission...
    ${enb_commission_path}=    _Get Enb Commission From Git     ${build_version}

    Wait Until Keyword Succeeds      6 min    30s    run_rpc_keyword
    ...    ${ADDRESS}    perform_enb_commissioning   ${enb_commission_path}
    _Wait eNB Modules Online

    # install enb asicli
    ${local_asicli_file}=    _Download Enb Asicli Package From Load Server    ${build_version}
    ${dest_asicli_dir}=      Set Variable    /opt/enb/asir
    run_rpc_keyword    ${ADDRESS}    prepare_asi_cli_env_for_enb     ${local_asicli_file}    ${dest_asicli_dir}

    # plan asir commission
    Log To Console  Perform ASiR Commission After Load Upgrade
    ${asir_commission_path}=    _Get Enb Asir Commission From Git     ${build_version}
    _Perform Enb Asir Commission Fullfile     ${asir_commission_path}    ${dest_asicli_dir}
    Sleep  2min
    _Wait eNB Modules Online

_Prepare Yaft Package
    [Documentation]    This keyword downloads yaft package from svn if needed

    ${yaft_path}=    run_rpc_keyword    ${ADDRESS}    prepare_yaft_package
    Log To Console  yaft path: ${yaft_path}
    Should Not Be Empty    ${yaft_path}

    [Return]    ${yaft_path}

_Download Enb Package From Load Server
    [Documentation]    This keyword downloads enb package from load server
    [Arguments]    ${build_version}

    Log To Console    download enb package ${build_version} from load server...
    ${enb_remote_package}=    run_rpc_keyword
    ...   ${ADDRESS}    download_enb_package_from_load_server    ${build_version}    ${ENB_PKG_LOCAL_PATH}    ${ENB_LOADSERVER_PATH}

    Should Not Be Empty    ${enb_remote_package}
    [Return]    ${enb_remote_package}

_Download Enb Asicli Package From Load Server
    [Documentation]    This keyword downloads enb package from load server
    [Arguments]    ${build_version}

    Log To Console      download asicli from load server...
    ${asicli_local}     Set Variable    ${ENB_PKG_LOCAL_PATH}/ASI_CLI
    ${asicli_remote}    Set Variable    ${ENB_LOADSERVER_PATH}/ASI_CLI
    ${remote_package}=    run_rpc_keyword
    ...    ${ADDRESS}    download_enb_asicli_package_from_load_server    ${build_version}    ${asicli_local}    ${asicli_remote}

    Should Not Be Empty    ${remote_package}
    [Return]    ${remote_package}

_Install Enb Via Yaft
    [Documentation]    This keyword installs enb by yaft
    [Arguments]    ${yaft_path}
    ...            ${build_package}

    Log To Console     installing enb by yaft...
    # for lint

    ${output}=    run_rpc_keyword    ${ADDRESS}    install_enb_via_yaft    ${yaft_path}    ${build_package}
    ${flash_flag}=    Run Keyword And Return Status    Should Contain    ${output}    Flashing done
    ${reboot_flag}=   Run Keyword And Return Status    Should Contain    ${output}    Waiting for FC* after reboot
    Run Keyword If    ${flash_flag} or ${reboot_flag}    Log To Console    yaft success! with msg ${output}
    ...    ELSE    Fail    yaft failed! with msg ${output}

_Get Enb Current Build Version From BBU
    [Documentation]  This keyword gets enb build version from bbu
    [Arguments]    ${ip_address}=192.168.255.129
    ${sw_version}=    run_rpc_keyword    ${ADDRESS}    get_enb_current_build_version_from_bbu    ${ip_address}
    Should Not Be Empty  ${sw_version}

    [Return]   ${sw_version}

_Get Enb Latest Build Version From Git
    [Documentation]    this keyword gets latest enb build version from 5g-commission.git
    [Arguments]        ${build_version}

    ${testline_name}=    tl_configuration.get_testline_name
    ${latest_build}=     run_rpc_keyword    ${ADDRESS}    get_enb_latest_build_version_from_git    ${testline_name}    ${build_version}
    Log To Console    latest build version: ${latest_build}
    [Return]   ${latest_build}

_Get Enb Commission From Git
    [Documentation]    this keyword returns the local path of the ${build_version} commission file
    [Arguments]        ${build_version}

    ${testline_name}=    tl_configuration.get_testline_name
    ${remote_commission}=    run_rpc_keyword    ${ADDRESS}    get_enb_commission_from_git   ${build_version}    ${testline_name}
    Log To Console    enb commission: ${remote_commission}
    Should Not Be Empty    ${remote_commission}

    [Return]   ${remote_commission}

_Get Enb Asir Commission From Git
    [Documentation]    this keyword returns the local path of the ${build_version} asir commission file
    [Arguments]        ${build_version}

    ${testline_name}=    tl_configuration.get_testline_name
    ${remote_commission}=    run_rpc_keyword    ${ADDRESS}    get_enb_asir_commission_from_git   ${build_version}    ${testline_name}
    Log To Console    enb asir commission: ${remote_commission}
    Should Not Be Empty    ${remote_commission}

    [Return]   ${remote_commission}

_Perform Enb Asir Commission Fullfile
    [Documentation]    This keyword performs asir commission file
    [Arguments]
    ...            ${asir_commission}
    ...            ${asicli_dir}=/opt/enb/asir
    ...            ${ip_address}=192.168.255.129
    ${output}=    run_rpc_keyword    ${ADDRESS}    perform_asir_commission_fullfile     ${asir_commission}    ${asicli_dir}    ${ip_address}
    Log To Console    ${output}
    Should Contain    ${output}    cli finished successfully

_Wait eNB Modules Online
    [Arguments]    ${ip_address}=192.168.255.129
    Log To Console    wait eNB SSH connected
    run_rpc_keyword    ${ADDRESS}    waiting_for_site_response    ip_addr=${ip_address}

    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     6x  1min     run_rpc_keyword
    ...    ${ADDRESS}  coam_admin_check_units_status_normal  basebandModules  ip_address=${ip_address}
    Sleep  2min

    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     6x  1min     run_rpc_keyword
    ...    ${ADDRESS}  coam_admin_check_units_status_normal  radioModules  ip_address=${ip_address}
