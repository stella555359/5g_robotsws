*** Settings ***
Suite Setup       suite setup   skip_build_download=${TRUE}
Suite Teardown    suite teardown

Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1
Library       ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/ta_xml_interface.py
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Library    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/tool_ping.py
Library    taf.sbts.oam.coam.admin
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../TRACE/CB008411.robot

Documentation    CB008411 for AP

*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS00
${Target SW dir}       /home/ute/btsauto/TARGET_SW

*** Test Cases ***
CB008411 Activation of the Subscriber Trace with PCMD content
    [Documentation]    CB008411 for CNI-127255
    [Tags]    QC_99779
    [Setup]     CB008411 setup For AP
    [Timeout]    45min
    Activation of the Subscriber Trace with PCMD content related to CB008411 AP
    [Teardown]  CB008411 teardown For AP

PCMD Records from gNB-CU-UP in SBA Session for a UE
    [Documentation]    CB008411 for CNI-127255
    [Tags]    QC_99780
    [Setup]     CB008411 setup For AP
    [Timeout]    45min
    CB008411-B B01 PCMD Records from gNB-CU-UP in SBA Session for a UE AP
    [Teardown]  CB008411 teardown For AP
