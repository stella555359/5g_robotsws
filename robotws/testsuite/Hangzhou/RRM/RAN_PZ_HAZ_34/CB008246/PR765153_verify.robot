*** Settings ***
Documentation
...    author: Shi Ming
...    contact: ming.shi@nokia-sbell.com
...    squal group: SG03
...    feature: CB008246

Force Tags  CA_5G_RRM
...    PY36
#Suite Setup    Run Keywords
#...             robot_common_operations.Common Suite Setup
#...             AND    Common Suite Setup for COAM
#...             AND    Get gnb release info
#...             AND    Common Case TestLine Setup    is_commission=True    scf_path=${scf_path}    golden_scf_name=${tl_scf_${release_info}}
##...             AND    Setup for Env cell on-air for 2 gnb    is_commission_for_second_gnb=False
#...             AND    Common UE parameter setup
#
#Suite Teardown     Common Suite Teardown for COAM    gnb_list=${gnb_list}

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.robot

*** Variables ***
${log_name_PR765153_verify_1}    log_name_PR765153_verify_1.pcap
${ue_type}    ${tl.ues[2].capabilities[2]}

*** Test Cases ***
PR765153_verify
    [Timeout]     1 hours
    [Setup]
    Online modify parmeters     parameters_to_update=${PARAM_8246_gnb1_E_008}    skip_parameter_relation_errors=False
    Run Keyword If    '${enb_instance}'=='${diffTL_enb_ID}[0]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[1]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    ...    ELSE IF    '${enb_instance}'=='${diffTL_enb_ID}[2]'    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=${0}
    Power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${2}
    Repeat Keyword    10 times    PR765153 UE2 attach


*** Keywords ***
PR765153 UE2 attach
    Start capture gNB log on master    filename=${log_name_PR765153_verify_1}
    Attach and check power UE    ue_type=${ue_type}    ue_index=${2}    gnb_index=${0}
    Stop and download Logs on gNB on master    filename=${log_name_PR765153_verify_1}
    Check wireshark log for PR765153_verify
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${log_name_PR765153_verify_1}
    ...    AND    Run Keyword If    '${KEYWORD STATUS}' == 'PASS'
    ...    QCM UE Recover Detach    ue_index=${2}    status=${0}    ue_type=${ue_type}
    ...    ELSE
    ...    Run keyword and continue on failure    COAM Save snapshot

Check wireshark log for PR765153_verify
    Check UL_UE_MCS_table_Capbility_and_5QI_5_7    logname=${log_name_PR765153_verify_1}

Check UL_UE_MCS_table_Capbility_and_5QI_5_7
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    f1ap.procedureCode == 12 and nr-rrc.uplinkBWP_ToAddModList == 1 and nr-rrc.mcs_Table == 1
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${nr_rrc_mcs_Table}=     cap.Get Field Value By Xpath    xpath=.//nr-rrc.mcs_Table    pcap_parser=test6
    Should Be Equal    ${nr_rrc_mcs_Table[1]}    1
    ${filter_expression}=     Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 14)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI_1}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    ${filter_expression}=     Catenate    (ngap.NGAP_PDU == 0) && (ngap.procedureCode == 29)
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI_2}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    ${ngap_fiveQI}=    Create List    ${ngap_fiveQI_1}[0]    ${ngap_fiveQI_2}[0]
    Should Contain    ${ngap_fiveQI}    5
    Should Contain    ${ngap_fiveQI}    7
    ${length}=    Get Length    ${ngap_fiveQI}
    Should Be Equal As Integers    ${length}    2
