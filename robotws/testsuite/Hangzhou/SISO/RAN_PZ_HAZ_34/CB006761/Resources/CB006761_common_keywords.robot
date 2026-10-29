*** Settings ***
Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    feature : CB006761


*** Variables ***

*** Keywords ***
UL_and_DL_LA_Peak_QAM256_4x4MIMO_AHPF
    Modify Parameters for SA PRBblanking
    ...    actPRBBlanking=true
    ...    coresetId=1
    ...    numOfPdcchCandidatesInAL4=n5
    ...    cRbSizeUl=n106
    ...    nbrOfBlankedPRBsHighEdgeUL=54
    L3 call with Check Throughput
    ...    ul_tp=180M
    ...    dl_tp=400M
    ...    ul_exp=68
    ...    dl_exp=260
    ...    actual_rate=0.9
    Modify Parameters for SA PRBblanking
    ...    actPRBBlanking=false
    ...    coresetId=0
    ...    numOfPdcchCandidatesInAL4=n4
    ...    cRbSizeUl=allRb
    ...    nbrOfBlankedPRBsHighEdgeUL=0

General_SiSo_E2E_system_setup_with_data_transfer_AHPF
    L3 call with Check Throughput
    ...    ul_tp=300M
    ...    dl_tp=500M
    ...    ul_exp=107
    ...    dl_exp=297
    ...    actual_rate=0.9

Online Delta Commission
    [Arguments]    ${dist_name}    ${filter_param}    ${abbr}    ${node_index}    ${target_value}
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
	...    filter_param=${filter_param}    abbr=${abbr}    node_index=${node_index}
    run keyword if  not '${current_value}'=='${target_value}'
    ...    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    ...    abbr=${abbr}    node_index=${node_index}    new_value=${target_value}

Modify Parameters for SA PRBblanking
    [Arguments]    ${actPRBBlanking}    ${coresetId}    ${numOfPdcchCandidatesInAL4}    ${cRbSizeUl}
    ...    ${nbrOfBlankedPRBsHighEdgeUL}
    selenium login and disable screen lock
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    filter_param=Activate PRB blanking
	...    abbr=actPRBBlanking    node_index=${0}    target_value=${actPRBBlanking}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...    filter_param=Control resource set associated to the search space
	...    abbr=coresetId    node_index=${1}    target_value=${coresetId}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-33/PDCCH-1/PDCCH_CONFIG_DEDICATED-1
    ...    filter_param=Number of PDCCH candidates in AL4
	...    abbr=numOfPdcchCandidatesInAL4    node_index=${1}    target_value=${numOfPdcchCandidatesInAL4}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/BWP_PROFILE-4
    ...    filter_param=Uplink Common Resource Block size of the BWP
	...    abbr=cRbSizeUl    node_index=${0}    target_value=${cRbSizeUl}
    Online Delta Commission  dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
    ...    abbr=nbrOfBlankedPRBsHighEdgeUL    filter_param=Number of blanked PRBs in high edge of uplink side
    ...    node_index=${0}    target_value=${nbrOfBlankedPRBsHighEdgeUL}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    COAM Wait for gnb ready and cell setup    timeout=15min    gnb_type='SA'
    selenium logout and close browser
