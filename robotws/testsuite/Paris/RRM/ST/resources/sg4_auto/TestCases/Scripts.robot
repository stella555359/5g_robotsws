*** Settings ***
Documentation
...     TODO
#
#...     AUTHOR (I&V-4):
#...         Alberto Fernandez

#Suite Setup        Setup Sequence
#Suite Teardown     Teardown Sequence
Resource     ../Resources/keywords_common.robot

Library	    OperatingSystem
Library	    taf.ue                                  WITH NAME    ue
Library	    taf.sbts.oam.coam.admin    		        WITH NAME    coam
Library	    taf.transport.ssh          		        WITH NAME    ssh
Library	    taf.collectors.btslog      		        WITH NAME    btslog
Library	    taf.collectors.core        		        WITH NAME    core
Library     taf.analyzer.iperf_throughput           WITH NAME    tput
Library     Scripts.py
Library     ${CURDIR}/../TestCases/CB009836/myTtiParserScro.py      WITH NAME    TTiParser
Library    taf/rfrl/uuf4all/resources/python/uuf_rfrl_common.py  WITH NAME  uuf_rfrl_common


#Library     ${CURDIR}/../TestCases/CB009836/myScriptPythonScro.py           WITH NAME    Scro2


*** Variables ***

#${tl}       ${EMPTY}
${alias_1}=      UE_1
${capabilities_1}=      REAL_UE_1
# Traffic mapping:
# ----------------
${protocol}               udp
${tput_duration}          360s
${tput_DL_bandwith_hi}       800 Mbits/sec
${tput_DL_bandwith_mi}       200 Mbits/sec
${tput_DL_bandwith_lo}       20 Mbits/sec
${tput_UL_ngbr_high}      180 Mbits/sec
${tput_UL_ngbr_low}       10 Mbits/sec
${tput_UL_gbr}            20 Mbits/sec
${tput_DL_gbr}            30 Mbits/sec

${qci_dl}                 9
${qci_ul}                 9
${qci_ul_gbr}             3
${Packet_Size}            1000
${syslog}=      SYSLOG_CV258.LOG
${syslog_folder}        /tmp/btslog2
@{dlstreams}                  ${4}       ${4}       ${4}
@{ulstreams}                  ${4}       ${4}       ${4}
${transfer_duration}        120s
${MUMIN}=                       ${True}
${MUMIN_CONFIG_FILE}=           /home/localuser/AutoDev/7_20_UTE5GCLASSSV397/rmod_config.yaml
${VIRTUALENV_DIR}=              /tmp  # path to virtual env used in starting syslog on remote vm
${SERIAL_CONSOLE}=              ${False}
${BTS_HOST_IP}=        10.14.48.17
${rmod_id}                    0
*** Test Cases ***
E2E_TL_SW_MUMIN
    Log      ${MUMIN_CONFIG_FILE}       console=True
    uuf_rfrl_common.Setup Mumin
    BuiltIn.Sleep     300s
    Run Keyword If  ${MUMIN}  uuf_rfrl_common.Mumin Gather Logs  ${VIRTUALENV_DIR}/${TEST_NAME}

