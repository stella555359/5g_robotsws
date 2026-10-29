*** Settings ***

Documentation     File containing keywords used by CB009568 test suites
...               it contain Redcap SA KW
...               2024-04-23    - vincent.boulet@nokia.com    - Parity testing to introduce dRNIC RINLINE2 CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...               2024-04-29    - vincent.boulet@nokia.com    - Check Counter And KPI Constraints for Cloud RAN
...               2024-09-24    - richard.duthu@nokia.com     - Produce Scout Data
Library           OperatingSystem
Library           String
Library           taf.collectors.btslog                                     WITH NAME    btslog
Library           taf.wts.runner                                            WITH NAME    wtsemu
Library           ../../../resources/common/TtiTrace/python/ttitrace.py     WITH NAME    nps_ttitraces_tools
Library           taf.config.scf                                            WITH NAME    scf
Library           taf.sbts.oam.coam.admin                                   WITH NAME    sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py    WITH NAME    coam_parameter
Library           taf.transport.ssh                                         WITH NAME    ssh
Library           ../python/numCdmGroupNoData_checker.py
# Library           ../python/4_4_CL_SM_checker.py
Library           BuiltIn
Library           ../../../../../resources/SWENG/python/StringTool.py

Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource          ../../../../../resources/SWENG/robot/CfgFilesTools.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot

Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Backup.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot

Resource          ../../../resources/robot/ConfigCollector_Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot

Resource          ../../../resources/robot/TDD_MultiBW_Keywords.robot

Variables         ../python/Constants.py


*** Variables ***

${userneed_PCAP}                 False
${userneed_TTI}                  False
${userneed_Btslog}               False
${userneed_TPcheck}              False

# following to manage end of collect
${BtsLogStarted}                 False
${save_debug_data}               False

# 9568_Set_RedcapRel17_And_Options KW use this variable
${bearer_set_allreadyDone}       False

# miscelaneous
${iphy_file_path}                /ffs/run/simmode

# Riyad - addition
${gnb_alias}                     gnb_under_test
${APPdcpPacketTrunc}             True

&{NRCELL1}                 actUl256Qam=true
...                        actRedCapUeSupport=true
...                        maxNumOfRrcSARedCap=200
...                        cellBarredRedCap=no barring
...                        dlMimoMode=4x4 or 4x2 Closed Loop Spatial Multiplexing
...                        freqBandIndicatorNR=78
...                        gscnOrSsPbchArfcn=7878
...                        nrCellType=4DL4UL
...                        nrarfcn=636666
...                        actDlDataDmrsFdm=true
...                        redCap1RxUesEnabled=true
...                        thres256QamMcsRedCap1Rx=20

&{NRCELL1_CR}              actUl256Qam=false
...                        actRedCapUeSupport=true
...                        maxNumOfRrcSARedCap=200
...                        cellBarredRedCap=1RX barring
...                        dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...                        freqBandIndicatorNR=78
...                        gscnOrSsPbchArfcn=7880
...                        nrCellType=4DL4UL
...                        nrarfcn=636534
...                        actDlDataDmrsFdm=true
...                        redCap1RxUesEnabled=true
...                        thres256QamMcsRedCap1Rx=20

&{NRBTS}                   pdcpSNLengthRedCap=len12bits
...                        rlcAMDrbSNLengthRedCap=rlcAm12bitSN
...                        actMeasurementProfile=SA+NSA
...                        actMobilityProfile=true

&{NRBTS_CR}                pdcpSNLengthRedCap=len12bits
...                        rlcAMDrbSNLengthRedCap=rlcAm12bitSN
...                        actMeasurementProfile=deactivated
...                        actMobilityProfile=false

&{NRMOPR_NSA1}
...                        a1MeashoEnabled=none
...                        a2MeashoEnabled=none
...                        a3MeasEnabled=none
...                        a5MeasEnabled=none


# Riyad - modification
&{UE1_redcap1rx}
...                        ueid=1
...                        isRc=${True}
...                        Rx=1
...                        ue_nr_capabilities=${Redcap1rx_capa}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE2_redcap1rx}           ueid=2
...                        isRc=${True}
...                        Rx=1
...                        ue_nr_capabilities=${Redcap1rx_capa}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE1_redcap2rx}
...                        ueid=1
...                        isRc=${True}
...                        Rx=2
...                        ue_nr_capabilities=${Redcap2rx_capa}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE2_redcap2rx}
...                        ueid=2
...                        isRc=${True}
...                        Rx=2
...                        ue_nr_capabilities=${Redcap2rx_capa}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE1_legacy}
...                        ueid=1
...                        isRc=${false}
...                        Rx=4
...                        ue_nr_capabilities=${Legacy_1Tx1Rx}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE2_legacy}
...                        ueid=2
...                        isRc=${false}
...                        Rx=4
...                        ue_nr_capabilities=${Legacy_1Tx1Rx}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE_DlDmrsType2}
...                        ueid=1
...                        isRc=${True}
...                        Rx=1
...                        ue_nr_capabilities=${Redcap1rx_capa}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20

&{UE_DlDmrsType2_CR}
...                        ueid=1
...                        isRc=${True}
...                        Rx=1
...                        ue_nr_capabilities=${Redcap1rx_capa}
...                        Target_cell=1
...                        DL_TP=175
...                        UL_TP=20
...                        Last_trfid_used=0
...                        pdu=1
...                        DlExpected=50
...                        UlExpected=20


@{uelist1}                 ${UE1_redcap1rx}
...                        ${UE2_redcap1rx}

@{uelist2}                 ${UE1_redcap1rx}
...                        ${UE2_redcap1rx}

@{uelist3}                 ${UE1_redcap2rx}
...                        ${UE2_redcap2rx}

@{uelist4}                 ${UE1_redcap2rx}
...                        ${UE2_redcap2rx}

@{uelist5}                 ${UE1_legacy}
...                        ${UE2_legacy}

@{uelist6}                 ${UE_DlDmrsType2}

@{uelist6_CR}              ${UE_DlDmrsType2_CR}



&{A1}                      NRCELL1=${NRCELL1}
...                        NRBTS=${NRBTS}
...                        NRMOPR_NSA1=${NRMOPR_NSA1}
...                        twoUEonSameCell=${True}
...                        GetTtiTraceTime=1
...                        deviation_in_percent=15
...                        ListOfUeEngaged=${uelist1}
...                        TrafficDuration=30
...                        miNrDlSignalQuality=5min
...                        PMdod=${CURDIR}/../config/CB009568_Constraints_SR.csv

&{A2}
...                        NRCELL1=${NRCELL1}
...                        NRBTS=${NRBTS}
...                        NRMOPR_NSA1=${NRMOPR_NSA1}
...                        twoUEonSameCell=${True}
...                        GetTtiTraceTime=1
...                        deviation_in_percent=15
...                        ListOfUeEngaged=${uelist2}
# ...                        ListOfUeEngaged=${uelist5}
...                        TrafficDuration=30
...                        miNrDlSignalQuality=5min
...                        PMdod=${CURDIR}/../config/CB009568_Constraints_SR.csv

&{A3}
...                        NRCELL1=${NRCELL1}
...                        NRBTS=${NRBTS}
...                        NRMOPR_NSA1=${NRMOPR_NSA1}
...                        twoUEonSameCell=${False}
...                        GetTtiTraceTime=1
...                        deviation_in_percent=15
...                        ListOfUeEngaged=${uelist6}
...                        TrafficDuration=30
...                        miNrDlSignalQuality=5min
...                        PMdod=${CURDIR}/../config/CB009568_Constraints_SR.csv

&{A3_CR}
...                        NRCELL1=${NRCELL1_CR}
...                        NRBTS=${NRBTS_CR}
...                        NRMOPR_NSA1=${NRMOPR_NSA1}
...                        twoUEonSameCell=${False}
...                        GetTtiTraceTime=1
...                        deviation_in_percent=15
...                        ListOfUeEngaged=${uelist6_CR}
...                        TrafficDuration=30
...                        miNrDlSignalQuality=5min
...                        PMdod=${CURDIR}/../config/CB009568_Constraints_TC4_VDU.csv
...                        PMdod_VCU=${CURDIR}/../config/CB009568_Constraints_TC4_VCU.csv

&{A4}
...                        NRCELL1=${NRCELL1}
...                        NRBTS=${NRBTS}
...                        NRMOPR_NSA1=${NRMOPR_NSA1}
...                        twoUEonSameCell=${False}
...                        GetTtiTraceTime=1
...                        deviation_in_percent=15
...                        ListOfUeEngaged=${uelist6}
...                        TrafficDuration=30
...                        miNrDlSignalQuality=5min
...                        PMdod=${CURDIR}/../config/CB009568_Constraints_SR.csv

*** Keywords ***
10767_Rob-redcap-register-100
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell1 or cell2 (according twoUEonSameCell value) + traffic
    ...                             1 ue SA redcap is set on cell1 + traffic

    [Arguments]                                   ${param}

    Init Sequence                                 ${param}

    Step                                 10767_SessionManagment
    Step                                 erase_eventual_basic_wts_step2
    Critical Step                        Set MRBTSID and NRBTSID
    Critical Step                        Set SCF context-                   True    #FDD = True
    # Critical Step                        Set Context_WTS CFG redcap        infra=SA
    # ...                                                                    2ue1cell=${param.twoUEonSameCell}
    # ...                                                                    APPdcpPacketTrunc=${True}
    Critical Step                        Create UEs in Cfg File            nb_nsa_ues=0
    ...                                                                    nb_sa_ues=${param.nb_ue_SA}
    Restart TL
    10767_SessionManagment
    9568_Start Btslog
    9568_Alarmslist   Beg    ${logsDir}
    # 10767_Capture start    cellSetup
    Critical Step                        CallSetup.Setup Wtsemu SA
    # 10767_Capture Stop     cellSetup

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

10767_Rob-redcap-8bearerPerUE
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell3 or cell4 (according twoUEonSameCell value) + traffic
    ...                             1 ue SA redcap is set on cell3 + traffic

    [Arguments]                               ${param}

    Init Sequence                             ${param}
    10767_Redcap_settings                     ${param}    multibearer=${True}
    10767_SessionManagment

    9568_Start Btslog
    9568_Alarmslist                          Beg    ${logsDir}
    # 10767_Capture start    cellSetup
    Critical Step                             CallSetup.Setup Wtsemu SA
    # 10767_Capture Stop     cellSetup

    ${dl_tput_per_ue}    ${ul_tput_per_ue}    10767_Throughtput adaptation to config 2ueOnSameCellorNot
    ...                                       ${param.twoUEonSameCell}    ${param.DL_TP}    ${param.UL_TP}

    ${Endrange}=                              Evaluate    ${param.nb_sequence} + 1
    FOR     ${SeqNum}                         IN RANGE    1    ${Endrange}
        Dated Log New Line                    * * * * Bearer stress test SEQUENCE NUMBER ${SeqNum} / ${param.nb_sequence} Seq * * * *

        10767_bearer_Register_pdu_traf_dereg        ${dl_tput_per_ue}    ${ul_tput_per_ue}

    END


