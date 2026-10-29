*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC    CONFIGURED    RAN_5G_TDD    RAN_5G
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Bartosz Grzegorczyk
...              :contact: bartosz.grzegorczyk@nokia.com

Resource    CB009010_Keywords.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/../initial_commissioning.xml
...            AND             Start Vm Ethernet Interfaces
...            AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_9010_URSC3_b.json    skip_relation_errors=False
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scf_before_test.xml
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_URSC3_b.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scf_after_test.xml
...               AND             Stop Default Processes And Gather Logs And Compress Logs
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/../initial_commissioning.xml

Test Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...           AND             Setup X2 Links

Test Teardown    Run Keywords    Add Scout Scf Id To Test Data
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
...              AND             Run Keyword If Test Passed    Find Suspicious Logs

*** Variables ***
${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_150}=    nr-rrc.drx_InactivityTimer == 14 && nr-rrc.drx_RetransmissionTimerDL == 0 &&
...                                              nr-rrc.drx_RetransmissionTimerUL == 0 && nr-rrc.drx_LongCycleStartOffset == 11 &&
...                                              nr-rrc.cellForWhichToReportCGI == 150
${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_151}=    nr-rrc.drx_InactivityTimer == 14 && nr-rrc.drx_RetransmissionTimerDL == 0 &&
...                                              nr-rrc.drx_RetransmissionTimerUL == 0 && nr-rrc.drx_LongCycleStartOffset == 9 &&
...                                              nr-rrc.cellForWhichToReportCGI == 151
${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_250}=    nr-rrc.drx_InactivityTimer == 14 && nr-rrc.drx_RetransmissionTimerDL == 0 &&
...                                              nr-rrc.drx_RetransmissionTimerUL == 0 && nr-rrc.drx_LongCycleStartOffset == 11 &&
...                                              nr-rrc.cellForWhichToReportCGI == 250
${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_251}=    nr-rrc.drx_InactivityTimer == 14 && nr-rrc.drx_RetransmissionTimerDL == 0 &&
...                                              nr-rrc.drx_RetransmissionTimerUL == 0 && nr-rrc.drx_LongCycleStartOffset == 11 &&
...                                              nr-rrc.cellForWhichToReportCGI == 251 && !xnap.HandoverRequest_element

*** Test Cases ***
CB009010_URSC_3b_ANR_ReportCGI_Reception_And_Validate_Created_ADJ_NRPLMNSET_SA_NSA
    [Documentation]    When reportCGI operation (for ANR) is performed the target cell's SIB1 is reported by the UE.
    ...                Upon reception of this information (successful reportCGI), store the received PLMN information and
    ...                related information in NRBTS/NRADJNRCELL/ADJ_NRPLMNSET_[SA,NSA] objects.
    ...                5G_RAN_USR_RRM_21205

    Configure DRX for NSA UE    ue_id=34
    Attach UE And Establish PDU Session And Send A5 Measurement For Intra Freq NSA HO    ue_id=34  meas_id=2  target_phycell_id=150
    Verify Traces For DRX Config In Cell 150 Resolution Message
    Configure DRX for NSA UE    ue_id=46
    Attach UE And Establish PDU Session And Send A3 Measurement For Intra Freq NSA HO    ue_id=46  meas_id=1  target_phycell_id=150
    Verify Created NRADJNRCELL And NRREL Objects    PCI=150  gNB_id=3  NRADJNRCELL_ID=12288  NRREL_ID=256  nrarfcn=636666  ssbFrequency=636576
    Verify Created NRPLMNSET_SA and NRPLMNSET_NSA Objects    NRADJNRCELL_ID=12288
    Verify Traces For DRX Config In Cell 150 Resolution Message

    Configure DRX and Meas Gap for NSA UE    ue_id=43
    Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq NSA HO    ue_id=43  meas_id=6  target_phycell_id=151
    Verify Traces For DRX Config In Cell 151 Resolution Message
    Configure DRX and Meas Gap for NSA UE    ue_id=35
    Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq NSA HO    ue_id=35  meas_id=6  target_phycell_id=151
    Verify Created NRADJNRCELL And NRREL Objects    PCI=151  gNB_id=3  NRADJNRCELL_ID=12287  NRREL_ID=255  nrarfcn=632000  ssbFrequency=631968
    Verify Created NRPLMNSET_SA and NRPLMNSET_NSA Objects    NRADJNRCELL_ID=12287
    Verify Traces For DRX Config In Cell 151 Resolution Message

    Configure Xn Response To Send PLMN TAC List    gnb_id=4  cell_id=1  plmn_list=311:492,311:495,311:498
    Configure Xn Response To Send PLMN TAC List    gnb_id=4  cell_id=2  plmn_list=311:492,311:495,311:498
    Attach UE And Establish PDU Session And Send A5 Measurement For Intra Freq HO    ue_id=6  meas_id=3  target_phycell_id=250
    Verify Traces For DRX Config In Cell 250 Resolution Message
    Attach UE And Establish PDU Session And Send A3 Measurement For Intra Freq HO    ue_id=11  meas_id=2  target_phycell_id=250
    Verify Created NRADJNRCELL And NRREL Objects    PCI=250  gNB_id=4  NRADJNRCELL_ID=12286  NRREL_ID=254  nrarfcn=636666  ssbFrequency=636576
    Verify Created NRPLMNSET_SA and NRPLMNSET_NSA Objects    NRADJNRCELL_ID=12286
    Verify Traces For DRX Config In Cell 250 Resolution Message

    Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq HO    ue_id=12  meas_id=5  target_phycell_id=251
    Verify Traces For DRX Config In Cell 251 Resolution Message
    Attach UE And Establish PDU Session And Send A5 Measurement For Inter Freq HO    ue_id=16  meas_id=5  target_phycell_id=251
    Verify Created NRADJNRCELL And NRREL Objects    PCI=251  gNB_id=4  NRADJNRCELL_ID=12285  NRREL_ID=253  nrarfcn=632000  ssbFrequency=631968
    Verify Created NRPLMNSET_SA and NRPLMNSET_NSA Objects    NRADJNRCELL_ID=12285
    Verify Traces For DRX Config In Cell 251 Resolution Message