Test_Simple_Call

    [Setup]          Run Keywords
    ...     Setup Sequence      Common Preconditions       Set MaxSpPRB

    [Teardown]        Common Teardown

    [Timeout]        40min

    Set Test Variable       ${actTddCsirsAllocOptimization}     false
    set test variable       ${maxNumStreamPrbL1Sp}     2184
    set test variable       ${maxNumLayerPrbL1Sp}     2184
    set test variable       ${maxNumStreamPrbL1Sp_ul_1}     2184
    set test variable       ${maxNumLayerPrbL1Sp_ul_1}     1092
    coam.reset_site	    connection=coam_admin
    wait until keyword succeeds     120s        30s         gnb_log.Start Collecting GNB Btslog
    # Reboot UEs      1

    wait until keyword succeeds     900s        10s           Verify that cells are onair with COAM CB007113      coam_admin      3
    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_after_setup.xml   connection=coam_admin

    ${cellcsirs_calc}       Check cellcsirs Assignment v2        ${syslog_folder}       ${syslog}
    Check CB010513 Activation
    ${dll1spcells}       Check Dll1Subpool Assignment
    ${ull1spcells}       Check Ull1Subpool Assignment
    # Check trscsirs Assignment CB010513_B_21     ${fs}
    ${numMinPrbAllocDl}           ${numMinPrbAllocUl}       Get numMinPrbAlloc
    Set Test Variable     ${numMinPrbAllocDl}
    Set Test Variable     ${numMinPrbAllocUl}
    Set Test Variable     ${dll1spcells}
    Set Test Variable     ${ull1spcells}
    ${maxCellPrb}           Get MaxCellPRB
    Set Test Variable      ${maxCellPrb}
    OperatingSystem.Run
    ...    command=cp ${syslog_folder}/${syslog} /tmp/SysLog_Setup.log
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp/btslog2
    #Create Pool Checks File    ${dll1spcells}  ${ull1spcells}  ${numMinPrbAllocDl}  ${numMinPrbAllocUl}  ${cellcsirs_calc}  /tmp  SysLog_Setup.log

    Set Prisma Variables
    Set Test Variable  ${dedicated_scenario}           CB010513_E_21.sce
    @{pcisToCheck}      Set Variable              58      60
    ${Step}     Set Variable        Step1
    gnb_log.Start Collecting GNB Btslog
#    Log To Console      Starting Test ${TestId} with Frame Structure ${fs}
    Sort List      ${pcisToCheck}
    Launch Prisma            ${pcisToCheck}
    Start Prisma call        ${dedicated_scenario}
    Start Prisma traffic On UE      7
    ...     direction=dl     throughput=800M      duration=${transfer_duration}     buffer_length=1350       type=nGBR
    Start Prisma traffic On UE      8
    ...     direction=dl     throughput=800M      duration=${transfer_duration}     buffer_length=1350       type=nGBR
    Start Prisma traffic On UE      7
    ...     direction=ul     throughput=50M      duration=${transfer_duration}     buffer_length=1350       type=nGBR
    Start Prisma traffic On UE      8
    ...     direction=ul     throughput=50M      duration=${transfer_duration}     buffer_length=1350       type=nGBR
    Start Prisma traffic On UE      7
    ...     direction=dl     throughput=30M      duration=${transfer_duration}     buffer_length=1350       type=GBR
    Start Prisma traffic On UE      8
    ...     direction=dl     throughput=30M      duration=${transfer_duration}     buffer_length=1350       type=GBR
    Start Prisma traffic On UE      7
    ...     direction=ul     throughput=30M      duration=${transfer_duration}     buffer_length=1350       type=GBR
    Start Prisma traffic On UE      8
    ...     direction=ul     throughput=30M      duration=${transfer_duration}     buffer_length=1350       type=GBR

    # Step1: Call Setup + traffic: 800/500/500
    # --------------------------------
#    Start Ip Capture
#    Start L1L2 BIP Trace


    Attach UEs      1
    sleep       5s
    ue.Start Data Transfer  dt_name=dt_UE_1_dl   ue_alias=UE_1   direction=dl   duration=${transfer_duration}
        ...    throughput=200 Mbits/sec   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    qci=${qci_ul}
    ue.Start Data Transfer  dt_name=dt_UE_1_ul   ue_alias=UE_1   direction=ul   duration=${transfer_duration}
        ...    throughput=200 Mbits/sec   protocol=${protocol}	  packet_size=${Packet_Size}
        ...    qci=${qci_ul}
    Sleep       10s
    Collect TTI Traces in Streaming mode CB007113       tti_trace_path=/tmp/
    ...     tti_trace_filename=TTI_trace
    ...     tti_trace_duration=2       trace_ip=${tl.test_pc.default_ssh_connection_details.addr}
#    ${TTI_Convert}      Convert TTI trace       TTI_trace.pcap
    ${TTIcsv}       Convert TTI trace from pcap to excelCsv CB007113    TTI_trace.pcap
    ${TTI_Convert}      Convert TTI trace from csv to dict CB007113     /tmp/${TTIcsv}
    #Create_Excel_Charts_from_TTI    tti_csv=/tmp/TTI_trace.dlAndUl.csv    tl=${tl}    dl=True    ul=True    syslog_folder=/tmp
    Check PRB Assignment CB008940
    ...       ${TTI_Convert}        ${dll1spcells}      ${dlstreams}        ${MaxSpPRBdl}
    Check PRB Assignment CB007113
    ...      ${TTI_Convert}        ${ull1spcells}      ${ulstreams}        ${MaxSpPRBul}


    ${stats}    Parse Dl    /tmp/TTI_trace.dl.csv
