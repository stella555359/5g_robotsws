*** Settings ***
Documentation
...     [Author]        "pooja"
...     [Maintenance]   "TRS I & V Tools Bangalore Team"



*** Keywords ***

Configure Value To Parameter:sctpWaitTimeInitSeqRetry

       Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${sctpWaitTimeInitSeqRetry}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}      timeout=300
       ...     alias=vdu
       BuiltIn.Sleep   30

Login_vDU
    Setup Oamops    dut=vdu_1        timeout=100   alias=default

Logout vDU
    Teardown Oamops    dut=vdu_1      timeout=100    alias=default


F1C Pcap CPRT
        Setup Remote Access    remote_device=vdu_1.ocp     alias=default
        Execute Interactive Remote Command          command=kubectl exec -it -n cran33 po-cprt-0 -c ctr-nwmgmt -- bash            alias=default
        Execute Interactive Remote Command          command=tcpdump -i f1cplane -w /tmp/dhcp.pcap       alias=default

        Execute Interactive Remote Command     command=chmod 777 /tmp/dhcp.pcap      alias=default
        Execute Interactive Remote Command          command=exit       alias=default
        Setup Remote Access    remote_device=vdu_1.ocp     alias=co
        Execute Interactive Remote Command
        ...    command=kubectl exec -n cran33 po-cprt-0 -c ctr-nwmgmt -- cat /tmp/dhcp.pcap > /var/home/core/dhcp.pcap
        ...    alias=co


Start Wireshark At vDU f1-C Interface@OAMCP POD:CPRT container To Check DSCP

    Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
    traffic_capture_start       capture_device=vDU        capture_type=plane    plane_type=['mplane']
    ...    pod_names=['po-cran33-oamext-0']      measurement_point=Transport_Interface    timeout=180        alias=vdu
        BuiltIn.Sleep       120
        traffic_capture_stop   capture_device=vDU     timeout=120       keep_alias=True     alias=vdu
        BuiltIn.Sleep       20
        generate_capture_files     capture_device=vDU        timeout=120        alias=vdu
        BuiltIn.Sleep       20
         Run     rm /home/ute/Desktop/*
        ${sctp_log}=    Upload Traffic Capture File     capture_device=vDU      capture_type=plane
         ...    plane_type=['mplane']      local_path=/home/ute/Desktop    timeout=180       alias=vdu
         Verify SCTP           ${sctp_log}
        Verify Alarm            faultid=7220          should_exist=${True}

Verify SCTP
   [Arguments]     ${sctp_log}
    Analyse Pcap    pcap_filename=${sctp_log}    analysis=verify_sctp    filter_file_name=${filter_file_name}


Check The Fault Should Be Reported
       Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
       BuiltIn.Sleep       30
       Wait Until Keyword Succeeds    20 min    30      Verify Alarm          dut=vdu_1        faultid=7505
       ...   occurrences=1      should_exist=${True}       alias=vdu


Recover SCTP Packets between vCU and vDU


        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
       Perform Recommissioning    dut=vdu_1    type=delta    delta_file=${recover_SCTP}
       ...     skip_parameter_relation_errors=${True}   force_reset=${True}     auto_lock_cells=${True}     timeout=300
       ...     alias=vdu

Check The Fault Should Be Canceled
        Setup Oamops    dut=vdu_1        timeout=100      alias=vdu
        BuiltIn.Sleep       500
        Wait Until Keyword Succeeds    6 min    30      Verify Alarm            dut=vdu_1           faultid=7505
        ...    occurrences=0      should_exist=${False}         alias=vdu


