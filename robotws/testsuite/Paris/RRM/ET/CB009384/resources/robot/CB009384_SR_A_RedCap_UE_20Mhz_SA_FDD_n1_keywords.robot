*** Settings ***

Documentation     File containing keywords used by CB009384 test suites
...               it contain Redcap SA KW
...               Modified Date               : 18-Sep-2024 - Scout data + some fixes for RF50

Library           OperatingSystem
Library           taf.analyzer.sherpa                                     WITH NAME   SherpaCsvReader
Library           String
Library           taf.collectors.btslog                                   WITH NAME   btslog
Library           taf.wts.runner                                          WITH NAME   wtsemu
Library           ../../../resources/common/TtiTrace/python/ttitrace.py   WITH NAME   nps_ttitraces_tools

Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource          ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot

Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Backup.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot

Resource          ../../../resources/robot/ConfigCollector_Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot

Variables         ../python/Constants.py

#FOREIGN CORNER resources for enclosed tests - LOCAL COPIES (obsoleted tests moved Feb 2026)

#foreign 5GC001227 - LOCAL COPY
Resource           5GC001227-Common_keywords.robot

#foreign CB008072_interaction_5GC00545_FDD_SA.robot - LOCAL COPIES
Variables          ../python/CB008072_Constants.py
Resource           CB008072_interaction_5GC00545_Keywords_FDD_SA.robot
Resource           CB008072_Keywords_common.robot
# Resource           ../../../CB008072/CB008072_interaction_5GC00545_FDD_SA.robot
# # Variables         ../../../CB008072/resources/robot/CB008072_interaction_5GC00545_Keywords_FDD_SA.robot

*** Variables ***

#following to collect or not -  ${enable_sherpa} set to true will also set following to true later on
${userneed_PCAP}                 False
${userneed_TTI}                  False
${userneed_Btslog}               Fasle

#following to manage end of collect
${BtsLogStarted}                 False
${save_debug_data}               False
${SherpaFileAlreadycollected}    True

#miscelaneous
${iphy_file_path}                /ffs/run/simmode    #use for Iphy restoration on TearDown step

#miscalenous
${egatelogoutput}                ${False}
${DBGlogs}           ${False}    # THIS VARIBLE USE SOME TRACES FOR DEBUGING PUPOSE (see kwmkt_dbg_log instruction)

#little data base
&{NRCELL1}        actUl256Qam=true           #MRBTS-1/NRBTS-1/NRCELL-1
...               actRedCapUeSupport=true    #MRBTS-1/NRBTS-1/NRCELL-1
...               maxNumOfRrcSARedCap=200    #MRBTS-1/NRBTS-1/NRCELL-1

&{NRCELL2}        actUl256Qam=true           #MRBTS-1/NRBTS-1/NRCELL-2
...               actRedCapUeSupport=true    #MRBTS-1/NRBTS-1/NRCELL-2
...               maxNumOfRrcSARedCap=200    #MRBTS-1/NRBTS-1/NRCELL-2

&{NRBTS}
...               pdcpSNLengthRedCap=len12bits         #distName="MRBTS-1/NRBTS-1/NRDRB_PDCP-1 + NRDRB_PDCP-2 + NRDRB_PDCP-3
...               rlcAMDrbSNLengthRedCap=rlcAm12bitSN  #distName="MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1 + NRDRB_RLC_AM-2

#PB value according frequency tool
#Ue_capa DLlayer 2x2Mimo UL Layer 1x1 mimo DLmodulation=Ulmodulation=64Qam
#http://5gtables.eecloud.dynamic.nsn-net.net/?code=KCSBBhmHekACXQIEKtN3pAAQAAAAAAD21ghJQDFwA5JCAQBAAAAAACYABAAAkQQAAEwA
#AAAJAAxKJRKJAkgAAAAAAAAAAAAAAAAAAABAgAAAABAALQARjAgAgAAAAAAAAAAAYBAEwJAAAAIBAAAAAAO4A
&{HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap}
...              cardName=AHLOA
...              RU=AHLOA
...              NRCELL1=${NRCELL1}
...              NRCELL2=${NRCELL2}
...              NRBTS=${NRBTS}
...              ue_nr_capabilities=${Basic_ReCap_UE_Cap_mini_v2}   #fourniture Riyad le 01/03/2023 14h00
...              Downlink_throughput=137   # Mbps (see frequencttool result link above)
...              Uplink_throughput=79      # Mbps (see frequencttool result link above)
...              TrafficDuration=30        #sec
...              twoUeonCell1=False        #warning if true the BW is divided by 2 (2 ue) so SOS on TP will be KO
...              GetTtiTraceTime=5
...              deviation_in_percent=15  #%

&{HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap_256}
...              cardName=AHLOA
...              RU=AHLOA
...              NRCELL1=${NRCELL1}
...              NRCELL2=${NRCELL2}
...              NRBTS=${NRBTS}
...              ue_nr_capabilities=${Basic_ReCap_UE_Cap_mini_v2_256qam}   #fourniture Riyad le 01/03/2023 14h00
...              Downlink_throughput=184   # Mbps (see frequencttool result link above)
...              Uplink_throughput=106      # Mbps (see frequencttool result link above)
...              TrafficDuration=30        #sec
...              twoUeonCell1=True        #False        #warning if true the BW is divided by 2 (2 ue) so SOS on TP will be KO
...              GetTtiTraceTime=5
...              deviation_in_percent=15  #%

&{HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap_Rob100}
...              cardName=AHLOA
...              RU=AHLOA
...              NRCELL1=${NRCELL1}
...              NRCELL2=${NRCELL2}
...              NRBTS=${NRBTS}
...              ue_nr_capabilities=${Basic_ReCap_UE_Cap_mini_v2}   #fourniture Riyad le 01/03/2023 14h00
...              Downlink_throughput=13    #137   # Mbps (see frequencttool result link above)
...              Uplink_throughput=7       #79      # Mbps (see frequencttool result link above)
...              TrafficDuration=30        #sec
...              twoUeonCell1=False        #warning if true the BW is divided by 2 (2 ue) so SOS on TP will be KO
...              GetTtiTraceTime=5
...              deviation_in_percent=15
...              nb_ue_SA=100
...              nb_sequence=3

&{HF_20_a3ghz_n1_AHLOA_FDD_SA_redcap_Rob8bearer}
...              cardName=AHLOA
...              RU=AHLOA
...              NRCELL1=${NRCELL1}
...              NRCELL2=${NRCELL2}
...              NRBTS=${NRBTS}
...              ue_nr_capabilities=${RedCap_UEcap_v2_multibearerIncludingVonr}
...              Downlink_throughput=13    #137   # Mbps (see frequencttool result link above)
...              Uplink_throughput=7       #79      # Mbps (see frequencttool result link above)
...              TrafficDuration=60        #sec
...              twoUeonCell1=False        #warning if true the BW is divided by 2 (2 ue) so SOS on TP will be KO
...              GetTtiTraceTime=5
...              deviation_in_percent=15
...              nb_ue_SA=3
...              nb_sequence=5

#"number of used PRBs for PDSCH by RedCap UE. Responsible SE: Mayank Chandla
# NOTE: This counter is also updated when control message (SRB data, RA msg4) is scheduled over PDSCH."
${REDCAP_PRB_USED_PDSCH}    M55308C36003

#The number of used PRBs for PUSCH by RedCap UE. Responsible SE: Mayank Chandla
#NOTE. This counter is also updated when control message (SRB data) is scheduled over PUSCH. RA Msg1, RA msg3 which is sent over PRACH is excluded.
${REDCAP_PRB_USED_PUSCH}    M55308C36004
# Constraints file
${constraints_1}            testsuite/Paris/RRM/ET/CB009384/resources/config/CB009384_Constraints.csv

# FOREIGN 5GC001227
&{TC_3_Cells_20Mhz}         nbCell=3    bandwith=20
&{Vendor_Param_RR_414}      bbPoolMode=round-robin
...                         maxNumLayerPrbDlL1Sp=414
...                         maxNumLayerPrbUlL1Sp=207
...                         maxNumStreamPrbDlL1Sp=414
...                         maxNumStreamPrbUlL1Sp=414

#FOREIGN CB008072_interaction_5GC00545_FDD_SA
&{A_1}                              dir=UL_DL
...                                 puschMappingType=TypeA
...                                 dmrsTypeAPosition=pos2
...                                 BIPvaluedmrsTypeAPosition=2
...                                 RRCvaluedmrsTypeAPosition=0
...                                 actUlDataDmrsFdm=false
...                                 BIPvalueDMrsCdmGroupWithoutData=2
...                                 ulDataDmrsFdmThres64QamMcs=20
...                                 ulDMRSAdditionalPosition=One additional DMRS
...                                 BIPvalueUlDMRSAdditionalPosition=1
...                                 RRCvalueUlAdditionalDmrs=1
...                                 actUlDftSOfdm=true
...                                 ulTransPrecodeOffSinrThresh=200
...                                 ulTransPrecodeOnSinrThresh=180
...                                 ulTransPrecodeOffSinrThrRedCap=200
...                                 ulTransPrecodeOnSinrThrRedCap=180

*** Keywords ***
Suite Setup 9384
    [Documentation]
    ...     Conditions:     customs configurations yamlPathname
    ...     Actions:        it performs the generic suite setup and backup the configurations files
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        suite setup is passed
    [Arguments]             ${yamlPathname}=${EMPTY}

    Setup.Suite Setup from scratch        yamlPathname=${yamlPathname}
    ...                                   listBackupFiles=${FD_ALL}

    Backup Files
    ${scf_suite_setup_backup}         OAM Get SCF File    file=SCF_Suite_Setup_Backup.xml
    Set Suite Variable      ${scf_suite_setup_backup}
    Dated Log               SCF backup file = ${scf_suite_setup_backup}


