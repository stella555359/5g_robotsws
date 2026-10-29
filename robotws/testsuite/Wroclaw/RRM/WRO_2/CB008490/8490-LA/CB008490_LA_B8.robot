*** Settings ***
Test Timeout       90 minutes

Force Tags    CONFIGURED   CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_[MP][MP]_AP_[LOOO]

Documentation   :copyright: Nokia
...             :authors: Kornel Dluniewski
...             :contact: kornel.dluzniewski@nokia.com

Resource    ../resources/feature_keywords.robot
Resource    ../../resources/testing_env.robot
Resource    ../../keywords/traffic.robot
Resource    ../resources/suite_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot

Library        taf.ul.ettf.setups
Library        ../resources/multignb_variables.py
Library        ../resources/KeywordsCB008490.py
Library        ta5g_ue_measurements
Library        ../resources/syslog_collector.py


Variables      ../resources/custom_policy.py

Suite Setup        Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Update And Put Iphy Xml         input_filepath=${IPHY}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_SN}
...                remote_host=${REMOTE_HOST_1_IP}
...    AND         Find Scfc And Fix And Send Full Commissioning
...                scfc_filename=${SCFC_GNB_MN}
...    AND         With Simulator Configuration    config=${cfg}    remote_hosts=${REMOTE_HOSTS}    timeout=600

Test Setup         Run Keywords
...                Enable Tshark Verification
...    AND         Setup multigNB devices aliases
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
...    AND         Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}

*** Variables ***
${SCFC_GNB_MN}=             MN_LAB8.xml
${SCFC_GNB_SN}=             SN_LAB8.xml
${IPHY}=                    ${CURDIR}/config/iphy_MN_AEQE_SN_AWEUB_8CC.xml
${cfg}=                     ${CURDIR}/config/cfg_n77A_n257M_8CC_LA_B8.cfg
${ue_id}=                   1
${pdu_id}=                  1
@{bandCombinationIndex}=    1
@{requestedFeatureSets}=    1
@{physCellIds_UE1}=         52    53    54    55
@{sCellIndexes_UE1}=        2    3    4
${NosCellToAddModList}=     xnap.procedureCode == 7 && xnap.id == 72 && !nr-rrc.sCellToAddModList
@{FAULT_IDS_LIST}=          6450    4383
${pcap_file}=               tshark/gnb_F1_E1_RRC.pcap


*** Test Cases ***
CB008490-LA#B8_UE_Capability_Maximum number of TRS resource sets_Impacts_On_FR2_SCell_Addition
    Attach UE1 And Establish PDU Session On GNB2 With 2 Qos Flow/s
    Set expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE1 GNB3
    Wait 2s For Measurement To Configure
    UE1 sends A4 measurement ID eq 1 for inter-gNB NR-DC PSCell ID eq 52 addition
    Wait 2s For NRDC To Establish
    Verify expected message flow for A4 meas based inter-gNB PSCell Addition on SN side For UE1 GNB3
    Send Data Traffic For UE1 With Two QFI
    Verify XnAP For UE1
    Wait for Traffic to Stabilize
    Verify Throughput For UE1 With Cell Index Max In DL Is Eq 4
    Wait for Traffic to Stabilize


    [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Add scout external execution id to the reporting portal
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}
     ...    AND    Verify If Admin Faults Are Down    fault_id_list=@{FAULT_IDS_LIST}    remote_host=${REMOTE_HOST_1_IP}

*** Keywords ***
Attach UE${ue_id:\d+} And Establish PDU Session On GNB${gnb_id:\d+} With 2 Qos Flow/s
    ta5g_ue_mobility.attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30
    Trigger PDU Session Modify Procedure For UE${ue_id} and QoS Flow ID eq 2

Trigger PDU Session Modify Procedure For UE${ue_id:\d+} and QoS Flow ID eq ${qosflows:\d+}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete

UE${ue_id:\d+} sends A4 measurement ID eq ${meas_id:\d+} for inter-gNB NR-DC PSCell ID eq ${phycell_id:\d+} addition
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} nrsrp_nr=60 report_type=event_triggered event=A4
    ...    pass_regexp=SCellIndex 3 activated successfully at airphone

Verify XnAP For UE1
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 In CG-Config That servCellIndex Set To 1 For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId On Index 0 Is Set To 52 In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That physCellId Is Equal To ${physCellIds_UE1} In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That sCellIndex Is Equal To ${sCellIndexes_UE1} In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That uplinkConfig Is Present In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That uplinkConfig Is Not Present 3 Times In CG-Config For GNB3
    Verify In XNAP SNodeAdditionRequestAcknowledge_1 Out Of 1 That tci-StatesPDCCH-ToAddList Is Not Present In CG-Config For GNB3

Verify Throughput For UE${ue_id:\d+} With Cell Index Max In DL Is Eq ${cell_index:\d+}
    Verify That Throughput Is Reached On Cell Group    ue_id=${ue_id}    expected_throughput=61Mbps      cell_index_min=1    cell_index_max=1
                                       ...     direction=ul    cell_group=SCG    selection_type=Average    margin=70%
    Verify That Traffic Is Scheduled On All SCells In Group    ue_id=${ue_id}    cell_group=SCG    cell_index_min=1    cell_index_max=${cell_index}

Send Data Traffic For UE${ue_id:\d+} With Two QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=170
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=67
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=dl    mbps=107
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=2    dir=ul    mbps=67

Send Data Traffic For UE${ue_id:\d+} With Only One QFI
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=dl    mbps=140
    Send Data Traffic In Direction      ue_id=${ue_id}    qfi=1    dir=ul    mbps=50

Send Data Traffic
    [Arguments]    ${ue_id}=1   ${pdu_id}=1    ${qfi}=1    ${mbps}=150    ${size}=1350    ${inactive_timer}=30
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=${mbps} size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} dir=ul mbps=60 size=${size}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=1 dir=ul mbps=60 size=${size}
    Wait for Traffic to Stabilize    inactive_timer=${inactive_timer}

