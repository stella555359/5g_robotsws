*** Settings ***
Documentation   Collection of pcap analysis KWs
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library         XML
Library	        Collections
Library         String
Library         ute_tshark
Library         ../../resources/Common/python/MCSharkDissectors.py

*** Keywords ***

Get Measurement Mapping
    [Documentation]
    ...     extracts measurement configuration from wireshark trace
    ...	    creates a dictionary phycell_events with defined measurement events per
    ...     physical cell id
    ...     | pcap_file | wireshark trace file  |
    ...     afterwards  ${phycell_events}[<physicalcellid>]  gives the defined events
    ...
    [Arguments]   ${pcap_file}  ${protocol_name}=f1ap
    &{measobjid}       Create Dictionary
    &{reportid}        Create Dictionary
    &{measid_measobj}  Create Dictionary
    &{measid_report}   Create Dictionary
    &{phys_freq}       Create Dictionary
    &{phycell_events}  Create Dictionary
    &{freq_events}     Create Dictionary
    ${meas_mapping}    Create List
    ${meas_mapping_single}  Create List
    #
    Set Test Variable  ${measobjid}
    Set Test Variable  ${reportid}
    Set Test Variable  ${measid_measobj}
    Set Test Variable  ${measid_report}
    Set Test Variable  ${phys_freq}
    Set Test Variable  ${phycell_events}
    Set Test Variable  ${freq_events}
    Set Test Variable  ${meas_mapping}
    Set Test Variable  ${meas_mapping_single}
    #
    ${packet_filter}  Set Variable  ${protocol_name}.measConfig||nr-rrc.measObjectToAddModList
    ${output}    ute_tshark.Read Pcap    packet_filter=${packet_filter}    output_type=pdml    pcap_file_path=${pcap_file}
    @{frames}=  XML.Get Elements  ${output}  .//field[@showname='MeasObjectToAddMod']
    FOR  ${element}  IN  @{frames}
        Get Measobj  ${element}
    END
    @{frames}=  XML.Get Elements  ${output}  .//field[@showname='ReportConfigToAddMod']
    FOR  ${element}  IN  @{frames}
        Get Reportconfig  ${element}
    END
    @{frames}=  XML.Get Elements  ${output}  .//field[@showname='MeasIdToAddMod']
    FOR  ${element}  IN  @{frames}
        Get Measid  ${element}
    END
   @{frames}=  XML.Get Elements  ${output}  .//field[@showname='SCellConfig']
    FOR  ${element}  IN  @{frames}
        Get Phycell Freq  ${element}
    END
   @{frames}=  XML.Get Elements  ${output}  .//field[@showname='spCellConfigCommon']
    FOR  ${element}  IN  @{frames}
        Get Phycell Freq  ${element}
    END
    FOR  ${key}  IN  @{measid_measobj}
      ${freq}  Collections.Get From Dictionary  ${measid_measobj}  ${key}
      Collections.Set To Dictionary  ${freq_events}  ${freq}=Events:
    END
    Log Dictionary  ${measobjid}
    Log Dictionary  ${reportid}
    Log Dictionary  ${measid_measobj}
    Log Dictionary  ${measid_report}
    Log Dictionary  ${phys_freq}
    ${meas_mapping_single}  Remove Duplicates  ${meas_mapping}
    Log List  ${meas_mapping_single}
    FOR  ${key}  IN  @{measid_measobj}
      ${freq}  Collections.Get From Dictionary  ${measid_measobj}  ${key}
      ${foo}  Catenate  ${freq_events}[${freq}]  ${measid_report}[${key}]
      Collections.Set To Dictionary  ${freq_events}  ${freq}=${foo}
    END
    FOR  ${key}  IN  @{phys_freq}
      ${freq}  Set Variable  ${phys_freq}[${key}]
      Collections.Set To Dictionary  ${phycell_events}  ${key}=${freq_events}[${freq}]
    END

Get Measobj
    [Documentation]
    ...     gets measurement objects from given pdml snippet
    ...     | child | wireshark trace snippet in pdml   |
    ...
    [Arguments]    ${child}
    ${foo}=  XML.Get Element  ${child}  field[@name='nr-rrc.measObjectId']
    ${id}  XML.Get Element Attribute  ${foo}  show
    ${foo}=  XML.Get Element  ${child}  .//field[@name='nr-rrc.ssbFrequency']
    ${freq}  XML.Get Element Attribute  ${foo}  show
    Collections.Set To Dictionary  ${measobjid}  ${id}=${freq}