#    Stop And Download Ip Capture
#    ${l1l2_pcap}        Stop L1L2 BIP Trace

    OperatingSystem.Run
    ...    command=cp ${syslog_folder}/${syslog} /tmp/SysLog_CB010513-SR-E_21_Setup.log
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp
#    Setup pcap      file=/tmp/ip_trace.gz       filter=s1ap || x2ap || f1ap || e1ap || ngap     alias=ip_trace
#    Setup pcap      file=${l1l2_pcap}        filter= (dldata_csirssendreq || dldata_pdschsendreq)     alias=bip_trace
#    Get sNSSAI      alias=ip_trace
#    Get Value from pcap      field=DlData_csiRsResource_t.startSymbol       alias=bip_trace

Delete and create cells
    [Setup]     Setup Sequence
    [Teardown]      Teardown Sequence

    ${dll1spcells}     ${ull1spcells}     Reset Site and check l1Subpools
    set global variable       ${dll1spcells}
    set global variable       ${ull1spcells}
    ${cells}        Get Cells
    ${numofcells}  Get Length     ${cells}
    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_before_deletion.xml   connection=coam_admin
    ${twocells}     Set Variable    ${FALSE}        #Cells will be deleted/created in pairs if TRUE
    FOR   ${cell}    IN RANGE    0      ${numofcells}
        ${nextcell}    Evaluate    ${cell}+1 if ${cell}+1<${numofcells} else 0
        ${listOfCells}    Run Keyword if        ${twocells}      Create List    ${cell}    ${nextcell}
        ...     ELSE        Create List    ${cell}
        Delete And Check Cells    ${listOfCells}    ${numofcells}
#        Delete And check Cell  ${nextcell}    ${${numofcells}-1}
        coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_after_deletion.xml   connection=coam_admin
        scf.calculate_delta_scf     /tmp/scf_before_deletion.xml     /tmp/scf_after_deletion_${cell}.xml     /tmp/scf_delta.xml
        Remove RPGRP from Delta scf     /tmp/scf_delta.xml
        Create And Check Cell    ${cell}    ${${numofcells}-1}       /tmp/scf_delta.xml
        Run Keyword if        ${twocells}
        ...     scf.calculate_delta_scf     /tmp/scf_after_deletion_${cell}.xml     /tmp/scf_after_deletion_${nextcell}.xml     /tmp/scf_delta.xml
        Run Keyword if        ${twocells}
        ...     Remove RPGRP from Delta scf     /tmp/scf_delta.xml
        Run Keyword if        ${twocells}
        ...     Create And Check Cell    ${nextcell}    ${numofcells}       /tmp/scf_delta.xml

    END


Reset Site
    [Setup]     Setup Sequence
    [Teardown]      Teardown Sequence
    [Timeout]        20min
    coam.reset_site	    connection=coam_admin
    Log To Console      \nResetting gNB...\n

Collect SCF
    [Setup]     Setup Sequence
    [Teardown]      Teardown Sequence
    ${d}        Get Current Date        result_format=%Y%m%d
    coam.get_current_scf_file       local_dir_path=${scf_folder}     file_name=scf_${d}.xml   connection=coam_admin
    Log To Console      \nSCF saved in ${scf_folder}/scf_${d}.xml\n

Get TTI trace Decoder
    [Timeout]        2min
    ${FileExist}        Scripts.File Exists      gnb_sw.txt
    ${SOFTWARE_LAST}        Run Keyword if      '${FileExist}'=='True'          Get File         gnb_sw.txt
    ${SOFTWARE_INFO}        Get gNB SW version
    Set suite variable      ${SOFTWARE_INFO}
    Run Keyword If      '${SOFTWARE_LAST}'!='${SOFTWARE_INFO}'
    ...     _Download And Install Ttitrace Decode Tool From File Server
    Run Keyword If      '${SOFTWARE_LAST}'!='${SOFTWARE_INFO}'      Create File     gnb_sw.txt      ${SOFTWARE_INFO}

