*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1   3_5_UTE4G204/3_5_UTE4G502
Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library     ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library     taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB007500/CB007500.robot
Resource    ../SWM/CB007500/CB007500ET.robot
# Resource    ../SWM/CB007500/LTE4034.robot

*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS25R3
${Target SW dir}       /home/ute/btsauto/TARGET_SW  #

#*** Test Cases ***
#CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
#    [Tags]    QC_83677      3_5_UTE4G502
#    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    3600s
#    CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
#    [Teardown]  CB007500 TC teardown
#
#CB007500_ST_05_06_Software management procedures on D&RSW
#    [Tags]    QC_83676
#    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
#    [Timeout]    3600s
#    CB007500_ST_05_06_Software management procedures on D&RSW
#    [Teardown]  TC teardown
#
#CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
#    [Tags]    QC_83748
#    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
#    [Timeout]    3600s
#    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
#    [Teardown]  TC teardown
