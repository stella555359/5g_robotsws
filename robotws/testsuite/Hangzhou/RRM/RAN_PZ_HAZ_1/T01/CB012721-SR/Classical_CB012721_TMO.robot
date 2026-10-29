*** Settings ***
Documentation
...   Author: Zhan Yangjun
...   Contact: yangjun.zhan@nokia-sbell.com
...   Description: CB012721 NFTA2.0

Resource          ../../Resources/Classical/RRM_Common_Resource.robot

Library    ../../T01/Resources/iolibrary/iolibrary.py    WITH NAME    PCF_KW

Force Tags        CRT    QCD_MN_RAN    QCP_RAN_VRF    STATE_SKIP_AGENT
...               CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG01_ST_RRM    TA_LEVEL_22
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM



*** Variables ***
${indicated_sw_version}    SBTS00_ENB_9999_241022_000005
${scf_path_file_test_TC02_TC03}    ${CURDIR}/TC02_TC03_TMO.xml
${scf_path_file_test_TC08_TC09}    ${CURDIR}/TC08_TC09_TMO.xml
${scf_path_file_test_TC13}    ${CURDIR}/TC13_TMO.xml
${scf_path_file_test_TC15}    ${CURDIR}/TC15_TMO.xml
${scf_path_file_test_TC18}    ${CURDIR}/TC18_TMO.xml
${INSTALL_BUILD}    NO

#QC part
${TC02_TC03_passed}    ${False}
${TC08_TC09_passed}    ${False}
${TC13_TC15_passed}    ${False}

*** Test Cases ***

CB012721_A_B1_EC1_BTS_Operation_SCF_Check_25R2
    [Tags]    CRT   QC_117725
    [Documentation]
    ...    Author: Zhan Yangjun
    ...    history change: <date>,<who>,<what and how>
    ...    08.11.2024, yangjun.zhan@nokia-sbell.com, draft
    [Setup]    Common Test Setup For RRM
    [Timeout]    72h
    ${cmd}=    Catenate    sudo rm -rf /home/ute/test_results/admin_api_coam_admin.log
    OperatingSystem.Run    ${cmd}
    COAM_Admin.Login   alias=coam_admin
    ${res}  run keyword and ignore error    coam.perform_commissioning     scf_file=${scf_path_file_test_TC02_TC03}
    ...    skip_parameter_relation_errors=False    timeout=660    connection=coam_admin  should_activate=${False}
    Sleep  15s
    ${Relation_error_size}  PCF_KW.extract_pdl_validation_result    file_path=/home/ute/test_results/admin_api_coam_admin.log
    Run Keyword And Ignore Error    Should Be True    ${Relation_error_size}==None
    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin
    ${cmd}=    Catenate    sudo rm -rf /home/ute/test_results/admin_api_coam_admin.log
    OperatingSystem.Run    ${cmd}
    COAM_Admin.Login   alias=coam_admin
    ${res}  run keyword and ignore error    coam.perform_commissioning     scf_file=${scf_path_file_test_TC08_TC09}
    ...    skip_parameter_relation_errors=False    timeout=660    connection=coam_admin  should_activate=${False}
    Sleep  15s
    ${Relation_error_size}  PCF_KW.extract_pdl_validation_result    file_path=/home/ute/test_results/admin_api_coam_admin.log
    Run Keyword And Ignore Error    Should Be True    ${Relation_error_size}>=30
    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin
    Set Suite Variable    ${TC02_TC03_passed}    ${True}
    Set Suite Variable    ${TC08_TC09_passed}    ${True}
    [Teardown]    Common Test Teardown For RRM

[1][1.0] CB012721_TC03
    [Documentation]
    [Tags]    CRT   QC_117726
    [Setup]    Empty Setup
    should be true    ${TC02_TC03_passed}
    [Teardown]    Empty Teardown

[1][1.0] CB012721_TC08
    [Documentation]
    [Tags]    CRT   QC_117727
    [Setup]    Empty Setup
    should be true    ${TC08_TC09_passed}
    [Teardown]    Empty Teardown

[1][1.0] CB012721_TC09
    [Documentation]
    [Tags]    CRT   QC_117728
    [Setup]    Empty Setup
    should be true    ${TC08_TC09_passed}
    [Teardown]    Empty Teardown

