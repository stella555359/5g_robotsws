*** Settings ***
Documentation    Author: leo.y.wang@nokia-sbell.com
...              \n GNB common operate keywords.
Library     BuiltIn
Library     String
Library     Telnet
Library     Collections
Library     OperatingSystem
Library     ute_fsmaccess
Library     taf.sbts.oam.coam.admin    WITH NAME   TAF_ADMIN
Library     ../../python/tak_gnb/tak_gnb/base.py     WITH NAME    GNB_BASE
Library     ../../python/tak_gnb/tak_gnb/commission.py     WITH NAME    GNB_COMMISSION
Library     taf.transport.ssh    WITH NAME    ssh
Resource    base.robot
Resource    internal_gnb.robot
Variables   ../scripts/gnb_randd_parameters.py
Resource    internal_ssh.robot

*** Variables ***
${MAX_REBOOT_TL_TIME}    3
${MAX_WAITTIME_CONFIGURED}      15min


*** Keywords ***
Get NRBTS DistName
    [Arguments]    ${scfc_file}=${EMPTY}
    [Documentation]    This keyword is to get the NRBTS distname for current gNB. e.g.MRBTS-1/NRBTS-1
    ...    Examples:
    ...    | ${nrbts_distname}= | Get NRBTS DistName | |
    ...    | ${nrbts_distname}= | Get NRBTS DistName | scfc.xml |
    ${nrbts_distname}=    Run Keyword If    '${scfc_file}'=='${EMPTY}'    _Onling Get NRBTS DistName
    ...    ELSE    _Get NRBTS DistName Via SCF    ${scfc_file}
    [Return]    ${nrbts_distname}

Get GNB Software Version
    [Documentation]    This keyword is to get gNB software version including below 3 suite variables.
    ...    Examples:
    ...    | Suite variable | Example | Description |
    ...    | ${SW_VERSION} | 0.800 | get the QT config files with the related version |
    ...    | ${SW_VERSION_TOTAL} | 0.800.779 | total sw version |
    ...    | ${SW_BRANCH} | 5G20B | the folder to stort config files for case |
    ${sw_info}=    _Get Software Info
    Log    Software Version: ${sw_info}    console=${True}
    @{sw_list}    String.Split String    ${sw_info}    _
    Run Keyword If    "${sw_list[0][:4]}"=="SBTS"    _Get Software Version On Common Package    ${sw_info}
    ...    ELSE    Get Software Version On 5G Pacakge    ${sw_info}

Get Control Board Type
    [Documentation]    this keyword is used to get control board Type, ASIK, ASIB, ASIL etc.
    ...    Examples:
    ...    | ${control_board_type}= | Get Control Board Type |
    ute_fsmaccess.Setup Enb Fsm Access
    ${cmd}=    Set Variable    cat /proc/device-tree/module-identity/unit-id
    ${board_type}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
    ${board_type}=    String.Replace String Using Regexp    ${board_type}    \x00    ${EMPTY}
    Log    Control Board Type is ${board_type}    console=${True}
    Set Global Variable    ${FCT_BOARD_TYPE}    ${board_type}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]    ${board_type}

Get Base Band Board Type
    [Documentation]    this keyword is used to get base band board Type, ABIL，ABIO，ABIN etc.
    ...    Examples:
    ...    | ${base_band_type}= | Get Base Band Board Type |
    ute_fsmaccess.Setup Enb Fsm Access
    ${board_type_list}    Create List
    FOR    ${loop}    IN RANGE    1    4
        ${cmd}=    Set Variable    bsh ${loop}:0 cat /proc/device-tree/module-identity/unit-id
        ${board_type}=     Run Keyword And Ignore Error    ute_fsmaccess.Execute Command On Enb    ${cmd}
        Exit For Loop If   'FAIL' in ${board_type}
        ${board_type}=    String.Replace String Using Regexp    ${board_type[1]}    \x00    ${EMPTY}
        Log    Base Band Board Type is ${board_type}    console=${True}
        Append To List    ${board_type_list}    ${board_type}
    END
    Set Global Variable    ${ASP_BOARD_TYPE}    ${board_type_list}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access
    [Return]   ${board_type_list}

