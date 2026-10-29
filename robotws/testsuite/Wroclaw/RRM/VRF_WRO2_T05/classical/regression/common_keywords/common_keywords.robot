*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library     OperatingSystem
Library     taf.transport.ssh      WITH NAME   csn
Library     taf.collectors.l1l2bip
Library     taf.ue    WITH NAME   ute_ue
Library     SSHLibrary    WITH NAME    robssh
Library     taf.ccs.aashell  WITH NAME  ah  #CNI-68640   https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1311145579
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.scf     WITH NAME  scf
Library     taf.hw.pdu     WITH NAME  hw_pdu
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_kw.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/admin/DeltaStore.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/admin/AdminHelper.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.bip_log.L1L2  WITH NAME  bip_mirroring
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/rude/rude_kw.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/phase_shifter/ps.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/orbis/positioner.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/reporting_portal.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Keywords ***

Reserve UEs MTK For tests
    Require Ue    UE_1    capabilities=REAL_ANDROID_UE_NSA
    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA
    # Require Ue    UE_3    capabilities=REAL_ANDROID_UE_SA_NSA

Attach UE SA For test
    sleep  5s
    Start tracing on SMOD
    # Start L1L2 Logs
    sleep  5s
    Attach Ue   UE_2
    ${CELL_ID}=    ute_ue.Get Ue Info    UE_2   IP
    Stop tracing and download logs from SMOD
    Log to console  ${CELL_ID}
    # [Teardown]    Stop L1L2 Logs And Download PCAP   ue_mode=Attach_SA

Attach UE NSA For test
    sleep  5s
    Start tracing on SMOD
    # Start L1L2 Logs
    sleep  5s
    Attach Ue   UE_1
    ${CELL_ID}=    ute_ue.Get Ue Info    UE_1   IP
    Stop tracing and download logs from SMOD
    Log to console  ${CELL_ID}
    # [Teardown]    Stop L1L2 Logs And Download PCAP   ue_mode=Attach_NSA

Attach UE SA_NSA For test
    sleep  5s
    Start tracing on SMOD
    # Start L1L2 Logs
    sleep  5s
    Attach Ue   UE_3
    ${CELL_ID}=    ute_ue.Get Ue Info    UE_3   IP
    Stop tracing and download logs from SMOD
    Log to console  ${CELL_ID}
    # [Teardown]    Stop L1L2 Logs And Download PCAP   ue_mode=Attach_SA_NSA

Detach UEs Used By Test
    Detach Ue  UE_1
    Detach Ue  UE_2
    # Detach Ue  UE_3

Start ULDL UDP SA
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s
    ...             ${bip_collection}=False  ${protocol}=udp
    sleep                2s
    Run Keyword if  ${bip_collection}
    ...             Start L1L2 Logs   time=50
    Start Data Transfer  dt_name=DT_DL_SA  ue_alias=UE_2  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}   protocol=${protocol}   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}   protocol=${protocol}
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_SA
    Check Data Transfer Is Alive               DT_UL_SA
    [Teardown]    Run Keyword if  ${bip_collection}
    ...           Stop L1L2 Logs And Download PCAP  time=50  ue_mode=Tput_SA

Verify ULDL UDP SA
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec
    Verify Average Throughput With Deviation   DT_UL_SA   ${tput_UL_bandwith}   ${tput_deviation}
    ...                                        omit=10
    Verify Average Throughput With Deviation   DT_DL_SA   ${tput_DL_bandwith}   ${tput_deviation}
    ...                                        omit=10
    Await Data Transfer Finish                 DT_UL_SA
    Await Data Transfer Finish                 DT_DL_SA

Verify ULDL UDP SA is stopped
    verify_average_throughput                  DT_UL_SA    0MBits/sec   6MBits/sec
    ...                                        omit=10
    verify_average_throughput                  DT_DL_SA    0MBits/sec   7MBits/sec
    ...                                        omit=10
    Await Data Transfer Finish                 DT_UL_SA
    Await Data Transfer Finish                 DT_DL_SA

Start ULDL UDP NSA
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec   ${tput_duration}=300s
    ...             ${bip_collection}=False    ${protocol}=udp
    sleep                2s
    Run Keyword if  ${bip_collection}
    ...             Start L1L2 Logs   time=50
    Start Data Transfer  dt_name=DT_DL_NSA  ue_alias=UE_1  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}    protocol=${protocol}   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}    protocol=${protocol}
    Sleep                10s
    Check Data Transfer Is Alive               DT_DL_NSA
    Check Data Transfer Is Alive               DT_UL_NSA
    [Teardown]    Run Keyword if  ${bip_collection}
    ...           Stop L1L2 Logs And Download PCAP  time=50  ue_mode=Tput_NSA

Verify ULDL UDP NSA
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec
    Verify Average Throughput With Deviation   DT_UL_NSA   ${tput_UL_bandwith}   ${tput_deviation}
    ...                                        omit=10
    Verify Average Throughput With Deviation   DT_DL_NSA   ${tput_DL_bandwith}   ${tput_deviation}
    ...                                        omit=10
    Await Data Transfer Finish                 DT_UL_NSA
    Await Data Transfer Finish                 DT_DL_NSA

Start ULDL UDP SA_NSA
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec   ${tput_duration}=300s
    ...             ${bip_collection}=False    ${protocol}=udp
    sleep                5s
    Run Keyword if  ${bip_collection}
    ...             Start L1L2 Logs   time=50
    Start Data Transfer  dt_name=DT_DL_SA_NSA  ue_alias=UE_3  direction=dl  duration=${tput_duration}
    ...                  throughput=${tput_DL_bandwith}       protocol=${protocol}   packet_size=${Packet_Size}
    Start Data Transfer  dt_name=DT_UL_SA_NSA  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}       protocol=${protocol}
    Sleep                20s
    Check Data Transfer Is Alive               DT_DL_SA_NSA
    Check Data Transfer Is Alive               DT_UL_SA_NSA
    [Teardown]    Run Keyword if  ${bip_collection}
    ...           Stop L1L2 Logs And Download PCAP  time=50  ue_mode=Tput_SA_NSA

