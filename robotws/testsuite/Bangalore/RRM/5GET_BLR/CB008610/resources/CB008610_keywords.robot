*** Settings ***
Variables    ta5g_global_var
Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../../resources/robot/Common_Keywords.robot
Resource            ../../resources/robot/Airphone.robot
Resource            ../../resources/robot/WTS_Runner_Keywords.robot
Library             ../python/utility.py
Library             taf.analyzer.pmcounter       WITH NAME    check_pm
Library             Collections

*** Variables ***
&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
${BIP_SCRIPT_PATH}         /home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/resources/NPS/SWENG/config/script/
${port}                    22

#   Add your vonr codec speed
&{vonr_codec_rate}         amr_wb_18_25=18.6      amr_wb_23_85=21.4
@{gbr_qfi_list_cfg}        3	4	5 	6	7	8	9	10	11	12	13	14	15

*** Keywords ***
## Delta Commissioning
Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size     ${AP_ASIK.ip}      ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}

UE Attach should be successful NSA
    X2AP Link Should be UP
    LTE Attach should be Successful    ${UE_ID}
    UE Attach should be Successful    ${UE_ID}
    Get Configured Measurements of UE${UE_ID}

Start Big Data and trigger A1 meas for scell addition and verify counters
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger A1 Measurement and verify Scell added successfully   ${UE_ID}    ${a1meas_id}    31624
    Change CQI Number   1   14   15   3   8
    Change CQI Number   2   14   15   1   9
    Run Keyword And Continue on Failure    Validate DL Traffic For NSA for Maximum high data   ue_id=${UE_ID}     dl_rate=490
    Run Keyword and Continue on Failure    Verify DL Tput For 2CC NSA TDD TDD
    Sync With Measurement Period      "vDU"
    Common_Keywords.Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    Run Keyword and continue on failure    Get buffer counters and validate vDU_scelladd     M55167C00001    M55167C00002
    ...     M55308C28001    M55308C28002      M55115C03001     *MRBTS*

Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID2}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID3}
    Sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID4}
    sleep   15s    reason=Wait for successful traffic start

Start Low Data Traffic And Check Scell Deactivation and verify counters
    Run keyword and ignore error    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=1     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=2     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=3     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=4     dir=dl
    Sleep    5s
    Trigger DL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     dl_rate=10     trf_id=1
    sleep    5s
    Trigger UL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     ul_rate=10     trf_id=1
    sleep    5s     reason=Wait for successful traffic start
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Run Keyword and continue on failure    Verify Low Data Traffic NSA
    Log to console     synch with Meas Period..
    Sync With Measurement Period      "vDU"
    Collect pm counter kubectls      "vDU"
    Log to Console    Verifying counters.....
    Run Keyword and continue on failure    Get buffer counters and validate vDU_scelldeact    M55167C00001    M55167C00002
    ...     M55115C03001     M55308C28001    M55308C28002      *MRBTS*

Verify Low Data Traffic NSA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Kbps
    Should Be True    ${pcell_tput} < ${60}
    Verify There is No TPUT On Scell    ue_id=${UE_ID}    scell_idx=9

Get buffer counters and validate vDU_scelladd
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}    ${PM_SCELL_COUNTER1}    ${PM_SCELL_COUNTER2}
    ...            ${PM_PCELL_COUNTER3}    ${pi_file_pattern}
    ${path}   Set Variable    CB008541_A*/*/k8scounters
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Should Be True    ${actual_pm_values_1}
    Run Keyword And Continue on Failure    should be Equal    ${actual_pm_values_1}    300
    Log to console     Counter is equal to 300

    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    Should Be True    200 < ${actual_pm_values_2} < 300
    #Run Keyword And Continue on Failure    should be Equal    ${actual_pm_values_2}    300
    #Log to console     Counter is equal to 300

    ${actual_pm_values_3}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER3}     pi_file_pattern=${pi_file_pattern}
    Run Keyword And Continue on Failure    should be Equal    ${actual_pm_values_3}    1


    ${actual_pm_values_4}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-2    pi_id=${PM_SCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    Should Be True    ${actual_pm_values_4}
    Run Keyword And Continue on Failure    should be True    296139 <= ${actual_pm_values_4} <= 330653


    ${actual_pm_values_5}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-2    pi_id=${PM_SCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    Should Be True    ${actual_pm_values_5}
    Run Keyword And Continue on Failure    should be Equal    ${actual_pm_values_5}    1



Get buffer counters and validate vDU_scelldeact
    [Arguments]    ${PM_PCELL_COUNTER1}    ${PM_PCELL_COUNTER2}    ${PM_PCELL_COUNTER3}    ${PM_SCELL_COUNTER1}    ${PM_SCELL_COUNTER2}
    ...            ${pi_file_pattern}

    ${path}   Set Variable    CB008541_A*/*/k8scounters
    ${actual_pm_values_1}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    #Should Be True    ${actual_pm_values_1}
    should be Equal    ${actual_pm_values_1}    300


    ${actual_pm_values_2}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    should be True    ${actual_pm_values_2} <= 300


    ${actual_pm_values_3}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-1    pi_id=${PM_PCELL_COUNTER3}     pi_file_pattern=${pi_file_pattern}
    should be Equal    ${actual_pm_values_3}    0


    ${actual_pm_values_4}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-2    pi_id=${PM_SCELL_COUNTER1}     pi_file_pattern=${pi_file_pattern}
    should be Equal    ${actual_pm_values_4}    0


    ${actual_pm_values_5}     Get PM counter value modified    pm_files_location=${LOG_PATH}${path}
    ...    moc=MRBTS-1/NRBTS-1/NRCELL-2    pi_id=${PM_SCELL_COUNTER2}     pi_file_pattern=${pi_file_pattern}
    should be Equal    ${actual_pm_values_5}    0


Verify DL Tput For 2CC NSA TDD TDD
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=9    unit=Mbps
    Should Be True    ${pcell_tput} > ${200}
    Should Be True    ${scell_tput} > ${80}

#Counter Verification Code
Wait for PM Interval to begin
    Wait until the next Measurement Period starts  additional_time=${0}

Collect PM Counters
    ${pm_counters_dir}=  Collect PM Counter  target_dir=${OUTPUT_DIR}/PMC
    Set Suite variable  ${pm_counters_dir}

Get PM counter value modified
    [Documentation]   :Author: Giangiacomo Guglielmini
    ...        get the value of a counter in the last reporting period
    ...
    ...        :param pm_files_location is the path to PM files
    ...        :param pi_id is the PM counter ID e.g. M55112C03001
    ...        :param moc is the class including the counter e.g. NRCELL-1
    ...               it is NOT necessary to give the full moc e.g. MRBTS-1113/NRBTS-1113/NRCELL-1
    [Arguments]    ${pm_files_location}   ${pi_id}    ${moc}    ${pi_file_pattern}
    ${pi_list}=  Create List
    ...  ${pi_id}
    ${PM_report_dict_list}=  check_pm.get_pi_value
    ...  pi_list=${pi_list}
    ...  pi_dir=${pm_files_location}
    ...  pi_file_pattern=${pi_file_pattern}
    ${last_report}    Get From List   ${PM_report_dict_list}     -1
    ${pi_dict}   Get Dictionary Values   ${last_report}
    ${first_pi}    Get From List   ${pi_dict}     0
    ${cell_dict_list}   Get Dictionary Values   ${first_pi}
    ${cell_dict}   Get From List   ${cell_dict_list}     0
    ${moc_list}   get dictionary keys   ${cell_dict}
    ${full_moc}    Set Variable     empty
    Log to Console    ${moc}
    FOR  ${key}  IN   @{moc_list}
       ${key_is_moc}  Run Keyword And Return Status    Should Be Equal  ${key}   ${moc}
       ${full_moc}  Set Variable If   ${key_is_moc}   ${key}    ${full_moc}
    END
    ${pi_value}     Get From Dictionary      ${cell_dict}    ${full_moc}
    BuiltIn.Log    ${pi_id} value: ${pi_value}   #console=${P_console}
    [Return]    ${pi_value}

Fetch PM counter values
    [Arguments]    ${pi_list}
    @{counter_val} =  Create List
    @{moc_values}=  Create List    MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-1   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-2
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-3  MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-4
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-5
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-6  MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-7
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-8
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-9  MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-10
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-11
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-12  MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-13
    ...   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-14   MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRPMQAP-15
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=${moc_values}    pi_id=${counter}
        Append To List    ${counter_val}    ${actual_pm_values}
    END
    [Return]    ${counter_val}

