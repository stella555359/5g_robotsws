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


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${iphy_booloo_AB13}
...            AND             Find Scfc And Fix And Send Full Commissioning    ${scfc_ab13}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Reach Onair    lua_cfg=${AB13_setup}
...            AND             Wait For Next Full Pm Interval


Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs


*** Test Cases ***
CB011081-AB13_A6_measurement_based_Scell_swap_with_6CC_CA
    Attach UE And Establish PDU Session    ue_id=${UE_ID_6CC}  cell_id=${SOURCE_CELL_ID}   enb_id=${GNB_ID}
    ...    pdu_id=${PDU_ID}    gw_id=${GW_ID}
    Trigger A1 Measurement A6    ue_id=${UE_ID_6CC}    meas_id=${A1_MEAS_ID}
    Start Specific Data DL Traffic    ue_id=${UE_ID_6CC}   pdu_id=${PDU_ID}    last_trf_id=7
    Start Specific Data UL Traffic    ue_id=${UE_ID_6CC}   pdu_id=${PDU_ID}    first_trf_id=8
    Trigger A6 Measurement    A6_cmd=${A6_cmd}
    Verify A6 Measurement    Verify_A6_Measurement=${Veryfication_A6_measurement}
    Verify Scell Swap    Verify_Scell_Swap=${Veryfication_scell_swap}
    Verify Pm Counters AB13
    [Teardown]    Add Scout Data Info To Testcase
