*** Settings ***
Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO

Documentation   :copyright: Nokia
...             :authors: Marta Klukas, Magdalena Mlynarska
...             :contact: marta.klukas@nokia.com magdalena.mlynarska@nokia.com

Resource    ../resources/feature_keywords.robot
Resource    ../../resources/testing_env.robot
Resource    ../../keywords/traffic.robot

Library        taf.ul.ettf.setups
Library        ../resources/KeywordsCB008490.py
Library        testsuite/Wroclaw/RRM/resources/scout_report.py
Variables      ../../resources/custom_policy.py

Suite Setup        Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Start Vm Ethernet Interfaces For Simulated gNB
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning    scfc_filename=${SCFC_GNB_SN_B301}

Test Teardown      Run Keywords
...                Deregister UE    ue_id=1
...    AND         Deregister UE    ue_id=2
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${SCFC_GNB_SN_B301}=        scfc_8490_K_B301_alt1_8CC_realSN.xml
${delta}=                   Delta_SN_8490_K_B201_Alt1.json
${IPHY}=                    ${CURDIR}/config/iphy_8490_K_B_8CC_realSN.xml
${cfg}=                     ${CURDIR}/config/cfg_8490-K_B_8CC_realSN.cfg
@{bandCombinationIndex}=    1
@{requestedFeatureSets}=    1
@{physCellIds_UE1}=         52    53    54    55    56    57    58    59
@{sCellIndexes_UE1}=        2    3    4    5    6    7    8
@{MIMO_values_UE2}=         2    2    2    2    2
@{physCellIds_UE2}=         52    53    54    55
@{sCellIndexes_UE2}=        2    3    4
@{physCellIds_UE#2}=        52
@{FAULT_IDS_LIST}=          6450    4383

*** Test Cases ***
CB008490_SR_K_B301_ALT1_Partial_SCell_admission_in_gNB-CU-CP_due_to_reached_limit_of_UEs_with_CA_with_the_highest_possible_CC_number_in_the_PSCell
    [Setup]        Run Keywords
    ...                Reset Wts
    ...    AND         Wait 300s For Wts To Reset
    ...    AND         With Simulator Configuration    config=${cfg}
    ...    AND         Enable Tshark Verification
    ...    AND         Setup devices aliases
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    Attach UE1 And Establish PDU Session On Simulated GNB3 With 2 Qos Flow/s
    Set expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE1 GNB2
    Wait 2s For Measurement To Configure
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Wait 2s For NRDC To Establish
    Verify expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE1 GNB2
    Send Data Traffic For UE1 With Two QFI
    Verify XnAP For UE1
    Wait for Traffic to Stabilize
    Verify Throughput For UE1 With Cell Index Max In DL Is Eq 8
    Attach UE2 And Establish PDU Session On Simulated GNB3 With 2 Qos Flow/s
    Set expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE2 GNB2
    Wait 2s For Measurement To Configure
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    ue_id=2
    Wait 2s For NRDC To Establish
    Verify expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE2 GNB2
    Send Data Traffic For UE2 With Two QFI
    Verify XNAP For UE2
    Wait for Traffic to Stabilize
    Verify Throughput For UE2 With Cell Index Max In DL Is Eq 4

CB008490_SR_K_B201_ALT2_Unsuccessful_FR2_SCell_Addition_for_PSCell_During_inter-gNB_NR-DC_Establishment-PSCell_Only
    [Setup]        Run Keywords
    ...                Reset Wts
    ...    AND         Wait 300s For Wts To Reset
    ...    AND         Find Scfc and Send Delta Commissioning Retrying After Errors   scfc_filename=${delta}
    ...    AND         With Simulator Configuration    config=${cfg}
    ...    AND         Enable Tshark Verification
    ...    AND         Setup devices aliases
    ...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
    Attach UE1 And Establish PDU Session On Simulated GNB3 With 1 Qos Flow/s
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    Wait 2s For Measurement To Configure
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB
    Wait 2s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE1 GNB2
    Send Data Traffic For UE1 With Only One QFI
    Verify XnAP For UE1
    Wait for Traffic to Stabilize
    Verify Throughput For UE1 With Cell Index Max In DL Is Eq 8
    Attach UE2 And Establish PDU Session On Simulated GNB3 With 1 Qos Flow/s
    Set Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE2 GNB2
    Wait 2s For Measurement To Configure
    UE Sends A4 Measurement For Inter-gNB NR-DC With Simulated MN GNB    ue_id=2
    Wait 2s For NRDC To Establish
    Verify Expected Message Flow For A4 Meas Based Inter-gNB PSCell Addition On SN Side For UE2 GNB2
    Send Data Traffic For UE2 With Only One QFI
    Verify XnAP For The UE#2
    Wait for Traffic to Stabilize
    Verify Throughput For UE2 With Cell Index Max In DL Is Eq 1

*** Keywords ***
Start Vm Ethernet Interfaces For Simulated gNB
    Start Vm Ethernet Interface    if_name=eth3:GNB1_NG_ADDR    ip_with_mask=10.0.1.8/24
    Start Vm Ethernet Interface    if_name=eth3:GNB1_XN_ADDR    ip_with_mask=10.0.1.9/24

Attach UE${ue_id:\d+} And Establish PDU Session On Simulated GNB${gnb_id:\d+} With ${x:\d+} Qos Flow/s
    Attach Ue    ue_id=${ue_id}    enb=${gnb_id}    cell=9
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=1
    Prepare Sim gNB
    Establish Pdu Session        ue_id=${ue_id}    timeout=30    gw_id=${ue_id}
    Run Keyword If    '${x}' > '1'    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

Prepare Sim gNB
    ${prepare_command}=    Catenate
    ...                    gnb_nrdc_param id=3 enable_dl_data_forwarding=off t_reordering=100 serving_cell_index_range_scg_nrdc=1:31
    ...                    direct_bearer_sn_addition_error=off include_candidate_cell_info_list_mn=on include_reestablish_pdcp=on
    ...                    include_data_fwd_info_from_source=on ue_sec_algo_first_bit_reserved=on allowed_bc_list_mrdc=1:1
    ...                    include_cgi_in_candidate_cell_info=off
    Execute Egate Command
    ...    cmd=${prepare_command}

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} and QoS Flow ID eq 2
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

