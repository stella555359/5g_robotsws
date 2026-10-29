*** Settings ***
Documentation
     ...    [Procedure] "The test case is planned to validate that MTU size of 1608/1644 bytes can be used on M-plane"
     ...    [Date] "30-07-2025"
     ...    [Author] "Ruchika"
     ...    [QC_Path] "QC_Path in Test Plan"
     ...    [QC_ID] "QC_ID in Test Lab for reporting"
     ...    [Funtion_Hash_Tags] "Jumbro_frame"
     ...    [Feature_ID] "network_impairement"
     ...    [Validation_status] "Validated"
     ...    [Validated_TestLine] "ASIL"
     ...    [Commissioning_comment] "This script requires 4G configuration."


Resource        ${CURDIR}/../resources/common_keywords.robot

Suite Setup    Run Keywords     Pre-conditions for testsuite
...            AND    Setup Oamops     dut=mplane_login     alias=mplane
Suite Teardown     Run Keywords     Post-conditions for testteardown
...            AND    Teardown Oamops    dut=mplane_login    alias=mplane


***Test Cases***
[1][1.0] [2.0]TRAN_Ethernet Jumbo frames on M-plane

    Get Mplane IP
    Set eNB MTU size to     1500
    Set EPCSim MTU size to      1500
    Traffic Capture Start        capture_device=oam_device    mode=file              measurement_point=Transport_Interface
...         uplane_capturing=True        timeout=120            alias=mplane
    Sleep   400
    Collect Snapshot        timeout=1200    alias=mplane
    ${mtu_upstream}=       Traffic Capture Stop    capture_device=oam_device    mode=file     timeout=180     alias=mplane
    Analyse Pcap        pcap_filename=${mtu_upstream}   filter_file_name=${jumbo_filter}        analysis=without_jumboframe
#mplane_6000
    Get Mplane IP
    Set eNB MTU size to     6000
    Traffic Capture Start        capture_device=oam_device    mode=file              measurement_point=Transport_Interface
...         uplane_capturing=True        timeout=120            alias=mplane
    Sleep   400
    Collect Snapshot        timeout=1200    alias=mplane
    ${mtu_upstream}=       Traffic Capture Stop    capture_device=oam_device    mode=file     timeout=180     alias=mplane
    Analyse Pcap        pcap_filename=${mtu_upstream}   filter_file_name=${jumbo_filter}        analysis=without_jumboframe
#mplane_9000
    Get Mplane IP
    Set eNB MTU size to     9000
    Traffic Capture Start        capture_device=oam_device    mode=file              measurement_point=Transport_Interface
...         uplane_capturing=True        timeout=120            alias=mplane
    Sleep   400
    Collect Snapshot        timeout=1200    alias=mplane
    ${mtu_upstream}=       Traffic Capture Stop    capture_device=oam_device    mode=file     timeout=180     alias=mplane
    Analyse Pcap        pcap_filename=${mtu_upstream}   filter_file_name=${jumbo_filter}        analysis=without_jumboframe




***Keywords***

Get Mplane IP
	${mplane_ipv4}=		Get Parameter	param_path=${mplane_ip_moc_path}
    Set Suite Variable       ${mplane_ipv4}

Set eNB MTU size to
    [Arguments]      ${mtu_size}
    Perform Recommissioning     type=param      rat=lte     param_path=IPIF-1:ipMtu   operation=update     value=${mtu_size}      timeout=250

Set EPCSim MTU size to
    [Arguments]      ${EPC_mtu_size}
	Run    sudo ifconfig eth3 mtu ${EPC_mtu_size}
	Run    sudo ifconfig eth3.603 mtu ${EPC_mtu_size}
