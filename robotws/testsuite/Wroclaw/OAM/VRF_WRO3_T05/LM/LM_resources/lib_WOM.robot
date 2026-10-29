*** Settings ***
Documentation    Internal WOM resource library repetetive keywords in multiple tests.
          ...    Authors: maciej.ferus@nokia.com, jacek.rolla@nokia.com or artur.czainski@nokia.com
          ...
          ...    !! DO NOT COMMIT ANY CHANGES WITHOUT CONTACT WITH AUTHORS FIRST !!

Library         String
Library         OperatingSystem
Library         SSHLibrary
Library         Collections
Library         XML
Library         DateTime
Library         ute_syslog
Library         feedback_collector.py

Library       taf.nms.netact
Library       lib_WOM.py
Library       ssh_handler.py

*** Keywords ***
Get reserved sw build
    [Timeout]  2min
    ${reserved_sw_build}=  Run process  ${reserved_sw_build_cmd}  shell=True  cwd=${CURDIR}  timeout=60min
    Log  ${reserved_sw_build.stdout}  console=False
    set suite variable  ${RESERVED_BUILD}  ${reserved_sw_build.stdout}
    set suite variable  ${UTE_RESERVED_BUILD}  ${reserved_sw_build.stdout}

Get And Set NetAct Parameters
    [Documentation]    Get and set variables which are needed to setup NetAct as suite variables and additional set NA_TYPE as suite variable
    [Arguments]    ${host_db}=False
    ${oms_ip_0}  Get Parameter From Infomodel  /MRBTS-1/RAT-1/BTS_L-$${ENB_SIDE}//FTM-1  omsIpAddress
    Log    Oms ip is ${oms_ip_0}    console=True
    ${status}  run keyword and return status    Find Netact By Oms    southbound_ip=${oms_ip_0}
	run keyword if  "${status}"== "True"    Netact date from TA tool   ${oms_ip_0}    ${host_db}   ELSE    Sub Get And Set NetAct Parameters

Netact date from TA tool
	[Arguments]     ${oms_ip_0}      ${host_db}
	${netact}   Find Netact By Oms    southbound_ip=${oms_ip_0}
    ${NA_WAS}   Get From Dictionary    ${netact}    was_host
    ${NA_USER}  Get From Dictionary    ${netact}    was_ssh_user
    ${NA_PASS}  Get From Dictionary    ${netact}    was_ssh_pass
    ${WEB_URL}  Get From Dictionary    ${netact}    web_url
    ${meta}  Get From Dictionary    ${netact}    meta
    ${netact_name}  Get From Dictionary    ${meta}    name_display
    Log    Netact: ${netact_name}    console=true
    Log    Was IP: ${NA_WAS}    console=true
    Set Suite Variable    ${NA_WAS}    ${NA_WAS}
    Set Suite Variable    ${NA_DB}    ${NA_WAS}
    Set Suite Variable    ${NA_USER}    ${NA_USER}
    Set Suite Variable    ${NA_PASS}      ${NA_PASS}
    Set Suite Variable    ${netact_name}    ${netact_name}
    Set Suite Variable    ${WEB_URL}    ${WEB_URL}
	${NA_DB}=   run keyword if   "True"== "${host_db}"     Legacy Get NA Service IP  db    ${NA_WAS}

Sub Get And Set NetAct Parameters
    [Documentation]    Get and set variables which are needed to setup NetAct as suite variables and additional set NA_TYPE as suite variable
    [Arguments]    ${OMS_USER_0}=Nemuadmin    ${OMS_PASS_0}=nemuuser    ${OMS_PASS_ROOT_0}=siemens
    ${oms_ip_0}  Get Parameter From Infomodel  /MRBTS-1/RAT-1/BTS_L-${ENB_SIDE}//FTM-1  omsIpAddress
    Log    Oms ip is ${oms_ip_0}    console=True
    Setup Ta Oms    hostname=${oms_ip_0}    username=${OMS_USER_0}    password=${OMS_PASS_0}    alias=get_and_set_netact_parameters
    Switch User  user=root  password=${OMS_PASS_ROOT_0}    alias=get_and_set_netact_parameters
    ${netact_name}=    Get Connected Netact Name    alias=get_and_set_netact_parameters
    Log    Connected NetAct name ${netact_name}    console=True
    ${netact_ip}=    Get Connected Netact Ip    alias=get_and_set_netact_parameters
    Log    Connected NetAct ip ${netact_ip}    console=True
    ${netact_number}=    Get Regexp Matches    ${netact_name}    \\d+
    ${netact_number}=    Get From List    ${netact_number}    0
    ${netact_type}=    Remove String    ${netact_name}    ${netact_number}
    ${if_sprintlab}=    Run Keyword And Return Status    Should Be Equal As Strings    ${netact_type}    sprintlab
    ${if_clab}=    Run Keyword And Return Status    Should Be Equal As Strings    ${netact_type}    clab
    Run Keyword If    ${if_sprintlab}    Set Suite Variable    ${NA_TYPE}    sprintlab
    Run Keyword If    ${if_clab}    Set Suite Variable    ${NA_TYPE}    clab
  #  Set Suite Variable    ${NA_PASS}    Admin${netact_number}--User
    Set Suite Variable    ${NA_NWI3}    ${netact_ip}
    ${ip_db_node}=    Legacy Get NA Service IP    db    ${NA_NWI3}
    ${ip_was_node}=    Legacy Get NA Service IP    was    ${NA_NWI3}
    SSHLibrary.Open Connection    ${ip_db_node}
    ${netact_pass}    run keyword and return status  SSHLibrary.Login    omc    Admin${netact_number}--User
    run keyword if  ${netact_pass}   Set Suite Variable    ${NA_PASS}    Admin${netact_number}--User
    Run Keyword If    not ${netact_pass}    Set Suite Variable    ${NA_PASS}    omc
    Set Suite Variable    ${NA_DB}    ${ip_db_node}
    Set Suite Variable    ${NA_WAS}    ${ip_was_node}
    Set Suite Variable    ${NA_USER}    omc
    Set Suite Variable    ${OMS}    OMSXX
    Set Suite Variable    ${PLMN}    PLMN-PLMN
    [Teardown]    Run Keywords    Teardown Ta Oms    alias=get_and_set_netact_parameters    AND
           ...    Log    Get And Set NetAct Parameters finished    console=True    AND
           ...    SSHLibrary.Close Connection

Get NA Service IP
    [Documentation]  Reurns ip of node with required service
    [Arguments]    ${service}    ${na_node_ip}
    Log    Getting IP address of ${service.upper()} node:    console=True
    ${ssh_root_handler}=    Get Ssh Handler    ${na_node_ip}    root    ${NA_ROOT_PASS}
    ${host_output}=    Call method    ${ssh_root_handler}    exec_command
    ...    smanager.pl status service ${service} | head -1 | cut -d ':' -f2 | xargs host
    ${regex_matches}=    Get Regexp Matches    ${host_output}    [0-9]+.[0-9]+.[0-9]+.[0-9]+\n
    ${ip_address_match}=    Split String    ${regex_matches[0]}    \n
    ${ip_address}=    Get From List     ${ip_address_match}    0
    ${node_number}=    Get Node Number    ${ip_address}
    Log    > NetAct ${service.upper()} node ${node_number} IP address: ${ip_address}    console=True
    ${specific_node_ssh_handler}=    Get Ssh Handler    ${ip_address}    root    ${NA_ROOT_PASS}
    ${status}=    Call method    ${specific_node_ssh_handler}    check_connection
    Run Keyword If    not ${status}    Try to Use Second Password    ${ip_address}
    [Return]    ${ip_address}

Try to Use Second Password
    [Arguments]    ${na_ip}
    ${pass_2}=    Set Variable    Adminroot?123
    ${ssh_root_handler}=    Get Ssh Handler    ${na_ip}    root    ${pass_2}
    ${status}=    Call method    ${ssh_root_handler}    check_connection
    Should Be Equal    ${status}    True
    Set Suite Variable    ${NA_ROOT_PASS}    ${pass_2}

Legacy Get NA Service IP
    [Documentation]  Reurns ip of node with required service
    [Arguments]    ${service}    ${na_ip}
    Log    Getting IP address of working ${service.upper()} node:    console=True
    SSHLibrary.Open Connection    ${na_ip}
    SSHLibrary.Login    system    system
    SSHLibrary.Write    su -
    ${ssh_output}=    SSHLibrary.Read Until    :
    ${pass_1}=    Set Variable    arthur
    Log    > Trying to login to root with password: ${pass_1}    console=True
    SSHLibrary.Write    ${pass_1}
    ${ssh_output}=    Read From SSH Until Response
    ${if_correctly_logged}=    Run Keyword And Return Status    Should Not Contain    ${ssh_output}    incorrect password
    Run Keyword If    ${if_correctly_logged}    Set Suite Variable    ${NA_ROOT_PASS}    ${pass_1}
    ...       ELSE                              Legacy Try to Use Second Password
    Log    > Sending command to get appropriate ${service.upper()} node
    SSHLibrary.Write    smanager.pl status service ${service} | head -1 | cut -d ':' -f2
    ${ssh_stdout_get_node_name}=    Read From SSH Until Response
    ${ssh_stdout_get_node_name}=    Split String    ${ssh_stdout_get_node_name}
    ${ssh_stdout_get_node_name}=    Get From List     ${ssh_stdout_get_node_name}    0
    ${ssh_stdout_get_node_name}=    Strip String    ${ssh_stdout_get_node_name}
    Log    > Login into appropriate ${service.upper()} node
    SSHLibrary.Write    ssh system@${ssh_stdout_get_node_name}
    ${ssh_output}=    Read From SSH Until Response
    Log  ${ssh_output}
    SSHLibrary.Write    system
    ${ssh_output}=    Read From SSH Until Response
    SSHLibrary.Write    su -
    ${ssh_output}=    Read From SSH Until Response
    Run Keyword If    not ${if_correctly_logged}    SSHLibrary.Write    Adminroot?123
    Run Keyword If    ${if_correctly_logged}    SSHLibrary.Write    arthur
    ${ssh_output}=    Read From SSH Until Response
    Log    > Get IP of appropriate ${service.upper()} node
    SSHLibrary.Write    ifconfig
    ${ssh_output}=    Read From SSH Until Response
    ${list_of_node_ips}=    Get Regexp Matches    ${ssh_output}   inet[^0-9]*(10.\\d+.\\d+.\\d+)    1
    ${ip_node}=    Get From List    ${list_of_node_ips}    0
    [Teardown]  SSHLibrary.Close Connection
    Log    > IP address of working ${service.upper()} node is ${ip_node}    console=True
    [Return]    ${ip_node}

