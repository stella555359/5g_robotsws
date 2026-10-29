*** Settings ***

Documentation     Keywords for IpTrafficCapturing

Library           taf.sbts.oam.coam.admin            WITH NAME               coam

*** Variables ***
${downloaded_file_pcap_gz}=    ${EXECDIR}/downloaded_libpcap_file.pcap.gz
${PCAP_PATH_TMP_VM}=           /tmp/tmp.pcap

*** Keywords ***

Start IP Traffic Capturing
    [Documentation]
    ...  Keyword for start capturing with inputed parameters
    ...  measurement_point:     NE_Terminated = CapturePoint A, Transport_Interface = CapturePoint B
    ...  uplane_capturing:      False or True
    ...  password:              Any user's password without special signs or "${EMPTY}"
    ...  timeout:               Time to wait for correct action of keyword
    [Arguments]    ${measurement_point}  ${uplane_capturing}  ${password}  ${connection}
    Log to console  Start IP traffic capturing...
    coam.start ip capture file     measurement_point=${measurement_point}
    ...                             uplane_capturing=${uplane_capturing}
    ...                             password=${password}
    ...                             connection=${connection}
    ...                             timeout=120

Start IP Traffic Capturing Streaming
    [Documentation]
    ...  Keyword for start capturing with inputed parameters
    ...  IMPORTANT:             CONNECTION MUST BE PROVIDED VIA M-PLANE
    ...  measurement_point:     NE_Terminated = CapturePoint A, Transport_Interface = CapturePoint B
    ...  uplane_capturing:      False or True
    ...  dst_mac_addr:          MAC address of sniffer interface
    ...  egress_port_dn:        Absolute path to egress port (object) on BTS
    ...  connection:            Connection via mplane
    ...  timeout:               Time to wait for correct action of keyword
    [Arguments]    ${measurement_point}  ${uplane_capturing}  ${dst_mac_addr}  ${egress_port_dn}  ${connection}
    coam.start ip capture streaming    measurement_point=${measurement_point}
    ...                                 uplane_capturing=${uplane_capturing}
    ...                                 dst_mac_addr=${dst_mac_addr}
    ...                                 egress_port_dn=${egress_port_dn}
    ...                                 connection=${connection}
    ...                                 timeout=120

Stop IP Traffic Capturing
    [Arguments]  ${connection}
    Log to console  Stop IP traffic capturing...
    coam.stop ip capture file        connection=${connection}

Stop IP Traffic Capturing Streaming
    [Arguments]  ${connection}
    Log to console  Stop IP traffic capturing streaming...
    coam.stop ip capture streaming        connection=${connection}

Download File With Captured Traffic
    [Documentation]
    ...  Keyword for generate and download captured traffic
    ...  target_file_name:      filename with extension: .pcap.gz (without password) or .pcap.gz.enc (with password)
    [Arguments]    ${connection}  ${target_file_name}=${downloaded_file_pcap_gz}
    Log to console  Download file with captured traffic...
    coam.generate ip capture file    connection=${connection}
    coam.download ip capture file    target_file_name=${target_file_name}
    ...                               connection=${connection}
    ...                               timeout=120
    [Return]  ${target_file_name}

Disable Started IP Traffic Capturing
    [Arguments]  ${connection}
    run keyword and ignore error     Stop IP Traffic Capturing    ${connection}

Disconnect from coam
    [Arguments]  ${alias}=coam_coam
    coam.teardown  ${alias}

