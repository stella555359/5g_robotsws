*** Settings ***
Documentation    Robotframework resource which performs multi ue actions. Here you can find keywords which helps
...              you with multi ue reservation, attaching and detaching multiple phones etc.

Library   ${ue_lib}
Library   Collections
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot

*** Variables ***
${ue_lib}    taf.ue

*** Keywords ***
Get UEs
    [Arguments]      ${ue_aliases}  ${ue_capabilities}=REAL_UE
    log to console    __Getting UEs for test...
    FOR  ${ue_alias}  IN  @{ue_aliases}
        taf.ue.Require ue   ${ue_alias}   capabilities=${ue_capabilities}
    END

Get attach cell ID
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
       ${CELL_ID}  Get Ue Info  ${ue_alias}  CELL_ID
       log to console  ${ue_alias} attached to cell ${CELL_ID}
       END

Attach UEs to cell
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Log to console      __Attach ${ue_alias} to cell
        taf.ue.Attach ue    ${ue_alias}
    END
    BuiltIn.Sleep               20s

Detach UEs from cell
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Log to console      __Detach ${ue_alias} from cell
        taf.ue.Detach ue    ${ue_alias}
    END

Stop using UEs
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Log to console        __Stop using ${ue_alias}
        Stop Using Ue  ${ue_alias}
    END

Reboot UEs
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Log to console        __Reboot ${ue_alias}
        Reboot UE  ${ue_alias}  120
    END

Create list for storing datatransfers
    @{dt_aliases}   Create list
    Set test variable  @{dt_aliases}

Start DL for UEs
    [Documentation]   ...  Keywords creates list to store data transfer aliases it one does not exists.
                      ...  Then its strarts DL for all UEs from given list with given parameters.
    [Arguments]
    ... 		        ${ue_aliases}
    ...                 ${duration}=30s
    ...                 ${dl_throughput}=1200 Mbits/sec
    ...                 ${protocol}=udp
    ...                 ${packet_size}=1400

    Log to console      __Perform ${dl_throughput} DL ${protocol} data transfer for ${duration} on @{ue_aliases}

    ${dt_aliases_value}  get variable value  ${dt_aliases}
    Run keyword if  ${dt_aliases_value}==None  Create list for storing datatransfers

    FOR  ${ue_alias}  IN  @{ue_aliases}
        ${dt_alias}  Set variable  DT_DL_${ue_alias}
        Append to list  ${dt_aliases}  ${dt_alias}
        taf.ue.Start data transfer
        ...                 dt_name=${dt_alias}
        ...                 ue_alias=${ue_alias}
        ...                 direction=dl
        ...                 duration=${duration}
        ...                 throughput=${dl_throughput}
        ...                 protocol=${protocol}
        ...                 packet_size=${packet_size}
    END

Start UL for UEs
    [Documentation]   ...  Keywords creates list to store data transfer aliases it one does not exists.
                      ...  Then its strarts UL for all UEs from given list with given parameters.
    [Arguments]
    ... 		        ${ue_aliases}
    ...                 ${duration}=30s
    ...                 ${ul_throughput}=1200 Mbits/sec
    ...                 ${protocol}=udp
    ...                 ${packet_size}=1400

    Log to console      __Perform ${ul_throughput} UL ${protocol} data transfer for ${duration} on @{ue_aliases}

    ${dt_aliases_value}  get variable value  ${dt_aliases}
    Run keyword if  ${dt_aliases_value}==None  Create list for storing datatransfers

    FOR  ${ue_alias}  IN  @{ue_aliases}
        ${dt_alias}  Set variable  DT_UL_${ue_alias}
        Append to list  ${dt_aliases}  ${dt_alias}
        taf.ue.Start data transfer
        ...                 dt_name=${dt_alias}
        ...                 ue_alias=${ue_alias}
        ...                 direction=ul
        ...                 duration=${duration}
        ...                 throughput=${ul_throughput}
        ...                 protocol=${protocol}
        ...                 packet_size=${packet_size}
    END

Start ULDL for UEs
    [Arguments]
    ... 		        ${ue_aliases}
    ...                 ${duration}=30s
    ...                 ${dl_throughput}=1200 Mbits/sec
    ...                 ${ul_throughput}=1200 Mbits/sec
    ...                 ${protocol}=udp
    ...                 ${packet_size}=1400

    Start DL for UEs    ${ue_aliases}  ${duration}  ${dl_throughput}  ${protocol}  ${packet_size}
    Start UL for UEs    ${ue_aliases}  ${duration}  ${ul_throughput}  ${protocol}  ${packet_size}

Start TCP Tput for UEs
    [Documentation]   ...  Keywords creates list to store data transfer aliases if one does not exists.
                      ...  Then it starts TCP DL, UL or both for all UEs from given list with given parameters.
                      ...  This Keyword has been made to add additional TCP flags to KW 'Start DL for UEs' and
                      ...  maintain backwards compatibility.
    [Arguments]
    ... 		        ${ue_aliases}
    ...                 ${duration}=30s
    ...                 ${throughput}=1200 Mbits/sec
    ...                 ${packet_size}=1400
    ...                 ${direction}=dl
    Log to console      __Perform ${throughput} ${direction} TCP data transfer for ${duration} on @{ue_aliases}
    ${dt_aliases_value}  get variable value  ${dt_aliases}
    Run keyword if  ${dt_aliases_value}==None  Create list for storing datatransfers
    FOR  ${ue_alias}  IN  @{ue_aliases}
        ${dt_alias}  Set variable  DT_${direction}_TCP_${ue_alias}
        Append to list  ${dt_aliases}  ${dt_alias}
        taf.ue.Start data transfer
        ...                 dt_name=${dt_alias}
        ...                 ue_alias=${ue_alias}
        ...                 direction=${direction}
        ...                 duration=${duration}
        ...                 throughput=${throughput}
        ...                 protocol=tcp
        ...                 packet_size=${packet_size}
        ...                 parallel_streams=1
        ...                 packet=1024B
        ...                 buffer=1M
        ...                 ttl=64
        ...                 max_segment_size=1400
