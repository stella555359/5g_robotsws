*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1  3_5_UTE4G204/3_5_UTE4G502
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library    taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB007335/CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck.robot
Resource    ../SWM/CB007500/CB007500ET.robot
# Resource    ../SWM/CB007500/LTE4034.robot
Resource    ../SWM/CB007500/CB007500.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS25R1
${Target SW dir}       /home/ute/btsauto/TARGET_SW  #


#*** Test Cases ***
#CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_ASIL_WEBEM
#    [Tags]    QC_83746    ASOG
#    [Setup]     run keywords    set library search order
#    ...    CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck    AND    TC Setup
#    [Timeout]    3600s
#    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
#    [Teardown]  TC teardown
#
#CB007500_ST_05_06_Software management procedures on D&RSW
#    [Tags]    QC_83747    ASOG
#    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
#    [Timeout]    5400s
#    CB007500_ST_05_06_Software management procedures on D&RSW
#    [Teardown]  TC teardown
#
#CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
#    [Tags]    QC_83748    ASOG
#    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    7200s
#    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
#    # CB007500_ST_05_01_PNP start with reset to D&RSW by GPS
#    [Teardown]  CB007500 TC teardown