Verify ULDL UDP SA_NSA
    [Arguments]     ${tput_DL_bandwith}=35Mbits/sec   ${tput_UL_bandwith}=15MBits/sec
    Verify Average Throughput With Deviation   DT_UL_SA_NSA   ${tput_UL_bandwith}   ${tput_deviation}
    ...                                        omit=10
    Verify Average Throughput With Deviation   DT_DL_SA_NSA   ${tput_DL_bandwith}   ${tput_deviation}
    ...                                        omit=10
    Await Data Transfer Finish                 DT_DL_SA_NSA
    Await Data Transfer Finish                 DT_UL_SA_NSA


Get list of cells
    admin.Connect to    name=cOAM
    ${cells}    coam.Get parameters for all    NRCEL   connection=cOAM
    ${cells_id}    Create List
    #${cell}        Set Variable     ${EMPTY}
    FOR    ${cell}    IN    @{cells}
        ${cell_id}    Get From Dictionary    ${cell}    configurationId
        Append To List   ${cells_id}    NRCELL-${cell_id}
    END
    admin.Teardown     connection=cOAM
    [Return]    ${cells_id}


Pcap L2L3 collection
    [Arguments]         ${alias}=ASIK       ${filename}=pcap_logs.pcap
    Connect to SMOD     alias=${alias}
    Sleep      10s
    ssh.send command    command=tcpdump sctp -i any -w /tmp/${filename}     connection=${alias}


Pcap L2L3 log download
    [Arguments]          ${alias}=ASIK      ${filename}=pcap_logs.pcap
                  ...    ${dir}=${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/${filename}
    ssh.execute          command=killall tcpdump   connection=${alias}
    sleep  2s
    Create Directory     ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}
    sleep  2s
    ssh.download_file    /tmp/${filename}   ${dir}    connection=${alias}


Start L1L2 Logs
    [Arguments]   ${time}=15   ${size}=50
    Connect to ASIK
    Sleep   3s
    Configure Gnbmirroring Script Params      ${EXECDIR}/testsuite/Wroclaw/RRM/resources/gnbMirroring/gnbMirroringConfig.sh
            ...     time=${time}         size=${size}
    Upload gnbMirroring Script To ASIK
    Sleep   10s
    csn.Send Command        bash /ffs/run/config/scripts/gnbMirroring.sh      connection=ASIK
    Sleep   10s


Stop L1L2 Logs And Download PCAP
    [Arguments]  ${time}=15  ${ue_mode}=SA  ${suffix}=${EMPTY}
    ...  ${dir}=${OUTPUT DIR}/${ue_mode}_${TEST NAME}${suffix}.pcap
    Run    command=mkdir -p '${LOG_PATH}/PCAPs'
    Sleep   5s
    Sleep   ${time}
    ssh.download_file    /tmp/tcpdump_L2L1_bip_filtering_off.pcap   ${dir}    connection=ASIK

Adjust proper scf to current stream
    [Arguments]    ${resource_path}    ${subfeature_name}
    ${sw_stream}    Get stream name
    ${tl_name}      Get TL hostname
    Commission with scf file  ${resource_path}/SCFs/${tl_name}/scf_${subfeature_name}_${sw_stream}.xml
    ...  is_pdl_checking_needed=${True}

Very Attach
    ${is_attach_success}   verify_if_attach_success    /home/ute/petrusa_attach_sa.pcap
    should be true    ${is_attach_success}

Get stream name
    [Arguments]    ${connection}=cOAM_stream
    admin.Connect to    name=${connection}
    ${stream} = 	coam.Get sw release name    connection=${connection}
    ${stream_name}=  Set stream name  ${stream}
    admin.Teardown     connection=${connection}
    [Return]  ${stream_name}

Get neightbour stream name
    [Arguments]    ${connection}=default
    ${stream} = 	coam.Get sw release name    connection=${connection}
    ${stream_name}=  Set stream name  ${stream}
    [Return]  ${stream_name}

Set stream name
    [Arguments]    ${stream}
    ${stream_name}=  Set Variable If
    ...  '${stream}'=='SBTS24R3'  SBTS24R3
    ...  '${stream}'=='SBTS25R1'  SBTS25R1
    ...  '${stream}'=='SBTS25R2'  SBTS25R2
    ...  '${stream}'=='SBTS25R3'  SBTS25R3
    ...  '${stream}'=='SBTS26R1'  SBTS26R1
    ...  '${stream}'=='SBTS26R2'  SBTS26R2    TRUNK
    [Return]  ${stream_name}

Get BBMOD state
    [Arguments]    ${host}
    ${out} = 	get_bbmod_status  ${host}
    [Return]  ${out}

Perform decommisionig
    [Arguments]    ${host}
    ${out} =    perform_decommisioning   ${host}
    [Return]  ${out}

Get TL hostname
    [Arguments]  ${replace_host_dash}=${False}
    ${result} = 	Run   uname -a|awk '{print $2}'
    ${result}=  Run keyword if  ${replace_host_dash}  Replace String  ${result}  -  _
    ...  ELSE  Set variable  ${result}
    [Return]  ${result}

Get TL in scout
    ${tl_host} = 	Run   uname -a|awk '{print $2}'|sed -e "s/-/_/g"
    ${result}=  Set Variable If
    ...  '${tl_host}'=='7_16_UTE5GCLOUDT190'  10_16_MRBTS-50704  ${tl_host}
    [Return]  ${result}

