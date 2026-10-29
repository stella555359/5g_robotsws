*** Settings ***
Documentation

...        [Procedure]     "Checking SEC-ADM parameters in Primary and Secondary core"
...        [Date]          "12-06-2024"
...        [Author]        "Nagadeep"
...        [Feature_ID]    "CB009826"
...        [Maintenance]   "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "onair,checking SSH , SOE and R&D ports functionality,IPSEC"
...        [DELTA_FILE_DEPENDENCY]  "ssh_key_root.json,ssh_key_service.json"
...        [Validated_TestLine]     "TL001 & TL002"
...        [Precondition]             "Primary and secondary core's should be in sync"

variables       ta_e2e_bts_trs_fw

Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot
Resource        ${CURDIR}/../../resources/Common_IPSEC_Operations.robot

***Keywords***

Check SSH Login
    [Arguments]     ${bts}
    Setup Remote Access     remote_device=${bts}
    [Teardown]  Teardown Remote Access

Get parameter values
    ${5g_x2u} =             Get Parameter   rat=common      param_path=${5g_x2u_ip_moc_path}     alias=source
    ${5g_x2c} =             Get Parameter   rat=common      param_path=${5g_x2c_ip_moc_path}     alias=source
    ${5g_s1u} =             Get Parameter   rat=common      param_path=${5g_s1u_ip_moc_path}     alias=source
    ${5g_ngu} =             Get Parameter   rat=common      param_path=${5g_ngu_ip_moc_path}     alias=source
    ${5gv6_x2u} =             Get Parameter   rat=common      param_path=${5g_x2u_ipv6_moc_path}     alias=source
    ${v6_amf} =             Get Parameter   rat=common      param_path=${5g_v6_amf_moc_path}     alias=source
    ${5gv6_s1u} =             Get Parameter   rat=common      param_path=${5g_s1u_ipv6_moc_path}     alias=source
    ${5gv6_ngu} =             Get Parameter   rat=common      param_path=${5g_ngu_ipv6_moc_path}     alias=source
    ${v4_amf} =             Get Parameter   rat=common      param_path=${5g_v4_amf_moc_path}     alias=source
    ${v4_lnmme} =             Get Parameter   rat=common      param_path=${5g_v4_lnmme_moc_path}     alias=source
    ${v6_lnmme} =             Get Parameter   rat=common      param_path=${5g_v6_lnmme_moc_path}     alias=source


    Set Suite Variable  ${5g_x2u}       ${5g_x2u}
    Set Suite Variable  ${5g_x2c}       ${5g_x2c}
    Set Suite Variable  ${5g_s1u}       ${5g_s1u}
    Set Suite Variable  ${5g_ngu}       ${5g_ngu}
    Set Suite Variable  ${5gv6_x2u}       ${5gv6_x2u}
    Set Suite Variable  ${v6_amf}       ${v6_amf}
    Set Suite Variable  ${5gv6_s1u}       ${5gv6_s1u}
    Set Suite Variable  ${5gv6_ngu}       ${5gv6_ngu}
    Set Suite Variable  ${v4_amf}       ${v4_amf}
    Set Suite Variable  ${v4_lnmme}     ${v4_lnmme}
    Set Suite Variable  ${v6_lnmme}     ${v6_lnmme}

Verify IP connectivity

    FOR   ${DSCP}   IN RANGE   3
        ${changed_dscp}=         Evaluate    random.choice(range(0, 64))  random
        Set Suite Variable      ${changed_dscp}      ${changed_dscp}
    END

    FOR    ${payload_size}   IN RANGE   3
        ${changed_payload_size}=         Evaluate    random.choice(range(16, 61411))  random
        Set Suite Variable      ${changed_payload_size}      ${changed_payload_size}
    END

    Test Ipconnectivity     dut=bts     remote_address=${5g_ngu}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source
    Sleep   100
    Test Ipconnectivity     dut=bts     remote_address=${5g_ngu}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${5g_x2u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${5g_x2u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${5g_x2c}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${5g_x2c}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${5g_s1u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${5g_s1u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${v4_amf}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${v4_amf}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${v4_lnmme}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${v4_lnmme}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v4gw}     alias=source     alias=secondary

    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_ngu}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_ngu}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_x2u}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_x2u}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_x2c}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_x2c}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_s1u}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${5g_s1u}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${v4_amf}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${v4_amf}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${v4_lnmme}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v4gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${v4_lnmme}     alias=source     alias=secondary

    Test Ipconnectivity     dut=bts     remote_address=${5gv6_x2u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${5gv6_x2u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${v6_amf}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${v6_amf}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${5gv6_s1u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${5gv6_s1u}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${5gv6_ngu}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${5gv6_ngu}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${v6_lnmme}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${v6_lnmme}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${default_v6gw}     alias=source     alias=secondary

     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${5gv6_x2u}     alias=source
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${5gv6_x2u}     alias=source     alias=secondary
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${v6_amf}     alias=source
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${v6_amf}     alias=source     alias=secondary
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${5gv6_s1u}     alias=source
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${5gv6_s1u}     alias=source     alias=secondary
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${5gv6_ngu}     alias=source
     Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
     ...     source_address=${5gv6_ngu}     alias=source     alias=secondary
    Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${v6_lnmme}     alias=source
    Test Ipconnectivity     dut=bts     remote_address=${default_v6gw}    payload_size=${changed_payload_size}     dscp=${changed_dscp}
    ...     source_address=${v6_lnmme}     alias=source     alias=secondary