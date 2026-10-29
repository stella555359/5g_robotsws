*** Settings ***

Documentation     Keywords related to WTS/egate and Airphone handling

Library     String
Library     OperatingSystem
Library     Collections

Library     ute_wtssim
Library     python/wts_ue.py            WITH NAME    wts_tools
Library     python/gnb.py               WITH NAME    gnb_internal
Library     taf.transport.ssh           WITH NAME    ssh
Library     python/egate_analyzer.py    WITH NAME    egate_analyzer

Resource    gnb.robot
Resource    testline.robot
Resource    connect.robot
Resource    util.robot
Resource    networking.robot


*** Variables ***

${P_ORIG_WTS_CONFIG}     None
${P_ORIG_AP_SWCONFIG}    None
${P_gNbCuType}           None
${P_cellTechnology}      None
${P_nrarfcn}             None
${P_console}             ${False}    # output to console can be enabled via "Set Console Output" from testline.robot
${P_BASIC_CFG_CLEANED}   ${False}    # used in KW ' Configure multiple UEs in WTS Basic Configuration File'


*** Keywords ***

Kill WTS Services
    [Documentation]
    ...    Keyword is used to terminate dedicated WTS service and ute_wtssim alias together.
    ...    Terminate egate and edaemon services running with the given port id.
    ...    Teardown ute_wtssim alias by using given alias name.
    ...
    ...    | egate_port     | used egate port                           |
    ...    | edaemon_port   | used edaemon port                         |
    ...    | wts_alias      | used ute_wtssim alias for egate console   |
    ...    | edaemon_alias  | used ute_wtssim alias for edaemon         |
    ...
    ...    *Example*
    ...    | wts_ue.Kill WTS Services  | egate_port=10000  | edaemon_port=22222  | wts_alias=wts1  | edaemon_alias=edaemon1  |
    ...
    [Arguments]   ${egate_port}=${tl.core.egate_port}   ${edaemon_port}=${tl.core.edaemon_port}
    ...   ${wts_alias}=ap_egate   ${edaemon_alias}=ap_edaemon

    Teardown Egate Connection For Airphone   wts_alias=${wts_alias}
    Teardown Edaemon Connection For Airphone   edaemon_alias=${edaemon_alias}

    Log   ${\n}Kill WTS Services with egate port: ${egate_port}, edaemon port: ${edaemon_port}   console=${P_console}
    OperatingSystem.Run   sudo pkill -f './egate.* --port ${egate_port}'
    OperatingSystem.Run   sudo pkill -f './edaemon.* --port ${edaemon_port}'

    Sleep  1s

    OperatingSystem.Run   sudo pkill -9 -f './egate.* --port ${egate_port}'
    OperatingSystem.Run   sudo pkill -9 -f './edaemon.* --port ${edaemon_port}'
    Log   ${\n}WTS services are killed!   console=${P_console}


Reboot Airphone Via Console
    [Documentation]
    ...    After soft reboot of Airphone system module the KW waits until the ssh connection
    ...    goes done if `check_reset` is set True.
    ...
    ...    | ue_id          | Id of UE                              |
    ...    | check_reset    | check until reset started true|false  |
    ...
    ...    *Example*
    ...    | wts_ue.Reboot Airphone via Console  | ue_id=0 |
    ...
    [Arguments]   ${ue_id}=0   ${check_reset}=${False}
    ${ap_alias}   Wait Until Keyword Succeeds   3min   10sec
    ...   connect.Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=0

    ssh.Execute   set -m ; ddal -s ddal_boot_set_reset_loop_count 0   connection=${ap_alias}
    ssh.Send Command   system-module-reboot   connection=${ap_alias}
    IF   ${check_reset}
        gnb.Wait Until Ssh Connection Is Down   connection=${ap_alias}
    END
    [Teardown]   Run Keyword And Ignore Error   ssh.Disconnect   connection=${ap_alias}


Reboot All GNBs Via Console
    [Documentation]
    ...    Reboot all gnbs via console and wait for all system boards come back
    ...
    ${gnb_num}   Get Length   ${tl.gnbs}
    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
        gnb.Reboot GNB System Module Via Console   gnb_id=${gnb_id}
        IF   '${gnb_id}'=='0'
            networking.Wait Until Ping Failed   ip_addr=192.168.255.129    iterations=${90}
        END
    END

    networking.Wait Until Ping Succeeds
    ...     ip_addr=192.168.255.129  iterations=${60}  ping_count=${45}   ping_deadline=${60}

    FOR   ${gnb_id}   IN RANGE   ${gnb_num}
        gnb.Wait Until All DUs Up   gnb_id=${gnb_id}   timeout=6min
    END


Reset Airphone Testline
    [Documentation]
    ...    This KW is for airphone testline with irfhead, to overcome testline instability.
    ...    After triggering the gNB system module reboot it checks if ping fails and succeeds again.
    ...    Then the KW waits 2min to secure the ssh service of the gNB becomes available so that it
    ...    is secure to connect. If all passed the AP board status is checked. If that fails a power
    ...    cycle of the AP is performed and the bioard status is checked again.
    ...
    ...     | ue_id    | Id of UE   |
    ...
    [Arguments]   ${ue_id}=0
    Reboot Airphone Via Console   ue_id=${ue_id}
    Reboot All GNBs Via Console

    ${airphone_status}   Run Keyword And Return Status
    ...   Wait Until Airphone Board Ready   ue_id=${ue_id}   timeout=3min

    IF   ${airphone_status}==${False}
        Power Cycle Ue   ue_id=${ue_id}
        networking.Wait Until Ping Failed     ${tl.ues[${ue_id}].l1.common_units[0].lmp_connection.addr}
        networking.Wait Until Ping Succeeds   ${tl.ues[${ue_id}].l1.common_units[0].lmp_connection.addr}
    ...            iterations=${60}   ping_count=${45}   ping_deadline=${60}
        Wait Until Airphone Board Ready   ue_id=${ue_id}   timeout=3min
    END


Wait Until Airphone Board Ready
    [Documentation]
    ...     This KW tries to connects via ssh to the Airphone Common Unit, fetches the existing
    ...     CCS Daemon node ids and calls every 20 seconds the Airscale Board Status for all node id.
    ...
    ...     | ue_id         | Id of UE                                      |
    ...     | ue_comu_id    | Id of DU                                      |
    ...     | timeout       | Time until Common+CapacityUnit have to be up  |
    ...
    [Arguments]   ${ue_id}=0   ${ue_comu_id}=0   ${timeout}=10min
    Log   ${\n}Wait until Airphone is ready   console=${P_console}

    ${comu_ssh_alias}  Wait Until Keyword Succeeds   ${timeout}      10 sec
    ...   connect.Connect To Airphone Common Unit    ue_id=${ue_id}  ue_comu_id=${ue_comu_id}

    Wait Until Keyword Succeeds   ${timeout}   20sec   gnb_internal.Check All Boards And CPUs Are Ready
    ...   connection=${comu_ssh_alias}


Reset Wts Cfg
    [Documentation]
    ...    Reset Cfg of Wts egate controller.
    ...
    Send Egate Command And Verify Output   cmd=re


Start WTS For Airphone
    [Documentation]
    ...    Used for Precondition: GNB and Airphone, at Suite Setup or Testcase setup
    ...    Will setup egate alias ap_egate for keyword  `Send Egate Command and verify output` previous
    ...    WTS processes should be killed at earlier step, before TL reboot
    ...
    ...    | wts_alias      | alias name to handle egate for ute_wtssim     |
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...    | remove_logs    | remove existing wts logs                      |
    ...    | egate_port     | used egate port                               |
    ...    | edaemon_port   | used edaemon port                             |
    ...
    ...    *Example*
    ...    | wts_ue.Kill WTS Services |
    ...    | wts_ue.Start WTS for Airphone      | wts_alias=ap_egate        |
    ...
    [Arguments]   ${wts_alias}=ap_egate   ${edaemon_alias}=ap_edaemon   ${remove_logs}=${False}
    ...   ${egate_port}=${tl.core.egate_port}   ${edaemon_port}=${tl.core.edaemon_port}
    Teardown Egate Connection For Airphone     wts_alias=${wts_alias}
    Teardown Edaemon Connection For Airphone   edaemon_alias=${edaemon_alias}

    IF   ${remove_logs}   OperatingSystem.Run   cd ${tl.core.dir_path} && sudo rm *log*

    ${edaemon_id}   OperatingSystem.Run   sudo pgrep -af 'edaemon.* --port ${edaemon_port}' | grep -v pgrep
    ${egate_id}     OperatingSystem.Run   sudo pgrep -af 'egate.* --port ${egate_port}' | grep -v pgrep

    IF   '${edaemon_id}'=='${EMPTY}'
        OperatingSystem.Run   cd ${tl.core.dir_path} && sudo .\\/edaemon --port ${edaemon_port}
        Sleep   2s   reason=wait for WTS edaemon startup
    END

    IF   '${egate_id}'=='${EMPTY}'
        OperatingSystem.Run   cd ${tl.core.dir_path} && .\\/egate --port ${egate_port} > egate.out.${egate_port} 2>&1
        Sleep   5s   reason=wait for WTS egate startup
    END
    ute_wtssim.Setup Egate   egate_port=${egate_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}   alias=${wts_alias}   save_egate=${True}
    ute_wtssim.Setup Edaemon   edaemon_port=${edaemon_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}   alias=${edaemon_alias}
    ${wts_status}   Run Keyword And Return Status
    ...   Send Egate Command And Verify Output   cmd=sim_info   pass_regexp=Process ID   wts_alias=${wts_alias}
    ${sim_status}   Run Keyword And Return Status
    ...   Send Egate Command And Verify Output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=${wts_alias}

    IF   not $sim_status
        ${sim_status}   Force WTS To Init State   wts_alias=${wts_alias}
    END
    IF   $wts_status==False or $sim_status==False   Fail   WTS is not correctly started


