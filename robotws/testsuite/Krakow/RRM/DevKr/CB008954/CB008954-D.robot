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
...       - Damian Rzeczkowski <damian.rzeczkowski@nokia.com>
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008954 CFAM
...
...      == HISTORY ==
...         [24.08.2023] - TC Create
...         [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893807)

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Suite Setup     Run Setup

Resource    ./resources/CB008954_common_keywords.robot
Resource    ./resources/ute_report.robot

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
CB008954-D-B101 EN-DC setup with NR cell with 3 bottom aligned BWP Profiles
    [Tags]    D_B101
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify EN-DC setup procedure in FDD and TDD NRCELL with 3 bottom aligned
    ...     BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for NSA mode
    ...  - eNB1 simulated by AirPhone with LNCELL-1, E-UTRA band 1
    ...  - eNB1 LNCELL-1 is configured to setup SgNBAddition with gNB2 NRCELL-1 and NRCELL-3
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
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
    ...  - NRCELL-3 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 30kHz
    ...        large BWP2: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        second BWP2: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n51
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n24
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...        UE71, UE72, UE73, UE74 support DC_1A_n78A band combination
    ...        UE75, UE76, UE77 support DC_1A_n25A band combination
    ...
    ...        In Feature Set Combination related to DC_1A_n78A band combination UE71 indicates:
    ...             In FeatureSetDownlinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz10
    ...	            In FeatureSetUplinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz10
    ...	       channelBWs-DL = channelBWs-UL = mhz10 on fr1 scs-30kHz entry for n78
    ...
    ...        In Feature Set Combination related to DC_1A_n78A band combination UE72 indicates:
    ...             In FeatureSetDownlinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz30
    ...	            In FeatureSetUplinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz30
    ...	       channelBWs-DL = channelBWs-UL = mhz30 on fr1 scs-30kHz entry for n78
    ...
    ...        In Feature Set Combination related to DC_1A_n78A band combination UE73 indicates:
    ...             In FeatureSetDownlinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz40
    ...	            In FeatureSetUplinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz40
    ...	       channelBWs-DL = channelBWs-UL = mhz40 on fr1 scs-30kHz entry for n78
    ...
    ...        In Feature Set Combination related to DC_1A_n78A band combination UE74 indicates:
    ...             In FeatureSetDownlinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz100
    ...	            In FeatureSetUplinkPerCC for n78 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz100
    ...	       channelBWs-DL = channelBWs-UL = mhz100 on fr1 scs-30kHz entry for n78
    ...
    ...        In Feature Set Combination related to DC_1A_n25A band combination UE75 indicates:
    ...             In FeatureSetDownlinkPerCC for n25 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz10
    ...	            In FeatureSetUplinkPerCC for n25 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz10
    ...	       channelBWs-DL = channelBWs-UL = mhz10 on fr1 scs-30kHz entry for n25
    ...
    ...        In Feature Set Combination related to DC_1A_n25A band combination UE76 indicates:
    ...             In FeatureSetDownlinkPerCC for n25 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz20
    ...	            In FeatureSetUplinkPerCC for n25 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz20
    ...	       channelBWs-DL = channelBWs-UL = mhz20 on fr1 scs-30kHz entry for n25
    ...
    ...        In Feature Set Combination related to DC_1A_n25A band combination UE77 indicates:
    ...             In FeatureSetDownlinkPerCC for n25 carrier:
    ...	                30kHz supportedSubcarrierSpacingDL
    ...	                supportedBandwidthDL = mhz30
    ...	            In FeatureSetUplinkPerCC for n25 carrier:
    ...	                30kHz supportedSubcarrierSpacingUL
    ...	                supportedBandwidthUL = mhz30
    ...	       channelBWs-DL = channelBWs-UL = mhz30 on fr1 scs-30kHz entry for n25
    ...
    ...  == Postconditions ==
    ...   - UE71 SgNB Addition procedure is rejected
    ...   - UE72, UE73 and UE74 are connected to NRCELL-1
    ...   - UE75, UE76 and UE77 are connected to NRCELL-3
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated radio modules (AEQE,AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_1300;5G_RAN_USR_RRM_21382;5G_RAN_USR_RRM_21359; 5G_RAN_USR_RRM_21360;
    ...                           5G_RAN_USR_RRM_21361;5G_RAN_USR_RRM_21385
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-50810 CB008954-D#B.1 Unsuccessful EN-DC setup, UE does not support any dedicated BWP
    ...     -  CB008954-50811 CB008954-D#B.2 Successful EN-DC with small BWP
    ...     -  CB008954-50812 CB008954-D#B.3 Successful EN-DC with second dedicated BWP
    ...     -  CB008954-50813 CB008954-D#B.4 Successful EN-DC with large dedicated BWP
    ...     -  CB008954-50814 CB008954-D#B.6 Multiple UEs served with dedicated BWP profiles in the cell simultanously (NSA 3x)
    ...
    ...  == HISTORY ==
    ...     [24.08.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893807)

    [Setup]  Prepare test environment D_B101

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=D_B101

    Attach UE71 to simulated eNB1 CELL-1
    Verify that SgNB Addition with NRCELL-1 is rejected for UE71

    Attach UE72 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE72 with NRCELL_1 on gNB2
    Verify that UE72 is configured with PSCell NRCELL-1 small BWP profile after EN-DC setup with gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE72 and wait 10 seconds
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE72

    Attach UE75 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE75 with NRCELL_3 on gNB2
    Verify that UE75 is configured with PSCell NRCELL-3 small BWP profile after EN-DC setup with gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE75 and wait 10 seconds
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE75

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-3 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-3 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-3 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-3 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE73 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE73 with NRCELL_1 on gNB2
    Verify that UE73 is configured with PSCell NRCELL-1 second BWP profile after EN-DC setup with gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE73 and wait 10 seconds
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE73

    Attach UE76 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE76 with NRCELL_3 on gNB2
    Verify that UE76 is configured with PSCell NRCELL-3 second BWP profile after EN-DC setup with gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE76 and wait 10 seconds
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE76

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-1 in gNB2
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-3 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-3 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-3 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-3 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE74 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE74 with NRCELL_1 on gNB2
    Verify that UE74 is configured with PSCell NRCELL-1 large BWP profile after EN-DC setup with gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE74 and wait 10 seconds
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE74

    Attach UE77 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE77 with NRCELL_3 on gNB2
    Verify that UE77 is configured with PSCell NRCELL-3 large BWP profile after EN-DC setup with gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE77 and wait 10 seconds
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE77

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-3 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,1] in NRCELL-3 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,1] in NRCELL-3 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,1] in NRCELL-3 in gNB2

    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE72
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE73
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE74
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE75
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE76
    Run Keyword And Continue On Failure    Verify 10Mbps DL traffic on SCG split bearer for UE77

    [Teardown]    Run Keywords    Basic cleanup
    ...    AND                    Add Scout Data Info To Testcase