10767_Rob-register-deregister_under_ul_dl
    [Documentation]                 2 cells are set redcap capable
    ...                             1 ue SA legacy is set on cell1 or cell2 (according twoUEonSameCell value) + traffic
    ...                             1 ue SA redcap is set on cell1 + traffic

    [Arguments]                                   ${param}

    Init Sequence                                 ${param}

    Step                                 10767_SessionManagment
    Step                                 erase_eventual_basic_wts_step2
    Critical Step                        Set MRBTSID and NRBTSID
    Critical Step                        Set SCF context-                   True    #FDD = True
    Critical Step                        Set Context_WTS CFG redcap        infra=SA
    ...                                                                    2ue1cell=${param.twoUEonSameCell}
    ...                                                                    APPdcpPacketTrunc=${True}
    ...                                                                    sim_debug_log_level=4

    Critical Step                        Create UEs in Cfg File            nb_nsa_ues=0
    ...                                                                    nb_sa_ues=${param.nb_ue_SA}
    Restart TL
    10767_SessionManagment

    Run Keyword If                       ${VMmonitoring}       Run keywords
    ...                                  ${cmd}=               Catenate      sudo nice -n -20 top >> ${MoniDir}/cpu_ram_wts.log &
    ...   AND                            Dated Log             command cpu monitoring : ${cmd}
    ...   AND                            Dated Log             alias ${alias_epcsim}
    ...   AND                            ${pid}=               Set Variable      0
    ...   AND                            ${pid}=               SSH Exec      command=sudo nice -n -20 top >> ${MoniDir}/cpu_ram_wts.log &
    ...                                                        alias=${alias_epcsim}
    ...   AND                            Dated Log             PID: ${pid}
    ...   AND                            Set Suite Variable    ${pid}

    9568_Start Btslog
    9568_Alarmslist                           Beg    ${logsDir}
    # 10767_Capture start    cellSetup
    Critical Step                        CallSetup.Setup Wtsemu SA
    # 10767_Capture Stop     cellSetup

    ${dl_tput_per_ue}    ${ul_tput_per_ue}    10767_Throughtput adaptation to config 2ueOnSameCellorNot
    ...                                       ${param.twoUEonSameCell}    ${param.DL_TP}    ${param.UL_TP}
    ${Endrange}=                              Evaluate    ${param.nb_sequence} + 1
    FOR     ${SeqNum}                         IN RANGE    1    ${Endrange}
        Dated Log New Line                    * * * * SEQUENCE NUMBER ${SeqNum} / ${param.nb_sequence} Seq * * * *
        10767_Register_pdu_traf_dereg        ${dl_tput_per_ue}    ${ul_tput_per_ue}
    END

9568_update_wtscfg_gscn
    [Arguments]    ${cellid}=1    ${gscn}=1

    Dated log            * * * * Set GSCN=${gscn} for TDD cellid=${cellid} * * * *

    WtsCfgConfig.startSession
    ${oldValue}          getParam        prefix=set_cell id=${cellid}        param=gscn
    replaceValue         prefix=set_cell id=${cellid}
    ...                  param=gscn
    ...                  oldValue=${oldValue}
    ...                  newValue=${gscn}
    Dated log            CFG File modified: gscn value changed for Cell${cellid} from ${oldValue} to ${gscn}

    WtsCfgConfig.stopSession

9568_update_wtscfg_nrarfcn
    [Arguments]    ${cellid}=1    ${nrarfcn}=633000:633000

    Dated log            * * * * Set nrarfcn=${nrarfcn} for TDD cellid=${cellid} * * * *

    WtsCfgConfig.startSession
    ${oldValue}          getParam        prefix=set_cell id=${cellid}        param=nr_arfcn
    replaceValue         prefix=set_cell id=${cellid}
    ...                  param=nr_arfcn
    ...                  oldValue=${oldValue}
    ...                  newValue=${nrarfcn}
    Dated log            CFG File modified: nr_arfcn value changed for Cell${cellid} from ${oldValue} to ${nrarfcn}

    WtsCfgConfig.stopSession

9568_Set_UE_serving_cell
    [Arguments]    ${ueid}=1    ${Target_cell}=1
    Dated Log                       * * * * Set UE${ueid} on Cell${Target_cell} * * * *
    WtsCfgConfig.startSession
    ${prefix}            Set variable    set_ue simulated id=${ueid} uec=1 release=
    ${oldValue}          getParam        prefix=${prefix}    param=cell    ignore_comments=True
    replaceValue         prefix=${prefix}    occurrence=${-1}
    ...                  param=cell
    ...                  oldValue=${oldValue}
    ...                  newValue=${Target_cell}
    ...                  ignore_comments=True
    Dated log            ue_id ${ueid} is set to camp on Cell${Target_cell} in basic cfg file
    WtsCfgConfig.stopSession

9568_Set_UE_capa
    [Arguments]          ${ue_id_used_rc}    ${capa}
    WtsCfgConfig.startSession
    ${oldValue}          getParam           prefix=ue_param id=${ue_id_used_rc}    param=ue_nr_capabilities    ignore_comments=True
    replaceValue         prefix=ue_param id=${ue_id_used_rc}    #occurrence=${-1}
    ...                  param=ue_nr_capabilities
    ...                  oldValue=${oldValue}
    ...                  newValue=${capa}
    ...                  ignore_comments=True
    Dated log            Redcap UE id${ue_id_used_rc}: nr_capabilities value changed from ${oldValue} to ${capa}
    WtsCfgConfig.stopSession

9568_Set_Redcap_3gppRel17
    [Arguments]    ${ue_id_used_rc}=1
    WtsCfgConfig.startSession
    ${prefix}            Set variable    set_ue simulated id=${ue_id_used_rc} uec
    ${oldValue}          getParam        prefix=${prefix}    param=release    ignore_comments=True
    replaceValue         prefix=${prefix}    #occurrence=${-1}
    ...                  param=release
    ...                  oldValue=${oldValue}
    ...                  newValue=17 red_cap=true
    ...                  ignore_comments=True
    Dated log            Basic cfg file: Set UE 3GPP release 17 with activation of redcap behavior for simulation purposes
    WtsCfgConfig.stopSession

9568_Add_PdcpTruncateCmd_WTSCFG
    [Documentation]      in case of over usage or UEC CPU on huge traffic or under 12bits SN packets traffic,
    ...                  packet trunk like below will help UEC to not cousume a lot of CPU
    ...                  sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    Dated Log                       * * * Add PDCP Packet Truncate CMD to WTS cfg file * * *
    ${res}    getIndexUsingParam    prefix=set_uec   paramId=id    paramVal=1
    dated log    ${res}
    WtsCfgConfig.startSession
    ${line_to_search}    Set Variable    set_uec
    ${data2insert}           Set Variable    sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100
    dated log    Prefix look for ${line_to_search}
    dated log    To insert ${data2insert}
    WtsCfgConfig.AddStringBeforeLine    line=${line_to_search}    str=${data2insert}
    WtsCfgConfig.stopSession

# KW to add to wts cfg file:
# 1\ 3GPP release 17 for a Redcap ue
# 2\
# 2\ PDCP Truncate cmd if needed
# 3\ Add multiple bearers tif needed
9568_Set_UE_Params
    [Arguments]    ${infra}=SA    ${ue_id_used_rc}=1    ${capa}=None
    ...            ${sim_debug_log_level}=none    ${multibearer}=none    ${isRc}=${False}
    [Documentation]        3 steps on this KW
    ...                    step 1\   setting ue_nr_capabilities
    ...                    step 2\   set_ue simulated id=1 uec=1 >release=17 red_cap=true<
    ...                    step 3\   specific basic design according arguments
    ...                    step 4\   Set UE1 on Cell1
    ...                    step 5\   Add below command to cfg file:
    ...                               sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100

    #step 1
    DatedLog    ${infra}
    DdatedLog_10767      Update UE capabilities for UE${ue_id_used_rc}
    9568_Set_UE_capa    ${ue_id_used_rc}    ${capa}

    #step 2
    Run Keyword if      ${isRc}     Run Keywords
    ...                             DdatedLog_10767     Modify 3GPP Release from 15 to 17 for Redcap UE ${ue_id_used_rc}
    ...        AND                  9568_Set_Redcap_3gppRel17        ${ue_id_used_rc}

    #step 3
    Run Keyword If     '${APPdcpPacketTrunc}'=='True'      9568_Add_PdcpTruncateCmd_WTSCFG
    Set Global Variable    ${APPdcpPacketTrunc}    False

    Run Keyword If     '${sim_debug_log_level}'!='none'
    ...                 Modify Field in WtsEmu Cfg File     field=sim_debug_log level    value=${sim_debug_log_level}

    DdatedLog_10767     multibearer >${multibearer}< bearer_set_allreadyDone >${bearer_set_allreadyDone}<
    Run Keyword If      ${multibearer} and not ${bearer_set_allreadyDone}
    ...                 Run Keywords
    ...                 Dated Log  -- B E A R E R - C R E A T I O N --
    ...   AND           Create Bearer in Cfg File    5qi=7    proto=udp
    ...   AND           Create Bearer in Cfg File    5qi=8    proto=udp
    ...   AND           Create Bearer in Cfg File    5qi=9    proto=udp
    ...   AND           Create Bearer in Cfg File    5qi=2    proto=udp

    ${bearer_set_allreadyDone}=    Set Variable    ${True}   #already done
    Set Global Variable    ${bearer_set_allreadyDone}

# Modify gscn in wts cfg file, set ue serving cell & WTS CFG Params - no TL restart at this step
9568_WTSCFG Adaptation
    [Arguments]    ${multibearer}=None    ${targcell}=None

    ${multibearer}=    set Variable if    '${multibearer}'!='None'    ${multibearer}    ${False}

    9568_update_wtscfg_gscn        cellid=1    gscn=${param.NRCELL1.gscnOrSsPbchArfcn}
    DatedLog    ${targcell}

    Run Keyword If    ${isAic}    9568_update_wtscfg_nrarfcn    cellid=1    nrarfcn=${param.NRCELL1.nrarfcn}:${param.NRCELL1.nrarfcn}

    FOR     ${idx}     IN                      @{param.ListOfUeEngaged}
            DdatedLog_10767                    basic.cfg adaptation for UE=${idx.ueid}

            Run Keyword If                     '${idx.Target_cell}'!='${EMPTY}'
            ...                                9568_Set_UE_serving_cell
            ...                                ${idx.ueid}
            ...                                ${idx.Target_cell}

            Run Keyword If                     '${idx.ue_nr_capabilities}'!='${EMPTY}'
            ...                                9568_Set_UE_Params
            ...                                infra=SA
            ...                                ue_id_used_rc=${idx.ueid}
            ...                                capa=${idx.ue_nr_capabilities}
            ...                                isRc=${idx.isRc}
            ...                                multibearer=${multibearer}
    END

# Modify gscn in AP iphy.xml file - no TL restart
9568_IPHY_Adaptation
    Run Keyword If    not ${isAic}    Run Keywords
    ...                               Dated log                           Update GSCN value into IPHY for cell1
    ...    AND                        WtsXmlConfig.startSession           file=iphy
    ...    AND                        WtsXmlConfig.setTextUsingIndex      //GSCN                ${param.NRCELL1.gscnOrSsPbchArfcn}    1
    ...    AND                        WtsXmlConfig.stopSession            file=iphy
    ...         ELSE                  Dated log                           GSCN value into IPHY for cell1 in case CR is correct by default

# Set distname variable - no TL restart
9568_Set MRBTSID and NRBTSID
    ${dist_name_nrbts}                   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${dist_name_nrcell1}                 Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ${dist_name_nrcell2}                 Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ${dist_name_nrcell3}                 Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ${dist_name_nrcell4}                 Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ${dist_name_nrdb_pdcp1}              Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-1
    ${dist_name_nrdb_pdcp2}              Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-2
    ${dist_name_nrdb_pdcp3}              Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_PDCP-3
    ${dist_name_nrdb_RLC_AM1}            Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-1
    ${dist_name_nrdb_RLC_AM2}            Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_RLC_AM-2
    ${dist_name_NRMOPR_NSA1}             Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRMOPR_NSA-1
    ${dist_name_NRPMRNL_1}               Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1

    Set Suite Variable                   ${dist_name_nrbts}
    Set Suite Variable                   ${dist_name_nrcell1}
    Set Suite Variable                   ${dist_name_nrcell2}
    Set Suite Variable                   ${dist_name_nrcell3}
    Set Suite Variable                   ${dist_name_nrcell4}
    Set Suite Variable                   ${dist_name_nrdb_pdcp1}
    Set Suite Variable                   ${dist_name_nrdb_pdcp2}
    Set Suite Variable                   ${dist_name_nrdb_pdcp3}
    Set Suite Variable                   ${dist_name_nrdb_RLC_AM1}
    Set Suite Variable                   ${dist_name_nrdb_RLC_AM2}
    Set Suite Variable                   ${dist_name_NRMOPR_NSA1}
    Set Suite Variable                   ${dist_name_NRPMRNL_1}


9568_Set SCF Params
    [Documentation]        Dedicated KW to use a delta commissioning file
    [Arguments]                   ${deltaScf}         ${gnb_alias}
    Dated Log New Line            * * * * DELTA COMMISSIONING STARTED * * * *
    sleep   180s    #to let gNB finishing its current task
    sbts_coam.connect_to          name=${gnb_alias}
    Dated Log New Line            delta_file=${deltaScf}
    coam_parameter.perform_scf_delta_commission    delta_file=${deltaScf}    connection=${gnb_alias}
    sleep   180s    #to let gNB finishing its current task
    OAM wait available
    sbts_coam.teardown            connection=${gnb_alias}
    Dated Log New Line            * * * * DELTA COMMISSIONING FINISHED * * * *
    Dated Log New Line            * * * * TL RESTART TRIGGERED * * * *
    Restart TL

