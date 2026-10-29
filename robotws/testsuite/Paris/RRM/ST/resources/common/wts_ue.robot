*** Settings ***

Documentation     Keywords related to Airphone handling

Library     String
Library     OperatingSystem
Library     ute_wtssim
Library     XML
Library     taf.config.scf    WITH NAME    scf
Library     taf.config.wts    WITH NAME    wts
Library     ./python/wts_ue.py  WITH NAME  wts_tools
Resource    ./gnb.robot
Resource    ./installation.robot
Resource    ./testline.robot
Resource    ./connect.robot
Resource    ./util.robot


*** Variables ***

${P_ORIG_WTS_CONFIG}     None
${P_ORIG_AP_CONFIG}      None
${P_ORIG_AP_SWCONFIG}    None
${P_gNbCuType}           None
${P_cellTechnology}      None
${P_nrarfcn}             None
${P_console}             ${False}    # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***

Kill WTS services
    [Documentation]    Author: Jing Liang
    ...    keyword is used to terminate dedicated WTS service and ute_wtssim alias together
    ...    core.Kill previous WTS services is only used to terminate single WTS service for Viavi
    ...    terminate egate and edaemon services by using given port id
    ...    teardown ute_wtssim alias by using given alias name
    ...    :param egate_port: used egate port    (default ${tl.core.egate_port})
    ...    :param edaemon_port: used edaemon port    (default ${tl.core.edaemon_port})
    ...    :param wts_alias: used ute_wtssim alias for egate console    (default in common keyword ap_egate)
    ...    :param edaemon_alias: used ute_wtssim alias for edaemon    (default in common keyword ap_edaemon)
    ...
    ...    **Example:**
    ...    | wts_ue.Kill WTS services    egate_port=10000    edaemon_port=22222    wts_alias=wts1    edaemon_alias=edaemon1
    ...
    [Arguments]    ${egate_port}=${tl.core.egate_port}    ${edaemon_port}=${tl.core.edaemon_port}
    ...    ${wts_alias}=ap_egate    ${edaemon_alias}=ap_edaemon
    BuiltIn.Log    Kill WTS services with egate port: ${egate_port}, edaemon port: ${edaemon_port}    console=${P_console}
    ${ssh_alias}=   connect.Connect to Core
    ssh.send_command    command=sudo pkill -f './egate.* --port ${egate_port}'    connection=${ssh_alias}
    ssh.send_command    command=sudo pkill -f './edaemon.* --port ${edaemon_port}'    connection=${ssh_alias}
    Sleep  1s
    ssh.send_command    command=sudo pkill -9 -f './egate.* --port ${egate_port}'    connection=${ssh_alias}
    ssh.send_command    command=sudo pkill -9 -f './edaemon.* --port ${edaemon_port}'    connection=${ssh_alias}
    Teardown Egate Connection for Airphone    wts_alias=${wts_alias}
    Teardown Edaemon Connection for Airphone    edaemon_alias=${edaemon_alias}
    BuiltIn.Log    WTS services are killed!    console=${P_console}


Reboot Airphone via Console
    [Documentation]    :Author: Jing Liang
    ...    soft reboot Airphone
    ...    :param ue_id:             Id of UE                       [0.. ]  default=0
    ...
    ...    **Example:**
    ...    | wts_ue.Reboot Airphone via Console    ue_id=0
    ...
    [Arguments]    ${ue_id}=0
    ${ap_alias}=    Wait Until Keyword Succeeds    3 min    10 sec     connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=0
    ssh.send command    set -m ; system-module-reboot    connection=${ap_alias}


Reset Airphone Testline
    [Documentation]    :Author: Jing Liang
    ...    this is for airphone testline with irfhead, to overcome testline instability
    [Arguments]    ${gnb_id}=0    ${ue_id}=0
    # reboot AirPhone before gNB (needed for ASIL/ABIO TLs to come up)
    Reboot Airphone via Console    ue_id=${ue_id}
    gnb.Reboot gNB System Module via Console    gnb_id=${gnb_id}
    gnb.Wait until all DUs up    gnb_id=${gnb_id}    timeout=6min
    installation.Wait until Airphone board ready    ue_id=${ue_id}    timeout=3min


Reset Wts Cfg
    [Documentation]    :Author: Jeissel Flores
    ...    Reset Cfg of Wts egate controller
    Send Egate Command and Verify Output    cmd=re


Start WTS for Airphone
    [Documentation]    :Author: Jing Liang
    ...    Used for Precondition: GNB and Airphone, at Suite Setup or Testcase setup
    ...    Will setup egate alias ap_egate for keyword "Send Egate Command and verify output"
    ...    previous WTS processes should be killed at earlier step, before TL reboot
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :param edaemon_alias: alias name to handle edaemon for ute_wtssim    default=ap_edaemon
    ...    :param remove_logs:   remove existing wts logs    default=${False}
    ...    :param egate_port: used egate port    (default ${tl.core.egate_port})
    ...    :param edaemon_port: used edaemon port    (default ${tl.core.edaemon_port})
    ...
    ...    **Example:**
    ...    | core.Kill previous WTS services
    ...    | wts_ue.Start WTS for Airphone    wts_alias=ap_egate
    ...
    [Arguments]    ${wts_alias}=ap_egate    ${edaemon_alias}=ap_edaemon    ${remove_logs}=${False}
    ...    ${egate_port}=${tl.core.egate_port}    ${edaemon_port}=${tl.core.edaemon_port}
    Teardown Egate Connection for Airphone    wts_alias=${wts_alias}
    Teardown Edaemon Connection for Airphone    edaemon_alias=${edaemon_alias}
    ${core_alias}=    connect.Connect to Core
    Run keyword if    ${remove_logs}    ssh.execute    cd ${tl.core.dir_path} && sudo rm *log*    connection=${core_alias}
    ssh.execute    cd ${tl.core.dir_path} && sudo .\\/edaemon --port ${edaemon_port}    connection=${core_alias}
    ssh.execute    cd ${tl.core.dir_path} && .\\/egate --port ${egate_port}    connection=${core_alias}
    Sleep    2s    reason=wait for WTS startup
    ute_wtssim.setup_egate    egate_port=${egate_port}  host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    tool_dir=${tl.core.dir_path}  alias=${wts_alias}
    ute_wtssim.setup_edaemon    edaemon_port=${edaemon_port}  host_ip=${tl.core.default_ssh_connection_details.addr}
    ...    tool_dir=${tl.core.dir_path}  alias=${edaemon_alias}
    ${wts_status}=    Run Keyword and Return Status
    ...    Send Egate Command and verify output    cmd=sim_info    pass_regexp=Process ID    wts_alias=${wts_alias}
    Run Keyword If    ${wts_status} == False    Fail    WTS is not correctly started


Collect egate log files
    [Documentation]    Author: Vasileios Papoutsis
    ...    Run keyword before egate teardown
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param wts_alias:    alias name to handle egate for ute_wtssim    default=ap_egate
    ...
    [Arguments]    ${target_dir}=None    ${wts_alias}=ap_egate
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ute_wtssim.collect_egate_log_files    unzip=${False}    subdirectory=${target_dir}    alias=${wts_alias}


