# Copyright (c) 2024 Nokia. All rights reserved.
*** Settings ***
Resource    keywords.robot
Documentation    PET Test cases

Suite Setup       Common Optimized PET Suite Setup
Suite Teardown    Common PET Suite Teardown

*** Test Cases ***
ORAN TDD 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF UL 1360Mbps traffic 1UE 1 CELL over 6 cells
    [Tags]    FULLRUN    [flow]L3 Call    1208FF_UL_6CELL    ORAN_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00002
    Set To Dictionary    ${ORAN_1208FF_UL}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_1208FF_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    49    54
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${ORAN_1208FF_UL}    1208FF_UL_6CELL
    Traffic Loop With Tput Validation    ${DIR}    1208FF_UL_6CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1208FF_UL_6CELL    ${pre_data_dictionary}

ORAN TDD 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 4630Mbps 1UE 1 Cell over 3 cells
    [Tags]    FULLRUN    [flow]L3 Call    1208FF_DL_3CELL    ORAN_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set To Dictionary    ${ORAN_1208FF_DL}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_1208FF_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    19    21
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${ORAN_1208FF_DL}    1208FF_DL_3CELL
    Traffic Loop With Tput Validation    ${DIR}    1208FF_DL_3CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1208FF_DL_3CELL    ${pre_data_dictionary}

ORAN TDD 100MHz FR1 SA MUE 1116 FF 4X4MIMO NBF SA CA 3CC 72 CA UE Cell 32 nonCA UEs PER SCELL
    [Tags]    FULLRUN    [flow]L3 Call    1116FF_DL_3CELL    ORAN_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set To Dictionary    ${ORAN_1116FF_DL}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_1116FF_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    5
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${ORAN_1116FF_DL}    1116FF_DL_3CELL
    Traffic Loop With Tput Validation   ${DIR}    1116FF_DL_3CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1116FF_DL_3CELL    ${pre_data_dictionary}

CB007949 1208FF 1SSB 4*4MIMO CA 3CC DL 4800Mbps 72UEs Pscell 32UEs SCell
    [Tags]    FULLRUN    [flow]L3 Call    TDD_3CC_CA    TDD_PHASE1
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set To Dictionary    ${TDD_132UE_3CC}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${TDD_132UE_3CC}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    7    7
    @{seq_list3}=    Create List    16    16
    @{seq_list4}=    Create List    17    17
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}    ${seq_list4}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${TDD_132UE_3CC}    TDD_3CC_CA
    Traffic Loop With Tput Validation    ${DIR}    TDD_3CC_CA    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    TDD_3CC_CA

1208FF_6SSB_8x4MIMO_CA_3CC_DL_Pcell_126UEs_50_percent_Tput_473UEs_Ping_traffic_Scells_1027UEs_Ping_traffic
    [Tags]    FULLRUN    [flow]L3 Call    TDD_3CC_Scell_ABIP    TDD_PHASE1
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002    M55140C00005    M55320C18002    M55118C07003
    Set To Dictionary    ${TDD_2527UE_3CC_ABIP}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0    MaxDRB=0    AverageDRB=0    SCell_UES=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${TDD_2527UE_3CC_ABIP}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_CA_SCELL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    7    7
    @{seq_list3}=    Create List    16    16
    @{seq_list4}=    Create List    17    17
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}    ${seq_list4}
    Set Suite Variable    ${stat_list}
    ${pre_data_dictionary}=    Create Dictionary    SCell_UES=0    NRCELL-4_SCell_UES=0    NRCELL-5_SCell_UES=0
    Set Suite Variable    &{pre_data_dictionary}
    Common Register and Traffic    ${TDD_2527UE_3CC_ABIP}    TDD_3CC_Scell_ABIP
    Sleep    10m
    ${return_list}=    Fetch Cummulative Values    ${ADD_2DLSCELL_CA_COUNTER}
    ${final_scell1}=    Run Keyword    Get counter value per Cell    1    ${return_list}
    ${return_list}=    Fetch Cummulative Values    ${SGNB_SA_ADMISSION_NON_CA_COUNTER}
    ${final_scell4}=    Run Keyword    Get counter value per Cell    4    ${return_list}
    ${final_scell5}=    Run Keyword    Get counter value per Cell    5    ${return_list}
    ${pre_data_check}=    Create List
    Set Suite Variable    @{pre_data_check}
    Log To Console    Scell Counter value NRCELL-4: ${final_scell1}
    Log To Console    Scell Counter value NRCELL-4: ${final_scell4}
    Log To Console    Scell Counter value NRCELL-5: ${final_scell5}
    ${scell_status} =    Run Keyword If    '${final_scell1}' == '${EXPECTED_CA_SCELL}'    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    ${scells_status}=    Run Keyword If    '${final_scell4}' == '${EXPECTED_NON_CA_SCELL_C4}' and '${final_scell5}' == '${EXPECTED_NON_CA_SCELL_C4}'
    ...    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    Append To List    ${pre_data_check}    ${scell_status}    ${scells_status}
    Set To Dictionary    ${pre_data_dictionary}    SCell_UES=${final_scell1}/${EXPECTED_CA_SCELL}
    Set To Dictionary    ${pre_data_dictionary}    NRCELL-4_SCell_UES=${final_scell4}/${EXPECTED_NON_CA_SCELL_C4}
    Set To Dictionary    ${pre_data_dictionary}    NRCELL-5_SCell_UES=${final_scell5}/${EXPECTED_NON_CA_SCELL_C5}
    List Should Not Contain Value    ${pre_data_check}    FAIL    msg=Scell Validation failed
    Traffic Loop With Tput Validation    ${DIR}    TDD_3CC_Scell_ABIP    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    TDD_3CC_Scell_ABIP
    ...    ${pre_data_dictionary}

1116 0msFF 3T and 1F MUMIMO SRS Based BF 4CC SA DLCA 6340Mbps PcellTDD 72CAUEs Scell 32NonCAUEs
    [Tags]    FULLRUN    [flow]L3 Call    MPP_MUMIMO    MPP_AP_LOOO
    Traffic Duration Set
    ${scell_status}=    Create List
    Set Suite Variable    @{scell_status}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set To Dictionary    ${MUMIMO_MPP}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MUMIMO_MPP}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${pre_data_dictionary}=    Create Dictionary    Scell_Addition=0    NRCELL-2_SCELL_ACTIVATION=0
    ...    NRCELL-3_SCELL_ACTIVATION=0    NRCELL-4_SCELL_ACTIVATION=0
    Set Suite Variable    &{pre_data_dictionary}
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    5    5
    @{seq_list3}=    Create List    10    10
    @{seq_list4}=    Create List    15    15
    @{seq_list5}=    Create List    20    20
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}    ${seq_list4}    ${seq_list5}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${MUMIMO_MPP}    MPP_MUMIMO
    Sleep    10m
    ${return_list}=    Fetch Cummulative Values    M55118C00033
    ${final_scell1}=    Run Keyword    Get counter value per Cell    1    ${return_list}
    ${scell_add_status}=    Run Keyword If    '${final_scell1}' == '${EXPECTED_SCELL_ADD}'    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    Append To List    ${scell_status}    ${scell_add_status}
    ${return_list}=    Fetch Cummulative Values    M55316C09000
    ${final_scell2}=    Run Keyword    Get counter value per Cell    2    ${return_list}
    Log To Console    SCELL ACTIVATION CELL 2:${final_scell2}
    ${final_scell3}=    Run Keyword    Get counter value per Cell    3    ${return_list}
    Log To Console    SCELL ACTIVATION CELL 3:${final_scell3}
    ${final_scell4}=    Run Keyword    Get counter value per Cell    4    ${return_list}
    Log To Console    SCELL ACTIVATION CELL 4:${final_scell4}
    ${scell_active}=    Catenate    '${final_scell2}' == '${EXPECTED_SCELL_ACTIVE}' and
    ...    '${final_scell3}' == '${EXPECTED_SCELL_ACTIVE}' and '${final_scell4}' == '${EXPECTED_SCELL_ACTIVE}'
    ${scell_active_status}=    Set Variable If    ${scell_active}    True    FAIL
    Append To List    ${scell_status}    ${scell_active_status}
    @{MU_MIMO_PAIRING_COUNTERS}=    Create List    M55308C34013    M55308C34014    M55308C34015
    Set Suite Variable    @{MU_MIMO_PAIRING_COUNTERS}
    Check MU_MIMO Pairing Counters    ${MU_MIMO_PAIRING_COUNTERS}
    Set To Dictionary    ${pre_data_dictionary}    Scell_Addition=${final_scell1}/${EXPECTED_SCELL_ADD}
    Set To Dictionary    ${pre_data_dictionary}    NRCELL-2_SCELL_ACTIVATION=${final_scell2}/${EXPECTED_SCELL_ACTIVE}
    Set To Dictionary    ${pre_data_dictionary}    NRCELL-3_SCELL_ACTIVATION=${final_scell3}/${EXPECTED_SCELL_ACTIVE}
    Set To Dictionary    ${pre_data_dictionary}    NRCELL-4_SCELL_ACTIVATION=${final_scell4}/${EXPECTED_SCELL_ACTIVE}
    Log To Console    ${pre_data_dictionary}
    List Should Not Contain value    ${scell_status}    FAIL    msg=Test case failed at Scell Addition/Activation
    Traffic Loop With Tput Validation    ${DIR}    MPP_MUMIMO    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    MPP_MUMIMO    ${pre_data_dictionary}

1116 0msFF 3T and 1F SSB BF 4CC SA Pcell 126UEs 50 percent Tput 800Mbps 240UEs Ping traffic Scells 1134UEs Ping traffic
    [Tags]    FULLRUN    [flow]L3 Call    MPP_MAXRRC    MPP_AP_LOOO
    Traffic Duration Set
    ${scell_list_status}=    Create List
    Set Suite Variable    @{scell_list_status}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55140C00002
    Set To Dictionary    ${MAXRRC_MPP}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MAX_NUM_OF_DRB=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MAXRRC_MPP}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${pre_data_dictionary}=    Create Dictionary    SCell_UES=0
    Set Suite Variable    &{pre_data_dictionary}
    Common Register and Traffic    ${MAXRRC_MPP}    MPP_MAXRRC
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    5    5
    @{seq_list3}=    Create List    10    10
    @{seq_list4}=    Create List    15    15
    @{seq_list5}=    Create List    20    20
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}    ${seq_list4}    ${seq_list5}
    Set Suite Variable    ${stat_list}
    Sleep    10m
    ${return_list}=    Fetch Cummulative Values    M55118C00033
    ${final_scell1}=    Run Keyword    Get counter value per Cell    1    ${return_list}
    ${scell_status}=    Run Keyword If    '${final_scell1}' == '${EXPECTED_CA_SCELL}'    Set Variable    True
    ...    ELSE    Set Variable    FAIL
    Append To List    ${scell_list_status}    ${scell_status}
    ${scell_data}=    Set Variable    "SCell_UES": "${final_scell1}/${EXPECTED_CA_SCELL}"
    Log To Console    ${scell_data}
    ${pre_data_dictionary}=    Create Dictionary
    Set To Dictionary    ${pre_data_dictionary}    SCell_UES=${final_scell1}/${EXPECTED_CA_SCELL}
    Log To Console    ${pre_data_dictionary}
    List Should Not Contain value    ${scell_list_status}    FAIL    msg=Test case failed at Scell Addition/Activation
    Traffic Loop With Tput Validation    ${DIR}    MPP_MAXRRC    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    MPP_MAXRRC    ${pre_data_dictionary}

ORAN FDD NonDSS 20MHz 4DL4UL 18Cells 836FF SA 72UE DL 406Mbps UL 202Mbps
    [Tags]    FULLRUN    [flow]L3 Call    72UE_18CELL    ORAN_FDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${72UE_836FF_18CELL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    19    19
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${72UE_836FF_18CELL}    72UE_18CELL
    Traffic Loop With Tput Validation    ${DIR}    72UE_18CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    72UE_18CELL    ${pre_data_dictionary}

ORAN FDD NonDSS 20MHz 4DL4UL 18Cells 836FF SA DL 2403Mbps UL 1127Mbps 9UE with 9 cells on one LOKI
    [Tags]    FULLRUN    [flow]L3 Call    9UE_18CELL    ORAN_FDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${9UE_836FF_18CELL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    109    126
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${9UE_836FF_18CELL}    9UE_18CELL
    Traffic Loop With Tput Validation    ${DIR}    9UE_18CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    9UE_18CELL    ${pre_data_dictionary}

TDD FR2 SA 1S 4CC Max RCC Max DRB Max SRB
    [Tags]    FULLRUN    [flow]L3 Call    1S_4CC_106UE    FR2_TDD
    Traffic Duration Set
    ${scell_status}=    Create List
    Set Suite Variable    @{scell_status}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${1S_4CC_106UE}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    Common Register and Traffic    ${1S_4CC_106UE}    1S_4CC_106UE
    Traffic Loop With Tput Validation    ${DIR}    1S_4CC_106UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1S_4CC_106UE    ${pre_data_dictionary}

TDD FR2 SA 1S 4CC MUE Max UL TP
    [Tags]    FULLRUN    [flow]L3 Call    1S_4CC_53UE    FR2_TDD
    Traffic Duration Set
    ${scell_status}=    Create List
    Set Suite Variable    @{scell_status}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${1S_4CC_53UE}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    Common Register and Traffic    ${1S_4CC_53UE}    1S_4CC_53UE
    Traffic Loop With Tput Validation    ${DIR}    1S_4CC_53UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1S_4CC_53UE    ${pre_data_dictionary}

TDD FR2 SA 6S 4CC MUE Max DL TP
    [Tags]    FULLRUN    [flow]L3 Call    MUE_6S_4CC    FR2_TDD
    Traffic Duration Set
    ${scell_status}=    Create List
    Set Suite Variable    @{scell_status}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${6S_4CC_MUE}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    5    5
    @{seq_list3}=    Create List    9    9
    @{seq_list4}=    Create List    13    13
    @{seq_list5}=    Create List    17    17
    @{seq_list6}=    Create List    21    21
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}    ${seq_list4}    ${seq_list5}
    ...    ${seq_list6}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${6S_4CC_MUE}    MUE_6S_4CC
    Traffic Loop With Tput Validation    ${DIR}    MUE_6S_4CC    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    MUE_6S_4CC    ${pre_data_dictionary}

TDD FR2 NonCA 2DL2UL 6S 1CC SA 106UE MUE per cell with 50 percent of Cell TP
    [Documentation]    TDD FR2 NonCA 2DL2UL 6S 1CC SA 106UE MUE
    ...    per cell with 50 percent of Cell TP
    [Tags]    FULLRUN    [flow]L3 Call    SA_106UE_RRC
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${RRC_106UE_2CELL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    Common Register and Traffic    ${RRC_106UE_2CELL}    SA_106UE_RRC
    Traffic Loop With Tput Validation    ${DIR}    SA_106UE_RRC    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    SA_106UE_RRC    ${pre_data_dictionary}

TDD FR2 NonCA 2DL2UL 6S 1CC SA 53UE Peak DL530Mbps traffic MUE per cell
    [Documentation]    TDD FR2 NonCA 2DL2UL 6S 1CC SA 53UE
    ...    Peak DL530Mbps traffic MUE per cell
    [Tags]    FULLRUN    [flow]L3 Call    DL_53UE_FR2
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_53UE_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    Common Register and Traffic    ${FR2_53UE_DL}    DL_53UE_FR2
    Traffic Loop With Tput Validation    ${DIR}    DL_53UE_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    DL_53UE_FR2    ${pre_data_dictionary}

TDD FR2 NonCA 2DL2UL 6S 1CC SA 53UE Peak UL144Mbps traffic MUE per cell
    [Documentation]    TDD FR2 NonCA 2DL2UL 6S 1CC SA 53UE
    ...    Peak UL144Mbps traffic MUE per cell
    [Tags]    FULLRUN    [flow]L3 Call    UL_53UE_FR2
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_53UE_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    Common Register and Traffic    ${FR2_53UE_UL}    UL_53UE_FR2
    Traffic Loop With Tput Validation    ${DIR}    UL_53UE_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    UL_53UE_FR2    ${pre_data_dictionary}

1070FF 6SSB 8x4 MIMO 6CELL SA 48UE DL 3600Mbps UL 1920Mbps traffic 8UE per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    48UEDLUL_BF
    Traffic Duration Set
    Fetch Dictionary items    ${BF_48UEDLUL}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00002
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${BF_48UEDLUL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    51    56
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${BF_48UEDLUL}    48UEDLUL_BF
    Traffic Loop With Tput Validation    ${DIR}    48UEDLUL_BF    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    48UEDLUL_BF    ${pre_data_dictionary}

1208FF 6SSB 8x4 MIMO 6CELL SA GBR Bearers 1182UEs DL 5900Mbps traffic 197UEs per CELL
    [Tags]    FULLRUN    [flow]L3 Call    1208FF_GBR
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${GBR_1208FF}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    41    46
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${GBR_1208FF}    1208FF_GBR
    Traffic Loop With Tput Validation    ${DIR}    1208FF_GBR    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1208FF_GBR    ${pre_data_dictionary}

CB008118_1070FF_6_SSB_8x4MIMO_6CELL_SA_GBR_MC_Bearers_552UEs_UL_1380Mbps_92_UEs_Percell
    [Tags]    FULLRUN    [flow]L3 Call    1070FF_GBR_ABIP
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00002    M55140C00501    M55140C00005
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    NON_GBR=0    GBR_COUNT=0    MaxDRB=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${GBR_1070FF_ABIP}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}    ${EXPECTED_GBR}    ${EXPECTED_MaxDRB}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    47    52
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${GBR_1070FF_ABIP}    1070FF_GBR_ABIP
    Traffic Loop With Tput Validation    ${DIR}    1070FF_GBR_ABIP    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1070FF_GBR_ABIP    ${pre_data_dictionary}

1070FF 6SSB 8x4 MIMO 6CELL SA GBR Bearers 300UEs DL 564Mbps UL 564Mbps traffic 50UEs per CELL
    [Tags]    FULLRUN    [flow]L3 Call    1070FF_MIXEDGBR
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0
    ...    GBR=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MIXEDGBR_1070FF}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}
    ...    ${EXPECTED_GBR}    ${EXPECTED_NONGBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    30
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${MIXEDGBR_1070FF}    1070FF_MIXEDGBR
    Traffic Loop With Tput Validation    ${DIR}    1070FF_MIXEDGBR    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1070FF_MIXEDGBR    ${pre_data_dictionary}

CB008701_1116_0msFF_3Cells_SRSBF_8x4MIMO_16DL8UL_MUMIMO_SA_DL_16UEs_6000Mpbs_in_1Cell
    [Tags]    FULLRUN    [flow]L3 Call    CB008701_16UES    TDD_PHASE1
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${CB008701_16DLUL_16UES}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${CB008701_16DLUL_16UES}    CB008701_16UES
    Traffic Loop With Tput Validation    ${DIR}    CB008701_16UES    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    CB008701_16UES    ${pre_data_dictionary}

TDD FR2 SA 3S 8CC MUE Max DL TP
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_DL_FR2   FR2_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_3S_8CC_MUE_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    49    49
    @{seq_list2}=    Create List    57    57
    @{seq_list3}=    Create List    65    65
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FR2_3S_8CC_MUE_DL}    3S_8CC_DL_FR2
    Traffic Loop With Tput Validation    ${DIR}    3S_8CC_DL_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    3S_8CC_DL_FR2    ${pre_data_dictionary}

