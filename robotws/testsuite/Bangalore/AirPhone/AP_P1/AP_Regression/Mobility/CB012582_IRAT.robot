*** Settings ***
Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description: CB012582_IRAT Verify InterRAT Handover SA Non CA UE VoNR

Resource          ../../Resources/robot/ue_operations.robot
Resource          ../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB012582_IRAT

*** Variables ***
${dl_tput}                             20
${ul_tput}                             20
@{Single_SA_HO_UE}                     1
${SA_UE}                               1
${A2_gnb_carrier_freq}                 636576
${WTS_CFG_PATH}                        ${CURDIR}/Config_Files_CB012582_IRAT/wts
${NUMBER_OF_CELLS}                     1
@{Custom_eth3_interfaces}              10.0.1.9    10.0.1.10    10.0.1.139    10.0.1.140    10.0.1.141
...                                    10.0.1.142    10.0.1.138
@{Custom_eth4_interfaces}              10.0.2.92    10.0.2.2    10.0.2.9    10.0.2.10

*** Test Cases ***
CB012582_InterRAT_Handover_SA Non CA UE VoNR
    [Documentation]    Verify InterRAT Handover SA Non CA UE VoNR
    [Tags]    CB012582_IRAT    AP_REG
    [Setup]    Test Setup For HO cases    Handover_Feature=CB012582_IRAT    Need_custom_eth3=True    Need_custom_eth4=True
    ...    A2_gnb_carrier_freq=${A2_gnb_carrier_freq}    Custom_eth3_interfaces=${Custom_eth3_interfaces}
    ...    Custom_eth4_interfaces=${Custom_eth4_interfaces}
    Register and Start Traffic For SA UEs    ${Single_SA_HO_UE}
    ...    uplink_tput=${ul_tput}    downlink_tput=${dl_tput}    pdu=1
    Sleep    30s
    Validate throughput from bearer stats    ue_id=${SA_UE}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=1
    Trigger InterRAT SA Forward Handover    ue_id=${SA_UE}    A2_carrier_freq=${A2_gnb_carrier_freq}    primary_cell=1
    ...    sim_enb_id=1    sim_cell=1
    Trigger InterRAT SA Reverse Handover    ue_id=${SA_UE}    primary_cell=1    sim_enb_id=1    sim_cell=1
    Validate throughput from bearer stats    ue_id=${SA_UE}    expected_dl_tput=${dl_tput}
    ...    expected_ul_tput=${ul_tput}    mode=SA    pdu_id=1
    Stop Traffic And Detach SA UEs    sa_ue_list=${Single_SA_HO_UE}    pdu=1
    [Teardown]    Test Teardown For HO cases    sa_ue_list=${Single_SA_HO_UE}
