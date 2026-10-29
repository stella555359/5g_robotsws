*** Settings ***
Documentation                          Suite description
Force Tags                             RAN_5G    RAN_5G_TDD
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_ASIKR_ABILB4_AZHA_ENB_NETACT    STATE_SW_UPLOADED    SBTS00
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/libraries/Cockpit/Cockpit_Config.py
Resource                               ${CURDIR}/resources/keywords_cOAM.robot
Resource                               ${CURDIR}/resources/5GC000772_Variables.robot
Resource                               ${CURDIR}/resources/5GC000772_Keywords.robot
Resource                               ${CURDIR}/resources/5GC001877_Variables.robot
Resource                               ${CURDIR}/resources/5GC000772_Keywords.robot
Library                                BuiltIn
Library                                String
Library                                ute_reporting_portal
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource                    ${CURDIR}/switchkeywords.robot
Resource      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008196_B_TDD_ST/Resource/COAM.robot


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    Run Keywords    CI_interface.Common Suite Setup
...    AND     robot_common_operations.Common Suite Setup
...    AND     Generic Suite Setup    SCF=${SCF}    SWconfig=${SWconfig}    NumberOfCells=${NumberOfCells}

Suite Teardown   Run Keywords     CI_interface.Common Suite Setup   AND   robot_common_operations.Common Suite Teardown
Test Setup     robot_common_operations.Common Case Setup    allowed_faults_ids=7107,4681
Test Teardown   Run Keywords    Connect to gnb coam via ssl   AND    Run Keyword If Test Failed
...    COAM Save snapshot via rest api   AND    robot_common_operations.Common Case Teardown
...    AND     CI interface.Common Case Teardown


*** Variables ***
${SCF}=                 CV_1Cell_dBF_Off_For_5GC000772_CRT.xml
${SWconfig}=            swconfig_For_5GC000772_CRT.txt
${NumberOfCells}=           1
${CAMPAIGN_NAME_15}    5GC000772_A_15
${CAMPAIGN_NAME_19}    5GC000772_A_19
${CAMPAIGN_NAME_2}    5GC000772_A_05_09_12
${CAMPAIGN_NAME_20}    5GC000772_A_20
${CAMPAIGN_NAME_5}    5GC001877_772_C_05_09
${CAMPAIGN_NAME_12}    5GC001877_772_C_12
${CAMPAIGN_NAME_10}    5GC001877_772_C_10
#${CAMPAIGN_NAME_15}    5GC001877_772_C_15
${TS_CASE_LOG_PATH}    ${OUTPUT_DIR}

*** Test Cases ***

[1]5GC000772-A_1_Feature_Activation
    COAM Update SERVEDAMF administrativeState    Locked
    Check Cell Availability Status is online after commissioning    ${CELL_NUMBER}

#[1]5GC000772-A_19_NSA_online_DRXmodification
#    [Teardown]    Run Keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_19}
#
#    Run Keywords    Set five parameters for case  feature1877_772_C_NSA_X2_CallEstablishmentAndRelease.sm
#    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g.sm
#    ...    feature1877_772_C_NSA_X2_OnlineDrxModification.sm
#    ...    feature1877_772_C_NSA_F1_CallEstablishmentAndRelease.sm
#    ...    feature1877_772_C_NSA_F1_OnlineDrxModification.sm    AND    Generic Suite Setup For Two Calls
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_19}    CELL_NUMBER=${CELL_NUMBER}    attach_mode=5G_NSA
#
#    Log to console    checkFeature_772_NSA_OnlineDrxModification
#    ${result}=    mylib772.checkFeature_772_NSA_OnlineDrxModification  ${1stCallCounterCheck}  ${2ndCallCounterCheck}
#    ...    ${5GLoadVersion}    ${hw_type}

[1]5GC000772-A_2_NSACallSetup_MSC_X2_UeSupportsDRX
    [Teardown]    5GC000772_Keywords.Test Teardown    ${result}
    COAM Update SERVEDAMF administrativeState    Locked
    Check Cell Availability Status is online after commissioning    ${CELL_NUMBER}
    Run Keywords    Set four parameters for case
    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndRelease.sm
    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5gsbts.sm
    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g.sm
    ...    feature1877_772_C_NSA_F1_CallEstablishmentAndRelease.sm    AND
    ...    Generic Suite Setup For one call during Activating DRX
    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_2}    CELL_NUMBER=${CELL_NUMBER}

    Log to console    checkFeature_772_NSA_Call for case2
    ${result}=                         mylib772.checkFeature_772_NSA_Call    ${5GLoadVersion}    2    ${hw_type}



[1]5GC000772-A_3_NSACallSetup_MSC_CU_UeSupportsDRX
    [Teardown]     5GC000772_Keywords.Test Teardown    ${result}
    Log to console    checkFeature_772_NSA_Call for case3
    ${result}=                         mylib772.checkFeature_772_NSA_Call    ${5GLoadVersion}    3    ${hw_type}



[1]5GC000772-A_5_NSACallSetup_counters_UeSupportsDRX
    [Teardown]     Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
	...    CAMPAIGN_NAME=${CAMPAIGN_NAME_2}
    Log to console    checkFeature_772_NSA_Counters for case5
    ${result}=                         mylib772.checkFeature_772_NSA_Counters    ${checkDrxRatio}    5


[1]5GC000772-A_12_NSACallRelease_UeSupportsDRX
    [Teardown]     Run Keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_2}
    ${result}=    case12_NSACallRelease_UeSupportsDRX



