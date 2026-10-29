***Settings***
Documentation
    ...     [Procedure]             "Common file to collect wireshark from BTS"


***Keywords***
Start Ip traffic capture point A file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}    mode=file     measurement_point=NE_Terminated   uplane_capturing=${uplane_val}
    ...    timeout=120    alias=${alias}
    Sleep    10

Start Ip traffic capture point B file mode
    [Arguments]       ${capture_device}      ${uplane_val}=True          ${alias}=default
    Traffic Capture Start     capture_device=${capture_device}   mode=file  measurement_point=Transport_Interface   uplane_capturing=${uplane_val}
    ...    timeout=120    alias=${alias}
    Sleep    10

Stop Ip traffic capture in file mode
    [Arguments]        ${alias}=default
    ${pcap_file}=  Traffic Capture Stop   mode=file   alias=${alias}  timeout=120
    Set Suite Variable     ${pcap_file}

Start Ip traffic capture point A streaming
    [Arguments]       ${capture_interface}    ${capture_device}   ${mac_address}    ${egress_port_dn}=None   ${uplane_val}=True
    ...             ${alias1}=default1   ${alias2}=default
    log     ${uplane_val}
    log     ${capture_device}
    Traffic Capture Start        capture_device=${capture_interface}    alias=${alias1}
    Run Keyword If   '${egress_port_dn}'=='None'    Traffic Capture Start        capture_device=oam_device    mode=streaming
    ...      measurement_point=NE_Terminated  uplane_capturing=True  dst_mac_addr=${mac_address}  timeout=900  alias=${alias2}
    ...      ELSE    Traffic Capture Start        capture_device=oam_device    mode=streaming
    ...      measurement_point=NE_Terminated  uplane_capturing=True  dst_mac_addr=${mac_address}  egress_port_dn=${egress_port_dn}
    ...     timeout=900  alias=${alias2}
    Sleep   5

Start Ip traffic capture point B streaming
    [Arguments]      ${capture_interface}    ${capture_device}   ${mac_address}    ${egress_port_dn}=None   ${uplane_val}=True
    ...             ${alias1}=default1   ${alias2}=default
    log     ${uplane_val}
    log     ${capture_device}
    Traffic Capture Start        capture_device=${capture_interface}    alias=${alias1}
	Run Keyword If   '${egress_port_dn}'=='None'    Traffic Capture Start        capture_device=oam_device    mode=streaming
    ...      measurement_point=Transport_Interface  uplane_capturing=True  dst_mac_addr=${mac_address}  timeout=900  alias=${alias2}
    ...      ELSE    Traffic Capture Start        capture_device=oam_device    mode=streaming
    ...      measurement_point=Transport_Interface  uplane_capturing=True  dst_mac_addr=${mac_address}  egress_port_dn=${egress_port_dn}
    ...     timeout=900  alias=${alias2}
    Sleep   5

Stop Ip traffic capture in streaming mode
    [Arguments]       ${capture_interface}     ${alias1}=default1    ${alias2}=default
    Traffic Capture Stop   mode=streaming   timeout=900  alias=${alias2}
    ${pcap_file}=     Traffic Capture Stop      capture_device=${capture_interface}      alias=${alias1}
    Set Suite Variable     ${pcap_file}