Perform Download from Git
    [Arguments]   ${target}   ${dir_to_keep_package}
    log to console  SW download: ${target}
    Run  mkdir -p ${dir_to_keep_package}; touch ${dir_to_keep_package}downloading
    Run    git clone ${target} ${dir_to_keep_package}
    Run  rm -f ${dir_to_keep_package}downloading

Download software package Using Git
    [Documentation]  Downloads sw package from Artifactory using wget
    [Arguments]   ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
    DatedLog    ${sw_folder}
    ${artifactory}  set variable    ${sw_path}
    ${target}   set variable  ${dir_to_keep_package}
    ${exists}=      Run Keyword And Return Status    File Should Exist    ${target}/BSR/${sw_file_name}
    run keyword if  ${exists}==${False}  Perform Download from Git  ${artifactory}  ${target}
    [Return]  ${target}/BSR/${sw_file_name}

ADMIN Update Software
    [Arguments]    ${sw_package}
    ...            ${should_activate}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    sbts_coam.update_software
    ...    sw_package=${sw_package}
    ...    should_activate=${should_activate}
    ...    timeout=${timeout}
    ...    connection=${alias}

ADMIN Update Software With Activation
    [Arguments]    ${sw_package}
    ...            ${timeout}=1800
    ...            ${alias}=coam_gnb
    ADMIN Update Software
    ...    sw_package=${sw_package}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    alias=${alias}

Get and Update BSR SW Using Git
     [Arguments]      ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     ${target}=  Download software package Using Git    ${sw_path}   ${sw_folder}    ${sw_file_name}    ${dir_to_keep_package}
     log to console   Update Software With Activation: ${target}
     ADMIN Update Software With Activation
     ...           sw_package=${target}
     ...           alias=coam_gnb

Connect to COAM ADMIN
    [documentation]   only one Connect to COAM ADMIN call and coam_gnb alias is used by every coam request
    [Arguments]    ${gnb_id}=0  ${bts_host}=${EMPTY}
    ${bts_host}=  Set Variable if  '${bts_host}'=='${EMPTY}'  ${tl.gnbs[${gnb_id}].cu.oam_http_connection_details.addr}  ${bts_host}
    sbts_coam.setup_admin    bts_host=${bts_host}    name=coam_gnb

Custom BSR Update
    Connect to COAM ADMIN
    dated log       =====> Get and Update BSR SW [BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip]
    Get and Update BSR SW Using Git             https://gitlabe1.ext.net.nokia.com/ferrag/sqdgrp_et_44.git
    ...                                         BSR     BSR_AEQE_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip   /home/ute/BSR
    # Dated Log New Line            * * * * TL RESTART TRIGGERED AFTER BSR UPDATE * * * *
    # Restart TL

9568_TL Preparation
    [Arguments]                    ${param}    ${deltaScf}    ${multibearer}=None     ${3fdd}=None
    DatedLog    ${param}
    DatedLog    ${3fdd}
    # call of Restart TL kw via "9568_Set SCF Params" kw
    Run Keywords                   Critical Step     9568_WTSCFG Adaptation      multibearer=${multibearer}
    ...  AND                       Critical Step     9568_IPHY_Adaptation
    ...  AND                       Critical Step     9568_Set MRBTSID and NRBTSID
    Run Keyword If     not ${isAic}    Critical Step     9568_Set SCF Params        ${deltaScf}    ${gnb_alias}
    Run Keyword if     ${B4_EI4_TC2}                 Custom BSR Update

9568_Session Mgmt
    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias_epcsim sur ssh wait For Connect ${alias_epcsim}

CB009568 Main Scenario
    [Documentation]                 Generic KW for CBOO9568 TL Preparation and TC execution
    [Arguments]                     ${param}        ${deltaScf}
    Dated Log New Line              * * * * TEST STARTED * * * *
    ${TTI_logdir}=                  Set Variable    ${logsDir}/tti
    Set Global Variable             ${TTI_logdir}
    Init Sequence                   ${param}
    9568_TL Preparation             ${param}    ${deltaScf}
    9568_Session Mgmt
    9568_L3 Call

10767_Test_BandWith_SA_FDD_conf
    [Documentation]                 2 cells are set redcap capable
    ...                             Test line Setting only

    [Arguments]                     ${param}
    Dated Log New Line              * * * * Test starting * * * *

    Init Sequence                   ${param}
    9568_Setup            ${param}    # Restart TL not necessary anymore as redcap_settins above lead to a TL restart

9568_Capture start
    [Arguments]                     ${step}

    Dated Log                       * * * * 9568_Capture start

    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_setup}
    ...  AND                        Capture Start                   ${CaptureCore_setup}

    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Start                   ${CaptureCPRT_attach}
    ...  AND                        Capture Start                   ${CaptureCore_attach}

    Run Keyword If                  "${step}" == "Traff"            Capture Start
    ...                                                             ${CaptureBIP}

9568_Start Btslog
    [Documentation]    :Author: Soenke Kullberg
    ...
    ...     KW starts Btslog on Testpc with log-collector
    ...
    ...     https://confluence.int.net.nokia.com/display/EE/EE+BTSlog
    ...
    ...     *Note:* KW works only on ute-vm
    Dated Log                       * * * * 9568_Start Btslog
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

    Dated log     =====> 9568_Start Btslog
    set Test variable     ${BtsLogStarted}    True

9568_Capture Stop
    [Arguments]                     ${step}
    Dated Log                       * * * * 9568_Capture Stop
    Run Keyword If                  "${step}" == "cellSetup"         Run Keywords
    ...                             Capture Stop                     ${CaptureCore_setup}
    ...  AND                        Capture Stop                     ${CaptureCPRT_setup}
    Run Keyword If                  "${step}" == "Attach"            Run Keywords
    ...                             Capture Stop                     ${CaptureCore_attach}
    ...  AND                        Capture Stop                     ${CaptureCPRT_attach}
    Run Keyword If                  "${step}" == "Traff"             Capture Stop
    ...                                                              ${CaptureBIP}

9568_Alarmslist
	[Arguments]    ${Step}=Beg    ${testCaseDir}=${LOG_PATH}
    Dated log New Line   OAM Get Active Alarms to Save into file
    ${aliasGNB}          OAM Connect                             ${GNB_DU.oam}

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


9568_TTI start
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    DdatedLog_10767  Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max} w_convert_pcap_to_excelCsv:${w_convert_pcap_to_excelCsv}
    DdatedLog_10767  Arguments targpath:${targpath}
    ${tm}                  Get Current Date
    ${tm}=                 Remove String    ${tm.replace(' ','-')}    .
    Set global variable    ${tm}
    Dated Log              Start TTI Traces in Streaming Mode
    ttitrace.Start TTI Traces in Streaming Mode      filter_bitmap2=0x0

    Traced Sleep    ${time}      msg=Waiting for TTI Traces


9568_TTI stop
    [Arguments]     ${suffix}=${EMPTY}   ${time}=1s    ${event_nr_max}=30000   ${w_convert_pcap_to_excelCsv}=True    ${targpath}=${LOG_PATH}
    DdatedLog_10767  Arguments suffix:${suffix} time:${time} event_nr_max:${event_nr_max}
    DdatedLog_10767  Arguments w_convert_pcap_to_excelCsv:${w_convert_pcap_to_excelCsv} targpath:${targpath}
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


Set DL MU MIMO Test Modes

    # No need of the bellow kw in scope of CB009568
    # Set Rank for UEs

    # Create cell_srs_beam_pos test mode

    wtsemu.cell_srs_beam_pos_nr           profile_id=1
    ...                                   num_of_ue_positions=4
    ...                                   azimuth=-70,-19,20,70

    wtsemu.cell_testmode_set_nr           cell_id=1
    ...                                   gnb=2
    ...                                   testmode=cell_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    # Create ue_srs_beam_pos test mode

    wtsemu.ue_srs_beam_pos_nr             profile_id=1
    ...                                   init_pos=0
    ...                                   srsMode=fixed

    wtsemu.ue_srs_beam_pos_nr             profile_id=2
    ...                                   init_pos=2
    ...                                   srsMode=fixed

    wtsemu.ue_testmode_set_nr             id=1
    ...                                   testmode=ue_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=2
    ...                                   testmode=ue_srs_beam_pos
    ...                                   profile_id=2
    ...                                   action=activate

Set UL MU MIMO Test Modes

    # Create ul_mimo_srs_beam_pos test mode
    wtsemu.ul_mimo_srs_beam_pos_nr        profile_id=1
    ...                                   mode=fixed
    ...                                   init_quad_pos=0
    ...                                   init_sub_quad_pos=0
    ...                                   test_type=UL_MIMO

    wtsemu.ul_mimo_srs_beam_pos_nr        profile_id=2
    ...                                   mode=fixed
    ...                                   init_quad_pos=2
    ...                                   init_sub_quad_pos=3
    ...                                   test_type=UL_MIMO

    wtsemu.ue_testmode_set_nr             id=1
    ...                                   testmode=ul_mimo_srs_beam_pos
    ...                                   profile_id=1
    ...                                   action=activate

    wtsemu.ue_testmode_set_nr             id=2
    ...                                   testmode=ul_mimo_srs_beam_pos
    ...                                   profile_id=2
    ...                                   action=activate

9568 TC4 validation

    Dated Log New Line      ===> CaptureBip.name: ${CaptureBip.name}
    Dated Log New Line      ===> LOG_PATH: ${LOG_PATH}
    ${file}=                catenate    ${LOG_PATH}/${CaptureBIP.name}.pcap
    Dated Log New Line      ===> PCAP L1L2 PATH: ${file}
    Dated Log New Line      Extract DlData_PdschSendReq info from L1L2 PCAP file : ${file}

    set test variable                 ${pcapprocessed}           NumCdmGroupNoData.csv
    set test variable                 ${pcapprocessed_path}      ${LOG_PATH}/${pcapprocessed}

    ${cmd_mcshark}                    Catenate    tshark -r
    ...                               ${file}     -T fields -Y "dldata_pdschsendreq"
    ...                               -e _ws.col.Info
    ...                               -e 3gpp.dmrsScramblingSequenceInt
    ...                               -e DlData_PdschGrant.dlDmrsConfigType
    ...                               -e DlData_PdschGrant.dlDmrsLen
    ...                               -e DlData_PdschGrant.dlDmrsMappingType
    ...                               -e DlData_PdschGrant.dlDmrsAddPos
    ...                               -e DlData_PdschGrant.dlDmrsTypeAPos
    ...                               -e DlData_PdschGrant.antPort
    ...                               -e DlData_PdschGrant.mcs
    ...                               -e DlData_PdschGrant.mcsTable
    ...                               -e DlData_PdschGrant.startPrb
    ...                               -e DlData_PdschGrant.numOfPrb
    ...                               -e DlData_PdschGrant.numOfLayers
    ...                               -e 3gpp.rnti
    ...                               -e DlData_PdschGrant.numOfDmrsCdmGroupWithoutData
    ...                               -E header=y -E separator='/t' > ${pcapprocessed_path}
    Run                               ${cmd_mcshark}

    Run      command=sed -i -e 's/ //g' ${pcapprocessed_path}

    ${thresh}=              Convert To Integer      ${param.NRCELL1.thres256QamMcsRedCap1Rx}
    Dated Log               ===> Check numOfDmrsCdmGroupWithoutData against the MCS Threshold = ${thresh}
    ${isSuccess}            check_num_cdm_grp    ${file}    ${thresh}
    Dated Log New Line      Check numOfDmrsCdmGroupWithoutData Returned ${isSuccess}
    Should Be True          ${isSuccess} == True