X2-C is available
    [Arguments]    ${alias}=cOAM    ${status}=available
    admin.Connect to    name=cOAM
    @{MOs_lteenb_a}    coam.Get managed objects    class_name=LTEENB_A    connection=${alias}
    @{MOs_lteenb_r}    coam.Get managed objects    class_name=LTEENB_R    connection=${alias}
    &{dict_x2LinkLock}     coam.get_parameters    dist_name=${MOs_lteenb_a[0]['distName']}  pattern=x2LinkLock    connection=${alias}
    &{dict_x2LinkStatus}    coam.get_parameters    dist_name=${MOs_lteenb_r[0]['distName']}  pattern=x2LinkStatus    connection=${alias}
    should be equal as strings    ${dict_x2LinkLock['x2LinkLock']}    unlocked    msg=x2LinkLock is not in unlocked status    ignore_case=${True}
    should be equal as strings    ${dict_x2LinkStatus['x2LinkStatus']}    ${status}    msg=x2LinkStatus is not in available status
    ...                            ignore_case=${True}
    admin.Teardown     connection=cOAM

NG-C is available
    [Arguments]    ${alias}=cOAM    ${status}=Active
    admin.Connect to    name=cOAM
    @{MOs_servedamf}    coam.Get managed objects    class_name=SERVEDAMF_R    connection=${alias}
    &{dict_NGLinkStatus}    coam.get_parameters    dist_name=${MOs_servedamf[0]['distName']}  pattern=ngLinkStatus    connection=${alias}
    admin.Teardown     connection=cOAM
    should be equal as strings    ${dict_NGLinkStatus['ngLinkStatus']}    ${status}    msg=NGLinkStatus is not in active status
    ...                            ignore_case=${True}


Reset attenuator
    [Arguments]      ${ip_addr}
    Run  wget http://${ipaddr}/cgi-bin/reboot.cgi
    sleep  15s

Setup attenuators
    @{att_conf}  get_attenuators
    FOR    ${at}    IN    @{att_conf}
        ${success_num}    Evaluate    ${success_num} + 1
        Reset attenuator   ip_addr=${at[0]}
        att.Setup attenuator    ip_addr=${at[0]}    port=${at[1]}
        ...    attenuation_port_numbers=${at[2]}    vendor=${atten_vendor}
        ...    alias=att_${success_num}
    END

Setup attenuators with pdu power reset
    FOR    ${at}    IN    @{tl.attenuators}
        ${success_num}    Evaluate    ${success_num} + 1
        ${pdu_ports_to_reset}=   Create List
        Append To List      ${pdu_ports_to_reset}      ${at.pdu_port}

        ${pdu}=  hw_pdu.setup_pdu  ${at.pdu_port.pdu}
        hw_pdu.reset_ports  ports=${pdu_ports_to_reset}  time_interval=30
        hw_pdu.teardown_pdu  ${pdu}
        sleep  20s

        att.Setup attenuator    ip_addr=${at.ip_addr}    port=${at.port}
        ...    attenuation_port_numbers=${at.attenuation_port_numbers}    vendor=${atten_vendor}
        ...    alias=att_${success_num}
    END
    [Teardown]  hw_pdu.teardown_pdu

Set attenuation and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}   attenuator_device=att_1
        ${value_port}    att.Read attenuation    port=${${line}}   attenuator_device=att_1
        Should be equal    ${value_port}    ${${value}}
    END

Set attenuation_2 and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}   attenuator_device=att_2
        ${value_port}    att.Read attenuation    port=${${line}}   attenuator_device=att_2
        Should be equal    ${value_port}    ${${value}}
    END

Set attenuation on ports and check
    [Arguments]      ${lines}    ${value}  ${alias}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}   attenuator_device=${alias}
        ${value_port}    att.Read attenuation    port=${${line}}   attenuator_device=${alias}
        Should be equal    ${value_port}    ${${value}}
    END

Restart attenuator via PDU
    [Arguments]    ${alias}    ${warmup_time}=20s
    [Documentation]    Restarts attenuator identified by ${alias} via PDU power cycle,
    ...                then re-initialises the attenuator connection.
    ${at}=    Evaluate    next(a for a in $tl.attenuators if 'att_' + str($tl.attenuators.index(a) + 1) == $alias)
    ${pdu_ports_to_reset}=    Create List    ${at.pdu_port}
    ${pdu}=    hw_pdu.setup_pdu    ${at.pdu_port.pdu}
    hw_pdu.reset_ports    ports=${pdu_ports_to_reset}    time_interval=30
    hw_pdu.teardown_pdu    ${pdu}
    Sleep    ${warmup_time}
    att.Setup attenuator    ip_addr=${at.ip_addr}    port=${at.port}
    ...    attenuation_port_numbers=${at.attenuation_port_numbers}    vendor=${atten_vendor}
    ...    alias=${alias}

Set attenuation on ports and check with retry
    [Arguments]      ${lines}    ${value}    ${alias}
    [Documentation]    Sets and verifies attenuation on given ports.
    ...                On read/write failure restarts the attenuator via PDU (max once) and retries.
    ${retry_done}=    Set Variable    ${False}
    FOR    ${attempt}    IN RANGE    1    4
        ${status}    ${message}=    Run keyword and ignore error
        ...    Set attenuation on ports and check    ${lines}    ${value}    ${alias}
        IF    '${status}' == 'PASS'
            Return From Keyword
        END
        Log to console    Set attenuation on ports and check failed (attempt ${attempt}/3): ${message}
        IF    not ${retry_done}
            Log to console    Restarting attenuator ${alias} via PDU due to attenuation read/write error.
            Setup attenuators with pdu power reset
            ${retry_done}=    Set Variable    ${True}
        ELSE
            Log to console    PDU restart already performed - skipping restart, retrying attenuation set directly.
        END
        IF    ${attempt} >= 3
            Fail    Set attenuation on ports and check failed after 3 attempts on alias=${alias}. Last error: ${message}
        END
    END

Turn off attenuation
    ${lines}    Get dictionary keys     ${tl.attenuators[0].attenuator_ports}
    Set attenuation on ports and check with retry    lines=${lines}    value=90    alias=att_1

Turn off attenuation_2
    ${lines}    Get dictionary keys     ${tl.attenuators[1].attenuator_ports}
    Set attenuation on ports and check with retry    lines=${lines}    value=90   alias=att_2

