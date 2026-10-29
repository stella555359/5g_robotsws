*** Settings ***

Documentation       : This Resource file is used for ORAN

Library    BuiltIn
Library    SSHLibrary
Library    Collections
Library    OperatingSystem
Library    DateTime
#Library    SeleniumLibrary
Library    taf.ul.status_watchdog    WITH NAME    status
Library    taf.sbts.oam.coam.admin    WITH NAME    sbts
Library         taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library    taf.ul.alarms_watchdog    WITH NAME    alarms
Library    taf.selenium.sbts    WITH NAME    selLib
Library    taf.collectors.btslog    WITH NAME    btslog
Variables  ta5g_global_var
Library    taf.selenium.gnb.oam.coam.classical    WITH NAME    classical

Library     ../../../resources/python/BBpooling_MuMIMO.py
Resource     ../../../resources/robot/Admin.robot

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ../../../resources/python/avg_dl_data.py
Library          taf.sw.scout    WITH NAME     scout

Resource         ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot

*** Variables ***
${NOKIA_LOGIN}     Nemuadmin
${NOKIA_PASS}       nemuuser
${GNB_IP}          https://192.168.255.129
${operation_value}=    update
@{sudo_list}=        &{authentication}
&{authentication}   id=1    defaultNetconfAccount=&{default_user}
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
${local_save_path}   /home/ute/Downloads
${nwslice_ID}        1
${gw_ID}             1
${Pdu_session_ID}    1
${QFI_ID}            1
${INDEX2}            0
${artifactory_link1}     "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_O-RU_NK_475701A-102_0034.zip"
${artifactory_link}     "https://lterel.es-si-s3-z2.eecloud.nsn-net.net/RFM_PLUGIN"
${artifactory_link2}     "http://lterel.es-si-s3-z4.eecloud.nsn-net.net/RFM_PLUGIN/RFMPlugin_O-RU_FJ_TA08029-B311-A1_0003.zip"
${vdu_connection}=    vDU
${correct_netconf_credentials}    [{"id":"1","defaultNetconfAccount":{"defaultNetconfAccountName":"xranuser",
...                               "defaultNetconfAccountPwd":"xran-password"}}]

${reconf_filepath}      ${CURDIR}/../../../../../

*** Keywords ***
#Add RD Parameters To GNB Swconfig File
Add GNB RadParam
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    SSHLibrary.execute command    echo "0x890091=1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

load ncsnapshot
    [Arguments]    ${ncsnap_path}
      ${cmd1}  Set Variable   scp ${ncsnap_path} toor4nsn@192.168.200.1:/rom/simmode/
      ${status1}    run    ${cmd1}

load iphyfile
    [Arguments]    ${INSTALL_OFGESA}
    Run    chmod +x ${INSTALL_OFGESA}
    Run    sh ${INSTALL_OFGESA}
    Log to console    \nInstalling OFGESA radio

Basic Bring up
    [Documentation]       This keyword is for basic Ng and AP cell setup
    NG Link Should be UP
    AP Cell Setup should be Successful

Create Log Directory
    [Arguments]     ${Test_CaseNumber}
    Run         mkdir ${LOG_DIR}/${Test_CaseNumber}
    ${Log_Path}     Set Variable     ${LOG_DIR}/${Test_CaseNumber}
    set test variable       ${Log_Path}
    [Return]    ${Log_Path}

Trigger MAX DL throughput
   [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=174
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END

Trigger MAX UL throughput
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}+1
        MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=170
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END

Validate MAX DL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_DL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${ue_id}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_DL_thp}
	END

UE details display
    wtsrunner.ue_disp     id=${st_ue_id}
    wtsrunner.ue_disp     id=${en_ue_id}

Validate MAX UL throughput
    [Arguments]      ${st_ue_id}    ${en_ue_id}    ${expected_UL_thp}
	FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+1
        ${pcell_tput}=    Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        Should Be True    ${pcell_tput} > ${expected_UL_thp}
    END

Attach UE
    X2AP Link Should be UP
    LTE Attach should be Successful    ${sa_ue_id}
    UE Attach should be Successful    ${sa_ue_id}

Multiple SA UE Detach
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR   ${ue_id}   IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         UE Detach should be Successful    ${ue_id}
    END

