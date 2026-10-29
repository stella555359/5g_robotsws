*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB010507
...         Based on the new n77 deployment requirement in Canada, CB010378 (gNB) has been defined. In this feature,
...         only UEs supporting IE extendedBand-n77-2-r17 can access a cell in "extended Canadian n77 frequency range"
...         (i.e. 3650 - 3980 MHz). In CB010507, frequency belonging to legacy Canadian n77 frequency range
...         (3450 - 3650 MHz) and frequency belonging to extended Canadian n77 frequency range  (3650 - 3980 MHz)
...         can be combined into one cell if the allocation is adjacent, by using BWP as defined in CB008954.
...
...         This feature can be enabled/disabled on cell level by O&M parameter.
...
...      == TEST SET NAME ==
...         CB010507 BWP for Canadian n77
...
...      == TESTING SPLIT ==
...         CB010507-A Feature activation - SIB1, SIB2, and SIB4 broadcasting
...         CB010507-B SA - Legacy-Extended Canadian n77 NR cell configured with 2 or 3 dedicated BWPs configured and acting as PCell
...         CB010507-C NSA - Legacy-Extended Canadian n77 NR cell configured with 2 or 3 dedicated BWPs and acting as PSCell
...         CB010507-D Carrier Aggregation - Legacy-Extended Canadian n77 NR cell configured with 2 or 3 dedicated BWPs and acting as SCell
...         CB010507-E Interworking with other features
...
...      == CONTACTS ==
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == MAINTAINER ==
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...
...      == REFERENCES ==
...         CB010507 CFAM
...
...      == HISTORY ==
...         [04.02.2024] - TC Create
...         [21.02.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904617)

Resource    ../CB010507/resources/CB010507_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R3
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...    PY36

Suite Setup     Run setup

*** Variables ***
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB010507/scf_CB010507_3BWP_40_70_100_arfcn_below.xml
${AP_XML}                 ${CURDIR}/../../../../../custom-config/Krakow/CB010507/iphy_2AEQE_3CELLS.xml
${LUA_CFG}=               ${CURDIR}/config/egate_TDD_3cells_n77_3BWP.lua

*** Test Cases ***
CB010507-A Activation of 3 dedicated BWPs - second BWP configured partly in extended range
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     This test case verifies gNB behavior at activation of the CB010507 feature on NRCELL with 3 dedicated
    ...     BWPs - small BWP is placed fully in legacy Canadian n77 frequency range while large and medium BWP are placed
    ...     partly in Legacy and partly in Extended Canadian n77 frequency range.
    ...     In this scenario cell center frequency (NRCELL.nrarfcn) is in legacy Canadian n77 frequency range (below 3650MHz).
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - Airphone simulator configured for SA mode
    ...  - NRBTS.actExt2N77Support = False (CB010378)
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRBTS.actPRBBlanking = False
    ...  - NRBTS.NRNSPMAX_PROFILE-1
    ...       additionalSpectrumEmission = 0
    ...  - NRBTS.NRMULTIBANDINFO_PROFILE-1
    ...       nrMultibandInfoList.freqBandIndicatorNR = 77
    ...       nrNsPmaxProfileDN refers to NRNSPMAX_PROFILE-1
    ...
    ...  - NRCELL-1.actLegExt2N77Coexist = False (CB010507)
    ...  - NRCELL-1.nrMultibandInfoProfileDN refers to NRMULTIBANDINFO_PROFILE-1
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQE radio module
    ...        NR_BAND: n77
    ...        SCS: 30kHz
    ...        nrarfcn: 643330 (3649,95MHz)
    ...        BWP3: 100MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP2: 70MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n189
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  == Postconditions ==
    ...   - NRCELL-1 is enabled, SIB1 without additionalSpectrumEmission is transmitted
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with AEQE radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_24105; 5G_RAN_USR_RRM_24106; 5G_RAN_USR_RRM_24106
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB010507-3271 UserScenario CB010507-A#B.3: Activation of 3 dedicated BWPs - second BWP configured partly
    ...                     in Legacy and partly in Extended Canadian n77 frequency range
    ...     -  CB010507-3272 UserScenario CB010507-A#B.4: SIB2 and SIB4 broadcasting in Legacy-Extended Canadian n77 NR cell
    ...
    ...  == HISTORY ==
    ...     [04.02.2024] - TC Create
    ...     [21.02.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=904617)
    ...     [25.03.2024] - Add CB010507-B102 part

    Prepare SIBs check in NRCELL-1
    Enable CB010378 and CB010507 features
    Verify SIBs are present in NRCELL-1
    Verify NRCELL-1 SIB1 does not contain additionalSpectrumEmission
    Verify NRCELL-1 SIB2 does not contain additionalSpectrumEmission
    Check no NRCELL related errors in ADMIN

    [Teardown]    Disable CB010378 and CB010507 features
