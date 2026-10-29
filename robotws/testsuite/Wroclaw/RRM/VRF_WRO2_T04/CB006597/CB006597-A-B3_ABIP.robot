*** Settings ***
Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00
...           CLOUD_5G_I_MP_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    NoResUsage    RF50

Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB006597: UE Power Saving - UE Assistance Inforamtion for UE preferred RRC state
...         This feature introduces the support of RRC UE Assistance Information in gNB, for the UE preferred RRC state
...         for UEs with according capabilities (3GPP Rel-16). gNB checks the UE capabilities, before to configure the
...         UAI message trigger, in particular
...          - If UE reports the following capability:
...            - PowSav-Parameters-r16/powSav-ParametersCommon-r16/releasePreference-r16 = supported
...         gNB configures such UEs in the RRC Connection Reconfiguration accordingly, in particular gNB will configure
...         the UE to report its preferred RRC state in the UAI, by sending following information's during RRC reconfiguration:
...          - ReleasePreferenceConfig-r16 to setup
...          - releasePreferenceProhibitTimer-r16 to the value configured by the operator
...         If UE will prefer to use another RRC state, then it will report the following IE in the UE Assistance Information
...         message preferredRRC-State-r16
...
...      == TEST SET NAME ==
...         CB006597 - UE Power Saving - UE Assistance Inforamtion for UE preferred RRC state
...
...      == TESTING SPLIT ==
...         CB006597-5G-A-B1: Activation of UE Assistance Information to report preference on the RRC state
...         CB006597-5G-A-B2: Activation of UE Assistance Information to report preference on the RRC state - Inter-gNB HO
...         CB006597-5G-A-B4: Reset RRC inactivity timer due to UE reports an RRC preferred state of "Connected"
...         CB006597-5G-A-B6: Online Change of feature flag
...         CB006597-5G-A-B3: RRC Connection release due to UE Assistance Information
...         CB006597-5G-B UE Power Saving: Cloud supporting - Cloud supporting in vRAN2.0
...
...      == CONTACTS ==
...         :copyright: Nokia
...         :authors: Anna Roskosz
...         :maintainer: Aleksandra Paszek
...         :contact: aleksandra.paszek@nokia.com
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [13.05.2022] - TC Create
...         [14.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858861)

Resource    CB006597_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_6597_A_B3.json
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_TDD_SA.lua
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_6597_A_B3.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/CB006597_A_B3_1

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/CB006597_A_B3_1

*** Test Cases ***
CB006597-A-B3_1 gNB releases the RRC connection of UE when UE reports an RRC preferred state of idle
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when UE reports an RRC preferred state of 'idle'.
    ...   gNB releases UE's context. UE performs successful transition from RRC-CONNECTED to RRC-IDLE
    ...   triggered by UAI (UE Assistance Information).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1 - Airphone simulator
    ...        UE_1 supports UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - UE_11 - Airphone simulator
    ...        UE_11 does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...
    ...  == Postconditions ==
    ...   - UE_1 context is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15507
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B2: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'idle'
    ...
    ...  == HISTORY ==
    ...     [13.05.2022] - TC Create
    ...     [14.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858861)

    Wait For Next Full Pm Interval
    Attach Ue Without Ics    ue_id=1
    Set Internal Traffic Type For Ue    ue=1    pdu=1
    Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Verify Tcpdump Log    packet_filter=${UE_CAPABILITY_INFORMATION} && (nr-rrc.releasePreference_r16 == 0)
    ...                   pcap_file_path=${OUTPUT_DIR}/CB006597_A_B3_1/tshark/gnb_F1_E1_RRC.pcap
    Verify Uu Messages    packet_filter=${RRC_RECONFIGURATION_RELEASE_PREFERENCE_R16_CONNECTED_REPORTING}
    Trigger Ue To Send UAI With PreferredRRCState Idle    ue_id=1
    Verify Tcpdump Log    packet_filter=${UE_ASSISTANT_INFO_PREFERRED_RRC_STATE}
    ...                   pcap_file_path=${OUTPUT_DIR}/CB006597_A_B3_1/tshark/gnb_F1_E1_RRC.pcap
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${CAUSE_UNSPECIFIED}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify any counters in file
    ...    M55124C08502     1    UAI_PREF_IDLE_REP
    ...    M55124C08503     0    UAI_PREF_INACT_REP
    ...    M55124C08505     0    UAI_PREF_OUTCONN_REP
    ...    M55124C08504     0    UAI_PREF_CONN_REP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify If Any Pm Counter Is In Range Of Given Values
    ...    M55124C08501     1    10
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    filepath=${pm_counter_file}
    Verify any counters in file
    ...    M55124C08506     1    UAI_RRC_REL_IDLE_PREF_IDLE
    ...    M55124C08507     0    UAI_RRC_REL_IDLE_PREF_INACT
    ...    M55124C08508     0    UAI_RRC_REL_IDLE_PREF_OUTCON
    ...    M55124C08509     0    UAI_INTIME_RES_PREF_CONN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify any counters in file
    ...    M55125C12001     1    SA_UE_CTX_REL_UAI
    ...    M55125C12004     1    NG_FLOW_REL_GNB_UAI
    ...    M55125C12005     0    NG_FLOW_REL_GNB_UAI_5QI1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify any counters in file
    ...    M55163C02502     1    NG_FLOW_REL_GNB_UAI_PMQAP
    ...    local_moid=PLMN-PLMN/NRPMQAP-1
    ...    file_path=${pm_counter_file}