Configure Netconf Credentials
    taf.sbts.oam.coam.admin.configure_netconf_accounts    unsecure_ciphering=false
    ...    authentication_method=NoAuthentication
    ...    timeout=60
    ...    connection=default
    ...    accounts=@{sudo_list}

Get and Update RFMplugin
     [Arguments]      ${sw_file_name}      ${artifactory_link}
     OperatingSystem.Run    wget ${artifactory_link} -P ${local_save_path}
     ADMIN Setup Admin
     ADMIN Update Software With Activation
     ...           sw_package=${local_save_path}/${sw_file_name}

Get and Update RFMplugin vdu
     [Arguments]      ${sw_file_name}
     OperatingSystem.Run    wget ${artifactory_link} -P ${local_save_path}
     admindu.connect_to     host=192.168.255.129       port=443     connection_name=${vdu_connection}
     ...        username=Nemuadmin     password=Nokia@123    secure=True        timeout=300
     admindu.trigger_sw_update    file_path=${sw_file_name}      vdu_connection=${vdu_connection}

Get and Install RFMplugin vdu
     [Arguments]      ${sw_file_name}
     OperatingSystem.Run    wget ${artifactory_link}/RFMPlugin_${sw_file_name}.zip -P ${local_save_path}
     admindu.connect_to     host=192.168.255.129       port=443     connection_name=${vdu_connection}
     ...        username=Nemuadmin     password=Nokia@123    secure=True        timeout=300
     admindu.trigger_sw_update    file_path=${local_save_path}/RFMPlugin_${sw_file_name}.zip      xml_file_name=TargetBD_RFM_${sw_file_name}.xml
     ...        sw_update_type=ORU_RFM      vdu_connection=${vdu_connection}

Get and Update BSR SW
     [Arguments]      ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ${target}=  Download software package    ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ADMIN Setup Admin
     ADMIN Update Software With Activation
     ...           sw_package=${target}

Teardown Suite
    Stop Syslog
    SSH Connection Close
    Collect Snapshot
    Admin Teardown
    Stop Alarms

Load CFG Config
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
#    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
#    ${oam_alias}=    Setup OAM session
#    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
#    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
#    Check gNB Airscale is Ready - ${BBoard_Type}
    sleep    300
    Log To console     loading cfg file
    Start WTS Using WTS_Runner      ${wts_cfg_file}

Selenium Connection Open
    [Documentation]    ... Opening Selenium Connection
    selLib.login
    ...    url=https://192.168.255.129
    ...    username=Nemuadmin
    ...    password=nemuuser
    ...    timeout=90
    ...    download_dir=${EXECDIR}
    ...    screenshot_dir=${EXECDIR}
    ...    browser=Chrome
    ...    wait_session_modal_timeout=15
    sleep    10


Selenium Connection Close
    [Documentation]    ... Opening Selenium Connection
    selLib.logout

Check Status
    [Documentation]    ... Checking BTS Status
    ${bts_status}    sbts.get_bts_statuses    connection=oam    timeout=90
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    OnAir
    Run Keyword If    '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \n---- BTS Status Is: ${bts_status["proceduralState"]}----\n

Check IntegratedToRAN
    [Documentation]    ... Checking BTS Status
    ${bts_status}    sbts.get_bts_statuses    connection=oam    timeout=90
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    IntegratedToRan
    Run Keyword If    '${bts_status["proceduralState"]}'=='IntegratedToRan'
	...    Log To Console    \n---BTS Status Is ${bts_status["proceduralState"]} as feature is enabled
	...    but BPF isn't downloaded on O-DU---\n

Check Commissioned
    [Documentation]    ... Checking BTS Status
    ${bts_status}    sbts.get_bts_statuses    connection=oam    timeout=90
    Should Be Equal As Strings    ${bts_status["proceduralState"]}    Commissioned
    Run Keyword If    '${bts_status["proceduralState"]}'=='Commissioned'
	...    Log To Console    \n----BTS Status Is ${bts_status["proceduralState"]} as feature is enabled but BPF
	...    isn't downloaded on O-DU---\n

Check Alarms
    [Documentation]    ... Checking Active Alarms
    sbts.collect_raw_alarm_history_file    connection=oam    timeout=90    target_file_name=${RAW_ALARM_HISTORY_PATH}
    ${active_alarms}=    sbts.get_active_alarms    connection=oam    timeout=120
    ${allowed_alarms}=    Expected_alarm
    alarms.watch_alarms    allowed_alarms=${allowed_alarms}    bts_config=${tl.gnbs[0]}
	Log to Console    \n---- Active alarms: ---- \n${active_alarms}