Delta Commission With SCF File
    [Arguments]    ${delta_json}
    [Documentation]    This keyword is to update parameters with delta file
    ...    | Input Parameters | Man. | Description |
    ...    | delta_json | Yes | delta file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${delta_json}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Delta Commission With SCF File | Delta_Conf_5GC002504.json |    |
    ...    Example2:
    ...    | ${delta_json} | Set Variable | ${CURDIR}/delta.json |
    ...    | Delta Commission With SCF File | ${delta_json} |    |
    Log To Console    Perform delta commissioning...
    ${scf_path}    Set Variable    ${CURDIR}${/}config
    Get GNB Software Version
    ${nrbts_distname}=    Get NRBTS DistName
    ${join_delta_path}=    OperatingSystem.Join Path    ${scf_path}    ${SW_BRANCH}    SCF    ${delta_json}
    ${is_join_path_file_exist}=    Run Keyword And Return Status    File Should Exist    ${join_delta_path}
    ${delta_path}    Set Variable If    ${is_join_path_file_exist}==True    ${join_delta_path}    ${delta_json}
    Modify File Parameter    ${delta_path}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${nrbts_distname}
    TAF_ADMIN.Setup Admin    bts_host=${GNB_ASIK.ip}    alias=TAF_ADMIN_delta_scf
    TAF_ADMIN.Perform Delta Recommissioning
    ...    delta_file=${delta_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    ...    connection=TAF_ADMIN_delta_scf
    [Teardown]    Run Keyword And Ignore Error    TAF_ADMIN.Teardown    connection=TAF_ADMIN_delta_scf

Get BTS Procedural State
    [Documentation]    This keyword is to get bts procedural state:Commissioned, Configured, OnAir and so on.
    ...    Examples:
    ...    | ${BTS_PROCEDURAL_STATE}= | Get BTS Procedural State |
    TAF_ADMIN.setup admin    bts_host=${GNB_ASIK.ip}    alias=TAF_ADMIN_procedural
    ${bts_status}=    TAF_ADMIN.Get Bts Statuses    connection=TAF_ADMIN_procedural
    [Return]    ${bts_status['proceduralState']}
    [Teardown]    TAF_ADMIN.Teardown    TAF_ADMIN_procedural

Verify BTS Is Onair
    [Documentation]    This keyword is to verify bts procedural state is onair.
    ...    Examples:
    ...    | Verify BTS Is Onair |
    Log To Console    Verify BTS is onair...
    ${bts_procedural_state}    Get BTS Procedural State
    ${state}=    String.Convert To Lowercase    ${bts_procedural_state}
    Should Be Equal    ${state}    onair

Get CELL Operational State
    [Arguments]    ${cell_id}=1
    TAF_ADMIN.setup admin    bts_host=${GNB_ASIK.ip}    alias=TAF_ADMIN_operational
    ${cell_status}=    TAF_ADMIN.Get Cells Info    connection=TAF_ADMIN_operational
    [Return]    ${cell_status[${cell_id}-1]['status']['operationalState']}
    [Teardown]    TAF_ADMIN.Teardown    TAF_ADMIN_operational

Verify CELLS Are Onair
    ${scfc_on_gnb_now}=    Backup Scf     ${test_log_directory()}    scfc_now.xml
    ${xml}=    XML.Parse Xml    ${scfc_on_gnb_now}
    ${lcrids}=   XML.Get Elements Texts    ${xml}    .//managedObject[@class\="com.nokia.srbts.nrbts:NRCELL"]/p[@name\="lcrId"]
    FOR    ${cell_id}    IN    @{lcrids}
        ${cell_operational_state}    Get CELL Operational State    ${cell_id}
        ${state}=    String.Convert To Lowercase    ${cell_operational_state}
        Should Be Equal    ${state}    enabled
    END

Reboot Testline Via SSH
    [Documentation]    This keyword is to reboot GNB and Airphone with reboot command
    ...    Examples:
    ...    | Reboot Testline Via SSH |
    Log To Console    Reboot testline via ssh...
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} 'reboot'
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait Until Keyword Succeeds    120s    10s    check ping is disabled    ${GNB_ASIK.ip}
    Wait Until Keyword Succeeds    120s    10s    check ping is disabled    ${AP_ASIK.ip}
    Wait Until Keyword Succeeds    240s    10s    check ping is enabled    ${GNB_ASIK.ip}
    Wait Until Keyword Succeeds    240s    10s    check ping is enabled    ${AP_ASIK.ip}

