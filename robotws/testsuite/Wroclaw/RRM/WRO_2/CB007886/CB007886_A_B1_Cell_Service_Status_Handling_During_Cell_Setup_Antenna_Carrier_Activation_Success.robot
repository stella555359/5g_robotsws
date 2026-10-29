*** Settings ***
Force Tags    CONFIGURED    RAN_5G    RAN_5G_TDD
    ...    CLOUD_5G_O_E_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    SBTS00__WITH__CIT
    ...    SBTS22R3__WITH__CIT
    ...    SBTS22R4__WITH__CIT
    ...    SBTS23R1__WITH__CIT

Documentation    :copyright: Nokia
...              :authors: Aleksandra Sienkiel
...              :contact: aleksandra.sienkiel@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB007886_Keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.setups
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    ta5g_global_var


Suite Setup    Run Keywords    Find Scfc And Fix And Send Full Commissioning    scfc_filename=full_scf_1c_NSA.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair   lua_cfg=${CURDIR}/config/egate_NSA_TDD_1c.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SIB1_FOR_ENB2_CELL1}=    ${SIB1} && nr-rrc.cellAccessRelatedInfo_element && iphy.enb_id == 2 && iphy.cell_id == 1
${MIB_FOR_ENB2_CELL1}=    ((nr-rrc.message == 0) && (nr-rrc.cellBarred == 1)) && (iphy.cell_id == 1) && (iphy.enb_id == 2)
${STATUS_TRANSFER}=    (x2ap.procedureCode == 4) && !(x2ap.radioNetwork == 5)

*** Test Cases ***
CB007886_A_B1_Cell_Service_Status_Handling_During_Cell_Setup_Antenna_Carrier_Activation_Success
    Verify Ngap Messages    ${X2_SETUP_REQUEST}    relation_symbol= >=
    Verify Ngap Messages    ${X2_SETUP_RESPONSE_SUCCESSFUL}    relation_symbol= >=
    Verify GNB CU Configuration Update Flow For 1 Cell
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL1}   number_of_messages=1
    Verify GNB DU Configuration Update Flow For 1 Cell
    Attach UE To Enb And Gnb 2
    Verify Ngap Messages    ${STATUS_TRANSFER}
