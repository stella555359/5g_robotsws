*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
# Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource   ${BASIC_PATH_5G}/RF/General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode.robot

*** Keywords ***
Set RF to Full Mode
    [Arguments]   ${ru_index}=1    ${ru_type}=64TRX
    selenium login and disable screen lock
    ${mMimoAntArrayMode}   Set Variable If   '${ru_type}' == '32TRX'   Full 32TRX Array (2x8x2)   Full 64TRX Array (4x8x2)
    log to console    Set RF-${ru_index} to Full Mode
    ${modify_params}    create list

    ${cell_list}    get all cell id    ru_index=${ru_index}
    FOR    ${cell_id}    IN    @{cell_list}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Massive MIMO Antenna Array Mode    p_name=mMimoAntArrayMode    value=${mMimoAntArrayMode}
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Channel bandwidth    p_name=chBw    value=50MHz
        append to list    ${modify_params}    ${item}
    END
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    6 min    40 sec   Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]   Run Keyword And Ignore Error   Selenium Logout And Close Browser

Set RF to Split Mode
    [Arguments]   ${ru_index}=1    ${ru_type}=64TRX
    log to console    Set RF-${ru_index} to Split Mode
    selenium login and disable screen lock
    ${Top}   Set Variable If   '${ru_type}' == '32TRX'   Top 16TRX Array (1x8x2)   Top 32TRX Array (2x8x2)
    ${Bottom}   Set Variable If   '${ru_type}' == '32TRX'   Bottom 16TRX Array (1x8x2)   Bottom 32TRX Array (2x8x2)
    ${modify_params}    create list
    ${cell_list}    get all cell id    ru_index=${ru_index}
    FOR   ${index}    ${cell_id}    IN ENUMERATE    @{cell_list}
        ${mMimoAntArrayMode}   Set Variable If   ${index % 2} == 0   ${Top}   ${Bottom}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate load-based PS control logic enhancement    p_name=actLbpsCtrlLogicEnh    value=false
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate NR cell-level extended configurations for MIMO muting and cell switch off
        ...    p_name=actNrExtCellSOMethod    value=false
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate NR load-based mMIMO TX power saving    p_name=actNrLBmMimoRTXPowerSaving    value=false
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate mixed mode load-based power saving    p_name=actNrMixedSOMethod    value=false
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
        ...    filter_param=Activate SSB boost in mMIMO TX power saving    p_name=actSSBBoostInmMIMOMuting    value=false
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1
        ...    filter_param=Load-based power saving switch off method    p_name=lbpsSOMethod    value=cell switch off
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Massive MIMO Antenna Array Mode    p_name=mMimoAntArrayMode    value=${mMimoAntArrayMode}
        append to list    ${modify_params}    ${item}
        ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Channel bandwidth    p_name=chBw    value=100MHz
        append to list    ${modify_params}    ${item}
    END
    Run Keyword And Ignore Error   Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    6 min    40 sec   Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]   Run Keyword And Ignore Error   Selenium Logout And Close Browser

All_RF_scan_test_with_full_mode_in_online_mode
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Verify  RF scan test on in online mode to check if there is RF interference present
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 25.03.2024
        ...    *******************
        ...    xuewen.zhang@nokia-sbell.com
    [Arguments]   ${ru_index}=1   ${technology}=NR TDD
    ...   ${atenna}=PHYANT 1  ${antenna_panel}=PHYANT-1 Full Array
    selenium login and disable screen lock
    Set actRfiTesting Parameter   actRfiTesting=true
    Run Keyword And Ignore Error  Selenium Logout And Close Browser
    Start RF Sniffing RF Scanning Full Mode  ru_index=${ru_index}  ru_type=${ru_type_init}  technology=${technology}
    ...   atenna=${atenna}   antenna_panel=${antenna_panel}
    [Teardown]   Run Keywords  Run Keyword And Ignore Error  Set actRfiTesting Parameter   actRfiTesting=false   AND
    ...   Selenium Logout And Close Browser

Start RF Sniffing RF Scanning Full Mode
    [Arguments]    ${ru_index}=1    ${ru_type}=AQQF    ${technology}=NR TDD    ${atenna}=PHYANT 1
    ...    ${antenna_panel}=PHYANT-1 Full Array    ${connection}=GNB_OAM
    log to console     Start RF Sniffing RF Scanning All
    selenium login and disable screen lock
    selenium_coam.change_bts_rnd_parameters      69      Dynamic changes      [{"paramIndexNumber":39, "paramValue":1}]   timeout=${100}
    Sleep  30
    Selenium Logout And Close Browser
    Sleep  10
    selenium login and disable screen lock   download_dir=${SUITE_LOG_PATH}

    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR    ${ru_info}  IN  @{ru_info_list}
        ${ru_Index}    Set Variable    ${ru_info["ru_index"]}
        ${product_Name}    Set Variable    ${ru_info["productName"]}
        Exit For Loop If  '${ru_Index}'=='1'
    END
    Set Test Variable    ${ru_type}    ${product_Name}

    ${rfscan_path_Composite}   Start RF Scanning Every Caputure   technology=${technology}   radio=RMOD-${ru_index} (${ru_type})
    ...   capture_type=Composite Rx (HBF0)
    ...   atenna=${atenna}   antenna_panel=${antenna_panel}
    ${rfscan_path_Feedback}  Start RF Scanning Every Caputure  technology=${technology}   radio=RMOD-${ru_index} (${ru_type})
    ...   capture_type=Feedback Tx (PDRx)
    ...   atenna=${atenna}   antenna_panel=${antenna_panel}
    ${cell_list}    get all cell id    ru_index=${ru_index}
    FOR    ${cell_id}    IN    @{cell_list}
        ${rfscan_path_Carrier}  Start RF Scanning Every Caputure  technology=${technology}   radio=RMOD-${ru_index} (${ru_type})
        ...   capture_type=Carrier Rx (FIR9)
        ...   atenna=${atenna}   antenna_panel=${antenna_panel}   local_cell=NRCELL-${cell_id}
    END
    RUN    rm ${rfscan_path_Composite}
    RUN    rm ${rfscan_path_Feedback}
    RUN    rm ${rfscan_path_Carrier}