Reset Testline
    [Documentation]    This keyword is to reset GNB with admin
    ...    Examples:
    ...    | Reset Testline |
    TAF_ADMIN.Setup Admin    bts_host=${GNB_ASIK.ip}    alias=TAF_ADMIN_reset
    TAF_ADMIN.reset          connection=TAF_ADMIN_reset
    [Teardown]    Run Keyword And Ignore Error    TAF_ADMIN.Teardown    connection=TAF_ADMIN_reset

Verify BTS Is Configured
    [Arguments]    ${remote_host}=${None}
    [Documentation]    This keyword is to check the state of gNB is Configured or IntegratedToRan
    ...    Examples:
    ...    | Verify BTS Is Configured |
    Log To Console    verify BTS is configured...
    TAF_ADMIN.Setup Admin    bts_host=${GNB_ASIK.ip}    remote_host=${remote_host}    alias=configured
    ${bts_state}    TAF_ADMIN.Get Mrbts State    connection=configured
    Log To Console    [INFO] BTS STATE : ${bts_state}
    Should Contain Any    ${bts_state}    Configured    IntegratedToRan    OnAir    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    TAF_ADMIN.Teardown    connection=configured

Verify Radio Is Online
    [Documentation]    This keyword is to check the state of Radio is online
    ...    Examples:
    ...    | Verify Radio Is Online |
    Log To Console    verify Radio is online...
    TAF_ADMIN.Setup Admin    bts_host=${GNB_ASIK.ip}    alias=radio
    ${bts_hw_info}    TAF_ADMIN.Get Bts Info    connection=radio
    ${radio_state}    Set Variable
    ...    ${bts_hw_info['radioModules']['rmod'][0]['status']['availabilityStatus']}
    Log To Console    [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    Online    ignore_case=True
    [Teardown]    Run Keyword And Ignore Error    TAF_ADMIN.Teardown    connection=radio

Verify GNB Is Configured and Radio Is Online
    [Documentation]    This keyword is to check the state of gNB is configured and Radio is online.
    ...    Examples:
    ...    | Verify GNB Is Configured and Radio Is Online |
    Log To Console    verify bts site is ready...
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify BTS Is Configured
    Wait Until Keyword Succeeds    ${MAX_WAITTIME_CONFIGURED}    30s    Verify Radio Is Online

Reboot TestLine And Make Sure GNB is Configured
    [Arguments]    ${max_reboot_time}=${MAX_REBOOT_TL_TIME}
    [Documentation]    This keyword is to soft reboot testline and check the status is configured.
    ...            It with try ${MAX_REBOOT_TL_TIME} times to make sure the testline can be reboot successfully.
    ...    | Input Parameters | Man. | Description |
    ...    | max_reboot_time | N | default read from global variable MAX_REBOOT_TL_TIME which set as 3 |
    ...    Examples:
    ...    | Reboot TestLine And Make Sure GNB is Configured | |
    ...    | Reboot TestLine And Make Sure GNB is Configured | $1 |
    Log To Console    Make sure BTS site is ready by rebooting at most ${MAX_REBOOT_TL_TIME} times...
    FOR    ${index}    IN RANGE    1    ${max_reboot_time}+1
        Log To Console    ===============Reboot Time: ${index}==============
        Reset Testline
        ${res}    Run Keyword And Return Status    Verify GNB Is Configured and Radio Is Online
        Exit For Loop If    '${res}'=='True'
    END
    Run Keyword If    '${max_reboot_time}'=='0'    Verify GNB Is Configured and Radio Is Online

Backup Scf
    [Arguments]    ${log_dir}    ${backup_name}=scfc.xml
    [Documentation]    This keyword is to back up SCF file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${backup_name} | No | the saved SCF file name. default:scfc.xml |
    ...    Examples:
    ...    | Backup Scf | /tmp | before_suite |
    ...    | ${scfc_full_path}= | Backup Scf | /tmp | before_suite |
    TAF_ADMIN.Setup Admin    bts_host=${GNB_ASIK.ip}    alias=back_scf
    TAF_ADMIN.Get Current Scf File    local_dir_path=${log_dir}    file_name=${backup_name}    connection=back_scf    timeout=50
    [Teardown]    Run Keyword And Ignore Error    TAF_ADMIN.Teardown    connection=back_scf
    [Return]    ${log_dir}/${backup_name}

Backup Swconfig
    [Arguments]    ${log_dir}    ${backup_name}=swconfig.txt
    [Documentation]    This keyword is to back up swconfig file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the swconfig file |
    ...    | ${backup_name} | No | the saved swconfig file name. it like swconfig_back.xml, default: swconfig.txt |
    ...    Examples:
    ...    | Backup Swconfig | /tmp |
    ${remote_path}=    Set Variable    /ffs/run/swconfig.txt
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

Get Single Value From Scf File
    [Arguments]    ${file_path}    ${dist_name}    ${para_name}    ${list_name}=${EMPTY}
    [Documentation]    This keyword is to get single parameter value from SCF file
    ...    | Input Parameters | Man. | Description |
    ...    | ${file_path} | Yes | SCF file path |
    ...    | ${dist_name} | Yes | dist name for the parameter |
    ...    | ${para_name} | Yes | parameter name |
    ...    | ${list_name} | No | list name if the parameter in list, the default value is ${EMPTY} |
    ...    Examples:
    ...    | Get Single Value From Scf File | /tmp/SCF_before_suite.xml | MRBTS-1/NRBTS-1 | gNbCuType |
    ${root}=    XML.Parse XML    ${file_path}
    Should Be Equal    ${root.tag}    raml
    ${ele}=    Run Keyword If    '${list_name}' == '${empty}'
    ...    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//p[@name='${para_name}']
    ...    ELSE    XML.Get Element    ${root}    .//managedObject[@distName='${dist_name}']//list[@name='${list_name}']//p[@name='${para_name}']
    [Return]    ${ele.text}

Get GNB Type
    [Arguments]    ${file_path}    ${nrbts_distname}=MRBTS-1/NRBTS-1
    [Documentation]    This keyword is to get the value of GNB type from current SCF
    ...    | gNbCuType | NSA/SA |
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | Yes | SCF file path. |
    ...    | nrbts_distname | No | default: MRBTS-1/NRBTS-1. |
    ...    Examples:
    ...    | ${GNBCUTYPE}= | Get GNB Type | /tmp/SCF.xml |
    ${GNBCUTYPE}=    Get Single Value From Scf File    ${file_path}    ${nrbts_distname}    gNbCuType
    ${GNBCUTYPE}=    Set Variable If    "${GNBCUTYPE}"=="both" or "${GNBCUTYPE}"=="SA+NSA"    SANSA    ${GNBCUTYPE}
    Set Global Variable    ${GNBCUTYPE}
    [Return]    ${GNBCUTYPE}

Get CELL Technology
    [Arguments]    ${file_path}    ${nrbts_distname}=MRBTS-1/NRBTS-1
    [Documentation]    This keyword is to get the value of cell Technology from current SCF
    ...    | cellTechnology | TDD/FDD |
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | Yes | SCF file path. |
    ...    | nrbts_distname | No | default: MRBTS-1/NRBTS-1. |
    ...    Examples:
    ...    | ${CELLTECHNOLOGY}= | Get CELL Technology | /tmp/SCF.xml |
    ${CELLTECHNOLOGY}=    Get Single Value From Scf File    ${file_path}    ${nrbts_distname}/NRCELL-1    cellTechnology
    [Return]    ${CELLTECHNOLOGY}

Get FR Type
    [Arguments]    ${file_path}    ${nrbts_distname}=MRBTS-1/NRBTS-1
    [Documentation]    This keyword is to get the value of FR type from current SCF
    ...    | freqBandIndicatorNR | mmwv/cmwv | freqBandIndicatorNR>=127 == FR2==mmmv |
    ...    | Input Parameters | Man. | Description |
    ...    | file_path | Yes | SCF file path. |
    ...    | nrbts_distname | No | default: MRBTS-1/NRBTS-1. |
    ...    Examples:
    ...    | ${FR}= | Get FR Type | /tmp/SCF.xml |
    ${band_value}=    Get Single Value From Scf File    ${file_path}    ${nrbts_distname}/NRCELL-1    freqBandIndicatorNR
    ${fr_tag}    Evaluate    int(${band_value})>=int(127)
    ${FR}    Set Variable If    '${fr_tag}'=='True'    mmwv    cmwv
    [Return]    ${FR}

Get Radio Protocol Type
    [Arguments]    ${scfc_file}
    [Documentation]    This keyword to get radio protocol type from current scfc file
    ...    Examples:
    ...    | ${RF_TYPE}= | Get Radio Protocol Type| /tmp/SCF.xml |
    ${root}=    XML.Parse XML    ${scfc_file}
    Should Be Equal    ${root.tag}    raml
    ${radio_protocol}=    XML.Get Elements Texts    ${root}    .//p[@name="radioProtocolType"]
    ${rf}    Set Variable If    '${radio_protocol}[0]'=='eCPRI'    eCPRI    CPRI
    Set Global Variable    ${RF_TYPE}    ${rf}
    [Return]    ${rf}

Get Gnb Domain Id
    [Documentation]    get gnb domain id
    ...    Examples:
    ...    | ${domain_id}= | Get Gnb Domain Id |
    ${query_cmd}    Set Variable    ddal -s ddal_sysinfo_module_get_domain_id 0
    ${cmd}=    Set Variable    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} ${query_cmd} 2>/dev/null
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${cmd}
    ${dmid_regexp}    Set Variable    dmid=(?P<domain_id>\\d)
    @{matches}    String.Get Regexp Matches    ${output}    ${dmid_regexp}    domain_id
    [Return]    ${matches[0]}