Collect Egate Log Files
    [Documentation]
    ...     With this KW the egate log files will be collected and stored in ``target_dir``.
    ...     Run this keyword before egate teardown.
    ...
    ...    | target_dir | directory to store the egate log files    |
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...
    [Arguments]   ${target_dir}=${None}   ${wts_alias}=ap_egate
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END
    ute_wtssim.Collect Egate Log Files   unzip=${False}   subdirectory=${target_dir}   alias=${wts_alias}


Collect Edaemon Log Files
    [Documentation]
    ...     With this KW the edaemon log files will be collected and stored in ``target_dir``.
    ...     Run keyword before edaemon teardown.
    ...
    ...    | target_dir     | directory to store the edaemon log files      |
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...
    [Arguments]   ${target_dir}=${None}   ${edaemon_alias}=ap_edaemon
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END
    ute_wtssim.Collect Edaemon Log Files   unzip=${False}   subdirectory=${target_dir}   alias=${edaemon_alias}


Collect Sos Report Logs
    [Documentation]
    ...    Collect Sos report logs which are needed to open an airphone pronto. The argument ``script_path`` must
    ...    point to the directory the sosReport_ASIK_ASIL.sh is located. If the argument ``target_dir`` is omitted the
    ...    Sos report will be stored in the Testcase Log Directory.
    ...
    ...    | target_dir     | directory to store the sos report logs        |
    ...    | script_path    | path where sosReport_ASIK_ASIL.sh is located  |
    ...
    [Arguments]   ${target_dir}=${None}   ${script_path}=${tl.core.dir_path}
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END
    OperatingSystem.Run   cd ${script_path}; ./sosReport_ASIK_ASIL.sh -c -s -nr -iphyDIR\=${tl.core.dir_path} -btsDIR\=${tl.core.dir_path}
    ${sos_report_file}    util.Get Latest Modified File With Defined Pattern   path=${script_path}   pattern=SosReport*.tgz

    IF   '${script_path}'!='${target_dir}'
        OperatingSystem.Run   cp ${script_path}/${sos_report_file} ${target_dir}/
    END
    OperatingSystem.Run   rm ${script_path}/${sos_report_file} ${script_path}/sosReport_ASIK_ASIL.sh.log


Modify SosReport Config
    [Documentation]
    ...     Modify SosReport.cfg to proper value. The argument ``script_path`` must
    ...     point to the directory the sosReport_ASIK_ASIL.sh is located.
    ...     TD 27.02.2024: l1bypass support was already removed from Ulm keywords. But the
    ...     sosReport.cfg still contains the L1_MODE variable and so we keep it here too.
    ...
    ...
    ...    | script_path    | path where sosReport_ASIK_ASIL.sh is located                                                          |
    ...    | LONER_VERSION  | Can be A/B/C/D/E, depend on your loner version, check help from start script for more information.    |
    ...    | PHONER_VERSION | Can be PH2 / PH4 / PH7                                                                                |
    ...    | L1_MODE        | Depend on your configuration choose l1bypass or fullstack                                             |
    ...
    [Arguments]   ${LONER_VERSION}=X   ${PHONER_VERSION}=X   ${L1_MODE}=X   ${script_path}=${tl.core.dir_path}

    ${sos_cfg}    Catenate    ${script_path}/sosReport.cfg

    ${command1}   Catenate   sed -ri 's@(LONER_VERSION\=)(.*)@\\1${LONER_VERSION}@' ${sos_cfg}
    ${command2}   Catenate   sed -ri 's@(PHONER_VERSION\=)(.*)@\\1${PHONER_VERSION}@' ${sos_cfg}
    ${command3}   Catenate   sed -ri 's@(L1_MODE\=)(.*)@\\1${L1_MODE}@' ${sos_cfg}

    OperatingSystem.Run   ${command1}; ${command2}; ${command3}


Teardown Egate Connection For Airphone
    [Documentation]
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown.
    ...    Could be used as teardown keyword for Start WTS for Airphone.
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...
    ...    *Example*
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Teardown Egate Connection for Airphone |
    ...
    [Arguments]   ${wts_alias}=ap_egate
    Run Keyword And Ignore Error   ute_wtssim.Teardown Egate   alias=${wts_alias}


Teardown Edaemon Connection For Airphone
    [Documentation]
    ...    Used for Postcondition: GNB and Airphone, at Suite Teardown or Testcase teardown.
    ...    used as teardown keyword for Start WTS for Airphone.
    ...
    ...    | edaemon_alias  | alias name to handle edaemon for ute_wtssim   |
    ...
    ...    *Example*
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Teardown Edaemon Connection for Airphone |
    ...
    [Arguments]   ${edaemon_alias}=ap_edaemon
    Run Keyword And Ignore Error   ute_wtssim.Teardown Edaemon   alias=${edaemon_alias}


Config WTS For Airphone
    [Documentation]
    ...     Configure WTS with default config file in __init__.py .
    ...     The parameter ``pass_regexp`` can be used to wait for a string in the egate log or ``timeout``.
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...    | cfg_file   | path of wts config file to be used        |
    ...
    ...    *Example*
    ...    -  NSA TL
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Config WTS for Airphone | pass_regexp=SystemInformationBlockType2 updated |
    ...    - SA TL
    ...    | wts_ue.Start WTS for Airphone |
    ...    | wts_ue.Config WTS for Airphone | pass_regexp=SystemInformationBlockType1-NR updated | timeout=600 |
    ...
    [Arguments]   ${pass_regexp}=${None}   ${timeout}=30   ${wts_alias}=ap_egate   ${cfg_file}=${tl.core.cfg_filename}
    ute_wtssim.Execute Egate Command And Wait For Data   cmd=cfg file=${cfg_file}   pass_regexp=${pass_regexp}
    ...   timeout=${timeout}   alias=${wts_alias}


Send Egate Command And Verify Output
    [Documentation]
    ...    Same as keyword `ute_wtssim.execute`_ egate command and wait for data.
    ...
    ...    http://doc.ute.nsn-rdnet.net/packages/ute_wtssim/interfaces/ute_wtssim.html#execute-egate-command-and-wait-for-data
    ...
    ...    It sends the given ``cmd`` to egate execute.
    ...    ``timeout`` defines the  timeout for this operation.
    ...    ``return_output`` boolean ${False} or ${Ture} indicate whether egate log should be printed out.
    ...    If given regexp ``pass_regexp`` is found in the command response the KW passes whereas if
    ...    the given ``fail_regexp`` is found in the command output the KW fails. The first occurance decides the result.
    ...    If ``return_output`` is True the egate console output will be returned to the caller.
    ...
    ...    | cmd            | Command to execute                                                |
    ...    | timeout        | Timeout for this operation                                        |
    ...    | return_output  | boolean Flag indicating whether egate log should be printed out   |
    ...    | pass_regexp    | Regexp indicating that the command passed                         |
    ...    | fail_regexp    | Regexp indicating that the command failed                         |
    ...    | wts_alias      | alias name to handle egate for ute_wtssim                         |
    ...
    ...    *Example*
    ...    |  `Start WTS for Airphone` |
    ...    |  `Config WTS for Airphone` |
    ...    | wts_ue.Send Egate Command and verify output | cmd=sim_state_disp | pass_regexp=The state is ACTIVE |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${cmd}   ${timeout}=10   ${return_output}=${True}   ${pass_regexp}=${None}   ${fail_regexp}=${None}
    ...   ${wts_alias}=ap_egate
    ${output}   ute_wtssim.Execute Egate Command And Wait For Data
    ...   cmd=${cmd}   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ...   timeout=${timeout}   return_output=${return_output}   alias=${wts_alias}
    RETURN   ${output}


