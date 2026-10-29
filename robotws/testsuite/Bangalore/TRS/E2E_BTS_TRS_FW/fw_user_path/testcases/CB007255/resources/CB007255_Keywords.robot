*** Settings ***
Documentation

...        [Procedure]        "[1][1.0] CB007255-B_verification of VLAN, PCP & DSCP check for M-Plane & CU-Plane configuriton."
...        [Date]             "11-10-2022"
...        [Author]           "Harsimran"
...        [Feature_ID]       "CB007255"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "DSCP,VLAN,PCP delta modification"
...        [DELTA_FILE_DEPENDENCY]  ""
...        [Validated_TestLine]     "IAV_BLR_2019"
...        [Config_Comments]         ""
...        [Precondition]             "ENodeB should be integrated to Netact"

***Keywords***

Reset bts and verify persistency of changed parameters
    Reset bts     verify_bts=${False}
    sleep   300
    Setup Remote Access   remote_device=bts_rr     alias=session1
    ${stdout_10}          Execute Interactive Remote Command    command=bsh 2:1   alias=session1
    ${stdout_11}          Execute Interactive Remote Command    command=ip netns exec radions bash     alias=session1
     ${stdout_12}          Execute Interactive Remote Command    command=timeout 60 tcpdump -i rfoe0 -w MOdified_values.pcap   alias=session1
     ${stdout_13}          Execute Interactive Remote Command    command=exit   alias=session1
     ${stdout_14}          Execute Interactive Remote Command    command=scp MOdified_values.pcap /ffs/run/logs   alias=session1
     ${stdout_13}          Execute Interactive Remote Command    command=exit   alias=session1
     ${stdout_13}          Execute Interactive Remote Command    command=exit   alias=session1
    Setup Remote Access     remote_device=vm
    Execute Interactive Remote Command      command=scp ${scp_path1}/MOdified_values.pcap ${path_2}
    Execute Interactive Remote Command    command=oZPS0POrRieRtu
    Analyse Pcap       pcap_filename=${CURDIR}/MOdified_values.pcap       analysis=modified_values        filter_file_name=${traffic_filer_file_name}
    [Teardown]     Teardown remote Access         alias=session1


Modify vlan in ETHIF Moc
    Perform Recommissioning     type=delta    delta_file=${change_vlan_in_ethif}    skip_parameter_relation_errors=${True}     timeout=400
    sleep  600

Modify vlan,dscp,pcp in mplanefhnw and verify in BBMOD
    Perform Recommissioning     type=delta    delta_file=${DSCP_VLAN}    skip_parameter_relation_errors=${True}     timeout=400
    sleep  500
    Setup Remote Access   remote_device=bts_rr     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=ssh toor4nsn@asp-6b   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=yes   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=oZPS0POrRieRtu   alias=session
    ${stdout_4}          Execute Interactive Remote Command    command=ip netns exec radions bash     alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=ifconfig   alias=session
     Should contain       ${stdout_5}    rfoe1.1030:
     Should contain       ${stdout_5}    rfoe0.1010:
     ${stdout_6}          Execute Interactive Remote Command    command=timeout 60 tcpdump -i rfoe1 -w MOdified_values.pcap   alias=session
     ${stdout_7}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_8}          Execute Interactive Remote Command    command=scp MOdified_values.pcap /ffs/run/logs   alias=session
     ${stdout_9}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_10}          Execute Interactive Remote Command    command=exit   alias=session
    Setup Remote Access     remote_device=vm
    Execute Interactive Remote Command      command=scp toor4nsn@192.168.255.119:/ffs/run/logs/MOdified_values.pcap ${path_2}
    Execute Interactive Remote Command    command=oZPS0POrRieRtu
    Analyse Pcap       pcap_filename=${CURDIR}/MOdified_values.pcap       analysis=modified_values        filter_file_name=${traffic_filer_file_name}
    [Teardown]     Teardown remote Access         alias=session

Check Mplane is tagged with configured vlan with feature enabled
    Setup Remote Access   remote_device=bts_rr     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=ssh toor4nsn@asp-6b   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=yes   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=oZPS0POrRieRtu   alias=session
     ${stdout_4}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=ifconfig   alias=session
     Should contain       ${stdout_5}    rfoe1.1020:
     Should contain       ${stdout_5}    rfoe0.1010:
     Should not contain       ${stdout_5}    rfoe2.295:
    [Teardown]     Teardown remote Access         alias=session
