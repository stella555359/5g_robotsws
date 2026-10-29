*** Settings ***
Documentation    Author: tingting.1.liu@nokia-sbell.com
...    squad group:SG_06
...    Feature Sleeping cell
Suite Setup    TMO_Sleeping_Cell_Suite_Setup    is_commission=${True}
Test Teardown    TMO_Common_Case_Teardown    ue_index=${ue_index}
Force Tags    5G_RRM    SG_06

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/TMO/TMO_common_keywords.robot

*** Variables ***
${target_version}
${SBTS22R4_package_link}     https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/SBTS22R4_packages/
${package_link}     https://esisoj70.emea.nsn-net.net/artifactory/mnp5g-central-public/System_Release/
${package_version_1525-CA}      ${target_version}
${enb_target_ver}
${enb_target_sw}          ${enb_target_ver}

*** Test Cases ***
E2E_TL_Reset_with_HWF_deletion_sleeping_cell_check
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup       ue_index=${ue_index}    swconfig_flag=special_flag
    FOR    ${i}    IN RANGE    ${1}
        COAM Create log directory
        ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
        Modify Swconfig File   para_update=${swconfig_list}
        run keyword and ignore error    COAM Teardown gnb connections
        Wait Until Keyword Succeeds    1 min    5 sec   Connect to gnb coam via ssl
        coam.reset_site    wait_for_reconnection=${True}    connection=GNB_OAM    timeout=600
        sleep   5min
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.001
        ...                                   min_UL_percent=0.001
        ...                                   ue_index=${ue_index}
        ...                                   check_scell_tput=${False}
        ...                                   enb_index=${fdd_enb_index}
        ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
        ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}    ru_type=${ru_type}
        ${fdd_ru_type}    Set Variable If    '${tl_prefix}'=='T816'    AHFIB
        ...                              '${tl_prefix}'=='T080'    AHFII
        ...                              '${tl_prefix}'=='T073'    AHLOB
        ...                              '${tl_prefix}'=='T813'    AHLOB
        ${fdd_ru_index}    Set Variable If    '${tl_prefix}'=='T816'    5
        ...                                 '${tl_prefix}'=='T080'    6
        ...                                 '${tl_prefix}'=='T073'    3
        ...                                 '${tl_prefix}'=='T813'    3
        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte   whether_get_first_ru_only=${True}    ru_type=${fdd_ru_type}
        ...                      ru_index=${fdd_ru_index}     enb_index=${fdd_enb_index}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   enb_index=${fdd_enb_index}
        ...                                                   whether_do_barred_action=${True}    ue_index=${ue_index}
    END
    [Teardown]    Run Keywords    Backup And Delete Parameter Of Swconfig File    swconfig_modify=@{delete_flag}    AND
    ...                           Perform gNB Reset site and Wait Onair

E2E_TL_RU_Reset_with_sleeping_cell_check
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup     ue_index=${ue_index}
    FOR    ${i}    IN RANGE    ${1}
        ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
        Perform Special RU Reset    cell_type=nr    whether_get_first_ru_only=${True}    ru_type=${ru_type}
        sleep   5min
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.05
        ...                                   min_UL_percent=0.05
        ...                                   ue_index=${ue_index}
        ...                                   check_scell_tput=${False}
        ...                                   enb_index=${fdd_enb_index}
        ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}    ru_type=${ru_type}
        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte   whether_get_first_ru_only=${True}    ru_type=${ru_type}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
        ...      Verify 4G Non-CA Basic L3 Call One By One    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   enb_index=${0}
        ...                                                   whether_do_barred_action=${True}     ue_index=${ue_index}
    END

E2E_TL_Capacity_Module_Reset_with_sleeping_cell_check
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup     ue_index=${ue_index}
    FOR    ${i}    IN RANGE    ${1}
        Perform BBMOD From AEHC Or AZHL Reset
        sleep   5min
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.05
        ...                                   min_UL_percent=0.05
        ...                                   ue_index=${ue_index}
        ...                                   check_scell_tput=${False}
        ...                                   enb_index=${fdd_enb_index}
        ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
        ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}    ru_type=${ru_type}
        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte   whether_get_first_ru_only=${True}    ru_type=${ru_type}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${0}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
        ...      Verify 4G Non-CA Basic L3 Call One By One    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   enb_index=${0}
        ...                                                   whether_do_barred_action=${True}    ue_index=${ue_index}
    END