#        ...                 linux_congestion=cubic #doesn't work with UL
    END

Start TCP ULDL for UEs
    [Arguments]
    ... 		        ${ue_aliases}
    ...                 ${duration}=30s
    ...                 ${dl_throughput}=1200 Mbits/sec
    ...                 ${ul_throughput}=1200 Mbits/sec
    ...                 ${packet_size}=1400
    Start TCP Tput for UEs    ${ue_aliases}  ${duration}  ${dl_throughput}  ${packet_size}  dl
    Start TCP Tput for UEs    ${ue_aliases}  ${duration}  ${ul_throughput}  ${packet_size}  ul

Await datatransfers finish
    [Documentation]  ...  Awaits for all datatransfers (from @{dt_aliases}) to finsih.
                     ...  Then it calculates avarage tput for each data transfer, prints and returns it.
    Log to console  __Await datatransfer finish
    FOR  ${dt_alias}  IN  @{dt_aliases}
        Await Data Transfer Finish  ${dt_alias}
    END
    @{avg_tputs}        Create list
    FOR  ${dt_alias}  IN  @{dt_aliases}
        ${avg_tput}     get average throughput  ${dt_alias}
        Append to list  ${avg_tputs}  ${avg_tput}
        Log to console  ${dt_alias} average throughput: ${avg_tput} kbits/sec
    END
    [Return]            @{avg_tputs}

Stop all datatransfers
    [Documentation]  ...  Stop all datatransfers stored in dt_aliases.
    Log to console  __Await datatransfer finish
    FOR  ${dt_alias}  IN  @{dt_aliases}
        taf.ue.Stop Data Transfer  ${dt_alias}
    END

Get max tputs from data transfer statistics
    [Documentation]  ...  If all datatransfers (from @{dt_aliases}) are finished, then this KW grabs statics of this
                     ...  transfers and parse, prints and returns max tputs from them.
    Log to console  __Get max tputs from data transfer statistics
    @{max_tputs}        Create list
    FOR  ${dt_alias}  IN  @{dt_aliases}
        ${data}     get Data Transfer Statistics  ${dt_alias}
        ${list}     Get Regexp Matches  ${data}     [^;]*
        ${list}     Split string        ${list}[0]  ,
        ${max}      Convert To Number   ${list}[2]
        ${max}      Evaluate            ${max}/1000
        Append to list  ${max_tputs}  ${max}
        Log to console  ${dt_alias} max throughput: ${max} kbits/sec
    END
    [Return]            ${max_tputs}

Attach UEs And Start Tput
    [Documentation]
    ...    Keyword adapted from 2637 - created by Mati

    [Arguments]
    ...    ${ue_aliases}
    ...    ${protocol}=udp
    ...    ${direction}=dl
    ...    ${duration}=10min
    ...    ${throughput}=800Mbits/sec
    ...    ${res}=off

    Run keyword if  '${res}' == 'on'
    ...             Reset UEs  ${ue_aliases}
    Attach UEs to cell  ${ue_aliases}
    Get attach cell ID  ${ue_aliases}
    Run keyword if  '${protocol}' == 'udp' and '${direction}' == 'dl'
    ...             Start DL for UEs  ${ue_aliases}  duration=${duration}  dl_throughput=${throughput}
    ...             ELSE IF  '${protocol}' == 'tcp' and '${direction}' == 'dl'
    ...             Start TCP Tput for UEs  ${ue_aliases}  duration=${duration}  throughput=${throughput}
    ...             direction=${direction}
    ...             ELSE IF  '${protocol}' == 'tcp' and '${direction}' == 'ul'
    ...             Start TCP Tput for UEs  ${ue_aliases}  duration=${duration}  throughput=${throughput}
    ...             direction=${direction}
    ...             ELSE IF  '${protocol}' == 'udp' and '${direction}' == 'ul'
    ...             Start UL for UEs  ${ue_aliases}  duration=${duration}  ul_throughput=${throughput}
    ...             ELSE IF  '${protocol}' == 'udp' and '${direction}' == 'both'
    ...             Start ULDL for UEs  ${ue_aliases}  duration=${duration}  dl_throughput=${throughput}
    ...             ul_throughput=${throughput}
    ...             ELSE
    ...             Start TCP ULDL for UEs  ${ue_aliases}  duration=${duration}  dl_throughput=${throughput}
    ...             ul_throughput=${throughput}

Wait For Tput Finish And Get Tput Statistics
    [Documentation]
    ...    Keyword adapted from 2637 - created by Mati

    [Arguments]
    ...    ${ue_alias}

    ${av_tputs}   Await datatransfers finish
    ${max_tputs}  Get max tputs from data transfer statistics
    Detach UEs from cell  ${ue_alias}

    [Return]  ${av_tputs}  ${max_tputs}
