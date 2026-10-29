*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup
Suite Teardown    suite teardown
Force Tags        SBTS25R3    QCD_MN_RAN     QCP_RAN_VRF   CA_RAN_PZ_HAZ_1   3_5_UTE4G204/3_5_UTE4G502
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library    taf.sbts.oam.coam.admin
Library    xml
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py

Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../SWM/CB007500/CB007500.robot
Resource    ../SWM/CB007500/CB007500ET.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS25R3
${Target SW dir}       /home/ute/btsauto/TARGET_SW  #


*** Test Cases ***
#CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
#    [Tags]    QC_547593
#    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    3600s
#    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less
#    [Teardown]  TC teardown

[1]CB008962_configuration reset to D&RSW
    [Tags]    QC_204172
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    3600s
    CB007500_ST_05_01_PNP start with configuration reset to D&RSW by DHCP-less_kpi
    ${ConfigReset_KPI_check}=  Operation_KPI_Check  ${ConfigResetEndTime}  ${ConfigResetStartTime}  ${ConfigReset_expect_time}  ConfigReset_BTS_KPI
    [Teardown]  TC teardown

[1]CB007215_ST_PnP_05_01 Autoconnection Performance (e2e) less than 10min
    [Tags]    QC_204171
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    600s
    ${Autoconn_KPI_check}=    Operation_KPI_Check    ${AutoconnEndTime}    ${AutoconnStartTime}    ${Autoconn_expect_time}    Autoconn_BTS_KPI
    set suite variable    ${Autoconn_KPI_check}
    [Teardown]  TC teardown

[1]CB007215_ST_PnP_05_04 Autoconfiguration performance (provision of target SW and configuration plan)
    [Tags]    QC_204170
    [Setup]    run keywords    set library search order    CB007500    AND    TC Setup
#    [Timeout]    600s
    ${Autoconf_KPI_check}=    Operation_KPI_Check    ${AutoconfEndTime}    ${AutoconfStartTime}    ${Autoconf_expect_time}    Autoconf_BTS_KPI
    set suite variable    ${Autoconf_KPI_check}
    [Teardown]  TC teardown