Get GNB Position
    [Documentation]    get the position of gnb is in right side or left side
    ...    Examples:
    ...    | ${gnb_pos}= | Get GNB Position |
    ${gnb_domain_id}    Get Gnb Domain Id
    ${gnb_pos}    Set Variable If    ${gnb_domain_id}==2    right_side    left_side
    [Return]    ${gnb_pos}

Execute Cmd On Fct
    [Arguments]    ${cmd}
    [Documentation]    execute command on FCT and return output
    ...    Examples:
    ...    | ${output}= | Execute Cmd On Fct |
    ${exec_cmd}=    Set Variable    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} "${cmd}"
    ${ret}    ${output}=    OperatingSystem.Run And Return Rc And Output    ${exec_cmd}
    Should Be True    "${ret}"=="0"
    [Return]    ${output}

Set Gnb Side SEI1 Port
    [Documentation]    This keyword is to set gnb side SEI1 port
    ...    Refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1085125821
    ...    Examples:
    ...    | Set Gnb Side SEI1 Port |
    # enable Marvell  ports2
    Execute Cmd On Fct    echo 1 > /var/run/cpss/ports/2/enable
    # set eths2 up
    Execute Cmd On Fct    ifconfig eths2 up
    # Enable interface and monitor ports 4 &6 to port 2.
    Execute Cmd On Fct     ncp_portmirror -d netdriver -p xgmac97
    Execute Cmd On Fct     echo 2 both > /var/run/cpss/ports/4/mirroring_port
    Execute Cmd On Fct    echo 2 both > /var/run/cpss/ports/6/mirroring_port
    Execute Cmd On Fct    ncp_l2 -p XGMAC97 -I -senableSwitching.false
    Execute Cmd On Fct    ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
    Execute Cmd On Fct    ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false

