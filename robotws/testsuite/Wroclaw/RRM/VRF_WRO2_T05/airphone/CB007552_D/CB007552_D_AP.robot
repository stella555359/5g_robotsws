*** Settings ***
Force Tags    RAN_5G    SBTS00    NoResUsage    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :authors: Tomasz Dabrowski
...             :contact: tomasz.dabrowski@nokia.com

Resource        taf/rfrl/common_resources/robot/libraries_instances.robot
Resource        testsuite/Wroclaw/RRM/resources/airphone/scout_reporting/reporting_portal.robot

Library     ../../../resources/scout_report.py
Resource    ../keywords/traffic.robot
Resource      testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_testline_management
Library     ta5g_enb
Library     ta5g_iphy
Library     ute_wtssim
Library     ta5g_ue_mobility
Library     ta5g_pm_counters

Suite Setup        Run Keywords
...                                Put Swconfig File    ${SW_CONFIG}
...                AND             Update And Put Iphy Xml         input_filepath=${IPHY}
...                AND             Find Scfc And Fix And Send Full Commissioning
...                                scfc_filename=${SCFC}
...                AND             Reach Onair    lua_cfg=${EGATE}

Test Setup    Run Keywords
...                Start Syslog For Enb
...                AND             Wait For Next Full Pm Interval


*** Variables ***
${SW_CONFIG}                ${CURDIR}/config/swconfig.txt
${SCFC}=                    scfc.xml
${IPHY}=                    ${CURDIR}/config/iphy_FDD_2cells_SA_L1B_n25_n66.xml
${EGATE}=                   ${CURDIR}/config/egate_FDD_2Cells_SA_n25_n66.lua
${LOCAL_MOID}=              PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
${ue_id}=                   5

*** Test Cases ***
[1]CNI_78446_B_3_RRC_connection_reestablishment_via_RRC_Setup_to_the_serving_cell_to_large_BWP
    Register UE
    Establish Pdu Session With Traffic      ue_id=${ue_id}    throughput=60mbps
    Verify That Correct BWP Profile Was Selected For The UE
    Initiate Ue Rrc Reestablishment         ue_id=${ue_id}
    Verify Pm Counters                      local_moid=${LOCAL_MOID}
    [Teardown]     Run Keywords
     ...           Deregister UE    ue_id=${ue_id}
     ...    AND    Add Scout Scf Id To Test Data
     ...    AND    Stop Default Processes And Gather Logs And Compress Logs

*** Keywords ***
Register UE
    ta5g_ue_mobility.attach ue    ue_id=${ue_id}

Verify Pm Counters
    [Arguments]    ${local_moid}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=    Get Latest Unpacked Full Pm Counters File
    Verify Any Counters In File
        ...    M55166C00002    2     NRRC_RRC_RECONF_BWP2_SENT
        ...    M55166C00004    2     NRRC_RCFG_CMP_BWP2_RCVD
        ...    M55139C02502    2     GNB_SA_DU_ADM_SUCC_BWP2
        ...    M55124C00502    1     RRC_REESTAB_FALLBACK
        ...    M55124C00505    1     RRC_REESTAB_OTHER_FAILURE
        ...    local_moid=${local_moid}
        ...    file_path=${pm_counter_file}

Verify That Correct BWP Profile Was Selected For The UE
    Wait For Specified Message In Syslog    selectedBwpprofile ID:4
    Wait For Specified Message In Syslog    selectedBwpprofile ID:37

Verify That Fallback Reestablishment Was Triggered
    Wait For Specified Message In Syslog    RrcReestablishmentRequest
    Wait For Specified Message In Syslog    Fallback-type Reestablish selected for PhyCellId