Sleep Until PM Availability
    [Arguments]             ${pm_granularity_period}=300
    ...                     ${pm_availability_delay}=60

    Dated Log                                   ===> sleep until PM availability is started
    ${time_of_start}=                           Evaluate    int(time.time())    time
    ${time_of_next_pm_period}=                  Evaluate    (int(${time_of_start} / ${pm_granularity_period}) + 1) * ${pm_granularity_period}
    ${time_of_pm_availability}=                 Evaluate    ${time_of_next_pm_period} + ${pm_availability_delay}
    ${duration_until_pm_availability}=          Evaluate    ${time_of_pm_availability} - ${time_of_start}
    ${timeout_string}=                          Catenate    ${duration_until_pm_availability}  sec
    ${date_of_pm_availability}=                 Convert date    ${time_of_pm_availability}
    Dated Log                                   ===> PM should be available in ${timeout_string}, at ${date_of_pm_availability}
    Sleep                                       ${timeout_string}
    Dated Log                                   ===> sleep until PM availability is ended

PM Print Measurements
    [Documentation]   Mu-MiMo Print PM Measurements
    [Arguments]       ${CellID}=1

    ${M55308C34013}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C34013    ${CellID}
    ${M55308C35007}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C35007    ${CellID}
    ${M55308C36001}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C36001    ${CellID}
    ${M55308C36002}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C36002    ${CellID}
    ${M55308C18002}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C18002    ${CellID}
    ${M55308C36003}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C36003    ${CellID}
    ${M55308C36004}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C36004    ${CellID}
    ${M55308C10001}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C10001    ${CellID}
    ${M55308C10002}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55308C10002    ${CellID}
    ${M55301C19067}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55301C19067    ${CellID}
    ${M55138C00057}=   Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55138C00057    ${CellID}

    Dated Log         ---------------------------------------------------COUNTERS & KPIs----------------------------------------------------
    Dated Log         M55308C34013 - Number of PRBs for 2 UE pair tx for MU MIMO in DL.....................................: ${M55308C34013}
    Dated Log         M55308C35007 - Number of PRBs for 2 UE pair Rx for MU MIMO in UL.....................................: ${M55308C35007}
    Dated Log         M55308C36001 - Maximum DL PRB Utilization per slot counter should stay at 100%.......................: ${M55308C36001}
    Dated Log         M55308C36002 - Maximum UL PRB Utilization per slot counter should stay at 100%.......................: ${M55308C36002}
    Dated Log         M55308C18002 - Maximum number of scheduled (FDM and MU-MIMO) UEs on PUSCH per slot...................: ${M55308C18002}
    Dated Log         M55308C36003 - Number of used PRBs for PDSCH for RedCap..............................................: ${M55308C36003}
    Dated Log         M55308C36004 - Number of used PRBs for PUSCH for RedCap..............................................: ${M55308C36004}
    Dated Log         M55308C10001 - Number of used PRBs for PDSCH.........................................................: ${M55308C10001}
    Dated Log         M55308C10002 - Number of used PRBs for PUSCH.........................................................: ${M55308C10002}
    Dated Log         M55301C19067 - WideBand CQI Histogram for Redcap UE reporting CQI values 15 related to 256 QAM table.: ${M55301C19067}
    Dated Log         M55138C00057 - Peak number of SA RRC users with RedCap in CU.........................................: ${M55138C00057}
    Dated Log         ----------------------------------------------------------------------------------------------------------------------

Collect PM Counters File
    [Documentation]   KW to get counters and store in specific directory with day date
    [Arguments]             ${target_dir}=${LOG_PATH}
    ...                     ${node}='vdu'
    Dated Log                        ===> COLLECT PM COUNTERS
    ${date}                          Get Current Date
    ${date_in_dir_name}              Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                   Set Variable         ${target_dir}/PM_${date_in_dir_name}
    Dated Log                      The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}    Run Keyword If    ${isAic}    Counters.Collect PM files from BTS    ${log_path_pm}    optional_files=${True}
    ...                                                         posProcess=${True}    node=${node}
    ...                         ELSE              Counters.Collect PM files from BTS    ${log_path_pm}
    Run Keyword If    ${isAic} and ${node} == 'vcu'    set Suite Variable    ${LATEST_FILE_VCU}    ${pm_latest}
    ...         ELSE                                   set Suite Variable    ${LATEST_FILE}        ${pm_latest}
    set Suite Variable               ${log_path_pm}
    Dated Log                        ===> Latest PM Counters File : ${LATEST_FILE}
    Run Keyword If          ${B3_EI3_TC1} or ${B4_EI4_TC2}      PM Print Measurements

Check Counter And KPI Constraints
    [Arguments]             ${pm_path}
    ...                     ${localKpiFileName}=${None}
    ...                     ${constraintsFileName}=${None}
    Dated Log                       ===> Check Counters & KPIs constraints S T A R T E D
    Dated log                       Latest PM File location : ${pm_path}
    KPI Evaluate                    pmFile=${pm_path}
    ...                             constraintsFile=${constraintsFileName}
    ...                             localKpiFile=${localKpiFileName}
    ...                             failOnError=${True}
    Dated Log                       ===> Check Counters & KPIs constraints F I N I S H E D

9568 TC_1_2 validation
    [Arguments]     ${param}
    [Documentation]   KW to check counters related to MU-MIMO Testing
    Sleep Until PM Availability
    step            Collect PM Counters File
    Run Keyword If    ${isAic}    step    Collect PM Counters File             node='vcu'
    step                                  Check Counter And KPI Constraints    pm_path=${LATEST_FILE}        constraintsFileName=${param.PMdod}
    Run Keyword If    ${isAic}    step    Check Counter And KPI Constraints    pm_path=${LATEST_FILE_VCU}    constraintsFileName=${param.PMdod_VCU}

9568_L3 Call

    # Start Bts logs
    Run Keyword If      ${userneed_Btslog} and not ${isAic}    9568_Start Btslog

    # Get Current Alarm list
    9568_Alarmslist     Beg                          ${logsDir}

    #-------------------------------------- Capture during Cell Setup
    Run Keyword If      ${userneed_PCAP}             9568_Capture start    cellSetup
    Critical Step                                    CallSetup.Setup Wtsemu SA

    #-------------------------------------- AP DL MU MIMO Test Mode
    Run Keyword IF      ${B3_EI3_TC1}                Set DL MU MIMO Test Modes

    #-------------------------------------- Capture during UE Attach
    Run Keyword If      ${userneed_PCAP}             9568_Capture start    Attach
    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            Critical Step                            CallSetup.UE Register           ue=${idx.ueid}
            Critical Step                            CallSetup.Launch PDU Session    ue=${idx.ueid}    pdu=${idx.pdu}
    END
    Run Keyword If      ${userneed_PCAP}             Run Keywords       9568_Capture Stop     Attach
    ...                                              AND                9568_Capture Stop     cellSetup

    #-------------------------------------- AP UL MU MIMO Test Mode
    Run Keyword IF      ${B4_EI4_TC2}                Set UL MU MIMO Test Modes

    #-------------------------------------- TRAFFIC Start
    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            DdatedLog_10767                          TRAFFIC for UE=${idx.ueid} - pdu number ${idx.pdu}

            FTS_trfxl                                ue=${idx.ueid}     pdu=${idx.pdu}    qfi=1    mbps=${idx.UL_TP}      dir=ul
            FTS_trfxl                                ue=${idx.ueid}     pdu=${idx.pdu}    qfi=1    mbps=${idx.DL_TP}      dir=dl

    END

    #--------------------------------------- TTI Capture
    Run Keyword If       ${userneed_TTI}             9568_TTI start
    ...                                              time=${param.GetTtiTraceTime}    w_convert_pcap_to_excelCsv=False    targpath=${TTI_logdir}
    Traced Sleep                                     1s     traffic TP tti collection
    Run Keyword If       ${userneed_TTI}             9568_TTI stop                   suffix=TTI_underTraffic
    ...                                              time=${param.GetTtiTraceTime}    w_convert_pcap_to_excelCsv=False    targpath=${TTI_logdir}

    #--------------------------------------- BIPL1L2 Capture
    Run Keywords                                     Dated log              1s L1L2 Bip collection
    ...       AND                                    9568_Capture Start     Traff
    ...       AND                                    Sleep                  1s
    ...       AND                                    9568_Capture Stop      Traff

    #PM collection (synchronisation)
    Run Keyword If       ${userneed_PM}              10767_PM_general        ${param.ListOfUeEngaged}
    #...  ELSE                                        10767_Cqi_Param_15-0    ${param.ListOfUeEngaged}

    Run keyword if       ${B3_EI3_TC1} or ${B4_EI4_TC2} or ${B3_EI5_TC4}    9568 TC_1_2 validation    ${param}
    Run keyword if       ${B3_EI5_TC4}               9568 TC4 validation

    # TP check if needed
    # Traced Sleep                                     30s     Time to recover normal traffic TP after CQI waves
    # Step    Run Keyword If    ${userneed_TPcheck}    10767_Throughtput_Check

10767_A_12_EI7_Test_adaptive_PMI_PDSCH_transmissions
    DdatedLog_10767    10767_A_12_EI7_Test_adaptive_PMI_PDSCH_transmissions
    wtsemu.bler_testmode_nr    profile_id=51    dl_bler=200,600,700,800,200,300,400,500
    wtsemu.ue_testmode_set_nr  id=51            testmode=bler       profile_id=51    action=activate
    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            DdatedLog_10767                          TP for UE=${idx.ueid}
            Critical Step                            10767_Tcheck  ue=${idx.ueid}  dir=dl
            ...                                                    expected_data_rate=${idx.DlExpected}
            ...                                                    deviation_in_percent=${param.deviation_in_percent}
            ...                                                    pdu=${idx.pdu}
    END


10767_A_12_EI7_TestCondCheck
    DdatedLog_10767    10767_A_12_EI7_TestCondCheck
    ${file}=                                         catenate                ${LOG_PATH}/${CaptureBIP.name}.pcap
    Dated Log                                        <> 10767_A_12_EI7_TestCondCheck ${file} <>
    ${res}=                                          Critical Step           is_CLSM_parameters_correct   ${file}
    Dated log                                                                is_CLSM_parameters_correct res: ${res}

10767_dmrs_check

    ${file}=                                         catenate                ${LOG_PATH}/${CaptureBIP.name}.pcap
    ${thres}=                                        Convert To Integer      ${param.NRCELL3.thres256QamMcsRedCap1Rx}
    ${res}=                                          run keyword if          ${A_14_EI8_IWK}    Run Keywords
    ...                                                                            Dated Log        <> check_mcs_dmrs_value ${file} ${thres} <>
    ...      AND                                                                   Critical Step    check_mcs_dmrs_value   ${file}    ${thres}
    Dated log                                        check_mcs_dmrs_value res: ${res}

10767_PM_general
    [Documentation]   This KW synchronise CQI activity and PM collection
    ...
    ...                1/ need to collect actual date (minute) to be able to project next PM timeslot will be use for CQI PM counters
    ...                2/ evaluation of the next PM possible slot & time to reach this slot
    ...                3/ ZOI start => Sweng timestamp for PM activity
    ...                4/ evaluation of exact remaining time before begining of CQI process to be run on the PM slot
    ...                   ( Zoiremining time - secondes_a_attendre ) & Sleep of this time
    ...                5/ CQI activity
    ...                6/ PM collect
    [Arguments]    ${ListOfUeEngaged}

    #1/
    ${connection}=                   ConnectToVM
    ${cmd}                           Catenate    date | awk -F " " {'print $5'} |awk -F ":" {' print $2 '}
    ${min_beeing}=                   ssh.execute  ${cmd}     connection=${connection}
    DdatedLog_10767                  ${cmd} aaa ${min_beeing}

    #2/
    @{occurrencies}=                 Create list     0    5    10    15    20    25    30    35    40    45    50    55
    ${occurrence_suivante}           FindNextOccurency    ${min_beeing}    ${occurrencies}
    ${occurrence_suivante}=          Convert To Integer      ${occurrence_suivante}
    ${min_beeing}=                   Convert To Integer      ${min_beeing}
    ${DurationBeforeNextPMslot}      Evaluate    (${occurrence_suivante} - ${min_beeing}) * 60
    Dated Log                        Wait ${DurationBeforeNextPMslot} seconds before next PM slot.

    #3/
    DdatedLog_10767                  PM -->${userneed_PM}
    ${zoi}                           Run Keyword If      ${userneed_PM}      ZOI Start    0    300    60
    ${remainingEndZoi}               ZOI Remaining Sec   ${zoi}

    #4/
    # ${secondes_a_attendre}=          Evaluate    (${remainingEndZoi} - ${DurationBeforeNextPMslot})
    ${secondes_a_attendre}=          Evaluate                      (${remainingEndZoi} - 360)
    Traced Sleep                     ${secondes_a_attendre}s       Time left before 5gnb PM production occurency

    #5/
    10767_Cqi_Param_15-0    ${ListOfUeEngaged}

    #6/
    Run Keyword If       ${userneed_PM}    Run Keywords
    ...                                    Dated log New Line            === Starting collecting PM
    ...  AND                               ZOI Wait End                  zoi=${zoi}
    ...  AND                               10767_PM_check                ${zoi}