Reset Check and Enable feature
    Log to Console    \n---- LMP IP will be pinged to check if BTS took reset during feature enabled ----\n
    SSHLibrary.Open Connection    host=${VM_IP}
    SSHLibrary.Login    username=ute    password=BT5l@bus3rl0g1n
    SSHLibrary.write    cd /home/ute/robotws5g/Ajay/CB008934/
    SSHLibrary.write    script enable_feature.txt
    SSHLibrary.write    ping 192.168.255.129
    Enable feature
    sleep    90
    ${ctrl_c}    evaluate    chr(int(3))
    SSHLibrary.Write Bare    ${ctrl_c}
    sleep    10s
    ${screen_log}    OperatingSystem.get file    /home/ute/robotws5g/Ajay/CB008934/enable_feature.txt
    should contain    ${screen_log}    Destination Host Unreachable
    Log To Console    \n---- BTS resetted ----\n
    SSHLibrary.Close All Connections
    sleep    660

Configuration Reset
    [Documentation]    ... Performing Configuration Reset
    Log To Console    \n---- Going to Perform Configuration Reset ----\n
    sbts.reset_configuration
    ...    remove_operator_certificates=false
    ...    remove_user_account_credentials=false
    ...    timeout=500
    ...    connection=oam
    ...    detailed_output=false
    Log to Console    \n---- Configuration Reset Done ----\n
    sleep    150


Upgrade Software
    [Documentation]    ... Upgrading Software To Trunk Build
    Log To Console    \n---- Starting Software Upgrade ----\n
    sbts.update_software
    ...    sw_package=${SW_PATH}
    ...    should_activate=true
    ...    should_reset_radios=true
    ...    timeout=2700
    ...    connection=oam
    Log To Console    \n---- Software Upgrade Completed ----\n
    sleep    360

Attach NSA UE
    X2AP Link Should be UP
    LTE Attach should be Successful   ${nsa_ue_id1}
    UE Attach should be Successful    ${nsa_ue_id1}

Download SCF
    [Documentation]    ... Downloading SCF
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${EXECDIR}/SCF_Software/${timestamp}_scf.xml
    sbts.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${directory}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    \n---- SCF Downloaded and file name is ${filename} ----\n
    set suite variable    ${filename}


Recommission Site
    [Documentation]    ... Recommissioning The Site
    Log To Console    \n---- SCF with which recommissioning will be done is: ${filename} ----\n
    sbts.perform_commissioning
    ...    scf_file=${filename}
    ...    should_activate=true
    ...    timeout=300
    ...    connection=oam
    ...    skip_parameter_relation_errors=true
    Log To Console    \n---- Site Recommissioned ----\n
    sleep    240


Enable feature
    [Documentation]    ... Enabling CB008934 feature
    sbts.perform_parameter_recommissioning
    ...    connection=oam
    ...    dist_name=MRBTS-1402/MNL-1
    ...    parameter=disableORUHWValidation
    ...    operation=update
    ...    value=false
    ...    should_activate=true
    ...    timeout=420
    Log To Console    \n---- Feature has been Enabled ----\n


Disable feature
    [Documentation]    ... Disabling CB008934 feature
    sbts.perform_parameter_recommissioning
    ...    connection=oam
    ...    dist_name=MRBTS-1402/MNL-1
    ...    parameter=disableORUHWValidation
    ...    operation=update
    ...    value=true
    ...    should_activate=true
    ...    timeout=420
    Log To Console    \n---- Feature has been Disabled ----\n

Change Bandwidth
    [Documentation]    ... Change any parameter
    [Arguments]    ${param_value}    ${dist_name}    ${filter_parameter}    ${abbr_parameter}
    Selenium Connection Open
    selLib.set_parameter_value
    ...    dist_name=${dist_name}
    ...    filter_param=${filter_parameter}
    ...    new_value=${param_value}
    ...    abbr=${abbr_parameter}
    ...    timeout=100
    selLib.validate_plan    timeout=20
    ${hw_error}=    selLib.get_hardware_errors
    ...    timeout=30
    [Return]    ${hw_error}
    sleep    5
    Selenium Connection Close