Turn on attenuation
    ${lines}    Get dictionary keys     ${tl.attenuators[0].attenuator_ports}
    Set attenuation on ports and check with retry    lines=${lines}    value=0    alias=att_1

Turn on attenuation_2
    ${lines}    Get dictionary keys     ${tl.attenuators[1].attenuator_ports}
    Set attenuation on ports and check with retry    lines=${lines}    value=0    alias=att_2

Get UE IP from pcap
    [Arguments]   ${pcap_file}
    ${ue_ip}   get_ueip_based_on_pcap    ${pcap_file}
    [Return]  ${ue_ip}

Get UE IP from pcap SA
    [Arguments]   ${pcap_file}
    ${ue_ip}   get_ueip_based_on_pcap_sa    ${pcap_file}
    [Return]  ${ue_ip}


Log ENB UE Info
    [Arguments]    ${UE_name}
    Log to console         Waiting for information to be checked from ENB side
    ${cell}=        ute_ue.Get Ue Info      ${UE_name}        CELL_ID
    ${enb}=         ute_ue.Get Ue Info      ${UE_name}        ENB_ID
    ${ip}=          ute_ue.Get Ue Info      ${UE_name}        IP
    ${device}=      ute_ue.Get Ue Info      ${UE_name}        DEVICE_MODEL
    Log To Console          Attach to Cell ${cell} ENB_ID ${enb} IP ${ip} device: ${device}.
    [Teardown]      Log to console      Log ENB UE info done


Check UE IP
    [Arguments]             ${UE_name}=UE_1      ${UE_mode}=NSA
    # UE mode must be one of: NSA, SA or NSA_SA.
    # If you want to use this keyword, your file some_tests.robot should containe Variable with path to ue_instruction.yaml
    # for example:     Variables         /home/ute/testline_configuration/7_16_UTE5GCLOUDT186/ue.yaml

    Set Test Variable
    ...     ${ip_addr_pcue}    ${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.configuration.ue_pc_ip}

    # Let's take a serial_number value from ues yaml file for each ues:
    Run Keyword And Ignore Error         Run Keyword If    '${UE_name}' == 'UE_1'       Set Test Variable
    ...     ${ue_serial_number}      ${UE_POOLS.AndroidUePool.inline_config.UE_1.CONSTRUCTOR_PARAMETERS.serial_number}
    Run Keyword And Ignore Error         Run Keyword If    '${UE_name}' == 'UE_2'       Set Test Variable
    ...     ${ue_serial_number}      ${UE_POOLS.AndroidUePool.inline_config.UE_2.CONSTRUCTOR_PARAMETERS.serial_number}
    Run Keyword And Ignore Error         Run Keyword If    '${UE_name}' == 'UE_3'       Set Test Variable
    ...     ${ue_serial_number}      ${UE_POOLS.AndroidUePool.inline_config.UE_3.CONSTRUCTOR_PARAMETERS.serial_number}
    Run Keyword And Ignore Error         Run Keyword If    '${UE_name}' == 'UE_4'       Set Test Variable
    ...     ${ue_serial_number}      ${UE_POOLS.AndroidUePool.inline_config.UE_4.CONSTRUCTOR_PARAMETERS.serial_number}

    # If we have a NSA ue we can log to console ENB info for this ue:
    Run Keyword If    '${UE_mode}' == 'NSA'        Run Keyword And Ignore Error     Log ENB UE Info    ${UE_name}
    Run Keyword If    '${UE_mode}' == 'SA_NSA'     Run Keyword And Ignore Error     Log ENB UE Info    ${UE_name}

    Log to console          Connection to ue_pc: ${ip_addr_pcue}
    Wait Until Keyword Succeeds     120 s    5 s
    ...                             robssh.Open Connection      ${ip_addr_pcue}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=uepc
    Log to console          Connection open to ue_pc.
    Wait Until Keyword Succeeds     300 s    5 s
    ...                             robssh.Login
    ...                             username=wro5grrm           password=5gpass!1
    Log to console          Login succeed, let's check IP on ${UE_name}: ${ue_serial_number}
    Log to console          Trying to obtain UE IP from UE's ip routing table.
    ${UE_IP}=     robssh.Execute Command    adb -s ${ue_serial_number} shell ip route | cut -d ' ' -f 9
    Log to console          UE ${UE_mode} IP: ${UE_IP}
    robssh.Close Connection
    Run Keyword If    '${UE_IP}' == ''    Log to console    UE IP is empty, most likely attach process has failed.
    # Should Not Be Empty     ${UE_IP}
    [Return]                ${UE_IP}


Collect suite snapshot
    [Arguments]         ${alias}=cOAM
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=1300sec

    log to console      Collect snapshot before test case
    coam.connect to     name=coam_snap
    ${software_info}    coam.get software info  connection=coam_snap
    coam.teardown       connection=coam_snap
    ${sw_version}       set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    set variable  ${OUTPUT DIR}/${SUITE NAME}/Before_test_snapshot/Snapshot_${sw_version}_${timestamp}.zip
    coam.connect to     name=${alias}
    coam.get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${alias}
    coam.teardown       connection=${alias}

Collect neightbour suite snapshot
    [Arguments]         ${tl_name}=remote
    ...                 ${connection}=default
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=1300sec

    log to console      Collect snapshot before test case
    ${software_info}    coam.get software info  connection=${connection}
    ${sw_version}       set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${snapshot_path}    set variable  ${OUTPUT DIR}/${SUITE NAME}/Before_test_snapshot/${tl_name}_Snapshot_${sw_version}_${timestamp}.zip
    coam.get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${connection}


# ATTENUATOR KEYWORDS

Set initial attenuation for 7_16_UTE5GCLOUDT157
    Set attenuation and check  lines=${lines_gNB_157_AHCA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_157}   value=0
    Set attenuation and check  lines=${lines_LTE_159}   value=90

Set initial attenuation for 7_16_UTE5GCLOUDT159
    Set attenuation and check  lines=${lines_gNlB_157_AHCA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_157_AHCA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_157}   value=90
    Set attenuation and check  lines=${lines_LTE_159}   value=0

