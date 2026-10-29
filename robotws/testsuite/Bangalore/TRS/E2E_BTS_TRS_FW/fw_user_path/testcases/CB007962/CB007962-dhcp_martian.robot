*** Settings ***
Documentation
...     [Author]        "Mamtha Kshirsagar"
...     [Maintenance]   "TRS ET Bangalore Team"
...     [Procedure]     "The test case is planned to verify gNB ignores & logs DHCPDECLINE messages"
...     [Date]          "10-01-2022"
...     [Feature_ID]    "CB007962"
...     [Requirement ID]    "WgNB_SEC_60532"
...     [Config]    "This script requires basic SCF loading."
...     [RunTime Parameters]    "bts_id used is 1599"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot



Suite Setup     Run Keywords        Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown     Run Keywords     Suite Teardown Postconditions
...     AND     Teardown Oamops


*** Test Cases ***
[1]CB007962-D_Verify that gNB ignores & logs DHCPDECLINE messages for both IPv4 & IPv6
    Get destination, source and requested addr
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}      timeout=60      alias=conn2
    Execute Interactive Remote Command     command=${start_capture}     alias=conn2
    Traffic Setup           device=device_1
    Traffic Start   profile=dhcp_decline
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}      timeout=60
    Execute Interactive Remote Command      command=${copy_capture}
    Execute Interactive Remote Command      command=${bts_password}
    Execute Interactive Remote Command      command=${exit_command}
    Execute Interactive Remote Command      command=${copy_capture2}
    Execute Interactive Remote Command      command=${ute_password}
    Analyse Pcap    pcap_filename=${pcap_file}  analysis=verify_dhcp_decline       filter_file_name=traffic_filter.json
    Setup Remote Access     remote_device=bts
    ${output}=  Execute Interactive Remote Command   command=${varlog_command}
    Should Contain  ${output}   DHCPDECLINE

[1]CB007962-D_Verify that gNB logs the packets without existing routes
    Setup Remote Access    remote_device=bts    session_type=ssh   alias=default
    FOR    ${ext_int}    IN    @{external_interfaces}
        ${output}=      Execute Interactive Remote Command      command=${martian_command}| grep ${ext_int}| cut -d= -f2
        ...      alias=default
        ${value}=   Get Line    ${output}   -2
        Should Be True      ${value}==1
    END

***keywords***
Get destination, source and requested addr
    Setup Remote Access     remote_device=linux_pc  alias=conn1
    ${output}=      Execute Interactive Remote Command      command=${cmd1}     alias=conn1
    ${output2}=     Get Line    ${output}   -2
    ${source_ip}=   Get Substring   ${output2}  9   22
    Set Suite Variable  ${source_ip}    ${source_ip}
    Rfmodule Setup      config_device=rf_module          fhnet_login_only=${True}      timeout=60
    ${output3}=     Execute Interactive Remote Command      command=${cmd2}
    ${output4}=     Get Line    ${output3}   -2
    ${destination_ip}=   Get Substring   ${output4}  9   20
    Set Suite Variable      ${destination_ip}   ${destination_ip}
    Rfmodule Teardown
    Setup Remote Access     remote_device=bts   alias=conn2
    Execute Interactive Remote Command  command=${baseband}     alias=conn2
    ${output5}=     Execute Interactive Remote Command  command=${netns}    alias=conn2
    ${output6}=     Get Line    ${output5}  -3
    ${requested_addr}=  Get Substring   ${output6}  9   22
    Set Suite Variable  ${requested_addr}   ${requested_addr}
    Teardown Remote Access  alias=conn2
