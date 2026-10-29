*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD


Documentation    :copyright: Nokia
...              :authors: Andrzej Stachowiak
...              :contact: andrzej.stachowiak@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/traffic.robot
Resource    ../keywords/tshark_verifying.robot
Resource     Keywords_CB011081.robot
Resource     Variables_CB011081.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    ta5g_global_var
Library      ta5g_ue_mobility


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy_booloo}
...            AND             Find Scfc And Fix And Send Full Commissioning    ${scfc_AB12}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${BASIC_SETUP}


Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Test Cases ***
CB011081-AB12_6CC_CA_UE_configured_with_DRX_and_established_VoNR_call
    Attach UE And Establish PDU Session    ue_id=${UE_ID_6CC}  cell_id=${SOURCE_CELL_ID}   enb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Send Pdu Session Modify And Start VoNR      ue_id=${UE_ID_6CC}    pdu_id=${PDU_ID}
    Trigger A1 Measurement    ue_id=${UE_ID_6CC}    meas_id=${A1_MEAS_ID}    srsrp_nr=90    srsrq_nr=95
    Start Specific Data DL Traffic    ue_id=${UE_ID_6CC}    pdu_id=${PDU_ID}   mbps_per_trf_id=150    first_trf_id=5    last_trf_id=7
    Start Specific Data UL Traffic    ue_id=${UE_ID_6CC}    pdu_id=${PDU_ID}   mbps_per_trf_id=150    first_trf_id=8    last_trf_id=9
    Verify Established 5QI-5 bearer for IMS Signalling    PDUModifyRequest=${first_PDUModifyRequest}
    Verify Established 5QI-1 bearer for voice data    PDUModifyRequest=${second_PDUModifyRequest}
    Veryfify DRX Profile    drx_profile=${drx_profile_1_configuration}    number_of_messages=1
    Veryfify DRX Profile    drx_profile=${drx_profile_2_configuration}    number_of_messages=4
    [Teardown]    Add Scout Data Info To Testcase
