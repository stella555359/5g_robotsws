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
...         [13.05.2022] - TC Create
...         [27.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=861137)
...         [10.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858770)

Resource    CB006597_Keywords_And_Variables.robot

Suite Setup    Run Keywords    Start Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs
...            AND             Get Scfc File   output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Find Scfc and Send Delta Commissioning    scfc_filename=delta_6597_A_B2.json
...            AND             Reach OnAir    lua_cfg=${CURDIR}/config/egate_2c_TDD_SA_1gNBsim.lua    cell_type=TDD
...            AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/Suite_Setup_Logs

Suite Teardown    Run Keywords    Roll Delta Back
...                                   initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
...                                   delta_scf_filename=delta_6597_A_B2.json
...               AND             Stop Default Processes And Gather Logs And Compress Logs

Test Setup    Start Default Logging    output_dirpath=${OUTPUT_DIR}/CB006597_A_B2

Test Teardown    Run Keywords    Add Scout External Execution ID To Reporting Portal
...              AND             Stop Default Logging    output_dirpath=${OUTPUT_DIR}/CB006597_A_B2

*** Test Cases ***
CB006597-A-B2_1 Activation of UE Assistance Information to report preference on the RRC state - Inter-gNB HO
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies if gNB handles to enable/disable reporting UE Assistance Information for
    ...   releasePreference after inter gNB handover.
    ...
    ...   UE_1 performs HO from gNB-3 (source) with feature disabled, to gNB-2 (target) with feature enabled.
    ...   Target gNB should send RRCReconfiguration message with releasePreferenceConfig-r16 set to true
    ...   and releasePreferenceProhibitTimer-r16 set to s0.
    ...   UE_1 should be able to send UEAssistanceInformation to gNB-2 with preferredRRC-State-r16 set to 'idle'
    ...   After sending UAI message UE_1 Context should be released from target gNB.
    ...
    ...   Same scenario is performed for UE_11 which is not supporting releasePreference. HO to target gNB should be
    ...   successful, but in RRCReconfiguration releasePreferenceConfig-r16 and releasePreferenceProhibitTimer-r16
    ...   should NOT be present. UE_11 should not bo able to send UEAssistanceInformation
    ...
    ...   UE_2 performs HO from gNB-3 (source) with feature enabled, to gNB-2 (target) with feature enabled too.
    ...   Target gNB should send RRCReconfiguration message without releasePreferenceConfig-r16 set to true
    ...   and releasePreferenceProhibitTimer-r16 set to s0.
    ...   UE_2 should be able to send UEAssistanceInformation to gNB-2 with preferredRRC-State-r16 set to 'inactive'
    ...   After sending UAI message UE_2 Context should be released from target gNB.
    ...
    ...   Same scenario is performed for UE_12 which is not supporting releasePreference. HO to target gNB should be
    ...   successful, but in RRCReconfiguration releasePreferenceConfig-r16 and releasePreferenceProhibitTimer-r16
    ...   should NOT be present. UE_12 should not bo able to send UEAssistanceInformation
    ...
    ...   UE_3 performs HO from gNB-3 (source) with feature enabled, to gNB-2 (target) with feature disabled.
    ...   Target gNB should send RRCReconfiguration message with releasePreferenceConfig-r16 set to release.
    ...   UE_3 should not be able to send UEAssistanceInformation to gNB-2.
    ...
    ...   Same scenario is performed for UE_13 which is not supporting releasePreference. HO to target gNB should be
    ...   successful, but in RRCReconfiguration releasePreferenceConfig-r16 and releasePreferenceProhibitTimer-r16
    ...   should NOT be present. UE_13 should not bo able to send UEAssistanceInformation
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NR cell is up and connected to AMF1
    ...  - AMF1 simulated
    ...  - UE_1, UE_2, UE_3 - Airphone simulator
    ...        UEs support UE assistance information for releasePreference.
    ...        releasePreference-r16 is set to supported in its UE-NR-Capability
    ...  - UE_11, UE_12, UE_13 - Airphone simulator
    ...        UEs does NOT support UE assistance information for releasePreference.
    ...  - gNB2 up and running with two SA cells
    ...  - NRBTS/actRrcReleasePreference = true (feature flag)
    ...  - NRBTS/timerReleasePreferenceProhibit = s0
    ...
    ...  == Postconditions ==
    ...   - UE_1 and UE_2 are enabled to provide UE Assistance Information for ReleasePreference to the gNB
    ...   - UE_3 is no able to provide UE Assistance Information for ReleasePreference to the gNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated AEQE radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15476, 5G_RAN_USR_RRM_15502
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4993 USCB006597-A#B8: Handover to enabled/disable reporting UE Assistance Information for releasePreference
    ...
    ...  == HISTORY ==
    ...     [13.05.2022] - TC Create
    ...     [10.06.2022] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=858770)

    Wait For Next Full PM Interval
    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006597_A_B2   subcase_name=CB006597_A_B2_1
    Add Ue History Information For Handover    ue_id=1
    Change Ue Location Without Confirmation    ue_id=1    dst_enb=3    dst_cell=1
    Attach Ue    ue_id=1
    Establish Pdu Session And Perform Handover    ue_id=1
    Verify Handover Messages    subcase_name=CB006597_A_B2_1
    Trigger Ue To Send UAI With PreferredRRCState Idle    ue_id=1
    Verify Ue Assistance Information And Ue Context Release    subcase_name=CB006597_A_B2_1    relation_symbol= >=
    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/CB006597_A_B2    subcase_name=CB006597_A_B2_2
    Add Ue History Information For Handover    ue_id=11
    Change Ue Location Without Confirmation    ue_id=11    dst_enb=3    dst_cell=1
    Attach Ue    ue_id=11
    Establish Pdu Session And Perform Handover    ue_id=11
    Verify Handover Messages    subcase_name=CB006597_A_B2_2
    Verify Ngap Messages For Subcase    packet_filter=nr-rrc.rrcReconfiguration    subcase_name=CB006597_A_B2_2   number_of_messages=0
    Trigger Ue To Send UAI With PreferredRRCState Idle    ue_id=11
    Verify Ue Assistance Information And Ue Context Release    subcase_name=CB006597_A_B2_2    number_of_messages=0
    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase     output_dirpath=${OUTPUT_DIR}/CB006597_A_B2   subcase_name=CB006597_A_B2_3
    Execute Egate Command    cmd=xn_handover_gnb_preparation_param id=3 ReleasePreferenceConfig=setup
    Add Ue History Information For Handover    ue_id=2
    Change Ue Location Without Confirmation    ue_id=2    dst_enb=3    dst_cell=1
    Attach Ue    ue_id=2
    Establish Pdu Session And Perform Handover    ue_id=2
    Verify Handover Messages    subcase_name=CB006597_A_B2_3
    Verify Ngap Messages For Subcase    packet_filter=nr-rrc.rrcReconfiguration    subcase_name=CB006597_A_B2_3   number_of_messages=0
    Trigger Ue To Send UAI With PreferredRRCState Inactive    ue_id=2
    Verify Ue Assistance Information And Ue Context Release    subcase_name=CB006597_A_B2_3    relation_symbol= >=    preferredRRC_State_r16=1
    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/CB006597_A_B2   subcase_name=CB006597_A_B2_4
    Add Ue History Information For Handover    ue_id=12
    Change Ue Location Without Confirmation    ue_id=12    dst_enb=3    dst_cell=1
    Attach Ue    ue_id=12
    Establish Pdu Session And Perform Handover    ue_id=12
    Verify Ngap Messages For Subcase    packet_filter=nr-rrc.rrcReconfiguration    subcase_name=CB006597_A_B2_4   number_of_messages=0
    Trigger Ue To Send UAI With PreferredRRCState Idle    ue_id=12
    Verify Ue Assistance Information And Ue Context Release    subcase_name=CB006597_A_B2_4    number_of_messages=0
    Stop Pcaps Collection For Test Subcase
    Perform Parameter Commissioning    parameter=actRrcReleasePreference    value=false    dist_name=MRBTS-1/NRBTS-1

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/CB006597_A_B2   subcase_name=CB006597_A_B2_5
    Add Ue History Information For Handover    ue_id=3
    Change Ue Location Without Confirmation    ue_id=3    dst_enb=3    dst_cell=1
    Attach Ue    ue_id=3
    Establish Pdu Session And Perform Handover    ue_id=3
    Verify Handover Messages    subcase_name=CB006597_A_B2_5
    Trigger Ue To Send UAI With PreferredRRCState Idle    ue_id=3
    Verify Ue Assistance Information And Ue Context Release    subcase_name=CB006597_A_B2_5    number_of_messages=0
    Stop Pcaps Collection For Test Subcase

    Start Pcaps Collection For Test Subcase    output_dirpath=${OUTPUT_DIR}/CB006597_A_B2   subcase_name=CB006597_A_B2_6
    Add Ue History Information For Handover    ue_id=13
    Change Ue Location Without Confirmation    ue_id=13    dst_enb=3    dst_cell=1
    Attach Ue    ue_id=13
    Establish Pdu Session And Perform Handover    ue_id=13
    Verify Handover Messages    subcase_name=CB006597_A_B2_6
    Trigger Ue To Send UAI With PreferredRRCState Idle    ue_id=3
    Verify Ue Assistance Information And Ue Context Release    subcase_name=CB006597_A_B2_6    number_of_messages=0
    Stop Pcaps Collection For Test Subcase

    Wait For Next Full PM Interval
    ${pm_counter_file}=    Get Latest Unpacked Full PM Counters File
    Verify any counters in file
    ...    M55124C08502     1    UAI_PREF_IDLE_REP
    ...    M55124C08503     1    UAI_PREF_INACT_REP
    ...    M55124C08505     0    UAI_PREF_OUTCONN_REP
    ...    M55124C08504     0    UAI_PREF_CONN_REP
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify If Any Pm Counter Is In Range Of Given Values    counter_id=M55124C08501    value_lower=1    value_higher=10
    ...                                                     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${pm_counter_file}
    Verify any counters in file
    ...    M55124C08506     1    UAI_RRC_REL_IDLE_PREF_IDLE
    ...    M55124C08507     1    UAI_RRC_REL_IDLE_PREF_INACT
    ...    M55124C08508     0    UAI_RRC_REL_IDLE_PREF_OUTCON
    ...    M55124C08509     0    UAI_INTIME_RES_PREF_CONN
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
    Verify any counters in file
    ...    M55125C12001     2    SA_UE_CTX_REL_UAI
    ...    M55125C12004     2    NG_FLOW_REL_GNB_UAI
    ...    M55125C12005     0    NG_FLOW_REL_GNB_UAI_5QI1
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counter_file}
