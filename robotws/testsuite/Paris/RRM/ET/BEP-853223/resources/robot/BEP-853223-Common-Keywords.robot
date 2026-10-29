*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of BEP 853223
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 14-01-2026
...               Modified Date               : 14-01-2026
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2602    ying.yw.wu@nokia.com              Creation
Library           OperatingSystem
Library           String
Library           BuiltIn
Library           ute_wtssim           WITH NAME    wts
Library           taf.wts.runner    WITH NAME    wtsemu
Library           taf.config.scf    WITH NAME    scf
Library           taf.sbts.oam.coam.admin           WITH NAME   sbts_coam
Library           ../../../../../resources/SWENG/python/CoamParameter.py      WITH NAME   coam_parameter
Library           ../../../../../resources/SWENG/python/ScfVendorOperations.py
Library           taf.ccs.aashell

Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/GnbXmlTools.robot
Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/Capture.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/WtsCfgConfig.robot
Resource          ../../../../../resources/SWENG/robot/WtsXmlConfig.robot
Resource          ../../../../../resources/SWENG/robot/PacketSearch.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/KPIs.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Syslogs.robot


*** Variables ***

# RAD parameters definition frrom CB012605
${rdBbPoolTddFr1Ecpri72e}                  0x42009D
${rdFakeUeSchedulingEnable}                0x5801CB
${enabledNewCeFrameworkFlagInDu}           0x8000A6
${rdCprtDebugLog}                          0x590072
${rdL2psFeatureDebugLevel}                 0x58057A
${rdPoolingDebugLog}                       0x58057C

# RAD param for CB013527
${rdTputPoolingEcpri72eAllowed}            0x4200B1

# FB2522 : RAD param CB015330 for testing which will be activated by default in 26R1
${rdTputPoolingUlEnhance}                  0x58061B

# RAD param for CB013305 & CB013932
${rdK2min}                                 0x58012D
${rdAvgMaxSizeDlCs1BiSlotThreshold}        0x5809B5
${rdBeamUsageDebugLog}                     0x580581
# RAD param for BEP 853223
${rdMuIrcCorr}                             0x5805A3
${rdTdPhaseTputPooling}                    0x580798
${rdTputPoolingDebugging}                  0x580581
# set rdActivatePmCounterMonitoring to tti counter capture
${rdActivatePmCounterMonitoring}           0x5806B1
# set rdMonitoredPmCounterId1 to pmCntBlockedPuschUeCount
${rdMonitoredPmCounterId1}                 0x5806B2
#ul tput pooling enh CB015330 (72A only, half board and full board abip)
${rdTddInstTputPoolingUlEnhEnable}         0x58061B
${rdCB013199}                              0x420062

#Common custom config settings for ecpri72e in vendor file
# Fronthaul interface resolution for PUSCH IQ data in eCPRI 7-2e UL split
${xEc_val}                            14
# Fronthaul interface resolution for PUSCH Normalization Factor in eCPRI 7-2e UL split
# ${betaEc_val}                         13

@{Custom_Vendor_For_Airphone}
...                     NRBTS.xEc=${xEc_val}
# ...                     NRBTS.betaEc=${betaEc_val}



@{Custom_Vendor_For_Airphone-TputLimit-UL}
...                     NRBTS.xEc=${xEc_val}
# ...                     NRBTS.betaEc=${betaEc_val}
...                     NRBTS.bbPoolCapacity.maxPuschTpSlotL1Pool=1250
...                     NRBTS.bbPoolCapacity.maxPuschTpSlotL2Pool=1250

@{Rad_Param_72e}
...                     ${rdBbPoolTddFr1Ecpri72e}=31
...                     ${rdFakeUeSchedulingEnable}=0
...                     ${enabledNewCeFrameworkFlagInDu}=0
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
# ...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdK2min}=2
...                     ${rdAvgMaxSizeDlCs1BiSlotThreshold}=4000
# ...                     ${rdBeamUsageDebugLog}=8
...                     ${rdMuIrcCorr}=1
...                     ${rdTdPhaseTputPooling}=1
...                     ${rdTputPoolingDebugging}=0x10000

@{Rad_Param_72a}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
# ...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdK2min}=2
...                     ${rdAvgMaxSizeDlCs1BiSlotThreshold}=4000
# ...                     ${rdBeamUsageDebugLog}=8
...                     ${rdMuIrcCorr}=1
...                     ${rdTdPhaseTputPooling}=1
...                     ${rdTputPoolingDebugging}=0x10000
...                     ${rdTddInstTputPoolingUlEnhEnable}=1

@{Rad_Param_72a_Off}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdK2min}=2
...                     ${rdAvgMaxSizeDlCs1BiSlotThreshold}=4000
# ...                     ${rdBeamUsageDebugLog}=8
...                     ${rdMuIrcCorr}=1
...                     ${rdTdPhaseTputPooling}=0
# ...                     ${rdTddInstTputPoolingUlEnhEnable}=1
...                     ${rdTputPoolingDebugging}=0x10000


