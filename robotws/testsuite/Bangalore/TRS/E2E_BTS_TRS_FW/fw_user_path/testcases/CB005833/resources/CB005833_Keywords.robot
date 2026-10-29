*** Settings ***
Documentation
...        [Procedure]        "[1][1.0] TRS_CB005833_eCPRI_Mplane_Transport_Resiliency_BFD_Alarm_verification"
...        [Date]             "28-05-2023"
...        [Author]           "Anshu Bhat"
...        [Feature_ID]       "CB005833"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "Mplane resiliency,BFD ingress and egress"
...        [DELTA_FILE_DEPENDENCY]  "set_bfdActivation_to_true.json,set_bfdAdminup_to_true.json,set_bfdActivation_to_false.json,"
...                                    "set_bfdAdminup_to_false.json,FHFirewall.json,RUEnabled.json"}
...        [Validated_TestLine]     "IAV_BLR_3622"
...        [Config_Comments]         "Mplane resiliency with BFD sessions"
...        [Precondition]             "ENodeB should be integrated to Netact"

*** Keywords ***

Preconditions
    Perform Commissioning       scf_file=${CB005833_config}     timeout=1800     alias=default      wait_for_bts_to_be_ready=600
    Setup Ems  config_device=netact2005   alias=lab2005
    Cm Upload   config_device=netact2005     alias=lab2005

Perform BBMOD Reset and verify BBMOD Routes
    Reset    operation=reset_unit   dist_name=${BBMOD}    reset_type=Hard     verify_bts=True     timeout=600
    Check Both Routes are added

Change actEcpriRuMPlaneSecurity as RuProtectEnabled
    Perform Recommissioning        type=delta      delta_file=${RUEnabled}     skip_parameter_relation_errors=false    timeout=300   operation=edit
    Verify Alarm    faultid=6450       should_exist=${False}
    Setup Remote Access   remote_device=bts_rr     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=${lxc}   alias=session
    ${stdout_2}          Execute Interactive Remote Command    command=${FRIp}      alias=session
    Should Contain      ${stdout_2}      15.1.1.1
    ${stdout_3}          Execute Interactive Remote Command    command=${Ipsec_status}   alias=session
    Should contain       ${stdout_3}        ESTABLISHED
    [Teardown]     Teardown remote Access         alias=session


Enable FH Firewall
    Perform Recommissioning	    type=param	  rat=nr	 param_path=MNLENT-1/FEATCADM-1:actMplaneFronthaulFirewall	  operation=update   value=true
    ...     timeout=600
    Verify Alarm    faultid=6450       should_exist=${False}

verify FH counters
    Pm Counters Start       analysis=FH_counter        counter_analysis_file=${FH_analysis}        pm_interval=5
    Verify Pm Counters       analysis=FH_counter        counter_analysis_file=${FH_analysis}        pm_interval=5
    Pm Counters Start       analysis=BBMOD_counter        counter_analysis_file=${FH_analysis}        pm_interval=5
    Verify Pm Counters       analysis=BBMOD_counter         counter_analysis_file=${FH_analysis}        pm_interval=5



Fetching details
    ${output1}=     Configuration Get   config_device=netact2005       dist_name=${PLMN}${bts_id}${IPRT}      alias=lab2005
    Log     ${output1}
    ${values_1}=        Get From Dictionary        ${output1}       staticRoutes
    Log     ${values_1}[0]
    ${primary_gw}=      Get From Dictionary        ${values_1}[0]        gateway
    Log     ${primary_gw}
    Set Suite Variable      ${primary_gw}   ${primary_gw}
    ${loopback_ip}=     Get From Dictionary        ${values_1}[0]        destIpAddr
    Log     ${loopback_ip}
    Set Suite Variable      ${loopback_ip}
    ${secondary_gw}=      Get From Dictionary        ${values_1}[1]        gateway
    Log     ${secondary_gw}
    Set Suite Variable      ${secondary_gw}   ${secondary_gw}
    ${output2}=    Configuration Get    config_device=netact2005       dist_name=${PLMN}${bts_id}${IPIF}       alias=lab2005
    Log     ${output2}
    ${prim_src_ip}=        Get From Dictionary        ${output2}           localIpAddr
    Log     ${prim_src_ip}
    Set Suite Variable      ${prim_src_ip}      ${prim_src_ip}