Set initial attenuation for 7_16_UTE5GCLOUDT153
    Set attenuation and check  lines=${lines_gNB_154_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_154_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_154_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_gNB_153_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_153_AHLOA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_153_AHLOA_3}   value=0
    Set attenuation and check  lines=${lines_LTE_155}   value=0

Set initial attenuation for 7_16_UTE5GCLOUDT154
    Set attenuation and check  lines=${lines_gNB_154_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_154_AHLOA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_154_AHLOA_3}   value=0
    Set attenuation and check  lines=${lines_gNB_153_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_153_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_153_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_LTE_156}   value=0
    Set attenuation and check  lines=${lines_LTE_155}   value=90

Set initial attenuation for 7_16_UTE5GCLOUDT184
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}   value=0
    Set attenuation and check  lines=${lines_LTE_185}   value=0

Set initial attenuation for 7_16_UTE5GCLOUDT186
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_1}   value=0
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_2}   value=0
    Set attenuation and check  lines=${lines_gNB_184_AHLOA_3}   value=0
    Set attenuation and check  lines=${lines_gNB_186_AHLOA_1}   value=90
    Set attenuation and check  lines=${lines_gNB_186_AHLOA_2}   value=90
    Set attenuation and check  lines=${lines_gNB_186_AHLOA_3}   value=90
    Set attenuation and check  lines=${lines_gNB_186_AEHC_1}    value=90
    Set attenuation and check  lines=${lines_LTE_185}   value=0
    Set attenuation and check  lines=${lines_LTE_187}   value=0

Set initial attenuation for 7_16_UTE5GCLOUDT190
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_1_FDD}   value=90
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_2_FDD}   value=90
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_3_FDD}   value=90
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_4_FDD}   value=90
    Set attenuation and check  lines=${lines_gNB_190_AHLOA_5_FDD}   value=90
    Set attenuation and check  lines=${lines_LTE_190_FDD}   value=90

Set initial attenuation
    ${tl_hostname}=  Get TL hostname
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT153'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT153
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT154'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT154
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT157'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT157
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT159'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT159
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT184'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT184
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT186'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT186
    Run keyword if   '${tl_hostname}'=='7-16-UTE5GCLOUDT190'
    ...              Set initial attenuation for 7_16_UTE5GCLOUDT190

Get testline configuration scf path
    [Arguments]  ${resource_path}  ${folder_name}  ${scf_nr_name}  ${stream_name}
    ${host_name}=  Get TL hostname  replace_host_dash=${True}
    ${scf_path_testline_configuration}=  Set variable  ${resource_path}/${host_name}/${folder_name}/${stream_name}/${scf_nr_name}
    [Return]  ${scf_path_testline_configuration}

Load scf for NR
    [Arguments]         ${resource_path}    ${folder_name}    ${scf_nr_name}    ${verify_cells_on_air}=True
    ${host_name}=       Get TL hostname
    ${stream_name}=     Get stream name
    ${scf_path_robotws}=  Set variable  ${resource_path}/${folder_name}/${host_name}/${stream_name}/${scf_nr_name}
    ${file_exists}=  Run Keyword And Return Status  OperatingSystem.File Should Exist    ${scf_path_robotws}
    ${scf_file_path}=    Run Keyword If    '${file_exists}' == 'True'    Set Variable    ${scf_path_robotws}
    ...    ELSE
    ...    Get testline configuration scf path  ${resource_path}  ${folder_name}  ${scf_nr_name}  ${stream_name}
    log to console      Start commissioning NR
    admin.Connect to    name=cOAM
    ${result}  coam.perform_commissioning     scf_file=${scf_file_path}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=cOAM
    log to console      Commissioning NR result=${result}
    Sleep   100s
    Run Keyword If    ${verify_cells_on_air} == True
    ...    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    admin.Teardown     connection=cOAM

Load scf for second NR
    [Arguments]         ${scf_resource_path}  ${folder_name}  ${scf_name}=scf_8533_186  ${ip_address}=10.44.137.49
    ${host_name}=       Get TL hostname
    ${conn}=    Connect to admin    ip_address=${ip_address}  alias=neighbour
    ${stream_name}=     Get stream name    connection=neighbour
    log to console      Start commissioning NR for second gNB
    Log    Commissioning ${ip_address} BTS with ${scf_name}    console=True
    coam.perform_commissioning      scf_file=${scf_resource_path}/${folder_name}/${host_name}/${stream_name}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=${conn}
    log to console      Commissioning of second gNB complete

Load scf for neightbour NR
    [Arguments]         ${scf_resource_path}  ${folder_name}  ${scf_name}  ${connectiom}  ${is_pdl_checking_needed}=${True}
    # ${host_name}=       Run keyword if  '${hostname}' == '${None}'  Get TL hostname  ELSE  Set variable  ${hostname}
    ${stream_name}=     Get neightbour stream name    connection=${connectiom}
    log to console      Start commissioning neightbour NR
    Log    Commissioning BTS with ${scf_name}    console=True
    ${result}=  coam.perform_commissioning      scf_file=${scf_resource_path}/${folder_name}/${stream_name}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=600
    ...   connection=${connectiom}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    log to console      Commissioning of neightbour gNB complete
    [Return]  ${result}

Read counters value
    ${counters_values}=   Create List
    Collect Counters
    FOR    ${counter}    IN      @{counters}
       ${value}    Get Last Counter Values     ${counter}
       Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Run Cmd On Ue via ADB
    [Arguments]     ${capabilities}   ${cmd}
    ${out}  Run Adb Cmd On Ue   ${capabilities}   ${cmd}
    [Return]    ${out}

Check Amount Of PRBs For Specific MCS For One UE
    [Arguments]  ${dir}=${OUTPUT DIR}/${UE_1}
    ${msgs}    check mcs one ue  ${dir}
    should be true    ${msgs}

