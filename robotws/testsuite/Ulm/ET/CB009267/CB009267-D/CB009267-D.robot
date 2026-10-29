*** Settings ***

Documentation
...    author: VRF ULM T01 01
...    Team: 'MN RAN RD VRF ULM 1'
...    Email: 'OU_MN_RAN_RD_VRF_ULM_1_53028392@internal.nsn.com'
...    Description: This is a Robot Test Suite for subfeature CB009267-D
...    Tested on: CLOUD_5G_I_MP_AP_LOOO   STATE_CONFIGURED
...    Private variant: VARIANT_PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]


Resource   ../CB009267_Keywords.robot

Suite Setup       Prepare TL for CB009267
Suite Teardown    Sqd65 Common Teardown

Test Setup        Perform Preconditions of Test Scenario
Test Teardown     Perform Postconditions of Test Case

*** Variables ***

${TEST_MODE}              auto
${CARRIER_FREQ-1}         518910
${CARRIER_FREQ-2}         127450
${CARRIER_FREQ-3}         431090
${CARRIER_FREQ-4}         392410
${CARRIER_FREQ-5}         655968
${CARRIER_FREQ-6}         531870

*** Test Cases ***

CB009267-D_NSA_number_of_UEs_supporting_various_CC_DL_UL
    [Documentation]
    ...   This user scenario describes the number of UEs in the PSCell that support various CCs for DL and UL separately for NSA.
    ...   Two UEs, having different DL/UL CC capabilities, are put into active state for different time intervals.
    ...   UE11: supports DL:1CC UL:1CC CA is active for 50s. UE12: supports DL:2CC UL:1CC CA is active for 230s (5mins = Reporting Period).
    ...   Average and Maximum counters are checked for DL and UL, respectively.
    ...   Entity item mapping: CB009267-SR-D-B1 UE capability counters for NSA_FR1.
    [Tags]    D_EI_B1
    Wait until the next Measurement Period starts
    Attach UEs to LTE and Trigger LTE-NR Dual connectivity    ue_1=11    ue_2=13
    Sleep  50s
    Detach UE from LTE    ue_id=11
    Sleep  180s
    Detach UE from LTE    ue_id=13
    Collect and Verify PM Counters for NSA  test_instance=D_EI_B1

[1]CB009267-D_SA_Time_of_usability_of_each_DL_UL_CC
    [Documentation]
    ...   This User scenario provides counters to differentiate the time each DL and UL CC was in configured state for SA UEs.
    ...   This TI is based on holding time for SA CA FR1 for one shot Scell Addition in Intra-gNB.
    ...   Entity item mapping: CB009267-SR-D-B2 holding time for SA CA FR1. One-shot scell addition (A1-based), scell release A2 based.
    ...   UE1: supports DL: 5CC  UL: 2CC
    [Tags]    D_EI_B2  D_EI_B2_1
    Wait until the next Measurement Period starts
    Register and Establish PDU Session and calculate UE CA Configuration time  ue_id=1
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=5  direction=dl
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=6  trf_id_range_max=8  direction=ul
    Sleep  50s
    Deregister the UE and calculate UE CA active duration  ue_id=1
    Set Counter Values for 9267-D_EI_B2_1
    Collect and Verify PM Counters for SA  test_instance=D_EI_B2_1

[2]CB009267-D_SA_Time_of_usability_of_each_DL_UL_CC
    [Documentation]
    ...   This User scenario provides counters to differentiate the time each DL and UL CC was in configured state for SA UEs.
    ...   This TI is based on holding time for SA CA FR1 for Scell Change in Intra-gNB.
    ...   Entity item mapping: CB009267-SR-D-B2 holding time for SA CA FR1. A1-based scell addition, A1-based scell change
    ...   A2-based scell release. UE4: supports DL: 2CC UL: 2CC is active for 50s
    [Tags]    D_EI_B2  D_EI_B2_2
    Apply Configs for D_EI_B2_2    test_instance=D_EI_B2_2
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=4
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=4  trf_id_range_min=1  trf_id_range_max=5  direction=dl
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=4  trf_id_range_min=6  trf_id_range_max=9  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Send NR Measurement Report  event=A1  ue_id=4  meas_values=srsrp_nr=55   carrier_freq=${CARRIER_FREQ-2}
    Sleep  30s
    Send NR Measurement Report  event=A1  ue_id=4  meas_values=srsrp_nr=65   carrier_freq=${CARRIER_FREQ-2}
    Sleep  40s
    Send NR Measurement Report  event=A2  ue_id=4  meas_values=scell=2 scell_rsrp=30  carrier_freq=${CARRIER_FREQ-5}
    UE Deregister  ue_id=4
    Collect and Verify PM Counters for SA  test_instance=D_EI_B2_2   pcell=4