#[1]5GC000772-A_20_NSACallSetup_FR1scheduling_MultiUeSupportDRX_startOffset
#    [Teardown]    Run Keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_20}
#
#    Run Keywords    Set four parameters for case
#    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndRelease.sm
#    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5g.sm
#    ...    feature1877_772_C_NSA_X2_CallEstablishmentAndReleaseFrom5gsbts.sm
#    ...    feature1877_772_C_NSA_F1_CallEstablishmentAndRelease.sm    AND
#    ...    Generic Suite Setup For MultiUe    ${CAMPAIGN_NAME_20}    ${CELL_NUMBER}
#
#    Log to console                     mylib772.checkFeature_772_NSA_Call_MultiUEs
#    ${result}=                         mylib772.checkFeature_772_NSA_Call_MultiUEs    ${5GLoadVersion}    ${hw_type}


#[1]5GC000772-A_15_NSACAllSetup_MSC_UeSupportsDRX_FeatureNotActive
#    [Teardown]    Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_15}
#
#    Run Keywords    Set three parameters for case
#    ...    feature1877_772_C_NSA_X2_UeSupportsDRX_FeatureNotActive.sm
#    ...    feature1877_772_C_NSA_X2_UeSupportsDRX_FeatureNotActiveReleaseFrom5g.sm
#    ...    feature1877_772_C_NSA_F1_UeSupportsDRX_FeatureNotActive.sm    AND    Generic Suite Setup For one call
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_15}    CELL_NUMBER=${CELL_NUMBER}
#
#    Log to console    checkFeature_772_NSA_DRX_OFF
#    ${result}=                         mylib772.checkFeature_772_NSA_DRX_OFF    ${5GLoadVersion}    ${hw_type}




[1]5GC000772_C_1_SA-classical-cmw-TDD_Feature_Activation
    COAM Update SERVEDAMF administrativeState    Unlocked
    Check Cell Availability Status is online after commissioning    ${CELL_NUMBER}

[1]5GC000772_C_5_SA-classical-cmw-TDD_counters_UeSupportsDRX
    [Teardown]    Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
    ...   CAMPAIGN_NAME=${CAMPAIGN_NAME_5}
    Run Keywords    Set two parameters for case
    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease.sm
    ...    feature1877_772_C_SA_F1_CallEstablishmentAndRelease.sm    AND
    ...    Generic Suite Setup For one call during Activating DRX    CAMPAIGN_NAME=${CAMPAIGN_NAME_5}
    ...    CELL_NUMBER=${CELL_NUMBER}    attach_mode=5G_SA

    Log to console    checkFeature_1877_772_C_05
    ${result}=                         mylib772.checkFeature_1877_772_C_05    ${checkDrxRatio}

[1]5GC000772_C_9_SA-classical-cmw-TDD_CallRelease_UeSupportsDRX
    [Teardown]    Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
    ...   CAMPAIGN_NAME=${CAMPAIGN_NAME_5}
    Log to console    checkFeature_1877_772_C_09_SA
    ${result}=                         mylib772.checkFeature_1877_772_C_09_SA    ${5GLoadVersion}

#[1]5GC000772_C_12_SA-classical-cmw-TDD_onlineFeatureModification
#    [Teardown]    Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_12}
#
#    Run Keywords    Set two parameters for case
#    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease.sm
#    ...    feature1877_772_C_SA_F1_CallEstablishmentAndRelease.sm    AND
#    ...    Generic Suite Setup For Two Calls   CAMPAIGN_NAME=${CAMPAIGN_NAME_12}     CELL_NUMBER=${CELL_NUMBER}
#    ...    attach_mode=5G_SA
#
#    Log to console    checkFeature_1877_772_C_12_SA
#    ${result}=    mylib772.checkFeature_1877_772_C_12_SA  ${1stCallCounterCheck}  ${2ndCallCounterCheck}
#    ...    ${5GLoadVersion}
#
#[1]5GC000772_C_15_SA-classical-cmw-TDD_multiUe_DrxStartOffset
#    [Teardown]    Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_15}
#
#    Run Keywords    Set two parameters for case
#    ...    feature1877_772_C_SA_NG_CallEstablishmentAndRelease.sm
#    ...    feature1877_772_C_SA_F1_CallEstablishmentAndRelease.sm    AND
#    ...    Generic Suite Setup For MultiUe   CAMPAIGN_NAME=${CAMPAIGN_NAME_15}     CELL_NUMBER=${CELL_NUMBER}
#    ...    attach_mode=5G_SA
#
#    Log to console    checkFeature_1877_772_C_15_SA
#    ${result}=                         mylib772.checkFeature_1877_772_C_15_SA    ${5GLoadVersion}


#[1]5GC000772_C_10_SA-classical-cmw-TDD_MSC_UeSupportsDRX_FeatureNotActive
#    [Teardown]    Run keywords    5GC000772_Keywords.Test Teardown    ${result}    AND    QCT Generic Test Teardown
#    ...    CAMPAIGN_NAME=${CAMPAIGN_NAME_10}
#
#    Run Keywords    Set two parameters for case
#    ...    feature1877_772_C_SA_NG_UeSupportsDRX_FeatureNotActive.sm
#    ...    feature1877_772_C_SA_F1_UeSupportsDRX_FeatureNotActive.sm    AND
#    ...    Generic Suite Setup For one call    CAMPAIGN_NAME=${CAMPAIGN_NAME_10}
#    ...    CELL_NUMBER=${CELL_NUMBER}    attach_mode=5G_SA
#
#    Log to console    checkFeature_1877_772_C_10_SA
#    ${result}=                         mylib772.checkFeature_1877_772_C_10_SA    ${5GLoadVersion}