Collect edaemon log files
    [Documentation]    Author: Vasileios Papoutsis
    ...    Run keyword before edaemon teardown
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param edaemon_alias:    alias name to handle edaemon for ute_wtssim    default=ap_edaemon
    ...
    [Arguments]    ${target_dir}=None    ${edaemon_alias}=ap_edaemon
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ute_wtssim.collect edaemon log files    unzip=${False}    subdirectory=${target_dir}    alias=${edaemon_alias}


Collect sos report logs
    [Documentation]    Author: Vasileios Papoutsis
    ...    Sos report logs are needed in case of opening airphone pronto
    ...
    ...    :param target_dir:   directory to store the journal file
    ...    :param script_path:  path where sosReport.sh is located (default: ${tl.core.dir_path})
    ...
    [Arguments]    ${target_dir}=None    ${script_path}=${tl.core.dir_path}
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${core_alias}=    connect.Connect to Core
    ssh.execute    cd ${script_path}; ./sosReport.sh -c -s -nr -iphyDIR\=${tl.core.dir_path} -btsDIR\=${tl.core.dir_path}    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/iphyPsSnapshot.zip    local_path=${target_dir}/iphyPsSnapshot.zip
    ...    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/btsSnapshot.zip    local_path=${target_dir}/btsSnapshot.zip
    ...    connection=${core_alias}
    ssh.Download File    remote_path=${tl.core.dir_path}/sosReport.sh.log    local_path=${target_dir}/sosReport.sh.log
    ...    connection=${core_alias}
    ${sos_report_file}=    util.Get latest modified file with defined pattern    path=${script_path}    pattern=SosReport*_complete_iphy1.tgz
    ssh.Download File    remote_path=${script_path}/${sos_report_file}    local_path=${target_dir}/${sos_report_file}
    ...    connection=${core_alias}


Modify SosReport config
    [Documentation]    Author: Noli Valdez III
    ...     Modify SosReport.cfg to proper value
    ...
    ...    :param script_path:  path where sosReport.sh is located (default: ${tl.core.dir_path})
    ...    :param LONER_VERSION: e.G D for loner newer than loner_R51-TDD-CPRI.0.0.20190624-100816, for other cases.
    ...                          Can be A/B/C/D/E, depend on your loner version, check help from start script for more information.
    ...    :param PHONER_VERSION: default PH4 for phoner newer than Phoner_R54_2019_w46_01, for other cases, check help from start script
    ...                           Can be PH2 / PH4 / PH7
    ...    :param L1_MODE: Depend on your configuration choose l1bypass or fullstack
    ...
    [Arguments]    ${LONER_VERSION}=X    ${PHONER_VERSION}=X    ${L1_MODE}=X    ${script_path}=${tl.core.dir_path}

    ${sos_cfg}    Catenate    ${script_path}/sosReport.cfg

    ${core_alias}=    connect.Connect to Core

    ${command1}    Catenate    sed -ri 's@(LONER_VERSION\=)(.*)@\\1${LONER_VERSION}@' ${sos_cfg}
    ${command2}    Catenate    sed -ri 's@(PHONER_VERSION\=)(.*)@\\1${PHONER_VERSION}@' ${sos_cfg}
    ${command3}    Catenate    sed -ri 's@(L1_MODE\=)(.*)@\\1${L1_MODE}@' ${sos_cfg}

    ssh.execute    ${command1}; ${command2}; ${command3}    connection=${core_alias}


Teardown Egate Connection for Airphone
    [Documentation]    :Author: Jing Liang
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown
    ...    used as teardown keyword for Start WTS for Airphone
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Teardown Egate Connection for Airphone
    ...
    [Arguments]    ${wts_alias}=ap_egate
    Run Keyword and Ignore Error    ute_wtssim.teardown_egate    alias=${wts_alias}


Teardown Edaemon Connection for Airphone
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown
    ...    used as teardown keyword for Start WTS for Airphone
    ...    :param edaemon_alias:     alias name to handle edaemon for ute_wtssim    default=ap_edaemon
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Teardown Edaemon Connection for Airphone
    ...
    [Arguments]    ${edaemon_alias}=ap_edaemon
    Run Keyword and Ignore Error    ute_wtssim.teardown_edaemon    alias=${edaemon_alias}


Config WTS for Airphone
    [Documentation]    :Author: Jing Liang
    ...    used for UTE Workaround keyword,
    ...    Configure WTS with default config file in __init__.py
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :param cfg_file:      path of wts config file to be used           default=${tl.core.cfg_filename}
    ...
    ...    **Example:**
    ...    NSA TL
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType2 updated
    ...    SA TL
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone    pass_regexp=SystemInformationBlockType1-NR updated    timeout=600
    ...
    [Arguments]    ${pass_regexp}=${None}    ${timeout}=30    ${wts_alias}=ap_egate    ${cfg_file}=${tl.core.cfg_filename}
    ute_wtssim.execute egate command and wait for data    cmd=cfg file=${cfg_file}    pass_regexp=${pass_regexp}
    ...    timeout=${timeout}    alias=${wts_alias}


Send Egate Command and verify output
    [Documentation]    :Author: Jing Liang
    ...    same as keyword ute_wtssim.execute egate command and wait for data
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...    :param cmd: (string) – Command to execute.
    ...    :param timeout: Timeout for this operation. Default is 10 seconds
    ...    :param return_output: (${False} or ${Ture} boolean) - Flag indicating whether egate log should be printed out. Default is True.
    ...    :param pass_regexp: (string) - Regexp indicating that the command passed.
    ...    :param wts_alias:     alias name to handle egate for ute_wtssim    default=ap_egate
    ...    :return output: egate console output
    ...
    ...    **Example:**
    ...    | wts_ue.Start WTS for Airphone
    ...    | wts_ue.Config WTS for Airphone
    ...    | wts_ue.Send Egate Command and verify output    cmd=sim_state_disp    pass_regexp=The state is ACTIVE
    ...
    [Arguments]    ${cmd}    ${timeout}=10    ${return_output}=${True}    ${pass_regexp}=${None}    ${wts_alias}=ap_egate
    ${output}=    ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    timeout=${timeout}    return_output=${return_output}    alias=${wts_alias}
    [Return]    ${output}


Store Current WTS Config
    [Documentation]    :Author: Jing Liang
    ...    collect current WTS config file and Set path as Suite Variable ${P_ORIG_WTS_CONFIG}
    ...    :param target_dir: where to save original WTS config, default with testline.Get Test Suite Config Directory
    ...
    [Arguments]    ${target_dir}=None
    ${ORIG_WTS_CONFIG}=    Get WTS Config    target_dir=${target_dir}
    Run    mv ${ORIG_WTS_CONFIG} ${ORIG_WTS_CONFIG}.orig
    Set Suite Variable    ${P_ORIG_WTS_CONFIG}    ${ORIG_WTS_CONFIG}.orig


Get WTS Config
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param target_dir: where to save WTS config, default with testline.Get Test Suite Config Directory
    ...
    [Arguments]    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${core_alias}=    connect.Connect to Core
    ssh.Download File    remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}    local_path=${target_dir}/${tl.core.cfg_filename}
    ...    connection=${core_alias}
    [Return]    ${target_dir}/${tl.core.cfg_filename}


