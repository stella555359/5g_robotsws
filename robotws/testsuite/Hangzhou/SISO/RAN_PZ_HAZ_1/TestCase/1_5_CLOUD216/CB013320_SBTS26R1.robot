*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        qing.2.he@nokia-sbell.com
...    Maintainer:    heqing

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Variables   ./env.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Library     ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Library     ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/tools/common_tools.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

*** Variables ***
#config5 with 30/60/40/60M
${pk1}    "300":[230,22],"301":[482,44],"302":[310,29],"303":[482,41]
#config6 with 60/40/60/50
${pk2}    "300":[482,46],"301":[30,5],"302":[482,46],"303":[390,36]



&{CB013320_CONFIG5}=    peak_rate_config={${pk1}}
...   HW_ID=CB013320
...   site_mode=4T4R
...   ONAIR_TIME=15 min

&{CB013320_CONFIG6}=    peak_rate_config={${pk2}}
...   HW_ID=CB013320
...   site_mode=4T4R
...   ONAIR_TIME=15 min

&{CB013320_CONFIG7}=    peak_rate_config={${pk1}}
...   HW_ID=CB013320
...   site_mode=4T4R
...   ONAIR_TIME=15 min

&{CB013320_CONFIG8}=    peak_rate_config={${pk1}}
...   HW_ID=CB013320
...   site_mode=4T4R
...   ONAIR_TIME=15 min
${online_commissioning}    [['MRBTS-37748/NRBTS-37748/NRCELL-2',['chBw','60MHz']],
...                         ['MRBTS-37748/NRBTS-37748/NRCELL-2',['actDownSampling','false']]]
${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}     CB013320_CONFIG5
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset

#${CALL_STRATEGY}     new_feature
${GLO_PERFORM_SAVE_LOG}    ALWAYS
#${if_reporting_rep}    True
#${REP_COMMENT}    NFTA
${REQUIRED_BTS_ID}    37748
${RB_TO_TARGET}    YES
${YAFT}    YES
*** Test Cases ***

[1][1.0] Common_SiSo_Startup_Onair_CONFIG5
    [Tags]    QC_251675    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Onair    config_id=CB013320_CONFIG5
    Site Reset
    [Teardown]    Testcase Basic Postcondition

[1][1] Common_SiSo_Call_Throughput_Measurements_UDP_CONFIG5
    [Tags]    QC_251677    QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Tput     config_id=CB013320_CONFIG5
    test_fv.Data Transfer
    ...       required_cells=300:301:302:303
    [Teardown]    Testcase Basic Postcondition

[1][4.0] Manual_SiSo_TEST_LTE_NR_RF_Diagnostic_Test
    [Tags]    QC_251676    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=rfDiagnosticTest    config_id=CB013320_CONFIG5
    RF Diagnostic Test for NR
    [Teardown]    Testcase Basic Postcondition

[1][1] Automated SiSo OnLine Parameters delta Commissioning
    [Tags]    QC_251678  QCD_MN_RAN   QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=delta Commissioning     config_id=CB013320_CONFIG5
    Automated SiSo OnLine Parameters Commissioning
    ...       required_cells=300:301:302:303
    [Teardown]    Testcase Basic Postcondition



*** Keywords ***
RF Diagnostic Test for NR
    FOR    ${bts_id}    IN    @{ALL_BTS_ID_LIST}
        ${connection_id}    Set Variable   ${CASE_NAME}_${bts_id}
        Run Keyword And Continue On Failure    Admin Alarms Get And Check    allowed=${GLO_ADMIN_ALLOWED_ALARM}
        ...    alias=${connection_id}
    END
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        ${lcrid}    Set Variable    ${cell_info["lcrId"]}
        Run RF Diagnostic Test    ${lcrid}    NR    alias=rfDiagnosticTest_${bts_id}
        Get And Check RF Diagnostic Test Result 5G    alias=rfDiagnosticTest_${bts_id}
    END
    Verify All Cells OnAir
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
