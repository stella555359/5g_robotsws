*** Settings ***
Documentation     Keywords for CB008116 feature
Resource        ../CA_Common_Keywords.robot
Resource        ../7_5GC001729/1729_Keywords.robot
Resource        ../14_CB007922/CB007922_Keywords.robot

*** Variables ***
${WTS_CFG_PATH}        ${CURDIR}/cfg
@{SA_Scell_Index}                0    1
@{number_of_amfs}                1    2

*** Keywords ***
Change SMF Security Indication
    FOR    ${amf}    IN    @{number_of_amfs}
        ${cmd}=    Set Variable    smf_param id=${amf} security_indication=pdu_session_setup:required:required
        ${cmd}=    Set Variable    ${cmd} max_data_rate=500mbps
        ${cmd}=    Set Variable    ${cmd} max_ip_data_rate_dl=maximum_UE_rate
        Log    Executing command: ${cmd}
        Execute Egate Command    cmd=${cmd}    timeout=2s
        sleep    5s
    END

Perform UE Register and Start Traffic For SA Non CA Capable UEs and verify SMFsecurityIndication
    [Arguments]    ${sa_ue_list}    ${csi_override}=False    ${uplink_tput}=${ul_tput}
    FOR    ${ue_id}    IN    @{sa_ue_list}
	    Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE Register Is Successful    ue_id=${ue_id}
        ${output}    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
		Verify SMF Security Indication    ${output}
        Run Keyword If    "${csi_override}" == "True"
        ...    Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=0
        Log To Console    Going To Start Traffic for SA Non CA Capable UE: ${ue_id}
        Start Traffic    ue_id=${ue_id}    dir=ul    pdu=3    protocol=udp    mbps=${uplink_tput}
        Start Traffic    ue_id=${ue_id}    dir=dl    pdu=3    protocol=udp    mbps=${uplink_tput}
    END

Perform SA UE Register for Measurement base ScellAddition and Bufferbase ScellActivation CSI Override and verifySMFsecurityIndication
    [Arguments]    ${sa_ue_list}    ${carrier_frequency}    ${scell}=0,1    ${4CC}=False
    ...    ${scell_index_list}=${4CC_scell_index}    ${srsrp_nr}=100
    FOR    ${ue_id}    IN    @{sa_ue_list}
	    Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=3    trf_type=internal
        Ensure UE Register Is Successful    ue_id=${ue_id}
        ${output}    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=3    gw_id=${ue_id}    nwslice=1
		Verify SMF Security Indication    ${output}
        Run Keyword If    "${4CC}" == "True"    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=measurementReport
        ...    carrier_frequency=${carrier_frequency}    srsrp_nr=${srsrp_nr}
        ...    ELSE
        ...    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=sCellIndex ${SA_Scell_Index}[1]
        ...    carrier_frequency=${carrier_frequency}    phycell_id=50    srsrp_nr=40
        Run Keyword If    "${4CC}" == "True"    Verify scell addition for each scell index    ${scell_index_list}
        Associate UE to testmode    id=${ue_id}    testmode=csi_override     profile_id=2    action=activate    scell=${scell}
    END

Trigger Intrafreq SA handover from Sim gNB to Real gNB and verify SMF security Indication
    log to console    SA reverse handover from simulator gNB22 cell1 to real gNB2 cell2
    [Arguments]    ${ue_id}     ${scell_index}    ${carrier_frequency}=522270
    ...    ${csi_override_needed}=False
    ${output}    Trigger A3 Event measurement    ue_id=${ue_id}    pass_regexp=PATH SWITCH REQUEST ACK    carrier_frequency=${carrier_frequency}
    ...    srsrp_nr=11    srsrq_nr=11    phycell_id=51    nrsrp_nr=30    nrsrq_nr=30
	Verify SMF Security Indication    ${output}
    Log To Console    Validating SA reverse handover...
    Validate success prints from command output    ${output}    pass_regex=*UE${ue_id}: Inter-eNB handover from ENB-22.1 to EXT_ENB-2.2 performed*
    Validate success prints from command output    ${output}
    ...    pass_regex=*PATH SWITCH REQUEST ACK with RAN UE NGAP ID*
    Run Keyword If    "${csi_override_needed}" == "True"
    ...    Update CSI Override parameters    profile_id=2    cqi_mode=fixed    cqi=15    ri_mode=fixed    ri=1
    ${output_A1}    Trigger A1 Event measurement    ue_id=${ue_id}    pass_regexp=SCellIndex \\d+ activated successfully
    ...    carrier_frequency=${carrier_frequency}    srsrp_nr=40    phycell_id=50
    Validate success prints from command output    ${output_A1}    pass_regex=*SCellIndex ${scell_index} activated successfully*
    sleep    10s   reason=To stabilise traffic txput

Verify SMF Security Indication
    [Arguments]    ${output}
	${pattern}    Set Variable    integrityProtection enabled
	${status}    ${matched_lines}    Run Keyword And Ignore Error    String.Get Lines Matching Regexp    ${output}
	...    ${pattern}    partial_match=True
	${stripped_matched_lines}    Strip String    ${matched_lines}
	Log To Console    ${stripped_matched_lines}
	${error}    Run Keyword And Continue On Failure    Should Contain    ${stripped_matched_lines}    ${pattern}

Validate Pcell and Scell Throughput For NSA UEs
    [Arguments]    ${expected_dl_tput}    ${UE_List}    ${Scell_Id}
    ${expected_dl_value}    Evaluate    isinstance(${expected_dl_tput}, list) == True
    ${expected_total_dl_tput}    Run Keyword If    ${expected_dl_value}    Evaluate
    ...    sum([int(str(x).encode('ascii')) for x in @{expected_dl_tput}])    ELSE    Set Variable    ${expected_dl_tput}
    FOR    ${ue_id}    IN    @{UE_List}
        Log To Console    Going To Check Throughput for NSA UE: ${ue_id}
        sleep    10s
        ${total_tput}    Get Throughput from all cells    ${ue_id}     ${Scell_Id}
        Total CA UE Throughput Verification from cell stats   ${total_tput}    ${expected_total_dl_tput}
    END
