*** Settings ***
Documentation     [SUITE PURPOSE]   Common keyword of CB011028 feature
...               Prerequisite : gNB configured with 4 Cells & RU detected
...               Scope : 11028-B-EI3-ROBUSTNESS

...               Test Case Scenario author   : adrien.hervat@nokia.com

...               Creation Date               : 02-11-2023
...               Version History    Date           Author                      Notes
...               0.1                27-07-2023     adrien.hervat@nokia.com     Creation
...               0.2                25-09-2023     adrien.hervat@nokia.com     Custom config addition + L1L2 capture with csirs rimrs filter
...               0.3                12-10-2023     adrien.hervat@nokia.com     CB011028 checking + BSR package handling
...               0.4                16-10-2023     adrien.hervat@nokia.com     UPD2 TC addition  + New SCF parameters
...               0.5                23-11-2023     adrien.hervat@nokia.com     Robustness TC modification to online modification + BIP size handling
...               0.6                27-11-2023     adrien.hervat@nokia.com     Delta SCF for TC robustness + new vendor file parameter handling
...               0.7                20-12-2023     adrien.hervat@nokia.com     New BSR and Prb Pooling check addition
...               0.8                11-01-2024     adrien.hervat@nokia.com     Prb Pooling checks modification
...               0.9                25-09-2024     richard.duthu@nokia.com     Produce Scout Data through "Test Teardown" + some RF50 fixes
...               1.0                07-01-2025     adrien.hervat@nokia.com     Fix iphy + attach

Variables         ./resources/python/Constants-CB011028-B.py

Library           OperatingSystem
Library           Collections
Library           ArchiveLibrary

Resource          ./resources/robot/CB011028-B-Keywords.robot


Suite Setup                 Suite Setup for CB011028-B     custom_bsr_update=1

Suite Teardown              Suite Teardown



*** Variables ***
# Hardware Variables
${isASOH}                   ${False}

&{params}                   nbCell=4
...                         duration=10
...                         deviation=50
...                         rad=32       # must be set to 0 to use NIDD parameter repetitionRsType1
...                         timeCapture=2
...                         repetition=r2
...                         explicitCsirs=false
...                         csiReport=slots320
...                         bip=250


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
...                                                                 DL_throughput=200             # DL_throughput nonGBR
...                                                                 DL_throughput_GBR=0           # DL_throughput GBR
...                                                                 UL_throughput=50               # UL_throughput nonGBR
...                                                                 ue_nr_capa=${SA_TDD_RANK4}

&{dict_settings_ue_2}                                               originalCell=2
...                                                                 DL_throughput=150
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=50
...                                                                 ue_nr_capa=${SA_TDD_RANK2}

&{dict_settings_ue_3}                                               originalCell=3
...                                                                 DL_throughput=200
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=50
...                                                                 ue_nr_capa=${SA_TDD_RANK4}

&{dict_settings_ue_4}                                               originalCell=4
...                                                                 DL_throughput=150
...                                                                 DL_throughput_GBR=0
...                                                                 UL_throughput=50
...                                                                 ue_nr_capa=${SA_TDD_RANK2}

@{dict_ues}                                                         ${dict_settings_ue_1}
...                                                                 ${dict_settings_ue_2}
...                                                                 ${dict_settings_ue_3}
...                                                                 ${dict_settings_ue_4}

${num_iteration}    1

${Cell2_Cell3_numRbForRs_48}       ${CURDIR}/config/delta_scf/Delta_Configuration_scf_Cell2_Cell3_numRbForRs_48.json
${Cell2_Cell3_numRbForRs_96}       ${CURDIR}/config/delta_scf/Delta_Configuration_scf_Cell2_Cell3_numRbForRs_96.json

# Cells parameters
&{Cell1_Conf}
...                                   Zab=0
...                                   CellId=50
...                                   minPrbDl=192                 # Check min Cell stream prb for DL
...                                   minCellPrbDl=160             # Check current Cell prb allocation within a range (min,max) for DL
...                                   maxCellPrbDl=280
...                                   minCellPrbUl=80             # Check current Cell prb allocation within a range (min,max) for UL
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=80        # Check current Cell stream prb allocation for non Gbr DL
...                                   StreamPrbGbrDl=0             # Check current Cell stream prb allocation for Gbr DL
...                                   StreamPrbNonGbrUl=140        # Check current Cell stream prb allocation for non Gbr UL
...                                   StreamPrbGbrUl=0             # Check current Cell stream prb allocation for Gbr UL
...                                   bbrmUsableCellPrbForDl=273   # Check max number of prb for DL Gbr Report
...                                   bbrmUsableCellPrbForUl=273   # Check max number of prb for UL Gbr Report

