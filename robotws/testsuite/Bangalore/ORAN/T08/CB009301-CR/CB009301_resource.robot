*** Settings ***
Documentation     This contains common keywords which are needed to run NR TDD+FDD ULCA L3 Calls.

Library    Telnet
Library    String
Library    Process
Library    BuiltIn
Library    DateTime
Library    Collections
Library    OperatingSystem
Library    taf.config.scf   WITH NAME    scf
Library    taf.wts.runner    WITH NAME    wtsrunner
Library    taf.config.wts    WITH NAME    wts_conf
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.collectors.core    WITH NAME    core
Library    taf.ul.alarms_watchdog   WITH NAME    alarm
Library    taf.collectors.btslog    WITH NAME    btslog
Library    taf.collectors.simple    WITH NAME    simple
Library     taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library     taf.gnb.oam.coam.cu    WITH NAME    admincu
Library    taf.sw.syslog     WITH NAME    taf_syslog
Resource   ../../../ORAN/SG04/resources/reportingportal_Keywords.robot
Resource            taf/rfrl/common_resources/common_step/interface.robot
Library    taf.sw.scout    WITH NAME    scout
Library    taf.sbts.oam.coam.admin    WITH NAME   admin

*** Variables ***
#Suite Setup Parameters
${host_vDU}              192.168.255.129
${host_vCU}              192.168.100.129
${PORT}                  443
${USER}                  Nemuadmin
${PWD}                   Nokia@123
${srvc_name}             cmwas
${vDU_NODE_HOST}         10.45.152.11
${vDU_NODE_USER}         core
${vDU_NODE_PASSWORD}     system123
${vDU_NAMESPACE}         vdutest
${vdu_connection}        vDU
${vcu_connection}        vCU
${BTS_ID}                1

${INSTALL_Radio}         ${CURDIR}/configurations/Install_Radios.sh
${scf_file_Config}       ${CURDIR}/configurations/CB009301_NR_FDD_FJT_SCF.xml
${DELTA_FILE_OLD}        ${CURDIR}/configurations/vlanid_old.json
${DELTA_FILE_NEW}        ${CURDIR}/configurations/vlanid_new.json
${enable_CB009301_file}      ${CURDIR}/configurations/enable_CB009301.json
${disable_CB009301_file}    ${CURDIR}/configurations/disable_CB009301.json
${OUT_LOG_PATH}          /home/ute/results/

#WTS parameters
&{WTS}                   Ip=127.0.0.1        Username=ute         Connection=Wts
${AMF_ID}                1
${WTS_DIR}               /opt/iphy/latest
${4G5G_Combo}            0
${Target_gNB}            2
${SUITE_WTS_CFG}         basic_1c.cfg
${Total_Timeout}         5 min
${Retry_Timeout}         15 sec
${Ng_link_pattern}       NG primary peer address.*up
${Ng_link_pattern_dual_stack}    NG link is Up
@{timeout}               300

${CELL_ID}                          1
${BEARER_ID}                        2
${Timeout_SA}    120
${Register_complete_pattern}    REGISTRATION COMPLETE
${Cell_setup_complete_pattern}    Cell Setup completed
${UE_register_complete_pattern}    .*REGISTRATION COMPLETE.*
${Initial_UE_message_pattern}    I\nnitial UE Message Success
${Initial_UE_success_pattern}    .*Initial UE Message Success.*
${UE_SIB_decoding_pattern_eNB}    SystemInformationBlockType2
${Initial_context_setup_pattern}    Initial Context Setup Successful
${UE_deregister_pattern}      UE Context Release Complete

&{GNB_SYSLOG}       ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog

@{Delay_list}
...    dlMinDelay
...    ulMinDelay


*** Keywords ***
Suite Setup
	Log to console    \n--Cloud environment Test Setup--\n
    Setup_VDU
    Setup_VCU
    Set global variable    ${BTS_ID}
    Set global variable    ${dist_name}    MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    Set global variable    ${FEATCADM_dist}    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    Set global variable    ${CABLINK_dist}    MRBTS-${BTS_ID}/EQM_R-1/HWTOP_R-1/CABLINK_R-1001/FHLKDLY_R-1
	Install TDD and FDD ORU
    Load BTS Configuration
    sleep    1000s
	Check if Radio state is enabled
	Run WTS configuration
	Check vDU Cell status
	Log Variables
	Log    \n+ Suite Setup finished    console=yes