NetConf Credential
    [Documentation]    ... Entering NetConf Credentials
    Selenium Connection Open
    selLib.continue_after_plug_and_play_modal_appear
    ...    timeout=30
    sleep    10
    ${RMOD}=    selLib.add_oru_account
    selLib.Configure Default Netconf Account    ${RMOD}    xranuser    xran-password    xran-password
    selLib.send netconf configuration
    sleep    10
    Log To Console    \n---- O-RU Default NetConf Credentials Entered ----\n
    sleep    10
    Selenium Connection Close

Load netconf credentials
    Log to console    \n--Loading correct netconf credentials--
    ${correct_credentials}=    Evaluate    ${correct_netconf_credentials}
    admindu.connect_to     host=192.168.255.129       port=443     connection_name=${vdu_connection}
     ...        username=Nemuadmin     password=Nokia@123    secure=True        timeout=300
    ${result}=    admindu.add_netconf_accounts    accounts_info=${correct_credentials}
	...    timeout=60    vdu_connection=${vdu_connection}

Collect Snapshot
    sbts.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    timeout=300
    ...    connection=oam
    Log To Console    \n---- Snapshot collected and saved on path ${snapshot_file_path} ----\n

Stop Alarms
    [Documentation]    ... Stop Watching Alarms
    alarms.stop_watching_alarms

Load CFG Config And Verify cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    ${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
#    Start Log   btslog    cprt
    Start WTS Using WTS_Runner      ${wts_cfg_file}
#    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
#    set suite variable    ${cprt_log}
#    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup_sys
#    set suite variable    ${cell_sys_log}

Validate DL UL Traffic For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}   ${QFI_ID}   ${rate}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${rate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    Run Keyword and Ignore Error   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=${rate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}

Validate DL UL Throughput For UE
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}   ${QFI_ID}   ${dlrate}   ${ulrate}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=${dlrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}
    Run Keyword and Ignore Error   Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=${ulrate}   pdu_id=${Pdu_session_ID}    qfi_id=${QFI_ID}


Check gNB Bulid
    ${aliasGNB}                     OAM Connect                             ${AIRSCALE_GNB.oam}
    ${GNB_SW_VERSION}               OAM Get SW Version                      oam=${AIRSCALE_GNB.oam}
    Set Suite Variable    ${GNB_SW_VERSION}
    ${Branch_22R1}    Run Keyword and Return Status   Should Contain    ${GNB_SW_VERSION}     22R1
    Set Suite variable   ${Branch_22R1}

UE Register should be Success
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    wtsrunner.set_pdu_param     ue=${ue_id}    pdu=${pdu_id}    trf_type=internal   log_traffic_stats=off
    wtsrunner.ue_register   id=${ue_id}    nwslice=${nw_id}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Log to Console    ---> ${UE_register_complete_pattern}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister   ${output}
    wtsrunner.ue_pdu_session_setup    pdu=${pdu_id}    ue=${ue_id}    nwslice=${nw_id}    gw=${gw_id}
    Read WTS Output For Pattern And Print matching Lines    ${Initial_context_setup_pattern}    ${Timeout_SA}
    BuiltIn.Log                first_ue_register_is_ok
    [Return]      ${output}

Trigger DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...    mbps=${dl_rate}   ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink Internal traffic    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP DL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger UL Traffic SA
    [Arguments]    ${ue_id}     ${ul_rate}       ${pdu_id}=${Pdu_session_ID}     ${trf_id}=${TRF_ID}      ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the UL Traffic for the SA variant
   # Log to Console    \nRunning UL Traffic for ${ul_rate} ${Traffic_rate}...
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul  trf_id=${trf_id}   protocol=udp   ack_mode=off  cl_trf_stats=on
    ...   mbps=${ul_rate}    ack_mode=off  cl_trf_stats=on
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink Internal traffic*    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    UDP UL TRF:    partial_match=${TRUE}
    Log to Console    ${output}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3




Verify Bearer Delete for all cells
    [Arguments]      ${logpath}       ${filter_req}
    [Documentation]      this KW Verifies the bearer delete is seen
    log to console       Verifying BearerDeleteReq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${bearer_rel}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_bearerdeletereq
    ...                                                path=.*drbScellDeletionInd$
    ...                                                endPacket=${1}
    Should Contain    ${bearer_rel}    0




