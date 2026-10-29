*** Settings ***
Documentation  This is generic Keyword file for feature
Variables    ta5g_global_var

Resource       taf/rfrl/common_resources/robot/coam.robot
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
#Library        ../resources/NPS/SWENaG/python_libs/luashark_tools.py
Resource       ../resources/NPS/SWENG/robot/PacketSearch.robot
Resource       ../resources/robot/Setup_Env.robot
Resource       ../resources/robot/common_log_collection.robot
Resource        ../resources/ECEcommon/common_file_operation.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/TTI_Traces.robot
Resource         ../resources/robot/Iperf_Traffic.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
#Resource         ../CB008954/CB008954_resource.robot
Library          ../resources/python/ssh_command.py
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library           XML    use_lxml=True    WITH NAME    Myxml
Library          ../resources/python/TTI_Converter.py    WITH NAME    TtiConvert
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta_a2a


*** Variables ***
${enhancedSkipUplink_pattern}    *enhancedSkipUplinkTxConfigured-r16*
${RD_PARAM}          0x5901C9=1;0x600012=1;0x5901CA=0;0x190297=1;
${RD_PARAM_DIS}      0x5901C9=0;0x600012=0;0x5901CA=0;0x190297=0;
${UE_attach_pattern}    reported successful RA
${Bearer_ID2}          3
${delta_set_collecting_counters_to_five_minutes}=
    ...    /home/ute/Auto5G/testsuite/RRM/5G_SW_WRO/resources/config/5G21B/delta_set_collecting_counters_to_five_minutes.json
@{FIELDS_CellSetupReq}     cellBwpList_item_0     cellBwpList_item_1
${BIP_SCRIPT_PATH}      ${CURDIR}/../resources/NPS/SWENG/config/script
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
@{pysical_cell_ids}    51

*** Keywords ***

Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Configure in VM for RANK-4
    [Documentation]    This keyword is to configure RANK-4 in VM
    Log To Console    configure VM for RANK-4..
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.wmem_default=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_max=20971520
    OperatingSystem.Run    sudo sysctl -w net.core.rmem_default=20971520


Load wts CFG Config And Capture CPRT Traces
    [Arguments]    ${wts_cfg_file}     ${start_cell}    ${end_cell}
    Start CPRT capture
    Load CFG and verify cell status    ${wts_cfg_file}   ${start_cell}  ${end_cell}

Common TTI PCAP to CSV Converter
    [Arguments]    ${ttitrace_path}    ${dir}=dl
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    ${tti_file_size}    Get File Size    ${tti_path}/tcpdump_ttitrace.pcap
    Run Keyword If  ${tti_file_size} <= 60000000
    ...   Decode TTI Trace    ${ttitrace_path}
    ...   ELSE
    ...   Decode TTI Trace For Large File Size    ${ttitrace_path}  ${dir}

Decode TTI Trace For Large File Size
    [Arguments]    ${ttitrace_path}  ${dir}
    Dated Log                        converting large ttitrace pcap to csv
    ${tti_path}      Set Variable     ${LOG_PATH}/${TEST_NAME}/gNB/ttitrace/${ttitrace_path}
    run     /sbin/tcpdump -r ${tti_path}/tcpdump_ttitrace.pcap -w ${tti_path}/tti_split.pcap -C 22
    ${files}    OperatingSystem.List Files In Directory     ${tti_path}     tti_split.*
    log to console    file_list-${files}
    ${count}    Count Files In Directory    ${tti_path}     tti_split.*
    log to console    file_count-${count}
    FOR    ${i}  IN RANGE   0   ${count}
    Run keyword if  ${i}!=0 and 'tti_split.pcap${i}' in ${files}
    ...    run     mv ${tti_path}/tti_split.pcap${i} ${tti_path}/tti_split_${i}.pcap
    ...    ELSE
    ...    run     mv ${tti_path}/tti_split.pcap ${tti_path}/tti_split_${i}.pcap
    Dated Log         converting ${tti_path}/tti_split_${i}.pcap to ${tti_path}/output_${dir}_formated_${i}.csv
    Common Convert Ttitrace From Pcap To Excelcsv        ${tti_path}    filename=tti_split_${i}.pcap
    Common Format Tti In Stream Mode         ${tti_path}/output_${dir}.csv     ${tti_path}/output_${dir}_formated_${i}.csv
    run     rm ${tti_path}/tti_split_${i}.pcap
    END
    merge_multiple_csv      ${tti_path}   ${dir}

