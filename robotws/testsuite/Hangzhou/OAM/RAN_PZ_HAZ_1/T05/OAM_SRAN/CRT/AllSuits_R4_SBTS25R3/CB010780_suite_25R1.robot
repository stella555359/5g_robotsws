*** Settings ***
Documentation     [PURPOSE]
Suite Setup       hran_frame_sbts.suite setup    #for debug
Suite Teardown    hran_frame_sbts.suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_ST    CA_RAN_PZ_HAZ_1
Library           ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/verdict.py
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource          ../SWM/CB010780/CB010780_Independeng_DU_SWupgrade.robot


*** Variables ***
${target_release}    SBTS25R3

*** Test Cases ***
CB007500_ST_05_06_Software management procedures on D&RSW
    [Tags]    QC_33416
    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
    ${release}=    Evaluate    "${target_release}"[4:]
    ${SWRelease}    taf.sbts.oam.coam.admin.get_sw_release_name
    run keyword if    '${SWRelease}'!='${target_release}'    prepare pre release build on SBTS    ${release}    ${SW_path_T2_package}
    [Teardown]  TC teardown

CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
    [Tags]    QC_204246   10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
    [Teardown]    TC teardown

CB010780_ST_05_04 Independent DU SW upgrade Activate RU Software_reset simultaneously
    [Tags]    QC_204243    10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_04 Independent DU SW upgrade Activate RU Software_reset simultaneously
    [Teardown]    TC teardown

CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
    [Tags]    QC_204244    10_5_UTESRAN288    SWM
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
    [Teardown]    TC teardown

CB010780_ST_05_13 Independent DU SW upgrade_SW provision for RU SW only by WEBEM
    [Tags]    QC_204245    10_5_UTESRAN288
    [Setup]    run keywords    NR_Switch_Open
    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
    ...    AND    TC setup
    CB010780_ST_05_13 Independent DU SW upgrade_SW provision for RU SW only by WEBEM
    [Teardown]    TC teardown