Store Current WTS Config
    [Documentation]
    ...    Collect current WTS config file and Set path as Suite Variable ${P_ORIG_WTS_CONFIG}
    ...    ``target_dir`` defines where to save original WTS config, if omitted the return value of
    ...    KW `testline.Get Test Suite Config Directory` is used.
    ...
    ...    | target_dir | where to save original WTS config |
    ...
    [Arguments]   ${target_dir}=${None}
    ${ORIG_WTS_CONFIG}   Get WTS Config   target_dir=${target_dir}
    OperatingSystem.Run   mv ${ORIG_WTS_CONFIG} ${ORIG_WTS_CONFIG}.orig
    Set Suite Variable    ${P_ORIG_WTS_CONFIG}   ${ORIG_WTS_CONFIG}.orig


Get WTS Config
    [Documentation]
    ...    This KW saves the WTS cfg file to the given location.
    ...    ``target_dir`` defines where to store the WTS config, default with testline.Get Test Suite Config Directory.
    ...
    ...    | target_dir | path where to store the WTS config file   |
    ...
    ...     *Returns*   path to the stored file
    ...
    [Arguments]   ${target_dir}=${None}
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Test Suite Config Directory
    END

    IF   '${tl.core.dir_path}'!='${target_dir}'
        OperatingSystem.Run   cp ${tl.core.dir_path}/${tl.core.cfg_filename} ${target_dir}/${tl.core.cfg_filename}
    END
    RETURN   ${target_dir}/${tl.core.cfg_filename}


Reload Stored WTS Config
    [Documentation]
    ...    Brings back WTS config file previously stored by KW `Store Current WTS config`.
    ...
    ...    *Example*
    ...    | wts_ue.Store Current WTS Config |
    ...    | wts_ue.Reload Stored WTS Config |
    ...

    IF   '${P_ORIG_WTS_CONFIG}'!='${tl.core.dir_path}/${tl.core.cfg_filename}'
        OperatingSystem.Run   cp ${P_ORIG_WTS_CONFIG} ${tl.core.dir_path}/${tl.core.cfg_filename}
    END


Upload Customized WTS Config
    [Documentation]
    ...    Upload customized WTS config file to WTS folder, if `Store Current WTS Config` has not been called before.
    ...    The parameter `remote_cfg` can be used if multiple WTS config needed.
    ...
    ...    | config_path    | location of feature related WTS config file   |
    ...    | remote_cfg     | can be used if multiple WTS config needed     |
    ...
    ...    *Example*
    ...    | wts_ue.Upload Customized WTS Config | config_path=absolut_path/basic_wts.cfg | remote_cfg=basic_wts.cfg |
    ...
    [Arguments]   ${config_path}   ${remote_cfg}=${tl.core.cfg_filename}
    IF   '${P_ORIG_WTS_CONFIG}'=='None'   Store Current WTS Config

    IF   '${config_path}'!='${tl.core.dir_path}/${remote_cfg}'
        OperatingSystem.Run   cp ${config_path} ${tl.core.dir_path}/${remote_cfg}
    END


Get Average Data Rate Via Egate
    [Documentation]
    ...    Check Average Data Rate during throughput test.
    ...
    ...    | ue_id      | Id of UE in WTS                                               |
    ...    | dir        | Direction ul|dl|bi                                            |
    ...    | trf_id     | Id or Ids of Traffic                                          |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)    |
    ...
    ...    http://wts-documentation.dyn.nesc.nokia.net/wts-ci/eGate/WTS_2112_WK48_4.0.19019_3686685.2/html_files/html_cmd_files/bearer_stats.html
    ...
    ...    *Example*
    ...    | ${data_rate}= | wts_ue.Get Average Data Rate via Egate | ue_id=1 | id=2 | dir=dl | trf_id=1 |
    ...
    ...    *Returns*   data_rate
    ...
    [Arguments]   ${ue_id}   ${dir}=bi   ${trf_id}=all   &{kwargs}
    ${dc_cell_group}   Set Variable If   '${dir}' == 'dl'   scg   all

    ${output}   Display Bearer Stats   ue_id=${ue_id}   direction=${dir}   trf_id=${trf_id}   type=l3
    ...   dc_cell_group=${dc_cell_group}   &{kwargs}

    ${data_rate}   Get Average Data Rate From Egate Output   ${output}
    ${data_rate}   Convert To Integer   ${data_rate}
    RETURN   ${data_rate}


Store Current Swconfig From Airphone
    [Documentation]
    ...    Use this KW in case testcase needs to modify swconfig.txt on Airphone.
    ...    Collects current one as backup, set path as Suite Variable ${P_ORIG_AP_SWCONFIG}.
    ...    If argument ``target_dir`` is omitted the file will be stored according to the return
    ...    value of KW `testline.Get Test Suite Config Directory`.
    ...
    ...    | ue_id      | Id of ue                              |
    ...    | comu_id    | Id of Common Unit                     |
    ...    | target_dir | where to save original swconfig.txt   |
    ...
    ...    *Example*
    ...    | wts_ue.Store Current swconfig from Airphone |
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}   ${target_dir}=${None}
    ${ORIG_SWCONFIG}   Get Swconfig From Airphone   ue_id=${ue_id}   comu_id=${comu_id}   target_dir=${target_dir}
    OperatingSystem.Run   mv ${ORIG_SWCONFIG} ${ORIG_SWCONFIG}.orig
    Set Suite Variable    ${P_ORIG_AP_SWCONFIG}   ${ORIG_SWCONFIG}.orig


Get Swconfig From Airphone
    [Documentation]
    ...     This KW connects to the ``comu_id`` of the Airphone given by ``ue_id`` and downloads the file swconfig.txt
    ...     to the given ``target_dir``. If ``target_dir`` is omitted it is stored in the Test Suite Config Directory.
    ...
    ...     | ue_id         | Id of gnb             |
    ...     | comu_id       | Id of Common Unit     |
    ...     | target_dir    | path to save swconfig |
    ...
    ...     *Returns*   swconfig path for further usage
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}   ${target_dir}=${None}
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Test Suite Config Directory
    END
    ${ap_alias}   connect.Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${comu_id}
    ssh.Download File   remote_path=/ffs/run/swconfig.txt   local_path=${target_dir}/ap-${ue_id}_swconfig.txt   connection=${ap_alias}
    RETURN   ${target_dir}/ap-${ue_id}_swconfig.txt


Reload Stored Swconfig To Airphone
    [Documentation]
    ...    Used for Suite Teardown or Testcase Teardown.
    ...    Bring back swconfig.txt file previously stored by KW `Store Current swconfig from Airphone`.
    ...
    ...    | ue_id      | Id of ue          |
    ...    | comu_id    | Id of Common Unit |
    ...
    ...    *Example:*
    ...    | wts_ue.Store Current swconfig from Airphone  |
    ...    | wts_ue.Reload stored swconfig to Airphone    |
    ...
    [Arguments]   ${ue_id}=${0}   ${comu_id}=${0}
    ${ap_alias}   connect.Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${comu_id}
    ssh.Upload File   local_path=${P_ORIG_AP_SWCONFIG}   remote_path=/ffs/run/swconfig.txt   connection=${ap_alias}


Update SW Config File On AP System Module
    [Documentation]
    ...    This KW connects to the ``comu_id`` of the Airphone given by ``ue_id`` and
    ...    sets the RND params given by ``param_list`` in the swconfig.txt.
    ...    The `param_list` is a list of key:value pairs, e.g. ["0x4600BA=6", "0x460002=6"].
    ...
    ...    | param_list | list the update content   |
    ...    | ue_id      | Id of ue                  |
    ...    | ue_comu_id | Id of Common Unit         |
    ...
    [Arguments]   ${param_list}   ${ue_id}=${0}   ${ue_comu_id}=${0}
    ${ap_alias}   connect.Connect To Airphone Common Unit   ue_id=${ue_id}   ue_comu_id=${ue_comu_id}
    swconf.Download SWConfig File From ASIK To Test Pc   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${ap_alias}
    swconf.Modify SWConfig File   parametersList=${param_list}   filePath=/tmp/swconfig_tmp.txt
    swconf.Upload SWConfig File To ASIK And Crasign   localFilePath=/tmp/swconfig_tmp.txt   asik_alias=${ap_alias}