Check Routes and vlans
    sleep   300
    Setup Remote Access   remote_device=bts_rr     alias=session
    ${stdout_2}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session
    ${stdout_3}          Execute Interactive Remote Command    command=yes   alias=session
    ${stdout_4}          Execute Interactive Remote Command    command=${root_pswd}   alias=session
    ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
    ${stdout_6}          Execute Interactive Remote Command    command=ip r s   alias=session
    Log  ${stdout_6}
    Should Contain      ${stdout_6}      15.1.1.1 via 10.1.1.2 dev rfoe0.1010 metric 1
    Should Contain      ${stdout_6}      15.1.1.1 via 20.1.1.2 dev rfoe1.1020 metric 2
    ${stdout_7}          Execute Interactive Remote Command    command=ifconfig   alias=session
    Log  ${stdout_7}
    Should Contain      ${stdout_7}      rfoe0.1010
    Should Contain      ${stdout_7}      rfoe1.1020
    Should not contain       ${stdout_7}    rfoe0.295
    [Teardown]     Teardown remote Access         alias=session

Verify Runtime Trigger
    ${state}=     Query Admin Infomodel       query=get list //TRIGGER_R-*
    Log    ${state}
    ${values_0}=        Get From Dictionary        ${state}[0]    state
    Log     ${values_0}
    ${values_1}=        Get From Dictionary        ${state}[1]    state
    Log     ${values_1}
    ${values_2}=        Get From Dictionary        ${state}[2]    state
    Log     ${values_2}
    ${values_3}=        Get From Dictionary        ${state}[3]    state
    Log     ${values_3}
    @{List_1}=  Create List  ${values_0}  ${values_1}  ${values_2}  ${values_3}
    List Should Contain Value      ${List_1}     TRUE
    List Should Contain Value      ${List_1}     TRUE
    List Should Contain Value      ${List_1}     TRUE
    List Should Contain Value      ${List_1}     TRUE

Verify Runtime Trigger with egress
#    ${state}=     Query Admin Infomodel       query=get list /MRBTS-2020/TNLSVC-1/TNL-2/TRIGGER_R-*
    ${state}=     Query Admin Infomodel       query=get list //TRIGGER_R-*
    Log    ${state}
    ${values_0}=        Get From Dictionary        ${state}[0]    state
    Log     ${values_0}
    ${values_1}=        Get From Dictionary        ${state}[1]    state
    Log     ${values_1}
    ${values_2}=        Get From Dictionary        ${state}[2]    state
    Log     ${values_2}
    ${values_3}=        Get From Dictionary        ${state}[3]    state
    Log     ${values_3}
    @{List_1}=  Create List  ${values_0}  ${values_1}  ${values_2}  ${values_3}
    List Should Contain Value      ${List_1}     TRUE
    List Should Contain Value      ${List_1}     TRUE
    List Should Contain Value      ${List_1}     TRUE
    List Should Contain Value      ${List_1}     FALSE

Verify Egress alarm

     ${alarm_description}=    Verify Ems Alarm   config_device=netact2005   faultid=${egress_faultid}   occurences=1   alias=lab2005
     Log    ${alarm_description}
     ${len}=     Get Length      ${alarm_description}
     FOR   ${i}   IN RANGE   ${len}
            Log   ${alarm_description}[${i}]
     Run Keyword If    '${alarm_description}[${i}][FAULT ID]'=='${egress_faultid}'     Set Suite Variable   ${supp_info}  ${alarm_description}[${i}]
            ${supp_info}=     Exit For Loop If    '${alarm_description}[${i}][FAULT ID]'=='${egress_faultid}'
     END
     Log   ${supp_info}[SUPPL ALARM INFO]
     Should Contain    ${supp_info}[SUPPL ALARM INFO]   ${egress_faultid}
    ...      supplAlarmInfo=Source IP address ${prim_src_ip}. Destination IP address ${primary_gw}. =${egress_faultid} BFD-1

