*** Settings ***

Documentation    :copyright: Nokia

*** Keywords ***
Start Additional Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24

Stop Additional Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24

Run Subcase With Dedicated Pcaps Collection
    [Arguments]    ${scenario_name}    @{args}    ${log_filename_prefix}
    ${tshark_alias_ue}=    Start Tshark For Uu Interface
    ...                        log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                        log_filename_prefix=${log_filename_prefix}
    ${tshark_alias_core}=    Start Tshark For S1 Mme Interface
    ...                          log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                          log_filename_prefix=${log_filename_prefix}
    ${tcpdump_F1_E1}=    Start Tcpdump On Remote Interface AiC
    ...                      log_dirpath=${OUTPUT_DIR}${/}${TEST_NAME}${/}${TSHARK_SUBDIR}
    ...                      log_filename_prefix=${log_filename_prefix}_F1_E1_tcpdump
    Sleep    2s    reason=waitinig for new tshark process to start capturing packets
    Run Keyword    ${scenario_name}    @{args}
    Sleep    2s    reason=waitinig for new tshark process to store all packets

    ${tcpdump_process}=    Set Variable    ${tcpdump_F1_E1}[0]
    ${tcpdump_filepath}=    Set Variable    ${tcpdump_F1_E1}[1]
    ${tcpdump_alias}=    Set Variable    ${tcpdump_F1_E1}[2]

    Stop Tshark    alias=${tshark_alias_ue}
    Stop Tshark    alias=${tshark_alias_core}
    Stop Tcpdump Log Collection    process=${tcpdump_process}
    RETURN    ${tshark_alias_ue}    ${tshark_alias_core}    ${tcpdump_alias}    ${tcpdump_filepath}

Run Subscenario
    [Arguments]    ${scenario_name}
    ${log_filename_prefix}    Replace Spaces In Prefix Name    ${scenario_name}
    Run Keyword And Return    Run Subcase With Dedicated Pcaps Collection
    ...                       scenario_name=${scenario_name}
    ...                       log_filename_prefix=${log_filename_prefix}

Assert Tcpdump Msg
    [Arguments]    ${messages}    ${packet_filter}    ${number_of_messages}    ${relation_symbol}= ==
    Verify Tcpdump Log
    ...    alias=${messages}[2]
    ...    packet_filter=${packet_filter}
    ...    number_of_messages=${number_of_messages}
    ...    pcap_file_path=${messages}[3]
    ...    relation_symbol=${relation_symbol}

Reset Testline And Wait For Rmods And Collect Logs
    Reset Testline
    Wait For Testline Icmp Echo Replies And Ssh Services
    Start Default Logging    output_dirpath=${OUTPUT_DIR}/reset_testline
    Check Radios Availability
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/reset_testline

Send A2 Event For HO
    [Arguments]    ${meas_id}=1    ${ue_id}=1    ${srsrp}=1    ${srsrq}=1    ${ssinr}=1
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete
    Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id}    pass_regexp=
    ${command} =  catenate    SEPARATOR=
    ...           ue_measurement_send_nr id=${ue_id} meas_id=${meas_id}
    ...           \ event=A2 srsrp_nr=${srsrp} srsrq_nr=${srsrq} ssinr_nr=${ssinr}

    Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}

Send A5 Event For Inter-Frequency HO
    [Arguments]    ${ue_id}=1   ${meas_id}=5    ${srsrp}=1    ${ssinr}=1    ${srsrq}=1  ${neigh_phycellid}=53
    ...            ${nrsrp}=127   ${nrsrq}=127   ${nsinr}=127     ${pass_regexp}=message c1 : rrcReconfigurationComplete
    Execute Egate Command    cmd=ue_meas_cfg_disp id=${ue_id}    pass_regexp=
    ${command} =  catenate    SEPARATOR=
    ...           ue_measurement_send_nr
    ...           \ id=${ue_id} meas_id=${meas_id}
    ...           \ event=A5 srsrp_nr=${srsrp} srsrq_nr=${srsrq} ssinr_nr=${ssinr}
    ...           \ phycell_id=${neigh_phycellid} nrsrp_nr=${nrsrp} nrsrq_nr=${nrsrq} nsinr_nr=${nsinr}

    Execute Egate Command    cmd=${command}    pass_regexp=${pass_regexp}

