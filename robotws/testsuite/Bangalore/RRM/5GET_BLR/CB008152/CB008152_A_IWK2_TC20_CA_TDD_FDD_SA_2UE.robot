*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

Documentation    :copyright: Nokia
...   The aim of the feature is to support  35Mhz Cell BW (FR1-FDD) IWK CB008541 and CB007552 with DL CA

Resource         ./resources_keywords.resource

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

#Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}        ${CURDIR}/config/basic_setup_TC20.cfg
${WTS_DIR}             /opt/iphy/latest
&{WTS}                 Ip=127.0.0.1        Username=ute         Connection=Wts
${UE_ID}               1
${nwslice_ID}          1
${gw_ID}               1
${Pdu_session_ID}      1
${qfi_id}              1
${st_ue_id}            1
${en_ue_id}            1
${file_path}     /opt/iphy/latest/egate_console.log
${SCFC}=                   Bangalore/RRM/ET/CB008152/CB008152_A_TC20_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008152/CB008152_A_TC20_iphy.xml

*** Test Cases ***
[1]CB008152_A_IWK3_TC20_CA_TDD_FDD_SA
    [Documentation]      support for 35Mhz Cell BW (FR1-FDD)
    ...                  This script validates DL CA scenario with FDD + TDD cells configured
    ...                  Cell#1 - TDD, n41, 80MHz (large BWP), 50MHz (smallBWP)
    ...                  Cell#2 - FDD, n66 , 35MHz (large BWP), 20MHz (smallBWP)
    ...                  UE#1 - Attach to TDD cell and FDD is scell with large BWP support in both the cells
    ...                  UE#2 - Attach to TDD cell and FDD is scell with small BWP support in both cells
    ...                  UE#3 nonCA UE, attach to cell#2 (FDD cell)
    set test variable      ${LOG_PATH}
    ${exp_thp_list}       Create List    1    1    170
    Attach SA Ue and start low DL data     st_ue_id=1    en_ue_id=1    trf_id_num=3    varg_expected_thp=${exp_thp_list}
    ${exp_thp_list} =	Create List    1     2    640    350     #SA/NSA , noofcc , exp_thp
    Increase DL data and verify scell activation    st_ue_id=1    en_ue_id=1    trf_id_num=9    varg_expected_thp=${exp_thp_list}
    Verify locationAndBandwidth from egate_log     ${file_path}    ${st_ue_id}    ${en_ue_id}    sansa_flag=1    l_bwp=24474
    Verify UL THP for single cell config     UE_ID=1      scell_idx=0      ul_thp=115
    sleep  10s
    Detach UE    1    1
    ${exp_thp_list}    	Create List    1     1    100
    Attach SA Ue and start low DL data    st_ue_id=2    en_ue_id=2    trf_id_num=3    varg_expected_thp=${exp_thp_list}
    ${exp_thp_list} =	Create List    1     2    500    200
    Increase DL data and verify scell activation    st_ue_id=2    en_ue_id=2    trf_id_num=9     varg_expected_thp=${exp_thp_list}
    Verify locationAndBandwidth from egate_log     ${file_path}     st_ue_id=2    en_ue_id=2    sansa_flag=1    l_bwp=28875
    Verify UL THP for single cell config     UE_ID=2      scell_idx=0      ul_thp=70
    sleep  10s
    Detach UE    2    2
    ${exp_thp_list}       Create List    1    1    360
    Attach SA Ue and start low DL data    st_ue_id=3    en_ue_id=3    trf_id_num=6    varg_expected_thp=${exp_thp_list}
    sleep  10s
    Verify UL THP for single cell config     UE_ID=3      scell_idx=0      ul_thp=320
    Detach UE    3    3