Check Amount Of PRBs For Specific MCS For Two UEs
    [Arguments]  ${dir}=${OUTPUT DIR}/${UE_2}
    ${rnti_msgs}    check two rnti    ${dir}
    should be true    ${rnti_msgs}
    ${msgs}    check mcs two ues   ${dir}
    should be true    ${msgs}

Check Amount Of PRBs
    [Arguments]  ${dir}=${OUTPUT DIR}/${UE_2}
    ${msgs}    check mcs   ${dir}
    should be true    ${msgs}

Starting UL UDP SA_NSA
    [Arguments]     ${tput_UL_bandwith}=15MBits/sec   ${tput_duration}=300s
    sleep                5s
    Start Data Transfer  dt_name=DT_UL_SA_NSA  ue_alias=UE_3  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=udp

Starting UL UDP SA
    [Arguments]     ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s  ${protocol}=udp
    sleep                5s
    Start Data Transfer  dt_name=DT_UL_SA  ue_alias=UE_2  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=${protocol}

Starting UL UDP NSA
    [Arguments]     ${tput_UL_bandwith}=15MBits/sec  ${tput_duration}=300s   ${protocol}=udp
    sleep                5s
    Start Data Transfer  dt_name=DT_UL_NSA  ue_alias=UE_1  direction=ul  duration=${tput_duration}
    ...                  throughput=${tput_UL_bandwith}              protocol=${protocol}

Save luashark
    Run    command=mkdir -p '${LOG_PATH}/luascript'
    Run    command=zip -r '${LOG_PATH}/luascript/luascript.zip' /opt/luashark/

Mkdir for logs
    Run  mkdir -p ${OUTPUT_DIR}/${SUITE NAME}

