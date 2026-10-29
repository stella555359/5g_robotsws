*** Settings ***
Force Tags    RAN_5G    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]    SBTS00

Documentation   :copyright: Nokia
...             :authors: Dawid Rusek
...             :contact: dawid.rusek@nokia.com

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T06/CB008490/resources/feature_keywords.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T06/resources/multignb_variables.py
Library        ta5g_commissioning
Library        ta5g_enb
Library        ta5g_iphy
Library        ta5g_egate
Library        ute_wtssim
Library        ute_fsmaccess
Library        ta5g_testline_management
Library        testsuite/Wroclaw/RRM/resources/scout_report.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaFixer.py
Library        testsuite/Wroclaw/RRM/resources/syslog_checker.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.py

Suite Setup         Run Keywords    Start Default Simulated Gnb Interface
...    AND         Start Vm Ethernet Interface    if_name=eth3:GNB_4    ip_with_mask=10.0.2.100/24
...    AND         Start Vm Ethernet Interface    if_name=eth3:GNB4_XN    ip_with_mask=10.0.1.4/24
Test Teardown      Run Keywords    Stop Default Processes And Gather Logs
...    AND         Add Scout Scf Id To Test Data
...    AND         Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
${SCFC_MN}=             scf_MN_CB008490_GD_B101_B301.xml
${SCFC_SN}=             scf_SN_CB008490_GD_B101_B301.xml
${IPHY}=                ${CURDIR}/config/CB008490_GD_B101_B301_iphy.xml
${EGATE}=               ${CURDIR}/config/CB008490_GD_B101_B301_WTS.cfg
${DELTA_B101_STEP1}=          delta_CB008490_GD_B101_B301_Step1_cells_locked.json
${DELTA_B101_STEP2}=          delta_CB008490_GD_B101_B301_Step2_cells_deleted.json
${DELTA_B101_STEP3}=          delta_CB008490_GD_B101_B301_Step3_cells_deleted.json
${DELTA_B101_B4_STEP4}=       delta_CB008490_GD_B101_B301_Step4_nradjgnb_unlocked.json
${DELTA_B301_STEP5}=          delta_CB008490_GD_B101_B301_Step5_add_locked_cell.json
${DELTA_B301_STEP6}=          delta_CB008490_GD_B101_B301_Step6_last_cell_delete.json
${SN_GNB_ID}=           3
${PEER_GNB_ID}=         4
${SCFC_MN_GG}=             GG_B401/Configuration_MN_GG_B401.xml
${SCFC_SN_GG}=             GG_B401/Configuration_SN_GG_B401.xml
${IPHY_GG}=                ${CURDIR}/config/iphy_GG_B401.xml
${EGATE_GG}=               ${CURDIR}/config/CB008490_GG_B401.cfg

*** Test Cases ***
CB008490-GD_B101_B301_Main_Dynamic_Deletion_Of_NR-DC-SN_Cells_In_RAN_Sharing_And_Multi-slice_Configuration
    [Setup]    Run Keywords    Enable Tshark Verification    logs_path=${OUTPUT_DIR}/${TEST_NAME}/${TSHARK_SUBDIR}
...    AND         Reach Onair Without Confirmation    lua_cfg=${EGATE}    remote_hosts=${REMOTE_HOSTS}    align_tac_values=${false}
    Verify Xn Link Establishment Between Mn And Sn
    Lock Cells 7 And 8
    Verification Of Cells 7 And 8 Locking Procedure
    Cells 7 And 8 Removal
    Cells 5 And 6 Removal
    Verification Of Cells 5 And 6 Removal Procedure
    Unlock Sn Nradjgnb Moc for Peer Xnlink
    Establish XN Link Between SN gNB And Peer gNB
    Add Locked Cell On Sn
    Delete Last Nrdcsn Cell At Sn
    Verification Of Last Active Cell Removal

CB008490-SR-GG_B401_Dynamic_Addition_Of_NR-DC-SN_Cells_In_RAN_Sharing_And_Multi-slice_Configuration_After_Xn_Link_Establishment
    [Setup]    Run Keywords