Rob-redcap-register-100
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell1 or cell2 (according twoUeonCell1 value) + traffic
    ...                             1 ue SA redcap is set on cell1 + traffic

    [Arguments]                                   ${param}

    Init Sequence                                 ${param}

    Step                                 SessionManagment
    Step                                 erase_eventual_basic_wts_step2
    Critical Step                        Set MRBTSID and NRBTSID
    Critical Step                        Set SCF context                   True    #FDD = True
    # Critical Step                        Set Context_WTS CFG redcap        infra=SA
    # ...                                                                    2ue1cell=${param.twoUeonCell1}
    # ...                                                                    APPdcpPacketTrunc=${True}
    Critical Step                        Create UEs in Cfg File            nb_nsa_ues=0
    ...                                                                    nb_sa_ues=${param.nb_ue_SA}
    Restart TL
    SessionManagment
    Start Btslog
    Alarmslist   Beg    ${logsDir}
    # CB009384 Capture start    cellSetup
    Critical Step                        CallSetup.Setup Wtsemu SA
    # CB009384 Capture Stop     cellSetup
    Step                      startSherpa

    ${Endrange}=                                    Evaluate    ${param.nb_ue_SA} + 1
    FOR     ${ueid}                                 IN RANGE    1    ${Endrange}
        Dated Log New Line                          * * * * REGISTER ${ueid} * * * *
        Dated log                               id ${ueid} is Registering
        wtsemu.ue_register                      id=${ueid}
        Sleep  3s
    END
    wtsemu.ue_disp
    Sleep  60s
    wtsemu.ue_disp
    Step                      stopSherpa

Rob-redcap-8bearerPerUE
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell1 or cell2 (according twoUeonCell1 value) + traffic
    ...                             1 ue SA redcap is set on cell1 + traffic

    [Arguments]                                   ${param}

    Init Sequence                                 ${param}

    Step                                 SessionManagment
    Step                                 erase_eventual_basic_wts_step2
    Critical Step                        Set MRBTSID and NRBTSID
    Critical Step                        Set SCF context BEARER            True    #FDD = True
    Critical Step                        Set Context_WTS CFG redcap        2ue1cell=${param.twoUeonCell1}
    ...                                                                    APPdcpPacketTrunc=${True}
    ...                                                                    multibearer=${True}
    Critical Step                        Create UEs in Cfg File            nb_nsa_ues=0
    ...                                                                    nb_sa_ues=${param.nb_ue_SA}

    Restart TL
    SessionManagment
    Start Btslog
    Alarmslist   Beg    ${logsDir}
    # CB009384 Capture start    cellSetup
    Critical Step                        CallSetup.Setup Wtsemu SA
    # CB009384 Capture Stop     cellSetup

    ${dl_tput_per_ue}    ${ul_tput_per_ue}    Throughtput adaptation to config 2ueOnSameCellorNot
    ...                                       ${param.twoUeonCell1}    ${param.Downlink_throughput}    ${param.Uplink_throughput}
    ${Endrange}=                              Evaluate    ${param.nb_sequence} + 1
    FOR     ${SeqNum}                         IN RANGE    1    ${Endrange}
        Dated Log New Line                    * * * * Bearer stress test SEQUENCE NUMBER ${SeqNum} / ${param.nb_sequence} Seq * * * *
        #each Sherpa log will be erased by next one - in case of issue only the last one will be interresting ;-)
        Run Keyword If                       ${enable_sherpa}==${True}    startSherpa
        bearer_Register_pdu_traf_dereg       # ${dl_tput_per_ue}    ${ul_tput_per_ue}
        Run Keyword If                       ${enable_sherpa}==${True}    stopSherpa
    END


Rob-register-deregister_under_ul_dl
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell1 or cell2 (according twoUeonCell1 value) + traffic
    ...                             1 ue SA redcap is set on cell1 + traffic

    [Arguments]                                   ${param}

    Init Sequence                                 ${param}

    Step                                 SessionManagment
    Step                                 erase_eventual_basic_wts_step2
    Critical Step                        Set MRBTSID and NRBTSID
    Critical Step                        Set SCF context                   True    #FDD = True
    Critical Step                        Set Context_WTS CFG redcap        2ue1cell=${param.twoUeonCell1}
    ...                                                                    APPdcpPacketTrunc=${True}
    ...                                                                    sim_debug_log_level=4

    Critical Step                        Create UEs in Cfg File            nb_nsa_ues=0
    ...                                                                    nb_sa_ues=${param.nb_ue_SA}
    Restart TL
    SessionManagment

    Run Keyword If                       ${VMmonitoring}       Run keywords
    ...                                  ${cmd}=               Catenate      sudo nice -n -20 top >> ${MoniDir}/cpu_ram_wts.log &
    ...   AND                            Dated Log             command cpu monitoring : ${cmd}
    ...   AND                            Dated Log             alias ${alias_epcsim}
    ...   AND                            ${pid}=               Set Variable      0
    ...   AND                            ${pid}=               SSH Exec      command=sudo nice -n -20 top >> ${MoniDir}/cpu_ram_wts.log &
    ...                                                        alias=${alias_epcsim}
    ...   AND                            Dated Log             PID: ${pid}
    ...   AND                            Set Suite Variable    ${pid}

    Start Btslog
    Alarmslist                           Beg    ${logsDir}
    # CB009384 Capture start    cellSetup
    Critical Step                        CallSetup.Setup Wtsemu SA
    # CB009384 Capture Stop     cellSetup

    ${dl_tput_per_ue}    ${ul_tput_per_ue}    Throughtput adaptation to config 2ueOnSameCellorNot
    ...                                       ${param.twoUeonCell1}    ${param.Downlink_throughput}    ${param.Uplink_throughput}
    ${Endrange}=                              Evaluate    ${param.nb_sequence} + 1
    FOR     ${SeqNum}                         IN RANGE    1    ${Endrange}
        Dated Log New Line                    * * * * SEQUENCE NUMBER ${SeqNum} / ${param.nb_sequence} Seq * * * *
        #each Sherpa log will be erased by next one - in case of issue only the last one will be interresting ;-)
        Run Keyword If                       ${enable_sherpa}==${True}    startSherpa
        Register_pdu_traf_dereg               ${dl_tput_per_ue}    ${ul_tput_per_ue}
        Run Keyword If                       ${enable_sherpa}==${True}    stopSherpa
    END

Test_BandWith_SA_FDD
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell1 or cell2 (according twoUeonCell1 value) + traffic
    ...                             1 ue SA redcap is set on cell1 + traffic

    [Arguments]                                   ${param}

    Redcap_settings                               ${param}
    Restart TL
    SessionManagment
    Redcap_Exploit_BWSAFDD

Redcap_Exploit_BWSAFDD

    Run Keyword If      ${userneed_Btslog}         Start Btslog
    Alarmslist   Beg    ${logsDir}

    Run Keyword If      ${userneed_PCAP}           CB009384 Capture start    cellSetup
    Critical Step                                  CallSetup.Setup Wtsemu SA
    Run Keyword If      ${userneed_PCAP}           CB009384 Capture Stop     cellSetup

    Run Keyword If      ${enable_sherpa}==${True}    startSherpa

    Run Keyword If      ${userneed_PCAP}           CB009384 Capture start    Attach
    Run Keyword If      ${userneed_PCAP}           Capture Start             ${CaptureBIP}

    # Run Keyword If            ${userneed_TTI}             TTI start                 suffix=${TEST NAME}_
    # ...                                                   time=${param.GetTtiTraceTime}    w_convert_pcap_to_excelCsv=False    targpath=${logsDir}

    Critical Step                                  CallSetup.UE Register           ue=1
    Critical Step                                  CallSetup.Launch PDU Session    ue=1    pdu=1
    Run Keyword If      ${userneed_PCAP}           CB009384 Capture Stop     Attach

    Critical Step                                  CallSetup.UE Register           ue=2
    Critical Step                                  CallSetup.Launch PDU Session    ue=2    pdu=2

    ${dl_tput_per_ue}    ${ul_tput_per_ue}         Throughtput adaptation to config 2ueOnSameCellorNot
    ...                                            ${param.twoUeonCell1}    ${param.Downlink_throughput}    ${param.Uplink_throughput}

    Step                                           wtsemu.trf_data_start      ue=1    pdu=1    qfi=1    dir=ul    trf_id=1    mbps=${ul_tput_per_ue}
    Step                                           wtsemu.trf_data_start      ue=1    pdu=1    qfi=1    dir=dl    trf_id=1    mbps=${dl_tput_per_ue}
    Step                                           wtsemu.trf_data_start      ue=2    pdu=2    qfi=1    dir=ul    trf_id=2    mbps=${ul_tput_per_ue}
    Step                                           wtsemu.trf_data_start      ue=2    pdu=2    qfi=1    dir=dl    trf_id=2    mbps=${dl_tput_per_ue}

    Run Keyword If       ${userneed_PCAP}          Capture Stop              ${CaptureBIP}
    Run Keyword If       ${enable_sherpa}==${True}    stopSherpa

    # Run Keyword If            ${userneed_TTI}             TTI stop                  suffix=${TEST NAME}_
    # ...                       time=${param.GetTtiTraceTime}    w_convert_pcap_to_excelCsv=False    targpath=${logsDir}

    Sleep                ${param.TrafficDuration}


    ${zoi}            ZOI Start
    Critical Step                                  Tcheck  ue=1  pdu=1  qfi=1  trf_id=1  dir=dl
    ...                                            expected_data_rate=${dl_tput_per_ue}  deviation_in_percent=${param.deviation_in_percent}
    Critical Step                                  Tcheck  ue=1  pdu=1  qfi=1  trf_id=1  dir=ul
    ...                                            expected_data_rate=${ul_tput_per_ue}  deviation_in_percent=${param.deviation_in_percent}
    Critical Step                                  Tcheck  ue=2  pdu=2  qfi=1  trf_id=2  dir=dl
    ...                                            expected_data_rate=${dl_tput_per_ue}  deviation_in_percent=${param.deviation_in_percent}
    Critical Step                                  Tcheck  ue=2  pdu=2  qfi=1  trf_id=2  dir=ul
    ...                                            expected_data_rate=${ul_tput_per_ue}  deviation_in_percent=${param.deviation_in_percent}

    Dated Log                                      === Waiting for end of ZOI
    ZOI Wait End                                   zoi=${zoi}

    Dated Log                                      === PM counter directory: ${logsDir}
    Collect PM Counters File                       ${logsDir}
    KPI Evaluate                                   pmFile=${LATEST_FILE}
    ...                                            constraintsFile=${constraints_1}
    ...                                            failOnError=${True}

    Step                                           wtsemu.trf_data_stop    ue=1    pdu=1    qfi=1
    Step                                           wtsemu.trf_data_stop    ue=2    pdu=2    qfi=1