Generate Egress alarm for BFD-1
    [Arguments]     ${loopback_ip}     ${rf_pswd}
     Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach 0x4018   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ssh serviceuser@${loopback_ip}   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=yes   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=${rf_pswd}   alias=session
     ${stdout_4}         Execute Interactive Remote Command    command=sudo nft insert rule ip filter INPUT ip saddr 10.1.1.1 drop     alias=session
     ${output}   Execute Interactive Remote Command  command=${Egress}|grep "ip saddr 10.1.1.1 drop # handle" | sed 's/.* handle //'  alias=session
     ${output}=     Split String    ${output}    separator=handle //'       max_split=-1
     Set Suite Variable      ${handle_egress}        ${output}[1]
     Log  ${handle_egress}
     [Teardown]     Teardown remote Access         alias=session

Check Routes are deleted
     Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=ssh toor4nsn@asp-6b   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=oZPS0POrRieRtu   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_6}          Execute Interactive Remote Command    command=ip r s   alias=session
     Log  ${stdout_6}
     Should not contain       ${stdout_6}    15.1.1.1 via 10.1.1.2 dev rfoe0.1010 metric 1
     [Teardown]     Teardown remote Access         alias=session

Check ping connectivity to loopback ip
    [Arguments]     ${session}
     Setup Remote Access   remote_device=bts_rr     alias=${session}
     ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach 0x4018   alias=${session}
     ${stdout_3}          Execute Interactive Remote Command    command=ping ${loopback_ip} -w 5   alias=${session}

Verify Ingress alarm
    ${Ingress_alarm}=    Verify Ems Alarm      config_device=netact2005    faultid=${ingress_faultid}   occurences=1     alias=lab2005
    Log   ${Ingress_alarm}
    ${len}=     Get Length      ${Ingress_alarm}
    FOR   ${i}   IN RANGE   ${len}
            Log   ${Ingress_alarm}[${i}]
            Run Keyword If    '${Ingress_alarm}[${i}][FAULT ID]'=='${ingress_faultid}'     Set Suite Variable   ${supp_info}  ${Ingress_alarm}[${i}]
            ${supp_info}=     Exit For Loop If    '${Ingress_alarm}[${i}][FAULT ID]'=='${ingress_faultid}'
    END
    Log   ${supp_info}[SUPPL ALARM INFO]
    Should Contain    ${supp_info}[SUPPL ALARM INFO]   ${ingress_faultid}
    ...      supplAlarmInfo=Source IP address ${prim_src_ip}. Destination IP address ${primary_gw}. =${ingress_faultid} BFD-1

Verify ingress alarm should not exist
    sleep   30
    Verify Ems Alarm      config_device=netact2005    faultid=${ingress_faultid}   occurences=1     should_exist=${False}       alias=lab2005

Verify Ingress and Egress alarm should not exist
     sleep  30
     Verify Ems Alarm      config_device=netact2005   faultid=${ingress_faultid}   occurences=1     should_exist=${False}       alias=lab2005
     Verify Ems Alarm      config_device=netact2005   faultid=${egress_faultid}   occurences=1     should_exist=${False}      alias=lab2005

Verify egress alarm should not exist
    sleep   30
    Verify Ems Alarm        config_device=netact2005   faultid=${egress_faultid}   occurences=1     should_exist=${False}        alias=lab2005

Making bfdAdminUp as false
    Perform Recommissioning         type=param     rat=5g      param_path=TNL-2/IPAPP-1/BFD-1:bfdAdminUp      operation=update
    ...        value=false        timeout=300

Check Admin state for BFD session
     [Arguments]    ${admin_state}
     Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_6}         Execute Interactive Remote Command    command=timeout 30 ${rfoe} -w primary_when_Admin_${admin_state}.pcap    alias=session
     ${stdout_7}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_8}          Execute Interactive Remote Command    command=scp primary_when_Admin_${admin_state}.pcap /ffs/run/logs   alias=session
     ${stdout_9}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_10}          Execute Interactive Remote Command    command=exit   alias=session
    Setup Remote Access     remote_device=vm
    Execute Interactive Remote Command      command=scp ${path1}/primary_when_Admin_${admin_state}.pcap ${path2}
    Execute Interactive Remote Command    command=oZPS0POrRieRtu
    Analyse Pcap       pcap_filename=${CURDIR}/primary_when_Admin_${admin_state}.pcap       analysis=Admin_${admin_state}_state
    ...       filter_file_name=${traffic_filer_file_name}
    [Teardown]     Teardown remote Access         alias=session


