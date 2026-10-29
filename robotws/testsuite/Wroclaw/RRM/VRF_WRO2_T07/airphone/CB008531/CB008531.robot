*** Settings ***
Force Tags    CLOUD_5G_I_BOO_AP_LOO    SBTS00    RAN_5G_TDD    RAN_5G    CONFIGURED    CRT    PY310    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Piotr Pondel, Maciej Katra
...              :contact: piotr.pondel@nokia.com, maciej.katra@nokia.com

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB008531_Keywords.robot
Resource     ./resources/CB008531_Variables.robot
Variables    ./resources/Capabilities.py
Library      ./resources/CB008531.py
Library      ta5g_testline_management
Library      ta5g_file_system
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ta5g_enb

Suite Setup    Run Keywords    Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Get Iphy Xml File
...            AND             Setup Test Line
...                                iphy_xml_filepath=${CURDIR}/config/iphy.xml
...                                scfc_filename=scfc.xml
...                                perform_full_commissioning=${FULL_COMMISSIONING}
...                                perform_testline_reset=${RESET_TL}
...                                output_dirpath=${OUTPUT_DIR}/testline_prep
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Xn And Ng Interfaces For Second Gnb
...            AND             Reach OnAir    lua_cfg=${CURDIR}/../../../resources/airphone/egate_CA_4FDD_2TDD.lua
...            AND             Enable XN Link
...            AND             Perform Parameter Commissioning
...                                dist_name=MRBTS-1/NRBTS-1   parameter=actUeCapaEnquiryHoCa    value=true
...            AND             Stop Default Logging   output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Perform Parameter Commissioning
...                                   dist_name=MRBTS-1/NRBTS-1   parameter=actUeCapaEnquiryHoCa    value=false
...               AND             Disable XN Link
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                                   Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Run Keyword If    ${RESTORE_DEFAULT_CONFIG}
...                                   Update Iphy Configuration And Modify Swconfig
...                                       iphy_xml_filepath=${OUTPUT_DIR}/iphy.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB008531_D_CA_Robustness
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    @{messages_subcase_1}=    Run Subscenario    scenario_name=CA Capable UE Incoming HO
    @{messages_subcase_2}=    Run Subscenario    scenario_name=CA NotCapable UE Incoming HO
    @{messages_subcase_3}=    Run Subscenario    scenario_name=CA Capable UE Active HO Optimization
    @{messages_subcase_4}=    Run Subscenario    scenario_name=CA NotCapable UE Active HO Optimization
    @{messages_subcase_5}=    Run Subscenario    scenario_name=Blind SCell Addition On Incoming HO
    @{messages_subcase_6}=    Run Subscenario    scenario_name=CA Capable No UE Response To Capability Enquiry
    @{messages_subcase_7}=    Run Subscenario    scenario_name=CA Capable UE Disabled ActUeCapaEnquiryHOCa

    Assert Tcpdump Msg    messages=@{messages_subcase_1}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_1}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD}
    ...                   number_of_messages=1    relation_symbol= >=

    Assert Tcpdump Msg    messages=@{messages_subcase_2}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_2}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
    ...                   number_of_messages=1

    Assert Tcpdump Msg    messages=@{messages_subcase_3}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_3}    packet_filter=${RRC_RECONFIG_SCELL_ADD}
    ...                   number_of_messages=1

    Assert Tcpdump Msg    messages=@{messages_subcase_4}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_4}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
    ...                   number_of_messages=1
    Assert Tcpdump Msg    messages=@{messages_subcase_4}    packet_filter=${RRC_RECONFIG_SCELL_ADD}
    ...                   number_of_messages=0

    Assert Tcpdump Msg    messages=@{messages_subcase_5}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_5}    packet_filter=${RRC_RECONFIG_SCELL_ADD}
    ...                   number_of_messages=1

    Assert Tcpdump Msg    messages=@{messages_subcase_6}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_6}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
    ...                   number_of_messages=2    relation_symbol= >=
    Assert Tcpdump Msg    messages=@{messages_subcase_6}    packet_filter=${RRC_UE_CAPA_INF}
    ...                   number_of_messages=1

    Assert Tcpdump Msg    messages=@{messages_subcase_7}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=1
    Assert Tcpdump Msg    messages=@{messages_subcase_7}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
    ...                   number_of_messages=2    relation_symbol= >=

    [Teardown]    Run Keywords    Add Scout External Execution ID To Reporting Portal
    ...           AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