CB009384_SR_A_13_IWK3a_RedCapUE_5GC001227_RoundRobin
    [Arguments]                                                    ${param}
    Init Sequence                                                  ${param}
    Critical Step    Redcap_settings                               ${param}
    Critical Step    TC 1227 TEST Round Robin                      ${TC_3_Cells_20Mhz}         ${Vendor_Param_RR_414}
    SessionManagment
    Critical Step    5GC001227_ComplementBLER

CB009384_SR_A_20_IWK4a
    [Arguments]                                                    ${param}
    Init Sequence                                                  ${param}
    Critical Step         Redcap_settings                          ${param}

    # Critical Step    Suite Setup DFT_s_OFDM
    ${ue_capu_type}       set variable     ${AP_DU.bb[0].M.boardType}
    Set Suite Variable    ${ue_capu_type}
    ${console_msg}        Evaluate     "The Board Type used on Airphone is ${ue_capu_type}"
    Dated Log             ${console_msg}
    Run keyword if        '${ue_capu_type}' == 'ABIL'
    ...                    Run Keyword
    ...                    Add Noise To AP L1
    SessionManagment
    Critical Step          Foreign_TC_8072_FDD    ${A_1}

    # Critical Step    CB008072_Keywords_common.Suite Teardown 8072
    # Critical Step    Suite Teardown 8072

#####  KW Land ##########
Foreign_TC_8072_FDD
    [Documentation]                 Generic test for CB008072_A_xxx (UL or UL_DL) tests
    [Arguments]                  ${param}
    Init Sequence                ${param}
    Critical Step                Set Context FDD
    Critical Step                Restart
    Step                         Captures Init
    Critical Step                CallSetup.Setup Wtsemu SA
    Critical Step                UE Cell Setup Check
    Step                         Captures Start
    Critical Step                CallSetup.UE Register                                    depends=UE Cell Setup Check
    Critical Step                CallSetup.UE Attach Check                                depends=CallSetup.UE Register
    Critical Step                CallSetup.Launch PDU Session                             depends=CallSetup.UE Attach Check
    Critical Step                kwmkt_run_script_once                                    ${CURDIR}/../egCmd/egCmd.sce
    Step                         Capture BIP Start
    Sleep   3s
    Step                         Capture BIP Stop                                         depends=Capture BIP Start
#   Critical Step                Decrease SINR TO Trigger TransformPrecoder Enabled       depends=CallSetup.Launch PDU Session    TargetedNoise=-500
    Step                         Captures Stop                                            depends=Captures Start
    Run Keyword if               ${enable_sherpa}==${True}                                Activate Sherpa
    ...                          depends=CallSetup.Launch PDU Session
#   Step                         ${param.dir} Traffic SA                                  depends=CallSetup.Launch PDU Session
    Run Keyword if               ${enable_sherpa}==${True}                                Deactivate Sherpa and Stop Collect
    Run Keyword if               ${enable_sherpa}==${True}
    ...                          Step                                                     Rename Of Sherpa Logs
    Critical Step                Check PuschMappingTypeA UL in BIP Traces
    Critical Step                Check transformPrecoder enabled in BIP Traces
    Critical Step                Check dmrs TypeA Position in BIP Traces
    Critical Step                Check Additional DMRS UL in BIP Traces

kwmkt_run_script_once
    [Documentation]        This KW start on egate command a script file=<path><file.sce> to perform egate commande
    ...                    recorded on a .sce file

    [Arguments]                    ${script_path_name}
    Dated Log                      Script sce used: ${script_path_name}

    wtsemu.script                  file=${script_path_name}
    ${output}                      wtsemu.read_wtsemu_output_until    PROCESSING    20
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${output}                      wtsemu.read_wtsemu_output_until_prompt    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wait until keyword succeeds    12hours    1s    kwmkt_is_script_finished
    ${error_in_status}=            Run Keyword And Return Status    Should Contain    ${script_status}    error
    kwmkt_dbg_log                  output:${error_in_status}

    should not match regexp        ${script_status}    error

kwmkt_is_script_finished
    [Documentation]        This KW is a part of kwmkt_run_script_once

    wtsemu.script_status
    ${output}                      wtsemu.read_wtsemu_output_until    Status of script    5
    Run Keyword If                ${egatelogoutput}    Dated Log                  output:${output}
    ${script_status}               wtsemu.read_wtsemu_output_until_prompt    5
    # ${log_string}          remove string using regexp    ${script_status}    (=|-| {6,}|\n)
    # ${log_string}          replace string   ${log_string}    description    description${\n}${SPACE}
    # ${log_string}          catenate    Script status:${\n}    ${log_string}
    # Dated Log              ${log_string}    first=True
    should not match regexp        ${script_status}    ( active | paused )
    [Return]                       ${script_status}

kwmkt_dbg_log
    [Documentation]             This KW will help on non regression to see deeper informations
    ...                         on Main Test case .robot file, ${DBGlogs} variable need to be set to ${True} or  ${False}

    [Arguments]                   ${SomethinToTrace}=none

    Run Keyword If                ${DBGlogs}    Dated Log   Debug wwwwwwwwww: ${SomethinToTrace}
    #added to pass RF5.0 sanity
    No Operation
    No Operation
    No Operation

SessionManagment
    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias sur ssh wait For Connect ${alias_epcsim}
bearer_Register_pdu_traf_dereg
   # [Arguments]           ${dl_tput_per_ue}    ${ul_tput_per_ue}
    ${EndrangeIII}                                  Evaluate    ${param.nb_ue_SA} + 1
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeIII}
            Dated Log New Line     ** ** Bearer egate campaign on UE_id=${ue_id} ** **     deep=${2}
            wtsemu.set_pdu_param    ue=${ue_id}    pdu=1    trf_type=internal
            wtsemu.set_pdu_param    ue=${ue_id}    pdu=2    trf_type=internal

            wtsemu.ue_register     id=${ue_id}
            Sleep    3s
            wtsemu.smf_param       additional_qosflows_to_activate=2,3,4    id=${ue_id}
            wtsemu.ue_pdu_session_setup    pdu=1    ue=${ue_id}    nwslice=1 gw=1
            Sleep    3s

            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=1    trf_id=1    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=1    trf_id=2    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=2    trf_id=3    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=2    trf_id=4    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=3    trf_id=5    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=3    trf_id=6    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=4    trf_id=7    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=1    qfi=4    trf_id=8    mbps=1    dir=ul    protocol=udp    seconds=3600

            wtsemu.smf_param      additional_qosflows_to_activate=4,5,6    id=${ue_id}
            wtsemu.ue_pdu_session_setup    pdu=2    ue=${ue_id}    nwslice=1 gw=1
            Sleep    3s

            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=1    trf_id=9     mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=1    trf_id=10    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=2    trf_id=11    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=2    trf_id=12    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=3    trf_id=13    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=3    trf_id=14    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=4    trf_id=15    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue_id}    pdu=2    qfi=4    trf_id=16    mbps=1    dir=ul    protocol=udp    seconds=3600
    END
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeIII}
            wtsemu.ue_stats_nr                      id=${ueid}    type=pusch    scell=0
            Sleep    3s
            wtsemu.ue_stats_nr                      id=${ueid}    type=pdsch    scell=0
            Sleep    3s
    END
    wtsemu.ue_disp
    Dated Log New Line     ** ** Traffic duration for ${param.TrafficDuration} ** **    deep=${2}
    Sleep                     ${param.TrafficDuration}
    Dated Log              ** ** record on egate_console logs of all UE status ** **    deep=${2}
    wtsemu.ue_disp
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeIII}
            Dated Log     ** ** record on egate_console logs of UE_${ue_id} TP ** **    deep=${2}
            wtsemu.ue_stats_nr                      id=${ueid}    type=pusch    scell=0
            wtsemu.ue_stats_nr                      id=${ueid}    type=pdsch    scell=0
            Sleep    3s
            Dated Log     ** ** record on egate_console logs of UE_${ue_id} status (ue_disp) ** **    deep=${2}
            wtsemu.ue_disp                          id=${ueid}
            wtsemu.ue_deregister    id=${ue_id}     by=ue    ue_deregister_type=switch_off
    END


Register_pdu_traf_dereg
    [Arguments]           ${dl_tput_per_ue}    ${ul_tput_per_ue}
    ${EndrangeII}                                   Evaluate    ${param.nb_ue_SA} + 1
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeII}
            Dated log                               id ${ueid} is Registering - max ${param.nb_ue_SA} -     deep=${2}
            # wtsemu.ue_register                      id=${ueid}
            # Sleep                                   3s
            # wtsemu.set_pdu_param                    ue=${ueid}    pdu=1    trf_type=internal
            # wtsemu.ue_pdu_session_setup             pdu=1 gw=1    ue=${ueid}    nwslice=1

            Critical Step                           CallSetup.UE Register                   ue=${ueid}
            Sleep                                   3s
            Critical Step                           CallSetup.Launch PDU Session            ue=${ueid}    pdu=1
            Sleep                                   3s
            wtsemu.trf_data_start                   ue=${ueid}    pdu=1    qfi=1    dir=ul    trf_id=20    mbps=${ul_tput_per_ue}
            Sleep                                   3s
            wtsemu.trf_data_start                   ue=${ueid}    pdu=1    qfi=1    dir=dl    trf_id=1     mbps=${dl_tput_per_ue}
            Sleep                                   5s
    END
    Sleep   10s
    wtsemu.ue_disp
    Dated Log New Line     ** ** Traffic duration for ${param.TrafficDuration} ** **    deep=${2}
    Sleep                     ${param.TrafficDuration}
    wtsemu.ue_disp
    Dated Log New Line     ** ** Traffic recording ** **    deep=${2}
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeII}
            wtsemu.ue_stats_nr                      id=${ueid}    type=pusch    scell=0
            Sleep    3s
            wtsemu.ue_stats_nr                      id=${ueid}    type=pdsch    scell=0
            Sleep    3s
    END
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeII}
            Dated log                               id ${ueid} is DeRegistering    deep=${2}
            wtsemu.ue_deregister                    id=${ueid}    ue_deregister_type=switch_off
            Sleep    3s
    END