E2E_TL_Delta_Commissioning_With_Site_Reset_Required_sleeping_cell_check
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...                ue: ue1, l3 call ok without peak. using cell bar to switch SA/NSA call.
    ...                for T073 SA call: AEHC cell301/401, using mcs to adjust att value.
    ...                for T073 NSA call: LTE cell 1+301+401, using PA to adjust att value.
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup      ue_index=${ue_index}
    FOR    ${i}    IN RANGE    ${1}
        ${cur_actBeamControlImprovement1}    Get actBeamControlImprovement1 parameters in Gnb
        Update actBeamControlImprovement1 parameters with different value in Gnb   cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
        Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
        Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False}    Verify All Enbs Cell On Air
#        Connect to gnb coam via ssl    connection=GNB_OAM
#        Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=@{GNB_ALLOWED_FAULT}
        Run Keyword If     '${LTE_WHETHER_IN_GNB}'=='${False}'    Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Procedures.Verify CA Basic L3 Call    ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.05
        ...                                   min_UL_percent=0.05
        ...                                   ue_index=${ue_index}
        ...                                   check_scell_tput=${False}
        ...                                   enb_index=${fdd_enb_index}
        ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
        ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}    ru_type=${ru_type}
        ${fdd_ru_type}    Set Variable If    '${tl_prefix}'=='T816'    AHFIB
        ...                              '${tl_prefix}'=='T080'    AHFII
        ...                              '${tl_prefix}'=='T073'    AHLOB
        ...                              '${tl_prefix}'=='T813'    AHLOB
        ${fdd_ru_index}    Set Variable If    '${tl_prefix}'=='T816'    5
        ...                                 '${tl_prefix}'=='T080'    6
        ...                                 '${tl_prefix}'=='T073'    3
        ...                                 '${tl_prefix}'=='T813'    3
        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte   whether_get_first_ru_only=${True}    ru_type=${fdd_ru_type}
        ...                      ru_index=${fdd_ru_index}     enb_index=${fdd_enb_index}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   enb_index=${fdd_enb_index}
        ...                                                   whether_do_barred_action=${True}    ue_index=${ue_index}
    END
    Update actBeamControlImprovement1 parameters with origin value in Gnb    cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
    Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot
    [Teardown]     Run Keywords     Run Keyword And Ignore Error    TMO_Common_Case_Teardown      ue_index=${ue_index}    AND
    ...    Update actBeamControlImprovement1 parameters with origin value in Gnb    cur_actBeamControlImprovement1=${cur_actBeamControlImprovement1}
    ...    AND       Check GNB On Air And Unexpect Alarm Should Not Exist without snapshot

E2E_TL_Cell_Lock_Unlock_NR_with_sleeping_cell_check
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...                ue: ue1, l3 call ok without peak. using cell bar to switch SA/NSA call.
    ...                for T073 SA call: AEHC cell301/401, using mcs to adjust att value.
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup   ue_index=${ue_index}
    ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
    FOR    ${i}    IN RANGE    ${1}
        Perform Lock Or Unlock Single Cell On Special RU and Make Non-CA L3 call    cell_type=nr    ue_index=${ue_index}     ru_type=${ru_type}
    END
    [Teardown]    Run Keywords     Run Keyword And Ignore Error    Unlock Cells On Special RU    cell_type=nr    action=unlock    ru_type=${ru_type}
    ...                            AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown

E2E_TL_Cell_Block_Unblock_NR_with_sleeping_cell_check
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...                ue: ue1, l3 call ok without peak. using cell bar to switch SA/NSA call.
    ...                for T073 SA call: AEHC cell301/401, using mcs to adjust att value.
    [Tags]    T080_QC    T813_QC    T816_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup   ue_index=${ue_index}
    ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
    FOR    ${i}    IN RANGE    ${1}
        Perform Block Or Unblock Single Cell On Special RU and Make Non-CA L3 call    cell_type=nr    ue_index=${ue_index}    ru_type=${ru_type}
    END
    [Teardown]    Run Keywords     Run Keyword And Ignore Error    Unlock Cells On Special RU    cell_type=nr    action=unblock   ru_type=${ru_type}
    ...                            AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown

E2E_TL_Cell_Lock_Unlock_LTE_with_sleeping_cell_check
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...                ue: ue1, l3 call ok without peak. using cell bar to switch SA/NSA call.
    ...                for T073 NSA call: AHFIB cell1/11/111.
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup    ue_index=${ue_index}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    FOR    ${i}    IN RANGE    ${1}
        ${fdd_ru_type}    Set Variable If    '${tl_prefix}'=='T816'    AHFIB
        ...                              '${tl_prefix}'=='T080'    AHFII
        ...                              '${tl_prefix}'=='T073'    AHLOB
        ...                              '${tl_prefix}'=='T813'    AHLOB
        ${fdd_ru_index}    Set Variable If    '${tl_prefix}'=='T816'    5
        ...                                 '${tl_prefix}'=='T080'    6
        ...                                 '${tl_prefix}'=='T073'    3
        ...                                 '${tl_prefix}'=='T813'    3
        Perform Lock Or Unlock LTE Cell On Special RU and Make LTE L3 call
        ...            cell_type=lte    ru_type=${fdd_ru_type}     ue_index=${ue_index}     ru_index=${fdd_ru_index}     enb_index=${fdd_enb_index}
    END
    [Teardown]    Run Keywords     Run Keyword And Ignore Error    Unlock Cells On Special RU
    ...                            cell_type=lte    ru_type=${fdd_ru_type}    action=unlock     ru_index=${fdd_ru_index}
    ...           AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown      ue_index=${ue_index}

E2E_TL_Cell_Block_Unblock_LTE_with_sleeping_cell_check
    [Documentation]    author: lei.jia@nokia-sbell.com
    ...                ue: ue1, l3 call ok without peak. using cell bar to switch SA/NSA call.
    ...                for T073 NSA call: AHFIB cell1/11/111.
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup    ue_index=${ue_index}
    ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
    FOR    ${i}    IN RANGE    ${1}
        ${fdd_ru_type}    Set Variable If    '${tl_prefix}'=='T816'    AHFIB
        ...                              '${tl_prefix}'=='T080'    AHFII
        ...                              '${tl_prefix}'=='T073'    AHLOB
        ...                              '${tl_prefix}'=='T813'    AHLOB
        ${fdd_ru_index}    Set Variable If    '${tl_prefix}'=='T816'    5
        ...                                 '${tl_prefix}'=='T080'    6
        ...                                 '${tl_prefix}'=='T073'    3
        ...                                 '${tl_prefix}'=='T813'    3
        Perform Block Or Unblock LTE Cell On Special RU and Make LTE L3 call
        ...            cell_type=lte    ru_type=${fdd_ru_type}    ru_index=${fdd_ru_index}      enb_index=${fdd_enb_index}    ue_index=${ue_index}
    END
    [Teardown]    Run Keywords     Run Keyword And Ignore Error    Unlock Cells On Special RU
    ...                            cell_type=lte    ru_type=${ru_type}    action=unblock      ru_index=${fdd_ru_index}
    ...           AND    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index}

