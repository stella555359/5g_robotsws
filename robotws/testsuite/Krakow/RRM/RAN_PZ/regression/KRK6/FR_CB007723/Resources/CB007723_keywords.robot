*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1MODIFY_SCF_COMMON
...   migrated to krk by klaudia.horyn@nokia.com

Library     taf.analyzer.pcap                                                                              WITH NAME    pcap
Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py                                 WITH NAME    scd
Library     testsuite/Krakow/RRM/RAN_PZ/resources/pcap_verification/flow_verifier.py                       WITH NAME    flow_verifier
Library     ute_ue                                                                                         WITH NAME    ue
Library     DateTime                                                                                       WITH NAME    dt
Library     taf.rfrl.ue.ute_ue_config.UteUeConfig                                                          WITH NAME    uteueconfig
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations                                      WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.du.commissioning.EnbCommissioning                                         WITH NAME    enbscf
Library     taf.rfrl.utilities.test_config.DefaultFileLocation                                             WITH NAME    dfl
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/resources/collect_logs.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   ./CB007723_deltas.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${current_config}    CB007723

*** Keywords ***
Suite Setup
    Log To Console    Suite Setup
    ${HOSTNAME}=    taf.rfrl.utilities.tl_config.Get Testline Name
    ${RELEASE}=     dfl.Get Commissioning Branch
    &{abstract_lib_config}=    uteueconfig.Get Ute UE Configuration Dict
    Set Suite Variable    ${HOSTNAME}
    Set Suite Variable    ${RELEASE}
    Set Suite Variable    ${abstract_lib_config}
    Upload SCF Commisson And Wait OnAir    prefix_tag=${current_config}

Upload SCF Commisson And Wait OnAir
    [Arguments]  ${prefix_tag}
    [Documentation]  Upload scf file on gnb.
    ...    :param prefix_tag:  prefix used to select SCF for comissoning
    Perform Full Commissioning On Classical gNB    prefix_tag=${prefix_tag}    awaiting_time=240
    Wait Until Keyword Succeeds     600 sec     30 sec   Verify gNB is onAir

Common Test Teardown
    Log To Console    Common Test Teardown
    Run Keyword And Ignore Error    ue.Detach Ue    UE_1
    scd.Verify Sleeping Cell Detection
    Common Postconditions

Test Setup
    [Arguments]    ${scf_prefix_tag}
    [Documentation]    Common test setup.
    ...                :param scf_prefix_tag: Prefix of scf file which should be load.
    Log To Console    Test Setup
    Run Keyword If    '${current_config}'!='${scf_prefix_tag}'    Run Keywords
    ...    Upload SCF commisson and wait onAir  prefix_tag=${scf_prefix_tag}    AND
    ...    Set Suite Variable    ${current_config}    ${scf_prefix_tag}
    ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Download gNB Configuration File    local_dir=${OUTPUT DIR}
    Run Keyword And Ignore Error    scd.Enable Sleeping Cell Detection Feature
    scd.Start Sleeping Cell Detection Watchdog       log_dir=${LOG_PATH}/SleepingCell

Deactivate CarrierAggregation
    Change Parameter On DU   value=none  internal_dist_name=MRBTS-78005/NRBTS-78005  name=caConfigurationSupport
    Log To Console   Change of parameter caConfigurationSupport to none value has been successful
    Verify gNB Is OnAir

Activate CarrierAggregation
    Change Parameter On DU    value=8CCDL_4CC UL  internal_dist_name=MRBTS-78005/NRBTS-78005  name=caConfigurationSupport
    Log To Console   Change of parameter caConfigurationSupport to 8CCDL_4CC UL value has been successful
    Verify gNB Is OnAir

Change Parameter On DU
    [Arguments]    ${value}  ${internal_dist_name}  ${name}  ${operation}=update
    [Documentation]     This keyword change selected parameter on gNB
    ...     :param value: value for parameter which will be set
    ...     :param internal_dist_name: distinguisive name for parameter which will be change
    ...     :param parameter name: name of parameter which will be change
    Perform Configuration Parameter Recommissioning On gNB
    ...  dist_name=${internal_dist_name}
    ...  param_name=${name}  param_value=${value}  skip_parameter_relation_errors=true  operation=${operation}
    ...  timeout=300
     Wait Until Keyword Succeeds    7min    10s    Verify Setup Of All Cells    gnb_id=0    du_id=${0}    cell_type=nr

