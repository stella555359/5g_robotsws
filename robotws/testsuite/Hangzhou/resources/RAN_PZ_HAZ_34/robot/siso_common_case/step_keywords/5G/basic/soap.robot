*** Settings ***
Documentation    This is common keywords for LTE siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library    taf.transport.ssh    WITH NAME    csn
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py
Library    parse_soap.SOAPParser    WITH NAME    soapp

*** Keywords ***
Download soap Log0 from RU
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${ru_alias}=RU
    ${file_name}    csn.execute    command= echo `ls /ram/UnitOAM_SOAP*_Log0.xml*` | cut -d . -f1 |tr -d '\r\n'    connection=${ru_alias}
    ${kw_status}    Run Keyword And Return Status     should contain    ${file_name}    No such file or directory
    ${file_name}    Run Keyword if    ${kw_status}
    ...    csn.execute    command= echo `ls /ram/*/UnitOAM_SOAP*_Log0.xml*` | cut -d . -f1 |tr -d '\r\n'    connection=${ru_alias}
    ...    ELSE    csn.execute    command= echo `ls /ram/UnitOAM_SOAP*_Log0.xml*` | cut -d . -f1 |tr -d '\r\n'    connection=${ru_alias}
    ${status}    csn.file_exists    remote_path=${file_name}.xml.gz    connection=${ru_alias}
    ${status_xml}    csn.file_exists    remote_path=${file_name}.xml    connection=${ru_alias}
    run keyword if    ${status}    csn.execute    command=gzip -d ${file_name}.xml.gz    connection=${ru_alias}
    ${check_xml}    csn.file_exists    remote_path=${file_name}.xml    connection=${ru_alias}
    run keyword if  not ${check_xml}    csn.execute    command=sudo gzip -d ${file_name}.xml.gz    connection=${ru_alias}
    csn.Download File    remote_path=${file_name}.xml    local_path=${log_path}/UnitOAM_SOAP_Log0.xml   connection=${ru_alias}
    ${local_path}    set variable    ${log_path}/UnitOAM_SOAP_Log0.xml
    [Return]    ${local_path}

check basic configuration by soapmsg parvaluechangeind
    [Documentation]    Author: jianhua.li@nokia-sbell.com
    [Arguments]    ${PC_soap_path}=${PC_soap_path}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=FaultManagement
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}

check carier activation by soapmsg parvaluechangeind
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    [Arguments]    ${PC_soap_path}=${PC_soap_path}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelTxEndpoints
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelRxEndpoints
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelTxLinks
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelRxLinks
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=TxArrayCarrier
    ...     parameterName=active    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=RxArrayCarrier
    ...     parameterName=active    newValue=TRUE
    should be true    ${status}

Check SOAP message_RU_lock
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Check SOAP message_RU_lock
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]   ${PC_soap_path}=${PC_soap_path}
    log to console  \n***check soap message_ru_lock ***
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=TxArrayCarrier
    ...     parameterName=active    newValue=FALSE
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=RxArrayCarrier
    ...     parameterName=active    newValue=FALSE
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=Module
    ...     parameterName=blocked    newValue=TRUE

Check SOAP message_RU_unlock
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] Check SOAP message_RU_unlock
    ...    Author: zhenzhen.ren@nokia-sbell.com
    ...    *****************
    [Arguments]  ${PC_soap_path}=${PC_soap_path}
    log to console  \n**Check SOAP message_RU_unlock***
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=TxArrayCarrier
    ...     parameterName=active    newValue=TRUE
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=RxArrayCarrier
    ...     parameterName=active    newValue=TRUE
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=Module
    ...     parameterName=blocked    newValue=FALSE

Check ECpriReceptionMonitor SOAP message
    [Arguments]  ${PC_soap_path}=${PC_soap_path}    ${change_interval}=5min
    ${interval_seconds}    Get Interval Seconds    interval=${change_interval}
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=ECpriReceptionMonitor
    ...     parameterName=subscribe    newValue=TRUE
    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=ECpriReceptionMonitor
    ...     parameterName=interval    newValue=${interval_seconds}

get acceptclock from soap log
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]    ${local_soap_path}
    @{acceptclock}    soapp.getacceptclockclass    logpath=${local_soap_path}
    [Return]    ${acceptclock}

get syncstate from soap log
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]    ${local_soap_path}
    @{syncstate}    soapp.getsyncstate    logpath=${local_soap_path}
    [Return]    ${syncstate}

get lockstate from soap log
    [Documentation]  Author:jiangjing.lin@nokia-sbell.com
    [Arguments]    ${local_soap_path}
    @{lockstate}    soapp.getlockstate    logpath=${local_soap_path}
    [Return]    ${lockstate}
