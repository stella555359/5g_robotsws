*** Settings ***
Documentation   This is a keyword file for CB008731, part parameter settings pcmd celltrace
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

prepare parameter celltrace
    [Documentation]    [PRIVATE]    set parameter for CB008731_Cell_trace_for_interRAT_HO_from_LTE_to_5G
    ...       :Autor: Sylvia Schneider
    set test variable    ${NRMTRACECU_actCellTraceReportingCU}             true
    set test variable    ${NRMTRACECU_actPCMDReporting}                    false
    set test variable    ${NRMTRACECU_traceNGAPSetting}                    all
    set test variable    ${actPCMDReport}                                  false



prepare parameter pcmd
    [Documentation]    [PRIVATE]    set parameter for CB008731_PCMD_trace_for_interRAT_HO_from_LTE_to_5G
    ...       :Autor: Sylvia Schneider
    set test variable    ${NRMTRACECU_actCellTraceReportingCU}             false
    set test variable    ${NRMTRACECU_actPCMDReporting}                    true
    set test variable    ${NRMTRACECU_traceNGAPSetting}                    none
    set test variable    ${actPCMDReport}                                  true