Redcap_settings
    [Arguments]                                   ${param}
    Init Sequence                                 ${param}
    Critical Step                                  Set MRBTSID and NRBTSID
    Critical Step                                  Set SCF context                   True    #FDD = True
    Critical Step                                  Set Context_WTS CFG redcap        2ue1cell=${param.twoUeonCell1}
    ...                                            APPdcpPacketTrunc=${True}

    #usage of ${enable_sherpa}  to start full debug or not (Sherpa bip btslog PM )
    ${userneed_PCAP}       Set Variable If         ${enable_sherpa}==${True}    True
    ${userneed_TTI}        Set Variable If         ${enable_sherpa}==${True}    True
    ${userneed_Btslog}     Set Variable If         ${enable_sherpa}==${True}    True
    ${save_debug_data}     Set Variable If         ${enable_sherpa}==${True}    True

    Set Global Variable    ${userneed_PCAP}
    Set Global Variable    ${userneed_TTI}
    Set Global Variable    ${userneed_Btslog}
    Set Global Variable    ${save_debug_data}

# ==========================================
Test Teardown CB009384_SR_A
    [Documentation]    Perform needed actions at the end of a test case

    Dated log New Line                       Test Teardown CB009384_SR_A : start
    Dated log                                ...................................
    Produce Scout Data

    # ${cmd}=               Catenate  sudo kill ${pid}
    # Dated Log             comand send : ${cmd}
    # ${pid}                SSH Exec            command=${cmd}          alias=${alias_epcsim}

    CollectConfigfilesUsedForTest

    Alarmslist   End    ${logsDir}
    Dated log                       TEST_NAME : ${TEST NAME}
    Run Keyword If                  '${TEST NAME}' == 'CB009384_SR_A_20_IWK4a_RedCap_UE_with_DFT_s_OFDM_for_PUSCH_pi2BPSK_is_used_for_MCS0_and_MCS1'
    ...                             Display diagnosis
    # Run Keyword If                  ${TEST NAME} == '[1]CB009384_SR_A_13_IWK3a_RedCapUE_with_5GC000792_5GC001227_5GC002426'    Display diagnosis
    Run Keyword If                  '${TEST NAME}' == '[1]CB009384_SR_A_2_B3a_RedCap_UE_Traffic_DL_12bits_RLC_PDCP_SN'
    ...                             Display diagnosis
    Run Keyword If                  '${TEST NAME}' == 'Rob-redcap-8bearerPerUE'                                 Display diagnosis
    Run Keyword If                  '${TEST NAME}' == 'Rob-register-deregister_under_ul_dl'                     Display diagnosis

    Run Keyword If Test Failed      Set Global Variable    ${save_debug_data}    ${True}
    Run Keyword If Test Failed      Dated log              TEST - I N T E R R U P T I O N -
    Run Keyword If                  ${AutoSaveDebugData} == ${True}    Set Global Variable    ${save_debug_data}    ${True}

    Dated log                       save_debug_data : ${save_debug_data}
    Dated log                       AutoSaveDebugData : ${AutoSaveDebugData}
    Dated log                       SherpaFileAlreadycollected : ${SherpaFileAlreadycollected}

    #following to uncomment if you don't want any SosReport / Snapshot /Sherpa collection
    # Set Global Variable             ${save_debug_data}    ${False}

    Run Keyword If                  ${BtsLogStarted}                 Stop Btslog      ${logsDir}
    stopSherpa
    Run Keyword If                  ${save_debug_data} == ${True}    LogCollection

    ${cmd}               set variable    cp -p ${tl.core.dir_path}/egate_console.* ${logsDir}
    Dated Log            ${cmd}
    SSH Exec             ${cmd}                                           alias=${alias_epcsim}

    Dated log                       Test Teardown CB009384_SR_A : end

Test Suite Teardown for CB009384_SR_A
    [Documentation]          Test suite Teardown for CB009384_SR_A.
    # run keyword and ignore error   Restore Orignal Configuration 7487
    # return from Keyword if      '${WITHOUT_TEST_SUITE_TEARDOWN}'=='1'
    # Call to generic test suite Teardown KW
    setup.Suite Teardown
    # CleanBasicFiles    #way to supply SWENG lua files erasement forget

Throughtput adaptation to config 2ueOnSameCellorNot
    [Arguments]     ${twoUeonCell1}=${False}    ${Total_DL_Tput}=10    ${Total_UL_Tput}=10
    Dated Log  twoUeonCell1 ${twoUeonCell1} Total_DL_Tput ${Total_DL_Tput} Total_UL_Tput ${Total_UL_Tput}
    ${nbUeperCell}=                     Set Variable If             '${twoUeonCell1}'=='${True}'    2    1
    ${dl_tput_per_ue}=                  Evaluate                    ${Total_DL_Tput}/${nbUeperCell}
    ${ul_tput_per_ue}=                  Evaluate                    ${Total_UL_Tput}/${nbUeperCell}
    ${dl_tput_int_per_ue}=              Convert To Integer          ${dl_tput_per_ue}
    ${ul_tput_int_per_ue}=              Convert To Integer          ${ul_tput_per_ue}
    Dated Log                           DL throughput per UE is: ${dl_tput_int_per_ue} Mbps
    Dated Log                           UL throughput per UE is: ${ul_tput_int_per_ue} Mbps
    [return]        ${dl_tput_int_per_ue}    ${ul_tput_int_per_ue}

stopSherpa
    Set Suite Variable              ${LOG_PATH_bu}     ${LOG_PATH}
    Set Suite Variable              ${LOG_PATH}        ${logsDir}
    Run Keyword If                  ${SherpaFileAlreadycollected}!=${True} and ${enable_sherpa}==${True}
    ...                             Run Keywords
    ...                                         Dated log            SHERPA STOP AND COLLECTION ongoing
    ...   AND                                   Deactivate Sherpa and Stop Collect    #keep_pcap_file=${True}
    Set Suite Variable              ${SherpaFileAlreadycollected}    ${True}
    Set Suite Variable              ${LOG_PATH}     ${LOG_PATH_bu}

startSherpa
    Dated log            SHERPA START
    Activate Sherpa
    set suite variable              ${SherpaFileAlreadycollected}    ${False}

