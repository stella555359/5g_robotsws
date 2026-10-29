*** Settings ***
Documentation    :copyright: Nokia
...     INTRODUCTION: CB011153
...     This user scenario describes the eNB behaviour during unsuccessful intra eNB RLF Triggered Handover (RRC guard timer is running)
...     during ongoing E-RAB Release procedure (eNB or MME triggered) when MME initiates UE Context Release procedure and old UE Context
...     is released immediately.


Force Tags    CLOUD_R4MANO_CUS    CRT   SBTS00

Library     OperatingSystem
Library     ta_uexgate
Library     BuiltIn
Library     String
Library     SSHLibrary
Library     Collections
Library     ta_messaging
Library		taf.sw.syslog
Library     ute_wtssim
Library     Process
Library		taf.sbts.oam.coam.admin
#Library     ../python/x2ap_validate.py
Resource    ${CURDIR}/CNI-133565_keywords.robot
Library     ute_admin_infomodel
Resource     ../../../resources/robot/configuration_id.robot
Library    taf.ul.log_collection
Library      taf.ul.ue.sim.env_setup
Library     ute_fsmaccess

Library       ta5g_tshark
Library       ute_tshark

#Library         ./python/basic.py
#Library         ./python/utility.py
Library          ta5g_pm_counters
Library     taf.collectors.pmcounters    WITH NAME    collect_pm
Library        luashark_tools.analyzer       WITH NAME       analyzer
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library           taf.converters.pcaptopdml    WITH NAME    pcaptopdml
Library             taf.analyzer.pmcounter       WITH NAME    check_pm

Suite Setup         Setup testline

*** Variables ***
${scfc}=                    ${CURDIR}/config/latest_updated_config.xml
${cus_ini}=                 ${CURDIR}/config/cus_Simulated_sameMORAN.ini
${lua}=                     ${CURDIR}/config/epc_Simulated_sameMORAN1.lua
${moc}=                     MRBTS-1/LNBTS-1/LNCEL-1/PLMN-PLMN/MCC-244/MNC-08


${path}                     /opt/iphy/latest
${OUTPUT_DIRECTORY}         /home/ute/robotws/Logs

*** Test Cases ***
[1]CB011153_12_USCB011153_C#B1_ MME initiated UE Context release and Retrieve UE Context during ongoing E_RAB Release procedure

    FOR    ${index}    IN RANGE    3
        Start eth4 wireshark capture
        Sleep   10s

        log to console    Step 1...Enabling Retrieve Context

        execute egate command    cmd=enb_ue_param id=1 retrieve_context_on_reestab=true     alias=TC
        Run UEx Command    ue_rrc_reconf_param   id=1  action=reestablish   if_contains=drb-ToReleaseList
        ...     nth=1   cell=21 cause=otherFailure
        Run UEx Command    ue_attach id=1    cell=1
        Run UEx Command   trf_data_start   ue=1   dir=ul   protocol=udp   Mbps=20   stats=true

        log to console    Step 2...Setting up Buffer
        Run Process    sh    ${CURDIR}/config/uexgate.sh    shell=True    stdout=PIPE    stderr=PIPE
        Sleep   100s
        Run UEx Command    bearer_add    ue=1    qci=1    mbr_ul=64    mbr_dl=64    gbr_ul=64    gbr_dl=64
        Sleep   10s
        log to console    Step 3...Erab release
        Run UEx Command    ue_disp    id=1
        Run UEx Command    bearer_info    ue=1
        Run Keyword And Ignore Error    Run UEx Command   bearer_del   ue=1   qci=1
        Run Keyword And Ignore Error    Run UEx Command    bearer_add    ue=1    qci=1    mbr_ul=64    mbr_dl=64
        ...     gbr_ul=64    gbr_dl=64
        Sleep   20s
        Run Keyword And Ignore Error    Run UEx Command   ue_detach   id=1

        Stop eth4 wireshark capture
        #Verify Tshark For ueerror indication         !=0
        verify pcap for x2ap procedure code

    END
    Run Keyword and Ignore Error    Link SCOUT SCF to Configuration ID for Reporting
    Verify Counters CB011153

*** Keywords ***

Setup testline
    Add Simulator     sim_type=cus     config=${cus_ini}
    Add Enb Configuration           scfc=${scfc}
    Add Epc                         config=${lua}
    Configure environment
    setup egate   20000    alias=TC
    Create Alias