Update WTS Config With Regex
    [Documentation]
    ...    Update value in WTS config file by using Regular expression, and verify if value has been correctly updated.
    ...    It uses taf.transport.ssh to execute, therefore please use double '\' if you have '\' in arguments.
    ...
    ...    | regex      | specifies the regular expression to search for occurance  |
    ...    | value      | new value to be set                                       |
    ...    | remote_cfg | target WTS config file name                               |
    ...
    ...    *Example*
    ...    | wts_ue.Update WTS config with Regex  | regex=nr_arfcn=\\S+  | value=nr_arfcn=646000:646000  |
    ...
    [Arguments]   ${regex}   ${value}   ${remote_cfg}=${tl.core.cfg_filename}
    OperatingSystem.Run   sed -i -E 's/${regex}/${value}/g' ${tl.core.dir_path}/${remote_cfg}
    ${output}   OperatingSystem.Run   grep ${value} ${tl.core.dir_path}/${remote_cfg}
    Should Contain   ${output}   ${value}


Get GNbCuType Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `gnb.Fetch gNB Info from SCF`.
    ...    If the global variable P_gNbCuType isn't None it returns its value.
    ...    Otherwise it calls `gnb.Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    SA or NSA or both
    ...
    IF  '${P_gNbCuType}'=='None'   Fetch GNB Info From SCF
    RETURN   ${P_gNbCuType}


Get CellTechnology Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `gnb.Fetch gNB Info from SCF`.
    ...    If the global variable P_cellTechnology isn't None it returns its value.
    ...    Otherwise it calls `gnb.Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    TDD or FDD
    ...
    IF   '${P_cellTechnology}'=='None'   Fetch GNB Info From SCF
    RETURN   ${P_cellTechnology}


Get NRARFCN Info
    [Documentation]
    ...    This is a specific wrapper KW utilizing KW `gnb.Fetch gNB Info from SCF`.
    ...    If the global variable P_nrarfcn isn't None it returns its value.
    ...    Otherwise it calls `gnb.Fetch gNB Info from SCF` to fetch the needed information
    ...    from the SCF.
    ...
    ...    *Returns*    nrarfcn value
    ...
    IF   '${P_nrarfcn}'=='None'   gnb.Fetch GNB Info From SCF
    RETURN   ${P_nrarfcn}


Attach UE To LTE
    [Documentation]
    ...    Initiates UE Attach procedure to LTE cell
    ...
    ...    | ue_id                  | ue_id configured in WTS configuration                         |
    ...    | emergency              | toggle for Emergency Attach (not applicable for NB-IoT UE)    |
    ...    | pdn_connectivity_type  | IP version of PDN connectivity                                |
    ...    | kwargs                 | dictionary of pairs "parameter:value"                         |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=11   ${emergency}=off   ${pdn_connectivity_type}=auto   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    ${output}   Send Egate Command And Verify Output
    ...   cmd=ue_attach id=${ue_id} emergency=${emergency} pdn_connectivity_type=${pdn_connectivity_type}${command_args}
    ...   pass_regexp=UE IS ACTIVE
    Log   ${\n}UE${ue_id} is attached to LTE    console=${P_console}
    RETURN   ${output}


Trigger LTE-NR Dual Connectivity For Bearers
    [Documentation]
    ...    eNB command to trigger LTE-NR dual connectivity for bearers.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                 |
    ...    | bearer_id      | bearer id configured in WTS configsuration (e.g. 9,8)  |
    ...    | target_gnb     | target gNB id                                         |
    ...    | target_cells   | target gNB cells                                      |
    ...    | type           | type of dual connectivity                             |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=11   ${bearer_id}=2   ${target_gnb}=2   ${target_cells}=1   ${type}=split_scg
    ${output}   Send Egate Command And Verify Output
    ...   cmd=enb_ue_dc_start ue=${ue_id} bearer=${bearer_id} target_gnb=${target_gnb} target_cells=${target_cells} type=${type}
    ...   pass_regexp=reported successful RA
    Log   ${\n}LTE-NR dual connectivity of UE${ue_id} with bearer${bearer_id} to gNB${target_gnb} and cell${target_cells} is successful
    ...   console=${P_console}
    Sleep   1s   reason=wait command to be executed
    RETURN   ${output}


Trigger LTE Dual Connectivity And Analyze Output
    [Documentation]
        ...    eNB command to trigger LTE-NR dual connectivity for bearers.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                 |
    ...    | bearer_id      | bearer id configured in WTS configuration (e.g. 9,8)  |
    ...    | target_gnb     | target gNB id                                         |
    ...    | target_cells   | target gNB cells                                      |
    ...    | type           | type of dual connectivity                             |
    ...
    ...    *Returns*   egate analysis accroding to parameters
    [Arguments]  ${ue_id}=11   ${bearer_id}=2   ${target_gnb}=2   ${target_cells}=1   ${type}=split_scg  ${target_path}=/tmp/egate_ouput.json
    ...    ${regex_search}=${EMPTY}
    ${status}  ${egate_output}   Run Keyword And Ignore Error  Trigger LTE-NR Dual Connectivity For Bearers     ue_id=${ue_id}
    ...    bearer_id=${bearer_id}   target_gnb=${target_gnb}
    ...    target_cells=${target_cells}   type=${type}
    Analyze Egate Log  status=${status}  egate_output=${egate_output}    target_path=${target_path}    ue_id=${ue_id}  regex_search=${regex_search}


Trigger LTE-NR Dual Connectivity Modification
    [Documentation]
    ...    Command to trigger LTE-NR dual connectivity modification.
    ...
    ...    | ue_id      | ue_id configured in WTS configuration         |
    ...    | bearer_id  | bearer id configured in WTS configuration     |
    ...    | reason     | reason to trigger SgNB modification           |
    ...    | by         | determines the initiator of the DC procedure  |
    ...    | cause      | cause for the DC procedure                    |
    ...    | type       | type of dual connectivity                     |
    ...
    [Arguments]   ${ue_id}   ${bearer_id}   ${reason}=bearer_to_add   ${by}=enb   ${cause}=RN_CauseRadioNetwork_unspecified
    ...   ${type}=split_scg
    Send Egate Command And Verify Output
    ...   cmd=enb_ue_dc_modify ue=${ue_id} ${reason}=${bearer_id} by=${by} cause=${cause} type=${type}
    ...   pass_regexp=SgNBReconfigurationComplete
    Log   ${\n}LTE-NR dual connectivity modification with reason ${reason} for bearer ${bearer_id} is successful   console=${P_console}


Set Traffic Type
    [Documentation]
    ...    Command to set traffic type ``trf_type`` for UE defined by ``ue_id`` and PDU Session Id by ``pdu_id``.
    ...    Parameter ``log_traffic_stats`` specifies if logging is needed on|off.
    ...
    ...    | ue_id:             | ue_id configured in WTS configuration         |
    ...    | pdu_id             | specified PDU session ID                      |
    ...    | trf_type:          | specified traffic type (internal|external)    |
    ...    | log_traffic_stats  | specified to log traffic stats (on|off)       |
    ...
    [Arguments]   ${ue_id}   ${pdu_id}   ${trf_type}=external   ${log_traffic_stats}=off
    Send Egate Command And Verify Output
    ...   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type} log_traffic_stats=${log_traffic_stats}
    Log   ${\n}Traffic type for UE${ue_id} and PDU${pdu_id} is set to ${trf_type}   console=${P_console}


Start Data Traffic In Egate
    [Documentation]
    ...    Start data traffic (NSA/SA)
    ...
    ...    | ue_id          | ue_id configured in WTS configuration                                         |
    ...    | direction:     | dl or ul traffic direction                                                    |
    ...    | protocol:      | L3 protocol type, e.g. udp|tcp|icmp                                           |
    ...    | ack_mode:      | toggle for receiver to generate an ack, e.g. on|off                           |
    ...    | trf_id:        | traffic id, e.g. 1                                                            |
    ...    | cl_trf_stats   | toggle for clear L3 statistics for the traffic instance, e.g. on|off          |
    ...    | kwargs:        | dictionary of pairs "parameter:value", e.g. id=2, mbps=5, rtp_codec=custom    |
    ...    | ..             | rtp_ps=32 or rtp_ts_step=1000                                                 |
    ...
    [Arguments]   ${ue_id}=${EMPTY}   ${direction}=${EMPTY}   ${protocol}=udp   ${ack_mode}=off   ${trf_id}=1
    ...   ${cl_trf_stats}=on    &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String    &{kwargs}
    ${command}   Catenate
    ...   trf_data_start ue=${ue_id} dir=${direction} trf_id=${trf_id}
    ...   protocol=${protocol} ack_mode=${ack_mode} cl_trf_stats=${cl_trf_stats}${command_args}
    ${output}   Send Egate Command And Verify Output   cmd=${command}   pass_regexp=TRF
    Validate If Traffic Has Started On All UEs   ue_ids=${ue_id}   output=${output}   protocol=${protocol}   direction=${direction}
    ...  command_args=${command_args}