CB009010_URSC_8b_ANR_ReportCGI_Reception_And_Storage_In_NRPLMN_SET_Objects_For_SA_And_NSA_Recheck_Scenario_With_Updated_PLMN_By_SA_UE
    [Documentation]    Test validateing ANR behavior when relation is in re-check state and new received nr-cgi report have
    ...                got other PLMNs in SA and NSA sets. Upon reception of this new information gNB store the received PLMN
    ...                information in valid NRBTS/NRADJNRCELL/ADJ_NRPLMNSET_[SA,NSA] objects.
    ...                Test steps:
    ...                - Perform delta commissioning with NRADJNRCELL-1 and NRREL-1 pointing to this adjcell;
    ...                This cell contains only one NRPLMN and actually cell have got more NRPLMNs;
    ...                - UE failing HO to cell and ANRs changing relation status to RE-CHECK;
    ...                - On next measurement report with this PCI ANR performing nr-cgi resolution on UE and UE send measurement
    ...                report with actual list of NRPLMNs in nr-cgi;
    ...                - After gNB receive new nr-cgi report with changed NRPLMNs should update internal SDL object and perform
    ...                delta commissioning to OAM;
    ...                - Test validating actual NRADJNRCELL-1 and NRREL-1 with changed NRPLMNSET_SA and NRPLMNSET_NSA objects.
    ...                5G_RAN_USR_RRM_21486

    Perform Test Case Delta Commisioning With NRREL And NRADJNRCELL To Recheck
    Set Gnb To Fail Handover Preparation
    Attach UE And Establish PDU Session And Send A5 Measurement For Intra Freq HO    ue_id=13  meas_id=3  target_phycell_id=152
    Verify Updated NRADJNRCELL And NRREL With NRPLMNSET_SA And NRPLMNSET_NSA

*** Keywords ***
Verify Traces For DRX Config In Cell 150 Resolution Message
    Verify Tcpdump Log    packet_filter=${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_150}    number_of_messages=2

Verify Traces For DRX Config In Cell 151 Resolution Message
    Verify Tcpdump Log    packet_filter=${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_151}    number_of_messages=2

Verify Traces For DRX Config In Cell 250 Resolution Message
    Verify Tcpdump Log    packet_filter=${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_250}

Verify Traces For DRX Config In Cell 251 Resolution Message
    Verify Tcpdump Log    packet_filter=${DRX_PROFILE_NRCGI_RECONFIGURATION_CELL_251}

Set Gnb To Fail Handover Preparation
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param action=force_failure id=${gnb_id}

Perform Test Case Delta Commisioning With NRREL And NRADJNRCELL To Recheck
    Find Scfc And Send Delta Commissioning    scfc_filename=delta_9010_URSC8_NRREL.json    skip_relation_errors=False
    Sleep   120   reason=Waiting for ANR object propagate

Verify Updated NRADJNRCELL And NRREL With NRPLMNSET_SA And NRPLMNSET_NSA
    Sleep    120   reason=Waiting for ANR update OAM objects
    Verify Created NRADJNRCELL And NRREL Objects    PCI=152  gNB_id=3  NRADJNRCELL_ID=1  NRREL_ID=1  nrarfcn=636666  ssbFrequency=636576
    Verify Created NRPLMNSET_SA And NRPLMNSET_NSA Objects    NRADJNRCELL_ID=1
