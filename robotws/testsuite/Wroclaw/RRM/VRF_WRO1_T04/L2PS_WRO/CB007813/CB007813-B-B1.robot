*** Settings ***
Documentation
...    copyright: Nokia
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)

Force Tags    CLOUD_5G_I_BO_AP_KL_SANSA_FS_CPRI_CMWV_FDD    RAN_5G    RAN_5G_FDD    CRT     SBTS00    SBTS22R4    SBTS23R1

Resource     ../resources/5G_SW_WRO_Keywords.robot
Library      ../resources/Python/webem_alarms.py
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library    ta5g_pm_counters
Library    ../CB007262/CB007262_A/CB007262_keywords.py
Library    CB007813-B_keywords.py


Suite Setup    Run Keywords    Update Iphy Configuration And Modify Swconfig
    ...                        iphy_xml_filepath=${CURDIR}/config/iphy_AHFIB_7813_B.xml
    ...                        swconfig_flags_list=@{SWCONFIG_FLAGS}
    ...        AND             Start Default Logging
    ...        AND             Find Scfc And Fix And Send Full Commissioning
    ...                        scfc_filename=full_cb007813_AHFIB_4x4.xml
    ...        AND             Check Radios Availability
    ...        AND             Reach Onair    lua_cfg=${CURDIR}/config/basic_setup_7813-B.cfg


Suite Teardown   Run Keywords    Print Active Alarms
    ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SMOD}    ASIB
${GNB_IP}    192.168.255.129
${NOKIA_USERNAME}    toor4nsn
${NOKIA_PASS}    oZPS0POrRieRtu
@{SWCONFIG_FLAGS}=     0x340000 = 5
${PRB_AVAIL_PDSCH}=    M55308C10003
${DL_DATA_SLOTS}=      M55308C00001
${LOCAL_MOID}=         PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

*** Test Cases ***
CB007813_B1_FDD_Cell_configuration_and_setup_with_BW_30MHz_DL_and_10MHz_UL_nulling_middle_PRBs_DL__CSI-IM_and_TRS_configured_full_BW_SA
    Collect BIP logs and verify CSI-RS scheduling
    Set Internal Traffic Type To UE
    Attach Ue    ue_id=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    Start DL and UL Data Traffic
    Verify Tput For UE SA    ue_id=1    dir=dl    expected_tput=220
    Verify Tput For UE SA    ue_id=1    dir=ul    expected_tput=70
    Verify If PRBs in the GB have been removed from the available PRBs
    [Teardown]    Stop All Data Transfers And Detach UE SA

CB007813_B1_FDD_Cell_configuration_and_setup_with_BW_30MHz_DL_and_10MHz_UL_nulling_middle_PRBs_DL__CSI-IM_and_TRS_configured_full_BW_NSA
    Collect BIP logs and verify CSI-RS scheduling
    Attach Ue To Enb And Start Gnb Addition    ue_id=11   target_cells=1
    Start DL and UL Data Traffic NSA
    Verify Tput For UE NSA    ue_id=11    id=2    dir=dl    unit=M    expected_tput=110
    Verify Tput For UE NSA    ue_id=11    id=2    dir=ul    unit=M    expected_tput=30
    Verify If PRBs in the GB have been removed from the available PRBs
    [Teardown]    Stop All Data Transfers And Detach UE NSA

*** Keywords ***
Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal

Start DL and UL Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=175
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=100 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=85
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1
    Sleep    30s

Start DL and UL Data Traffic NSA
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=175
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=dl mbps=100 trf_id=2
    Execute Egate Command    cmd=trf_data_start id=2 ue=11 dir=ul mbps=40
    Sleep    30s

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Verify Tput For UE NSA
    [Arguments]   ${ue_id}    ${id}    ${dir}    ${unit}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic Nsa    ue_id=${ue_id}    id=${id}    dir=${dir}    unit=${unit}
    Should Be True    ${avg_tput} > ${expected_tput}