Modify NIDD parameters
    [Documentation]     This Keyword modify NIDD parameter as per the requirement of the feature CB005788
    [Arguments]        ${paramDst}='None'                  ${operation}=update
     ...                ${paramName}='None'                 ${paramValue}='None'
    Log to Console      Modifying NIDD parameters
    admin.Setup admin
    Online NIDD parameter change    paramDst=${paramDst}        operation=${operation}
    ...          paramName=${paramName}         paramValue=${paramValue}
    sleep               60s
    [Teardown]          admin.Teardown admin


Verify Initial Context Response
    [Arguments]    ${output}
    [Documentation]    This keyword checks the Initial Context Response  message in  UE Registration
    ...                in the output file for the SA variant
    Should Contain    ${output}    ${Initial_context_setup_pattern}    ignore_case=True
    Print Matching Lines from Output File    ${output}    ${Initial_context_setup_pattern}


Verify PDU Session resoruce setup response
    [Arguments]    ${output}    ${ue_id}     ${pdu_session_id}
    [Documentation]    This keyword checks the PDU Session resoruce setup response without ICS
    ...                in the output file for the SA variant
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     UE-${ue_id}.*\\n.*PDU SESSION ID-${pdu_session_id} setup/reestablishment complete

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Multiple NSA UE Register
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR     ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         LTE Attach should be Successful    ${ue_id}
         UE Attach should be Successful     ${ue_id}
    END

Multiple NSA UE start and validate DL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  5s
         Validate DL Traffic For NSA     ${ue_id}     ${dl_rate}
    END

Multiple NSA UE start and validate UL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
         sleep  5s
         Validate UL Traffic For NSA     ${ue_id}     ${dl_rate}
    END

Multiple NSA UE Detach
    [Arguments]    ${first_ue_id}    ${last_ue_id}
    FOR   ${ue_id}   IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         UE Detach should be Successful    ${ue_id}
    END

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   Get GNB Swconfig File    ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt

Add new LTE Bearer
    [Arguments]    ${ue_id}   ${bearer_id}    ${precedence}
    wtsrunner.bearer_add    ue=${ue_id}   id=${bearer_id}  filter=0  precedence=${precedence}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_Bearer_creation_success}    ${10}
    Print Matching Lines from Output File    ${output}    ${LTE_Bearer_creation_success}
    Log to console    New LTE Bearer addition is Success

ENDC Modify for Bearer Addition
    [Arguments]    ${ue_id}   ${bearer_id}    ${cause}=RN_CauseRadioNetwork_unspecified
    wtsrunner.enb_ue_dc_modify   ue=${ue_id}   bearer_to_add=${bearer_id}   by=enb   cause=${cause}
    ${output}    Read WTS Output Until Pattern Matches    ${ENDC_Sgnb_modification}    ${10}
    Print Matching Lines from Output File    ${output}    ${ENDC_Sgnb_modification}
    Log to console    ENDC Modify for Bearer Addition Success

Wait for UE to go to INACTIVE state
    [Arguments]       ${inactivity_timer}
    Log to Console          Wait ${inactivity_timer}s for UE to move inactive state
    sleep   ${inactivity_timer}s
    sleep   30s       #add extra delta

Trigger RRC Re-establishment
    [Arguments]    ${ue_id}   ${cell_id}
    wtsrunner.ue_rrc_reestablish    id=${ue_id}     cell=${cell_id}
    sleep    2s


Collect and Store PM Counter Files
    Log to Console     Collecting PM Files
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    [Return]    ${PM_dir1}