@{Rad_Param_72a_Debug}
...                     ${rdCprtDebugLog}=1
...                     ${rdL2psFeatureDebugLevel}=4
...                     ${rdPoolingDebugLog}=0x3800
...                     ${rdK2min}=2
...                     ${rdAvgMaxSizeDlCs1BiSlotThreshold}=4000
...                     ${rdBeamUsageDebugLog}=8
...                     ${rdMuIrcCorr}=1
...                     ${rdTdPhaseTputPooling}=1
...                     ${rdTputPoolingDebugging}=0x10000
...                     ${rdActivatePmCounterMonitoring}=1
...                     ${rdMonitoredPmCounterId1}=0xD80CD305
*** Keywords ***

BEP 853223 Setup With Custom Config 72E
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...                  vendorParam: list of vendor parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}    ${IPHY}=${EMPTY}
    ...                      ${rdParam}=${EMPTY}    ${vendorParam}=${EMPTY}

    Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    ...      iphy=${IPHY}
    ...      rad_params=@{rdParam}
    ...      vendor_params=@{vendorParam}


BEP 853223 Setup With Custom Config 72A
    [Documentation]
    ...     Actions:     Apply customized configuration then launch cell setup.
    ...     Parameters:  SCF: customized SCF
    ...                  CFG: customized basic CFG file
    ...                  IPHY: airphone iphy file
    ...                  rdParam: list of RAD parameters
    ...     Return:      None
    [Arguments]              ${SCF}    ${CFG}=${EMPTY}    ${IPHY}=${EMPTY}
    ...                      ${rdParam}=${EMPTY}

    Apply Custom Config
    ...      scfc=${SCF}
    ...      cfg=${CFG}
    ...      iphy=${IPHY}
    ...      rad_params=@{rdParam}

CB013932 IWK Set RAD Parameters on Airphone
    [Documentation]
    ...     Conditions:     it needs no conditions
    ...     Actions:        it adds or modifies the RAD parameters to activate functions. It will be replaced later by NIDD
    ...     Checks:         it needs no checks
    ...     Verdict:        the setting is passed
    [Arguments]             ${rad_0x70735_val}=1    ${rad_0x70737_val}=0x323200
    Dated Log New Line                          ===> set RAD parameters on Airphone with rad_0x70735_val= ${rad_0x70735_val}
    Dated Log New Line                          ===> set RAD parameters on Airphone with rad_0x70737_val= ${rad_0x70737_val}
    Dated Log                                   ===> SYSLOG output severity prints (0=disable 1=debug 2=info 3=warning 4=error 5=vip 6=disable)
    #
    ${rad_0x70735}=         Create Dictionary    field=0x70735    value=${rad_0x70735_val}
    ${rad_0x70737}=         Create Dictionary    field=0x70737    value=${rad_0x70737_val}

    #
    ${list_rad_param}=      Create List    ${rad_0x70735}   ${rad_0x70737}
    Dated Log                                   ===> RAD params list is ${list_rad_param}
    SetConfig.Set Fields in swconfig DU         param_list=${list_rad_param}    host=${AP_DU.entryCard[0]}


BEP 853223 Cell Setup With Syslogs
    [Documentation]
    ...         Actions : collect syslog during cell setup
    ...         Params :  none
    ...         Return :  syslog file
    ${syslog}                SYSLOG Start    host=${GNB_DU.sys[0].M}    name=cellSetup
    Setup Wtsemu SA          shouldUseLua=False
    sleep    10s
    WTS Set X2 Link
    sleep    5s
    ${syslogFile}            SYSLOG Stop     syslog=${syslog}
    RETURN                   ${syslogFile}


BEP 853223 start TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # TTI capture configuration
    ${TTIdir}              Get TTI Trace Path    dir_suffix=${suffix}
    set Suite Variable     ${TTIdir}

    # Start TTI capture
    Dated Log New Line     ===> start TTI traces capture
    Start TTI Traces in Streaming mode    src_ip=10.0.1.2

BEP 853223 stop TTI Capture
    [Arguments]            ${suffix}=${EMPTY}
    # Stop TTI capture
    Dated Log New Line     ===> stop TTI traces capture
    ${TTIpcap}             Stop TTI Traces in Streaming mode    tti_trace_path=${TTIdir}    tti_trace_filename=TTI_${suffix}
    set Suite Variable     ${TTIpcap}


BEP 853223 End Of TC
   [Documentation]        At the end of each TC :
   ...                      - show the Diagnosis of the TC steps
   ...                      - collect the gnb Snapshot
   ...                      - if TC failed, collect also AP sosReport

   Dated Log              End Of TC :  add produce scout data ...
   # Oam.OAM Get Snapshot
   # Run Keyword If Test Failed     Setup.Get Sos Report
   GenericTest.Display Diagnosis
   # Dated Log              End of TC : end
   # Dated Log              start Teardown ... restore files
   # Restore Files          listFileDesc=${FD_ALL}
   # OAM Restore Files
   Setup.Produce Scout Data

