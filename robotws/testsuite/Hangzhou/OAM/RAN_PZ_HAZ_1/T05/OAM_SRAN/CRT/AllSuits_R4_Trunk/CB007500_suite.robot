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
Resource    ../SWM/CB007500/CB007500.robot
Resource    ../SWM/CB007500/CB007500ET.robot
# Resource    ../SWM/CB007500/LTE4034.robot
Resource    ../SWM/CB010738/CB010738.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS00
${Target SW dir}       /home/ute/btsauto/TARGET_SW  #


*** Test Cases ***
CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Tags]    QC_581840    ASIM
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    # CB007500_ST_05_01_PNP start with reset to D&RSW by GPS
    [Teardown]  CB007500 TC teardown

CB007500_ST_05_05_PNP start with configuration reset to D&RSW with Multi_NMS
    [Tags]    QC_581823
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_05_PNP start with configuration reset to D&RSW with Multi_NMS
    [Teardown]  CB007500 TC teardown

CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Tags]    QC_33417      3_5_UTE4G502
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
    [Timeout]    3600s
    CB007500_ST_05_02_PNP start with configuration reset to D&RSW by DHCP with siteID
    [Teardown]  CB007500 TC teardown

CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_ASIL_WEBEM
    [Tags]    QC_60231    ASOH
    [Setup]     run keywords    set library search order
    ...    CB007335_02_01_Copy_BTS_SW_and_configuration_from_ac_to_pa_par_WithoutHealthCheck    AND    TC Setup
    [Timeout]    3600s
    TC_CB007335_02_01_Copy_BTS_SW_and_configuration_from_active_to_passive_partition_WithoutHeatlthCheck
    [Teardown]  TC teardown

CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Tags]    QC_33418
    [Setup]    run keywords    set library search order    CB007500ET  CB007500    AND    TC Setup
#   [Timeout]    1800s
    CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Teardown]  TC teardown

LTE4034_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Tags]    QC_33440
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#   [Timeout]    8000s
    LTE4034_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
    [Teardown]   TC teardown

CB007500_ST_05_06_Software management procedures on D&RSW
    [Tags]    QC_33416
    [Setup]     run keywords    set library search order    CB007500ET    AND    TC Setup
#   [Timeout]    3600s
    CB007500_ST_05_06_Software management procedures on D&RSW
    [Teardown]  TC teardown