Stop Data Traffic In Egate
    [Documentation]
    ...    Stop running data traffic (NSA/SA) for the given ``ue_id``.
    ...
    ...    | ue_id:     | ue_id configured in WTS configuration             |
    ...    | direction  | ul|dl|bi traffic direction                        |
    ...    | trf_id:    | traffic id, e.g. 1                                |
    ...    | kwargs:    | dictionary of pairs "parameter:value" (e.g. id=2) |
    ...
    [Arguments]   ${ue_id}   ${direction}   ${trf_id}=1   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=trf_data_stop ue=${ue_id} dir=${direction} trf_id=${trf_id}${command_args}
    ...   pass_regexp=${direction.upper()} Traffic was stopped||Stopping .* traffic
    Log   ${\n}${direction.upper()} data for UE${ue_id} is stopped.   console=${P_console}


Detach UE From LTE
    [Documentation]
    ...    Initiates UE or MME-initiated detach procedure from LTE cell for the given ``ue_id``.
    ...
    ...    | ue_id          | ue_id configured in WTS configuration             |
    ...    | device_type    | device type initiating the detach procedure       |
    ...    | type           | type of network initiated (MME) detach procedure  |
    ...    | ue_detach_type | type of UE initiated detach procedure             |
    ...
    [Arguments]   ${ue_id}   ${device_type}=ue   ${type}=not_specified   ${ue_detach_type}=automatic
    Send Egate Command And Verify Output   cmd=ue_detach id=${ue_id} ${device_type} type=${type} ue_detach_type=${ue_detach_type}
    ...   pass_regexp=UE${ue_id}: detached
    Log   ${\n}UE${ue_id} is detached from LTE   console=${P_console}


Trigger RLF
    [Documentation]
    ...    Trigger a radio link failure with the given cause ``failure_type`` for UE ``ue_id`` in dual connectivity.
    ...
    ...    | ue_id          | specified UE id                                           |
    ...    | failure_type   | cause of radio link failure                               |
    ...    | at             | specifies where UE detected radio link failure (gnb|enb)  |
    ...
    [Arguments]   ${ue_id}   ${failure_type}   ${at}
    ...   ${pass_regexp}=Successfully reconfigured dual connectivity .* Bearer-type change .* is successful
    Send Egate Command And Verify Output   cmd=ue_dc_rlf ue=${ue_id} failure_type=${failure_type} at=${at}
    ...   pass_regexp=${pass_regexp}
    Sleep   1s   reason=wait command to be executed
    Log   ${\n}RLF for UE${ue_id} is triggered   console=${P_console}


Add Bearer
    [Documentation]
    ...    Activates UE bearer ``bearer_id`` for UE ``ue_id``.
    ...
    ...    | ue_id      | ue_id configured in WTS configuration                     |
    ...    | bearer_id  | bearer id configured in WTS configuration                 |
    ...    | filter_id  | filter id to add (unique among all filters of the bearer) |
    ...
    [Arguments]   ${ue_id}   ${bearer_id}   ${filter_id}=0
    Send Egate Command And Verify Output   cmd=bearer_add ue=${ue_id} id=${bearer_id} filter=${filter_id} precedence=${bearer_id}
    ...   pass_regexp=Bearer-${bearer_id} .* created
    Log   ${\n}Bearer ${bearer_id} for UE${ue_id} is added   console=${P_console}


Delete Bearer
    [Documentation]
    ...    Deactivates UE bearer ``bearer_id`` for UE ``ue_id``.
    ...
    ...    | ue_id      | ue_id configured in WTS configuration     |
    ...    | bearer_id  | bearer id configured in WTS configuration |
    ...    | by         | initiator                                 |
    ...
    [Arguments]   ${ue_id}   ${bearer_id}   ${by}=pgw
    Send Egate Command And Verify Output   cmd=bearer_del ue=${ue_id} id=${bearer_id} by=${by}
    ...   pass_regexp=Bearer-${bearer_id} .* deleted
    Log   ${\n}Bearer ${bearer_id} for UE${ue_id} is deleted    console=${P_console}


Display Bearer Stats
    [Documentation]
    ...    Displays bearer statistics or per-traffic(s) statistics of the bearer.
    ...
    ...    | ue_id          | sets the ue_id configured in WTS configuration                                |
    ...    | direction      | ul|dl|bi traffic direction                                                    |
    ...    | type           | specify the statistics type                                                   |
    ...    | scell          | the carrier aggregation serving cell (carrier component, CC)                  |
    ...    | ..             | Primary is for scell index 0. Secondary is for scell indexes 1-7.             |
    ...    | format         | display format                                                                |
    ...    | size_unit      | unit of PDU/SDU/packets size                                                  |
    ...    | trf_id         | traffic id/ids (only for internal traffic. default=1). For 'l3_trf' type      |
    ...    | dc_cell_group  | displays the UE's MCG or SCG bearer statistics (appl. only for DC bearers)    |
    ...    | kwargs         | is an optional dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)     |
    ...
    ...    http://wts-documentation.dyn.nesc.nokia.net/wts-ci/eGate/WTS_2112_WK48_4.0.19019_3686685.2/html_files/html_cmd_files/bearer_stats.html
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}   ${direction}=bi   ${type}=l3   ${scell}=0   ${format}=short   ${size_unit}=auto
    ...   ${trf_id}=1   ${dc_cell_group}=all   &{kwargs}
    ${gNbCuType}   Get GNbCuType Info
    IF   '${gNbCuType}'=='NSA'   Set To Dictionary   ${kwargs}   dc_cell_group=${dc_cell_group}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    ${str}   Catenate
    ...   bearer_stats ue=${ue_id} dir=${direction} type=${type} scell=${scell} format=${format} size_unit=${size_unit}
    ...   trf_id=${trf_id}${command_args}
    ${output}   Send Egate Command And Verify Output   cmd=${str}
    ...   pass_regexp=Average data rate
    Log   ${\n}Stats for UE${ue_id} and${command_args} are displayed   console=${P_console}
    RETURN   ${output}


Display Bearer Stats For Multiple UE'S
    [Documentation]
    ...    Displays bearer statistics or per-traffic(s) statistics of the bearer.
    ...
    ...    | ue_id          | ue_id(s) configured in WTS configuration                                      |
    ...    | direction      | direction                                                                     |
    ...    | type           | statistics type                                                               |
    ...    | scell          | carrier aggregation serving cell (carrier component, CC). Primary is for      |
    ...    | ..             | scell index 0. Secondary is for scell indexes 1-7                             |
    ...    | format         | display Format                                                                |
    ...    | size_unit      | unit of PDU/SDU/packets size                                                  |
    ...    | trf_id         | traffic id/ids (only for internal traffic. For 'l3_trf' type                  |
    ...    | dc_cell_group  | displays the UE's MCG or SCG bearer statistics (appl. only for DC bearers)    |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)                    |
    ...
    ...    http://wts-documentation.dyn.nesc.nokia.net/wts-ci/eGate/WTS_2112_WK48_4.0.19019_3686685.2/html_files/html_cmd_files/bearer_stats.html
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}   ${direction}=bi   ${type}=l3   ${scell}=0   ${format}=short   ${size_unit}=auto
    ...   ${trf_id}=1   ${dc_cell_group}=all   &{kwargs}
    ${gNbCuType}   Get GNbCuType Info
    IF   '${gNbCuType}' == 'NSA'   Set To Dictionary   ${kwargs}   dc_cell_group=${dc_cell_group}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    ${str}   Catenate
    ...   bearer_stats ue=${ue_id} dir=${direction} type=${type} scell=${scell} format=${format} size_unit=${size_unit}
    ...   trf_id=${trf_id}${command_args}
    ${output}   Send Egate Command And Verify Output    cmd=${str}
    ...   pass_regexp=[0-9]{0,2}:
    Log   ${\n}Stats for UE${ue_id} and${command_args} are displayed   console=${P_console}
    RETURN   ${output}


