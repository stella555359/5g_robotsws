*** Settings ***
Documentation
...	    [Author]	        	    "Aditya Kanakamalla"
...     [Author_Team]               "MN RAN RD VRF BLR2 2"
...     [Email]                     "Kavya M"
... 	[Feature_ID]            	"CNI-112008"
...     [Feature_Name]              "Filtering support for IP traffic capture"
...     [QC_Path]                   "QC_Path in test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
... 	[Description]               "R&D parameter enableTrafficCaptureFiltering has 4 values "
... 	[Hw Supported]    	        "ASIA(supported with limitations)/ASIB/ASIL/ASOE/ASIM/ASOF"



Library    taf.sw.scout    WITH NAME    scout

Resource         ${CURDIR}/../resources/common_keywords.robot


Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown   Teardown Oamops


#Suite Setup         Setup Oamops
#Suite Teardown      Teardown oamops



***Variables***

${traffic_filter_file_name}      /home/ute/fw_user_path/testcases/CNI-112008/resources/traffic_filters.json
${base_scf}         Configuration_scf_MRBTS-516200_NO01INMU405462_20250604-1800.xml
*** Test Cases ***
[1][2.1] CNI-112008-D-B1_ASIM_Verify IP Traffic Capturing Filter after BTS reset
   Perform Commissioning        scf_file=${base_scf}     verify_bts_status=False       timeout=600
   sleep       360

    ssh to ipv4 Mplane

    Set value to REMOVE TCP TRACE
    Start Capture and Verify SSH/TLS/TCP Trace Traffic
    Perform BTS reset and verify traces
    sleep   100
    Start Capture and Verify SSH/TLS/TCP Trace Traffic after reset


*** Keywords ***

Set value to REMOVE TCP TRACE

	Set Rad Debug Parameters	name=enableTrafficCaptureFiltering      value=2     domain=ERadSwDomain_OamTas      persistency=NotPersistent

Start Capture and Verify SSH/TLS/TCP Trace Traffic
    Traffic Capture Start           capture_device=vm_eth3_interface  mode=file   uplane_capturing=True       alias=default
    sleep   10
    ssh to ipv4 Mplane
    sleep   30
    ${pcap_file}=    Traffic Capture Stop    mode=file   timeout=120
    Set Suite Variable  ${pcap_file}     ${pcap_file}
    Analyse Pcap      pcap_filename=${pcap_file}      analysis=verify_ssh_test     filter_file_name=${traffic_filter_file_name}
    [TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop    alias=default


Start Capture and Verify SSH/TLS/TCP Trace Traffic after reset
    Traffic Capture Start           capture_device=vm_eth3_interface  mode=file   uplane_capturing=True    alias=new
    ${pcap_file}=    Traffic Capture Stop    mode=file   timeout=120       alias=new
     ssh to ipv4 Mplane
    Analyse Pcap      pcap_filename=${pcap_file}      analysis=verify_ssh_test     filter_file_name=${traffic_filter_file_name}
    [TEARDOWN]   Run Keyword and Ignore Error     Traffic capture stop    alias=new

ssh to ipv4 Mplane
    Setup Remote Access    remote_device=bts
    Teardown Remote Access

Perform BTS reset and verify traces
    Reset Bts      verify_bts=False       should_be_onair=False   wait_for=300
