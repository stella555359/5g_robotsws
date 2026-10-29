*** Settings ***
Documentation     [PURPOSE]
Suite Setup       suite setup   skip_build_download=${TRUE}
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
Resource    ../SWM/CB007500/CB007500.robot
Resource    ../SWM/CB010738/CB010738.robot
Resource    ../SWM/CB007500/CB007500ET.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}     SBTS25R3
${Target SW dir}       /home/ute/btsauto/TARGET_SW


*** Test Cases ***
IP change after DHCP renewal
    [Tags]    QC_204192     10_5_UTESRAN22259
    [Setup]     CB010738 setup
    [Timeout]    150min
    CB010738 PnP with DHCP and Followed by DHCP IP Change
    [Teardown]  CB010738 teardown

Fault 61678 with Failure in refreshing the lease of the DHCP-assigned IP
    [Tags]    QC_204191     10_5_UTESRAN22259
    [Setup]     CB010738 setup
    [Timeout]    150min
    CB010738 PnP with DHCP and Followed by DHCP Renewal Failure
    [Teardown]  CB010738 teardown
