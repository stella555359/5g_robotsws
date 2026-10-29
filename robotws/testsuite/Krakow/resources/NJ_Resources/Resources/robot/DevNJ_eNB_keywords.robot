*** Settings ***
Documentation
...    author: Haiyang Zhao
...    contact: haiyang.a.zhao@nokia-sbell.com
...    Purpose: keywords for enb upgrade

Library    OperatingSystem
Library    String
Library    taf.gnb.oam.coam.admin     WITH NAME     admin

Library    ../python/wft.py    WITH NAME    wft
Library    ../python/DevNJ_download_build_from_LS.py
Library    ../python/DevNJ_get_tl_configuration.py    WITH NAME    tl_configuration
Library    ../python/DevNJ_eNB_keywords.py

Resource    DevNJ_asicli.robot
Resource    DevNJ_gNB_PnP_keywords.robot
Resource    DevNJ_upgrade.robot
Resource    DevNJ_testline.robot

*** Variables ***
${ENB_LOADSERVER_PATH}      /home/scpadm/SPACE/COMMON/Loads/ASIR
${ENB_PKG_LOCAL_PATH}       /home/ute/pkgload
${YAFT_PKG_LOCAL_PATH}      /home/ute/yaft

*** Keywords ***
Setup Enb To Onair Status
    [Documentation]    The keyword upgrades enb and brings it to on air
    [Arguments]    ${build_version}=None
    ...            ${ip_address}=192.168.255.129

    Log To Console    checking if need upgrade...
    ${install_enb}    ${target_build}=   Check If Need To Updrade Enb    ${build_version}
    Log To Console    checked result: ${install_enb}
    Return From Keyword If    '${install_enb}' != 'True'

    Log To Console    preparing env and upgrading enb to ${target_build}
    Upgrade Enb And Commission    ${target_build}    ${ip_address}

    # wait enb on air
    Wait for onAir    ip_addr=${ip_address}
    Log To Console  enb is already onair

Check If Need To Updrade Enb
    [Documentation]    This keyword checks if need to updrade enb
    ...    If a build version wasn't provided, the keyword will get the latest version from 5g-commission,
    ...    and compare it with the build version on asir
    ...    If a build version was provided, the keyword will compare it with the build version on asir
    ...    :param    ${build_version}     build, e.g.: SBTS20A_ENB_0000_001770_000000

    [Arguments]    ${build_version}=None
     ${current_build}=    Get Enb Current Build Version From BBU
    Log To Console    current build version is ${current_build}

    ${target_build}=     Run Keyword If    '${build_version}' == 'None'    Get Enb Latest Build Version From Git    ${current_build}
    ...    ELSE    Set Variable    ${build_version}
    Log To Console    set target build: ${target_build}
    Run Keyword If    '${target_build}' == 'None'    Fail    cannot get latest build from git

    ${current_build_num}=   Get Substring    ${current_build}    -22
    ${target_build_num}=    Get Substring    ${target_build}     -22
    Log To Console   compare build number,
    ...    ${current_build_num} is equal to ${target_build_num} : ${current_build_num} != ${target_build_num}
    ${result}=    Set Variable If    '${current_build_num}' != '${target_build_num}'    ${True}    ${False}

    [Return]    ${result}    ${target_build}