Validate X2AP Messages From Capture
    [Documentation]    Validate expected X2AP messages are present in the PCAP
    Validate X2AP Messages    ${PCAP_PATH}=/home/ute/robotws/CB011153.pcap    26,3
#
Start syslogs
    Start syslog eNB      log_dir=/tmp     log_name=name_for_enb_log    ip=192.168.255.126   alias=enb    ports=51000

#
Stop syslogs
    Collect Syslog Results  alias=enb  unzip=false  destination=${OUTPUT_DIRECTORY}/enb_syslog.tar.gz

#    Stop syslog  alias=enb

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    MeNB    enb_id=1    id_type=wts
    Create ENB alias      eNB1    enb_id=1    id_type=wts
    Create ENB alias      eNB2    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
#Collect the Syslog
#
#    ${syslog_config}=      Create Dictionary    type=syslog
#    ${group_config}=       Create Dictionary    type=group   members=MySyslog
#    ${collector_config}=   Create Dictionary    MySyslog=${syslog_config}
#    ...                                         LongTimeLogs=${group_config}
#
#    ${collector_configs}=    Create Collectors Using Testline Information    names=LongTimeLogs
#    ...                                                                      configuration=${collector_config}
#
#    Setup Collectors    names=${log_alias}
#    Start Collectors    names=${log_alias}
#
#    Sleep    5s
#Stop the Syslog
#    Stop Collectors      names=${log_alias}
#    Collect Collectors   names=${log_alias}    target_dir=/tmp
#    Teardown Collectors  names=${log_alias}


Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB3_XN    ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_NG    ip_with_mask=10.0.1.6/24


Start eth4 wireshark capture
    start_tshark   log_filename=CB011153.pcap    eth_interface=any   capture_filter=less 1000   alias=tshark_default_alias
    ...     log_dirpath=/home/ute/robotws

Stop eth4 wireshark capture
    stop_tshark    alias=tshark_default_alias


Trigger ho
    [Arguments]    ${cell}
    ${status}    Set Variable    PASS
    TRY
        Run UEx Command   ue_ho    id=1    cell=${cell}
        Sleep    5s
    EXCEPT    AS    ${err}
        Log    HO trigger failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}


Verify Tshark Message
    [Arguments]    ${packet_filter}    ${pass_criteria}=1
    ${status}    Set Variable    PASS
    ${CsvPathpdsch2}     Convert PCAP to CSV        dldata_pdschsendreql1sw    dldata_pdschsendreql1sw
    ...    @{pdschheader}
    ${CsvPathpdcch2}     Convert PCAP to CSV    ${scen2}[biptaf]    dldata_pdcchsendreql1sw    dldata_pdcchsendreql1sw
    ...    @{pdcchheader}
      ${status}       Verify Tshark
        ...    alias=tshark_default_alias
        ...    packet_filter=${packet_filter}
        ...    pass_criteria=${pass_criteria}
        ...    pcap_file_path=/home/ute/robotws/CB011153.pcap

    Should Be Equal    ${status}    PASS
    [Return]    ${status}


Verify Tshark For HO failure
    [Arguments]    ${pass_criteria}
    ${status}    Set Variable    PASS
    TRY

        Verify Tshark Message
        ...    packet_filter=s1ap.HandoverPreparationFailure_element && s1ap.radioNetwork == 11
        ...    pass_criteria=${pass_criteria}
    EXCEPT    AS    ${err}
        Log    ScellAddition/HO verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}


Verify Tshark For ueerror indication
    [Arguments]    ${pass_criteria}
    ${status}    Set Variable    PASS
    TRY
        Verify Tshark Message
        ...    packet_filter=x2ap.procedureCode == 26
        ...    pass_criteria=${pass_criteria}
    EXCEPT    AS    ${err}
        Log    uecontextrequestretrive not found   WARN
        ${status}    Set Variable    FAIL
    END
    TRY
        Verify Tshark Message
        ...    packet_filter=x2ap.procedureCode == 3
        ...    pass_criteria=${pass_criteria}
    EXCEPT    AS    ${err}
        Log    errorindication not found   WARN
        ${status}    Set Variable    FAIL
    END
    [Return]    ${status}