LogCollection
    Dated log   L O G S _ C O L L E C T I O N

    Get Snapshot
    SSH Exec             mv ${LOG_PATH_bu}/SNAPSHOT_GNB*zip ${logsDir}    alias=${alias_epcsim}

    Get Sos Report
    SSH Exec             mv %{HOME}/SosReport*tgz ${logsDir}              alias=${alias_epcsim}

    #move pcap file from mirroring
    SSH Exec             mv ${LOG_PATH_bu}/*.pcap ${logsDir}              alias=${alias_epcsim}

    #move 1227 Sherpa repo on $LogsDir
    Run Keyword If  '${AutoSaveDebugData}'
    ...   Run Keyword And Ignore Error
    ...   SSH Exec       cp -rp ${LOG_PATH}/l2stream3 ${logsDir}          alias=${alias_epcsim}

Get TTI traces
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    ${tm}                  Get Current Date
    ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
    Dated Log              Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0
    Traced Sleep    ${time}      msg=Waiting for TTI Traces
    Dated log              Stop TTI Traces in Streaming Mode...
    ${ttiTraceSubDir}      set Variable    TtiTrace-${time}-${tm}
    ${ttiTraceSubDir}      set Variable if    '${suffix}'!='${EMPTY}'     ${ttiTraceSubDir}-${suffix}
    ...                                                                ${ttiTraceSubDir}
    ${tti_trace_path}=     ttitrace.Stop TTI Traces in Streaming Mode    tti_trace_path=${targpath}/${ttiTraceSubDir}
    Dated log              Decode TTI Traces...
    nps_ttitraces_tools.decode_tti_traces_using_TtitraceReaderEvtDec       desired_storage_directory=${targpath}/${ttiTraceSubDir}
    ...                                                                    num_of_events=${event_nr_max}
    run keyword if   '${w_convert_pcap_to_excelCsv}'=='True'    run keywords
    ...               Dated log    Convert TTI trace from pcap to excelCsv...    AND
    ...               Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv     input_file_path=${tti_trace_path}
    ...                                                                    output_file_path=${targpath}/${ttiTraceSubDir}
    [return]     ${targpath}/${ttiTraceSubDir}

# TTI start
#     [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
#     ${tm}                  Get Current Date
#     ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
#     Set global variable    ${tm}
#     Dated Log              Start TTI Traces in Streaming Mode
#     ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0

#     Traced Sleep    ${time}      msg=Waiting for TTI Traces

# TTI stop
#     [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
#     Dated log              Stop TTI Traces in Streaming Mode...
#     ${ttiTraceSubDir}      set Variable    TtiTrace-${time}-${tm}
#     ${ttiTraceSubDir}      set Variable if    '${suffix}'!='${EMPTY}'     ${ttiTraceSubDir}-${suffix}
#     ...                                                                ${ttiTraceSubDir}
#     ${tti_trace_path}=     ttitrace.Stop TTI Traces in Streaming Mode    tti_trace_path=${targpath}/${ttiTraceSubDir}
#     Dated log              Decode TTI Traces...
#     nps_ttitraces_tools.decode_tti_traces_using_TtitraceReaderEvtDec       desired_storage_directory=${targpath}/${ttiTraceSubDir}
#     ...                                                                    num_of_events=${event_nr_max}
#     run keyword if   '${w_convert_pcap_to_excelCsv}'=='True'    run keywords
#     ...               Dated log    Convert TTI trace from pcap to excelCsv...    AND
#     ...               Run keyword and continue on failure     ttitrace.Convert TTI trace from pcap to excelCsv     input_file_path=${tti_trace_path}
#     ...                                                                    output_file_path=${targpath}/${ttiTraceSubDir}
#     [return]     ${targpath}/${ttiTraceSubDir}

Set MRBTSID and NRBTSID
    ${dist_name_nrbts}                   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${dist_name_nrcell1}                 Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${dist_name_nrcell2}                 Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ${dist_name_nrdb_pdcp1}              Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-1
    ${dist_name_nrdb_pdcp2}              Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-2
    ${dist_name_nrdb_pdcp3}              Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-3
    ${dist_name_nrdb_RLC_AM1}            Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-1
    ${dist_name_nrdb_RLC_AM2}            Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-2

    Set Suite Variable                   ${dist_name_nrbts}
    Set Suite Variable                   ${dist_name_nrcell1}
    Set Suite Variable                   ${dist_name_nrcell2}
    Set Suite Variable                   ${dist_name_nrdb_pdcp1}
    Set Suite Variable                   ${dist_name_nrdb_pdcp2}
    Set Suite Variable                   ${dist_name_nrdb_pdcp3}
    Set Suite Variable                   ${dist_name_nrdb_RLC_AM1}
    Set Suite Variable                   ${dist_name_nrdb_RLC_AM2}

Set SCF context
    [Documentation]    This module is used for FDD & TDD so need to kept compliant with both Thechnology
    [Arguments]    ${fdd}=${False}    # this arg is not mandatory so by defauld TDD naming
    Dated log  Arguments >${fdd}<

    Backup Scf
    @{modify_param}    Create List
    set suite variable    @{modify_param}

    ScfDicConstitution   parameter=actUl256Qam             dist_name=${dist_name_nrcell1}    value=${param.NRCELL1.actUl256Qam}
    # ScfDicConstitution   parameter=actUl256Qam             dist_name=${dist_name_nrcell2}    value=${param.NRCELL2.actUl256Qam}

    #test conditions
    ScfDicConstitution   parameter=actRedCapUeSupport      dist_name=${dist_name_nrcell1}    value=${param.NRCELL1.actRedCapUeSupport}
    # ScfDicConstitution   parameter=actRedCapUeSupport      dist_name=${dist_name_nrcell2}    value=${param.NRCELL2.actRedCapUeSupport}
    ScfDicConstitution   parameter=maxNumOfRrcSARedCap     dist_name=${dist_name_nrcell1}    value=${param.NRCELL1.maxNumOfRrcSARedCap}
    # ScfDicConstitution   parameter=maxNumOfRrcSARedCap     dist_name=${dist_name_nrcell2}    value=${param.NRCELL2.maxNumOfRrcSARedCap}

    ScfDicConstitution   parameter=pdcpSNLengthRedCap      dist_name=${dist_name_nrdb_pdcp1}    value=${param.NRBTS.pdcpSNLengthRedCap}
    ScfDicConstitution   parameter=pdcpSNLengthRedCap      dist_name=${dist_name_nrdb_pdcp2}    value=${param.NRBTS.pdcpSNLengthRedCap}
    ScfDicConstitution   parameter=pdcpSNLengthRedCap      dist_name=${dist_name_nrdb_pdcp3}    value=${param.NRBTS.pdcpSNLengthRedCap}

    Dated log     \n
    Dated log                         Parameters to modify:\n  #${modify_param}
    FOR  ${item}  IN   @{modify_param}
       Dated log   ${item}
    END

    Dated log     \n
    Dated log                         OAM try :\n
    OAM Set Params                    ${modify_param}
    Dated log     \n

    OAM Get SCF Files      #this will help to stay with actual SCF level

Set SCF context BEARER
    [Documentation]    This module is used for FDD & TDD so need to kept compliant with both Thechnology
    [Arguments]    ${fdd}=${False}    # this arg is not mandatory so by defauld TDD naming
    Dated log  Arguments >${fdd}<

    Backup Scf
    @{modify_param}    Create List
    set suite variable    @{modify_param}

    ScfDicConstitution   parameter=actUl256Qam             dist_name=${dist_name_nrcell1}    value=${param.NRCELL1.actUl256Qam}
    # ScfDicConstitution   parameter=actUl256Qam             dist_name=${dist_name_nrcell2}    value=${param.NRCELL2.actUl256Qam}

    #test conditions
    ScfDicConstitution   parameter=actRedCapUeSupport      dist_name=${dist_name_nrcell1}    value=${param.NRCELL1.actRedCapUeSupport}
    # ScfDicConstitution   parameter=actRedCapUeSupport      dist_name=${dist_name_nrcell2}    value=${param.NRCELL2.actRedCapUeSupport}
    ScfDicConstitution   parameter=maxNumOfRrcSARedCap     dist_name=${dist_name_nrcell1}    value=${param.NRCELL1.maxNumOfRrcSARedCap}
    # ScfDicConstitution   parameter=maxNumOfRrcSARedCap     dist_name=${dist_name_nrcell2}    value=${param.NRCELL2.maxNumOfRrcSARedCap}

    ScfDicConstitution   parameter=pdcpSNLengthRedCap      dist_name=${dist_name_nrdb_pdcp1}    value=${param.NRBTS.pdcpSNLengthRedCap}
    ScfDicConstitution   parameter=pdcpSNLengthRedCap      dist_name=${dist_name_nrdb_pdcp2}    value=${param.NRBTS.pdcpSNLengthRedCap}
    ScfDicConstitution   parameter=pdcpSNLengthRedCap      dist_name=${dist_name_nrdb_pdcp3}    value=${param.NRBTS.pdcpSNLengthRedCap}

    ScfDicConstitution   parameter=rlcAMDrbSNLengthRedCap      dist_name=${dist_name_nrdb_RLC_AM1}    value=${param.NRBTS.rlcAMDrbSNLengthRedCap}
    ScfDicConstitution   parameter=rlcAMDrbSNLengthRedCap      dist_name=${dist_name_nrdb_RLC_AM2}    value=${param.NRBTS.rlcAMDrbSNLengthRedCap}

    ScfDicConstitution   parameter=rlcAMDrbSNLengthRedCap      dist_name=${dist_name_nrdb_RLC_AM1}    value=${param.NRBTS.rlcAMDrbSNLengthRedCap}
    ScfDicConstitution   parameter=rlcAMDrbSNLengthRedCap      dist_name=${dist_name_nrdb_RLC_AM2}    value=${param.NRBTS.rlcAMDrbSNLengthRedCap}

    ScfDicConstitution   parameter=actEnhancedNgRanSupport      dist_name=${dist_name_nrbts}      value=${True}
    ScfDicConstitution   parameter=actNonVoNRGbrService         dist_name=${dist_name_nrcell1}    value=${True}
    ScfDicConstitution   parameter=actVoNR                      dist_name=${dist_name_nrcell1}    value=${True}

    Dated log     \n
    Dated log                         Parameters to modify:\n  #${modify_param}
    FOR  ${item}  IN   @{modify_param}
       Dated log   ${item}
    END

    Dated log     \n
    Dated log                         OAM try :\n
    OAM Set Params                    ${modify_param}
    Dated log     \n

    OAM Get SCF Files      #this will help to stay with actual SCF level

ScfDicConstitution
    [Documentation]  done to bypass "Run keywords" above as first text after it is a variable
    [Arguments]    ${parameter}=nrarfcn    ${dist_name}=dist_name    ${value}=nrarfcn

    Dated Log                       *** ScfDicConstitution
    &{unitaryDic}      Create Dictionary    parameter=${parameter}    dist_name=${dist_name}    value=${value}
    APPEND TO LIST    ${modify_param}    ${unitaryDic}

Set Context_WTS CFG redcap
    [Arguments]    ${2ue1cell}=${False}    ${APPdcpPacketTrunc}=${False}    ${sim_debug_log_level}=none  ${multibearer}=none
    [Documentation]        3 steps on this KW
    ...                    step 1\   setting param.ue_nr_capabilities
    ...                    step 2\   set_ue simulated id=1 uec=1 >release=17 red_cap=true<
    ...                    step 3\   specific basic design according arguments
    ...                              2uebyCell
    ...                              sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    Dated Log                       *** Set Context_WTS CFG redcap
    # in this TC SA ueid=1 and ueid=2 are used. only ueid=1 is redcapready
    ${ue_id_used}       Set variable    1

    #step 1\
    WtsCfgConfig.startSession
    ${oldValue}          getParam           prefix=ue_param id=${ue_id_used}    param=ue_nr_capabilities    ignore_comments=True
    replaceValue         prefix=ue_param    occurrence=${-1}
    ...                  param=ue_nr_capabilities
    ...                  oldValue=${oldValue}
    ...                  newValue=${param.ue_nr_capabilities}
    ...                  ignore_comments=True
    Dated log            Basic file nr_capabilities value changed from ${oldValue} --> ${param.ue_nr_capabilities}
    WtsCfgConfig.stopSession

    #step 2\
    WtsCfgConfig.startSession
    ${prefix}            Set variable    set_ue simulated id=${ue_id_used} uec
    ${oldValue}          getParam        prefix=${prefix}    param=release    ignore_comments=True
	Run Keyword If       ${oldValue}!=17           RedCap    ${prefix}    ${oldValue}
    WtsCfgConfig.stopSession

    #step 3\
    #this start close session may be done without modification if variable are not true but it conclue all preivious settings with modified
    WtsCfgConfig.startSession
    Run Keyword If       '${2ue1cell}'=='${True}'           2uebyCell
    Run Keyword If       '${APPdcpPacketTrunc}'=='${True}'  PdcpPacketTrunc
    WtsCfgConfig.stopSession         rename=modified

    #step 4\
    Run Keyword If       '${sim_debug_log_level}'!='none'
    ...                  Modify Field in WtsEmu Cfg File     field=sim_debug_log level    value=${sim_debug_log_level}

    #step 5\
    Run Keyword If       '${multibearer}'!='none'
    ...                  Run Keywords
    ...                  Dated Log  -- B E A R E R - C R E A T I O N --
    ...   AND            Create Bearer in Cfg File    5qi=7    proto=udp
    ...   AND            Create Bearer in Cfg File    5qi=8    proto=udp
    ...   AND            Create Bearer in Cfg File    5qi=9    proto=udp
    ...   AND            Create Bearer in Cfg File    5qi=2    proto=udp

    # WtsCfgConfig.startSession
    # ${prefix}            Set variable    sim_debug_log level=
    # ${oldValue}          getParam        prefix=${prefix}    param=sim_debug_log    ignore_comments=True
    # replaceValue         prefix=${prefix}    #occurrence=${-1}
    # ...                  param=sim_debug_log
    # ...                  oldValue=${oldValue}
    # ...                  newValue=${sim_debug_log_level}
    # ...                  ignore_comments=True
    # Dated log            Basic file sim_debug_log_level value changed from ${oldValue} --> ${sim_debug_log_level}
    # WtsCfgConfig.stopSession

PdcpPacketTrunc
    [Documentation]      in case of over usage or UEC CPU on huge traffic or under 12bits SN packets traffic,
    ...                  packet trunk like below will help UEC to not cousume a lot of CPU
    ...                  sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    Dated Log                       *** PdcpPacketTrunc
    ${res}    getIndexUsingParam    prefix=set_uec   paramId=id    paramVal=1
    dated log    ${res}

    ${line_to_search}    Set Variable    set_uec
    ${data2insert}           Set Variable    sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    dated log    Prefix look for ${line_to_search}
    dated log    To insert ${data2insert}
    WtsCfgConfig.AddStringBeforeLine    line=${line_to_search}    str=${data2insert}

RedCap
    [Arguments]    ${prefix}    ${oldValue}
       replaceValue         prefix=${prefix}    occurrence=${-1}
       ...                  param=release
       ...                  oldValue=${oldValue}
       ...                  newValue=17 red_cap=true
       ...                  ignore_comments=True
       Dated log            Basic file set_ue release value changed from ${oldValue} --> 17 red_cap=true

2uebyCell
    Dated Log                       *** 2uebyCell
    ${prefix}            Set variable    set_ue simulated id=2 uec=1 release=15
    ${oldValue}          getParam        prefix=${prefix}    param=cell    ignore_comments=True
    replaceValue         prefix=${prefix}    occurrence=${-1}
    ...                  param=cell
    ...                  oldValue=${oldValue}
    ...                  newValue=1
    ...                  ignore_comments=True
    Dated log            Basic file Now the 2 ue will live on same Cell1

Create Test Suite Folder
    [Documentation]    create test suite folder
    ${timeStamp}          get current date    result_format=%Y%m%d_%H%M%S

    Set Suite Variable    ${testSuiteDir}    ${OUTPUT DIR}/Logs/${TEST NAME}_${timeStamp}
    #Cette expression régulière va retirer tous les caractères qui ne sont pas des lettres (majuscules et minuscules),
    #des chiffres, des caractères de soulignement (_), des points (.), des tirets (-) et des slashs (/). Ces caractères
    #sont couramment utilisés pour les noms de fichiers et de répertoires en Linux.
    ${testSuiteDir}       Replace String Using Regexp    ${testSuiteDir}    [^a-zA-Z0-9/_.-]      ${EMPTY}
    Dated log             \n out of regex: ${testSuiteDir}

    create directory      ${testSuiteDir}

    Set Suite Variable    ${ConfigDir}        ${testSuiteDir}/Config_${timeStamp}
    Create Directory      ${ConfigDir}
    Set Suite Variable    ${logsDir}          ${testSuiteDir}/logs
    Create Directory      ${logsDir}
    Run Keyword If        ${VMmonitoring}     Run keywords
    ...                                       Set Global Variable   ${MoniDir}          ${testSuiteDir}/MONITORING
    ...                   AND                 Create Directory      ${MoniDir}

Backup Scf
    [Documentation]                 Save the current SCF
    [Arguments]    ${dir}=${LOG_PATH}
    ${timeStamp}       get current date    result_format=%Y%m%d_%H%M%S
    ${g_backup_scf}    OAM Get SCF File    dir=${dir}    file=SCF_ofTheTest_${timeStamp}.xml
    Set Suite Variable    ${g_backup_scf}
    Dated Log    SCF backup file = ${g_backup_scf}


CollectConfigfilesUsedForTest
    [Documentation]                 Save current scf/iphy/swconfig/basic files used for the test in ${testSuiteDir}
    Dated Log                       *** CollectConfigfilesUsedForTest
    Backup Scf            ${ConfigDir}
    Backup Files FTS      ${FD_ALL}           ${ConfigDir}

    #previou KW collect only original .cfg, not cfg modified by the test => correction of this:
    SSH Exec              rm ${ConfigDir}/*.cfg                                                          alias=${alias_epcsim}
    ${cmd}                set variable    cp -p ${tl.core.dir_path}/${tl.core.cfg_filename} ${ConfigDir}/${tl.core.cfg_filename}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}                                                                         alias=${alias_epcsim}

    Set Suite Variable    ${LOG_PATH_bu}      ${LOG_PATH}
    Set Suite Variable    ${LOG_PATH}         ${ConfigDir}
    # Get Data From Gnb TargetBD File           card_name=${param.RU}
    Set Suite Variable    ${LOG_PATH}         ${LOG_PATH_bu}


SherpaProcessingII
    # [Arguments]    ${nbPrbmaxDeviationDL}=20    ${nbPrbmaxDeviationUL}=20

    ${trace_dir}   Set Variable            ${LOG_PATH}
    Dated log  Upload and decode sherpa pcap files, location : ${trace_dir}
    Upload and decode sherpa pcap files    Sherpa_logs_local_path=${trace_dir}    keep_pcap_file=${True}

    ${scsFDD__OK}     Verify Message presence in csv Files    #[Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${directory}
    ...               directory=${sherpa_output_path}
    ...               CsvName=micro__Scg.csv
    ...               ColumnName=DL/UL scs(Khz)
    ...               valuetocheck=${param.ssbScs}/${param.ssbScs}
    Dated log  check scsFDD:  ${scsFDD__OK}

    ${scsFDD__OK_II}    Run keyword If    "${scsFDD__OK}"=="False"
    ...                 Verify Message presence in csv Files
    ...                   directory=${sherpa_output_path}
    ...                   CsvName=micro__Scg.csv
    ...                   ColumnName=DL/UL scs(Khz)
    ...                   valuetocheck=${param.ssbScs}/like DL
    Run keyword If     "${scsFDD__OK_II}"=="False"    Run keywords
    ...                             Dated log  check scsFDD_II: ${scsFDD__OK_II}
    ...                AND          Set Global Variable         ${AutoSaveDebugData}    ${True}  #snapshot collection
    ...                AND          FAIL    2 attempt failed

    ${BandWth_OK}     Verify Message presence in csv Files    #[Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${directory}
    ...                 directory=${sherpa_output_path}
    ...                 CsvName=micro__Scg.csv
    ...                 ColumnName=DL/UL bandwidth(Mhz)
    ...                 valuetocheck=${param.chBwDl}/${param.chBwUl}
    Dated log  check BandWth: ${BandWth_OK}

    ${BandWth_OK_II}    Run keyword If   "${BandWth_OK}"=="False"
    ...                 Verify Message presence in csv Files    #[Arguments]    ${CsvName}    ${ColumnName}    ${valuetocheck}   ${directory}
    ...                   directory=${sherpa_output_path}
    ...                   CsvName=micro__Scg.csv
    ...                   ColumnName=DL/UL bandwidth(Mhz)
    ...                   valuetocheck=${param.chBwDl}/like DL
    Run keyword If     "${BandWth_OK_II}"=="False"    Run keywords
    ...                            Dated log  check BandWth: ${BandWth_OK_II}
    ...                AND         Set Global Variable       ${AutoSaveDebugData}    ${True}  #snapshot collection
    ...                AND         FAIL    2 attempt failed

    # Should Be True    ${scsFDD__OK}
    # Should Be True    ${BandWth_OK}

    @{ROBOTS}=          Create List    UL    DL
    FOR    ${directionCap}    IN    @{ROBOTS}
                ${directionSmall} =    Convert To Lower Case       ${directionCap}
                Dated log  directionSmall: ${directionSmall}

                ${maxPRB}         CB009384.Verify Max PRB In Sherpa    ${directionSmall}
                ${dodPerCent}     evaluate    ${param.nbPrbmax} * ${nbPrbmaxDeviation${directionCap}} / 100
                ${maxPRBdod}      evaluate    ${param.nbPrbmax} - ${dodPerCent}
                Dated log  is ${maxPRB} > ${maxPRBdod} ?
                Should Be True    ${maxPRB} > ${maxPRBdod}                #no necessary of evaluate as variables are intgers
    END

SherpaProcessing
    [Arguments]    ${directionCap}=DL    ${nbPrbmaxDeviation}=20

    ${trace_dir}   Set Variable            ${LOG_PATH}
    Dated log  Upload and decode sherpa pcap files, location : ${trace_dir}
    Upload and decode sherpa pcap files    ${trace_dir}

    #je triche pour le ${valuetocheck} car en FDD scs c'est 15 KHz et dans le scv 15KHz (sans espace)
    #https://jiradc.ext.net.nokia.com/browse/FIVEG_FTPS-36968 (attente de traitement monoligne)
    @{ssbScs_List}    create list    ${param.ssbScs}

    @{chBw_List}    Run keyword If    '${directionCap}'=='UL'    create list    ${param.chBwUl}
    ...               ELSE    create list    ${param.chBwDl}

    Dated log    chBw_List : ${chBw_List}
    # ${scsFDD__OK}     Sherpa.Check Values In File    ${sherpa_output_path}/tcpdump/micro__Scg.csv    DL scs(Khz)          ${ssbScs_List}
    # ${BandWth_OK}     Sherpa.Check Values In File    ${sherpa_output_path}/tcpdump/micro__Scg.csv    DL bandwidth(Mhz)    ${chBwDl_List}

    Dated log  directionCap scs(Khz): ${directionCap} scs(Khz)
    ${scsFDD__OK}     Verify Message presence in csv Files    micro__Scg.csv
    ...               ${directionCap} scs(Khz)    ${ssbScs_List}    ${sherpa_output_path}
    Dated log  check scsFDD:  ${scsFDD__OK}
    ${BandWth_OK}     Verify Message presence in csv Files    micro__Scg.csv
    ...               ${directionCap} bandwidth(Mhz)    ${chBw_List}    ${sherpa_output_path}


    Dated log  check BandWth: ${BandWth_OK}
    Should Be True    ${scsFDD__OK}
    Should Be True    ${BandWth_OK}

    ${directionSmall} =    Convert To Lower Case       ${directionCap}
    Dated log  directionSmall: ${directionSmall}

    ${maxPRB}         CB009384.Verify Max PRB In Sherpa    ${directionSmall}
    ${dodPerCent}     evaluate    ${param.nbPrbmax} * ${nbPrbmaxDeviation} / 100
    ${maxPRBdod}      evaluate    ${param.nbPrbmax} - ${dodPerCent}
    Dated log  is ${maxPRB} > ${maxPRBdod} ?
    Should Be True    ${maxPRB} > ${maxPRBdod}                #no necessary of evaluate as variables are intgers


CB009384.Verify Max PRB In Sherpa
    [Documentation]     Point out the max PRB found in Sherpa macro__dlStat.csv "MAX PRB" column
    ...                 Return the value
    ...                 argument direction : dl or ul in small letters
    [Arguments]    ${direction}=dl
    ${max}              Set Variable    ${none}
    SherpaCsvReader.setup reader    ${sherpa_output_path}/tcpdump/macro__${direction}Stat.csv
    ${result}           SherpaCsvReader.get_values_for_column    MAX PRB
    # Dated log  result: ${result}
    ${newlist}          Evaluate    [item for item in ${result} if item != '']     #File sanity remove empty result
    set suite variable    ${newlist}
    # Dated log  Thenewlist: ${newlist}
    ${newlistII}        Evaluate         [int(i) for i in ${newlist}]              #File Sanity convert stings in integer
    Dated log  column MAX PRB contain ${newlistII}
    ${max}=    Evaluate    max($newlistII)
    [Return]    ${max}

Init Trace color
    ${consTraceColor}               Evaluate                    "${CYAN}"
    ${consTraceColorRed}            Evaluate                    "${RED}"
    ${defColor}                     Evaluate                    "${NORMAL}"
    Set Suite Variable              ${consTraceColor}
    Set Suite Variable              ${consTraceColorRed}
    Set Suite Variable              ${defColor}

Alarmslist
    [Arguments]    ${Step}=Beg    ${testCaseDir}=${LOG_PATH}
    Dated log New Line   OAM Get Active Alarms to Save into file
    ${aliasGNB}          OAM Connect                             ${GNB_DU.oam}
    Dated log            ${aliasGNB}

    ${active_alarms}      OAM Get Active Alarms                   oam=${GNB_DU.oam}    textFormat=${False}

    ${len}                Get Length                             ${active_alarms}
    ${alarm_id_list}      Create List
    ${alarm_name_list}    Create List
    ${faultId}=           set variable if                        ${isAiC}        fault_id
    ...                                                                          faultId
    ${faultName}=         set variable if                        ${isAiC}        fault_name
    ...                                                                          faultName
    FOR    ${i}           IN RANGE    ${len}
          ${tmp_id}         Get From Dictionary    ${active_alarms[${i}]}    ${faultId}
          ${tmp_name_id}    Get From Dictionary    ${active_alarms[${i}]}    ${faultName}
          Append To List    ${alarm_id_list}    ${tmp_id}
          Append To List    ${alarm_name_list}    ${tmp_name_id}
    # Dated log     Active alarms: alarm_id_list=${alarm_id_list}
    # Dated log     Active alarms: alarm_name_list=${alarm_name_list}
    END
    Append To File        ${testCaseDir}/OAM_Alarms_${Step}_${TEST_NAME}.txt     Active Alarms Id List:\n${alarm_id_list}\n\n
    Append To File        ${testCaseDir}/OAM_Alarms_${Step}_${TEST_NAME}.txt     Active Alarms Name List:\n${alarm_name_list}\n\n

    OAM Disconnect        ${GNB_DU.oam}


# SCF Corner #################################################################################################


# Attach Traffic corner #######################################################################################
Tcheck
    [Documentation]    This is the Tcheck Traffic check mechanisum foe 1 ue
    ...                is on ${deviation_in_percent} range 5% as default value
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl
    ...            ${expected_data_rate}=5    ${deviation_in_percent}=5

    Dated log  Arg: ue:${ue} pdu:${pdu} qfi:${qfi} tref_id:${trf_id} dir:${dir} expected:${expected_data_rate} deviation:${deviation_in_percent}

    wtsemu.ue_stats_nr  id=${ue}    type=pusch    scell=0
    ${LynxStatus_UL}    wtsemu.read_wtsemu_output_until    expected=NR PUSCH Throughput   timeout=10
    wtsemu.ue_stats_nr  id=${ue}    type=pdsch    scell=0
    ${LynxStatus_DL}    wtsemu.read_wtsemu_output_until    expected=NR PDSCH Throughput   timeout=10
    Dated log  Arg: ue:${ue} Lynx UL ${LynxStatus_UL}
    Dated log  Arg: ue:${ue} Lynx DL ${LynxStatus_DL}



    wtsemu.bearer_stats_clear       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=bi            #bi is Ul and Dl

    #${average_out}=    UteWts.Get Average Traffic Rate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}
    sleep   15s    #to let Berear_stat buffer collect again
    wtsemu.Bearer Stats             ue=${ue}
    ...                             dir=${dir}                        #trf_id=${trf_id}
    ...                             qfi=${qfi}                        pdu=${pdu}

    Empty Buffer For Egate
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=20
    Dated Log           ${status}
    ${output}=                 Get Lines Containing String             ${output}          Average data rate
    ${output}=                 Replace String      ${output}      Average data rate       ${EMPTY}
    @{words}=                  Split String        ${output}      (
    ${average_out}=            Strip String        ${words[0]}
    should not be empty     ${average_out}
    Dated log  average_out: ${average_out}
    ${average}    Convert To Integer    ${average_out}
    ${MEGA}=    Set Variable      1000000
    ${average_rate}=    Evaluate      ${average} / ${MEGA}
    ## compare with expected data rate with percentage
    ${min}=             Evaluate                                ${expected_data_rate} * (100 - ${deviation_in_percent}) / 100
    ${max}=             Evaluate                                ${expected_data_rate} * (100 + ${deviation_in_percent}) / 100
    ${statusError}=     Evaluate                                ${min} <= ${average_rate}
    ${statusWarn}=      Evaluate                                ${average_rate} <= ${max}
    ${statusStr}        Set variable if                         '${statusError}'=='True'
    ...                 REACHED                                 NOT REACHED
    ${statusStr}        Set variable if                         '${statusWarn}'=='True'
    ...                 ${statusStr}                            EXCEEDED
    Dated Log           Average data rate in ${dir} trf_id=${trf_id} for ${statusStr}: expected = ${expected_data_rate}, current = ${average_rate}
    Run Keyword If      '${statusError}'!='True'                 Fail    Data rate failure
    [Return]    ${statusStr}

#=== MIRRORING
CB009384_Capture_session_initiating
    Dated Log                       *** install Mirroring scripts in GNB

    ${CaptureCPRT_setup}            Capture CPRT Set upon config
    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_setup}             withTN=True             suffix=_setup

    ${CaptureCore_setup}            Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_setup}             withTN=True             suffix=_setup

    ${CaptureBIP}                   Capture L1L2 Set Upon Config    airscale=${GNB_DU}       isMirror=${True}
    Capture Init                    ${CaptureBIP}                   withTN=True

    Set Suite Variable              ${CaptureCPRT_setup}
    Set Suite Variable              ${CaptureCore_setup}
    Set Suite Variable              ${CaptureBIP}

    ${CaptureCPRT_attach}           Capture CPRT Set upon config
    ${CaptureCPRT_attach.filter}    Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_attach}            withTN=True             suffix=_attach_ueid1_redcap

    ${CaptureCore_attach}           Capture CORE Set Upon Config
    Capture Init                    ${CaptureCore_attach}            withTN=True             suffix=_attach_ueid1_redcap

    Set Suite Variable              ${CaptureCPRT_attach}
    Set Suite Variable              ${CaptureCore_attach}


CB009384 Capture start
    [Arguments]                     ${step}
    Dated Log                       *** CB009384 Capture start
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_setup}
    ...  AND                        Capture Start                   ${CaptureCore_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_attach}
    ...  AND                        Capture Start                   ${CaptureCore_attach}


CB009384 Capture Stop
    [Arguments]                     ${step}
    Dated Log                       *** CB009384 Capture Stop
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...  AND                        Capture Stop                     ${CaptureCPRT_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...  AND                        Capture Stop                     ${CaptureCPRT_attach}


Start Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm
    Dated Log                       *** Start Btslog
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud
    ${testpc_ssh_config}=  Create Dictionary
    ...     host=${tl.test_pc.default_ssh_connection_details.addr}
    ...     user=${tl.test_pc.default_ssh_connection_details.username}
    ...     password=${tl.test_pc.default_ssh_connection_details.password}
    ${btslog_collector_name}=   Set Variable    btslog
    btslog.create_btslog_collector
    ...     name=${btslog_collector_name}
    ...     executor=${testpc_ssh_config}
    btslog.setup_collectors    names=${btslog_collector_name}
    btslog.start_collectors    names=${btslog_collector_name}
    btslog.set_suite_alias     ${btslog_collector_name}
    Dated log     =====> Start Btslog
    set Test variable     ${BtsLogStarted}    True


Stop Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...    Stop and fetch btslog from Testpc
    ...
    ...    *Note:* KW works only on ute-vm
    ...    :return path: Path to btslog file
    ...
    ...    :param target_dir: Directory to store the btslog file
    ...
    [Arguments]    ${target_dir}=None
    Dated Log                       *** Stop Btslog
    Return From Keyword If  '${tl.test_pc.default_ssh_connection_details.username}'!='ute'   message=Works only on Cloud

    ${btslog_collector_name}=   Set Variable    btslog
    btslog.stop_collectors         names=${btslog_collector_name}
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    Builtin.Sleep   15 sec      # wait for btslog to close
    # WA for https://jira3.int.net.nokia.com/browse/TALIB-854
    btslog.collect_collectors      names=${btslog_collector_name}   target_dir=${target_dir}
    btslog.teardown_collectors     names=${btslog_collector_name}
    [RETURN]    ${target_dir}/${btslog_collector_name}/syslog_files.tgz

Collect PM Counters File
    [Documentation]                 KW to get counters and store in specific directory with day date
    [Arguments]    ${target_dir}=${LOG_PATH}
    Dated Log                       *** Collect PM Counters File
    ${date}                          Get Current Date
    ${date_in_dir_name}              Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                   Set Variable         ${target_dir}/PM_${date_in_dir_name}
    BuiltIn.Log              The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${log_path_pm}
    set Suite Variable              ${LATEST_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}
    BuiltIn.Log     Latest pm counters file : ${LATEST_FILE}

trfdl
    [Documentation]    As loop in loop is not possible in Robot this is
    ...                a sub KW of Traffic KW in charge to start traffic
    ...                Huge traffic is possible up to  3500 Mbps In DL :
    ...                175 Mbps maximum is possible by trf_id, egate limit to 20 Trf_id, Maximum traffic rate
    ...                is so theoricaly 175 (max Mbps by trf_id) x nb max trf_id (20) 3500 Mbps on DL
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${mbps}=22

    Dated log   Args_trf: ue ${ue} pdu ${pdu} qfi ${qfi} mbps ${mbps}
    ${trfid}     set variable    1
    FOR    ${i}    IN RANGE    9999999
            # Dated log  mbps ${mbps}     ${i}
            Dated log  trf_id ${trfid}
            ${complement}          Evaluate                ${mbps} - 175    #175 is the maximum DL TP by trf_id
            #Dated log  complement ${complement}
            Run Keyword If         ${complement}>0 and ${mbps}>=175
                ...                                        wtsemu.trf_data_start       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=dl
                ...                                                                    trf_id=${trfid}    mbps=175
                ...     ELSE IF    ${mbps}>0 and ${mbps}<=175
                ...                                        wtsemu.trf_data_start       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=dl
                ...                                                                    trf_id=${trfid}    mbps=${mbps}
                ...     ELSE                               Exit For Loop
            ${mbps}     set variable    ${complement}
            ${trfid}   Evaluate        ${trfid} + 1
            Run Keyword If    ${trfid} > 19    Exit For Loop       #Trf_id max = 20
            sleep   2s   #to no let start traffic too quickly
    END

DOD
    [Documentation]    This is the DOD Traffic check mechanisum foe 1 ue
    ...                is on ${deviation_in_percent} range 5% as default value
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl
    ...            ${expected_data_rate}=5    ${deviation_in_percent}=5

    Dated log  Arg: ue:${ue} pdu:${pdu} qfi:${qfi} tref_id:${trf_id} dir:${dir} expected:${expected_data_rate} deviation:${deviation_in_percent}

    wtsemu.bearer_stats_clear       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=bi            #bi is Ul and Dl

    #${average_out}=    UteWts.Get Average Traffic Rate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}
    sleep   15s    #to let Berear_stat buffer collect again
    wtsemu.Bearer Stats             ue=${ue}
    ...                             dir=${dir}                        #trf_id=${trf_id}
    ...                             qfi=${qfi}                        pdu=${pdu}

    Empty Buffer For Egate
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=20
    Dated Log                  ${status}
    ${output}=                 Get Lines Containing String             ${output}          Average data rate
    ${output}=                 Replace String      ${output}      Average data rate       ${EMPTY}
    @{words}=                  Split String        ${output}      (
    ${average_out}=            Strip String        ${words[0]}
    should not be empty     ${average_out}
    Dated log  average_out: ${average_out}
    ${average}    Convert To Integer    ${average_out}
    ${MEGA}=    Set Variable      1000000
    ${average_rate}=    Evaluate      ${average} / ${MEGA}
    ## compare with expected data rate with percentage
    ${min}=             Evaluate                                ${expected_data_rate} * (100 - ${deviation_in_percent}) / 100
    ${max}=             Evaluate                                ${expected_data_rate} * (100 + ${deviation_in_percent}) / 100
    ${statusError}=     Evaluate                                ${min} <= ${average_rate}
    ${statusWarn}=      Evaluate                                ${average_rate} <= ${max}
    ${statusStr}        Set variable if                         '${statusError}'=='True'
    ...                 REACHED                                 NOT REACHED
    ${statusStr}        Set variable if                         '${statusWarn}'=='True'
    ...                 ${statusStr}                            EXCEEDED
    Dated Log           Average data rate in ${dir} trf_id=${trf_id} for ${statusStr}: expected = ${expected_data_rate}, current = ${average_rate}
    Run Keyword If      '${statusError}'!='True'                 Fail    Data rate failure
    [Return]    ${statusStr}

EgateEncaps
    [Documentation]      usage: EgateEncaps    enb_xp_param            id=1 ignore_xp=off xp_listening_socket=on
    [Arguments]          ${cmd}    ${arg}      #{cmd} {arg}  #les non named vont dans la suite @{cmd} les named argument vont dans le dico &{arg}
    Dated Log            ======> cmd ${cmd}
    Dated Log            ======> arg ${arg}
    @{words}=            Split String    ${arg}
    &{dic}               create dictionary
    ${idx}=              set variable     0
    FOR    ${elem}       IN    @{words}
           @{bid} =      Split String    ${elem}    separator==
           set to dictionary             ${dic}    ${bid[0]}=${bid[1]}
           ${idx}        evaluate        ${idx}+1
    END
    Run Keyword          wtsemu.${cmd}   &{dic}

5GC001227_ComplementBLER
    [Documentation]          Egate command as complement to check Bler on traffic
    ...                      Egate commands are stored in a list formated as below:
    ...                      egate_command  parameterofpreviousCommand egate_command  parameterofpreviousCommand and so one
    ...                      for egate command without parameter please use ${space}

    @{complement}    Create List
    ...                             ue_stats_nr            id=1 type=pdsch scell=0
    ...                             ue_stats_nr            id=1 type=pusch scell=0
    ...                             bler_testmode_nr       profile_id=3 target_mcs=21 num_dl_pkts=2000
    ...                             bler_testmode_nr       profile_id=4 target_mcs=25 num_dl_pkts=2000
    ...                             ue_testmode_set_nr     id=1 scell=0 testmode=bler profile_id=3 action=activate
    ...                             ue_testmode_set_nr     id=1 scell=0 testmode=bler profile_id=3 action=deactivate
    ...                             ue_testmode_set_nr     id=1 scell=0 testmode=bler profile_id=4 action=activate
    ...                             ue_stats_nr            id=1 type=pdsch scell=0
    ...                             ue_stats_nr            id=1 type=pusch scell=0
    ...                             ue_disp                ${space}
    ...                             ue_stats_nr            id=1 type=pdsch scell=0
    ...                             ue_stats_nr            id=1 type=pusch scell=0
    # ...                             sim_log_set flush      ${space}

    ${len}=                   Get Length    ${complement}
    ${LenghtcomplementMoins1}=      Evaluate         ${len}-1
    FOR    ${index}           IN RANGE    0    ${LenghtcomplementMoins1}   2
           ${indexPlus1}=     Evaluate         ${index}+1
           ${egate_command}=  Set Variable     ${complement}[${index}]
           ${egate_param}=    Set Variable     ${complement}[${indexPlus1}]

           Run Keyword If     '${egate_command}'=='sim_log_set flush'    Sleep    60s
           Dated Log          send on egate: ${egate_command} ${egate_param}
           EgateEncaps        ${egate_command}    ${egate_param}
           Sleep              2s
    END

    #Check if mobile still alive
    wtsemu.ue_disp     id=1
    ${output}   wtsemu.read_wtsemu_output_until_re        expected=PDN    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    ACTIVE    partial_match=${TRUE}
    Log to Console    ${output}
    Log to Console    UE: 1 moved to RRC Active state

erase_eventual_basic_wts_step2
    [Documentation]          This KW help to erase evental basic_wts_step2.* file from previous test
    ...

    # ${cmd}=             set variable             rm -f ${WTS_CFG_LOCAL_PATH}/basic*step2.modified.*;rm -rf /tmp/ute/  #lie WtsCfgConfig.robot
    ${cmd}=             set variable             rm -f /opt/iphy/latest/basic*step2.modified.*;rm -rf /tmp/ute/
    Dated Log           command sent to Epcsim : ${cmd}
    SSH Exec            command=${cmd}           alias=${alias_epcsim}