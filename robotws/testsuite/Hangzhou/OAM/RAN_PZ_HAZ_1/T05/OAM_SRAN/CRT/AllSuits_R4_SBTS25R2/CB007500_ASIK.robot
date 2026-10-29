*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R2    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1  3_5_UTE4G204/3_5_UTE4G502
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library    taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB007500/CB007500.robot
Resource    ../SWM/CB007500/CB007500ET.robot


*** Variables ***
#${sw_package_path}     /home/ute/btsauto/BASE_SW  #
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS25R2
${Target SW dir}       /home/ute/btsauto/TARGET_SW  #


*** Test Cases ***
CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Tags]    QC_146482    ASIK
    [Setup]    run keywords    set library search order    CB007500    AND    Common Test Setup
    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    #CB007500_ST_05_01_PNP start with reset to D&RSW by GPS
    [Teardown]  ASIK TC teardown
