*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1 10_5_UTESRAN22259
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library    taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB012098/CB012098.robot
Resource    ../SWM/CB007500/CB007500.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS25R3
${Target SW dir}       /home/ute/btsauto/TARGET_SW


*** Test Cases ***
ST_02_02_execute SW activation from MantaRay failed when pdl ERR detected
    [Tags]    QC_204240     10_5_UTESRAN22259
    [Setup]     CB012098 setup
    [Timeout]    150min
    Execute SW activation from MantaRay failed when pdl ERR detected
    [Teardown]  CB012098 teardown

ST_02_08_SW activation for DU only failed on MantaRay when PDL ERR detected
    [Tags]    QC_204239     10_5_UTESRAN22259
    [Setup]     CB012098 setup
    [Timeout]    150min
    SW activation for DU only failed on MantaRay when PDL ERR detected
    [Teardown]  CB012098 teardown