...                Update And Put Iphy Xml         input_filepath=${IPHY_GG}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_SN_GG}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_MN_GG}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Sleep    240s
...    AND         Switch Pdu Ports    reboot
...    AND         Check Radios Availability    remote_hosts=${REMOTE_HOSTS}
...    AND         Enable Tshark Verification    logs_path=${OUTPUT_DIR}/${TEST_NAME}/${TSHARK_SUBDIR}
...    AND         Reach Onair Without Confirmation    lua_cfg=${EGATE_GG}    remote_hosts=${REMOTE_HOSTS}    align_tac_values=${false}
    Add NRDC Cell With Delta Commissioning
    Sleep    100s    Waiting For Cell Addition
    Verify That Dynamic Addition and Setup Procedure for NR-DC-SN Cell In RAN Sharing Ware Completed Succesfully

*** Keywords ***
Lock Cells 7 And 8
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B101_STEP1}
    Send Delta Commissioning With Fixer    ${DELTA}

Cells 7 And 8 Removal
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B101_STEP2}
    Send Delta Commissioning With Fixer    ${DELTA}

Cells 5 And 6 Removal
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B101_STEP3}
    Send Delta Commissioning With Fixer    ${DELTA}

Unlock Sn Nradjgnb Moc for Peer Xnlink
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B101_B4_STEP4}
    Send Delta Commissioning With Fixer    ${DELTA}

Establish XN Link Between SN gNB And Peer gNB
    Establish Xn Link    source_gnb_id=${PEER_GNB_ID}    target_gnb_id=${SN_GNB_ID}

Add Locked Cell On Sn
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B301_STEP5}
    Send Delta Commissioning With Fixer    ${DELTA}
    Sleep    60s    Wait For PartialReset to be finished

Delete Last Nrdcsn Cell At Sn
    ${DELTA}=    Get Commissioning File For Enb Release Name    ${DELTA_B301_STEP6}
    Send Delta Commissioning With Fixer    ${DELTA}
    Sleep    5s

Verification Of Cells 7 And 8 Locking Procedure
      Verify Tcpdump Log    ${F1AP_GNBDU_CONF_UPD_FOR_CELL7_GD_B101_B301}
      Verify Tcpdump Log    ${XNAP_NGRANNODE_CONF_UPD_FOR_CELL7_GD_B101_B301}
      Verify Tcpdump Log    ${F1AP_GNBDU_CONF_UPD_FOR_CELL8_GD_B101_B301}
      Verify Tcpdump Log    ${XNAP_NGRANNODE_CONF_UPD_FOR_CELL8_GD_B101_B301}

Verification Of Cells 5 And 6 Removal Procedure
      Verify Tcpdump Log    ${F1AP_GNBDU_CONF_UPD_FOR_CELL5_GD_B101_B301}
      Verify Tcpdump Log    ${XNAP_NGRANNODE_CONF_UPD_FOR_CELL5_GD_B101_B301}    relation_symbol= >=
      Verify Tcpdump Log    ${F1AP_GNBDU_CONF_UPD_FOR_CELL6_GD_B101_B301}
      Verify Tcpdump Log    ${XNAP_NGRANNODE_CONF_UPD_FOR_CELL6_GD_B101_B301}    relation_symbol= >=
      Verify Tcpdump Log    ${XNAP_NGRANNODE_CONF_UPD_FOR_CELL5_AND_CELL6_REMOVAL_GD_B101_B301}

Verify Xn Link Establishment Between Mn And Sn
      Verify Tcpdump Log     ${XNAP_SETUP_RESPONSE_TO_SN_B101_B301}    timeout=60

Verification Of Last Active Cell Removal
      Verify Tcpdump Log    ${F1AP_GNBDU_CONF_UPD_FOR_LAST_ACTIVE_CELL_REMOVAL_GD_B101_B301}    number_of_messages=2

Add NRDC Cell With Delta Commissioning
    ${DELTA}=    Get Commissioning File For Enb Release Name    /GG_B401/Delta_Configuration_SN_GG_B401.json
    Send Delta Commissioning With Fixer    ${DELTA}

Verify That Dynamic Addition and Setup Procedure for NR-DC-SN Cell In RAN Sharing Ware Completed Succesfully
      Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_SERVED_CELL_INF_WITH_PLMN}
      Verify Tcpdump Log      ${F1AP_GNB_DU_CONFIGURATION_UPDATE_WITH_BROADCAST_PLMN_LIST}
      Verify Tcpdump Log      ${XNAP_NGRAN_NODE_CONFIGURATION_UPDATE_WITH_TAI_SUPPORT_LIST}
      Verify Tcpdump Log      ${XNAP_NGRAN_NODE_CONFIGURATION_UPDATE_WITH_SERVED_CELL_INF}
      Verify Tcpdump Log      ${F1AP_NEW_CELL_STATE_IN_SERVICE}