Get L1Bypass Type
    [Documentation]    Get TL is configured as L1Bypass mode or FS mode
    ...    Examples:
    ...    | ${L1_type}= | Get L1Bypass Type |
    ssh.Connect_to          hostname=${GNB_ASIK.ip}
    ...                     username=${GNB_ASIK.username}
    ...                     password=${GNB_ASIK.password}
    ...                     alias=connection_get_bypass
    ${prompt}               Set variable      AaShell>
    ssh.Send command           telnet localhost 15007             connection=connection_get_bypass
    ssh.Read output until      ${prompt}       timeout=60         connection=connection_get_bypass
    ssh.Write input            tag -a\n                           connection=connection_get_bypass
    ${output}    ssh.Read output until      ${prompt}       timeout=300        connection=connection_get_bypass
    ssh.Write input            quit\n                             connection=connection_get_bypass
    ssh.Await execution end                                       connection=connection_get_bypass
    ${result}=                      Run Keyword And Return Status   should contain  ${output}   L1BypassMap
    Log                             ${result}
    ${L1_TYPE}=                     Set Variable IF     "${result}" == "True"    L1b    FS
    Set Global Variable             ${L1_TYPE}          ${L1_TYPE}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect         connection=connection_get_bypass
    [Return]    ${L1_TYPE}

