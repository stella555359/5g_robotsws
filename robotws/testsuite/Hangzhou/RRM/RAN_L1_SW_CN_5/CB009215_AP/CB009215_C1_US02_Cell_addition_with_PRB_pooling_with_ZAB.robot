*** Settings ***
Documentation
...    Author: Huang Shujun
...    Contact: shujun.j.huang@nokia-sbell.com
...    Feature: CB009215_C1
...    Release: 24R1
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    Regression    CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD    CB009215    QCD_MN_RAN    QCP_RAN_RF

Library    taf.selenium.sbts  WITH NAME  selenium_coam
Library           taf.pdu    WITH NAME    pdu
Library           taf.transport.ssh    WITH NAME    ssh
Resource    ../resources/Airphone/Airphone_resource.robot
Resource    ../resources/common_resource_bts.robot


*** Variables ***
&{vendor_new_values_dict}    maxNumLayerPrbL1Sp=424     maxNumStreamPrbL1Sp=424     maxNumWbStreamPrbL1Sp=288
&{vendor_orig_value_dict}    maxNumLayerPrbL1Sp=1272    maxNumStreamPrbL1Sp=1272    maxNumWbStreamPrbL1Sp=864
${btsid}    1
${active_sw}    SBTS24R1_ENB_9999_230910_000003
&{cell_info}
...    cell_id=10
...    lcrId=10
...    cell_group_id=10
...    nrarfcnDl=428000
...    nrarfcnUl=348000
...    gscnOrSsPbchArfcn=5350
...    physCellId=59
...    type0CoresetConfigurationIndex=7
...    prachConfigurationIndex=37
...    cell_id_to_copy_from=9
...    cellType=FDD
#configuration of Sixth Cell cell_id=10 base on cell_9

*** Test Cases ***
CB009215_C1_US02_Cell_addition_with_PRB_pooling_with_Zero-Allocation_symbol_Bypass_(ZAB)_functionality
    [Documentation]
    ...    This case is used to verify CB009215_C1_US02_Cell_addition_with_PRB_pooling_with_ZAB_functionality
    [Tags]    CB009215    CRT
    step1:UE attach to 5cells
    step2:add Sixth cell_10 to SP1
    step3:Start traffic data for 5G L3 call in cell_10
    step4:check ZAB print of cell_10 in syslog
    step5:5G L3 call throughput veriry
    [Teardown]    step6:UE stop data transfer and detach and recover vendor


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    update vendor file    ${vendor_new_values_dict}
    Setup Airphone Env  tl_type=AP_LOOO/fdd_sansa_cmwv/FS/5cells_cpri_FDD    cfg=wts.cfg

step1:UE attach to 5cells
    ue_register    ue_id=1    cell_id=1
    ue_register    ue_id=3    cell_id=3
    ue_register    ue_id=5    cell_id=5
    ue_register    ue_id=7    cell_id=7
    ue_register    ue_id=9    cell_id=9

step2:add Sixth cell_10 to SP1
    #add cell base on exist cell whcih connect to same RU, and NR_Cell_ID equal to Cell_GRP_ID
    Online Add Cell Based On Existing Cell    ${cell_info}
    Sleep    5s
    ue_register    ue_id=10    cell_id=10


step3:Start traffic data for 5G L3 call in cell_10
    Sleep    5s
    Perform Egate Command    command=trf_data_start ue=10 pdu=1 qfi=1 dir=dl burst=60 period_ms=4 size=1350 seconds=1800 trf_id=1
    ...    fail_regexp=isn't active/idle
    Perform Egate Command    command=trf_data_start ue=10 pdu=1 qfi=1 dir=ul burst=40 period_ms=4 size=1350 seconds=1800 trf_id=1
    ...    fail_regexp=isn't active/idle
    Perform Egate Command    command=trf_data_start ue=5 pdu=1 qfi=1 dir=dl burst=40 period_ms=4 size=1350 seconds=1800 trf_id=1
    ...    fail_regexp=isn't active/idle
    Perform Egate Command    command=trf_data_start ue=5 pdu=1 qfi=1 dir=ul burst=40 period_ms=4 size=1350 seconds=1800 trf_id=1
    ...    fail_regexp=isn't active/idle
    Perform Egate Command    command=trf_data_start ue=9 pdu=1 qfi=1 dir=dl burst=20 period_ms=4 size=1350 seconds=1800 trf_id=1
    ...    fail_regexp=isn't active/idle
    Perform Egate Command    command=trf_data_start ue=9 pdu=1 qfi=1 dir=ul burst=20 period_ms=4 size=1350 seconds=1800 trf_id=1
    ...    fail_regexp=isn't active/idle


step4:check ZAB print of cell_10 in syslog
    ute_syslog.Start Syslog    log_dir=${SAVE LOG DIRECTORY}    log_name=btslog_zab.LOG    ip=192.168.255.126    alias=chk_zabcell
    Sleep    10s
    ${output}=    ute_syslog.Message Should Exist In Syslog File    regexp=isZabCell:1     alias=chk_zabcell
    Log    ${output}
    ute_syslog.Collect Syslog Results     destination=${SAVE LOG DIRECTORY}    alias=chk_zabcell
    ute_syslog.stop_syslog    alias=chk_zabcell
    Should Not Be Empty    ${output}    [ERROR] ZAB cell is not found in syslog

