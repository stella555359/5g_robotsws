*** Settings ***
Documentation     Keywords related to UTE Cloud Testline handling

Library    OperatingSystem
Library    String
Resource   ./connect.robot
Resource   ./gnb.robot
Resource   ./testline.robot
Resource   ./installation.robot
Resource   ./wts_ue.robot
Resource   ./core.robot
Library    ./python/ute_workarounds.py

*** Variables ***
${P_AP_STREAM}        None
${AP_URL}    https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone
@{IP_LIST}    10.0.1.121    10.0.1.131    10.0.1.132    10.0.1.133    10.0.1.134    10.0.1.135    10.0.1.136    10.0.1.137

*** Keywords ***

UTE Cloud Workaround
    [Documentation]    :Author: Jing Liang
    ...    To be used as FRIST keyword in Suite Setup
    ...    patch testline configure with missing configuration, update AirphoneConfig.xml name in basic_setup.cfg
    ...    to add other IPs on test VM, you can define @{IP_LIST} in your testsuite Variables part
    ...    [Temporary] Used for UTE Cloud Airphone TL
    ...
    ${core_obj}    Get Variable Value    ${tl.core}
    Run Keyword If    '${core_obj}'!='None'    Run Keywords
    ...    Configure core IP addresses on WTS host    AND
    ...    Return From Keyword
    Patch testline configuration for UTE Cloud
    Configure core IP addresses on WTS host
    ${file_exist}=    WTS Config Files Are Present
    Run Keyword If    ${file_exist}    wts_ue.Update AirPhoneConfig file name in WTS Config    file_name=AirphoneConfig.xml
    ...    ELSE    BuiltIn.Log    default WTS config file not found    WARN

Bring Airphone TL to on Air status without reboot
    [Documentation]    :Author: Jing Liang
    ...    This keyword is used for Suite Setup, which need gnb on air as pre-condition without GNB reboot
    ...    by default, gNbCuType both will be handled as SA TL
    ...    :param remove_logs:   remove existing wts logs                     default=${False}
    ...    :param cfg_file:      path of wts config file to be used           default=${tl.core.cfg_filename}
    ...    :param force_cu_type:   define SA / NSA TL if gNbCuType is configured as SA+NSA    default=SA+NSA
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA
    gnb.Wait until F1 link up    timeout=10min
    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Verify Cell Setup

Bring Airphone TL to on Air status
    [Documentation]    :Author: Jing Liang
    ...    This keyword is used for testcases, which need gnb on air as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...    by default, gNbCuType both will be handled as SA TL
    ...    **Example:**
    ...    |    Run Keyword If    '${PREV_TEST_STATUS}'=='FAIL'    Bring Airphone TL to on Air status
    ...
    ...    :param remove_logs:   remove existing wts logs                     default=${False}
    ...    :param cfg_file:      path of wts config file to be used           default=${tl.core.cfg_filename}
    ...    :param force_cu_type:   define SA / NSA TL if gNbCuType is configured as SA+NSA    default=SA+NSA
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA
    Bring Airphone TL to F1 up status
    Configure WTS for UTE Cloud Airphone TL    remove_logs=${remove_logs}    cfg_file=${cfg_file}    force_cu_type=${force_cu_type}
    Verify Cell Setup

Bring Airphone TL to F1 up status
    [Documentation]    :Author: Jing Liang
    ...    This keyword is used for testcases, which need gnb and ap correctly startup as pre-condition
    ...    or this keyword can be used as testline recovery once testcase failed
    ...    **Example:**
    ...    |    Run Keyword If    '${PREV_TEST_STATUS}'=='FAIL'    Bring Airphone TL to F1 up status
    ...
    [Arguments]    ${timeout}=10min
    core.Kill previous WTS services
    Wait Until Keyword Succeeds    3x    30 sec    Run Keywords
    ...     wts_ue.Reset Airphone Testline                    AND
    ...     Wait For Minimum Required State For Cell Setup    timeout=${timeout}    AND
    ...     gnb.Wait until F1 link up    timeout=${timeout}

Prepare TL for TTITraces
    [Documentation]    :Author: Nikolay Shkulepov
    ...    This keyword helps to download and install MULTI packages needed for TTITraces
    ...
    ute_workarounds . Install Multidynamic if neeeded


