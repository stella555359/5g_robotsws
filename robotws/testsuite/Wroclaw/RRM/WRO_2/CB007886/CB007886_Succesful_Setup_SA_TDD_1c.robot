*** Settings ***
Force Tags    CONFIGURED    RAN_5G    RAN_5G_TDD
    ...    CLOUD_5G_KL_AP_SA_L1B_CMWV_TDD

Documentation    :copyright: Nokia
...              :authors: Dominik Rejman
...              :contact: dominik.rejman@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
#Resource    ../keywords/tshark_verifying.robot
Resource     CB007886_Keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.setups
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    ta5g_global_var


Suite Setup    Run Keywords    Trigger Site Reset
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair   lua_cfg=${CURDIR}/config/egate_SA_TDD_1c.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${GNB_CU_Configuration_Without_SystemInformation}=   ${F1AP_GNB_CU_CONFIGURATION_UPDATE} && !f1ap.GNB_CUSystemInformation_element
${GNB_DU_Configuration_Without_SystemInformation}=   ${F1AP_GNB_CONFIGURATION_UPDATE} && !f1ap.gNB_DU_System_Information_element
${SIB1_FOR_ENB2_CELL1}=    ${SIB1}  && nr-rrc.cellAccessRelatedInfo_element && iphy.enb_id == 2 && iphy.cell_id == 1
${MIB_FOR_ENB2_CELL1}=    ((nr-rrc.message == 0) && (nr-rrc.cellBarred == 1)) && (iphy.cell_id == 1) && (iphy.enb_id == 2)

*** Test Cases ***
CB007886_Succesful_Cell_Setup_SA_TDD_1c
    Verify Ngap Messages    ${NGAP_NG_SETUP_REQUEST}
    Verify Ngap Messages    ${NGAP_NG_SETUP_RESPONSE}
    Verify GNB CU Configuration Update Flow For 1 Cell
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL1}   number_of_messages=1
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${SIB1_FOR_ENB2_CELL1}    number_of_messages=1
    Verify GNB DU Configuration Update Flow For 1 Cell
    Attach Ue    ue_id=1