Read From SSH Until Response
    FOR    ${i}    IN RANGE   200
        ${ssh_output_begin}=    SSHLibrary.Read    delay=0.1s
        ${not_empty_output}=    Run Keyword And Return Status    Should Not Be Empty    ${ssh_output_begin}
        Exit For Loop IF    ${not_empty_output}
    END
    ${ssh_output_end}=    SSHLibrary.Read    delay=1s
    ${ssh_output}=    Set Variable   ${ssh_output_begin}${ssh_output_end}
#    Should Not Be Empty    ${ssh_output}
    [Return]  ${ssh_output}

Legacy Try to Use Second Password
    [Documentation]    Keyword used if first password didn't work
    ${pass_2}=    Set Variable    Adminroot?123
    Log    Trying to login to root with password: ${pass_2}    console=True
    SSHLibrary.Write    su -
    ${ssh_output}=    SSHLibrary.Read Until    :
    SSHLibrary.Write    ${pass_2}
    ${ssh_output}=    Read From SSH Until Response
    Should Not Contain    ${ssh_output}    incorrect password
    Set Suite Variable    ${NA_ROOT_PASS}    ${pass_2}

    ### SRAN/FLAT ###

Get And Set NetAct Parameters SRAN
    [Documentation]    Get and set variables which are needed to setup NetAct as suite variables and additional set NA_TYPE as suite variable
    Get And Set Specific NetAct Parameters with FLAT

Get And Set Specific NetAct Parameters with OAM
    [Arguments]    ${current_oam_ip}
    Log    ${\n}Getting node IP and NetAct password from hardcoded dictionary:    console=True
    ${na_pass}    ${na_node_ip}=    Get Appropriate Pass And Node Ip    ${current_oam_ip}
    Log    > OAM IP address: ${current_oam_ip}    console=True
    Log    > NetAct password: ${na_pass}    console=True
    Get And Set Specific NetAct Parameters    ${na_pass}    ${na_node_ip}

Get Appropriate Pass And Node Ip By Name
    [Documentation]    Returns apropriate na_pass and netact node for given netact name
    ${status_Netact_flat}     run keyword and return status  Variable Should Exist    ${Netact_flat}
    ${choosen_netact_dictionary}   run keyword if  '${status_Netact_flat}' == 'True'     get netact by name     ${Netact_flat}
    ...    ELSE      Get enb Connected to Flat Netacts    ${ENB_RELEASE}
    ${na_pass}=    Get From Dictionary    ${choosen_netact_dictionary}    password
    ${na_node_ip}=    Get From Dictionary    ${choosen_netact_dictionary}    node_ip
    ${netact_name}=    Get From Dictionary    ${choosen_netact_dictionary}    netact_name
    ${CLS_API_HOST_EXIST}=    Run keyword and return status    Get From Dictionary    ${choosen_netact_dictionary}    CLS_API_HOST
    ${CLS_DATABASE_HOST_EXIST}=    Run keyword and return status   Get From Dictionary    ${choosen_netact_dictionary}    CLS_DATABASE_HOST
    ${CLS_API_HOST}    Run keyword if    '${CLS_API_HOST_EXIST}'=='True'    Get From Dictionary    ${choosen_netact_dictionary}    CLS_API_HOST
    ${CLS_DATABASE_HOST}    Run keyword if    '${CLS_DATABASE_HOST_EXIST}'=='True'   Get From Dictionary
    ...    ${choosen_netact_dictionary}    CLS_DATABASE_HOST
    ${web_gui_username_exist}=    Run keyword and return status    Get From Dictionary    ${choosen_netact_dictionary}    web_gui_username
    ${web_gui_password_exist}=    Run keyword and return status   Get From Dictionary    ${choosen_netact_dictionary}    web_gui_password
    ${web_gui_username}    Run keyword if    '${web_gui_username_exist}'=='True'    Get From Dictionary
    ...    ${choosen_netact_dictionary}    web_gui_username
    ${web_gui_password}    Run keyword if    '${web_gui_password_exist}'=='True'   Get From Dictionary
    ...    ${choosen_netact_dictionary}    web_gui_password
    ${regex}=    Get Regexp Matches    ${netact_name}    srn
    ${status}=    Run keyword and return status    Should not be empty    ${regex}
    Run keyword if    ${status}      Set Suite Variable    ${WEB_URL}    https://${netact_name}lbwas.srnblr.nsn-rdnet.net
    ...   ELSE    Set Suite Variable    ${WEB_URL}    https://${netact_name}lbwas.netact.nsn-rdnet.net
    Set Suite Variable    ${WEB_URL}
    Set Suite Variable    ${netact_name}
    Set Suite Variable    ${na_pass}
    Set Suite Variable    ${na_node_ip}
    Run keyword if    '${CLS_API_HOST_EXIST}'=='True'    Set Suite Variable    ${CLS_API_HOST}
    Run keyword if    '${CLS_DATABASE_HOST_EXIST}'=='True'   Set Suite Variable    ${CLS_DATABASE_HOST}
    Run keyword if    '${web_gui_username_exist}'=='True'    Set Suite Variable    ${web_gui_username}
    Run keyword if    '${web_gui_password_exist}'=='True'    Set Suite Variable    ${web_gui_password}

Get And Set Specific NetAct Parameters with FLAT
    Log    ${\n}Getting node IP and NetAct password from hardcoded dictionary:    console=True
    Get Appropriate Pass And Node Ip By Name
    Log    > NetAct password: ${na_pass}    console=True
    Log    > Using FLAT SOAM    console=True
    Get And Set Specific NetAct Parameters    ${na_pass}    ${na_node_ip}

Get And Set Specific NetAct Parameters
    [Arguments]    ${na_pass}    ${na_node_ip}
    ${is_dict_password_correct}=    Check If Password Is Correct    ${na_pass}
    Run Keyword If    not ${is_dict_password_correct}    Check If Hardcoded Passwords Are Correct
    ${node_number}=    Get Node Number    ${na_node_ip}
    Log    > NetAct name: ${netact_name}    console=True
    Log    > NetAct node ${node_number} IP address: ${na_node_ip}    console=True
    ${status}=    Run Keyword And Return Status    Get And Set NA Services IP
    Run Keyword If    not ${status}    Wait Until Keyword Succeeds    5x    1min    Legacy Get And Set NA Service IP    ${na_node_ip}
    Set Suite Variable    ${NA_USER}    omc

Get And Set NA Services IP
    [Documentation]    Trying to log to netact node
    Log    > Trying to login to root with password: arthur    console=True
    ${ssh_root_handler}=    Get Ssh Handler    ${na_node_ip}    root    arthur
    ${status}=    Call method    ${ssh_root_handler}    check_connection
    Run Keyword If    ${status}    Set Suite Variable    ${NA_ROOT_PASS}    arthur
    ...       ELSE                 Try to Use Second Password    ${na_node_ip}
    ${ip_db_node}=    Get NA Service IP    db    ${na_node_ip}
    ${ip_was_node}=    Get NA Service IP    was    ${na_node_ip}
	${ip_fm_pipe_node}=    Get NA Service IP    fm_pipe    ${na_node_ip}
    Set Suite Variable    ${NA_DB}    ${ip_db_node}
    Set Suite Variable    ${NA_WAS}    ${ip_was_node}
	Set Suite Variable    ${NA_FM_PIPE}    ${ip_fm_pipe_node}

Legacy Get And Set NA Service IP
    [Arguments]    ${na_node_ip}
    ${ip_db_node}=    Legacy Get NA Service IP    db    ${na_node_ip}
    ${ip_was_node}=    Legacy Get NA Service IP    was    ${na_node_ip}
    Set Suite Variable    ${NA_DB}    ${ip_db_node}
    Set Suite Variable    ${NA_WAS}    ${ip_was_node}

Check If Hardcoded Passwords Are Correct
    ${hardcoded_passwords}=    Create List    omc
    FOR    ${password}    IN    @{hardcoded_passwords}
        Log    > Hardcoded password: ${password}    console=True
        ${is_hardcoded_passsword_correct}=    Check If Password Is Correct    ${password}
        Exit For Loop IF    ${is_hardcoded_passsword_correct}=True
    END
    Run Keyword If    not ${is_hardcoded_passsword_correct}    Should Be Equal    ${is_hardcoded_passsword_correct}    True
    Run Keyword If    ${is_hardcoded_passsword_correct}    Set Suite Variable    ${na_pass}    ${password}

Check If Password Is Correct
    [Arguments]    ${password}
    ${ssh_root_handler}=    Get Ssh Handler    ${na_node_ip}    omc    ${password}
    ${login_status}=    Call method    ${ssh_root_handler}    check_connection
    Run Keyword If    ${login_status}    Set Suite Variable    ${na_pass}   ${password}
    ...       ELSE    Log    Password: ${password} is incorrect!    console=True
    [Return]    ${login_status}

Get Node Number
    [Arguments]    ${node_ip}
    ${ssh_root_handler}=    Get Ssh Handler    ${node_ip}    omc    ${na_pass}
    ${ssh_output}=    Call method    ${ssh_root_handler}    exec_command    hostname
    ${node_number_regex}=    Get Regexp Matches    ${ssh_output}    [0-9]+
    ${node_number}=    Convert To Integer    ${node_number_regex[-1]}
    [Return]    ${node_number}

Get And Set NetAct Parameters FLAT
    [Documentation]    Get and set variables which are needed to setup NetAct as suite variables and additional set NA_TYPE as suite variable
    [Arguments]     ${FLAT_netact_ip}