### PRIVATE ###

Configure core IP addresses on WTS host
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL, require core obj in testline config
    ${core_alias}=    connect.Connect to Core
    FOR    ${ip}    IN    @{IP_LIST}
        Configure IP for eth3 on VM    alias=${core_alias}    ip=${ip}
    END
Configure IP for eth3 on VM
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE][Temporary] Used for UTE Cloud Airphone TL
    [Arguments]    ${alias}    ${ip}
    ssh.execute    sudo ip addr add ${ip}/24 dev eth3    connection=${alias}
    ${output}=    ssh.execute    ip add | grep ${ip}    connection=${alias}
    Should Contain    ${output}    ${ip}

Patch testline configuration for UTE Cloud
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL
    testline.Get Testline Name
    Import Variables    ${CURDIR}/config/ute_cloud_ap_config.py

WTS Config Files Are Present
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL
    ...    :return ${True} if wts config files are prepared by UTE agent, ${False} if they are not found
    ${core_alias}=    connect.Connect to Core
    ${wts_config_exists}=    ssh.File Exists    ${tl.core.dir_path}/${tl.core.cfg_filename}    connection=${core_alias}
    ${airphone_xml_exists}=    ssh.File Exists    ${tl.core.dir_path}/AirphoneConfig.xml    connection=${core_alias}
    Return from Keyword If    ${wts_config_exists} and ${airphone_xml_exists}    ${True}
    Return from Keyword    ${False}

# AP Gerrit

Download Airphone config files from Gerrit
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL
    ...
    ...    :param file_name: file name, must match file in Airphone Gerrit, check link
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=tree;f=global_configs/streams;hb=HEAD
    ...
    [Arguments]    ${file_name}
    ${ap_version}=    testline.Get Airphone SW version
    ${stream}=    Get Airphone Gerrit Stream
    ${gnb_branch}=    Get gNB SW Branch
    ${file_link}=    Catenate    SEPARATOR=/
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=blob_plain;f=global_configs/streams
    ...    ${gnb_branch}/${stream}/${file_name};hb=refs/tags/${ap_version}
    ${file}=    Download file from Gerrit link    file_name=${file_name}    file_link=${file_link}
    Return From Keyword If    '${file}'!='None'    ${file}
    BuiltIn.Log    message=${file_link} doesn't exist    level=DEBUG
    ${file_link}=    Catenate    SEPARATOR=/
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=blob_plain;f=global_configs/streams
    ...    ${gnb_branch}/${stream}/${file_name}
    ${file}=    Download file from Gerrit link    file_name=${file_name}    file_link=${file_link}
    [Return]    ${file}

Download file from Gerrit link
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE] Used for UTE Cloud Airphone TL
    [Arguments]    ${file_name}    ${file_link}
    ${rc}   Run And Return Rc    curl -k -s "${file_link}" > /tmp/${file_name}
    Should Be Equal As Integers     ${rc}   0    msg=No access to ${file_link}
    ${file}     OperatingSystem.Get File    /tmp/${file_name}
    # if qt file not exists, curl returns html page containing "Cannot find file"
    ${status}=    Run Keyword and Return Status    Should Not Contain      ${file}     Cannot find file
    Return From Keyword If    ${status}    /tmp/${file_name}
    [Return]    None

Set Airphone Gerrit Stream
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    base on variables to build AP Gerrit stream name
    ...    https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/AIRPHONE/QT/config.git;a=tree;f=global_configs/streams;hb=HEAD
    ${gNbCuType}=    Get gNbCuType Info
    ${cellTechnology}=    Get cellTechnology Info
    ${stream}=    Set Variable If
    ...    '${gNbCuType}'=='NSA' and '${cellTechnology}'=='TDD'    fs_tdd_nsa_cmwv
    ...    '${gNbCuType}'=='NSA' and '${cellTechnology}'=='FDD'    fs_fdd_nsa_cmwv
    ...    '${gNbCuType}'=='SA' and '${cellTechnology}'=='TDD'     l1b_tdd_sa_cmwv
    ...    '${gNbCuType}'=='SA' and '${cellTechnology}'=='FDD'     fs_fdd_sa_cpri_cmwv_ASIB_ABIL
    Set Suite Variable    ${P_AP_STREAM}    ${stream}

