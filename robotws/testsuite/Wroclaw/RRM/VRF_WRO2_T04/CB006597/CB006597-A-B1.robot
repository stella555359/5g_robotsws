*** Settings ***
Force Tags    CONFIGURED    CRT    master_classicalbts_all    RAN_5G    RAN_5G_TDD    SBTS00
...           CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    NoResUsage    RF50

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
...         CB006597-5G-A-B1-1 Activation of UE Assistance Information to report preference on the RRC state
...         CB006597-5G-A-B2-1 Activation of UE Assistance Information to report preference on the RRC state - Inter-gNB HO
...         CB006597-5G-A-B3-1 RRC Connection release due to UE Assistance Information
...         CB006597-5G-A-B4-1 Reset RRC inactivity timer due to UE reports an RRC preferred state of Connected
...         CB006597-5G-A-B6-1 Online Change of feature flag
...         CB006597-5G-A-B6-2 Online Change of feature flag with HO
...         CB006597-5G-B-1 UE Power Saving Cloud supporting - Cloud supporting in vRAN2.0
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
...         [11.05.2022] - TC Create
...         [31.05.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858590)

Resource    CB006597_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_6597_A_B1.json
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_TDD_SA.lua    cell_type=TDD
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                               initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                               delta_scf_filename=delta_6597_A_B1.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/CB006597_A_B1_1

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/CB006597_A_B1_1

*** Test Cases ***
CB006597-A-B1_1 Activation of UE Assistance Information to report preference on the RRC state - ICS optimized
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior during successful activation of UE Assistance Information to report preference
    ...   on the RRC state in a capable 5G-UE during attach with optimized ICS and PDU session setup.
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
    ...   - UE_1 is enabled to provide UE Assistance Information for ReleasePreference to the gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15476
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B1: Activation of UE Assistance Information to report preference on the RRC state
    ...
    ...  == HISTORY ==
    ...     [11.05.2022] - TC Create
    ...     [31.05.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858590)

    Send Ics Registration On    id=1
    Change Ue Location Without Confirmation   ue_id=1    dst_enb=2    dst_cell=1
    Attach Ue    ue_id=1
    Send Ics Registration Off    id=1
    Establish Pdu Session With Traffic    ue_id=1    pdu_id=1    gw_id=1    nwslice=1
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE}
    Verify Ngap Messages    packet_filter=${NGAP_INITIAL_CONTEXT_SETUP_REQUEST}
    Verify Ngap Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION_RELEASE_PREFERENCE_R16} && ngap.AMF_UE_NGAP_ID == 1
    ...                     relation_symbol= >=
    Verify Ngap Messages    packet_filter=${NGAP_PDU_SESSION_RESOURCE_SETUP_RESPONSE}
    Verify Uu Messages    packet_filter=${RRC_RECONFIGURATION_RELEASE_PREFERENCE_R16_CONNECTED_REPORTING} && iphy.ue_id == 1
    Wait For Triggering Procedure
    Deregister Ue Without Confirmation    ue_id=1
    Kill Ue    id=1
    Send Ics Registration On    id=1
    Change Ue Location Without Confirmation   ue_id=11    dst_enb=2    dst_cell=1
    Attach Ue    ue_id=11
    Send Ics Registration Off    id=1
    Establish Pdu Session With Traffic    ue_id=11    pdu_id=1    gw_id=2    nwslice=1
    Verify Ngap Messages    packet_filter=${NGAP_UE_RADIO_CAPABILITY_INFO_INDICATION_RELEASE_PREFERENCE_R16} && ngap.AMF_UE_NGAP_ID == 2
    ...                     number_of_messages=0
    Verify Uu Messages    packet_filter=${RRC_RECONFIGURATION_RELEASE_PREFERENCE_R16_CONNECTED_REPORTING} && iphy.ue_id == 11
    ...                   number_of_messages=0
    Wait For Next Full PM Interval
    ${pm_counter_file}=    Get Latest Unpacked Full PM Counters File
    Verify Any Counters In File
    ...    M55124C08502    0    UAI_PREF_IDLE_REP
    ...    M55124C08503    0    UAI_PREF_INACT_REP
    ...    M55124C08505    0    UAI_PREF_OUTCONN_REP
    ...    M55124C08504    0    UAI_PREF_CONN_REP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    ...    report_pm_counter=True
    Verify If Any Pm Counter Is In Range Of Given Values    counter_id=M55124C08501    value_lower=19    value_higher=29
    ...                                                     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counter_file}