Perform Full Commission And Delta Commission And Reach Onair
    [Arguments]    ${delta_json}    ${scfc}    ${wts_config}     ${wait_onair_timeout}=1500
    [Documentation]    This keyword with these steps:
    ...    1. get valan id form online scfc and set this value in ${scfc}
    ...    1. use step 1's scfc to do full commission
    ...    4. wait gnb to 'configred' status
    ...    5. use ${delta_jason} to do delat commission
    ...    6. start wts and wait bts until onair
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_json} | Yes | delta json's path |
    ...    | ${scfc} | Yes |  scfc path |
    ...    | ${wts_config} | Yes | wts path |
    ...    Examples:
    ...    | Modify TL VM And AP SCTP Configuration |  |  |
    ...    | Perform Full Commission And Delta Commission And Reach Onair | delta_json=Delta_Conf.json | scfc=scfc.xml | wts_config=wts_config.cfg |
    [Timeout]    ${wait_onair_timeout}
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_and_delta_commission/
    Perform Full Commission    ${new_scfc}
    Wait Until Keyword Succeeds    ${wait_onair_timeout}    5s    Verify BTS Is Configured
    Delta Commission With SCF File    ${delta_json}
    Wait Until RRU Configured    ${wait_onair_timeout}
    Start Wts And Wait Bts Until Onair    ${wts_config}    timeout=${wait_onair_timeout}

Perform Full Commission
    [Arguments]     ${scfc}
    [Documentation]    This keyword will use ${scfc} to do full commission
    ...    Examples:
    ...    | Perform Full Commission | scfc.xml |
    GNB_COMMISSION.Do Full Commissioning    ${scfc}

Perform Full Commission And Reach Onair
    [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}=1500    ${reset_after_commission}=${False}
    ...             ${wait_bts_timeout}=600    ${wait_rru_timeout}=600
    [Documentation]    This keyword will use ${scfc} to do full commission, and use ${wts_config} to start wts process and check onair
    ...    | Input Parameters | Man. | Description |
    ...    | scfc | Yes | SCF file path. |
    ...    | wts_config | Yes | WTS config file |
    ...    | wait_onair_timeout | No | timeout to check onair. Default is 1500 |
    ...    | reset_after_commission | No | Will reset bts after commission.Default is False |
    ...    Examples:
    ...    | Perform Full Commission And Reach Onair | scfc.xml |  wts_config.xml |
    Log to console    Perform Full Commissioning And Reach Onair start.
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
    Perform Full Commission     ${new_scfc}
    Run Keyword If    '${reset_after_commission}'=='True'     Reset Testline
    FOR    ${loop}    IN RANGE    2
        ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
        Run Keyword If    '${bts_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${bts_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${bts_status}' == 'False' and ${loop} >= 1    Fail
        ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
        Run Keyword If    '${rru_status}' == 'False' and ${loop} < 1    Reset Testline
        Continue For Loop If    '${rru_status}' == 'False' and ${loop} < 1
        Run Keyword If    '${rru_status}' == 'False' and ${loop} >= 1    Fail
        ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
         ...    timeout=${wait_onair_timeout}
        Return From Keyword If    '${onair_status}' == 'True'
        Run Keyword If    '${onair_status}' == 'False' and ${loop} < 1    Reset Testline
        Run Keyword If    '${onair_status}' == 'False' and ${loop} >= 1    Fail
    END

GNB Upload Swconfig
    [Arguments]    ${swconfig}
    [Documentation]    This keyword is used to upload swconfig.txt to GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig} | Yes | swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | GNB Upload Swconfig | ${CURDIR}/config_files/swconfig.txt |
    ute_fsmaccess.Setup eNB Fsm Access    alias=putswconfig
    ${file_path}    ute_fsmaccess.Put Enb Swconfig File    ${swconfig}    alias=putswconfig
    ute_fsmaccess.Execute Command On Enb    crasign /ffs/run/swconfig.txt   alias=putswconfig
	ute_fsmaccess.Execute Command On Enb    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7	alias=putswconfig
    ute_fsmaccess.Teardown eNB Fsm Access		alias=putswconfig