Store Current AP Config
    [Documentation]    :Author: Vasileios Papoutsis
    ...    collect current AP config file and Set path as Suite Variable ${P_ORIG_AP_CONFIG}
    ...    :param target_dir: where to save original WTS config, default with testline.Get Test Suite Config Directory
    ...
    [Arguments]    ${target_dir}=None
    ${ORIG_AP_CONFIG}=    Get AP Config    target_dir=${target_dir}
    Run    mv ${ORIG_AP_CONFIG} ${ORIG_AP_CONFIG}.orig
    Set Suite Variable    ${P_ORIG_AP_CONFIG}    ${ORIG_AP_CONFIG}.orig


Get AP Config
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param target_dir: where to save AP config, default with testline.Get Test Suite Config Directory
    ...
    [Arguments]    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${core_alias}=    connect.Connect to Core
    ssh.Download File    remote_path=${tl.core.dir_path}/AirphoneConfig.xml    local_path=${target_dir}/AirphoneConfig.xml
    ...    connection=${core_alias}
    [Return]    ${target_dir}/AirphoneConfig.xml


Reload Stored WTS Config
    [Documentation]    :Author: Jing Liang
    ...    bring back Keyword "Store Current WTS config" collected WTS config file
    ...
    ...    **Example:**
    ...    | wts_ue.Store Current WTS Config
    ...    | wts_ue.Reload Stored WTS Config
    ...
    ${core_alias}=    connect.Connect to Core
    ssh.Upload File    local_path=${P_ORIG_WTS_CONFIG}    remote_path=${tl.core.dir_path}/${tl.core.cfg_filename}    connection=${core_alias}


Reload Stored AP Config
    [Documentation]    :Author: Vasileios Papoutsis
    ...    bring back Keyword "Store Current AP config" collected AP config file
    ...
    ...    **Example:**
    ...    | wts_ue.Store Current AP Config
    ...    | wts_ue.Reload Stored AP Config
    ...
    ${core_alias}=    connect.Connect to Core
    ssh.Upload File    local_path=${P_ORIG_AP_CONFIG}    remote_path=${tl.core.dir_path}/AirphoneConfig.xml    connection=${core_alias}


Upload Customized WTS Config
    [Documentation]    :Author: Jing Liang
    ...    upload customized WTS config file to WTS folder, if Store Current WTS Config has not been called before, will be used here
    ...    if param update_config=True, update arfcn based on gnb scf, update used AirPhoneConfig file name based on current WTS config
    ...    :param config_path: location of feature related WTS config file
    ...    :param remote_cfg: can be used if multiple WTS config needed (default ${tl.core.cfg_filename})
    ...    :param update_config: (default False)
    ...
    ...    **Example:**
    ...    | wts_ue.Upload Customized WTS Config    config_path=absolut_path/basic_wts.cfg    remote_cfg=basic_wts.cfg    update_config=True
    ...
    [Arguments]    ${config_path}    ${remote_cfg}=${tl.core.cfg_filename}    ${update_config}=False
    ${core_alias}=    connect.Connect to Core
    Run Keyword If    '${P_ORIG_WTS_CONFIG}'=='None'    Store Current WTS Config
    ${ap_file_name}=    Get AirPhoneConfig file name from WTS Config
    ssh.Upload File    local_path=${config_path}    remote_path=${tl.core.dir_path}/${remote_cfg}    connection=${core_alias}
    Return From Keyword If    not ${update_config}
    Update ARFCN in WTS Config    remote_cfg=${remote_cfg}
    Update AirPhoneConfig file name in WTS Config    file_name=${ap_file_name}    remote_cfg=${remote_cfg}


Upload Customized AirPhoneConfig
    [Documentation]    :Author: Jing Liang
    ...    upload customized AirPhoneConfig file to WTS folder, by default will be renamed as AirphoneConfig.xml
    ...
    ...    :param config_path: location of feature related AirPhoneConfig file
    ...    :param rename: (default True, False) by default will be renamed as AirphoneConfig.xml, False will keep using the file name
    ...
    ...    **Example:**
    ...    | wts_ue.Upload Customized AirPhoneConfig    config_path=absolut_path/AirphoneConfig.xml
    [Arguments]    ${config_path}    ${rename}=True
    ${core_alias}=    connect.Connect to Core
    Run Keyword If    '${P_ORIG_WTS_CONFIG}'=='None'    Store Current WTS Config
    ${ap_file_name}=    Run Keyword If    ${rename}    Get AirPhoneConfig file name from WTS Config
    ...    ELSE    Set Variable    ${config_path.split('/')[-1]}
    ssh.Upload File    local_path=${config_path}    remote_path=${tl.core.dir_path}/${ap_file_name}    connection=${core_alias}


Get Average Data Rate via Egate
    [Documentation]    :Author: Jing Liang
    ...    check Average Data Rate during throughput test
    ...    :param ue_id:             Id of UE in WTS                [1.. ]
    ...    :param dir:               Direction                      [ul|dl|bi] default bi
    ...    :param trf_id:            Id or Ids of Traffic           [1..20+] default all
    ...    :param kwargs:            dictionary of pairs "parameter:value" (e.g. id=2)
    ...
    ...    **Example:**
    ...    | ${data_rate}=    wts_ue.Get Average Data Rate via Egate    ue_id=1    id=2    dir=dl    trf_id=1
    ...    | Verify Throughput    ${data_rate}    # Keyword doesn't exist
    ...
    [Arguments]    ${ue_id}    ${dir}=bi    ${trf_id}=all    &{kwargs}
    ${dc_cell_group}=    Set Variable If    '${dir}' == 'dl'    scg    all
    ${output}=    Display bearer stats    ue_id=${ue_id}    direction=${dir}    trf_id=${trf_id}    type=l3
    ...    dc_cell_group=${dc_cell_group}    &{kwargs}
    ${data_rate}=    Get Average Data Rate from Egate output    ${output}
    ${data_rate}=    Convert to Integer    ${data_rate}
    [Return]    ${data_rate}


Store Current swconfig from Airphone
    [Documentation]    :Author: Jing Liang
    ...    in case testcase needs to modify swconfig.txt on Airphone, collect current one as backup, Set path as Suite Variable ${P_ORIG_AP_SWCONFIG}
    ...
    ...    :param ue_id:      Id of ue                       [0.. ]  default=0
    ...    :param comu_id:    Id of Common Unit              [0..1]  default=0
    ...    :param target_dir: where to save original swconfig.txt, default with testline.Get Test Suite Config Directory
    ...
    ...    **Example:**
    ...    | wts_ue.Store Current swconfig from Airphone
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${ORIG_SWCONFIG}=    Get swconfig from Airphone    ue_id=${0}    comu_id=${0}    target_dir=${target_dir}
    Run    mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_AP_SWCONFIG}    ${ORIG_SWCONFIG}.orig


Get swconfig from Airphone
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...     :param ue_id:         Id of gnb                       [0.. ]  default=0
    ...     :param comu_id:       Id of Common Unit               [0..1]  default=0
    ...     :param target_dir:    (default None) save swconfig to path
    ...
    ...     :return:   swconfig path for further usage
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}    ${target_dir}=None
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Test Suite Config Directory
    ...    ELSE    Set Variable    ${target_dir}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.Download File    remote_path=/ffs/run/swconfig.txt    local_path=${target_dir}/ap-${ue_id}_swconfig.txt    connection=${ap_alias}
    [Return]    ${target_dir}/ap-${ue_id}_swconfig.txt


