*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G_TDD    SBTS00    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Krystian Kozlowski
...              :contact: krystian.kozlowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB007886_Keywords.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      Telnet
Library      SSHLibrary

Library      ta5g_cell_operations
Library      ta5g_admin_operations

Variables    ta5g_global_var

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_7886_NSA_SA_2c_cell_add.xml
...            AND             Find Scfc And Fix And Send Full Commissioning    scfc_filename=full_scf_cell1_SA.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair Without Confirmation   lua_cfg=${CURDIR}/config/egate_2c_NSA_SA.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${SIB1_FOR_ENB2_CELL1}=    ${SIB1} && nr-rrc.cellAccessRelatedInfo_element && iphy.enb_id == 2 && iphy.cell_id == 1
${MIB_FOR_ENB2_CELL1}=    ((nr-rrc.message == 0) && (nr-rrc.cellBarred == 1)) && (iphy.cell_id == 1) && (iphy.enb_id == 2)
${MIB_FOR_ENB2_CELL2}=    ((nr-rrc.message == 0) && (nr-rrc.cellBarred == 1)) && (iphy.cell_id == 2) && (iphy.enb_id == 2)
${loop_count}=    10
${id_of_cell_to_be_added}=    2

*** Test Cases ***
CB007886_A_B1_Cell_Service_Status_Handling_During_Dynamic_Cell_Addition
    Verify Ngap Messages    packet_filter=${NGAP_NG_SETUP_REQUEST}    timeout=200
    Verify Ngap Messages    packet_filter=${NGAP_NG_SETUP_RESPONSE}    timeout=200
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL1}   number_of_messages=1
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${SIB1_FOR_ENB2_CELL1}    number_of_messages=1

    Find Scfc and Send Delta Commissioning    scfc_filename=delta_add_cell2_moc.json

    Wait For Cells Are In Correct State    cell_ids=${id_of_cell_to_be_added}    search_key=operationalState    cells_status=Enabled

    Verify GNB CU Configuration Update Flow For NSA Cell
    Verify GNB CU Configuration Update Flow For SA Cell
    Verify GNB DU Configuration Update Flow For NSA Cell
    Verify GNB DU Configuration Update Flow For SA Cell
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL2}   number_of_messages=1

    Repeat keyword    ${loop_count}    Lock And Unlock Cell 2

*** Keywords ***
Lock And Unlock Cell 2
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-${id_of_cell_to_be_added}    parameter=administrativeState    value=Locked
    Wait For Cells Are In Correct State    cell_ids=${id_of_cell_to_be_added}    search_key=operationalState    cells_status=Disabled
    Perform Parameter Commissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-${id_of_cell_to_be_added}    parameter=administrativeState    value=Unlocked
    Wait For Cells Are In Correct State    cell_ids=${id_of_cell_to_be_added}    search_key=operationalState    cells_status=Enabled