Setup_VDU
    Log to console    \n--Connecting vDU--
    admindu.connect_to    host=${host_vDU}    port=${PORT}    connection_name=${vdu_connection}
    ...    username=${USER}    password=${PWD}    secure=True    timeout=300
    Log to console    \n--vDU is connected--

Setup_VCU
    Log to console    \n--Connecting vCU--
    admincu.connect_to    host=${host_vCU}    port=${PORT}    username=${USER}
    ...    password=${PWD}    secure=True    alias=vCU    timeout=300
    Log to console    \n--vCU is connected--

Check vDU Cell status
    [Documentation]    Check the vDU cell status
    ${vDU_Cell_status}=    admindu.get_vdu_cells_status    vdu_connection=${vdu_connection}    timeout=300
    log to console    ${vDU_Cell_status[0]['availability_status']}
    log    ${vDU_Cell_status[0]['availability_status']}
    Log    All cell statuses: ${vDU_Cell_status}
    FOR    ${cell}    IN    @{vDU_Cell_status}
        Should Be Equal As Strings    ${cell['availability_status']}    on line
        Log    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
	END
    ${offline_cells}=    Evaluate    [cell for cell in ${vDU_Cell_status} if cell['availability_status'] != 'on line']
    Run Keyword If    len(${offline_cells}) == 0    Log    All cells are online
    Log To Console    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
    [Return]    ${vDU_Cell_status[0]['availability_status']}

Link SCOUT SCF to Configuration ID for Reporting
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: VRF
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    log to console     ${scout_testline_name}
	Wait Until Keyword Succeeds    3min    10s    Request Scout SCF    ${scout_testline_name}

Request Scout SCF
    [Arguments]   ${bts_name}
    scout.setup_scout  ${bts_name}
    ${TC_ID}=   scout.request_scf   use_scout_internal_id=True
    scout.teardown_scout_api
    ${TC_ID}    set variable    ute:id:${TC_ID}
    Set Tags  ${TC_ID}

Stop Syslog
    RUN Keyword and Ignore Error    taf_syslog.Stop Syslog    alias=${GNB_SYSLOG.alias}

Suite Teardown
    Log to console   \n--End Test--\n
    admindu.disconnect    vdu_connection=${vdu_connection}
    admincu.disconnect    connection=vCU
    Log Variables
	Check resource hanging
    Log    \n+ Suite teardown finished    console=yes

Snapshot_vDU
    Log to console    \n--DU Snapshot collection started--\n
    create directory    ${out}/Snapshot_vDU/
    admindu.get_local_snapshot    directory=${out}/Snapshot_vDU/
    ...    request_timeout=30    operation_timeout=600     vdu_connection=${vdu_connection}
    Log to console    \n--DU Snapshot collection Ended--\n

Snapshot_vCU
    Log to console    \n--CU Snapshot collection started--\n
    create directory    ${out}/Snapshot_vCU/
    admincu.get_local_snapshot    directory=${out}/Snapshot_vCU/
    ...    request_timeout=30    operation_timeout=600     connection=vCU
    Log to console    \n--CU Snapshot collection Ended--\n

Start Syslogs
    Log To Console    \n [INFO] bts collector creation is in progress
    RUN Keyword and Ignore Error    taf_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=/tmp/btslog2
    ...    log_name=${GNB_SYSLOG.log_name}    ip=${GNB_SYSLOG.ip}    alias=${GNB_SYSLOG.alias}

Install TDD and FDD ORU
    Run    chmod a+x ${INSTALL_Radio}
    Run    sh ${INSTALL_Radio}
    sleep    150s
    Log to console    \n [INFO] Installing NR TDD and NR FDD ORAN radio

Check VlanId
    ${vlanId}=    admin.Get Parameters
	...		dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/TNLSVC_CONF_M-1/TNL_CONF_M-1/ETHSVC_CONF_M-1/ETHIF_CONF_M-1/VLANIF_CONF_M-1
    ...     connection=${ADMIN_ALIAS}
	${vlanId_1}=		Get From Dictionary    ${vlanId}    vlanId
    ${vlanId_str}=    Convert to String    ${vlanId_1}
    ${json}=   OperatingSystem.Get File    ${DELTA_FILE_OLD}
    ${replace}=     Replace String    ${json}    10000    ${vlanId_str}
    Create File   ${CURDIR}/configurations/vlanid_new.json      ${replace}