TDD FR2 SA 3S 8CC MUE Max UL TP
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_UL_FR2    FR2_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_3S_8CC_MUE_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    73    73
    @{seq_list2}=    Create List    81    81
    @{seq_list3}=    Create List    89    89
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FR2_3S_8CC_MUE_UL}    3S_8CC_UL_FR2
    Traffic Loop With Tput Validation    ${DIR}    3S_8CC_UL_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    3S_8CC_UL_FR2    ${pre_data_dictionary}

TDD_FR2_SA_3S_8CC_12UE_Max_DL_TP
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_DL_12UE
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_3S_8CC_12UE_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    9    9
    @{seq_list3}=    Create List    17    17
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FR2_3S_8CC_12UE_DL}    3S_8CC_DL_12UE
    Traffic Loop With Tput Validation    ${DIR}    3S_8CC_DL_12UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    3S_8CC_DL_12UE    ${pre_data_dictionary}

ORAN FDD NonDSS 40MHz 4DL4UL 3Cells 836FF SA 72UEs DL 831Mbps UL 449Mbps
    [Tags]    FULLRUN    [flow]L3 Call    72UE_3CELL    ORAN_FDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${72UE_836FF_3CELL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    5    5
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${72UE_836FF_3CELL}    72UE_3CELL
    Traffic Loop With Tput Validation    ${DIR}    72UE_3CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    72UE_3CELL    ${pre_data_dictionary}

ORAN FDD NonDSS 40MHz 4DL4UL 3Cells 836FF 3CC 136 SA UE PEAK DL 72 CA UE PCell 32 nonCA UEs PER SCELL
    [Tags]    FULLRUN    [flow]L3 Call    72UE_DL_3CELL    ORAN_FDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${72UE_3CELL_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    4
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${72UE_3CELL_DL}    72UE_DL_3CELL
    Traffic Loop With Tput Validation    ${DIR}    72UE_DL_3CELL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    72UE_DL_3CELL    ${pre_data_dictionary}

ORAN TDD 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 1630Mbps UL 226Mbps 72UE 1Cell
    [Tags]    FULLRUN    [flow]L3 Call    1208FF_DL_UL    ORAN_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00002
    Set To Dictionary    ${ORAN_1208FF_DL_UL}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_1208FF_DL_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    25    25
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${ORAN_1208FF_DL_UL}    1208FF_DL_UL
    Traffic Loop With Tput Validation    ${DIR}    1208FF_DL_UL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1208FF_DL_UL    ${pre_data_dictionary}

TDD FR2 SA 6S 4CC Max RRC DL TP
    [Tags]    FULLRUN    [flow]L3 Call    6S_4CC_DL_FR2   FR2_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_6S_4CC_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    25    25
    @{seq_list2}=    Create List    29    29
    @{seq_list3}=    Create List    33    33
    @{seq_list4}=    Create List    37    37
    @{seq_list5}=    Create List    41    41
    @{seq_list6}=    Create List    45    45
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}    ${seq_list4}    ${seq_list5}    ${seq_list6}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FR2_6S_4CC_DL}    6S_4CC_DL_FR2
    Traffic Loop With Tput Validation    ${DIR}    6S_4CC_DL_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    6S_4CC_DL_FR2    ${pre_data_dictionary}

TDD FR2 SA 1S 8CC MUE Max DL TP
    [Tags]    FULLRUN    [flow]L3 Call    1S_8CC_DL_FR2   FR2_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_1S_8CC_MUE_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    17    17
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FR2_1S_8CC_MUE_DL}    1S_8CC_DL_FR2
    Traffic Loop With Tput Validation    ${DIR}    1S_8CC_DL_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1S_8CC_DL_FR2    ${pre_data_dictionary}

TDD FR2 SA 1S 8CC MUE Max UL TP
    [Tags]    FULLRUN    [flow]L3 Call    1S_8CC_UL_FR2    FR2_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00005    M55320C18002    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    MaximumDRB=0    AverageDRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FR2_1S_8CC_MUE_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_MaxDRB}    ${EXPECTED_AvgDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    25    25
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FR2_1S_8CC_MUE_UL}    1S_8CC_UL_FR2
    Traffic Loop With Tput Validation    ${DIR}    1S_8CC_UL_FR2    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    1S_8CC_UL_FR2    ${pre_data_dictionary}

CB010448 4x4 MIMO 8CELL 50MHz ABIP SA 8UE DL 6800Mbps SUE per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    8UEDL_MIMO
    Traffic Duration Set
    Fetch Dictionary items    ${8UEDL_MIMO}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    8
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${8UEDL_MIMO}    8UEDL_MIMO
    Traffic Loop With Tput Validation    ${DIR}    8UEDL_MIMO    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    8UEDL_MIMO

CB010448 4x4 MIMO 8CELL 50MHz ABIP SA 8UE UL 3100Mbps SUE per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    8UEUL_MIMO
    Traffic Duration Set
    Fetch Dictionary items    ${8UEUL_MIMO}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    9    16
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${8UEUL_MIMO}    8UEUL_MIMO
    Traffic Loop With Tput Validation    ${DIR}    8UEUL_MIMO    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    8UEUL_MIMO

CB011080 6CC 3x100Mhz 3x20Mhz 3T 3F MUMIMO SRS Based BF DLCA 1208FF SA 72CAUEsonPcellTDD 32NonCAUes on Scell 7337MbpsDL
    [Tags]    FULLRUN     [flow]L3 Call    MIMO_232UECA
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00002    M55326C00501
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MIMO_232UECA}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    2    8
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${MIMO_232UECA}    MIMO_232UECA
    Traffic Loop With Tput Validation    ${DIR}    MIMO_232UECA    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    MIMO_232UECA

CB005935 6CC 3x100Mhz 3x20Mhz 3F 3T ULCA 1208FF SA 30CAUEsonPcelFDD 222MbpsUL
    [Tags]    FULLRUN     [flow]L3 Call    CB005935_30UE
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00002    M55326C00502
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${CB005935_30UE}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${CB005935_30UE}    CB005935_30UE
    Traffic Loop With Tput Validation    ${DIR}    CB005935_30UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    CB005935_30UE

CB011080 6CC 3x100Mhz 3x20Mhz 3T 3F CA SSB BF 1208FF SA MAXRRC 236CAUEsonPcell 1264NonCAUEsonScells2TDD 3FDDcell
    [Tags]    FULLRUN     [flow]L3 Call    FDD_TDD_6556UEDL
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00002    M55326C00501
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FDD_TDD_6556UEDL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    9    15
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${FDD_TDD_6556UEDL}    FDD_TDD_6556UEDL
    Traffic Loop With Tput Validation    ${DIR}    FDD_TDD_6556UEDL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    FDD_TDD_6556UEDL

SCF VALIDATION STATUS
    [Tags]    FULLRUN    [flow]L3 Call    TDD_SCF    FDD_SCF    SCF_CHECK
    ${tags}=    Get Variable Value    ${TEST TAGS}
    SCF Error Validation    ${apConfiguration}
    @{lines}=    Split String    ${SCF_VALIDATION_STATUS}    :
    ${mail_data}=    Create Dictionary
    Set To Dictionary   ${mail_data}    AP_CONFIGURATION    ${apConfiguration}
    ${json_mail_data}=    Evaluate   json.dumps(${mail_data})    json
    Set Suite Variable    ${json_mail_data}
    Append To File    ${test_property_file}
    ...    ${\n}SCF_CHECK_TEST_RESULTS={"s1-t1":${json_mail_data}}${\n}
    ${STATUS}    Set Variable If      '${lines}[1]' == ' Pass'    True    False
    Should Be True    ${STATUS}    msg=SCF Validation Failed, Check for errors in scf_errors.txt

Agent Status
    [Tags]    FULLRUN    [flow]L3 Call    AGENT_TC
    ${agent_status}    Run    agentctl info 1|grep "${SPACE}*STATE"
    Log To Console    ${agent_status}

CB010448 4x4 MIMO 8CELL 50MHz SA VoNR 2880UEs DL UL Ping traffic 360UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    8UE_VoNR
    Traffic Duration Set
    Fetch Dictionary items    ${8UE_VoNR}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55125C09530
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    PEAK_VoNR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_PeakVoNR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    17    24
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${8UE_VoNR}    8UE_VoNR
    Traffic Loop With Tput Validation    ${DIR}    8UE_VoNR    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    8UE_VoNR

CB008305 1208FF SRS BF 8x4MIMO 6Cells SA 432UEs DL 10300Mbps MUMIMO 2Cells 72UEs Percell SUMIMO 4Cells 72UEs Percell
    [Tags]    FULL_RUN     [flow]L3 Call    CB008305_432UE
    Traffic Duration Set
    Fetch Dictionary items    ${CB008305_432UE_DL}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    6
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${CB008305_432UE_DL}    CB008305_432UE
    Traffic Loop With Tput Validation    ${DIR}    CB008305_432UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    CB008305_432UE    ${pre_data_dictionary}

CB009568 Max RRC connected 1500 UEs with 1208FF SA per cell incl Red Cap UE 8 DL 200RedCap UE 1300 non RedCap UE 100 MHz
    [Tags]    FULLRUN     [flow]L3 Call    RRC_RedCap
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55140C00002
    Set To Dictionary    ${REDCAP_RRC}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${REDCAP_RRC}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    4    4
    @{seq_list2}=    Create List    7    7
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${REDCAP_RRC}    RRC_RedCap
    Traffic Loop With Tput Validation    ${DIR}    RRC_RedCap    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    RRC_RedCap

CB009568 DL throughput 1360 Mbps with 1208FF SA per cell incl Red Cap UE 8DL 15RedCap UE 57 non RedCap UE 100MHz
    [Tags]    FULLRUN     [flow]L3 Call    DL_RedCap
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${REDCAP_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    19    19
    @{seq_list2}=    Create List    16    16
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${REDCAP_DL}    DL_RedCap
    Traffic Loop With Tput Validation    ${DIR}    DL_RedCap    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    DL_RedCap

CB009568 UL throughput 309 Mbps with 1070FF_SA per cell incl Red Cap UE 4UL 15RedCap UE 57 non RedCap UE 100MHz
    [Tags]    FULLRUN     [flow]L3 Call    UL_RedCap
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${REDCAP_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    25    25
    @{seq_list2}=    Create List    22    22
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${REDCAP_UL}    UL_RedCap
    Traffic Loop With Tput Validation    ${DIR}    UL_RedCap    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    UL_RedCap

CB012149 A CA TDD FDD 2CC UL Throughput with UL TX switching
    [Tags]    FULLRUN     [flow]L3 Call    TDD_FDD_CB012149
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55310C03006    M55310C03006    M55308C35001    M55308C35002
    ...    M55308C35003    M55308C35004    M55308C35005    M55181C00010    M55118C00053
    Set Suite Variable    ${COUNTER_LIST}
    @{INDEX_LIST}=    Create List    0    0    1    2    2    2    2    2    2    2    2
    Set Suite Variable    ${INDEX_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0     PDCP_UL_TPUT(Mbps)=0    CELL2_FDD_TPUT(Mbps)=0
    ...    CELL3_TDD_TPUT(Mbps)=0    PAIRING_SUCESS_RATIO=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${TDD_FDD_CB012149}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_PDCP_UL_RANGE}    ${EXPECTED_RANGE_CELL2}
    ...    ${EXPECTED_CELL3_FDD_TPUT}    ${EXPECTED_PAIRING_SUCESS_RATIO}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{seq_list2}=    Create List    2    3
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${TDD_FDD_CB012149}    TDD_FDD_CB012149
    Traffic Loop With Tput Validation    ${DIR}    TDD_FDD_CB012149    ${COUNTER_LIST}    ${MAIL_DATA}    ${INDEX_LIST}
    [Teardown]    Deregister and Append Data    TDD_FDD_CB012149

CB012149 C CA TDD FDD 2CC UL Throuhput without UL TX switching
    [Tags]    FULLRUN     [flow]L3 Call    CB012149_TC2
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55310C03006    M55310C03006    M55308C35001    M55308C35002
    ...    M55308C35003    M55308C35004    M55308C35005
    Set Suite Variable    ${COUNTER_LIST}
    @{INDEX_LIST}=    Create List    0    0    1    2    2    2    2    2    2
    Set Suite Variable    ${INDEX_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    PDCP_UL_TPUT(Mbps)=0    CELL2_FDD_TPUT(Mbps)=0
    ...    CELL3_TDD_TPUT(Mbps)=0    PAIRING_SUCESS_RATIO=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${CB012149_TC2}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_PDCP_UL_RANGE}    ${EXPECTED_RANGE_CELL2}
    ...    ${EXPECTED_CELL3_FDD_TPUT}    ${EXPECTED_PAIRING_SUCESS_RATIO}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    4    4
    @{seq_list2}=    Create List    5    6
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${CB012149_TC2}    CB012149_TC2
    Traffic Loop With Tput Validation    ${DIR}    CB012149_TC2    ${COUNTER_LIST}    ${MAIL_DATA}    ${INDEX_LIST}
    [Teardown]    Deregister and Append Data    CB012149_TC2

CB012149 2FDD 3TDD 5CC DL 2CC UL 30percent CA RRC connected UEs with overall 5906 UEs with Ping Data
    [Tags]    FULLRUN    [flow]L3 Call    CB012149_30CA_RRC
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001
    Set To Dictionary    ${RRC_30CA_CB012149}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${RRC_30CA_CB012149}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    8    8
    @{seq_list2}=    Create List    14    14
    @{seq_list3}=    Create List    15    18
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}    ${seq_list3}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${RRC_30CA_CB012149}    CB012149_30CA_RRC
    Traffic Loop With Tput Validation   ${DIR}    CB012149_30CA_RRC    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    CB012149_30CA_RRC

ORAN TDD 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 1654Mbps traffic 72UE 3CELL dlDmrsType Type2 TVTN TDD FR1 10103
    [Tags]    FULLRUN    [flow]L3 Call    CB008830_DL    ORAN_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set To Dictionary    ${ORAN_CB008830_TC1}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_CB008830_TC1}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    25    25
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${ORAN_CB008830_TC1}    CB008830_DL
    Traffic Loop With Tput Validation    ${DIR}    CB008830_DL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    CB008830_DL

ORAN TDD 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 4735Mbps traffic 3UE 3CELL dlDmrs Type2 TVTN TDD FR1 10332
    [Tags]    FULLRUN    [flow]L3 Call    CB008830_TDD_DL    ORAN_TDD
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set To Dictionary    ${ORAN_CB008830_TC2}    COUNTER_LIST    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_CB008830_TC2}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    19    21
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${ORAN_CB008830_TC2}    CB008830_TDD_DL
    Traffic Loop With Tput Validation    ${DIR}    CB008830_DL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    CB008830_TDD_DL

2AP CNI112583 ABIP 1116 0msFF 6Cell SRSBF 8x4MIMO 16DL8UL MUMIMO SA DL 72UEs 6000mbps
    [Tags]    FULLRUN    [flow]L3 Call    2AP_CNI112583_72UES    2AP
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${2AP_CNI112583_UL_72UES}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    1
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${2AP_CNI112583_UL_72UES}    2AP_CNI112583_72UES
    Traffic Loop With Tput Validation    ${DIR}    2AP_CNI112583_72UES    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    2AP_CNI112583_72UES

CNI 112583 PET ABIP 1116 0msFF 6Cell SRSBF 8x4MIMO 16DL8UL MUMIMO 72UE DL 6Cell 8600 Mbps
    [Tags]    FULLRUN    [flow]L3 Call    2AP_8600_72UES    2AP
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${2AP_8600_DL_72UES}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    7    12
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${2AP_8600_DL_72UES}    2AP_8600_72UES
    Traffic Loop With Tput Validation    ${DIR}    2AP_8600_72UES    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    2AP_8600_72UES    ${pre_data_dictionary}

CNI 112583 PET ABIP 1070FF 6Cell SRSBF 8x4MIMO 16DL8UL MUMIMO SA UL 72UEs 6Cell 2220 Mbps
    [Tags]    FULLRUN    [flow]L3 Call    2AP_2220_72UES    2AP
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${2AP_2220_UL_72UES}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    6
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${2AP_2220_UL_72UES}    2AP_2220_72UES
    Traffic Loop With Tput Validation    ${DIR}    2AP_2220_72UES    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    2AP_2220_72UES

CNI 112583 PET ABIP 1070FF 6Cell SSB 8x4MIMO 16DL8UL MUMIMO SRSBF SA 1500UEs DL UL Ping traffic 2DRBs PerUE
    [Tags]    FULLRUN    [flow]L3 Call    2AP_1500UES_RRC    2AP
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${2AP_1500UES}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    7    7
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${2AP_1500UES}    2AP_1500UES_RRC
    Traffic Loop With Tput Validation    ${DIR}    2AP_1500UES_RRC    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    2AP_1500UES_RRC