All_RF_scan_test_with_Split_mode_in_online_mode
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Verify  RF scan test on in online mode to check if there is RF interference present
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 25.03.2024
        ...    *******************
        ...    xuewen.zhang@nokia-sbell.com
    [Arguments]   ${ru_index}=1   ${technology}=NR TDD
    ...   ${atenna}=PHYANT 1  ${antenna_panel}=PHYANT-1 All Arrays
    selenium login and disable screen lock
    Set actRfiTesting Parameter   actRfiTesting=true
    Run Keyword And Ignore Error  Selenium Logout And Close Browser
    Start RF Sniffing RF Scanning Split Mode  ru_index=${ru_index}  ru_type=${ru_type_init}  technology=${technology}
    ...   atenna=${atenna}   antenna_panel=${antenna_panel}
    [Teardown]   Run Keywords  Run Keyword And Ignore Error  Set actRfiTesting Parameter   actRfiTesting=false   AND
    ...   Selenium Logout And Close Browser

Start RF Sniffing RF Scanning Split Mode
    [Arguments]    ${ru_index}=1    ${ru_type}=AQQF    ${technology}=NR TDD    ${atenna}=PHYANT 1
    ...    ${antenna_panel}=PHYANT-1 All Arrays    ${connection}=GNB_OAM
    log to console     Start RF Sniffing RF Scanning Split Mode
    selenium login and disable screen lock
    selenium_coam.change_bts_rnd_parameters      69      Dynamic changes      [{"paramIndexNumber":39, "paramValue":1}]   timeout=${100}
    Sleep  30
    Selenium Logout And Close Browser
    Sleep  10
    selenium login and disable screen lock   download_dir=${SUITE_LOG_PATH}

    ${ru_info_list}    Get All RUs Status Info    connection=${connection}
    FOR    ${ru_info}  IN  @{ru_info_list}
        ${ru_Index}    Set Variable    ${ru_info["ru_index"]}
        ${product_Name}    Set Variable    ${ru_info["productName"]}
        Exit For Loop If  '${ru_Index}'=='1'
    END
    Set Test Variable    ${ru_type}    ${product_Name}

    ${rfscan_path_Composite}   Start RF Scanning Every Caputure   technology=${technology}   radio=RMOD-${ru_index} (${ru_type})
    ...   capture_type=Composite Rx (HBF0)
    ...   atenna=${atenna}   antenna_panel=${antenna_panel}
    ${rfscan_path_Feedback}  Start RF Scanning Every Caputure   technology=${technology}   radio=RMOD-${ru_index} (${ru_type})
    ...   capture_type=Feedback Tx (PDRx)
    ...   atenna=${atenna}   antenna_panel=${antenna_panel}
    ${cell_list}    get all cell id    ru_index=${ru_index}
    FOR   ${index}    ${cell_id}    IN ENUMERATE    @{cell_list}
        ${antenna_panel}   Set Variable If   ${index % 2} == 0   PHYANT-1 Top Array   PHYANT-1 Bottom Array
        ${rfscan_path_Carrier}  Start RF Scanning Every Caputure  technology=${technology}   radio=RMOD-${ru_index} (${ru_type})
        ...   capture_type=Carrier Rx (FIR9)
        ...   atenna=${atenna}   antenna_panel=${antenna_panel}   local_cell=NRCELL-${cell_id}
    END
    RUN    rm ${rfscan_path_Composite}
    RUN    rm ${rfscan_path_Feedback}
    RUN    rm ${rfscan_path_Carrier}

Start RF Scanning Every Caputure
    [Arguments]    ${technology}=NR TDD    ${radio}=RMOD-1 (AQQF)    ${capture_type}=Composite Rx (HBF0)
    ...   ${atenna}=PHYANT 1      ${antenna_panel}=PHYANT-1 Full Array      ${local_cell}=${EMPTY}
    ...   ${download_timeout}=${200}
    log to console    \n Start RF Sniffing RF Scanning ${capture_type}
    ${rfscan_path}=    Run Keyword If  '${capture_type}'=='Carrier Rx (FIR9)'
    ...    selenium_coam.start_rf_scan   ${technology}   ${radio}
	...    ${capture_type}   ${atenna}   ${antenna_panel}    ${local_cell}
	...      timeout=${120}
	...   ELSE    selenium_coam.start_rf_scan   ${technology}   ${radio}
	...    ${capture_type}   ${atenna}   ${antenna_panel}
	...      timeout=${120}
	Sleep   2min
	${rfscan_path}=    selenium_coam.download_rf_scan_files   download_timeout=${download_timeout}
    ${size}=  OperatingSystem.get file size  ${rfscan_path}
    should be true  ${size} > 100
    [Return]    ${rfscan_path}