IP Traffic Capturing To .pcap File
    [Arguments]    ${measurement_point}  ${uplane_capturing}  ${password}
    ...            ${target_file_name}=${downloaded_file_pcap_gz}  ${capture_time}=120
    ${conn}=  coam.connect_to  name=ip_traffic_capture
    Start IP Traffic Capturing
    ...                        measurement_point=${measurement_point}
    ...                        uplane_capturing=${uplane_capturing}
    ...                        password=${password}
    ...                        connection=${conn}
    Log  IP Traffic Capturing started. Duration: ${capture_time} [second].  console=True
    Sleep  ${capture_time}  reason= Time to capture traffic.
    Stop IP Traffic Capturing  ${conn}
    Download File With Captured Traffic
    ...                                     target_file_name=${target_file_name}
    ...                                     connection=${conn}
    Log  File ${target_file_name} downloaded.  console=True
    [Teardown]  Run keywords    Disable Started IP Traffic Capturing  ${conn}    AND
    ...                         Disconnect from coam   alias=${conn}

Connect And Start IP Traffic Capturing
    [Arguments]    ${measurement_point}  ${uplane_capturing}  ${password}
    ${conn}=  coam.connect_to  name=ip_traffic_capture
    Start IP Traffic Capturing
    ...                        measurement_point=${measurement_point}
    ...                        uplane_capturing=${uplane_capturing}
    ...                        password=${password}
    ...                        connection=${conn}
    set Test Variable    ${conn}

Stop IP Traffic Capturing and Download File
    [Arguments]   ${target_file_name}=${downloaded_file_pcap_gz}    ${w_unzip}=False    ${dest_unzip}=None
    Stop IP Traffic Capturing  ${conn}
    Download File With Captured Traffic
    ...                                     target_file_name=${target_file_name}
    ...                                     connection=${conn}
    Log  File ${target_file_name} downloaded.  console=True
    Run Keyword if    '${w_unzip}' == 'True'      Run                rm -f ${PCAP_PATH_TMP_VM}*
    Run Keyword if    '${w_unzip}' == 'True'      Run                cp ${target_file_name} ${PCAP_PATH_TMP_VM}.gz
    Run Keyword if    '${w_unzip}' == 'True'      Run                gunzip -f ${PCAP_PATH_TMP_VM}.gz
    ${dest_unzip}=  set Variable If     '${dest_unzip}' == 'None'    ${LOG_PATH}
    ...                                                              ${dest_unzip}
    Run Keyword if    '${w_unzip}' == 'True'      Run                mv ${PCAP_PATH_TMP_VM} ${dest_unzip}
    [Teardown]  Run keywords    Disable Started IP Traffic Capturing  ${conn}    AND
    ...                         Disconnect from coam   alias=${conn}

IP Traffic Streaming And Capturing On Sniffer
    [Arguments]    ${measurement_point}  ${uplane_capturing}  ${dst_mac_addr}  ${egress_port_dn}
    ...            ${sniffer_ip}  ${sniffer_username}  ${sniffer_password}  ${dst_sniff_port}
    ...            ${downloaded_file_pcap_sniff}=${downloaded_file_pcap_sniff}
    ${BTS_MPLANE}   set Variable        ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
    ${LMP_IP}       set Variable        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${connection}=  admin.connect_to  bts_host=${BTS_MPLANE}  name=ip_traffic_capture_streaming_mplane
    Start IP Traffic Capturing Streaming
    ...                                     measurement_point=${measurement_point}
    ...                                     uplane_capturing=${uplane_capturing}
    ...                                     dst_mac_addr=${dst_mac_addr}
    ...                                     egress_port_dn=${egress_port_dn}
    ...                                     connection=${connection}
    Save traffic on SNIFFER
    ...                                     sniffer_ip=${sniffer_ip}
    ...                                     sniffer_username=${sniffer_username}
    ...                                     sniffer_password=${sniffer_password}
    ...                                     dst_sniff_port=${dst_sniff_port}
    ...                                     downloaded_file_pcap_sniff=${downloaded_file_pcap_sniff}
    ${conn}=  coam.connect_to  bts_host=${LMP_IP}  name=ip_traffic_capture
    Stop IP Traffic Capturing Streaming     connection=${conn}
    [Teardown]  Run Keywords
    ...                         coam.teardown  connection=${connection}    AND
    ...                         coam.teardown  connection=${conn}