ORAN VTM MVP 1116FF 0ms 4DL4UL Non BF 6Cells CA scell addition-deletion UEstatetransition attach-detach paging Mixed HO VONR RNA TAU additional DRB
    [Tags]    FULLRUN     [flow]L3 Call    VTM_MVP_TDD
    @{COUNTER_LIST}=    Create List    M55112C00002    M55112C00010    M55112C00007    M55112C00005    M55120C00001    M55120C00501
    ...    M55120C00004    M55151C00001    M55151C00002    M55151C00005    M55151C00007    M55151C00008    M55112C02501    M55118C02000
    ...    M55118C02001    M55118C02002    M55118C02003    M55118C02004    M55118C02005    M55118C02006    M55118C02007    M55118C02008
    ...    M55118C02009    M55118C02010    M55118C02011    M55118C02012    M55118C02013    M55118C06503    M55124C01001    M55124C01002
    ...    M55124C01003    M55124C01004    M55124C01005    M55124C01006    M55124C01014    M55124C01015    M55124C01016    M55124C01017
    ...    M55124C00008    M55124C00007    M55124C00001    M55125C00014    M55125C00016    M55125C00018    M55125C02504    M55145C00301
    ...    M55145C00303    M55145C00304    M55145C00321    M55145C00323    M55145C00324    M55147C00011    M55147C00013    M55147C00014
    ...    M55147C00030    M55147C00032    M55147C00033    M55145C00341    M55125C07501    M55125C07502    M55143C00005    M55125C07503
    ...    M55125C02001    M55145C00351    M55142C00501    M55118C05505    M55118C07004    M55118C09503    M55118C02015    M55118C00001
    ...    M55118C00002    M55118C00003    M55118C10001    M55118C00007    M55118C00008    M55118C06501    M55118C10003    M55119C01501
    ...    M55117C00004
    Set Suite Variable    ${COUNTER_LIST}
    @{DL_NGU_LIST}    Create List    M55327C02001    M55327C02002    M55327C02003    M55327C02004    M55327C02005    M55327C02006
    ...    M55327C02007    M55327C02008    M55327C02009    M55327C02010    M55327C02011    M55327C02012    M55327C02013
    ...    M55327C02014    M55327C02015    M55327C02016    M55327C02017    M55327C02018    M55327C02019    M55327C02020
    Set Suite Variable    ${DL_NGU_LIST}
    @{UL_NGU_LIST}    Create List    M55327C04001    M55327C04002    M55327C04003    M55327C04004    M55327C04005    M55327C04006
    ...    M55327C04007    M55327C04008    M55327C04009    M55327C04010    M55327C04011    M55327C04012    M55327C04013
    ...    M55327C04014    M55327C04015    M55327C04016    M55327C04017    M55327C04018    M55327C04019    M55327C04020
    Set Suite Variable    ${UL_NGU_LIST}
    @{PDCP_DL_LIST}    Create List    M55319C12001    M55319C12002    M55319C12003    M55319C12004    M55319C12005    M55319C12006
    ...    M55319C12007    M55319C12008    M55319C12009    M55319C12010    M55319C12011    M55319C12012    M55319C12013
    ...    M55319C12014    M55319C12015    M55319C12016    M55319C12017    M55319C12018    M55319C12019    M55319C12020
    Set Suite Variable    ${PDCP_DL_LIST}
    @{PDCP_UL_LIST}    Create List    M55319C16001    M55319C16002    M55319C16003    M55319C16004    M55319C16005
    ...    M55319C16006    M55319C16007    M55319C16008    M55319C16009    M55319C16010    M55319C16011    M55319C16012
    ...    M55319C16013    M55319C16014    M55319C16015    M55319C16016    M55319C16017    M55319C16018    M55319C16019
    ...    M55319C16020
    Set Suite Variable    ${PDCP_UL_LIST}
    Traffic Duration Set
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0    NG-U_DL(Mbps)=0    NG-U_UL(Mbps)=0    PDCP_DL(Mbps)=0
    ...    PDCP_UL(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${ORAN_VTM_MVP}
    Fetch Dictionary items    ${MAIL_DATA}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list}=    Create List    1    72
    Set Suite Variable    ${seq_list}
    @{seq_stat_list}=    Create List    0.3    0.11    1    5
    Set Suite Variable    ${seq_stat_list}
    ${sansa_lua_delays}=    Create List
    Set Suite Variable    @{sansa_lua_delays}
    Append To List    ${sansa_lua_delays}    ${TAU_DELAY}    ${UE_STATE_DELAY}    ${PAGING_DELAY}
    ${TIMER_DATA}=    Create Dictionary    TIMER1=0    TIMER2=0    TIMER3=0    TIMER4=0    TIMER5=0    TIMER6=0    TIMER7=0
    Set Suite Variable    &{TIMER_DATA}
    Fetch Dictionary items    ${TIMER_DATA}
    ${timer_key_list}=    Get Dictionary Keys    ${TIMER_DATA}    sort_keys=False
    Set Suite Variable    @{timer_key_list}
    Common Register and Traffic    ${ORAN_VTM_MVP}    VTM_MVP_TDD
    Set Suite Variable    ${COUNTER_LIST}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${vtm_data_list}=    Create List
    Set Suite Variable    @{vtm_data_list}
    ${expected_values}=    Create List    ${expected_rate}    ${NG_DL}    ${NG_UL}    ${PDCP_DL}    ${PDCP_UL}
    Set Suite Variable    @{expected_values}
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Sleep    ${COUNTER_DURATION}m
        Set Suite Variable    ${trf_loop}
        ${active_ues}    Active UE Count Status Check
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${RATE1}    Fetch Sum of Counter lists for Multiple Counters    ${COUNTER_LIST}
        ${RATE2}    Fetch Sum of Counter lists for Multiple Counters    ${DL_NGU_LIST}
        ${RATE3}    Fetch Sum of Counter lists for Multiple Counters    ${UL_NGU_LIST}
        ${RATE4}    Fetch Sum of Counter lists for Multiple Counters    ${PDCP_DL_LIST}
        ${RATE5}    Fetch Sum of Counter lists for Multiple Counters    ${PDCP_UL_LIST}
        ${RATE6}    Counter Fetch    M55319C00001
        Append To Kpi list    ${kpi_list}    ${RATE1}
        Calculate KPI of NG    ${RATE2}    ${RATE3}
        Calculate KPI of PDCP    ${RATE2}    ${RATE3}
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Run Keywords
    ...    Validate Kpi and update testproperties MVP    VTM_MVP_TDD    ${MAIL_DATA}    AND
    ...    Deregister and Append Data    VTM_MVP_TDD

ORAN FDD VTM MVP 4DL4UL Non DSS 18Cells CA scell addition-deletion UE-state-transition attach-detach Paging Mixed HO VoNR RNA TAU additional DRB
    [Tags]    FULLRUN     [flow]L3 Call    MVP_VTM_FDD
    @{COUNTER_LIST}=    Create List    M55112C00002    M55112C00010    M55112C00007    M55112C00005    M55120C00001    M55120C00501
    ...    M55120C00004    M55151C00001    M55151C00002    M55151C00005    M55151C00007    M55151C00008    M55112C02501    M55118C02000
    ...    M55118C02001    M55118C02002    M55118C02003    M55118C02004    M55118C02005    M55118C02006    M55118C02007    M55118C02008
    ...    M55118C02009    M55118C02010    M55118C02011    M55118C02012    M55118C02013    M55118C06503    M55124C01001    M55124C01002
    ...    M55124C01003    M55124C01004    M55124C01005    M55124C01006    M55124C01014    M55124C01015    M55124C01016    M55124C01017
    ...    M55124C00008    M55124C00007    M55124C00001    M55125C00014    M55125C00016    M55125C00018    M55125C02504    M55145C00301
    ...    M55145C00303    M55145C00304    M55145C00321    M55145C00323    M55145C00324    M55147C00011    M55147C00013    M55147C00014
    ...    M55147C00030    M55147C00032    M55147C00033    M55145C00341    M55125C07501    M55125C07502    M55143C00005    M55125C07503
    ...    M55125C02001    M55145C00351    M55142C00501    M55118C05505    M55118C07004    M55118C09503    M55118C02015    M55118C00001
    ...    M55118C00002    M55118C00003    M55118C10001    M55118C00007    M55118C00008    M55118C06501    M55118C10003    M55119C01501
    ...    M55117C00004
    Set Suite Variable    ${COUNTER_LIST}
    @{DL_NGU_LIST}    Create List    M55327C02001    M55327C02002    M55327C02003    M55327C02004    M55327C02005    M55327C02006
    ...    M55327C02007    M55327C02008    M55327C02009    M55327C02010    M55327C02011    M55327C02012    M55327C02013
    ...    M55327C02014    M55327C02015    M55327C02016    M55327C02017    M55327C02018    M55327C02019    M55327C02020
    Set Suite Variable    ${DL_NGU_LIST}
    @{UL_NGU_LIST}    Create List    M55327C04001    M55327C04002    M55327C04003    M55327C04004    M55327C04005    M55327C04006
    ...    M55327C04007    M55327C04008    M55327C04009    M55327C04010    M55327C04011    M55327C04012    M55327C04013
    ...    M55327C04014    M55327C04015    M55327C04016    M55327C04017    M55327C04018    M55327C04019    M55327C04020
    Set Suite Variable    ${UL_NGU_LIST}
    @{PDCP_DL_LIST}    Create List    M55319C12001    M55319C12002    M55319C12003    M55319C12004    M55319C12005    M55319C12006
    ...    M55319C12007    M55319C12008    M55319C12009    M55319C12010    M55319C12011    M55319C12012    M55319C12013
    ...    M55319C12014    M55319C12015    M55319C12016    M55319C12017    M55319C12018    M55319C12019    M55319C12020
    Set Suite Variable    ${PDCP_DL_LIST}
    @{PDCP_UL_LIST}    Create List    M55319C16001    M55319C16002    M55319C16003    M55319C16004    M55319C16005
    ...    M55319C16006    M55319C16007    M55319C16008    M55319C16009    M55319C16010    M55319C16011    M55319C16012
    ...    M55319C16013    M55319C16014    M55319C16015    M55319C16016    M55319C16017    M55319C16018    M55319C16019
    ...    M55319C16020
    Set Suite Variable    ${PDCP_UL_LIST}
    Traffic Duration Set
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0    NG-U_DL(Mbps)=0    NG-U_UL(Mbps)=0    PDCP_DL(Mbps)=0
    ...    PDCP_UL(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FDD_VTM_MVP}
    Fetch Dictionary items    ${MAIL_DATA}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    @{seq_list}=    Create List    1    216
    Set Suite Variable    ${seq_list}
    @{seq_stat_list}=    Create List    0.3    0.11    1    5
    Set Suite Variable    ${seq_stat_list}
    ${sansa_lua_delays}=    Create List
    Set Suite Variable    @{sansa_lua_delays}
    Append To List    ${sansa_lua_delays}    ${TAU_DELAY}    ${UE_STATE_DELAY}    ${PAGING_DELAY}
    ${TIMER_DATA}=    Create Dictionary    TIMER1=0    TIMER2=0    TIMER3=0    TIMER4=0    TIMER5=0    TIMER6=0    TIMER7=0
    Set Suite Variable    &{TIMER_DATA}
    Fetch Dictionary items    ${TIMER_DATA}
    ${timer_key_list}=    Get Dictionary Keys    ${TIMER_DATA}    sort_keys=False
    Set Suite Variable    @{timer_key_list}
    Common Register and Traffic    ${FDD_VTM_MVP}    MVP_VTM_FDD
    Set Suite Variable    ${COUNTER_LIST}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    ${expected_values}=    Create List    ${expected_rate}    ${NG_DL}    ${NG_UL}    ${PDCP_DL}    ${PDCP_UL}
    Set Suite Variable    @{expected_values}
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Sleep    ${COUNTER_DURATION}m
        Set Suite Variable    ${trf_loop}
        ${active_ues}    Active UE Count Status Check
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${RATE1}    Fetch Sum of Counter lists for Multiple Counters    ${COUNTER_LIST}
        ${RATE2}    Fetch Sum of Counter lists for Multiple Counters    ${DL_NGU_LIST}
        ${RATE3}    Fetch Sum of Counter lists for Multiple Counters    ${UL_NGU_LIST}
        ${RATE4}    Fetch Sum of Counter lists for Multiple Counters    ${PDCP_DL_LIST}
        ${RATE5}    Fetch Sum of Counter lists for Multiple Counters    ${PDCP_UL_LIST}
        ${RATE6}    Counter Fetch    M55319C00001
        Append To Kpi list    ${kpi_list}    ${RATE1}
        Calculate KPI of NG    ${RATE2}    ${RATE3}
        Calculate KPI of PDCP    ${RATE2}    ${RATE3}
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Run Keywords
    ...    Validate Kpi and update testproperties MVP    MVP_VTM_FDD    ${MAIL_DATA}    AND
    ...    Deregister and Append Data    MVP_VTM_FDD

CNI 112583 PET ABIP 1070FF 6Cell SRSBF 8x4MIMO 16DL8UL MUMIMO Cell lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    CELL_LOCK_UNLOCK
    Fetch Dictionary items    ${LOCK_UNLOCK}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${LOCK_UNLOCK}    CELL_LOCK_UNLOCK
    [Teardown]    Unlock cells And Append Data    CELL_LOCK_UNLOCK

1070FF TDD FR1 6S 1CC 1350UEs Per cell DL RAN PAGING for Mobile Termination MT
    [Tags]    FULLRUN    [flow]L3 Call    DL_MT_RAN_PAGING
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${DL_MT_RAN_PAGING}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    13    18
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${DL_MT_RAN_PAGING}    DL_MT_RAN_PAGING
    Traffic Loop With Tput Validation    ${DIR}    DL_MT_RAN_PAGING    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    2AP_1500UES_RRC

1070FF TDD FR1 6S 1CC 1350UEs Per cell UL DATA PAGING for Mobile Originated MO
    [Tags]    FULLRUN    [flow]L3 Call    UL_MO_DATA_PAGING
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${UL_MO_DATA_PAGING}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    19    24
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${UL_MO_DATA_PAGING}    UL_MO_DATA_PAGING
    Traffic Loop With Tput Validation    ${DIR}    UL_MO_DATA_PAGING    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    UL_MO_DATA_PAGING

3Cells 16DL8UL CA 2CC DL UL 72UEs
    [Tags]    FULLRUN    [flow]L3 Call    16DL8UL_72UES
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55326C00502    M55140C00005    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    UL_RATE(Mbps)=0    MAX_NUM_OF_DRB=0
    ...    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${16DL8UL_72UES}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${OVERALL_UL}    ${EXPECTED_MaxDRB}
    ...    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    2
    @{seq_list2}=    Create List    6    6
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${16DL8UL_72UES}    16DL8UL_72UES
    Traffic Loop With Tput Validation    ${DIR}    16DL8UL_72UES    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    16DL8UL_72UES    ${pre_data_dictionary}

1208FF 3Cell SRSBF 8x4MIMO 16DL8UL MUMIMO SA DL 4UEs 18Gbps
    [Tags]    FULLRUN    [flow]L3 Call    16DL8UL_DL_18Gbps
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00005    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    MAX_NUM_OF_DRB=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${16DL8UL_18GBPS_DL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_MaxDRB}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    3
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${16DL8UL_18GBPS_DL}    16DL8UL_DL_18Gbps
    Traffic Loop With Tput Validation    ${DIR}    16DL8UL_DL_18Gbps    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    16DL8UL_DL_18Gbps    ${pre_data_dictionary}

1070FF 3Cell SRSBF 8x4MIMO_16DL8UL_MUMIMO_SA_UL_2UEs_2Gbps
    [Tags]    FULLRUN    [flow]L3 Call    16DL8UL_UL_2Gbps
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00005    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    MAX_NUM_OF_DRB=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${16DL8UL_2GBPS_UL}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_MaxDRB}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    1    3
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${16DL8UL_2GBPS_UL}    16DL8UL_UL_2Gbps
    Traffic Loop With Tput Validation    ${DIR}    16DL8UL_UL_2Gbps    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Deregister and Append Data    16DL8UL_UL_2Gbps    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA 9000 RRC Connected UEs with DLUL Ping traffic 375UEs per cell
    [Tags]    FULLRUN     [flow]L3 Call    NONDSS4DL4UL
    [Documentation]    FDD PET scenario for 9000 UE
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSS4DL4UL    &{FDD_NONDSS4DL4UL}
    [Teardown]    Deregister and Append Data    NONDSS4DL4UL    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA 864UE Peak DL2497Mbps traffic on L1Pool 12Cells
    [Tags]    FULLRUN     [flow]L3 Call    NONDSS72UELOKIAB_DL
    [Documentation]    FDD PET scenario for 864UE with DL 2497Mbps
    ...                Modified Date: 25-june-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    NONDSS72UELOKIAB_DL    &{NONDSS_LOKIAB_72UE_DL}
    [Teardown]    Deregister and Append Data    NONDSS72UELOKIAB_DL    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA 864UE Peak UL997Mbps traffic on L1Pool 12Cells
    [Tags]    FULLRUN     [flow]L3 Call    NONDSS72UELOKIAB_UL
    [Documentation]    FDD PET scenario for 864UE with UL 997Mbps
    ...                Modified Date: 25-june-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    NONDSS72UELOKIAB_UL    &{NONDSS_LOKIAB_72UE_UL}
    [Teardown]    Deregister and Append Data    NONDSS72UELOKIAB_UL    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA 48UE Peak DL 5010Mbps UL 1970Mbps traffic 2UEs per cell Full ABIO
    [Tags]    FULLRUN    [flow]L3 Call    NONDSSMUE_FullABIO
    [Documentation]    FDD PET scenario for 48UE with DL 5010Mbps and UL 1970Mbps
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSSMUE_FullABIO    &{NONDSS_FDD_MUE_FullABIO}
    [Teardown]    Deregister and Append Data    NONDSSMUE_FullABIO    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA 24UE Peak DL 5010Mbps traffic SUE per cell
    [Tags]    FULLRUN     [flow]L3 Call    NONDSSDL_24SUE
    [Documentation]    FDD PET scenario for 24UE with DL 5010Mbps
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSSDL_24SUE    &{NONDSS_FDD_24SUE}
    [Teardown]    Deregister and Append Data    NONDSSDL_24SUE    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA 24UE Peak UL 1970Mbps traffic SUE per cell
    [Tags]    FULLRUN     [flow]L3 Call    NONDSSUL_24SUE
    [Documentation]    FDD PET scenario for 24UE with UL 1970Mbps
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSSUL_24SUE    &{NONDSS_FDD_4UL_24SUE}
    [Teardown]    Deregister and Append Data    NONDSSUL_24SUE    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA VoNR 2880UEs with DLUL Ping traffic 120UEs per cell
    [Tags]    FULLRUN     [flow]L3 Call    NONDSS_VoNR
    [Documentation]    FDD PET scenario for VoNR 2400UE
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSS_VoNR    &{FDD_24CELL_VoNR}
    [Teardown]    Deregister and Append Data    NONDSS_VoNR    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA GBR NonGBR Mix 50UE per cell Peak DL 569Mbps traffic on LokiA 3Cells & LokiB 3Cells
    [Tags]    FULLRUN    [flow]L3 Call    NONDSS_DL_GBR_NonGBR    PET_FDD
    [Documentation]    FDD PET scenario for 300UE with DL 569Mbps
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSS_DL_GBR_NonGBR    &{NONDSS_GBR_NonGBR_DL}
    [Teardown]    Deregister and Append Data    NONDSS_DL_GBR_NonGBR    ${pre_data_dictionary}

