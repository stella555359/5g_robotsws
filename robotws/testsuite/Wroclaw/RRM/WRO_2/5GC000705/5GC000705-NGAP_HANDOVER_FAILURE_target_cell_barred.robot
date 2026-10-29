*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G_TDD    SBTS00    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Krystian Kozlowski, Vira Solomashenko
...              :contact: krystian.kozlowski@nokia.com, vira.solomashenko@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     5GC000705_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../../VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      taf.ul.ettf.setups
Library      ta5g_pm_counters
Variables    ta5g_global_var

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_5GC000705_1AEQE_1c.xml
...			   AND			   With Gnb Configuration     commissioning=full_scfc_5G000705_ho_failure_target_cell_barred.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             With Simulated Network Interface    name=eth3:GNB3_XN_ADDR    ip=10.0.1.4/24
...            AND             With Simulated Network Interface    name=eth3:AMF_NG    ip=10.0.1.1/24
...            AND             Reach Onair Without Confirmation   lua_cfg=${CURDIR}/config/egate_1c_1Ue.lua

Suite Teardown    Stop Default Logging


*** Variables ***
${NGAP: HANDOVER REQUEST}=    ((ngap.HandoverRequest_element)&&(ngap.HandoverType == intra5gs)&&(ngap.dLForwarding == dl-forwarding-proposed))
${NGAP: HANDOVER FAILURE}=    ngap.HandoverFailure_element
${NGAP: HO_Target_Not_Allowed}    (ngap.HandoverFailure_element)&&(ngap.radioNetwork == 8)
${NG_HO_RES_ALC_ATT_TRG}=    M55125C07503
${NG_HO_RES_ALC_F_OTH_TRG}=    M55125C07506
@{counters_list_failure_scenario}=    ${NG_HO_RES_ALC_ATT_TRG}    ${NG_HO_RES_ALC_F_OTH_TRG}

*** Test Cases ***
5GC000705-NGAP_HANDOVER_FAILURE_target_cell_barred

    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Change Simulation UE Location
    Register UE To Simulation gNB
    Start Data Traffic
    Perform NGAP Handover
    Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER REQUEST}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER FAILURE}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HO_Target_Not_Allowed}    timeout=120
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify That Appropriate Counters Incremented Correctly
    ...    counters_list=@{counters_list_failure_scenario}    pm_counter_path=${pm_counter_file}
    [Teardown]    Add Scout Data Info To Testcase

