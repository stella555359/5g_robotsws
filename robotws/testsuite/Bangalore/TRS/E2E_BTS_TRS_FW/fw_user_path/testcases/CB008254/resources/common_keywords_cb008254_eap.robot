*** Settings ***
Documentation
...     [Documentation]
...     [Author]        "Sushma R"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"
...     [Procedure] "The test case checks the support for different ciphers with graylog server and DCAP server"
...     [Date]      "02-11-2022"
...     [QC_Path]   "QC_Path in Test Plan"
...     [QC_ID]     "Verify both RSA & ECDSA operator certificate-based auth with BTS as Client-server for TLS"
...     [Funtion_Hash_Tags] "RSA & ECDSA operator certificate-based authentication"
...     [Feature_ID]            "CB008254"
...     [Requirement ID]    "OM_GEN_SFS_Netsec_3197,OM_GEN_SFS_NetSec.3190"
...     [Validation_Status]    "Validated"
...     [Validated_TestLine]    "3707"
...     [Config]    "This testcase requires Trace expert configurations from NRBTS/NRCTRLTS/NRMTRACECU  MOC"
...     [scf_file]  "scf to be updated"

*** Keywords ***
Get Pcap Details
    Analyse Pcap        pcap_filename=${file}        analysis=verify_success_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_request_message
    ...    filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_response_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_client_hello_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_server_hello_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_eap_request_message
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_eap_response_message
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap details for rsa
    Analyse Pcap        pcap_filename=${file}        analysis=verify_eaptls12_certificate_rsa
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_eaptls12_ciphers_rsa
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for rsakex
    Analyse Pcap        pcap_filename=${file}        analysis=verify_rsakex
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap Details for cbc
    Analyse Pcap        pcap_filename=${file}        analysis=verify_cbc
    ...     filter_file_name=${traffic_filter_file_name}

Get Pcap details for ecdsa
    Analyse Pcap        pcap_filename=${file}        analysis=verify_eaptls12_certificate_ecdsa
    ...     filter_file_name=${traffic_filter_file_name}
    Analyse Pcap        pcap_filename=${file}        analysis=verify_eaptls12_ciphers_ecdsa
    ...     filter_file_name=${traffic_filter_file_name}

Install Certificate on Radius Server
    [Arguments]     ${certificate_type}
    Run Keyword If      '${certificate_type}'=='rsa'        Run     command=${copy_rsa_cert}
    Run Keyword If      '${certificate_type}'=='ecdsa'      Run     command=${copy_ecdsa_cert}
    Setup Remote Access     remote_device=radius_server     alias=radius
    Put File To Remote Host     /home/ute/fw_user_path/testcases/CB008254/resources/eap     /tmp/   alias=radius
    Execute Interactive Remote Command      command=sudo rm -rf /etc/raddb/mods-enabled/eap     alias=radius
    Execute Interactive Remote Command      command=sudo su     exit_prompt=#    return_rc=${True}   alias=radius
    Execute Interactive Remote Command      command=sudo cp -r /tmp/eap /etc/raddb/mods-enabled
    ...     exit_prompt=#    return_rc=${True}   alias=radius
    Teardown Remote Access      alias=radius

Start Radius Server
    Setup Remote Access     remote_device=radius_server     alias=radius_server
    Execute Interactive Remote Command      command=sudo killall radiusd    exit_prompt=      return_rc=${False}
    ...     alias=radius_server
    Execute Interactive Remote Command      command=sudo radiusd -Xxx &     exit_prompt=      return_rc=${False}
    ...     alias=radius_server
    Teardown Remote Access      alias=radius_server

Capture EAP traffic
    [Arguments]     ${pcap_name}
    Start Radius Server
    Traffic Capture Start        capture_device=bts_tapeif1          alias=${pcap_name}
    Perform Recommissioning     type=param  param_path=${ethlk_path}    value=${ethlk_state_lock}    operation=update
    Sleep    120
    Perform Recommissioning     type=param  param_path=${ethlk_path}    value=${ethlk_state_unlock}    operation=update
    Sleep    120
    ${status}=            Query Admin Infomodel     query=get param ${EAP_Status}
    Should be equal     ${status}        Passed
    ${file}=                Traffic Capture Stop   alias=${pcap_name}
    Set Suite Variable              ${file}