#    ${enb_side}=    Get Bts L    ${ENB_ID}
#    ${current_oam_ip}=    Get Parameter From Infomodel    /MRBTS-1/RAT-1/BTS_L-${enb_side}//MPLANENW_A-1    oamPeerIpAddress
#    Log    oam ip ${current_oam_ip}    console=True
    Log    Getting node ip and na pass from hardcoded dictionary    console=True
    ${na_pass_l}    ${na_node}    Get Appropriate Pass And Node Ip    ${FLAT_netact_ip}
    Log    Node ip ${na_node}
    Log    NetAct password ${na_pass_l}
    Set Suite Variable    ${NA_PASS}    ${na_pass_l}
    SSHLibrary.Open Connection    ${na_node}
    ${netact_pass}    run keyword and return status  SSHLibrary.Login    omc    ${na_pass_l}
    run keyword if  ${netact_pass}   Set Suite Variable    ${NA_PASS}    ${na_pass_l}
    Run Keyword If    not ${netact_pass}    Set Suite Variable    ${NA_PASS}    omc
    ${ip_db_node}=    Legacy Get NA Service IP    db    ${na_node}
    ${ip_was_node}=    Legacy Get NA Service IP    was    ${na_node}
#   Set Suite Variable    ${NA_PASS}    ${na_pass_l}
    Set Suite Variable    ${NA_DB}    ${ip_db_node}
    Set Suite Variable    ${NA_WAS}    ${ip_was_node}
    Set Suite Variable    ${NA_USER}    omc

Get Appropriate Pass And Node Ip
    [Documentation]    Returns apropriate na_pass and netact node for given virtual south
    [Arguments]    ${current_oam_ip}
    ${netact_oam_dictionary}=    Get Netact Params By Btsmed Addresses
    ${choosen_netact_dictionary}=    Get From Dictionary    ${netact_oam_dictionary}    ${current_oam_ip}
    ${na_pass}=    Get From Dictionary    ${choosen_netact_dictionary}    password
    ${na_node_ip}=    Get From Dictionary    ${choosen_netact_dictionary}    node_ip
    ${north}=    Get From Dictionary    ${choosen_netact_dictionary}    virtual_north
    ${netact_name}=    Get From Dictionary    ${choosen_netact_dictionary}    netact_name
    ${WEB_URL}=    Set Variable    https://${netact_name}lbwas.netact.nsn-rdnet.net
	Set Suite Variable     ${btsmed_north}     ${north}
    Set Suite Variable    ${WEB_URL}
    Set Suite Variable    ${netact_name}
    Set Suite Variable    ${na_pass}
    Set Suite Variable    ${na_node_ip}
    [Return]    ${na_pass}    ${na_node_ip}

### End of section: Get And Set NetAct Parameters Keywords ###

### Begin of section: Get And Set enb Parameters Keywords ###

Get And Set enb Parameters
    [Documentation]    Get and set required enb-related variables as suite variables if cloud VM
    ${testline}=    Get Cloud ID

#    ${if_cloud_1}=    Run Keyword And Return Status    Should Match Regexp    ${testline}    CLOUD
#    ${if_cloud_2}=    Run Keyword And Return Status    Should Match Regexp    ${testline}    UTE4G
#    ${help}=    Run Keyword And Return Status    Should be exual   ${if_cloud_1}    ${if_cloud_2}
#    ${if_cloud}=    Set Variable If
#    ...             ${if_cloud_1}    True
#    ...             ${if_cloud_2}    True
#    ...        	    ${help}    False
    Set Suite Variable    ${if_cloud}    True
    Get And Set enb Parameters Sub

Setup ENB Release Variable
    ${software_version}=    Get Active Sw Version
    ${enb_release_regexes}=    Get Regexp Matches    ${software_version}    ^[a-zA-Z0-9]+
    Set Suite Variable    ${ENB_RELEASE}    ${enb_release_regexes[0]}

Get And Set enb Parameters Sub
    [Documentation]    Get and set required enb-related variables as suite variables
    Collect Scf    target_file_name=${RESULTS}/scf_to_check_enb_parameters.xml
    ${xml_file}=    OperatingSystem.Get File    ${RESULTS}/scf_to_check_enb_parameters.xml
    ${enb_id_list}=    Get Regexp Matches    ${xml_file}   MRBTS.(\\d+)    1
    ${enb_id_l}=    Get From List    ${enb_id_list}    0
    Log    enb${enb_id_l}    console=true
    Set Suite Variable    ${ENB_ID}    ${enb_id_l}
    ${side}=    Run Keyword If    ${if_cloud}    Check Which Side Is Your AirScale
    Run Keyword If    ${if_cloud}    Set Suite Variable    ${ENB_SIDE}    ${side}
    Set ENB Release
    Run Keyword If    ${if_cloud}    Get And Set enb M-C-U-PLANE IP
    ${allowed_alarms_l}=    Create List
    ...        71106    61074    7651     61510    71107
    ...        61006    61616    61652    46100    61649
    ...        61058    61524    61631    71058    41003
    ...        7665     6261     7220     4592
    Set Suite Variable    ${ALLOWED_ALARMS}    ${allowed_alarms_l}
    ${allowed_faults_l}=    Create List
    ...        3080     6450    2019     1816     4082
    ...        61649    1898    61524    61652    61510
    ...        6261     7220    4655    4654    4681
    Set Suite Variable    ${ALLOWED_FAULTS}    ${allowed_faults_l}
    Set Suite Variable    ${PLMN}    PLMN-PLMN
    # --variable ENB_MPLANE_IP:192.168.255.129  added to run test

Set ENB Release
    [Documentation]    Get and set required enb-related variables as suite variables
    ${temp_enb_release}=     Set Variable    ${ENB_RELEASE}
    ${dict_sw_releases}=    Create Dictionary    FL18A=FL18SP    FL18=FL18SP     SBTS18A=SBTS18SP    SBTS19=SBTS18SP
    ${dict_sw_releases_keys}=    Get Dictionary Keys    ${dict_sw_releases}
    ${hardcoded_enb_release}=    Run Keyword If    '${temp_enb_release}' in ${dict_sw_releases_keys}
    ...    Check Hardcoded Releases    ${temp_enb_release}    ${dict_sw_releases}
    ...                                ELSE                                                               Set Variable    ${temp_enb_release}
    ${hardcoded_enb_release}=    Convert To Uppercase    ${hardcoded_enb_release}
    Set Suite Variable    ${ENB_RELEASE}    ${hardcoded_enb_release}

Check Hardcoded Releases
    [Arguments]    ${enb_release_regex}    ${dict_sw_releases}
    ${enb_hardcoded_releas}=    Get From Dictionary    ${dict_sw_releases}    ${enb_release_regex}
    [Return]    ${enb_hardcoded_releas}

Get And Set enb M-C-U-PLANE IP
    [Documentation]    Get and set required enb-related variables as suite variables
    ${ip_addresses}=    Get M C U Plane Holder    ${ENB_SIDE}    ${ENB_RELEASE}
    ${status}  run keyword and return status  variable should exist  ${5G}
    ${ENB_UPLANE_IP}=    Run keyword if    '${status}'=='False'    Get Parameter From Infomodel    ${ip_addresses.uplane.path}
    ...    ${ip_addresses.uplane.attribute}
    Run keyword if    '${status}'=='False'    Set Suite Variable    ${ENB_UPLANE_IP}
    ${ENB_CPLANE_IP}=    Run keyword if    '${status}'=='False'     Get Parameter From Infomodel    ${ip_addresses.cplane.path}
    ...    ${ip_addresses.cplane.attribute}
    Run keyword if    '${status}'=='False'    Set Suite Variable    ${ENB_CPLANE_IP}
    ${mplane_path}=    Run Keyword If    '${ip_addresses.mplane.path}'=='None'    Get MPLANE path
    ...                          ELSE    Set Variable    ${ip_addresses.mplane.path}
    ${ENB_MPLANE_IP}=    Get Parameter From Infomodel    ${mplane_path}    ${ip_addresses.mplane.attribute}
    Set Suite Variable    ${ENB_MPLANE_IP}

Get MPLANE path
    [Documentation]    Gets mplane path on SBTS releases
    ${mplane_path}=    Get Parameter From Infomodel    /MRBTS-1/RAT-1/BTS_L-${ENB_SIDE}//MPLANENW_A-*    mPlaneIpv4AddressDN
    [Return]    ${mplane_path}

### End of section: Get And Set enb Parameters Keywords ###

### Start of section: Logs collecting keywords ###

Start Capturing Logs
    [Documentation]    Start capturing sys and ims2 logs
    [Arguments]    ${im_port}=3600    ${address}=192.168.255.129
    Setup infomodel    address=${address}    port=${im_port}    alias=im_logs    admin_api_log_dir=${RESULTS}/adminlog
    Connect infomodel    alias=im_logs
    Set Suite Variable    ${keep_logs}    ${True}
    Run Keyword If   True==${if_cloud}   ute_syslog.Start Syslog    ${RESULTS}/syslog    syslog1

Stop Capturing Logs And Collect
    [Documentation]    Stop capturing sys and ims2 logs and save them
    [Arguments]    ${remove_logs}=${False}
    ${remove_logs}    Set Variable If    '${remove_logs}'=='PASS'    ${True}    ${remove_logs}
    ${remove_logs}    Set Variable If    '${remove_logs}'=='FAIL'    ${False}    ${remove_logs}
    Run Keyword If   True==${if_cloud}     Run Keyword And Continue On Failure   Run Keyword If    not ${remove_logs}
    ...    ute_syslog.Collect Syslog Results  destination_file=${RESULTS}/syslog/syslog1    unzip=False
    Run Keyword And Continue On Failure    Run Keyword If    not ${remove_logs}    Save Infomodel Log    ${RESULTS}/ims2_file  alias=im_logs
    Run Keyword And Continue On Failure    Run Keyword If    not ${remove_logs}    Collect Snapshot    ${RESULTS}/snapshot.zip
    Run Keyword And Continue On Failure    Run Keyword If    not ${remove_logs}    Collect Raw Alarm History File
    ...    target_file_name=${RESULTS}/alarm_history_file
    Teardown Infomodel   alias=im_logs
    Run Keyword If    ${remove_logs}    Run   rm -R ${RESULTS}/syslog