unpack collected syslog
    [Arguments]    ${file}=${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    # Run    tar -xf ${OUTPUT DIR}/${SUITE NAME}/${test_name}/SYSLOG/syslog_files.tgz -C ${OUTPUT DIR}/${SUITE NAME}
    # Run    mv ${OUTPUT DIR}/${SUITE NAME}/SYSLOG* ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    # Run    rm ${OUTPUT DIR}/${SUITE NAME}/SYSLOG*
    Run    rm ${file}
    Run    tar -xf ${OUTPUT DIR}/${SUITE NAME}/${test_name}/SYSLOG/syslog_files.tgz -C ${OUTPUT DIR}/${SUITE NAME}
    Run    find ${OUTPUT DIR}/${SUITE NAME} -maxdepth 1 -name "SYSLOG_*" -exec cat >> ${file} '{}' \\;
    Run    rm ${OUTPUT DIR}/${SUITE NAME}/SYSLOG*

check if exist in syslog
    [Arguments]    ${grepfilter}    ${expected value}
    ${syslogOutput}    Run    grep -i "${grepfilter}" ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    should contain    ${syslogOutput}    ${expected value}

check if not exist in syslog
    [Arguments]    ${grepfilter}    ${expected value}
    ${syslogOutput}    Run    grep -i "${grepfilter}" ${OUTPUT DIR}/${SUITE NAME}/${test_name}.log
    should not contain    ${syslogOutput}    ${expected value}

Get Resource Usage before test
    Create AaShell CLI    name=aashell
    ah.Setup    aashell
    ${resources_usage1}=    Get Resources Usage    aashell
    set suite variable  ${us1}   ${resources_usage1}
    [Teardown]    ah.Teardown    aashell

Get Resource Usage after test
    Create AaShell CLI    name=aashell
    ah.Setup    aashell
    ${resources_usage2}=    Get Resources Usage    aashell
    Should Be Equal As Resources
    ...    ${us1}
    ...    ${resources_usage2}
    ...    exclude=//bufferPoolFreeCount
    [Teardown]    ah.Teardown    aashell

Verify Crash occurrence In Syslog
    [Arguments]    ${file}='${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'/merged_syslog.log
    Run    rm -f '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'/SYSLOG_*
    Run    tar -xf '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'/SYSLOG/syslog_files.tgz -C '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'
    Run  find '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}' -maxdepth 1 -name "SYSLOG_*" -exec cat >> ${file} '{}' \\;
    # Run    mv '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'/SYSLOG_* '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'/merged_syslog.LOG
    Run    rm -f '${OUTPUT DIR}'/'${SUITE NAME}'/'${test_name}'/SYSLOG_*
    Log  Checking syslog for possible crash occurrence.  console=yes
    ${crash_check_result}    ${crash_check_error}=    Run Keyword And Ignore Error
    ...  common_kw.Check Syslog For Crashes   ${file}
    Syslog checker for suspicious logs
    Run Keyword If    "${crash_check_result}" == "FAIL"    Log    ${crash_check_error}    ERROR! CRASH OCCURENCE!
    [Return]    ${crash_check_result}

Syslog checker for suspicious logs
    [Arguments]    ${file}=${OUTPUT DIR}/${SUITE NAME}/${test_name}/
    Log  Syslog checker for suspicious logs  console=yes
    Run Keyword And Ignore Error  common_kw.Syslog Checker For Suspicious Prints   ${file}

Activate debug logs
    [Arguments]      ${command}= echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    Connect to SMOD    alias=asib
    ssh.send_command   ${command}     connection=asib
    ssh.send_command   chmod a+r /ffs/run/cp_runtime.ini      connection=asib

Run Change Mode Script
    [Arguments]     ${uepcip}=10.44.72.183
    ...             ${resource_filepath}=testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/change_ue_mode.py
    ...             ${destination_filepath}=C:/Users/wro5grrm/Desktop/MEDIATEK/ELT_exe_v3.2220.0_customer_x64
    ...             ${venv1}=virtualenv --python=python3.7 script_venv
    ...             ${venv2}=source script_venv/Scripts/activate
    ...             ${script_run}=python change_ue_mode.py
    ...             ${ue_mode}=SA
    Run     sshpass -p '${labpcpass}' scp ${resource_filepath} ${labpcname}@${uepcip}:${destination_filepath}
    ssh.connect to  hostname=${uepcip}
    ...             username=wro5grrm
    ...             password=5gpass!1
    ...             alias=uepc
    ${output}=      ssh.execute     cd ${destination_filepath} && ${venv1} && ${venv2} && ${script_run} ${ue_mode}    connection=uepc
    Log To Console  ${output}
    Should Not Contain Any  ${output}   SystemError  database   ignore_case=True

Set AT command to MTK
    [Arguments]    ${ue_mode}
    ${tl_hostname}=  Get TL hostname
    Run keyword if    '${tl_hostname}'=='7-16-UTE5GCLOUDT157'
    ...              ssh.connect_to   hostname=10.42.61.155
    ...              username=wro5grrm
    ...              password=5gpass!1
    ...              alias=uepc
    Run keyword if    '${tl_hostname}'=='7-16-UTE5GCLOUDT157'
    ...              ssh.send command    command=cd /cygdrive/c/mtk_scripts/ && python send_at_command.py ${ue_mode}          connection=uepc

Turn OFF RU on TL
    tl prepare to ru off

Turn ON RU on TL
    tl prepare to ru on

UE Reboot Before Test
    ${uepcip}=  Get UEPC IP address
    Wait Until Keyword Succeeds     10 s    5 s
    ...                             robssh.Open Connection      ${uepcip}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=uepc
    Log to console          Connection open to ue_pc.
    Wait Until Keyword Succeeds     10 s    5 s
    ...                             robssh.Login
    ...                             username=wro5grrm           password=5gpass!1
    Sleep  2s
    ${devices}=     robssh.Execute Command    adb devices    connection=uepc
    Sleep  2s
    robssh.Execute Command    adb kill-server    connection=uepc
    Sleep  2s
    robssh.Execute Command    adb start-server    connection=uepc
    Sleep  5s
    ${devices}=     robssh.Execute Command    adb devices    connection=uepc
    ${devices_list}=       common_kw.Strip Devices String      ${devices}
    ${length}=      BuiltIn.Get Length      ${devices_list}
    FOR     ${index}        IN RANGE    ${length}
        robssh.Execute Command    adb -s ${devices_list}[${index}] reboot      connection=uepc
        Log To Console  ${devices_list}[${index}] rebooting...
    END
    Sleep  20s
    Sleep  2s
    robssh.Execute Command    adb kill-server    connection=uepc
    Sleep  2s
    robssh.Execute Command    adb start-server    connection=uepc
    Sleep  5s
    ${devices}=     robssh.Execute Command    adb devices    connection=uepc
    [Teardown]  robssh.Close Connection
    sleep  60s
    Log To Console      Connection closed.

UE power reset
    [Arguments]    ${ue_sn}=MTK_M70
    ${uepcip}=  Get UEPC IP address
    Wait Until Keyword Succeeds     10 s    5 s
    ...                             robssh.Open Connection      ${uepcip}
    ...                             escape_ansi=True            newline=CRLF
    ...                             alias=uepc
    Log to console          Connection open to ue_pc.
    Wait Until Keyword Succeeds     10 s    5 s
    ...                             robssh.Login
    ...                             username=wro5grrm           password=5gpass!1
    Sleep  2s
    ${devices}=     robssh.Execute Command    adb devices    connection=uepc
    Log To Console      ${devices}
    robssh.Execute Command    adb -s ${ue_sn} shell input keyevent --longpress 26    connection=uepc
    Sleep  5s
    Run Keyword If    '${ue_sn}' == 'MTK_M70'
    ...    robssh.Execute Command    adb -s ${ue_sn} shell input tap 1000 200    connection=uepc
    ...    ELSE
    ...    robssh.Execute Command    adb -s ${ue_sn} shell input tap 540 1300    connection=uepc
    Log To Console  ${ue_sn} rebooting...
    Sleep  30s
    [Teardown]  robssh.Close Connection
    sleep  30s
    Log To Console      Connection closed.

Get UEPC IP address
    ${ueip}  get_uepc_ip
    [Return]  ${ueip}

# ********* CB008729 ********
Sleeping cell test
    Run Keyword and Ignore Error  Connect To Coam
    ${stream_name}    Get stream name
    ${is_trunk}       Run Keyword And Return Status
    ...               Should Be Equal  ${stream_name}  TRUNK
    Run keyword if                          ${is_trunk} != False
    ...                                     Common step trigger

Change actHighestEstNrTputBcSel
    [Arguments]    ${value}=true   ${alias}=cOAM
    Log to console      Connect to cOAM.
    coam.Connect to    name=${alias}
    ${bts_info}    coam.Get bts info    connection=cOAM
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    Set suite variable    ${bts_id}
    coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
    ...                                       parameter=actHighestEstNrTputBcSel
    ...                                       operation=update
    ...                                       value=${value}
    ...                                       skip_parameter_relation_errors=${True}
    ...                                       connection=${alias}
    coam.Teardown     connection=${alias}

Enable debugging syslogs

    ${proxy}=       ssh.connect to    10.44.178.120    ute    ute
    ssh.connect to  hostname=192.168.255.129
    ...             username=toor4nsn
    ...             password=oZPS0POrRieRtu
    ...             alias=asik_master
    ssh.connect to  hostname=192.168.255.119
    ...             username=toor4nsn
    ...             password=oZPS0POrRieRtu
    ...             proxy=${proxy}
    ...             alias=asik_slave
    ssh.execute     command=echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini   connection=asik_master
    sleep  2s
    ssh.execute     command=echo -e "\n0x1003F=1\n0x10040=1\n0x10041=1\n0x590072=1\n0x66001b=1\n" >> /ffs/run/swconfig.txt
    ...             connection=asik_master
    sleep  2s
    ssh.execute     command=crasign /ffs/run/swconfig.txt   connection=asik_master
    ssh.execute     command=echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini    connection=asik_slave
    sleep  2s
    ssh.execute     command=echo -e "\n0x1003F=1\n0x10040=1\n0x10041=1\n0x590072=1\n0x66001b=1\n" >> /ffs/run/swconfig.txt
    ...             connection=asik_slave
    sleep  2s
    ssh.execute     command=crasign /ffs/run/swconfig.txt   connection=asik_slave
    # Reboot will be done during load NR scf kw
    # ssh.execute     command=reboot   connection=asik_master
    # ssh.execute     command=reboot   connection=asik_slave
    ssh.disconnect  connection=asik_master
    ssh.disconnect  connection=asik_slave
    Log to console  Rebooting SMOD
    sleep  15s

Add btslog flag
    add_btslog_flag_to_swconfig

Check intra-gnb-Handover success
    unpack collected syslog
    check if exist in syslog  Successfull HO   Successfull HO

Start New L1L2 Logs
    [Arguments]  ${ip}=192.168.255.129  ${suffix}=${EMPTY}
    ...          ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}${suffix}.pcap
    Run    command=mkdir -p '${LOG_PATH}/PCAPs'
    Sleep   5s
    bip_mirroring.start_gnbmirroring   filename=${dir}  ip=${ip}