Get File from RF to ENB RR
    [Arguments]    ${admin_state}
    Setup Remote Access    remote_device=bts_rr     alias=session
    Get File for ENodeB RR     primary_when_Admin_${admin_state}.pcap      ${CURDIR}/primary_when_Admin_${admin_state}.pcap
    Analyse Pcap       pcap_filename=${CURDIR}/primary_when_Admin_${admin_state}.pcap       analysis=Admin_${admin_state}_state
    ...       filter_file_name=${traffic_filer_file_name}
     [Teardown]     Teardown remote Access         alias=session

Making bfdAdminUp as true
    Perform Recommissioning         type=param     rat=5g      param_path=TNL-2/IPAPP-1/BFD-1:bfdAdminUp      operation=update        value=true
    ...        timeout=300

Making bfdActivation as false
    Perform Recommissioning         type=param     rat=5g      param_path=TNL-2/IPAPP-1/BFD-1:bfdActivation      operation=update        value=false
    ...        timeout=300

Making bfdActivation as true
    Perform Recommissioning         type=param     rat=5g      param_path=TNL-2/IPAPP-1/BFD-1:bfdActivation      operation=update        value=true
    ...        timeout=300

No BFD packets in wireshark
    Setup Remote Access   remote_device=bts_rr     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session
    ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_6}          Execute Interactive Remote Command    command=timeout 20 ${rfoe} -w no_bfd_packets_from_BTS_to_radio.pcap    alias=session
     ${stdout_7}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_8}          Execute Interactive Remote Command    command=scp no_bfd_packets_from_BTS_to_radio.pcap /ffs/run/logs       alias=session
     ${stdout_9}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_10}          Execute Interactive Remote Command    command=exit   alias=session
     Setup Remote Access     remote_device=vm
    Execute Interactive Remote Command    command=scp ${path1}/no_bfd_packets_from_BTS_to_radio.pcap ${path2}
    Execute Interactive Remote Command    command=oZPS0POrRieRtu
     Analyse Pcap       pcap_filename=${CURDIR}/no_bfd_packets_from_BTS_to_radio.pcap
     ...     analysis=no_bfd_packets       filter_file_name=${traffic_filer_file_name}
     [Teardown]     Teardown remote Access         alias=session

Generate Ingress alarm for BFD-1
    [Arguments]     ${loopback_ip}     ${rf_pswd}
     Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach -n 0x4018   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ssh serviceuser@${loopback_ip}   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=yes   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=${rf_pswd}   alias=session
     ${stdout_4}        Execute Interactive Remote Command    command=sudo nft insert rule ip filter OUTPUT ip daddr 10.1.1.1 drop     alias=session
     ${output}=     Split String    ${stdout_4}    separator=\r\r\n       max_split=-1
     ${output}         Execute Interactive Remote Command    command=${Ingress}|grep "ip daddr 10.1.1.1 drop # handle" | sed 's/.* handle //'
     ...        alias=session
     ${output}=     Split String    ${output}    separator=handle //'       max_split=-1
     Set Suite Variable      ${handle_ingress}        ${output}[1]
     Log  ${handle_ingress}
     [Teardown]     Teardown remote Access         alias=session

Clear Ingress alarm for BFD
    [Arguments]     ${loopback_ip}     ${rf_pswd}
     Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach -n 0x4018   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ssh serviceuser@${loopback_ip}   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=yes   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=${rf_pswd}     alias=session
     ${output}=     Split String    ${handle_ingress}    separator=\r\r\n       max_split=-1
     Set Suite Variable   ${handle_ingress}     ${output}[1]
     ${stdout_4}         Execute Interactive Remote Command    command=sudo nft delete rule ip filter OUTPUT handle ${handle_ingress}
    ...      alias=session
     Log    ${stdout_4}
     [Teardown]     Teardown remote Access         alias=session