Collect Logs From Enb To Netact Pronto
    [Documentation]    This keyword gets notifs and ne3sadapt logs file directly from enb via FTP, author katarzyna.olszewska@nokia.com
    SSHLibrary.Open Connection    host=${ENB_IP}
    SSHLibrary.Login        ${ENB_ROOT_USER}   ${ENB_ROOT_PASS}
    @{files_managers}=       SSHLibrary.List Files In Directory          /ffs/run/config/ne3sadapt/managers  *
    FOR    ${one_file}    IN    @{files_managers}
        Set Suite Variable    ${one_file}
        ${logs_managers_file}=    SSHLibrary.Get File     /ffs/run/config/ne3sadapt/managers/${one_file}
    ...    destination=${RESULTS}/Collected_logs/managers/
        OperatingSystem.File Should Exist    ${RESULTS}/Collected_logs/managers/${one_file}
    END
    Log To Console      Logs from /ffs/run/config/ne3sadapt/managers collected
    @{files_notifs}=       SSHLibrary.List Directory          /ram/ne3sadapt/notifs  *
    ${logs_files_notifs}=    SSHLibrary.Get Directory     /ram/ne3sadapt/notifs    destination=${RESULTS}/Collected_logs/notifs/    recursive=True
    FOR    ${one_file_notifs}    IN    @{files_notifs}
        Set Suite Variable    ${one_file_notifs}
        OperatingSystem.Directory Should Exist    ${RESULTS}/Collected_logs/notifs/${one_file_notifs}
    END
    Log To Console      Logs from /ffs/run/config/ne3sadapt/notifs collected
    SSHLibrary.Close Connection

### End of section: Logs collecting keywords ###

### Start of section: Alarm collecting keywords ###

Check Expected Faults And Accept Allowed T
    [Documentation]
    ...    Keyword check whether expected faults are present on eNB
    ...    By default expected_faults list is empty
    ...    Allowed faults could be declared in eNB configuration file

    [Arguments]      ${allowed_faults}=&{EMPTY}    ${expected_faults}=&{EMPTY}      ${faults}=&{EMPTY}   ${new_way}=False

    ${active_alarms}=    Get Netact Faults
    @{active_faults}=    create list
    ${active_faults}=    Get Netact Alarm IDs  ${active_alarms}

    ${active_faults}=    remove duplicates  ${active_faults}
    ${faults_to_delete}=    Create List

    FOR   ${fault}   IN   @{allowed_faults}
        ${fault}=    convert to integer    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    FOR    ${fault}    IN    @{expected_faults}
        ${fault}=    convert to integer    ${fault}
        list should contain value    ${active_faults}    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    Remove Values From List    ${active_faults}    @{faults_to_delete}
    ${active_faults}=    convert to list    ${active_faults}
    Run Keyword If   "${new_way}"=="True"     Add to faults list   ${active_faults}    ${faults}       ELSE     Should Be Empty    ${active_faults}

Check Expected Faults And Accept Allowed T v2
    [Documentation]
    ...    Keyword check whether expected faults are present on eNB
    ...    By default expected_faults list is empty
    ...    Allowed faults could be declared in eNB configuration file

    [Arguments]      ${allowed_faults}=&{EMPTY}    ${expected_faults}=&{EMPTY}      ${faults}=&{EMPTY}   ${new_way}=False

    ${active_alarms}=    Get Netact Faults v2
    @{active_faults}=    create list
    ${active_faults}=    Get Netact Alarm IDs  ${active_alarms}

    ${active_faults}=    remove duplicates  ${active_faults}
    ${faults_to_delete}=    Create List

    FOR   ${fault}   IN   @{allowed_faults}
        ${fault}=    convert to integer    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END
    FOR    ${fault}    IN    @{expected_faults}
        ${fault}=    convert to integer    ${fault}
        list should contain value    ${active_faults}    ${fault}
        Append To List    ${faults_to_delete}    ${fault}
    END

    Remove Values From List    ${active_faults}    @{faults_to_delete}
    ${active_faults}=    convert to list    ${active_faults}
    Run Keyword If   "${new_way}"=="True"     Add to faults list   ${active_faults}    ${faults}       ELSE     Should Be Empty    ${active_faults}

Check Alarms After Test
    [Documentation]    Throw error if any unexpected alarm occured during tests
    [Arguments]   ${alarms}
    For    ${alarm}    IN    @{alarms}
        Run keyword if    ${alarm} != []    Log to console    During the test there was an alarm which is not in allowed_alarms list
        Should Be Empty    ${alarm}
    END

Add to faults list
    [Documentation]  Sub keyword to Check Expected Alarms And Accept Allowed
	[Arguments]       ${active_faults}    ${faults}
    Append To List    ${faults}   ${active_faults}
    Set Suite Variable     ${faults}

Check Faults After Test
    [Documentation]    Throw error if any unexpected alarm occured during tests
    [Arguments]   ${faults}
    For    ${fault}    IN    @{faults}
        Run keyword if    ${fault} != []    Log to console    During the test there was an fault which is not in allowed_faults list
        Should Be Empty    ${fault}
    END

Check alarms alive
    [Arguments]    ${hostname}    ${password}    ${username}    ${directory}    ${iteration}
    ${status}    ${expected_faults}=    Run Keyword And Ignore Error     Get Variable Value    ${expected_faults}
    @{expected_faults}=    Run Keyword If    '${status}'!='PASS'    Create List
    ...                              ELSE                           Set Variable    ${expected_faults}
    ${status}    ${history_file}=    Run Keyword And Ignore Error    OperatingSystem.Get File    ${directory}/alarm_history.log
    ${found_alarms}=    Run Keyword If    '${status}'=='PASS'    Collect And Check Alarms    ${ALLOWED_ALARMS}    ${expected_faults}
    ...    ${history_file}
    Run Keyword If    '${status}'=='PASS'    Should Be Empty    ${found_alarms}
    Run Process    pkill -f /home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/resources/other/collecting_alarms.py    shell=True
    Run Process    pkill -f admin_api_collecting_infomodel.log    shell=True
    ${last_iteration}=    Evaluate    ${iteration}-1
    Run Keyword And Ignore Error    Run Process    mv ${directory}/alarm_history.log logi_${last_iteration}/    shell=True
    Run Keyword And Ignore Error    Run Process    mv ${directory}/alarm_history_stdout.txt logi_${last_iteration}/    shell=True
    Run Keyword And Ignore Error    Run Process    mv ${directory}/alarm_history_stderr.txt logi_${last_iteration}/    shell=True
    ${cmd}=    Catenate    python /home/ute/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/resources/other/collecting_alarms.py
    ...    ${hostname} ${username} ${password} ${directory}
    Start Process    ${cmd}    shell=True    stderr=${directory}/alarm_history_stderr.txt    stdout=${directory}/alarm_history_stdout.txt

Check If Toggling Is Triggered
    [Documentation]     This kw checks if in NA alarms alarm with toggling is visible
    [Arguments]    ${fault}=None
    ${netact_alarms}=    Get Netact Faults
    ${netact_alarms}=    Convert To String    ${netact_alarms}
    Should Contain    ${netact_alarms}    Toggling
    Run Keyword If    '${fault}'!='None'    Should Contain    ${netact_alarms}    ${fault}

Check If Toggling Is Not Triggered
    [Documentation]  This kw checks if in NA alarms alarm with toggling is not visible
    ${netact_alarms}=    Get Netact Faults
    ${netact_alarms}=    Convert To String    ${netact_alarms}
    Should Not Contain    ${netact_alarms}   Toggling

Get Netact Faults
    [Documentation]    Get Netact alarms
    ${status}  ${netact_alarms}=    run keyword and ignore error  taf.nms.netact.Get Alarms    dist_names=${ENB_ID}     only_active=True
    ${netact_alarms}=    Run Keyword If  '${status}'!='PASS'  taf.nms.netact.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE    Set Variable    ${netact_alarms}
    [Return]    ${netact_alarms}

Get Netact Faults v2
    [Documentation]    Get Netact alarms
    ${status}  ${netact_alarms}=    run keyword and ignore error  taf.nms.netact.Get Alarms    dist_names=${ENB_ID}     only_active=True
    ${netact_alarms}=    Run Keyword If  '${status}'!='PASS'  taf.nms.netact.Get Alarms  dist_name=${PLMN}/MRBTS-${ENB_ID}
    ...  ELSE    Set Variable    ${netact_alarms}
    [Return]    ${netact_alarms}

Get correlated Alarms From Netact
    [Documentation]    Get Netact correlated alarms based on alarm number and dn (Distinguished Name). for example specificProblem=7107
    ...  dn=PLMN-PLMN/S1_LinkGroup-1
    [Arguments]    ${alarm_number}    ${dn}
    Sleep    300    #this sleep is necessary to make sure if S1_LinkGroup correlation appeared
    ${main_alarm}=     Get Alarms based On Template  specificProblem=${alarm_number}    dn=${dn}
    Log    Main alarm: ${main_alarm}    console=${TRUE}
    ${correlated_alarms}=    Get Correlated Alarms     correlating_alarm_number=${alarm_number}
    ...    correlating_notification_id=${main_alarm[0]['additionalAttributes']['originalAlarmId']}   correlating_dist_name=${dn}
    [Return]    ${correlated_alarms}

### End of section: Alarm collecting keywords ###

### Start of section: Other keywords ###

Test First Checkpoint
    [Documentation]    Checks status of eNB before test
    [Arguments]    ${sbts}=${False}
    Run CM Upload
    Run Keyword and ignore error    Upload Alarms  dist_name=PLMN-PLMN/MRBTS-${ENB_ID}
    Wait Until keyword Succeeds    8x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Run Keyword If    ${sbts}==${False}    Check Expected Alarms And Accept Allowed v2    allowed_alarms=${ALLOWED_ALARMS}
    ...    alarms=@{alarms}    new_way=${if_new_way}
    ...               ELSE     Check Expected Faults And Accept Allowed T v2    allowed_faults=${ALLOWED_FAULTS}
    ...    faults=@{faults}    new_way=${if_new_way}
    Check If Alarms From ENB and NetAct Are The Same v2
    Set Reset Counter Before Test

