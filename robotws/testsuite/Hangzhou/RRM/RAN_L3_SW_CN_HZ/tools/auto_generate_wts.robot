*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          ../resources/DevHZ5_resource.robot

*** Variables ***
${config_path}    ${CURDIR}/../resources/configuration_file/trunk/AP_KL_CONF
${tl_type}        l1bypass_tdd_sa_cmwv/1cell
${wts_svn_path}    ${config_path}/${tl_type}/wts

*** Test Cases ***
Auto Generate Lua
    ${config_dir}    Set Variable
    Get Current Scf File  local_dir_path=.
    ...  file_name=scf.xml
    ${cutype}    get_scf_parameter_value    gNbCuType    scf.xml
    Generate Default Cfg1    30    ${WTS_DIR}    ${AUTO_CFG}    ${wts_svn_path}/wts.cfg    scf.xml    AirphoneConfig.xml
    ...    ${cutype}
    Modify Cfg
    Teardown Cfg
    Log To Console    ${EMPTY}
    Log To Console    Lua configuration file: ${AUTO_CFG}
    ${apConfigIsExist}=    evaluate    os.path.exists("${wts_svn_path}//AirphoneConfig.xml")    modules=os
    Run Keyword If    ${apConfigIsExist}
    ...    Modify Apoamconfig    ${PARAMS_IN_APCONFIG_XML}    ${wts_svn_path}//AirphoneConfig.xml

*** Keywords ***
Suite Setup
    _Create Suite Log Directory
    Setup Admin
    ${edaemon_pid}    Get Linux Process Id    edaemon    22222
    Run Keyword If    "${edaemon_pid.__len__()}"=="0"    Execute Cmd On Pc    cd ${WTS_DIR};sudo ./edaemon --port 22222
    Run Keyword If    "${edaemon_pid.__len__()}"=="0"    Execute Cmd On Pc    cd ${WTS_DIR};./egate --port 20000
    Set Iphy Ip
	Configure SCTP

Suite Teardown
    Teardown All Aliases For Admin

Configure SCTP
	execute_cmd_on_pc    sudo sysctl -w net.sctp.sack_timeout=20
	execute_cmd_on_pc    sudo sysctl -w net.sctp.rto_min=200
	execute_cmd_on_pc    sudo sysctl -w net.sctp.rto_initial=200
	execute_cmd_on_pc    sudo sysctl -w net.sctp.rto_max=800
	Setup Wts Fsm Access    fallback_prompt=#
	execute_command_on_wts    sysctl -w net.sctp.sack_timeout\=20
	execute_command_on_wts    sysctl -w net.sctp.rto_min\=200
	execute_command_on_wts    sysctl -w net.sctp.rto_initial\=200
	execute_command_on_wts    sysctl -w net.sctp.rto_max\=800
	Teardown All Aliases For Wts Fsmaccess


Modify Cfg
    Comment    here use keywords from ta_kiss_lua_generator to modify default lua