#Check Cells On Air
#    [Setup]     Setup Sequence
#    [Teardown]      Teardown Sequence
#    Verify that cells are onair with COAM CB007113      coam_admin      3

Start Syslog
    wait until keyword succeeds     120s        30s         gnb_log.Start Collecting GNB Btslog

Stop Syslog
#    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp
    OperatingSystem.Run
    ...    command=cp ${syslog_folder}/${syslog} ${out_folder}/
    OperatingSystem.Run    command=pkill btslog

Start S1X2
    Start Ip Capture

Stop S1X2
    log to console      destination file: ${s1x2_folder}/${s1x2}.gz
    Stop And Download Ip Capture        target_file_name=${s1x2_folder}/${s1x2}.gz
    OperatingSystem.Run
    ...    command=cp ${s1x2_folder}/${s1x2} ${out_folder}/

Start l1l2
    Start L1L2 BIP Trace

Stop l1l2
    Set To Dictionary      ${SUITE_TAF_collectors}     l1l2bip=STARTED

    ${l1l2_pcap}        Stop L1L2 BIP Trace
    OperatingSystem.Run
    ...    command=cp ${l1l2_pcap} ${out_folder}/${l1l2}


Check BBPool Assignment
    [Setup]     Setup Sequence
    [Teardown]      Teardown Sequence
    [Timeout]        20min
    ${checks}        Create List
    ${setup_flags} =    Evaluate    json.loads('${setup_flags_json}')       json
    ${gnb_cells}            Get Cells
    ${numofcells}  Get Length     ${gnb_cells}
    wait until keyword succeeds     120s        30s         gnb_log.Start Collecting GNB Btslog
    wait until keyword succeeds     600s        10s           Verify that cells are onair with COAM CB007113      coam_admin      ${numofcells}
    ${cellSetupInfos}      Create Dictionary
    ${dll1spcells}       Check Dll1Subpool Assignment
    Log to console  \n-----------DL-----------\nCells in Subpool 1: ${dll1spcells[0]}\nCells in Subpool 2: ${dll1spcells[1]}
    ${ull1spcells}       Check Ull1Subpool Assignment
    Log to console  \n-----------UL-----------\nCells in Subpool 1: ${ull1spcells[0]}\nCells in Subpool 2: ${ull1spcells[1]}
    ${l1spcells}      Create Dictionary        dlL1SpCells     ${dll1spcells}       ulL1SpCells     ${ull1spcells}
    Run keyword if      '${setup_flags['l1SpCells']}'=='True'
    ...     Set To Dictionary        ${cellSetupInfos}      l1SpCells     ${l1spcells}
    ${bbpoolinfos}       Get bbPoolInfos        ${syslog_folder}       ${syslog}
    Log to console  \n-----------L1 BB Pool Infos-----------\n
    Run keyword if      '${setup_flags['bbPoolInfos']}'=='True'
    ...         Set To Dictionary        ${cellSetupInfos}      bbPoolInformations     ${bbpoolinfos}

#    ${keys}    Get Dictionary keys    ${bbpoolinfos}
#    FOR    ${item}    IN    @{keys}
#        ${value}    Get From Dictionary    ${bbpoolinfos}       ${item}
##        ${value_proc}       Replace String      ${value}        {       \n{
#        Log to console    ${item}: ${value}
#    END
    Set Test Variable       ${bbpoolinfos}
    ${numMinPrbAllocDl}           ${numMinPrbAllocUl}       Get numMinPrbAlloc
    Log to console  \n------------------------\nnumMinPrbAllocDl: ${numMinPrbAllocDl}\nnumMinPrbAllocUl: ${numMinPrbAllocUl}
    ${numMinPrbAlloc}       Create Dictionary               numMinPrbAllocDl       ${numMinPrbAllocDl}     numMinPrbAllocUl     ${numMinPrbAllocUl}
    Run keyword if      '${setup_flags['numMinPrbAlloc']}'=='True'
    ...             Set To Dictionary        ${cellSetupInfos}      numMinPrbAlloc        ${numMinPrbAlloc}
