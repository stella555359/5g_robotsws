*** Settings ***
Documentation
...    copyright: Nokia
...    authors: Mateusz Bilewicz (mateusz.bilewicz@nokia.com
...    maintainer: Wojciech Szczesniak (wojciech.szczesniak@nokia.com)
...    testline: CLOUD_5G_I_MP_AP_LO
...    variant: SANSA_FS_CPRI_CMWV_FDD

Library    taf.collectors.l2stream3  WITH NAME  tcl
Library    taf.collectors.core       WITH NAME  tcc
Library    taf.converters.eventdecoder  WITH NAME  tce
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.ul.gnb.bip.collection    WITH NAME    bip_collection

*** Variables ***
${SMOD}                 ASIB
${GNB_IP}               192.168.255.129
${NOKIA_USERNAME}       toor4nsn
${NOKIA_PASS}           oZPS0POrRieRtu

*** Keywords ***
Commmon Test Setup
    [Arguments]    ${iphy_config_file_name}   ${scf_file_name}   ${lua_config_file_name}
    Update Iphy Configuration And Modify Swconfig    iphy_xml_filepath=${iphy_config_file_name}
    Find Scfc And Fix And Send Full Commissioning    scfc_filename=${scf_file_name}
    Check Radios Availability
    Reach Onair    lua_cfg=${lua_config_file_name}

Start Bip Logs Collection
    [Arguments]
    ...    ${Bip_filename}=L1L2_GNB0
    ${executor}    Create Dictionary
    ...    host=192.168.255.129
    ...    user=toor4nsn
    ...    password=oZPS0POrRieRtu
    tcpdump.create_tcpdump_collector
    ...    name=${Bip_filename}
    ...    options=-i any
    ...    executor=${executor}
    tcc.setup_collectors    names=${Bip_filename}
    tcc.start_collectors    names=${Bip_filename}
    tcc.set_suite_alias     ${Bip_filename}

Stop Bip Logs Collection
    [Arguments]
    ...    ${Bip_filename}=L1L2_GNB0
    tcc.stop_collectors        names=${Bip_filename}
    tcc.collect_collectors     names=${Bip_filename}    target_dir=${OUTPUT_DIR}
    tcc.teardown_collectors    names=${Bip_filename}

Install OFEGSA RU
    [Arguments]
    ...    ${sh_path}
    Run    chmod +x ${sh_path}
    Run    sh ${sh_path}
    Log to console    \nInstalling OFEGSA radio

Start Gathering BIP Logs ASIM
    [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
    [Arguments]
    ...     ${bb_mods}=[ABIO]

    bip_collection.Configure Bip Collection     l1_type=FS
    ...                                         gNB_common_unit=ASIM
    ...                                         gNB_capacity_units=${bb_mods}
    ...                                         use_script=True
    bip_collection.Start Bip Trace
    Log to console  BIP logs collecting started

Stop gnbMirroring And Gather L1L2 Bip Logs ASIM
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${dir_path}=${OUTPUT_DIR}
    ...     ${delay}=0
    Sleep  ${delay}
    Create directory  path=${dir_path}/${alias}
    Create directory  path=/tmp/${alias}
    bip_collection.Stop Bip Trace   target_dir=/tmp/${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/tcpdump*.pcap* -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
    Copy File    /tmp/${alias}/tcpdump.pcap    ${dir_path}/${alias}/BIP_L1L2.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished

Start TTI trace
    ${configurations}=  tcc.Load Configurations
    ...  ${CURDIR}/ttitrace_collectors.yaml
    tcc.Create collectors
    ...  names=l2stream3
    ...  configurations=${configurations['collectors']}
    tcl.Set suite alias
    ...  alias=l2stream3
    tcc.Setup collectors
    ...  names=l2stream3
    tcc.Start collectors
    ...  names=l2stream3

Stop TTI trace
    tcc.Stop collectors
    ...  names=l2stream3
    tcc.Collect collectors
    ...  names=l2stream3
    tcc.Teardown collectors
    ...  names=l2stream3

Convert TTI trace from pcap to excelCsv
    tce.Create eventDecoder converter
    ...  name=ttitrace_converter
    ...  input_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/l2stream3/tcpdump/tcpdump.pcap
    ...  output_file_format=excelCsv
    ...  output_file_path=${OUTPUTDIR}/${SUITENAME}/${TESTNAME}/output
    tce.Convert
    ...  name=ttitrace_converter


Activate L1Bypass ABIO
   ${domain_id}=    Execute Enb Command    cmd=ddal -s ddal_sysinfo_module_get_domain_id 0 | egrep -o '[12]'
   Execute Enb Command    cmd=echo "tag -3w app.btsom.nts.L1BypassMap 0x${domain_id}24D:0x574A" | nc 0 15007

Set Internal Traffic Type To UE
    Execute Egate Command   cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command   cmd=set_pdu_param ue=2 pdu=2 trf_type=internal

Activate RI profile
    Execute Egate Command   cmd=csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=2
    Execute Egate Command   cmd=ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1

Start DL and UL Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=dl mbps=10
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:1 Pdu:1 Qfi:1 TrfId:1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 dir=ul mbps=5
    ...    pass_regexp=Started Uplink Internal traffic Receiver on Ue:1 UpfId:1 Pdu:1 Qfi:1 TrfId:1

Start DL Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=2 pdu=2 dir=dl mbps=10
    ...    pass_regexp=Started Downlink Internal traffic Receiver on Ue:2 Pdu:2 Qfi:1 TrfId:1

Verify Tput For UE SA
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=0   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE SA
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1
    Sleep    5s
    Execute Egate Command    cmd=ue_deregister id=1 ue_deregister_type=switch_off

Prepare gNB For Bip Log Collection
    Run On Gnb
    ...    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 5 -l eths2 -v 303
    Run On Gnb
    ...    cd /usr/bin;./lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 5 -l eths2 -v 303
    Run On Gnb    cd /usr/bin;ncp_portmirror -p xgmac97 -r
    Run On Gnb    cd /usr/bin;ncp_portmirror -d netdriver -p xgmac97

Start BIP log collection
    Create Directory    ${OUTPUT_DIR}/CB009086
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
    Stop Biplog Collection And Download Biplog    smod=${SMOD}

Stop Biplog Collection And Download Biplog
    [Arguments]    ${remote_bip_path}=/tmp/tcpdump.pcap
    ...            ${local_bip_path}=${OUTPUT_DIR}/CB009086/tcpdump.pcap
    Run On Gnb    cmd=pkill tcpdump
    Run On Gnb    cmd=bsh 0:1 pkill tcpdump
    Run On Gnb    cmd=bget 0:1 /tmp/tcpdump.pcap /tmp
    ssh.download_file    remote_path=${remote_bip_path}    local_path=${local_bip_path}    connection=ASIB
    [Teardown]    Run On Gnb    cmd=rm /tmp/tcpdump.pcap