FindNextOccurency
    [Documentation]   declaration faite:    @{occurrencies}   0    5    10    15    20    25    30    35    40    45    50    55
    [Arguments]    ${minute_actuelle}    ${occurrencies}

    ${taille}                   Get Length    ${occurrencies}
    Dated Log                   taille ${taille}
    FOR   ${idx}                IN    @{occurrencies}
          DdatedLog_10767       idx ${idx}
          ${idx}                convert to integer   ${idx}
          ${minute_actuelle}    convert to integer   ${minute_actuelle}
          Run Keyword If        ${idx} > ${minute_actuelle}    Return from Keyword    ${idx}
    END

    #other method to try challenge = lower code necessity
    # Run Keyword If    '${occurrencies[${idx}]}' > '${minute_actuelle}'    Return from Keyword    ${occurrencies[${idx}]}
    [Return]    ${idx}

10767_PM_check
    [Arguments]               ${zoi}

    DatedLog    ${zoi}
    # Constraints file
    ${constraints}=           Set Variable    ${param.PMdod}
    DdatedLog_10767           constraints=${constraints}
    # Wait Until Keyword Succeeds    6min    10s    isPMreaddyToBeChecked    ${zoi}   720  #${GP_DEF} + ${PM_AVAIL_DELAY_DEF}
    Run keywords
    ...                          Dated Log        === PM counter directory: ${logsDir}
    ...  AND                     10767_Collect PM Counters File             ${logsDir}
    ...  AND                     KPI Evaluate                               pmFile=${LATEST_FILE}
    ...                                                                     constraintsFile=${constraints}
    ...                                                                     failOnError=${True}
    ...  AND                     PM_Counter_Tput_Check_10767    3    #Cellid 3

isPMreaddyToBeChecked
    [Documentation]    This keyword will help In case we know how many time the activity monitored by PM is long
    ...                Args:  Zoi ref  / how long time the monitored event is
    [Arguments]        ${zoi}    ${zoiPlustime}
    Dated Log       === check if ZOI t0 + ${zoiPlustime} is reached

    #PM synchronisation, need to wait ZOI Remaining Sec  <= ${GP_DEF} + ${PM_AVAIL_DELAY_DEF} befor check
    ${RemainingTime}    ZOI Remaining Sec               ${zoi}
    ${GOpmCheck}        Set Variable if                 '${RemainingTime}' <= '${zoiPlustime}'    ${True}    ${False}
    Dated Log       === GOpmCheck ${GOpmCheck} RemainingTime ${RemainingTime}
    Run keyword if      '${GOpmCheck}' == '${False}'    Fail


10767_Cqi_Param_15-0
    [Documentation]
    ...                              Set only csi_override on ue_id 51  ( 1rx ue )
    [Arguments]                      ${ListOfUeEngaged}
    ${interlevelTime}=               Set Variable    10
    DdatedLog_10767                       <--- Start CQI modification time

    #profile 2 because Recommendation is to create new profiles after ue _registration so that profile ID=1(default) is intact
    wtsemu.csi_override_testmode_nr  profile_id=2
    ...                              cqi=15
    ...                              pmi=0
    ...                              ri=0
    ...                              cqi_mode=fixed
    ...                              pmi_mode=fixed
    ...                              ri_mode=fixed

    FOR     ${idx}     IN            @{ListOfUeEngaged}
        Dated log                    ======================> ue_testmode_set_nr setting prof:2 to UE_id: ${idx.ueid} isRc:${idx.isRc} Rx: ${idx.Rx}
        wtsemu.ue_testmode_set_nr    id=${idx.ueid}    testmode=csi_override    profile_id=2    action=activate
    END


    @{CQIliste}    Create List    14    13    12    11    10    9    8    7    6    5    4    3    2    1    0
    FOR     ${cqi_value}    IN               @{CQIliste}
            Sleep  ${interlevelTime}s
            Dated log                        cqi_value ${cqi_value}
            wtsemu.csi_override_testmode_nr  profile_id=2   cqi=${cqi_value}
    END

    DdatedLog_10767                       <--- Stop CQI modification time
    #back to CQI 15
    Traced Sleep                          ${interlevelTime}    msg=Waiting ${interlevelTime}s to switch back to CQI15
    Dated log                             <--- back to CQI 15
    wtsemu.csi_override_testmode_nr  profile_id=2   cqi=15


10767_Throughtput_Check
    FOR     ${idx}     IN                            @{param.ListOfUeEngaged}
            DdatedLog_10767                          TP for UE=${idx.ueid}
            Critical Step                            10767_Tcheck  ue=${idx.ueid}  dir=dl
            ...                                                    expected_data_rate=${idx.DlExpected}
            ...                                                    deviation_in_percent=${param.deviation_in_percent}
            ...                                                    pdu=${idx.pdu}
            Critical Step                            10767_Tcheck  ue=${idx.ueid}  dir=ul
            ...                                                    expected_data_rate=${idx.UlExpected}
            ...                                                    deviation_in_percent=${param.deviation_in_percent}
            ...                                                    pdu=${idx.pdu}
    END

10767-A_4_EI4_IWK_1RxRedCapUE_5GC001227
    [Arguments]                                                    ${param}
    Init Sequence                                                  ${param}
    Critical Step    10767_Redcap_settings                         ${param}                    3fdd=${True}
    Critical Step    TC 1227 TEST Round Robin                      ${TC_3_Cells_20Mhz}         ${Vendor_Param_RR_414}
    10767_SessionManagment
    Critical Step    10767_5GC001227_ComplementBLER                ueid=1    #ueid=${param.ListOfUeEngaged.ueid}

10767_SR_A_20_IWK4a
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
    10767_SessionManagment
    Critical Step          Foreign_TC_8072_FDD    ${A_1}

#####  KW Land ##########
10767_Foreign_TC_8072_FDD
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
    Critical Step                Decrease SINR TO Trigger TransformPrecoder Enabled       depends=CallSetup.Launch PDU Session    TargetedNoise=-500
    Step                         Captures Stop                                            depends=Captures Start
    ...                          depends=CallSetup.Launch PDU Session
    Step                         ${param.dir} Traffic SA                                  depends=CallSetup.Launch PDU Session
    Critical Step                Check PuschMappingTypeA UL in BIP Traces
    Critical Step                Check transformPrecoder enabled in BIP Traces
    Critical Step                Check dmrs TypeA Position in BIP Traces
    Critical Step                Check Additional DMRS UL in BIP Traces

10767_SessionManagment
    ${alias_epcsim}                      SSH Wait For Connect            ${HOST_EPCSIM}
    Set Suite Variable                   ${alias_epcsim}
    Dated Log                            alias_epcsim sur ssh wait For Connect ${alias_epcsim}

10767_bearer_Register_pdu_traf_dereg
    [Arguments]           ${dl_tput_per_ue}    ${ul_tput_per_ue}
    DatedLog    ${dl_tput_per_ue}
    DatedLog    ${ul_tput_per_ue}

    FOR     ${ue}               IN          @{param.ListOfUeEngaged}
            Dated Log New Line     ** ** Bearer egate campaign on UE_id=${ue.ueid} ** **     deep=${2}
            wtsemu.set_pdu_param    ue=${ue.ueid}    pdu=1    trf_type=internal
            wtsemu.set_pdu_param    ue=${ue.ueid}    pdu=2    trf_type=internal

            wtsemu.ue_register     id=${ue.ueid}
            Sleep    3s
            wtsemu.smf_param       additional_qosflows_to_activate=2,3,4    id=1   #id – identifier of AMF(virtual SMF)
            wtsemu.ue_pdu_session_setup    pdu=1    ue=${ue.ueid}    nwslice=1 gw=1
            Sleep    3s

            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=1    trf_id=1    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=1    trf_id=2    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=2    trf_id=3    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=2    trf_id=4    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=3    trf_id=5    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=3    trf_id=6    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=4    trf_id=7    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=1    qfi=4    trf_id=8    mbps=1    dir=ul    protocol=udp    seconds=3600

            wtsemu.smf_param      additional_qosflows_to_activate=4,5,6    id=1    #id – identifier of AMF(virtual SMF)
            wtsemu.ue_pdu_session_setup    pdu=2    ue=${ue.ueid}    nwslice=1 gw=1
            Sleep    3s

            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=1    trf_id=9     mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=1    trf_id=10    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=2    trf_id=11    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=2    trf_id=12    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=3    trf_id=13    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=3    trf_id=14    mbps=1    dir=ul    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=4    trf_id=15    mbps=1    dir=dl    protocol=udp    seconds=3600
            wtsemu.trf_data_start    ue=${ue.ueid}    pdu=2    qfi=4    trf_id=16    mbps=1    dir=ul    protocol=udp    seconds=3600
    END
    FOR     ${ue}               IN          @{param.ListOfUeEngaged}
            wtsemu.ue_stats_nr                      id=${ue.ueid}    type=pusch    scell=0
            Sleep    3s
            wtsemu.ue_stats_nr                      id=${ue.ueid}    type=pdsch    scell=0
            Sleep    3s
    END
    wtsemu.ue_disp
    Dated Log New Line     ** ** Traffic duration for ${param.TrafficDuration} ** **    deep=${2}
    Sleep                     ${param.TrafficDuration}
    Dated Log              ** ** record on egate_console logs of all UE status ** **    deep=${2}
    wtsemu.ue_disp
    FOR     ${ue}               IN          @{param.ListOfUeEngaged}
            Dated Log     ** ** record on egate_console logs of UE_${ue.ueid} TP ** **    deep=${2}
            wtsemu.ue_stats_nr                      id=${ue.ueid}    type=pusch    scell=0
            wtsemu.ue_stats_nr                      id=${ue.ueid}    type=pdsch    scell=0
            Sleep    3s
            Dated Log     ** ** record on egate_console logs of UE_${ue.ueid} status (ue_disp) ** **    deep=${2}
            wtsemu.ue_disp                          id=${ue.ueid}
            wtsemu.ue_deregister    id=${ue.ueid}     by=ue    ue_deregister_type=switch_off
    END


10767_Register_pdu_traf_dereg
    [Arguments]           ${dl_tput_per_ue}    ${ul_tput_per_ue}
    ${EndrangeII}                                   Evaluate    ${param.nb_ue_SA} + 1
    FOR     ${ue_id}                                IN RANGE    1    ${EndrangeII}
            Dated log                               id ${ueid} is Registering - max ${param.nb_ue_SA} -     deep=${2}
            # wtsemu.ue_register                      id=${ueid}
            # Sleep                                   3s
            # wtsemu.set_pdu_param                    ue=${ueid}    pdu=${ue_id_used_rc}    trf_type=internal
            # wtsemu.ue_pdu_session_setup             pdu=${ue_id_used_rc} gw=1    ue=${ueid}    nwslice=1

            Critical Step                           CallSetup.UE Register                   ue=${ueid}
            Sleep                                   3s
            Critical Step                           CallSetup.Launch PDU Session            ue=${ueid}    pdu=${ue_id_used_rc}
            Sleep                                   3s
            wtsemu.trf_data_start                   ue=${ueid}    pdu=${ue_id_used_rc}    qfi=1    dir=ul    trf_id=20    mbps=${ul_tput_per_ue}
            Sleep                                   3s
            wtsemu.trf_data_start                   ue=${ueid}    pdu=${ue_id_used_rc}    qfi=1    dir=dl    trf_id=1     mbps=${dl_tput_per_ue}
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


9568_SetRadParam
    [Documentation]     Add or Modify the RAD params

    Dated Log New Line   Add RAD params for CB010767-A_14_EI8_IWK
    dated log    -----> field=0x58000f value=${param.rad_58000f}

    ${rad_param_1}=          create dictionary       field=0x58000f    value=${param.rad_58000f}

    ${rad_param_list}=       Create List         ${rad_param_1}

    SetConfig.Set Fields in swconfig DU       param_list=${rad_param_list}


9568_Test Teardown
    [Documentation]    Perform needed actions at the end of a test case

    Dated log New Line                       Test Teardown CB009568_SR_B : start
    Dated log                                ...................................
    Produce Scout Data

    Run Keyword If Test Failed      Set Global Variable    ${save_debug_data}    ${True}

    Run Keyword If Test Failed      Dated log              TEST - I N T E R R U P T I O N -
    Run Keyword If Test Passed      Dated log              TEST - N A T U R A L - E N D -

    9568_CollectConfigfilesUsedForTest

    9568_Alarmslist       End    ${logsDir}
    StringTool.printLineWithTitle              title=TEST_NAME : ${TEST NAME}

    Display diagnosis

    Run Keyword If        ${AutoSaveDebugData} == ${True}    Set Global Variable    ${save_debug_data}    ${True}

    Dated log             save_debug_data : ${save_debug_data}
    Dated log             AutoSaveDebugData : ${AutoSaveDebugData}

    #following to uncomment if you don't want any SosReport / Snapshot collection
    # Set Global Variable             ${save_debug_data}    ${False}

    Run Keyword If        ${BtsLogStarted}                 9568_Stop Btslog      ${logsDir}
    Run Keyword If        ${save_debug_data} == ${True}    9568_LogCollection

    ${cmd}                set variable    cp -p ${tl.core.dir_path}/egate_console.* ${logsDir}
    Dated Log             ${cmd}
    SSH Exec              ${cmd}          alias=${alias_epcsim}

    Dated log             9568_Test Teardown CB009568_SR_B : end

9568_Test Suite Teardown
    [Documentation]          Suite Teardown for CB010767_SR_A.
    # run keyword and ignore error   Restore Orignal Configuration 7487
    # return from Keyword if      '${WITHOUT_TEST_SUITE_TEARDOWN}'=='1'
    # Call to generic test suite Teardown KW
    setup.Suite Teardown
    # CleanBasicFiles    #way to supply SWENG lua files erasement forget

10767_Throughtput adaptation to config 2ueOnSameCellorNot
    [Arguments]     ${twoUEonSameCell}=${False}    ${Total_DL_Tput}=10    ${Total_UL_Tput}=10
    Dated Log  twoUEonSameCell ${twoUEonSameCell} Total_DL_Tput ${Total_DL_Tput} Total_UL_Tput ${Total_UL_Tput}
    ${nbUeperCell}=                     Set Variable If             '${twoUEonSameCell}'=='${True}'    2    1
    ${dl_tput_per_ue}=                  Evaluate                    ${Total_DL_Tput}/${nbUeperCell}
    ${ul_tput_per_ue}=                  Evaluate                    ${Total_UL_Tput}/${nbUeperCell}
    ${dl_tput_int_per_ue}=              Convert To Integer          ${dl_tput_per_ue}
    ${ul_tput_int_per_ue}=              Convert To Integer          ${ul_tput_per_ue}
    Dated Log                           DL throughput per UE is: ${dl_tput_int_per_ue} Mbps
    Dated Log                           UL throughput per UE is: ${ul_tput_int_per_ue} Mbps
    [return]        ${dl_tput_int_per_ue}    ${ul_tput_int_per_ue}

