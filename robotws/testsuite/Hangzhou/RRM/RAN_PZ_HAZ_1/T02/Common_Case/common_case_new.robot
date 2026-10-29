*** Settings ***
Documentation
...    Author: mengli yang
...    Contact: mengli.yang@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
&{dcap_info}    host=10.56.221.45    port=443    username=utfuser    password=utfadmin!
@{tti_condition_1}    physCellId    ==    117
@{basic_rules}    or    ${tti_condition_1}
&{tti_check_rules_1}         basic_rules=${basic_rules}
&{tti_analysis_dict_1}       check_rules=${tti_check_rules_1}
@{tti_analysis_dict}    ${tti_analysis_dict_1}
*** Test Cases ***
############################## Testup and Teardown ##############################
Case Precondition For AIC
    log to console    Case Precondition
    Common Test Setup For AIC

Case Precondition For AIC With AP
    log to console    Case Precondition
    Common Test Setup For AIC
    Case Precondition For AP

Case Postcondition For AIC
    log to console    Case Postcondition
    Common Test Teardown For AIC

Case Postcondition For AIC With AP
    log to console    Case Postcondition
    Common Test Teardown For AIC
    Case Postcondition For AP
############################### parameter ##############################
Parameter Updated In vCU
    @{para_list}          Create List    actCDrx
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vcu

Parameter Updated In vDU
    @{para_list}          Create List    actCDrx
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

Full Commission In vDU
    Full Commission    product_type=vdu
    ...     scf_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10875/SCF/10875_vDU_FDD_DC_Common.xml

Full Commission In vCU
    Full Commission    product_type=vcu
    ...      scf_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL10875/SCF/10875_CU_FDD_DC_Common.xml

############################### counter ##############################
Start Counter In VCU With Rule That Requires It To Be Larger Than 0
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55125C05505;
    ...         Counter rule: max(M55125C05505)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0
    Sleep    100s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0

Start Counter In VDU With Rule That Requires It To Be Larger Than 0
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2;
    ...         Counter: M55324C00101;
    ...         Counter rule: max(M55324C00101)>0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0
    Sleep    100s
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0

Check Counter In VCU With Rule That Requires It To Be Equal To 0
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55125C05505;
    ...         Counter rule: max(M55125C05505)==0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}
    Sleep    100s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}

Check Counter In VDU With Rule That Requires It To Be Equal To 0
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55324C00101;
    ...         Counter rule: max(M55324C00101)==0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=${0}
    Sleep    100s
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=${0}

Start Counter In VCU With Rule That Requires The Sum Of Multiple Counters To Be Equal To 0
    ${rule}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55110C00005,M55110C00006;
    ...         Counter rule:  sum(M55110C00005+M55110C00006)>=0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=0
    Sleep    100s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=0


Start Counter In VDU With Rule That Requires The Sum Of Multiple Counters To Be Equal To 0
    ${rule}    Catenate
    ...         Distname: MRBTS-1/NRBTS-1/NRCELL-1;
    ...         Counter: M55110C00005,M55110C00006;
    ...         Counter rule:  sum(M55110C00005+M55110C00006)>=0;
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vdu    bts_index=0
    Sleep    100s
    Collect And Check Counter    product_type=vdu    bts_index=${0}    cudu_index=0

Start Counter and Check Multiple Counters In VCU
    ${rule}    Catenate
    ...         Distname: MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1;
    ...         Counter: M55350C00007,M55350C01007,M55350C03007,M55350C02001,M55350C04001,M55350C07001,M55350C08001;
    ...         Counter rule: max(M55350C00007,M55350C01007,M55350C03007,M55350C02001,M55350C04001,M55350C07001,M55350C08001)>=0
    ${rule_list}    Create List    ${rule}
    Start Counter    rule_list=${rule_list}    product_type=vcu    bts_index=${0}
    Sleep    100s
    Collect And Check Counter    product_type=vcu    bts_index=${0}    cudu_index=${0}


############################## PA ##############################
Modify PA Signal For Source
    ${source_pa_port_list}     Create List     9
    ${source_pa_value_list}    Create List     127    0
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${10}

Modify PA Signal For Source And Target
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     127    20
    ${target_pa_port_list}     Create List    5    6    9
    ${target_pa_value_list}    Create List    0    127
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Initialize PA Value For TL10875
    Set Initialize PA Value    pa_port=5-8;1,2;9;    pa_value=0;127;127;

############################## BTS ##############################
Lock Cell In vDU
    BTS Operation With Module    operation=cell_lock    product_type=vdu
    ...                          bts_index=${0}    distname_id=NRCELL-1

Unlock Cell In vDU
    BTS Operation With Module    operation=cell_unlock    product_type=vdu
    ...                          bts_index=${0}    distname_id=NRCELL-1

############################# log ##############################
Collect Wireshark Log
    Collect Wireshark Log    log_type=wireshark_cp    product_type=vcu    bts_index=${0}
    Sleep    10s
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark_cp
    ...                                                      product_type=vcu
    ...                                                      bts_index=${0}

Collect and Check TTI Log
    ${dict_argument}   Create Dictionary   dcap_server=${dcap_info}
    Log Collection    start    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}    dict_argument=${dict_argument}
    sleep    20s    reason=Waiting For TTI capture
    ${local_file_path}    Log Collection    stop_and_download    tti    product_type=vdu    bts_index=${0}    cudu_index=${0}
    Log To Console    \nTTI log of VDU: ${local_file_path}
    ${result}=    Log Analysis    check    tti    ${local_file_path}    ${tti_analysis_dict}
    Log To Console    \nAnalyze log: ${result}
    Should Be True    ${result[0][0]}

############################# AP ##############################
update local AP
    [Tags]    apupgrade
    Airphone Operation    operation=local_ap_upgrade    product_type=${None}
    ...                   eth_config_path=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/TL_Airphone_AIC/ap_tl250.json