NonDSS 4DL4UL 24CELL SA GBR NonGBR Mix 50UE per cell Peak UL 569Mbps traffic on LokiA 3Cells & LokiB 3Cells
    [Tags]    FULLRUN    [flow]L3 Call    NONDSS_UL_GBR_NonGBR    PET_FDD
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 26-March-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    NONDSS_UL_GBR_NonGBR    &{NONDSS_GBR_NonGBR_UL}
    [Teardown]    Deregister and Append Data    NONDSS_UL_GBR_NonGBR    ${pre_data_dictionary}

ORAN TDD 100MHz FR1 SA 1208FF 4DL4UL SUMIMO NBF RU lock and unlock
    [Tags]    FULLRUN    [flow]L3 Call    TDD_RU_LOCK_UNLOCK    AP_REG
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1    RU_2=2    RU_3=3    RU_4=4    RU_5=5    RU_6=6
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_TDD_LOCK_UNLOCK}
    RUs Status List Creation and Perfom Lock Unlock of RUs    ${RU_TDD_LOCK_UNLOCK}    TDD_RU_LOCK_UNLOCK
    [Teardown]    Unlock RUs And Append Data    TDD_RU_LOCK_UNLOCK

ORAN TDD 100MHz FR1 SA 1208FF 4DL4UL SUMIMO NBF Cell lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    TDD_CELL_LOCK_UNLOCK    AP_REG
    Fetch Dictionary items    ${CELL_TDD_LOCK_UNLOCK}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${CELL_TDD_LOCK_UNLOCK}
    ...    TDD_CELL_LOCK_UNLOCK
    [Teardown]    Unlock cells And Append Data    TDD_CELL_LOCK_UNLOCK

ORAN FDD NonDSS 20MHz 4DL4UL 18Cells 836FF SA Cell lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    FDD_CELL_LOCK_UNLOCK    AP_REG
    Fetch Dictionary items    ${CELL_FDD_LOCK_UNLOCK}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${CELL_FDD_LOCK_UNLOCK}
    ...    FDD_CELL_LOCK_UNLOCK
    [Teardown]    Unlock cells And Append Data    FDD_CELL_LOCK_UNLOCK

ORAN FDD NonDSS 20MHz 4DL4UL 18Cells 836FF SA RU lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    FDD_RU_LOCK_UNLOCK    AP_REG
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1,2,3    RU_2=4,5,6    RU_3=7,8,9    RU_4=10,11,12
    ...    RU_5=13,14,15    RU_6=16,17,18
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_FDD_LOCK_UNLOCK}
    ${LOOP_TIMES}=    Get Variable Value    ${RU_LOCK_UNLOCK}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    RUs Status List Creation and Perfom Lock Unlock of RUs    ${RU_FDD_LOCK_UNLOCK}    FDD_RU_LOCK_UNLOCK
    [Teardown]    Unlock RUs And Append Data    FDD_RU_LOCK_UNLOCK

CNI113765 Non DSS 20MHz 4x4MIMO 12CELL 4500UE DL 3065Mbps 375UE per CELL 40UEtrf
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_FR1_FDD_TC1
    [Documentation]    FR1 CNI113765 FDD PET scenario for 375UE with UL 3065Mbps
    ...                Modified Date: 14-April-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    CNI113765_FR1_FDD_TC1    &{FR1_FDD_CNI113765_TC1}
    [Teardown]    Deregister and Append Data    CNI113765_FR1_FDD_TC1    ${pre_data_dictionary}

CNI113765 Non DSS 20MHz 4x4MIMO 12CELL 4500UE UL 1251Mbps 375UE per CELL 40UEtrf
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_FR1_FDD_TC2
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 14-April-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    CNI113765_FR1_FDD_TC2    &{FR1_FDD_CNI113765_TC2}
    [Teardown]    Deregister and Append Data    CNI113765_FR1_FDD_TC2    ${pre_data_dictionary}

ORAN TDD 50MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 815Mbps UL 113Mbps 72UE 1Cell
    [Tags]    FULLRUN    [flow]L3 Call    72UE_TDD    AP_REG
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    72UE_TDD    &{1208FF_ORAN_DL_UL}
    [Teardown]    Deregister and Append Data    72UE_TDD

ORAN TDD 10MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 128Mbps UL 11Mbps 72UE 1Cell
    [Tags]    FULLRUN    [flow]L3 Call    72UE_SUMIMO    AP_REG
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 07-May-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    72UE_SUMIMO    &{72UE_ORAN_SUMIMO}
    [Teardown]    Deregister and Append Data    72UE_SUMIMO

ORAN FDD NonDSS 10MHz 4DL4UL 18Cells 836FF SA 72UE DL 203Mbps UL 101Mbps
    [Tags]    FULLRUN    [flow]L3 Call    72UE_FDD    AP_REG
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    72UE_FDD    &{72UE_FDD_ORAN}
    [Teardown]    Deregister and Append Data    72UE_FDD

FDD DSS 4DL4UL SA Max RRC Connceted Users with Ping traffic
    [Tags]    FULLRUN    [flow]L3 Call    DSS_MaxRRC
    Initialize Test Data    DSS_MaxRRC    &{DSS_MaxRRC}
    [Teardown]    Deregister and Append Data    DSS_MaxRRC    ${pre_data_dictionary}

FDD DSS 4DL4UL SA Max VoNR Users Per Pool
    [Tags]    FULLRUN    [flow]L3 Call    DSS_MaxVoNR
    Update AP swconfig files    DSS_MaxVoNR
    Initialize Test Data    DSS_MaxVoNR    &{DSS_MaxVoNR}
    [Teardown]    Deregister and Append Data    DSS_MaxVoNR    ${pre_data_dictionary}

FDD DSS 4DL4UL SA Multi UE Peak DL Throughtput Per Pool
    [Tags]    FULLRUN    [flow]L3 Call    DSS_PeakDL
    Update AP swconfig files    DSS_PeakDL
    Initialize Test Data    DSS_PeakDL    &{DSS_PeakDL}
    [Teardown]    Deregister and Append Data    DSS_PeakDL    ${pre_data_dictionary}

FDD DSS 4DL4UL SA Multi UE Peak UL Throughtput Per Pool
    [Tags]    FULLRUN    [flow]L3 Call    DSS_PeakUL
    Initialize Test Data    DSS_PeakUL    &{DSS_PeakUL}
    [Teardown]    Deregister and Append Data    DSS_PeakUL

ORAN FDD NonDSS 50MHz 4DL4UL 1Cell 836FF SA 72UE DL 1015Mbps UL 505Mbps
    [Tags]    FULLRUN    [flow]L3 Call    72UE_FDD_50MHz
    [Documentation]    FDD PET scenario for ORAN FDD NonDSS 50MHz
    ...                Modified Date: 14-May-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    72UE_FDD_50MHz    &{72UE_FDD_50MHz}
    [Teardown]    Deregister and Append Data    72UE_FDD_50MHz

ORAN FDD NonDSS 35MHz 4DL4UL 1Cell 836FF SA 72UE DL 712Mbps UL 354 Mbps
    [Tags]    FULLRUN    [flow]L3 Call    72UE_FDD_35MHz
    [Documentation]    FDD PET scenario for ORAN FDD NonDSS 35MHz
    ...                Modified Date: 14-May-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    72UE_FDD_35MHz    &{72UE_FDD_35MHz}
    [Teardown]    Deregister and Append Data    72UE_FDD_35MHz

CNI113765 Non DSS 40MHz 4x4MIMO 12CELL 4500UE DL 2709Mbps 1cell per LOKI 750UE per CELL
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_FR1_FDD_TC3
    [Documentation]    FDD PET FR1 DL Non DSS
    ...                Modified Date: 14-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    3    6    8    10    12
    Set Suite Variable    ${CELL_INDEX}
    @{INDEX_LIST}=    Create List    3    5    8    10   12    14
    Set Suite Variable    ${INDEX_LIST}
    @{CNI113765_CELL_COUNTERS}=    Create List    M55125C09530    M55138C00033
    Set Suite Variable    ${CNI113765_CELL_COUNTERS}
    Initialize Test Data    CNI113765_FR1_FDD_TC3    &{FR1_FDD_CNI113765_TC3}
    [Teardown]    Deregister and Append Data    CNI113765_FR1_FDD_TC3    ${pre_data_dictionary}

CNI113765 Non DSS 40MHz 4x4MIMO 12CELL 4500UE UL 1359Mbps 1cell per LOKI 750UE per CELL
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_FR1_FDD_TC4
    [Documentation]    FDD PET FR1 UL Non DSS
    ...                Modified Date: 14-May-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    3    6    8    10    12
    Set Suite Variable    ${CELL_INDEX}
    @{INDEX_LIST}=    Create List    3    5    8    10   12    14
    Set Suite Variable    ${INDEX_LIST}
    @{CNI113765_CELL_COUNTERS}=    Create List    M55125C09530    M55138C00033
    Set Suite Variable    ${CNI113765_CELL_COUNTERS}
    Initialize Test Data    CNI113765_FR1_FDD_TC4    &{FR1_FDD_CNI113765_TC4}
    [Teardown]    Deregister and Append Data    CNI113765_FR1_FDD_TC4    ${pre_data_dictionary}

CNI113765 NonDSS 20MHz25MHz 40MHz_4x4MIMO 10Cell 9000UE 1cellperLOKI 3cell DL 949Mbps 3cell UL 462Mbps
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC5
    [Documentation]    FDD PET CNI113765 scenario for 9000UE with UL & DL Tput
    ...                Modified Date: 23-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    CNI113765_TC5    &{TC5_CNI113765}
    [Teardown]    Deregister and Append Data    CNI113765_TC5    ${pre_data_dictionary}

CA CB011080 6CC Pcell 8DL8UL 126UEs_50%PeakTp 110UEs pingtraffic Scell 86UEs_50%PeakTp 1224UEs pingtraffic
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC8
    [Documentation]    FR1 CNI113765 FDD PET scenario for 4500UE  with DL Tput
    ...                Modified Date: 23-May-2025
    ...                Last Modified by: kushal.j@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    CNI113765_TC8    &{TC8_CNI113765}
    [Teardown]    Deregister and Append Data    CNI113765_TC8    ${pre_data_dictionary}

CNI132812 4DSS 4TDD CA 6CC SA Max RRC Connceted CA Users with DL CA thourghput
    [Tags]    FULLRUN    [flow]L3 Call    DSS_2TDD_CA_RRC
    Initialize Test Data    4DSS_2TDD_CA_RRC    &{DSS_CA_RRC}
    [Teardown]    Deregister and Append Data    4DSS_2TDD_CA_RRC

CNI132812 4DSS 2TDD CA 6CC SA DL CA throughput DSS Pcell
    [Tags]    FULLRUN    [flow]L3 Call    DSS_2TDD_CA_TPUT
    Initialize Test Data    DSS_2TDD_CA_TPUT    &{DSS_CA_DL}
    [Teardown]    Deregister and Append Data    DSS_2TDD_CA_TPUT

CB012149 2FDD 3TDD 5CC DL 2CC UL Max CA RRC connected UEs with overall 5499 UEs with 50percent Tput
    [Tags]    FULLRUN    [flow]L3 Call    CB012149_RRC
    [Documentation]    CB012149 2FDD 3TDD 5CC DL 2CC UL Max CA RRC connected
    ...                Modified Date: 04-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CB012149_RRC    &{RRC_CB012149}
    [Teardown]    Deregister and Append Data    CB012149_RRC

TDD FR2 CA 3S 8CC SA 318UE Peak 50per Cell Peak Tput DL 2646Mbps traffic MUE
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_DL
    [Documentation]    FDD PET FR1 UL Non DSS
    ...                Modified Date: 02-June-2025
    ...                Last Modified by: kokila.b@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    @{INDEX_LIST}=    Create List    2    10    18
    Set Suite Variable    ${INDEX_LIST}
    @{CNI113765_CELL_COUNTERS}=    Create List    M55138C00033
    Set Suite Variable    ${CNI113765_CELL_COUNTERS}
    Initialize Test Data    CNI113765_DL    &{FR2_TDD_CNI113765_TC2}
    [Teardown]    Deregister and Append Data    CNI113765_DL    ${pre_data_dictionary}

TDD FR2 CA 3S 8CC SA 318UE Peak 50per Cell Peak Tput UL 848Mbps traffic MUE
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_UL
    [Documentation]    FDD PET FR1 UL Non DSS
    ...                Modified Date: 02-June-2025
    ...                Last Modified by: kokila.b@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    @{INDEX_LIST}=    Create List    2    10    18
    Set Suite Variable    ${INDEX_LIST}
    @{CNI113765_CELL_COUNTERS}=    Create List    M55138C00033
    Set Suite Variable    ${CNI113765_CELL_COUNTERS}
    Initialize Test Data    CNI113765_UL    &{FR2_TDD_CNI113765_TC1}
    [Teardown]    Deregister and Append Data    CNI113765_UL    ${pre_data_dictionary}

TDD NSA 16DL8UL MUMIMO 6Cells BF 1208FF DLpeak tp 6192Mbps 72UEs percell 1cell ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_TC1
    [Documentation]    DROP1 2AP NSA 16DL8UL MUMIMO 6Cells BF 1208FF DLpeak tp 6192Mbps 72UEs percell
    ...                Modified Date: 10-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CNI108638_TC1    &{2AP_CNI108638_TC1}
    [Teardown]    Deregister and Append Data    CNI108638_TC1

TDD NSA 16DL8UL MUMIMO 6Cells BF 8406FF UL peak tp 860Mbps 72UEs percell 1cell ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_TC2
    [Documentation]    DROP1 2AP NSA 16DL8UL MUMIMO 6Cells BF 8406FF UL peak tp 860Mbps 72UEs percell
    ...                Modified Date: 10-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CNI108638_TC2    &{2AP_CNI108638_TC2}
    [Teardown]    Deregister and Append Data    CNI108638_TC2

CNI113765 Non DSS 20MHz 4x4MIMO 24CELL 3000UE DL 1328Mbps 4cell ABIO1 375UE 2cell ABIO3 750UE
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC6
    [Documentation]    CNI113765 Non DSS 20MHz 4x4MIMO 24CELL 3000UE DL 1328Mbps
    ...                Modified Date: 16-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    2    3    4    16    18
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data     CNI113765_TC6    &{CNI113765_TC6}
    [Teardown]    Deregister and Append Data     CNI113765_TC6

CNI113765 Non DSS 20MHz 4x4MIMO 24CELL 3000UE UL 616Mbps 4cell ABIO1 375UE 2cell ABIO3 750UE
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC7
    [Documentation]    CNI113765 Non DSS 20MHz 4x4MIMO 24CELL 3000UE UL 616Mbps
    ...                Modified Date: 16-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    2    3    4    16    18
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    CNI113765_TC7    &{CNI113765_TC7}
    [Teardown]    Deregister and Append Data    CNI113765_TC7

Inter gNB FR1 FR2 NRDC 106UE Max RRC testcase
    [Tags]    FULLRUN    [flow]L3 Call    CB008490_NRDC
    [Documentation]    FR1 FR2 Inter gNB scenario
    ...                Modified Date: 19-June-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    CB008490_NRDC    &{CB008490_NRDC_RRC}
    [Teardown]    Deregister and Append Data    CB008490_NRDC

CB008701FF 1116 0msFF 1Cell SRSBF 8x4MIMO 16DL8UL MUMIMO SA DL 72UEs 6200Mpbs MixTRF UDP TCP
    [Tags]    FULLRUN    [flow]L3 Call    CB008701FF_16UE_DL
    [Documentation]    TCP TC DL with MIxed Traffic TCP + UDP
    ...                Modified Date: 30-June-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    CB008701FF_16UE_DL    &{CB008701FF_16UE_DL}
    [Teardown]    Deregister and Append Data    CB008701FF_16UE_DL    ${pre_data_dictionary}

CNI-132812_FDD_DSS_24CELL_traffic_model_test_with_300_events
    [Tags]    FULLRUN     [flow]L3 Call    FDD_DSS_VTM
    [Documentation]    CNI-132812_FDD_DSS_24CELL_traffic_model
    ...                Modified Date: 19-May-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Traffic Duration Set
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0    PDCP_SDU_DL(Mbps)=0    PDCP_SDU_UL(Mbps)=0    DL_BLER(%)=0    UL_BLER(%)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${FDD_DSS_VTM}
    Fetch Dictionary items    ${MAIL_DATA}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    Set Suite Variable    @{keys_list}
    @{seq_list}=    Create List    1    216
    Set Suite Variable    ${seq_list}
    Common Register and Traffic    ${FDD_DSS_VTM}    FDD_DSS_VTM
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    ${expected_values}=    Create List    ${expected_rate}    ${OVERALL_PDCP_DL}    ${OVERALL_PDCP_UL}    ${OVERALL_DL_BLER}    ${OVERALL_UL_BLER}
    Set Suite Variable    @{expected_values}
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Sleep    ${COUNTER_DURATION}m
        Set Suite Variable    ${trf_loop}
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${last_loop}=    Evaluate    ((${TRF_DURATION}-${COUNTER_DURATION})+1)
        ${trf_loop_int}=    Convert To Integer    ${trf_loop}
        Run Keyword If    ${trf_loop_int} > 1 and ${trf_loop_int} < ${last_loop}
        ...    Validate KPI Values FOR DSS VTM
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Update testproperties VTM    FDD_DSS_VTM    ${MAIL_DATA}

TDD NSA FR2 CA 16DL8UL 3S 8CC 3UE percell DL 4372Mbps Percell Total 13116Mbps
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_9UEs_13Gbps
    [Documentation]    TDD NSA FR2 CA 16DL8UL 3S 8CC 3UE percell DL 4372Mbps
    ...                Modified Date: 27-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data        3S_8CC_9UEs_13Gbps    &{3S_8CC_9UEs_13Gbps}
    [Teardown]    Deregister and Append Data    3S_8CC_9UEs_13Gbps

TDD NSA 16DL8UL 6Cells BF 1116 0ms Total DLpeak tp 10464Mbps perBBUcard 2UEs percell ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_DROP2_TC1
    [Documentation]    TDD NSA 16DL8UL 6Cells BF 1116 0ms Total DLpeak tp 10464Mbps
    ...                Modified Date: 01-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CNI108638_DROP2_TC1    &{CNI108638_DROP2_TC1}
    [Teardown]    Deregister and Append Data    CNI108638_DROP2_TC1

TDD NSA 16DL8UL 6Cells BF 1070FF Total ULpeak tp 1992Mbps perBBUcard 2UEs percell ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_DROP2_TC2
    [Documentation]    TDD NSA 16DL8UL 6Cells BF 1070FF Total ULpeak tp 1992Mbps
    ...                Modified Date: 01-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CNI108638_DROP2_TC2    &{CNI108638_DROP2_TC2}
    [Teardown]    Deregister and Append Data    CNI108638_DROP2_TC2

