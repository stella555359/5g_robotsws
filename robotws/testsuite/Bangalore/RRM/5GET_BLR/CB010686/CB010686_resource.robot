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

Add PDU Session
    [Arguments]   ${start_ue_id}     ${endue_id}    ${pdu_profile}      ${nw_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1

    ute_wtssim.Execute Egate Command   cmd=set_pdu_param ue=${ue_idx} pdu=${pdu_profile} trf_type=internal
    ${add_pdu}     SET VARIABLE    ue_pdu_session_setup pdu=${pdu_profile} ue=${ue_idx} nwslice=${nw_id} gw=${ue_idx}
    sleep   1s
    ${output}       ute_wtssim.Execute Egate Command And Wait For Data   ${add_pdu}
    ...     pass_regexp=PDU SESSION ID-${pdu_profile} setup/reestablishment comple   timeout=60
    END

ADD Multi PDU Session
    [Arguments]     ${start_pdu_id}    ${end_pdu_id}
    FOR     ${pdu_id}   IN RANGE    ${start_pdu_id}    ${end_pdu_id}+1
    Add PDU Session     ${start_ue_id}     ${endue_id}    ${pdu_id}      ${nw_id}
    sleep   1s
    END

Inject PDU Error
     [Arguments]   ${start_ue_id}    ${end_ue_id}    ${pdu_profile}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ${pdu_error}      Set Variable    upf_ue_pdu_inject_error_ind ue=${ue_idx} id=1 pdu=${pdu_profile} abnormal_scenario=none
    sleep   1s
    ute_wtssim.Execute Egate Command And Wait For Data    ${pdu_error}
    ...    pass_regexp=Successfully released PDU Session with ID ${pdu_profile}      timeout=60
    sleep   3s
    END

Inject Multiple PDU Error
    [Arguments]     ${start_pdu_id}    ${end_pdu_id}
    FOR     ${pdu_id}   IN RANGE    ${start_pdu_id}    ${end_pdu_id}+1
    Inject PDU Error    ${start_ue_id}    ${end_ue_id}    ${pdu_id}
    sleep   1s
    END

Multi PDU Traffic
     [Arguments]     ${start_pdu_id}    ${end_pdu_id}     ${ul_rate}      ${dl_rate}
     FOR     ${pdu_id}   IN RANGE    ${start_pdu_id}    ${end_pdu_id}+1
     MultiUE Trigger UL Traffic for SA    ${start_ue_id}  ${endue_id}  Traffic_rate=mbps   ul_rate=${ul_rate}   pdu_id=${pdu_id}   trf_id=1   qfi_id=1
     sleep   1s
     MultiUE Trigger DL Traffic for SA    ${start_ue_id}  ${endue_id}  Traffic_rate=mbps   dl_rate=${dl_rate}   pdu_id=${pdu_id}   trf_id=1   qfi_id=1
     sleep   1s
     END

UE state should be active
    [Arguments]   ${start_ue_id}     ${endue_id}
    FOR     ${ue_idx}   IN RANGE    ${start_ue_id}    ${end_ue_id}+1
    ute_wtssim.Execute Egate Command   cmd=ue_disp id=${ue_idx}     pass_regexp=ACTIVE    timeout=60
    END

Verify Specific PDU Traffic
    [Arguments]    ${ue_idx}    ${pdu}

    ${dl_data}    ute_wtssim.Execute Egate Command    cmd=qfi_stats ue=${ue_idx} pdu=${pdu} qfi=1 dir=dl
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/dl.txt    ${dl_data}
    ${avg}    OperatingSystem.Run    cat /tmp/dl.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average dl tput is: ${mavg}M \n
    Should Be True    ${mavg} > ${140}

Validate error msg in syslog
    [Arguments]     ${file}
    ${Reqmsg}   run     command=sudo cat ${file} | grep -i "Fatal" -m 1
    Builtin.Log   ${Reqmsg}
    ${Req}   Run keyword and return status   Should Be Empty    ${Reqmsg}

Trigger Xn HO and HO Prepration Timeout
    [Arguments]     ${start_ue_id}     ${gnb_id}
    ${cmd}   set variable   gnb_xn_handover_preparation_param id=${gnb_id} action=force_failure time_to_wait=v1s nth=1
    ute_wtssim.Execute Egate Command    ${cmd}
    sleep   1s
    ${cmd1}   set variable   ue_measurement_send_nr id=${start_ue_id} meas_id=1 event=A3 srsrp_nr=1 srsrq_nr=1 phycell_id=52 nrsrp_nr=30 nrsrq_nr=20
    sleep   3s
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data   ${cmd1}
    ...     pass_regexp=HandoverPreparationFailure for XnHANDOVER_REQUEST   timeout=60
    sleep   1s