Trigger High DL Traffic for NSA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${dl_rate}    ${bearer_id}
    [Documentation]    This keyword starts the DL Traffic for the SA variant for higher data rate
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//165
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%165
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
        Run Keyword if    ${loop}==0    Trigger DL Traffic For NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=${dl_rate_reminder}     id=${bearer_id}   trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger DL Traffic For NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   dl_rate=165     id=${bearer_id}    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Trigger High UL Traffic for NSA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${ul_rate}      ${bearer_id}
    [Documentation]    This keyword starts the UL Traffic for the SA variant for higher data rate
    ${ul_rate_loop}=      Evaluate      ${ul_rate}//165
    ${ul_rate_reminder}=     Evaluate      ${ul_rate}%165
    ${ul_rate_loop}=      Evaluate     ${ul_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${ul_rate_loop}
        Run Keyword if    ${loop}==0    Trigger UL Traffic for NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=${ul_rate_reminder}     id=${bearer_id}   trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger UL Traffic for NSA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=165     id=${bearer_id}    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Multiple NSA UE start DL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${dl_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger DL Traffic for NSA     ${ue_id}    mbps   ${dl_rate}
    END

Multiple NSA UE start UL Traffic
    [Arguments]    ${first_ue_id}    ${last_ue_id}    ${ul_rate}
    FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
         Trigger UL Traffic for NSA     ${ue_id}    mbps   ${ul_rate}
    END

Validate DL UL Throughput For NSA UE
    [Arguments]    ${UE_ID}   ${bearer_id}    ${dlrate}   ${ulrate}
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=${dlrate}   id=${bearer_id}
    Run Keyword and continue on Failure   Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=${ulrate}   id=${bearer_id}

Send A1 Measurement for Scell Addition
    [Arguments]    ${ue_id}   ${meas_id}    ${srsrp_nr}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr   id=${ue_id}    meas_id=${meas_id}   event=A1  srsrp_nr=${srsrp_nr}   phycell_id=${phycell_id}

Trigger High DL Traffic SA
    [Arguments]    ${ue_id}      ${dl_rate}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the DL Traffic for the SA variant
    ${dl_rate_loop}=      Evaluate      ${dl_rate}//175
    ${dl_rate_reminder}=     Evaluate      ${dl_rate}%175
    ${dl_rate_loop}=      Evaluate     ${dl_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${dl_rate_loop}
    #Log to Console    \nRunning DL Traffic for ${dl_rate} ${Traffic_rate}...
            Run Keyword if    ${loop}==0       wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=${dl_rate_reminder}   ack_mode=off  cl_trf_stats=on
            Run Keyword if    ${loop}>0        wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=dl
            ...     trf_id=${TRF_ID}   protocol=udp   ack_mode=off  cl_trf_stats=on    mbps=175   ack_mode=off  cl_trf_stats=on
            ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END
    BuiltIn.Log    DL_traffic_data_is_started_successfully

Trigger High UL Traffic SA
    [Arguments]    ${ue_id}      ${ul_data}     ${pdu_id}=${Pdu_session_ID}     ${qfi_id}=${QFI_ID}
    [Documentation]    This keyword starts the \UL Traffic for the SA variant
    ${TRF_ID}=   Set Variable   1
    wtsrunner.trf_data_start   ue=${ue_id}  pdu=${pdu_id}   qfi=${qfi_id}  dir=ul   trf_id=${TRF_ID}   protocol=udp    mbps=${ul_data}
    BuiltIn.Log    UL_traffic_data_is_started_successfully

Validate UE beamid from TTI traces
    [Arguments]   ${csv_file_path}   ${rnti}    ${beamid}
    ${Check}  Verify Rnti ueBamid    ${csv_file_path}/output_dl_formated.csv      ${rnti}   ${beamid}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Beamid is not matching


Detach UE
    [Arguments]      ${st_ue_id}    ${en_ue_id}
    [Documentation]    detach the UE
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

Increase DL data and verify scell activation
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}    ${varg_expected_thp}
    FOR    ${trf_id}    IN RANGE    3    ${trf_id_num}
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END
    sleep  30s
    Verify DL THP For pcell_scells    ${st_ue_id}    ${en_ue_id}     ${varg_expected_thp}

Validate THP and Dettach UE
    [Arguments]      ${UE_ID}    ${st_ue_id}    ${en_ue_id}      ${dl_thp}    ${ul_thp}
    [Documentation]    This KW validates the throughput in DL and UL and dettach the UE
    Run Keyword And Continue on Failure    Validate DL Traffic For SA   ue_id=${UE_ID}      dl_rate=${dl_thp}
    ...    qfi_id=${QFI_ID}
    Run Keyword And Continue on Failure    Validate UL Traffic For SA   ue_id=${UE_ID}      ul_rate=${ul_thp}
    ...    qfi_id=${QFI_ID}
    Detach UE     ${st_ue_id}    ${en_ue_id}

Verify DL THP for single cell config
    [Arguments]   ${st_ue_id}        ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	0
	log to console   ${exp_dl_thp}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}

Verify DL THP for two cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    Verify DL THP for single cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	1
	log to console   ${exp_dl_thp}
	${scell_idx} =	Evaluate      ${scell_idx}+1
	log to console   ${scell_idx}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}