Load BTS Configuration
    [Documentation]    Perform BTS Full Commissioning
	Log to console    \n Performing BTS commission...
    ADMIN Perform Commissioning     ${scf_file_Config}     ${vdu_connection}


ADMIN Perform Commissioning
    [Arguments]    ${scf_file_Config}
    ...            ${True}=True
    ...            ${timeout}=600
    ...            ${vdu_connection}=${vdu_connection}
    admindu.Perform Commissioning      scf_file=${scf_file_Config}
    ...                                vdu_connection=${vdu_connection}
    ...                                should_activate=${True}
    ...                                timeout=${timeout}
    ...                                wait_for_completion=${True}

Change VlanId
	ADMIN Perform Delta Recommissioning
        ...    delta_file=${DELTA_FILE_NEW}
        ...    skip_parameter_relation_errors=${True}

ADMIN Perform Delta Recommissioning
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=False
    ...            ${should_activate}=True
    ...            ${timeout}=300
    ...            ${alias}=${ADMIN_ALIAS}
    admin.Perform Delta Recommissioning    delta_file=${delta_file}
    ...                                        skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                        should_activate=${should_activate}
    ...                                        timeout=${timeout}
    ...                                        alias=${alias}

ADMIN Assert All Rmods Are In Enabled State
    [Arguments]    ${timeout}=10
    ADMIN Assert All Rmods Are In Expected Operational State    expected_state=regex"Enabled|enabled"
    ...                                                         timeout=${timeout}

ADMIN Assert All Rmods Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ADMIN Assert All Rmods Are In Expected State    expected_state=${expected_state}
    ...                                             timeout=${timeout}
    ...                                             state_type=operationalState

ADMIN Assert All Rmods Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=RMOD
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

Run WTS configuration
    [Documentation]    \n To Start WTS configuration for AMF & MME Simulation
    Start UTE WTS

Start UTE WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS
    Stop Edaemon Egate
    Configure UTE ETH3 FOR BOAM_ET_CONF
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=300
    Wait Until Keyword Succeeds    10 min    30 sec    Verify if sim state is active
    sleep	80s

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Configure UTE ETH3 FOR BOAM_ET_CONF
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.150/24 dev eth3
    Run    sudo ip addr add 10.0.1.112/24 dev eth3

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    ssh.Connect to     hostname=${WTS.Ip}
    ...                username=${WTS.Username}
    ...                alias=${WTS.Connection}
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=10 &&
    ...               sysctl -w net.sctp.rto_min=200 &&
    ...               sysctl -w net.sctp.rto_initial=200 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Verify if sim state is active
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=20

Verify Ng Link Status
    [Documentation]    \n -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
	Log to console    \n NG Link is available

NG Link Should be UP
    [Documentation]    This keyword checks if the NG link is up for the SA variant in egate_console.log file
    ...                Modified Date: 10-Jun-2021
    ...                Last Modified by: gopalakrishnan.n@nokia.com
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}
    ...    NG link check using AMF Link Status    ${AMF_ID}    ${TARGET_GNB}


NG link check using AMF Link Status
    [Arguments]    ${amf_id}=${AMF_ID}    ${gnb_id}=${Target_gNB}
    [Documentation]    This Keyword checks if the NG link status for the mentioned gNB ID using the amf_disp command
    ...    on egate console
    wtsrunner.amf_disp    id=${amf_id}    type=link_info    gnb=${gnb_id}
	${amf_link_status}=    Run Keyword And Return Status
    ...    wtsrunner.read_wtsemu_output_until_re    expected=${Ng_link_pattern}    timeout=60
    Run Keyword If    '${amf_link_status}'=='False' and '${4G5G_Combo}'=='1'
    ...    Search pattern should Exists In EGATE
    ...    ${WTS_DIR}/egate_console.log    ${Ng_link_pattern_dual_stack}
    ...    ELSE IF    '${amf_link_status}'=='True'    Log    "NG Link in UP"
    ...    ELSE    Fail    msg="NG Link is not Up"

