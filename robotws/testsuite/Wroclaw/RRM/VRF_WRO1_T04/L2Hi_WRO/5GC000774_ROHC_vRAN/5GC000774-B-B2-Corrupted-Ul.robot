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
@{FILES_TO_CHECK_VCU}=     ${42}

*** Test Cases ***
5GC000774-B-B2_Verification_Of_Pm_Counters_Ul_Pdu_Disc_Rohc_Decomp_Failed_And_Ul_Vol_Disc_Rohc_Decomp_Failed
    Wait For Next PM counters Interval
    Set Support For Ul Packet Corruption
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Ul Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Deregister Ue    ue_id=1
    Verify If Rohc Decompr Failed Rd Counters Were Incremented

*** Keywords ***
Set Support For Ul Packet Corruption
    Execute Egate Command    cmd=ue_param id=1 rohc_hdr_corruption=2:4:6

Display Ue Statistics
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=3 trf_id=1 dir=bi type=l3_trf include_corruption_stats=on
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85

Verify If Rohc Decompr Failed Rd Counters Were Incremented
    Wait For Next PM counters Interval
    ${RD_COUNTERS}=     Get Counters File From vCU    rad_counters=${True}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55320CRD50501
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=M55320CRD50502
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${RD_COUNTERS}