[3]CB009267-D_SA_Time_of_usability_of_each_DL_UL_CC
    [Documentation]
    ...   This User scenario provides counters to differentiate the time each DL and UL CC was in configured state for SA UEs.
    ...   In this scenario scells addition are A1-based and step wise and scell release are A2 based.
    ...   This TI is based on holding time for SA CA FR1 for Scell Release in Intra-gNB.
    ...   Entity item mapping: CB009267-SR-D-B2 holding time for SA CA FR1.
    ...   A1-based scell addition, A2-based scell release.
    [Tags]    D_EI_B2  D_EI_B2_3
    Apply Configs for D_EI_B2_3       test_instance=D_EI_B2_3
    Wait until the next Measurement Period starts
    Register and Establish PDU Session  ue_id=1
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=1  trf_id_range_max=5  direction=dl
    Start SA Data Traffic in Egate on multiple Traffic IDs    ue_id=1  trf_id_range_min=6  trf_id_range_max=9  direction=ul
    Sleep   10s  reason=wait for AP to start DL and UL data for all trf_ids
    Send NR Measurement Report  event=A1  ue_id=1   meas_values=srsrp_nr=60   carrier_freq=${CARRIER_FREQ-1}
    Sleep   10s
    Send NR Measurement Report  event=A2  ue_id=1  meas_values=scell=1 scell_rsrp=30  carrier_freq=${CARRIER_FREQ-6}
    Sleep   15s
    Send NR Measurement Report  event=A2  ue_id=1  meas_values=scell=2 scell_rsrp=30  carrier_freq=${CARRIER_FREQ-5}
    Sleep   20s
    Send NR Measurement Report  event=A2  ue_id=1  meas_values=scell=3 scell_rsrp=30  carrier_freq=${CARRIER_FREQ-2}
    Sleep   25s
    Send NR Measurement Report  event=A2  ue_id=1  meas_values=scell=4 scell_rsrp=30  carrier_freq=${CARRIER_FREQ-3}
    UE Deregister  ue_id=1
    Collect and Verify PM Counters for SA  test_instance=D_EI_B2_3

[4]CB009267-D_SA_Time_of_usability_of_each_DL_UL_CC
    [Documentation]
    ...   CB009267-D-UPD001: Procedure 4: F1AP UE context release for SCell release Inter-gNB HO: This User scenario provides counters to
    ...   differentiate the time each DL and UL CC was in configured state for SA UEs. In this scenario scells addition are blind and scell release
    ...   happens due to UE context release. UE context release is based on A3 event triggered NG Inter-gNB Handover, which pegs the respective
    ...   SCells holding time counters. UE1: supports DL:5CC UL:2CC CA is active for 50s followed by UE context release with A3 event
    ...   based NG handover.
    ...   This TI is based on holding time for SA CA FR1 for Scell Release in Intra-gNB.
    ...   Entity item mapping: CB009267-D-UPD001 holding time for SA CA FR1.
    [Tags]    D_EI_B2  D_EI_B2_4
    Wait until the next Measurement Period starts
    Register and Establish PDU Session and calculate UE CA Configuration time  ue_id=1
    Sleep  50s
    Perform NG Handover and calculate UE CA active duration  ue_id=1
    Set Counter Values for 9267-D_EI_B2_4
    Collect and Verify PM Counters for SA  test_instance=D_EI_B2_4
    UE Deregister  ue_id=1
    Change UE location back to source gNB  ue_id=1

[1]CB009267-D_SA_number_of_UEs_supporting_various_CC_DL_UL
    [Documentation]
    ...   Main scenario: actCarAgPmCount is set to ON. This user scenario describes the number of UEs in the PCell that support various CCs for DL
    ...   and UL separately for SA.
    ...   Four UEs, having different DL/UL CC capabilities, are put into active state for different time intervals.
    ...   UE1,2: supports DL:5CC UL:2CC CA are active for 60s and 10s, respectively. UE9: supports DL:1CC UL:1CC CA is active for 70s.
    ...   UE8: supports DL:2CC UL:1CC CA is active for 170s. UE2,1,9,8 are step-wise de-registered after 10s, 60s, 70s and 170s, respectively.
    ...   Average and Maximum counters are checked for DL and UL.
    ...   Entity item mapping: CB009267-SR-D-B3 UE capability counters for SA.
    [Tags]    D_EI_B3  D_EI_B3_1
    [Setup]   Setup for CB009267-D_EI_B3
    Wait until the next Measurement Period starts
    Register and Establish PDU Session with modified UE Capability and calculate UE CA Configuration time  ue_id=1
    ...    ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    Register and Establish PDU Session with modified UE Capability and calculate UE CA Configuration time  ue_id=2
    ...    ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    Register and Establish PDU Session and calculate UE CA Configuration time  ue_id=8
    Register and Establish PDU Session and calculate UE CA Configuration time  ue_id=9
    Sleep  10s
    Deregister the UE and calculate UE CA active duration  ue_id=2
    Sleep  50s
    Deregister the UE and calculate UE CA active duration  ue_id=1
    Sleep  10s
    Deregister the UE and calculate UE CA active duration  ue_id=9
    Sleep  100s
    Deregister the UE and calculate UE CA active duration  ue_id=8
    Set Counter Values for 9267-D_EI_B3_1
    Collect and Verify PM Counters for SA  test_instance=D_EI_B3_1
    [Teardown]  Teardown for CB009267-D_EI_B3