Attach UE
    [Arguments]    ${desired_5g_cell_pci}
    [Documentation]    The keyword perform attach EN-DC and checks if attach was performed to desired cell 5G.
    ...                :param desired_5g_cell_pci:    Physical cell ID of expected 5G cell to be added as PSCell
    Log To Console    Attach UE
    ${date}=    dt.Get Current Date   exclude_millis=True    result_format=%d.%m.%Y.%H.%M
    ${pcap_name}=  Set Variable    UE_attach-${date}.pcap
    Set Suite Variable     ${pcap_name}
    Start Tcpdump     filename=${pcap_name}
    ue.Attach UE   UE_1
    Stop Tcpdump On CU And Download Logs    filename=${pcap_name}
    Verify NSA Flow Pcap   ${pcap_name}   ${desired_5g_cell_pci}
    [Teardown]    Run Keyword And Ignore Error    Stop tcpdump

Stop Tcpdump
    Sleep   3 s    reason=Wait a while before stopping the logs
    ${alias}=        Connect To gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.execute
    ...              command=killall tcpdump
    ...              connection=${alias}
    ...              ELSE
    ...              ssh.execute
    ...              command=sudo killall tcpdump
    ...              connection=${alias}

Start Tcpdump
    [Arguments]   ${filename}=${test_name}.pcap   ${interface}=any   ${sleep_after_start_s}=3
    ${alias}=    Connect To gNB
    Run Keyword If   '${BTS_TYPE}' == 'ClassicalBts'
    ...              ssh.send_command    command=tcpdump -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    ...              ELSE
    ...              ssh.send_command    command=sudo tcpdump -i ${interface} -w "/tmp/${filename}"   connection=${alias}
    Sleep   ${sleep_after_start_s} s   reason=Wait a while after the log starts

Verify NSA Flow Pcap
    [Arguments]   ${pcap_file}   ${5g_pci}
    [Documentation]    The keyword checks if attach was performed successfully. The keyword checks attach messages
    ...                in pcap file.
    ...                :param pcap_file:     name of pcap file with extension
    ...                :param 5g_pci:        Physical cell ID of expected 5G cell to be added as PSCell
    ${pcap_file} =   Set Variable   ${LOG_PATH}/${pcap_file}
    ${attach_expected_messages} =    Create List
    ...    SgNBAdditionRequest    SgNBAdditionRequestAcknowledge(contains(physCellId=${5g_pci}))
    ...    SgNBReconfigurationComplete    SNStatusTransfer
    Expect Messages In Flow    awaited_messages=${attach_expected_messages}   pcap_file=${pcap_file}
    ${rach_fail} =    Check If Message Is In Flow
    ...    awaited_message=SgNBModificationRequest(contains(scgFailureInfo))  pcap_file=${pcap_file}
    Run Keyword If   ${rach_fail}       Fail   msg=SCG Failure occured
    ${sgnb_release} =    Check If Message Is In Flow
    ...    awaited_message=SgNBReleaseRequest  pcap_file=${pcap_file}
    Run Keyword If   ${sgnb_release}    Fail   msg=SgNB Release occured

Start Streams For DL And UL Data Transmission For Specified Time For UDP
    [Arguments]    ${data_transfer_time}    ${ul_throughput}     ${dl_throughput}
    [Documentation]    Keyword starts UDP traffic transmision for specified time.
    ...                Traffic is performed in uplink and downlink directions.
    ...                :param data_transfer_time:    data trasmission's time in seconds
    ...                :param ul_throughput:    level of throughput in uplink direction
    ...                :param dl_throughput:    level of throughput in downlink direction
    ...                :protocol:    protocol type tcp/udp
    Log To Console    Start DL and UL data transmission for specified time
    ue.Start Data Transfer    dt_name=DT_1_UL    ue_alias=UE_1
    ...                 direction=ul    duration=${data_transfer_time}s    protocol=udp   throughput=${ul_throughput}
    ...                 packet=1320    buffer_client=4M
    Sleep    2s   reason=Wait a while to start DL traffic
    ue.Start Data Transfer    dt_name=DT_1_DL    ue_alias=UE_1
    ...                  direction=dl    duration=${data_transfer_time}s    protocol=udp   throughput=${dl_throughput}
    ...                  packet=1320    buffer=4M
    Sleep    1s    reason=Wait a while to stabilize throughput

