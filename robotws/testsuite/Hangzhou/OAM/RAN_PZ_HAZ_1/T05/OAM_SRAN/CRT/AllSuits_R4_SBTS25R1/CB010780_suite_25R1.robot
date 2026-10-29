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
${target_release}    SBTS25R1

#*** Test Cases ***
#CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
#    [Tags]    QC_111124   10_5_UTESRAN288    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
#    ...    AND    TC setup
#    CB010780_ST_05_02 Independent DU SW upgrade Activate RU Software from NMS
##    Step1 prepare bts and choose package
#    [Teardown]    TC teardown
#
#CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
#    [Tags]    QC_111120    10_5_UTESRAN288    SWM
#    [Setup]    run keywords    NR_Switch_Open
#    ...    AND    Set Library Search Order    CB010780_Independeng_DU_SWupgrade
#    ...    AND    TC setup
#    CB010780_ST_05_06 Independent DU SW upgrade software Activate WEBUI
#    [Teardown]    TC teardown
