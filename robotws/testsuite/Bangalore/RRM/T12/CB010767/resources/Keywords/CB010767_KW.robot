*** Settings ***
Documentation     This file contains feature specific keywords
Library         BuiltIn
Library         Collections
Library         OperatingSystem
Library         String
Library         taf.wts.runner    WITH NAME    wtsrunner
Library         taf.config.scf    WITH NAME    scf
Library         ute_wtssim
Library         ta5g_commissioning
Resource        ${CURDIR}/../../../resources/Keywords/sosReport.robot
Resource        ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource        ${CURDIR}/../../../resources/Variables/common_variables.robot
Resource        ${CURDIR}/../../../resources/Keywords/common_keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource        ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource        ${CURDIR}/../../../resources/Keywords/HO_KW.robot


*** Variables ***
${Pdu_session_mod_patten}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${Pdu_session_qos_patten}      PDU SESSION RESOURCE MODIFY RESPONSE
${WTS_WORKING_DIR}             /opt/iphy/latest
${GNB_IP}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_USERNAME}     ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_PASSWORD}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${TRAFFIC_DL_RATE}             5
${TRAFFIC_UL_RATE}             2
${TRAFFIC_DURATION}            10
${ymlUteLinuxTrimCrLf}         tr -d '\r\n'
${AP_CONFIG_BASIC}         ${CURDIR}/../../config/wts
${TOPOLOGY}                 CLOUD_5G_I_LOO_AP_LOOO


*** Keywords ***
Make a SA call for GBR NonGBR bearer
    [Arguments]     ${UE_ID}=${UE_ID}    ${gw_ID}=${gw_ID}
    Flush console logs
    Enable Internal TG   ${UE_ID}    1
    Flush console logs
    wtsrunner.ue_register   id=${UE_ID}
    sleep   20s
    wtsrunner.smf_param     additional_qosflows_to_activate=2,3       id=1
    wtsrunner.ue_pdu_session_setup    pdu=1    ue=${UE_ID}   nwslice=1   gw=${gw_ID}
    Sleep   30s
    Flush console logs

Commision iphy
    [Documentation]    This keyword is used to change RMOD type
    [Arguments]   ${iphy}=${EMPTY}
    Run Keyword Unless    '${iphy}' == '${EMPTY}'    update_and_put_iphy_xml
    ...      input_filepath=${iphy}

Get cellBarring Status
    [Arguments]          ${pcap_file}       ${cellID}
    ${Barring_stat_2RX}          Get Fields from Pcap     ${pcap_file}
    ...     (f1ap.procedureCode == 3)&&(nr-rrc.physCellId == ${cellID})         nr-rrc.cellBarredRedCap2Rx_r17
    ${Barring_stat_1RX}          Get Fields from Pcap     ${pcap_file}
    ...     (f1ap.procedureCode == 3)&&(nr-rrc.physCellId == ${cellID})         nr-rrc.cellBarredRedCap1Rx_r17
    [return]             ${Barring_stat_2RX}    ${Barring_stat_1RX}

Verify Traffic Data
    [Arguments]    ${direction}    ${throughput}
    [Documentation]    Checks Throughput and Duration of traffic
    ${result}                  Return Grep Match    /tmp/iperf_${direction}.txt    " Mbits/sec"
    ${actualLines}             Get Line Count    ${result}
    ${actualTime}              Evaluate    ${actualLines} / 60
    ${expectedLines}           Evaluate    ${TRAFFIC_DURATION} * 60 - 5
    ${errMsg}                  Catenate    ${direction} Traffic duration: ${actualTime} mins
    ...                        | Expected Duration ${TRAFFIC_DURATION} mins
    Should Match Regexp        ${result}    ([^\n]+Mbits/sec[^\n]+\n){${expectedLines}}    msg=${errMsg}
    Should Not Match Regexp    ${result}    ([^${throughput}]|\d{2,})\.\d+ Mbits/sec
    ...                        msg=${direction} Traffic is less than ${throughput} Mbits/sec

Execute Kill Processes with PID
    [Arguments]    ${process}    ${pgrepArgs}=${EMPTY}
    ...                ${killArgs}=${EMPTY}
    [Documentation]    Use "kill" to stop a proccess by its process ID (PID) from a host machine
    ...                If process does not exist return from this keyword.
    ...                String: "[sudo] password for ute: " will be removed in case of sudo prompt.
    ...                Parameters:
    ...                1. processes - list of processes to kill
    ...                2. pgrepArgs - additional pgrep arguments
    ...                3. killArgs - additional kill arguments
    ...                4. sudo - put "sudo" if desired to run with sudo rights

    ${type}                           Evaluate    type(${process}).__name__
    ${pattern}                        Run Keyword If    "${type}" == "list"    Evaluate    "|".join(${process})
    ...                               ELSE    Remove String    ${process}    "
    ${result}                         Get Pgrep Process ID    ${pattern}    ${pgrepArgs}    sudo=${sudo}
    ${pid}                            Remove String    ${result}    [sudo] password for ute:${SPACE}
    Return From Keyword if            "${pid}" == "${EMPTY}"    "Processes do not exist"
    ${command}                        Catenate    ${sudo} kill -9 ${killArgs} ${pid}
    Run                               ${command}
	Sleep                             3 sec
    Pgrep Process Should Not Exist    ${pattern}

Execute Iperf in Linux
    [Arguments]    ${args}=${EMPTY}    ${pipeArgs}=${EMPTY}
    ${result}    Run Keyword    Start Process    iperf ${args} ${pipeArgs}    shell=${TRUE}
    [Return]    ${result}

Return Grep Match
    [Arguments]    ${file}    ${pattern}    ${postPipe}=${EMPTY}
    ${result}    Run    grep ${pattern} ${file} ${postPipe}

    [Return]    ${result}

Pgrep Process Should Not Exist
    [Arguments]    ${pattern}    ${sudo}=${EMPTY}    ${args}=-c
    ${command}    Catenate    ${sudo} pgrep ${args} "${pattern}" | ${ymlUteLinuxTrimCrLf}
    ${result}     Run    ${command}
    Should Be Equal    "${result}"    "0"    msg=${pattern} is still running!

Get Pgrep Process ID
    [Arguments]    ${pattern}    ${args}=${EMPTY}    ${sudo}=sudo
    [Documentation]    Use "pgrep" to get the proccess ID (PID) of a process name from a host machine
    ...                Parameters:
    ...                1. pattern - pattern used by pgrep to match a running process
    ...                2. args - additional pgrep arguments
    ...                3. sudo - put "sudo" if desired to run with sudo rights
    ...                Returns: Process ID (PID) if pattern has a match, else returns EMPTY
    ${command}    Catenate    ${sudo}  pgrep ${args} "${pattern}" | ${ymlUteLinuxTrimCrLf}
    ${result}     Run    ${command}
    [Return]    ${result}

Verify Downlink Traffic Data Rate
    [Documentation]    Run DL Traffic and Verify Throughput
    Set Suite Variable                 ${g_TrafficDlStatus}    ${FALSE}
    Execute Iperf in Linux             args=-c 1.2.4.2 -u -p 7070 -l 1300 -b ${TRAFFIC_DL_RATE}M -i 1 -t 1200
    Execute Iperf in Linux             args=-s -u -p 7070 -i 1 -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_DL.txt
    Log to Console                     Running DL Traffic for ${TRAFFIC_DURATION} minutes
    Sleep                              ${TRAFFIC_DURATION} minutes
    Execute Kill Processes with PID    "iperf"    pgrepArgs=-d ' '
    ...                                sudo=sudo -S
    Verify Traffic Data                DL    5
    Set Suite Variable                 ${g_TrafficDlStatus}    ${TRUE}

Verify Uplink Traffic Data Rate
    [Documentation]    Run UL Traffic and Verify Throughput
    Set Suite Variable                 ${g_TrafficUlStatus}    ${FALSE}
    Execute Iperf in Linux             args=-c 72.23.0.1 -u -p 7070 -l 1300 -b ${TRAFFIC_UL_RATE}M -i 1 -t 1200
    Execute Iperf in Linux             args=-s -u -p 7070 -i 1 -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_UL.txt
    Log to console                     Running UL Traffic for ${TRAFFIC_DURATION} minutes
    Sleep                              ${TRAFFIC_DURATION} minutes
    Execute Kill Processes with PID    "iperf"    pgrepArgs=-d ' '
    ...                                sudo=sudo -S
    Verify Traffic Data                UL    2
    Set Suite Variable                 ${g_TrafficUlStatus}    ${TRUE}

Verify Traffic
    [Documentation]    Verify Traffic
    ${traffic}        Catenate    ${g_TrafficDlStatus} and ${g_TrafficUlStatus}
    Should Be True    ${traffic}    msg=Traffic Failed!

Extract XnAP Bcast Information
    [Documentation]     This KW is used to verify extract the value of redcap broadcast info in Xnap
    ...                 author:Amitha
    ...                 added as part of RCA
    [Arguments]         ${PCAP_FILE}
    ${BCAST_VALUE}      Get Fields From Pcap     ${PCAP_FILE}
    ...                 (xnap.procedureCode == 17)         xnap.Redcap_Bcast_Information
    @{BCAST_LIST}       Split String                 ${BCAST_VALUE}         ,
    [Return]            ${BCAST_LIST}[0]

Flush console logs
    wtsrunner.sim_log_set
    log     flushed log

Check Pattern in Egate Console Log
    [Arguments]    ${pattern}    ${file}=${run_script_log_set}
    [Documentation]    This keyword checks if the ${pattern} is present in the egate_console.log file for the SA variant
    ...                Modified Date: 09-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword If    '${variant_name}' != '4G5G_COMBO_MultiUE'
    ...    wtsrunner.script    file=${file}    entry=sim_log_set_flush()
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search pattern should Exists In EGATE
    ...                            ${WTS_DIR}/egate_console.log     ${pattern}

Tear down for B8
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_Configuration_IAIEGNB_XN_reverse.json
    Sleep   20s
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_8127_reverse.json
    Sleep   20s
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    Sleep   60s
    Wait Coam Site to be Ready

Tear down for CB010767_B_B1B2e_9
    Run    sudo ip addr delete 10.0.1.141/24 dev eth3
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_Configuration_scf_IEFXn_reverse.json
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_8127_reverse.json
    Sleep   60s
    Wait Coam Site to be Ready

tear down for CB010767_B6a_23
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_8127_reverse.json
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_Configuration_APoABIL_IANG_FDD_reverse.json
    Sleep   60s
    Wait Coam Site to be Ready

Tear Down for CB010767_B6c_26
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_8127_reverse.json
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_FeatureEnabled_NoCellBarring_reverse.json
    GNB Delta commission     ${CURDIR}/../../config/gnb_scf/Delta_Configuration_APoABIL_IANG_FDD_reverse.json
    Sleep   60s
    Wait Coam Site to be Ready
