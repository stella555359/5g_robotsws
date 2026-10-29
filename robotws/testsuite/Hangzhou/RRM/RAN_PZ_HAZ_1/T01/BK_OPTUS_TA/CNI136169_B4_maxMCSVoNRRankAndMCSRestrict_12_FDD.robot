*** Settings ***
Documentation
...   Author: Wu Haihua
...   Contact: haihua.wu@nokia-sbell.com
...   Description: The purpose of this test is to testing CNI136169
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

Force Tags
...                CA_RAN_PZ_HAZ_1
...                RAN_PZ_HAZ1_SG01_ST_RRM
...                TA_LEVEL_22
...                CRT
...                TRUNK

Test Timeout    1800 minutes
Resource          ../../Resources/Classical/RRM_Common_Resource.robot

*** Variables ***
${SEPARATOR}        ,
${str1}  262033100015474,262033100015475,262033100015476,262033100015477,262033100015478,262033100015479,262033100015480,262033100015481
${ue_imsi}     ${str1}

*** Test Cases ***
CNI136169 B4 maxMCSVoNRRankAndMCSRestrict 12 FDD
    [Tags]    QC_161182       QCD_MN_RAN      QCP_RAN_VRF
    [Documentation]
    ...    Author: Jinying.Guo
    ...    Contact: jinying.guo@nokia-sbell.com
    ...    3.12.2025,jinying.guo@nokia-sbell.com
     MT_Initialize PA Value
     Modify feature paramter ON
     Counter_collect_Start
     FOR   ${index}  IN RANGE    3
         Attach_8UEs
         MT_VoNR_Start_8UEs
         sleep       300
         MT_VoNR_Stop_8UEs
         sleep      10
         Detach_8UEs
         Log    Loop ${index} times (Total 3)  console=True
    END
    Sleep    960
    Counter_checking
    Collect snapshot
    [Teardown]    Single Run Update Config ID

*** Keywords ***
Single Run Update Config ID
    Get SCF Internal Id By Scout    no_ute=False     bts_id=10_5_4G-37542-5G-37543_MRBTS-37543

Collect snapshot
    ${local_file_path}    Log Collection    start    snapshot    product_type=gnb    bts_index=${0}
    Log To Console    \nSnapshot log: ${local_file_path}

Modify feature paramter ON
    @{para_list}      Create List    actVoNR   actEnhancedVoNR    actDlVoNrLimMaxMcsAndLayer    maxMCSVoNRRankAndMCSRestrict
    ...               actTargetBlerVoNR    dllaTargetBlerVoNR    ullaTargetBlerVoNR     actDl256Qam
    @{mo_list}        Create List    MRBTS-37543/NRBTS-37543/NRCELL-73     MRBTS-37543/NRBTS-37543/NRCELL-73
    ...               MRBTS-37543/NRBTS-37543/NRCELL-73     MRBTS-37543/NRBTS-37543/NRCELL-73     MRBTS-37543/NRBTS-37543/NRCELL-73
    ...               MRBTS-37543/NRBTS-37543/NRCELL-73     MRBTS-37543/NRBTS-37543/NRCELL-73     MRBTS-37543/NRBTS-37543/NRCELL-73
    @{value_list}     Create List    true     true     true     12    true     2      2     true
    ${out}            Parameter Operation    operation=parameter_update    product_type=gnb
    ...                                      para_list=@{para_list}        value_list=@{value_list}    mo_list=@{mo_list}
    Log To Console    paramter update result: ${out}

MT_Initialize PA Value
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters
    ...     pa_port=1;10;17;26;33;42;65;74;81;90;97;106;129;138;145;154;193;202;
    ...     pa_value=120;120;120;120;120;120;120;120;120;120;120;120;120;120;120;120;40;40;
    &{source}    Create Dictionary    att_index=${0}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${10}
    Run Keyword And Ignore Error     PA Operation    operation=Initialize PA Value    source=&{source}

Attach_8UEs
      Traffic Uebox Operation    attach     ue_imsi=${ue_imsi}
      Log    Attach Done!  console=True

Detach_8UEs
      Traffic Uebox Operation    detach    ue_imsi=${ue_imsi}
      Log    Detach success!   console=True

MT_VoNR_Start_8UEs
     Traffic Uebox Operation    start voice call  ue_imsi=${ue_imsi}    Number=6688
     Log    VoNR start!   console=True

MT_VoNR_Stop_8UEs
     Traffic Uebox Operation    stop voice call  ue_imsi=${ue_imsi}
     Log    VoNR stop!   console=True

Counter_collect_Start
    ${rule1}    Catenate
    ...         Distname: MRBTS-37543/NRBTS-37543/NRCELL-73;
    ...         Counter: M55300C12056 to M55300C12070;
    ...         Counter rule:max(M55300C12056 to M55300C12070)==0
    ${rule_list}    Create List    ${rule1}
    Log To Console    \nThe rule list is: ${rule_list}
    Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=0    counter_rule=${rule_list}

Counter_checking
    ${result}    Counter Operation    operation=collect_counter_and_check_rule    product_type=gnb    bts_index=0    cudu_index=0
    Log To Console    \nCounter Rule Collect Result is: ${result}

[Teardown]