Clear Egress alarm for BFD
    [Arguments]     ${loopback_ip}     ${rf_pswd}
     Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach -n 0x4018   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ssh serviceuser@${loopback_ip}   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=yes   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=${rf_pswd}   alias=session
     ${output}=     Split String    ${handle_egress}    separator=\r\n       max_split=-1
     Set Suite Variable   ${handle_egress}     ${output}[1]
     ${stdout_4}         Execute Interactive Remote Command    command= sudo nft delete rule ip filter INPUT handle ${handle_egress}
    ...    alias=session
     Log    ${stdout_4}
     [Teardown]     Teardown remote Access         alias=session

Check Routes are added
    Setup Remote Access   remote_device=bts_rr     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session
    ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_6}          Execute Interactive Remote Command    command=ip r s   alias=session
     Log  ${stdout_6}
     Should contain       ${stdout_6}       15.1.1.1 via 10.1.1.2 dev rfoe0.1010 metric 1
     [Teardown]     Teardown remote Access         alias=session

Check Both Routes are added
    Setup Remote Access   remote_device=bts_rr     alias=session7
    ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session7
    ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session7
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session7
     ${stdout_6}          Execute Interactive Remote Command    command=ip r s   alias=session7
     Log  ${stdout_6}
     Should contain       15.1.1.1 via 10.1.1.2 dev rfoe0.1010 metric 1
     Should contain       15.1.1.1 via 20.1.1.2 dev rfoe1.1020 metric 2
     [Teardown]     Teardown remote Access         alias=session7

Verify FHNET Routes
    Setup Remote Access   remote_device=bts_rr     alias=session1
    ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach -n 0x4018   alias=session1
    ${stdout_2}          Execute Interactive Remote Command    command=ip r s   alias=session1
    Should contain       ${stdout_2}        10.1.1.0/30 via 172.21.0.6 dev rlan0.ecpri metric 1
    Should contain       ${stdout_2}        20.1.1.0/30 via 172.21.0.6 dev rlan0.ecpri metric 1
    Should contain       ${stdout_2}        15.1.1.1 via 172.21.0.6 dev rlan0.ecpri metric 1
    [Teardown]     Teardown remote Access         alias=session1

Change actEcpriRuMPlaneSecurity as RuProtectDisabled
    Perform Recommissioning	type=param	rat=5g	   param_path=MNLENT-1/FEATCADM-1:actEcpriMPlaneSecurity	operation=update
    ...	value=RuProtectDisabled     timeout=600
    Verify Bts Status   should_be_onair=${True}
    Verify Alarm    faultid=6450       should_exist=${False}

Make wrong mplane mapping and verify ping connectivity to loopback ip
     Configuration Manage     config_device=netact2005    config=${make_wrong_mplane_mapping}       plan_name=fw_plan        delete_plan=${True}
     ...       alias=lab2005      operation=edit
     Check Routes are added one

Change preference value and verify
     Perform Recommissioning     type=delta    delta_file=${change_preference_value}    skip_parameter_relation_errors=${False}     timeout=400
     Setup Remote Access   remote_device=bts_rr     alias=session1
     ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session1
     ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session1
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session1
     ${stdout_6}          Execute Interactive Remote Command    command=ip r s   alias=session1
     Should contain       ${stdout_6}    15.1.1.1 via 10.1.1.2 dev rfoe0.1010 metric 3
     Should contain       ${stdout_6}    15.1.1.1 via 20.1.1.2 dev rfoe1.1020 metric 4
     ${stdout_7}          Execute Interactive Remote Command    command=exit    alias=session1
     ${stdout_8}          Execute Interactive Remote Command    command=exit    alias=session1
     sleep   180
     Verify Alarm    faultid=6450        should_exist=${False}
     [Teardown]     Teardown remote Access         alias=session1

