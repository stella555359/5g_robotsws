*** Settings ***
Documentation   Robot Test Suite for feature '5GC002481-CIAB-SyVe Test Only for 5GC000706 Inter-frequency handover via Xn (SA option 2)' \n
...             Team: 'MN 5G&SC PZ ULM 2 SqdGp63' \n
...             Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com' \n
#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]
Library    OperatingSystem
Library    ute_tshark

Resource    ../resources/attenuator.robot
Resource    ../resources/attenuator_scenario.robot
Resource   CB012121_commissioning.robot
Resource   CB012121_revert.robot


*** Variables ***
${DL_THROUGHPUT}         10Mbits/sec
${UL_THROUGHPUT}         10Mbits/sec
${DURATION_DL}           120s
${DURATION_UL}           110s
${DL_Protocol}           udp
${UL_Protocol}           udp


*** Keywords ***
Start Tracing
    [Documentation]    Start tracing tcpdump on eth3 interface
    ${eth3_collector}=  tcpdump.Start Tcpdump on TestPc   options=-i eth3 sctp or tcp port 49148
    Set Test Variable    ${eth3_collector}


Stop Tracing And Save As
    [Documentation]    Stop tracing tcpdump on eth3 interface
    [Arguments]    ${tcp_file}
    ${file_captured}  tcpdump.Stop Tcpdump On TestPc   collector=${eth3_collector}  target_dir=${resultTestDir}
    OperatingSystem.Run  cp ${file_captured} ${resultTestDir}/${tcp_file}.pcap
    Set Test Variable    ${${tcp_file}}    ${file_captured}


Start UL And DL Traffic
    [Documentation]     start DL/UL Traffic on default PDU and second PDU
    [Arguments]    ${transfer}
    ${dl_dt_name}=  Set Variable    DT_DL_${UE_ALIAS_1}_${transfer}
    ${ul_dt_name}=  Set Variable    DT_UL_${UE_ALIAS_1}_${transfer}
    taf.ue.Start Data Transfer    ${dl_dt_name}  ${UE_ALIAS_1}  DL  duration=${DURATION_DL}
    ...    throughput=${DL_THROUGHPUT}    protocol=${DL_Protocol}  packet_size=1300
    taf.ue.Start Data Transfer    ${ul_dt_name}  ${UE_ALIAS_1}  UL  duration=${DURATION_UL}
    ...    throughput=${UL_THROUGHPUT}    protocol=${UL_Protocol}  packet_size=1300
    RETURN    ${dl_dt_name}    ${ul_dt_name}


Stop DL And UL Traffic And check throughput
    [Documentation]     Stop DL/UL Traffic and check throughput with given deviation
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}
    taf.ue.Stop Data Transfer    ${dl_dt_name}
    taf.ue.Stop Data Transfer    ${ul_dt_name}


Commission Delta GNB_SCF
    [Documentation]     Settings for file commissioning and executiong of Delta commissioning
    ...                 Set all gnb variables
    Set Suite Variable  ${bts_host_gnb}  ${tl.gnbs[${source_node_id}].cu.oam_ssh_connection_details.addr}
    Set Suite Variable  ${basic_scf_name_gnb_${source_node_id}}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${gnb_sw_branch}/${tl_name}/GNB-${source_node_id}/scf.xml
    Set Suite Variable  ${basic_scf_name_gnb_${target_node_id}}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${gnb_sw_branch}/${tl_name}/GNB-${target_node_id}/scf.xml
    Set Suite Variable   ${target_scf_name_gnb_${source_node_id}}  ${configSuiteDir}/scf_updated_gnb_${source_node_id}.xml
    Set Suite Variable   ${target_scf_name_gnb_${target_node_id}}  ${configSuiteDir}/scf_updated_gnb_${target_node_id}.xml
    Set Suite Variable  ${delta_scf_recommissioning_name_${target_node_id}}
    ...                 ${configSuiteDir}/delta_scf_${TEST TAGS[${0}]}_${target_node_id}.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${source_node_id}}
    ...                 ${configSuiteDir}/delta_scf__${source_node_id}.json
    Set Suite Variable  ${revert_delta_scf_recommissioning_name_${source_node_id}}
    ...                 ${configSuiteDir}/revert_delta_scf_${TEST TAGS[${0}]}_${source_node_id}.json
    Set Suite Variable  ${revert_delta_scf_recommissioning_name_${target_node_id}}
    ...                 ${configSuiteDir}/revert_delta_scf_${TEST TAGS[${0}]}_${target_node_id}.json
    Log To Console    \Loading delta gnb scf parameters

    IF    'CB012121_A_05' in ${TEST TAGS}
        CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_A GNB-0  nrbts_id=${nrbts_id_0}  gnb_id=${source_node_id}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${source_node_id}}
        CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_A GNB-1  nrbts_id=${nrbts_id_1}  gnb_id=${target_node_id}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${target_node_id}}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${target_node_id}}
    ELSE IF    'CB012121_A_11' in ${TEST TAGS}
        CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_A GNB-0  nrbts_id=${nrbts_id_0}  gnb_id=${source_node_id}
        ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
        ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${source_node_id}}
    END

    IF    '${TL_NAME}' in ${TL_LIST}
        IF    'CB012121_B_01' in ${TEST TAGS}
            CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_B_01 GNB-0  nrbts_id=${nrbts_id_0}  gnb_id=${source_node_id}
            ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
            ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${source_node_id}}
            CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_B_01 GNB-1  nrbts_id=${nrbts_id_1}  gnb_id=${target_node_id}
            ...    target_scf_name_gnb=${target_scf_name_gnb_${target_node_id}}
            ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${target_node_id}}
        ELSE IF    'CB012121_B_11' in ${TEST TAGS}
            CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_B_11 GNB-0  nrbts_id=${nrbts_id_0}  gnb_id=${source_node_id}
            ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
            ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${source_node_id}}
            CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_B_11 GNB-1  nrbts_id=${nrbts_id_1}  gnb_id=${target_node_id}
            ...    target_scf_name_gnb=${target_scf_name_gnb_${target_node_id}}
            ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${target_node_id}}
        END
    ELSE
        IF    'CB012121_B_01' in ${TEST TAGS}
            CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_B_01 GNB-0  nrbts_id=${nrbts_id_0}  gnb_id=${source_node_id}
            ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
            ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${source_node_id}}
        ELSE IF    'CB012121_B_11' in ${TEST TAGS}
            CB012121_commissioning.Execute GNB Delta Commission JSON For CB012121_B_11 GNB-0  nrbts_id=${nrbts_id_0}  gnb_id=${source_node_id}
            ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
            ...    delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${source_node_id}}
        END
    END

    gnb.Wait Until Node To Be Onair State   node_id=${source_node_id}  timeout=900s