Register multi ues and send 1 mbps data
     [Arguments]    ${start_ue_id}   ${end_ue_id}
     ${crnti_list}   create list
     ${crnti_list}    wts_sim_keywords.MultiUE Register should be Successful    ${start_ue_id}   ${end_ue_id}
     Set Suite Variable   ${crnti_list}
     log to console    Attached UEs with CRNTI: ${crnti_list}
     FOR  ${UE}  IN RANGE   ${start_ue_id}   ${end_ue_id}+0
            wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${UE}      Traffic_rate=mbps     ul_rate=1     pdu_id=1   trf_id=1
            wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=mbps     dl_rate=1     pdu_id=1   trf_id=1
     END


AP commands to Drop bwp switching DCIs SUE
#    [Airguments]    ${profile_id}    ${num_dci_drop}     ${start_ue_id}   ${end_ue_id}
    [Arguments]    ${profile_id}    ${num_dci_drop}    ${UE_ID}
    log to console    actvating bler test mode commands
    ${Dci_drop_cmd}    SET VARIABLE     bler_testmode_nr profile_id=${profile_id} num_of_bwp_switching_dci_to_be_dropped=${num_dci_drop}
    ute_wtssim.Execute Egate Command  ${Dci_drop_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
#    FOR  ${UE}  IN RANGE   ${start_ue_id}   ${end_ue_id}+1
        ${Dci_drop_cmd_activate}    SET VARIABLE     ue_testmode_nr_set id=${UE_ID} testmode=bler profile_id=${profile_id} action=activate
        ute_wtssim.Execute Egate Command  ${Dci_drop_cmd_activate}    timeout=${EGATE_COMMAND_TIMEOUT}
#    END

AP commands to Drop bwp switching DCIs
#    [Arguments]    ${profile_id}    ${num_dci_drop}     ${start_ue_id}   ${end_ue_id}
    [Arguments]    ${profile_id}    ${num_dci_drop}     ${start_ue_id}   ${end_ue_id}
    log to console    actvating bler test mode commands
    ${Dci_drop_cmd}    SET VARIABLE     bler_testmode_nr profile_id=${profile_id} num_of_bwp_switching_dci_to_be_dropped=${num_dci_drop}
    ute_wtssim.Execute Egate Command  ${Dci_drop_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    FOR  ${UE}  IN RANGE   ${start_ue_id}   ${end_ue_id}+1
        ${Dci_drop_cmd_activate}    SET VARIABLE     ue_testmode_nr_set id=${UE} testmode=bler profile_id=${profile_id} action=activate
        ute_wtssim.Execute Egate Command  ${Dci_drop_cmd_activate}    timeout=${EGATE_COMMAND_TIMEOUT}
    END

AP commands to Drop bwp switching DCIs Fail
    [Arguments]    ${profile_id_bler}    ${profile_id_bwp}    ${force_switch_bwp}    ${pdcch_misd_rate}     ${start_ue_id}   ${end_ue_id}
    log to console    actvating bler test mode commands
    ${Dci_drop_cmd_1}    SET VARIABLE     bwp_testmode_nr profile_id=${profile_id_bwp} force_switch_bwp=${force_switch_bwp}
    ute_wtssim.Execute Egate Command  ${Dci_drop_cmd_1}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${Dci_drop_cmd_2}    SET VARIABLE     bler_testmode_nr profile_id=${profile_id_bler} pdcch_misd_rate=${pdcch_misd_rate}
    ute_wtssim.Execute Egate Command  ${Dci_drop_cmd_2}    timeout=${EGATE_COMMAND_TIMEOUT}

    FOR  ${UE}  IN RANGE   ${start_ue_id}   ${end_ue_id}+1
        ${Dci_drop_cmd_activate_1}    SET VARIABLE     ue_testmode_nr_set id=${UE} testmode=bwp profile_id=${profile_id_bler} action=activate
        ute_wtssim.Execute Egate Command  ${Dci_drop_cmd_activate_1}    timeout=${EGATE_COMMAND_TIMEOUT}
        ${Dci_drop_cmd_activate_2}    SET VARIABLE     ue_testmode_nr_set id=${UE} testmode=bler profile_id=${profile_id_bwp} action=activate
        ute_wtssim.Execute Egate Command  ${Dci_drop_cmd_activate_2}    timeout=${EGATE_COMMAND_TIMEOUT}
    END

Trigger dl_ul data in Mbps
     [Arguments]    ${start_ue_id}   ${end_ue_id}   ${dl_rate}    ${ul_rate}
     log to console    triggering low traffic for switching to psbwp
     FOR  ${UE}  IN RANGE   ${start_ue_id}   ${end_ue_id}+0
            wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${UE}      Traffic_rate=Mbps     ul_rate=${dl_rate}     pdu_id=1   trf_id=1
            wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=Mbps     dl_rate=${ul_rate}     pdu_id=1   trf_id=1
     END




Trigger dl_ul data in kbps
     [Arguments]    ${start_ue_id}   ${end_ue_id}   ${dl_rate}    ${ul_rate}
     log to console    triggering low traffic for switching to psbwp
     FOR  ${UE}  IN RANGE   ${start_ue_id}   ${end_ue_id}+1
            wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     ul_rate=${dl_rate}     pdu_id=1   trf_id=1
            wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${UE}      Traffic_rate=kbps     dl_rate=${ul_rate}     pdu_id=1   trf_id=1
     END
Stop dl_ul data traffic for Ues
     [Arguments]   ${start_ue_id}   ${end_ue_id}
     wts_sim_keywords.Multiue DL TRF Data Stop for SA     ${start_ue_id}   ${end_ue_id}
     wts_sim_keywords.Multiue UL TRF Data Stop for SA     ${start_ue_id}   ${end_ue_id}

Deregister Ues
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}
        wts_sim_keywords.MultiUE Deregister should be Successful     ${Ues}   ${Ues}+${0}
    END

Deregister Ues no
    [Arguments]   ${start_ue}   ${end_ue}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}
        wts_sim_keywords.MultiUE Deregister should be Successful     ${Ues}
    END