Run Test For Given Path
    [Documentation]    Running test for given path
    [Arguments]    ${test_name}    ${path_to_test}
    ${current_date}=    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S    exclude_millis=True
    ${testline_localisation}    ${testline_label}=    Split String    ${CONFIGURATION}    .
    ${testline_localisation}=    Strip String    ${testline_localisation}
    ${testline_label}=    Strip String    ${testline_label}
    ${rc}    ${output}=    Run and Return RC and Output     Catenate
    ...    robot -X --variable CONFIGURATION:${CONFIGURATION} -V /home/ute/robotlte/config/${testline_localisation}/${testline_label}/__init__.py
    ...    --variable ENB_MPLANE_IP:192.168.255.129 --variable RESULTS:${OUTPUT_DIR}/${current_date}_${test_name} -L TRACE
    ...    -b ${OUTPUT_DIR}/${current_date}_${test_name}/debug.log -d ${OUTPUT_DIR}/${current_date}_${test_name}/
    ...    /home/ute/robotlte/testsuite/${path_to_test}
    Log    ${output}    console=true
    Should Be Equal As Integers    ${rc}    0

Check if snapshot file is on NetAct
    [Documentation]    Chceck if snapshot is on netact
    ...  Exemplary snapshot file name
    ...  MRBTS-100766-Snapshot_mrbts-100766_eNB_100766_SBTS18SP_FSM3_9999_180521_008147_20180524-1731-1527176011396.zip
    [Arguments]    ${snapshot_name}    ${opposite}=False
    # list files which have been modified in less than 5 minutes ago (-cmin -5)
    ${cmd}=    Set Variable    find /d/oss/global/diagsnap/ne3sws/${snapshot_name} -cmin -15 2>/dev/null
    ${ssh_root_handler}=    Get Ssh Handler    ${na_node_ip}    root    ${NA_ROOT_PASS}
    ${stdout}=    Call method    ${ssh_root_handler}    exec_command    ${cmd}
    ${stdout_string}=    Convert to string    ${stdout}
    ${first_string}=    Split String    ${stdout_string}    [
    ${stdout_stripped}=    Strip String    ${first_string[0]}
    Run Keyword If    ${opposite}    Should Be Empty    ${stdout_stripped}
    ...       ELSE                   Should Not Be Empty    ${stdout_stripped}
    ${snapshot_name_ff_right}=    Fetch From Right    ${stdout_stripped}    /var/opt/nokia/oss/global/nwi3/ne_symptom_files/
    ${snapshot_name}=    Fetch From Left    ${snapshot_name_ff_right}    .in-progress
    [Return]    ${snapshot_name}

Run CM Upload
    [Documentation]    Perform CM Uplad using new and deprecated libs
    ${status}=    Run Keyword and Ignore Error  Upload Configuration Data    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}     ignore_errors=True
    Run Keyword If    '${status[0]}'!='PASS'    CM Upload

Run CM Upload v2
    [Documentation]    Perform CM Uplad using new and deprecated libs
    ${status}=    Run Keyword and Ignore Error  Upload configuration    dist_names=PLMN-PLMN/MRBTS-${ENB_ID}    parameters=None
    ...    verbose=True    schedule=None    ignore_errors=False    timeout=7200
    Run Keyword If    '${status[0]}'!='PASS'    CM Upload

Get Random LNCEL ID
    [Documentation]    Returns random RMOD-ID from current configuration
    Collect Scf    target_file_name=${RESULTS}/scf_to_check_list_LNCEL.xml
    ${act_config}=    OperatingSystem.Get File    ${RESULTS}/scf_to_check_list_LNCEL.xml
    ${lines}=    Get Lines Matching Pattern    ${act_config}    *<managedObject class="*LNCEL"*distName="*${ENB_ID}/LNCEL-*"*>*
    ${lncel_ids}=    Get Regexp Matches    ${lines}    (LNCEL-)(\\d+)    2
    ${length_of_lncel_list}=    Get Length    ${lncel_ids}
    ${max_index}=    Evaluate    ${length_of_lncel_list}-1
    ${random index}=    Evaluate    random.randint(0, ${max_index})    modules=random, sys
    ${lncel_id_to_return}=    Get From List    ${lncel_ids}    ${random_index}
    [Return]    ${lncel_id_to_return}

Check If Cells Are Not On Air
    [Documentation]    Check If Cells Are Not On Air
    @{list_of_cells_status}=    Get Cell Status    bts_l=${ENB_SIDE}
    FOR   ${cell_status}    IN    @{list_of_cells_status}
        Log    ${cell_status}
        Should Not Be Equal    ${cell_status}    OnAirDone
    END

Create Delta And Perform Recommissioning
    [Documentation]    This keyword updates ENB_ID name inside json file
    [Arguments]    ${delta_template}    ${new_delta_file_name}
    ${plan_file}=    OperatingSystem.Get File     ${delta_template}
    ${new_plan_file}=    Replace String    ${plan_file}    %ENB_ID%    ${ENB_ID}
    OperatingSystem.Create File    ${RESULTS}${/}${new_delta_file_name}.json    ${new_plan_file}
    Perform Delta Recommissioning    ${RESULTS}${/}${new_delta_file_name}.json
    Sleep    30s

Simple Prepare and Import All Plans From Directory
    [Documentation]
    ...    Simpler version of Prepare and Import All Plans From Directory
    ...    That was took from lib_VEROAMWRO for some problematic cases.
    [Arguments]         ${directory}   ${Cell}=1
    Log To Console      Preparing and importing plans from ${directory}
    @{test_data_files_content}=    OperatingSystem.List Files In Directory    path=${directory}      absolute=True
    ${i}            Set Variable    0

    FOR    ${file}   IN    @{test_data_files_content}
        ${plan_name}=    Set Variable    plan
        ${i}=            Evaluate  ${i} + 1
        ${plan_name}=    Set Variable      ${plan_name}_${i}.xml
        Log to console    ${file} -> ${plan_name}
        Replace strings in xml     ${file}     ${RESULTS}/plans/${plan_name}    %PLMN%,${PLMN}    %ENB_ID%,${ENB_ID}
      ...    %ENB_RELEASE%,${ENB_RELEASE}    %CELL%,${Cell}
        Import Plan Depending On Library  local_dir=${RESULTS}/plans/     input_file=plan_${i}.xml     plan_name=${ENB_ID}_plan_${i}
    END

Get Active Sw Version
    [Documentation]    Returns Active SW Version
    ${sw_info}=    Set Variable  &{EMPTY}
    ${sw_info}=    Get Software Info
    ${active_sw_version}=    Get From Dictionary    ${sw_info}    Active SW version
    [Return]    ${active_sw_version}

Compare Element Parameter Value To Actual Configuration via NA
    [Documentation]    Comparing given parameter to actual value on eNB
    ...                Requires include Library  XML  use_lxml=True inside test
    ...                Author: artur.czainski@nokia.com
    [Arguments]    ${element}    ${parameter}    ${expected_value}    ${ui_values}=true    ${alias_netact}=ta_netact
    Run CM Upload
    ${rand}=    Generate Random String    4    [UPPER]
    ${status}=    Run Keyword And Return Status    Cm Export    ${RESULTS}    ${ENB_ID}_compare_SCF_${rand}.xml    ui_values=${ui_values}
    Run Keyword If    not ${status}    Export Actual Configuration    local_dir=${RESULTS}    file_name=${ENB_ID}_compare_SCF_${rand}.xml
    ...  	 dist_names=PLMN-PLMN/MRBTS-${ENB_ID}       ui_values=${ui_values}    alias=${alias_netact}
    ${parameter_xpath}=    Set Variable    .//managedObject[@distName="${element}"]/p[@name="${parameter}"]
    ${actual_value}=    Get Element Text    ${RESULTS}/${ENB_ID}_compare_SCF_${rand}.xml    ${parameter_xpath}
    ${actual_value}=    Convert to String    ${actual_value}
    ${expected_value}=    Convert to String    ${expected_value}
    Should Be Equal as Strings     ${actual_value}    ${expected_value}

Compare Element Parameter Value To Actual Configuration via NA v2
    [Documentation]    Comparing given parameter to actual value on eNB
    ...                Requires include Library  XML  use_lxml=True inside test
    ...                Author: artur.czainski@nokia.com
    [Arguments]    ${element}    ${parameter}    ${expected_value}    ${ui_values}=true
    Run CM Upload v2
    ${rand}=    Generate Random String    4    [UPPER]
    ${status}=    Run Keyword And Return Status    Cm Export    ${RESULTS}    ${ENB_ID}_compare_SCF_${rand}.xml    ui_values=${ui_values}
    Run Keyword If    not ${status}    Export Configuration    local_dir=${RESULTS}    file_name=${ENB_ID}_compare_SCF_${rand}.xml
    ...  	 dist_names=PLMN-PLMN/MRBTS-${ENB_ID}
    ${parameter_xpath}=    Set Variable    .//managedObject[@distName="${element}"]/p[@name="${parameter}"]
    ${actual_value}=    Get Element Text    ${RESULTS}/${ENB_ID}_compare_SCF_${rand}.xml    ${parameter_xpath}
    ${actual_value}=    Convert to String    ${actual_value}
    ${expected_value}=    Convert to String    ${expected_value}
    Should Be Equal as Strings     ${actual_value}    ${expected_value}

Get active btsmed address
    [Arguments]    ${address}
    SSHLibrary.Open Connection    host=${address}
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Write    btsmed console
    Sleep    5s
    ${stdout}=    SSHLibrary.Read
	SSHLibrary.Write    resil list
	Sleep    15s
	${stdout}=    SSHLibrary.Read
	${pattern}=    Set variable    active\\s{9}(\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b)
	${btsmed_north}=    Get Regexp Matches    ${stdout}    ${pattern}    1
    ${btsmed_north}    Set Variable If	  ${btsmed_north}== []    ${address}
    [Return]    ${btsmed_north}