Stop New L1L2 Logs And Download PCAP
    [Arguments]  ${ip}=192.168.255.129    ${suffix}=${EMPTY}
    ...    ${dir}=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}${suffix}.pcap
    bip_mirroring.stop_gnbmirroring_and_download_logs   ip=${ip}   filename=${dir}

Get MPlane from BTS configuration
    coam.Connect to    name=cOAM_mplane
    ${bts_info}    coam.Get bts info    connection=cOAM_mplane
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    coam.Get current scf file    local_dir_path=/tmp/
    ...                          file_name=scf.xml
    ...                          connection=cOAM_mplane
    ...                          timeout=60s
    scf.Load Scf   file_path=/tmp/scf.xml
    ${mPlaneIpv4AddressDN}    scf.Get value from scf    dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                          p_name=mPlaneIpv4AddressDN
    ${mplane_ip}    scf.Get value from scf    dist_name=${mPlaneIpv4AddressDN}
    ...                                          p_name=localIpAddr
    coam.Teardown     connection=cOAM_mplane
    [Return]    ${mplane_ip}

Stop and fix when critical fid
    stop_and_fix

Stop and fix when critical fid neightbour
    stop_and_fix_neightbour

Start Tshark monitoring
    [Arguments]  ${filename}=test.pcap
    ...          ${hostname}=192.168.255.129
    ...          ${username}=toor4nsn
    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=ASIK
    ssh.connect_to  hostname=${hostname}  username=${username}
    ...             password=${password}  alias=${alias}
    Wait until keyword succeeds    5 min    1 min
    ...    ssh.send_command    command=tcpdump sctp -i any -w ${filename}   connection=${alias}
    sleep  3s

Stop Tshark monitoring and download logs
    [Arguments]  ${filename}=${OUTPUT_DIR}/Tshark_${TEST_NAME}.pcap
#    ...          ${hostname}=192.168.255.129
#    ...          ${username}=toor4nsn
#    ...          ${password}=oZPS0POrRieRtu
    ...          ${alias}=ASIK
    sleep  3s
    Run    command=mkdir -p '${LOG_PATH}/PCAPs'
    Sleep  3s
#    ssh.connect_to  hostname=${hostname}  username=${username}
#    ...             password=${password}  alias=${alias}
    ssh.execute  command=killall tcpdump  connection=${alias}
    sleep  3s
    ssh.download_file   /user/toor4nsn/test.pcap  ${filename}  connection=${alias}
    sleep  3s
    ssh.disconnect  connection=${alias}

Load identical software build on external gNB
    [Documentation]     This keyword allows test to update software on any other gNB. Works only on trunk for now.
    ...                 param bts_host(str): ip of neighbour gNB m-Plane
    [Arguments]         ${bts_host}=10.44.137.49
    ADMIN CLI connection
    ${Downloaded_SW}    admin_cli.get_sw_version
    Log to Console      Updating software to build ${Downloaded_SW} on neighbour BTS with M-Plane IP ${bts_host}.
    ADMIN CLI disconnection
    ${sw_build_to_download}     Download CommonTrunk Soft    ${Downloaded_SW}
    ${conn}=    Connect to admin    ip_address=${bts_host}  alias=neighbour
    admin_cli.update_software      sw_package=${CURDIR}/Commissioning_preparation/${sw_build_to_download}
    ...                            should_activate=True    timeout=1200    connection=${conn}
    Log to Console                 Software updated. Resetting...
    Sleep                          8 minutes

Collect counters ext gnb
    [Arguments]  ${n_last}=8    ${hostname}=10.44.137.49
    &{webservice}=   Create dictionary
    ...                 host=${hostname}
    ...                 user=Nemuadmin
    ...                 password=nemuuser
    ...                 port=443
    pm.Create PM collector   name=collector   webservice=&{webservice}
    pm.setup collectors      names=collector
    pm.collect collectors    names=collector
    pm.teardown collectors    names=collector
    Remove counter files except for last   ${n_last}

Change XnLink
    [Arguments]    ${value}=Unlocked   ${alias}=cOAM
    Log to console      Connect to cOAM to change Xn-link state.
    coam.Connect to    name=${alias}
    ${bts_info}    coam.Get bts info    connection=cOAM
    ${bts_id}     Get from dictionary    ${bts_info}    mrbtsID
    Set suite variable    ${bts_id}
    coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRADJGNB-4
    ...                                       parameter=administrativeState
    ...                                       operation=update
    ...                                       value=${value}
    ...                                       skip_parameter_relation_errors=${True}
    ...                                       should_activate=${True}
    ...                                       connection=${alias}
    coam.Perform parameter recommissioning    dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}/NRADJGNB-5
    ...                                       parameter=administrativeState
    ...                                       operation=update
    ...                                       value=${value}
    ...                                       skip_parameter_relation_errors=${True}
    ...                                       should_activate=${True}
    ...                                       connection=${alias}
    coam.Teardown     connection=${alias}