Attach Ue To Enb And Start Gnb Addition
    [Arguments]    ${ue_id}    ${target_cells}
    Attach Ue To Enb    ue_id=${ue_id}
    Start Gnb Addition Procedure
    ...    ue=${ue_id}
    ...    target_cells=${target_cells}
    ...    target_gnb=2
    ...    bearer=2
    ...    dc_type=split_scg

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Stop All Data Transfers And Detach UE NSA
    Execute Egate Command    cmd=trf_data_stop id=2 ue=11
    Sleep    5s
    Execute Egate Command    cmd=ue_detach id=11

Setup And Start Bip Logs
    [Arguments]    ${target_file_name}=tcpdump
     ${webservice}=  Create Dictionary
     ...  host=192.168.255.129
     ...  user=Nemuadmin
     ...  password=nemuuser
     ...  port=443

     create_interface_mirroring_l1l2bip_collector
     ...  name=tcpdump
     ...  webservice=${webservice}
     ...  target_file_name=tcpdump
     ...  timeout=240
     ...  remove_zip_file=False
     core.setup_collectors    names=tcpdump
     core.start_collectors    names=tcpdump
     core.Set Suite Alias     ${target_file_name}

Stop And Collect Bip Logs
     core.stop_collectors    names=tcpdump
     core.collect_collectors    names=tcpdump    target_dir=${OUTPUT_DIR}
     core.teardown_collectors    names=tcpdump

Convert pcap file to pdml
    [Documentation]     Using luashark converting BIP log from pcap to pdml.
    [Arguments]   ${input_file}=${OUTPUT_DIR}/${TEST_NAME}/tcpdump.pcap
    Create Directory    ${OUTPUT_DIR}/${TEST_NAME}
#    Move File    ${OUTPUT_DIR}/CB007813-B-B1/tcpdump.pcap    ${OUTPUT_DIR}/${TEST_NAME}    #old bip collecting method
    Move File    ${OUTPUT_DIR}/tcpdump/BTS*.pcap    ${OUTPUT_DIR}/${TEST_NAME}/tcpdump.pcap
    Remove Directory    ${OUTPUT_DIR}/tcpdump/
    Log to console    Converting pcap to pdml
        ${tshark_cmd} =   Catenate    tshark
    ...    -r ${input_file}
    ...    -Y dldata_csirssendreq
    ...    -T pdml > ${OUTPUT_DIR}/${TEST_NAME}/BIP_log_CSIRS.pdml
    Run    ${tshark_cmd}
    Log to console    Pcap->Pdml conversion done...

Verify CSI-RS scheduling
    verify_csi_rs_split    pdml_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_log_CSIRS.pdml
    verify_trs_split    pdml_path=${OUTPUT_DIR}/${TEST_NAME}/BIP_log_CSIRS.pdml

Collect BIP logs and verify CSI-RS scheduling
    Setup And Start Bip Logs
    Sleep    3s
    Stop And Collect Bip Logs
    Convert pcap file to pdml
    Verify CSI-RS scheduling

Get Number Of Available PRBs
    Wait For Next Full Pm Interval
    ${PM_COUNTERS_FILE}=    Get Latest Unpacked Raw Pm Counters File
    ${VALUE_OF_PRB_AVAIL_PDSCH}=    Get Latest Pm Counter Value     counter_id=${PRB_AVAIL_PDSCH}
    ...    local_moid=${LOCAL_MOID}    filepath=${PM_COUNTERS_FILE}
    ${VALUE_OF_DL_DATA_SLOTS}=      Get Latest Pm Counter Value     counter_id=${DL_DATA_SLOTS}
    ...    local_moid=${LOCAL_MOID}    filepath=${PM_COUNTERS_FILE}
    ${AVAILABLE_PRBS}=    Evaluate     ${VALUE_OF_PRB_AVAIL_PDSCH}/${VALUE_OF_DL_DATA_SLOTS}
    [Return]    ${AVAILABLE_PRBS}