Await DL And UL Data Transmission Finish
    Log To Console    Await DL and UL data transmission finish
    ue.Await Data Transfer Finish    DT_1_UL
    ue.Await Data Transfer Finish    DT_1_DL

Verify DL And UL Data Transmission Loss For UDP
    [Arguments]    ${deviation}=5
    [Documentation]    Keyword checks if throughput datagram loss is below max_allowed_datagram_loss parameter value.
    ...                Checking is performed in uplink and downlink directions.
    ...                :param deviation:   max allowed data loss value in percentage, e.g: '25' for 25%
    Log To Console    Verify DL and UL data transmission loss
    ue.Verify Average Throughput With Deviation    dt_name=DT_1_DL    tput=100000000 bits/sec    deviation=${deviation}%
    ue.Verify Average Throughput With Deviation    dt_name=DT_1_UL    tput=20000000 bits/sec    deviation=${deviation}%
    ${avg_UL_tput}=      ue.Get Average Throughput   DT_1_UL
    Log To Console   Average UL TPUT: ${avg_UL_tput} Mbps
    ${avg_DL_tput}=      ue.Get Average Throughput   DT_1_DL
    Log To Console   Average DL TPUT: ${avg_DL_tput} Mbps

Stop DL And UL Data Transmission
    Log To Console    Stop DL and UL data transmission
    ue.Stop Data Transfer    dt_name=DT_1_UL
    ue.Stop Data Transfer    dt_name=DT_1_DL

Specify NR Cell For Dual Connectivity
    [Arguments]    ${lnrelgnbcell_instance}
    enbscf.Perform Configuration Parameter Recommissioning    operation=update    bts_id=0    du_id=${0}
    ...    dist_name=MRBTS-78004/LNBTS-78004/LNCEL-1
    ...    parameter=defaultLnRelGnbCellId   value=${lnrelgnbcell_instance}
    ...    skip_parameter_relation_errors=${false}    should_activate=${true}    timeout=${120}

Check SSB And CSI-RS From X2 Log
    [Arguments]    ${pcap_file}    ${csi-rs-list}=88    ${ssb}='0f:0f:0f:0f:0f:0f:0f:0f'
    [Documentation]    Check specifid trace exists.
    ...    :param  trace_type: The type of trace record data. It could be  Cu / Du
    ${pcap_file} =   Set Variable   ${LOG_PATH}/${pcap_file}
    ${csi-MeasConfig}=    Get Wireshark Value    cap_file=${pcap_file}
    ...    field_name=nr-rrc.slots640
    ...    filter=nr-rrc.csi_MeasConfig == 1
    Should Be True    ${csi-MeasConfig}[0] == ${csi-rs-list}

    ${ssb-PositionsInBurst}=    Get Wireshark Value    cap_file=${pcap_file}
    ...    field_name=nr-rrc.longBitmap
    ...    filter=nr-rrc.ssb_PositionsInBurst == 2
    Should Be True    '${ssb-PositionsInBurst}[0]' == ${ssb}

Get Wireshark Value
    [Arguments]  ${cap_file}    ${filter}    ${field_name}=_3gpp.sfn
    ${cmd}    Set Variable    /usr/bin/tshark -r {pcap_file} -Y \"${filter}\" -T pdml
    pcap.Load Pcap File    command_template=${cmd}    pcap_file=${cap_file}
    ${field_value}=    pcap.Get Field Value By Name    field_name=${field_name}    attribute_name=show
    [Return]  ${field_value}
