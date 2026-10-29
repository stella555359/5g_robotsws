*** Settings ***
Documentation
...   Keywords for feature CB010576
...   author: Wioleta Swies
...   contact: wioleta.swies@nokia.com

Library      taf.sbts.oam.coam.admin  WITH NAME  SbtsAdmin
Library      taf.ue    WITH NAME    ue
Library      taf.collectors.tcpdump    WITH NAME    tcpdump
Library      taf.transport.ssh  WITH NAME  ssh
Library      ./tools.py
Library      ta_a2a
Library      testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    sg7keywords
Resource     taf/rfrl/bts/robot/enb.robot
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
# -----------------------------UE-----------------------------
${capabilities}                         REAL_UE
${alias}                                UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${deviation_dl}                         90%
${duration}                             230s
${parallel_streams_dl}                  1
${reboot_ue}                            False
${size_packet_dl}                       1400B
${timeout_reboot_ue}                    100
${tput_dl}                              514 Mbits/sec
${qci}                                  None
${protocol}                             udp
${clear_source_dir}                     False
${CONNECTION_ALIAS}                     gnb

${FLAGS}                                ether[0x20:2]==0xe24d or ether[0x20:2]==0xe113 or ether[0x20:2]==0xe110 or ether[0x20:2]==0xe10f or
...                                     ether[0x20:2]==0xe118 or ether[0x20:2]==0xe226 or ether[0x20:2]==0xe24c or ether[0x20:2]==0xe251 or
...                                     ether[0x20:2]==0xe20b or ether[0x20:2]==0xe24b or ether[0x20:2]==0xe231 or ether[0x20:2]==0x0198 or
...                                     ether[0x20:2]==0xe239

&{mirroring_script_params}=             number_of_files=${5}    file_size_mbytes=${500}    filter=${FLAGS}    filtering=on
${MRBTS_ID}                             ${tl.gnbs[0].instance_id}
${BEAM_INDEX_LENGTH}                    10
&{LOAD_INFO_DICT}                       totalLoad=100    mcsIndex=0
${numOfBitsOfUciInformation}            29
${numOfPrb}                             16

*** Keywords ***
Verify L3 Call Traffic DL Only
    [Arguments]    ${duration}=230s    ${anp}=${None}    ${change_apn}=${True}
    Prepare Ue    capabilities=REAL_UE    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}    alias=${alias}
    ue.Attach Ue    ${alias}

    Run Keyword If    ${change_apn} == ${True}   Change Apn    ${alias}    ${anp}
    ...                                             apn_switcher_widget=android.widget.RadioButton
    ...                                             labels_to_apn_settings=Connections,Mobile networks,Access Point Names
    Start Multi Data Transfer DL and Verify Troughput    duration=${duration}    apn_name=${anp}    tput_dl=${tput_dl}
    ...    protocol=${protocol}    deviation_dl=${deviation_dl}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    size_packet_dl=${size_packet_dl}

    [Teardown]    Run Keywords    ue.Detach UE    UE    AND
    ...                           ue.Stop Using UE    UE

Prepare Ue
    [Arguments]    ${capabilities}=REAL_UE    ${reboot_ue}=${False}    ${timeout_reboot_ue}=100  ${alias}=UE
    ue.Require Ue    ${alias}    capabilities=${capabilities}
    ue.Detach Ue     ${alias}
    Run Keyword If  ${reboot_ue}    ue.Reboot Ue    ${alias}    timeout=${timeout_reboot_ue}

Start Multi Data Transfer DL and Verify Troughput
    [Arguments]    ${duration}    ${apn_name}    ${tput_dl}    ${protocol}=udp   ${parallel_streams_dl}=1
    ...    ${size_packet}=1400B    ${deviation}=25%     ${deviation_dl}=${deviation}
    ...    ${size_packet_dl}=${size_packet}
    ...    ${clear_source_dir}=${False}
    [Documentation]    Data Transfer DL and UL, Verification Average Troughput
    ...     :param duration:               Duration of transmision, exaple: 600s
    ...     :param tput_dl:                Expected tput for DL, example 100 Mbits/sec
    ...     :param protocol:               udp or TCP
    ...     :param deviation:              Percentage of deviation in tput, example: 25%
    ...     :param size_packet:            Parameter -l for UDP and -M for TCP in iPerf
    ...     :param clear_source_dir:       Clear logs source directory

    ue.Start Data Transfer    dt_name=DT_DL_1
    ...                       ue_alias=UE
    ...                       direction=dl
    ...                       duration=${duration}
    ...                       packet=${size_packet_dl}
    ...                       throughput=${tput_dl}
    ...                       protocol=${protocol}
    ...                       parallel_streams=${parallel_streams_dl}
    ...                       port=5007
    ...                       apn=${apn_name}
    Sleep    10s
    ue.Check Data Transfer is Alive     dt_name=DT_DL_1
    ue.Await Data Transfer Finish       dt_name=DT_DL_1

    ue.Verify Average Throughput With Deviation   dt_name=DT_DL_1   tput=${tput_dl}   deviation=${deviation_dl}

    [Teardown]  Run Keyword If  ${COLLECT_LOGS_DURING_DATA_TRANSFER}  Download logs from gNB    sub_dir=data_transfer
    ...    clear_source_dir=${clear_source_dir}

Catch Tcpdump During BBomd Reset
    ssh.Connect To    hostname=192.168.255.129   username=toor4nsn
    ...    password=oZPS0POrRieRtu    alias=${CONNECTION_ALIAS}
    ssh.Send Command    command=tcpdump -i any -C 100 -vv -w /tmp/${TEST_NAME}.pcap sctp
    ...                 connection=${CONNECTION_ALIAS}
    gnbbbu.Reset Bbmod
    Sleep    20s
    Wait Until Keyword Succeeds    600 sec    5 sec   gnbcell.Verify All Cells Are Onair

    Kill Tcpdump On Du Site
    ssh.Download File   remote_path=/tmp/${TEST_NAME}.pcap
    ...                 local_path=${LOG_PATH}/${TEST_NAME}.pcap
    ...                 connection=${CONNECTION_ALIAS}
    [Return]    ${LOG_PATH}/${TEST_NAME}.pcap

Kill Tcpdump On Du Site
    ssh.Execute    command=killall tcpdump
    ...            connection=${CONNECTION_ALIAS}

Load and Activate SCF and Wait for OnAir
    [Arguments]    ${scf_file_name}
    ${SCF_PATH}    sg7keywords.Get Default Scf Path     file_name=${scf_file_name}
    Log to console   SCF PATH: ${SCF_PATH}
    Perform Full Commissioning on Classical gNB    scf_path=${SCF_PATH}
    Sleep    180s
    Wait Until Keyword Succeeds    20min    20s    gnbcell.Verify All Cells Are Onair