Wait Until RRU Configured
    [Arguments]    ${timeout}=200
    [Documentation]    This keyword is used to wait rru configured
    Log To Console    ...wait rru configured...
    TAF_ADMIN.Setup Admin    bts_host=${GNB_ASIK.ip}    alias=radio
    ${bts_hw_info}    TAF_ADMIN.Get Bts Info    connection=radio
    ${rru_list}    Set Variable    ${bts_hw_info['radioModules']['rmod']}
    ${rru_list_len}    Get Length    ${rru_list}
    FOR    ${rru_id}    IN RANGE   ${rru_list_len}
        Wait Until Keyword Succeeds    ${timeout}    5    _Verify RRU Is Configured    ${rru_id}    radio
    END
    [Teardown]    Run Keyword And Ignore Error    TAF_ADMIN.Teardown    connection=radio

Wait Unit Bts Configured
    [Arguments]    ${timeout}=200
    [Documentation]    This keyword is used to wait rru configured
    Log To Console    ...wait bts configured...
    Wait Until Keyword Succeeds    ${timeout}    5s    Verify BTS Is Configured

Online Recommissioning With Delta Json File
    [Arguments]    ${delta_path}    ${timeout}=300
    [Documentation]     This keyword will use delta file input by ${delta_path} to do commission.
    TAF_ADMIN.Setup Admin    name=delta_scf
    TAF_ADMIN.Perform Delta Recommissioning
    ...    delta_file=${delta_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=${timeout}
    ...    connection=delta_scf
    [Teardown]    TAF_ADMIN.Teardown Admin     connection=delta_scf

Perform Online Change Parameter Value
    [Documentation]     Perform parameter recommissioning, update and delete operation can be used.
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | Object dist name ie. "MRBTS-1/LNBTS-1/LNMME-0" |
    ...    | ${parameter} | Yes | Parameter name ie. "ipAddrPrim" |
    ...    | ${value}     | Yes | Parameter value ie. "10.0.1.99" or [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}] |
    ...    | ${operation} | No | Parameter operation, update or delete can be chosen. Default is update. |
    ...
    ...    Examples:
    ...    | Perform Online Change Parameter Value | MRBTS-1/LNBTS-1/LNMME-0 | ipAddrPrim | 10.0.1.99 | update |
    ...    | Perform Online Change Parameter Value | MRBTS-1/LNBTS-1/LNMME-0 | ipAddrPrim | 10.0.1.99 | delete |
    [Arguments]     ${dist_name}      ${parameter}      ${value}     ${operation}=update
    TAF_ADMIN.Setup Admin    name=onchangepara
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...    operation=${operation}    value=${value}    skip_parameter_relation_errors=True
    ...    should_activate=True     connection=onchangepara
    [Teardown]    TAF_ADMIN.Teardown Admin     connection=onchangepara

Get L1BypassMap From GNB
    [Documentation]     This Keyword is to Get L1BypassMap From GNB.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ownnid} | Yes | such as 0x224d.which get from command bsh 1:* ownnid  |
    ...    | ${frame_id} | Yes | ASP board index such as 1,2,3 |
    ...    Examples:
    ...    | Get L1BypassMap From GNB | 0x224d | 1 |
    [Arguments]    ${ownnid}    ${frame_id}
    ${L1_Node_id}    Run Keyword If    '${ownnid}'=='0x123d'    Set Variable    0x124D
    ...    ELSE IF    '${ownnid}'=='0x223d'    Set Variable    0x224D
    ...    ELSE IF    '${ownnid}'=='0x124d'    Set Variable    0x125D
    ...    ELSE IF    '${ownnid}'=='0x224d'    Set Variable    0x225D
    ${L1_frame_id}    Run Keyword If    '${frame_id}'=='1'    Set Variable    0x524A
    ...    ELSE IF    '${frame_id}'=='2'    Set Variable    0x534A
    ${L1BypassMap}    Set Variable    ${L1_Node_id}:${L1_frame_id}
    [Return]    ${L1BypassMap}

