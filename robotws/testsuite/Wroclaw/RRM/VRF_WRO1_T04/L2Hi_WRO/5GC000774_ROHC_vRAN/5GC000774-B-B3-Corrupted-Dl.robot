*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/pm_counters_validator_vran.py
Documentation
...    author: Anna Chabik
...    maintainer: Anna Chabik (anna.chabik@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc
...   AND   Set Internal Traffic Type To UEs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC000774-B-B3_Verification_Of_Pm_Counters_Dl_Sdu_Disc_During_Rohc_Comp_And_Dl_Vol_Disc_During_Rohc_Comp
    Wait For Next PM counters Interval
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Packet Corrupted Dl Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Deregister Ue    ue_id=1
    Verify If Rohc Compr Failed Rd Counters Were Incremented

*** Keywords ***
Display Ue Statistics
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=3 trf_id=1 dir=bi type=l3_trf include_corruption_stats=on
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Packet Corrupted Dl Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 trf_id=1 dir=dl dl_packet_corruption=2 corruption_threshold=0

Verify If Rohc Compr Failed Rd Counters Were Incremented
    Wait For Next PM counters Interval
    ${RD_COUNTERS}=    Get Counters File From vCU    rad_counters=${True}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55320CRD50503
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55320CRD50504
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}