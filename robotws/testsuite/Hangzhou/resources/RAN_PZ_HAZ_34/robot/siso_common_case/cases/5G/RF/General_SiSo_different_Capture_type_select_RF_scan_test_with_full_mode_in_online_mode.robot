*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot


*** Keywords ***
General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]Verify  RF scan test on in online mode to check if there is RF interference present
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 18.03.2024 - - Created https://jiradc.ext.net.nokia.com/browse/LEOPARD-1856?filter=-1
        ...    *******************
        ...    kaihui.fan@nokia-sbell.com
    [Arguments]   ${technology}=NR TDD   ${ru_type}=AQQF    ${atenna}=PHYANT 1  ${antenna_panel}=PHYANT-1 Full Array
    selenium login and disable screen lock
    Set actRfiTesting Parameter   actRfiTesting=true
    Run Keyword And Ignore Error  Selenium Logout And Close Browser
    Start RF Sniffing RF Scanning All    ru_type=${ru_type}    technology=${technology}    atenna=${atenna}    antenna_panel=${antenna_panel}
    [Teardown]   Run Keywords  Run Keyword And Ignore Error  Set actRfiTesting Parameter   actRfiTesting=false   AND
    ...   Selenium Logout And Close Browser

Set actRfiTesting Parameter
    [Arguments]   ${actRfiTesting}=true
    log to console    Set actRfiTesting Parameter ${actRfiTesting}
    ${modify_params}    create list
    ${item}    create dictionary  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
        ...    filter_param=Activate RFI testing    p_name=actRfiTesting    value=${actRfiTesting}
    append to list    ${modify_params}    ${item}
    Modify Parameters On Webem    modify_params=${modify_params}
    Wait until keyword succeeds    5 min    40 sec   Verify all cells should be onair    cell_type=${cell_type}

Start RF Sniffing RF Scanning All
    [Arguments]   ${ru_type}=AQQF  ${technology}=NR TDD  ${atenna}=PHYANT 1  ${antenna_panel}=PHYANT-1 Full Array
    ...   ${composite_files_count}=14  ${feedback_files_count}=14  ${carrier_files_count}=2  ${connection}=GNB_OAM
    log to console     Start RF Sniffing RF Scanning All
    selenium login and disable screen lock
    Wait Until Keyword Succeeds    5min    30s    selenium_coam.change_bts_rnd_parameters    69
    ...    Dynamic changes    [{"paramIndexNumber":39, "paramValue":1}]   timeout=${100}
    Sleep  30
    Selenium Logout And Close Browser
    Sleep  10
    selenium login and disable screen lock   download_dir=${SUITE_LOG_PATH}

    ${ru_index_list}    Get RU index list    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_type}    Get RU type    ru_index=${ru_index}
        ${radio}  Set Variable    RMOD-${ru_index} (${ru_type})
        ${rfscan_path_Composite}   Start RF Sniffing RF Scanning Every Caputure   technology=${technology}   radio=${radio}
        ...   capture_type=Composite Rx (HBF0)   files_count=${composite_files_count}
        ...   atenna=${atenna}   antenna_panel=${antenna_panel}
        Sleep  60s
        ${rfscan_path_Feedback}  Start RF Sniffing RF Scanning Every Caputure   technology=${technology}   radio=${radio}
        ...   capture_type=Feedback Tx (PDRx)   files_count=${feedback_files_count}
        ...   atenna=${atenna}   antenna_panel=${antenna_panel}
        Sleep  60s
        ${cell_list}    get all cell id    ru_index=${ru_index}
        FOR    ${cell_id}    IN    @{cell_list}
            # ${local_cell}  Set Variable If  '${ru_type}'=='${special_ru_type}'  NRCELL-${cell_id}(NR_Cell${cell_id})  NRCELL-${cell_id}
            # Comment this line due to NRCELL-${cell_id}(NR_Cell${cell_id}), (NR_Cell${cell_id}) = NIDD "cellName"
            ${local_cell}  Set Variable    NRCELL-${cell_id}
            @{CTA6_types}=    Create List    AQQF    AQQC    AQQA    AQQY
            ${is_CTA6_type}=    Run Keyword And Return Status    List Should Contain Value    ${CTA6_types}    ${ru_type}
            ${carrier_files_count_new}=    Set Variable If    ${is_CTA6_type}    4    ${carrier_files_count}
            ${rfscan_path_Carrier}  Start RF Sniffing RF Scanning Every Caputure  technology=${technology}   radio=${radio}
            ...   capture_type=Carrier Rx (FIR9)   files_count=${carrier_files_count_new}
            ...   atenna=${atenna}   antenna_panel=${antenna_panel}   local_cell=${local_cell}
            Sleep  60s
        END
        RUN    rm ${rfscan_path_Composite}
        RUN    rm ${rfscan_path_Feedback}
        RUN    rm ${rfscan_path_Carrier}
    END

Start RF Sniffing RF Scanning Every Caputure
    [Arguments]    ${technology}=NR TDD    ${radio}=RMOD-1 (AQQF)    ${capture_type}=Composite Rx (HBF0)
    ...      ${atenna}=PHYANT 1      ${antenna_panel}=PHYANT-1 Full Array      ${local_cell}=${EMPTY}
    ...   ${files_count}=14
    log to console    \n Start RF Sniffing RF Scanning ${capture_type}
    ${rfscan_path}=    Run Keyword If  '${capture_type}'=='Carrier Rx (FIR9)'
    ...    selenium_coam.start_rf_scan   ${technology}   ${radio}
	...    ${capture_type}   ${atenna}   ${antenna_panel}    ${local_cell}
	...      timeout=${120}
	...   ELSE    selenium_coam.start_rf_scan   ${technology}   ${radio}
	...    ${capture_type}   ${atenna}   ${antenna_panel}
	...      timeout=${120}
	${rfscan_path}=    selenium_coam.download_rf_scan_files   download_timeout=${120}
    ${size}=  OperatingSystem.get file size  ${rfscan_path}
    should be true  ${size} > 100
    ${filename_with_extension}=  Get From List  ${rfscan_path.split('/')}  -1
    ${rfscan_filename}=  Get From List  ${filename_with_extension.split('.')}  0
    ${directory_parts}=  Split String From Right  ${rfscan_path}  /  max_split=1
    ${rfscan_dir}=  Get From List  ${directory_parts}  0
    Unzip And Check RF Scan File  rfscan_dir_path=${rfscan_dir}  rfscan_filename=${rfscan_filename}  files_count=${files_count}
    [Return]    ${rfscan_path}
