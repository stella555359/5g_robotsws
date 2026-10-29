*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...            CB008379-D_c
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [07.02.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    RAN_5G    RAN_5G_FDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_KL_AP_KL_SANSA_FS_CPRI_CMWV_FDD

Suite Setup
...     Run Setup

*** Variables ***
${LUA_CFG}=                 ${CURDIR}/config/SA_TDD_2c_1gNBSim_inter_freq.lua
${yaml_enable_interho}=     ${CURDIR}/../resources/yaml_config/inter_gnb_ho.yaml
${yaml_enable_ngho}=        ${CURDIR}/../resources/yaml_config/NG_handover.yaml

*** Test Cases ***
CB008379-D-c_1 Successful inter-gNB inter-freq A3 or A5 based handover with GBR bearer
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful inter-frequency inter-gNB XN handover with traffic verification
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...	 - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actInterFreqHoSA is set to 'true'
    ...  - GBR Service for SA feature is enabled NRBTS/NRCELL.actNonVoNRGBRService
    ...  - NRBTS/NRCELL.actCDrx = disabled
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_CP_12360506; 5G_CP_MM_2997; CB_FIM_4085
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCB008379-D1#B4: Successful Intra-frequency Inter-gNB handover with GBR bearers
    ...			- 5GC000706-B#B6 Successful Inter-frequency Inter-gNB handover based on A3/A5 measurements - 5G_RAN_USR_RRM_1483
	...
    ...  == HISTORY ==
    ...     [07.02.2022]  - Created TC

    [Tags]  DC1

    Prepare test environment DC1

    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI2 for UE1
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI3 for UE2
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI4 for UE3
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI71 for UE4
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI72 for UE5
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI76 for UE6
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI128 for UE7
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI212 for UE8
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb XN handover from simulated gNB3 to gNB2 with 5QI254 for UE9

CB008379-D-c_3 Successful inter-gNB intra-freq NG-HO handover without indirect forwarding with GBR bearer
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  == Precondition: ==
    ...	 - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actInterFreqHoSA is set to 'true'
    ...  - GBR Service for SA feature is enabled NRBTS/NRCELL.actNonVoNRGBRService
    ...  - NRBTS/NRCELL.actCDrx = disabled
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...  - NG HO is supported between real and simulated gNB
    ...  - NRBTS.actIntraNrNgHo = sourceAndTarget
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_CP_12360506; 5G_CP_MM_2997
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCB008379-D1#B4: Successful Intra-frequency Inter-gNB handover with GBR bearers
    ...			- 5GC000705-A#EC10 Inter-gNB NG based Handover based on A3/A5 measurements without indirect DL data forwarding - 5G_RAN_USR_RRM_14577
	...
    ...  HISTORY:
    [Tags]  DC3

    Prepare test environment DC3

    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI2 for UE1
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI3 for UE2
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI4 for UE3
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI71 for UE4
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI72 for UE5
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI76 for UE6
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI128 for UE7
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI212 for UE8
    Run Keyword And Continue On Failure
    ...     Repeat Successful inter-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI254 for UE9
