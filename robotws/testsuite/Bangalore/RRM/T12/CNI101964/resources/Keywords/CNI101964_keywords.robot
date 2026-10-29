*** Settings ***
Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         Process
Library         String
Library         XML
Library         re
Library         taf.sbts.oam.coam.admin         WITH NAME    admin
Variables       ta5g_global_var
Library         ta5g_pm_counters
Library         ute_fsmaccess
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/sosReport.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot

Documentation       :copyright: Nokia
...                 :author   : Vikash Kumar
...                 :contact  : vikash.20.kumar@nokia.com
...                 :Feature Related all common Keywords


*** Variables ***
${DELTACONFIGDIR}          ${CURDIR}/../../config/scf
${TOPOLOGY}                CLOUD_5G_I_MP_AP_LO
${CAP_FILE}                ${CURDIR}/../../config/wts/ue_cap144k.cfg
${UE_NR_CAP}               mobiletype_1_ue_nr
${RRC_SEG_ALLOWED}         nr-rrc.rrc_SegAllowed_r16
${FRAGMENT_COUNT}          nr-rrc.segmentNumber_r16 == 15
${FRAGMENT_COUNT_NO}       nr-rrc.segmentNumber_r16
${FILTER_CNI}              nr-rrc.rrc_SegAllowed_r16||nr-rrc.ULDedicatedMessageSegment.fragment_count
${SUCC_CAP}      1
${MAX_CAP}       16
${AVG_CAP}       16
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts


*** Keywords ***
Prepare For CNI101964
    [Documentation]    Prepare for CNI101964
    ${Log_Path}    Create Log Directory    CNI101964
    Link SCOUT SCF to Configuration ID for Reporting
    Log To Console    log path created ${Log_Path}
    Create Basic Interface On UTE
    GNB Delta Commission    ${DELTACONFIGDIR}/Delta_Commissionoing_CNI101964.json
    Wait Coam Site To Be Ready
    Start UTE WTS     basic_CNI.cfg
    Basic Bring Up
    [Return]        ${Log_Path}

Stop Pcap Collection In GNB CU
    [Documentation]    This keyword is to stop PCAP logs from gnB
    ...     [arguments]    name     : This is file name where pcap logs will be collected, default name is gnbTcpdump
    ...                    Log_path : Path where pcap log file will be stored, default path is Log_Path
    ...     [return]    pcap_file   : pcap file path captured on wts
    ...     [usage]     Stop pcap collection in gNB
    ...                 Stop pcap collection in gNB     name=PCAPLOG    Log_Path= dir/dir/filename
    ...                 Stop pcap collection in gNB     gnbTcpdump1     dir/dir/filename
    [Arguments]                     ${name}=gnbTcpdump                  ${Log_Path}=${Log_Path}
    Stop pcap collection in gNB     ${name}             ${Log_Path}
    ${pcap_file}    Join Path       ${Log_Path}         ${name}         ${name}.pcap
    Log To Console                  pcap capture is stopped
    [Return]                        ${pcap_file}

Getting UE Param And Register UE
    [Documentation]   Using the taf.wts.runner library ue_param is being called to get the UE parameters
    ...               Also it is being used for UE register as per ue Capability set.
    [Arguments]    ${UE_ID}=1   ${ueCapThrs}=8950    ${ue_nr_Cap}=mobiletype_1_ue_nr    ${cap_file}=${CAP_FILE}
    wtsrunner.UE Param    id=${UE_ID}    ueCapInfomsg_Segment_Threshold=${ueCapThrs}
    ...      ue_nr_capabilities=${ue_nr_Cap}      capability_file=${cap_file}
    wtsrunner.UE Register      id=${UE_ID}     ue_nr_capabilities=mobiletype_1_ue_nr      capability_file=${cap_file}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${Register_complete_pattern}
    Initial Success Message for UE Register and Reregister      ${output}
    PDU Session setup   ${UE_ID}

Verify Fragment Count
    [Documentation]      This Keyword Verify Fragment Count
    [Arguments]     ${pcap_file}    ${filter}=${FRAGMENT_COUNT}    ${field}=${FRAGMENT_COUNT_NO}
    ${Frag_Count}         Get Fields from Pcap    ${pcap_file}     ${filter}    ${field}
    Log To Console      ${Frag_Count}
    Should Be Equal     ${Frag_Count}      15

Verify RRC Segment Allowed
    [Documentation]      This Keyword Verify RRC Segment Allowed
    [Arguments]     ${pcap_file}    ${filter}=${RRC_SEG_ALLOWED}    ${field}=${RRC_SEG_ALLOWED}
    ${RRC_Seg}         Get Fields from Pcap    ${pcap_file}      ${filter}     ${field}
    Log To Console      ${RRC_Seg}
    Should Be Equal     ${RRC_Seg}[0]      0

Verifying The PM Counter For CNI10964
    [Documentation]    Verifying The PM Counter For CNI10964
    [Arguments]    ${SUCC_CAP}=1    ${MAX_CAP}=16    ${AVG_CAP}=16   ${SEG_FAIL}=0
    Wait For Next Full Pm Interval
    ${pm_counter_file}      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55125C00004     ${SUCC_CAP}    NG_UE_CAP_INFO_SEG_SUCC
    ...     M55125C00005     ${MAX_CAP}     NG_UE_CAP_INFO_SEG_MAX
    ...     M55125C00006     ${AVG_CAP}     NG_UE_CAP_INFO_SEG_AVG
    ...     M55125C00007     ${SEG_FAIL}    NG_UE_CAP_INFO_SEG_FAIL
    ...     local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