Start LMTS Script with restart
    [Documentation]    This keyword starts script on 3 party tool machine LMTS to generate traffic. Argument ${connect_to_lmts} to connect to LMTS,
    ...    ${start_command} to start LMTS, ${stats_command} to check if LMTS is running, ${stop_command} to stop LMTS
    [Arguments]    ${address_lmts}
    Login As User    ${address_lmts}   lmts     !!lmts
    ${connect_to_lmts}=  Set Variable    telnet 0 1234
    SSHLibrary.Write  ${connect_to_lmts}
    SSHLibrary.Read    delay=5 sec  #this sleep is necessary. It takes some time, when command is consumed
    ${output}=  SSHLibrary.Read
    Log    ${output}    console=True
    ${start_command}=    Set Variable     start OVL_sektor_3
    SSHLibrary.Write    ${start_command}
    Log    ${start_command}    console=True
    Log    Wait 5 min - LMTS is runing script    console=True
    ${output_with_start_scenario}     SSHLibrary.Read    delay=1 min    #this sleep is necessary. It takes some time, when command is consumed
    ${status_keyword}      run keyword and return status   Should Match Regexp    ${output_with_start_scenario}    error
    run keyword if       ${status_keyword}==True    Restart Lmts Sector   ${address_lmts}
    ${start_command_stats}=  Set Variable    stats ue
    SSHLibrary.Write    ${start_command_stats}
    Log    ${start_command_stats}    console=True
    ${output_1}=  SSHLibrary.Read
    Log    ${output_1}    console=True
    SSHLibrary.Read    delay=4 min    #this sleep is necessary. It takes some time, when command is consumed
    ${stop_command}=  Set Variable    stop
    SSHLibrary.Write    ${stop_command}
    Log    ${stop_command}    console=True
    ${output}=  SSHLibrary.Read
    Log    ${output}    console=True

Restart Lmts Sector
    [Documentation]    This keyword restart LMTS sector
    [Arguments]    ${address_lmts}
    Login As User    ${address_lmts}   lmts     !!lmts
    ${connect_to_lmts}=  Set Variable    telnet 0 1234
    SSHLibrary.Write    ${connect_to_lmts}
    SSHLibrary.Read    delay=5 sec    #this sleep is necessary, it takes some time, when command is consumed
    Log to console    Trying to reset sectors...
    ${restart_command}=    Set Variable    config remote restart ctrl
    #SSHLibrary.Write    ${restart_command}
    SSHLibrary.Read    delay=5s
    Sleep   20s    #wait for restart LMTS
    SSHLibrary.Close Connection
    Start LMTS Script second     ${address_lmts}


Start LMTS Script second
    [Documentation]    This keyword starts script on 3 party tool machine LMTS to generate traffic. Argument ${connect_to_lmts} to connect to LMTS,
    ...    ${start_command} to start LMTS, ${stats_command} to check if LMTS is running, ${stop_command} to stop LMTS
    [Arguments]    ${address_lmts}
  	Wait Until Keyword Succeeds    26x    30    Check If Cells OnAir Or PowerSaving Enabled
    Login As User     ${address_lmts}  lmts     !!lmts
    ${connect_to_lmts}=  Set Variable    telnet 0 1234
    SSHLibrary.Write  ${connect_to_lmts}
    SSHLibrary.Read    delay=5 sec  #this sleep is necessary. It takes some time, when command is consumed
    ${output}=  SSHLibrary.Read
    Log    ${output}    console=True
    ${start_command}=  Set Variable     start OVL_sektor_3
    SSHLibrary.Write    ${start_command}
    Log    ${start_command}    console=True
    ${output_with_start_scenario}     SSHLibrary.Read    delay=1 min    #this sleep is necessary. It takes some time, when command is consumed
    ${status_keyword}      run keyword and return status   Should Match Regexp    ${output_with_start_scenario}    error
    Should Be True    ${status_keyword}==False


Start RTGs Script
    [Documentation]    This keyword starts script on 3 party tool machine LMTS to generate traffic. Argument ${connect_to_lmts} to connect to LMTS,
    ...    ${start_command} to start LMTS, ${stats_command} to check if LMTS is running, ${stop_command} to stop LMTS
    [Arguments]    ${address_rtg}
    Login As User    ${address_rtg}   rtg    !!rtg
    ${connect_to_lmts}=  Set Variable    telnet 0 1234
    SSHLibrary.Write  ${connect_to_lmts}
    SSHLibrary.Read    delay=5 sec  #this sleep is necessary. It takes some time, when command is consumed
    ${output}=  SSHLibrary.Read
    Log    ${output}    console=True
    ${start_command}=    Set Variable     start OVL_sektor_1
    SSHLibrary.Write    ${start_command}
    Log    ${start_command}    console=True
    Log    Wait 5 min - LMTS is runing script    console=True
    ${output_with_start_scenario}     SSHLibrary.Read    delay=1 min    #this sleep is necessary. It takes some time, when command is consumed
    ${status_keyword}      run keyword and return status   Should Match Regexp    ${output_with_start_scenario}    error
    Should Be True    ${status_keyword}==False
    ${start_command_stats}=  Set Variable    stats ue
    SSHLibrary.Write    ${start_command_stats}
    Log    ${start_command_stats}    console=True
    ${output_1}=  SSHLibrary.Read
    Log    ${output_1}    console=True
    SSHLibrary.Read    delay=4 min    #this sleep is necessary. It takes some time, when command is consumed
    ${stop_command}=  Set Variable    stop
    SSHLibrary.Write    ${stop_command}
    Log    ${stop_command}    console=True
    ${output}=  SSHLibrary.Read
    Log    ${output}    console=True

Change value vendor
    [Documentation]    Download and change values of vendor files.
    [Arguments]        ${ovlOccurrences}=1     ${ovlThrOvl1}=1    ${ovlThrOvl2}=2    ${ovlTimer}=60     ${ovlIpcPoolUsageL2}=50
	Download Vendor File     target_file_name=${RESULTS}/vendor.xml
    Log  Vendor download  console=False
	${xml_vendor}    Parse XML     ${RESULTS}/vendor.xml
	Set Element Text   ${xml_vendor}      ${ovlOccurrences}    xpath=.//managedObject[@class="LNBTS"]/p[@name='ovlOccurrences']
	Set Element Text   ${xml_vendor}      ${ovlThrOvl1}    xpath=.//managedObject[@class="LNBTS"]/p[@name='ovlThrOvl1']
	Set Element Text   ${xml_vendor}      ${ovlThrOvl2}    xpath=.//managedObject[@class="LNBTS"]/p[@name='ovlThrOvl2']
	Set Element Text   ${xml_vendor}      ${ovlTimer}    xpath=.//managedObject[@class="LNBTS"]/p[@name='ovlTimer']
	Set Element Text   ${xml_vendor}      ${ovlIpcPoolUsageL2}    xpath=.//managedObject[@class="LNBTS_FDD"]/p[@name='ovlIpcPoolUsageL2']
#	${altoggsupplist_items1}=    Get Element Attribute   ${xml_vendor}    ovlIpcPoolUsageL2   xpath=.//managedObject[@class="LNBTS_FDD"]
#	${altoggsupplist_items1}=    Get Element Attribute	   ${xml_vendor}    ovlOccurrences    xpath=.//managedObject[@class="LNBTS"]
	Save Xml           ${xml_vendor}   ${RESULTS}/vendor.xml
	Set Vendor File        vendor_file=${RESULTS}/vendor.xml
	Wait Until Keyword Succeeds    5x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Check Expected Faults And Accept Allowed T    allowed_faults=${ALLOWED_FAULTS}    faults=@{faults}    new_way=${if_new_way}
    Check If Alarms From ENB and NetAct Are The Same
    Check If Reset Counter Did Not Change
	Collect Scf    target_file_name=${RESULTS}/scf_vendor.xml
	Perform Commissioning    bts_id=${ENB_ID}    scf_file=${RESULTS}/scf_vendor.xml    timeout=500
	Wait Until Keyword Succeeds    13x    1min    Check If Cells OnAir Or PowerSaving Enabled
    Compare Ovl Specific Vendor Parameters
	Log  Vendor changed  console=False


Compare Ovl Specific Vendor Parameters
    [Documentation]    Keyword compares current vendor file OVL specific parameter values to given by user.
    [Arguments]        ${ovlOccurrences}=1     ${ovlThrOvl1}=1    ${ovlThrOvl2}=2    ${ovlTimer}=60
    ${ovl_occur_val}=    Get Parameter From Infomodel
    ...    /MRBTS-1/RAT-1/BTS_L-${enb_side}/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-${ENB_ID}/LNBTS_A-${ENB_ID}    ovlOccurrences
    Should Be Equal    ${ovl_occur_val}    ${ovlOccurrences}
    ${ovl_thr1_val}=    Get Parameter From Infomodel
    ...    /MRBTS-1/RAT-1/BTS_L-${enb_side}/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-${ENB_ID}/LNBTS_A-${ENB_ID}    ovlThrOvl1
    Should Be Equal    ${ovl_thr1_val}    ${ovlThrOvl1}
    ${ovl_thr2_val}=    Get Parameter From Infomodel
    ...    /MRBTS-1/RAT-1/BTS_L-${enb_side}/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-${ENB_ID}/LNBTS_A-${ENB_ID}    ovlThrOvl2
    Should Be Equal    ${ovl_thr2_val}    ${ovlThrOvl2}
    ${ovl_timer_val}=    Get Parameter From Infomodel
    ...    /MRBTS-1/RAT-1/BTS_L-${enb_side}/BTS_CONF-1/NP-*/SCF-*/MRBTS_A-${ENB_ID}/LNBTS_A-${ENB_ID}    ovlTimer
    Should Be Equal    ${ovl_timer_val}    ${ovlTimer}


Login As User
    [Documentation]
    ...  This keyword set proper user name and password. Argument ${ip} is ip, ${user name} is name to login and ${user password} is password
    [Arguments]    ${ip}    ${user name}    ${user password}
    SSHLibrary.Open Connection    ${ip}
    ${output}=    SSHLibrary.Login    ${user name}    ${user password}
    Log    ${\n}Loggeed as '${user name}' to ${ip}    console=True