Search pattern should Exists In EGATE
    [Arguments]    ${file}    ${pattern}    ${grepArgs}=grep -i
    ${command}        Catenate    ${grepArgs} '${pattern}' ${file}
    ${result}         Run    ${command}
    Log               ${result}
    Should Contain    """${result}"""    ${pattern}    ignore_case=${TRUE}

ADMIN Assert Every
    [Arguments]    ${class_name}
    ...            ${parameters}
    ...            ${timeout}=10
    ...            ${alias}=${ADMIN_ALIAS}
    admin.Assert Every    class_name=${class_name}
    ...                       parameters=${parameters}
    ...                       timeout=${timeout}
    ...                       alias=${alias}

ADMIN Assert All NRCells Are In Enabled State
    [Arguments]    ${timeout}=10
    ...            ${expected_state}=regex"Enabled|enabled"
    ...            ${class_name}=NRCEL
    ADMIN Assert All NRCells Are In Expected Operational State    expected_state=${expected_state}
    ...                                                         timeout=${timeout}
    ...                                                         class_name=${class_name}

ADMIN Assert All NRCells Are In Expected Operational State
    [Arguments]    ${expected_state}
    ...            ${timeout}=10
    ...            ${state_type}=operationalState
    ...            ${class_name}=NRCEL
    ADMIN Assert All NRCells Are In Expected State    expected_state=${expected_state}
    ...                                             state_type=${state_type}
    ...                                             timeout=${timeout}
    ...                                             class_name=${class_name}

ADMIN Assert All NRCells Are In Expected State
    [Arguments]    ${state_type}
    ...            ${expected_state}
    ...            ${timeout}=10
    ...            ${class_name}=NRCEL
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

ADMIN Assert BTS is onAir
    [Arguments]    ${state_type}=proceduralState
    ...            ${expected_state}=regex"[oO]nAir"
    ...            ${timeout}=10
    ...            ${class_name}=BTS
    ADMIN Assert Every    parameters=${state_type}=${expected_state}
    ...                   timeout=${timeout}
    ...                   class_name=${class_name}

Check if Radio state is enabled
    [Documentation]    \n Check if Operational State of all Radio's is enabled
    Radio State should be enabled

Radio State should be enabled
    Wait Until Keyword succeeds     20min    30s    Verify Coam Radio is Online

Verify Coam Radio is Online
    ${bts_hw_info}                admindu.get_rmods_status    vdu_connection=${vdu_connection}
    ${radio_state}                Set Variable
    ...                           ${bts_hw_info [0]['operational_state']}
    Log to Console    \n [INFO] RADIO STATE : ${radio_state}
    Should Be Equal As Strings    ${radio_state}    enabled    ignore_case=${TRUE}

Expected alarm
    [Documentation]     Alarms which are ignored on runtime
    ${allowed_alarm_1}    Create alarm    alarm_id=7220     fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220     fault_id=4654     fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220     fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220     fault_id=4655     fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220     fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_6}    Create alarm    alarm_id=61641    fault_id=61641    fault_name=IP Traffic Capturing ongoing
    ${allowed_alarm_7}    Create alarm    alarm_id=7115     fault_id=4592     fault_name=BTS Reset Cause
    ${allowed_alarm_8}    Create alarm    alarm_id=7115     fault_id=8000     fault_name=Failure in connection between BTS and 3rd party tool
    ${allowed_alarm_9}    Create alarm    alarm_id=7102     fault_id=49       fault_name=Cell blocked
	${allowed_alarm_10}    Create alarm    alarm_id=7115     fault_id=4740     fault_name=EFaultId_ClearFaultNotifUnderMoAl
    ${allowed_alarm_11}    Create alarm    alarm_id=7115     fault_id=4681     fault_name=Sanity Check Error
    ${allowed_alarm_12}    Create alarm    alarm_id=7115     fault_id=4720
	...    fault_name=Mismatch of RU reported capabilities with static HW Validation information
	${allowed_alarm_13}    Create alarm    alarm_id=7115     fault_id=4602     fault_name=5G cell configuration mismatch
	${allowed_alarm_14}    Create alarm    alarm_id=7114     fault_id=7509
	...    fault_name=EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
	${allowed_alarm_15}    Create alarm    alarm_id=7110     fault_id=4293     fault_name=IP Traffic Capacity Limit
	${allowed_alarm_16}    Create alarm    alarm_id=7107     fault_id=7300     fault_name=No X2 link available
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}
    ...     ${allowed_alarm_5}  ${allowed_alarm_6}  ${allowed_alarm_7}  ${allowed_alarm_8}  ${allowed_alarm_9}  #${allowed_alarm_10}
    ...     ${allowed_alarm_11}  ${allowed_alarm_12}  ${allowed_alarm_13}  ${allowed_alarm_14}  ${allowed_alarm_15}  ${allowed_alarm_16}
    [Return]    ${allowed_alarms}