Reload stored swconfig to Airphone
    [Documentation]    :Author: Jing Liang
    ...    used for Suite Teardown or Testcase Teardown
    ...    bring back Keyword "Collect swconfig from Airphone" collected swconfig.txt file
    ...
    ...    **Example:**
    ...    | wts_ue.Store Current swconfig from Airphone
    ...    | wts_ue.Reload stored swconfig to Airphone
    ...
    ...    :param ue_id:       Id of ue                        [0.. ]  default=0
    ...    :param comu_id:     Id of Common Unit               [0..1]  default=0
    ...
    [Arguments]    ${ue_id}=${0}    ${comu_id}=${0}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${comu_id}
    ssh.Upload File    local_path=${P_ORIG_AP_SWCONFIG}    remote_path=/ffs/run/swconfig.txt    connection=${ap_alias}


Update SW Config file on AP System Module
    [Documentation]    :Author: Vasileios Papoutsis
    ...    This keyword sets the rnd params in the swconfig.txt
    ...    :param param_list:    list the update content, example input can be: ["0x4600BA=6","0x460002=6"]
    ...    :param ue_id:         Id of ue                        [0.. ]  default=0
    ...    :param ue_comu_id:    Id of Common Unit               [0..1]  default=0
    ...
    [Arguments]  ${param_list}  ${ue_id}=${0}  ${ue_comu_id}=${0}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${ue_comu_id}
    swconf.download_swConfig_file_from_asik_to_test_pc    localFilePath=/tmp/swconfig_tmp.txt    asik_alias=${ap_alias}
    swconf.modify_swConfig_file    parametersList=${param_list}    filePath=/tmp/swconfig_tmp.txt
    swconf.upload_swConfig_file_to_asik_and_crasign    localFilePath=/tmp/swconfig_tmp.txt    asik_alias=${ap_alias}


Update ARFCN in WTS Config
    [Documentation]    :Author: Jing Liang
    ...    get NRARFCN from gNB SCF and update this value in WTS config
    ...    :param remote_cfg: target WTS config file name (default ${tl.core.cfg_filename})
    ...
    [Arguments]    ${remote_cfg}=${tl.core.cfg_filename}
    ${scf_value}=    Get nrarfcn Info
    Update WTS config with Regex    regex=nr_arfcn=\\S+    value=nr_arfcn=${scf_value}    remote_cfg=${remote_cfg}


Get AirPhoneConfig file name from WTS Config
    [Documentation]    :Author: Jing Liang
    ...    Get AirPhoneConfig file name from WTS Config
    ...
    ...    :return: used AirPhoneConfig file name
    ${cmd_output}    OperatingSystem.Run    command=grep uec.*file ${P_ORIG_WTS_CONFIG}
    ${file_name}=    String.Get regexp matches    ${cmd_output}    file=(.*xml)   1
    [Return]    ${file_name[0].strip()}


Update AirPhoneConfig file name in WTS Config
    [Documentation]    :Author: Jing Liang
    ...    update WTS Config with given file name
    ...    :param remote_cfg: target WTS config file name (default ${tl.core.cfg_filename})
    ...
    ...    **Example:**
    ...    | wts_ue.Update AirPhoneConfig file name in WTS Config    file_name=AirphoneConfig.xml
    ...
    [Arguments]    ${file_name}    ${remote_cfg}=${tl.core.cfg_filename}
    ${core_alias}=    connect.Connect to Core
    ${output}=    ssh.execute    command=ls ${tl.core.dir_path}/${file_name}    connection=${core_alias}
    Should Contain    ${output}    ${file_name}
    Update WTS config with Regex    regex= file=\\S+    value= file=${file_name}    remote_cfg=${remote_cfg}


Update WTS config with Regex
    [Documentation]    :Author: Jing Liang
    ...    update value in WTS config file by using Regular expression, and verify if value has been correctly updated
    ...    it uses taf.transport.ssh to execute, therefore please use double '\' if you have '\' in arguments
    ...    :param regex:
    ...    :param value:
    ...    :param remote_cfg: target WTS config file name (default ${tl.core.cfg_filename})
    ...
    ...    **Example:**
    ...    | wts_ue.Update WTS config with Regex    regex=nr_arfcn=\\S+    value=nr_arfcn=646000:646000
    ...
    [Arguments]    ${regex}    ${value}    ${remote_cfg}=${tl.core.cfg_filename}
    ${core_alias}=    connect.Connect to Core
    ssh.execute    command=sed -i -E 's/${regex}/${value}/g' ${tl.core.dir_path}/${remote_cfg}
    ...    connection=${core_alias}
    ${output}=    ssh.execute    grep ${value} ${tl.core.dir_path}/${remote_cfg}    connection=${core_alias}
    Should Contain    ${output}    ${value}


Modify AirPhoneConfig element values
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Modify the element values in AirphoneConfig.xml file
    ...
    ...    :param elements: Dictionary with path of element as dictionary key and the value as dictionary value
    ...
    ...    **Example:**
    ...    &{MOD_AP_CONFIG_ELEM}    testModeTAConfig/testModeTA[@index\="0"]/nbRepetitionsTaSimulation=255
    ...                             testModeTAConfig/testModeTA[@index\="0"]/ueSpeed=30
    ...                             testModeTAConfig/testModeTA[@index\="0"]/uePositionDelayMax_ts=288
    ...                             testModeTAConfig/testModeTA[@index\="0"]/uePositionDelayInitial_ts=100
    ...
    [Arguments]    ${elements}
    ${AirPhoneConfig}=    Parse XML    source=${tl.core.dir_path}/AirphoneConfig.xml
    FOR    ${element_path}    IN    @{elements.keys()}
        ${value}=    Get From Dictionary    ${elements}    ${element_path}
        Set element text    source=${AirPhoneConfig}    text=${value}    xpath=${element_path}
    END
    Save XML    source=${AirPhoneConfig}    path=${tl.core.dir_path}/AirphoneConfig.xml


Add AirPhoneConfig element values
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Add element values in AirphoneConfig.xml file
    ...
    ...    :param elements: Dictionary with path of element as dictionary key and the value as dictionary value
    ...
    ...    **Example:**
    ...    &{ADD_AP_CONFIG_ELEM}    testModeConfig/testMode[@index\="0"]=<testModeTA associated="true" index="0" xref="0" />
    ...
    [Arguments]    ${elements}
    ${AirPhoneConfig}=    Parse XML    source=${tl.core.dir_path}/AirphoneConfig.xml
    FOR    ${element_path}    IN    @{elements.keys()}
        ${new_element}=    Get From Dictionary    ${elements}    ${element_path}
        ${element}=    Element to string    source=${AirPhoneConfig}    xpath=${element_path}
        ${match}    ${value}=    Run keyword and ignore error    Should not contain    ${element}    ${new_element}
        Run keyword if    '${match}' == 'PASS'    Add element    source=${AirPhoneConfig}    element=${new_element}
        ...    xpath=${element_path}
    END
    Save XML    source=${AirPhoneConfig}    path=${tl.core.dir_path}/AirphoneConfig.xml