#    Set To Dictionary        ${cellSetupInfos}      numMinPrbAllocUl     ${numMinPrbAllocUl}
    ${csirsGroups}      ${nrCellGroups}     ${trscsirs}     ${cellcsirs}        ${uecsirs}
    ...     Get csirs Assignment        ${syslog_folder}       ${syslog}
    ${anycsirs}       Evaluate
    ...     '${setup_flags['cellcsirs']}'=='True' or '${setup_flags['trscsirs']}'=='True' or '${setup_flags['uecsirs']}'=='True'
    Run keyword if      '${anycsirs}'=='True'
    ...                 Set To Dictionary        ${cellSetupInfos}      csirsGroups        ${csirsGroups}
    Run keyword if      '${anycsirs}'=='True'
    ...                     Set To Dictionary        ${cellSetupInfos}      nrCellGroups        ${nrCellGroups}

    Run keyword if      '${setup_flags['cellcsirs']}'=='True'
    ...                         Set To Dictionary        ${cellSetupInfos}      cellcsirs        ${cellcsirs}
    ${cellcsirs_calc}       Run keyword if      '${setup_flags['cellcsirs']}'=='True'
    ...                       Calculate cellcsirs v2
    Run keyword if      '${setup_flags['cellcsirs']}'=='True'
    ...                         Set To Dictionary        ${cellSetupInfos}      calculatedCellcsirs        ${cellcsirs_calc}

    ${cellcsirs_check}       Evaluate
    ...     '${setup_flags['cellcsirs']}'=='True' and ${cellcsirs_calc}==${cellcsirs}
    ${cellCsiRsMatch}       Run keyword if      '${setup_flags['cellcsirs']}'=='True'
    ...            Create Dictionary               cellCsiRsMatch      ${cellcsirs_check}
    Run keyword if      '${setup_flags['cellcsirs']}'=='True'       Append To List      ${Checks}       ${cellCsiRsMatch}

    Run keyword if      '${setup_flags['trscsirs']}'=='True'
    ...                     Set To Dictionary        ${cellSetupInfos}      trscsirs        ${trscsirs}
    ${trscsirs_calc}       Run keyword if      '${setup_flags['trscsirs']}'=='True'
    ...                       Calculate trscsirs
    Run keyword if      '${setup_flags['trscsirs']}'=='True'
    ...                         Set To Dictionary        ${cellSetupInfos}      calculatedtrscsirs        ${trscsirs_calc}
    Run keyword if      '${setup_flags['uecsirs']}'=='True'
    ...                         Set To Dictionary        ${cellSetupInfos}      uecsirs           ${uecsirs}
    ${trscsirs_check}       Evaluate
    ...     '${setup_flags['trscsirs']}'=='True' and ${trscsirs_calc}==${trscsirs}
    ${trsCsiRsMatch}       Run keyword if      '${setup_flags['trscsirs']}'=='True'
    ...            Create Dictionary               trsCsiRsMatch      ${trscsirs_check}
    Run keyword if      '${setup_flags['trscsirs']}'=='True'       Append To List      ${Checks}       ${trsCsiRsMatch}


    Run keyword if      '${setup_flags['uecsirs']}'=='True'
    ...                         Set To Dictionary        ${cellSetupInfos}      uecsirs           ${uecsirs}
    Set To Dictionary        ${cellSetupInfos}      Checks           ${Checks}
    ${json_data}        Evaluate    json.dumps(${cellSetupInfos})       json
    Create File    ${syslog_folder}/check_cell_setup.json    ${json_data}
    OperatingSystem.Run
    ...    command=cp ${syslog_folder}/${syslog} ${out_folder}/
    Log to console  \n------------------------\Syslog file copied to ${out_folder}/${syslog}
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp


Launch and convert TTI
#    [Setup]     Setup Sequence
#    [Teardown]      Teardown Sequence
    ${tti_flags} =    Evaluate    json.loads('${tti_flags_json}')       json
    Run keyword if      '${tti_flags['launch']}'=='True'
    ...     Collect TTI Traces in Streaming mode CB007113       tti_trace_path=${tti_folder}
    ...     tti_trace_filename=${tti_filename}
    ...     tti_trace_duration=${tti_duration}       trace_ip=${tl.test_pc.default_ssh_connection_details.addr}

    Run keyword if      '${tti_flags['launch']}'=='True'
    ...     Log To Console        \n----------------------\nTTI trace pcap created: ${tti_folder}/${tti_filename}.pcap
    ...     \n----------------------
    ${tti_filename_comp}     Set Variable If      '${tti_flags['launch']}'=='True'      ${tti_filename}.pcap
    ${NoCollectConvert}       Evaluate         '${tti_flags['launch']}'=='False' and '${tti_flags['convert']}'=='True'

    Run Keyword if      '${NoCollectConvert}' == 'True'     Open File Dialog     ${tti_folder}        pcap
    Log To console  ${tti_folder}/${tti_filename}
    ${TTIcsv}       Run keyword if      '${tti_flags['convert']}'=='True'
    ...     Convert TTI trace from pcap to excelCsv CB007113    ${tti_filename_comp}        ${tti_folder}/
