*** Settings ***
Documentation    Author: yonna.yao@nokia-sbell.com
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

Library    BuiltIn
Library    String
Library    OperatingSystem
Library    ute_fsmaccess
Resource    internal_airphone.robot
Resource    common_gnb.robot
Library     taf.transport.ssh    WITH NAME   TAF_SSH

*** Variables ***
${WTS_DIR}    /opt/wts/latest

*** Keywords ***
Wait Throughput Timer
    [Arguments]    ${time}
    [Documentation]    This keyword is used to sleep several seconds after start data traffic.
    ...    | Input Parameters | Man. | Description |
    ...    | time | Yes | time, unit is second |
    ...    Example:
    ...    | Wait Throughput Timer | 15 |
    Sleep    ${time}

Get Airphone Software Version
    [Documentation]    This keyword is to get airphone software version
    ...    Example:
    ...    | Get Airphone Software Version | |
    ...    | ${AP_version}= | Get Airphone Software Version | 
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_5G_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

Get WTS Version
    [Documentation]    This keyword is to get WTS version including below 1 suite variable.
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...    Example:
    ...    | Get WTS Version | |
    ...    | ${wts_version}= | Get WTS Version |
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/wts/latest
    @{split_list}    String.Split String    ${output}    /
    Set Global Variable    ${WTS_VERSION}    ${split_list[-1]}
    Set Suite Metadata    WTS Version    ${WTS_VERSION} 
    Log    WTS Version: ${WTS_VERSION}      console=${True}
    [Return]    ${WTS_VERSION}

Get RU Type
    [Arguments]    ${iphy_file}=${EMPTY}
    [Documentation]    this keyword is used to Get RU Type, AEQA,AAHF,AHLOA etc.
    ...    Example:
    ...    | ${RU_TYPE} | Get RU Type | |
    ...    | ${RU_TYPE} | Get RU Type | iphy.xml |
    ute_fsmaccess.Setup Wts Fsm Access
    ${online_cmd}=    Set Variable    cat /ffs/run/simmode/iphy.xml|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"|head -1
    ${local_cmd}=    Set Variable    cat ${iphy_file}|grep -Eo "<cardName>.*</cardName>"|grep -Eo "[[:upper:]]{4,5}"|head -1
    ${RU_TYPE}=    Run Keyword If    '${iphy_file}'=='${EMPTY}'    ute_fsmaccess.Execute Command On Wts    ${online_cmd}
    ...    ELSE    OperatingSystem.Run    ${local_cmd}
    ${RU_TYPE}=    String.Replace String Using Regexp    ${RU_TYPE}    \x00    ${EMPTY}
    Log    RRU Type is ${RU_TYPE}    console=${True}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${RU_TYPE}

Start WTS And Wait BTS Until Onair
    [Arguments]    ${cfg_file}=${None}    ${reload}=${True}    ${timeout}=1500
    [Documentation]    This keyword is used to wait bts on air until timeout happened, default timeout is 1500 seconds.
    ...    | Input Parameters | Man. | Description |
    ...    | ${cfg_file} | No | wts config file, default is get from gerrit store in /opt/wts/latetst/ |
    ...    | ${reload} | No | load lua cfg file or not, default is to load |
    ...    | ${timeout} | No | timeout, default is 1500 |
    ...    Examples:
    ...    | Start Wts And Wait Bts Until Onair | /opt/wts/latest/basic_fullstack_nsa_call_tdd_cmwv.cfg |
    Log To Console    Start WTS And Wait BTS Until Onair...
    ${nrbts_distname}=    Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Get NRBTS DistName
    Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Backup Scf    ${TEST_LOG_DIRECTORY()}    before_onair_scf.xml
    Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Get GNB Type    ${TEST_LOG_DIRECTORY()}/before_onair_scf.xml    ${nrbts_distname}
    ${gnb}=    String.Convert To Lowercase    ${GNBCUTYPE}
    ${cfg_file}=    Run Keyword If    '${cfg_file}' == '${None}'    Set Variable    ${WTS_CFG_FULL_PATH}
    ...             ELSE              Set Variable    ${cfg_file}
    Airphone Start Wtssim With Cfg File    ${cfg_file}    ${reload}
    Run Keyword If    '${gnb}' == 'nsa' and '${reload}' == '${True}'    _wait_sim_state_until_active_and_setup_x2_connection
    ...               timeout=${timeout}
    Run Keyword If    '${gnb}' == 'sansa' and '${reload}' == '${True}'  _wait_until_sib1_received_and_setup_x2_connection    timeout=${timeout}
    Run Keyword If    '${gnb}' == 'sa' and '${reload}' == '${True}'    _wait_until_sib1_received_for_all_cells    timeout=${timeout}
    Wait Until Keyword Succeeds    300    15    Verify BTS Is Onair

Backup Iphy Xml File
    [Arguments]    ${log_dir}    ${backup_name}=iphy.xml
    [Documentation]    This keyword is to back up SCF file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the scf file |
    ...    | ${backup_name} | No | the saved iphy.xml file name. default:iphy.xml |
    ...    Examples:
    ...    | Backup Iphy Xml File | /tmp |
    ${remote_path}=    Set Variable    /ffs/run/simmode/iphy.xml
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