E2E_TL_SW_upgrade_rollback_with_sleeping_cell_check
    [Tags]    T080_QC    T813_QC    T073_QC
    [Setup]  TMO_Common_Case_Setup     ue_index=${ue_index}
    log to console    --- start to download sw build from artifactory---
    Set Test Variable    ${upgrade_package_path}    /home/ute/${package_version_1525-CA}_release_BTSSM_downloadable_A54.zip
    Set Test Variable    ${enb_upgrade_package_path}    /home/ute/${enb_target_sw}_release_BTSSM_downloadable_A54.zip
    ${gnb_up}    Set Variable If    '${package_version_1525-CA}'==''      false    true
    ${enb_up}    Set Variable If    '${enb_target_sw}'==''      false    true
    Set Test Variable    ${whether_gnb_up}    ${gnb_up}
    Set Test Variable    ${whether_enb_up}    ${enb_up}
    log to console    --- start to download sw build from artifactory---
    Check Rollback is needed before sw upgrade
    Check Enb Rollback is needed before sw upgrade
    Check TMO Gnb Ready And All Cell On Air
    Verify All Enbs Cell On Air
    Run Keyword And Continue On Failure    run keyword If    '${whether_gnb_up}'=='true'    Download SW Build from artifactory
    Run Keyword And Continue On Failure    run keyword If    '${whether_enb_up}'=='true'    Download SW Build from artifactory
    ...                                    target_version=${enb_target_sw}
    FOR    ${i}    IN RANGE    ${1}
        Log To Console    ${\n}INFO:-- start to upgrade gnb/enb time_${i}--
        run keyword If    '${whether_enb_up}'=='true'    Enb Upgrade Only
        wait until keyword succeeds     5 min   10 sec     Connect to gnb coam via ssl
        run keyword If    '${whether_gnb_up}'=='true'    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200
        ...               connection=GNB_OAM
        Run Keyword And Ignore Error    COAM Teardown gnb connections
        sleep  5min
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
        ${fdd_enb_index}    Select ENB Index based on LTE Technology    used_enb_technology=FDD
        Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call
        ...                                   ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.01
        ...                                   min_UL_percent=0.01
        ...                                   min_scell_percent=0.05
        ...                                   ue_index=${ue_index}
        ...                                   check_scell_tput=${False}
        ...                                   enb_index=${fdd_enb_index}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
        ${ru_type}    Set Variable If    '${tl_prefix}'=='T816'        AZHL    AEHC
        ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}     ru_type=${ru_type}
        ${fdd_ru_type}    Set Variable If    '${tl_prefix}'=='T816'    AHFIB
        ...                              '${tl_prefix}'=='T080'    AHFII
        ...                              '${tl_prefix}'=='T073'    AHLOB
        ...                              '${tl_prefix}'=='T813'    AHLOB
        ${fdd_ru_index}    Set Variable If    '${tl_prefix}'=='T816'    5
        ...                                 '${tl_prefix}'=='T080'    6
        ...                                 '${tl_prefix}'=='T073'    3
        ...                                 '${tl_prefix}'=='T813'    3
        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte   whether_get_first_ru_only=${True}    ru_type=${fdd_ru_type}
        ...                      ru_index=${fdd_ru_index}     enb_index=${fdd_enb_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   enb_index=${fdd_enb_index}
        ...                                                   whether_do_barred_action=${True}    ue_index=${ue_index}
        Log To Console    ${\n}INFO:-- start to do GNB rollback --
        Check Rollback is needed before sw upgrade
        Check Enb Rollback is needed before sw upgrade
        sleep  5min
        Check GNB On Air And Unexpect Alarm Should Not Exist
        Check ENB On Air And Unexpect Alarm Should Not Exist
        Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}
        Log To Console    ${\n}INFO:-- start to do L3 call --
        Run Keyword And Continue On Failure    Procedures.Verify CA Basic L3 Call
        ...                                   ue_mode=NSA
        ...                                   ul_throughput=150M
        ...                                   dl_throughput=2500MKbits/sec
        ...                                   notbarred_cell_index=all
        ...                                   b1_select_cell_index=${PCELL_INDEX}
        ...                                   exp_status=barred
        ...                                   whether_do_lte_barred_action=${True}
        ...                                   whether_check_scell_addition=${False}
        ...                                   tput_collect_duration=60
        ...                                   ignore_time=15sec
        ...                                   target_DL_avg_percent=0.1
        ...                                   target_UL_avg_percent=0.1
        ...                                   min_DL_percent=0.01
        ...                                   min_UL_percent=0.01
        ...                                   ue_index=${ue_index}
        ...                                   check_scell_tput=${False}
        ...                                   enb_index=${fdd_enb_index}
        ${aehc_nr_cell_list}    Get Cell List For Special RU    cell_type=nr    whether_get_first_ru_only=${True}    ru_type=${ru_type}
        ${fdd_ru_type}    Set Variable If    '${tl_prefix}'=='T816'    AHFIB
        ...                              '${tl_prefix}'=='T080'    AHFII
        ...                              '${tl_prefix}'=='T073'    AHLOB
        ...                              '${tl_prefix}'=='T813'    AHLOB
        ${fdd_ru_index}    Set Variable If    '${tl_prefix}'=='T816'    5
        ...                                 '${tl_prefix}'=='T080'    6
        ...                                 '${tl_prefix}'=='T073'    3
        ...                                 '${tl_prefix}'=='T813'    3
        ${aehc_lte_cell_list}    Get Cell List For Special RU    cell_type=lte   whether_get_first_ru_only=${True}    ru_type=${fdd_ru_type}
        ...                      ru_index=${fdd_ru_index}     enb_index=${fdd_enb_index}
        Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=barred    enb_index=${fdd_enb_index}
        Verify Non-CA Basic L3 Call One By One    cell_list=${aehc_nr_cell_list}    ue_type=${ue_type}    ue_index=${ue_index}
        ...                                   enb_index=${fdd_enb_index}
        Verify 4G Non-CA Basic L3 Call One By One    cell_list=${aehc_lte_cell_list}   ue_type=${ue_type}   enb_index=${fdd_enb_index}
        ...                                                   whether_do_barred_action=${True}     ue_index=${ue_index}
    END
    [Teardown]    Run Keyword And Ignore Error    TMO_Common_Case_Teardown    ue_index=${ue_index}