[2]CB009267-D_SA_number_of_UEs_supporting_various_CC_DL_UL
    [Documentation]
    ...   Alternate scenario #1: Online change FAF (actCarAgPmCount) to disabled. This user scenario describes the number of UEs in the PCell that
    ...   support various CCs for DL and UL separately for SA.
    ...   Four UEs, having same DL/UL CC capabilities, are put into active state for different time intervals.
    ...   UE1,2,3,4: supports DL:5CC UL:2CC CA are active for 10s, 60s, 70s and 170s, respectively. UE1,2 are registered with PDU session setup
    ...   followerd by deactivating the FAF (NRBTS/actCarAgPmCount=false) and then UE3,4 are registered with PDU session setup. UE1,2,3,4 are
    ...   step-wise de-registered after 10s, 60s, 70s and 170s, respectively. Average and Maximum counters are checked for DL and UL.
    ...   Entity item mapping: CB009267-SR-D-B3 UE capability counters for SA.
    [Tags]    D_EI_B3  D_EI_B3_2
    [Setup]   Setup for CB009267-D_EI_B3
    Register and Establish PDU Session with modified UE Capability  ue_id=1  ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    Register and Establish PDU Session with modified UE Capability  ue_id=2  ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    Updating Feature Activation flag  test_instance=D_EI_B3_2  action=_featureflag_disabled
    Wait until the next Measurement Period starts
    Register and Establish PDU Session with modified UE Capability  ue_id=3  ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    Register and Establish PDU Session with modified UE Capability  ue_id=4  ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    Sleep  10s
    UE Deregister  ue_id=1
    Sleep  50s
    UE Deregister  ue_id=2
    Sleep  10s
    UE Deregister  ue_id=3
    Sleep  100s
    UE Deregister  ue_id=4
    Collect and Verify PM Counters for SA  test_instance=D_EI_B3_2
    [Teardown]  Teardown for CB009267-D_EI_B3

[3]CB009267-D_SA_number_of_UEs_supporting_various_CC_DL_UL
    [Documentation]
    ...   Alternate scenario #2: online change FAF (actCarAgPmCount) to disabled and later to enabled. This user scenario describes the number of UEs
    ...   in the PCell that support various CCs for DL and UL separately for SA.
    ...   Six UEs, having same DL/UL CC capabilities, are put into active state for different time intervals.
    ...   UE1,2,3,4,5,6: supports DL:5CC UL:2CC CA are active for 10s, 30s, 50s, 70s, 90s and 170s, respectively. Disable the
    ...   FAF (NRBTS/actCarAgPmCount=false), followerd by activating  the FAF (NRBTS/actCarAgPmCount=true). UE1,2,3,4,5,6 are registered with PDU
    ...   session setup. UE1,2,3,4,5,6 are step-wise de-registered after 10s, 30s, 50s, 70s, 90s and 170s, respectively. Average and Maximum counters
    ...   are checked for DL and UL.
    ...   Entity item mapping: CB009267-SR-D-B3 UE capability counters for SA.
    [Tags]    D_EI_B3  D_EI_B3_3
    [Setup]   Setup for CB009267-D_EI_B3
    Updating Feature Activation flag  test_instance=D_EI_B3_3  action=_featureflag_disabled
    Updating Feature Activation flag  test_instance=D_EI_B3_3  action=_featureflag_enabled
    Wait until the next Measurement Period starts
    FOR   ${ue_id}   IN   1  2  3  4  5  6
        Register and Establish PDU Session with modified UE Capability  ue_id=${ue_id}  ue_nr_capabilities=${UE_CAPAB_5CC_2CC}
    END
    Sleep  10s
    UE Deregister  ue_id=1
    Sleep  20s
    UE Deregister  ue_id=2
    Sleep  20s
    UE Deregister  ue_id=3
    Sleep  20s
    UE Deregister  ue_id=4
    Sleep  20s
    UE Deregister  ue_id=5
    Sleep  80s
    UE Deregister  ue_id=6
    Collect and Verify PM Counters for SA  test_instance=D_EI_B3_3
    [Teardown]  Teardown for CB009267-D_EI_B3
