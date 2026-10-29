*** Settings ***
Variables    ta5g_global_var

Documentation
...				Keyword resources

Resource          ./../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Library        ../resources/NPS/SWENG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
#Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
#Library        taf.collectors.core   WITH NAME   CORE
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
#Library         ./python/increase_buffer_size.py
Resource        ../resources/robot/wts_sim_keywords.robot


*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3    4   5   6   7   8   9   10  11  12  13  14  15

*** Keywords ***

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}
    Fetch board type
    Configure UTE ETH3 IPs
    Wait Until Keyword Succeeds    5min    20sec     Check gNB Airscale is Ready - ${BBoard_Type}
    ${oam_alias}=    Setup OAM session
    Wait Until Keyword Succeeds    10min    20sec    Verify Single Radio is Online      connection=${oam_alias}
    #${file_name}    set variable     NODECPRT_GNB_cellsetup.pcap
    Check gNB Airscale is Ready - ${BBoard_Type}

    Log To console     loading cfg file
    Start Log   btslog    cprt
    Start WTS Using WTS_Runner and collect SIB1 output     ${wts_cfg_file}
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    set suite variable    ${cprt_log}
    ${cell_sys_log}     Stop Log   btslog   test_scenario=cellsetup
    set suite variable    ${cell_sys_log}

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

Start WTS Using WTS_Runner and collect SIB1 output
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    ${sib1_output}      wtsrunner.read_wtsemu_output_until_re    expected=cell 1: SystemInformationBlockType1-NR updated     timeout=400
    Set Suite Variable     ${sib1_output}
    sleep    60s
    Create File      /home/ute/sib_output.txt       ${sib1_output}
    Log to Console    Cell onair successful
    [Return]    ${sib1_output}

Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Drop Xn Link
    [Arguments]     ${target_gNB}
    ute_wtssim.Execute Egate Command   cmd=link_drop link=xn by=gnb:${target_gNB} to=gnb:2

Establish Xn Link To gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    ute_wtssim.Execute Egate Command    cmd=gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true
    sleep   5
    ute_wtssim.Execute Egate Command     cmd=gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   10s

Check If Alarm Appeared
    [Documentation]    This keyword checks if an alarm with the specified fault ID appeared and fetches additional information.
    [Arguments]    ${fault_id}
    COAM.Setup Admin    timeout=120
    @{alarm_history}=    COAM.Get Active Alarms
    ${alarm_found}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId
        ${contains_faultid}=    Run Keyword And Return Status
        ...    Should Be Equal As Strings    ${alarm_fault_id}    ${fault_id}
        Run Keyword If    ${contains_faultid}
        ...    Should Contain    ${alarm}    destinationIPAddr
        Run Keyword If    ${contains_faultid}
        ...    Should Contain    ${alarm}    supplAlarmInfo
        Run Keyword If    ${contains_faultid}
        ...    Exit For Loop
    END
    Run Keyword If    not ${contains_faultid}
    ...    Fail    Alarm with fault ID ${fault_id} did not appear.
    BuiltIn.Log   Alarm Found: ${fault_id}, Destination IP: ${alarm['destinationIPAddr']}, Supplementary Info: ${alarm['supplAlarmInfo']}
    [RETURN]    ${fault_id}     ${alarm['destinationIPAddr']}       ${alarm['supplAlarmInfo']}