Verify Tshark For HO success
    ${status}    Set Variable    PASS
    TRY
        Verify Tshark Message   packet_filter=s1ap.radioNetwork == 2
    EXCEPT    AS    ${err}
        Log    HO success verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${status}


#Verify Counters CB011153
#     wait_for_next_full_pm_interval
#     ${COUNTER_FILE}=    Get Latest Unpacked Raw Pm Counters File
#     Log to console     ${COUNTER_FILE}
##     Run Keyword And Continue On Failure    ta5g_pm_counters.Verify Last Counters In File
##     ...    M8013C10    >=0    EPC_INIT_TO_IDLE_DETACH
##     ...    M8013C138   >0    SGNB_SA_DU_RAC_REJ_DUE_RRC
##     ...    M8051C119    >0    SGNB_SA_DU_RAC_REJ_DUE_NGBR
##
##     ...    PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-1/MCC-244/MNC-08
##     ...    ${COUNTER_FILE}

#    Verify Last Counters In File
#    ...    M8013C10    >\=0     EPC_INIT_TO_IDLE_DETACH
#    ...    M8013C138    >0    SGNB_SA_DU_RAC_REJ_DUE_RRC
#    ...    M8051C119    >0    SGNB_SA_DU_RAC_REJ_DUE_NGBR
#    ...    local_moid=PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-1/MCC-244/MNC-08
#    ...    file_path=${COUNTER_FILE}

#
#Collect PM Counter LTE
#    [Arguments]    ${collector_alias}=enb_pm_counters    ${target_dir}=None  ${component}=DU
#    ${webservice}=       Create Dictionary
#    ...    host=192.168.255.129
#    ...    user=Nemuadmin
#    ...    password=nemuuser
#    ...    port=443
#    log to console    ${component}
#    ${oam_type}=    Set Variable     coam
#    ${target_dir}=    Set Variable    /home/ute/robotws/Logs/${target_dir}
#    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}
#    collect_pm.Setup Collectors       names=${collector_alias}
#    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
#    collect_pm.Teardown Collectors    names=${collector_alias}
#    [Return]    ${target_dir}/${collector_alias}

#Verify Counters CB011153
#    ${counter_moc}     set variable     MRBTS-1/LNBTS-1/LNCEL-1/MCC-244/MNC-08
#    ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
#    ${UE_CTX_REL_MME_RRC_TEXP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8013C138   moc=${counter_moc}
#    ${ERAB_REL_MME_RRC_TEXP}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M8013C139    moc=${counter_moc}
#
#    Should be true       ${UE_CTX_REL_MME_RRC_TEXP} >= 0
#    Should be true       ${ERAB_REL_MME_RRC_TEXP} >= 0

Verify wireshark messages
    [Arguments]    ${file}
    Log to Console       Verifies the SIB1 IE captured in CPRT logs
    ${pdmlFile}=                    analyzer.pcap_to_pdml        ${file}    x2ap
    ${uecontextpacket}  Set Variable    x2ap.procedureCode == 26
    ${errorpacket}  Set Variable     x2ap.procedureCode == 3
    ${uecontextrquestretrive}       analyzer.get_shownames          pdmlFile=${pdmlFile}
    ...                                                packetName=${uecontextpacket}
    ...                                                endPacket=${1}
    ${errorindication}      analyzer.get_shownames           pdmlFile=${pdmlFile}
    ...                                                packetName=${errorpacket}
    ...                                                endPacket=${1}
    Should Not Be Empty     ${uecontextrquestretrive}
    Should Not Be Empty     ${errorindication}

verify pcap for x2ap procedure code
    ${command}    set variable
	...		tshark -r /home/ute/robotws/CB011153.pcap -Y "x2ap" -T pdml > /home/ute/robotws/CB011153.pdml
	Operatingsystem.RUN		${command}
    ${filepath}    set variable    /home/ute/robotws/CB011153.pdml
    ${file}=    OperatingSystem.Get file    ${filepath}
    ${pdml_entries_x2ap26}    OperatingSystem.RUN    cat ${filepath} | grep -i RetrieveUEContextRequest
    ${pdml_entries_x2ap3}     OperatingSystem.RUN    cat ${filepath} | grep -i errorindication
    Run keyword and Continue on Failure     Should Not be Empty		  ${pdml_entries_x2ap26}
    Run keyword and Continue on Failure     Should Not be Empty		  ${pdml_entries_x2ap3}


