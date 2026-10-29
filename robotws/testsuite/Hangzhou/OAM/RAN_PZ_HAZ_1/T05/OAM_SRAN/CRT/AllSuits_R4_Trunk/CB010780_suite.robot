*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB010780/CB010780_Independeng_DU_SWupgrade.robot


*** Variables ***
${target_release}    SBTS00

*** Test Cases ***
CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
    [Tags]    QC_105493   10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
#    Step1 prepare bts and choose package
    [Teardown]    TC teardown

[1]CB010780_ST_05_07 Independent DU SW upgrade software activation_NMS
    [Tags]    QC_105526   10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    [1]CB010780_ST_05_07 Independent DU SW upgrade software activation_NMS
    [Teardown]    TC teardown

CB010780_ST_05_03 Independent DU SW upgrade Activate RU Software_reset sequentially
    [Tags]    QC_105498    10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_03 Independent DU SW upgrade Activate RU Software_reset sequentially
    [Teardown]    TC teardown

CB010780_ST_05_04 Independent DU SW upgrade Activate RU Software_reset simultaneously
    [Tags]    QC_107562    10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_04 Independent DU SW upgrade Activate RU Software_reset simultaneously
    [Teardown]    TC teardown

CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
    [Tags]    QC_107563    10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
    [Teardown]    TC teardown

CB010780_ST_05_13 Independent DU SW upgrade_SW provision for RU SW only by WEBEM
    [Tags]    QC_105521    10_5_UTESRAN288
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_13 Independent DU SW upgrade_SW provision for RU SW only by WEBEM
    [Teardown]    TC teardown

CB010780_ST_05_12 Independent DU SW upgrade_SW provision for RU SW only by NMS
    [Tags]    QC_105500    10_5_UTESRAN288
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_12 Independent DU SW upgrade_SW provision for RU SW only by NMS
    [Teardown]    TC teardown

CB010780_ST_05_14 Independent DU SW upgrade software activation_with disableSWUpdate=true
    [Tags]    QC_105500    10_5_UTESRAN288
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_14 Independent DU SW upgrade software activation_with disableSWUpdate=true
    [Teardown]    TC teardown