Add AirPhoneConfig Element Values with Same Element Path
    [Documentation]    :Author: Jeissel Flores
    ...    Add element values with the same element_path on AirphoneConfig.xml file
    ...    This is needed when array of element values has the same element_path (parent) so the key has to be the array values
    ...    :param elements: Dictionary with value as dictionary key and the value as path of element
    ...
    ...    **Example:**
    ...    &{PROFILE}    <radioLinkFailure index\="2"></radioLinkFailure>=radioLinkFailureConfig
    ...                  <stopHarqTransmission>1</stopHarqTransmission>=radioLinkFailureConfig/radioLinkFailure[@index\="2"]
    ...                  <stopCsiTransmission>0</stopCsiTransmission>=radioLinkFailureConfig/radioLinkFailure[@index\="2"]
    ...
    [Arguments]    ${elements}
    ${AirPhoneConfig}=    Parse XML    source=${tl.core.dir_path}/AirphoneConfig.xml
    FOR    ${new_element}    IN    @{elements.keys()}
        ${element_path}=    Get From Dictionary    ${elements}    ${new_element}
        ${old_element}=    Get Child Elements    source=${AirPhoneConfig}    xpath=${element_path}
        ${match}    ${value}=    Run keyword and ignore error    Should not Contain    ${old_element}    ${new_element}
        Run keyword if    '${match}' == 'PASS'    Add Element    source=${AirPhoneConfig}    element=${new_element}
        ...    xpath=${element_path}
    END
    Save XML    source=${AirPhoneConfig}    path=${tl.core.dir_path}/AirphoneConfig.xml


Get gNbCuType Info
    [Documentation]    :Author: Jing Liang
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    :return: SA or NSA or both
    Run Keyword If    '${P_gNbCuType}'=='None'    Fetch gNB Info from SCF
    [Return]    ${P_gNbCuType}


Get cellTechnology Info
    [Documentation]    :Author: Jing Liang
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    :return: TDD or FDD
    Run Keyword If    '${P_cellTechnology}'=='None'    Fetch gNB Info from SCF
    [Return]    ${P_cellTechnology}


Get nrarfcn Info
    [Documentation]    :Author: Jing Liang
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    :return: in used nrarfcn
    Run Keyword If    '${P_nrarfcn}'=='None'    Fetch gNB Info from SCF
    [Return]    ${P_nrarfcn}


Attach UE to LTE
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Initiates UE Attach procedure to LTE cell
    ...
    ...    :param ue_id:                  ue_id configured in WTS configuration
    ...    :param emergency:              toggle for Emergency Attach (not applicable for NB-IoT UE) (default=off)
    ...    :param pdn_connectivity_type:  IP version of PDN connectivity (default=auto)
    ...    :param kwargs:                 dictionary of pairs "parameter:value" (e.g. profile=1)
    ...
    [Arguments]    ${ue_id}    ${emergency}=off    ${pdn_connectivity_type}=auto    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output
    ...    cmd=ue_attach id=${ue_id} emergency=${emergency} pdn_connectivity_type=${pdn_connectivity_type}${command_args}
    ...    pass_regexp=UE IS ACTIVE
    BuiltIn.Log    UE${ue_id} is attached to LTE    console=${P_console}


Trigger LTE-NR dual connectivity for bearers
    [Documentation]    :Author: Vasileios Papoutsis
    ...    eNB command to trigger LTE-NR dual connectivity for bearers
    ...
    ...    :param ue_id:         ue_id configured in WTS configuration
    ...    :param bearer_id:     bearer id configured in WTS configuration (e.g. 9,8)
    ...    :param target_gnb:    target gNB id (default=2)
    ...    :param target_cells:  target gNB cells (default=2)
    ...    :param type:          type of dual connectivity (default=split_scg)
    ...
    [Arguments]    ${ue_id}    ${bearer_id}    ${target_gnb}=2    ${target_cells}=1    ${type}=split_scg
    Send Egate Command and verify output
    ...    cmd=enb_ue_dc_start ue=${ue_id} bearer=${bearer_id} target_gnb=${target_gnb} target_cells=${target_cells} type=${type}
    ...    pass_regexp=reported successful RA
    BuiltIn.Log    LTE-NR dual connectivity of UE${ue_id} with bearer${bearer_id} to gNB${target_gnb} and cell${target_cells} is successful
    ...    console=${P_console}
    Sleep    1s    reason=wait command to be executed


Trigger LTE-NR dual connectivity modification
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Command to trigger LTE-NR dual connectivity modification
    ...
    ...    :param ue_id:      ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    ...    :param reason:     reason to trigger SgNB modification (default=bearer_to_add)
    ...    :param by:         determines the initiator of the DC procedure (default=enb)
    ...    :param cause:      cause for the DC procedure (default=RN_CauseRadioNetwork_unspecified)
    ...    :param type:       type of dual connectivity (default=split_scg)
    ...
    [Arguments]    ${ue_id}    ${bearer_id}    ${reason}=bearer_to_add    ${by}=enb    ${cause}=RN_CauseRadioNetwork_unspecified
    ...    ${type}=split_scg
    Send Egate Command and verify output
    ...    cmd=enb_ue_dc_modify ue=${ue_id} ${reason}=${bearer_id} by=${by} cause=${cause} type=${type}
    ...    pass_regexp=Bearer-type change .* is successful
    BuiltIn.Log    LTE-NR dual connectivity modification with reason ${reason} for bearer ${bearer_id} is successful    console=${P_console}


Set traffic type
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Command to set traffic type for given UEs and PDU Session Id
    ...
    ...    :param ue_id:                ue_id configured in WTS configuration
    ...    :param pdu_id                specified PDU session ID
    ...    :param trf_type:             specified traffic type (internal|external, default: external)
    ...    :param log_traffic_stats:    specified traffic type (on|off, default: off)
    ...
    [Arguments]    ${ue_id}    ${pdu_id}    ${trf_type}=external    ${log_traffic_stats}=off
    Send Egate Command and verify output
    ...    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type} log_traffic_stats=${log_traffic_stats}
    BuiltIn.Log    Traffic type for UE${ue_id} and PDU${pdu_id} is set to ${trf_type}    console=${P_console}


Start data traffic in egate
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Start data traffic (NSA/SA)
    ...
    ...    :param ue_id:           ue_id configured in WTS configuration
    ...    :param direction:       dl or ul traffic direction
    ...    :param protocol:        L3 protocol type, e.g. udp|tcp|icmp (defailt=udp)
    ...    :param ack_mode:        toggle for receiver to generate an ack, e.g. on|off (default=off)
    ...    :param trf_id:          traffic id, e.g. 1 (default=1)
    ...    :param cl_trf_stats:    toggle for clear L3 statistics for the traffic instance, e.g. on|off (default=on)
    ...    :param kwargs:          dictionary of pairs "parameter:value" (e.g. id=2 or mbps=5 or rtp_codec=custom
    ...                            rtp_ps=32 rtp_ts_step=1000)
    ...
    [Arguments]    ${ue_id}    ${direction}    ${protocol}=udp    ${ack_mode}=off    ${trf_id}=1
    ...    ${cl_trf_stats}=on    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    ${command}=    Catenate
    ...    trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...    protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}${command_args}
    Send Egate Command and verify output    cmd=${command}
    ...    pass_regexp=UE ${ue_id}: ${protocol.upper()} ${direction.upper()} TRF
    BuiltIn.Log    ${direction.upper()} ${protocol.upper()} data for UE${ue_id} and${command_args} is started    console=${P_console}