Verify DL THP for three cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    Verify DL THP for two cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	2
	log to console   ${exp_dl_thp}
	${scell_idx} =	Evaluate      ${scell_idx}+2
	log to console   ${scell_idx}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}

Verify DL THP for four cell config
    [Arguments]   ${st_ue_id}    ${en_ue_id}      ${scell_idx}      ${expected_thp}
    Verify DL THP for three cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
    ${exp_dl_thp} 	Collections.Get From List	${expected_thp}	3
	log to console   ${exp_dl_thp}
	${scell_idx} =	Evaluate      ${scell_idx}+3
	log to console   ${scell_idx}
    ${pcell_thp}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${st_ue_id}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${pcell_thp} > ${exp_dl_thp}


Verify UL THP for single cell config
    [Arguments]   ${UE_ID}      ${scell_idx}      ${ul_thp}
    ${ulcell_thp}=    Get AVG UL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=${scell_idx}    unit=Mbps
    Should Be True    ${ulcell_thp} > ${ul_thp}


Verify UL THP for 2 cell config
     [Arguments]    ${UE_ID}  ${expected_pcell_thp}    ${expected_scell_thp}
     [Documentation]    This KW validates the UL data in Pcell and scell in 2CC scenario
        ${pcell_thp}=    Get AVG UL DATA TRAFFIC For Given CC
        ...    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
        ${scell_thp}=    Get AVG UL DATA TRAFFIC For Given CC
        ...    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
        Run Keyword And Continue on Failure     Should Be True    ${pcell_thp} > ${expected_pcell_thp}
        Run Keyword And Continue on Failure     Should Be True    ${scell_thp} > ${expected_scell_thp}


Verify DL THP For pcell_scells
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${varg_expected_thp}
    [Documentation]    This KW takes 3 parameters as argument.
    ...                The 3rd argument is a list which consist of first parameter SA/NSA (sa_flag: 1 means SA, 0 means NSA),
    ...                second parameter used to get how many component carriers are used (cc_count: 1 --> 1CC only pcell stats
    ...                are needed, 2 --> 2CC, pcell and one scell ). Third parameter will represent expected_dl_thp
    ...                for pcell, 4th argument in list will represent expected_dl_thp for scell_1 , 5th argument in
    ...                list will represent expected_dl_thp for scell_2 and so on.
    ...                cc_count and number of expected_dl_thp passed should mathc. Otherwise this KW will fail
    ${sa_flag}    Get From List	   ${varg_expected_thp}	0
    ${cc_count}    Get From List	   ${varg_expected_thp}	1
	${expected_thp}    Get Slice From List	${varg_expected_thp}	2
	log to console    ${expected_thp}
	${numofexpthp}    Get length    ${expected_thp}
	Should Be Equal As Integers    ${numofexpthp}    ${cc_count}
    ${scell_idx} =	Set Variable If	'${sa_flag}' > '0'      0      8
    log to console    ${scell_idx}
	Runkeyword IF   ${cc_count}==4    Verify DL THP for four cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
	...   ELSE IF   ${cc_count}==3    Verify DL THP for three cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
	...   ELSE IF   ${cc_count}==2    Verify DL THP for two cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}
	...   ELSE IF   ${cc_count}==1    Verify DL THP for single cell config    ${st_ue_id}    ${en_ue_id}    ${scell_idx}      ${expected_thp}

Attach SA Ue and start low DL data
    [Arguments]    ${st_ue_id}    ${en_ue_id}    ${trf_id_num}    ${varg_expected_thp}
    log to console   UE attach trigerring now...
    ${crnti_list}=     MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    set test variable      ${crnti_list}
    sleep  10s
    FOR    ${trf_id}    IN RANGE    1    ${trf_id_num}
        MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     dl_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
        MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=mbps     ul_rate=175
        ...    pdu_id=${Pdu_session_ID}    trf_id=${trf_id}       qfi_id=${qfi_id}
    END
    sleep  20s
    Verify DL THP For pcell_scells    ${st_ue_id}    ${en_ue_id}    ${varg_expected_thp}

#Update GNB R&D Parameter
#   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
#   Get GNB Swconfig File    ${LOG_PATH}
#   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
#   Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt
