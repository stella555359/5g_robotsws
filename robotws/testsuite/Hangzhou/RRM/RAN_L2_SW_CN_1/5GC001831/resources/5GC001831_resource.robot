*** Settings ***
Resource          ../../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Common Suite Setup
    Suite Setup Update GNB    log=${False}
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3

Setup TL for 1831 Counter
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${onlyscellul}=false    ${timerforreinit}=100
    #Verify Coam Site Is Ready
    #Create Test Directory
    #Send Swconfig for GNB    ${gnb_swconfig}
    #Send Swconfig for AP    ${ap_swconfig}
    #Add RD Parameters To GNB Swconfig File    ${6137_BA_RD}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    Full Commission With SCF File For UTE    ${scf_file}
    Sleep    120S    wait gnb and airphone all reboot avaliable.
    Reboot TL And Check Configured
    Set WTS Files Name For Each Cases    ${wts_cfg_name}
    Suite Setup Start WTS And Check OnAir
    FOR    ${index}    IN RANGE    1    4
        Log To Console    ===============Trigger Time: ${index}==============
        Attach NSA UE and Traffic    ${UE_ID}
        NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    dl    1-4
        NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    ul
        Sleep    10S    wait traffic stable
        NSA LTE Detach    ${UE_ID}
    END
    Get PM counter

Setup TL for 1831
    [Arguments]    ${scf_file}    ${iphy_name}    ${wts_cfg_name}    ${onlyscellul}=false    ${timerforreinit}=100
    #Verify Coam Site Is Ready
    #Create Test Directory
    #Send Swconfig for GNB    ${gnb_swconfig}
    #Send Swconfig for AP    ${ap_swconfig}
    #Add RD Parameters To GNB Swconfig File    ${6137_BA_RD}
    Modify IPHY File And Send to Airphone    ${LOCAL_IPHY_DIR}/${iphy_name}
    Full Commission With SCF File For UTE    ${scf_file}
    Sleep    120S    wait gnb and airphone all reboot avaliable.
    Reboot TL And Check Configured
    Set WTS Files Name For Each Cases    ${wts_cfg_name}
    Suite Setup Start WTS And Check OnAir

Set WTS Files Name For Each Cases
    [Arguments]    ${wts_cfg_name}
    Set Suite Variable    ${WTS_CFG}    ${wts_cfg_name}
    Log To Console    ${WTS_CFG}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}

Get PM counter
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    Set Suite Variable    ${file_name}

Capture And Decode TTitrace
    [Arguments]    ${log_id}=1    ${duration}=2
    Log To Console     start ttitrace...
    Start Ttitrace With Streaming Mode
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Start NSA DL Big Traffic Internal
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    this keyword is to start big dl udp traffic which more than 175.
    ${dl_times}    Evaluate    int(${mbps}/${175})
    : FOR    ${t_time}    IN RANGE    1    ${dl_times}+1
    \    NSA Start DL Traffic    ${ue_id}    ${BEARER_ID}    mbps=175    trf_id=${t_time}
    ${last_mbps}    Evaluate    ${mbps}-${175}*${dl_times}
    NSA Start DL Traffic    ${ue_id}    ${BEARER_ID}    mbps=${last_mbps}    trf_id=${dl_times+1}

Attach NSA UE and Traffic
    [Arguments]    ${UE_ID}=11    ${dl_tp_set}=175   ${ul_tp_set}=175    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
    Serving Cell Index for 5G-NR
    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2
    Set Value For CQI Testmode    profile_id=11    cqi=10    ri=0
    Send Action To GNB    ue_id=11   testmode=csi_override    action=activate    profile_id=11    scell=0-4
    Start NSA DL Big Traffic Internal    ue_id=${UE_ID}    mbps=700
    NSA Start UL Traffic    ue_id=${UE_ID}    bearer_id=2    trf_id=1    mbps=${ul_tp_set}
    Sleep    10s

Attach NSA UE with cqi
    [Arguments]    ${UE_ID}=11    ${dl_tp_set}=175   ${ul_tp_set}=175    ${dl_tp_threshold}=5    ${ul_tp_threshold}=5
    NSA LTE Attach    ue_id=${UE_ID}    profile_id=1
    Serving Cell Index for 5G-NR
    NSA 5G Attach    ue_id=${UE_ID}    gnb_id=2    cell_id=1    bearer_id=2
    #Set Value For BLER Testmode
    #Send Action To GNB    ue_id=11    testmode=bler    action=activate    profile_id=30    scell=0-3
    Set Value For CQI Testmode    profile_id=11    cqi=10    ri=0
    Send Action To GNB    ue_id=11   testmode=csi_override    action=activate    profile_id=11    scell=0-4

Serving Cell Index for 5G-NR
    [Arguments]    ${id}=1
    Log To Console    Serving Cell Index for 5G-NR
    ute_wtssim.Execute Egate Command    enb_endc_param id\=${id} serving_cell_index_range_scg\=1:4
    Log To Console    Serving_cell_index_is_OK
    sleep    10s

Verify Tbsize On Cell DL As Expected
    [Arguments]    ${physcellid}
    Log To Console    Check tbsize of dl cell from TTI trace
    @{tbSize}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_dl.csv
    ...    dlFdSchedData.dciFormat    physCellId    DL_11    include    ${physcellid}    include    dlFdSchedData.tbSize    yes
    FOR    ${i}    IN    @{tbSize[1:]}
         Should Be True    ${i}>0
    END

Verify Tbsize On Cell UL As Expected
    [Arguments]    ${physcellid}
    Log To Console    Check tbsize of ul cell from TTI trace
    @{tbSize}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/1/output_ul.csv
    ...    ulFdSchedData.dciFormat    physCellId    UL_01    include    ${physcellid}    include    ulFdSchedData.tbSize    yes
    FOR    ${i}    IN    @{tbSize[1:]}
         Should Be True    ${i}>0
    END

Full Commission With SCF File For UTE
    [Arguments]    ${scf_file}
    [Documentation]    This keyword is to update parameters with delta file
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file | Yes | SCF file name.It usual exist in ${scf_path}/${SW_BRANCH}/SCF/${scf_file}. |
    ...    |  |  | ${SW_BRANCH} is get in keyword 'Suite Setup Update GNB', like 5G20A |
    ...
    ...    Examples:
    ...    | *** Variables *** |
    ...    | ${scf_path} | Set Variable | ${CURDIR}/config |
    ...    | Full Commission With SCF File | SCF_5GC002504.xml |    |
    ...    Example2:
    ...    | ${scf_file} | Set Variable | ${CURDIR}/scf.xml |
    ...    | Full Commission With SCF File | ${scf_file} |    |
    Log To Console    Perform Full Commissioning
    ${NRBTS_DISTNAME}    Set Variable If    '${NRBTS_DISTNAME}'==''    MRBTS-1/NRBTS-1    ${NRBTS_DISTNAME}
    Modify File Parameter    ${SCF_DIR}/${scf_file}    MRBTS-[0-9]+/NRBTS-[0-9]+    ${NRBTS_DISTNAME}
    Modify VlanId In SCF File    ${SCF_DIR}/${scf_file}
    ${new_scf_path}    Run Keyword If    "${ENB_BUILD}"=="SBTS"    Migration SCF To New Release    ${SCF_DIR}/${scf_file}
    ${new_scf_path}=    Set Variable If    "${new_scf_path}"=="${None}"    ${SCF_DIR}/${scf_file}    ${new_scf_path}
    File Should Exist    ${new_scf_path}
    ${bts_id}    Get Regexp Matches    MRBTS-1/NRBTS-1    MRBTS-(?P<bts_id>\\d+)\\/    bts_id
    COAM.Setup Admin
    COAM.Perform Commissioning
    ...    bts_id=${bts_id[0]}
    ...    scf_file=${new_scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300
    [Teardown]    Run Keyword And Ignore Error    COAM.Teardown

Verify Tbsize On 2Cells UL As Expected
    Verify Tbsize On Cell UL As Expected    50
    Verify Tbsize On Cell UL As Expected    51

Set Value For BLER Testmode
    [Arguments]    ${profile_id}=30    ${dl_bler}=200,200,200,200,200,200,200,200
    Log To Console    Set Value For BLER Testmode...
    ${cmd}    Set Variable    bler_testmode_nr profile_id=${profile_id} dl_bler=${dl_bler}
    ute_wtssim.Execute Egate Command    ${cmd}

Send Action To GNB
    [Arguments]    ${ue_id}    ${testmode}    ${action}    ${profile_id}    ${scell}
    Log To Console    set action=${action} to gnb...
    ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} testmode=${testmode} action=${action}
    ...     profile_id=${profile_id} scell=${scell}
    ute_wtssim.Execute Egate Command    ${cmd}

Set Value For CQI Testmode
    [Arguments]    ${profile_id}=3    ${cqi}=15    ${cqi_mode}=fixed    ${cqi_min}=1    ${cqi_max}=15    ${ri}=0
    Log To Console    Set Value For CQI Testmode...
    ${cmd}    Catenate    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} cqi_mode=${cqi_mode}
    ...    cqi_min=${cqi_min} cqi_max=${cqi_max} ri=${ri}
    ute_wtssim.Execute Egate Command    ${cmd}

Check Scell Active Status
    [Arguments]    ${cell_nums}    ${scell_active_status}=activated    ${scell_index_start}=2
    Log To Console    \nverify Scell Activation Info...
    ute_wtssim.Execute Egate Command    sim_log_set flush
    FOR    ${id}    IN RANGE    ${scell_index_start}    ${cell_nums}
    ${scell_activation}    Set Variable    SCellIndex ${id} ${scell_active_status} successfully.
    ${check_rst}    Run    cat ${WTS_DIR}/egate_console.log|grep -i "${scell_activation}"|wc -l
    Should Be True    ${check_rst}>=1
    END

Check PM counter M55118C03001 RRC_RECONF_1_SCELL_UL_SUCC
    [Documentation]    Maximum amount of PSCell UEs with 1 activated SCells in DL
    Log To Console    Check Counter M55118C03001
    ${RRC_RECONF_1_SCELL_UL_SUCC}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C03001    cell_id=1
    Should Be True    "${RRC_RECONF_1_SCELL_UL_SUCC}">="0"
    ${RRC_RECONF_1_SCELL_UL_SUCC}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C03001    cell_id=2
    Should Be True    "${RRC_RECONF_1_SCELL_UL_SUCC}"=="0"
    ${RRC_RECONF_1_SCELL_UL_SUCC}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C03001    cell_id=3
    Should Be True    "${RRC_RECONF_1_SCELL_UL_SUCC}"=="0"
    ${RRC_RECONF_1_SCELL_UL_SUCC}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C03001    cell_id=4
    Should Be True    "${RRC_RECONF_1_SCELL_UL_SUCC}"=="0"

