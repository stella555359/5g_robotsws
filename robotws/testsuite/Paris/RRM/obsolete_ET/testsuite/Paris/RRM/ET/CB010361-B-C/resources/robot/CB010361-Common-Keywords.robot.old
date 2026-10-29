*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com
...   description: Common keywords for feature CB010361-B-C - SR - VRF - RRM - ET

Library             taf.sbts.oam.coam.admin    WITH NAME    admin
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog
Library             taf.transport.ssh    WITH NAME    ssh
Library             taf.wts.runner    WITH NAME  wtsemu
Library             OperatingSystem
Library             Process
Library             Collections
Library             String
Library             DateTime
Library             SSHLibrary
Library             BuiltIn
Library             taf.sw.reporting_portal

Resource           ../../../../../resources/SWENG/robot/Setup.robot

*** Variables ***

${BTS_ADDRESS}                      192.168.255.129
${log_alias}                        btslog
${LOGS_PATH}                        /home/ute/test_results/logs
${BTS_ADDRESS_MPLANE}               10.0.1.2    # BTS M PLane IP
${btsuserremote}                    Nemuadmin
${btspassremote}                    nemuuser
${VM_IP}                            ${tl.test_pc.default_ssh_connection_details.addr}
${BTS_path}                         /home/ute/test_results
${password}                         ute
${TCE_IP}                           ${tl.test_pc.default_ssh_connection_details.addr}
${TCE_PORT}                         49148
${WIRESHARK_PATH}                   /usr/bin/tshark
${Script_path}                      /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB010361-B-C

# ====== SWENG =====
${TestSharkTool}                    MC_SHARK
${isAic}                            False
${TLConfig.isGnbCloud}              False
${keep_all_data_in_file}            ${False}
# ==================

${SA_Capa_perUE_Full}  SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D60
...    8C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE
...    00098000702A0D883AC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA160703878
...    4FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C639F3
...    0C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E
...    31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF00000130000E0541B06F582308682041E2090195B262
...    AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000004C00038024F0F1340038820
...    000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13400388
...    C0000042C0AC5C46000E20800710400002858158B89A001C41000E140000040B02B1713400388C001C4600
...    0004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E2300000
...    20B02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B02B1F0
...    A0003850001C1B000E208000070B02B1F0A0003836001C41000E230000080B02B1F0A0003850001C1B000E
...    230000070B02B1F0A0003850001C41000E230000070B020120234028809B010600D87A06E84A14489B1CF8
...    70A244D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C0890
...    2040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E0
...    428103639F0214081B1CF810A040D8E7C000D890C6318C6318C6318C6318C60F413003C00281C1401C0C02
...    500700060240040603E0900200000001000002008000000040000080200000801000006008000040040000
...    2802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000
...    812048020000300CE54D654D60C560CD60CD60CD652D64CD602D60CD602D604D60ED034100000965240400
...    0065949010000296524040000E594901000049652404000165949010000696524040001E59490100008965
...    2404000265949010000A96524040002E5949010000C96524040000C594900CD2A8BA55154AA2E95455068A
...    A0D1541A2A94C55268AA031540A2A93455078A1202F012A05028140A05028140A05028140A05028140A050
...    2800404040300601002004202004010080600C20100200404030060100C018202018030080600C20100200
...    4040300601002004402018030080600C020180304040080201002008602004008080100202018030080600
...    C30100200404030060100C01804030061AA1F000102030406070A0B0C0D101112131418191B1C1D1F21252
...    62728292A2D2F414182D

*** Keywords ***

Configure UTE ETH3
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3 && sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3 && sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3 && sudo ip addr add 10.0.1.136/24 dev eth3
	OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3 && sudo ip addr add 10.0.1.138/24 dev eth3
    SSHLibrary.Open Connection    host=127.0.0.1    port=22    timeout=60
    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write   sudo pkill -9 edaemon && pkill -9 egate