9568_LogCollection
    Dated log   L O G S _ C O L L E C T I O N

    Run Keyword If    not ${isAic}    Run Keywords    Get Snapshot
    ...    AND                                        SSH Exec             mv ${LOG_PATH_bu}/SNAPSHOT_GNB*zip ${logsDir}    alias=${alias_epcsim}

    Run Keyword If    not ${isAic}    Run Keywords    Get Sos Report
    ...    AND                                        SSH Exec             mv %{HOME}/SosReport*tgz ${logsDir}              alias=${alias_epcsim}

    #move pcap file from mirroring
    SSH Exec             mv ${LOG_PATH_bu}/*.pcap ${logsDir}              alias=${alias_epcsim}

    Run Keyword If 	'${AutoSaveDebugData}'
    ...   Run Keyword And Ignore Error
    ...   SSH Exec       cp -rp ${LOG_PATH}/l2stream3 ${logsDir}          alias=${alias_epcsim}

10767_Get TTI traces
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


10767_Set SCF context
    [Documentation]    This module is used for FDD & TDD so need to kept compliant with both Thechnology
    [Arguments]        ${3fdd}=${False}    # this arg is not mandatory so by defauld TDD naming
    DdatedLog_10767    Arguments 3fdd : >${3fdd}<

    Backup Scf

    #New object creation -deltaco-
    ${scf_suite_setup_backup}         OAM Get SCF File          file=SCF_Suite_Setup_Backup.xml
    Set Suite Variable                                          ${scf_suite_setup_backup}
    Dated Log                         SCF backup file = ${scf_suite_setup_backup}

    ${current_scf}         String.Replace string    ${scf_suite_setup_backup}    _Suite_Setup_Backup.xml    ${EMPTY}
    ${updated_scf}         catenate                 SEPARATOR=${EMPTY}    ${current_scf}_RC1rx.xml
    ${std_output}=         Run                      cp ${scf_suite_setup_backup} ${updated_scf}

    Dated Log              SCF Target = ${updated_scf}
    SCF StartSession       scf_file=${updated_scf}

    #WK_1RxRedcapUE_with_CB008983
    run keyword if    ${IWK_CB008983_Cell3_Adaptation}
    ...               Run Keywords
    ...               Dated Log  -- WK_1RxRedcapUE_with_CB008983 AddON --
    ...   AND     S_SCF    dist_name=${dist_name_RMOD_3}    element_name=prodCodePlanned         element_value=${param.NRCELL3.prodCodePlanned}
    ...   AND     S_SCF    dist_name=${dist_name_nrcell3}    element_name=dlMimoMode             element_value=${param.NRCELL3.dlMimoMode}
    ...   AND     S_SCF    dist_name=${dist_name_nrcell3}    element_name=freqBandIndicatorNR    element_value=${param.NRCELL3.freqBandIndicatorNR}
    ...   AND     S_SCF    dist_name=${dist_name_nrcell3}    element_name=gscnOrSsPbchArfcn      element_value=${param.NRCELL3.gscnOrSsPbchArfcn}
    ...   AND     S_SCF    dist_name=${dist_name_nrcell3}    element_name=nrCellType             element_value=${param.NRCELL3.nrCellType}
    ...   AND     S_SCF    dist_name=${dist_name_nrcell3_fdd1}    element_name=nrarfcnDl         element_value=${param.NRCELL3.nrarfcnDl}
    ...   AND     S_SCF    dist_name=${dist_name_nrcell3_fdd1}    element_name=nrarfcnUl         element_value=${param.NRCELL3.nrarfcnUl}


    S_SCF    dist_name=${dist_name_nrcell1}      element_name=nrDefMoPrNsaDN          element_value=${param.NRCELL1.nrDefMoPrNsaDN}
    S_SCF    dist_name=${dist_name_nrcell2}      element_name=nrDefMoPrNsaDN          element_value=${param.NRCELL2.nrDefMoPrNsaDN}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=nrDefMoPrNsaDN          element_value=${param.NRCELL3.nrDefMoPrNsaDN}
    Run Keyword If       not ${3fdd}
    ...      S_SCF    dist_name=${dist_name_nrcell4}       element_name=nrDefMoPrNsaDN    element_value=${param.NRCELL4.nrDefMoPrNsaDN}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=actRedCapUeSupport      element_value=${param.NRCELL3.actRedCapUeSupport}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=maxNumOfRrcSARedCap     element_value=${param.NRCELL3.maxNumOfRrcSARedCap}
    S_SCF    dist_name=${dist_name_nrdb_pdcp1}    element_name=pdcpSNLengthRedCap     element_value=${param.NRBTS.pdcpSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrdb_pdcp2}    element_name=pdcpSNLengthRedCap     element_value=${param.NRBTS.pdcpSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrdb_pdcp3}    element_name=pdcpSNLengthRedCap     element_value=${param.NRBTS.pdcpSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=actRedCapUeSupport      element_value=${param.NRCELL3.actRedCapUeSupport}
    S_SCF    dist_name=${dist_name_nrbts}      element_name=actMeasurementProfile     element_value=${param.NRBTS.actMeasurementProfile}
    S_SCF    dist_name=${dist_name_nrbts}        element_name=actMobilityProfile      element_value=${param.NRBTS.actMobilityProfile}

    #ex 10767_Set SCF context BEARER
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=actUl256Qam             element_value=${param.NRCELL3.actUl256Qam}
    Run Keyword If       not ${3fdd}
    ...       S_SCF    dist_name=${dist_name_nrcell4}       element_name=actUl256Qam    element_value=${param.NRCELL4.actUl256Qam}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=actRedCapUeSupport      element_value=${param.NRCELL3.actRedCapUeSupport}
    Run Keyword If       not ${3fdd}    S_SCF    dist_name=${dist_name_nrcell4}       element_name=actRedCapUeSupport
    ...                                                                               element_value=${param.NRCELL4.actRedCapUeSupport}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=maxNumOfRrcSARedCap     element_value=${param.NRCELL3.maxNumOfRrcSARedCap}
    Run Keyword If       not ${3fdd}    S_SCF    dist_name=${dist_name_nrcell4}       element_name=maxNumOfRrcSARedCap
    ...                                                                               element_value=${param.NRCELL4.maxNumOfRrcSARedCap}
    S_SCF    dist_name=${dist_name_nrdb_pdcp1}    element_name=pdcpSNLengthRedCap     element_value=${param.NRBTS.pdcpSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrdb_pdcp2}    element_name=pdcpSNLengthRedCap     element_value=${param.NRBTS.pdcpSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrdb_pdcp3}    element_name=pdcpSNLengthRedCap     element_value=${param.NRBTS.pdcpSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrdb_RLC_AM1}                                      element_name=rlcAMDrbSNLengthRedCap
    ...                                                                               element_value=${param.NRBTS.rlcAMDrbSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrdb_RLC_AM2}                                      element_name=rlcAMDrbSNLengthRedCap
    ...                                                                               element_value=${param.NRBTS.rlcAMDrbSNLengthRedCap}
    S_SCF    dist_name=${dist_name_nrbts}    element_name=actEnhancedNgRanSupport     element_value=${True}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=actNonVoNRGbrService    element_value=${True}
    Run Keyword If       not ${3fdd}    S_SCF    dist_name=${dist_name_nrcell4}       element_name=actNonVoNRGbrService
    ...                                                                               element_value=${True}
    S_SCF    dist_name=${dist_name_nrcell3}      element_name=actVoNR                 element_value=${True}
    Run Keyword If       not ${3fdd}    S_SCF    dist_name=${dist_name_nrcell4}       element_name=actVoNR
    ...                                                                               element_value=${True}
    #FIN block ex 10767_Set SCF context BEARER

    #cellBarredRedCap NRBTS.NRCELL.cellBarredRedCap
    SCF Add element	     dist_name=${dist_name_nrcell3}      element_name=cellBarredRedCap       element_value=${param.NRCELL3.cellBarredRedCap}
    Run Keyword If       not ${3fdd}    SCF Add element	     dist_name=${dist_name_nrcell4}      element_name=cellBarredRedCap
    ...                                                                                          element_value=${param.NRCELL4.cellBarredRedCap}
    #Adds whole managedObject to loaded SCF
    S_ADD    dist_name=${dist_name_NRMOPR_NSA1}      class_name=com.nokia.srbts.nrbts:NRMOPR_NSA    version=${None}

    #enum
    #https://mind.emea.nsn-net.net/nrbts.nrmopr_nsa.a3measenabled?search=a3MeasEnabled&selectedCategory=129&selectedSystemRelease=1292
    S_SCF    dist_name=${dist_name_NRMOPR_NSA1}
    ...      element_name=a1MeashoEnabled
    ...      element_value=${param.NRMOPR_NSA1.a1MeashoEnabled}
    ...      scope=Classical
    S_SCF    dist_name=${dist_name_NRMOPR_NSA1}
    ...      element_name=a2MeashoEnabled
    ...      element_value=${param.NRMOPR_NSA1.a2MeashoEnabled}
    ...      scope=Classical
    S_SCF    dist_name=${dist_name_NRMOPR_NSA1}
    ...      element_name=a3MeasEnabled
    ...      element_value=${param.NRMOPR_NSA1.a3MeasEnabled}
    ...      scope=Classical
    S_SCF    dist_name=${dist_name_NRMOPR_NSA1}
    ...      element_name=a5MeasEnabled
    ...      element_value=${param.NRMOPR_NSA1.a5MeasEnabled}
    ...      scope=Classical

    #PM 10767
    S_SCF    dist_name=${dist_name_NRPMRNL_1}
    ...      element_name=miNrDlSignalQuality
    ...      element_value=${param.miNrDlSignalQuality}

    # #SPECIAL CELL 5Mhz  [A-05][ET L2] "DL BLER in a cell BW=5Mhz config used with at least 2 UEs"
    # S_SCF    dist_name=${dist_name_nrcell4}        element_name=p0NominalPucchF1F3
    # ...                      element_value=-94
    #finalement mis dans le SCF custom_config !!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    run keyword if    ${A_14_EI8_IWK}
    ...            Run Keywords
    ...            Dated Log  -- WK_1RxRedcapUE_with_A_14_EI8_IWK AddON --
    ...   AND      S_SCF
    ...            dist_name=${dist_name_nrcell3}    element_name=actDlDataDmrsFdm        element_value=${param.NRCELL3.actDlDataDmrsFdm}
    ...   AND      S_SCF
    ...            dist_name=${dist_name_nrcell3}    element_name=redCap1RxUesEnabled     element_value=${param.NRCELL3.redCap1RxUesEnabled}
    ...   AND      S_SCF
    ...            dist_name=${dist_name_nrcell3}    element_name=thres256QamMcsRedCap1Rx     element_value=${param.NRCELL3.thres256QamMcsRedCap1Rx}

    run keyword if    ${A_12_EI7_CL} or ${A_13_EI7_OL}    A_12_EI7_CL_OL

    SCF StopSession                   scf_file=${updated_scf}
    Critical Step                     OAM Perform Full Commissioning    scf_file=${updated_scf}
    OAM wait available
    Dated Log                         xxx Full Commissioning D O N E xxx

    OAM Get SCF Files      #this will help to stay with actual SCF level

A_12_EI7_CL_OL
    Dated Log  -- A_12_EI7_CL_OL --
    S_ADD    dist_name=${dist_name_RMOD_3_ANT3}    class_name=com.nokia.srbts.eqm:ANTL    version=${None}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT3}    element_name=antPortId    element_value=${param.NRCELL3.ANTL3.antPortId}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT3}    element_name=antennaPathDelayDL    element_value=${param.NRCELL3.ANTL3.antennaPathDelayDL}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT3}    element_name=antennaPathDelayUL    element_value=${param.NRCELL3.ANTL3.antennaPathDelayUL}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT3}    element_name=cwaThreshold    element_value=${param.NRCELL3.ANTL3.cwaThreshold}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT3}    element_name=totalLoss    element_value=${param.NRCELL3.ANTL3.totalLoss}

    S_ADD    dist_name=${dist_name_RMOD_3_ANT4}    class_name=com.nokia.srbts.eqm:ANTL    version=${None}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT4}    element_name=antPortId    element_value=${param.NRCELL3.ANTL4.antPortId}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT4}    element_name=antennaPathDelayDL    element_value=${param.NRCELL3.ANTL4.antennaPathDelayDL}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT4}    element_name=antennaPathDelayUL    element_value=${param.NRCELL3.ANTL4.antennaPathDelayUL}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT4}    element_name=cwaThreshold    element_value=${param.NRCELL3.ANTL4.cwaThreshold}
    S_SCF    dist_name=${dist_name_RMOD_3_ANT4}    element_name=totalLoss    element_value=${param.NRCELL3.ANTL4.totalLoss}

    S_ADD    dist_name=${dist_name_RMOD_4_ANT3}    class_name=com.nokia.srbts.eqm:ANTL    version=${None}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT3}    element_name=antPortId    element_value=${param.NRCELL3.ANTL3.antPortId}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT3}    element_name=antennaPathDelayDL    element_value=${param.NRCELL3.ANTL3.antennaPathDelayDL}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT3}    element_name=antennaPathDelayUL    element_value=${param.NRCELL3.ANTL3.antennaPathDelayUL}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT3}    element_name=cwaThreshold    element_value=${param.NRCELL3.ANTL3.cwaThreshold}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT3}    element_name=totalLoss    element_value=${param.NRCELL3.ANTL3.totalLoss}

    S_ADD    dist_name=${dist_name_RMOD_4_ANT4}    class_name=com.nokia.srbts.eqm:ANTL    version=${None}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT4}    element_name=antPortId    element_value=${param.NRCELL3.ANTL4.antPortId}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT4}    element_name=antennaPathDelayDL    element_value=${param.NRCELL3.ANTL4.antennaPathDelayDL}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT4}    element_name=antennaPathDelayUL    element_value=${param.NRCELL3.ANTL4.antennaPathDelayUL}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT4}    element_name=cwaThreshold    element_value=${param.NRCELL3.ANTL4.cwaThreshold}
    S_SCF    dist_name=${dist_name_RMOD_4_ANT4}    element_name=totalLoss    element_value=${param.NRCELL3.ANTL4.totalLoss}

    ${rac}    Set Variable    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-
    S_ADD    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-5    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-5    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-3
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-5    element_name=direction    element_value=TX

    S_ADD    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-6    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-6    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-3
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-6    element_name=direction    element_value=RX

    S_ADD    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-7    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-7    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-4
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-7    element_name=direction    element_value=TX

    S_ADD    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-8    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-8    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-3/ANTL-4
    S_SCF    dist_name=${rac}3/CHANNELGROUP-1/CHANNEL-8    element_name=direction    element_value=RX

    S_ADD    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-5    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-5    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-5    element_name=direction    element_value=TX

    S_ADD    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-6    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-6    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-3
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-6    element_name=direction    element_value=RX

    S_ADD    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-7    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-7    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-7    element_name=direction    element_value=TX

    S_ADD    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-8    class_name=com.nokia.srbts.mnl:CHANNEL    version=${None}
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-8    element_name=antlDN    element_value=MRBTS-1/EQM-1/APEQM-1/RMOD-4/ANTL-4
    S_SCF    dist_name=${rac}4/CHANNELGROUP-1/CHANNEL-8    element_name=direction    element_value=RX

    run keyword if    ${A_12_EI7_CL}    run keywords
    ...               S_SCF    dist_name=${dist_name_nrcell3}    element_name=dlMimoMode    element_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...  AND          S_SCF    dist_name=${dist_name_nrcell4}    element_name=dlMimoMode    element_value=4x4 or 4x2 Closed Loop Spatial Multiplexing
    ...  ELSE         run keywords
    ...               S_SCF    dist_name=${dist_name_nrcell3}    element_name=dlMimoMode    element_value=4x4 or 4x2 Open Loop Spatial Multiplexing
    ...  AND          S_SCF    dist_name=${dist_name_nrcell4}    element_name=dlMimoMode    element_value=4x4 or 4x2 Open Loop Spatial Multiplexing
    S_SCF    dist_name=${dist_name_nrcell3}    element_name=nrCellType    element_value=4DL4UL
    S_SCF    dist_name=${dist_name_nrcell4}    element_name=nrCellType    element_value=4DL4UL

S_SCF
    [Arguments]         ${dist_name}    ${element_name}    ${element_value}    ${scope}=None
    Dated Log           ${dist_name}/${element_name} - ${element_value}
    SCF Set element     dist_name=${dist_name}    element_name=${element_name}    element_value=${element_value}    scope=${scope}

S_ADD
    [Arguments]         ${dist_name}    ${class_name}    ${version}
    Dated Log           Creation --> ${dist_name} ... ${class_name}
    SCF Add object      dist_name=${dist_name}    class_name=${class_name}    version=${version}


10767_ScfDicConstitution
    [Documentation]  done to bypass "Run keywords" above as first text after it is a variable
    [Arguments]    ${parameter}=nrarfcn    ${dist_name}=dist_name    ${value}=nrarfcn

    Dated Log                       *** 10767_ScfDicConstitution
    &{unitaryDic}      Create Dictionary    parameter=${parameter}    dist_name=${dist_name}    value=${value}
    APPEND TO LIST    ${modify_param}    ${unitaryDic}


9568_Create Test Suite Folder
    [Documentation]    9568 Create test case folder

    ${timeStamp}     get current date       result_format=%Y%m%d_%H%M%S
    # ${timeStamp}=    Remove String    ${timeStamp.replace(' ','-')}

    ${testCase}    Replace String    ${TEST_NAME[0:30]}    ${SPACE}    _
    ${testCase}    Replace String    ${testCase}    .    _
    ${testCase}    Remove String     ${testCase}    [1]
    ${testCase}    Remove String     ${testCase}    [1.0]
    ${testCase}    Remove String     ${testCase}    [2.0]
    ${testCase}    Remove String     ${testCase}    [
    ${testCase}    Remove String     ${testCase}    ]

    Set Suite Variable    ${testSuiteDir}    ${OUTPUT DIR}/Logs/${testCase}${timeStamp}

    create directory      ${testSuiteDir}

    Set Suite Variable    ${ConfigDir}        ${testSuiteDir}/Config_${timeStamp}
    Create Directory      ${ConfigDir}
    Set Suite Variable    ${logsDir}          ${testSuiteDir}/logs
    Create Directory      ${logsDir}
    Run Keyword If        ${VMmonitoring}     Run keywords
    ...                                       Set Global Variable   ${MoniDir}          ${testSuiteDir}/MONITORING
    ...                   AND                 Create Directory      ${MoniDir}

10767_Backup Scf
    [Documentation]                 Save the current SCF
    [Arguments]    ${dir}=${LOG_PATH}
    ${timeStamp}       get current date     result_format=%Y%m%d_%H%M%S
    # ${timeStamp}=      Remove String    ${timeStamp.replace(' ','-')}
    ${g_backup_scf}    OAM Get SCF File    dir=${dir}    file=SCF_ofTheTest_${timeStamp}.xml
    Set Suite Variable    ${g_backup_scf}
    Dated Log    SCF backup file = ${g_backup_scf}
    ${g_backup_scf_cu}    Run Keyword If    ${isAic}    OAM Get Cu SCF File    dir=${dir}    file=SCF_ofTheTest_cu_${timeStamp}.xml
    Run Keyword If    ${isAic}    Run Keywords    Set Suite Variable    ${g_backup_scf_cu}
    ...    AND    Dated Log    SCF cu backup file = ${g_backup_scf_cu}

9568_CollectConfigfilesUsedForTest
    [Documentation]                 Save current scf/iphy/swconfig/basic files used for the test in ${testSuiteDir}
    Dated Log                       *** CollectConfigfilesUsedForTest
    10767_Backup Scf      ${ConfigDir}
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

9568_Init Trace color
    ${consTraceColor}               Evaluate                    "${CYAN}"
    ${consTraceColorRed}            Evaluate                    "${RED}"
    ${defColor}                     Evaluate                    "${NORMAL}"
    Set Suite Variable              ${consTraceColor}
    Set Suite Variable              ${consTraceColorRed}
    Set Suite Variable              ${defColor}


# Attach Traffic corner #######################################################################################
10767_Tcheck
    [Documentation]    This is the Tcheck Traffic check mechanisum for 1 ue
    ...                is on ${deviation_in_percent} range 5% as default value
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${trf_id}=1    ${dir}=dl
    ...            ${expected_data_rate}=5    ${deviation_in_percent}=5

    Dated log  Arg: ue:${ue} pdu:${pdu} qfi:${qfi} tref_id:${trf_id} dir:${dir} expected:${expected_data_rate} deviation:${deviation_in_percent}

    ${type}=    Set Variable if    "${dir}" == "dl"    PDSCH    PUSCH
    ${egty}=    Set Variable if    "${dir}" == "dl"    pdsch    pusch
    wtsemu.ue_stats_nr    id=${ue}    type=${egty}    scell=0
    CallSetup.Flush Egate Console Buffer
    ${expected}    catenate    NR ${type} Throughput
    ${LynxStatus_XL}    wtsemu.read_wtsemu_output_until    expected=${expected}    timeout=30
    Dated log  Arg: ue:${ue} Lynx ${dir}+++ ${LynxStatus_XL}

    wtsemu.bearer_stats_clear       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}

    #${average_out}=    UteWts.Get Average Traffic Rate    ue=${ue}    pdu=${pdu}    qfi=${qfi}    trf_id=${trf_id}    dir=${dir}
    sleep   15s    #to let Berear_stat buffer collect again
    wtsemu.Bearer Stats             ue=${ue}
    ...                             dir=${dir}
    ...                             qfi=${qfi}
    ...                             pdu=${pdu}

    CallSetup.Flush Egate Console Buffer
    ${status}    ${output}     Run Keyword And Ignore Error            wtsemu.read_wtsemu_output_until
    ...                        expected=Average packet interval        timeout=40
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
9568_Capture_session_initiating
    Dated Log New Line              * * * install Mirroring scripts in GNB

    ${CaptureCPRT_setup}            Capture CPRT Set Upon Config     airscale=${GNB_DU}
    ${CaptureCPRT_setup.filter}     Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_setup}             withTN=False             suffix=_setup

    ${CaptureCore_setup}    Run Keyword If    ${isAic}
    ...                                         Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...                                 ELSE    Capture CORE Set Upon Config    airscale=${GNB_DU}
    Capture Init                    ${CaptureCore_setup}             withTN=False             suffix=_setup

    ${CaptureBIP}                   Capture L1L2 Set Upon Config    airscale=${GNB_DU}       #isMirror=${True}
    Capture Init                    ${CaptureBIP}                   withTN=False

    Set Suite Variable              ${CaptureCPRT_setup}
    Set Suite Variable              ${CaptureCore_setup}
    Set Suite Variable              ${CaptureBIP}

    ${CaptureCPRT_attach}           Capture CPRT Set Upon Config     airscale=${GNB_DU}
    ${CaptureCPRT_attach.filter}    Get Filter For SCTP
    Capture Init                    ${CaptureCPRT_attach}            withTN=False              suffix=_attach_

    ${CaptureCore_attach}    Run Keyword If    ${isAic}
    ...                                          Capture CORE Set Upon Config    airscale=${GNB_CU}
    ...                                  ELSE    Capture CORE Set Upon Config    airscale=${GNB_DU}
    Capture Init                    ${CaptureCore_attach}            withTN=False              suffix=_attach_

    Set Suite Variable              ${CaptureCPRT_attach}
    Set Suite Variable              ${CaptureCore_attach}


9568_Stop Btslog
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

10767_Collect PM Counters File
    [Documentation]   KW to get counters and store in specific directory with day date
    ...               orig= CNI-68516/resources/robot/CNI-68516_0920_Resources.robot
    [Arguments]    ${target_dir}=${LOG_PATH}
    Dated Log                       *** 10767_Collect PM Counters File
    ${date}                          Get Current Date
    ${date_in_dir_name}              Convert Date         ${date}     result_format=%d%m%Y_%H%M
    ${log_path_pm}                   Set Variable         ${target_dir}/PM_${date_in_dir_name}
    Dated Log              The PM counters file collected from gnb will be stored under : ${log_path_pm}
    ${pm_latest}                    Counters.Collect PM files from BTS    ${log_path_pm}
    set Suite Variable              ${LATEST_FILE}       ${pm_latest}
    set Suite Variable              ${log_path_pm}
    Dated Log     Latest pm counters file : ${LATEST_FILE}

PM_Counter_Tput_Check_10767
    [Documentation]   Check the throughput in DL 4TX with RI 3 is above a min value
    ...               orig= CNI-68516/resources/robot/CNI-68516_0920_Resources.robot
    [Arguments]       ${CellID}=1

                                                                   #M55309C01001 => DL MAC SDU volume transmitted on DTCH
                                                                   #M55309C00001 => Duration of the measurement period for the MAC SDU report

                                                                   #M55301C10001 => PDSCH transmissions using 4TX transmission with rank 1

    ${vol}=           Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55309C01001    ${CellID}
    ${dur}=           Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55309C00001    ${CellID}
    ${pdsch4TXR1}=    Counters.Retrieve Latest Single Counter Value From Pm File with CellID    ${LATEST_FILE}    M55301C10001    ${CellID}
    Dated Log         +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    Dated Log           vol ...... / M55309C01001 / DL MAC SDU volume transmitted on DTCH ..........................: ${vol} Bytes
    Dated Log           dur ...... / M55309C00001 / Duration of the measurement period for the MAC SDU report ......: ${dur} ms
    Dated Log           pdsch4TXR1 / M55301C10001 / PDSCH transmissions using 4TX transmission with rank 1 .........: ${pdsch4TXR1} Grants
    Dated Log         +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	${tput}               Evaluate    8 * ${vol} / (1000 * ${dur})
    ${nb_pdsch4TXR1_byS}    Evaluate    8 * ${pdsch4TXR1} / (1000 * ${dur})

    Dated Log           tput .......................................................................................: ${tput} Mb/s
    Dated Log           nb_pdsch4TXR1_byS ..........................................................................: ${nb_pdsch4TXR1_byS} NbGrant/s
    Dated Log         +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


10767_trfdl
    [Documentation]    As loop in loop is not possible in Robot this is
    ...                a sub KW of Traffic KW in charge to start traffic
    ...                Huge traffic is possible up to  3500 Mbps In DL :
    ...                175 Mbps maximum is possible by trf_id, egate limit to 20 Trf_id, Maximum traffic rate
    ...                is so theoricaly 175 (max Mbps by trf_id) x nb max trf_id (20) 3500 Mbps on DL
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${mbps}=22

    Dated log   Args_trf: ue ${ue} pdu ${pdu} qfi ${qfi} mbps ${mbps}
    ${trfid}     set variable    1
    FOR    ${i}    IN RANGE    9999999
            # Dated log  mbps ${mbps}
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

10767_DOD
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

10767_EgateEncaps
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

10767_5GC001227_ComplementBLER
    [Documentation]          Egate command as complement to check Bler on traffic
    ...                      Egate commands are stored in a list formated as below:
    ...                      egate_command  parameterofpreviousCommand egate_command  parameterofpreviousCommand and so one
    ...                      for egate command without parameter please use ${space}

    [Arguments]           ${ueid}=1
    Dated Log             ======> ueid=${ueid}
    @{complement}         Create List
    ...                             ue_stats_nr            id=${ueid} type=pdsch scell=0
    ...                             ue_stats_nr            id=${ueid} type=pusch scell=0
    ...                             bler_testmode_nr       profile_id=3 target_mcs=21 num_dl_pkts=2000
    ...                             bler_testmode_nr       profile_id=4 target_mcs=25 num_dl_pkts=2000
    ...                             ue_testmode_set_nr     id=${ueid} scell=0 testmode=bler profile_id=3 action=activate
    ...                             ue_testmode_set_nr     id=${ueid} scell=0 testmode=bler profile_id=3 action=deactivate
    ...                             ue_testmode_set_nr     id=${ueid} scell=0 testmode=bler profile_id=4 action=activate
    ...                             ue_stats_nr            id=${ueid} type=pdsch scell=0
    ...                             ue_stats_nr            id=${ueid} type=pusch scell=0
    ...                             ue_disp                ${space}
    ...                             ue_stats_nr            id=${ueid} type=pdsch scell=0
    ...                             ue_stats_nr            id=${ueid} type=pusch scell=0
    # ...                             sim_log_set flush      ${space}

    ${len}=                   Get Length    ${complement}
    ${LenghtcomplementMoins1}=      Evaluate         ${len}-1
    FOR    ${index}           IN RANGE    0    ${LenghtcomplementMoins1}   2
           ${indexPlus1}=     Evaluate         ${index}+1
           ${egate_command}=  Set Variable     @{complement}[${index}]
           ${egate_param}=    Set Variable     @{complement}[${indexPlus1}]

           Run Keyword If     '${egate_command}'=='sim_log_set flush'    Sleep    60s
           Dated Log          send on egate: ${egate_command} ${egate_param}
           10767_EgateEncaps    ${egate_command}    ${egate_param}
           Sleep              2s
    END

    #Check if mobile still alive
    wtsemu.ue_disp     id=${ueid}
    ${output}   wtsemu.read_wtsemu_output_until_re        expected=PDN    timeout=10
    ${output}   Get Lines Matching Regexp    ${output}    ACTIVE    partial_match=${TRUE}
    Log to Console    ${output}
	Log to Console    UE: ${ueid} moved to RRC Active state

10767_erase_eventual_basic_wts_step2
    [Documentation]          This KW help to erase evental basic_wts_step2.* file from previous test
    ...

    # ${cmd}=             set variable             rm -f ${WTS_CFG_LOCAL_PATH}/basic*step2.modified.*;rm -rf /tmp/ute/  #lie WtsCfgConfig.robot
    ${cmd}=             set variable             rm -f /opt/iphy/latest/basic*step2.modified.*;rm -rf /tmp/ute/
    Dated Log           command sent to Epcsim : ${cmd}
    SSH Exec            command=${cmd}           alias=${alias_epcsim}

FTS_trfxl
    [Documentation]    As loop in loop is not possible in Robot this is
    ...                a sub KW of Traffic KW in charge to start traffic
    ...                Huge traffic is possible up to  3500 Mbps In DL :
    ...                175 Mbps maximum is possible by trf_id, egate limit to 20 Trf_id, Maximum traffic rate
    ...                is so theoricaly 175 (max Mbps by trf_id) x nb max trf_id (20) 3500 Mbps on DL
    ...                record last trfid used
    [Arguments]    ${ue}=1    ${pdu}=1    ${qfi}=1    ${mbps}=22    ${dir}=dl
    DdatedLog_10767  Arguments ue:${ue} pdu:${pdu} qfi:${qfi} mbps:${mbps} dir:${dir}

    Dated log   Args_trf: ue ${ue} pdu ${pdu} qfi ${qfi} mbps ${mbps}
    ${trfid}     set variable    1
    FOR    ${i}    IN RANGE    9999999
            # Dated log  mbps ${mbps}
            Dated log  trf_id ${trfid}
            ${complement}          Evaluate                ${mbps} - 175    #175 is the maximum DL TP by trf_id
            #Dated log  complement ${complement}
            Run Keyword If         ${complement}>0 and ${mbps}>=175
                ...                                        wtsemu.trf_data_start       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}
                ...                                                                    trf_id=${trfid}    mbps=175
                ...     ELSE IF    ${mbps}>0 and ${mbps}<=175
                ...                                        wtsemu.trf_data_start       ue=${ue}    pdu=${pdu}    qfi=${qfi}    dir=${dir}
                ...                                                                    trf_id=${trfid}    mbps=${mbps}
                ...     ELSE                               Exit For Loop
            ${mbps}     set variable    ${complement}
            ${trfid}   Evaluate        ${trfid} + 1
            Run Keyword If    ${trfid} > 19    Exit For Loop       #Trf_id max = 20

            sleep   2s   #to no let start traffic too quickly
    END
    # A REVOIR LES TRFID
    # ${param.ue_rc.Last_trfid_used}     set variable     ${trfid}
    # Set Suite Variable    ${param.ue_rc.Last_trfid_used}

ConnectToVM
    [Documentation]   :Author: Soenke Kullberg
    ...     Setup ssh connection to Test PC and returns connection handle/alias
    ...
    ...     **Note:** KW sould be called without arguments
    ...
    ...     :param alias: (optional) alias used for ssh connection
    ...
    ...     :return alias: for ssh connection to Testpc
    ...
    ...     **Example:**
    ...
    ...     | ${tpc_alias}=  ttitrace.Connect to TestPC
    ...     | ssh.execute  command=ls  connection=${tpc_alias}
    ...
    [Arguments]    ${alias}=ssh-test-pc
    ssh.Connect_to      hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...                 username=${tl.test_pc.default_ssh_connection_details.username}
    ...                 password=${tl.test_pc.default_ssh_connection_details.password}
    ...                 alias=${alias}
    [Return]    ${alias}


DdatedLog_10767
    [Documentation]    This KW will help on non regression to see deeper informations
    ...                ${debugArg} need to be set to True at the begining of this file
    [Arguments]        ${SomethinToTrace}=none

    Run Keyword If     ${debugArg}    Dated Log   Debug wwwwwwwwww: ${SomethinToTrace}