Get Retainability counter
    [Arguments]    ${NG_FLOW_SETUP_SUCC_PMQAP}      ${NG_FLOW_SETUP_ATT_TOT_PMQAP}
    ...    ${NG_FLOW_REL_PMQAP}    ${NG_FLOW_REL_NORMAL_PMQAP}     ${qos_profile}
    @{list}=  Create List   ${NG_FLOW_SETUP_SUCC_PMQAP}    ${NG_FLOW_SETUP_ATT_TOT_PMQAP}
    ...    ${NG_FLOW_REL_PMQAP}    ${NG_FLOW_REL_NORMAL_PMQAP}
    @{gbr_pmqap_list}=  Create List       1    2   3   4   5   6   7   8   9   10   11   12   13    14    15
    @{counter_value} =   Fetch PM counter values     ${list}
    ${ng_setup_succ}=  Set variable     @{counter_value}[0]
    ${ng_setup_succ_att}=  Set variable     @{counter_value}[1]
    ${ng_setup_rel}=  Set variable     @{counter_value}[2]
    ${ng_setup_rel_normal}=  Set variable     @{counter_value}[3]
    Lists Should Be Equal    ${ng_setup_succ}    ${ng_setup_succ_att}   #PDU session setup successfull,no failure
    Lists Should Be Equal    ${ng_setup_succ}    ${ng_setup_rel}
    Lists Should Be Equal    ${ng_setup_rel}     ${ng_setup_rel_normal}
    ${pmqap_list}=  create list
    ${total_ue_set}=   Get Dictionary Keys   ${qos_profile}
    ${prof}=   Get Dictionary Values   ${qos_profile}
    ${pmqap_set}    Evaluate    [item for sublist in $prof for item in (sublist if isinstance(sublist, list) else [sublist])]
    FOR     ${id}    IN    @{gbr_pmqap_list}
         ${value1}=   Get Match Count   ${pmqap_set}   ${id}
         Append To List  ${pmqap_list}   ${value1}
         Run Keyword If   ${id} != 4     continue for loop
         ${status}=  run keyword and return status    should contain   ${pmqap_set}    4
         Run Keyword If   ${status} == False     continue for loop
         ${value2}=   Evaluate   ${value1} + ${pmqap_list}[0]
         Set List Value   ${pmqap_list}   0    ${value2}
    END
    Lists Should Be Equal  ${ng_setup_succ_att}   ${pmqap_list}
    Lists Should Be Equal  ${ng_setup_rel}   ${pmqap_list}

