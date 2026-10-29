*** Settings ***
Documentation     CB008779
Suite Setup       suite setup   skip_build_download=${TRUE}
Suite Teardown    suite teardown

Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1  10_5_UTESRAN22259
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library    taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../TRACE/CB008779.robot


*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS00
${Target SW dir}       /home/ute/btsauto/TARGET_SW


*** Test Cases ***
Configuration of LTE2202 (Cell Trace with MAC extensions) and LTE3333 (PCMD) content in the same Trace Session
    [Documentation]    CB008779
    [Tags]    QC_119262     10_5_UTESRAN22259
    [Setup]     CB008779 setup
    [Timeout]    24h
    CB008779 verification
    [Teardown]  CB008779 teardown
