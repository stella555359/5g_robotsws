*** Settings ***
Documentation     [SUITE PURPOSE]   Common keyword of CB009836 feature
...               Prerequisite : gNB configured with 4 Cells & RU detected
...               Scope : CB009836

...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 20-02-2024
...               Version History    Date           Author                      Notes
...               1.0                13-06-2024     adrien.hervat@nokia.com     First Push
...               1.1                24-09-2024     richard.duthu@nokia.com     Produce Scout Data
...               1.1                07-01-2025     adrien.hervat@nokia.com     Fix iphy + attach


Variables         ./resources/python/Constants-B2-1-CB009836.py

Library           ./resources/python/CB009836-B2-1-Checks.py

Resource          ./resources/robot/CB009836-B2-1-Keywords.robot

Library           OperatingSystem
Library           Collections
Library           ArchiveLibrary




Suite Setup                 Suite Setup for CB009836      custom_bsr_update=1

Suite Teardown              Suite Teardown



*** Variables ***

# PM counters
&{PRBs_Available_Pdsch_L1_Pooling}          PM_ID=M55308C10005              # PRB available for PDSCH with L1 Baseband pooling activated
...                                         CELL_1_Expected=113700000       # 99367500 without 2516
...                                         CELL_2_Expected=61211958        # 53006527 without 2516
...                                         CELL_3_Expected=113700000       # 67080000 without 2516
...                                         CELL_4_Expected=50295875       # 44825006 without 2516

&{PRBs_Available_Pusch_L1_Pooling}          PM_ID=M55308C10006             # PRB available for PUSCH with L1 Baseband pooling activated
...                                         CELL_1_Expected=23999520
...                                         CELL_2_Expected=23999520
...                                         CELL_3_Expected=23999520
...                                         CELL_4_Expected=23999520

# beam set config
${bsr_1}                    BSR_AEQE_1_H1_ALN60_ARP60_P00_COVERAGE_00418_00001
${bsr_2}                    BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00001
${bsr_4}                    BSR_AEQE_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001
${bsr_6}                    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
${bsr_8}                    BSR_AEQE_8_H8_ALN60_ARP60_P00_COVERAGE_00426_00001



# TC parameters
&{params}
...                         duration=10
...                         deviation=50
...                         CB002516=true
...                         cni74648=false
...                         csiReportPeriodicity=slots160
...                         maxCsirsNumber=4
...                         CsirsNumberWithin=2
...                         rbAllocation=BWP
...                         basicBeam=beamSet_4
...                         numSsBlocks=4 beams
...                         basicBeamSet=${bsr_4}



# Vendor parameters
&{Vendor_Param}             bbHwVariant=ASOE                                 # bbL1SpPrbInitCapacity
...                         l1PoolType=NR_L1_Loki_TDD_FR1_eCPRI_IQF_Symm     # bbL1SpPrbInitCapacity
...                         maxNumLayerPrbL1Sp=2184                          # bbL1SpPrbInitCapacity DL
...                         maxNumStreamPrbL1Sp=2184                         # bbL1SpPrbInitCapacity DL   default value = 2184
...                         maxNumWbStreamPrbL1Sp=1092                       # bbL1SpPrbInitCapacity DL
...                         ul_maxNumLayerPrbL1Sp=819                        # bbL1SpPrbInitCapacity UL
...                         ul_maxNumStreamPrbL1Sp=1638                      # bbL1SpPrbInitCapacity UL   default value = 1638
...                         ul_maxNumWbStreamPrbL1Sp=1092                    # bbL1SpPrbInitCapacity UL
...                         maxNumScheUePdschL1Pool=None                     # bbPoolCapacity
...                         maxNumScheUePdschL1Sp=None                       # bbPoolCapacity



# ue's settings
&{dict_settings_ue_1}                                               originalCell=1                # original cell for call establishment
...                                                                 DL_throughput=1000            # DL_throughput nonGBR
...                                                                 DL_throughput_GBR=0           # DL_throughput GBR
...                                                                 UL_throughput=100             # UL_throughput nonGBR
...                                                                 ue_nr_capa=${SA_TDD_RANK4}

&{dict_settings_ue_2}                                               originalCell=2
...                                                                 DL_throughput=50
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=100
...                                                                 ue_nr_capa=${SA_TDD_RANK2}

&{dict_settings_ue_3}                                               originalCell=3
...                                                                 DL_throughput=100
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=100
...                                                                 ue_nr_capa=${SA_TDD_RANK4}

&{dict_settings_ue_4}                                               originalCell=4
...                                                                 DL_throughput=10
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=100
...                                                                 ue_nr_capa=${SA_TDD_RANK2}

@{List_UEs}                                                         ${dict_settings_ue_1}
...                                                                 ${dict_settings_ue_2}
...                                                                 ${dict_settings_ue_3}
...                                                                 ${dict_settings_ue_4}



# Csi Rs and Trs Slots and symbols to check for CB009836
@{subcell1}=    0   4
@{subcell2}=    1   5
@{subcell3}=    2   6
@{subcell4}=    3   7

@{TrsSlots}=    0   1
@{TrsSymbols}=  4   5    8    9

@{CellSymbols1}=    10   11
@{CellSymbols2}=    12   13
@{CellSymbols3}=    10   11   12   13
@{CellSymbols4}=     2    3    6    7