Get Airphone Gerrit Stream
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    Run Keyword If    '${P_AP_STREAM}'=='None'    Set Airphone Gerrit Stream
    [Return]    ${P_AP_STREAM}

# WTS handling

Configure WTS for UTE Cloud Airphone TL
    [Documentation]    :Author: Jing Liang
    ...    [Temporary][PRIVATE] Used for UTE Cloud Airphone TL,
    ...    by default, gNbCuType both will be handled as SA TL
    ...
    ...    :param remove_logs:   remove existing wts logs                     default=${False}
    ...    :param cfg_file:      path of wts config file to be used           default=${tl.core.cfg_filename}
    ...    :param force_cu_type:   define SA / NSA TL if gNbCuType is configured as SA+NSA    default=SA+NSA
    ...
    [Arguments]    ${remove_logs}=${False}    ${cfg_file}=${tl.core.cfg_filename}    ${force_cu_type}=SA+NSA
    ${scf_cu_type}=    Get gNbCuType Info
    ${gNbCuType}=    Set Variable If    '${scf_cu_type}'=='SA+NSA' or '${scf_cu_type}'=='both'    ${force_cu_type}    ${scf_cu_type}
    wts_ue.Start WTS for Airphone    remove_logs=${remove_logs}
    Run Keyword If    '${gNbCuType}'=='NSA'    Configure WTS with X2 link    cfg_file=${cfg_file}
    ...    ELSE IF    '${gNbCuType}'=='SA'    wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType1-NR updated    timeout=600
    ...    cfg_file=${cfg_file}
    ...    ELSE IF    '${gNbCuType}'=='SA+NSA'    Run Keywords
    ...    wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType1-NR updated
    ...    timeout=600    cfg_file=${cfg_file}
    ...    AND    wts_ue.Setup X2 Link
    ...    ELSE    Fail   not supported TL type

Configure WTS with X2 link
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE] used for NSA Test Case
    ...    :param cfg_file:      path of wts config file to be used           default=${tl.core.cfg_filename}
    [Arguments]    ${cfg_file}=${tl.core.cfg_filename}
    wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType2 updated    cfg_file=${cfg_file}
    wts_ue.Setup X2 Link

Verify Cell Setup
    [Documentation]    :Author: Jing Liang
    ...    Used for UTE Cloud Airphone TL
    gnb.Wait until gNB to be onair state    timeout=2 min
    ${status}    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1 min    20 sec    wts_ue.Check APL3 Log Ensure Cells Setup Successful
    Run Keyword If    ${status} == False
    ...    Wait Until Keyword Succeeds    1 min    20 sec    wts_ue.Check Current Egate Console Status    Cell Setup completed

SCTP WA for PR503508
    [Documentation]    :Author: Jing Liang
    ...    run these line of codes in AP_ASIK and WTS VM every time reboot the machine, This should handle the timeout issue
    ...    [PRIVATE] this is for airphone testline with irfhead, to overcome testline instability
    ${sa_nsa}=    wts_ue.Get gNbCuType Info
    ${sack_timeout}=    Set Variable If    '${sa_nsa}'=='NSA'    20    10
    ${cmds}=    Catenate    SEPARATOR=;
    ...    sudo sysctl -w net.sctp.rto_min=200
    ...    sudo sysctl -w net.sctp.rto_initial=200
    ...    sudo sysctl -w net.sctp.rto_max=800
    ...    sudo sysctl -w net.sctp.sack_timeout=${sack_timeout}
    ${testpc_alias}=    connect.Connect to TestPC
    ssh.execute    command=${cmds}    connection=${testpc_alias}
    ${cmds}=    Catenate    SEPARATOR=;
    ...    sysctl -w net.sctp.rto_min=200
    ...    sysctl -w net.sctp.rto_initial=200
    ...    sysctl -w net.sctp.rto_max=800
    ...    sysctl -w net.sctp.sack_timeout=${sack_timeout}
    ${ap_alias}=    connect.Connect to Airphone Common Unit
    ssh.execute    command=${cmds}    connection=${ap_alias}