Get Throughput counters and validate
    [Arguments]    ${DL_PDCP_VOL_UE_TPUT_PMQAP}    ${DL_PDCP_TIME_UE_TPUT_PMQAP}
    ...    ${UL_RLC_VOL_UE_TPUT_PMQAP}    ${UL_RLC_TIME_UE_TPUT_PMQAP}    ${AVE_NUMBER_OF_SA_RRC_PMQAP}
    ...    ${AVE_NUMB_OF_SA_DENOM_PMQAP}
    @{list}=  Create List   ${DL_PDCP_VOL_UE_TPUT_PMQAP}    ${DL_PDCP_TIME_UE_TPUT_PMQAP}
    ...    ${UL_RLC_VOL_UE_TPUT_PMQAP}    ${UL_RLC_TIME_UE_TPUT_PMQAP}    ${AVE_NUMBER_OF_SA_RRC_PMQAP}
    ...    ${AVE_NUMB_OF_SA_DENOM_PMQAP}
    @{counter_value} =   Fetch PM counter values     ${list}
    ${PDCP_VOL} =   Set variable     @{counter_value}[0]
    ${PDCP_TIME}=   Set variable     @{counter_value}[1]
    ${RLC_VOL} =   Set variable     @{counter_value}[2]
    ${RLC_TIME}=   Set variable     @{counter_value}[3]
    ${SA_RRC}=   Set variable     @{counter_value}[4]
    ${SA_RRC_Denom}=   Set variable     @{counter_value}[5]
    ${pmqap_len}=   get length    ${PDCP_VOL}
    @{DL_PDCP_Tput} =  Create List
    @{UL_RLC_Tput} =  Create List
    @{tput_ratio}=  Create List
    @{condition}=   Create List
    FOR  ${id}   IN RANGE    ${0}      ${pmqap_len}
            Run Keyword IF  ${PDCP_VOL}[${id}] == ${0}    Append To List    ${DL_PDCP_Tput}   ${0}
            Run Keyword IF  ${RLC_VOL}[${id}] == ${0}    Append To List    ${UL_RLC_Tput}   ${0}
            continue for loop if  @{PDCP_VOL}[${id}] == ${0} and @{RLC_VOL}[${id}] == ${0}
            ${cal1} =   pm_analyzer.ue_count_from_counters     @{PDCP_VOL}[${id}]    @{PDCP_TIME}[${id}]
            Append To List    ${DL_PDCP_Tput}   ${cal1}
            ${cal2} =   pm_analyzer.ue_count_from_counters     @{RLC_VOL}[${id}]     @{RLC_TIME}[${id}]
            Append To List    ${UL_RLC_Tput}   ${cal2}
    END
    log to console   ${DL_PDCP_Tput}  DL PDCP Throughput as per PMQAP profile
    log to console   ${UL_RLC_Tput}  UL RLC Throughput as per PMQAP profile
    ${len}=   get length    ${DL_PDCP_Tput}
    FOR  ${val}   IN RANGE    ${0}      ${len}
            Run Keyword IF  ${DL_PDCP_Tput}[${val}] == ${0} and ${UL_RLC_Tput}[${val}] == ${0}    Append To List    ${tput_ratio}   ${0}
            continue for loop if  ${DL_PDCP_Tput}[${val}] == ${0} and ${UL_RLC_Tput}[${val}] == ${0}
            ${ratio}=    pm_analyzer.ue_count_from_counters     @{DL_PDCP_Tput}[${val}]     @{UL_RLC_Tput}[${val}]
            Append To List    ${tput_ratio}   ${ratio}
            ${cal3}=     evaluate  (0.98<= @{tput_ratio}[${val}] <=1.02)
            Append To List    ${condition}   ${cal3}
#            run keyword if    ${cal3}        Append To List    ${condition}   ${cal3}
    END

Get PDCP Discard QoS Group counters and validate
    [Arguments]    ${QoS_Group_01}    ${QoS_Group_02}   ${QoS_Group_03}     ${QoS_Group_04}     ${QoS_Group_05}     ${QoS_Group_06}
    ...    ${QoS_Group_07}    ${QoS_Group_08}    ${QoS_Group_09}    ${QoS_Group_10}     ${QoS_Group_11}     ${QoS_Group_12}     ${QoS_Group_13}
    ...    ${QoS_Group_14}    ${QoS_Group_15}    ${QoS_Group_16}    ${QoS_Group_17}     ${QoS_Group_18}     ${QoS_Group_19}     ${QoS_Group_20}
    @{pi_list}=  Create List   ${QoS_Group_01}   ${QoS_Group_02}    ${QoS_Group_03}     ${QoS_Group_04}     ${QoS_Group_05}     ${QoS_Group_06}
    ...    ${QoS_Group_07}    ${QoS_Group_08}    ${QoS_Group_09}    ${QoS_Group_10}     ${QoS_Group_11}     ${QoS_Group_12}     ${QoS_Group_13}
    ...    ${QoS_Group_14}    ${QoS_Group_15}    ${QoS_Group_16}    ${QoS_Group_17}     ${QoS_Group_18}     ${QoS_Group_19}     ${QoS_Group_20}
    @{counter_value} =  Create List
    @{moc_values}=  Create List    MRBTS-1/NRBTS-1     MRBTS-1/NRBTS-1/NRCELL-1
    FOR    ${counter}    IN    @{pi_list}
        ${actual_pm_values}=    Get PM counter value modified    pm_files_location=${OUTPUT_DIR}/PMC/gnb_pm_counters
        ...    moc=${moc_values}    pi_id=${counter}
        Append To List    ${counter_value}    ${actual_pm_values}
    END
    ${PDCP_discard_QoS_Group} =   Set variable     @{counter_value}