TDD NSA FR2 CA 16DL8UL 3S_8CC 3UE percell UL 572Mbps Percell total 1716Mbps
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_9UEs_1716Mbps
    [Documentation]    TDD NSA FR2 CA 16DL8UL 3S_8CC 3UE percell UL 572Mbps
    ...                Modified Date: 27-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data        3S_8CC_9UEs_1716Mbps    &{3S_8CC_9UEs_1716Mbps}
    [Teardown]    Deregister and Append Data    3S_8CC_9UEs_1716Mbps

TDD ORAN 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF 6144UEs DLUL Ping traffic 6CELL
    [Tags]    FULLRUN    [flow]L3 Call    6144UE_MAXRRC
    [Documentation]    ORAN TDD 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO
    ...                Modified Date: 14-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    6144UE_MAXRRC    &{6144UE_MAXRRC}
    [Teardown]    Deregister and Append Data    6144UE_MAXRRC

TDD NSA FR2 CA 8DL4UL 6S 4CC 2UE percell DL 4372Mbps Percell Total 13116Mbps
    [Tags]    FULLRUN    [flow]L3 Call    6S_4CC_12UEs_13Gbps
    [Documentation]    TDD NSA FR2 CA 8DL4UL 6S 4CC 2UE percell DL 4372Mbps
    ...                Modified Date: 08-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data        6S_4CC_12UEs_13Gbps    &{6S_4CC_12UEs_13Gbps}
    [Teardown]    Deregister and Append Data    6S_4CC_12UEs_13Gbps

TDD NSA FR2 CA 8DL4UL 6S 4CC 2UE percell UL 572Mbps Percell total UL Peak 1716Mbps
    [Tags]    FULLRUN    [flow]L3 Call    6S_4CC_12UEs_1716Mbps
    [Documentation]    TDD NSA FR2 CA 8DL4UL 6S 4CC 2UE percell DL 4372Mbps
    ...                Modified Date: 08-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data        6S_4CC_12UEs_1716Mbps    &{6S_4CC_12UEs_1716Mbps}
    [Teardown]    Deregister and Append Data    6S_4CC_12UEs_1716Mbps

Inter-gNB_1CCFR1-8CCFR2_NRDC_72UE_Downlink_8DL8UL_BF
    [Tags]    FULLRUN    [flow]L3 Call    2gNB_FR1_FR2_DL
    [Documentation]    2 real gNBs case. FR1 gNB1 to test signaling and FR2 gNB to test DL tput
    ...                Modified Date: 06-June-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    2gNB_FR1_FR2_DL    &{CB008490_DL}
    [Teardown]    Deregister and Append Data    2gNB_FR1_FR2_DL

Inter-gNB_1CCFR1-1CCFR2_NRDC_72UE_UPlink_8DL8UL_BF
    [Tags]    FULLRUN    [flow]L3 Call    2gNB_FR1_FR2_UL
    [Documentation]    2 real gNBs case. FR1 gNB1 to test signaling and FR2 gNB to test ULtput
    ...                Modified Date: 06-June-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    2gNB_FR1_FR2_UL    &{CB008490_UL}
    [Teardown]    Deregister and Append Data    2gNB_FR1_FR2_UL

6CC_3x100Mhz_3x20Mhz_3T_3F_MUMIMO_SRS_Based_BF_DLCA_1208FF_SA_72CAUEsonPcellTDD_32NonCAUes_on_Scell_10600 Mbps DL
    [Tags]    FULLRUN    [flow]L3 Call    DL_MUMIMOECPRI72E
    [Documentation]    DL CA case for 7.2eCPRI feature with pairing ratio and cell-wise tput calculation
    ...                Modified Date: 15-June-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    ${expression}=    Set Variable    '(a * b)'
    Set Suite Variable    ${expression}
    Initialize Test Data    DL_MUMIMOECPRI72E    &{3T_3F_DL_MUMIMO}
    [Teardown]    Deregister and Append Data    DL_MUMIMOECPRI72E

6CC_3x100Mhz_3x20Mhz_3F_3T_MUMIMO_SRS_Based_BF_DLCA_1208FF_SA_72CAUEsonPcellTDD_32NonCAUes_on_Scell_5895MbpsDL
    [Tags]    FULLRUN    [flow]L3 Call    ECPRI72E_DL
    [Documentation]    DL CA case for 7.2eCPRI feature
    ...                Modified Date: 15-June-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    ECPRI72E_DL    &{3F_3T_DL}
    [Teardown]    Deregister and Append Data    ECPRI72E_DL

CB014465_W_PET_Dual_Boost_1116_0msFF_2Cell_SRSBF_8x4MIMO_16DL4UL_MUMIMO_SA_UL_CA_T_F_72UEs_560_Mbps
    [Tags]    FULLRUN    [flow]L3 Call    ECPRI72E_UL
    [Documentation]    UL CA case for 7.2eCPRI feature
    ...                Modified Date: 15-June-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    ECPRI72E_UL    &{3F_3T_UL_CA}
    [Teardown]    Deregister and Append Data    ECPRI72E_UL

ORAN FDD ABIP NonDSS 20MHz 4DL4UL 18Cells 836FF SA 4500UEs DL UL Ping traffic on L1 POOL
    [Tags]    FULLRUN    [flow]L3 Call    4500UE_18CELL_FDD
    [Documentation]    ORAN FDD ABIP NonDSS 20MHz 4DL4UL 18Cells
    ...                Modified Date: 30-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    4500UE_18CELL_FDD    &{ORAN_836FF_18CELL_FDD}
    [Teardown]    Deregister and Append Data    4500UE_18CELL_FDD    ${pre_data_dictionary}

ORAN FDD ABIP NonDSS 20MHz 4DL4UL 18Cells 836FF SA 1500UEs DL UL 50 percent cell traffic in Single CELL
    [Tags]    FULLRUN    [flow]L3 Call    1500UE_18CELL_FDD
    [Documentation]    ORAN FDD ABIP NonDSS 20MHz 4DL4UL 18Cells
    ...                Modified Date: 30-July-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    1500UE_18CELL_FDD    &{1500UE_836FF_18CELL_FDD}
    [Teardown]    Deregister and Append Data    1500UE_18CELL_FDD    ${pre_data_dictionary}

ORAN TDD ABIP 100MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF 1500UEs DLUL Ping traffic 1CELL
    [Tags]    FULLRUN    [flow]L3 Call    RRC_1500UE_TDD
    [Documentation]    ORAN TDD ABIP 100MHz FR1 SA MUE 1208FF 4DL4UL
    ...                Modified Date: 31-June-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    RRC_1500UE_TDD    &{ORAN_RRC_1500_1CELL_TDD}
    [Teardown]    Deregister and Append Data    RRC_1500UE    ${pre_data_dictionary}

TDD_TCP_FR2_CA_3S_8CC_SA_159UE_Peak_Tput_DL_5184Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    TCP_3S_8CC_DL
    [Documentation]    TCP DL for 3S_8CC
    ...                Modified Date: 30-July-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    TCP_3S_8CC_DL    &{TCP_3S_8CC_DL}
    [Teardown]    Deregister and Append Data    TCP_3S_8CC_DL

TDD_TCP_FR2_CA_3S_8CC_SA_159UE_Peak_Tput_UL_1713Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    TCP_3S_8CC_UL
    [Documentation]    TCP UL for 3S_8CC
    ...                Modified Date: 30-July-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    TCP_3S_8CC_UL    &{TCP_3S_8CC_UL}
    [Teardown]    Deregister and Append Data    TCP_3S_8CC_UL

TDD_TCP_FR2_CA_1S_8CC_SA_4UE_Peak_Tput_DL_4220Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    TCP_1S_8CC_DL
    [Documentation]    TCP DL for 1S_8CC
    ...                Modified Date: 30-July-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    TCP_1S_8CC_DL    &{TCP_1S_8CC_DL}
    [Teardown]    Deregister and Append Data    TCP_1S_8CC_DL

TDD NSA FR2 CA 16DL8UL 3S_8CC 106UE percell DL 1800MbpsPercell Total 5400Mbps
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_318UEs_5400Mbps
    [Documentation]    NSA TDD 3S_8CC 5400 Mbps DL
    ...                Modified Date: 24-July-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data        3S_8CC_318UEs_5400Mbps    &{3S_8CC_318UEs_5400Mbps}
    [Teardown]    Deregister and Append Data    3S_8CC_318UEs_5400Mbps

TDD NSA 4DL4UL 12Cells BF 1208FF DL peak tp 1539Mbps 72UEs percell 1cell ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_TC3
    [Documentation]    TDD_NSA_4DL4UL_12Cells_BF_1208FF_DLpeak_tp_1539Mbps_72UEs_percell_1cell_ABIP
    ...                Modified Date: 12-Auguest-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CNI108638_TC3    &{CNI108638_TC3}
    [Teardown]    Deregister and Append Data    CNI108638_TC3

TDD NSA 4DL4UL 12Cells BF 1208FF UL peak tp 234Mbps 72UEs 1cell ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_TC4
    [Documentation]    TDD_NSA_4DL4UL_12Cells_BF_1208FF_ULpeak_tp_234Mbps_72UEs_1cell_ABIP
    ...                Modified Date: 12-August-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CNI108638_TC4    &{CNI108638_TC4}
    [Teardown]    Deregister and Append Data    CNI108638_TC4

TDD NSA FR2 CA 16DL8UL 3S_8CC 3UE_percell UL 571MbpsPercell total 1713Mbps
    [Tags]    FULLRUN    [flow]L3 Call    3S_8CC_318UEs_1713Mbps
    [Documentation]    NSA TDD 3S_8CC 1713 Mbps UL
    ...                Modified Date: 24-July-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data        3S_8CC_318UEs_1713Mbps    &{3S_8CC_318UEs_1713Mbps}
    [Teardown]    Deregister and Append Data    3S_8CC_318UEs_1713Mbps

