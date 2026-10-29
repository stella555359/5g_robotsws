*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008954
...         The CB008954  feature increases the number of BWP used to manage UE with different bandwidth capabilities
...         to 3. Minimal bandwidth of small BWP is 20% of the carrier bandwidth or 10 MHz. BWP are aligned either
...         at the bottom or the top of the carrier. Multiple dedicated BWPs are supported on cells that have bandwidth
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
...         [24.08.2023] - TC Create
...         [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893480)

Resource    ./resources/CB008954_common_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...    PY36

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
CB008954-C-B105 Initial Context Setup to low bandwidth BWP in TDD cell
    [Tags]    C_B105
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify the Initial Context Setup procedure in TDD NRCELL with 3 or 2 bottom aligned
    ...     BWP profiles. BWP1 profile (small) is configured with 20% NRCELL bandwidth and is equal 20MHz.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-1.actPRBBlanking = False
    ...  - NRCELL-2.actPRBBlanking = False
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQN radio module
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
    ...    - UE1 supports BWP1 profile from NRCELL-1:
    ...        channelBWs-DL = mhz20 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz20 on fr1 scs-30kHz entry for n78
    ...    - UE2 supports BWP1, BWP2 profiles from NRCELL-1:
    ...        channelBWs-DL = mhz20,40 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz20,40 on fr1 scs-30kHz entry for n78
    ...
    ...  == Postconditions ==
    ...   - UE1 and UE2 are connected to NRCELL-1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated radio modules (AEQN,AEHC)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21352;5G_RAN_USR_RRM_21353
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-59666 CB008954-C#8 Initial context setup when small BWP is 20% of cell bandwidth
    ...
    ...  == HISTORY ==
    ...     [24.08.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893480)
    ...     [23.11.2023] - modified tue to descope of CB008954-C#9 Initial context setup when small BWP is 10 MHz

    [Setup]  Prepare test environment C_B105

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_collecting_syslog  prefix=C_B105

    Attach UE1 to NRCELL-1
    Verify that UE1 is configured with small BWP profile after ICS to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE2 to NRCELL-1
    Verify that UE2 is configured with second BWP profile after ICS to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-1 in gNB2


    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    [Teardown]  Basic cleanup
