*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Manasa
...              :contact: manasa.shankarappa@nokia.com
...              The aim of the Tetscase describes successful configuration of Long PUCCH and verifies expansion of the 
...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE for SA with 
...              Single UE Call Attach on ABIO             
...              *REQUIREMENTS COVERAGE:
...              *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_16150

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ./resources/CB006878_Resource.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep    120s
...                 AND     Start Log   btslog

Suite Teardown    Run Keywords     
...               Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...               AND   Stop Log   btslog   snapshot    sosreport

*** Variables ***
${wts_cfg_file}     basic_setup.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${epc_log_path}    /tmp/

${sa_ue_id}      1
${sa_trf_id}    1
${sa_qfi_id}    1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TEST_NAME}    TC01

*** Test Cases ***
CB006878_A#1_01_LongPUCCH_for_FR1_TDD_NonBF_with_SA_SingleUE_Call_attach_ABIO
    [Tags]      QC_220040
    [Documentation]   
    ...              The aim of the Tetscase describes successful configuration of Long PUCCH and verifies expansion of the
    ...              PUSCH region over the PRB of PUCCH in the pCSI area which are still not allocated to any UE for SA with
    ...              Single UE Call Attach on ABIO

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    cprt
#Step 1. Attach Single SA UE and start low DL data and Max UL data
    UE Register should be Successful    ${sa_ue_id}
    ${path1}    Stop Log    cprt   test_scenario=ue_attach
    Trigger DL Data Traffic for SA    ue_id=${sa_ue_id}    Traffic_rate=mbps     dl_rate=20      trf_id=${sa_trf_id}     
    Trigger High UL Traffic for SA    ue_id=${sa_ue_id}    Traffic_rate=mbps     ul_rate=250
    sleep   120s
    Validate Max DL Traffic For SA    ue_id=${sa_ue_id}     dl_rate=20     qfi_id=${sa_qfi_id}
    Validate Max UL Traffic For SA   ue_id=${sa_ue_id}     ul_rate=220     qfi_id=${sa_qfi_id}
    Start Log    biptaf
    sleep   2s
    ${bip_path}   Stop Log    biptaf  test_scenario=data_traffic
    Run Keyword And Continue on Failure     Verify prbs in uldata_puschreceivereq new     ${bip_path}[biptaf]/BIP_L1L2.pcap   ${9}    ${255}
    [Teardown]  Link SCOUT SCF to Configuration ID for Reporting    


*** Keywords ***
Validate Max DL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Maximum data rate must be within 99% and 110% of expected rate
    ...                2. DL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${dl_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=dl
    ${bearer_stat_dl}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Maximum Rate      ${bearer_stat_dl}    DL    ${dl_rate}

Check Maximum Rate
    [Arguments]    ${bearer_stat}    ${dir}    ${mbps}
    ${output}         Get Regexp Matches    ${bearer_stat}    Maximum data rate +(\\d+)    1
    ${result}         Evaluate    (${mbps} * 1000000 * 1.2) > int(${output[0]}) > (${mbps} * 1000000 * 0.98)
    ${result}         Evaluate    (${mbps} * 1000000 * 1.06) > int(${output[0]}) > (${mbps} * 1000000 * 0.98)
    Run Keyword if    ${result}    Log to Console    ${dir} Maximum data rate: ${output[0]}
    ...               ELSE    BuiltIn.Log     ${dir} Maximum data rate: ${output[0]}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=${dir} Maximum data rate failed!

Validate Max UL Traffic For SA
    [Documentation]    SA Traffic Criteria
    ...                1. Maximum data rate must be within 99% and 110% of expected rate
    ...                2. UL Bytes Received must be equal to ALL Bytes Sent
    [Arguments]    ${ue_id}     ${ul_rate}     ${pdu_id}=${Pdu_session_ID}      ${qfi_id}=${QFI_ID}
    wtsrunner.bearer_stats  ue=${ue_id}   pdu=${pdu_id}   qfi=${qfi_id}   dir=ul
    ${bearer_stat_ul}      wtsrunner.read_wtsemu_output_until    expected=Average packet interval
    ...                     timeout=30
    Check Maximum Rate      ${bearer_stat_ul}    UL    ${ul_rate}

Trigger High UL Traffic for SA
    [Arguments]    ${ue_id}     ${Traffic_rate}     ${ul_rate}
    [Documentation]    This keyword starts the UL Traffic for the SA variant for higher data rate
    ${ul_rate_loop}=      Evaluate      ${ul_rate}//175
    ${ul_rate_reminder}=     Evaluate      ${ul_rate}%175
    ${ul_rate_loop}=      Evaluate     ${ul_rate_loop}+1
    ${TRF_ID}=   Set Variable   1
    FOR   ${loop}   IN RANGE   0   ${ul_rate_loop}
        Run Keyword if    ${loop}==0    Trigger UL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=${ul_rate_reminder}     pdu_id=1    trf_id=${TRF_ID}
        Run Keyword if    ${loop}>0     Trigger UL Data Traffic for SA   ue_id=${ue_id}    Traffic_rate=${Traffic_rate}
        ...   ul_rate=175     pdu_id=1    trf_id=${TRF_ID}
        ${TRF_ID}=      Evaluate     ${TRF_ID}+1
        sleep   2s
    END

Verify prbs in uldata_puschreceivereq new
    [Arguments]
    ...      ${pcapFile}   ${start_prb}   ${num_of_prb}
    [Documentation]
    ...     Verifies start prb and number of prbs value used in uldata_puschreceivereq in provided pcap traces
    ${num_of_prbs_using_lower_pcsi}=   set Variable   0
    ${num_of_prbs_using_upper_pcsi}=   set Variable   0
    ${pdmlFile}=         Get filtered PDML file from pcap        ${pcapFile}         (uldata_puschreceivereq && 3gpp.subcellid == 0 )
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_START_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_start_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_START_PRB}
        ${packet_start_prb}=    convert to integer      ${packet_start_prb}
        should be true      ${packet_start_prb} >= ${start_prb}
        ${num_of_prbs_using_lower_pcsi}=  Run Keyword if     '${packet_start_prb}' == '${start_prb}'
        ...                               Evaluate   ${num_of_prbs_using_lower_pcsi} + 1
        ...                               ELSE     Set Variable   ${num_of_prbs_using_lower_pcsi}
    END
    @{list_of_values}    get matched packet in a list     uldata_puschreceivereq    ${pdmlFile}   ${FIELDS_NUM_PRB}
    FOR      ${prb_packet}     IN      @{list_of_values}
        ${packet_num_prb}               Get Value In Packet Match
        ...                   packetMatch=${prb_packet}
        ...                   field=${FIELDS_NUM_PRB}
        ${packet_num_prb}=      convert to integer      ${packet_num_prb}
        should be true      ${packet_num_prb} <= ${num_of_prb}
        ${num_of_prbs_using_upper_pcsi}=   Run Keyword if     '${packet_num_prb}' == '${num_of_prb}'
        ...                               Evaluate   ${num_of_prbs_using_upper_pcsi} + 1
        ...                               ELSE      Set Variable   ${num_of_prbs_using_upper_pcsi}
    END
    Log to console  Checking lower PCSI and upper PCSI prb region are used.
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_lower_pcsi} > 50
    Run Keyword and continue on Failure     should be true  ${num_of_prbs_using_upper_pcsi} > 50

