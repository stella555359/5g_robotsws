*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD
    ...    RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Documentation    :copyright: Nokia
...              :authors: Kuropka Mateusz
...              :contact: mateusz.kuropka@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     5GC000705_keywords.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var

Suite Setup    Run Keywords    Find Scfc And Fix And Send Full Commissioning    scfc_filename=SCFC_1AMF_2PLMN.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair   lua_cfg=${CURDIR}/config/egate_1amf_2plmn.lua

Suite Teardown    Run Keywords   Stop Vm Ethernet Interfaces
...               AND            Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${NGAP: HANDOVER REQUEST}=    ((ngap.HandoverRequest_element)&&(ngap.HandoverType == intra5gs)&&(ngap.dLForwarding == dl-forwarding-proposed))
${NGAP: HANDOVER FAILURE}=    ngap.HandoverFailure_element
${NGAP: HO_Target_Not_Allowed}    (ngap.HandoverFailure_element)&&(ngap.radioNetwork == 8)
${NG_HO_RES_ALC_ATT_TRG}=    M55125C07503
${NG_HO_RES_ALC_F_OTH_TRG}=    M55125C07506
@{Counters_List_Failure_Scenario}=    ${NG_HO_RES_ALC_ATT_TRG}    ${NG_HO_RES_ALC_F_OTH_TRG}

*** Test Cases ***
5GC000705-B_NGAP_HANDOVER_REQUEST_Failure_to_select_UE_serving_PLMN_ID
    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Change Simulation UE Location
    Register UE To Simulation gNB
    Perform NGAP Handover
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER REQUEST}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HANDOVER FAILURE}    timeout=120
    Verify Ngap Messages    packet_filter=${NGAP: HO_Target_Not_Allowed}    timeout=120
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify That Appropriate Counters Incremented Correctly
    ...    counters_list=@{Counters_List_Failure_Scenario}    pm_counter_path=${pm_counter_file}
