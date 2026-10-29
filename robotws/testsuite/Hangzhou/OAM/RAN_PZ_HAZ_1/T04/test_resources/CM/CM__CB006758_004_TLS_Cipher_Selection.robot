*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Keywords ***
CM__CB006758_004_TLS_Cipher_Selection
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case: CM__TLS_Cipher_Selection_CB006758_Case4
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.06.2023 - Commit to robotws
    Set Tags    CM    UI    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-bin.7.liu@nokia-sbell.com
    Verify SBTS is TLS Setting
    Check TLS Hand Shake Message

Check TLS Hand Shake Message
    Log    Check TLS Hand Shake Message    console=${True}
    ${list_ciphersuite}    Create List    tls.handshake.ciphersuite == 0xc030    tls.handshake.ciphersuite == 0x009f
    ...    tls.handshake.ciphersuite == 0x006b    tls.handshake.ciphersuite == 0x009d    tls.handshake.ciphersuite == 0x003d
    Append To List    ${list_ciphersuite}    tls.handshake.ciphersuite == 0x009e    tls.handshake.ciphersuite == 0x0067
    ...    tls.handshake.ciphersuite == 0x009c    tls.handshake.ciphersuite == 0x003c    tls.handshake.ciphersuite == 0x00ff
    ${long_tls_version}    Create List    SBTS23R1    SBTS23R2    SBTS23R3    SBTS23R4
    ${active SW version head}    Fetch From Left    ${active SW version}    _
    ${is_long_tls}    Run Keyword And Return Status    List Should Contain Value    ${long_tls_version}    ${active SW version head}
    Run Keyword If    ${is_long_tls}    Append To List    ${list_ciphersuite}    tls.handshake.ciphersuite == 0xc02c
    ...    tls.handshake.ciphersuite == 0xc02b
    ${tls_length}    Set Variable If    ${is_long_tls}    24    20
    ${filter_str_ciphersuite}    Catenate    SEPARATOR=${SPACE}&&${SPACE}    @{list_ciphersuite}
    ${tmp_str1}    Set Variable    tls.handshake.cipher_suites_length == ${tls_length} and
    ${tmp_str2}    Set Variable    tls.handshake.type == 1 and tls.handshake.version == 0x0303 and (${filter_str_ciphersuite})
    ${tshark_Y_filter_str}    Set Variable     ${tmp_str1} ${tmp_str2}
    Log    ${tshark_Y_filter_str}
    ${ssh_connection}    Establish SSH to SBTS    ${SMOD1['IP']}
    ${tmp_cmd1}    Set Variable    tcpdump -i ${ENB_MPLANE_INTERFACE} -w ~/SBTS_to_NetAct_tcpdump_log.cap src host ${MPLANE_IP} and
    ${tmp_cmd2}    Set Variable    dst host ${NETACT['ne3sws_host']}
    Execute CMD Via SSH connection    ${tmp_cmd1} ${tmp_cmd2}        listening on ${ENB_MPLANE_INTERFACE}
    sleep    20s    #20 seconds is sufficient and necessary for catching hand shake message.
    SSHLibrary.Close Connection
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...     sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['IP']}:~/SBTS_to_NetAct_tcpdump_log.cap ${OUTPUT_DIR}/ \
    LOG    ${output}
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output
    ...    tshark -r ${OUTPUT_DIR}/SBTS_to_NetAct_tcpdump_log.cap -Y '${tshark_Y_filter_str}'
    LOG    ${output}
    ${lines}    String.Get Lines Containing String    ${output}    Client Hello
    Should Not Be Empty    ${lines.strip()}

Verify SBTS is TLS Setting
    Log    Verify SBTS is TLS Setting    console=${True}
    ${cur_scf}    coam.Get_SCF
    ${DN_MPLANENW}    XML.Get Element Attribute    ${cur_scf}    distName    cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]
    ${param_elements}    XML.Get Elements    ${cur_scf}    cmData/managedObject[@class="com.nokia.srbts.mnl:MPLANENW"]/p
    ${dic_param_expect}    Create Dictionary    oamTls=forced    tls12CbcCipherDisabled=false    tls12RsaKExDisabled=false    tls12Enabled=true
    ${same_as_expect}    Set Variable    ${True}
    FOR    ${element}    IN    @{param_elements}
        ${p_name}    XML.Get Element Attribute    ${element}    name
        ${expect_value}    Pop From Dictionary    ${dic_param_expect}    ${p_name}    !EMPTY!
        Continue For Loop If    '${expect_value}'=='!EMPTY!'
        ${cur_value}    XML.Get Element Text    ${element}
        Continue For Loop If    '${expect_value}'=='${cur_value}'
        ${same_as_expect}    Set Variable    ${False}
    END
    Return From Keyword If    ${same_as_expect}
    ${tmp_plan1}    Set Variable    [{"distName": "${DN_MPLANENW}","operation": "update","parameters":
    ${tmp_plan2}    Set Variable    [{"parameterName": "oamTls","value": "forced","operation": "update"},
    ${tmp_plan3}    Set Variable    {"parameterName": "tls12CbcCipherDisabled","value": "false","operation": "update"},
    ${tmp_plan4}    Set Variable    {"parameterName": "tls12RsaKExDisabled","value": "false","operation": "update"},
    ${tmp_plan5}    Set Variable    {"parameterName": "tls12Enabled","value": "true","operation": "update"}]}]
    ${delta_plan}    Set Variable    ${tmp_plan1} ${tmp_plan2}${tmp_plan3}${tmp_plan4}${tmp_plan5}
    coam.perform_delta_recommissioning    ${delta_plan}
