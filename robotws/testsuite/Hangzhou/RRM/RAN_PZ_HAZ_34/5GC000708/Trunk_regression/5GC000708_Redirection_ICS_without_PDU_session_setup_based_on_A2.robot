# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: Liu Jia
# # #...    contact: jia-rebecca.liu@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC000470-T-708
# # #
# # #
# # #Resource       ../Resources/5GC000708_common_keywords.robot
# # #Variables      Resources/variables.py
# # #Resource       ../../libraries/connection_with_hostname.robot
# # #Variables      Resources/Stream_parameter.py
# # #
# # #Suite Setup    Run Keyword And Ignore Error    Common Suite Setup for COAM
# # #
# # #Suite Teardown    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error    Common Suite Teardown for COAM
# # #
# # #*** Variables ***
# # #${tl_scf_dir_path}        /opt/workspace/SCF/470_708/
# # #${tl_scf_filename}         gNB1_B001.xml
# # #${TL382_GNB2_SCF}          gNB2_B001.xml
# # #${TL367_GNB2_SCF}         TL367_GNB2_B001.xml
# # #${TL343_GNB2_SCF}         TL343_GNB2_B001.xml
# # #${interface}               any
# # #${port}                    br1
# # #${gnb0_BTS_host}            ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# # #${gnb_BTS_username}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${gnb_BTS_password}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${tshark_path}              /usr/bin/tshark
# # #${LOG_PATH}                 /opt/workspace/CIT/Master/Case_Logs/
# # #${eNB_parameter}          administrativeState
# # #${UTE_CPUE}         /opt/workspace/SCF/470_708/cp_runtime.ini
# # ##############case bparameter###############
# # #${NGAP_logB001}     708_B_001_NGAP.pcap
# # #${S1_log_B001}    S1_log_eNB_B001.pcap
# # #${NGAP_logC005}    708_C_005_NGAP.pcap
# # #${S1_log_C005}    S1_log_eNB_C005.pcap
# # #@{expect_message_B_case001}    1    77    0    9
# # #
# # #${5GRU0_ANT9}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# # #${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# # #
# # ###PA
# # #@{PA_value}    ${35}    ${25}    ${45}    ${0}    ${50}    ${30}   #int list
# # #${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# # #${att_api_port}             ${tl.attenuator[0].port}
# # #@{att_connection_port}      ${5GRU0_ANT9}    ${5GRU0_ANT10}     #int list
# # #${HBTE_max_value}           ${120}
# # #${vendor}                    ${tl.attenuator[0].vendor}
# # #
# # #*** Test Cases ***
# # #[1][1.0] 5GC000708_B_001_Inter_Frequency_Redirection_based_on_A2_rsrp_enable
# # #    [Documentation]
# # #    ...    This user scenario describes the gNB behavior, when a UE for which
# # #    ...    ICS_without_PDU_session_setup_based_ with required A2 measurement for Redirection
# # #    [Tags]    Huawei    classical    CRT_21B
# # #    [Setup]    test suite variable set for 708_B001
# # #    Prepare with Trunk BTS cell onair    ip_addr=${${gnb_addr}}    gnb=${${ALIAS}}
# # #    ...     tl_scf_filename_gnb2=${${scf_filename}}
# # #    Adjust the attenuation value for HBTE     value_1=@{PA_value}[3]     value_2=@{PA_value}[3]
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Lock the eNB cell    eNB_cell1_distname=${enbcell_dist_TL343}
# # #    ...    ELSE    Lock the eNB cell
# # #    Run Keyword And Ignore Error    Lock gnb cell    parameters=${${LOCKCELL}}    bts_host=${${bts_host}}
# # #    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
# # #    Huawei UE setup
# # #    Start To Capture Wireshark Logs on gNB2    interface=${interface}    filename=${NGAP_logB001}
# # #    Wait until keyword succeeds    2X    5s    Huawei UE attach    gnb_index=${${INDEX}}
# # #    Start ul data transfer
# # #    sleep    5s
# # ##  gnb2 PA
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'       Adjust the attenuation value for HBTE
# # #                                                                     ...    value_1=@{PA_value}[4]     value_2=@{PA_value}[4]
# # #    ...    ELSE IF    '${release_info}' == 'SBTS21B_ENB_0000'        Adjust the attenuation value for HBTE
# # #                                                                     ...    value_1=@{PA_value}[5]     value_2=@{PA_value}[5]
# # #    ...    ELSE IF    '${release_info}' == 'SBTS22R2_ENB_9999'       Adjust the attenuation value for HBTE
# # #                                                                     ...    value_1=@{PA_value}[4]     value_2=@{PA_value}[4]
# # #    sleep    5s
# # #    Stop and download Logs on gNB2    filename=${NGAP_logB001}
# # #    Analysis wireshark log to check RRC_Release with redirection    logname=${NGAP_logB001}    asik_addr=${${gnb_addr}}
# # #    [Teardown]    Run Keyword And Ignore Error    Recover trunk test env done
# # #
# # #*** Keywords ***
# # #
# # #Recover trunk test env done
# # #    Run Keyword And Ignore Error    Huawei UE teardown
# # #    Run Keyword And Ignore Error    Adjust the attenuation value for HBTE     value_1=@{PA_value}[3]     value_2=@{PA_value}[3]
# # #    Run Keyword And Ignore Error    Lock gnb cell    parameters=${${UNLOCKCELL}}    bts_host=${${bts_host}}
# # #    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
# # #    Run Keyword And Ignore Error    Disable RD flag of rdUeContextRequest    ip_addr=${asik2_addr}    gnb=${ALIAS_ASIK2}
# # #    Run Keyword And Ignore Error    Unlock the eNB cell
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Unlock the eNB cell    eNB_cell1_distname=${enbcell_dist_TL343}
# # #    ...    ELSE    Unlock the eNB cell
# # #
# # #Analysis wireshark on eNB
# # #    ${all_packets}=    pcap.load_pcap_file    pcap_file=${epc_log_path}${S1_log_C005}    tshark_path=${tshark_path}    command_template=${None}
# # #    ${filter_expression}=    Catenate    s1ap
# # #    ${filtered_packets}=    pcap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${procedureCode}=    pcap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//s1ap.procedureCode
# # #    should contain    ${procedureCode}    9
# # #    ${msg_emm_type}=    pcap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nas_eps.nas_msg_emm_type
# # #    should contain    ${msg_emm_type}    49
# # #    ${procedureCode}=    pcap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//s1ap.procedureCode
# # #    should contain    ${procedureCode}    13
# # #    ${msg_emm_type}=    pcap.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//nas_eps.nas_msg_emm_type
# # #    should contain    ${msg_emm_type}    53
# # #
# # ###PA##
# # #Adjust the attenuation value for HBTE
# # #    [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
# # #    [Documentation]    Auther:cris.cai@nokia-sbell.com
# # #    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
# # #    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
# # #    ...                if connect on local plz disconnect firstly
# # #    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
# # #    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
# # #    att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
# # #    att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
# # #    ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
# # #    should be equal    ${value_port1}    ${value_1}
# # #    ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
# # #    should be equal    ${value_port2}    ${value_1}
