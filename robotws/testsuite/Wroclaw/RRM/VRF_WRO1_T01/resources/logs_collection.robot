*** Settings ***
Library    taf.collectors.l1l2bip    WITH NAME    l1l2bip
Library    taf.collectors.core    WITH NAME    core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.l2stream3    WITH NAME    l2stream3
Library    taf.collectors.snapshot

Documentation
...    This file contains keywords used to collect logs.

*** Variables ***
${preferences}  ${CURDIR}/wireshark_settings/bip_fmc/preferences
${drb_bearerconfig}  ${CURDIR}/wireshark_settings/bip_fmc/drb_bearerconfig

*** Keywords ***
Start L1l2bip Mirroring
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=l1l2bip
    ...  webservice=${webservice}
    ...  timeout=300
    core.setup_collectors    names=l1l2bip
    core.start_collectors    names=l1l2bip
    core.Set Suite Alias     l1l2bip

Stop L1l2bip Mirroring
     [Arguments]
     ...     ${dir_path}=${OUTPUT_DIR}
     ...     ${file_name}=BIP_L1L2.pcap
    core.stop_collectors    names=l1l2bip
    core.collect_collectors    names=l1l2bip       target_dir=${OUTPUT_DIR}
    core.teardown_collectors    names=l1l2bip
    ${rc}=    Run And Return Rc  mergecap -a ${dir_path}/l1l2bip/*mirroring_L2L1*.pcap* -w /tmp/tcpdump.pcap
     Run keyword if    ${rc}!=0    Fail    PCAP merging failed, check if alias does not contain spaces
     Copy File    /tmp/tcpdump.pcap    ${dir_path}/l1l2bip/${file_name}
     Remove Directory    ${OUTPUT_DIR}/tcpdump
     Remove Files    ${dir_path}/l1l2bip/*mirroring_L2L1*.pcap*    /tmp/tcpdump.pcap
     ...                 recursive=True

Setup wireshark for pdcp decoding in L1L2 bip
    Run  chmod 777 /home/ute/.config/wireshark/preferences
    Run  chmod 777 /home/ute/.config/wireshark/drb_bearerconfig
    log to console  ${CURDIR}
    ${output1}  Run  cp -f ${preferences} /home/ute/.config/wireshark/
    ${output2}  Run  cp -f ${drb_bearerconfig} /home/ute/.config/wireshark/

Prepare BIP column for pdcp sn
    @{BIP_columns_artime}  Create List
    Append To List  ${BIP_columns_artime}  pdcp-nr.fmc
    Append To List  ${BIP_columns_artime}  pdcp-nr.seq-num
    Set test variable  @{BIP_columns_artime}

Convert BIP logs pcap to csv
    [Arguments]    ${pcap_path}    ${filter}    ${columns}    ${dir_path}=${OUTPUT_DIR}    ${csv_log_name}=BIP_Logs.csv

    Log to console    Filter and Converting BIP Log Pcap to csv...

    ${columns_string}    Catenate    SEPARATOR=${SPACE}-e${SPACE}  @{columns}
    ${cmd}      catenate    tshark
    ...         -r ${pcap_path}
    ...         -Y "${filter}"
    ...         -T fields -e ${columns_string}
    ...         -E header=y -E separator=";", -E occurrence=a > ${dir_path}${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    Log to console    ...conversion done

    [Return]    ${dir_path}${csv_log_name}

Collect Snapshot
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    create_sbts_snapshot_collector
    ...  name=gnb_sbts_snapshot
    ...  webservice=${webservice}
    ...  coverage=Full
    ...  force=False
    ...  timeout=480
    taf.collectors.snapshot.setup_collectors
    ...  names=gnb_sbts_snapshot
    taf.collectors.snapshot.collect_collectors
    ...  names=gnb_sbts_snapshot
    taf.collectors.snapshot.teardown_collectors
    ...  names=gnb_sbts_snapshot

Collect L2Hi and L2Lo Component Traces
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${l2_stream_config_1}=  Create Dictionary
    ...  nr_phy_cell_ids=50
    ...  up_sw=L2Lo
    ${l2_stream_config_2}=  Create Dictionary
    ...  nr_phy_cell_ids=50
    ...  up_sw=L2HiRlc
    ${l2_stream_config_3}=  Create Dictionary
    ...  up_sw=L2HiPdcp
    @{l2_stream_configuration}    Create List    ${l2_stream_config_1}    ${l2_stream_config_2}    ${l2_stream_config_3}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth3 udp and dst 10.0.1.1 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.0.1.1
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3
    sleep    10s
    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3
    core.teardown_collectors    names=l2stream3