Setup Airphone Env for CellSetup
    ssh.Connect To    hostname=${VM_IP}    username=ute    key_path=/home/ute/.ssh/id_rsa    look_for_keys=True    alias=wtsemu
    wtsemu.configure_wtsemu_edaemon    edaemon_ssh_alias=wtsemu
    ...                                directory_path=/opt/iphy/latest
    ...                                port=22222
    wtsemu.configure_wtsemu_egate    egate_ssh_alias=wtsemu
    ...                              directory_path=/opt/iphy/latest
    ...                              port=20000
    wtsemu.start_wtsemu    egate_console_ip=${VM_IP}
    ...                    egate_port=20000
	Sleep    5s
    wtsemu.configure    file=basic_setup.cfg
	Wait Until Keyword Succeeds    90    10   ADMIN Check Bts Status    status=OnAir
    sleep    60s

Get Average Traffic Rate SA
    [Documentation]    Get Average Traffic Rate SA from bearer stat WTS function
    [Arguments]    ${ue}    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl
    Log to console  Arguments : ${ue} ${pdu} ${qfi} ${trf_id} ${dir}

    wtsemu.Bearer Stats             ue=${ue}
    ...                             dir=${dir}                        trf_id=${trf_id}
    ...                             qfi=${qfi}                        pdu=${pdu}
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=20
    ${output}=                 Get Lines Containing String             ${output}          Average data rate
    ${output}=                 Replace String      ${output}      Average data rate       ${EMPTY}
    @{words}=                  Split String        ${output}      (
    ${average_out}=            Strip String        ${words[0]}
    [Return]    ${average_out}

Get Average Traffic Rate NSA
    [Documentation]    Get Average Traffic Rate NSA from bearer stat WTS function
    [Arguments]    ${ue}    ${id}=1    ${dir}=dl    ${dc_cell_group}=scg
    Log to console  Arguments : ${id} ${dir} ${dc_cell_group}
    wtsemu.Bearer Stats    ue=${ue}
    ...    id=${id}    dir=${dir}    dc_cell_group=${dc_cell_group}
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=20
    ${output}=                 Get Lines Containing String             ${output}          Average data rate
    ${output}=                 Replace String      ${output}      Average data rate       ${EMPTY}
    @{words}=                  Split String        ${output}      (
    ${average_out}=            Strip String        ${words[0]}
    [Return]    ${average_out}

Traffic_DL_UL_SA
    [Arguments]    ${ue}
    Check Script Name if CA And Execute Keyword set_SA_Capa_perUE_Full for UL CA    ${ue}
    wtsemu.ue_register    id=${ue}
    ${status}    ${output}    Run Keyword And Ignore Error    wtsemu.read_wtsemu_output_until    expected=crnti    timeout=30
    Run Keyword If    '${status}' == 'FAIL'    wtsemu.ue_register    id=${ue}
    wtsemu.set_pdu_param    ue=${ue}    pdu=1    trf_type=internal
    sleep    30s
    wtsemu.ue_pdu_session_setup    pdu=1    gw=1    ue=${ue}    nwslice=1
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=1    size=1350    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=2    size=1350    mbps=140    protocol=tcp
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=3    size=1350    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=4    size=1350    mbps=140    protocol=tcp
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=5    size=1350    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=dl    trf_id=6    size=1350    mbps=140    protocol=tcp
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=1    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=2    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=3    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=4    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=5    mbps=140    protocol=tcp
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    pdu=1    qfi=1    dir=ul    trf_id=6    mbps=140    protocol=tcp

    Add Bler To Scell ULDL Channel    ue=${ue}    scell=0,1

    sleep    60s

    Delete Bler To Scell ULDL Channel    ue=${ue}

    ${traffic_dl}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=1  dir=dl
    ${traffic_ul}      Get Average Traffic Rate SA  ue=${ue}  pdu=1  qfi=1  trf_id=1  dir=ul

    ${Ue_PDSCH_Tput}=    Set Variable    ${traffic_dl}
    ${Ue_PUSCH_Tput}=    Set Variable    ${traffic_ul}
    Log to console    traffic dl: ${Ue_PDSCH_Tput}
    Log to console    traffic ul: ${Ue_PUSCH_Tput}

    ${result}=  Evaluate    " cell"
    wtsemu.ue_stats_nr    id=${ue}    type=pdsch    scell=0-5
    ${traffic_dl_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic dl NR: ${traffic_dl_NR}
    wtsemu.ue_stats_nr    id=${ue}    type=pusch    scell=0-5
    ${traffic_ul_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic ul NR: ${traffic_ul_NR}

Traffic_DL_UL_SA_stop
    [Arguments]    ${ue}
    wtsemu.ue_deregister    id=${ue}    by=ue    ue_deregister_type=switch_off
    run keyword and continue on failure
    ...    wtsemu.read_wtsemu_output_until    expected=UE Context Release Complete
    ...                                       timeout=40

Traffic_DL_UL_NSA
    [Arguments]    ${ue}
    wtsemu.enb_x2_link_up    enb=1    target=2
    sleep    30s
    wtsemu.ue_attach    id=${ue}    profile=1
    sleep    30s
    wtsemu.enb_ue_dc_start    ue=${ue}    target_gnb=2    target_cells=1    bearer=2    type=split_scg
    sleep    30s
    wtsemu.read_wtsemu_output_until_prompt     timeout=30
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    id=2    dir=dl    trf_id=1    mbps=140
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    id=2    dir=dl    trf_id=2    mbps=140
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    id=2    dir=dl    trf_id=3    mbps=140
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    id=2    dir=dl    trf_id=4    mbps=140
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    id=2    dir=dl    trf_id=5    mbps=140
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    id=2    dir=dl    trf_id=6    mbps=140
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    id=2    dir=ul    trf_id=1    mbps=140
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    id=2    dir=ul    trf_id=2    mbps=140
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    id=2    dir=ul    trf_id=3    mbps=140
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    id=2    dir=ul    trf_id=4    mbps=140
    sleep    30s

    wtsemu.trf_data_start    ue=${ue}    id=2    dir=ul    trf_id=5    mbps=140
    sleep    30s
    wtsemu.trf_data_start    ue=${ue}    id=2    dir=ul    trf_id=6    mbps=140

    Add Bler To Scell ULDL Channel    ue=${ue}    scell=8,9

    sleep    60s

    Delete Bler To Scell ULDL Channel    ue=${ue}

    ${traffic_dl}      Get Average Traffic Rate NSA    ue=${ue}    id=2    dir=dl    dc_cell_group=scg
    ${traffic_ul}      Get Average Traffic Rate NSA    ue=${ue}    id=2    dir=ul    dc_cell_group=all

    ${Ue_PDSCH_Tput}=    Set Variable    ${traffic_dl}
    ${Ue_PUSCH_Tput}=    Set Variable    ${traffic_ul}
    Log to console    traffic dl: ${Ue_PDSCH_Tput}
    Log to console    traffic ul: ${Ue_PUSCH_Tput}

    ${result}=  Evaluate    " cell"
    wtsemu.ue_stats_nr    id=${ue}    type=pdsch    scell=0-20
    ${traffic_dl_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic dl NR: ${traffic_dl_NR}
    wtsemu.ue_stats_nr    id=${ue}    type=pusch    scell=0-20
    ${traffic_ul_NR}    wtsemu.read_wtsemu_output_until    expected=${result}   timeout=10
    Log to console    traffic ul NR: ${traffic_ul_NR}

Add Bler To Scell ULDL Channel
    [Arguments]   ${ue}    ${scell}    ${ul_bler}=100,200,300,400,100,300,400,500    ${dl_bler}=100,200,300,400,100,300,400,500
    wtsemu.bler_testmode_nr    profile_id=1    ul_bler=${ul_bler}    dl_bler=${dl_bler}
    wtsemu.ue_testmode_set_nr    id=${ue}    scell=${scell}    testmode=bler    profile_id=1    action=activate

Delete Bler To Scell ULDL Channel
    [Arguments]    ${ue}
    wtsemu.ue_testmode_set_nr    id=${ue}    testmode=bler    profile_id=1    action=deactivate

Traffic_DL_UL_NSA_stop
    [Arguments]    ${ue}
    wtsemu.ue_detach    id=${ue}

ADMIN Check Bts Status
    [Arguments]    ${status}=OnAir
    ${bts_state}=    admin.get_bts_statuses    connection=mplane
    BuiltIn.Log    [INFO] BTS STATE : ${bts_state}
    BuiltIn.Log To Console     ${BTS STATE['proceduralState']}
	BuiltIn.Should Be True    '${BTS STATE['proceduralState']}' == '${status}'

Login To Admin
    wait until keyword succeeds     5min    30s
    ...    admin.setup_admin    bts_host=${BTS_ADDRESS}    alias=oam

LoginToAdminMplane
    admin.setup_admin    bts_host=${BTS_ADDRESS_MPLANE}    alias=mplane

Start Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    btslog.create_btslog_collector    btslog
    ...    log_dir=/tmp/btslog2
    core.setup_collectors    btslog
    core.start_collectors    btslog
    core.Set Suite Alias    btslog

Stops Btslogs from Local machine
    [Documentation]    path from where to get btslog files default value: \u201c/tmp/btslog2\u201d
    Run Keyword And Continue On Failure    core.stop_collectors    btslog
    Run Keyword And Continue On Failure    core.collect_collectors    btslog    ${out}
    Run Keyword And Continue On Failure    core.teardown_collectors    btslog

Get Date
    [Documentation]    Get date to create testcase folder
    ${date}=    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
    ${date}=    Convert to String    ${date}
    Set global variable    ${Folder}    ${date}

Collect_Alarms
    Wait Until Keyword Succeeds
    ...    3min
    ...    30s
    ...    admin.collect_raw_alarm_history_file
    ...    target_file_name=${out}/AllAlarms.txt
    ...    connection=mplane

Collect_ImSnapshot
    Wait Until Keyword Succeeds    2min    30s    admin.collect_im_snapshot    target_file_name=${out}/ImSnapshot.ims2    connection=mplane

Collect_SCF
    Wait Until Keyword Succeeds    2min    30s    admin.get_current_scf_file
    ...    file_name=SCF.xml
    ...    timeout=60
    ...    local_dir_path=${out}
    ...    connection=mplane

Download Snapshot
    Wait Until Keyword Succeeds
    ...    10min
    ...    120s
    ...    admin.collect_snapshot
    ...    target_file_name=${out}/Snapshot.zip
    ...    connection=mplane

Test Setup
    Run Keywords    LoginToAdminMplane
    Create testcase folder
    ${SUITE NAME}=    Set Variable    ${SUITE NAME}
    ${SUITE NAME}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    OperatingSystem.run    chmod 777 ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}
    Run Keyword And Ignore Error    Start Btslogs from Local machine
    Run Keyword And Ignore Error    Delete Files

Test Teardown
    Run Keyword And Ignore Error    Stops Btslogs from Local machine
    Collect_Alarms
    Collect_ImSnapshot
    Collect_SCF
    Download Snapshot
    admin.teardown_admin    mplane
    wtsemu.stop_wtsemu
    Log to console    --End test--\n

Create testcase folder
    [Documentation]    Create testcase folder in VM
    ${SUITE NAME}=    Set Variable    ${SUITE NAME}
    ${SUITE NAME}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${val}=    Run Keyword And Return Status    LOG    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    OperatingSystem.create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    ${out}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/
    set test variable    ${out}

Suite_Setup
    Log to console    --Test Started--\n
    ${status_TCE_IP}    ${output_TCE_IP}    Run Keyword And Ignore Error    Get tceIpAddressparameter from Info Model
    Run Keyword If    '${status_TCE_IP}' == 'FAIL'    Activate PCMD tracing GNB on WebEM
    Check Script Name if CA And Execute Keyword Activate CA UL FDD as PCell GNB CB006137
    ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M
    ${CurrentDate}=    Convert to String    ${CurrentDate}
    ${SUITE NAME}=    Set Variable    ${SUITE NAME}
    ${SUITE NAME}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    OperatingSystem.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
    Set global variable    ${Date}    ${CurrentDate}

Start TCE
    Log to console    Start TCE
    SSHLibrary.open connection    ${TCE_IP}    timeout=30 seconds
    SSHLibrary.Login With Public Key    ute    /home/ute/.ssh/id_rsa
    SSHLibrary.Write    sudo pkill -9 -f 'nc -lvnp 49148'
    sleep    30s
    SSHLibrary.Write    nc -lvnp 49148 &> /home/ute/logs/tce_49148.txt&

Create_wireshark_Logs_Path
    [Documentation]    Create testcase folder in VM
    ${SUITE NAME}=    Set Variable    ${SUITE NAME}
    ${SUITE NAME}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${val1}=    Run Keyword And Return Status    LOG    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs
    create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs
    OperatingSystem.create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs_parsed_CB010361_C
    OperatingSystem.create directory    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs_parsed_CB010361_B
    ${wireshark_path}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs
    ${wire_parsed_CB010361_C}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs_parsed_CB010361_C
    ${wire_parsed_CB010361_B}=    Set Variable    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/wireshark_Logs_parsed_CB010361_B
    Set global variable    ${wireshark_Logs_path}    ${wireshark_path}
    Set global variable    ${wire_path_parsed_CB010361_C}    ${wire_parsed_CB010361_C}
    Set global variable    ${wire_path_parsed_CB010361_B}    ${wire_parsed_CB010361_B}

Start To Capture UTE Wireshark
    Run Keyword And Ignore Error  SSHLibrary.Write
    ...    sudo tcpdump tcp port 49148 -i eth3 -w ${wireshark_Logs_path}${/}ute_wireshark_eth3.pcap>& tmp_3.txt&

Stop Capture UTE Wireshark
    Run Keyword And Ignore Error    SSHLibrary.Write    ps -ef | grep 'tcpdump' | grep -v -w grep
    Run Keyword And Ignore Error    SSHLibrary.Write    ps aux | grep tcpdump | awk '{ print $2}' | xargs -I {} sudo kill -s SIGTERM {}
    Run Keyword And Ignore Error    SSHLibrary.Write    ps -ef | grep 'tcpdump' | grep -v -w grep

Suite_Teardown
    log    "Test END"

Test Setup CB010361-SR-C
	[Documentation]
    ...    | Description | Test Setup CB010361-SR-C |
    ...    | . | .       |
    ...    | Test Steps  | 1. Configure UTE ETH3 |
    ...    | Test Steps  | 2. Setup Airphone Env for CellSetup |
    ...    | Test Steps  | 3. Create TCE |
	##########################################################################################
    #1. Configure UTE ETH3
    ##########################################################################################
    Run keyword and continue on failure    Configure UTE ETH3
    sleep    30s
    ##########################################################################################
    #2. Setup Airphone Env for CellSetup
    ##########################################################################################
    Setup Airphone Env for CellSetup
    sleep    40s
    ##########################################################################################
    #3. Create TCE and start wireshark Logs
    ##########################################################################################
    Create_wireshark_Logs_Path
    Start TCE

Activate PCMD tracing GNB on WebEM
    Update TCE IP Address in Delta JSON
    Recommission GNB With Delta    delta_file=${JSON_FILE_PATH}

Activate CA UL FDD as PCell GNB CB006137
    Log To Console    Activate CA UL GNB
    Recommission GNB With Delta    delta_file=${JSON_CA_UL_FILE_PATH}

set_SA_Capa_perUE_Full for UL CA
    [Arguments]    ${ue}
    wtsemu.ue_param    id=${ue}    ue_nr_capabilities=${SA_Capa_perUE_Full}
    Sleep    30s
    Log To Console    set_SA_Capa_perUE_Full

Check Script Name if CA And Execute Keyword Activate CA UL FDD as PCell GNB CB006137
    [Documentation]    This keyword checks the script name and executes specific keywords if it matches.
    ${SCRIPT_NAME}=    Set Variable    CB010361-B-C_FR1_FDD_SA_NSA_CA.robot
    ${SUITE_NAME}=    Set Variable    ${SUITE NAME}
    ${SUITE_NAME}=    Replace String    ${SUITE_NAME}    ${SPACE}    _
    ${current_script_name}=    Set Variable    ${SUITE_NAME}.robot
    Log to console    ${current_script_name} started.
    Run Keyword If    '${current_script_name}' == '${SCRIPT_NAME}'    Activate CA UL FDD as PCell GNB CB006137

Check Script Name if CA And Execute Keyword set_SA_Capa_perUE_Full for UL CA
    [Arguments]    ${ue}
    [Documentation]    This keyword checks the script name and executes specific keywords if it matches.
    ${SCRIPT_NAME}=    Set Variable    CB010361-B-C_FR1_FDD_SA_NSA_CA.robot
    ${SUITE_NAME}=    Set Variable    ${SUITE NAME}
    ${SUITE_NAME}=    Replace String    ${SUITE_NAME}    ${SPACE}    _
    ${current_script_name}=    Set Variable    ${SUITE_NAME}.robot
    Log To Console    ${current_script_name} started.
    Run Keyword If    '${current_script_name}' == '${SCRIPT_NAME}'    set_SA_Capa_perUE_Full for UL CA    ${ue}

Recommission GNB With Delta
    [Arguments]    ${delta_file}    ${skip_parameter_relation_errors}=${True}    ${should_activate}=${True}   ${timeout}=300
    LoginToAdminMplane
    admin.Perform Delta Recommissioning    delta_file=${delta_file}    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...    should_activate=${should_activate}   timeout=${timeout}    connection=mplane
    [Teardown]    admin.teardown_admin    mplane

Update TCE IP Address in Delta JSON
    [Documentation]   This function updates the TCE IP address in a specified JSON file.
    ${json_data}=    Evaluate    json.load(open('${JSON_FILE_PATH}'))    json
    FOR    ${param}    IN    @{json_data[8]["parameters"]}
        ${param_name}=    Set Variable    ${param["parameterName"]}
        Run Keyword If    '${param_name}' == 'tceIpAddress'    Set To Dictionary    ${param}    value=${TCE_IP}
    END
    ${updated_json}=    Evaluate    json.dumps(${json_data}, indent=4)   # RF5
    OperatingSystem.Create File    ${JSON_FILE_PATH}    ${updated_json}
    Log    ${updated_json}

Get tceIpAddressparameter from Info Model
    [Documentation]   This keyword is used to Get tceIpAddress parameter from Info Model.
    Log to console    Get tceIpAddress parameter from Info Model.
    LoginToAdminMplane
    ${tceIpAddress_DICT}=    admin.get_parameters    /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-1/TCE_L-1    connection=mplane
    ${tceIpAddress_param}=    get from dictionary    ${tceIpAddress_DICT}    ipAddress
    Should Be Equal As Strings    ${tceIpAddress_param.strip()}    ${TCE_IP}
    Set Global Variable    ${tceIpAddress_param}
    [Return]    ${tceIpAddress_param}
    [Teardown]    admin.teardown_admin    mplane

Run Python Script CB010361_C
    [Documentation]    This test case runs the specified Python script with given arguments.
    ${my_wireshark_file}    Set Variable    ${wireshark_Logs_path}${/}ute_wireshark_eth3.pcap
    ${COMMAND}    Set Variable    python ${Script_path}/resources/python/Script_Parse_PCDM.py ${my_wireshark_file} CB010361_C
    ${result}=    Run Process    ${COMMAND}    shell=True    timeout=300    cwd=${Script_path}
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Be Equal As Numbers    ${result.rc}    0
    ${stdout}=    Set Variable    ${result.stdout}
    ${status}=    Evaluate    r'The following protocols are not in the input file:' not in r'''${stdout}'''
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Log To Console    The following protocols are not in the input file: ${stdout}
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Fail    Check if PCMD are in the pcap input file. Failed.
    ${dlRbPdcpMeasRecord_numOfPdcpSduTx}=
    ...    Evaluate    r'CuUpVendorExtensionRecordDataType: dlRbPdcpMeasRecord---numOfPdcpSduTx' not in r'''${stdout}'''
    Set Global Variable    ${dlRbPdcpMeasRecord_numOfPdcpSduTx}
    ${dlRbPdcpMeasRecord_numOfPdcpSduTxDiscarded}=
    ...    Evaluate    r'CuUpVendorExtensionRecordDataType: dlRbPdcpMeasRecord---numOfPdcpSduTxDiscarded' not in r'''${stdout}'''
    Set Global Variable    ${dlRbPdcpMeasRecord_numOfPdcpSduTxDiscarded}
    ${ulRbPdcpMeasRecord_numOfPdcpSduRx}=
    ...    Evaluate    r'CuUpVendorExtensionRecordDataType: ulRbPdcpMeasRecord---numOfPdcpSduRx' not in r'''${stdout}'''
    Set Global Variable     ${ulRbPdcpMeasRecord_numOfPdcpSduRx}
    ${ulRbPdcpMeasRecord_numOfPdcpSduRxDiscarded}=
    ...    Evaluate    r'CuUpVendorExtensionRecordDataType: ulRbPdcpMeasRecord---numOfPdcpSduRxDiscarded' not in r'''${stdout}'''
    Set Global Variable    ${ulRbPdcpMeasRecord_numOfPdcpSduRxDiscarded}

Run Python Script CB010361_B_HI_UL_FR1_FDD_SA
    [Documentation]    This test case runs the specified Python script with given arguments.
    ${my_wireshark_file}    Set Variable    ${wireshark_Logs_path}${/}ute_wireshark_eth3.pcap
    ${COMMAND}    Set Variable    python ${Script_path}/resources/python/Script_Parse_PCDM.py ${my_wireshark_file} data_CB010361_B_HI_UL_FR1_FDD_SA
    ${result}=    Run Process    ${COMMAND}    shell=True    timeout=300    cwd=${Script_path}
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Be Equal As Numbers    ${result.rc}    0
    ${stdout}=    Set Variable    ${result.stdout}
    ${status}=    Evaluate    r'The following protocols are not in the input file:' not in r'''${stdout}'''
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Log To Console    The following protocols are not in the input file: ${stdout}
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Fail    Check if PCMD are in the pcap input file. Failed.

    ${ulRbHighRlcMeasRecord_numOfRlcSduRx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: ulRbHighRlcMeasRecord---numOfRlcSduRx' not in r'''${stdout}'''
    Set Global Variable    ${ulRbHighRlcMeasRecord_numOfRlcSduRx}
    ${ulRbHighRlcMeasRecord_sumOfRlcSduRxBytes}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: ulRbHighRlcMeasRecord---sumOfRlcSduRxBytes' not in r'''${stdout}'''
    Set Global Variable    ${ulRbHighRlcMeasRecord_sumOfRlcSduRxBytes}

Run Python Script CB010361_B_HI_DL_FR1_FDD_NSA
    [Documentation]    This test case runs the specified Python script with given arguments.
    ${my_wireshark_file}    Set Variable    ${wireshark_Logs_path}${/}ute_wireshark_eth3.pcap
    ${COMMAND}    Set Variable    python ${Script_path}/resources/python/Script_Parse_PCDM.py ${my_wireshark_file} data_CB010361_B_HI_DL_FR1_FDD_NSA
    ${result}=    Run Process    ${COMMAND}    shell=True    timeout=300    cwd=${Script_path}
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Be Equal As Numbers    ${result.rc}    0
    ${stdout}=    Set Variable    ${result.stdout}
    ${status}=    Evaluate    r'The following protocols are not in the input file:' not in r'''${stdout}'''
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Log To Console    The following protocols are not in the input file: ${stdout}
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Fail    Check if PCMD are in the pcap input file. Failed.

    ${dlRbHighRlcMeasRecord_numOfRlcSduTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: dlRbHighRlcMeasRecord---numOfRlcSduTx' not in r'''${stdout}'''
    Set Global Variable    ${dlRbHighRlcMeasRecord_numOfRlcSduTx}
    ${dlRbHighRlcMeasRecord_sumOfRlcSduTxBytes}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: dlRbHighRlcMeasRecord---sumOfRlcSduTxBytes' not in r'''${stdout}'''
    Set Global Variable    ${dlRbHighRlcMeasRecord_sumOfRlcSduTxBytes}

Run Python Script CB010361_B_LO_DL_FR1_FDD_SA_CA
    [Documentation]    This test case runs the specified Python script with given arguments.
    ${my_wireshark_file}    Set Variable    ${wireshark_Logs_path}${/}ute_wireshark_eth3.pcap
    ${COMMAND}   Set Variable   python ${Script_path}/resources/python/Script_Parse_PCDM.py ${my_wireshark_file} data_CB010361_B_LO_DL_FR1_FDD_SA_CA
    ${result}=    Run Process    ${COMMAND}    shell=True    timeout=300    cwd=${Script_path}
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Be Equal As Numbers    ${result.rc}    0
    ${stdout}=    Set Variable    ${result.stdout}
    ${status}=    Evaluate    r'The following protocols are not in the input file:' not in r'''${stdout}'''
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Log To Console    The following protocols are not in the input file: ${stdout}
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Fail    Check if PCMD are in the pcap input file. Failed.

    # CB010361_B LO
    ${dlRbRlcMeasRecord_numOfRlcPduTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: dlRbRlcMeasRecord---numOfRlcPduTx' not in r'''${stdout}'''
    Set Global Variable    ${dlRbRlcMeasRecord_numOfRlcPduTx}
    ${dlRbRlcMeasRecord_numOfReTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: dlRbRlcMeasRecord---numOfReTx' not in r'''${stdout}'''
    Set Global Variable    ${dlRbRlcMeasRecord_numOfReTx}

    ${caSCellDlRbRlcMeasRecord_numOfRlcPduTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: caSCellDlRbRlcMeasRecord---numOfRlcPduTx' not in r'''${stdout}'''
    Set Global Variable    ${caSCellDlRbRlcMeasRecord_numOfRlcPduTx}
    ${caSCellDlRbRlcMeasRecord_numOfReTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: caSCellDlRbRlcMeasRecord---numOfReTx' not in r'''${stdout}'''
    Set Global Variable    ${caSCellDlRbRlcMeasRecord_numOfReTx}

    ${caSCellUlRbRlcMeasRecord_numOfRlcPduRx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: caSCellUlRbRlcMeasRecord---numOfRlcPduRx' not in r'''${stdout}'''
    Set Global Variable    ${caSCellUlRbRlcMeasRecord_numOfRlcPduRx}
    ${caSCellUlRbRlcMeasRecord_numOfReTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: caSCellUlRbRlcMeasRecord---numOfReTx' not in r'''${stdout}'''
    Set Global Variable    ${caSCellUlRbRlcMeasRecord_numOfReTx}

Run Python Script CB010361_B_LO_UL_FR1_FDD_NSA_CA
    [Documentation]    This test case runs the specified Python script with given arguments.
    ${my_wireshark_file}    Set Variable    ${wireshark_Logs_path}${/}ute_wireshark_eth3.pcap
    ${COMMAND}   Set Variable   python ${Script_path}/resources/python/Script_Parse_PCDM.py ${my_wireshark_file} data_CB010361_B_LO_UL_FR1_FDD_NSA_CA
    ${result}=    Run Process    ${COMMAND}    shell=True    timeout=300    cwd=${Script_path}
    Log    ${result.stdout}
    Log    ${result.stderr}
    Should Be Equal As Numbers    ${result.rc}    0
    ${stdout}=    Set Variable    ${result.stdout}
    ${status}=    Evaluate    r'The following protocols are not in the input file:' not in r'''${stdout}'''
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Log To Console    The following protocols are not in the input file: ${stdout}
    run keyword and continue on failure
    ...    Run Keyword If    '${status}'=='False'    Fail    Check if PCMD are in the pcap input file. Failed.

    # CB010361_B LO without CA UL NSA
    ${ulRbRlcMeasRecord_numOfRlcPduRx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: ulRbRlcMeasRecord---numOfRlcPduRx' not in r'''${stdout}'''
    Set Global Variable    ${ulRbRlcMeasRecord_numOfRlcPduRx}
    ${ulRbRlcMeasRecord_numOfReTx}=
    ...    Evaluate    r'DuVendorExtensionRecordDataType: ulRbRlcMeasRecord---numOfReTx' not in r'''${stdout}'''
    Set Global Variable    ${ulRbRlcMeasRecord_numOfReTx}

Transfer Files
    [Documentation]    Transfer files from current directory to new directory
    [Arguments]    ${wire_path_feature}
    Move File    ${Script_path}/Template_protocol_v1.xlsx    ${wire_path_feature}/Template_protocol_v1.xlsx
    Move File    ${Script_path}/parsed_results.xlsx    ${wire_path_feature}/parsed_results.xlsx
    Move File    ${Script_path}/parsed_results.txt    ${wire_path_feature}/parsed_results.txt
    Move File    ${Script_path}/nsetapx.pdml    ${wire_path_feature}/nsetapx.pdml
    Move File    ${Script_path}/tmp_file_protocol_found.txt    ${wire_path_feature}/tmp_file_protocol_found.txt
    Move File    ${Script_path}/tmp_file_protocol_not_found.txt    ${wire_path_feature}/tmp_file_protocol_not_found.txt

Delete Files
    [Documentation]    Delete specified files before running tests
    Remove File    ${Script_path}/Template_protocol_v1.xlsx
    Remove File    ${Script_path}/parsed_results.xlsx
    Remove File    ${Script_path}/parsed_results.txt
    Remove File    ${Script_path}/nsetapx.pdml
    Remove File    ${Script_path}/tmp_file_protocol_found.txt
    Remove File    ${Script_path}/tmp_file_protocol_not_found.txt

TC Teardown Action
    Produce Scout Data