Revert Commission Delta GNB_SCF
    [Documentation]     Reverting delta file commissioning and executiong Revert commissioning
    Log To Console    \Revert delta commissioning
    IF    'CB012121_A_05' in ${TEST TAGS}
        CB012121_revert.Revert GNB Delta Commission JSON For CB012121 GNB-0  gnb_id=${source_node_id}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
        ...        revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${source_node_id}}
        CB012121_revert.Revert GNB Delta Commission JSON For CB012121 GNB-1  gnb_id=${target_node_id}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${target_node_id}}
        ...        revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${target_node_id}}
    ELSE IF    'CB012121_A_11' in ${TEST TAGS} or 'CB012121_B_11' in ${TEST TAGS}
        syve_testline.Load Initial GNB SCF For CCRT    gnb_id=${0}
        syve_testline.Load Initial GNB SCF For CCRT    gnb_id=${1}
    ELSE IF    '${TL_NAME}' in ${TL_LIST}
        CB012121_revert.Revert GNB Delta Commission JSON For CB012121 GNB-0  gnb_id=${source_node_id}
        ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
        ...    revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${source_node_id}}
        CB012121_revert.Revert GNB Delta Commission JSON For CB012121 GNB-1  gnb_id=${target_node_id}
        ...    target_scf_name_gnb=${target_scf_name_gnb_${target_node_id}}
        ...    revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${target_node_id}}
    ELSE
        CB012121_revert.Revert GNB Delta Commission JSON For CB012121 GNB-0  gnb_id=${source_node_id}
        ...    target_scf_name_gnb=${target_scf_name_gnb_${source_node_id}}
        ...    revert_delta_scf_recommissioning_name=${revert_delta_scf_recommissioning_name_${source_node_id}}

    END

    gnb.Wait Until Node To Be Onair State   node_id=${source_node_id}  timeout=900s


Set GNB Cell Attenuation With File Per Cell
    [Documentation]    starts predefined attenuation scenario
    [Arguments]    ${scenario}=SEN1  ${att_file_path}=att_file_path
    ${resultSuiteBaseDir}=    Get Test Suite Result Base Directory
    ${template}=  Get File  ${att_file_path}
    ${message}=  Replace Variables  ${template}
    Create File  ${resultSuiteBaseDir}/CB_attenuator_scenario_tl.txt  ${message}
    attenuator_scenario.Run Attenuator Scenario By Cell
    ...    att_file=${resultSuiteBaseDir}/CB_attenuator_scenario_tl.txt  scenario=${scenario}


Perform Postconditions Of Test Scenario
    ute_tshark.Teardown Tshark
    attenuator.Set Attenuator To Max Value
    syve_testline.Save Current Loads


### PM Counter coding ####

Fetch and Rename PM Counter Dirs
    [Documentation]     Fetch and Verify all new CB006139 and legacy PM counters
    [Arguments]    ${gnb_id}    ${PM_Part}

    Log To Console    PMcounters: Wait next Measurement Period Stops.
    pmcounters.Wait until the current Measurement Period stops    gnb_id=${gnb_id}

    log to console  Stop PM Counter collection
    ${PMCounters_dir_Part}=    Fetch All PM Counter Values  gnb_id=${gnb_id}  PM_Part=${PM_Part}
    RETURN    ${PMCounters_dir_Part}


