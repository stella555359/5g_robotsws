*** Settings ***
Documentation
...	    [Author]	        	    "Aditya Kanakamalla"
...     [Author_Team]               "MN RAN RD VRF BLR2 6"
...     [Email]                     "kanakamalla.aditya@nokia.com"
... 	[Feature_ID]            	"CNI-112008"
...     [Feature_Name]              "Filtering support for IP traffic capture"
...     [QC_Path]                   "QC_Path in test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
... 	[Description]               "R&D parameter enableTrafficCaptureFiltering has 4 values "
... 	[Hw Supported]    	        "ASIA(supported with limitations)/ASIB/ASIL/ASOE/ASIM/ASOF"
Resource         ${CURDIR}/../resources/common_keywords.robot
Suite Setup         Setup Oamops
Suite Teardown          Teardown oamops
*** Test Cases ***
[1]CNI-112008_Activate Filtering support in IP Traffic Capture for 3GPP quality and performance issues
    Remove UDP Trace Traffic
[1]CNI-112008_Activate Filtering support in IP Traffic Capture for Mplane and 3GPP interface issues
    Remove UDP and TCP Trace Traffic
[1]CNI-112008_Activate Filtering support in IP Traffic Capture for UDP
    Remove TCP Trace Traffic
[1]CNI-112008_Deactivating IP Traffic Capturing Filtering support and robutness test
    De-Activate CNI-112008
*** Keywords ***
Remove TCP Trace Traffic
    Set Rad Debug Parameters    name=enableTrafficCaptureFiltering      value=2     domain=ERadSwDomain_OamTas
    ...     persistency=NotPersistent
    Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True       measurement_point=NE_Terminated
    ...     timeout=180     alias=remove_tcp_trace_traffic
    ssh to ipv4 Mplane
    sleep   30
    ${filemode_capture}=    Traffic Capture Stop    mode=file   timeout=120     alias=remove_tcp_trace_traffic
    Run     mv ${filemode_capture} execution_logs/calls_capture.gz
    Run     gunzip execution_logs/calls_capture.gz
    Run     mv execution_logs/calls_capture execution_logs/calls_capture.pcap
    Analyse Pcap        analysis=verify_ssh_test     pcap_filename=execution_logs/calls_capture.pcap
ssh to ipv4 Mplane
    Setup Remote Access     remote_device=ssh_to_mplane
    Teardown Remote Access
Remove UDP Trace Traffic
    Set Rad Debug Parameters    name=enableTrafficCaptureFiltering      value=1     domain=ERadSwDomain_OamTas
    ...      persistency=NotPersistent
    start_uplane_trace_stream       operation=l2_start      source_ip=${source_ip}      dscp=${dscp}
    ...     destination_ip=${destination_ip}     destination_port=${destination_port}
    ...     nr_cell_dns=${nr_cell_dns}      trace_type=${trace_type}        up_sw=${up_sw}      timeout=10
    Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True
    ...     measurement_point=NE_Terminated     timeout=180     alias=remove_udp_trace_traffic
    sleep   10
    ssh to ipv4 Mplane
    sleep   30
    ${filemode_capture}=    Traffic Capture Stop    mode=file   timeout=120     alias=remove_udp_trace_traffic
    Run     mv ${filemode_capture} execution_logs/calls_capture_1.gz
    Run     gunzip execution_logs/calls_capture_1.gz
    Run     mv execution_logs/calls_capture_1 execution_logs/calls_capture_1.pcap
    Analyse Pcap        analysis=verify_udp_non_presnece     pcap_filename=execution_logs/calls_capture_1.pcap
    Analyse Pcap        analysis=verify_ssh_on_udp_test     pcap_filename=execution_logs/calls_capture_1.pcap
Remove UDP and TCP Trace Traffic
    Set Rad Debug Parameters    name=enableTrafficCaptureFiltering      value=3     domain=ERadSwDomain_OamTas
    ...     persistency=NotPersistent
    Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True       measurement_point=NE_Terminated
    ...     timeout=180     alias=remove_udp_tcp_trace_traffic
    sleep   10
    ssh to ipv4 Mplane
    sleep   30
    ${filemode_capture}=    Traffic Capture Stop    mode=file   timeout=120     alias=remove_udp_tcp_trace_traffic
    Run     mv ${filemode_capture} execution_logs/calls_capture_1.gz
    Run     gunzip execution_logs/calls_capture_1.gz
    Run     mv execution_logs/calls_capture_1 execution_logs/calls_capture_1.pcap
    Analyse Pcap        analysis=verify_udp_non_presnece     pcap_filename=execution_logs/calls_capture_1.pcap
    Analyse Pcap        analysis=verify_ssh_test     pcap_filename=execution_logs/calls_capture_1.pcap
De-Activate CNI-112008
    Set Rad Debug Parameters    name=enableTrafficCaptureFiltering      value=0     domain=ERadSwDomain_OamTas
    ...     persistency=NotPersistent
    Stop Uplane Trace Stream    nr_cell_dn=${nr_cell_dns}	timeout=30  operation=l2_stop
    Traffic Capture Start    capture_device=oam_device     mode=file   uplane_capturing=True       measurement_point=NE_Terminated
    ...     timeout=180     alias=remove_no_traffic
    sleep   10
    ssh to ipv4 Mplane
    sleep   30
    ${filemode_capture}=    Traffic Capture Stop    mode=file   timeout=120     alias=remove_no_traffic
    Run     mv ${filemode_capture} execution_logs/calls_capture_1.gz
    Run     gunzip execution_logs/calls_capture_1.gz
    Run     mv execution_logs/calls_capture_1 execution_logs/calls_capture_1.pcap
    Analyse Pcap        analysis=verify_ssh_on_udp_test     pcap_filename=execution_logs/calls_capture_1.pcap
    Analyse Pcap        analysis=verify_udp_presence     pcap_filename=execution_logs/calls_capture_1.pcap