Get Bearer Stats From Egate
    [Documentation]
    ...
    ...    Reads the output of bearer stats and returns the output as dict/int.
    ...    Output with ``only_average=${False}`` is a Dictionary containing ue_id, timestamp and all the gathered data.
    ...    If used with ``only_average=${True}`` it will return an integer value of the Average throughput of the first item in egate output.
    ...    This should not be used with more than one UE or direction.
    ...
    ...    | ue_id          | Id's of UE's in WTS                                                                                       |
    ...    | dir            | Direction (ul|dl|bi)                                                                                      |
    ...    | trf_id         | Id or Ids of Traffic                                                                                      |
    ...    | mode           | Defines the output you want. accepts "legacy", "only_average" and "all", which will return all data       |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. id=2 or pdu=1)                                                |
    ...
    ...    please refer to the egate documentation of bearer stats egate command too:
    ...    Description of all E Gate parameters can be found here: select 'bearer_stats' for bearer stats command description:
    ...
    ...    https://wts-ci-main.dyn.nesc.nokia.net/job/WTS.Documentation.Egate/E-Gate_20Documentation/
    ...
    ...    *Example*
    ...    | ${data_rate}= | wts_ue.Get Bearer Stats From Egate | ue_id=1,2,3 | id=2,3 | dir=dl | trf_id=1 |
    ...
    ...    *Returns*   traffic Int or Dict, depending on "mode" parameter. mode="only_average" -> INT; mode="legacy" -> Dict.
    ...                For mode="all" will return a dict as well, but with the key's named exactly like in the "bearer_stats" output.
    ...    If it fails, returns string.
    ...    | dict for mode "legacy" has the following structure (all throughput values in bps):
    ...    | {
    ...    |      "UE_101": "UL": {"Average_Throughput": 10000, "Current_Throughput": 12311},
    ...    |                "DL": {"Average_Throughput": 500000, "Current_Throughput": 123111}
    ...    |      "timestamp": "22.03.2022 12:22:13.413579"
    ...    | }
    ...    | dict for mode "all" hast the following structure:
    ...    |{
    ...    |    "UE_101": "UL": {'Timebase interval (msec)': 1000, 'Average window size (in timebases)': 10, 'Real average window size': 1,
    ...    |                       'Maximum data rate': 5100000, 'Minimum data rate': 5100000, 'Average data rate': 5100000},
    ...    |    "timestamp": "26.06.2023 15:32:36.257704"
    ...    |}
    ...    Multiple UE's may be present, but only 1 timestamp per call.
    ...
    ...    To access certain elemets inside the dictionary the following syntax can be used: (sample shows access to dict for mode "all")
    ...    ${ret_val}= |       Get Bearer Stats From Egate | ue_id=101 | dir=bi | trf_id=1
    ...    ${timestamp}= |     Set Variable | ${ret_val["timestamp"]}                         # timestamp shows string "26.06.2023 15:32:36.257704"
    ...    ${av_data_rate}= |  Set variable | ${ret_val["UE_101"]["DL"]["Average data rate"]} # av_data_rate shows integer value 5100000
    ...    ${ul_data_rates}= | Set Variable | ${info["UE_101"]["DL"]} # ul_data_rates shows (sub)dict of all UL data rates of UE_101
    ...    # i.e. {'Timebase interval (msec)': 1000, 'Average window size (in timebases)': 10,... , 'Average data rate': 5100000}
    ...
    [Arguments]   ${ue_id}   ${dir}=bi   ${trf_id}=all   ${mode}=legacy   &{kwargs}
    ${dc_cell_group}   Set Variable If   '${dir}'=='dl'   scg   all

    ${output}   Display Bearer Stats For Multiple UE'S   ue_id=${ue_id}   direction=${dir}   trf_id=${trf_id}   type=l3
    ...   dc_cell_group=${dc_cell_group}   &{kwargs}

    ${result}   wts_tools.Get All Parameters From Bearer Stats Output   ${output}   mode=${mode}
    ${string_output}   Convert To String   ${result}
    IF   "${string_output}"=="No Data Found In Output"   Fail   msg=bearer_stats failed. Output is empty.
    RETURN   ${result}


Set Timing Adjustment
    [Documentation]
    ...   Set the test mode parameters given by ``kwargs`` dictionary for a ``profile_id``.
    ...
    ...   | profile_id      | test profile id                                                               |
    ...   | kwargs          | dictionary of pairs "parameter:value" (e.g. nb_reps_ta_sim=255 ue_speed=70)   |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=ue_ta_nr profile_id=${profile_id}${command_args}
    Sleep   1s   reason=wait command to be executed
    Log   ${\n}Timing adjustment for profile_id ${profile_id} and${command_args} is set   console=${P_console}


UE Register
    [Documentation]
    ...    Performs UE registration for the given ``ue_id``.
    ...
    ...    | ue_id          | Specified UE ID                                           |
    ...    | nwslice        | id of the Network Slice containing the requested NSSAI    |
    ...    | pass_regexp    | Regexp indicating that the command passed                 |
    ...    | kwargs         | Optional additional arguments                             |
    ...
    ...    *Returns*   egate console output
    ...
    [Arguments]   ${ue_id}=1   ${nwslice}=1   ${pass_regexp}=Received REGISTRATION COMPLETE   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    ${output}   Send Egate Command And Verify Output   cmd=ue_register id=${ue_id} nwslice=${nwslice} ${command_args}
    ...   pass_regexp=${pass_regexp}
    Log   ${\n}UE${ue_id} registration is successful   console=${P_console}
    RETURN   ${output}


UE Deregister
    [Documentation]
    ...
    ...    | ue_id              | Specified UE ID                                   |
    ...    | ue_deregister_type | Type of UE initiated deregister procedure         |
    ...    | by                 | Device type initiating the deregister procedure   |
    ...
    [Arguments]   ${ue_id}=1   ${ue_deregister_type}=switch_off   ${by}=ue
    wts_ue.Send Egate Command And Verify Output   cmd=ue_deregister id=${ue_id} ue_deregister_type=${ue_deregister_type} by=${by}
    ...   pass_regexp=UE${ue_id}: detached
    Log   ${\n}UE${ue_id} deregistration is successful   console=${P_console}


UE Dual Connectivity Release
    [Documentation]
    ...    command to trigger LTE-NR dual connectivity release
    ...
    ...    | ue_id      | Specified UE ID                               |
    ...    | bearer     | Bearer ID List                                |
    ...    | by         | Determines the initiator of the DC procedure  |
    ...    | cause      | Cause for the DC procedure                    |
    ...
    [Arguments]   ${ue_id}=11   ${bearer}=2   ${by}=enb   ${cause}=off
    wts_ue.Send Egate Command And Verify Output   cmd=enb_ue_dc_release ue=${ue_id} bearer=${bearer} by=${by} cause=${cause}
    ...   pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Log   ${\n}UE${ue_id} Dual Connectivity Released   console=${P_console}


UE PDU Session Setup
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue_id          | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...    | fail_regexp    | regexp to fail the KW if found in egate command response                                  |
    ...
    ...    *Returns*   ue ip    and    egate console output
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful   ${fail_regexp}=${None}
    ${output}   Send Egate Command And Verify Output   cmd=ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
    ...   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    ${pattern}   Catenate   Allocated PduSessionFsm with PDU session ID:${pdu} .*
    ...   UE IP address:([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})
    ${ue_ip}   String.Get Regexp Matches   ${output}   ${pattern}   1
    Log   ${\n}UE${ue_id} PDU${pdu} session setup is successful   console=${P_console}
    RETURN   ${ue_ip[0]}    ${output}


UE PDU Session Setup And Analyze Output
    [Documentation]
    ...    Performs ue_pdu_session_setup and checks if given ``pass_regexp`` is found in egate console output.
    ...
    ...    | pdu            | PDU Session ID                                                                            |
    ...    | gw             | PDU Gateway ID. Specifies gateway to use for this PDU session                             |
    ...    | ue_id          | Specified UE ID                                                                           |
    ...    | nwslice        | Requested Network Slice for the PDU Session                                               |
    ...    | pass_regexp    | Initial Context Setup Successful (for 1st PDU session)                                    |
    ...    | ..             | Pdu Session.*successfully (for further PDU sessions in case of more than 1 PDU session)   |
    ...    | fail_regexp    | regexp to fail the KW if found in egate command response                                  |
    ...
    ...    *Returns*   ue ip    and    egate console output
    [Arguments]  ${ue_id}=1   ${pdu}=1   ${nwslice}=1   ${gw}=1   ${pass_regexp}=Initial Context Setup Successful
    ...  ${target_path}='/tmp/egate_ouput.json'    ${regex_search}=${EMPTY}
    ${status}  ${egate_output}   Run Keyword And Ignore Error  UE PDU Session Setup     ue_id=${ue_id}
    ...    pdu=${pdu}   nwslice=${nwslice}  gw=${gw}  pass_regexp=${pass_regexp}
    Analyze Egate Log  status=${status}  egate_output=${egate_output[${1}]}    target_path=${target_path}
    ...    ue_id=${ue_id}  regex_search=${regex_search}