### End of section: Other keywords ###

### Begin of section to reporting to RP Keywords. Reporting keywords are supported by PM/LM team ###

Get Cloud ID
    [Documentation]  Keyword return cloud id e.g 1_16_CLOUD3698
    ${host_id}=  Run process  hostname  shell=True  cwd=${CURDIR}  timeout=60min
    Log  ${host_id.stdout}  console=False
    ${cloud_id}=   Replace String  ${host_id.stdout}  -  _
    Log  ${cloud_id}  console=False
    [Return]  ${cloud_id}

Get Testline Type
    [Documentation]    Return testline label for cloud testlines
    ${testline_label}=    Run    cat /opt/ute/reservation.json | grep -o -P '"testline_type": (".+")' | awk -F '"' '{print $4}'
    [Return]    ${testline_label}

Get Platform From Testline Type
    [Documentation]    Returns platform for given testline name
    [Arguments]    ${testline_type}
    ${if_airscale}=    Run Keyword And Return Status    Should Match Regexp    ${testline_type}    CLOUD.[A-Z]+[^A-Z]A
    ${if_fsmf}=    Run Keyword And Return Status    Should Match Regexp    ${testline_type}    CLOUD.[A-Z]+[^A-Z]F
    ${platform}=    Set Variable If    ${if_airscale}    airscale
    ${platform}=    Set Variable If    ${if_fsmf}    fsmf    ${platform}
    [Return]    ${platform}

Report Result
    [Documentation]    Report result to reporting portal
    [Arguments]    ${test_name}    ${test_set}
    ${testline}=    Get Cloud ID
    ${if_cloud}=    Run Keyword And Return Status    Should Match Regexp    ${testline}    CLOUD
    Run Keyword If    ${if_cloud}    Report Result Cloud VM    ${testname}    ${test_set}
    Run Keyword If    not ${if_cloud}    Report Result Windows VM    ${testname}    ${test_set}

Report Result Windows VM
    [Documentation]    Report result to reporting portal
    [Arguments]    ${test_name}    ${test_set}
    ${testline}=    Set Variable    ${RP_TEST_LINE_IN_CFG}
    ${build}=     Get Active SW Version
    ${qc_test_instance_name}=    Set Variable    [1]${test_name}
    ${AS_or_FSMF}=     Run keyword if  '${PLATFORM}'=='AIRSCALE'  Get Parameter From Infomodel
    ...  /MRBTS-1/RAT-1/BTS_L-${enb_side}/EQM_L-1/CABINET_L-1/BBMOD_L-1  productName
    ...             ELSE  Get Parameter From Infomodel  /MRBTS-1/RAT-1/BTS_L-${enb_side}/EQM_L-1/CABINET_L-1   productCode
    ${REAL_PLATFORM}=     Run Keyword if  '${AS_or_FSMF}'!='ABIC AirScale Capacity'  Set variable  ${PLATFORM}  ELSE
    ...  Fetch from left  ${AS_or_FSMF}  ${SPACE}
    ${platform}=     Convert to lowercase  ${REAL_PLATFORM}
#    ${platform}=    Convert To Lowercase    ${PLATFORM}
    ${if_airscale}=    Run Keyword And Return Status    Should Be Equal As Strings    ${platform}    airscale
    ${if_fsmf}=    Run Keyword And Return Status    Should Be Equal As Strings    ${platform}    fsmf
    ${if_abic}=    Run Keyword And Return Status    Should Be Equal As Strings    ${platform}    abic
    ${if_correct_platform_typing}=    Evaluate  ${if_airscale} or ${if_fsmf} or ${if_abic}
    Should Be True    ${if_correct_platform_typing}
    ${qc_test_lab_path}=    Get Appropriate Paths To Qc    ${build}    ${platform}
#    ${FoN}=     Get Parameter From Infomodel  /MRBTS-1/RAT-1/BTS_L-${ENB_SIDE}//MRBTS_A-${ENB_ID}/MNL_A-1/MNLENT_A-1/MPLANENW_A-1
  #oamPeerIpAddress
#    ${qc_test_lab_path}=    Run keyword if  '${FoN}'=='None' and '${test_set}'=='PM'   Get Appropriate Path To QC AirScale FLAT  ${build}
  #ELSE  Set variable  ${qc_test_lab_path}
#    ${qc_test_lab_path}=    Run keyword if  '${LF}'=='True' and '${test_set}'=='PM'   Get Appropriate Path To QC LionFish    ${build}  ELSE
  #Set variable  ${qc_test_lab_path}
    Report To RP    ${SUITE_STATUS}    ${test_name}    ${testline}    ${build}    ${test_set}    qc_test_lab_path=${qc_test_lab_path}
    ...    qc_test_instance_name=${qc_test_instance_name}

Report Result Cloud VM
    [Documentation]    Report result to reporting portal
    [Arguments]    ${test_name}    ${test_set}
    ${testline}=    Get Cloud ID
    ${build}=     Get Active SW Version
    ${qc_test_instance_name}=    Set Variable  [1]${test_name}
    ${testline_type}=  Get Testline Type
    ${platform}=    Get Platform From Testline Type    ${testline_type}
    ${qc_test_lab_path}=    Get Appropriate Paths To Qc    ${build}    ${platform}
    Report To RP    ${SUITE_STATUS}    ${test_name}    ${testline}    ${build}    ${test_set}    qc_test_lab_path=${qc_test_lab_path}
    ...    qc_test_instance_name=${qc_test_instance_name}

Get Appropriate Path To Qc
    [Documentation]    Returns Apropriate QC Path for given SW version
    [Arguments]    ${active_sw_version}    ${enb_type}
    ${Dictionary_of_Releases}=  Create Dictionary
    ...     SBTS20A_ENB_0000=SRAN20A\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\${enb_type}
    ...     SBTS20B_ENB_0000=SRAN20B\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\${enb_type}
    ...     SBTS20C_ENB_9999=SBTS20C\\Branch_CRT\\4G_ASPZ_WRO\4G_ASPZ_WRO - OAM\\CRT\\${enb_type}
    ...     SBTS21A_ENB_9999=Trunk_COMMON\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\CRT\\${enb_type}
    ...     SBTS19B_ENB_0000=SRAN19B\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\${enb_type}
    ...     SBTS20A_ENB_9999=Trunk_COMMON\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\CRT\\${enb_type}
    ...     SBTS19A_ENB=L19A\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - WOM\\${enb_type}
    ...     FL19_ENB=L19\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\${enb_type}
    ...     FL18_=L18 OMS\\Verification\\Branch_CRT\\System Test\\Test Automation WRO\\Operation & Maintenance\\${enb_type}
    ...     SBTS18_=SRAN18\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\Operation & Maintenance\\${enb_type}
    ...     FL18SP_=L18 SP\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\${enb_type}
    ...     FL18A_=L18A\\Branch_CRT\\4G_ASPZ_WRO\\4G_ASPZ_WRO - OAM\\Operation & Maintenance\\${enb_type}
    ${List_Of_Releases}=  Get Dictionary Keys  ${Dictionary_of_Releases}
    FOR  ${key}  IN  @{List_of_Releases}
        ${if_match_sw}=    Run Keyword And Return Status    Should Match Regexp    ${active_sw_version}   ${key}
        ${Release}=     Get From Dictionary  ${Dictionary_of_Releases}  ${key}
        ${path_to_qc}=    Set Variable If    ${if_match_sw}  ${Release}
        Exit For Loop IF    ${path_to_qc}'!='None'
    END
    [Return]    ${path_to_qc}

Get Appropriate Path To QC AirScale FLAT
    [Arguments]    ${active_sw_version}
    ${if_match_sw}=    Run Keyword And Return Status    Should Match Regexp    ${active_sw_version}    FL19_ENB
    ${path_to_qc}=    Set Variable If    ${if_match_sw}    L19\\New Feature\\4G_ASPZ_WRO\\4G_ASPZ_WRO - WOM\\LTE4934    ${path_to_qc}
    Log  ${path_to_qc}  console=true
    [Return]    ${path_to_qc}

Get Appropriate Path To QC LionFish
    [Arguments]    ${active_sw_version}
    ${if_match_sw}=    Run Keyword And Return Status    Should Match Regexp    ${active_sw_version}    SBTS19B_ENB
    ${path_to_qc}=    Set Variable If    ${if_match_sw}    L19LF\\New Feature\\4G_ASPZ_WRO\\4G_ASPZ_WRO - WOM\\CRT\\AirScale   ${path_to_qc}
    Log  ${path_to_qc}  console=true
    [Return]    ${path_to_qc}

Get Appropriate Paths To Qc
    [Documentation]    Returns Apropriate QC Path for given SW version and platform
    [Arguments]    ${active_sw_version}    ${platform}
    ${if_airscale}=    Run Keyword And Return Status    Should Be Equal As Strings    ${platform}    airscale
    ${if_fsmf}=    Run Keyword And Return Status    Should Be Equal As Strings    ${platform}    fsmf
    ${if_abic}=    Run Keyword And Return Status    Should Be Equal As Strings    ${platform}    abic
    ${path_to_qc_airscale}=    Run Keyword If    ${if_airscale}    Get Appropriate Path To Qc    ${active_sw_version}    AirScale
    ${path_to_qc_fsmf}=    Run Keyword If    ${if_fsmf}    Get Appropriate Path To Qc    ${active_sw_version}    FSMr3
    ${path_to_qc_abic}=    Run Keyword If    ${if_abic}    Get Appropriate Path To Qc    ${active_sw_version}    ABIC
    ${path_to_qc}=    Set Variable If    ${if_airscale}  ${path_to_qc_airscale}   ${if_fsmf}   ${path_to_qc_fsmf}  ${if_abic}  ${path_to_qc_abic}
#    ${path_to_qc}=    Set Variable If    ${if_fsmf}   ${path_to_qc_fsmf}    ${path_to_qc_airscale}
#    ${path_to_qc}=    Set Variable If    ${if_abic}   ${path_to_qc_abic}
    [Return]    ${path_to_qc}