step5:5G L3 call throughput veriry
    ${scell_tput_ue1_dl}    ap_get_throuput_on_specific_scell    ue_id=10    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput_ue1_dl}/1000 > 120
    ${scell_tput_ue1_ul}    ap_get_throuput_on_specific_scell    ue_id=10    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput_ue1_ul}/1000 > 70
    ${scell_tput_ue3_dl}    ap_get_throuput_on_specific_scell    ue_id=5    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput_ue3_dl}/1000 > 90
    ${scell_tput_ue3_ul}    ap_get_throuput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput_ue3_ul}/1000 > 70
    ${scell_tput_ue7_dl}    ap_get_throuput_on_specific_scell    ue_id=9    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell_tput_ue7_dl}/1000 > 45
    ${scell_tput_ue7_ul}    ap_get_throuput_on_specific_scell    ue_id=9    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell_tput_ue7_ul}/1000 > 45

step6:UE stop data transfer and detach and recover vendor
    Perform Egate Command    command=trf_data_stop ue=1,3,5,7,9,10 pdu=1 qfi=1 dir=dl
    Perform Egate Command    command=trf_data_stop ue=1,3,5,7,9,10 pdu=1 qfi=1 dir=ul
    Perform Egate Command    command=ue_pdu_session_release ue=1,3,5,7,9,10 pdu=1 by=amf
    Perform Egate Command    command=ue_deregister id=1,3,5,7,9,10 ue_deregister_type=switch_off by=ue
    update vendor file    ${vendor_orig_value_dict}

update vendor file
    [Arguments]    ${vendor_dict}
    ${target_list}    Get Content From Vendor XML
    FOR    ${item}    IN    @{target_list}
        Get Parameters And Values And Updated    ${item}    ${vendor_dict}
    END
    ${target_list}    Get Content From Vendor XML
    Run    command=sshpass -p "oZPS0POrRieRtu" ssh toor4nsn@192.168.255.1 crasign /ffs/run/swpool/OAM/vendor_*.xml

Get Content From Vendor XML
    ${grep_cmd}    Catenate    sshpass -p "oZPS0POrRieRtu" ssh toor4nsn@192.168.255.1
    ...            grep -B 3 -A 4 -n -E NR_L1_Loki_FDD_FR1_NB_CPRI_IQF /ffs/run/swpool/OAM/vendor_*.xml
    ${result}    Run    command=${grep_cmd}
    ${first_split}    Set Variable    ${result.split('</item>\n')}
    ${length}    Get Length    ${first_split}
    Should Be True    ${length}>=2    [ERROR]cannot find 'NR_L1_Loki_FDD_FR1_NB_CPRI_IQF' in vendor_*.xml
    ${first_list}    Create List
    FOR    ${item}    IN    @{first_split}
        Run Keyword If    ">ABIO<" in '''${item}''' and ">DL<" in '''${item}'''    Append To List    ${first_list}    ${item.strip()}
    END
    ${length}    Get Length    ${first_list}
    Should Be True    ${length}>=1    [ERROR]cannot find 'ABIO' & 'DL' & 'NR_L1_Loki_FDD_FR1_NB_CPRI_IQF' in vendor_*.xml
    Log To Console    \n${first_list[0]}
    ${target_list}    Set Variable    ${first_list[-1].split('\n')[1:-1]}
    [Return]    ${target_list}

Get Parameters And Values And Updated
    [Arguments]    ${item}    ${vendor_paras_dict}=${vendor_new_values_dict}
    ${name_list}    Set Variable    ${vendor_paras_dict.keys()}
    FOR    ${name}    IN    @{name_list}
        ${foundItem}    Set Variable If    "${name}" in '''${item}'''    ${item.strip().split('-')}    ${EMPTY}
        ${isNotEmpty}    Run Keyword And Return Status    Should Not Be Empty    ${foundItem}
        ${line_number}    ${tmp_value}    Run Keyword If    ${isNotEmpty}    Set Variable    ${foundItem}
        ${value}    Set Variable If    '${tmp_value}'!='None'    ${tmp_value.split('>')[-2].strip('</p')}    ${None}
        ${new_value}    Set Variable If    '${value}'!='None'    ${vendor_paras_dict}[${name}]    ${None}
        Run Keyword If    '${value}'!='None'    Log To Console    [INFO] Updating: line number : ${line_number} : ${name} = ${value} -> ${new_value}
        Run Keyword If    '${value}'!='None'    Exit for loop
    END
    ${sed_cmd}    Run Keyword If    '${value}'!='None'    Catenate    sshpass -p "oZPS0POrRieRtu" ssh toor4nsn@192.168.255.1
    ...    sed -i '${line_number},${line_number}s/${value}/${new_value}/g' /ffs/run/swpool/OAM/vendor_*.xml
    Run Keyword If    '${value}'!='None'    Log To Console    ${sed_cmd}
    ${result}    Run Keyword If    '${value}'!='None'    Run    command=${sed_cmd}

