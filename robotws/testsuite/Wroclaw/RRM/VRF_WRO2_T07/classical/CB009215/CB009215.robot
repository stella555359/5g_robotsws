*** Settings ***
Documentation
...   author: Marta Irasiak-Gaciarek
...   contact: marta.irasiak-gaciarek@nokia.com
...   This is the TESTSUITE file for feature CB009215
...   Verification od PRB pooling based on sherpa logs. All needed parameter are collected in 2 dictionaries:
...   first with cellid as a key and list of parameters as a value: [0-PoolId, 1-SubPoolId, 2-NRCellid, 3-NumMinPrbAlloc,
...   4-NumMaxPrbAlloc, 5-CellType, 6-PrbAllocated, 7-GbrPrbRequest, 8-nonGbrPrbRequest, 9-ZAB Privilege],
...   second with cellid as a key and list of parameters as a value: [0-PoolId, 1-SubPoolId, 2-l1SubPoolStreamPrbCapacity,
...   3-l1SubPoolLayerPrbCapacity, 4-NumAllocStreamPrb].



Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009215/resources/keywords_9215.robot


Suite Setup      Initialise Attenuator


Test Teardown    Run Keywords
...              Nullify attenuation on all ports                  AND
...              Detach UE  UE_1                                   AND
...              Detach UE  UE_2                                  AND
...              Detach UE  UE_3


*** Test Cases ***

CB009215_01_Enhancement_for_GBR_Non-GBR_load_estimation
    [Documentation]   The purpose of this test case is to check DL inter-L1 PRB Pooling takes place
    ...               when 3 UEs perform traffic GBR and non GBR in two cells.
    CB009215_01_Enhancement_for_GBR_Non-GBR_load_estimation

CB009215_02_ShortBsrLimitAdaptation
    [Documentation]   The purpose of this test case is to check UL inter-L1 PRB Pooling takes place
    ...               when 3 UEs perform traffic GBR and non GBR in two cells.
    CB009215_02_ShortBsrLimitAdaptation