&{Cell2_Conf}
...                                   Zab=1
...                                   CellId=51
...                                   minPrbDl=192
...                                   minCellPrbDl=250
...                                   maxCellPrbDl=350
...                                   minCellPrbUl=80
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=160
...                                   StreamPrbGbrDl=0
...                                   StreamPrbNonGbrUl=140
...                                   StreamPrbGbrUl=0
...                                   bbrmUsableCellPrbForDl=273
...                                   bbrmUsableCellPrbForUl=273

&{Cell3_Conf}
...                                   Zab=0
...                                   CellId=52
...                                   minPrbDl=192
...                                   minCellPrbDl=160
...                                   maxCellPrbDl=280
...                                   minCellPrbUl=80
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=80
...                                   StreamPrbGbrDl=0
...                                   StreamPrbNonGbrUl=140
...                                   StreamPrbGbrUl=0
...                                   bbrmUsableCellPrbForDl=273
...                                   bbrmUsableCellPrbForUl=273

&{Cell4_Conf}
...                                   Zab=1
...                                   CellId=53
...                                   minPrbDl=192
...                                   minCellPrbDl=250
...                                   maxCellPrbDl=350
...                                   minCellPrbUl=80
...                                   maxCellPrbUl=320
...                                   StreamPrbNonGbrDl=160
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
...                                   L1PoolIdtoCheck=9          # L1 Pool ID for DL and UL
...                                   L1PoolMaxStreamPrbDl=4368  # Max stream prb for L1 Pool for DL
...                                   L1PoolMaxStreamPrbUl=3276  # Max stream prb for L1 Pool for UL

&{L1Subpool0_Conf}                    L1SpId=0
...                                   minStreamL1SpDl=1800  # Check current L1 Subpool stream prb allocation
...                                   maxStreamL1SpDl=2100  #      within a range (min,max) for DL
...                                   minStreamL1SpUl=1000  # Check current L1 Subpool stream prb allocation
...                                   maxStreamL1SpUl=2050  #      within a range (min,max) for UL

&{L1Subpool1_Conf}                    L1SpId=1
...                                   minStreamL1SpDl=2300
...                                   maxStreamL1SpDl=2600
...                                   minStreamL1SpUl=1200
...                                   maxStreamL1SpUl=2300

@{List_L1Subpool}                     ${L1Subpool0_Conf}
...                                   ${L1Subpool1_Conf}



*** Test Cases ***

[1]CB011028-B-EI3_2_IWK_RIM-RS_CB006991-A_online_RIM_RS_numRbForRs_modification
    TC_CB011028-EI3    ${params}
    [Teardown]            Setup.Test Teardown


*** Keywords ***

TC_CB011028-EI3
    [Documentation]       11028 Basic Call
    [Arguments]           ${params}
    Set Suite Variable    ${params}
    Init Sequence         ${params}
    Step                  Set RAD Params for 11028
#   Step                  Update Vendor File Config For bbL1SpPrbInitCapacity And bbPoolCapacity for ASOE           argument=${Vendor_Param}
    Step                  Set 11028 Context TDD SA
    Step                  Restart.F1 Wait Link Classical
    ${listOfUes}          Build UEs list SA Multi UEs               dict_ues=${dict_ues}
    Step                  Set UE_Capa Context_WTS CFG               listOfUes=${listOfUes}
    Step                  Multi Cells Setup for 11028               listOfUes=${listOfUes}     nbCell=${params.nbCell}
    Critical Step         SA Start Traffic Multi UEs NonGBR         listOfUes=${listOfUes}
    Step                  Get L1L2 Logs
    Step                  Check Rim Rs in L1L2
    FOR     ${i}     IN RANGE     0     ${num_iteration}
        ${iteration}=     Evaluate      ${i} + 1
        Step              Modify and Check Rim Rs in L1L2            RimCell1=48
                          ...                                        RimCell2=96
                          ...                                        RimCell3=96
                          ...                                        RimCell4=48
                          ...                                        listOfUes=${listOfUes}
                          ...                                        it=${iteration}
        Step              Get TTI Logs
        Step              Check Prb Pooling DL in TTI
        Step              Check Prb Pooling UL in TTI
        Step              Set to Default and check Rim Rs in L1L2    listOfUes=${listOfUes}
                          ...                                        it=${iteration}
    END
    Step                  SA DeRegister Multi UEs                    listOfUes=${listOfUes}
    Step                  Get Snaphot Sos Report
    [Teardown]            Display diagnosis