Backup AP Swconfig File
    [Arguments]    ${log_dir}    ${backup_name}=ap_swconfig.txt
    [Documentation]    This keyword is to back up airphone swconfig file
    ...    | Input Parameters | Man. | Description |
    ...    | ${log_dir} | Yes | the folder directory to store the swconfig file |
    ...    | ${backup_name} | No | the saved swconfig file name. default:ap_swconfig.xml |
    ...    Examples:
    ...    | Backup AP Swconfig File | /tmp |
    ${remote_path}=    Set Variable    /ffs/run/swconfig.txt
    ${local_path}=    Set Variable    ${log_dir}/${backup_name}
    ${cp_cmd}=    Set Variable    sshpass -p ${AP_ASIK.password} scp ${AP_ASIK.username}@${AP_ASIK.ip}:${remote_path} ${local_path}
    OperatingSystem.Run    ${cp_cmd}

Airphone Upload Swconfig
    [Arguments]    ${ap_swconfig}
    [Documentation]    This keyword is used to upload swconfig.txt to Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${ap_swconfig} | Yes | ap_swconfig.txt with absolute path |
    ...
    ...    Examples:
    ...    | Airphone Upload Swconfig | ${CURDIR}/config_files/ap_swconfig.txt |
    ute_fsmaccess.Setup Wts Fsm Access
    ute_fsmaccess.Put Wts File    ${ap_swconfig}    /ffs/run/swconfig.txt    partition=active
    ute_fsmaccess.Execute Command On Wts    crasign /ffs/run/swconfig.txt
    ute_fsmaccess.Execute Command On Wts    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    ute_fsmaccess.Teardown Wts Fsm Access

Airphone Download L1ByPTestModeConfiguration from ABIL
    [Arguments]    ${local_l1bypass_path}      ${source_path}=/tmp/L1ByPTestModeConfiguration.xml
    [Documentation]    This keyword is used to download Airphone l1bypass.xml to pc.
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_l1bypass_path} | Yes | l1bypass.xml with absolute path |
    ...    | ${source_path} | No | L1ByPTestModeConfiguration's source path |
	...
    ...    Examples:
    ...    | Airphone Download l1bypass | ${CURDIR}/L1ByPTestModeConfiguration.xml |
    TAF_SSH.connect to    ${AP_ASIK.ip}   ${AP_ASIK.username}    ${AP_ASIK.password}   alias=iphy
    TAF_SSH.connect to    ${AP_ABIL_1.ip}    ${AP_ABIL_1.username}    ${AP_ABIL_1.password}    alias=bsh    proxy=iphy
    ${ret}    TAF_SSH.execute    ls /tmp |grep ${source_path[-8:]}   connection=bsh
    TAF_SSH.download file    ${source_path}    ${local_l1bypass_path}    connection=bsh
    TAF_SSH.Disconnect     connection=iphy

Airphone Upload L1ByPTestModeConfiguration to ASIK
    [Arguments]    ${local_l1bypass_path}     ${target_path}=/ffs/run/logs/L1ByPTestModeConfiguration.xml
    [Documentation]    This keyword is used to upload l1bypass.xml to Airphone.
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_l1bypass_path} | Yes | l1bypass.xml with absolute path |
    ...    | ${target_path} | Yes | L1ByPTestModeConfiguration's target path |
    ...
    ...    Examples:
    ...    | Airphone Upload l1bypass | ${CURDIR}/L1ByPTestModeConfiguration.xml |
    TAF_SSH.connect to    ${AP_ASIK.ip}   ${AP_ASIK.username}    ${AP_ASIK.password}    alias=iphy
    TAF_SSH.upload file    ${local_l1bypass_path}       ${target_path}    connection=iphy
    ${ret}    TAF_SSH.execute    ls /ffs/run/logs |grep ${target_path[-8:]}    connection=iphy	
    TAF_SSH.Disconnect     connection=iphy	  

Change Vlan Id In Iphy xml
    [Documentation]    This keyword is used to vRan iphy.xml modify.
    ...    | Input Parameters | Man. | Description |
    ...    | ${targe_iphy_path} | Yes | the target iphy.xml which need to be modified |
    ...
    ...    Examples:
    ...    | Change Vlan Id In Iphy xml | ${CURDIR}/iphy.xml |
    [Arguments]    ${targe_iphy_path}
    Backup Iphy Xml File    ${test_log_directory()}    source_iphy.xml
    ${vlan_id}    read xml    ${test_log_directory()}/source_iphy.xml    text|//preferredVlanId   
    ...    return_type=list
    ${uni_id}    evaluate    len(list(set(${vlan_id})))==1
    should be true    ${uni_id}    ${True}
    ${status}    ${msg}     Run Keyword And Ignore Error    File Should Exist     ${targe_iphy_path}
    ${base_xml}     Set Variable If    '${status}'=='PASS'    ${targe_iphy_path}     ${test_log_directory()}/source_iphy.xml
    modify xml    ${base_xml}     ${targe_iphy_path}    text|${vlan_id[0]}|//preferredVlanId
    
Wts Execute Aashell Command
    [Documentation]    This keyword is to execute command by 'nc 0 15007' with ute_fsmaccess.
    ...    Examples:
    ...    | Execute Aashell Command | confmgmtdefscli set --domain NrUeDlPhy --name a --value 1 --change-type persistent --timeout 5 |
    [Arguments]    ${command}
	${cmds}     split string    ${command}    ; 
    ute_fsmaccess.Setup Wts Fsm Access
	FOR     ${single}    IN    @{cmds} 
        ${ret}    ute_fsmaccess.Execute Command On Wts    bsh 1:1 "${single}"
	    log    ${ret}
    END
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access        
