*** Settings ***
Documentation    ...
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Library      ./../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
#Suite Setup    Common Suite Setup
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_LO_AP_LO_NSA_FS_ECPRI_MMWV_TDD    SBTS00    CN1_SQ
#...                RAN_5G    RAN_5G_TDD    CRT
#*** Variables ***
#${UE_ID}               11
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${Egatelog_path}    ${CURDIR}
#${LOCAL_IPHY_DIR}    ${CURDIR}/config
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${WTS_DIR}    /opt/iphy/latest
#${SCF_DIR}    ${CURDIR}/config
#${527_SCF}    SCF_527.xml
#${WTS_CFG}    basic_setup_527.cfg
#${IPHY_2CC}    iphy_527.xml
#${gnb_swconfig}    ${CURDIR}/config/swconfig_gnb.txt
#${ap_swconfig}    ${CURDIR}/config/swconfig_ap.txt
#
#*** Test Cases ***
#5GC000527_B_4201_CA_UL_And_DL_Data_Trans_Single_CA_UE_With_2CC_In_mmW_Band
#    [Tags]    Owner_dguan
#    [Setup]    Setup TL    ${527_SCF}    ${IPHY_2CC}    ${WTS_CFG}
#    Suite Setup Start WTS And Check OnAir
#    Attach NSA UE and Traffic    11
#    Capture And Decode TTitrace
#    Verify Tbsize On 2Cells DL UL As Expected
#    Check PM Counters Of UE AMOUNTS
#
#*** Keywords ***
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#
#Setup TL
#    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${onlyscellul}=false    ${timerforreinit}=100
#    Verify Coam Site Is Ready
#    Create Test Directory
#    #Send Swconfig for GNB    ${gnb_swconfig}
#    #Send Swconfig for AP    ${ap_swconfig}
#    #Add RD Parameters To GNB Swconfig File    ${6137_BA_RD}
#    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
#    Full Commission With SCF File For UTE    ${scf_file}
#    Sleep    120S    wait gnb and airphone all reboot avaliable.
#    Reboot TL And Check Configured
#    Set WTS Files Name For Each Cases    ${wts_cfg_name}
#
#Set WTS Files Name For Each Cases
#    [Arguments]    ${wts_cfg_name}
#    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_name}
#    Log To Console    ${WTS_CFG}
#    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#
#Capture And Decode TTitrace
#    [Arguments]    ${log_id}=1    ${duration}=2
#    Log To Console     start ttitrace...
#    Start Ttitrace With Streaming Mode
#    Sleep    ${duration}s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#
#Verify Tbsize On 2Cells DL UL As Expected
#    Verify Tbsize On Cell DL As Expected    50
#    Verify Tbsize On Cell DL As Expected    51
#    Verify Tbsize On Cell UL As Expected    50
#    Verify Tbsize On Cell UL As Expected    51
#
#Check PM Counters Of UE AMOUNTS
#    [Documentation]    This keyword is to check PM Counters related to ue amounts
#    ...    M55316C05001 Maximum amount of PSCell UEs with 1 activated SCells in DL
#    ...    M55316C06001 Maximum amount of PSCell UEs with 1 activated SCells in UL
#    ...    M55316C05002 Maximum amount of PSCell UEs with 2 activated SCells in DL
#    ...    M55316C06002 Maximum amount of PSCell UEs with 2 activated SCells in UL
#    ...    M55316C01003 Sample amount for DL UE amount counters
#    ...    M55316C01002 Sample amount for UL UE amount counters
#    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
#    Log To Console    to reach next pm counter update time, need to wait ${time}...
#    Sleep    ${time}    wait for pm counter file updated.
#    Sleep    20s    wait pm counter file generated stable.
#    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
#    Log To Console    Check Counter M55316C05001
#    ${MAX_PSCELL_UE_1_ACT_DL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C05001    cell_id=1
#    Should Be True    "${MAX_PSCELL_UE_1_ACT_DL}"=="1"
#    ${MAX_SCELL_UE_1_ACT_DL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C05001    cell_id=2
#    Should Be True    "${MAX_SCELL_UE_1_ACT_DL}"=="0"
#    Log To Console    Check Counter M55316C06001
#    ${MAX_PSCELL_UE_1_ACT_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06001    cell_id=1
#    Should Be True    "${MAX_PSCELL_UE_1_ACT_UL}"=="1"
#    ${MAX_SCELL_UE_1_ACT_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06001    cell_id=2
#    Should Be True    "${MAX_SCELL_UE_1_ACT_UL}"=="0"
#    Log To Console    Check Counter M55316C05002
#    ${MAX_PSCELL_UE_2_ACT_DL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C05002    cell_id=1
#    Should Be True    "${MAX_PSCELL_UE_2_ACT_DL}"=="0"
#    ${MAX_SCELL_UE_2_ACT_DL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C05002    cell_id=2
#    Should Be True    "${MAX_SCELL_UE_2_ACT_DL}"=="0"
#    Log To Console    Check Counter M55316C06002
#    ${MAX_PSCELL_UE_2_ACT_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06002    cell_id=1
#    Should Be True    "${MAX_PSCELL_UE_2_ACT_UL}"=="0"
#    ${MAX_SCELL_UE_2_ACT_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06002    cell_id=2
#    Should Be True    "${MAX_SCELL_UE_2_ACT_UL}"=="0"
#    Log To Console    Check Counter M55316C01003
#    ${SAMPLES_DL_UE_AMOUNTS_PSCELL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C01003    cell_id=1
#    Should Be True    "900">="${SAMPLES_DL_UE_AMOUNTS_PSCELL}">"0"
#    ${SAMPLES_DL_UE_AMOUNTS_SCELL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C01003    cell_id=2
#    Should Be True    "900">="${SAMPLES_DL_UE_AMOUNTS_SCELL}">"0"
#    Log To Console    Check Counter M55316C01002
#    ${SAMPLES_UL_UE_AMOUNTS_PSCELL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C01002    cell_id=1
#    Should Be True    "900">="${SAMPLES_UL_UE_AMOUNTS_PSCELL}">"0"
#    ${SAMPLES_UL_UE_AMOUNTS_SCELL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C01002    cell_id=2
#    Should Be True    "900">="${SAMPLES_UL_UE_AMOUNTS_SCELL}">"0"
#
#Attach NSA UE and Traffic
#    [Arguments]    ${UE_ID}=11    ${dl_tp_set}=175   ${ul_tp_set}=175    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
#    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
#    Serving Cell Index for 5G-NR
#    NSA 5G Attach 2    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2    bip=no
#    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=1    mbps=${dl_tp_set}
#    NSA Start DL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=2    mbps=${dl_tp_set}
#    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=2    mbps=${ul_tp_set}
#    Sleep    10s
#
#Serving Cell Index for 5G-NR
#    [Arguments]    ${id}=1
#    Log To Console    Serving Cell Index for 5G-NR
#    ute_wtssim.Execute Egate Command    enb_endc_param id\=${id} serving_cell_index_range_scg\=1:2
#    Log To Console    Serving_cell_index_is_OK
#    sleep    10s
#
#Verify Tbsize On Cell DL As Expected
#    [Arguments]    ${physcellid}
#    Log To Console    Check tbsize of dl cell from TTI trace
#    @{tbSize}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_dl.csv
#    ...    dlFdSchedData.dciFormat    physCellId    DL_11    include    ${physcellid}    include    dlFdSchedData.tbSize    yes
#    FOR    ${i}    IN    @{tbSize[1:]}
#         Should Be True    ${i}>0
#    END
#
#Verify Tbsize On Cell UL As Expected
#    [Arguments]    ${physcellid}
#    Log To Console    Check tbsize of ul cell from TTI trace
#    @{tbSize}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
#    ...    ulFdSchedData.dciFormat    physCellId    UL_01    include    ${physcellid}    include    ulFdSchedData.tbSize    yes
#    FOR    ${i}    IN    @{tbSize[1:]}
#         Should Be True    ${i}>0
#    END
#
#Full Commission With SCF File For UTE
#    [Arguments]    ${scf_file}
#    [Documentation]    This keyword is to update parameters with delta file
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
#    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
#    ...
#    ...    Examples:
#    ...    | *** Variables *** |
#    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
#    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
#    ...    Example2:
#    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
#    ...    | Full Commission With SCF File | ${scf_file} |    |
#    Log To Console    Perform Full Commissioning
#    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
#    Modify File Parameter    ${SCF_DIR}/${scf_file}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
#    Modify VlanId In SCF File    ${SCF_DIR}/${scf_file}
#    ${new_scf_path}    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Migration SCF To New Release    ${SCF_DIR}/${scf_file}
#    ${new_scf_path}=    Set Variable If    "${new_scf_path}"=="${None}"    ${SCF_DIR}/${scf_file}    ${new_scf_path}
#    File Should Exist    ${new_scf_path}
#    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
#    COAM.Setup Admin
#    COAM.Perform Commissioning
#    ...    bts_id=${bts_id[0]}
#    ...    scf_file=${new_scf_path}
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=300
#    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown
#
#
#