Verify XnAP For UE1
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That servCellIndex Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId On Index 0 Is Set To 52 In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId Is Equal To ${physCellIds_UE1} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndexes_UE1} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That uplinkConfig Is Present In CG-Config For GNB2

Verify XnAP For UE2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That servCellIndex Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId On Index 0 Is Set To 52 In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That maxMIMO-Layers Is Equal To ${MIMO_values_UE2} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId Is Equal To ${physCellIds_UE2} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndexes_UE2} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That bandCombinationIndex Is Equal To ${bandCombinationIndex} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That requestedFeatureSets Is Equal To ${requestedFeatureSets} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That uplinkConfig Is Present In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellConfigCommon Is Present 3 Times In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellConfigDedicated Is Present 3 Times In CG-Config For GNB2

Verify Throughput For UE${ue_id:\d+} With Cell Index Max In DL Is Eq ${cell_index:\d+}
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=61Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=ul    cell_group=SCG    selection_type=Average    margin=70%
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=${ue_id}    cell_group=SCG    cell_index_min=1    cell_index_max=${cell_index}

Verify XnAP For The UE#2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That servCellIndex Set To 1 For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId On Index 0 Is Set To 52 In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId Is Equal To ${physCellIds_UE#2} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That bandCombinationIndex Is Equal To ${bandCombinationIndex} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That requestedFeatureSets Is Equal To ${requestedFeatureSets} In CG-Config For GNB2
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellToAddModList Is Not Present In CG-Config For GNB2

Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=150
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=60
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=100
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=ul    mbps=60

Send Data Traffic For UE${ue_id:\d+} With Only One QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=150
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=60
