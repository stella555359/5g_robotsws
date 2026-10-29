# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...    author: Liu Jia
# # #...    contact: jia-rebecca.liu@nokia-sbell.com
# # #...    squad group: SG_03
# # #...    feature : 5GC000470-T-708
# # #
# # #
# # #
# # #Resource    ../Resources/5GC000708_common_keywords.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# # #Variables    Resources/variables.py
# # #Variables    Resources/Stream_parameter.py
# # #
# # #Suite Setup    Run Keyword And Ignore Error    Common Suite Setup for COAM
# # #Suite Teardown    Run Keyword If Any Tests Failed    Run Keyword And Ignore Error    Common Suite Teardown for COAM
# # #
# # #*** Variables ***
# # #${tl_scf_dir_path}        /opt/workspace/SCF/470_708/
# # #${UTE_CPUE}               /opt/workspace/SCF/470_708/cp_runtime.ini
# # #${tl_scf_filename}    Full_Configuration_scf_MRBTS_1042_cOAM_SA_AEQN.xml
# # #${TL42_GNB2_SCF}     gNB2_Full_Configuration_scf_MRBTS_1012_cOAM_SA_AEQA_eutra.xml
# # #${TL367_GNB2_SCF}     MRBTS-1040_TL040_SA_AAHF_gnb2.xml
# # #${TL343_GNB2_SCF}     TL343_GNB2_C001.xml
# # #${interface}    any
# # #${port}    br1
# # ##############case bparameter###############
# # #${NGAP_log007}    708_D_007_NGAP.pcap
# # #${S1_log_D007}    S1_log_eNB_D007.pcap
# # #${NGAP_log001}    708_C_001_NGAP.pcap
# # #@{expect_message_D}    ESM_MSG_ESM_INFORMATION_RESPONSE
# # #@{expect_message_D_case007}    1    65    0    15
# # #
# # #${5GRU0_ANT9}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# # #${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# # #
# # ###PA
# # #@{PA_value}    ${35}    ${25}    ${45}    ${0}    #int list
# # #${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# # #${att_api_port}             ${tl.attenuator[0].port}
# # #@{att_connection_port}      ${5GRU0_ANT9}    ${5GRU0_ANT10}     #int list
# # #${HBTE_max_value}           ${120}
# # #${vendor}                    ${tl.attenuator[0].vendor}
# # #
# # #*** Test Cases ***
# # #[1][1.0] 5GC000708_C_001_A2_measurement_configuration_for_redirection_and_redirFreqEutra_not_supported_by_UE
# # #    [Documentation]
# # #    ...    This user scenario describes the gNB behavior, when a UE for which context is being created in a cell
# # #    ...    is configured with required A2 measurement for redirection.
# # #    [Tags]    huawei    classical    CIT_21B
# # #    [Timeout]    1 hour
# # #    [Setup]     test suite variable set for 708_C001
# # #    Check one BTS cell onair with disable RD flag    gnb_addr=${${gnb_addr}}        ALIAS=${${ALIAS}}
# # #    ...     tl_scf_filename=${${scf_filename}}     bts_host=${${bts_host_u}}
# # ##    Should be equal    ${cell_status}    PASS
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Lock the eNB cell    eNB_cell1_distname=${enbcell_dist_TL343}
# # #    ...    ELSE    Lock the eNB cell
# # #    Run Keyword And Ignore Error    Lock gnb cell    parameters=${${LOCKCELL}}    bts_host=${${bts_host}}
# # #    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
# # #    Modify parameters online for cases     parameters_to_update=${PARAM_708_C_001}        WEBUI=${${WEBUI}}
# # #    sleep    10s
# # #    start capture wireshark log    interface=${interface}    filename=${NGAP_log001}    gnb_addr=${${gnb_addr}}    ALIAS=${${ALIAS}}
# # #    Huawei UE setup
# # #    Wait until keyword succeeds    2X    5s    Huawei UE attach    gnb_index=${${INDEX}}
# # #    Start ul data transfer
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Unlock eNB and wait cell onair    eNB_cell1_distname=${enbcell_dist_TL343}
# # #    ...    ELSE    Unlock eNB and wait cell onair
# # ##  gnb2 PA
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'       Adjust the attenuation value for HBTE
# # #                                                                     ...    value_1=@{PA_value}[0]     value_2=@{PA_value}[0]
# # #    ...    ELSE IF    '${release_info}' == 'SBTS21B_ENB_0000'        Adjust the attenuation value for HBTE
# # #                                                                     ...    value_1=@{PA_value}[1]     value_2=@{PA_value}[1]
# # #    ...    ELSE IF    '${release_info}' == 'SBTS22R2_ENB_9999'       Adjust the attenuation value for HBTE
# # #                                                                     ...    value_1=@{PA_value}[2]     value_2=@{PA_value}[2]
# # #    sleep    5s
# # #    Collect wireshark logs    filename=${NGAP_log001}    gnb_addr=${${gnb_addr}}    ALIAS=${${ALIAS}}
# # #    ${redi_status}    ${redi_value} =    Run keyword and ignore error
# # #    ...    Analysis wireshark log to check RRC_Release with redirection    logname=${NGAP_log001}    asik_addr=${${gnb_addr}}
# # #    Should be equal    ${redi_status}    FAIL
# # #    [Teardown]    Run keyword and ignore error    Recovery test
# # #
# # #*** Keywords ***
# # #Recovery test
# # #    Run Keyword And Ignore Error    Huawei UE teardown
# # #    Run Keyword And Ignore Error    Adjust the attenuation value for HBTE     value_1=@{PA_value}[3]     value_2=@{PA_value}[3]
# # #    RUN KEYWORD IF    '${release_info}' == 'SBTS22R1_ENB_0000'    Unlock the eNB cell    eNB_cell1_distname=${enbcell_dist_TL343}
# # #    ...     ELSE    Unlock the eNB cell
# # #    Run Keyword And Ignore Error    Lock gnb cell    parameters=${${UNLOCKCELL}}    bts_host=${${bts_host}}
# # #    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
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
