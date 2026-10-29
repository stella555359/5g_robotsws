*** Settings ***
Documentation    Generic keywords for log collection


Library    Collections
Library    OperatingSystem
Library    Process
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.collectors.l1l2bip       WITH NAME    l1l2bip
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.l2stream3     WITH NAME    l2stream3
Library    taf.converters.eventdecoder  WITH NAME    eventdecoder
Library    ta_logcollector
Library    taf.ul.gnb.bip.collection    WITH NAME    bip_collection
Library    taf.collectors.syscomdump    WITH NAME    syscomdump
Library    taf.collectors.tshark        WITH NAME    tshark
Library    ta5g_tshark
Library    ute_tshark

*** Variables ***
${gnb_host}=        192.168.255.129
${gnb_user}=        Nemuadmin
${gnb_password}=    nemuuser

*** Keywords ***
Start collecting BIP logs
    [Documentation]     Collect L1L2 BIP Logs
    ...     Create BIP trace collector, that uses ADMIN API request "interfaceMirroring"
    ...     Script repository: https://gitlabe2.ext.net.nokia.com/juhakang/tools/tree/master/gnbMirroring
    ...     -   :param alias:     Alias for l1l2bip which is also a directory name (default L1L2_BIP_Logs)
    ...     -   :param interface: (Optional) either "L1-L2" or "L2Hi-L2Lo", default value "L1-L2"
    ...     -   :param options:   Addtional options for tcpdump e.g. set bip filter (default empty)
    ...     -   :param mirroring_filter: Optional, ["Default" | "AllMessages" | "SpecificL1L2Messages"].
    ...                                    Only supported when interface is 'L1-L2' and destination is 'Local'.
    ...                                    Only available from SBTS24R1 onwards.
    ...     -   :param specific_message_ids: Optional, only supported when mirroring_filter is 'SpecificL1L2Messages'.
    ...                                      string using comma separate. Must be in hex format. e.g :
    ...                                      '0xE3F3,0x0A00'

    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    # ...     ${interface}=Any
    ...     ${mirroring_filter}=${None}
    ...     ${specific_message_ids}=${None}

    ${webservice}=  Create Dictionary
    ...    host=${gnb_host}
    ...    user=${gnb_user}
    ...    password=${gnb_password}
    ...    port=443
    l1l2bip.create_interface_mirroring_l1l2bip_collector
    ...  name=${alias}
    ...  webservice=${webservice}
    ...  mirroring_filter=${mirroring_filter}
    ...  specific_message_ids=${specific_message_ids}
    ...  merge_pcap_files=${False}
    ...  timeout=300
    l1l2bip.Set suite alias  ${alias}
    core.setup_collectors    names=${alias}
    core.start_collectors    names=${alias}
    Log to console  BIP logs collecting started

Stop collecting BIP logs
    [Documentation]   Stop collectors for BIP Logs
    ...     -   :param alias:       Alias for l1l2bip
    ...     -   :param dir_path:    Path where to store BIP logs.

    [Arguments]
    ...     ${alias}=L1L2_BIP_Logs
    ...     ${log_dirpath}=${OUTPUT_DIR}/${TEST_NAME}
    core.stop_collectors  names=${alias}
    core.collect_collectors  names=${alias}  target_dir=/tmp
    core.teardown_collectors  names=${alias}
    ${rc}=    Run And Return Rc  mergecap -a /tmp/${alias}/BTS*.pcap -w /tmp/${alias}/tcpdump.pcap
    Run keyword if    ${rc}!=0    Fail    PCAP merging failed
    Copy File    /tmp/${alias}/tcpdump.pcap    ${log_dirpath}/${alias}/L1L2_BIP_tcpdump.pcap
    Remove directory    /tmp/${alias}    recursive=True
    Log to console  BIP logs collecting finished
    [Return]    ${log_dirpath}/${alias}/L1L2_BIP_tcpdump.pcap

Convert pcap trace to csv
    [Arguments]    ${pcap_path}    ${filter}    ${columns}    ${dir_path}=${OUTPUT_DIR}
    ...            ${csv_log_name}=L1L2_BIP_Logs.csv
    [Documentation]    This keyword converts BIP logs pcap to csv
    ...     -   :param pcap_path:       Path to BIP logs pcap
    ...     -   :param filter:          Filter (e.g. dldata_slottypereq || dldata_pdcchsendreq)
    ...     -   :param dir_path:        Path for output csv file (default OUTPUT_DIR)
    ...     -   :param csv_log_name:    csv file name (default BIP_Logs.csv)
    ...     -   :param columns:         Fields name to be collect in csv
    ...         (e.g. DlData_SlotTypeReq.SlotTypeReq.slot  DlData_SlotTypeReq.SlotTypeReq.slotType)

    Log to console    Converting BIP Log Pcap to csv...

    ${columns_string}    Catenate    SEPARATOR=${SPACE}-e${SPACE}  @{columns}
    ${cmd}      catenate    tshark
    ...         -r ${pcap_path}
    ...         -Y "${filter}"
    ...         -T fields -e ${columns_string}
    ...         -E header=y -E separator=/t -E occurrence=a > ${dir_path}/${csv_log_name}
    ${rc}    OperatingSystem.Run And Return RC    ${cmd}

    Log to console    ...conversion done

    [Return]    ${dir_path}/${csv_log_name}

#----- PCAP collection ---------------------------------------------------------------------------------------------
Start GNB tcpdump Collection
    [Documentation]    Starts tcpdump collection of SCTP packets on GNB
    ...                which includes SYSCOM/NGAP/X2AP/XnAP/E1AP/F1AP protocols.
    ...                Saves filepath to test variable TEST_tcpdump_gnb_path.
    ...                - ``log_dir``: Directory for PCAP, Default: ``$\{TEST_log_dir\}/Wireshark/``
    [Arguments]    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    ...            ${ssh_ip}=192.168.255.129
    Log to Console    Starting SCTP packet capture on GNB
    ${proc}    ${filepath}    ${alias}    ta5g_tshark.start_tcpdump_on_remote_interface
    ...    log_dirpath=${log_dir}
    ...    log_filename_prefix=tcpdump_SYSCOM_NG_X2_Xn_E1_F1
    ...    alias=tshark_gnb_sctp
    ...    ssh_ip=${ssh_ip}
    Set Test Variable    ${TEST_tcpdump_gnb_path}    ${filepath}
    # Set Test Variable    ${TEST_tcpdump_gnb_state}    STARTED

Stop GNB tcpdump Collection
    [Documentation]    Stops tcpdump collection of SCTP packets on GNB. Returns path to collected PCAP file.
    # ${state}    Get Variable Value    ${TEST_tcpdump_gnb_state}    STOPPED
    # Return From Keyword If    '${state}' == 'STOPPED'
    Log to Console    Stopping SCTP packet capture on GNB
    ta5g_tshark.stop_tcpdump_on_remote_interface
    ta5g_tshark.stop_tshark    alias=tshark_gnb_sctp
    # Set Test Variable    ${TEST_tcpdump_gnb_state}    STOPPED
    File Should Exist    ${TEST_tcpdump_gnb_path}
    [Return]    ${TEST_tcpdump_gnb_path}


Remove WireShark Plugins
    [Documentation]    This keyword will remove the wireshark plugin
    ${plugin_dir}=     Run  tshark -G folders | grep "Personal Plugins:" | awk '{print $3}'
    Run  rm -f ${plugin_dir}/epan/*