Verify If PRBs in the GB have been removed from the available PRBs
    ${AVAILABLE_PRBS}=    Get Number Of Available PRBs
    Should Be True    ${AVAILABLE_PRBS} == 144

#old BIP collecting method (script-based)
Prepare gNB For Bip Log Collection
    Run On Gnb
    ...    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 5 -l eths2 -v 303
    Run On Gnb
    ...    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 5 -l eths2 -v 303
    Run On Gnb    cd /usr/bin;ncp_portmirror -p xgmac97 -r
    Run On Gnb    cd /usr/bin;ncp_portmirror -d netdriver -p xgmac97

Start BIP log collection
    Create Directory    ${OUTPUT_DIR}/CB007813-B-B1
    Prepare gNB For Bip Log Collection
    Setup Biplog Collection
    Start Collection

Setup Biplog Collection
    Run On Gnb    cmd=echo 1 > /var/run/cpss/ports/2/enable
    Run On Gnb    cmd=ip link set eths2 up
    Run On Gnb    cmd=ncp_portmirror -d netdriver -p xgmac97
    Run On Gnb    cmd=echo 2 both > /var/run/cpss/ports/4/mirroring_port
    Run On Gnb    cmd=echo 2 both > /var/run/cpss/ports/5/mirroring_port
    Run On Gnb    cmd=echo 2 both > /var/run/cpss/ports/6/mirroring_port
    Run On Gnb    cmd=ncp_l2 -p XGMAC97 -I -senableSwitching.false
    Run On Gnb    cmd=ncp_l2 -p XGMAC97 -i -sdiscardInvalidVlanidPackets.false
    Run On Gnb    cmd=ncp_l2 -p XGMAC97 -i -sdiscardBadLengthPackets.false
    Run On Gnb    cmd=dbgrrc mirror sport 20 dport 3 e b && dbgrrc mirror sport 21 dport 3 e b
    Run On Gnb    cmd=dbgrrc mirror sport 15 dport 3 e b

Start Collection
    [Arguments]    ${host}=${GNB_IP}    ${user}=${NOKIA_USERNAME}  ${password}=${NOKIA_PASS}
    ssh.Connect To    hostname=${host}    username=${user}    password=${password}    alias=ASIB
    ${filter}=    Get Gnb Bip Filter
    ssh.Send Command    command=nohup tcpdump -i eths2 -w /tmp/tcpdump.pcap -vvv ${filter}    connection=ASIB

Get Gnb Bip Filter
    [Documentation]      Create specific BIP filter
    ...                  Creation Date: 19.01.2021
    ...                  Modified Date:
    ...                  Last Modified by: mateusz.pajor@nokia.com

    ${gnb_bip_filter}=    Catenate
    ...    'ether[0x18:2]!=0xe101 && ether[0x18:2]!=0x122 && ether[0x18:2]!=0x131 && ether[0x18:2]!=0x127
    ...    && ether[0x18:2]!=0xf2ff && ether[0x18:2]!=0xf31b && ether[0x18:2]!=0x240 && ether[0x18:2]!=0xe105
    ...    && ether[0x18:2]!=0xe206'
    [Return]    ${gnb_bip_filter}

Stop BIP log collection
    Stop Biplog Collection And Download Biplog

Stop Biplog Collection And Download Biplog
    [Arguments]    ${remote_bip_path}=/tmp/tcpdump.pcap
    ...            ${local_bip_path}=${OUTPUT_DIR}/${SUITE_NAME}/tcpdump.pcap
    Run On Gnb    cmd=pkill tcpdump
    Run On Gnb    cmd=bsh 0:1 pkill tcpdump
    Run On Gnb    cmd=bget 0:1 /tmp/tcpdump.pcap /tmp
    ssh.download_file    remote_path=${remote_bip_path}    local_path=${local_bip_path}    connection=ASIB
    [Teardown]    Run On Gnb    cmd=rm /tmp/tcpdump.pcap
