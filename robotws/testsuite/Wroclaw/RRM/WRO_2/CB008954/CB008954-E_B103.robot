*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008954: Up to 3 BWPs for UE with different bandwidth
...         The feature increases the number of BWP used to manage UE with different bandwidth capabilities
...         to 3. Minimal bandwidth of small BWP is 20% of the carrier bandwidth or 10 MHz. BWP are aligned
...         at the bottom of the carrier. Multiple dedicated BWPs are supported on cells that have bandwidth
...         at least 15 MHz.
...
...      == TEST SET NAME ==
...         CB008954 Up to 3 BWPs for UE with different bandwidth
...
...      == TESTING SPLIT ==
...         CB008954-A Feature activation
...         CB008954-B SA FDD with 3 dedicated BWPs and PRB blanking
...         CB008954-C SA TDD with 3 dedicated BWPs and PRB blanking
...         CB008954-D NSA: FDD or TDD with 3 dedicated BWPs
...         CB008954-E Interaction with CA
...         CB008954-H Other interactions
...
...      == CONTACTS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008954 CFAM
...
...      == HISTORY ==
...         [11.09.2023] - TC Create
...         [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=894392)

Resource    ./resources/CB008954_common_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup     Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_TDD_2c_n78_n41_FDD_2c_n25_n66.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008954/scfc_TDD_2c_n78_n41_FDD_2c_n25_n66.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008954/iphy_AEQE_AEHC_2_AHFII.xml
${SKIP_COUNTERS}=         ${FALSE}

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=20    SECOND_BW=40    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=20    SECOND_BW=40    LARGE_BW=100
&{NRCELL_3_BWP}=    ID=3    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
&{NRCELL_4_BWP}=    ID=4    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
@{NRCELL_BWP}=      &{NRCELL_1_BWP}    &{NRCELL_2_BWP}    &{NRCELL_3_BWP}    &{NRCELL_4_BWP}

*** Test Cases ***
CB008954-E-B103 SCell addition and CA band combination selection in case the limited BCS support in UE
    [Tags]    E_B103
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify SCell Addition and CA band combination selection in case the UE has
    ...     limited BCS support.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRBTS.NRDU.carrierAggregationSupportList = ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa
    ...  - NRBTS.actBcsCheck = 1 "enabled_FR1"
    ...  - NRCELL-1.actEnhMultipleDedicatedBWPs = true (CB008541 feature flag)
    ...  - NRCELL-4.actEnhMultipleDedicatedBWPs = true (CB008541 feature flag)
    ...  - NRCELL-1.NRREL-1.sCellAdditionMethod = blind (relation to NRCELL-4)
    ...  - NRCELL-4.NRREL-1.sCellAdditionMethod = blind (relation to NRCELL-1)
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQE radio module
    ...        NR_BAND: n78
    ...        SCS: 30kHz
    ...        large BWP3: 100MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        second BWP2: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n51
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-4 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP2: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        second BWP2: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...        SA UE1, UE2 support CA_n66A-n78A band combination BCS0 only
    ...
    ...        In Feature Set Combination related to CA_n66A-n78A band combination UE1 indicates:
    ...             In FeatureSetDownlinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz100
    ...	            In FeatureSetUplinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz100
    ...             In FeatureSetDownlinkPerCC for n66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz30
    ...	            In FeatureSetUplinkPerCC for n66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz30
    ...	       channelBWs-DL = channelBWs-UL = mhz100 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-DL = channelBWs-UL = mhz10,20,30 on fr1 scs-15kHz entry for n66
    ...
    ...        In Feature Set Combination related to CA_n25A-n78A band combination UE2 indicates:
    ...             In FeatureSetDownlinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz100
    ...	            In FeatureSetUplinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz100
    ...             In FeatureSetDownlinkPerCC for n66 carrier:
    ...	                15kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz30
    ...	            In FeatureSetUplinkPerCC for n66 carrier:
    ...	                15kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz30
    ...	       channelBWs-DL = channelBWs-UL = mhz100 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-DL = channelBWs-UL = mhz10,20,30 on fr1 scs-15kHz entry for n66
    ...
    ...  == Postconditions ==
    ...   - UE1 has NRCELL-1 configured as PSCell and NRCELL-4 configured as SCell
    ...   - UE2 has NRCELL-4 configured as PSCell and does not have any SCells configured
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated radio modules (AEQE,AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_1314;5G_RAN_USR_RRM_21496
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-65178 CB008954-E#B.5 SCell addition and CA band combination selection in case the limited BCS
    ...                       support in UE.
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=894392)

    [Setup]  Prepare test environment E_B103

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=E_B103

    EXPECT FLOW[timeout=10]: UE_1 NR-RRC 2*RRCReconfiguration
    Attach UE1 to NRCELL-1
    PASS FLOW[timeout=10]: UE_1 NR-RRC 2*RRCReconfiguration
    Verify that UE1 is configured with large BWP profile after ICS to NRCELL-1
    Verify in 2 out of 2 RRCReconfiguration that UE1 is configured with SCell NRCELL-4 second BWP

    EXPECT FLOW[timeout=10]: UE_2 NR-RRC 2*RRCReconfiguration
    Attach UE2 to NRCELL-4
    Verify that UE2 is configured with large BWP profile after ICS to NRCELL-4
#    Verify that Scell Addition is rejected for UE2, 2nd RRCReconfiguration is not sent
    FAIL FLOW[timeout=10]: UE_2 NR-RRC 2*RRCReconfiguration

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...                 Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [1-300,0] in NRCELL-1 in gNB2
    ...                 Check RTPM counter: NRCELL-1 SAMPLES_BWP_UE_AMOUNTS (M55167C00001) is in range 60 - 360
    ...                 Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [0,1,0] in NRCELL-4 in gNB2
    ...                 Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [0,0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [0,0] in NRCELL-4 in gNB2
    ...                 Check RTPM counter: NRCELL-4 SAMPLES_BWP_UE_AMOUNTS (M55167C00001) is in range 60 - 360

    [Teardown]  Basic cleanup