Get Reportconfig
    [Documentation]
    ...     gets reportconfig objects from given pdml snippet
    ...     | child | wireshark trace snippet in pdml   |
    ...
    [Arguments]    ${child}
    ${foo}=  XML.Get Element  ${child}  field[@name='nr-rrc.reportConfigId']
    ${id}  XML.Get Element Attribute  ${foo}  show
    ${foo}=  XML.Get Element  ${child}  .//field[@name='nr-rrc.eventId']
    ${event}  XML.Get Element Attribute  ${foo}  showname
    @{items}  String.Split String  ${event}
    Collections.Set To Dictionary  ${reportid}  ${id}=${items}[1]

Get Measid
    [Documentation]
    ...     gets measurement ids and relations from given pdml snippet
    ...     | child | wireshark trace snippet in pdml   |
    ...
    [Arguments]    ${child}
    ${foo}=  XML.Get Element  ${child}  field[@name='nr-rrc.measId']
    ${id}  XML.Get Element Attribute  ${foo}  show
    ${foo}=  XML.Get Element  ${child}  .//field[@name='nr-rrc.measObjectId']
    ${measobj}  XML.Get Element Attribute  ${foo}  show
    ${foo}=  XML.Get Element  ${child}  .//field[@name='nr-rrc.reportConfigId']
    ${report}  XML.Get Element Attribute  ${foo}  show
    ${freq}  Collections.Get From Dictionary  ${measobjid}  ${measobj}
    ${event}  Collections.Get From Dictionary  ${reportid}  ${report}
    Collections.Set To Dictionary  ${measid_measobj}  ${id}=${freq}
    Collections.Set To Dictionary  ${measid_report}  ${id}=${event}
    ${item}  Catenate  SEPARATOR=-  ${id}  ${measobj}  ${freq}  ${report}  ${event}
    Collections.Append to List  ${meas_mapping}  ${item}

Get Phycell Freq
    [Documentation]
    ...     gets physical cell and ssbfreq from given pdml snippet
    ...     | child | wireshark trace snippet in pdml   |
    ...
    [Arguments]    ${child}
    ${foo}=  XML.Get Element  ${child}  .//field[@name='nr-rrc.physCellId']
    ${id}  XML.Get Element Attribute  ${foo}  show
    ${foo}=  XML.Get Element  ${child}  .//field[@name='nr-rrc.absoluteFrequencySSB']
    ${freq}  XML.Get Element Attribute  ${foo}  show
    Collections.Set To Dictionary  ${phys_freq}  ${id}=${freq}


Set Correct F1AP Protocol Name For Wireshark Check
    [Documentation]     checks the wireshark plugins and sets the protocol name
    ...                 for the verification of the wireshark file depending of the installed plugins
    ${ft1ap_filter}  MCSharkDissectors.Get F1AP Tshark Filter String
    Set Suite Variable  $PROTOCOL_NAME   ${ft1ap_filter}


Start PCAP Tracing On Eth Port For SCTP And TCP
    [Documentation]    Start tracing tcpdump on eth3 interface
    [Arguments]    ${eth_itf}=eth3

    ${IP_HOSTS}    Get Variable Value    ${IP_HOSTS}
    IF  '${IP_HOSTS}'=='${None}'
        ${IP_HOSTS}=  pcap_analysis.Get IPv4 Hosts For Tracing From SCF
    END
    ${tcpdump_options}=     Catenate    -i ${eth_itf} '(sctp or tcp port 49148) and (${IP_HOSTS})'
    ${eth3_collector}=  tcpdump.Start Tcpdump On TestPC    options=${tcpdump_options}
    Set Test Variable    ${eth3_collector}
    RETURN    ${eth3_collector}


Stop PCAP Tracing And Save As
    [Documentation]    Stop tracing tcpdump on eth3 interface
    [Arguments]    ${tcp_file}
    ${file_captured}  tcpdump.Stop Tcpdump On TestPc   collector=${eth3_collector}  target_dir=${resultTestDir}
    OperatingSystem.Run  cp ${file_captured} ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${${tcp_file}}    ${file_captured}


Get IPv4 Hosts For Tracing From SCF
    [Documentation]   Reading IPv4 addresses for U/C/M Plane from SCF file for Pcap filtering

    ${LocalIpList}=    scf_info.Get IPADDRESSV4

    ${IP_HOSTS}=    Catenate    SEPARATOR= or${SPACE}    @{LocalIpList}
    Set Test Variable  ${IP_HOSTS}
    RETURN    ${IP_HOSTS}
