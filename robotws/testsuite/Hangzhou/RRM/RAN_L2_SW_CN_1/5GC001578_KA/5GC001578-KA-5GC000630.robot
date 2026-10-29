*** Settings ***
Documentation    ...
#Documentation     author: LI Min
#...               contact: min.b.li@nokia-sbell.com
#
#Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
#Library    taf.transport.ssh    WITH NAME    ssh
#Library    ute_wtssim    WITH NAME    wts
#Resource          keywords_common.robot
#
#Suite Setup    Create Test Suite Folder
#Suite Teardown    Test Suite End
#Test Setup    Create Test Case Folder
#
#
#*** Variables ***
#
#
#*** Test Cases ***
#5GC000630_B_02_Verify_DL_data_transfer_to_UE_by_flow_control_during_air_interface_congestion
#     [Tags]    Cloud    CRT_HNZ    5GC001578-KA    FR1    QCD_MN_5G    QCP_5G
#     ...    IPV4    IPV6    CN1    5G20B       Owner_minbl    PRI-Medium
#     ...    Airphone
#     [Setup]
#     Reboot gNB_ASIK
#     sleep    300s
#     Download SCF and backup
#     Modify SCF nokiaFlowControl
#     Import scf     ${testCaseDir}/Modify_scf.xml
#     Reboot AP
#     sleep    600s
#     Active LTE Emu Cfg Until Cell Onair and F1 Link Setup
#     Ue Attach
#     sleep    5s
#     Start Traffic and Modify CQI
#     Stop Traffic in WTS
#     sleep     5s
#     Import scf    ${testCaseDir}/Original_scf.xml
#     sleep     120s
#     WEB logout
#     [Teardown]    Teardown egate and WTS
#
#5GC000630_C_02_Verify_3GPP_flow_control_for_GTP-U_DL_data_transmission_during_air_interface_congestion
#    [Tags]    Cloud    CRT_HNZ    5GC001578-KA    FR1    QCD_MN_5G    QCP_5G
#    ...    IPV4    IPV6    CN1    5G20B       Owner_minbl    PRI-Medium
#    ...    Airphone
#    [Setup]
#    Reboot gNB_ASIK
#    sleep    600s
#    Download SCF and backup
#    Modify SCF 3GPPFlowControl
#    Import scf     ${testCaseDir}/Modify_scf
#    Reboot AP
#    sleep    600s
#    Active LTE Emu Cfg Until Cell Onair and F1 Link Setup
#    Ue Attach
#    sleep    5s
#    Start Traffic and Modify CQI
#    Stop Traffic in WTS
#    sleep     20s
#    Rollback the Original SCF
#    sleep     120s
#    [Teardown]    Teardown egate and WTS