Set dates Baj
    Set Suite Variable    ${pm_date_user_format}    %d.%m.%Y %H:%M                #Date format for eNB and OMS
    Set Suite Variable    ${user_date}              %Y.%m.%d %H:%M                #Date format for NetAct
    #Check time and wait 4 minutes if PMs could not reach NetAct
    ${min}=    Get Time    min
    ${minutes}=    Convert To Integer    ${min}
    Run keyword if    59<=${minutes}<60 or 0<=${minutes}<3 or 14<${minutes}<18 or 29<${minutes}<33 or 44<${minutes}<48    Sleep    4 minutes
    #Set current date for eNB
    ${end_time_format}    ${start_time_format}=    Specify Date Baj    ${pm_date_user_format}    -135
    Set Suite Variable    ${end_time_format}
    Set Suite Variable    ${start_time_format}
    ${end_time_format_na}    ${start_time_format_na}=    Specify Date Baj    ${user_date}    -15
    Set Suite Variable    ${end_time_format_na}
    Set Suite Variable    ${start_time_format_na}

Specify date Baj
    [Arguments]    ${data_format}    ${time increment}=0    ${duration_time}=30    ${interval}=15
    ${actual_time}=    Get Current Date    exclude_millis=True    increment=${time_increment} minutes
    Set Suite Variable    ${end_time}    ${actual_time}
    ${actual_time}=    Subtract Time From Date    ${end_time}    ${duration_time} minutes    exclude_millis=True
    Set Suite Variable    ${start_time}    ${actual_time}
    ${number_of_samples}=    Evaluate    ${duration_time}/${interval}
    Set Suite Variable    ${number_of_samples}
    #Set correct date format for eNB and OMS
    ${start_time_format}=    Convert Date    ${start_time}    ${data_format}
    ${end_time_format}=    Convert Date    ${end_time}    ${data_format}
    [Return]    ${end_time_format}    ${start_time_format}

Test Suite Setup PM Baj
    [Arguments]  ${infomodel_alias}=default  ${ute_admin_alias}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}
    Get and Set enb Parameters
    Get And Set NetAct Parameters SRAN
    Show Current SBTS Configuration PM  alias=${infomodel_alias}
    Setup TA NetAct    was_host=${NA_WAS}    was_ssh_user=${NA_USER}    was_ssh_pass=${NA_PASS}    fm_host=${NA_DB}
    ...    fm_ssh_user=${NA_USER}    fm_ssh_pass=${NA_PASS}
    Setup Ta Netact Pm    db_host=${NA_DB}    port=1521   alias=ta_netact_pm
    Setup Netact Cm Operations
    Setup Ta Netact Monitor Fm  alias=ta_netact
    Set Reset Counter Before Test
    Set Test Start Time

Test Suite Setup PM Baj v2
    [Arguments]  ${infomodel_alias}=default  ${ute_admin_alias}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}
    Get and Set enb Parameters
    Get And Set NetAct Parameters SRAN
    Show Current SBTS Configuration PM  alias=${infomodel_alias}
    Setup Ta Netact Pm    db_host=${NA_DB}    port=1521   alias=ta_netact_pm    was_host=${NA_WAS}
    ...    was_ssh_user=${NA_USER}    was_ssh_pass=${NA_PASS}    fm_host=${NA_DB}    fm_ssh_user=${NA_USER}    fm_ssh_pass=${NA_PASS}
    Add node    service_name=cmwas    hostname=${NA_WAS}    username=${NA_USER}    password=${NA_PASS}
    Add web url    web_url=${WEB_URL}    username=${NA_USER}    password=${NA_PASS}
    Set Reset Counter Before Test
    Set Test Start Time

Test Suite Teardown PM Baj v2
    [Arguments]  ${infomodel_alias}=default  ${ta_enb_alias}=ta_enb  ${ute_admin_alias}=default
    Teardown Infomodel  alias=${infomodel_alias}
    Teardown Ta Enb  alias=${ta_enb_alias}
    Teardown Admin  alias=${ute_admin_alias}
    Clean All
    Teardown Ta Enb PM
    Teardown Ta Netact Pm    alias=ta_netact_pm
    Get Test Duration Time

Test Suite Teardown PM Baj
    [Arguments]  ${infomodel_alias}=default  ${ta_enb_alias}=ta_enb  ${ute_admin_alias}=default
    Teardown Infomodel  alias=${infomodel_alias}
    Teardown Ta Enb  alias=${ta_enb_alias}
    Teardown Admin  alias=${ute_admin_alias}
    Teardown Ta Netact Monitor Fm  alias=ta_netact
    Teardown Netact Cm Operations
    Teardown Ta Netact
    Teardown Ta Enb PM
    Teardown Ta Netact Pm  alias=ta_netact_pm
    Get Test Duration Time

Get Counters From ENB And Netact And Compare_PMQAP Baj
    [Arguments]  ${PM_LIST}  ${CURDIR1}  ${time_shift}=0
    ${PMQAP_id_list}=    Create List Of PMQAP Baj
    ${text_file}=    OperatingSystem.Get file    ${CURDIR1}/test_data_files/${PM_LIST}
    ${counters_group_list}=    Split String    ${text_file}    ;
    ${eNB_pm_list}=    Get and parse xml file from eNB    ${start_time_format}    ${end_time_format}
    FOR     ${counters_group}    IN    @{counters_group_list}
        ${name_of_group}    ${counters}=    OperatingSystem.Split_Extension    ${counters_group}
        ${stripped_name}=    Strip String    ${name_of_group}    characters=\n
        ${counters_list}=    Split String    ${counters}
        ${local_moid_part1}=    Set Variable    //*[*/DN/text()="PLMN-PLMN/MRBTS-${ENB_ID}/LNBTS-${ENB_ID}
        ${local_moid_part2}=    Set Variable    [*/DN/text()="PLMN-PLMN/MCC-555/MNC-10"][*/DN/text()="PLMN-PLMN
        ${local_moid_part3}=    Set Variable    "]/*[@measurementType="${stripped_name}"]
        ${NetAct_local_moid_part1}=    Set Variable    DN:NE-LNBTS-${ENB_ID}/LNCEL-
        ${NetAct_local_moid_part2}=    Set Variable    /MCC-555/MNC-10/PMQAP-
        ${dictenb}    ${dictoms}    ${dictNA}=    Get Counters from Cell Level for PMQAP Profiles
        ...    ${eNB_pm_list}    ${cells_id_list}    ${PMQAP_id_list}    ${counters_list}
        ...    ${local_moid_part1}    ${local_moid_part2}    ${local_moid_part3}    ${NetAct_local_moid_part1}
        ...    ${NetAct_local_moid_part2}    ${number_of_samples}    ${time_shift}
    END


Create List of PMQAP Baj
    [Documentation]  Keyword checks pmqap_ids and returns a list containing every pmqap_id. Requires previously setup infomodel
    [Arguments]  ${alias}=default
    [Timeout]  5 min
    ${list_of_pmqap}   create list
    ${side}  Check which side is your AirScale
    ${pmqap_paths}    create dictionary
                      ...   FL16A=/MRBTS-1/RAT-1//LNBTS-1/LCELL-
                      ...   FL17A=/MRBTS-1/RAT-1//CELL_M-
                      ...   FL17SP=/MRBTS-1/RAT-1//CELL_M-
                      ...   FL17ASP1=/MRBTS-1/RAT-1/MCTRL-${side}//LNCEL_M-
                      ...   SBTS17A=/MRBTS-1/RAT-1//CELL_M-
                      ...   SBTS18SP=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS19A=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS19B=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS20A=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS20B=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS20C=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS21A=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS21B=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS22R1=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   SBTS22R2=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      #...   SBTS18SP=/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-3/SCF-1/MRBTS_A-${ENB_ID}/LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   FL18=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   FL18SP=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   FL19=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
                      ...   FL19A=/MRBTS-1/RAT-1//LNBTS_A-${ENB_ID}/PMRNL_A-1/PMQAP_A-
    ${ENB_RELEASE}=    Convert To Uppercase    ${ENB_RELEASE}
    ${path}=    get from dictionary    ${pmqap_paths}    ${ENB_RELEASE}
    ${pmqaps}   Query Infomodel
    ...             query=get list ${path}*
    ...             alias=${alias}
    FOR    ${pmqap}    IN    @{pmqaps}
        ${dist}=    get from dictionary  ${pmqap}  dist_name
        ${pmqap_no}=    fetch from right  ${dist}  -
        append to list  ${list_of_pmqap}  ${pmqap_no}
    END
    [Return]  ${list_of_pmqap}

Test Suite Setup Baj
    [Arguments]  ${infomodel_alias}=default  ${ute_admin_alias}=default
    Suite Setup Infomodel    im_port=443  alias=${infomodel_alias}
    Show Current SBTS Configuration  alias=${infomodel_alias}
    Setup Admin    bts_host=${ENB_MPLANE_IP}    bts_port=443   use_ssl=True  alias=${ute_admin_alias}
    Setup TA NetAct    was_host=${NA_WAS}    was_ssh_user=${NA_USER}    was_ssh_pass=${NA_PASS}    fm_host=${NA_DB}
    ...    fm_ssh_user=${NA_USER}    fm_ssh_pass=${NA_PASS}
    Setup Netact Cm Operations
    Setup Ta Netact Monitor Fm
    Set Reset Counter Before Test
    Set Test Start Time

Setup LM
    [Documentation]  Keyword makes setup for LM tests
    Set Suite Variable     ${Netact_flat}        srnclab2009

Suite Setup LM
    Set Suite Variable     ${HOSTNAME}        ${NA_WAS}
    Set Suite Variable     ${USERNAME}        ${NA_USER}
    Set Suite Variable      ${PASSWORD}        ${NA_PASS}
    Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${Netact_flat}

Suite Postcondition LM
    Clean All    alias=${Netact_flat}

Setup NMS
    [Documentation]  Keyword makes setup for NMS tests
    [Arguments]    ${nms_lab}=srnclab2009
    Set Suite Variable     ${Netact_flat}    ${nms_lab}
