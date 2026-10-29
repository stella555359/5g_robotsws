*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R1
    ...    RAN_5G__WITH__SBTS00__WITH__CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    RAN_5G__WITH__SBTS22R4__WITH__CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
    ...    RAN_5G__WITH__SBTS23R1__WITH__CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Documentation    :copyright: Nokia
...              :authors: FTW41
...              :contact: I_EXT_LTE_DEVWRO1_FTW41@internal.nsn.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
#Resource    ../keywords/tshark_verifying.robot
Resource     CB007886_Keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      taf.ul.ettf.setups
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_iphy
Library      Telnet
Library      SSHLibrary
Variables    ta5g_global_var

Suite Setup    Run Keywords    Find Scfc And Fix And Send Full Commissioning    scfc_filename=full_scf_2c_NSA.xml
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             SSH Connection
...            AND             Reach Onair Without Confirmation   lua_cfg=${CURDIR}/config/egate_1aeqa_2c_nsa.lua

Suite Teardown    Run Keywords   Stop Default Processes And Gather Logs And Compress Logs

*** Variables ***
${host}                             192.168.200.1
${username}                         toor4nsn
${password}                         oZPS0POrRieRtu
${port}                             8023
${prompt}                           AaShell>
${timeout}                          10s
${command}                          /opt/UE_APP-OAM/service/OamTerm/oamTerm.py failure_on_carrier_activation 0 1 true\n
${NRcellsToDeleteENDCConfUpdList}   x2ap.ServedNRcellsToDeleteENDCConfUpdList == 1
${Cells_to_be_Activated_List}       f1ap.Cells_to_be_Activated_List == 2
${Served_Cells_To_Delete_List}      f1ap.Served_Cells_To_Delete_List && f1ap.TransactionID == 2


*** Test Cases ***
CB007886_A_B1_Cell_Service_Status_Handling_During_Cell_Setup_Antenna_Carrier_Activation_Failure
    Verification_Tshark_Messages
    Attach Ue To Enb    ue_id=1    pass_regexp=UE IS ACTIVE    timeout=30

*** Keywords ***
SSH Connection
    SSHLibrary.Open Connection     host=${host}
    SSHLibrary.Login               username=${username}    password=${password}
    SSHLibrary.Execute Command     command=${command}
    SSHLibrary.Close All Connections

Verification_Tshark_Messages
    Verify Ngap Messages    packet_filter=${X2_SETUP_REQUEST}
    Verify Ngap Messages    packet_filter=${X2_SETUP_RESPONSE_SUCCESSFUL}
    Verify Tcpdump Log      packet_filter=${Cells_to_be_Activated_List}
    Verify Tcpdump Log      packet_filter=${Served_Cells_To_Delete_List}
    Verify Ngap Messages    packet_filter=${NRcellsToDeleteENDCConfUpdList}