CNI132812_TDD_DSS_UL_2CC_SA_UL_CA_with_3tx_ul_muMIMO_thourghput_499Mbps
    [Tags]    FULLRUN    [flow]L3 Call    TDD_DSS_ULCA
    [Documentation]    CA_with_3tx_ul_muMIMO_thourghput_506Mbps
    ...                Modified Date: 23-Aug-2025
    ...                Last Modified by: kushal.j@nokia.com
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55165C00039    M55181C00013    M55310C03006
    ...    M55310C03006
    Set Suite Variable    ${COUNTER_LIST}
    @{INDEX_LIST}=    Create List    0    0    1    1    1    3
    Set Suite Variable    ${INDEX_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    PDCP_UL_TPUT(Mbps)=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${TDD_DSS_ULCA}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    4    4
    @{seq_list2}=    Create List    5    6
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${TDD_DSS_ULCA}    TDD_DSS_ULCA
    Traffic Loop With Tput Validation    ${DIR}    TDD_DSS_ULCA    ${COUNTER_LIST}    ${MAIL_DATA}    ${INDEX_LIST}
    [Teardown]    Deregister and Append Data    TDD_DSS_ULCA


CNI132812_3TDD_3DSS_DL_6CC_SA_DL_CA_with_dl_muMIMO_thourghput_6870Mbps
    [Tags]    FULLRUN    [flow]L3 Call    DLCA_TDD
    [Documentation]    CA_with_dl_muMIMO_thourghput_6870Mbps
    ...                Modified Date: 22-Aug-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    DLCA_TDD   &{3TDD_3DSS_DLCA}
    [Teardown]    Deregister and Append Data    DLCA_TDD

FDD NonDSS NonCA SA MUE Peak DLalone Tput on L1Pool
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CNI129753_DL
    [Documentation]    FDD NonDSS NonCA SA MUE Peak DLalone Tput on L1Pool
    ...                Modified Date: 28-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CNI129753_DL    &{TCP_CNI129753_DL}
    [Teardown]    Deregister and Append Data    TCP_CNI129753_DL

FDD NonDSS NonCA SA MUE Peak UL alone Tput on L1Pool
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CNI129753_UL
    [Documentation]    FDD_NonDSS_NonCA_SA MUE_Peak_ULalone_Tput_on_L1Pool
    ...                Modified Date: 28-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CNI129753_UL    &{TCP_CNI129753_UL}
    [Teardown]    Deregister and Append Data    TCP_CNI129753_UL

FDD_NonDSS_NonCA_SA MUE_Peak_DLalone_Tput_on_24cells
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CNI129753_DL_TC1
    [Documentation]    FDD_NonDSS_NonCA_SA MUE_Peak_DLalone_Tput_on_24cells
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CNI129753_DL_TC1    &{TCP_CNI129753_DL_TC1}
    [Teardown]    Deregister and Append Data    TCP_CNI129753_DL_TC1

FDD_NonDSS_NonCA_SA MUE_Peak_ULalone_Tput_on_24cells
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CNI129753_UL_TC2
    [Documentation]    FDD_NonDSS_NonCA_SA MUE_Peak_ULalone_Tput_on_24cells
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CNI129753_UL_TC2    &{TCP_CNI129753_UL_TC2}
    [Teardown]    Deregister and Append Data    TCP_CNI129753_UL_TC2

FDD_NonDSS_NonCA_SA_Mix_GBR-_NonGBR_MUE_Peak_ULalone_Tput_on_LokiA_3cells_LokiB_3cells
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CNI129753_UL_TC3
    [Documentation]    FDD_NonDSS_NonCA_SA_Mix_GBR-_NonGBR_MUE_Peak_ULalone
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CNI129753_UL_TC3    &{TCP_CNI129753_UL_TC3}
    [Teardown]    Deregister and Append Data    TCP_CNI129753_UL_TC3

TDD_NSA_8DL8UL_6Cells_BF_1208FF_2UE_percell_DL_peak_tp_perL1Pool_5640Mbps_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    NSA_DL_BF
    [Documentation]    NSA_8DL8UL_6Cells_BF_1208FF_2UE_percell_DL_peak_tp_perL1Pool_5640Mbps_ABIP
    ...                Modified Date: 17-Sep-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_DL_BF    &{NSA_DROP2_BF_DL}
    [Teardown]    Deregister and Append Data    NSA_DL_BF

TDD_NSA_8DL8UL_6Cells_BF_1070FF_2UE_percell_UL_peak_tp_perL1Pool_1105Mbps_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    NSA_UL_BF
    [Documentation]    NSA_8DL8UL_6Cells_BF_1070FF_2UE_percell_UL_peak_tp_perL1Pool_1105Mbps_ABIP
    ...                Modified Date: 17-Sep-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_UL_BF    &{NSA_DROP2_BF_UL}
    [Teardown]    Deregister and Append Data    NSA_UL_BF

PET_UC1_1070FF_6_SSB_8x4MIMO_6CELL_SA_9000UEs_DL_UL_Ping_traffic_2DRBs_PerUE_1500UEs_per_CELL
    [Tags]    FULLRUN    [flow]L3 Call    9000_BF_MP
    [Documentation]    PET_UC1_1070FF_6_SSB_8x4MIMO_6CELL_SA_9000UEs_DL_U
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    9000_BF_MP    &{9000_BF_MP}
    [Teardown]    Deregister and Append Data    9000_BF_MP

1070FF_6_SSB_8x4MIMO_6CELL_SA_VoNR_CDRx_Enabled_2208UEs_DL_26kbps_UL_26kbps_perVoiceBearer_368UEs_per_CELL
    [Tags]    FULLRUN    [flow]L3 Call    1070FF_BF_VoNR_MP
    [Documentation]    1070FF_6_SSB_8x4MIMO_6CELL_SA_VoNR_CDRx_Enabled_2208UEs_DL
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    1070FF_BF_VoNR_MP    &{1070_VoNR_MP}
    [Teardown]    Deregister and Append Data    1070FF_BF_VoNR_MP

CB008406FF_1_SSB_6Cells_4X4_MIMO_SA_432UEs_UL_2.6Gb_Throughput_72UEs_Percell
    [Tags]    FULLRUN    [flow]L3 Call    CB008406FF_432UES_MP
    [Documentation]    CB008406FF_1_SSB_6Cells_4X4_MIMO_SA_432UEs_UL_2.6GbPS
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CB008406FF_432UES_MP    &{CB008406FF_SSB_432UES_MP}
    [Teardown]    Deregister and Append Data    CB008406FF_432UES_MP

CB008360_1070FF_2Cells_144UEs_SRSBF_8x4MIMO_8DL8UL_MUMIMO_SA_UL_1300mbps_72UEs_Percell
    [Tags]    FULLRUN    [flow]L3 Call    CB008360_72UES_MP
    [Documentation]    CB008360_1070FF_2Cells_144UEs_SRSBF_8x4MIMO_8DL8UL
    ...                Modified Date: 29-Aug-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    CB008360_72UES_MP    &{CB008360_UL_72UES_MP}
    [Teardown]    Deregister and Append Data    CB008360_72UES_MP


VTM_Drop2_1070FF_6SSB_8x4MIMO_6Cells_CNInitiated_State_Transition_1200UEs_ping_traffic_200UEs_perCell(paging)
    [Documentation]    VTM 1070FF CNIST 6 SSB 8*4 MIMO 6Cells 1200UEs
    ...    200UEs perCell CNInitiated State Transition 1200UEs ping traffic
    [Tags]    FULLRUN     [flow]L3 Call    VTM_CNIST_1070FF_200UE_MP
    Fetch Dictionary items    ${200UE_1070FF_CNIST_VTM_MP}
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0
    Set Suite Variable    &{MAIL_DATA}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${vtm_data_list}=    Create List
    Set Suite Variable    @{vtm_data_list}
    ${missing_counter}=    Create List
    Set Suite Variable    @{missing_counter}
    Traffic Duration Set
    @{seq_list1}=    Create List    31    36
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${expected_values}=    Create List    ${expected_rate}
    Set Suite Variable    @{expected_values}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Common Register and Traffic    ${200UE_1070FF_CNIST_VTM_MP}    VTM_CNIST_1070FF_200UE_MP
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        ${M55119C01501}    Run Keyword    Counter Fetch    M55119C01501
        ${achieved_rate}=    Evaluate   (sum(${M55119C01501})/((${COUNTER_DURATION})*60))
        Log To Console    Achieved Rate ${achieved_rate}
        Append To Kpi list    ${kpi_list}    ${achieved_rate}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Update testproperties VTM    VTM_CNIST_1070FF_200UE_MP    ${MAIL_DATA}

VTM_Drop2_1070FF_6_SSB_8x4MIMO_6Cells_Mixed_HO_600UEs_ping_traffic_100UEs_perCell
    [Documentation]    VTM_Drop2_1070FF_6_SSB_8*4MIMO_6Cells_Mixed_HO_600UEs
    ...    ping_traffic_100UEs_perCell
    [Tags]    FULLRUN     [flow]L3 Call    VTM_MIXED_HO_MP
    Fetch Dictionary items    ${MIXED_HO_VTM_MP}
    Traffic Duration Set
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0
    Set Suite Variable    &{MAIL_DATA}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${vtm_data_list}=    Create List
    ${expected_values}=    Create List    ${expected_rate}
    Set Suite Variable    @{expected_values}
    Set Suite Variable    @{vtm_data_list}
    ${missing_counter}=    Create List
    Set Suite Variable    @{missing_counter}
    ${kpi_result_list}=    Create List
    Set Suite Variable    @{kpi_result_list}
    @{seq_list1}=    Create List    7    24
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${MIXED_HO_VTM_MP}    VTM_MIXED_HO_MP
    Sleep    ${COUNTER_DURATION}m
    @{COUNTER_LIST}=    Create List    M55145C00351     M55145C00341    M55143C00005    M55145C00321     M55145C00301
    Set Suite Variable    ${COUNTER_LIST}
    @{COUNTER_VALUE}=    Create List
    Set Suite Variable    ${COUNTER_VALUE}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        ${active_ues}    Active UE Count Status Check
        Log To Console    Active UEs:${active_ues[0]}
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${RATE}    Fetch Sum of Counter lists for Multiple Counters
        Log To Console    Achieved Rate ${RATE}
        Append To Kpi list    ${kpi_list}    ${RATE}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Update testproperties VTM    VTM_MIXED_HO_MP    ${MAIL_DATA}

VTM_Drop2A_1070FF_6_SSB_8x4MIMO_6Cells_2CC_1800UEs_CA_scelladdition_deletion_UE_statetransition_300UEs_Percell
    [Documentation]    VTM 1070FF 6SSB 8x4MIMO 6Cells CA 2CC 1800UEs
    ...    Scell Addtion Deletion 200UEs Percell
    [Tags]    FULLRUN     [flow]L3 Call    VTM_SCELL_1800UE_MP
    Fetch Dictionary items    ${1800UE_SCELL_VTM_MP}
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0
    Set Suite Variable    &{MAIL_DATA}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${vtm_data_list}=    Create List
    Set Suite Variable    @{vtm_data_list}
    ${missing_counter}=    Create List
    Set Suite Variable    @{missing_counter}
    ${expected_values}=    Create List    ${expected_rate}
    Set Suite Variable    @{expected_values}
    Traffic Duration Set
    @{seq_list1}=    Create List    25    30
    @{seq_list2}=    Create List    43    48
    @{stat_list}=    Create List    ${seq_list1}    ${seq_list2}
    Set Suite Variable    ${stat_list}
    @{COUNTER_LIST}=    Create List    M55118C05505    M55118C06501    M55124C00001    M55124C01001
    Set Suite Variable    ${COUNTER_LIST}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Common Register and Traffic    ${1800UE_SCELL_VTM_MP}    VTM_SCELL_1800UE_MP
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        ${active_ues}    Active UE Count Status Check
        Log To Console    Active UEs:${active_ues[0]}
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${RATE}    Fetch Sum of Counter lists for Multiple Counters
        Log To Console    Achieved Rate ${RATE}
        Append To Kpi list    ${kpi_list}    ${RATE}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Update testproperties VTM    VTM_SCELL_1800UE_MP    ${MAIL_DATA}

SA_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_DL_40percent_cell_peak_Tput_2DRB_perUE_3cell_MPPP_1CellperABIO
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC2_MPPP
    Initialize Test Data    CNI113765_TC2_MPPP    &{CNI113765_TC2_MPPP}
    [Teardown]    Deregister and Append Data    CNI113765_TC2_MPPP    ${pre_data_dictionary}

SA_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_UL_40percent_cell_peak_Tput_2DRB_perUE_3cell_MPPP_1CellperABIO
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC3_MPPP
    Initialize Test Data    CNI113765_TC3_MPPP    &{CNI113765_TC3_MPPP}
    [Teardown]    Deregister and Append Data    CNI113765_TC3_MPPP    ${pre_data_dictionary}

SA_Max_RRC_Test_8DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_DL_40percent_cell_peak_Tput_2DRB_perUE_6cells_MPPP_1CellperLOKI
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_TC1_MPPP
    Initialize Test Data    CNI113765_TC1_MPPP    &{CNI113765_TC1_MPPP}
    [Teardown]    Deregister and Append Data    CNI113765_TC1_MPPP    ${pre_data_dictionary}

CB007949_1208FF_1SSB_4x4MIMO_CA_3CC_DL_4800mbps_72UEs_Pscell_32UEs_Scell
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CB007949_DL_TC1
    [Documentation]    CB007949_1208FF_1SSB_4x4MIMO_CA_3CC_DL_4800mbps
    ...                Modified Date: 10-sept-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CB007949_DL_TC1    &{TCP_CB007949_DL_TC1}
    [Teardown]    Deregister and Append Data    TCP_CB007949_DL_TC1

CB007112_1070FF_3Cell_SRSBF_8x4MIMO_16DL8UL_MUMIMO_SA_UL_2Gbps_2UEs_PerCell
    [Tags]    FULLRUN    [flow]L3 Call    TCP_CB007112_UL_TC2
    [Documentation]    CB007112_1070FF_3Cell_SRSBF_8x4MIMO_16DL8UL_MUMIMO_SA_UL_2Gbps
    ...                Modified Date: 10-sept-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_CB007112_UL_TC2    &{TCP_CB007112_UL_TC2}
    [Teardown]    Deregister and Append Data    TCP_CB007112_UL_TC2

PET_UC2_1070FF_6_SSB_8x4MIMO_6CELL_SA_48UE_DL_3600Mbps_UL_1900mbps_traffic_8UE_per_CELL
    [Tags]    FULLRUN    [flow]L3 Call    TCP_UC2_DL_UL_TC3
    [Documentation]    PET_UC2_1070FF_6_SSB_8x4MIMO_6CELL_SA_48UE_DL_36mbps_UL_1900mbps
    ...                Modified Date: 10-sept-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    TCP_UC2_DL_UL_TC3    &{TCP_UC2_DL_UL_TC3}
    [Teardown]    Deregister and Append Data    TCP_UC2_DL_UL_TC3

ORAN_FDD_DL_3CC_CA_72UE
    [Tags]    FULLRUN    [flow]L3 Call    FDD_CA_72
    [Documentation]    ORAN_FDD_DL_3CC_CA_72UE
    ...                Modified Date: 23-sept-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    FDD_CA_72    &{FDD_CA_72}
    [Teardown]    Deregister and Append Data    FDD_CA_72

FDD_SA_DL_peak_TP_with_DCM_IOT_Profile_6B_with_6_cell_config
    [Tags]    FULLRUN    [flow]L3 Call    FDD_6DL
    [Documentation]    FDD_SA_DL_peak_TP_with_DCM_IOT_Profile_6B_with_6_cell_config
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    FDD_6DL    &{FDD_6DL}
    [Teardown]    Deregister and Append Data    FDD_6DL

FDD_SA_UL_peak_TP_with_DCM_IOT_Profile_6B_with_6_cell_config
    [Tags]    FULLRUN    [flow]L3 Call    FDD_6UL
    [Documentation]    FDD_SA_UL_peak_TP_with_DCM_IOT_Profile_6B_with_6_cell_config
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    FDD_6UL    &{FDD_6UL}
    [Teardown]    Deregister and Append Data    FDD_6UL

TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_DL_2646Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    DL_3S_8CC
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_DL_2646Mbps_traffic_MUE
    ...                Modified Date: 06-Oct-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    DL_3S_8CC    &{DL_3S_8CC}
    [Teardown]    Deregister and Append Data    DL_3S_8CC

TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_UL_849Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    UL_3S_8CC
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_UL_849Mbps_traffic_MUE
    ...                Modified Date: 06-Oct-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    UL_3S_8CC    &{UL_3S_8CC}
    [Teardown]    Deregister and Append Data    UL_3S_8CC

TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_100%_Cell_Peak_Tput_DL_5184Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    DL_MUE_3S_8CC
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_100%_Cell_Peak_Tput_DL_5184Mbps_traffic_MUE
    ...                Modified Date: 06-Oct-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    DL_MUE_3S_8CC    &{DL_MUE_3S_8CC}
    [Teardown]    Deregister and Append Data    DL_MUE_3S_8CC

TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_100%_Cell_Peak_Tput_UL_1713Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    UL_MUE_3S_8CC
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_UL_1713Mbps_traffic_MUE
    ...                Modified Date: 06-Oct-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    UL_MUE_3S_8CC    &{UL_MUE_3S_8CC}
    [Teardown]    Deregister and Append Data    UL_MUE_3S_8CC

CB009936-W_PET_Dual_Boost_1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_72UEs_1.6_Gbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC1
    [Documentation]    CB009936-W_PET_Dual_Boost_1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_72UEs_1.6_Gbps
    ...                Modified Date: 16-10-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC1    &{TC1_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC1

CB014465-W_PET_Dual_Boost1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_DL_72UEs_5.86_Gbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_MUMIMO_UePercell_TC2
    [Documentation]    CB014465-W_PET_Dual_Boost1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL
    ...    MUMIMO_SA_DL_72UEs_5.86_Gbps
    ...                Modified Date: 16-10-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    Dual_Boost_MUMIMO_UePercell_TC2    &{TC2_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_MUMIMO_UePercell_TC2    ${pre_data_dictionary}

CB013527-W_PET_Dual_Boost_1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_DL_72UEs_5.86Mbps_UL_224Mbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC3
    [Documentation]    CB013527-W_PET_Dual_Boost_1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL
    ...    MUMIMO_SA_DL_72UEs_5.86Mbps_UL_224Mbps
    ...                Modified Date: 16-10-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC3    &{TC3_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC3

CB009843-WB_PET_Dual_Boost_1116_0msFF_6_Cell_L1_pool_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_4UEs_6.5Gbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC4
    [Documentation]    CB009843-WB_PET_Dual_Boost_1116_0msFF_6_Cell_L1_pool_SRSBF_8*4MIMO_16DL4UL
    ...    _SUMIMO_SA_DL_4UEs_6.5Gbps
    ...                Modified Date: 16-10-2025
    ...                Last Modified by: kushal.j@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC4    &{TC4_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC4

CB009843-WB_PET_Dual_Boost_5G001070_FF_1Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_UL_72UEs_320_Mbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC5
    [Documentation]    CB009843-WB_PET_Dual_Boost_5G001070_FF_1Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_UL_72UEs_320_Mbps
    ...                Modified Date: 21-10-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC5    &{TC5_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC5

CB009843-WB_PET_Dual_Boost_5G001070_6Cell_L1_pool_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_UL_4UEs_1.5Gbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC6
    [Documentation]    CB009843-WB_PET_Dual_Boost_5G001070_6Cell_L1_pool_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_UL_4UEs_1.5Gbps
    ...                Modified Date: 21-10-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC6    &{TC6_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC6

CB009843-WB_Dual_Boost_5G001070_FF_12Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_4UEs_2.8Gbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC7
    [Documentation]    CB009843-WB_Dual_Boost_5G001070_FF_12Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_4UEs_2.8Gbps
    ...                Modified Date: 21-10-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC7    &{TC7_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC7

CB009843-WB_Dual_Boost_1116_0msFF_12Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_4UEs_9.6Gbps
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC8
    [Documentation]    CB009843-WB_Dual_Boost_1116_0msFF_12Cell_SRSBF_8*4MIMO_16DL4UL_SUMIMO_SA_DL_4UEs_9.6Gbps
    ...                Modified Date: 04-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC8    &{TC8_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC8

CB009843-WA_PET_Dual_Boost_1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_VoNR_380_UE
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC9
    [Documentation]    CB009843-WA_PET_Dual_Boost_1116_0msFF_1Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_VoNR_380_UE
    ...                Modified Date: 04-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC9    &{TC9_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC9

CB009843-WA_PET_Dual_Boost_1116_0msFF_6_Cell__L1_pool_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_VoNR_900_UE
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC10
    [Documentation]    CB009843-WA_PET_Dual_Boost_1116_0msFF_6_Cell__L1_pool_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_VoNR_900_UE
    ...                Modified Date: 04-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC10    &{TC10_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC10

CB009843-WA_PET_Dual_Boost_1116_0msFF_12_Cell__BBU_Level_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_VoNR_1800_UE
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC11
    [Documentation]    CB009843-WA_PET_Dual_Boost_1116_0msFF_12_Cell__BBU_Level_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_VoNR_1800_UE
    ...                Modified Date: 04-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC11    &{TC11_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC11

CB008379_1208FF_6_SSB_8*4MIMO_6CELL_SA_GBR_Bearers_1182UEs_DL_5.9Gb_197UEs_Percell
    [Tags]    FULLRUN    [flow]L3 Call    FDD_CB008379_TCP
    [Documentation]    CB008379_1208FF_6_SSB_8*4MIMO_6CELL_SA_GBR_Bearers_1182UEs_DL_5.9Gb_197UEs_Percell
    ...                Modified Date: 16-oct-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    FDD_CB008379_TCP    &{FDD_CB008379_TCP}
    [Teardown]    Deregister and Append Data    FDD_CB008379_TCP

CB010478_1116_0msFF_3Cell_SRSBF_8*4MIMO_16DL8UL_MUMIMO_2CC_CA_SA_DL_6.3Gbps_UL_1.2Gbps_72UEs_PerCell
    [Tags]    FULLRUN    [flow]L3 Call    FDD_CB010478_TCP
    [Documentation]    CB010478_1116_0msFF_3Cell_SRSBF_8*4MIMO_16DL8UL_MUMIMO_2CC_CA_SA_DL_6.3Gbps_UL_1.2Gbps_72UEs_PerCell
    ...                Modified Date: 16-oct-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    FDD_CB010478_TCP    &{FDD_CB010478_TCP}
    [Teardown]    Deregister and Append Data    FDD_CB010478_TCP

TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244Mbps_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_Drop2_TC9
    [Documentation]    TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244Mbps_ABIP
    ...                Modified Date: 03-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    CNI108638_Drop2_TC9    &{CNI108638_Drop2_TC9}
    [Teardown]    Deregister and Append Data    CNI108638_Drop2_TC9

TC10_TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_375UE_percell_total_UL_peak_tp_1450Mbps_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_Drop2_TC10
    [Documentation]    TC10_TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_375UE_percell_total_UL_peak_tp_1450Mbps_ABIP
    ...                Modified Date: 03-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    CNI108638_Drop2_TC10    &{CNI108638_Drop2_TC10}
    [Teardown]    Deregister and Append Data    CNI108638_Drop2_TC10

FDD_NonDSS_NonCA_RJIO_SA MUE_Peak_DLUL_Tput_on_cell7
    [Tags]    FULLRUN    [flow]L3 Call    FDD_FR1_TCP_7CELL
    [Documentation]    FDD_NonDSS_NonCA_RJIO_SA MUE_Peak_DLUL_Tput_on_cell7
    ...                Modified Date: 23-10-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    FDD_FR1_TCP_7CELL    &{FDD_FR1_TCP_7CELL}
    [Teardown]    Deregister and Append Data    FDD_FR1_TCP_7CELL

TDD_SA_DL_peak_TP_with_DCM_IOT_Profile_1
    [Tags]    FULLRUN    [flow]L3 Call    SA_DCM_DL
    [Documentation]    TDD_SA_DL_peak_TP_with_DCM_IOT_Profile_1
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    SA_DCM_DL    &{SA_DCM_DL}
    [Teardown]    Deregister and Append Data    SA_DCM_DL

TDD_SA_UL_peak_TP_with_DCM_IOT_Profile_1
    [Tags]    FULLRUN    [flow]L3 Call    SA_DCM_UL
    [Documentation]    TDD_SA_UL_peak_TP_with_DCM_IOT_Profile_1
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    SA_DCM_UL    &{SA_DCM_UL}
    [Teardown]    Deregister and Append Data    SA_DCM_UL

ORAN_TDD_UL_2CC_CA_peak_TP
    [Tags]    FULLRUN    [flow]L3 Call    UL_2CC_CA
    [Documentation]    ORAN_TDD_UL_2CC_CA_peak_TP
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    UL_2CC_CA    &{UL_2CC_CA}
    [Teardown]    Deregister and Append Data    UL_2CC_CA

ORAN_TDD_100MHz_FR1_3CC_CA
    [Tags]    FULLRUN    [flow]L3 Call    DL_3CC_CA
    [Documentation]    ORAN_TDD_100MHz_FR1_3CC_CA
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    DL_3CC_CA    &{DL_3CC_CA}
    [Teardown]    Deregister and Append Data    DL_3CC_CA

TDD_NSA_DL_peak_TP_with_DCM_IOT_Profile_1b
    [Tags]    FULLRUN    [flow]L3 Call    NSA_DCM_DL
    [Documentation]    TDD_NSA_DL_peak_TP_with_DCM_IOT_Profile_1b
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_DCM_DL    &{NSA_DCM_DL}
    [Teardown]    Deregister and Append Data    NSA_DCM_DL

TDD_NSA_UL_peak_TP_with_DCM_IOT_Profile_1b
    [Tags]    FULLRUN    [flow]L3 Call    NSA_DCM_UL
    [Documentation]    TDD_NSA_UL_peak_TP_with_DCM_IOT_Profile_1b
    ...                Modified Date: 24-sept-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_DCM_UL    &{NSA_DCM_UL}
    [Teardown]    Deregister and Append Data    NSA_DCM_UL

Fake_Paging_Events_2500perSec_with_5AMF_500Events_PerAMF_MP
    [Documentation]    Fake_Paging_Events_2500perSec_with_5AMF_500Events_PerAMF
    [Tags]    FULLRUN     [flow]L3 Call    VTM_FAKE_PAGING_MP
    Fetch Dictionary items    ${VTM_FAKE_PAGING_MP}
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0
    Set Suite Variable    &{MAIL_DATA}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${vtm_data_list}=    Create List
    Set Suite Variable    @{vtm_data_list}
    ${missing_counter}=    Create List
    Set Suite Variable    @{missing_counter}
    Traffic Duration Set
    @{seq_list1}=    Create List    71
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${expected_values}=    Create List    ${expected_rate}
    Set Suite Variable    @{expected_values}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Common Register and Traffic    ${VTM_FAKE_PAGING_MP}    VTM_FAKE_PAGING_MP
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        ${M55119C01501}    Run Keyword    Counter Fetch    M55119C01501
        ${achieved_rate}=    Evaluate   (sum(${M55119C01501})/((${COUNTER_DURATION})*60))
        Log To Console    Achieved Rate ${achieved_rate}
        Append To Kpi list    ${kpi_list}    ${achieved_rate}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Update testproperties VTM    VTM_FAKE_PAGING_MP    ${MAIL_DATA}

TDD_NSA_FR2_DL_peak_TP_with_DCM_IOT_Profile_3
    [Tags]    FULLRUN    [flow]L3 Call    NSA_DL_MMWV
    [Documentation]    TDD_NSA_FR2_DL_peak_TP_with_DCM_IOT_Profile_3
    ...                Modified Date: 30-Oct-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_DL_MMWV    &{NSA_DL_MMWV}
    [Teardown]    Deregister and Append Data    NSA_DL_MMWV

TDD_NSA_FR2_UL_peak_TP_with_DCM_IOT_Profile_3
    [Tags]    FULLRUN    [flow]L3 Call    NSA_UL_MMWV
    [Documentation]    TDD_NSA_FR2_UL_peak_TP_with_DCM_IOT_Profile_3
    ...                Modified Date: 30-Oct-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_UL_MMWV    &{NSA_UL_MMWV}
    [Teardown]    Deregister and Append Data    NSA_UL_MMWV

CB009843-WA_PET_Dual_Boost_5G001070_1_Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_RRC_1500_UE
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC12
    [Documentation]    CB009843-WA_PET_Dual_Boost_5G001070_1_Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_RRC_1500_UE
    ...                Modified Date: 10-11-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC12    &{TC12_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC12

CB009843-WA_PET_Dual_Boost_5G001070_12_Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_RRC_9000_UE
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC14
    [Documentation]    CB009843-WA_PET_Dual_Boost_5G001070_12_Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_RRC_9000_UE
    ...                Modified Date: 10-11-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC14    &{TC14_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC14

CB012605-W_PET_Dual_Boost_5G001070_6_Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_RRC_4500_UE
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_FR1_TC13
    [Documentation]    CB012605-W_PET_Dual_Boost_5G001070_6_Cell_SRSBF_8*4MIMO_16DL4UL_MUMIMO_SA_RRC_4500_UE
    ...                Modified Date: 10-11-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    Dual_Boost_FR1_TC13    &{TC13_FR1_DUAL_BOOST}
    [Teardown]    Deregister and Append Data    Dual_Boost_FR1_TC13

TDD_FR2_CA_3S_8CC_SA_318UE_Peak_full_buffer_Cell_Peak_Tput_UL_1696Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_UL_FULLBUFFER
    [Documentation]    TDD_FR2_CA_3S_8CC_SA_318UE_Peak_full_buffer_Cell_Peak_Tput_UL_1696Mbps_traffic_MUE
    ...                Modified Date: 14-Nov-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    @{INDEX_LIST}=    Create List    2    10    18
    Set Suite Variable    ${INDEX_LIST}
    @{CNI113765_CELL_COUNTERS}=    Create List    M55138C00033
    Set Suite Variable    ${CNI113765_CELL_COUNTERS}
    Initialize Test Data    CNI113765_UL_FULLBUFFER    &{FR2_TDD_CNI113765_TC3}
    [Teardown]    Deregister and Append Data    CNI113765_UL_FULLBUFFER    ${pre_data_dictionary}

TDD_FR2_CA_3S_8CC_SA_318UE_Peak_full_buffer_Cell_Peak_Tput_DL_5133Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    CNI113765_DL_FULLBUFFER
    [Documentation]    TDD_FR2_CA_3S_8CC_SA_318UE_Peak_full_buffer_Cell_Peak_Tput_DL_5133Mbps_traffic_MUE
    ...                Modified Date: 14-Nov-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    @{INDEX_LIST}=    Create List    2    10    18
    Set Suite Variable    ${INDEX_LIST}
    @{CNI113765_CELL_COUNTERS}=    Create List    M55138C00033
    Set Suite Variable    ${CNI113765_CELL_COUNTERS}
    Initialize Test Data    CNI113765_DL_FULLBUFFER    &{FR2_TDD_CNI113765_TC4}
    [Teardown]    Deregister and Append Data    CNI113765_DL_FULLBUFFER    ${pre_data_dictionary}

DCM IOT Profile1B cell_lockunlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    [Tags]    FULLRUN    [flow]L3 Call    PROFILE1B_LOCK
    [Documentation]    Lock/Unlock for Profile1B
    ...                Modified Date: 03-11-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Initialize_And_Execute_DCM_IOT_Profile_Test    ${PROFILE1B_LOCK}    PROFILE1B_LOCK
    [Teardown]    Append Data and add lock/unlock status    ${FINAL_DATA}    PROFILE1B_LOCK

DCM IOT Profile6B cell_lockunlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    [Tags]    FULLRUN    [flow]L3 Call    PROFILE6B_LOCK
    [Documentation]    Lock/Unlock for Profile6B
    ...                Modified Date: 03-11-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1    RU_2=2    RU_3=3    RU_4=4    RU_5=5    RU_6=6
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Initialize_And_Execute_DCM_IOT_Profile_Test    ${PROFILE6B_LOCK}    PROFILE6B_LOCK
    [Teardown]    Append Data and add lock/unlock status    ${FINAL_DATA}    PROFILE6B_LOCK

TDD_NSA_1070FF_4DL4UL_12Cells_9000UEs_750UE_percell_with_pingtraffic_2DRB_perUE
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_Drop3_TC15
    [Documentation]    TDD_NSA_1070FF_4DL4UL_12Cells_9000UEs_750UE_percell_with_pingtraffic_2DRB_perUE
    ...                Modified Date: 2-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    CNI108638_Drop3_TC15    &{CNI108638_Drop3_TC15}
    [Teardown]    Deregister and Append Data    CNI108638_Drop3_TC15

FDD_NSA_4T4R_24Cells_20Mhz_DL_peak_tp_5640Mbps_perBBUcard_1UE_percell
    [Tags]    FULLRUN    [flow]L3 Call    FDD_FR1_TCP_24CELL
    [Documentation]    FDD_NSA_4T4R_24Cells_20Mhz_DL_peak_tp_5640Mbps_perBBUcard_1UE_percell
    ...                Modified Date: 01-11-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    FDD_FR1_TCP_24CELL    &{FDD_FR1_TCP_24CELL}
    [Teardown]    Deregister and Append Data    FDD_FR1_TCP_24CELL

CNI-129753_TCP_FDD_4T4R_12CELL_25Mhz_1UE_percell_DL_peak_tp_perL1SubPool_3cells_1519Mbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_TCP_25MHz_3UE_DL
    [Documentation]    CNI-129753_TCP_FDD_4T4R_12CELL_25Mhz_1UE_percell_DL_peak_tp_perL1SubPool_3cells_1519Mbps
    ...                Modified Date: 28-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    NSA_FDD_TCP_25MHz_3UE_DL    &{NSA_FDD_TCP_25MHz_3UE_DL}
    [Teardown]    Deregister and Append Data    NSA_FDD_TCP_25MHz_3UE_DL

CNI-129753_TCP_FDD_4T4R_12CELL_25Mhz_1UE_percell_UL_peak_tp_perL1SubPool_3cells_847Mbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_TCP_25MHz_3UE_UL
    [Documentation]    CNI-129753_TCP_FDD_4T4R_12CELL_25Mhz_1UE_percell_UL_peak_tp_perL1SubPool_3cells_847Mbps
    ...                Modified Date: 28-11-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    Initialize Test Data    NSA_FDD_TCP_25MHz_3UE_UL    &{NSA_FDD_TCP_25MHz_3UE_UL}
    [Teardown]    Deregister and Append Data    NSA_FDD_TCP_25MHz_3UE_UL

DCM IOT Profile6 cell_lockunlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    [Tags]    FULLRUN    [flow]L3 Call    PROFILE6_LOCK
    [Documentation]    Lock/Unlock for Profile6
    ...                Modified Date: 24-11-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Initialize_And_Execute_DCM_IOT_Profile_Test    ${PROFILE6_LOCK}    PROFILE6_LOCK
    [Teardown]    Append Data and add lock/unlock status    ${FINAL_DATA}    PROFILE6_LOCK

DCM IOT Profile3 cell_lockunlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    [Tags]    FULLRUN    [flow]L3 Call    PROFILE3_LOCK
    [Documentation]    Lock/Unlock for Profile3
    ...                Modified Date: 24-11-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Initialize_And_Execute_DCM_IOT_Profile_Test    ${PROFILE3_LOCK}    PROFILE3_LOCK
    [Teardown]    Append Data and add lock/unlock status    ${FINAL_DATA}    PROFILE3_LOCK

DCM IOT Profile12 cell_lockunlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    [Tags]    FULLRUN    [flow]L3 Call    PROFILE1_2_LOCK
    [Documentation]    Lock/Unlock for Profile1_2
    ...                Modified Date: 24-11-2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1    RU_2=2
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Initialize_And_Execute_DCM_IOT_Profile_Test    ${PROFILE1_2_LOCK}    PROFILE1_2_LOCK
    [Teardown]    Append Data and add lock/unlock status    ${FINAL_DATA}    PROFILE1_2_LOCK

Drop3_TDD_NSA_2CC_nonBF_Pcell_768CA_UE_Scell_732_NonCA_UE
    [Tags]    FULLRUN    [flow]L3 Call    CNI108638_Drop3_CA_RRC
    [Documentation]    Drop3_TDD_NSA_2CC_nonBF_Pcell_768CA_UE_Scell_732_NonCA_UE
    ...                Modified Date: 16-12-2025
    ...                Last Modified by: arjun.1.k@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    CNI108638_Drop3_CA_RRC    &{CNI108638_Drop3_CA_RRC}
    [Teardown]    Deregister and Append Data    CNI108638_Drop3_CA_RRC

VTM MVP MP 1070FF 6SSB 8x4MIMO 6Cells CA scelladd del UEstatetransition attachDetach paging Mixed HO VONR RNA TAU additional DRB
    [Documentation]    VTM_Drop2_1070FF_6_SSB_8*4MIMO_6Cells_Mixed_HO_600UEs
    ...    ping_traffic_100UEs_perCell
    [Tags]    FULLRUN     [flow]L3 Call    VTM_MVP_MP
    @{COUNTER_LIST}=    Create List    M55326C00501    M55326C00502
    Set Suite Variable    ${COUNTER_LIST}
    Traffic Duration Set
    Fetch Dictionary items    ${VTM_MVP_MP}
    ${MAIL_DATA}=    Create Dictionary    DL_RATE=0    UL_RATE=0
    Set Suite Variable    &{MAIL_DATA}
    @{vtm_data_list}=    Create List
    Set Suite Variable    ${vtm_data_list}
    @{dl_tput_list}=    Create List
    Set Suite Variable    ${dl_tput_list}
    @{ul_tput_list}=    Create List
    Set Suite Variable    ${ul_tput_list}
    @{test_verdict}=    Create List
    Set Suite Variable    ${test_verdict}
    @{missing_counter}=    Create List
    Set Suite Variable    ${missing_counter}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    ${expected_values}=    Create List    ${OVERALL_DL}    ${OVERALL_UL}
    Set Suite Variable    @{expected_values}
    Common Register and Traffic    ${VTM_MVP_MP}    VTM_MVP_MP
    Run Keyword And Ignore Error    Enable SIM RFM Logging
    Set Suite Variable    ${COUNTER_LIST}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Create KPI Type List
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${DL_RATE}    Run Keyword    Counter Fetch    M55326C00501
        ${achieved_dl_tput}=    Convert Bits to Mbps    ${DL_RATE[0]}
        Log To Console    Achieved DL Rate ${achieved_dl_tput}
        ${UL_RATE}    Run Keyword    Counter Fetch    M55326C00502
        ${achieved_ul_tput}=    Convert Bits to Mbps    ${UL_RATE[0]}
        Log To Console    Achieved UL Rate ${achieved_ul_tput}
        Append To List    ${dl_tput_list}    ${achieved_dl_tput}
        Append To List    ${ul_tput_list}    ${achieved_ul_tput}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
    END
    [Teardown]    Validate Kpi VTM MVP    VTM_MVP_MP    ${MAIL_DATA}

NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_Peak_DL553Mbps_72UEs_single_cell
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_25MHz_72UE_DL
    [Documentation]    NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_Peak_DL553Mbps_72UEs_single_cell
    ...                Modified Date: 4-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    NSA_FDD_25MHz_72UE_DL    &{NSA_FDD_25MHz_72UE_DL}
    [Teardown]    Deregister and Append Data    NSA_FDD_25MHz_72UE_DL

NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_Peak_UL282Mbps_72UEs_single_cell
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_25MHz_72UE_UL
    [Documentation]    NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_Peak_UL282Mbps_72UEs_single_cell
    ...                Modified Date: 4-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    NSA_FDD_25MHz_72UE_UL    &{NSA_FDD_25MHz_72UE_UL}
    [Teardown]    Deregister and Append Data    NSA_FDD_25MHz_72UE_UL

NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_1UE_percell_DL_peak_tp_perL1SubPool_3cells_1519Mbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_25MHz_3UE_DL
    [Documentation]    NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_1UE_percell_DL_peak_tp_perL1SubPool_3cells_1519Mbps
    ...                Modified Date: 4-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    NSA_FDD_25MHz_3UE_DL    &{NSA_FDD_25MHz_3UE_DL}
    [Teardown]    Deregister and Append Data    NSA_FDD_25MHz_3UE_DL

NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_1UE_percell_UL_peak_tp_perL1SubPool_3cells_847Mbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_25MHz_3UE_UL
    [Documentation]    NSA_CNI108638_FDD_4T4R_12CELL_25Mhz_1UE_percell_UL_peak_tp_perL1SubPool_3cells_847Mbps
    ...                Modified Date: 4-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    NSA_FDD_25MHz_3UE_UL    &{NSA_FDD_25MHz_3UE_UL}
    [Teardown]    Deregister and Append Data    NSA_FDD_25MHz_3UE_UL

CB012598 WA PET Dual Boost 1116 0msFF 6 Cell L1 pool SRSBF 8x4MIMO 16DL4UL MUMIMO 48DL 48UL scheduled UE per L1 pool
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_UePerL1Pool_TC15
    [Documentation]    CB012598 WA PET Dual Boost 1116 0msFF 6 Cell L1 pool SRSBF 8x4MIMO 16DL4UL MUMIMO 48DL 48UL
    ...                Modified Date: 12-11-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    Dual_Boost_UePerL1Pool_TC15    &{Dual_Boost_UePerL1Pool_TC15}
    [Teardown]    Deregister and Append Data    Dual_Boost_UePerL1Pool_TC15    ${pre_data_dictionary}

CB009843 WB PET Dual Boost 1116 0msFF 12Cell BBU Level SRSBF 8x4MIMO 16DL4UL MUMIMO SA RRC 96DL 96UL scheduled UE per BBU
    [Tags]    FULLRUN    [flow]L3 Call    Dual_Boost_UeperBBU_TC16
    [Documentation]    CB009843 WB PET Dual Boost 1116 0msFF 12Cell BBU Level SRSBF 8x4MIMO 16DL4UL MUMIMO SA RRC
    ...                Modified Date: 12-11-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    Dual_Boost_UeperBBU_TC16    &{Dual_Boost_UeperBBU_TC16}
    [Teardown]    Deregister and Append Data    Dual_Boost_UeperBBU_TC16    ${pre_data_dictionary}

TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_DL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIO
    [Tags]    FULLRUN    [flow]L3 Call    TCP_129753_TC1
    [Documentation]    TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_DL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIO
    ...                Modified Date: 11-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    TCP_129753_TC1    &{TCP_129753_TC1}
    [Teardown]    Deregister and Append Data    TCP_129753_TC1

TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_UL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIO
    [Tags]    FULLRUN    [flow]L3 Call    TCP_129753_TC2
    [Documentation]    TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_UL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIO
    ...                Modified Date: 11-12-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    TCP_129753_TC2    &{TCP_129753_TC2}
    [Teardown]    Deregister and Append Data    TCP_129753_TC2

TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_DL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIP
    [Tags]    FULLRUN    [flow]L3 Call    TCP_129753_TC1_MP
    [Documentation]    TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_DL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIP
    ...                Modified Date: 25-2-2026
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    TCP_129753_TC1_MP    &{TCP_129753_TC1_MP}
    [Teardown]    Deregister and Append Data    TCP_129753_TC1_MP

TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_UL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIP
    [Tags]    FULLRUN    [flow]L3 Call    TCP_129753_TC2_MP
    [Documentation]    TDD_SA_CNI-129753_TCP_Max_RRC_Test_16DL8UL_SRSBF_1208_FF_SUMIMO_1500UEs_UL_40%_cell_peak_Tput_2DRB_perUE_3cell_1CellperABIP
    ...                Modified Date: 25-2-2026
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    TCP_129753_TC2_MP    &{TCP_129753_TC2_MP}
    [Teardown]    Deregister and Append Data    TCP_129753_TC2_MP

NSA_CNI108638_FDD_NSA_4T4R_24Cells_NSA_9000UEs_DL_UL_Ping_traffic_375UEs_per_CELL
    [Tags]    FULLRUN    [flow]L3 Call    NSA_9000UEs_ping_data
    [Documentation]    NSA_CNI108638_FDD_NSA_4T4R_24Cells_NSA_9000UEs_DL_UL_Ping_traffic_375UEs_per_CELL
    ...                Modified Date: 5-DEC-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    NSA_9000UEs_ping_data    &{NSA_9000UEs_ping_data}
    [Teardown]    Deregister and Append Data    NSA_9000UEs_ping_data

NSA_CNI108638_FDD_NSA_4T4R_24Cells_NSA_1500UEs_50percent_DL_traffic_single_cell
    [Tags]    FULLRUN    [flow]L3 Call    NSA_1500UEs_single_cell
    [Documentation]    NSA_CNI108638_FDD_NSA_4T4R_24Cells_NSA_1500UEs
    ...                Modified Date: 5-DEC-2025
    ...                Last Modified by: rahul.20.singh@nokia.com
    @{sansa_lua_delays}=    Create List    15
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    NSA_1500UEs_single_cell    &{NSA_1500UEs_single_cell}
    [Teardown]    Deregister and Append Data    NSA_1500UEs_single_cell

NSA_FDD_Drop4b_4T4R_24CELL_20Mhz_4500UEs_total_peak_30UEsperCell_UL_1.24Gbps_158UEsperCell_Ping_traffic
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_Drop4b_UL
    [Documentation]    NSA_FDD_Drop4b_4T4R_24CELL_20Mhz_4500UEs_total_peak_30UEsperCell_UL_1.24Gbps_158UEsperCell_Ping_traffic
    ...                Modified Date: 21-1-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    NSA_FDD_Drop4b_UL    &{NSA_FDD_Drop4b_UL}
    [Teardown]    Deregister and Append Data    NSA_FDD_Drop4b_UL

NSA_FDD_Drop4b_4T4R_24CELL_20Mhz_4500UEs_total_peak_30UEsperCell_DL_3.07Gbps_158UEsperCell_Ping_traffic
    [Tags]    FULLRUN    [flow]L3 Call    NSA_FDD_Drop4b_DL
    [Documentation]    NSA_FDD_Drop4b_4T4R_24CELL_20Mhz_4500UEs_total_peak_30UEsperCell_DL_3.07Gbps_158UEsperCell_Ping_traffic
    ...                Modified Date: 21-1-2025
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    NSA_FDD_Drop4b_DL    &{NSA_FDD_Drop4b_DL}
    [Teardown]    Deregister and Append Data    NSA_FDD_Drop4b_DL

CB008406FF 1SSB 6Cells 4x4 MIMO SA 432UEs UL 2600Mbps Tput 72UEs Percell MixTRF TCP UDP
    [Tags]    FULLRUN    [flow]L3 Call    CB008406FF_432UE_UL_MP
    [Documentation]    TCP TC UL with MIxed Traffic TCP + UDP
    ...                Modified Date: 17/02/2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    CB008406FF_432UE_UL_MP    &{CB008406FF_432UE_UL_MP}
    [Teardown]    Deregister and Append Data    CB008406FF_432UE_UL_MP    ${pre_data_dictionary}

CB008360_1070FF_2Cells_144UEs_SRSBF_8*4MIMO_8DL8UL_MUMIMO_SA_UL_1.3Gb _72UEs_Percell
    [Tags]    FULLRUN    [flow]L3 Call    TCP_FR1_CMWV_CPRI_UL_MP
    [Documentation]    CB008360_1070FF_2Cells_144UEs_SRSBF_8*4MIMO_8DL8UL_MUMIMO_SA_UL_1.3Gb _72UEs_Percell
    ...                Modified Date: 17/02/2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data   TCP_FR1_CMWV_CPRI_UL_MP   &{TCP_FR1_CMWV_CPRI_UL_MP}
    [Teardown]    Deregister and Append Data    TCP_FR1_CMWV_CPRI_UL_MP

TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244Mbps
    [Tags]    FULLRUN    [flow]L3 Call    TCP_4500UEs_DL_12cells
    [Documentation]    TDD_NSA_4DL4UL_12Cells_nonBF_1208FF_375UE_percell_total_DL_peak_tp_3244_dot_3Mbps
    ...                Modified Date: 13-JAN-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    TCP_4500UEs_DL_12cells    &{TCP_4500UEs_DL_12cells}
    [Teardown]    Deregister and Append Data    TCP_4500UEs_DL_12cells

TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_375UE_percell_total_UL_peak_tp_1450Mbps
    [Tags]    FULLRUN    [flow]L3 Call    TCP_4500UEs_UL_12cells
    [Documentation]    TDD_NSA_4DL4UL_12Cells_nonBF_8406FF_375UE_percell_total_UL_peak_tp_1450Mbps
    ...                Modified Date: 13-JAN-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    @{sansa_lua_delays}=    Create List    9.5
    Set Suite Variable    ${sansa_lua_delays}
    Initialize Test Data    TCP_4500UEs_UL_12cells    &{TCP_4500UEs_UL_12cells}
    [Teardown]    Deregister and Append Data    TCP_4500UEs_UL_12cells

TDD_FDD_NSA_2CC_8406FF_SRSBF_Pcell_1100Mbps_nonBF_Scell_446Mbps_72UE_percell
    [Tags]    FULLRUN    [flow]L3 Call    NSA_TCP_T_F_1546Mbps
    [Documentation]    TDD_FDD_NSA_2CC_8406FF_SRSBF_Pcell_1100Mbps_nonBF_Scell_446Mbps_72UE_percell
    ...                Modified Date: 12-FEB-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    NSA_TCP_T_F_1546Mbps    &{NSA_TCP_T_F_1546Mbps}
    [Teardown]    Deregister and Append Data    NSA_TCP_T_F_1546Mbps

FDD_SA_AXEGHA_SFP_COUNTER_MONITOR_L3_CALL
    [Tags]    FULLRUN    [flow]L3 Call    AXEGHA_CB013212
    [Documentation]    FDD_SA_AXEGHA_SFP_COUNTER_MONITOR_L3_CALL
    ...                Modified Date: 5-Feb-2026
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    AXEGHA_CB013212    &{AXEGHA_CB013212}
    [Teardown]    Deregister and Append Data    AXEGHA_CB013212    ${pre_data_dictionary}

FDD_SA_AXEGHA_lock_unlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    [Tags]    FULLRUN    [flow]L3 Call    AXEGHA_LOCK_UNLOCK
    [Documentation]    FDD_SA_AXEGHA_lock_unlock_RU_lock_unlock_LANE_lock_unlock_AND_AMF_lock_unlock_RESET_RU_RESET_GNB_RESET_BASEBAND_CARD
    ...                Modified Date: 5-Feb-2026
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1    RU_2=2
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Initialize_And_Execute_DCM_IOT_Profile_Test    ${AXEGHA_LOCK_UNLOCK}    AXEGHA_LOCK_UNLOCK
    [Teardown]    Append Data and add lock/unlock status    ${FINAL_DATA}    AXEGHA_LOCK_UNLOCK

TDD_ABIP_TCP_FR2_CA_3S_8CC_SA_159UE_Peak_Tput_DL_5184Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    TCP_3S_8CC_DL_MP
    [Documentation]    TCP DL for 3S_8CC
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    TCP_3S_8CC_DL_MP    &{TCP_3S_8CC_DL}
    [Teardown]    Deregister and Append Data    TCP_3S_8CC_DL_MP

TDD_ABIP_TCP_FR2_CA_3S_8CC_SA_159UE_Peak_Tput_UL_1713Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    TCP_3S_8CC_UL_MP
    [Documentation]    TCP UL for 3S_8CC
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    TCP_3S_8CC_UL_MP    &{TCP_3S_8CC_UL}
    [Teardown]    Deregister and Append Data    TCP_3S_8CC_UL_MP

TDD_ABIP_TCP_FR2_CA_1S_8CC_SA_4UE_Peak_Tput_DL_4220Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    TCP_1S_8CC_DL_MP
    [Documentation]    TCP DL for 1S_8CC
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    TCP_1S_8CC_DL_MP    &{TCP_1S_8CC_DL}
    [Teardown]    Deregister and Append Data    TCP_1S_8CC_DL_MP

TDD_ABIP_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_DL_2646Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    DL_3S_8CC_MP
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_DL_2646Mbps_traffic_MUE
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    DL_3S_8CC_MP    &{DL_3S_8CC}
    [Teardown]    Deregister and Append Data    DL_3S_8CC_MP

TDD_ABIP_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_UL_849Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    UL_3S_8CC_MP
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_UL_849Mbps_traffic_MUE
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    UL_3S_8CC_MP    &{UL_3S_8CC}
    [Teardown]    Deregister and Append Data    UL_3S_8CC_MP

TDD_ABIP_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_100%_Cell_Peak_Tput_DL_5184Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    DL_MUE_3S_8CC_MP
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_100%_Cell_Peak_Tput_DL_5184Mbps_traffic_MUE
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    DL_MUE_3S_8CC_MP    &{DL_MUE_3S_8CC}
    [Teardown]    Deregister and Append Data    DL_MUE_3S_8CC_MP

TDD_ABIP_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_100%_Cell_Peak_Tput_UL_1713Mbps_traffic_MUE
    [Tags]    FULLRUN    [flow]L3 Call    UL_MUE_3S_8CC_MP
    [Documentation]    TDD_TCP_FR2_CA_3S_8CC_SA_318UE_Peak_50%_Cell_Peak_Tput_UL_1713Mbps_traffic_MUE
    ...                Modified Date: 02-Mar-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    @{CELL_INDEX}=    Create List    1    9    17
    Set Suite Variable    ${CELL_INDEX}
    Initialize Test Data    UL_MUE_3S_8CC_MP    &{UL_MUE_3S_8CC}
    [Teardown]    Deregister and Append Data    UL_MUE_3S_8CC_MP

Inter_gNB_1CCFR1_8CCFR2_NRDC_72UE_Downlink_4DL4UL_NonBF
    [Tags]    FULLRUN    [flow]L3 Call    2gNB_DL_NonBF
    [Documentation]    2 real gNBs case. FR1 gNB1 to test signaling and FR2 gNB to test DL tput
    ...                Modified Date: 10-March-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    2gNB_DL_NonBF    &{2gNB_DL_NonBF}
    [Teardown]    Deregister and Append Data    2gNB_DL_NonBF

Inter_gNB_1CCFR1_8CCFR2_NRDC_72UE_Uplink_4DL4UL_NonBF
    [Tags]    FULLRUN    [flow]L3 Call    2gNB_UL_NonBF
    [Documentation]    2 real gNBs case. FR1 gNB1 to test signaling and FR2 gNB to test DL tput
    ...                Modified Date: 10-March-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    2gNB_UL_NonBF    &{2gNB_UL_NonBF}
    [Teardown]    Deregister and Append Data    2gNB_UL_NonBF

Inter_gNB_1CCFR1_8CCFR2_NRDC_72UE_Downlink_16DL8UL_BF
    [Tags]    FULLRUN    [flow]L3 Call    2gNB_DL_BF
    [Documentation]    2 real gNBs case. FR1 gNB1 to test signaling and FR2 gNB to test DL tput
    ...                Modified Date: 10-March-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    2gNB_DL_BF    &{2gNB_DL_BF}
    [Teardown]    Deregister and Append Data    2gNB_DL_BF

VTM_375Events_1070FF_6_SRS_BF_8*4MIMO_12Cells_CA_Sell_Add_Del_UE_Statetransition_HO_TAU_RNA_AttachDetach_NgPaging_Additional_DRB_VoNR
    [Documentation]    VTM_Drop2_1070FF_6_SSB_8*4MIMO_6Cells_Mixed_HO_600UEs
    ...    ping_traffic_100UEs_perCell
    [Tags]    FULLRUN     [flow]L3 Call    Dual_Boost_VTM
    @{COUNTER_LIST}=    Create List    M55326C00501    M55326C00502
    Set Suite Variable    ${COUNTER_LIST}
    Traffic Duration Set
    Fetch Dictionary items    ${Dual_Boost_VTM}
    ${MAIL_DATA}=    Create Dictionary    DL_RATE=0    UL_RATE=0
    Set Suite Variable    &{MAIL_DATA}
    @{vtm_data_list}=    Create List
    Set Suite Variable    ${vtm_data_list}
    @{dl_tput_list}=    Create List
    Set Suite Variable    ${dl_tput_list}
    @{ul_tput_list}=    Create List
    Set Suite Variable    ${ul_tput_list}
    @{test_verdict}=    Create List
    Set Suite Variable    ${test_verdict}
    @{missing_counter}=    Create List
    Set Suite Variable    ${missing_counter}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    ${expected_values}=    Create List    ${OVERALL_DL}    ${OVERALL_UL}
    Set Suite Variable    @{expected_values}
    Common Register and Traffic    ${Dual_Boost_VTM}    Dual_Boost_VTM
    Run Keyword And Ignore Error    Enable SIM RFM Logging
    Set Suite Variable    ${COUNTER_LIST}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Create KPI Type List
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${DL_RATE}    Run Keyword    Counter Fetch    M55326C00501
        ${achieved_dl_tput}=    Convert Bits to Mbps    ${DL_RATE[0]}
        Log To Console    Achieved DL Rate ${achieved_dl_tput}
        ${UL_RATE}    Run Keyword    Counter Fetch    M55326C00502
        ${achieved_ul_tput}=    Convert Bits to Mbps    ${UL_RATE[0]}
        Log To Console    Achieved UL Rate ${achieved_ul_tput}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
        Append To List    ${dl_tput_list}    ${achieved_dl_tput}
        Append To List    ${ul_tput_list}    ${achieved_ul_tput}
    END
    [Teardown]    Validate Kpi VTM MVP    Dual_Boost_VTM    ${MAIL_DATA}

Drop3b_TDD_NSA_16DL8UL_MUMIMO_6Cells_BF_8406FF_UL_peak_tp_860Mbps_72UEs_percell_1cell_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    Drop3b_UL_NSA
    [Documentation]    Drop3b_TDD_NSA_16DL8UL_MUMIMO_6Cells_BF_8406FF_UL_peak_tp_860Mbps_72UEs_percell_1cell_ABIP
    ...                Modified Date: 27-Feb-2026
    ...                Last Modified by: moola.kankshitha_reddy@nokia.com
    Initialize Test Data    Drop3b_UL_NSA    &{Drop3b_UL_NSA}
    [Teardown]    Deregister and Append Data    Drop3b_UL_NSA    ${pre_data_dictionary}

CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_DL_187_188UEpercell_total_peak_tp_3067Mbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_4500UE_DL
    [Documentation]    CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_DL_187_188UEpercell_total_peak_tp_3.07Gbps
    ...                Modified Date: 30-march-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_4500UE_DL    &{NSA_4500UE_DL}
    [Teardown]    Deregister and Append Data    NSA_4500UE_DL    ${pre_data_dictionary}

CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_UL_187-188UEpercell_total_peak_tp_2037Gbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_4500UE_UL
    [Documentation]    CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_UL_187-188UEpercell_total_peak_tp_2037Gbps
    ...                Modified Date: 30-march-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_4500UE_DL    &{NSA_4500UE_UL}
    [Teardown]    Deregister and Append Data    NSA_4500UE_UL    ${pre_data_dictionary}

CNI108638_FDD_NSA_FDD_20Mhz_TDD_100MHz_2CC_CA_FDD_PCELL_72UE_SCELL_8UE_3464Mbps
    [Tags]    FULLRUN    [flow]L3 Call    NSA_2CC_FDD_TDD
    [Documentation]    CNI108638_FDD_NSA_FDD_20Mhz_TDD_100MHz_2CC_CA_FDD_PCELL_72UE_SCELL_8UE_3464Mbps
    ...                Modified Date: 30-march-2026
    ...                Last Modified by: anjana.kulkarni@nokia.com
    Initialize Test Data    NSA_2CC_FDD_TDD    &{NSA_2CC_FDD_TDD}
    [Teardown]    Deregister and Append Data    NSA_2CC_FDD_TDD    ${pre_data_dictionary}

Drop5a_VTM_375Events_1070FF_6_SRS_BF_8*4MIMO_6Cells_CA_Sell_Add_Del_UE_Statetransition_HO_TAU_RNA_AttachDetach_NgPaging_Additional_DRB_VoNR
    [Documentation]    Drop5a_VTM_375Events_1070FF_6_SRS_BF_8*4MIMO_6Cells_CA_Sell_Add_Del_UE_Statetransition
    ...                Modified Date: 10-Mar-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    [Tags]    FULLRUN     [flow]L3 Call    TDD_SA_VTM_TCP
    @{COUNTER_LIST}=    Create List    M55326C00501    M55326C00502
    Set Suite Variable    ${COUNTER_LIST}
    Traffic Duration Set
    Fetch Dictionary items    ${TDD_SA_VTM_TCP}
    ${MAIL_DATA}=    Create Dictionary    DL_RATE=0    UL_RATE=0
    Set Suite Variable    &{MAIL_DATA}
    @{seq_list}=    Create List    1    87
    Set Suite Variable    ${seq_list}
    @{vtm_data_list}=    Create List
    Set Suite Variable    ${vtm_data_list}
    @{dl_tput_list}=    Create List
    Set Suite Variable    ${dl_tput_list}
    @{ul_tput_list}=    Create List
    Set Suite Variable    ${ul_tput_list}
    @{test_verdict}=    Create List
    Set Suite Variable    ${test_verdict}
    @{missing_counter}=    Create List
    Set Suite Variable    ${missing_counter}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    ${expected_values}=    Create List    ${OVERALL_DL}    ${OVERALL_UL}
    Set Suite Variable    @{expected_values}
    Common Register and Traffic    ${TDD_SA_VTM_TCP}    TDD_SA_VTM_TCP
    Run Keyword And Ignore Error    Enable SIM RFM Logging
    Set Suite Variable    ${COUNTER_LIST}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Create KPI Type List
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Create PM counter local directory
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        FOR    ${ip}    ${folder}    IN ZIP    ${gNB_IP_list}    ${pmcouter_folder}
            Wait Until Keyword Succeeds    ${COUNTER_DURATION}min    ${COUNTER_RETRY_DURATION}min
            ...    Fetch Counter Value from GNB BTS    ${folder}    ${ip}
        END
        ${DL_RATE}    Run Keyword    Counter Fetch    M55326C00501
        ${achieved_dl_tput}=    Convert Bits to Mbps    ${DL_RATE[0]}
        Log To Console    Achieved DL Rate ${achieved_dl_tput}
        ${UL_RATE}    Run Keyword    Counter Fetch    M55326C00502
        ${achieved_ul_tput}=    Convert Bits to Mbps    ${UL_RATE[0]}
        Log To Console    Achieved UL Rate ${achieved_ul_tput}
        Run Keyword If    '${kpi_var_exist}' == 'True' and '${calculate_kpi}' == 'True'
        ...    KPI Calculation and Validation
        Append To List    ${dl_tput_list}    ${achieved_dl_tput}
        Append To List    ${ul_tput_list}    ${achieved_ul_tput}
    END
    [Teardown]    Validate Kpi VTM MVP    TDD_SA_VTM_TCP    ${MAIL_DATA}

CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_DL_peak_tp_5640Mbps_perBBUcard_1UE_percell_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    NSA_24E_DL
    [Documentation]    CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_DL_peak_tp_5640Mbps_perBBUcard_1UE_percell_ABIP
    ...                Modified Date: 30-March-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    NSA_24E_DL    &{NSA_24E_DL}
    [Teardown]    Deregister and Append Data    NSA_24E_DL    ${pre_data_dictionary}

CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_UL_peak_tp_2904Mbps_perBBUcard_1UE_percell_ABIP
    [Tags]    FULLRUN    [flow]L3 Call    NSA_24E_UL
    [Documentation]    CNI108638_FDD_NSA_4T4R_24Cells_20Mhz_UL_peak_tp_2904Mbps_perBBUcard_1UE_percell_ABI
    ...                Modified Date: 30-March-2026
    ...                Last Modified by: rahul.20.singh@nokia.com
    Initialize Test Data    NSA_24E_UL    &{NSA_24E_UL}
    [Teardown]    Deregister and Append Data    NSA_24E_UL    ${pre_data_dictionary}