Stop data traffic in egate
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Stop data traffic (NSA/SA)
    ...
    ...    :param ue_id:       ue_id configured in WTS configuration
    ...    :param direction:   ul|dl|bi traffic direction
    ...    :param trf_id:      traffic id, e.g. 1 (default=1)
    ...    :param kwargs:      dictionary of pairs "parameter:value" (e.g. id=2)
    ...
    [Arguments]    ${ue_id}    ${direction}    ${trf_id}=1    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=trf_data_stop ue=${ue_id} dir=${direction} trf_id=${trf_id}${command_args}
    ...    pass_regexp=${direction.upper()} Traffic was stopped||Stopping .* traffic
    BuiltIn.Log    ${direction.upper()} data for UE${ue_id} and${command_args} is stopped    console=${P_console}


Detach UE from LTE
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Initiates UE or MME-initiated detach procedure from LTE cell
    ...
    ...    :param ue_id:           ue_id configured in WTS configuration
    ...    :param device_type:     device type initiating the detach procedure (default=ue)
    ...    :param type:            type of network initiated (MME) detach procedure (default=not_specified)
    ...    :param ue_detach_type:  type of UE initiated detach procedure (default=automatic)
    ...
    [Arguments]    ${ue_id}    ${device_type}=ue    ${type}=not_specified    ${ue_detach_type}=automatic
    Send Egate Command and verify output    cmd=ue_detach id=${ue_id} ${device_type} type=${type} ue_detach_type=${ue_detach_type}
    ...    pass_regexp=UE${ue_id}: detached
    BuiltIn.Log    UE${ue_id} is detached from LTE    console=${P_console}


Trigger RLF
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Trigger a radio link failure in a UE in dual connectivity
    ...
    ...    :param ue_id:         specified UE id
    ...    :param failure_type:  cause of radio link failure
    ...    :param at:            specifies where UE detected radio link failure (gnb or enb)
    ...
    [Arguments]    ${ue_id}    ${failure_type}    ${at}
    ...            ${pass_regexp}=Successfully reconfigured dual connectivity .* Bearer-type change .* is successful
    Send Egate Command and verify output    cmd=ue_dc_rlf ue=${ue_id} failure_type=${failure_type} at=${at}
    ...    pass_regexp=${pass_regexp}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    RLF for UE${ue_id} is triggered    console=${P_console}


Add bearer
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Activates UE bearers
    ...
    ...    :param ue_id:      ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    ...    :param filter_id:  filter id to add (unique among all filters of the bearer) (default=0)
    ...
    [Arguments]    ${ue_id}    ${bearer_id}    ${filter_id}=0
    Send Egate Command and verify output    cmd=bearer_add ue=${ue_id} id=${bearer_id} filter=${filter_id} precedence=${bearer_id}
    ...    pass_regexp=Bearer-${bearer_id} .* created
    BuiltIn.Log    Bearer ${bearer_id} for UE${ue_id} is added    console=${P_console}


Delete bearer
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Deactivates UE bearers
    ...
    ...    :param ue_id:      ue_id configured in WTS configuration
    ...    :param bearer_id:  bearer id configured in WTS configuration
    ...    :param by:         initiator (default=pgw)
    ...
    [Arguments]    ${ue_id}    ${bearer_id}    ${by}=pgw
    Send Egate Command and verify output    cmd=bearer_del ue=${ue_id} id=${bearer_id} by=${by}
    ...    pass_regexp=Bearer-${bearer_id} .* deleted
    BuiltIn.Log    Bearer ${bearer_id} for UE${ue_id} is deleted    console=${P_console}


Display bearer stats
    [Documentation]    :Author: Vasileios Papoutsis
    ...    Displays bearer statistics or per-traffic(s) statistics of the bearer.
    ...
    ...    :param ue_id:         ue_id configured in WTS configuration
    ...    :param direction:     direction (default=bi)
    ...    :param type:          statistics type (default l3)
    ...    :param scell:         carrier aggregation serving cell (carrier component, CC).
    ...                          Primary is for scell index 0. Secondary is for scell indexes 1-7 (default=0).
    ...    :param format:        display Format (default=short)
    ...    :param size_unit:     unit of PDU/SDU/packets size (default=auto)
    ...    :param trf_id:        traffic id/ids (only for internal traffic. default=1). For 'l3_trf' type
    ...    :param dc_cell_group: displays the UE's MCG or SCG bearer statistics (applicable only for DC bearers) (default=all)
    ...    :param kwargs:        dictionary of pairs "parameter:value" (e.g. id=2)
    ...
    [Arguments]    ${ue_id}    ${direction}=bi    ${type}=l3    ${scell}=0    ${format}=short    ${size_unit}=auto
    ...    ${trf_id}=1    ${dc_cell_group}=all    &{kwargs}
    ${gNbCuType}=    Get gNbCuType Info
    Run keyword if    '${gNbCuType}' == 'NSA'    Set to dictionary    ${kwargs}    dc_cell_group=${dc_cell_group}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    ${str}=    Catenate
    ...    bearer_stats ue=${ue_id} dir=${direction} type=${type} scell=${scell} format=${format} size_unit=${size_unit}
    ...    trf_id=${trf_id}${command_args}
    ${output}=    Send Egate Command and verify output    cmd=${str}
    ...    pass_regexp=Average data rate
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    Stats for UE${ue_id} and${command_args} are displayed    console=${P_console}
    [Return]    ${output}


Set timing adjustment
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param ue_id:      ue_id configured in WTS configuration
    ...    :param rach_ta:    RACH preamble transmission delay in Ts * 16
    ...    :param shr_ta:     time adjustment value
    ...    :param tag_id:     0 is for p-TAG. 1..3 is for s-TAG (default=0)
    ...    :param cell:       to which cell the command is applicable (default=current)
    ...
    [Arguments]    ${ue_id}    ${rach_ta}    ${shr_ta}    ${tag_id}=0    ${cell}=current
    ${output}=    Send Egate Command and verify output    cmd=ue_ta id=${ue_id} tag_id=${tag_id} cell=${cell} rach_ta=${rach_ta} shr_ta=${shr_ta}
    ...    pass_regexp=OnTimeAdjustmentUpdate
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    Timing adjustment ${rach_ta}(${shr_ta}) for UE${ue_id} is set    console=${P_console}


UE Register
    [Documentation]    :Author: Noli Valdez III
    ...
    ...    :param ue_id:      Specified UE ID
    ...    :param args:    id of the Network Slice containing the requested NSSAI
    ...
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${args}=${EMPTY}
    ${output}=    Send Egate Command and verify output    cmd=ue_register id=${ue_id} nwslice=${nwslice} ${args}
    ...           pass_regexp=UE now in NG RM Registered
    BuiltIn.Log    UE${ue_id} registration is successful    console=${P_console}
    [Return]    ${output}


UE Deregister
    [Documentation]    :Author: Noli Valdez III
    ...
    ...    :param id:                    Specified UE ID
    ...    :param ue_deregister_type:    Type of UE initiated deregister procedure
    ...    :param by:                    Device type initiating the deregister procedure
    ...
    [Arguments]    ${id}=1    ${ue_deregister_type}=switch_off    ${by}=ue
    wts_ue.Send Egate Command and verify output    cmd=ue_deregister id=${id} ue_deregister_type=${ue_deregister_type} by=${by}
    ...                                            pass_regexp=UE Context Release Complete
    BuiltIn.Log    UE${id} deregistration is successful    console=${P_console}


