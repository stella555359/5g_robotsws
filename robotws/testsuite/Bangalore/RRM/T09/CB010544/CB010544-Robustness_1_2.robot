*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010544: UE power saving: Full flexible setting of Initial BWP respect to PS BWP
...         The feature removes restrictions concerning the feature 5GC000937 allowing PRACH frequency position outside
...         the Power Saving Bandwidth Part (PS-BWP). With this feature, it will be possible to:
...         - Remove RACH configuration at RRC level for the PowerSaving BWP (PS-BWP)
...         - Take into account the implicit BWP switch in case of Beam Failure Recovery if UE active BWP has no RACH configuration (PS-BWP)
...         - Performs a new BWP switch procedure via RRC reconfiguration (different to nominal DCI-based BWP switch used by feature 5GC000937)
...           to the nominal BWP (BWP#1) after the BFR if the RACH config is not present
...         - CP will be able to detect automatically if the RACH config requires to be outside the dedicated BWP
...           (sending the BWP config without RACH-ConfigCommon to UP)
...         Concerning the new RRC reconfiguration for BWP switch:
...         - UP will be able to initiate a BWP switch after BFR depending on the BWP config if RACH-ConfigCommon is not present
...           in the dedicated BWP, send a RRC reconfiguration for BWP switch request to CP-RT
...         - CP will be able to send RRC reconfiguration when receiving the request from UP
...
...         The main purpose of the feature is to give the possibility to have the PRACH channel outside the PowerSaving BWP.
...         Other restrictions such as startPRB of BWPs remain the same (no change required).
...
...         Beam Failure Recovery (BFR) procedure if RACH is not configured in the active BWP :
...         Following the 3GPP 38.321 – chapter 5.15, if PRACH occasions are not configured for the active UL BWP,
...         the UE switches to its initialUplinkBWP.
...         When the UE detects a Beam Failure, a Random Access is initiated on the initial BWP.
...         UP checks if the CRNTI received in the MSG3 is known and that the active BWP has no RACH-Config.
...         In that case, UP sends the message "RRC reconfiguration for BWP switch request" to CP-RT with the target BWP-Id.
...         During this phase, UP uses the common channels (SRB1) in order to communicate with the UE.
...         CP-RT sends the "RRC Reconfiguration" with IE "firstActiveUplinkBWP-Id" and "firstActiveDownlinkBWP-Id" using the target BWP-Id to the UE.
...         CP-RT has to stop on-going RRC procedures if required during this phase.
...         CP-RT responds to UP with a "RRC Reconfiguration for BWP switch complete".
...         When UP detects the RRC Reconfiguration sent by CP-RT, a timer is initiated in order to consider the ending for BWP switch (as CNI-81991).
...
...         The feature doesn't apply to FDD.
...         The feature doesn't apply to FR2.
...         The feature doesn't apply to UEs in NSA mode.
...         (same as 5GC000937 feature)
...
...      == TEST SET NAME ==
...         CB010544 - UE power saving: Full flexible setting of Initial BWP respect to PS BWP
...
...      == TESTING SPLIT ==
...         CB010544-A Full flexibility setting for initial BWP
...         CB010544-B Feature interaction handling for full flexibility setting for initial BWP
...         CB010544-C OAM update for CNI-100008
...         CB010544-W Capacity and performance for full flexibility setting for initial BWP
...
...      == TESTING SCOPE ==
...         This Test Plan is covering feature part CB010544-A Full flexibility setting for initial BWP
...
...      == CONTACTS ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Konrad Bem <konrad.bem@nokia.com>
...
...      == MAINTAINER ==
...         - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...         - Konrad Bem <konrad.bem@nokia.com>
...
...      == REFERENCES ==
...         CB010544 CFAM - https://gates.nsn-net.net/view/00026c2b#o=0
...
...      == HISTORY ==
...         [04.10.2023] - Create Test Suite

Resource    resources/CB010544-common_keywords.robot
Resource    resources/CB010544_setup_and_teardowns.robot
Resource        ../../../resources/robot/configuration_id.robot
Resource    ../CB008541/resources/CB008541_keywords_KRK.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00
...    CLOUD_5G_I_LO_AP_LO
...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE


*** Variables ***
${SKIP_COUNTERS}=         ${FALSE}
${rtpm}=                  ${TRUE}
@{NRCELL_1_large_bwp}=  ${rb_scs15_bw30}  ${loc_and_bw_scs15_bw30}
@{NRCELL_1_small_bwp}=  ${rb_scs15_bw20}  ${loc_and_bw_scs15_bw20}

@{NRCELL_2_large_bwp}=  ${rb_scs15_bw30}  ${loc_and_bw_scs15_bw30}
@{NRCELL_2_small_bwp}=  ${rb_scs15_bw20}  ${loc_and_bw_scs15_bw20}
*** Test Cases ***
[1][1.0] CB010544-Robustness_1_Setting_various_values_of_RACH_frequency_start
    [Tags]    Robustness_1    SKIPRUN
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm behaviour during UE attach when RACH is configured outside Power Saving BWP and with various values of RACH
    ...  frequency start. Test verifies also that WEBEM online modification of NRBTS/NRCELL.msg1FrequencyStart parameter triggers inernal checks
    ...  and raises alarm for incorrect values.
    ...  UEs supporting PS-BWP are configured with PS-BWP without RACH config during First RRC Reconfiguration.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after ICS:
    ...  BWP-Downlink
    ...   bwp-Id: 2
    ...    bwp-Common
    ...    bwp-Dedicated
    ...  BWP-Uplink
    ...   bwp-Id: 2
    ...    bwp-Common without RACH configuration
    ...    bwp-Dedicated
    ...
    ...  TEST DESCRIPTION
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 24
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 26
    ...  Check that NRCELL-1 is enabled and not degraded, there are no alarms
    ...  Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is present in PS-BWP
    ...  Run small DL traffic and verify switch to PS-BWP for UE1
    ...  Deregister UE1
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 40
    ...  Check that NRCELL-1 is enabled and not degraded, there are no alarms
    ...  Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    ...  Run small DL traffic and verify switch to PS-BWP for UE1
    ...  Deregister UE1
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 90
    ...  Check that NRCELL-1 is enabled and not degraded, there are no alarms
    ...  Attach UE1 to gNB2 NRCELL-1 and verify that UE is configured with PS-BWP and RACH is not present in PS-BWP
    ...  Run small DL traffic and verify switch to PS-BWP for UE1
    ...  Deregister UE1
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 91
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 100
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  Set NRCELL-1.msg1FrequencyStart = 120
    ...  Check that NRCELL-1 is enabled and degraded
    ...  Alarm "7114 CELL SERVICE PROBLEM" with fault "7516 Incorrect cell parameter configuration" is present with cause: msg1FrequencyStart is
    ...  outside of the accepted range, long PUCCH case; Min limit of msg1FrequencyStart: 26; Max limit of msg1FrequencyStart: 90; Start CRB of
    ...  Initial BWP: 0; Size of Initial BWP [PRBs]: 106;
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AEQE
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NR cells are up and connected to AMF1
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = true
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 60
    ...   (NRCELL-1.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRBTS-1.actMultipleDedicatedBWPs = false
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 and NRCELL-2 without PS-BWP configured when configuration is correct
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;5G_L3_16407;5G_L3_16949;
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...    - USCB010544-A#1 Single-UE Switch to power saving BWP and switch to initial BWP when RACH is not in the PS-BWP
    ...
    ...  == HISTORY ==
    ...  [04.10.2023] - Create Test Suite

    # Manual Test Description above
    No operation
    [Teardown]   Link SCOUT SCF to Configuration ID for Reporting


CB010544-Robustness_2 Interaction with RRC Reestablishment and CB008255 RRC Inactive for various values of RACH frequency start outside PS-BWP
    [Tags]    Robustness_2    TC01
    [Documentation]
    ...  == DESCRIPTION ==
    ...  Test case purpose is to confirm behaviour of CB010544 during interaction with RRC Reestablishment and CB008225 RRC Inactive.
    ...  UE attach when RACH is configured outside Power Saving BWP with various values of RACH frequency start set and procedures of
    ...  RRC Reestablishment and RRC Inactive are verified.
    ...  UEs supporting PS-BWP are configured with PS-BWP without RACH config during First RRC Reconfiguration.
    ...
    ...  Proper configuration (RRC Reconfiguration message) of UE supporting Power Saving BWP capabilities after ICS:
    ...  BWP-Downlink
    ...   bwp-Id: 2
    ...    bwp-Common
    ...    bwp-Dedicated
    ...  BWP-Uplink
    ...   bwp-Id: 2
    ...    bwp-Common without RACH configuration
    ...    bwp-Dedicated
    ...
    ...  == PRECONDITION ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO with simulated 2x AEQE
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NR cells are up and connected to AMF1
    ...  - gNB2 up and running with 2 SA TDD cells (band n78)
    ...  - NRCELL-1.chBw = 100Mz
    ...  - NRCELL-1.cellTechnology = TDD
    ...  - NRCELL-1.actPowerSavingBWP = true
    ...  - NRCELL-1.actInitialBWPFlexibility = true
    ...  - NRCELL-1.nrarfcn = 636666
    ...  - NRCELL-1.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-1.msg1FrequencyStart = 60
    ...   (NRCELL-1.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-1.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-1.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-1.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRCELL-2.chBw = 100Mz
    ...  - NRCELL-2.cellTechnology = TDD
    ...  - NRCELL-2.actPowerSavingBWP = true
    ...  - NRCELL-2.actInitialBWPFlexibility = true
    ...  - NRCELL-2.nrarfcn = 636666
    ...  - NRCELL-2.gscnOrSsPbchArfcn = 7853
    ...  - NRCELL-2.msg1FrequencyStart = 60
    ...   (NRCELL-2.msg1frequencyStart is outside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-50 (RACH is outside the PS-BWP, >51))
    ...   (NRCELL-2.msg1frequencyStart is inside range <cRbStartUl, cRbStartUl+cRbSizeUl> of the BWP_PROFILE-5 (RACH is inside the initial BWP, <106))
    ...  - NRCELL-2.ueConnectionEstablishmentMode = useDedicatedBwp
    ...  - NRCELL-2.cellBwpList =
    ...    - cellBwpId: '0'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-5'     initial BWP - 40MHZ, BWP#0
    ...    - cellBwpId: '1'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-44'    default dedicated BWP - 100MHZ, BWP#1
    ...    - cellBwpId: '2'
    ...      bwpDN: 'MRBTS-1/NRBTS-1/BWP_PROFILE-50'    Power Saving BWP - 20MHZ, BWP#2
    ...
    ...  - NRBTS-1.actMultipleDedicatedBWPs = false
    ...
    ...  - NRPMRNL-1.nrRTPMMeasurementsList = [55351 NR Dynamic BWP, 55305 NR Beamforming]
    ...  - NRPMRNL-1.miNrBeamforming = 5min
    ...  - NRPMRNL-1.miNrPowerSavingBwp = 5min
    ...
    ...  - UEs 1-9 are supporting PS-BWP
    ...
    ...  == POSTCONDITION ==
    ...  NRCELL-1 and NRCELL-2 are enabled, not degraded and without alarms
    ...  UEs are able to attach to NRCELL-1 and NRCELL-2 without PS-BWP configured when configuration is correct
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with 2 simulated AEQE radio modules
    ...  - UE configured in SA, TDD
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_19340;CB_FIM_35535;5G_L3_16407;5G_L3_16949;
    ...
    ...  == REQUIRED LOGS ==
    ...  NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Tomasz Pyrek <tomasz.pyrek@nokia.com>
    ...  - Konrad Bem <konrad.bem@nokia.com>
    ...
    ...  == REFERENCES ==
    ...  Related CFAM US:
    ...    - USCB010544-A#1 Single-UE Switch to power saving BWP and switch to initial BWP when RACH is not in the PS-BWP
    ...
    ...  == HISTORY ==
    ...  [04.10.2023] - Create Test Suite
    [Setup]   Run Keywords   Set Suite Variable   ${LUA_CFG}       ${CURDIR}/config/egate_2c_TDD_SANSA.lua
    ...   AND   Set Suite Variable   ${SCF}    Bangalore/RRM/ET/CB010544/scf_2AEQE_RRC_Inactive.xml
    ...   AND   Set Suite Variable   ${AP_XML}   Bangalore/RRM/ET/CB010544/iphy_2AEQE_gscn_7853.xml
    ...   AND   Run setup    ute_ca=True    internal_mirroring=True
    ...   AND   Prepare test environment CB010544-Robustness_2
    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Test msg1FreequencyStart value 45 in interaction with RRC Reestablishment and RRC Inactive
    Test msg1FreequencyStart value 51 in interaction with RRC Reestablishment and RRC Inactive
    Test msg1FreequencyStart value 60 in interaction with RRC Reestablishment and RRC Inactive
    Test msg1FreequencyStart value 90 in interaction with RRC Reestablishment and RRC Inactive

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm After Test

    Omit when SKIP_COUNTERS present
    ...  Check RTPM counter: NRCELL-1 MAX_UE_ACTIVE_PWR_SAVING_BWP (M55351C00001) is equal 2

    [Teardown]   Run Keywords   Basic cleanup
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting
    ...        AND     Run Suite Teardown

[1][1.0] CB008541-A-B401_3_Feature_flag_online_change_during_SCell_addition
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...   Purpose of this test is to verify that online change of actEnhMultipleDedicatedBWPs feature flag after
    ...   UE attach does not affect Scell Addition procedure. Scell Addition method is set as A1 measurement based.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        large BWP: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - AMF1 simulated
    ...  - UE5 - Airphone simulator
    ...        UE5 supports 2CC n25A-n66A band combination
    ...        In Feature Set Combination related to n25A-n66A CA band combination UE5 indicates:
    ...             In FeatureSetDownlinkPerCC for B25 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz30
    ...	            In FeatureSetUplinkPerCC for B25 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz30
    ...	            In FeatureSetDownlinkPerCC for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz20
    ...	            In FeatureSetUplinkPerCC for B66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz20
    ...	       channelBWs-DL = mhz30 on fr1 scs-15kHz entry for B25
    ...	       channelBWs-UL = mhz30 on fr1 scs-15kHz entry for B25
    ...	       channelBWs-DL = mhz20 on fr1 scs-15kHz entry for B66
    ...	       channelBWs-UL = mhz20 on fr1 scs-15kHz entry for B66
    ...
    ...  - gNB2 up and running with two SA cells OnAir (NRCELL-1 acts as PCell and NRCELL-2 acts as SCell)
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRBTS/NRCELL-1/NRREL/sCellAdditionMethod = covBasedA1 (relation to NRCELL-2)
    ...  - NRBTS/actMeasBasedSCellAddition = true
    ...  - NRBTS/NRCELL-1/a1MeasSCellAddEnabled = rsrp
    ...  - NRBTS/NRCELL-1/a2MeasSCellRelEnabled = rsrp
    ...  - NRBTS/NRCELL-1/actEnhMultipleDedicatedBWPs = false (CB008541-A feature flag)
    ...  - NRBTS/NRCELL-1/allowUnsuppBcOrBcs = 0 "complete BCS check"
    ...  - NRBTS/NRDU/carrierAggregationSupportList = ca_Fdd_Fdd
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AHFII radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_541, 5G_RAN_USR_RRM_14852
    ...
    ...  == REQUIRED LOGS ==
    ...    F1AP, NR-RRC, NGAP pcap
    ...
    ...  == CONTACTS ==
    ...  - Malgorzata Konior (Nokia - PL/Krakow) <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008541-6208 User Scenario#4 SA Feature deactivation before UE re-establishment - SCell configured
    ...        with small BWP
    ...
    ...  == HISTORY ==
    ...     [31.05.2023] - TC Create
    ...     [26.06.2023] - review closed (https://collab.ext.net.nokia.com/ui#review:id=886710)

    [Setup]   Run Keywords   Set Suite Variable   ${LUA_CFG}     ${CURDIR}/config/egate_FDD_2Cells_SA_n25_n66.lua
    ...   AND   Set Suite Variable    ${SCFC}    Bangalore/RRM/ET/CB008541/scfc_B401_3_FS.xml
    ...   AND   Set Suite Variable    ${AP_XML}   Bangalore/RRM/ET/CB008541/iphy_FDD_2cells_SA_L1B_n25_n66.xml
    ...   AND    Prepare test suite   ute_ca=True
    ...   AND    Prepare test environment B401_3
    [Tags]   TC02   QC_303813      QCD_MN_RAN    QCP_RAN_ET

    Attach UE1 to NRCELL-1
    Verify that Initial Context Setup with NRCELL-1 with large BWP profile was successful for UE1
    Verify that A1 measurement is not configured for UE1

    Set NRCELL-1 actEnhMultipleDedicatedBWPs to true

    Trigger reestablishment for UE1 in NRCELL-1
    Verify that A1 measurement is not configured for UE1

    Attach UE2 to NRCELL-1
    Verify that Initial Context Setup with NRCELL-1 with large BWP profile was successful for UE2
    Verify that A1 measurement was installed for UE2

    Attach UE3 to NRCELL-1
    Verify that Initial Context Setup with NRCELL-1 with large BWP profile was successful for UE3
    Verify that A1 measurement was installed for UE3

    Wait until PM counters file is ready and saved
    # Changes due to PR720042 - counter is increased after feature activation
    Verify that M55167C00001 SAMPLES_BWP_UE_AMOUNTS counter is in range 1 - 300 in NRCELL-1 in gNB2

    Trigger A1 measurement for UE3 with result greater than FDD threshold
    Verify that Scell Addition of NRCELL-2 with small BWP profile is completed for UE3
    Verify that A2 measurement is configured for UE3

    Set NRCELL-1 actEnhMultipleDedicatedBWPs to false

    Trigger A1 measurement for UE2 with result greater than FDD threshold
    Verify that Scell Addition of NRCELL-2 with small BWP profile is completed for UE2

    Trigger A2 measurement for UE3 with result greater than FDD threshold
    Verify that NRCELL-2 Scell was released for UE3
    Verify that A1 measurement was installed for UE3

    Wait until PM counters file is ready and saved
    Verify that M55167C00001 SAMPLES_BWP_UE_AMOUNTS counter is in range 1 - 300 in NRCELL-1 in gNB2
    Verify that M55167C00002 SUM_UE_SCELL_CONF_S_BWP counter is in range 1 - 300 in NRCELL-1 in gNB2
    Verify that M55139C04001 GNB_DU_SCELL_ADM_S_BWP_SUCC counter is equal 2 in NRCELL-1 in gNB2
    Verify that M55139C04002 GNB_DU_SCELL_ADM_L_BWP_SUCC counter is equal 0 in NRCELL-1 in gNB2
    Verify that M55167C00003 SUM_UE_SCELL_CONF_L_BWP counter is equal 0 in NRCELL-1 in gNB2
    [Teardown]   Run Keywords   Cleanup after test B401_3
    ...         AND        Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***
Prepare test environment B401_3
    Wait until PM counters file is ready and saved

Cleanup after test B401_3
    Deregister UE1
    Deregister UE2
    Deregister UE3
    Set NRCELL-1 actEnhMultipleDedicatedBWPs to false

Verify that A1 measurement is not configured for UE${ue_id}
    Verify That Message Fulfills Query
    ...     eventA1 is not present
    ...     message_alias=PCellConfiguration
    ...     flow_alias=UE${ue_id}_RRC_Reconfiguration_PCell

Trigger reestablishment for UE${ue_id} in NRCELL-1
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentRequest
    ...     UE_${ue_id}:NR-RRC_RRCReestablishment
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentComplete
    ...     alias=UE${ue_id}_RRC_reestablishment
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as PCellConfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_PCell
    ...     overall_timeout=30

    Execute egate command  cmd=ue_rrc_reestablish id=${ue_id} gnb=2 cell=1

    Flow occurred as expected   alias=UE${ue_id}_RRC_reestablishment
    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell

Trigger A1 measurement for UE${ue_id} with result greater than FDD threshold
    Flow not occurred for message  alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add
    Expect RRC Reconfiguration flow with sCellToAddModList for UE${ue_id}

    Execute egate command
    ...   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=11 phycell_id=51 nrsrp_nr=11

Trigger A2 measurement for UE${ue_id} with result greater than FDD threshold
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as SCellReleaseReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_Scell_Release
    ...     overall_timeout=30

    Execute egate command  cmd=ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=4

    Flow occurred as expected   alias=UE${ue_id}_RRC_Reconfiguration_PCell

Verify that A2 measurement is configured for UE${ue_id}
    Verify That Message Fulfills Query
    ...     reportConfigToAddModList contains (eventA2 is present)
    ...     message_alias=RRCReconfScellAdd
    ...     flow_alias=UE${ue_id}_RRC_Reconfiguration_SCell_Add

Verify that NRCELL-${cell_id} Scell was released for UE${ue_id}
    Log to console  ${cell_id}
    Verify That Message Fulfills Query
    ...     sCellToReleaseList is present
    ...     message_alias=SCellReleaseReconfiguration
    ...     flow_alias=UE${ue_id}_RRC_Reconfiguration_Scell_Release


Outdated Request Scout SCF
    [Arguments]   ${scout_testline_name}
    [Documentation]    :Author: Michele
    ...    Request Scout SCF used inside Link SCOUT SCF to Configuration ID for Reporting KW.
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=False
    scout.teardown_scout_api
    [Return]   ${external_scf_id}

Outdated Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ...
    ...    Example:
    ...     |  Link SCOUT SCF to Configuration ID for Reporting    node_id=${0}    node_type=enb
    ...
    ...     |param node_id | (default=0) Id/Number of Node (eNB or gNB) |
    ...     |param node_type | (default=gnb) Node type; possible values: gnb or enb |
    [Arguments]    ${node_id}=0    ${node_type}=gnb
    log to console     ${node_id}
    ${tl_name_only}      Get Hostname
    ${node_type_Name}        Run Keyword If  "${node_type}"=="gnb"   Set Variable  gNB
    ...     ELSE IF     "${node_type}"=="enb"                   Set Variable  eNB
    ...     ELSE        Fail    Wrong node_type '${node_type}'! allowed: enb|gnb
    Log To Console    ${\n}SCOUT Test Line Name: ${tl_name_only}
    ${scout_testline_name}=    Set Variable    ${tl_name_only}
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}

Outdated Get Hostname
    ${rc}  ${hostname_tmp}=  Run And Return Rc And Output  hostname
    ${hostname_tmp}=  Replace String  ${hostname_tmp}  -  _
    ${hostname_tmp}=  Convert To String  ${hostname_tmp}
    ${hostname_part}=  Split String  ${hostname_tmp}  _
    ${hostname_combined}=  Catenate  ${hostname_part[0]}_${hostname_part[1]}_${hostname_part[2]}
    Set Suite Variable  ${HOSTNAME}  ${hostname_combined}
    [Return]   ${HOSTNAME}