Activate eCPRI Delay Measurement
    [Arguments]    ${dist_name}     ${parameter}    ${value}
    [Documentation]     Change parameter value in SCF and commision it
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run Keyword If    '${current_value}' == 'false'    Enable CB009301 Feature    ${enable_CB009301_file}    ${ADMIN_ALIAS}
    ${current_value}    Get Current Parameter Value    ${dist_name}    ${parameter}
    LOG    ${current_value}
    Run keyword And Continue On Failure    Should Be Equal As Strings    ${current_value}    ${value}
    Sleep    10s

Enable CB009301 Feature
    [Documentation]     Change parameter value in SCF and commision it
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=false
    ...            ${should_activate}=true
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    admin.perform delta recommissioning    delta_file=${delta_file}
    ...            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...            should_activate=${should_activate}
    ...            timeout=${timeout}
    ...            connection=${connection}

Get Current Parameter Value
    [Arguments]    ${dist_name}    ${param_name}
    [Documentation]     Get current parameter value
    ${temp_scf_file}    admin.Get Current Scf File    local_dir_path=/tmp    file_name=temp_scf.xml    connection=${ADMIN_ALIAS}
    scf.Load Scf    ${temp_scf_file}
    ${param_value}    scf.get_value_from_scf    dist_name=${dist_name}    p_name=${param_name}
    [Return]    ${param_value}

Get Measured Delay
    [Documentation]     Get current parameter value
    ${param_value}    admindu.get_managed_object_parameters_of_current_plan    dist_name=${CABLINK_dist}    timeout=30
	...    vdu_connection=${vdu_connection}
    Log to console    \n ${param_value}
    ${parameters} =    Get From Dictionary    ${param_value}    parameters
    ${first_param} =    Get From List    ${parameters}    0
    ${dl_min_delay} =    Get From Dictionary    ${first_param}    simple_parameter
    ${dl_min_delay_name} =    Get From Dictionary    ${dl_min_delay}    name
    ${dl_min_delay_value} =    Get From Dictionary    ${dl_min_delay}    value
	${dlvalue} =  BuiltIn.Convert To Integer  ${dl_min_delay_value}
    Run Keyword And Continue On Failure    Should Be True    ${dlvalue} >= 0
    ${parameters} =    Get From Dictionary    ${param_value}    parameters
    ${first_param} =    Get From List    ${parameters}    3
    ${ul_min_delay} =    Get From Dictionary    ${first_param}    simple_parameter
    ${ul_min_delay_name} =    Get From Dictionary    ${ul_min_delay}    name
    ${ul_min_delay_value} =    Get From Dictionary    ${ul_min_delay}    value
	${ulvalue} =  BuiltIn.Convert To Integer  ${ul_min_delay_value}
    Run Keyword And Continue On Failure    Should Be True    ${ulvalue} > 0

Disable CB009301 Feature
    [Documentation]     Change parameter value in SCF and commision it
    [Arguments]    ${delta_file}
    ...            ${skip_parameter_relation_errors}=false
    ...            ${should_activate}=true
    ...            ${timeout}=300
    ...            ${connection}=${ADMIN_ALIAS}
    admin.perform delta recommissioning    delta_file=${delta_file}
    ...            skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...            should_activate=${should_activate}
    ...            timeout=${timeout}
    ...            connection=${connection}