Check PM counter M55316C02001 UE_PSCELL_ACT_SCELL_UL
    [Documentation]    UEs in the cell using this cell as PSCell or having activated SCell in UL
    Log To Console    Check Counter M55316C02001
    ${UE_PSCELL_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C02001    cell_id=1
    Should Be True    "${UE_PSCELL_ACT_SCELL_UL}">="0"
    ${UE_PSCELL_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C02001    cell_id=2
    Should Be True    "${UE_PSCELL_ACT_SCELL_UL}">="0"
    ${UE_PSCELL_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C02001    cell_id=3
    Should Be True    "${UE_PSCELL_ACT_SCELL_UL}"=="0"
    ${UE_PSCELL_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C02001    cell_id=4
    Should Be True    "${UE_PSCELL_ACT_SCELL_UL}"=="0"

Check PM counter M55316C06001 MAX_PSCELL_UE_1_ACT_SCELL_UL
    [Documentation]    Maximum amount of PSCell UEs with 1 activated SCells in UL
    Log To Console    Check Counter M55316C06001
    ${MAX_PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06001    cell_id=1
    Should Be True    "${MAX_PSCELL_UE_1_ACT_SCELL_UL}">="0"
    ${MAX_PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06001    cell_id=2
    Should Be True    "${MAX_PSCELL_UE_1_ACT_SCELL_UL}"=="0"
    ${MAX_PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06001    cell_id=3
    Should Be True    "${MAX_PSCELL_UE_1_ACT_SCELL_UL}"=="0"
    ${MAX_PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C06001    cell_id=4
    Should Be True    "${MAX_PSCELL_UE_1_ACT_SCELL_UL}"=="0"

Check PM counter M55316C04001 PSCELL_UE_1_ACT_SCELL_UL
    [Documentation]    PSCell UEs with 1 activated SCells in UL
    Log To Console    Check Counter M55316C04001
    ${PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C04001    cell_id=1
    Should Be True    "${PSCELL_UE_1_ACT_SCELL_UL}">="0"
    ${PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C04001    cell_id=2
    Should Be True    "${PSCELL_UE_1_ACT_SCELL_UL}"=="0"
    ${PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C04001    cell_id=3
    Should Be True    "${PSCELL_UE_1_ACT_SCELL_UL}"=="0"
    ${PSCELL_UE_1_ACT_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C04001    cell_id=4
    Should Be True    "${PSCELL_UE_1_ACT_SCELL_UL}"=="0"

Check PM counter M55118C02001 RRC_RECONF_1_SCELL_UL_ATT
    [Documentation]    RRC Reconfigurations attempts for 1 SCell Addition in UL for NSA mode
    Log To Console    Check Counter M55118C02001
    ${RRC_RECONF_1_SCELL_UL_ATT}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C02001    cell_id=1
    Should Be True    "${RRC_RECONF_1_SCELL_UL_ATT}">="0"
    ${RRC_RECONF_1_SCELL_UL_ATT}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C02001    cell_id=2
    Should Be True    "${RRC_RECONF_1_SCELL_UL_ATT}"=="0"
    ${RRC_RECONF_1_SCELL_UL_ATT}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C02001    cell_id=3
    Should Be True    "${RRC_RECONF_1_SCELL_UL_ATT}"=="0"
    ${RRC_RECONF_1_SCELL_UL_ATT}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C02001    cell_id=4
    Should Be True    "${RRC_RECONF_1_SCELL_UL_ATT}"=="0"

Check PM counter M55118C04001 UE_PSCELL_1_CONF_SCELL_UL
    [Documentation]    Number of CA UEs in the current cell configured as a PSCell, which have 1 configured SCell in UL
    Log To Console    Check Counter M55118C04001
    ${UE_PSCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C04001    cell_id=1
    Should Be True    "${UE_PSCELL_1_CONF_SCELL_UL}">="0"
    ${UE_PSCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C04001    cell_id=2
    Should Be True    "${UE_PSCELL_1_CONF_SCELL_UL}"=="0"
    ${UE_PSCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C04001    cell_id=3
    Should Be True    "${UE_PSCELL_1_CONF_SCELL_UL}"=="0"
    ${UE_PSCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C04001    cell_id=4
    Should Be True    "${UE_PSCELL_1_CONF_SCELL_UL}"=="0"

Check PM counter M55118C05001 UE_SCELL_1_CONF_SCELL_UL
    [Documentation]    Number of CA UEs in the current cell configured as a SCell, which have 1 configured SCell in UL
    Log To Console    Check Counter M55118C05001
    ${UE_SCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C05001    cell_id=1
    Should Be True    "${UE_SCELL_1_CONF_SCELL_UL}"=="0"
    ${UE_SCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C05001    cell_id=2
    Should Be True    "${UE_SCELL_1_CONF_SCELL_UL}">="0"
    ${UE_SCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C05001    cell_id=3
    Should Be True    "${UE_SCELL_1_CONF_SCELL_UL}"=="0"
    ${UE_SCELL_1_CONF_SCELL_UL}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55118C05001    cell_id=4
    Should Be True    "${UE_SCELL_1_CONF_SCELL_UL}"=="0"

Check PM counter M55316C09000 SCELL_ACTIVATIONS
    [Documentation]    This counter provides the number of S-Cell activations while pegged in the secondary cell.
    Log To Console    Check Counter M55316C09000
    ${SCELL_ACTIVATIONS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=1
    Should Be True    "${SCELL_ACTIVATIONS}"=="0"
    ${SCELL_ACTIVATIONS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=2
    Should Be True    "${SCELL_ACTIVATIONS}">="0"
    ${SCELL_ACTIVATIONS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=3
    Should Be True    "${SCELL_ACTIVATIONS}">="0"
    ${SCELL_ACTIVATIONS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09000    cell_id=4
    Should Be True    "${SCELL_ACTIVATIONS}">="0"

Check PM counter M55316C09001 SCELL_DEACT_BUFFER_STATUS
    [Documentation]    SCell deactivations due to Buffer Status
    Log To Console    Check Counter M55316C09001
    ${SCELL_DEACT_BUFFER_STATUS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=1
    Should Be True    "${SCELL_DEACT_BUFFER_STATUS}"=="0"
    ${SCELL_DEACT_BUFFER_STATUS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=2
    Should Be True    "${SCELL_DEACT_BUFFER_STATUS}">="0"
    ${SCELL_DEACT_BUFFER_STATUS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=3
    Should Be True    "${SCELL_DEACT_BUFFER_STATUS}">="0"
    ${SCELL_DEACT_BUFFER_STATUS}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09001    cell_id=4
    Should Be True    "${SCELL_DEACT_BUFFER_STATUS}">="0"

Check PM counter M55316C09002 SCELL_DEACT_CHANNEL_STATE
    [Documentation]    SCell deactivations due to Channel State
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    Log To Console    Check Counter M55316C09002
    ${SCELL_DEACT_CHANNEL_STATE}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09002    cell_id=1
    Should Be True    "${SCELL_DEACT_CHANNEL_STATE}"=="0"
    ${SCELL_DEACT_CHANNEL_STATE}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09002    cell_id=2
    Should Be True    "${SCELL_DEACT_CHANNEL_STATE}">="0"
    ${SCELL_DEACT_CHANNEL_STATE}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09002    cell_id=3
    Should Be True    "${SCELL_DEACT_CHANNEL_STATE}">="0"
    ${SCELL_DEACT_CHANNEL_STATE}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55316C09002    cell_id=4
    Should Be True    "${SCELL_DEACT_CHANNEL_STATE}">="0"