Change GNB From Fullstack To L1bypass
    [Documentation]    This keyword is to change gNB from fullstatck to L1bypass.
    ...    Examples:
    ...    | Change GNB From Fullstack To L1bypass |  |
    ${ASP_BOARDS_TYPE}    Get Base Band Board Type
    ${ASP_num}    Get Length    ${ASP_BOARDS_TYPE}
    ${frame_id_list}=    Create List    1    2    3
    ${L1BypassMap_list}    Create List
    ute_fsmaccess.Setup Enb Fsm Access
    FOR    ${frame_id}    IN    @{frame_id_list}
        Run Keyword If    ${frame_id}>${ASP_num}    Exit For Loop
        ${index}    Evaluate    ${frame_id}-1
        ${cmd}    Run Keyword If    '${ASP_BOARDS_TYPE[${index}]}'=='ABIL'    Set Variable    bsh 1:1 ownnid
        ...    ELSE IF    '${ASP_BOARDS_TYPE[${index}]}'=='ABIO'    Set Variable    bsh 1:0 ownnid
        ${ownnid}=    ute_fsmaccess.Execute Command On Enb    ${cmd}
        ${L1BypassMap}    Get L1BypassMap From GNB    ${ownnid}    ${frame_id}
        Collections.Append To List    ${L1BypassMap_list}    ${L1BypassMap}
    END
    Log    ${L1BypassMap_list}
    ${L1BypassMap_all}    Catenate    SEPARATOR=,    @{L1BypassMap_list}
    ${set_l1bypass_cmd}    Set Variable    echo "tag -3w app.btsom.nts.L1BypassMap ${L1BypassMap_all}" | nc 0 15007
    Log    execute:tag -3w app.btsom.nts.L1BypassMap ${L1BypassMap_all}
    ute_fsmaccess.Execute Command On Enb    ${set_l1bypass_cmd}
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access

Execute Aashell Command
    [Documentation]    This keyword is to execute command by 'nc 0 15007' with ute_fsmaccess.
    ...    Examples:
    ...    | Execute Aashell Command | tag -3w app.btsom.nts.L1BypassMap 0x224D:0x574A,0x225D:0x574A |
	...    | Execute Aashell Command | rad -mr 88;rad -mw 0x580184 0xa |
    [Arguments]    ${command}
	${cmds}     split string    ${command}    ;
    ute_fsmaccess.Setup Enb Fsm Access
	FOR     ${single}    IN    @{cmds}
        ${aashell_cmd}    Set Variable    echo "${single}" | nc 0 15007
        ${ret}    ute_fsmaccess.Execute Command On Enb    ${aashell_cmd}
	    log    ${ret}
    END
    [Teardown]    ute_fsmaccess.Teardown Enb Fsm Access

Get and Update BSR File
     [Arguments]      ${par_of_bsr_name}=BSR_AEQE_6_H6_ALN60
     ${bsr_file_path}     get BSR file name      ${par_of_bsr_name}
     TAF_ADMIN.setup admin
     ${ret}     TAF_ADMIN.Update Software      ${bsr_file_path}
     TAF_ADMIN.teardown admin

Change RandD parameters
    [Documentation]     ${RandDParametersFile} param value must be the same as python variable name in
    ...                 testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/resources/KISS/robot/scripts/gnb_randd_parameters.py
    [Arguments]      ${RandDParametersFile}    ${CP_UE_rdSktSpId}=17    ${CP_UE_rdSktPlmnId_ini}=1261976    ${CP_UE_rdUlPowerControl}=True
    ...        ${CP_UE_rdNsaInactTimer}=20    ${CP_UE_rdActInactDetNSAUe}=True
    ssh.Connect To                hostname=${GNB.ip}    username=${GNB.username}    password=${GNB.password}     alias=gNB_CLASSICAL_OAM
    ${CP_UE_TXZ_FILE} =     Get file name    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    Extract file    ${CP_UE_TXZ_FILE}    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktSpId    ${CP_UE_rdSktSpId}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdSktPlmnId    ${CP_UE_rdSktPlmnId_ini}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdUlPowerControl    ${CP_UE_rdUlPowerControl}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdNsaInactivityTimer    ${CP_UE_rdNsaInactTimer}    gNB_CLASSICAL_OAM
    Change RandD flag value    rdActInactDetNSAUe    ${CP_UE_rdActInactDetNSAUe}    gNB_CLASSICAL_OAM
    Compress and crasign RandD parameters file   ${CP_UE_TXZ_FILE}    ${RandDParametersFile}    gNB_CLASSICAL_OAM
    [Teardown]     Run Keyword And Ignore Error    ssh.Disconnect    connection=gNB_CLASSICAL_OAM
