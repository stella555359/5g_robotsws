*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library   Collections
Library   SSHLibrary
Library   OperatingSystem
Library   Telnet   prompt=(> |# )   prompt_is_regexp=yes

Library   taf.transport.ssh    WITH NAME    csn

*** Variables ***

*** Keywords ***
Setup Core Simulator
    # csn.Connect To    hostname=${epc_addr}    username=root    password=${epc_password}    alias=LTEEMU_ROOT    timeout=10
    # csn.Execute    killall edaemon    connection=LTEEMU_ROOT
    # csn.Execute    cd ${epc_dir_path}; ./edaemon --port 22222    connection=LTEEMU_ROOT
    # csn.Disconnect    connection=LTEEMU_ROOT
    # csn.Connect To    hostname=${epc_addr}    username=nokia    password=${epc_password}    alias=Core_Simulator    timeout=10
    # csn.Execute    killall egate    connection=Core_Simulator    timeout=10
    # csn.Execute    cd ${epc_dir_path}; ./egate --port 20000    connection=Core_Simulator    timeout=10
    # csn.Disconnect    connection=Core_Simulator
    Telnet.Open Connection   host=127.0.0.1    port=20000    alias=EGATE
    Telnet.Set Prompt   prompt=(> |# )   prompt_is_regexp=yes
    Telnet.Execute Command   re
    Telnet.Execute Command   cfg file=/home/ute/WTS/SA_cloud.cfg
    Sleep    10s
    Telnet.Execute Command   start
    Sleep    10s
    ${sba_str}   Catenate   SEPARATOR=
    ...   amf_ue_ics_param
    ...   ${SPACE}id=1
    ...   ${SPACE}ue=1
    ...   ${SPACE}object_id=1
    ...   ${SPACE}location_reporting_reference_id=1
    ...   ${SPACE}trace_activation=on
    ...   ${SPACE}trace_plmn=262:03
    ...   ${SPACE}trace_ref_id=1
    ...   ${SPACE}trace_rec_session_ref_id=1
    ...   ${SPACE}trace_depth=maximum
    ...   ${SPACE}ifaces_to_trace=NG-C,Xn-C,Uu
    ...   ${SPACE}tce_ip=${dcap_server_ip}
    Telnet.Execute Command   ${sba_str}
    Sleep   10s
    Telnet.Close Connection
