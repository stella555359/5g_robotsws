*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

*** Variables ***
### part-8: 5GC001340 - 2 TCs ###
${Alarm_name_CP}        BASE STATION CONNECTIVITY PROBLEM
${Severity_CP}          major
${LTEENB_ID}            0
${x2link_dist_name}     MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-${LTEENB_ID}

*** Keywords ***
### part-2: CB008655 ###
General_Feature_Micro-DTXAdvanced_activate_advancedMicroDtxEnabled_true
    log to console   \n*** set precondition: microDTXAdvanced deactivate ***
    Selenium Login And Disable Screen Lock
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    filter_param=Activate micro discontinued transmission advanced    abbr=actMicroDTXAdvanced    new_value=true
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  @{ru_index_list}
        Connect to Common Unit Master    alias=ASIK Master
        Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
        ${soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        Check SOAP message for microDTXAdvanced status    soapLog_path=${soap_path}    advancedMicroDtxEnabled=${TRUE}
        ${soap_file_path}    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${soap_path}    ${SAVE LOG DIRECTORY}
        csn.Disconnect    connection=ASIK Master
    END

Check SOAP message for microDTXAdvanced status
    [Arguments]   ${soapLog_path}    ${advancedMicroDtxEnabled}=${TRUE}
    log to console  \n*** Check microDTXAdvanced status in SOAP message ***
    soapp.check_soapmsg_parvaluechangeind    log_path=${soapLog_path}    class_value=TxArray
    ...     parameterName=advancedMicroDtxEnabled    newValue=${advancedMicroDtxEnabled}

### part-8: 5GC000470-1340 - 2 TCs ###
Step1: Check gNB is onAir
    log to console    Step1: Check gNB is onAir
    Check_gNB_status

Step2: Trigger fault 7300 on WebEM
    log to console    Step2: Trigger fault 7300 on WebEM
    Trigger fault 7300 on WebEM

Step3: Check fault 7300 display on WebEM
    log to console    Step3: Check fault 7300 display on WebEM
    ${Alarm_ob_CP}    set variable    [${BTS_Name}] MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Wait until keyword succeeds    2min    10s    Check fault on WebEM
    ...    alarm_filter=No X2 link available   Alarm_ID_CP=7107    Alarm_name_CP=${Alarm_name_CP}    Fault_ID_CP=7300
    ...    Fault_name_CP=No X2 link available    Severity_CP=${Severity_CP}    Alarm_ob_CP=${Alarm_ob_CP}
    run keyword and ignore error    coam_resource.WEBUI Logout

Recovery Env
    log to console    Recovery Env
    run keyword and ignore error    Clear fault 7300 on WebEM
    run keyword and ignore error    Wait until keyword succeeds    7min    10s
    ...    Check fault disappear on WebEM    alarm_filter=No X2 link available
    sleep   3min
    run keyword and ignore error    coam_resource.WEBUI Logout

Step2: Trigger fault 7308
    log to console    Step2: Trigger fault 7308
    Trigger fault 7308 on gNB

Step3: Check fault 7308 display on WebEM
    log to console    Step3: Check fault 7308 display on WebEM
    coam_resource.WEBUI Login
    ${Alarm_ob_CP}    set variable    [${BTS_Name}] MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-1
    Wait until keyword succeeds    10min    1min    Check fault on WebEM
    ...    alarm_filter=Transport layer connection failure   Alarm_ID_CP=7107
    ...    Alarm_name_CP=${Alarm_name_CP}    Fault_ID_CP=7308
    ...    Fault_name_CP=Transport layer connection failure in X2 interface
    ...    Severity_CP=${Severity_CP}    Alarm_ob_CP=${Alarm_ob_CP}
    Run Keyword And Ignore Error    coam_resource.WEBUI Logout

Recovery fault 7308
    log to console    Recovery fault 7308
    Teardown_fault_clear    alarm_filter=Transport layer connection failure

Trigger fault 7308 on gNB
    Trigger alarm on gNB    cmd=iptables -t filter -A OUTPUT -p sctp --dport 36422 -j DROP
    Trigger alarm on eNB    cmd=iptables -t filter -I INPUT 1 -s ${asik_addr} -p sctp --dport 36422 -j DROP

