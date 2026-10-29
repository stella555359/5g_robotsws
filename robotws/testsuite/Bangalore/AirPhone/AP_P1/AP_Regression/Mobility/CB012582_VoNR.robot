*** Settings ***
Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description: CB012582 Verify XN Based IntraFrequency IntergNB SA Non CA UE VoNR

Resource          ../../Resources/robot/ue_operations.robot
Resource          ../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB012582

*** Variables ***
${dl_tput}                             20
${ul_tput}                             20
@{Single_SA_HO_UE}                     1
${SA_UE}                               1
${A3_real_gnb_carrier_freq}            636576
${WTS_CFG_PATH}                        ${CURDIR}/Config_Files_CB012582/wts
${NUMBER_OF_CELLS}                     2
@{Sim_Gnb_list_HO}                     2
@{Custom_eth3_interfaces}              10.0.1.3    10.0.1.4

*** Test Cases ***
CB012582_TC1_XN_Based_IntraFrequency_IntergNB_SANSA Non CA UE VoNR
    [Documentation]    Verify XN Based IntraFrequency IntergNB SA Non CA UE VoNR
    [Tags]    CB012582_TC1    AP_REG
    [Setup]    Test Setup For HO cases    Handover_Feature=CB012582    simulator_gnb_list=${Sim_Gnb_list_HO}
    ...    A3_carrier_freq=${A3_real_gnb_carrier_freq}    Need_custom_eth3=True    Custom_eth3_interfaces=${Custom_eth3_interfaces}
    Register and Start Traffic For SA UEs    ${Single_SA_HO_UE}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    pdu=1    pass_regexp=PDU SESSION ID-1 setup/reestablishment complete
    Sleep    30s
    Validate throughput from bearer stats    ue_id=${SA_UE}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=1
    Update UE History Information    id=1    gnb_id=3    cell_type=medium    nrcgi=311:489|0x01    time_ue_stayed_in_cell=100
    ...    ue_enb_param_id=1    action=commit
    Sleep    10s
    Validate throughput from bearer stats    ue_id=${SA_UE}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=1
    Trigger Simple Intrafreq XN Based SA Forward handover    ue_id=${SA_UE}
    ...    carrier_frequency=${A3_carrier_freq}
    Validate throughput from bearer stats    ue_id=${SA_UE}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=1
    Stop Traffic And Detach SA UEs    sa_ue_list=${Single_SA_HO_UE}    pdu=1
    [Teardown]    Test Teardown For HO cases    sa_ue_list=${Single_SA_HO_UE}
