*** Settings ***
Documentation    Robotframework resource which performs multi ue actions. Here you can find keywords which helps
...              you with multi ue reservation, attaching and detaching multiple phones etc.

Library   taf.ue
Library   Collections


*** Keywords ***
Get UEs
    [Arguments]      ${ue_aliases}  ${ue_capabilities}=REAL_UE
    log to console    __Getting UEs for test...
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Require ue   ${ue_alias}   capabilities=${ue_capabilities}
    END

Attach UEs to cell
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Log to console      __Attach ${ue_alias} to cell
        ${attach_status}  run keyword and return status  Attach ue    ${ue_alias}

        run keyword if  $attach_status is False
        ...  run keywords
        ...  Reboot ue  ${ue_alias}  400  AND
        ...  Detach ue  ${ue_alias}  AND
        ...  Attach ue  ${ue_alias}

    END
    Sleep               5s

Detach UEs from cell
    [Arguments]         ${ue_aliases}
    FOR  ${ue_alias}  IN  @{ue_aliases}
        Log to console      __Detach ${ue_alias} from cell
        Detach ue    ${ue_alias}
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
        Start data transfer
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
        Start data transfer
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
        Stop Data Transfer  ${dt_alias}
    END

    # Clear legacy aliases from list
    FOR  ${dt_alias}  IN  @{dt_aliases}
        Remove values from list  ${dt_aliases}  ${dt_alias}
    END