# Cells parameters
&{Cell1_Conf}
...                                   SubCellId=${subcell1}
...                                   CsiSlots=1
...                                   CsiSymbols=${CellSymbols3}
...                                   Zab=0
...                                   CellId=50
...                                   minPrbDl=192                 # Check min Cell stream prb for DL
...                                   minCellPrbDl=400             # Check current Cell prb allocation within a range (min,max) for DL
...                                   maxCellPrbDl=546
...                                   minCellPrbUl=110             # Check current Cell prb allocation within a range (min,max) for UL
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=500        # Check current Cell stream prb allocation for non Gbr DL
...                                   StreamPrbGbrDl=0             # Check current Cell stream prb allocation for Gbr DL
...                                   StreamPrbNonGbrUl=140        # Check current Cell stream prb allocation for non Gbr UL
...                                   StreamPrbGbrUl=0             # Check current Cell stream prb allocation for Gbr UL
...                                   bbrmUsableCellPrbForDl=273   # Check max number of prb for DL Gbr Report
...                                   bbrmUsableCellPrbForUl=273   # Check max number of prb for UL Gbr Report

&{Cell2_Conf}
...                                   SubCellId=${subcell2}
...                                   CsiSlots=1
...                                   CsiSymbols=${CellSymbols3}
...                                   Zab=1
...                                   CellId=51
...                                   minPrbDl=192
...                                   minCellPrbDl=100
...                                   maxCellPrbDl=200
...                                   minCellPrbUl=110
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=30
...                                   StreamPrbGbrDl=0
...                                   StreamPrbNonGbrUl=140
...                                   StreamPrbGbrUl=0
...                                   bbrmUsableCellPrbForDl=273
...                                   bbrmUsableCellPrbForUl=273

&{Cell3_Conf}
...                                   SubCellId=${subcell3}
...                                   CsiSlots=15
...                                   CsiSymbols=${CellSymbols3}
...                                   Zab=1
...                                   CellId=52
...                                   minPrbDl=192
...                                   minCellPrbDl=200
...                                   maxCellPrbDl=273
...                                   minCellPrbUl=110
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=60
...                                   StreamPrbGbrDl=0
...                                   StreamPrbNonGbrUl=140
...                                   StreamPrbGbrUl=0
...                                   bbrmUsableCellPrbForDl=273
...                                   bbrmUsableCellPrbForUl=273

&{Cell4_Conf}
...                                   SubCellId=${subcell4}
...                                   CsiSlots=15
...                                   CsiSymbols=${CellSymbols3}
...                                   Zab=1
...                                   CellId=53
...                                   minPrbDl=192
...                                   minCellPrbDl=80
...                                   maxCellPrbDl=200
...                                   minCellPrbUl=110
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=3
...                                   StreamPrbGbrDl=0
...                                   StreamPrbNonGbrUl=140
...                                   StreamPrbGbrUl=0
...                                   bbrmUsableCellPrbForDl=273
...                                   bbrmUsableCellPrbForUl=273

@{List_Cells}                         ${Cell1_Conf}
...                                   ${Cell2_Conf}
...                                   ${Cell3_Conf}
...                                   ${Cell4_Conf}

# L1 Pool Subpool parameters
&{L1pool_Conf}
...                                   L1PoolIdtoCheck=9         # L1 Pool ID for DL and UL
...                                   L1PoolMaxStreamPrbDl=4368  # Max stream prb for L1 Pool for DL
...                                   L1PoolMaxStreamPrbUl=3276  # Max stream prb for L1 Pool for UL

&{L1Subpool0_Conf}                    L1SpId=0
...                                   minStreamL1SpDl=3100  # Check current L1 Subpool stream prb allocation
...                                   maxStreamL1SpDl=3600  #      within a range (min,max) for DL
...                                   minStreamL1SpUl=1000  # Check current L1 Subpool stream prb allocation
...                                   maxStreamL1SpUl=2200  #      within a range (min,max) for UL

&{L1Subpool1_Conf}                    L1SpId=1
...                                   minStreamL1SpDl=800
...                                   maxStreamL1SpDl=1200
...                                   minStreamL1SpUl=1100
...                                   maxStreamL1SpUl=2300

@{List_L1Subpool}                     ${L1Subpool0_Conf}
...                                   ${L1Subpool1_Conf}



*** Test Cases ***

[1]CB009836-B2-1_IWK_5GC002516_CNI-74648_OFF_ tdLTE_1116_3ms_Canada_Semistatic_1-4_SANSA_Mixed_BW_ASOE_SS-0_CSIRS_160_SSB-4
    TC_CB009836      params_TC=${params}
    [Teardown]       Setup.Test Teardown



*** Keywords ***

TC_CB009836

    [Arguments]           ${params_TC}
    Set Suite Variable    ${params_TC}
    Init Sequence         ${params_TC}
    Step                  Set RAD Params for 9836
#   Step                  Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity for ASOE
    Step                  Set 9836 Context TDD SA                   params=${params_TC}
    Step                  Restart.F1 Wait Link Classical
    ${listOfUes}          Build UEs list SA Multi UEs
#   Step                  Set UE_Capa Context_WTS CFG               listOfUes=${listOfUes}    !! issue due to MCC NCC Canada forced to use lua !!
    Step                  Start Syslogs 9836
    Step                  Start Capture CPRT
    Step                  Multi Cells Setup for 9836                listOfUes=${listOfUes}
    Step                  SA Start Traffic Multi UEs NonGBR         listOfUes=${listOfUes}    params=${params_TC}
    Step                  Stop Capture CPRT
    Step                  Stop Syslogs 9836
    Step                  Get L1L2 Logs
    Step                  Check Csi Rs Slots and Symbols
    Step                  Get TTI Logs
    Step                  Check 9836 PM Counters
    Step                  SA DeRegister Multi UEs                    listOfUes=${listOfUes}
    Step                  Get Snaphot Sos Report
    [Teardown]            Display diagnosis