L3 Call
    [Arguments]    ${UE_ID}=${1}    ${dl_tp}=${175}    ${ul_tp}=${175}    ${start_id}=${1}    ${end_id}=${15}
    Attach Single SA CA UE    ${UE_ID}
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=1
    Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=2
    FOR	    ${trf_id}   IN RANGE    ${start_id}	  ${end_id}
       Start SA Internal Traffic    ${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=${trf_id}
    END
    ${pcell_dl_tp}=    Get Cell Average Throughput    ${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    Log to Console    Primary Cell Downlink Throughput=${pcell_dl_tp}
    ${pcell_ul_tp}=    Get Cell Average Throughput    ${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    Log to Console    Primary Cell Uplink Throughput=${pcell_ul_tp}
    log     DL Troughput of pcell is ${pcell_dl_tp}
    log     UL Troughput of pcell is ${pcell_ul_tp}
    Should Be True    ${pcell_dl_tp}>160
    Should Be True    ${pcell_ul_tp}>160

Attach Single SA CA UE
    [Arguments]    ${UE_ID}
    SA 5G Attach    ${UE_ID}
    SA Set Traffic Type To Internal    ${UE_ID}    pdu_id=1
    SA CA 5G PDU Session Setup    ${UE_ID}

SA 5G Attach
    [Arguments]    ${UE_ID}
    [Documentation]    This keyword is used to simulate UE attach on 5GNR side during NSA L3 Call on eGate.
    ...    Expected output is: "UE1: Proxy (eNB 2 Cell 3 ) reported successful RA" on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Attach | 1 |
    Log To Console    start 5G attach...
    Sleep    20s
    wtsrunner.ue_register    id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    I\nnitial UE Message Success
    Sleep    3s    reason=wait 5G attach is stable

Read WTS Output Until Pattern Matches
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks the output file until the ${pattern} matches in the file.
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=${pattern}
    ...    timeout=${timeout}
    [Return]    ${output}

SA Set Traffic Type To Internal
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    wtsrunner.set_pdu_param     ue=${UE_ID}    pdu=${pdu_id}    trf_type=internal

SA CA 5G PDU Session Setup
    [Arguments]    ${UE_ID}    ${pdu_id}=1
    [Documentation]    This keyword is used to simulate PDU session setup on 5GNR side.
    ...    Expected output is: " Initial Context Setup Successful " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G PDU Session Setup | 1 |
    Log To Console    start 5G PDU Session Setup...
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${UE_ID}    nwslice=1    gw=1
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    Log To Console    ${output_0}

Read WTS Output For Pattern And Print matching Lines
    [Arguments]    ${pattern}    ${timeout}
    [Documentation]    This keyword checks if the ${pattern} is present in the output file and prints the line matching the pattern.
    ${output}    Read WTS Output Until Pattern Matches   ${pattern}    ${timeout}
    Print Matching Lines from Output File    ${output}    ${pattern}
    [Return]    ${output}

Print Matching Lines from Output File
    [Arguments]    ${output}    ${pattern}
    [Documentation]    This keyword Prints the lines which contains the ${pattern} from the output file ${output}
    ${output}        String.Get Lines Matching Regexp    ${output}    ${pattern}
    ...               partial_match=${TRUE}
    Log to Console    \n${output}

Start SA Internal Traffic
    [Arguments]    ${UE_ID}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    Log To Console    start Internal traffic...
    wtsrunner.trf_data_start    ue=${UE_ID}    pdu=${pdu_id}    dir=${dir}    mbps=${mbps}
    ...    trf_id=${trf_id}
    Sleep    5s    reason=wait traffic is stable

Get Cell Average Throughput
    [Arguments]    ${UE_ID}    ${dir}    ${cell_type}    ${scell_index}
    [Documentation]    This keyword is to get Pcell/Scell Average throughput,1Mbps=1000Kbps
    ...    The unit of return throughput is Mbps.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${UE_ID} | Yes | ue_id |
    ...    | ${dir} | Yes | dl/ul |
    ...    | ${cell_type} | Yes | pcell/scell |
    ...    | ${scell_index} | Yes | 1/2/3...|
    ...
    ...    | Examples: |
    ...    | ${pcell_tput} | Get CA Cell Average Throughput | 1 | dl | pcell | 0 |
    ...
    ${type}    Set Variable If    '${dir}'=='dl'    pdsch    pusch
    wtsrunner.ue_stats_nr    id=${UE_ID}    type=${type}    scell=${scell_index}
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Total       timeout=300
    ${regexp_cell}    Catenate    SEPARATOR=${EMPTY}    CellIndex-\\d{1,2}\\s+((\\d+.?\\d*\\s)(Mbps)?(Kbps)?(bps)?\\s+){3}
    ...    (?P<AvgTput>\\d+.?\\d*)\\s(?P<TputUnit>(Mbps)?(Kbps)?(bps)?)
    ${avg_tp_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    AvgTput
    ${cell_tp}=    Evaluate    sum(map(float,${avg_tp_list}))
    ${cell_tp}=    Set Variable If    "${cell_tp}"=="0.0"    0    ${cell_tp}
    ${tp_unit_list}    String.Get Regexp Matches    ${output}    ${regexp_cell}    TputUnit
    ${tp_unit_empty}    ${ret}    Run Keyword And Ignore Error    Should Be Empty    ${tp_unit_list[0]}
    Run Keyword If    "${cell_tp}"=="0"    Append To List    ${tp_unit_list}    Mbps
    ${Kbps_to_Mbps}    Evaluate    float(${cell_tp}/1000)
    ${bps_to_Mbps}    Evaluate    float(${cell_tp}/1000/1000)
    ${cell_tput_Mbps}    Set Variable If    '${tp_unit_list[0]}'=='Kbps'    ${Kbps_to_Mbps}
    ...                                     '${cell_tp}'!='0' and '${tp_unit_empty}'=='PASS'    ${bps_to_Mbps}
    ...                                     ${cell_tp}
    [Return]    ${cell_tput_Mbps}

Get Cell Throughput From Btslog
    [Arguments]    ${duration}=20s    ${log_dir}=${OUTPUT_DIR}
    ${savepoint}=    taf_syslog.Capture Savepoint    alias=${GNB_SYSLOG.alias}
    Sleep    ${duration}
    taf_syslog.Collect From Savepoint    savepoint=${savepoint}    destination_file=${log_dir}/target_syslog.txt    alias=${GNB_SYSLOG.alias}
    ${tp}=    Analyze_syslog.get_tp_from_syslog    ${log_dir}/target_syslog.txt
    [Return]    ${tp}

Check Cell Throughput Quality From Btslog
    [Arguments]    ${tp_list}    ${cell_id}    ${direction}    ${target_tp}    ${aver_ratio}=${0.95}    ${min_ratio}=${0.85}
    [Documentation]    Check Throughput Quality from keyword "Get Cell Throughput From Btslog"
    ...    | Input Parameters | Man. | Description |
    ...    | ${tp_list} | YES | return value from keyword "Get Throughput From Bts" |
    ...    | ${cell_id} | YES | cell id|
    ...    | ${direction} | YES | dl/ul|
    Should Be True    ${tp_list}[${direction}][${cell_id}][ave]>${target_tp}*${aver_ratio}    Syslog average TP is lower than Target
    Should Be True    ${tp_list}[${direction}][${cell_id}][min]>${target_tp}*${min_ratio}    Syslog min TP is lower than Target

SA 5G Detach
    [Arguments]    ${UE_ID}=1
    [Documentation]    This keyword is used to simulate UE detach on 5GNR side.
    ...    Expected output is: " UE Context Release Complete " on eGate.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    Example:
    ...    | SA 5G Detach | 1 |
    Log To Console    start 5G detach...
    wtsrunner.ue_deregister    id=${UE_ID}    ue_deregister_type=switch_off
    ${output_0}    Read WTS Output For Pattern And Print matching Lines    ${UE_deregister_pattern}    ${Timeout_SA}
    ${output1}    String.Get Lines Matching Regexp    ${output_0}    UE Context Release Complete
    ...    partial_match=${true}
    Log To Console    \n${output1}

Collect SosReport
    [Arguments]    ${log_dir}
    Log to console	\n Start generating Sos Report
    OperatingSystem.Run    rm ${WTS_DIR}/SosReport*.tgz
    Create Directory    ${log_dir}/
    ${output}=		Run         cd ${WTS_DIR}/ && ${WTS_DIR}/sosReport_ASIK_ASIL.sh
    Wait Until Created	${WTS_DIR}/SosReport*.tgz	timeout=5 minute
    Wait Until Keyword Succeeds    100s    20s	OperatingSystem.Run    mv ${WTS_DIR}/SosReport*.tgz ${log_dir}/

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
	...    /home/ute/robotws/testsuite/Bangalore/ORAN/SG08/CB009301/configurations/hanging.py ${OUT_LOG_PATH}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI