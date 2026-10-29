*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Piotr Pondel
...              :contact: piotr.pondel@nokia.com
...
...    Test Configuration:
...
...    1. Cells
...
...    cell     | band  |  techn. |   BW (DL/UL)    |  nrarfcn        |     DL MIMO
...    -----------------------------------------------------------------------------------
...    cell_1	 |	n71	 |	FDD	   |	10Mhz		 |	127420/136620  |  2x2 Open Loop
...    cell_2	 |	n66	 |	FDD    |	20MHz		 |	431000/349000  |  2x2 Open Loop
...    cell_3	 |	n66	 |	FDD	   |	20MHz    	 |	427000/347000  |  2x2 Open Loop
...    cell_4	 |	n2	 |	FDD	   |	20MHz		 |	392000/376000  |  2x2 Open Loop
...    cell_5	 |	n41	 |	TDD	   |	60MHz		 |	518580         |  2x2 Open Loop
...    cell_6	 |	n77	 |	TDD	   |	60MHz		 |	649970         |  2x2 Open Loop
...
...    2. cells CA relations:
...
...    pcell/scell |  1  |  2  |  3  |  4  |  5  |  6      CA type              external gNB relation
...    ------------------------------------------------   ---------            -------------------------
...    1           |     |     |     |     |  X  |         FDD+TDD
...    2           |     |     |  X  |  X  |     |         FDD+FDD+FDD
...    3           |  X  |     |     |     |  X  |  X      FDD+FDD+TDD+TDD
...    4           |     |     |     |     |     |         --
...    5           |  X  |     |  X  |     |     |  X      TDD+FDD+FDD+TDD
...    6           |  X  |     |     |     |     |         TDD+FDD                       X

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Resource     ./resources/CB010413_CB008531_Keywords.robot
Resource     ./resources/CB010413_CB008531_Variables.robot
Variables    ./resources/Capabilities.py
Library      ./resources/CB010413.py
Library      ta5g_testline_management
Library      ta5g_file_system
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_iphy
Library      ta5g_enb

Suite Setup    Run Keywords    Enable Cloud
...            AND             Update And Put Iphy Xml Aic    input_filepath=${CURDIR}/config/iphy.xml
...            AND             Send Commissioning Vcu And All Vdus Scfc Filepath
...                            scf_vcu_filepath=${CURDIR}/config/default/SCFC_CU_CB010413.xml
...                            scf_vdu_1_filepath=${CURDIR}/config/default/SCFC_DU_CB010413.xml
...            AND             Call Ap Console Reboot
...            AND             Trigger Site Reset Aic Vcu    waiting_for_f1=False
...            AND             Trigger Site Reset Aic Vdu
...            AND             Wait For All Radios To Be Enabled Aic    timeout=600
...            AND             Wait For F1 Links To Be Available Aic
...            AND             Start Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs
...            AND             Start Additional Vm Ethernet Interfaces
...            AND             Reach Onair    lua_cfg=/home/ute/robotws/testsuite/Wroclaw/RRM/resources/airphone/egate_CA_4FDD_2TDD_aic.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/SetupLogs

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs

*** Test Cases ***
CB008531_D_CA_Robustness
    [Setup]    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

    @{messages_subcase_1}=    Run Subscenario    scenario_name=CA Capable UE Incoming HO
    @{messages_subcase_2}=    Run Subscenario    scenario_name=CA NotCapable UE Incoming HO
    @{messages_subcase_3}=    Run Subscenario    scenario_name=CA Capable UE Active HO Optimization
    @{messages_subcase_4}=    Run Subscenario    scenario_name=CA NotCapable UE Active HO Optimization
    @{messages_subcase_5}=    Run Subscenario    scenario_name=CA Capable UE Disabled ActUeCapaEnquiryHOCa

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
    Assert Tcpdump Msg    messages=@{messages_subcase_4}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=2
    Assert Tcpdump Msg    messages=@{messages_subcase_4}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
    ...                   number_of_messages=1
    Assert Tcpdump Msg    messages=@{messages_subcase_4}    packet_filter=${RRC_RECONFIG_SCELL_ADD}
    ...                   number_of_messages=0

    Assert Tcpdump Msg    messages=@{messages_subcase_5}    packet_filter=${UE_CAPA_ENQUIRY}
    ...                   number_of_messages=1    relation_symbol= >=
    Assert Tcpdump Msg    messages=@{messages_subcase_5}    packet_filter=${RRC_RECONFIG_A1_MEAS_ADD_CAPA_NOID}
    ...                   number_of_messages=2    relation_symbol= >=

    [Teardown]    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
