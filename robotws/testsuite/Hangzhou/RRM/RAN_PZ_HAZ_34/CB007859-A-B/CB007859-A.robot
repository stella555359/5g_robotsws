*** Settings ***
Documentation     author: y63li
...               contact: ying.15.li@nokia-sbell.com
...               squad group: MMW_SG3

Force Tags        CRT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2
...    PY36

Suite Setup       CB007859_Common Suite Setup for COAM
Suite Teardown    CB007859_Common Suite Teardown for COAM

Resource       Resources/CB007859_Common_Keywords.robot
*** Variables ***
${TS_CASE_LOG_PATH}   /home/ute/log

*** Test Cases ***
[1] CB007859-A_001_DL_UL_scheduling_5MHz_NSA_below_3cells
    [Setup]    Case Setup      chbw=${5}
    Run CB007859_NSA_Case
    [Teardown]    Case Teardown

#[1]CB007859-A_003_DL_UL_scheduling_10MHz_NSA_below_3cells
#    [Setup]    Case Setup    chbw=${10}
#    Run CB007859_NSA_Case
#    [Teardown]    Case Teardown

[1]CB007859-A_006_DL_UL_scheduling_15MHz_SA_below_3cells
    [Setup]    Case Setup    chbw=${15}
    Run CB007859_SA_Case
    [Teardown]    Case Teardown

#[1]CB007859-A_008_DL_UL_scheduling_20MHz_SA_below_3cells
#    [Setup]    Case Setup    chbw=${20}
#    Run CB007859_SA_Case
#    [Teardown]    Case Teardown
#
#[1]CB007859-A_010_DL_UL_scheduling_30MHz_SA_below_3cells
#    [Setup]    Case Setup    chbw=${30}
#    Run CB007859_SA_Case
#    [Teardown]    Case Teardown

#[1]CB007859-A_014_DL_UL_scheduling_5MHz_SA_above_3cells
#    [Setup]    Case Setup for max cell   chbw=${5}
#    Run CB007859_SA_Case
#    [Teardown]    Case Teardown

#[1]CB007859-A_016_DL_UL_scheduling_10MHz_SA_above_3cells
#    [Setup]    Case Setup for max cell    chbw=${10}
#    Run CB007859_SA_Case
#    [Teardown]    Case Teardown
#
#[1]CB007859-A_017_DL_UL_scheduling_15MHz_NSA_above_3cells
#    [Setup]    Case Setup for max cell   chbw=${15}
#    Run CB007859_NSA_Case
#    [Teardown]    Case Teardown

[1]CB007859-A_019_DL_UL_scheduling_20MHz_NSA_above_3cells
    [Setup]    Case Setup for max cell    chbw=${20}
    Run CB007859_NSA_Case
    [Teardown]    Case Teardown

[1]CB007859-A_025_UCI_on_PUSCH_DRX_disable_without_data_transmission_SA
    [Setup]    Case Setup for max cell    chbw=${20}
    Connect to DU via ssl
    Configure actAperCsi to true
    Run CB007859_SA_Case
    Check target DL Report CSI   tti_csv_dir=${path}
    [Teardown]    Case Teardown

*** Keywords ***
