*** Settings ***
Documentation    CM FM PM kpi testing DU
...              authors: Lukasz Rzodeczko
...              maintainer: Lukasz Rzodeczko
...              contact: lukasz.rzodeczko@nokia.com
...              The purpose of test suite is test CM FM PM KPIs on DU.

Library    OperatingSystem
Library    testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB007726.resources.resources.RfswLogs
Resource    taf/rfrl/bts/robot/gnb.robot


Force Tags    STATE_SW_UPLOADED

*** Test Cases ***

CB007726-A_n_6_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    ${snapshot_path}   gnblog.Collect Snapshot
    @{gen_1_prrh}   Create list    AHENA    AHENB
    ${gen_2_prrh}   Set Variable   AWHHC
    find_mandatory_rfsw_logs_in_snapshot_ASIR   ${snapshot_path}    ${gen_1_prrh}    ${gen_2_prrh}
    [Teardown]    OperatingSystem.Run   rm ${snapshot_path}

