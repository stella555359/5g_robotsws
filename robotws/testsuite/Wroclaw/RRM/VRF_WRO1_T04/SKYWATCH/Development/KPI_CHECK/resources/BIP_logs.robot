*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Mateusz Bilewicz
...              :contact: mateusz.bilewicz@nokia.com

#Library    ../../CB007262/CB007262_A/CB007262_keywords.py
#Library    ../../CB007813/CB007813-B_keywords.py
Library    taf.collectors.l2stream3  WITH NAME  tcl
Library    taf.collectors.core       WITH NAME  tcc
Library    taf.converters.eventdecoder  WITH NAME  tce
Library    OperatingSystem
Library    taf.transport.ssh  WITH NAME  ssh
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.ul.gnb.bip.collection    WITH NAME    bip_collection

*** Keywords ***
Start Bip Logs Collection
    [Arguments]
    ...    ${Bip_filename}=L1L2_GNB0
    ${executor}    Create Dictionary
    ...    host=192.168.255.1
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


#Start Gathering BIP Logs ASIM
#    [Documentation]     Collect L1L2 BIP Logs using taf.ul.gnb.bip.collection - scripting approach
#    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
#    ...     -   :param bb_mods:   List of BB modules to start collection from them, default: [ABIO]
##    [Arguments]
#    ...     ${alias}=L1L2BIPLogs
#    ...     ${bb_mods}=[ABIO]
#
#    bip_collection.Configure Bip Collection     l1_type=FS
#    ...                                         gNB_common_unit=ASIL
#    ...                                         gNB_capacity_units=${bb_mods}
#    ...                                         use_script=True
#    bip_collection.Start Bip Trace
#    Log to console  BIP logs collecting started
Upload gnbMirroring Script To ASIL
    [Documentation]   Uploads the gnbMirroring.sh script, which sets up and collects L1L2 logs.
    [Arguments]       ${script_folder}=${EXECDIR}/testsuite/Wroclaw/RRM/L2PS_WRO/CB006991/resources/gnbMirroring/ASIL
    ${asik_alias}=    Connect To ASIK
    ${remote_path}=   Set Variable    /ffs/run/config/scripts
    ssh.Execute       command=mkdir ${remote_path}   connection=${asik_alias}
    ssh.Upload File   local_path=${script_folder}/gnbMirroring.sh
    ...               remote_path=${remote_path}/gnbMirroring.sh
    ...               connection=${asik_alias}
    ssh.Upload File   local_path=${script_folder}/gnbMirroringConfig.sh
    ...               remote_path=${remote_path}/gnbMirroringConfig.sh
    ...               connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/gnbMirroring.sh         connection=${asik_alias}
    ssh.Execute       command=chmod +x ${remote_path}/gnbMirroringConfig.sh   connection=${asik_alias}

Stop gnbMirroring And Gather L1L2 Bip Logs ASIM
    [Documentation]     Stop collecting BIP Logs and save them at selected location
    ...     -   :param alias:       Alias for l1l2bip which is also a directory name without spaces (default L1L2_BIP_Logs)
    ...     -   :param dir_path:    Path where BIP logs should be copied (default ${OUTPUT_DIR}/
    ...     -   :param delay:       Time to wait before collecting the logs
    [Arguments]
    ...     ${alias}=L1L2BIPLogs
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
#    ...            ${smod}=None
    Run On Gnb    cmd=pkill tcpdump
    Run On Gnb    cmd=bsh 0:1 pkill tcpdump
    Run On Gnb    cmd=bget 0:1 /tmp/tcpdump.pcap /tmp
    ssh.download_file    remote_path=${remote_bip_path}    local_path=${local_bip_path}    connection=ASIB
    [Teardown]    Run On Gnb    cmd=rm /tmp/tcpdump.pcap