Upgrade Enb And Commission
    [Documentation]    This keyword upgrades enb by Yaft
    [Arguments]    ${build_version}
    ...            ${ip_address}=192.168.255.129
    # install enb asicli
    ${local_asicli_file}=    Download Enb Asicli Package From Load Server    ${build_version}
    ${dest_asicli_dir}=      Set Variable    /opt/enb/asir
    Prepare ASI CLI Env For Enb     ${local_asicli_file}    ${dest_asicli_dir}

    # upgrade enb
    ${yaft_path}=       Prepare Yaft Package
    ${enb_pkg_path}=    Download Enb Package From Load Server    ${build_version}

    Install Enb Via Yaft    ${yaft_path}     ${enb_pkg_path}    ${ip_address}

    Log To Console    wait eNB SSH connected
    Waiting_For_Site_Response    ip_addr=${ip_address}

    Log To Console  Wait for BaseBandModulesStatus Online
    admin.connect_to   bts_host=${ip_address}    bts_port=443    name=coam_admin
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'    bts_host=${ip_address}

    # plan enb commission
    Log To Console  starting perform eNB commission...
    ${enb_commission_path}=    Get Enb Commission From Git     ${build_version}
    Wait Until Keyword Succeeds      6 min    30s    admin.Perform Commissioning   ${enb_commission_path}    connection=coam_admin

    Log To Console    wait eNB SSH connected
    Waiting_For_Site_Response    ip_addr=${ip_address}

    Log To Console  Wait for BaseBandModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'basebandModules'    bts_host=${ip_address}
    Sleep  2min

    # upgrade enb via oam
    COAM_Admin_UpdateSW     ${enb_pkg_path}    bts_host=${ip_address}

    Log To Console    wait eNB SSH connected
    Waiting_For_Site_Response    ip_addr=${ip_address}

    Log To Console  Wait for RadioModulesStatus Online
    Wait Until Keyword Succeeds     6x   1min    COAM_Admin_CheckUnitsStatusNormal      'radioModules'    bts_host=${ip_address}

    # plan asir commission
    Log To Console  Perform ASiR Commission After Load Upgrade
    ${asir_commission_path}=    Get Enb Asir Commission From Git     ${build_version}
    Perform Enb Asir Commission Fullfile     ${asir_commission_path}    ${dest_asicli_dir}
    [Teardown]    admin.teardown    connection=coam_admin

Prepare Yaft Package
    [Documentation]    This keyword downloads yaft package from svn if needed

    ${exist}=    Run Keyword And Return Status    OperatingSystem.Should Exist  ${YAFT_PKG_LOCAL_PATH}/yaft.py
    Return From Keyword If    '${exist}' == 'True'    ${YAFT_PKG_LOCAL_PATH}/yaft.py

    ${yaft_path}=    Checkout Yaft From Svn
    OperatingSystem.Should Exist  ${yaft_path}

    [Return]    ${yaft_path}

Download Enb Package From Load Server
    [Documentation]    This keyword downloads enb package from load server
    [Arguments]    ${build_version}

    Log To Console    download enb package from load server...
    ${build_package}=    Set Variable    ${build_version}_release_BTSSM_downloadable_A50.zip
    ${enb_local_package}=    Set Variable    ${ENB_PKG_LOCAL_PATH}/${build_version}/${build_package}
    ${enb_remote_package}=    Set Variable    ${ENB_LOADSERVER_PATH}/${build_version}/${build_package}
    OperatingSystem.Create Directory     ${ENB_PKG_LOCAL_PATH}/${build_version}
    Download Package From Load Server    ${build_package}    ${enb_local_package}    ${enb_remote_package}

    OperatingSystem.Should Exist  ${enb_local_package}
    [Return]    ${enb_local_package}

Download Enb Asicli Package From Load Server
    [Documentation]    This keyword downloads enb package from load server
    [Arguments]    ${build_version}

    Log To Console    download asicli from load server...
    ${asicli_version}=    wft.get_asicli_version    ${build_version}
    Run Keyword If    '${asicli_version}' == 'None'    Fail    failed to get asicli version
    ${asicli_local_package}    Set Variable      ${ENB_PKG_LOCAL_PATH}/ASI_CLI/asi-cli.tgz
    ${asicli_remote_package}     Set Variable    ${ENB_LOADSERVER_PATH}/ASI_CLI/${asicli_version}/asi-cli.tgz
    OperatingSystem.Create Directory     ${ENB_PKG_LOCAL_PATH}/ASI_CLI
    Download Package From Load Server    ${build_version}    ${asicli_local_package}    ${asicli_remote_package}

    OperatingSystem.Should Exist  ${asicli_local_package}
    [Return]    ${asicli_local_package}