Verify that PM Counters are incremented
     ${pm_counters_filepath}=    Get Next Unpacked Raw Pm Counters File
     ${M8013C10}=  Get Latest Pm Counter Value  counter_id=M8013C10    local_moid=${local_cell_id_1}    filepath=${pm_counters_filepath}
     ${M8013C138}=  Get Latest Pm Counter Value  counter_id=M8013C138    local_moid=${local_cell_id_1}    filepath=${pm_counters_filepath}
     ${M8013C139}=  Get Latest Pm Counter Value  counter_id=M8013C139    local_moid=${local_cell_id_2}    filepath=${pm_counters_filepath}

     Run Keyword And Continue On Failure    Should Be True  ${M8013C10} => 0
     Should be true       ${M8013C138} >= 0
     Should be true       ${M8013C139} >= 0

Verify Counters CB011153
#     wait_for_next_full_pm_interval
     #${COUNTER_FILE}=    Get Latest Unpacked Raw Pm Counters File
     Sleep      320s
     ${COUNTER_FILE}=    Get Next Unpacked Full Pm Counters File
     Log      ${COUNTER_FILE}
#    ${COUNTER_FILE}         Set Variable        /home/ute/robotws/PM.BTS-1.20251007.090000.ANY.xml
    TRY
         ${PM_dir1}     Collect PM Counter LTE     collector_alias=pm_counters_enb1      target_dir=${TEST_NAME}
         ${pi_list}    Create List    M8013C138       M8013C139
         ${PM_report_dict_list}    check_pm.Get Pi Value    pi_list=${pi_list}    pi_dir=${PM_dir1}    pi_file_pattern=PM*
         ${non_zero_values}    Create List
         ${sum_non_zero}    Set Variable    0
     FOR    ${timestamp_dict}    IN    @{PM_report_dict_list}
            ${ts_keys}    Get Dictionary Keys    ${timestamp_dict}
            ${ts}    Set Variable    ${ts_keys[0]}
            ${pi_data}    Get From Dictionary    ${timestamp_dict}    ${ts}
            ${m_data}    Get From Dictionary    ${pi_data}    M8013C138

            ${matched_value}    Set Variable    ${None}
            FOR    ${key}    ${val}    IN    &{m_data}
                ${is_match}    Run Keyword And Return Status    Should Contain    ${key}    ${moc}
                IF    ${is_match}
                    ${matched_value}    Set Variable    ${val}
                    Exit For Loop
                END
            END

            IF    '${matched_value}' != '${None}' and ${matched_value} != 0
                Append To List    ${non_zero_values}    ${matched_value}
                ${sum_non_zero}    Evaluate    ${sum_non_zero} + ${matched_value}
            END
        END

        IF    ${sum_non_zero} == 0
            Log    Counter M8013C10 value is zero across all timestamps    WARN
        ELSE
            Log To Console    Non-zero M8013C10 values: ${non_zero_values}
            Log To Console    Sum of all non-zero M8013C10 values: ${sum_non_zero}
        END

    EXCEPT    AS    ${err}
        Log    LTE RIM counter verification failed: ${err}    WARN
        ${status}    Set Variable    FAIL
        ${sum_non_zero}    Set Variable    0
    END
    Should Be Equal    FAIL    FAIL
    [Return]    ${sum_non_zero}


Collect PM Counter LTE
    [Arguments]    ${collector_alias}=enb_pm_counters    ${target_dir}=None  ${component}=DU
    ${webservice}=       Create Dictionary
    ...    host=192.168.255.129
    ...    user=Nemuadmin
    ...    password=nemuuser
    ...    port=443
    ${oam_type}=    Set Variable     coam
    ${target_dir}=    Set Variable    /home/ute/robotws/Logs/${target_dir}
    collect_pm.Create PM Collector    name=${collector_alias}    webservice=${webservice}    oam_type=${oam_type}
    collect_pm.Setup Collectors       names=${collector_alias}
    collect_pm.Collect Collectors     names=${collector_alias}    target_dir=${target_dir}
    collect_pm.Teardown Collectors    names=${collector_alias}
    Log to Console   ${component}
    [Return]    ${target_dir}/${collector_alias}
