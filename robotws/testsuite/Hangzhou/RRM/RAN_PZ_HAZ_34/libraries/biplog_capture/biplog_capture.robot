*** Settings ***
Documentation
...    author: Huimin.Cheng
...    contact: huimin.1.cheng@nokia-sbell.com & cris.cai@nokia-sbell.com
...    squad group: SG_03

Library     ${CURDIR}/bipcatch.py
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     taf.transport.ssh    WITH NAME    csn

*** Variables ***
${gnb_path}             /tmp/

*** Keywords ***
Bip capture
    [Documentation]
    ...    This keyword using for bip logcapture,ASIK interface etha01 ASIB interface ethbp1.
    ...    you can use this keyword whenever you are using ASIB and ASIK,Just distinguish by HW_TYPE
    ...    :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...    however for ASIB left or right, hw slot still 123 123 not 123 567
    [Arguments]     ${biplog}    ${connection}=ASIK Master    ${gnb_index}=${0}    ${mirror_mode}=local
    ...            ${bip_interface}=etha01     ${bip_time}=${3}    ${hw_slot}=1    ${HW_TYPE}=ASIK
    Preconfdition for Bip log Capture     hw_slot=${hw_slot}    mirror_mode=${mirror_mode}    HW_TYPE=${HW_TYPE}
    sleep    3s
    run keyword if     '${HW_TYPE}'=='ASIK'    Connect to Common Unit Master    alias=bip_alias
    ...    ELSE IF    '${HW_TYPE}'=='ASIB'    Connect to Capacity Unit Master    alias=bip_alias
    sleep    3s
    Run keyword if    '${bip_time}'=='infinity'
    ...    csn.Execute    command=tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...           connection=bip_alias
    ...    ELSE    csn.Execute    command=timeout ${bip_time} tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...         connection=bip_alias

HW slot for asib capture
    [Arguments]    ${hw_slot}
    ${hwindex_asib} =    Evaluate    ${hw_slot}%4
    set suite variable    ${hwindex_asib}
    [Return]    ${hwindex_asib}

Preconfdition for Bip log Capture
    [Arguments]    ${hw_slot}    ${mirror_mode}    ${HW_TYPE}
    Connect to Capacity Unit Loner    alias=ABIL    hw_slot=${hw_slot}
    run keyword if     '${HW_TYPE}'=='ASIK'    detectHwAndStartMirroring    asik_alias=ASIK Master
    ...    loner_alias=ABIL    mirror_mode=${mirror_mode}    hw_index=${hw_slot}    sw_release=${HW_TYPE}
    run keyword if     '${HW_TYPE}'=='ASIB'    run keywords    HW slot for asib capture    hw_slot=${hw_slot}    AND
    ...    detectHwAndStartMirroring    asik_alias=ASIK Master    loner_alias=ABIL
    ...    mirror_mode=${mirror_mode}    hw_index=${hwindex_asib}    sw_release=${HW_TYPE}

Download bip log to ute
    [Arguments]    ${logname}    ${remote_path}=${gnb_path}    ${download_path}=${epc_log_path}
    csn.download_file   remote_path=${remote_path}${logname}   local_path=${download_path}${logname}   connection=bip_alias
	
