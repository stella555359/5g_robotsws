*** Settings ***
Documentation     TRACE
Suite Setup       suite setup   skip_build_download=${TRUE}
Suite Teardown    suite teardown

Force Tags        SBTS00    QCD_MN_RAN     QCP_RAN_VRF    CA_RAN_PZ_HAZ_1  10_5_UTESRAN22259
Library    taf.sbts.oam.coam.admin
Resource    ../SWM/SWM__SW_download_and_activation__SBTS_to_SBTS.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Trace/UeHandler.robot
Resource    ../TRACE/LTE_TRACE.robot
Resource    ../TRACE/CB008779.robot
Resource    ../TRACE/LTE1308.robot
Resource    ../TRACE/LTE1501.robot
Resource    ../TRACE/LTE644.robot

*** Variables ***
${sw_package_path}     /home/ute/btsauto
${target_release}      SBTS00
${Target SW dir}       /home/ute/btsauto/TARGET_SW

*** Test Cases ***
Configuration of LTE2202 (Cell Trace with MAC extensions) and LTE3333 (PCMD) content in the same Trace Session
    [Documentation]    CB008779
    [Tags]    QC_119262     10_5_UTESRAN22259
    [Setup]     CB008779 setup
    [Timeout]    45min
    CB008779 verification
    [Teardown]  CB008779 teardown

Immediate MDT Basic Operation
    [Documentation]    LTE1308
    [Tags]    QC_33304     10_5_UTESRAN22259
    [Setup]     LTE1308 setup
    [Timeout]    30min
    LTE1308 Immediate MDT Basic Operation
    [Teardown]  LTE1308 teardown

#Subscriber and Equipment Trace
#    [Documentation]    SBA
#    [Tags]    QC_33340     10_5_UTESRAN22259
#    [Setup]     LTE644 setup
#    [Timeout]    30min
#    LTE644 Subscriber and Equipment Trace
#    [Teardown]  LTE644 teardown

#MDT with enhCellVendorSpecTracing
#    [Documentation]    MDT with enhCellVendorSpecTracing  on 4TRX TDD Radio
#    [Tags]    QC_33503     10_5_UTESRAN22259
#    [Setup]     LTE1501 setup
#    [Timeout]    30min
#    MDT with enhCellVendorSpecTracing on 4TRX TDD Radio
#    [Teardown]  LTE1501 teardown
