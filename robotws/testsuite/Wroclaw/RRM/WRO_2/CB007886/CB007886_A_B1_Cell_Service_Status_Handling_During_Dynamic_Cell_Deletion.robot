*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G_TDD
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     CB007886_Keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.setups
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Variables    ta5g_global_var


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_7886_NSA_SA_2c.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair   lua_cfg=${CURDIR}/config/egate_2c_NSA_SA.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${scfc}=              full_scf_2c_NSA_SA.xml
${SIB1_FOR_ENB2_CELL_NSA}=    ${SIB1} && nr-rrc.cellAccessRelatedInfo_element && iphy.enb_id == 2 && iphy.cell_id == 1
${MIB_FOR_ENB2_CELL_NSA}=    ((nr-rrc.message == 0) && (nr-rrc.cellBarred == 1)) && (iphy.cell_id == 1) && (iphy.enb_id == 2)
${SIB1_FOR_ENB2_CELL_SA}=    ${SIB1} && nr-rrc.cellAccessRelatedInfo_element && iphy.enb_id == 2 && iphy.cell_id == 2
${MIB_FOR_ENB2_CELL_SA}=    ((nr-rrc.message == 0) && (nr-rrc.cellBarred == 1)) && (iphy.cell_id == 2) && (iphy.enb_id == 2)

*** Test Cases ***
CB007886_A_B1_Cell_Service_Status_Handling_During_Dynamic_Cell_Deletion
    Verify Ngap Messages    ${X2_SETUP_REQUEST}    number_of_messages=2
    Verify Ngap Messages    ${X2_SETUP_RESPONSE_SUCCESSFUL}    number_of_messages=2
    Verify Ngap Messages    ${NGAP_NG_SETUP_REQUEST}
    Verify Ngap Messages    ${NGAP_NG_SETUP_RESPONSE}
    Verify GNB CU Configuration Update Flow For NSA Cell
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL_NSA}   number_of_messages=1
    Verify GNB DU Configuration Update Flow For NSA Cell
    Verify GNB CU Configuration Update Flow For SA Cell
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL_SA}   number_of_messages=1
    Verify Tshark For At Least Given Number Of Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${SIB1_FOR_ENB2_CELL_SA}    number_of_messages=1
    Verify GNB DU Configuration Update Flow For SA Cell
    Attach Ue To NSA Cell
    Attach Ue To SA Cell
	Remove SA Cell From gNB Configuration By Delta Commissioning
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${MIB_FOR_ENB2_CELL_SA}
    Verify Tshark For No Messages
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}    packet_filter=${SIB1_FOR_ENB2_CELL_SA}
    Verify GNB DU Configuration Update Flow For SA Cell After Cell Deletion
    Attach Ue To SA Cell Fails


*** Keywords ***
Remove SA Cell From gNB Configuration By Delta Commissioning
    Find Scfc and Send Delta Commissioning    scfc_filename=delta_7886_SA_cell_delete.json

Attach Ue To SA Cell Fails
	Attach Ue    ue_id=2    pass_regexp=UE2: Cell is blocked

Attach Ue To NSA Cell
    Attach Ue To Enb    ue_id=1
    Start Gnb Addition Procedure    ue=1    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}

Attach Ue To SA Cell
	Attach Ue    ue_id=2