Analyze Egate Log
    [Documentation]  Analyzes egate output and looks for messages with a given regular expression
    [Arguments]  ${status}  ${egate_output}  ${target_path}  ${ue_id}  ${regex_search}=${EMPTY}
    IF   '${status}'=='FAIL'  Log  ${\n}ue_${ue_id} was not attached sucessfully.  level=Error  console=True
    IF    'not ${regex_search}'
        ${regex_search}     Create List  eventId event[A,B]\\d  frequencyBandList
    END
    egate_analyzer.Analyze Egate Output  egate_output=${egate_output}  target_file_path=${target_path}  ue_id=${ue_id}
    ...  regex_search=${regex_search}


UE PDU Session Modify
    [Documentation]
    ...    Added additional qos flows to pdu session of an UE. By default adds flows 2 and 3, which are pre-configured in
    ...    basic_setup.cfg and necessary for VoNR.
    ...
    ...    | ue_id              | Specified UE ID                                          |
    ...    | pdu                | PDU Session to be modified                               |
    ...    | list qos_flow_list | list of all the used qos_flows that should be added      |
    ...    | by                 | Device type initiating the procedure ue|amf              |
    ...    | pass_regexp        | regexp to pass the KW if found in egate command response |
    ...    | fail_regexp        | regexp to fail the KW if found in egate command response |
    ...
    [Arguments]   ${ue_id}   ${pdu}=1   ${qos_flow_list}=${NONE}   ${by}=amf   ${pass_regexp}=Added QosFlow with QFI   ${fail_regexp}=${None}
    ${default_qos_list}   Create List   ${2}   ${3}
    ${qos_flow_list}      Set Variable If   ${qos_flow_list}   ${qos_flow_list}   ${default_qos_list}

    FOR   ${qos_parameter}   IN   @{qos_flow_list}
        Log   ${\n}ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}   console=${P_console}
        Send Egate Command And Verify Output   cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qos_parameter} by=${by}
        ...   pass_regexp=${pass_regexp}   fail_regexp=${fail_regexp}
    END


UE PDU Session Release
    [Documentation]
    ...
    ...    | pdu            | PDU Session ID                    |
    ...    | ue_id          | Specified UE ID                   |
    ...    | pass_regexp    | Successfully released PDU Session |
    ...
    [Arguments]   ${ue_id}=1   ${pdu}=1   ${pass_regexp}=Successfully released PDU Session
    Send Egate Command And Verify Output   cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu} by=amf
    ...   pass_regexp=${pass_regexp}
    Log   ${\n}UE${ue_id} PDU${pdu} session release is successful   console=${P_console}


Check Current Egate Console Status
    [Documentation]
    ...    flush the egate log to update egate_console.log then check for the query
    ...    should be used for triggerless/async events e.g. NG Link, SIB, MIB, Cell Setup for SA
    ...
    ...    | query          | Specific log in egate console     |
    ...
    ...    *Example*
    ...    | Check Current Egate Console Status | NG link is Up |
    ...
    [Arguments]   ${query}
    Send Egate Command And Verify Output   cmd=sim_log_set flush

    ${egate_log}   OperatingSystem.Run   grep -i '${query}' ${tl.core.dir_path}/egate_console.log
    Should Contain   ${egate_log}   ${query}   ignore_case=True


Save Current Egate Console Log
    [Documentation]
    ...    for post analysis of egate_console.log per testcase
    ...    flushes the egate log to update egate_console.log then save to target directory
    ...
    ...    | target_dir     | Directory to store the egate_console.log file |
    ...    | target_name    | filename to save the file                     |
    ...
    ...    *Returns*   path to the stored egate log
    ...
    [Arguments]   ${target_dir}=${None}   ${target_name}=egate_console.log
    IF   '${target_dir}'=='${None}'
        ${target_dir}   testline.Get Testcase Log Directory
    END
    Send Egate Command And Verify Output   cmd=sim_log_set flush

    OperatingSystem.Run   cp ${tl.core.dir_path}/egate_console.log ${target_dir}/${target_name}
    RETURN   ${target_dir}/${target_name}


Configure NR BLER Testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                       |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. dl_bler=100,600,700,800,200,300,400,500)  |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=bler_testmode_nr profile_id=${profile_id}${command_args}
    Sleep   1s   reason=wait command to be executed
    Log   ${\n}NR BLER testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Configure NR Advanced BLER Testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                             |
    ...    | kwargs | dictionary of pairs "parameter:value" (e.g. target_bler, retx_target_bler1, target_mcs, rank...)|
    ...    | please find more details --> https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1743587025|
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=adv_bler profile_id=${profile_id}${command_args}
    Send Egate Command And Verify Output   cmd=adv_bler profile_id=${profile_id}
    ...   pass_regexp=adv_bler_testmode_nr Parameters
    Log   NR Advanced BLER testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Configure Beam Control Testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                                   |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ...) |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=beam_control_testmode_nr profile_id=${profile_id}${command_args}
    Sleep   1s   reason=wait command to be executed
    Log   ${\n}Beam Control testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Delete NR UL SINR Testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                   |
    ...
    [Arguments]   ${profile_id}
    Send Egate Command And Verify Output   cmd=ul_sinr_testmode_nr profile_id=${profile_id} delete=true
    Send Egate Command And Verify Output   cmd=ul_sinr_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=UlSinr TestMode not configured
    Log   ${\n}NR UL SINR testmode for profile_id ${profile_id} is deleted   console=${P_console}


Configure NR UL SINR Testmode
    [Documentation]
    ...
    ...    | profile_id | test profile id                                                                   |
    ...    | kwargs     | dictionary of pairs "parameter:value" (e.g. sinr_target_pusch=100 pathloss=40)    |
    ...
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=ul_sinr_testmode_nr profile_id=${profile_id}${command_args}
    Send Egate Command And Verify Output   cmd=ul_sinr_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=ul_sinr_testmode_nr Parameters
    Log   ${\n}NR UL SINR testmode for profile_id ${profile_id} and${command_args} is configured   console=${P_console}


Associate UEs To Testmode
    [Documentation]
    ...
    ...    | ue_id          | specified UE ID                                                                           |
    ...    | scell          | carrier Aggregation serving cell (carrier component, CC). Primary is for scell index 0.   |
    ...    | ..             | Secondary is for scell indexes 1-7.                                                       |
    ...    | testmode       | testmode to be used                                                                       |
    ...    | profile_id     | test profile id                                                                           |
    ...    | action         | triggers the activation or the deactivation of the test mode (activate or deactivate)     |
    ...
    [Arguments]   ${ue_id}   ${testmode}   ${profile_id}   ${action}   ${scell}=0
    ${command}   Set Variable   ue_testmode_set_nr id=${ue_id} scell=${scell} testmode=${testmode} profile_id=${profile_id} action=${action}
    Send Egate Command And Verify Output   cmd=${command}
    Sleep   1s   reason=wait command to be executed
    Log   ${\n}${action} testmode ${testmode} for UE${ue_id} scell=${scell} and profile_id ${profile_id}   console=${P_console}


Update Dual Connectivity Parameters
    [Documentation]
    ...
    ...    | id             | local identifier for eNodeB / gNodeB                                              |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. serving_cell_index_range_scg=5:31)    |
    ...
    [Arguments]   ${id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=enb_endc_param id=${id}${command_args}
    Sleep   1s   reason=wait command to be executed
    Log   ${\n}Dual connectivity with id=${id} is updated with${command_args}   console=${P_console}


Update UE Channel State Information
    [Documentation]
    ...
    ...    | profile_id     | specified profile_id                                          |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. cqi_mode=fixed)   |
    ...
    ...    Note: The profile_id used should be in active state and this could be achieved by the
    ...    keyword `Associate UEs to testmode` either before or after this keyword
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=csi_override_testmode_nr profile_id=${profile_id}${command_args}
    Send Egate Command And Verify Output   cmd=csi_override_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=csi_override_testmode_nr Parameters
    Log   ${\n}Channel State Information for UE is updated with${command_args}   console=${P_console}


Update UE Radio Link Failure
    [Documentation]
    ...
    ...    | profile_id     | specified profile_id                                          |
    ...    | kwargs         | dictionary of pairs "parameter:value" (e.g. cqi_mode=fixed)   |
    ...
    ...    Note: The profile_id used should be in active state and this could be achieved by the
    ...    keyword `Associate UEs to testmode` either before or after this keyword
    [Arguments]   ${profile_id}   &{kwargs}
    ${command_args}   Convert Dictionary To Parameter String   &{kwargs}
    Send Egate Command And Verify Output   cmd=rlf_testmode_nr profile_id=${profile_id}${command_args}
    Send Egate Command And Verify Output   cmd=rlf_testmode_nr profile_id=${profile_id}
    ...   pass_regexp=rlf_testmode_nr Parameters
    Log   ${\n}Radio Link Failure for UE is updated with${command_args}   console=${P_console}