Create Ue History For Simulated Gnb
    [Arguments]    ${local_id}=1    ${gnb_id}=3
    ${command_create_history} =  catenate    SEPARATOR=
    ...                          ue_history_information_list_add_ngran
    ...                          \ id=1 gnb_id=${gnb_id}
    ...                          \ cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    ${command_commit} =  catenate    SEPARATOR=
    ...                  ue_history_information_list
    ...                  \ id=${local_id} action=commit
    Execute Egate Command    cmd=${command_create_history}
    Execute Egate Command    cmd=${command_commit}

Apply UE History
    [Arguments]    ${ue_id}
    ${command_ue_enb_param} =  catenate    SEPARATOR=
    ...                        ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    cmd=${command_ue_enb_param}

Change Action Of RRC UE Capability Enquiry
    [Arguments]    ${action}    ${ue_id}
    ${command} =  catenate    SEPARATOR=
    ...           ue_capability_enquiry_param id=${ue_id} if_contains=nr action=${action}
    Execute Egate Command    cmd=${command}

Perform Ue Ho To Neighbour Gnb And Trigger Ho Back
    [Arguments]    ${ue_id}    ${gw_id}     ${meas_id}=5
    Wait Until Keyword Succeeds    2x  100ms   ta5g_ue_mobility.Attach Ue    ue_id=${ue_id}    pass_regexp=Received REGISTRATION COMPLETE from UE
    Establish PDU Session    ue_id=${ue_id}    pdu_id=1    gw_id=${gw_id}
    Sleep    2s    reason=stabilisation purposes
    Send A2 Event For HO    ue_id=${ue_id}    meas_id=1
    Sleep    2s    reason=stabilisation purposes
    Send A5 Event For Inter-Frequency HO    neigh_phycellid=56    meas_id=${meas_id}    ue_id=${ue_id}
    Sleep    2s    reason=stabilisation purposes
    Apply UE History    ue_id=${ue_id}
    Sleep    2s    reason=stabilisation purposes
    Send A5 Event For Inter-Frequency HO    neigh_phycellid=50    meas_id=1    ue_id=${ue_id}

Enable XN Link
    Perform Parameter Commissioning Aic    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-1    parameter=administrativeState    value=Unlocked

Disable XN Link
    Perform Parameter Commissioning Aic    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-1    parameter=administrativeState    value=Locked

CA Capable UE Incoming HO
    [Documentation]    This testcase test gNB behavior, which has A1 meas based S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has capabilities for CA setup on target gNB.
    ...                gNB shall configure A1 measurement in last RRC Reconfiguration message for S-Cell addition purposes
    ...                right after sending UE Capability enquiry. Therefore there will be *2* messages contatining
    ...                A1 measurement Addtion ( one for HO purposes, one for CA purposes)
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_1}    ue_nr_capabilities=${UE_CA_CAPA_PRESENT}
    Create Ue History For Simulated Gnb
    Perform Ue Ho To Neighbour Gnb And Trigger Ho Back    ue_id=${UE_ID_1}    gw_id=1    meas_id=5
    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID_1}

CA NotCapable UE Incoming HO
    [Documentation]    This testcase test gNB behavior, which has A1 meas based S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has no capabilities for CA setup on target gNB.
    ...                After receiving UE Capa enquiry response, gnb shall not send RRC Reconfiguration with
    ...                A1 measurement Addition for CA. Therefore there will be only one RRC Reconfiguration with A1 Configuration
    ...                Present in tshark files ( A1 conf for HO purposes )
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_2}   ue_nr_capabilities=${UE_NO_CA_CAPA_PRESENT}
    Perform Ue Ho To Neighbour Gnb And Trigger Ho Back    ue_id=${UE_ID_2}    gw_id=2    meas_id=3
    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID_2}

CA Capable UE Active HO Optimization
    [Documentation]    This testcase test gNB behavior, which has A1 meas based S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has capabilities for CA setup on target gNB,
    ...                and HO Optimization is active on target gNB
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_3}    ue_nr_capabilities=${UE_CA_CAPA_PRESENT}
    Perform Ue Ho To Neighbour Gnb And Trigger Ho Back    ue_id=${UE_ID_3}    gw_id=3    meas_id=5
    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID_3}