Stop data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}     ${step}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${step}
        wts_sim_keywords.Multiue DL TRF Data Stop for SA     ${Ues}   ${Ues}+${4}
        wts_sim_keywords.Multiue UL TRF Data Stop for SA     ${Ues}   ${Ues}+${4}
    END

Validate Counters For Bwp switch
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01006    1      INCOM_BWP_SWITCH_CBWP4
    ...    M55351C01009    1      OUTGO_BWP_SWITCH_CBWP3
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Validate Counters For Bwp switch To SmallBWP
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01005    1      INCOM_BWP_SWITCH_CBWP3
    ...    M55351C01010    1      OUTGO_BWP_SWITCH_CBWP4
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Validate Counters For Scanning And Recovery Success old
    [Arguments]    ${incoming_name}    ${outgoing_name}    ${incoming_value}     ${outgoing_value}
    ...      ${ue_noconf}       ${succes_rec}
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${INCOMING_BWP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=${incoming_name}    moc=NRCELL-1
    ${OUTGOING_BWP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=${outgoing_name}    moc=NRCELL-1
    ${UE_NOCONFF}       Get PM counter value    pm_files_location=${PM_dir1}    pi_id=${ue_noconf}    moc=NRCELL-1
    ${SUCCES_RECC}      Get PM counter value    pm_files_location=${PM_dir1}    pi_id=${succes_rec}    moc=NRCELL-1

    Should be True     ${INCOMING_BWP} == ${incoming_value}
    Should be True     ${OUTGOING_BWP} == ${outgoing_value}
    Should be True     ${UE_NOCONFF} == 1
    Should be True     ${SUCCES_RECC} == 1

Validate Counters For Scanning And Recovery Success
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01006    2      INCOM_BWP_SWITCH_CBWP4
    ...    M55351C01007    2      OUTGO_BWP_SWITCH_CBWP1
    ...    M55351C01014    1      CBWP4_UE_NO_CONF
    ...    M55351C01015    1      CBWP1_RECOVERY
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

Validate Counters For Scanning And Recovery Success SBWP
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01006    2      INCOM_BWP_SWITCH_CBWP4
    ...    M55351C01009    2      OUTGO_BWP_SWITCH_CBWP3
    ...    M55351C01014    1      OUTGO_BWP_SWITCH_CBWP4
    ...    M55351C01017    1      CBWP3_RECOVERY
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}


Validate Counters For Scanning And Recovery Failure SBWP
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01013    1      INCOM_BWP_SWITCH_CBWP4_NOCONF
    ...    M55351C01009    1      OUTGO_BWP_SWITCH_CBWP3
    ...    M55351C01006    1      INCOM_BWP_SWITCH_CBWP4
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...    file_path=${pm_counters}

Collect BIPLOG and decode
    [Arguments]     ${Foldername}
    Start log  biptaf
    sleep    3s
    ${path_SCN_1}   Stop log   biptaf   test_scenario=${Foldername}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}


Change IPHY File Value old
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "card"|tail -n 2|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "GSCN"|tail -n 2|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s

Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "card"|tail -n 2|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 1 "GSCN"|tail -n 1|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s

Start Tti Trace Per Cell
    [Arguments]         ${path}    ${pysical_cell_ids}
    Log to console    ${path}
    Start Ttitrace With Streaming Mode Per Cell    pysical_cell_ids=${pysical_cell_ids}
#    Sleep    ${duration}    reason=get *L2TtiTrace_EventsSnapshot
    #Stop Ttitrace
    #Convert Ttitrace From Pcap To Excelcsv        ${path}