#    Run keyword if      '${tti_flags['prb_dl']}'=='True'
#    ...     Convert TTI trace from pcap to excelCsv CB007113    ${tti_filename}.pcap        ${tti_folder}/
    Run keyword if      '${tti_flags['convert']}'=='True'
    ...     Log To Console        \n----------------------
    ...     \nTTI trace csv created: ${tti_folder}/${tti_filename}.dlAndUl.csv\n----------------------

    Run keyword if      '${tti_flags['convert']}'=='True'
    ...     OperatingSystem.Run
    ...    command=cp ${tti_folder}/${tti_filename}.dlAndUl.csv ${out_folder}/
    ${DLorUL}       Evaluate         '${tti_flags['DL']}'=='True' or '${tti_flags['UL']}'=='True'

    ${NoCollectNoConvert}       Evaluate
    ...     '${tti_flags['launch']}'=='False' and '${tti_flags['convert']}'=='False' and '${DLorUL}'=='True'

    Run Keyword if      '${NoCollectNoConvert}' == 'True'     Open File Dialog     ${tti_folder}        csv

    ${folderconverted}        Remove String       ${tti_folder}     \\

    ${path_tmp}=    Set Variable    ${folderconverted}/${tti_filename}.dlAndUl.csv
    ${ExcelFile}        Run keyword if      '${DLorUL}'=='True'
    ...     Create_Excel_Charts_from_TTI    ${path_tmp}    ${tl}  ${tti_flags['DL']}  ${tti_flags['UL']}  ${syslog_folder}

    Run keyword if      '${DLorUL}'=='True'
    ...     OperatingSystem.Run    command=cp ${ExcelFile} ${out_folder}/
    ${ExcelFile_trunc}      Split String    ${ExcelFile}    /
    # Run keyword if      '${DLorUL}'=='True'     show msg    File ${out_folder}/${ExcelFile_trunc[-1]} created!

#    Log to console  \n------------------------\TTI csv file copied to ${out_folder}/${tti_filename}.dlAndUl.csv
#    ...     Create_UL_Charts_from_TTI       ${tti_folder}/${tti_filename}.dlAndUl.csv

Collect Snapshot
    [Setup]     Setup Sequence
    [Teardown]      Teardown Sequence
    Collect snapshot coam ext01     resultBaseDir=${snap_folder}

*** Keywords ***
Common Preconditions

    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_ref.xml   connection=coam_admin
    Start ue proxy socketIO
    sleep       5s
    Set ADB ROOT in UE
    sleep       5s
    Set Airplane Mode Off And Enable Data
    wait until keyword succeeds     120s        30s     Setup UEs      1

Common Teardown
    Reboot UEs      1
    Detach UEs      1

Setup Sequence
    [Timeout]        2min
    ${collectors}    Create Dictionary
#    ${BFAT}=    Run Keyword And Return Status    Variable Should Exist    ${system_under_test.basestation.1.ip}
#    Run Keyword If      '${BFAT}'=='True'       Import Variables      ${CURDIR}/../Resources/common_import/python/bfatToTl.py
#    Set Global Variable      ${tl}
    ${mrbts}        Set Variable        MRBTS-${tl.gnbs[0].instance_id}
    ${dn}           Set Variable        ${mrbts}/NRBTS-${tl.gnbs[0].global_bts_id}
    Get TTI trace Decoder CB007113