UE PDU Session Setup
    [Documentation]    :Author: Noli Valdez III
    ...    Returns UE IP
    ...
    ...    :param pdu:        PDU Session ID
    ...    :param gw:         PDU Gateway ID. Specifies gateway to use for this PDU session
    ...    :param ue:         Specified UE ID
    ...    :param nwslice:    Requested Network Slice for the PDU Session
    ...    :param pass_regexp:  Initial Context Setup Successful (for 1st PDU session)
    ...                         Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)
    ...                         default: Initial Context Setup Successful
    ...
    [Arguments]    ${ue}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=Initial Context Setup Successful
    ${output}=     Send Egate Command and verify output    cmd=ue_pdu_session_setup pdu=${pdu} ue=${ue} nwslice=${nwslice} gw=${gw}
    ...                                                    pass_regexp=${pass_regexp}
    ${pattern}=    Catenate    Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...                        UE IP address:([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})
    ${ue_ip}=      Get Regexp Matches    ${output}    ${pattern}    1
    BuiltIn.Log    UE${ue} PDU${pdu} session setup is successful    console=${P_console}
    [Return]      ${ue_ip[0]}


UE PDU Session Release
    [Documentation]    :Author: Doreen Dellosa
    ...    :param pdu:        PDU Session ID
    ...    :param ue:         Specified UE ID
    ...    :param pass_regexp:  Successfully released PDU Session
    ...
    [Arguments]    ${ue}=1    ${pdu}=1    ${pass_regexp}=Successfully released PDU Session
    ${output}=     Send Egate Command and verify output    cmd=ue_pdu_session_release ue=${ue} pdu=${pdu} by=amf
    ...                                                    pass_regexp=${pass_regexp}
    BuiltIn.Log    UE${ue} PDU${pdu} session release is successful    console=${P_console}


Check Current Egate Console Status
    [Documentation]    :Author: Noli Valdez III
    ...    flush the egate log to update egate_console.log then check for the query
    ...    should be used for triggerless/async events e.g. NG Link, SIB, MIB, Cell Setup for SA
    ...    example:
    ...                Check Current Egate Console Status    NG link is Up
    ...
    ...    :param query:      Specific log in egate console
    ...
    [Arguments]       ${query}
    ${output}=        Send Egate Command and verify output    cmd=sim_log_set flush
    ${core_alias}=    connect.Connect to Core

    ${egate_log}=     ssh.execute    grep -i '${query}' ${tl.core.dir_path}/egate_console.log    connection=${core_alias}
    Should Contain    ${egate_log}    ${query}    ignore_case=True


Save Current Egate Console Log
    [Documentation]    :Author: Noli Valdez III
    ...    for post analysis of egate_console.log per testcase
    ...    flushes the egate log to update egate_console.log then save to target directory
    ...
    ...    :param target_dir: Directory to store the egate_console.log file
    ...    :param target_name: filename to save the file (default: egate_console.log)
    ...
    [Arguments]    ${target_dir}=None    ${target_name}=egate_console.log
    ${target_dir}=    Run Keyword If    '${target_dir}'=='None'    testline.Get Testcase Log Directory
    ...    ELSE    Set Variable    ${target_dir}

    ${output}=        Send Egate Command and verify output    cmd=sim_log_set flush

    ${core_alias}=    connect.Connect to Core
    ${egate_log}=     ssh.execute    cp ${tl.core.dir_path}/egate_console.log ${target_dir}/${target_name}    connection=${core_alias}
    [Return]    ${target_dir}/${target_name}


Configure NR BLER testmode
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param profile_id:    test profile id
    ...    :param kwargs:        dictionary of pairs "parameter:value" (e.g. dl_bler=100,600,700,800,200,300,400,500)
    ...
    [Arguments]    ${profile_id}    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=bler_testmode_nr profile_id=${profile_id}${command_args}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    NR BLER testmode for profile_id ${profile_id} and${command_args} is configured    console=${P_console}


Configure NR UL SINR testmode
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param profile_id:    test profile id
    ...    :param kwargs:        dictionary of pairs "parameter:value" (e.g. sinr_target_pusch=100 pathloss=40)
    ...
    [Arguments]    ${profile_id}    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=ul_sinr_testmode_nr profile_id=${profile_id}${command_args}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    NR UL SINR testmode for profile_id ${profile_id} and${command_args} is configured    console=${P_console}


Associate UEs to testmode
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param id:          specified UE ID
    ...    :param scell:       carrier Aggregation serving cell (carrier component, CC). Primary is for scell index 0.
    ...                        Secondary is for scell indexes 1-7.
    ...    :param testmode:    testmode to be used
    ...    :param profile_id:  test profile id
    ...    :param action:      triggers the activation or the deactivation of the test mode (activate or deactivate)
    ...
    [Arguments]    ${id}    ${testmode}    ${profile_id}    ${action}    ${scell}=0
    ${command}=    Set variable    ue_testmode_set_nr id=${id} scell=${scell} testmode=${testmode} profile_id=${profile_id} action=${action}
    Send Egate Command and verify output    cmd=${command}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    ${action} testmode ${testmode} for UE${id} scell=${scell} and profile_id ${profile_id}    console=${P_console}


Update dual connectivity parameters
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param id:            local identifier for eNodeB / gNodeB
    ...    :param kwargs:        dictionary of pairs "parameter:value" (e.g. serving_cell_index_range_scg=5:31)
    ...
    [Arguments]    ${id}    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=enb_endc_param id=${id}${command_args}
    Sleep    1s    reason=wait command to be executed
    BuiltIn.Log    Dual connectivity with id=${id} is updated with${command_args}    console=${P_console}


Update UE Channel State Information
    [Documentation]    :Author: Vasileios Papoutsis
    ...
    ...    :param profile_id: specified profile_id
    ...    :param kwargs:     dictionary of pairs "parameter:value" (e.g. cqi_mode=fixed)
    ...    Note: The profile_id used should be in active state and this could be achieved by the
    ...    keyword "Associate UEs to testmode" either before or after this keyword
    [Arguments]    ${profile_id}    &{kwargs}
    ${command_args}=    Convert Dictionary to Parameter String    &{kwargs}
    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${profile_id}${command_args}
    ${output}=    Send Egate Command and verify output    cmd=csi_override_testmode_nr profile_id=${profile_id}
    ...    pass_regexp=csi_override_testmode_nr Parameters
    BuiltIn.Log    Channel State Information for UE is updated with${command_args}
    ...    console=${P_console}