Revert preference value and verify
    Perform Recommissioning     type=delta    delta_file=${change_preference_value_2}    skip_parameter_relation_errors=${False}     timeout=400
     Setup Remote Access   remote_device=bts_rr     alias=session2
     ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session2
     ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session2
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session2
     ${stdout_6}          Execute Interactive Remote Command    command=ip r s   alias=session2
     Should contain       ${stdout_6}    15.1.1.1 via 10.1.1.2 dev rfoe0.1010 metric 1
     Should contain       ${stdout_6}    15.1.1.1 via 20.1.1.2 dev rfoe1.1020 metric 2
     ${stdout_7}          Execute Interactive Remote Command    command=exit    alias=session2
     ${stdout_8}          Execute Interactive Remote Command    command=exit    alias=session2
     sleep  120
     Verify Bts Status  req_rat=5g   should_be_onair=${True}
     [Teardown]     Teardown remote Access         alias=session2

Change desMinTxInt and reqMinRxInt and verify modified value in tcpdump
     Perform Recommissioning     type=delta    delta_file=${change_desMinTxInt_and_reqMinRxInt}    skip_parameter_relation_errors=${False}
    ...     timeout=800
     Setup Remote Access   remote_device=bts_rr     alias=session3
     ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session3
     ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session3
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session3
     ${stdout_6}          Execute Interactive Remote Command    command=timeout 20 tcpdump -i rfoe0.1010 -w modified_desMinTxInt_and_reqMinRxInt.pcap
    ...    alias=session3
     ${stdout_7}          Execute Interactive Remote Command    command=exit   alias=session3
     ${stdout_8}          Execute Interactive Remote Command    command=scp modified_desMinTxInt_and_reqMinRxInt.pcap /ffs/run/logs   alias=session3
     ${stdout_9}          Execute Interactive Remote Command    command=exit   alias=session3
     ${stdout_10}          Execute Interactive Remote Command    command=exit   alias=session3
    Setup Remote Access     remote_device=vm
    Execute Interactive Remote Command      command=scp ${path1}/modified_desMinTxInt_and_reqMinRxInt.pcap ${path2}
    Execute Interactive Remote Command    command=oZPS0POrRieRtu
    Analyse Pcap       pcap_filename=${CURDIR}/modified_desMinTxInt_and_reqMinRxInt.pcap       analysis=modified_desMinTxInt_and_reqMinRxInt
    ...       filter_file_name=${traffic_filer_file_name}
    Verify Alarm    faultid=6450        should_exist=${False}
     [Teardown]     Teardown remote Access         alias=session3

Change bfdSrcUdpPort and verify modified value in tcpdump
    Perform Recommissioning     type=delta    delta_file=${change_bfdSrcUdpPort}    skip_parameter_relation_errors=${False}     timeout=400
    sleep  300
    Setup Remote Access   remote_device=bts_rr     alias=session4
    ${stdout_1}          Execute Interactive Remote Command    command=${bsh_2_login}   alias=session4
    ${stdout_3}          Execute Interactive Remote Command    command=${root_pswd}   alias=session4
     ${stdout_5}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session4
     ${stdout_6}          Execute Interactive Remote Command    command=timeout 20 tcpdump -i rfoe0.1010 -w modified_bfdSrcUdpPort.pcap
    ...   alias=session4
     ${stdout_7}          Execute Interactive Remote Command    command=exit   alias=session4
     ${stdout_8}          Execute Interactive Remote Command    command=scp modified_bfdSrcUdpPort.pcap /ffs/run/logs   alias=session4
     ${stdout_9}          Execute Interactive Remote Command    command=exit   alias=session4
     ${stdout_10}          Execute Interactive Remote Command    command=exit   alias=session4
     Setup Remote Access     remote_device=vm
    Execute Interactive Remote Command      command=scp ${path1}/modified_bfdSrcUdpPort.pcap ${path2}
    Execute Interactive Remote Command    command=oZPS0POrRieRtu
    Analyse Pcap       pcap_filename=${CURDIR}/modified_bfdSrcUdpPort.pcap       analysis=modified_bfdSrcUdpPort
    ...       filter_file_name=${traffic_filer_file_name}
    Verify Alarm    faultid=6450        should_exist=${False}
     [Teardown]     Teardown remote Access         alias=session4