Install Enb Via Yaft
    [Documentation]    This keyword installs enb by yaft
    [Arguments]    ${yaft_path}
    ...            ${build_package}
    ...            ${ip_address}=192.168.255.129

    Log To Console     installing enb by yaft...
    # for lint
    ${yaft_params}=    Set Variable    --NO_lockfile --ignore_slaves --ask_for_password --clean_to_default
    ${command}=    Set Variable
    ...  echo oZPS0POrRieRtu | python ${yaft_path} --ip ${ip_address} ${yaft_params} -z ${build_package}
    Log To Console    ${command}
    ${output}=    OperatingSystem.Run     ${command}
    ${flash_flag}=    Run Keyword And Return Status    Should Contain    ${output}    Flashing done
    ${reboot_flag}=   Run Keyword And Return Status    Should Contain    ${output}    Waiting for FC* after reboot
    Run Keyword If    ${flash_flag} or ${reboot_flag}    Log To Console    yaft success! with msg ${output}
    ...    ELSE    Fail    yaft failed! with msg ${output}

Get Enb Current Build Version From BBU
    [Documentation]  This keyword gets enb build version from bbu
    [Arguments]    ${ip_address}=192.168.255.129
    admin.connect_to   bts_host=${ip_address}    bts_port=443    name=coam_admin
    ${sw_version}    admin.Get Sw Version    timeout=30    connection=coam_admin
    Log To Console    sw version: ${sw_version}
    admin.teardown    connection=coam_admin
    Should Not Be Empty  ${sw_version}

    [Return]   ${sw_version}

Get Enb Latest Build Version From Git
    [Documentation]    this keyword gets latest enb build version from 5g-commission.git
    [Arguments]        ${build_version}

    ${commission_dir}=   tl_configuration.get_full_commission_dir
    ${testline_name}=    tl_configuration.get_testline_name
    ${latest_build}=     Get Tl Enb Latest Load    ${commission_dir}    ${testline_name}    ${build_version}
    Log To Console    latest build version: ${latest_build}
    [Return]   ${latest_build}

Get Enb Commission From Git
    [Documentation]    this keyword returns the local path of the ${build_version} commission file
    [Arguments]        ${build_version}

    ${commission_dir}=   tl_configuration.get_full_commission_dir
    ${testline_name}=    tl_configuration.get_testline_name
    ${commission}=    Set Variable    ${commission_dir}/${testline_name}/${build_version}/${testline_name}_enb.xml
    OperatingSystem.Should Exist    ${commission}
    Log To Console    enb commission: ${commission}
    [Return]   ${commission}

Get Enb Asir Commission From Git
    [Documentation]    this keyword returns the local path of the ${build_version} asir commission file
    [Arguments]        ${build_version}

    ${commission_dir}=   tl_configuration.get_full_commission_dir
    ${testline_name}=    tl_configuration.get_testline_name
    ${commission}=    Set Variable    ${commission_dir}/${testline_name}/${build_version}/${testline_name}_enb_asirmgr.xml
    OperatingSystem.Should Exist    ${commission}
    Log To Console    enb asir commission: ${commission}
    [Return]   ${commission}

Perform Enb Asir Commission Fullfile
    [Documentation]    This keyword performs asir commission file
    [Arguments]
    ...            ${asir_commission}
    ...            ${asicli_dir}=/opt/enb/asir
    ...            ${ip_address}=192.168.255.129
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output
    ...    ${asicli_dir}/scripts/commission.sh -ne ${ip_address} -pw Nemuadmin:nemuuser -fullfile \"${asir_commission}\"
    Should Be Equal As Integers	${rc}    0
    Log To Console    ${output}
    Should Contain    ${output}    cli finished successfully
