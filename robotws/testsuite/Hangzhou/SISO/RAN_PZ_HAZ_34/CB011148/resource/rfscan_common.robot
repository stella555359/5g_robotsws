*** Settings ***
Documentation
...  author: ruiyu.han
...  contact: ruiyu.han@nokia-sbell.com

# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011148/resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot


*** Keywords ***
Case Setup for 8899
    [Documentation]   Setup WEBUI login and start btslog collection
    SISO Coam Test Setup
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Wait Until Keyword Succeeds    15m    1m    COAM LOGIN
    Start R&D Mode


Case Teardown for 8899
    [Documentation]   Stop btslog collection, and logout WEBUI connection
    SISO Coam Test Teardown
    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Run Keyword and Ignore Error   COAM Logout


Admin_General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE]Verify  RF scan test on in online mode to check if there is RF interference present
    ...    ******************
    ...    History of changes
    ...    *******************
    ...    ruiyu.han@nokia.com  --change to admim lib
    [Arguments]    ${technology}=NR_TDD    ${ru_type}=AQQF
    Admin Set actRfiTesting Parameter    actRfiTesting=true
    Admin Start RF Sniffing RF Scanning All    ru_type=${ru_type}    technology=${technology}
    [Teardown]   Run Keyword And Ignore Error  Admin Set actRfiTesting Parameter    actRfiTesting=false


Start R&D Mode
    csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=asik
    ${output}    csn.execute    command=cat /rom/swconfig.txt    connection=asik
    run keyword if    ${output.count('0x450027=1')}<=0    csn.execute    command=echo -e "0x450027=1\n" >> /rom/swconfig.txt
    ...    connection=asik
    run keyword if    ${output.count('0x450027=1')}<=0    csn.execute    command=crasign /rom/swconfig.txt    connection=asik
    run keyword if    ${output.count('0x450027=1')}<=0    COAM RESET SITE
    wait until keyword succeeds    15m    1m    COAM Check all cells should be onair
    [Teardown]    csn.Disconnect    connection=asik


Admin Set actRfiTesting Parameter
    [Arguments]    ${actRfiTesting}=true
    log to console    Set actRfiTesting Parameter ${actRfiTesting}
    run keyword if    '${actRfiTesting}'=='true'    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_TO_actRfiTesting_true}
    ...    ELSE    COAM Commission Prameters Operation    param_dic_to_change=${PARAMS_TO_actRfiTesting_false}
    Wait Until Keyword Succeeds    5m    1m    COAM Check all cells should be onair

Admin Start RF Sniffing RF Scanning All
    [Arguments]    ${ru_type}=AQQF    ${technology}=NR_TDD
    log to console     Start RF Sniffing RF Scanning All

    ${rmods_info}  coam.Get FRM    timeout=60  connection=COAM
    FOR    ${rmod}    IN    @{rmods_info}
        Set Test Variable    ${Radio_PRODUCT_NAME}    ${rmod['productName']}
        Continue For Loop If    '${Radio_PRODUCT_NAME}'!='${ru_type}'
        ${serial_number}=    Set Variable    ${rmod['serialNumber']}
        ${is_in_scan_list}=    Evaluate    $serial_number in $RU_RFSCAN_SN
        set test variable    ${Radio_SERIAL_NUMBER}    ${serial_number}
        Continue For Loop If    not ${is_in_scan_list}
        ${radio_dn}    Set Variable    ${rmod['id']['internal']}

        @{CTA6_types}=    Create List    AQQF    AQQC    AQQA    AQQY
        ${is_CTA6_type}=    Run Keyword And Return Status    List Should Contain Value    ${CTA6_types}    ${ru_type}
        ${carrier_files_count_new}=    Set Variable If    ${is_CTA6_type}    4    ${RU_RFSCAN_COUNT['${ru_type}']['Carrier Rx (FIR9)']}
        ${composite_files_count_new}=    Set Variable If    ${is_CTA6_type}    14    ${RU_RFSCAN_COUNT['${ru_type}']['Composite Rx (HBF0)']}
        ${feedback_files_count_new}=    Set Variable If    ${is_CTA6_type}    14    ${RU_RFSCAN_COUNT['${ru_type}']['Feedback Tx (PDRx)']}

        ${rfscan_path_Composite}    Admin Start RF Sniffing RF Scanning Every Caputure    technology=${technology}    radio_dn=${radio_dn}
        ...    capture_type=RX_COMBINED_RAW    files_count=${composite_files_count_new}
        ...    output_file_name=${OUTPUTDIR}/RU_${serial_number}_RFScan_Composite_Rx_HBF0.zip
        Sleep    60s

        ${rfscan_path_Feedback}    Admin Start RF Sniffing RF Scanning Every Caputure    technology=${technology}    radio_dn=${radio_dn}
        ...    capture_type=TX_FEEDBACK    files_count=${feedback_files_count_new}
        ...    output_file_name=${OUTPUTDIR}/RU_${serial_number}_RFScan_Feedback_Tx_PDRx.zip
        Sleep    60s
        ${cells_distname}    coam.Get_Cell_Mapping_By_Module_Id    module_id=${radio_dn}    connection=COAM

        FOR    ${cell_distname}    IN    @{cells_distname}
            ${cell_index}    fetch from right    ${cell_distname}    /
            ${rfscan_path_Carrier}    Admin Start RF Sniffing RF Scanning Every Caputure    technology=${technology}    radio_dn=${radio_dn}
            ...    capture_type=RX_CARRIER    files_count=${carrier_files_count_new}
            ...    cell_dn=${cell_distname}
            ...    output_file_name=${OUTPUTDIR}/RU_${serial_number}_${cell_index}_RFScan_Carrier_Rx_FIR9.zip
            Sleep    60s
        END

        RUN    rm ${rfscan_path_Composite}
        RUN    rm ${rfscan_path_Feedback}
        RUN    rm ${rfscan_path_Carrier}
    END

Admin Start RF Sniffing RF Scanning Every Caputure
    [Arguments]    ${technology}=NR_TDD    ${radio_dn}=MRBTS-858/EQM_R-4/APEQM_R-1/RMOD_R-1    ${capture_type}=RX_COMBINED_RAW
    ...    ${cell_dn}=None    ${files_count}=14    ${output_file_name}=${OUTPUTDIR}/RFScan.zip
    log to console    \n Start RF Sniffing RF Scanning ${capture_type}
    ${rfscan_path}=    Set Variable    ${output_file_name}
    Run Keyword If    '${capture_type}'=='RX_CARRIER'    coam.start_rf_scanning_test    technology=${technology}
    ...    radio_dn=${radio_dn}    capture_type=${capture_type}
    ...    cell_dn=${cell_dn}
    ...    output_file_name=${output_file_name}    timeout=60    connection=COAM
    ...    ELSE    coam.start_rf_scanning_test    technology=${technology}
    ...    radio_dn=${radio_dn}    capture_type=${capture_type}
    ...    output_file_name=${output_file_name}    timeout=60    connection=COAM
    ${size}=    OperatingSystem.get file size    ${rfscan_path}
    should be true    ${size} > 100
    ${filename_with_extension}=    Get From List    ${rfscan_path.split('/')}    -1
    ${rfscan_filename}=    Get From List    ${filename_with_extension.split('.')}    0
    ${directory_parts}=    Split String From Right    ${rfscan_path}    /    max_split=1
    ${rfscan_dir}=    Get From List    ${directory_parts}    0
    Unzip And Check RF Scan File    rfscan_dir_path=${rfscan_dir}    rfscan_filename=${rfscan_filename}    files_count=${files_count}
    [Return]    ${rfscan_path}
