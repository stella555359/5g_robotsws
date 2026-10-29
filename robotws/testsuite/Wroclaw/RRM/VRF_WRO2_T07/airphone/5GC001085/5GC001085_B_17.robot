*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CRT    PY310
...           CONFIGURED    SBTS00    NoResUsage    RF50

Documentation    :copyright: Nokia
...              :authors: Anna Roskosz
...              :maintainer: Marcin Szulc
...              :contact: marcin.szulc@nokia.com

Resource    5GC001085_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Start Additional Vm Ethernet Interfaces
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_1085_B_17.json
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/wts_1085_B_1CELL_TC11_TC17.cfg    align_tac_values=False
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Additional Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             Wait For Testline Icmp Echo Replies And Ssh Services
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

Test Teardown    Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Test Cases ***
5GC001085_B_017_Unsupported_PLMN_received_in_cgi-info
    [Documentation]    Purpose of this testcase is to check the ANR procedure correctness when
    ...                unsupported PLMN is received in MR with cgi-info
    ...                Test case covers requirement: 5G_RAN_USR_RRM_2926
    Wait Until Keyword Succeeds    2x    100ms    Attach UE    ue_id=1
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    gw_id=1
    Send A3 Measurement Report With PCI And Check If Handover Is Not Performed
    Wait For Specified Message In Syslog    msg_regexp=with.*status.*pciIdentified.*Received NeighbourStatusUpdateInd
    Verify Ngap Messages    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}    number_of_messages=0
    Waiting For OAM Config Update
    Check If Object Doesnt Exist    object_name=NRADJNRCELL_A-12288    moc=NRADJNRCELL_A
    Check If Object Doesnt Exist    object_name=NRCELL_A-1/NRREL_A-256    moc=NRREL_A
    Add Scout External Execution ID To Reporting Portal
