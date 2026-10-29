*** Settings ***
Documentation
    ...     [Procedure]             "Keywords Defined for CB010846"
    ...     [Date]                  "11-09-24"
    ...     [Author]                "Nethra"
    ...     [QC_Path]               "QC_Path in Test Plan"
    ...     [QC_ID]                 "QC_ID in Test Lab for reporting"
    ...     [Funtion_Hash_Tags]     "Operability"
    ...     [Feature_ID]            "CB010846"
    ...     [Validation_status]     "Validated and Passed"
    ...     [Validated_TestLine]    "TL-2011"
    ...     [Requirements]          "5G_RAN_USR_COM_21094,OM_GEN_SFS_SYSM.9224,5G_RAN_USR_COM_21991"

Resource        taf/rfrl/trs_e2e_fw/setup/framework.robot


*** Variables ***
${tc_variables}     testcase_variables.json


*** Keywords ***

BBMOD Reset
    Run Keyword And Ignore Error     Reset      operation=reset_unit     dist_name=${bbmod_1}      reset_type=Hard
    Run Keyword And Ignore Error     Reset      operation=reset_unit     dist_name=${bbmod_3}      reset_type=Hard


Ping to Mplane
    ${status}=  Run Keyword     Run     command=ping -c 10 ${mplane_ipv4}
    Should contain Any      ${status}   0% packet loss

Read mplane IP
    ${mplane_ipv4}=     Get Parameter   param_path=${mplane_ipv4_moc}
    Set Suite Variable          ${mplane_ipv4}

Multiple BBMOD Reset
    FOR    ${index}    IN RANGE    ${length}
        Run Keyword And Ignore Error     Reset      operation=reset_unit     dist_name=${bbmod_1}      reset_type=Hard     verify_bts=${False}
        Run Keyword And Ignore Error     Reset      operation=reset_unit     dist_name=${bbmod_3}       reset_type=Hard    verify_bts=${False}
        Sleep     200
    END

Verify RU1 uptime Ecpri
    Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist_akqj}     fhnet_login_only=${True}      timeout=60      alias=conn3
    ${RF}=      Execute Interactive Remote Command      command=${getipakqj}     alias=conn3
    ${RFIp}=    Get Line   ${RF}     2
    Execute Interactive Remote Command      command=ssh rfsw@${RFIp}    alias=conn3
    Execute Interactive Remote Command      command=${yes}    alias=conn3
    Execute Interactive Remote Command      command=${AKQJ_password}    alias=conn3
    ${uptime_akqj}=     Execute Interactive Remote Command      command=${uptime}  alias=conn3
    ${time}=    Get Line   ${uptime_akqj}     2
    ${status}=  Evaluate    0 < ${time} > 10
    Convert To String   ${status}
    Run Keyword And Ignore Error        Should Contain  ${status}    True
    Rfmodule Teardown       alias=conn3


Verify RU1 uptime Cpri
    Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist_ahib}     fhnet_login_only=${True}      timeout=60      alias=conn4
    ${RF_ahib}=      Execute Interactive Remote Command      command=${getipahib}     alias=conn4
    ${RFIp_ahib}=    Get Line   ${RF_ahib}     2
    Execute Interactive Remote Command      command=rm -rf .ssh/known_hosts    alias=conn4
    Execute Interactive Remote Command      command=ssh root@${RFIp_ahib}    alias=conn4
    Execute Interactive Remote Command      command=${yes}    alias=conn4
    ${uptime_ahib}=     Execute Interactive Remote Command      command=${uptime_1}  alias=conn4
    ${time_1}=    Get Line   ${uptime_ahib}     2
    ${status}=  Evaluate    0 < ${time_1} > 10
    Convert To String   ${status}
    Run Keyword And Ignore Error      Should Contain  ${status}    True
    Rfmodule Teardown       alias=conn4


Verify RU2 uptime Ecpri
    Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist_avql}     fhnet_login_only=${True}      timeout=60      alias=conn5
    ${RF_avql}=      Execute Interactive Remote Command      command=${getipavql}     alias=conn5
    ${RFIp_avql}=    Get Line   ${RF_avql}     2
    Execute Interactive Remote Command      command=ssh rfsw@${RFIp_avql}    alias=conn5
    Execute Interactive Remote Command      command=${yes}    alias=conn5
    Execute Interactive Remote Command      command=${AVQL_password}    alias=conn5
    ${uptime_avql}=     Execute Interactive Remote Command      command=${uptime_1}  alias=conn5
    ${time_2}=    Get Line   ${uptime_avql}     2
    ${status}=  Evaluate    0 < ${time_2} > 10
    Convert To String   ${status}
    Run Keyword And Ignore Error    Should Contain  ${status}    True
    Rfmodule Teardown       alias=conn5