Configure Multiple UEs In WTS Basic Configuration File
    [Documentation]
    ...    With this KW one can modify and add multiple UEs in the wts configuration file.
    ...    The backup of the original file will be stored in /tmp/basic_setup_backup.cfg
    ...    Please note: This keyword can be used only if the default UE configuration needs to be duplicated
    ...                 for subsequent UEs.
    ...
    ...    | number_of_ues      | Number of UEs that you would like to be configured in WTS |
    ...    | start_ue_id        | Start of new ue_id                                        |
    ...    | source_file        | Path to basic cfg file that needs to be modified          |
    ...    | destination_file   | Path where modified basic cfg file must be stored         |
    ...    | mode               | Either SA or NSA configuration                            |
    ...    | refer_pdn          | Old LO_LO with default 1, set to 101 for new LO_LO        |
    ...
    ...    *Returns*   list of configured UEs for the given mode
    ...
    [Arguments]   ${number_of_ues}=1   ${start_ue_id}=${EMPTY}
    ...   ${source_file}=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...   ${destination_file}=${tl.core.dir_path}/${tl.core.cfg_filename}
    ...   ${mode}=NSA  ${refer_pdn}=1

    OperatingSystem.Copy File   ${source_file}   /tmp/basic_setup_backup.cfg  #Create backup of original file

    IF          '${mode}'=='NSA'
        ${nsa_sa_ues_configured}    Configure Multiple NSA UEs In Basic Config File   number_of_ues=${number_of_ues}
        ...                             start_ue_id=${start_ue_id}   source_file=${source_file}   destination_file=${destination_file}
        ...                             refer_pdn=${refer_pdn}
    ELSE IF     '${mode}'=='SA'
        ${nsa_sa_ues_configured}    Configure Multiple SA UEs In Basic Config File   number_of_ues=${number_of_ues}
        ...                             start_ue_id=${start_ue_id}   source_file=${source_file}   destination_file=${destination_file}
    END
    RETURN   ${nsa_sa_ues_configured}[${mode}]


Connect To Running EGATE
    [Documentation]
    ...    Used for Precondition: egate and edaemon already started
    ...    Will just setup egate alias for keywords like "Send Egate Command and verify output"
    ...
    ...    | wts_alias  | alias name to handle egate for ute_wtssim |
    ...    | egate_port | used egate port                           |
    ...
    ...    *Returns*   True|False whether or not the ``pass_regexp`` was found in egate output
    ...
    [Arguments]   ${wts_alias}=ap_egate   ${egate_port}=${tl.core.egate_port}

    ute_wtssim.Setup Egate   egate_port=${egate_port}   host_ip=${tl.core.default_ssh_connection_details.addr}
    ...   tool_dir=${tl.core.dir_path}  alias=${wts_alias}
    ${wts_status}   Run Keyword And Return Status
    ...   Send Egate Command And Verify Output   cmd=sim_info   pass_regexp=Process ID   wts_alias=${wts_alias}
    RETURN   ${wts_status}


Sim Log Set Flush
    [Documentation]
    ...    flush the egate to update egate_console.log
    [Arguments]    ${wts_alias}=ap_egate
    ute_wtssim.Execute Egate Command    cmd=sim_log_set flush    timeout=5    alias=${wts_alias}


Convert Dictionary To Parameter String
    [Documentation]
    ...
    ...    | kwargs | dictionary of pairs "parameter:value" |
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   &{kwargs}
    ${command_args}   Set Variable   ${EMPTY}
    FOR   ${key}   IN   @{kwargs}
       ${value}   Collections.Get From Dictionary   ${kwargs}   ${key}
        ${command_args}   Set Variable   ${command_args} ${key}=${value}
    END
    RETURN   ${command_args}


Force WTS To Init State
    [Documentation]
    ...    Used to bring WTS from e.g. ACTIVE to INIT state.
    ...
    ...    *Scope* Internal
    ...
    ...    | wts_alias      | alias name to handle egate for ute_wtssim     |
    ...
    [Arguments]   ${wts_alias}
    Run Keyword And Return Status
    ...   Send Egate Command And Verify Output   cmd=re   pass_regexp=.*   wts_alias=${wts_alias}
    Sleep   5s   Guard time until WTS reaches INIT state
    ${sim_status}   Run Keyword And Return Status
    ...   Send Egate Command And Verify Output   cmd=sim_state_disp   pass_regexp=The state is INIT   wts_alias=${wts_alias}
    Sleep   30s   Guard time until AP becomes idle
    RETURN    ${sim_status}


Setup X2 Link
    [Documentation]
    ...     This KW calls egate cmd enb_x2_link_up for enb 1 with target 2 and verifies
    ...     'X2AP Link .* is up' is found in egate console output. An alias 'ap_egate' must exist.
    ...     Used for UTE Workaround keyword
    ...
    ...     *Scope*  Internal
    ...
    ute_wtssim.Execute Egate Command And Wait For Data
    ...   cmd=enb_x2_link_up enb=1 target=2   pass_regexp=X2AP Link .* is up   alias=ap_egate


Check Egate Output Ensure Cells Setup Successful
    [Documentation]
    ...     This KW checks the Egate Output for Cell Setup.
    ...     To ensure Airphone has correct status status after reboot and x2 link is setup.
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   ${total_cells}=1
    Send Egate Command And Verify Output   cmd=sim_log_set flush
    ${num_of_onair_cells}   OperatingSystem.Run   grep -i 'Cell Setup completed' ${tl.core.dir_path}/egate_console.log | wc -l
    Should Be Equal As Integers   ${num_of_onair_cells}   ${total_cells}   msg=Not all Cells on Air with Airphone
    # later should check all cells configured in basic.cfg, get cell id and compare with egate console log


Get Average Data Rate From Egate Output
    [Documentation]
    ...     KW to grep average data rate from given egate output ``output`` buffer.
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   ${output}
    ${output}   String.Get Lines Containing String   ${output}   Average data rate
    ${output}   String.Replace String   ${output}   Average data rate   ${EMPTY}
    @{words}    String.Split String     ${output}    (
    ${data_rate}   String.Strip String   ${words[0]}
    RETURN   ${data_rate}


Configure Multiple SA UEs In Basic Config File
    [Documentation]
    ...     Configures the Basic config file for multiple SA UEs
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   ${number_of_ues}   ${source_file}   ${destination_file}  ${start_ue_id}

    IF   not ${P_BASIC_CFG_CLEANED}
        wts_tools.Clean Up Basic CFG  path_to_basic_cfg=${source_file}   path_to_destination_file=${destination_file}
    END

    Set Suite Variable   ${P_BASIC_CFG_CLEANED}   ${TRUE}

    ${ues_configured}   wts_tools.Configure NSA SA UEs In Basic CFG   number_of_required_sa_ues=${number_of_ues}
    ...   start_sa_id=${start_ue_id}   path_to_basic_cfg=${destination_file}   modified_file_path=${destination_file}
    RETURN   ${ues_configured}


Configure Multiple NSA UEs In Basic Config File
    [Documentation]
    ...     Configures the Basic config file for multiple NSA UEs
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   ${number_of_ues}  ${source_file}   ${destination_file}   ${start_ue_id}  ${refer_pdn}=1
    IF   not ${P_BASIC_CFG_CLEANED}
        wts_tools.Clean Up Basic CFG  path_to_basic_cfg=${source_file}   path_to_destination_file=${destination_file}
    END
    Set Suite Variable   ${P_BASIC_CFG_CLEANED}   ${TRUE}

    ${ues_configured}   wts_tools.Configure NSA SA UEs In Basic CFG   number_of_required_nsa_ues=${number_of_ues}
    ...   start_nsa_id=${start_ue_id}   path_to_basic_cfg=${destination_file}   modified_file_path=${destination_file}
    ...   refer_pdn=${refer_pdn}
    RETURN   ${ues_configured}


Validate If Traffic Has Started On All UEs
    [Documentation]
    ...     Validates traffic start on single or multiple UEs
    ...
    ...     *Scope*  Internal
    ...
    [Arguments]   ${ue_ids}   ${output}   ${protocol}   ${direction}   ${command_args}
    ${ue_ids}   Convert To String   ${ue_ids}
    @{ue_ids_list}   String.Split String	${ue_ids}   ,
    FOR   ${UE_ID}   IN   @{ue_ids_list}
       ${matches}   Run Keyword And Warn On Failure   Should Match Regexp
       ...   ${output}   UE ${UE_ID}: ${protocol.upper()} ${direction.upper()} TRF
       IF    '${matches[0]}'=='PASS'
            Log     ${direction.upper()} ${protocol.upper()} data for UE${UE_ID} and${command_args} is started   console=${P_console}
       END
    END