Verify PM Counters CB012121_A_05
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB012121 PM Counters:

    ${reference_table}    Run keyword
    ...    Create List
    ...      (NRCELL-3/PLMN-PLMN/MCC-540/MNC-01)M55145C00351  ==  2    ATT_OG_IF_INTER_GNB_HO_SA_PLMN
    ...      (NRCELL-3/PLMN-PLMN/MCC-540/MNC-01)M55145C00352  ==  2    SUCC_OG_IF_INTERGNB_HO_SA_PLMN
    ...      (NRCELL-3)M55147C00024                           ==  2    TOT_INTER_FREQ_HO_DECISION_A3
    ...      (NRCELL-3)M55147C00025                           ==  0    TOT_INTER_FREQ_HO_DECISION_A5
    ...      (NRCELL-3)M55142C00523                           ==  0    ATT_OG_IF_INTER_GNB_HO_SA_PLMN
    ...      (NRCELL-3)M55142C00524                           ==  0    SUCC_OG_IF_INTERGNB_HO_SA_PLMN
    ...      (NRCELL-3)M55142C00525                           ==  0    TOT_INTER_FREQ_HO_DECISION_A3
    ...      (NRCELL-3)M55142C00526  in  (8, 12, 16)                   TOT_INTER_FREQ_HO_DECISION_A5

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB012121_A_11
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB012121 PM Counters:

    ${reference_table}    Run keyword
    ...    Create List
    ...      (NRCELL-3)M55147C01001  ==  1                 NMOCU_ANR_NRREL_ADD
    ...      (NRCELL-3)M55147C00024 + (NRCELL-3)M55147C00025   ==  1       TOT_INTER_FREQ_HO_DECISION_A3/A5
    ...      (NRCELL-3)M55142C00523  ==  0                 AVG_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-3)M55142C00524  ==  0                 AVG_TIME_HO_TGTSEL_MEASPRI_DEN
    ...      (NRCELL-3)M55142C00525  ==  0                 MAX_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-3)M55142C00526  in  (8, 12, 16)       TOT_MEASREPORT_RECVD_MEASPRI

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB012121_B_01
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB012121 PM Counters:

    ${reference_table}    Run keyword
    ...    Create List
    ...      (NRCELL-3/PLMN-PLMN/MCC-540/MNC-01)M55145C00351  ==  1       ATT_OG_IF_INTER_GNB_HO_SA_PLMN
    ...      (NRCELL-3/PLMN-PLMN/MCC-540/MNC-01)M55145C00352  ==  1       SUCC_OG_IF_INTERGNB_HO_SA_PLMN
    ...      (NRCELL-3)M55147C00024 + (NRCELL-3)M55147C00025  ==  1       TOT_INTER_FREQ_HO_DECISION_A3/A5
    ...      (NRCELL-3)M55142C00523  >  0       AVG_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-3)M55142C00523  <  10000   AVG_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-3)M55142C00524  ==  1      AVG_TIME_HO_TGTSEL_MEASPRI_DEN
    ...      (NRCELL-3)M55142C00525  >  0       MAX_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-3)M55142C00525  <  10000   Max_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-3)M55142C00526  ==  5      TOT_MEASREPORT_RECVD_MEASPRI

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Verify PM Counters CB012121_B_11
    [Arguments]    ${PMCounters_dir}
    Log To Console    \nVerify the CB012121 PM Counters:

    ${reference_table}    Run keyword
    ...    Create List
    ...      (NRCELL-1)M55147C01001                           ==  1    NMOCU_ANR_NRREL_ADD
    ...      (NRCELL-1)M55147C00001 + (NRCELL-1)M55147C00002  ==  1    TOT_INTRA_FREQ_HO_DECISION_A3/A5
    ...      (NRCELL-1)M55142C00523                           ==  0    AVG_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-1)M55142C00524                           ==  0    AVG_TIME_HO_TGTSEL_MEASPRI_DEN
    ...      (NRCELL-1)M55142C00525                           ==  0    MAX_TIME_HO_TGTSEL_MEASPRI_NOM
    ...      (NRCELL-1)M55142C00526  in  (8, 12, 16)                   TOT_MEASREPORT_RECVD_MEASPRI

    pmcounters.Verify PM Counter Reference Table   reference_table=${reference_table}  pm_dir=${PMCounters_dir}


Fetch All PM Counter Values
    [Documentation]     This KW collects all PM counters and returns the directory, where they are stored.
    [Arguments]  ${gnb_id}  ${PM_Part}
    Log To Console    \n"PMcounters: Wait next Measurement Period Stops."
    pmcounters.Wait until the current Measurement Period stops    gnb_id=${gnb_id}
    ${PMCounters_dir}=     pmcounters.Collect PM Counter    gnb_id=${gnb_id}
    OperatingSystem.Move Directory    ${PMCounters_dir}  ${PMCounters_dir}_${PM_Part}
    RETURN    ${PMCounters_dir}_${PM_Part}