#    Update mcshark
    Set Suite Variable    ${SUITE_TAF_collectors}    ${collectors}
    coam.connect to     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}       name=coam_admin
    OperatingSystem.Run    command=sudo rm /tmp/scf_*
    OperatingSystem.Run    command=sudo rm /tmp/TTI_trace*
    OperatingSystem.Run    command=sudo rm -rf ${syslog_folder}/*
    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_orig.xml   connection=coam_admin

Teardown Sequence
    [Timeout]        5min
    Run Keyword And Continue On Failure     gnb_log.Stop Collecting gNB Btslog     log_dir=/tmp
    Reboot UEs      1
    Detach UEs      1
    coam.perform_commissioning	bts_id=0	scf_file=/tmp/scf_orig.xml
    ...     skip_parameter_relation_errors=True	should_activate=True	timeout=300  connection=coam_admin
    coam.teardown  connection=coam_admin

Open File Dialog
    [Arguments]     ${tti_folder_ini}=/tmp        ${pcapcsv}=pcap

    #bypass robocop tmp
    ${tti_folder_ini}=    Set Variable    ${tti_folder_ini}
    ${pcapcsv}=    Set Variable    ${pcapcsv}

    Fail    TODO:Not Implemented

    # ${tti_folder}       ${tti_filename_comp}     get file To convert     ${tti_folder_ini}        ${pcapcsv}
    # ${tti_filename}     Evaluate        re.sub(r'\.pcap[0-9]?|' '\.dlAndUl\.csv', '','${tti_filename_comp}')       re
    # Set Test Variable   ${tti_folder}
    # Set Test Variable   ${tti_filename_comp}
    # Set Test Variable   ${tti_filename}

Set Prisma Variables
    # Variable used for Prisma:
    # -------------------------
    Set Test Variable       ${AP_LSU_UU_ip}                     ${tl.ues[0].lsu_uu_ssh_connection_details.addr}
    Set Test Variable       ${AP_LSU_UU_login}                  ${tl.ues[0].lsu_uu_ssh_connection_details.username}
    Set Test Variable  ${AP_LSU_UU_passwd}                      ${tl.ues[0].lsu_uu_ssh_connection_details.password}
    Set Test Variable  ${AP_TSTM_UU_ip}                         ${tl.ues[0].tstm_uu_ssh_connection_details.addr}
    Set Test Variable  ${sdrDLGain}                             ${custom['Dl_gain']}
    Set Test Variable  ${sdrULGain}                             ${custom['Ul_gain']}
    Set Test Variable  ${am_host}                               ${tl.ues[0].airmosaic_harness_connection_details.addr}
    Set Test Variable  ${am_port}                               ${tl.ues[0].airmosaic_harness_connection_details.port}
    Set Test Variable  ${AM_PATH}                               ${custom['prisma_cli_path']}
    Set Test Variable  ${scenario_prisma_folder}                ${custom['airmosaic_cfg_path']}
    #${scenario_prisma_file_name}    Set Test Variable           ${custom['sid_filename']}
    #${scenario_prisma_file_full_name}    Set Test Variable      ${scenario_prisma_folder}/${scenario_prisma_file_name}
    # ${am_zip_package}    Set Test Variable                    ${zip_path_name}/${zip_file_name}
#    ${dedicated_scenario}     Set Test Variable                  CB010513_E_21.sce
    #${specific_scenario}    Set Test Variable                  5GC002240_EA.sce
    Set Test Variable  ${default_sid_file}                       ${custom['sid_filename']}

    Set Test Variable  ${AP_PRISMA_TAF_YAML_PATH}               ${custom['yaml_prisma_filename_path']}
    Set Test Variable  ${AP_PRISMA_TAF_YAML_FILENAME}           ${custom['yaml_prisma_filename']}
    Set Test Variable  ${AP_PRISMA_TAF_YAML_FULLPATH}           ${AP_PRISMA_TAF_YAML_PATH}${AP_PRISMA_TAF_YAML_FILENAME}
    Set Test Variable  ${lsu_s1_node}                           lsu_s1
    Set Test Variable  ${lsu_x2uu_node}                         lsu_uu
    Set Test Variable  ${lsu_tstmx2}                            tstm_x2
    Set Test Variable  ${lsu_tstmuu}                            tstm_uu
    Set Test Variable  ${airmosaic}                             airmosaic
#    Set Test Variable  ${SimulatedeNB_flag}                     True
#    Set Test Variable  ${Classicalenv_flag}                     False
    #${prisma_ppu_cell_4G}    Set Test Variable                  ${custom['prisma_ppu_cell_4G']}
    Set Test Variable  ${prisma_ppu_cell_5G}                     ${custom['prisma_ppu_cell_5G']}
    Set Test Variable  ${mrbts}                                  MRBTS-${tl.gnbs[0].instance_id}
    Set Test Variable  ${dn}                                     ${mrbts}/NRBTS-${tl.gnbs[0].global_bts_id}

Set MaxSpPRB
    Set Test Variable       ${maxNumLayerPrbL1Sp}       ${2184}
    Set Test Variable       ${maxNumStreamPrbL1Sp}      ${2184}
    Set Test Variable       ${maxNumWbStreamPrbL1Sp}      ${1092}
    Set Test Variable       ${CB007113}        C
    Set Test Variable       ${maxNumLayerPrbL1Sp_ul_64}       ${1092}
    Set Test Variable       ${maxNumStreamPrbL1Sp_ul_64}      ${2184}
    Set Test Variable       ${maxNumLayerPrbL1Sp_ul_32}       ${546}
    Set Test Variable       ${maxNumStreamPrbL1Sp_ul_32}      ${1092}
    set test variable       ${bbmod_model}      ABIO
    coam.get_current_scf_file       local_dir_path=/tmp     file_name=scf_orig.xml   connection=coam_admin

    ${csSize_1}       Set Variable If     '${bbmod_model}'=='ABIO'        64
    ...          '${bbmod_model}'=='ABIQ'        48
    ${csSize_2}       Set Variable If     '${bbmod_model}'=='ABIO'        32
    ...          '${bbmod_model}'=='ABIQ'        48
    ${maxNumLayerPrbL1Sp_ul_1}       Set Variable If     '${bbmod_model}'=='ABIO'        ${maxNumLayerPrbL1Sp_ul_64}
    ...          '${bbmod_model}'=='ABIQ'        ${600}
    ${maxNumLayerPrbL1Sp_ul_2}       Set Variable If     '${bbmod_model}'=='ABIO'        ${maxNumLayerPrbL1Sp_ul_32}
    ...          '${bbmod_model}'=='ABIQ'        ${600}
    ${maxNumStreamPrbL1Sp_ul_1}       Set Variable If     '${bbmod_model}'=='ABIO'        ${maxNumStreamPrbL1Sp_ul_64}
    ...          '${bbmod_model}'=='ABIQ'        ${1200}
    ${maxNumStreamPrbL1Sp_ul_2}       Set Variable If     '${bbmod_model}'=='ABIO'        ${maxNumStreamPrbL1Sp_ul_32}
    ...          '${bbmod_model}'=='ABIQ'        ${1200}

    Set Test Variable       ${maxNumLayerPrbL1Sp_ul_1}
    Set Test Variable       ${maxNumStreamPrbL1Sp_ul_1}

    ${vendorElement1}        Create Dictionary
    ...       csSize      48      direction     DL
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1Sp}
    ...       maxNumStreamPrbL1Sp     ${maxNumStreamPrbL1Sp}
    ...       maxNumWbStreamPrbL1Sp     ${maxNumWbStreamPrbL1Sp}
    ${vendorElement2}        Create Dictionary
    ...       csSize      ${csSize_1}             direction     UL
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1Sp_ul_1}
    ...       maxNumStreamPrbL1Sp     ${maxNumStreamPrbL1Sp_ul_1}

    ${vendorElement3}        Create Dictionary
    ...       csSize      ${csSize_2}                  direction     UL
    ...       maxNumLayerPrbL1Sp      ${maxNumLayerPrbL1Sp_ul_2}
    ...       maxNumStreamPrbL1Sp     ${maxNumStreamPrbL1Sp_ul_2}

    ${MaxSpPRB}     Create List       ${vendorElement1}      ${vendorElement1}
    ...         ${vendorElement2}      ${vendorElement2}
    Set Test Variable       ${MaxSpPRB}
    ${MaxSpPRBul}     Create List       ${vendorElement2}      ${vendorElement2}
    Set Test Variable       ${MaxSpPRBul}
    ${MaxSpPRBdl}     Create List       ${vendorElement1}      ${vendorElement1}
    Set Test Variable       ${MaxSpPRBdl}
#    Update vendor file      ${MaxSpPRB}