CA NotCapable UE Active HO Optimization
    [Documentation]    This testcase test gNB behavior, which has A1 meas based S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has capabilities for CA setup on target gNB,
    ...                and HO Optimization is active on target gNB, when UE has no capabilities for desired CA.
    ...                gNB shall not configure A1 measurement nor S-Cell for UE
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_4}   ue_nr_capabilities=${UE_NO_CA_CAPA_PRESENT}
    Perform Ue Ho To Neighbour Gnb And Trigger Ho Back    ue_id=${UE_ID_4}    gw_id=4    meas_id=3
    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID_4}


Blind SCell Addition On Incoming HO
    [Documentation]    This testcase test gNB behavior, which has blind S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has capabilities for CA setup on target gNB,
    ...                GNB shall immediately ask for S-cell addition after capability enquiry. Number of SCELL_ADD
    ...                messages is two as initial admittance of UE to gNB also results in scell additon (cause its set to blind)
    vcu_cm.Enable M2M Rest API Via Delta Commission
    vcu_cm.Fast Delta Commissioning With Delta XML File
    ...    ${CURDIR}/../config/default/delta_set_scelladditionmethod_to_blind.xml
    Wait For F1 Links To Be Available Aic
    Sleep    30s    reason=Waitinig for MIBs and SIBS after Cu reset caused by delta commissioning
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_5}    ue_nr_capabilities=${UE_CA_CAPA_PRESENT}
    Perform Ue Ho To Neighbour Gnb And Trigger Ho Back    ue_id=${UE_ID_5}    gw_id=5    meas_id=5
    [Teardown]    Run Keywords    Deregister Ue Without Confirmation    ue_id=${UE_ID_5}
    ...           AND             vcu_cm.Enable M2M Rest API Via Delta Commission
    ...           AND             vcu_cm.Fast Delta Commissioning With Delta XML File
    ...                               ${CURDIR}/../config/default/delta_set_scelladditionmethod_to_covbaseda1.xml
    ...           AND             Wait For F1 Links To Be Available Aic

CA Capable No UE Response To Capability Enquiry
    [Documentation]    This testcase test gNB behavior, which has A1 meas based S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has capabilities for CA setup on target gNB, but Capability Info
    ...                got lost and there is no response for enquiry. gNB shall Configure A1 measurement for that UE, and ignore lack of response.
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_6}    ue_nr_capabilities=${UE_CA_CAPA_PRESENT}
    ta5g_ue_mobility.Attach Ue    ue_id=${UE_ID_6}    pass_regexp=Received REGISTRATION COMPLETE from UE
    Establish PDU Session    ue_id=${UE_ID_6}    pdu_id=1    gw_id=6
    Send A2 Event For HO    ue_id=${UE_ID_6}    meas_id=1
    Send A5 Event For Inter-Frequency HO    neigh_phycellid=56    ue_id=${UE_ID_6}    meas_id=5
    Create Ue History For Simulated Gnb    ue_id=${UE_ID_6}
    Change Action Of RRC UE Capability Enquiry    ue_id=${UE_ID_6}    action=drop
    Apply UE History    ue_id=${UE_ID_6}
    Send A5 Event For Inter-Frequency HO    neigh_phycellid=50    ue_id=${UE_ID_6}    meas_id=1
    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID_6}

CA Capable UE Disabled ActUeCapaEnquiryHOCa
    [Documentation]    This testcase test gNB behavior, which has A1 meas based S-Cell addition active,
    ...                when there is an incoming inter-GNB HO and UE has capabilities for CA setup on target gNB.
    ...                when Capa Enquiry is disabled, but UE has capabilities for CA on that gNB. A1 Should be configured for that UE
    Execute Manual Step     message=dist_name=MRBTS-1/NRBTS-1_parameter=actUeCapaEnquiryHoCa_value=false
    Setup Custom UE Radio Capabilities    ue_id=${UE_ID_7}    ue_nr_capabilities=${UE_CA_CAPA_PRESENT}
    Perform Ue Ho To Neighbour Gnb And Trigger Ho Back    ue_id=${UE_ID_7}    gw_id=7    meas_id=5
    [Teardown]    Deregister Ue Without Confirmation    ue_id=${UE_ID_7}