Configure multiple UEs in WTS Basic Configuration File
    [Documentation]    :Author: Srihari Janardhan
    ...
    ...    :param number_of_ues:         Number of UEs that you would like to be configured in WTS
    ...    :ue_id:     Start of ue_id (For NSA, by default it is 11 so +1 for another UE)
    ...    :param source_file:     Path to basic cfg file that needs to be modified
    ...    :param destination_file:     Path where modified basic cfg file must be stored
    ...    The backup of the original file will be stored in /tmp/basic_setup_backup.cfg
    ...    Please note: This keyword can be used only if the default UE configuration needs to be duplicated
    ...                 for subsequent UEs.
    ...                 The keyword is designed for NSA only.
    [Arguments]  ${number_of_ues}=${10}    ${ue_id}=12  ${source_file}=/opt/iphy/latest/basic_setup.cfg
    ...  ${destination_file}=/opt/iphy/latest/basic_setup.cfg
    Copy File   ${source_file}    /tmp/basic_setup_backup.cfg  #Create backup of original file
    wts.Load Wts Cfg        /opt/iphy/latest/basic_setup.cfg
    ${pdn}=      get_parameter     set     PDN_IP
    ${imsi}=     get_parameter     set_ue simulated id=11  imsi
    :FOR  ${ue}  IN RANGE  ${ue_id}  ${number_of_ues+11}
    \  ${new_ip}=  wts_tools.obtain_new_ip  ${ue}  ${pdn}
    \  ${new_imsi}=  wts_tools.obtain_new_imsi  ${ue}  ${imsi}
    \  wts.Clone and Modify    set_ue simulated id=${ue-1}      id=${ue} imsi=${new_imsi}  after  ue_param id=${ue-1}
    \  wts.Clone and Modify    ue_param id=${ue-1}              id=${ue}                   after  set_ue simulated id=${ue}
    \  wts.Clone and Modify    set_bearer id=2 ue=${ue-1}       ue=${ue} ip=${new_ip}      before  uec_param id=1
    wts.Save Wts Cfg        ${destination_file}



### PRIVATE ###

Convert Dictionary to Parameter String
    [Documentation]    :Author: Vasileios Papoutsis
    ...    [PRIVATE]
    [Arguments]    &{kwargs}
    ${command_args}=    Set variable    ${EMPTY}
    FOR    ${key}    IN    @{kwargs}
        ${value}=    Get from dictionary    ${kwargs}    ${key}
        ${command_args}=    Set variable    ${command_args} ${key}=${value}
    END
    [Return]    ${command_args}


Fetch gNB Info from SCF
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    fetch needed gnb information to prepare Airphone keyword
    ...    If additional configuration needed, could be added into this keyword
    ${scf_path}=    gnb.Get SCF from gNB    target_dir=/tmp    gnb_id=0
    ${gNbCuType}=    Get SCF Value from file    p_name=gNbCuType    scf_path=${scf_path}
    ${distName_params}=  Get distNames from gNB SCF  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
    ${cellTechnology}=    Get SCF Value from file    p_name=cellTechnology    scf_path=${scf_path}    dist_name=${distName_params[0]}
    ${freqBandIndicatorNR}=     Get SCF Value from file
    ...     p_name=freqBandIndicatorNR    scf_path=${scf_path}  dist_name=${distName_params[0]}
    ${nrarfcn}=    Run Keyword If  '${cellTechnology}'=='TDD'   Get SCF Value from file
	...     p_name=nrarfcn    scf_path=${scf_path}     dist_name=${distName_params[0]}
    ${nrarfcnDl}=    Run Keyword If  '${cellTechnology}'=='FDD'  Get SCF Value from file    p_name=nrarfcnDl    scf_path=${scf_path}
    ${nrarfcnUl}=    Run Keyword If  '${cellTechnology}'=='FDD'  Get SCF Value from file    p_name=nrarfcnUl    scf_path=${scf_path}
    ${nrarfcn_wts}=    Set Variable If    '${cellTechnology}'=='TDD'    ${nrarfcn}:${nrarfcn}    ${nrarfcnUl}:${nrarfcnDl}
    Set Suite Variable    ${P_gNbCuType}    ${gNbCuType}
    Set Suite Variable    ${P_cellTechnology}    ${cellTechnology}
    Set Suite Variable    ${P_freqBandIndicatorNR}    ${freqBandIndicatorNR}
    Set Suite Variable    ${P_nrarfcn}    ${nrarfcn_wts}


Get SCF Value from file
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    :param dist_name: ‘distName’, ${None} is default value
    ...     SBTS prefix can be ommited e.g.: both ‘SBTS-1900/NGNODEB-1’ and ‘NGNODE-1’ are valid and equivalent.
    ...    :param p_name: ‘name’ attribute in <p> tag, ${None} is default value
    ...    :param list_name: ‘name’ attribute in <list> tag, ${None} is default value
    [Arguments]    ${scf_path}    ${p_name}=${None}    ${list_name}=${None}    ${dist_name}=${None}
    scf.Load Scf    file_path=${scf_path}
    ${value}=    scf.Get Value from SCF    p_name=${p_name}    list_name=${list_name}    dist_name=${dist_name}
    [Return]    ${value}


Setup X2 Link
    [Documentation]    :Author: Jing Liang
    ...    Used for UTE Workaround keyword
    ute_wtssim.execute egate command and wait for data
    ...    cmd=enb_x2_link_up enb=1 target=2    pass_regexp=X2AP Link .* is up     alias=ap_egate


Check APL3 Log Ensure Cells Setup Successful
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE] To ensure Airphone after reboot and x2 setup has correct status
    ${ap_alias}=    connect.Connect to Airphone Common Unit
    ${output}=    ssh.execute    cat /tmp/APL3.log | grep -i 'Cell Setup completed'    ${ap_alias}
    should contain    ${output}    Cell Setup completed


Get Average Data Rate from Egate output
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]   to grep average data rate from Egate output
    [Arguments]    ${output}
    ${output}=    Get Lines Containing String    ${output}    Average data rate
    ${output}=    Replace String    ${output}    Average data rate    ${EMPTY}
    @{words}=    Split String    ${output}    (
    ${data_rate}=    Strip String    ${words[0]}
    [Return]    ${data_rate}


Workaround for L2PS nodeID
    [Documentation]  :Author: Guenter Doemer
    ...   used as long as 634-K and CNI-54937 are not done
    ...   to set actual l2PsNodeId to AirPhone config files after gNB restart
    [Arguments]    ${AirPhoneConfig_path}=/opt/iphy/latest/AirphoneConfig.xml
    ${l2PsNodeId}=   Identify L2PS Node ID
    ${iphy_alias}=   Connect to Airphone Common Unit
    ${local_path}=  set variable   /tmp/iphy.xml
    ${remote_path}=  set variable   /ffs/run/simmode/iphy.xml
    ssh.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=${iphy_alias}
    ${status}  ${curr_nodeId}=  run keyword and ignore error   get XML Content  ${local_path}  .//l2PSNodeId
    Run Keyword If    '${status}' == 'FAIL'    Log to Console    \n\tl2PsNodeId not found in config file, Workaround no longer necessary.
    Return From Keyword If   '${status}' == 'FAIL'
    Run Keyword If    ${curr_nodeId} == ${l2psNodeId}    Log to Console    \n\tCorrect nodeId already in config file
    Return From Keyword If   ${curr_nodeId} == ${l2psNodeId}
    Modify XML Content  ${local_path}  .//l2PSNodeId  ${l2PsNodeId}
    ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}    connection=${iphy_alias}
    Remove File   ${local_path}
    ${core_alias}=   connect.Connect to Core
    ${local_path}=  set variable   /tmp/AirphoneConfig.xml
    ssh.download_file    remote_path=${AirPhoneConfig_path}    local_path=${local_path}   connection=${core_alias}
    Modify XML Content  ${local_path}  .//l2PsNodeId  ${l2PsNodeId}
    ssh.upload_file    remote_path=${AirPhoneConfig_path}    local_path=${local_path}   connection=${core_alias}
    Remove File   ${local_path}
    Reboot Airphone via Console
    installation.Wait until Airphone board ready    timeout=10min