CB012721_A_B2_BTS_Operation_SCF_Check_25R2
    [Tags]    CRT   QC_117729
    [Documentation]
    ...    Author: Zhan Yangjun
    ...    history change: <date>,<who>,<what and how>
    ...    23.12.2024, yangjun.zhan@nokia-sbell.com, draft
    [Setup]    Common Test Setup For RRM
    [Timeout]    72h
    ${cmd}=    Catenate    sudo rm -rf /home/ute/test_results/admin_api_coam_admin.log
    OperatingSystem.Run    ${cmd}
    COAM_Admin.Login   alias=coam_admin
    ${res}  run keyword and ignore error    coam.perform_commissioning     scf_file=${scf_path_file_test_TC13}
    ...    skip_parameter_relation_errors=False    timeout=660    connection=coam_admin  should_activate=${False}
    Sleep  15s
    ${Relation_error_size}  PCF_KW.extract_pdl_validation_result    file_path=/home/ute/test_results/admin_api_coam_admin.log
    Run Keyword And Ignore Error    Should Be True    ${Relation_error_size}==None
    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin
    ${cmd}=    Catenate    sudo rm -rf /home/ute/test_results/admin_api_coam_admin.log
    OperatingSystem.Run    ${cmd}
    COAM_Admin.Login   alias=coam_admin
    ${res}  run keyword and ignore error    coam.perform_commissioning     scf_file=${scf_path_file_test_TC15}
    ...    skip_parameter_relation_errors=False    timeout=660    connection=coam_admin  should_activate=${False}
    Sleep  15s
    ${Relation_error_size}  PCF_KW.extract_pdl_validation_result    file_path=/home/ute/test_results/admin_api_coam_admin.log
    Run Keyword And Ignore Error    Should Be True    ${Relation_error_size}>=2
    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin
    Set Suite Variable    ${TC13_TC15_passed}    ${True}
    [Teardown]    Common Test Teardown For RRM

[1][1.0] CB012721_TC15
    [Documentation]
    [Tags]    CRT   QC_117730
    [Setup]    Empty Setup
    should be true    ${TC13_TC15_passed}
    [Teardown]    Empty Teardown

CB012721_A_EC2_BTS_Operation_SCF_Check_25R2
    [Tags]    CRT   QC_117731
    [Documentation]
    ...    Author: Zhan Yangjun
    ...    history change: <date>,<who>,<what and how>
    ...    23.12.2024, yangjun.zhan@nokia-sbell.com, draft
    [Setup]    Common Test Setup For RRM
    [Timeout]    72h
    ${cmd}=    Catenate    sudo rm -rf /home/ute/test_results/admin_api_coam_admin.log
    OperatingSystem.Run    ${cmd}
    COAM_Admin.Login   alias=coam_admin
    ${res}  run keyword and ignore error    coam.perform_commissioning     scf_file=${scf_path_file_test_TC18}
    ...    skip_parameter_relation_errors=False    timeout=660    connection=coam_admin  should_activate=${False}
    Sleep  15s
    ${Relation_error_size}  PCF_KW.extract_pdl_validation_result    file_path=/home/ute/test_results/admin_api_coam_admin.log
    Run Keyword And Ignore Error    Should Be True    ${Relation_error_size}>=6
    Run Keyword And Ignore Error    coam.teardown    connection=coam_admin
    [Teardown]    Common Test Teardown For RRM

*** Keywords ***

BTS_Operation_Upgrade
    [Tags]    upgrade
    BTS Operation    operation=upgrade    product_type=gnb    bts_index=0
    ...              indicated_sw_version=${indicated_sw_version}

TC01_Parameter_Operation_parameter_check
    @{para_list}    Create List    ssbFrequency    a1MeashoSsbRsrp/0/a1ThresholdhoSsbRsrp    a1MeashoSsbRsrp/0/a1HysteresishoSsbRsrp
    ...                            a1MeashoSsbRsrp/0/a1TimeToTriggerhoSsbRsrp    a1MeashoSsbRsrq/0/a1ThresholdhoSsbRsrq
    ...                            a1MeashoSsbRsrq/0/a1HysteresishoSsbRsrq    a1MeashoSsbRsrq/0/a1TimeToTriggerhoSsbRsrq
    ...                            a2MeashoSsbRsrp/0/a2HysteresishoSsbRsrp    a2MeashoSsbRsrp/0/a2ThresholdhoSsbRsrp
    ...                            a2MeashoSsbRsrp/0/a2TimeToTriggerhoSsbRsrp    a2MeashoSsbRsrq/0/a2HysteresishoSsbRsrq
    ...                            a2MeashoSsbRsrq/0/a2ThresholdhoSsbRsrq    a2MeashoSsbRsrq/0/a2TimeToTriggerhoSsbRsrq
    ...                            a2MeasRedirectSsbRsrp/0/a2HysteresisRedirectSsbRsrp    a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp
    ...                            a2MeasRedirectSsbRsrp/0/a2TimeToTriggerRedirectSsbRsrp    a2MeasRedirectSsbRsrq/0/a2HysteresisRedirectSsbRsrq
    ...                            a2MeasRedirectSsbRsrq/0/a2ThresholdRedirectSsbRsrq    a2MeasRedirectSsbRsrq/0/a2TimeToTriggerRedirectSsbRsrq
    @{mo_list_gnb}    Create List    MRBTS-11648/NRBTS-11648/NRADJNRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1    MRBTS-11648/NRBTS-11648/NRCELL-1
    ...                              MRBTS-11648/NRBTS-11648/NRCELL-1
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=gnb    para_list=@{para_list}    mo_list=@{mo_list_gnb}
    Log To Console    \nGNB Parameter Check Result: ${out}
    RETURN    ${out}

Empty Setup
    Log To Console  Ok

Empty Teardown
    sleep  30s
    ${scf_id}=    Get SCF Internal Id By Scout    no_ute=False