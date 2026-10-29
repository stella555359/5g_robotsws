*** Settings ***
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
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Maciej Madej <maciej.madej@nokia.com>
...
...      == REFERENCES ==
...         CB006597 CFAM
...
...      == HISTORY ==
...         [22.06.2022] - Created parity suite for VRAN2.0
...         [13.02.2023] - Switch to VRAN4.0 RANNIC
...         [23.11.2023] - Switch to VRAN4.0 Rinline2 Thor

Resource    ./resources/CB006597_common_keywords.robot

Force Tags    CONFIGURED    CRT    RAN_5G    RAN_5G_TDD    vDUCNF00    DISABLE_GENERATION
    ...    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
    ...    VARIANT_SANSA_FS_ECPRI_CMWV_TDD
    ...    PY39

Suite Setup   Run VRAN setup
Suite Teardown  Run keywords
...             vcu_emss_teardown    AND
...             vdu_emss_teardown

*** Variables ***
${common_timeout}=                20
${LUA_CFG}=                       ${CURDIR}/config/VRAN/FS_SA_TDD_2c_1gNBSim.lua
${feature_activation_cu_delta}=   ${CURDIR}/config/VRAN/feature_activation.json
@{yaml_paths_to_configure}=       ${CURDIR}/config/yaml_config/feature_activation.yaml
...                               ${CURDIR}/config/yaml_config/pmqap_profile_cfg_CU.yaml
...                               ${disable_ciphering_yaml_path}

*** Test Cases ***
CB006597-A-B3_1 gNB releases the RRC connection of UE when UE reports an RRC preferred state of idle - VRAN parity
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   This user story verifies gNB behavior when UE reports an RRC preferred state of 'idle'.
    ...   gNB releases UE's context. UE performs successful transition from RRC-CONNECTED to RRC-IDLE
    ...   triggered by UAI (UE Assistance Information).
    ...
    ...  == Precondition: ==
    ...  - gNB VRAN4.0 BTS in SA mode
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
    ...  - NRBTS/actNrpmqapProfiles = true
    ...  - NRBTS/cipherPrefL.nea0 = 9
    ...  - NRBTS/cipherPrefL.nea1_128 = 0
    ...  - NRBTS/cipherPrefL.nea2_128 = 0
    ...  - NRBTS/cipherPrefL.nea3_128 = 0
    ...  - NRPMRNL/miNrNgInterfaceNrpmqap = "5min"
    ...  - NRPMQAP-1/cfg5qiRange = "5"
    ...  - NRPMQAP-1/cfgProfType = "SA"
    ...
    ...  == Postconditions ==
    ...   - UE_1 context is released
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB VRAN4.0 BTS in SA mode
    ...  - HARDWARE ID: gNB(vCU OE22 + vDU RANNIC) with simulated AEQP radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_15507
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...   - Marek Kieltyka <marek.kieltyka@nokia.com>
    ...   - Maciej Madej <maciej.madej@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB006597-4717 USCB006597-A#B2: gNB releases the RRC connection of UE when UE reports an RRC preferred state of 'idle'
    ...
    ...  == HISTORY ==
    ...     [22.06.2022] - VRAN2.0 passed CB008608 - SW build: vCUCNF22R4_0.250.5497;vDUCNF22R4_0.300.6345
    ...     [08.02.2023] - VRAN4.0 passed CB009881 - SW build: vCUCNF23R2_0.250.10218;vDUCNF23R2_0.300.10914

    [Tags]    A-B3-1

    Wait until CU PM counters file is ready and saved

    Attach UE1 to gNB2 cell1 with ICS during PDU session setup

    Verify that in UECapabilityInformation for UE_1 releasePreference-r16 is set to supported
    Verify that in RRCReconfiguration for UE_1 releasePreferenceConfig-r16 is set to setup
    Verify that in RRCReconfiguration for UE_1 releasePreferenceProhibitTimer-r16 is set to s0
    Verify that in RRCReconfiguration for UE_1 connectedReporting is set to true

    EXPECT FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Trigger UE1 to send UAI with RRC preferred state of idle
    Verify that in UEAssistanceInformation for UE_1 preferredRRC-State-r16 is set to idle
    PASS FLOW[timeout=60]: AMF1 NGAP uEContextReleaseRequest,uEContextRelease
    Verify that AMF1 UEContextReleaseRequest contains cause=unspecified

    Wait until CU PM counters file is ready and saved

    Check VRAN counters: UAI_PREF_IDLE_REP 1, UAI_PREF_INACT_REP 0, UAI_PREF_OUTCONN_REP 0, UAI_PREF_CONN_REP 0
    Check VRAN counter: ACC_UAI_RRC_REL_PREF_CONF_UES is in range 1 - 10
    Check VRAN counters:UAI_RRC_REL_IDLE_PREF_IDLE 1,UAI_RRC_REL_IDLE_PREF_INACT 0,UAI_RRC_REL_IDLE_PREF_OUTCON 0,UAI_INTIME_RES_PREF_CONN 0
    Check VRAN counters: SA_UE_CTX_REL_UAI 1, NG_FLOW_REL_GNB_UAI 1, NG_FLOW_REL_GNB_UAI_5QI1 0
    Check VRAN counters NRPMQAP-1: NG_FLOW_REL_GNB_UAI_PMQAP 1

    [Teardown]  Cleanup after test


*** Keywords ***
Run VRAN setup
    Log To Console    Setup started
    Setup VRAN devices aliases
    Run Keyword and ignore error        Setup VRAN libraries
    setup_vcu_emss
    setup_vdu_emss
    vcu_configure       ${yaml_paths_to_configure}
#    Send CU delta commissioning   input_filepath=${feature_activation_cu_delta}
    ${run_update}    get variable value      ${configure}    True     # do not ever change that line!
    Run Keyword if  "${run_update}" == "True"
    ...         Reach OnAir in VRAN with retries   lua_cfg=${LUA_CFG}
    Run Keyword if  "${run_update}" != "True"
    ...         Setup egate  egate_port=20000  alias=default

Cleanup after test
    Deregister UE1 and kill if failed

Prepare test environment CB006597-A-B6-1
    Change CU parameter on MRBTS-1/NRBTS-1 actRrcReleasePreference=false
    Wait until CU PM counters file is ready and saved

Cleanup after test CB006597-A-B6-1
    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Deregister UE3 and kill if failed
    Deregister UE4 and kill if failed
    Deregister UE5 and kill if failed
