*** Settings ***
Documentation    CBRS Library adding methods to operate with DCAP_LITE logs collector
...              more info about DCAP: https://confluence.ext.net.nokia.com/display/DCAPBASIC/About+DCAP
...              FOR INTERNAL USE ONLY!


*** Keywords ***
Collect SysLog DCAP
    [Documentation]  Description:           Stop DCAP trace between VM - BTS, and download SysLog    ${\n}
    ...              Return:                none                                                     ${\n}
    ...              Output:                { }                                                      ${\n}
    ...              Author:                karol.sadowski@nokia.com                                 ${\n}
    ...              Maintainer:            CBRS Team                                                ${\n}
    [Arguments]  ${trace_id}                                        # dcap trace id (aka bts_id)
    ...          ${alias}=RAT_1ST_dcap                              # connection alias
    ...          ${filename}=/home/ute/Downloads/syslog_4g.zip      # name and location to result file

    dcap.Stop Trace  trace_id=${trace_id}  connection=${alias}  timeout=60
    dcap.Get Results  result_id=${None}  target_dir=${filename}  connection=${alias}  timeout=180


Create BTS Dictionary
    [Documentation]  Description:           KW used in some other KW's from DCAPLib                  ${\n}
    ...              Return:                dictionary with BTS info                                 ${\n}
    ...              Output:                { list }                                                 ${\n}
    ...              Author:                karol.sadowski@nokia.com                                 ${\n}
    ...              Maintainer:            CBRS Team                                                ${\n}
    [Arguments]  ${host}=192.168.255.129        # host ip, typically LMP/m-plane IP
    ...          ${port}=443                    # host connection port

    &{bts_dict}  Create Dictionary  host=${host}  port=${port}  username=Nemuadmin  password=nemuuser
    ${bts_dict}  Create List  ${bts_dict}

    RETURN  ${bts_dict}
