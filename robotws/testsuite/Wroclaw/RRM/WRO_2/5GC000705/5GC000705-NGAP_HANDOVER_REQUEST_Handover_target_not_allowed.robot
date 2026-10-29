*** Settings ***
Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G_TDD
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     5GC000705_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot

Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      taf.ul.ettf.setups
Variables    ta5g_global_var


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_5GC000705_1AEQE_1c.xml
...            AND             With Gnb Configuration     commissioning=full_scfc_5G000705_lo_ap_lo_disabled.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             With Simulator Configuration   config=${CURDIR}/config/egate_1c_1Ue.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${NGAP: HANDOVER REQUEST}=    ((ngap.HandoverRequest_element)&&(ngap.HandoverType == intra5gs)&&(ngap.dLForwarding == dl-forwarding-proposed))
${NGAP: HANDOVER FAILURE}=    ngap.HandoverFailure_element
${NGAP: HO_Target_Not_Allowed}    (ngap.HandoverFailure_element)&&(ngap.radioNetwork == 8)
${NG_HO_RES_ALC_ATT_TRG}=    M55125C07503
${NG_HO_RES_ALC_F_OTH_TRG}=    M55125C07506
@{counters_list_failure_scenario}=    ${NG_HO_RES_ALC_ATT_TRG}    ${NG_HO_RES_ALC_F_OTH_TRG}
*** Test Cases ***
5GC000705-NGAP_HANDOVER_REQUEST_Handover_target_not_allowed
    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Change Simulation UE Location
    Register UE To Simulation gNB
    Start Data Traffic
    Perform NGAP Handover
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER REQUEST}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER FAILURE}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HO_Target_Not_Allowed}    timeout=120

    #Verify Handover Target Not Allowed Message
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify That Appropriate Counters Incremented Correctly
    ...    counters_list=@{counters_list_failure_scenario}    pm_counter_path=${pm_counter_file}
