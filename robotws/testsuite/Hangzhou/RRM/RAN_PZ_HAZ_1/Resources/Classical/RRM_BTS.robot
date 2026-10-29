*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    Common KWs related to Classicalbts.
...    Some common operation is put in this file
...    Case proccess is put to case file
...    Please do not modify the file without notification to author

Resource          RRM_Common_Resource.robot



*** Keywords ***
#----Connect to Control Board: ASIK,ASIB,ASIL,etc-----------------------------------------------------
Connect to ASIB Master
    [Arguments]    ${du_index}=${0}    ${alias}=ASIB_Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ASIB master for full rack and half rack.
    ...                username and password are same to related asib Master.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for this test line in the indicated gNB, default is 0 |
    ...    | ${alias} | No | The alias assign to this connection, default is ASIB_Master |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ASIB Master  |    |    |
    ...    |  Connect to ASIB Master  |  du_index=1  |  alias=ASIB  |
    ...
    ${ASIBL}    Get Regexp Matches    ${TL_Type}    .*ASIBL.*
    ${ASIBR}    Get Regexp Matches    ${TL_Type}    .*ASIBR.*
    run keyword if    ${ASIBL} == ${ASIBR}    run keywords    Connect to Second_ASIB    du_index=${0}    alias=ASIB_Master    AND
    ...                                                       Set Test Variable    ${connection_ASIB}    ${alias}
    ...       ELSE                            run keywords    Connect to First_ASIB    alias=ASIB_Master    AND
    ...                                                       Set Test Variable    ${connection_ASIB}    ${alias}
    [Return]    ${connection_ASIB}

Connect to First_ASIB
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${alias}=First_ASIB
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to First_ASIB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${gnb_index} | No | The gNB index for this test line, default is 0 |
    ...    | ${du_index} | No | The DU index for this test line in the indicated gNB, default is 0 |
    ...    | ${alias} | No | The alias assign to this connection, default is First_ASIB |
    ...    | ${host} | No | The indicated gNB and DU's connection IP addr, default read from __init__.py |
    ...    | ${username} | No | The indicated gNB and DU's connection username, default read from __init__.py |
    ...    | ${password} | No | The indicated gNB and DU's connection password, default read from __init__.py |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to First_ASIB  |    |    |    |
    ...    |  Connect to First_ASIB  |  gnb_index=1  |  du_index=1  |    |
    ...    |  Connect to First_ASIB  |  host=10.57.10.10  |  username=toor4nsn  |  password=oZPS0POrRieRtu  |
    ...
    csn.Connect To    hostname=${host}    username=${username}    password=${password}    alias=${alias}

Connect to Second_ASIB
    [Arguments]    ${du_index}=${0}    ${alias}=ASIB Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to second_ASIB with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib only have one asib Master and one asib Slave.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for this test line in the indicated gNB, default is 0 |
    ...    | ${alias} | No | The alias assign to this connection, default is ASIB Master |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to Second_ASIB  |    |    |
    ...    |  Connect to Second_ASIB  |  du_index=1  |  alias=Second_ASIB  |
    ...
    Connect to Common Unit Master    ${du_index}
    csn.connect_to    hostname=${fct_4a}
    ...               username=${ASIB_USERNAME}
    ...               password=${ASIB_PASSWORD}
    ...               proxy=ASIB Master
    ...               alias=${alias}

Connect to Common Unit Master
    [Arguments]    ${du_index}=${0}    ${alias}=ASIB Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe asib.
    ...                In cloud gNB, asib Master connection need OAM as proxy.
    ...                In classical gNB, asib Master connection don't need any proxy.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | testline_info.get_du_list will return du list, any element can be visited in list. |
    ...    | ${alias} | No | ASIB Master is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to Common Unit Master  |    |    |
    ...    |  Connect to Common Unit Master  |  du_index=1  |  alias=Second_ASIB  |
    ...
    #${has_cbts}    testline_info.has_cloudBts    ${tl}
    #Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    #${proxy}    Set Variable If    ${has_cbts}    OAM
    #...                                           ${None}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    ${dus[${du_index}].f1_m_ip_addr}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${None}    alias=${alias}

Connect to Common Unit Slave
    [Arguments]    ${du_index}=${0}    ${alias}=ASIB Slave
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to Common Unit Slave with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib only have one asib Master and one asib Slave.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | testline_info.get_du_list will return du list, any element can be visited in list. |
    ...    | ${alias} | No | ASIB Slave is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to Common Unit Slave  |    |    |
    ...    |  Connect to Common Unit Slave  |  du_index=1  |  alias=Second_ASIB  |
    ...
    Connect to Common Unit Master    ${du_index}
    ${hoststr}    ssh.Execute    arp -a | grep fct    ASIB Master
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    ${hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=ASIB Master    alias=${alias}

#----Connect to Base Band Board: ABIL,ABIO,ABIN,etc----------------------------------------------------------
Connect to GNB_ABIL_Master
    [Arguments]    ${alias}=GNB_ABIL_Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to the first ABIL
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The alias assign to this connection, default is GNB_ABIL_Master |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to GNB_ABIL_Master  |
    ...
    csn.connect_to    hostname=${ABIL_MASTER_ADDR}    username=${ASIB_USERNAME}    password=${ASIB_PASSWORD}    alias=${alias}

Connect to GNB_loner
    [Arguments]    ${alias}=GNB_loner    ${proxy}=First_ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to the loner fsp-1-1c via first ASIB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The alias assign to this connection, default is GNB_loner |
    ...    | ${proxy} | No | The ASIB connection be used to connect to loner, default is First_ASIB. You should prepare this proxy firstly |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to GNB_loner  |    |    |
    ...    |  Connect to GNB_loner  |  alias=my_loner  |  proxy=asib_conn  |
    ...
    csn.connect_to    hostname=${Loner_addr}    username=${Loner_username}    password=${Loner_password}
    ...               alias=${alias}    proxy=${proxy}

Connect to GNB_ABIL
    [Arguments]    ${alias}=GNB_ABIL    ${proxy}=First_ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to the gNB ABIL fsp-1-1a via first ASIB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The alias assign to this connection, default is GNB_ABIL |
    ...    | ${proxy} | No | The ASIB connection be used to connect to loner, default is First_ASIB. You should prepare this proxy firstly |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to GNB_ABIL  |    |    |
    ...    |  Connect to GNB_ABIL  |  alias=my_abil  |  proxy=asib_conn  |
    ...
    csn.connect_to    hostname=${GNB_ABIL_addr}    username=${Loner_username}    password=${Loner_password}
    ...               alias=${alias}    proxy=${proxy}

Connect to ABIL Master
    [Arguments]    ${du_index}=${0}    ${alias}=ABIL_Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIL for full rack and half rack.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIL Master is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL Master  |    |    |
    ...    |  Connect to ABIL Master  |  du_index=1  |  alias=abil_conn  |
    ...
    ${testline_type}    Get Regexp Matches    ${TL_Type}    ASI.*?ASI
    run keyword if    ${testline_type}    run keywords    Connect to ABIL Master for full rack    du_index=${du_index}    alias=${alias}
    ...                                            AND    Set Test Variable    ${connection_ABIL}    ${alias}
    ...       ELSE                        run keywords    Connect to ABIL Master for half rack    du_index=${du_index}    alias=${alias}
    ...                                            AND    Set Test Variable    ${connection_ABIL}    ${alias}
    [Return]    ${connection_ABIL}

Connect to ABIL Slave
    [Arguments]    ${du_index}=${0}    ${alias}=ABIL_Slave
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIL for full rack and half rack.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIL Slave is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL Slave  |    |    |
    ...    |  Connect to ABIL Slave  |  du_index=1  |  alias=abil_conn  |
    ...
    ${testline_type}    Get Regexp Matches    ${TL_Type}    .*?fullrack
    run keyword if    ${testline_type}    run keywords    Connect to ABIL Slave for full rack    du_index=${du_index}    alias=${alias}
    ...                                            AND    Set Test Variable    ${connection_ABIL}    ${alias}
    ...       ELSE                        run keywords    Connect to ABIL Slave for half rack    du_index=${du_index}    alias=${alias}
    ...                                            AND    Set Test Variable    ${connection_ABIL}    ${alias}
    [Return]    ${connection_ABIL}

Connect to ABIO Master
    [Arguments]    ${du_index}=${0}    ${alias}=ABIO_Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIO for full rack and half rack.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib connect to ABIL minnum one and maxnum three.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIO_Master is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIO Master  |    |    |
    ...    |  Connect to ABIO Master  |  du_index=1  |  alias=abio_conn  |
    ...
    ${testline_type}    Get Regexp Matches    ${TL_Type}    ASI.*?ASI
    run keyword if    ${testline_type}    run keywords    Connect to ABIO Master for full rack    du_index=${du_index}    alias=${alias}
    ...                                            AND    Set Test Variable    ${connection_ABIO}    ${alias}
    ...       ELSE                        run keywords    Connect to ABIO Master for half rack    du_index=${du_index}    alias=${alias}
    ...                                            AND    Set Test Variable    ${connection_ABIO}    ${alias}
    [Return]    ${connection_ABIO}

#----Connect to Full Rack TL's ABIL, ABIO--------------------------------------------------------------------
Connect to ABIL Master for full rack
    [Arguments]    ${du_index}=${0}    ${alias}=ABIL_Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIL with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib only have one asib Master and one asib Slave.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIL Master is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL Master for full rack  |    |    |
    ...    |  Connect to ABIL Master for full rack  |  du_index=1  |  alias=abil_conn  |
    ...
    Connect to Second_ASIB    du_index=${du_index}    alias=Second_ASIB
    ${TL_list}=    Create list
    ...    .*?ABILB1.*?
    ...    .*?ABILB2.*?
    ...    .*?ABILB3.*?
    ${fsp_list}=    Create list
    ...    fsp-5a
    ...    fsp-6a
    ...    fsp-7a
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE    run keywords
        ...               Continue For Loop
    END
    csn.connect_to    hostname=${hostname}
    ...               username=${ASIB_USERNAME}
    ...               password=${ASIB_PASSWORD}
    ...               proxy=Second_ASIB
    ...               alias=${alias}

Connect to ABIL Slave for full rack
    [Arguments]    ${du_index}=${0}    ${alias}=ABIL_Slave
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIL with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib only have one asib Master and one asib Slave.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIL Slave is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL Slave for full rack  |    |    |
    ...    |  Connect to ABIL Slave for full rack  |  du_index=1  |  alias=abil_conn  |
    ...
    Connect to Second_ASIB    du_index=${du_index}    alias=Second_ASIB
    ${TL_list}=    Create list
    ...    .*?ABILB1.*?fullrack
    ...    .*?ABILB2.*?fullrack
    ...    .*?ABILB3.*?fullrack
    ${fsp_list}=    Create list
    ...    fsp-5b
    ...    fsp-6b
    ...    fsp-7b
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE                 run keywords
        ...                            Continue For Loop
    END
    csn.connect_to    hostname=${hostname}
    ...               username=${ASIB_USERNAME}
    ...               password=${ASIB_PASSWORD}
    ...               proxy=Second_ASIB
    ...               alias=${alias}

Connect to ABIL loner for full rack
    [Arguments]    ${du_index}=${0}    ${alias}=ABIL
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIL with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib only have one asib Master and one asib Slave.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIL is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL loner for full rack  |    |    |
    ...    |  Connect to ABIL loner for full rack  |  du_index=1  |  alias=abil  |
    ...
    Connect to Second_ASIB    du_index=${du_index}    alias=Second_ASIB
    ${TL_list}=    Create list
    ...    .*?ABILB1.*?fullrack
    ...    .*?ABILB2.*?fullrack
    ...    .*?ABILB3.*?fullrack
    ${fsp_list}=    Create list
    ...    fsp-5c
    ...    fsp-6c
    ...    fsp-7c
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE                 run keywords
        ...                            Continue For Loop
    END
    csn.connect_to    hostname=${hostname}
    ...               username=${ASIB_USERNAME}
    ...               password=${ASIB_PASSWORD}
    ...               proxy=Second_ASIB
    ...               alias=${alias}

Connect to ABIO Master for full rack
    [Arguments]    ${du_index}=${0}    ${alias}=ABIO_Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to ABIO with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib only have one asib Master and one asib Slave.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIO Master is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIO Master for full rack  |    |    |
    ...    |  Connect to ABIO Master for full rack  |  du_index=1  |  alias=abio_conn  |
    ...
    Connect to Second_ASIB    du_index=${du_index}    alias=Second_ASIB
    ${TL_list}=    Create list
    ...    .*?ABIOB1.*?
    ...    .*?ABIOB2.*?
    ...    .*?ABIOB3.*?
    ${fsp_list}=    Create list
    ...    fsp-5a
    ...    fsp-6a
    ...    fsp-7a
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE                 run keywords
        ...                            Continue For Loop
    END
    csn.connect_to    hostname=${hostname}
    ...               username=${ASIB_USERNAME}
    ...               password=${ASIB_PASSWORD}
    ...               proxy=Second_ASIB
    ...               alias=${alias}

#----Connect to Half Rack TL's ABIL, ABIO--------------------------------------------------------------------
Connect to ABIL Master for half rack
    [Arguments]    ${du_index}=${0}    ${alias}=ABIL Master    ${asib_alias}=ASIB Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to Capacity Unit Master with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIL Master is default value, you can set with other name. |
    ...    | ${asib_alias} | No | The ASIB connection you use to connect to ABIL.  You should prepare this connection firstly. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL Master for half rack  |    |    |
    ...    |  Connect to ABIL Master for half rack  |  du_index=1  |  alias=abil_conn  |
    ...
    Connect to Common Unit Master    ${du_index}    alias=${asib_alias}
    ${dus}    testline_info.get_du_list    ${tl}
    ${TL_list}=    Create list
    ...    .*?ASIBL.*?ABILB1.*?halfrack
    ...    .*?ASIBL.*?ABILB2.*?halfrack
    ...    .*?ASIBL.*?ABILB3.*?halfrack
    ...    .*?ASIBR.*?ABILB1.*?halfrack
    ...    .*?ASIBR.*?ABILB2.*?halfrack
    ...    .*?ASIBR.*?ABILB3.*?halfrack
    ${fsp_list}=    Create list
    ...    fsp-1a
    ...    fsp-2a
    ...    fsp-3a
    ...    fsp-5a
    ...    fsp-6a
    ...    fsp-7a
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE                 run keywords
        ...                            Continue For Loop
    END
    ssh.Connect to    hostname=${hostname}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asib_alias}    alias=${alias}

Connect to ABIL Slave for half rack
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL_Slave
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to Capacity Unit Slave with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${hw_slot} | No | In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7. |
    ...    | ${alias} | No | ABIL Master is default value, you can set with other name. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIL Slave for half rack  |    |    |
    ...    |  Connect to ABIL Slave for half rack  |  du_index=1  |  alias=abil_conn  |
    ...
    Connect to Common Unit Master    ${du_index}
    ${dus}    testline_info.get_du_list    ${tl}
    ${TL_list}=    Create list
    ...    .*?ASIBL.*?ABILB1.*?halfrack
    ...    .*?ASIBL.*?ABILB2.*?halfrack
    ...    .*?ASIBL.*?ABILB3.*?halfrack
    ...    .*?ASIBR.*?ABILB1.*?halfrack
    ...    .*?ASIBR.*?ABILB2.*?halfrack
    ...    .*?ASIBR.*?ABILB3.*?halfrack
    ${fsp_list}=    Create list
    ...    fsp-1b
    ...    fsp-2b
    ...    fsp-3b
    ...    fsp-5b
    ...    fsp-6b
    ...    fsp-7b
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE                 run keywords
        ...                            Continue For Loop
    END
    ssh.Connect to    hostname=${hostname}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=ASIB Master    alias=${alias}

Connect to ABIO Master for half rack
    [Arguments]    ${du_index}=${0}    ${alias}=ABIO Master    ${asib_alias}=ASIB Master
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Connect to Capacity Unit Master with IP which search from asib Master.
    ...                username and password are same to related asib Master.
    ...                set related asib Master as proxy is mandantory.
    ...                one asib connect to ABIL minnum one and maxnum three.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${du_index} | No | The DU index for the indicated TL, default value is 0. |
    ...    | ${alias} | No | ABIO Master is default value, you can set with other name. |
    ...    | ${asib_alias} | No | The ASIB connection you use to connect to ABIL.  You should prepare this connection firstly. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect to ABIO Master for half rack  |    |    |
    ...    |  Connect to ABIO Master for half rack  |  du_index=1  |  alias=abio_conn  |
    ...
    Connect to Common Unit Master    ${du_index}    alias=${asib_alias}
    ${dus}    testline_info.get_du_list    ${tl}
    ${TL_list}=    Create list
    ...    .*?ASIBL.*?ABIOB1.*?
    ...    .*?ASIBL.*?ABIOB2.*?
    ...    .*?ASIBL.*?ABIOB3.*?
    ...    .*?ASIBR.*?ABIOB1.*?
    ...    .*?ASIBR.*?ABIOB2.*?
    ...    .*?ASIBR.*?ABIOB3.*?
    ${fsp_list}=    Create list
    ...    fsp-1a
    ...    fsp-2a
    ...    fsp-3a
    ...    fsp-5a
    ...    fsp-6a
    ...    fsp-7a
    ${index}    set variable    ${-1}
    ${length}    get length    ${TL_list}
    FOR    ${TL}    IN    @{TL_list}
        run keyword if    ${index} == ${length}    fail    find hostname is failed
        ${index}    Evaluate    ${index} + ${1}
        ${status}    Get Regexp Matches    ${TL_Type}    ${TL}
        run keyword if    ${status}    run keywords
        ...                            set test variable    ${hostname}    ${fsp_list[${index}]}    AND
        ...                            exit for loop
        ...       ELSE                 run keywords
        ...                            Continue For Loop
    END
    ssh.Connect to    hostname=${hostname}
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asib_alias}    alias=${alias}

#----Other Connections---------------------------------------------------------------------------------------
Connect To FCT
    [Arguments]    ${host}=${BTS_INFO.IP}    ${username}=${BTS_INFO.USERNAME}
    ...            ${password}=${BTS_INFO.PASSWORD}    ${alias}=BTS_LOCAL_Conn
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Connect to control board ASIK, ASIB, ASIL, etc.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | host | No | The ASIX need to connect, default is ${BTS_INFO.IP} |
    ...    | username | No | The ASIX username, default is ${BTS_INFO.USERNAME} |
    ...    | password | No. | The ASIX password, default is ${BTS_INFO.PASSWORD} |
    ...    | alias | No. | The Connection alias, default is BTS_LOCAL_Conn |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect To FCT  |    |    |
    ...    |  Connect To FCT  |  host=${BTS_INFO.LOCALIP}  |  username=${}  |
    ...
    SSH.connect_to    hostname=${host}    username=${username}    password=${password}
    ...    alias=${alias}
    Set Suite Variable    ${alias}    ${alias}
    [Return]    ${alias}

Disconnect FCT
    [Arguments]    ${alias}=BTS_LOCAL_Conn
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Disconnect from control board ASIK, ASIB, ASIL, etc.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias | No. | The Connection alias, default is BTS_LOCAL_Conn |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Connect To FCT  |    |
    ...    |  Connect To FCT  |  alias=bts_conn  |
    ...
    SSH.Disconnect    connection=${alias}

Get Hosts From String
    [Arguments]    ${output_string}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                get IP list from String which search from asib Master
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${output_string} | Yes | Could be the output of searching asib slave ip string or abil master ip string |
    ...    |                  |     | or abil slave ip string, or abil loner ip string from asib master |
    ...
    ...    | Return Value | Description |
    ...    | @{hosts} | The asib slave ip list, or abil master ip list, or abil slave ip list, or abil loner ip list. |
    ...
    ...    Example
    ...    | ${hostnames} | Get Hosts From String | ${hoststr} |
    ...
    @{lines}=    Split To Lines    ${output_string}
    @{hosts}    Create List
    FOR    ${line}    IN    @{lines}
        @{first_split}=    Split String    ${line}    (
        @{second_split}=    Split String    ${first_split}[1]    )
        Append To List    ${hosts}    ${second_split}[0]
    END
    sort list    ${hosts}
    Return From Keyword    @{hosts}

Connect to Cbctest
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to connect to the cbc server
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No. | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Connect to Cbctest |
    ...
    csn.connect to    hostname=${cbctest_ip}
    ...               username=${cbctest_usr}
    ...               password=${cbctest_psw}
    ...               alias=${cbctest_alias}

Connect To VM
    [Arguments]    ${alias}=VM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to connect VM
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The alias assign to this connection to VM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Connect To VM |  |
    ...    | Connect To VM | alias=vm_conn |
    ...
    csn.connect_to    hostname=${PC_HOST}    username=${PC_USER}
    ...               password=${PC_PASSWORD}    alias=${alias}

Disconnect VM
    [Arguments]    ${alias}=VM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to disconnect VM
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The alias assign to this connection to VM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Disconnect VM |  |
    ...    | Disconnect VM | alias=vm_conn |
    ...
    csn.disconnect    connection=${alias}

Reboot VM
    [Arguments]    ${timeout}=${300}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is for reboot VM
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | The max time for connecting to VM, default is 300s |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Reboot VM |  |
    ...    | Reboot VM | timeout=30 |
    ...
    Connect To VM    alias=VM
    csn.execute    command=sudo reboot    connection=${alias}    timeout=${timeout}
    wait until keyword succeeds    10 min    10s    Connect To VM    alias=VM

#----COAM Login Logout Operations----------------------------------------------------------------------------
COAM_Admin.Login
    [Arguments]    ${bts_host}=${ASIB_IP}    ${username}=${http_USERNAME}    ${password}=${http_PASSWORD}
    ...            ${bts_port}=${443}    ${log_dir}=${RESULT_DIR}    ${alias}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                login to ASIB for connect to http address:
    ...                ${ASIB_IP}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                In ute test lines, this address is set to 192.168.255.129
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bts_host} | No | The control board ASIX address, default is ${ASIB_IP} |
    ...    | ${username} | No | The webEM username, default is ${http_USERNAME} |
    ...    | ${password} | No | The webEM password, default is ${http_PASSWORD} |
    ...    | ${bts_port} | No | The port, default is ${443} |
    ...    | ${log_dir} | No | The location for log, default is ${RESULT_DIR} |
    ...    | ${alias} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Login |  |
    ...    | COAM_Admin.Login | alias=coam_admin |
    ...
    coam.connect_to
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    admin_api_log_dir=${log_dir}
    ...    name=${alias}

COAM_Admin.local_Login
    [Arguments]    ${bts_host}=${ASIB_IP_local}    ${username}=${http_USERNAME}    ${password}=${http_PASSWORD}
    ...            ${bts_port}=${443}    ${log_dir}=${RESULT_DIR}    ${alias}=COAM_local
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                login to ASIB by indicated local address: 192.168.255.129
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bts_host} | No | The control board ASIX address, default is ${ASIB_IP_local} |
    ...    | ${username} | No | The webEM username, default is ${http_USERNAME} |
    ...    | ${password} | No | The webEM password, default is ${http_PASSWORD} |
    ...    | ${bts_port} | No | The port, default is ${443} |
    ...    | ${log_dir} | No | The location for log, default is ${RESULT_DIR} |
    ...    | ${alias} | No | The alias for this connection, default is COAM_local |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.local_Login |  |
    ...    | COAM_Admin.local_Login | alias=coam_local |
    ...
    coam.connect_to
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    admin_api_log_dir=${log_dir}
    ...    name=${alias}

COAM_Admin.Login for ENB
    [Arguments]    ${bts_host}=${ENB_IP}    ${username}=${http_USERNAME}    ${password}=${http_PASSWORD}
    ...            ${bts_port}=${443}    ${log_dir}=${RESULT_DIR}    ${alias}=COAM_ENB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                login to eNB for connect to http address by admin
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bts_host} | No | The control board ASIX address, default is ${ENB_IP} |
    ...    | ${username} | No | The webEM username, default is ${http_USERNAME} |
    ...    | ${password} | No | The webEM password, default is ${http_PASSWORD} |
    ...    | ${bts_port} | No | The port, default is ${443} |
    ...    | ${log_dir} | No | The location for log, default is ${RESULT_DIR} |
    ...    | ${alias} | No | The alias for this connection, default is COAM_ENB |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Login for ENB |  |
    ...    | COAM_Admin.Login for ENB | alias=coam_enb |
    ...
    coam.connect_to
    ...    bts_host=${bts_host}
    ...    bts_port=${bts_port}
    ...    username=${username}
    ...    password=${password}
    ...    use_ssl=${True}
    ...    update_interval=${5000}
    ...    admin_api_log_dir=${log_dir}
    ...    name=${alias}

COAM_Admin.Logout
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Log out of the webEM admin connection
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Logout |  |
    ...    | COAM_Admin.Logout | connection=coam_conn |
    ...
    coam.teardown    connection=${connection}

COAM_Admin.Logout_local
    [Arguments]    ${connection}=COAM_local
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Log out of the webEM admin connection use local IP
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM_local |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Logout_local |  |
    ...    | COAM_Admin.Logout_local | connection=coam_local |
    ...
    coam.teardown    connection=${connection}

COAM_Admin.Logout for ENB
    [Arguments]    ${connection}=COAM_ENB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Log out of the webEM admin connection of eNB
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM_ENB |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Logout for ENB |  |
    ...    | COAM_Admin.Logout for ENB | connection=coam_enb |
    ...
    coam.teardown    connection=${connection}

#----SWB Version Operations----------------------------------------------------------------------------------
Get SW VER From SBTS and Convert Trunk or Branch
    [Arguments]    ${bts_host}=${ASIB_IP}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to get the SWB verion and branch info with Trunk or Branch format.
    ...                Firstly read from BTS active SWB version, if failed, then read from the UTE reservation info.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | ${new_sw_version} | return new sw version |
    ...    | ${branch} | return branch tag |
    ...
    ...    Example
    ...    | ${sw_version} | ${branch} | Get SW VER From SBTS and Convert Trunk or Branch |
    ...
    wait until keyword succeeds    3x    1min    COAM_Admin.Login    bts_host=${bts_host}
    ${status} =    run keyword and return status    COAM_Admin.GetSBTSSWVersion
    ${SW_version} =    Run Keyword If    '${status}' == 'False'    Get SW VER From json file
    ...                          ELSE                              COAM_Admin.GetSBTSSWVersion
    ${SW_version_list1}    split string    ${SW_version}    _
    ${trunk_or_branch}    get from list    ${SW_version_list1}    2
    ${branch_tag}    get from list    ${SW_version_list1}    0
    ${SW_version_list2}    split string    ${SW_version}    ENB
    ${SBTS_VER_FULL}    get from list    ${SW_version_list2}    1
    ${branch}=    Run keyword if    ${trunk_or_branch}==${9999}    Set Variable   SBTS00
    ...   ELSE       Set Variable   ${SW_version_list1[0]}
    ${new_sw_version}    Set Variable    ${branch}_ENB${SBTS_VER_FULL}
    [Return]    ${new_sw_version}    ${branch}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

COAM_Admin.GetSBTSSWVersion
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to get the active sw build version by COAM.
    ...                If the active SWB cannot be read, then status false will be returned.
    ...                The returned SWB version format is: SBTSXXX_ENB_XXXX_XXXXXX_XXXXXX
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${active_sw_version} | return the active sw version |
    ...
    ...    Example
    ...    | ${sw_version} | COAM_Admin.GetSBTSSWVersion |  |
    ...    | ${sw_version} | COAM_Admin.GetSBTSSWVersion | connection=coam_conn |
    ...
    ${sw_info}    coam.get_software_info    connection=${connection}    timeout=10
    ${active_sw_version}    Set Variable    ${sw_info['Active SW version']}
    Run Keyword If    "${active_sw_version}"=="" or "${active_sw_version}"=="-"    Fail    Please Enter Correct Parameter!
    ${passive_sw_version}    Set Variable    ${sw_info['Passive SW version']}
    Run Keyword If    "${passive_sw_version}"=="" or "${passive_sw_version}"=="-"    Fail    Please Enter Correct Parameter!
    ${planned_sw_version}    Set Variable    ${sw_info['Planned SW version']}
    [Return]    ${active_sw_version}

Get SW VER From json file
    [Arguments]    ${reservation_path}=/opt/ute/reservation.json
    ...            ${connection}=VM    ${VM_IP}=${PC_HOST}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is to read the SWB version information from UTE reservation file.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${reservation_path} | No | The ute reservation json file full path |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${VM_IP} | No | The test line's VM IP addr |
    ...
    ...    | Return Value | Description |
    ...    | ${SW_version} | return the reservation sw version |
    ...
    ...    Example
    ...    | ${sw_version} | Get SW VER From json file |  |
    ...    | ${sw_version} | Get SW VER From json file | connection=vm_conn |
    ...
    csn.connect_to    hostname=${VM_IP}    username=ute    password=ute    alias=VM
    ${reservation_info_file}=    OperatingSystem.Get File    ${reservation_path}
    &{reservation_info}=    json.Loads    ${reservation_info_file}
    ${SW_version}    Get From Dictionary    ${reservation_info}    enb_build
    [Return]    ${SW_version}

COAM_Admin.GetSWVersion
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to get the active sw build version by COAM.
    ...                If the active SWB cannot be read, then the None value will be returned.
    ...                The status will NOT be set to false.
    ...                The returned SWB version format is: XXXX.XXXXXX.XXXXXX
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${active_sw_version} | return the active sw version |
    ...
    ...    Example
    ...    | ${sw_version} | COAM_Admin.GetSWVersion |  |
    ...    | ${sw_version} | COAM_Admin.GetSWVersion | connection=coam_conn |
    ...
    ${sw_info}    coam.get_software_info    connection=${connection}    timeout=10
    ${active_sw_version}    Run Keyword If    "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...    COAM_Admin.TransferSWVersion    ${sw_info['Active SW version']}
    ...    ELSE    Set Variable    ${None}
    ${passive_sw_version}    Run Keyword If    "${sw_info['Passive SW version']}"!="${None}" and "${sw_info['Passive SW version']}"!=""
    ...    COAM_Admin.TransferSWVersion    ${sw_info['Passive SW version']}
    ...    ELSE    Set Variable    ${None}
    ${planned_sw_version}    Run Keyword If    "${sw_info['Planned SW version']}"!="${None}" and "${sw_info['Planned SW version']}"!=""
    ...    COAM_Admin.TransferSWVersion    ${sw_info['Planned SW version']}
    ...    ELSE    Set Variable    ${None}
    [Return]    ${active_sw_version}

COAM_Admin.TransferSWVersion
    [Arguments]    ${sw_version}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Transfer the SWB version format from: SBTSXXX_ENB_XXXX_XXXXXX_XXXXXX to XXXX.XXXXXX.XXXXXX
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw_version} | Yes | The SWB version in format: SBTSXXX_ENB_XXXX_XXXXXX_XXXXXX |
    ...
    ...    | Return Value | Description |
    ...    | ${new_sw_version} | The SWB version in format: XXXX.XXXXXX.XXXXXX |
    ...
    ...    Example
    ...    | ${sw_version} | COAM_Admin.TransferSWVersion | sw_version=${sw_info['Active SW version']} |
    ...
    Run Keyword If    "${sw_version}"=="" or "${sw_version}"=="-"    Fail    Please Enter Correct Parameter!
    @{list}    Split String    ${sw_version}    _
    ${first}    Set Variable    ${${list[-3]}}
    ${second}    Set Variable    ${${list[-2]}}
    ${third}    Set Variable    ${${list[-1]}}
    ${new_sw_version}    Set Variable    ${first}.${second}.${third}
    [Return]    ${new_sw_version}

#----BTS Status and Onair Operations-------------------------------------------------------------------------
COAM_Admin.GetBTSStatusforLTE
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Get the LTE BTS status: system, baseband, radio, cells, general.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${system_status} | The system status |
    ...    | ${baseband_status} | The baseband status |
    ...    | ${radio_status} | The radio status |
    ...    | ${cells_status} | The cells status |
    ...    | ${general_status} | The general status |
    ...
    ...    Example
    ...    | ${system_status} | ${baseband_status} | ${radio_status} | ${cells_status} | ${general_status} | COAM_Admin.GetBTSStatusforLTE |
    ...
    ${bts_info}    coam.get_bts_info    connection=${connection}    timeout=10
    ${system_status}    Set Variable    ${bts_info['systemModules'][0]['status']}
    ${baseband_status}    Set Variable    ${bts_info['basebandModules'][0]['status']}
    ${radio_status}    Set Variable    ${bts_info['radioModules']['rmod'][0]['status']}
    ${cells_status}    Set Variable    ${bts_info['cells']['lte'][0]['status']}
    ${general_status}    Set Variable    ${bts_info['status']}
    [Return]    ${system_status}    ${baseband_status}    ${radio_status}    ${cells_status}    ${general_status}

COAM_Admin.GetBTSStatusforNR
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Get the NR BTS status: system, baseband, radio, cells, general.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${system_status} | The system status |
    ...    | ${baseband_status} | The baseband status |
    ...    | ${radio_status} | The radio status |
    ...    | ${cells_status} | The cells status |
    ...    | ${general_status} | The general status |
    ...
    ...    Example
    ...    | ${system_status} | ${baseband_status} | ${radio_status} | ${cells_status} | ${general_status} | COAM_Admin.GetBTSStatusforNR |
    ...
    ${bts_info}    coam.get_bts_info    connection=${connection}    timeout=10
    ${system_status}    Set Variable    ${bts_info['systemModules'][0]['status']}
    ${baseband_status}    Set Variable    ${bts_info['basebandModules'][0]['status']}
    ${radio_status}    Set Variable    ${bts_info['radioModules']['rmod'][0]['status']}
    ${cells_status}    Set Variable    ${bts_info['cells']['nr'][0]['status']}
    ${general_status}    Set Variable    ${bts_info['status']}
    [Return]    ${system_status}    ${baseband_status}    ${radio_status}    ${cells_status}    ${general_status}

COAM_Admin.getcellinfo
    [Arguments]    ${cell_type}=nr    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The the BTS cell information.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_type} | No | The cell type, default is nr |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${cell_info} | Cell information |
    ...
    ...    Example
    ...    | COAM_Admin.getcellinfo |  |  |
    ...    | COAM_Admin.getcellinfo | cell_type=nr | connection=coam_conn |
    ...
    ${cell_info}    coam.get_cells_info    cell_type=${cell_type}    timeout=10    connection=${connection}
    [Return]    ${cell_info}

COAM_Admin.getsubcellsinfo
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The the BTS subcell information.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${subcell_info} | Subcell information |
    ...
    ...    Example
    ...    | COAM_Admin.getsubcellsinfo |  |
    ...    | COAM_Admin.getsubcellsinfo | connection=coam_conn |
    ...
    ${subcell_info}    coam.get_subcells_info    timeout=10    connection=${connection}
    [Return]    ${subcell_info}

Get All Cell Id
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is to get the BTS all cell ids.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${cell_list} | Cell list |
    ...
    ...    Example
    ...    | Get All Cell Id |  |
    ...    | Get All Cell Id | connection=coam_conn |
    ...
    ${output}=    coam.get_cells_info    connection=${connection}
    Log Many    ${output}
    ${cell_list}    create list
    FOR    ${cell}    IN    @{output}
        append to list    ${cell_list}    ${cell['globalCellId']}
    END
    [Return]    ${cell_list}

COAM Check GNB RU Status
    [Arguments]    ${connection}=COAM    ${ru_sn}=all
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is to check multiple RU status
    ...                :ru_sn default check all ru detected, also support add RU sn number to just check this ru status.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${ru_sn} | No | By default check all ru detected. You can give the RU sn number to just check this ru status |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM Check GNB RU Status |  |
    ...    | COAM Check GNB RU Status | connection=coam_conn |
    ...
    Log to console    Check RU status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${ru_item}    Set variable    ${0}
    Should be true    ${count_RUs}>=${1}    msg=Check RU status failed as total RU number is less than 1
    FOR    ${ru}    IN    @{list_RUs}
        Run keyword if    '${ru_sn}'!='all' and '${ru_sn}'!='${ru['serialNumber']}'    continue for loop
        ${ru_item}=    evaluate    ${ru_item}+1
        __Coam Status Check    status=${ru['status']}    checked_part=RU
    END
    should be true    ${ru_item}>${0}    msg=Check RU status failed as no RU found !!!

COAM_Admin.CheckBTSOnAir
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Check whether the BTS is onair.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.CheckBTSOnAir |  |
    ...    | COAM_Admin.CheckBTSOnAir | connection=coam_conn |
    ...
    ${bts_info}    coam.get_bts_info    connection=${connection}    timeout=10
    ${status}    Set Variable    ${bts_info['status']['proceduralState']}
    Should Contain    ${status}    OnAir

COAM_Admin.CheckBTSConfigured
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Check whether the BTS is onair.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.CheckBTSConfigured |  |
    ...    | COAM_Admin.CheckBTSConfigured | connection=coam_conn |
    ...
    ${bts_info}    coam.get_bts_info    connection=${connection}    timeout=10
    ${status}    Set Variable    ${bts_info['status']['proceduralState']}
    Log to Console    Bts stats is ${status}
    Should Contain    ${status}    Configured

COAM_Admin.CheckBTSCommissioned
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Check whether the BTS is onair.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.CheckBTSConfigured |  |
    ...    | COAM_Admin.CheckBTSConfigured | connection=coam_conn |
    ...
    ${bts_info}    coam.get_bts_info    connection=${connection}    timeout=10
    ${status}    Set Variable    ${bts_info['status']['proceduralState']}
    Log to Console    Bts stats is ${status}
    Should Contain    ${status}    Commissioned

_Get BTS Information From btsinfo
    [Arguments]    ${info_key}    ${bts_index}=${0}
    COAM_Admin.Login     bts_host=${tl.gnbs[${bts_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${bts_index}].cu.oam_http_connection_details.password}
    ...    alias=get_bts_info_${bts_index}
    ${bts_info}    coam.get_bts_info    connection=get_bts_info_${bts_index}    timeout=10
    ${value}    get_value_by_unique_key    ${bts_info}    ${info_key}
    [Return]    ${value}
    [Teardown]    COAM_Admin.Logout    get_bts_info_${bts_index}

Wait Until RRU Configured
    [Arguments]    ${connection}=COAM    ${timeout}=200
    [Documentation]    This keyword is used to wait rru configured
    Log To Console    ...wait rru configured...
    COAM_Admin.Login
    ${bts_hw_info}    coam.get_bts_info   connection=${connection}
    ${rru_list}    Set Variable    ${bts_hw_info['radioModules']['rmod']}
    ${rru_list_len}    Get Length    ${rru_list}
    FOR    ${rru_id}    IN RANGE   ${rru_list_len}
        Wait Until Keyword Succeeds    ${timeout}    5
        ...    _Verify RRU Is Configured    ${rru_id}    ${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

_Verify RRU Is Configured
    [Arguments]    ${rru_id}    ${connection}=COAM
    ${bts_hw_info}    coam.get_bts_info   connection=${connection}
    Should Be Equal    ${bts_hw_info['radioModules']['rmod'][${rru_id}]['status']['proceduralStatus']}    configured

Wait Unit Bts Configured
    [Arguments]    ${connection}=COAM    ${timeout}=300
    [Documentation]    This keyword is used to wait rru configured
    Log To Console    ...wait bts configured...
    COAM_Admin.Login
    Wait Until Keyword Succeeds    ${timeout}    5s    COAM_Admin.CheckBTSConfigured
    ...    ${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Verify 5G cells by NRCELLGRP should be onair
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify all the subcells status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Verify 5G cells by NRCELLGRP should be onair |  |
    ...    | Verify 5G cells by NRCELLGRP should be onair | connection=coam_conn |
    ...
    ${cell_info}    coam.get_subcells_status    timeout=20    connection=${connection}
    ${number_of_cell_group_info}    get length    ${cell_info}
    FOR    ${index}    IN RANGE    ${number_of_cell_group_info}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
        5G cells in cell group should be onair    ${cell_from_cellgrp}
    END

5G cells in cell group should be onair
    [Arguments]    ${cell_from_cellgrp}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify a single cell status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${cell_from_cellgrp} | Yes | The cell need to be checked |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | 5G cells in cell group should be onair | cell_from_cellgrp=${cell_from_cellgrp} |
    ...
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR    ${cell}    IN    @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['administrativeState']}    Unlocked
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['availabilityStatus']}    Online
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}    Enabled
    END

Verify LTE cells should be onair
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify LTE cells status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Verify LTE cells should be onair |  |
    ...    | Verify LTE cells should be onair | connection=coam_conn |
    ...
    ${cell_info_lte}    coam.get_cells_info    cell_type=lte    timeout=10    connection=${connection}
    ${number_of_cell}    get length    ${cell_info_lte}
    FOR    ${index}    IN RANGE    ${number_of_cell}
        ${status}    Set Variable    ${cell_info_lte[${index}]['status']}
        Run Keyword If    '${status['administrativeState']}'=='Unlocked'
        ...    Run Keywords    Should Be Equal As Strings    ${status['availabilityStatus']}    Online
        ...    AND    Should Be Equal As Strings    ${status['operationalState']}    Enabled
        ...    ELSE
        ...    Run Keywords    Should Be Equal As Strings    ${status['administrativeState']}    unlocked
        ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
        ...    AND    Should Be Equal As Strings    ${status['operationalState']}    enabled
    END

Verify 5G cells should be onair
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify 5G cells status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Verify 5G cells should be onair |  |
    ...    | Verify 5G cells should be onair | connection=coam_conn |
    ...
    ${cell_info_5g}    coam.get_cells_info    cell_type=nr    timeout=10    connection=${connection}
    ${number_of_cell}    get length    ${cell_info_5g}
    FOR    ${index}    IN RANGE    ${number_of_cell}
        ${status}    Set Variable    ${cell_info_5g[${index}]['status']}
        ${has_availabilityStatus}    ${value}    Run Keyword And Ignore Error
        ...    dictionary should contain key    ${status}    availabilityStatus
        ${has_usageState}    Run Keyword And Return Status
        ...    dictionary should contain key    ${status}    usageState
        ${operationalState}    Convert To Lower Case    ${status['operationalState']}
        Run Keyword If    '${has_availabilityStatus}'=='PASS'
        ...    Run Keywords
        ...    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked
        ...    AND    Should Be True   "${status['availabilityStatus']}"=="Online"
        ...    AND    Should Be True   "${operationalState}"=="enabled"
        Run Keyword If    ${has_usageState}
        ...    Run Keywords    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked
        ...    AND    Should Be True   "${status['usageState']}"=="Active" or "${status['usageState']}"=="Idle"
        ...    AND    Should Be True   "${operationalState}"=="enabled"
        ...    ELSE
        ...    Run Keywords    Should Be Equal As Strings    ${status['administrativeState']}    Unlocked
        ...    AND    Should Be True   "${status['blockingState']}"=="Unblocked"
        ...    AND    Should Be True   "${operationalState}"=="enabled"
    END

Verify bts and all cell status should be onair
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Verify all the LTE and 5G cells status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Verify bts and all cell status should be onair |  |
    ...    | Verify bts and all cell status should be onair | connection=coam_conn |
    ...
    COAM_Admin.Login
    ${bts_status}    coam.get_bts_statuses    timeout=20    connection=${connection}
    ${status}    Set Variable    ${bts_status['proceduralState']}
    Should Contain    ${status}    OnAir
    Verify LTE cells should be onair
    Verify 5G cells should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Reset site and wait cell onair
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Reset the BTS and verify all the 5G cells status should be correct.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Reset site and wait cell onair |
    ...
    COAM_Admin.ResetSite
    Sleep    600
    wait until keyword succeeds    5 min    5 sec    Verify 5G cells should be onair

#----SWB/Upgrade/Rollback Operations-------------------------------------------------------------------------
Upgrade gNB With Indicated Version
    [Arguments]    ${indicated_sw_version}
    [Documentation]    Author: Du Ning
    ...                Contact: ning.du@nokia-sbell.com
    ...                This keyword is to upgrade the gNB SWB with the indicated version. The SWB will be
    ...                downloaded from UTE file server.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${indicated_sw_version} | Yes | Give the SWB version, e.g. SBTS00_ENB_9999_210906_000002 |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example:
    ...    | Upgrade gNB With Indicated Version | indicated_sw_version=${EXPECT_SW_VERSION} |
    ...    | Upgrade gNB With Indicated Version | indicated_sw_version=SBTS00_ENB_9999_210906_000002 |
    ...
    Log To Console    \nWill be upgraded to SWB Version: ${indicated_sw_version}
    ssh.Connect to    hostname=127.0.0.1    username=ute    password=ute    alias=VM
    ${swb_cmd}=    Catenate
    ...    mkdir ${indicated_sw_version} &&
    ...    cd ${indicated_sw_version} &&
    ...    wget http://files.ute.nsn-rdnet.net/builds/enb/base/${indicated_sw_version}/${indicated_sw_version}_release_BTSSM_downloadable.zip
    ssh.execute    command=${swb_cmd}    connection=VM
    ssh.disconnect    connection=VM
    COAM_Admin.UpdateSW for SRAN    VM_IP=${PC_HOST}
    ...                             directory=/home/ute/${indicated_sw_version}/
    Log To Console    Wait for the upgrade done and stable.
    wait until keyword succeeds    3x    1min    COAM_Admin.Login
    Wait until keyword succeeds    15 min    10 sec    COAM Check GNB Systemboard Status
    Wait until keyword succeeds    15 min    10 sec    COAM Check GNB Basebandboard Status
    Wait until keyword succeeds    15 min    10 sec    COAM Check GNB RU Status
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

__Coam Status Check
    [Arguments]    ${status}   ${checked_part}
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                use for check common status status
    ...                private keywords, please don't use it in case robot
    ...    | Input Parameters | Man. | Description |
    ...    | ${status} | yes | status get from coam get status msg |
    ...    | ${checked_part} | yes | rru or system or basebandboard |
    ${has_availabilityStatus}    ${value}    Run Keyword And Ignore Error
    ...    dictionary should contain key    ${status}    availabilityStatus
    Run Keyword If    '${has_availabilityStatus}'=='PASS'    Run Keywords
    ...    Should be equal as strings    ${status['administrativeState']}    Unlocked
    ...    msg=Current ${checked_part} administrativeState is not in Unlocked status    ignore_case=${True}
    ...    AND    Should be equal as strings    ${status['availabilityStatus']}    Online
    ...    msg=Current ${checked_part} availabilityStatus is not in Online status    ignore_case=${True}
    ...    ELSE    Run Keywords
    ...    Should be equal as strings    ${status['administrativeState']}    Unlocked
    ...    msg=Current ${checked_part} administrativeState is not in Unlocked status    ignore_case=${True}
    ...    AND    Should be equal as strings    ${status['operationalState']}    enabled
    ...    msg=Current ${checked_part} operationalState is not in enabled status    ignore_case=${True}

COAM Check GNB Systemboard Status
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Zou Shuang
    ...                Contact: shuang.zou@nokia-sbell.com
    ...                This KW is to check multiple systemboard status
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM Check GNB Systemboard status |
    ...    | COAM Check GNB Systemboard status | connection=coam_conn |
    ...
    Log to console    Check Systemboard status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_system}    Set variable    ${hw_info['systemModules']}
    ${count_system}    Get length    ${list_system}
    Should be true    ${count_system}>=${1}    msg=Check systemboard status failed as total systemboard number is less than 1
    FOR    ${system}    IN    @{list_system}
        __Coam Status Check    status=${system['status']}    checked_part=systemModules
    END

COAM Check GNB Basebandboard Status
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Zou Shuang
    ...                Contact: shuang.zou@nokia-sbell.com
    ...                This KW is to check multiple basebandboard status
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM Check GNB Basebandboard status |
    ...    | COAM Check GNB Basebandboard status | connection=coam_conn |
    ...
    Log to console    Check Basebandboard status from GNB
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_baseband}    Set variable    ${hw_info['basebandModules']}
    ${count_baseband}    Get length    ${list_baseband}
    Should be true    ${count_baseband}>=${1}    msg=Check basebandboard status failed as total basebandboard number is less than 1
    FOR    ${baseband}    IN    @{list_baseband}
        __Coam Status Check    status=${baseband['status']}    checked_part=basebandModules
    END

COAM_Admin.UpdateSW for SRAN
    [Arguments]    ${bts_host}=${ASIB_IP}    ${activate}=yes    ${connection}=COAM
    ...            ${VM_IP}=${PC_HOST}    ${directory}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Upgrade the SWB for BTS. The SWB should be exist in /home/ute/Downloads .
    ...                And the file should be in this name format: *_release_BTSSM_downloadable*.zip
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${bts_host} | No | The BTS control board ASIX IP address. Default is ${ASIB_IP} |
    ...    | ${activate} | No | Whether the SWB should be activated after upgrade to BTS. Default is yes |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${VM_IP} | No | The test line's VM IP address. Default is ${PC_HOST} |
    ...    | ${directory} | No | The SWB package's location. Default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.UpdateSW for SRAN |
    ...
    COAM_Admin.Login    bts_host=${bts_host}
    ...                 username=Nemuadmin
    ...                 password=nemuuser
    Log To Console    Start Software Updating...
    ${should_activate}    Set Variable If    '${activate}'=='yes'    ${True}
    ...    '${activate}'=='no'    ${False}
    csn.connect_to    hostname=${VM_IP}    username=ute    password=ute    alias=VM
    set suite variable    ${alias}    VM
    @{SBTS_Version}    common_commands.get_file_names_under_directory    directory=${directory}
    ...                connection=${alias}
    ...                file_indicator=*_release_BTSSM_downloadable*.zip
    coam.update_software    sw_package=${directory}/${SBTS_Version[0]}
    ...                     should_activate=${True}
    ...                     timeout=${3600}
    ...                     connection=${connection}
    Log To Console    Software Update Finished, Waiting For Resetting...
    Sleep    100s
    [Teardown]    COAM_Admin.Logout

Download SW build from jenkins
    [Arguments]    ${SBTS_Version}=SBTS00_ENB_9999_210815_000001    ${hostname}=10.106.197.46    ${username}=root    ${password}=RRM3_NOKIA
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to download sw build from local Jenkins server.
    ...                The SWB should be exist in local Jenkins server path: /ephemeral/jenkins/workspace/images/${SBTS_Version}/ .
    ...                And the file should be in this name format: *_release_BTSSM_downloadable_A54.zip
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${SBTS_Version} | Yes | The SWB version you want to download |
    ...    | ${hostname} | No | The local jenkins server IP addr. Default is 10.106.197.46 |
    ...    | ${username} | No | The local jenkins server username. Default is root |
    ...    | ${password} | No | The local jenkins server password. Default is RRM3_NOKIA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Download SW build from jenkins | SBTS00_ENB_9999_210925_000001 |
    ...
    csn.connect_to    hostname=${hostname}    username=${username}    password=${password}    alias=jenkins
    csn.download file
    ...    remote_path=/ephemeral/jenkins/workspace/images/${SBTS_Version}/${SBTS_Version}_release_BTSSM_downloadable_A54.zip
    ...    local_path=/home/ute/Downloads/${SBTS_Version}_release_BTSSM_downloadable_A54.zip
    ...    connection=jenkins
    Sleep    60s
    [Teardown]    csn.disconnect    connection=jenkins

COAM_Admin.UpdateSW_local
    [Arguments]    ${SW_Buid_path}=/home/ute/Downloads/SBTS00_ENB_9999_210925_000001_release_BTSSM_downloadable_A54.zip
    ...            ${activate}=yes    ${connection}=COAM_local
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Upgrade the SWB for BTS. The SWB should be exist in /home/ute/Downloads .
    ...                And the file's full path and name should be provided.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${SW_Buid_path} | Yes | The SWB file's full path and name |
    ...    | ${activate} | No | Whether the SWB should be activated after upgrade to BTS. Default is yes |
    ...    | ${connection} | No | The alias for this connection, default is COAM_local |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.UpdateSW_local | SW_Buid_path=/home/ute/Downloads/SBTS00_ENB_9999_210925_000001_release_BTSSM_downloadable_A54.zip |
    ...
    COAM_Admin.local_Login
    Log To Console    Start Software Updating...
    ${should_activate}    Set Variable If    '${activate}'=='yes'    ${True}
    ...    '${activate}'=='no'    ${False}
    coam.update_software    sw_package=${SW_Buid_path}    should_activate=${True}    timeout=${3600}    connection=${connection}
    Log To Console    Software Update Finished, Waiting For Resetting...
    COAM_Admin.Logout_local

Get SRAN Package
    [Arguments]    ${Component}    ${sw_name}    ${package_store_path}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to download sran package by command from http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${Component} | Yes | The SWB branch, E.g. SBTS00, SBTS22R1 |
    ...    | ${sw_name} | Yes | The SWB version, E.g. SBTS00_ENB_9999_210925_000001 |
    ...    | ${package_store_path} | No | The folder to store the downloaded SWB, default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | ${SW_Buid_path} | The folder which stores the downloaded SWB |
    ...
    ...    Example
    ...    | ${SW_Buid_path}= | Get SRAN Package | Component=SBTS00 | sw_name=SBTS00_ENB_9999_210925_000001 |
    ...
    ${sw_url}=    Catenate    sudo wget ${arti}${Component}/${sw_name}/${sw_name}_release_BTSSM_downloadable_A54.zip -nv -P ${package_store_path}
    ${status}=    run keyword and return status    file should not exist    ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    ${cmd}=    Catenate    sudo rm -f ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    Run Keyword If    not ${status}    OperatingSystem.Run    ${cmd}
    ${res}=    Run    ${sw_url}
    file should exist    ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    ${SW_Buid_path}=    Set Variable    ${package_store_path}/${sw_name}_release_BTSSM_downloadable_A54.zip
    [Return]    ${SW_Buid_path}

Get SRAN latest build by wft link with promotion_tags
    [Arguments]    ${branch}    ${release_prefix}=${branch}_ENB    ${suffix}=A54
    ...            ${promotion_tags}=RAN_MRAT_CRT    ${target_dir}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get sran latest promotion build by wft and download sw build by command
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${branch} | Yes | The SWB branch, E.g. SBTS00, SBTS22R1 |
    ...    | ${release_prefix} | No | The SWB version's prefix, E.g. SBTS00_ENB. Suggest use the default value |
    ...    | ${suffix} | No | The SWB version's suffix, Default value is A54 |
    ...    | ${promotion_tags} | No | The SWB promotion tags, default is RAN_MRAT_CRT |
    ...    | ${target_dir} | No | The SWB store folder after download, default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | ${latest_build_name} | The latest SWB version for the given branch and promotion tags |
    ...
    ...    Example
    ...    | ${latest_promotion_swb}= | Get SRAN latest build by wft link with promotion_tags | branch=SBTS00 |
    ...
    ${package_states}    Create List    RELEASED    RELEASED_WITH_RESTRICTIONS
    ${latest_build_name}    wft.get_name_of_latest_build    branch=${branch}
    ...                          release_prefix=${release_prefix}
    ...                          package_states=${package_states}
    ...                          promotion_tags=${promotion_tags}
    Log To Console    ${latest_build_name}
    ${SW_Buid_path}    Get SRAN Package    Component=${branch}    sw_name=${latest_build_name}
    ...                                    package_store_path=${target_dir}
    [Return]    ${latest_build_name}

Get SRAN latest build by wft link
    [Arguments]    ${branch}=SBTS00    ${release_prefix}=${branch}_ENB    ${suffix}=A54
    ...            ${target_dir}=/home/ute/Downloads
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get sran latest build (without promotion tag) by wft and download sw build by command
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${branch} | Yes | The SWB branch, E.g. SBTS00, SBTS22R1 |
    ...    | ${release_prefix} | No | The SWB version's prefix, E.g. SBTS00_ENB. Suggest use the default value |
    ...    | ${suffix} | No | The SWB version's suffix, Default value is A54 |
    ...    | ${target_dir} | No | The SWB store folder after download, default is /home/ute/Downloads |
    ...
    ...    | Return Value | Description |
    ...    | ${latest_build_name} | The latest SWB version for the given branch and promotion tags |
    ...
    ...    Example
    ...    | ${latest_swb}= | Get SRAN latest build by wft link | branch=SBTS00 |
    ...
    ${package_states}    Create List    RELEASED    RELEASED_WITH_RESTRICTIONS
    ${latest_build_name}    wft.get_name_of_latest_build    branch=${branch}
    ...                          release_prefix=${release_prefix}
    ...                          package_states=${package_states}
    Log To Console    ${latest_build_name}
    ${SW_Buid_path}    Get SRAN Package    Component=${branch}    sw_name=${latest_build_name}
    [Return]    ${latest_build_name}

Update SW Build By UTE CLOUD
    [Arguments]    ${hostname}=${PC_HOST}    ${username}=${PC_USER}    ${password}=${PC_PASSWORD}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get SWB from ute file server and upgrade the SWB.
    ...                The SWB version is fetched from BTS active SWB version, if failed, then fetched from the UTE reservation info.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${hostname} | No | The test line's VM's IP address. Default is ${PC_HOST} |
    ...    | ${username} | No | The test line's VM's username. Default is ${PC_USER} |
    ...    | ${password} | No | The test line's VM's password. Default is ${PC_PASSWORD} |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Update SW Build By UTE CLOUD |
    ...
    ${new_sw_version}    ${branch}    Get SW VER From SBTS and Convert Trunk or Branch
    ssh.Connect to    hostname=${hostname}    username=${PC_USER}    password=${PC_PASSWORD}    alias=VM
    ${cmd}=    Catenate    wget http://files.ute.nsn-rdnet.net/builds/enb/base/${new_sw_version}/${new_sw_version}_release_BTSSM_downloadable.zip
    ssh.execute    command=${cmd}    connection=VM
    ssh.disconnect    connection=VM
    run keyword and ignore error    COAM_Admin.Login
    COAM_Admin.UpdateSW for SRAN    VM_IP=${PC_HOST}
    ...                             directory=/home/ute/
    Sleep    800s

Update SW Build With Check FID23
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used for update sw build again after FID 23 is appeared
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Update SW Build With Check FID23 |  |
    ...    | Update SW Build With Check FID23 | connection=coam_conn |
    ...
    COAM_Admin.Login
    @{alarms}    coam.get_active_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{alarms}
        Run Keyword If    ${alarm['faultId']}==${23}    Update SW Build By UTE CLOUD
        Exit For Loop If    ${alarm['faultId']}==${23}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Rollback software for SRAN
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to rollback sw build in sbts
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Rollback software for SRAN |  |
    ...    | Rollback software for SRAN | connection=coam_conn |
    ...
    COAM_Admin.Login
    coam.rollback_software    connection=${connection}
    [Teardown]    run keyword and ignore error    COAM_Admin.Logout

Rollback software twice for SRAN
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to rollback twice (rollback to passive and come back again) sw build in sbts.
    ...                And verify the cell status should be onair
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Rollback software twice for SRAN |  |
    ...    | Rollback software twice for SRAN | connection=coam_conn |
    ...
    Rollback software for SRAN    connection=${connection}
    sleep    600s
    Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair
    ${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
    Run Keyword If    ${cell_status}==${False}    reset site and wait cell onair
    Rollback software for SRAN    connection=${connection}
    sleep    600s
    Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair
    ${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
    Run Keyword If    ${cell_status}==${False}    reset site and wait cell onair

#----Lock/Unlock/Reset Operations----------------------------------------------------------------------------
COAM_Admin.lock
    [Arguments]    ${dist_name}    ${timeout}=${800}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is a general lock function, could be used for RMOD, CELL, BTS.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | Dist_name of RMOD or cell or LANE or site, e.g. MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2 |
    ...    | ${timeout} | No | The timeout for this kw, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lock | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2 | connection=coam_conn |
    ...
    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}

COAM_Admin.lockcell
    [Arguments]    ${dist_name}    ${timeout}=${800}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to lock the cell.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | Dist_name to lock the cell, e.g. MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lockcell | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1 | connection=coam_conn |
    ...
    coam.lock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}

COAM_Admin.unlock
    [Arguments]    ${dist_name}    ${timeout}=${800}    ${connection}=COAM
    [Documentation]    Author: Zou Shuang
    ...                Contact: shuang.zou@nokia-sbell.com
    ...                This kw is to unlock the given resource.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | Dist_name of RMOD or cell or LANE or site, e.g. MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.unlock | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1 | connection=coam_conn |
    ...
    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}

COAM_Admin.unlock_cell
    [Arguments]    ${dist_name}    ${timeout}=${800}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to unlock the cell.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | Dist_name to unlock the cell, e.g. MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.unlockcell | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1 | connection=coam_conn |
    ...
    coam.unlock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}

COAM_Admin.lock_NR
    [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...             ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to lock the BTS site.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | No | Dist_name to lock the bts, e.g. MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lock_NR | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1 | connection=coam_conn |
    ...
    coam.lock_bts    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.unlock_NR
    [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...             ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to unlock the BTS site.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | No | Dist_name to unlock the bts, e.g. MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.unlock_NR | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1 | connection=coam_conn |
    ...
    coam.unlock_bts    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.lock_RU
    [Arguments]    ${RMOD_name}=RMOD_R-1    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to lock the RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${RMOD_name} | No | RMOD_name in dist_name to lock the RU, Default is RMOD_R-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lock_RU |  |  |
    ...    | COAM_Admin.lock_RU | RMOD_name=RMOD_R-1 | connection=coam_conn |
    ...
    coam.lock_RU    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/${RMOD_name}
    ...             timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.unlock_RU
    [Arguments]    ${RMOD_name}=RMOD_R-1    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to unlock the RU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${RMOD_name} | No | RMOD_name in dist_name to unlock the RU, Default is RMOD_R-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.unlock_RU |  |  |
    ...    | COAM_Admin.unlock_RU | RMOD_name=RMOD_R-1 | connection=coam_conn |
    ...
    coam.unlock_RU    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/${RMOD_name}
    ...             timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.lock_BBMOD
    [Arguments]    ${BBMOD_name}=BBMOD_R-1    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to lock the BBU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${BBMOD_name} | No | BBMOD_name in dist_name to lock the BBU, Default is BBMOD_R-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lock_BBMOD |  |  |
    ...    | COAM_Admin.lock_BBMOD | BBMOD_name=RMOD_R-1 | connection=coam_conn |
    ...
    coam.lock_baseband    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/${BBMOD_name}
    ...                   timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.unlock_BBMOD
    [Arguments]    ${BBMOD_name}=BBMOD_R-1    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to unlock the BBU.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${BBMOD_name} | No | BBMOD_name in dist_name to unlock the BBU, Default is BBMOD_R-1 |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.unlock_BBMOD |  |  |
    ...    | COAM_Admin.unlock_BBMOD | BBMOD_name=RMOD_R-1 | connection=coam_conn |
    ...
    coam.unlock_baseband    dist_name=MRBTS-${MRBTS_ID}/EQM_R-1/APEQM_R-1/CABINET_R-1/${BBMOD_name}
    ...                   timeout=${timeout}    connection=${connection}
    Sleep    60

COAM_Admin.ResetSite
    [Arguments]    ${timeout}=600    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to reset the BTS.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.ResetSite |  |
    ...    | COAM_Admin.ResetSite | connection=coam_conn |
    ...
    log to console    Start reseting gNB!
    coam.reset_site    timeout=${timeout}    connection=${connection}
    log to console    Finish reseting gNB!

COAM_Admin.ResetRat
    [Arguments]    ${timeout}=600    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to reset the RAT.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.ResetRat |  |
    ...    | COAM_Admin.ResetRat | connection=coam_conn |
    ...
    log to console    Start reset rat!
    coam.rat_reset    timeout=${timeout}    connection=${connection}
    log to console    Finish reset rat!

COAM_Admin.ResetConfiguration
    [Arguments]    ${timeout}=600    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to reset the Configuration.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${timeout} | No | The timeout for this kw, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.ResetConfiguration |  |
    ...    | COAM_Admin.ResetConfiguration | connection=coam_conn |
    ...
    log to console    Start configuration reset!
    coam.reset_configuration    timeout=${timeout}    connection=${connection}
    log to console    Finish configuration reset!

COAM_Admin.Upgrade From Console Mode
    [Arguments]    ${package_path}    ${scf_path}=${None}
    ...    ${log_dir}=${TEST_LOG_DIRECTORY}
    ...    ${bts_index}=${0}
    ...    ${timeout}=900s
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This kw will upgrade from console mode after reset configuration
    ...                untill the site is onair
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.ResetConfiguration |  |
    ...
    ${host}    Set Variable   192.168.255.129
    ${username}    Set Variable   ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.username}
    ${password}    Set Variable   ${tl.gnbs[${bts_index}].cu.oam_http_connection_details.password}
    ${connection}    fdswrc.connect_to    ip_address=${host}
    ...    username=${username}
    ...    password=${password}
    ...    name=fdswrc
    ...    port=443
    ${active_part_ID}    rc.get_active_sw_partition    timeout=10
    ...    connection=${connection}
    fdswrc.software_update    sw_pkg_path=${package_path}
    ...    timeout=${timeout}    connection=${connection}
    ...    sw_slot_id=${active_part_ID}
    ...    activate=True
    Sleep    2 min
    wait until keyword succeeds     10min    10s    coam.connect_to    bts_host=${host}
    ...    username=${username}
    ...    password=${password}
    ...    admin_api_log_dir=${log_dir}
    ...    name=COAM_${bts_index}
    # load scf after upgrade
    Commission Full SCF For One GNB
    ...    timeout=${600}    bts_index=${bts_index}
    ...    scf_file_path=${scf_path}
    wait until keyword succeeds     10min    10s
    ...    COAM_Admin.CheckBTSCommissioned    COAM_${bts_index}
    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'    Reboot Iphy
    Run Keyword If    "_AP_" in '${TESTLINE_TYPE}'
    ...    Commission Full SCF For One GNB
    ...    timeout=${600}    bts_index=${bts_index}
    ...    scf_file_path=${scf_path}
    ${rru_configured}    Run Keyword And Return Status
    ...    Wait Until RRU Configured    COAM_${bts_index}    timeout=10 min
    &{expected_alarms}        Create Dictionary    faultId=23
    @{expected_list}          Create List     ${expected_alarms}
    Log To Console    check 23 alarm
    ${passed}    Run Keyword And Return Status
    ...    wait until keyword succeeds     5min    10s
    ...    Alarm Operation    operation=check_active_alarms
    ...    product_type=gnb
    ...    bts_index=${bts_index}
    ...    expected_alarms=${expected_list}
    Run Keyword If    '${passed}'=='${False}'    coam.update_software
    ...    sw_package=${package_path}
    ...    connection=COAM_${bts_index}
    ...    ELSE    Log to Console     should not need to update software again



COAM_Admin.Reset_RMOD
    [Arguments]    ${rmod_id}=1    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Xiang Liang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This kw is used to reset radio module by index list.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${rmod_id} | Yes | rmod_list to be reset. E.g. 1 2 |
    ...    | ${timeout} | No | The timeout for radio module reset, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Reset_RMOD | 1 |
    ...    | COAM_Admin.Reset_RMOD | 1 2 3 |
    ...    | COAM_Admin.Reset_RMOD | rmod_list=1 2 3 | timeout=600 | connection=COAM |

    ${rmod_list}=    string.split string    ${rmod_id}
    ${rmod_info}=    coam.get_frm    connection=${connection}
    FOR    ${rmod}    IN    @{rmod_info}
        ${prefix}    ${rmod_full_id}=    string.Split String From Right    ${rmod['id']['configuration']}    separator=/    max_split=${1}
        ${prefix}    ${rmod_id}=    string.Split String From Right    ${rmod_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${rmod_id}' in @{rmod_list}     run keywords
        ...    Log To Console    \n reset rmod ${rmod_full_id}
        ...    AND    coam.reset_unit    ${rmod['id']['internal']}    force_radio_reset=${True}
        ...    timeout=${timeout}    connection=${connection}
    END

COAM_Admin.Block_CELL
    [Arguments]    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    [Documentation]    Author: Xiang Liang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${global_cell_id} | Yes | cell list to be blocked. E.g. 1 2 3. |
    ...    | ${cell_type} | No | cell_type, E.g. nr, lte , default value is nr|
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Block_CELL |  1   |   block one cell with global_cell_id
    ...    | COAM_Admin.Block_CELL |  1 2 3  |
    ...    | COAM_Admin.Block_CELL | cells_list=1 2 3 | cell_type=nr | connection=COAM  |
    _COAM_Admin.One Cell Operation    operation=block_cell
    ...    global_cell_id=${global_cell_id}
    ...    cell_type=${cell_type}
    ...    connection=${connection}

COAM_Admin.Unblock_CELL
    [Arguments]    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    [Documentation]    Author: Xiang Liang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${global_cell_id} | Yes | cell list to be unblocked. E.g. 1 2 3. |
    ...    | ${cell_type} | No | cell_type, E.g. nr, lte , default value is nr|
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Block_CELL |  1   |   block one cell with global_cell_id
    ...    | COAM_Admin.Unblock_CELL |  1 2 3  |
    ...    | COAM_Admin.Unblock_CELL | cells_list=1 2 3 | cell_type=nr | connection=COAM  |
    _COAM_Admin.One Cell Operation    operation=unblock_cell
    ...    global_cell_id=${global_cell_id}
    ...    cell_type=${cell_type}
    ...    connection=${connection}

COAM_Admin.Unlock_CELL_By_Global_Cell_Id
    [Arguments]    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${global_cell_id} | Yes | cell list to be unblocked. E.g. 1 2 3. |
    ...    | ${cell_type} | No | cell_type, E.g. nr, lte , default value is nr|
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Unlock_CELL |  1   |   block one cell with global_cell_id
    ...    | COAM_Admin.Unlock_CELL |  1 2 3  |
    ...    | COAM_Admin.Unlock_CELL | cells_list=1 2 3 | cell_type=nr | connection=COAM  |
    _COAM_Admin.One Cell Operation    operation=unlock
    ...    global_cell_id=${global_cell_id}
    ...    cell_type=${cell_type}
    ...    connection=${connection}

COAM_Admin.Lock_CELL_By_Global_Cell_Id
    [Arguments]    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${global_cell_id} | Yes | cell list to be unblocked. E.g. 1 2 3. |
    ...    | ${cell_type} | No | cell_type, E.g. nr, lte , default value is nr|
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lock_CELL |  1   |   block one cell with global_cell_id
    ...    | COAM_Admin.lock_CELL |  1 2 3  |
    ...    | COAM_Admin.lock_CELL | cells_list=1 2 3 | cell_type=nr | connection=COAM  |
    _COAM_Admin.One Cell Operation    operation=lock
    ...    global_cell_id=${global_cell_id}
    ...    cell_type=${cell_type}
    ...    connection=${connection}

COAM_Admin.Reset_CELL_By_Global_Cell_Id
    [Arguments]    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${global_cell_id} | Yes | cell list to be unblocked. E.g. 1 2 3. |
    ...    | ${cell_type} | No | cell_type, E.g. nr, lte , default value is nr|
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.lock_CELL |  1   |   block one cell with global_cell_id
    ...    | COAM_Admin.lock_CELL |  1 2 3  |
    ...    | COAM_Admin.lock_CELL | cells_list=1 2 3 | cell_type=nr | connection=COAM  |
    _COAM_Admin.One Cell Operation    operation=reset_cell
    ...    global_cell_id=${global_cell_id}
    ...    cell_type=${cell_type}
    ...    connection=${connection}

_COAM_Admin.One Cell Operation
    [Arguments]    ${operation}
    ...    ${global_cell_id}=1    ${cell_type}=nr    ${connection}=COAM
    ${cells_list}=    string.split string    ${global_cell_id}
    ${cell_info}=    coam.get_cells_info    cell_type=${cell_type}   connection=${connection}
    ${upper_global_id}    Convert To Upper Case    ${global_cell_id}
    FOR    ${cell}    IN    @{cell_info}
        Run Keyword If    '${upper_global_id}'=="ALL"
        ...    run keywords
        ...    Log To Console    \n ${operation} cell ${cell}
        ...    AND    coam.${operation}    ${cell['id']['internal']}    connection=${connection}
        ...    timeout=60
        Continue For Loop If    '${upper_global_id}'=="ALL"
        ${prefix}    ${cell_full_id}=    string.Split String From Right    ${cell['id']['configuration']}    separator=/    max_split=${1}
        ${prefix}    ${cell_id}=    string.Split String From Right    ${cell_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${cell_id}' in @{cells_list}    run keywords
        ...    Log To Console    \n ${operation} cell ${cell_full_id}
        ...    AND    coam.${operation}    ${cell['id']['internal']}    connection=${connection}
        ...    timeout=60
    END

COAM_Admin.Block Cells For Specified Type
    [Arguments]    ${connection}=COAM    ${cell_type}=lte
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Block Cells For all lte cells or NR cells
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${cell_type} | No | the block cells type, like nr or lte |

    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Block Cells For Specified Type  | connection=COAM_0 | cell_type=lte |
    ...
    ${cell_info_lte}    coam.get_cells_info    cell_type=${cell_type}    timeout=10
    ...    connection=${connection}
    FOR    ${cell_info}    IN    @{cell_info_lte}
        coam.block_cell    dist_name=${cell_info['id']['configuration']}    connection=${connection}
    END

COAM_Admin.Unblock Cells For Specified Type
    [Arguments]    ${connection}=COAM    ${cell_type}=lte
    [Documentation]    Author: He winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                unBlock Cells For all lte cells or NR cells
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${cell_type} | No | the block cells type, like nr or lte |

    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Unblock Cells For Specified Type | connection=COAM_0 | cell_type=lte |
    ...
    ${cell_info_lte}    coam.get_cells_info    cell_type=${cell_type}    timeout=10
    ...    connection=${connection}
    FOR    ${cell_info}    IN    @{cell_info_lte}
        Run Keyword And Ignore Error    coam.unblock_cell
        ...    dist_name=${cell_info['id']['configuration']}    connection=${connection}
    END

COAM_Admin.Reset_BBMOD
    [Arguments]    ${fbb_id}=1    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Xiang Liang
    ...                Contact: liang.xiang@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${fbb_id} | Yes | bbmod list to be reset. E.g. 1 2 |
    ...    | ${timeout} | No | The timeout for radio module reset, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Reset_BBMOD | 1 |
    ...    | COAM_Admin.Reset_BBMOD | fbb_list=1 2 3 | timeout=600 | connection=COAM |

    ${fbb_list}=    string.split string    ${fbb_id}
    ${fbb_info}=    coam.get_fbb_info    connection=${connection}
    FOR    ${fbb}    IN    @{fbb_info}
        ${prefix}    ${fbb_full_id}=    string.Split String From Right    ${fbb['id']['configuration']}    separator=/    max_split=${1}
        ${prefix}    ${fbb_id}=    string.Split String From Right    ${fbb_full_id}    separator=-    max_split=${1}
        Run Keyword If    '${fbb_id}' in @{fbb_list}    run keywords
        ...    Log To Console    \n reset fbb ${fbb_full_id}
        ...    AND    coam.reset_unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${timeout}    connection=${connection}
    END
#----Alarm Operation-----------------------------------------------------------------------------------------
COAM_Admin.GetActiveAlarms
    [Arguments]    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Get the BTS current active alarms.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${active_alarms} | The current active alarms as list |
    ...
    ...    Example
    ...    | ${alarms} | COAM_Admin.GetActiveAlarms |  |
    ...    | ${alarms} | COAM_Admin.GetActiveAlarms | connection=coam_conn |
    ...
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=10
    [Return]    ${active_alarms}

Wait For Expect Fault Present
    [Arguments]    ${faultId}=${23}    ${timeout}=${60}    ${source}=${None}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to wait for ${timeout} for the ${faultId} alarm should appear.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${faultId} | No | The expected alarm fault id, default is 23 |
    ...    | ${timeout} | No | The waiting time, default is 60s |
    ...    | ${source} | No | The customized information should exist in "notifier" in alarm, default is None |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Wait For Expect Fault Present | faultid=${23} |
    ...    | Wait For Expect Fault Present | faultid=${23} | timeout=120 | connection=coam_conn |
    ...
    Wait Until Keyword Succeeds    ${timeout} sec    5 sec    Expect Fault Should Present
    ...                                                       faultId=${faultId}
    ...                                                       source=${source}
    ...                                                       connection=${connection}

Wait For Expect Fault To Disappear
    [Arguments]    ${faultId}=${23}    ${timeout}=${60}    ${source}=${None}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to wait for ${timeout} for the ${faultId} alarm should disappear.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${faultId} | No | The expected alarm fault id, default is 23 |
    ...    | ${timeout} | No | The waiting time, default is 60s |
    ...    | ${source} | No | The customized information should exist in "notifier" in alarm, default is None |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Wait For Expect Fault To Disappear | faultid=${23} |
    ...    | Wait For Expect Fault To Disappear | faultid=${23} | timeout=120 | connection=coam_conn |
    ...
    Wait Until Keyword Succeeds    ${timeout} sec    5 sec    Expect Fault Should Absent
    ...                                                       faultId=${faultId}
    ...                                                       source=${source}
    ...                                                       connection=${connection}

Expect Fault Should Present
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=COAM    ${severity}=${None}    ${alarmId}=${None}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to check the ${faultId} alarm should exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${faultId} | No | The expected alarm fault id, default is 23 |
    ...    | ${source} | No | The customized information should exist in "notifier" in alarm, default is None |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${severity} | No | The severity information should exist in "severity" in alarm, default is None |
    ...    | ${alarmId} | No | The alarmid information should exist in "alarmId" in alarm, default is None |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Expect Fault Should Present | faultid=${23} |
    ...    | Expect Fault Should Present | faultid=${23} | connection=coam_conn |
    ...
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...                  Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
        ...                  Run Keyword If    '${source}'!='${None}'
        ...                  Should Contain    ${alarm['notifier']}    ${source}    case_insensitive=True    AND
        ...                  Run Keyword If    '${severity}'!='${None}'
        ...                  Should Contain    ${alarm['severity']}    ${severity}    case_insensitive=True    AND
        ...                  Run Keyword If    '${alarmId}'!='${None}'
        ...                  Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.

Expect Fault Should Absent
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to check the ${faultId} alarm should NOT exist.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${faultId} | No | The indicated alarm fault id, default is 23 |
    ...    | ${source} | No | The customized information should exist in "notifier" in alarm, default is None |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Expect Fault Should Absent | faultid=${23} |
    ...    | Expect Fault Should Absent | faultid=${23} | connection=coam_conn |
    ...
    ${status}    Run Keyword And Return Status    Expect Fault Should Present    faultId=${faultId}
    ...                                                                          source=${source}
    ...                                                                          connection=${connection}
    Run Keyword If    ${status}==${True}    Fail    faultId ${faultId} reported by source ${source} is still present on gnb.

Check Unexpect Alarm Should Not Exist
    [Arguments]    ${allowed_faults}
    ...            ${file_path}=${TEST_LOG_DIRECTORY}
    ...            ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to check the unexpected alarm (out of the allow list) should NOT exist.
    ...                If there's unexpected alarms, they will be recorded in file "unexpect_active_alarms_${timestamp}.txt".
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${allowed_faults} | Yes | The allowed alarms list. Could be created as this:                      |
    ...    |                   |     | &{fault_61524}    faultId=${61524}                                      |
    ...    |                   |     | &{fault_61649}    faultId=${61649}                                      |
    ...    |                   |     | &{fault_61652}    faultId=${61652}                                      |
    ...    |                   |     | @{allowed_faults}    &{fault_61652}    &{fault_61524}    &{fault_61649} |
    ...    | ${file_path} | No | The path to stored the unexpexted alarm list file, default is ${TEST_LOG_DIRECTORY} |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Check Unexpect Alarm Should Not Exist | allowed_faults=@{allowed_faults} |
    ...
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    ${active_alarms_num}    Get Length    ${active_alarms_list}
    ${unexpect_alarms}    Create List
    FOR    ${alarm}    IN    @{active_alarms_list}
        Exit For Loop If    ${active_alarms_num}==${0}
        ${status}    Run Keyword And Return Status    Check Alarm Is Allowed
        ...                                           allowed_alarm_list=${allowed_faults}
        ...                                           check_alarm=${alarm}
        Run Keyword If    ${status}==${False}    Append To List    ${unexpect_alarms}    ${alarm}
    END
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${unexpect_alarm_file}    Set variable    ${file_path}/unexpect_active_alarms_${timestamp}.txt
    ${alarm_num}    Get Length    ${unexpect_alarms}
    Run Keyword If    ${alarm_num}!=${0}    Run    command=echo "unexpect alarm number:${alarm_num}">${unexpect_alarm_file}
    FOR    ${alarm}    IN    @{unexpect_alarms}
        Exit For Loop If    ${alarm_num}==${0}
        run    command=echo "${alarm}">>${unexpect_alarm_file}
    END
    Run Keyword If    ${alarm_num}!=${0}    fail    ${alarm_num} alarms are not allowed, details in log: ${unexpect_alarm_file}

Check Alarm Is Allowed
    [Arguments]    ${allowed_alarm_list}    ${check_alarm}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Description: used in keyword <<< Unexpect Alarm Should Not Exist >>>
    ...                This kw is to check whether the ${check_alarm} exists in ${allowed_alarm_list}.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${allowed_alarm_list} | Yes | The allowed alarms list. Could be created as this:                          |
    ...    |                       |     | &{fault_61524}    faultId=${61524}                                          |
    ...    |                       |     | &{fault_61649}    faultId=${61649}                                          |
    ...    |                       |     | &{fault_61652}    faultId=${61652}                                          |
    ...    |                       |     | @{allowed_alarm_list}    &{fault_61652}    &{fault_61524}    &{fault_61649} |
    ...    | ${check_alarm} | Yes | The alarm to be checked. It's the alarm element return from coam.get_active_alarms |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Check Alarm Is Allowed | allowed_alarm_list=@{allowed_alarm_list} | check_alarm=${alarm} |
    ...
    ${allowed_status}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{allowed_alarm_list}
        ${check_source}    ${source_value}    Run Keyword And Ignore Error    Set Variable    ${alarm['source']}
        ${allowed_status}    Run Keyword And Return Status    Run Keywords
        ...                  Should Be Equal    ${check_alarm['faultId']}    ${alarm['faultId']}    AND
        ...                  Run Keyword If    '${check_source}'=='PASS'
        ...                                   Should Contain    ${check_alarm['notifier']}    ${source_value}
        Exit For Loop If    ${allowed_status}
    END
    Run Keyword If    ${allowed_status}==${False}    Fail    faultId ${check_alarm['faultId']} reported by ${check_alarm['notifier']} not allowed

Get All Allow Faults
    [Arguments]    ${tl_allowed_faults_file_path}
    ...    ${ALLOWED_FAULT}=${ALLOWED_FAULT}
    [Documentation]    Author: Winnie He
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Description:  use to combine the base fault: ${ALLOWED_FAULT},
    ...                case allowd fault, ${Ohter_Allow_Alarms}
    ...                tl specify fault, get from file testline_allow_faults.json which put in __init__.py dir
    ...    | Input Parameters | Man. | Description |
    ...    | ${tl_allowed_faults_file_path} | Yes | the tl specify fault path|
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | ${allow_faults} | Get All Allow Faults | tl_allowed_faults_file_path=@{tl_allowed_faults_file_path} |
    ...
    ${combined_allow_fault_alarms}    Combine Lists    ${ALLOWED_FAULT}    ${Ohter_Allow_Alarms}
    ${tl_allow_faults}    Get TestLine Faults From File    ${tl_allowed_faults_file_path}
    ${combined_allow_fault_alarms}    Combine Lists    ${combined_allow_fault_alarms}    ${tl_allow_faults}
    [Return]    ${combined_allow_fault_alarms}

#----SCF Operations------------------------------------------------------------------------------------------
Judge If Commissioning SCF
    [Arguments]    ${config_path}=${CURDIR}/../HAZ3/{SUITE_NAME}    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to check the given config path.
    ...                If there's full scf xml file, then full commission to sbts and check onair.
    ...                If there's delta scf json file, then delta commission to sbts and check onair.
    ...                If both exists, then first full commission and then delta commission with checking onair.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${config_path} | Yes. | The config path need to check. E.g. ${CURDIR}/../HAZ3/CB005882 |
    ...    | ${timeout} | No |  The time out of full and delta each commission, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Judge If Commissioning SCF  |  ${CURDIR}/../HAZ3/CB005882  |
    Log to console    \n***Commissioning SCF And Check On Air***
    Connect To VM    alias=VM
    # ${xml_file}=    common_commands.get_file_names_under_directory    directory=${config_path}
    # ...                                                               connection=VM
    # ...                                                               file_indicator=*.xml
    # ${xml_file_length}    get length    ${xml_file}
    # Run Keyword If    ${xml_file_length} != 0    Set Test Variable    ${xml_file}    ${xml_file[0]}
    ${json_file}=    common_commands.get_file_names_under_directory    directory=${config_path}
    ...                                                                connection=VM
    ...                                                                file_indicator=*.json
    ${json_file_length}    get length    ${json_file}
    Run Keyword If    ${json_file_length} != 0    Set Test Variable    ${json_file}    ${json_file[0]}
    Run Keyword If    '${xml_file}' != '[]' and '${json_file}' == '[]'    Commissioning Full SCF
    ...                                                                   scf_file=${config_path}/${xml_file}
    ...                                                                   timeout=${timeout}
    ...                                                                   connection=${connection}
    Run Keyword If    '${xml_file}' == '[]' and '${json_file}' != '[]'    Commissioning Delta SCF
    ...                                                                   delta_file=${config_path}/${json_file}
    ...                                                                   timeout=${timeout}
    ...                                                                   connection=${connection}
    Run Keyword If    '${xml_file}' != '[]' and '${json_file}' != '[]'    Commissioning Full SCF And Delta SCF
    ...                                                                   scf_file=${config_path}/${xml_file}
    ...                                                                   delta_file=${config_path}/${json_file}
    ...                                                                   timeout=${timeout}
    ...                                                                   connection=${connection}
    [Teardown]    Disconnect VM

Commissioning Full SCF
    [Arguments]    ${scf_file}    ${timeout}=${600}    ${connection}=COAM
    ...    ${check_onair}=${True}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to commission full scf to sbts. And check onair status.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | The scf file full path and name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...    | ${timeout} | No |  The time out of commission, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Commissioning Full SCF  |  scf_file=${CURDIR}/ ../{SUITE_NAME}/full_scf.xml  |
    ...
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login
    coam.perform_commissioning    scf_file=${scf_file}
    ...                           skip_parameter_relation_errors=True
    ...                           should_activate=${true}
    ...                           timeout=${timeout}
    ...                           connection=${connection}
    Run Keyword If    '${check_onair}'=='${True}'
    ...    Wait Until Keyword Succeeds    20 min    10 sec
    ...    Verify bts and all cell status should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Commissioning Delta SCF
    [Arguments]    ${delta_file}    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to commission delta scf to sbts. And check onair status.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_file} | Yes | The delta scf file full path and name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.json |
    ...    | ${timeout} | No |  The time out of commission, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Commissioning Delta SCF  |  delta_file=${CURDIR}/ ../{SUITE_NAME}/delta_scf.json |
    ...
    Wait Until Keyword Succeeds    3x    1min    COAM_Admin.Login
    coam.perform_delta_recommissioning    delta_file=${delta_file}
    ...                                   skip_parameter_relation_errors=${true}
    ...                                   should_activate=${true}
    ...                                   timeout=${600}
    ...                                   connection=${connection}
    Wait Until Keyword Succeeds    20 min    10 sec    Verify bts and all cell status should be onair
    [Teardown]    Run Keyword And Ignore Error    COAM_Admin.Logout

Commissioning Full SCF And Delta SCF
    [Arguments]    ${scf_file}    ${delta_file}    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to commission full scf and delta scf to sbts. And check onair status.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | The scf file full path and name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...    | ${delta_file} | Yes | The delta scf file full path and name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.json |
    ...    | ${timeout} | No |  The time out of full and delta each commission, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Commissioning Full SCF And Delta SCF  |  scf_file=${CURDIR}/ ../{SUITE_NAME}/full_scf.xml |
    ...    |                                        |  delta_file=${CURDIR}/ ../{SUITE_NAME}/delta_scf.json |
    ...
    Commissioning Full SCF    scf_file=${scf_file}
    ...                       timeout=${timeout}
    ...                       connection=${connection}
    Commissioning Delta SCF    delta_file=${delta_file}
    ...                        timeout=${timeout}
    ...                        connection=${connection}

COAM_Admin.BackupSCF
    [Arguments]    ${local_dir}=${RESULT_DIR}    ${file_name}=old_commission.xml    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to backup the scf.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_dir} | No | The path to store the backup scf, default is ${RESULT_DIR} |
    ...    | ${file_name} | No | The backup scf name, default is old_commission.xml |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.BackupSCF | connection=coam_conn |
    ...
    coam.get_current_scf_file    local_dir_path=${local_dir}    file_name=${file_name}    connection=${connection}    timeout=10
    ${backupfile}=    Join Path    ${local_dir}    ${file_name}
    [Return]    ${backupfile}

COAM_Admin.ValidateSCF
    [Arguments]    ${scf_file}=/home/ute/Auto5G/commissionings/SBTS1734.xml
    ...           ${timeout}=${300}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to validate the scf.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | The scf file full path and name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...    | ${timeout} | No | The timeout for scf validation, default is 300s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.ValidateSCF | scf_file=/home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...
    wait until keyword succeeds    3x    1min    COAM_Admin.Login
    coam.validate_scf    scf_file=${scf_file}    timeout=${timeout}    connection=${connection}
    [Teardown]    COAM_Admin.Logout

COAM_Admin.get parameters with class name
    [Arguments]    ${class_name}=SERVEDAMF_R    ${pattern}=ngLinkStatus    ${value}=Active    ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get parameters with class name.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${class_name} | Yes | The class name. E.g. 'SMOD', 'RMOD'. |
    ...    | ${pattern} | Yes | The pattern in ${ng_param[0]['parameters']}. E.g. ngLinkStatus |
    ...    | ${value} | Yes | The value of the pattern. |
    ...    | ${timeout} | No | The timeout for getting the parameters, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.get parameters with class name | class_name=SERVEDAMF_R | pattern=ngLinkStatus | ${value}=Active |
    ...
    ${ng_param}    coam.get_managed_objects    class_name=${class_name}    timeout=${timeout}    connection=${connection}
    ${pattern_status}    Set variable    ${ng_param[0]['parameters']['${pattern}']}
    should be equal as strings    ${value}    ${pattern_status}

COAM_Admin.get parameters
    [Arguments]    ${dist_name}=NRBTS_R-${NRBTS_ID}    ${pattern}=ngLinkStatus    ${value}=Active
    ...            ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to get parameters
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | The dist name. E.g. NRBTS_R-${NRBTS_ID} |
    ...    | ${pattern} | Yes | The pattern in ${dict_parameters}. E.g. ngLinkStatus |
    ...    | ${value} | Yes | The value of the pattern. |
    ...    | ${timeout} | No | The timeout for getting the parameters, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | ${dict_parameters['${pattern}']} | The pattern's value got from BTS |
    ...
    ...    Example
    ...    | COAM_Admin.get parameters | dist_name=NRBTS_R-${NRBTS_ID} | pattern=ngLinkStatus | ${value}=Active |
    ...
    &{dict_parameters}    coam.get_parameters    dist_name=${dist_name}    pattern=${pattern}
    ...                    timeout=${timeout}    connection=${connection}
    should be equal as strings    ${dict_parameters['${pattern}']}    ${value}    ignore_case=${True}
    [Return]    ${dict_parameters['${pattern}']}

COAM_Admin.set parameter value
    [Arguments]    ${dist_name}    ${parameter}    ${new_value}    ${operation}=update
    ...            ${sleep_time}=${30}    ${timeout}=${800}    ${connection}=COAM
    ...            ${skip_parameter_relation_errors}=true    ${should_activate}=${true}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to set the parameters
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | The dist name. E.g. MRBTS-1/LNBTS-1/LNMME-0 |
    ...    | ${parameter} | Yes | The parameter. E.g. ipAddrPrim |
    ...    | ${new_value} | Yes | The value to be set of the parameter. E.g. 10.0.1.99 |
    ...    | ${operation} | No | The operation for this parameter, update or delete can be choosen. Default is update |
    ...    | ${sleep_time} | No | The operation for this parameter. Default is update |
    ...    | ${timeout} | No | The timeout for setting the parameters, default is 800s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${skip_parameter_relation_errors} | No | Skip parameter relation errors. Default is true. |
    ...    | ${should_activate} | No | Should automatically activate plan. Default is true. |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.set parameter value | dist_name=NRBTS_R-${NRBTS_ID} | pattern=ngLinkStatus | ${value}=Active |
    ...
    coam.perform_parameter_recommissioning    dist_name=${dist_name}    parameter=${parameter}
    ...                                       operation=${operation}    value=${new_value}
    ...                                       skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                       should_activate=${should_activate}    timeout=${timeout}
    ...                                       connection=${connection}
    Sleep    ${sleep_time}

COAM_Admin.commission
    [Arguments]    ${scf_file}=/home/ute/Auto5G/commissionings/SBTS1734.xml
    ...            ${timeout}=${600}    ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Description: Only perform the full SCF commission, the full path and file name of SCF
    ...                should be input. The connection should be input, default is COAM.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file} | Yes | The scf file full path and file name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...    | ${timeout} | No | The timeout for this commission, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.commission | scf_file=/home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...
    coam.perform_commissioning    scf_file=${scf_file}    skip_parameter_relation_errors=True
    ...    should_activate=${true}    timeout=${timeout}    connection=${connection}

COAM_Admin.perform_object_recommissioning
    [Arguments]    ${dist_name}    ${parameter_delta_list}
    ...            ${operation}=update    ${timeout}=${600}
    ...            ${connection}=COAM    ${skip_parameter_relation_errors}=True
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The kw is used to Perform object recommissioning, create, update and delete operation can be used.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${dist_name} | Yes | The dist name. E.g. MRBTS-1/LNBTS-1/LNMME-0 |
    ...    | ${parameter_delta_list} | Yes | list of dicts, as empty list to delete object |
    ...    | ${operation} | No | The operation, update or delete can be choosen. Default is update |
    ...    | ${timeout} | No | The timeout for this commission, default is 600s |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...    | ${skip_parameter_relation_errors} | No | Skip parameter relation errors. Default is true. |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | @{value_list}                             | create list                                            |                        |
    ...    | ${value}=                                 | create dictionary                                      | basicBeamSet=beamSet_6 |
    ...    | ...                                       | beamsMuted=21                                          |                        |
    ...    | ...                                       | leftEdgeAngle=60                                       |                        |
    ...    | ...                                       | nrBtsBeamRefinementP2=false                            |                        |
    ...    | ...                                       | rightEdgeAngle=60                                      |                        |
    ...    | append to list                            | ${value_list}                                          | ${value}               |
    ...    | ${dict1}=                                 | create dictionary                                      | parameterName=beamSet  |
    ...    | ...                                       | operation=update                                       |                        |
    ...    | ...                                       | value=@{value_list}                                    |                        |
    ...    | @{parameter_delta_list}=                  | create list                                            | ${dict1}               |
    ...    | COAM_Admin.perform_object_recommissioning | dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2 |                        |
    ...    | ...                                       | parameter_delta_list=${parameter_delta_list}           |                        |
    ...
    coam.perform_object_recommissioning    dist_name=${dist_name}    parameter=${parameter_delta_list}
    ...                                    operation=${operation}
    ...                                    skip_parameter_relation_errors=${skip_parameter_relation_errors}
    ...                                    should_activate=${true}
    ...                                    timeout=${timeout}
    ...                                    connection=${connection}

COAM_Admin.Perform Delta Recommission
    [Arguments]    ${delta_scf}    ${testline_name}=10_5_UTESRAN001T${MRBTS_ID}
    ...           ${connection}=COAM
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The KW is to perform delta recommission by using JSON file.
    ...                The json file should be in: /commissionings/RRM/SRAN_5G/${testline_name}/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${delta_scf} | Yes | The delta scf file name without .json. E.g. SBTS1734 |
    ...    | ${testline_name} | No | The test line name, default is 10_5_UTESRAN001T${MRBTS_ID} |
    ...    | ${connection} | No | The alias for this connection, default is COAM |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | COAM_Admin.Perform Delta Recommission | delta_scf=SBTS1734 |
    ...
    ${SCF_PATH}    Get Substring    ${CURDIR}    0    -32
    ${delta_path}    Set Variable    ${SCF_PATH}/commissionings/RRM/SRAN_5G/${testline_name}/${delta_scf}.json
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_path}
    ...    skip_parameter_relation_errors=${true}
    ...    should_activate=${true}
    ...    timeout=${600}
    ...    connection=${connection}

Commissioning SCF And Check On Air
    [Arguments]    ${scf_name}    ${testline_name}=10_5_UTESRAN001T${MRBTS_ID}
    [Documentation]    Auther: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Commission the SCF, but will NOT check onair status.
    ...                Please check onair status after this keyword!
    ...                The scf file should be put in: /commissionings/RRM/SRAN_5G/${testline_name}/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_name} | Yes | The scf file file name without .xml. E.g. 10_5_UTESRAN001T${MRBTS_ID}_4DL_4UL_NSA |
    ...    | ${testline_name} | No | The test line to commission scf, default is 10_5_UTESRAN001T${MRBTS_ID} |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Commissioning SCF And Check On Air | scf_name=10_5_UTESRAN001T${MRBTS_ID}_4DL_4UL_NSA |
    ...
    Log to console    \n***Commissioning SCF And Check On Air***
    ${SCF_PATH}    Split String    ${CURDIR}    testsuite
    ${GOLDEN_FULL_SCF}    Set Variable    ${SCF_PATH[0]}commissionings/RRM/SRAN_5G/${testline_name}/${scf_name}.xml
    COAM Commission with scf file    scf_file_path=${GOLDEN_FULL_SCF}

COAM Commission with scf file
    [Arguments]    ${scf_file_path}    ${connection}=COAM_local    ${timeout}=300    ${is_pdl_checking_needed}=${True}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Description: Do commission and verify commission status
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scf_file_path} | Yes | The scf file full path and file name. E.g. /home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...    | ${connection} | No | The connection alias, default is COAM_local |
    ...    | ${timeout} | No | The timeout for this commission, default is 300s |
    ...    | ${is_pdl_checking_needed} | No | Whether need the pdl validation, default is True |
    ...
    ...    | Return Value | Description |
    ...    | ${result} | The commission result |
    ...
    ...    Example
    ...    | ${commission_result} | COAM Commission with scf file | scf_file=/home/ute/Auto5G/commissionings/SBTS1734.xml |
    ...
    COAM_Admin.local_Login
    &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=COAM_local
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    [Return]    ${result}

#----SWCONFIG Operation--------------------------------------------------------------------------------------
Judge If Update Swconfig
    [Arguments]    ${config_path}=${CURDIR}/../HAZ3/{SUITE_NAME}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This KW is used to check the given config path.
    ...                If there's txt file, then use the 1st txt file as swconfig.txt to upload to control board /ffs/run and crasign.
    ...                But will NOT reboot the BTS, if you need to take this affect, please reboot BTS after this KW.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${config_path} | Yes. | The config path need to check. E.g. ${CURDIR}/../HAZ3/CB005882 |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    |  Judge If Update Swconfig  |  ${CURDIR}/../HAZ3/CB005882  |
    ...
    Log to console    \n***Update Swconfig And Check On Air***
    Connect To VM    alias=VM
    ${swconfig_file}=    common_commands.get_file_names_under_directory    directory=${config_path}
    ...                                                                    connection=VM
    ...                                                                    file_indicator=*.txt
    ${swconfig_file_length}    get length    ${swconfig_file}
    Run Keyword If    ${swconfig_file_length} != 0    Set Test Variable    ${swconfig_file}    ${swconfig_file[0]}
    Run Keyword If    '${swconfig_file}' != '[]'    ReplaceSwconfig
    ...                                             local_path=${config_path}/${swconfig_file}
    ...                                             remote_path=/ffs/run/swconfig.txt
    [Teardown]    Disconnect VM

Update Swconfig
    [Arguments]    ${swconfig_file_path}    ${alias}=First_ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The kw is used to replace and crasign the swconfig file to control board /ffs/run.
    ...                But will NOT reboot the BTS, if you need to take this affect, please reboot BTS after this KW.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${swconfig_file_path} | Yes | The swconfig.txt file full path and file name. E.g. /home/ute/swconfig/swconfig.txt |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Update Swconfig | swconfig_file_path=home/ute/swconfig/swconfig.txt |
    ...
    Log to console    \n***Update Swconfig***
    ReplaceSwconfig    local_path=${swconfig_file_path}
    ...                remote_path=/ffs/run/swconfig.txt
    [Teardown]     Run Keyword And Ignore Error    ssh.disconnect    connection=${alias}

ReplaceSwconfig
    [Arguments]    ${local_path}=home/ute/swconfig/swconfig.txt    ${remote_path}=/ffs/run/swconfig.txt
    ...            ${alias}=First_ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                The kw is used to replace and crasign the swconfig file to control board /ffs/run.
    ...                But will NOT reboot the BTS, if you need to take this affect, please reboot BTS after this KW.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_path} | Yes | The swconfig.txt file full path and file name. E.g. /home/ute/swconfig/swconfig.txt |
    ...    | ${remote_path} | No | The control board swconfig path, default is /ffs/run/swconfig.txt |
    ...    | ${alias} | No | The connection to the control board ASIX, default is First_ASIB |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | ReplaceSwconfig | local_path=home/ute/swconfig/swconfig.txt |
    ...
    Run Keyword If    '${alias}'=='First_ASIB'    Connect to First_ASIB    alias=${alias}
    ssh.upload_file    local_path=${local_path}    remote_path=${remote_path}    connection=${alias}
    ${cmd}=    Catenate    cd /ffs/run/ && crasign swconfig.txt
    ssh.execute    command=${cmd}    connection=${alias}
    Run Keyword If    '${alias}'=='First_ASIB'    ssh.disconnect    connection=${alias}

Modify Swconfig by command
    [Arguments]    ${item}=0x340000    ${old_value}=15    ${new_value}=1    ${alias}=First_ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Modify swconfig configuration in swconfig file and crasign. Cannot add new flags.
    ...                But will NOT reboot the BTS, if you need to take this affect, please reboot BTS after this KW.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${item} | Yes | The indicated swconfig.txt flag to be changed the value. E.g. 0x340000 |
    ...    | ${old_value} | Yes | The indicated swconfig.txt flag original value. E.g. 15 |
    ...    | ${new_value} | Yes | The indicated swconfig.txt flag new value. E.g. 1 |
    ...    | ${alias} | No | The connection to the control board ASIX, default is First_ASIB |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | ReplaceSwconfig | local_path=home/ute/swconfig/swconfig.txt |
    ...
    Connect to First_ASIB    alias=${alias}
    ${cmd}=    Catenate    cd /ffs/run/ && grep -q ${item} swconfig.txt &&
    ...                    sed -i -E 's/^.*${item}\s{0,}=.*/${item}=${new_value}/g' swconfig.txt || echo ${item}=${new_value} >> swconfig.txt
    csn.Execute    cmd=${cmd}    alias=${alias}
    csn.Execute    cmd=cd /ffs/run/ && crasign swconfig.txt    alias=${alias}
    ssh.disconnect    connection=${alias}

Modify swconfig
    [Arguments]    ${para_update}=${null}    ${swconfig_path}=/home/ute    ${para_delete}=${null}    ${connection}=First_ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Modify, add, delete swconfig configuration in swconfig file and crasign.
    ...                But will NOT reboot the BTS, if you need to take this affect, please reboot BTS after this KW.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${para_update} | Yes | The swconfig.txt flags and values to be modified or added. E.g. in example. |
    ...    | ${swconfig_path} | No | The vm local path to edit the swconfig. Default is /home/ute |
    ...    | ${para_delete} | No | The swconfig.txt flags and values to be deleted. E.g. in example. |
    ...    | ${connection} | No | The connection to the control board ASIX, default is First_ASIB |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | ${para_update}= | Create list | 0x580011=0 | 0x580013=0 |
    ...    | ${para_delete}= | Create list | 0x580015=0 | 0x580016=0 |
    ...    | Modify Swconfig | para_update=${para_update} | para_delete=${para_delete} |  |
    ...
    wait until keyword succeeds    15 min    3 sec    Connect to First_ASIB    alias=${connection}
    swconf.download_swConfig_file_from_asib_to_test_pc    localFilePath=${swconfig_path}/swconfig.txt
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    ...                                                   asik_alias=${connection}
    swconf.Modify swConfig file    parametersList=${para_update}
    ...                            filePath=${swconfig_path}/swconfig.txt
    Run Keyword if    ${para_delete}!=${null}    swconf.delete_parameter_of_swConfig_file    parametersList=${para_delete}
    ...                                                                                      filePath=${swconfig_path}/swconfig.txt
    swconf.upload_swConfig_file_to_asib_and_crasign    localFilePath=${swconfig_path}/swconfig.txt
    ...                                                asik_alias=${connection}

#----Other Operations----------------------------------------------------------------------------------------
Get_domain_id
    [Arguments]    ${alias}=ASIB
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to get the domain id.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The connection to the control board ASIX, default is ASIB  |
    ...
    ...    | Return Value | Description |
    ...    | ${Domain_ID} | The domain ID |
    ...
    ...    Example
    ...    | ${domain_id}= | Get_domain_id |
    ...
    Connect to First_ASIB    alias=ASIB
    Set Test Variable    ${connection_ASIB}    ${alias}
    ${domain_id}=
    ...    Execute Command On Enb    ddal -s ddal_sysinfo_module_get_domain_id 0| tail -c 2
    ...                              alias=${connection_ASIB}
    ${domain_id}=    Set Variable If    ('${domain_id}'=='1' or '${domain_id}'=='0')    1
    ...                                 ('${domain_id}'=='2')    4
    Set Suite Variable    ${Domain_ID}    ${domain_id}
    [Return]    ${Domain_ID}
    [Teardown]    csn.disconnect    connection=ASIB

Get the container id
    [Arguments]    ${local_node_id}    ${node_name}    ${connection_alias}=ASIB Master    ${gnb_index}=${0}    ${du_index}=${0}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to get the container id.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${local_node_id} | Yes | Refer to ASIB/ABIL Master/Slave node id, eg, 0x1011, 0x123D  |
    ...    | ${node_name} | Yes | refer to container name, eg, UPUE, CPIF  |
    ...    | ${connection_alias} | No | The connection to the control board ASIX, default is ASIB Master  |
    ...    | ${gnb_index} | No | The gNB index for this test line, default is 0 |
    ...    | ${du_index} | No | The DU index for this test line in the indicated gNB, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${container_id} | The domain ID |
    ...
    ...    Example
    ...    | ${container_id}= | Get the container id | local_node_id=CPIF00 | node_name=CPIF00 |
    ...
    csn.connect_to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${connection_alias}
    ${cmd}    Catenate    export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/SupervisorS.py -n ${local_node_id}
    ...               -o list_cbts -p 15004 | grep -i ${node_name} |awk '{print $2}'
    ${cmd_output}    csn.Execute    command=${cmd}    connection=${connection_alias}
    ${output_len}    Get length    ${cmd_output}
    Should be true    ${output_len} > ${0}    msg=there is no ${node_name} in ${local_node_id}.
    ${container_id_tmp}    fetch from left    ${cmd_output}    ,
    ${container_id}    fetch from right    ${container_id_tmp}    :
    [Return]    ${container_id}

CMAS Notification
    [Arguments]    ${amf}=&{AMF6_Han}
    ...            ${message_identifier}=4372
    ...            ${serial_number}=51
    ...            ${repetition_period}=5
    ...            ${number_of_broadcasts_requested}=${10}
    ...            ${connection}=${cbctest_alias}
    ...            ${content_idx}=${0}
    ...            ${test_amf_name}=test_amf_RRM3.py
    ...            ${testcase_name}=testcase
    ...            ${nr_of_bits_g_node_b_id}=22
    ...            ${cell_id}=2
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to trigger the CMAS notification.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${amf} | No | Default is &{AMF6_Han} |
    ...    | ${message_identifier} | No | Default is 4372 |
    ...    | ${serial_number} | No | Default is 51 |
    ...    | ${repetition_period} | No | Default is 5 |
    ...    | ${number_of_broadcasts_requested} | No | Default is ${10} |
    ...    | ${connection} | No | Default is ${cbctest_alias} |
    ...    | ${content_idx} | No | Default is ${0} |
    ...    | ${test_amf_name} | No | Default is test_amf_RRM3.py |
    ...    | ${testcase_name} | No | Default is testcase |
    ...    | ${nr_of_bits_g_node_b_id} | No | Default is 22 |
    ...    | ${cell_id} | No | Default is 2 |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | CMAS Notification | amf=${tang_amf} |
    ...    | ...               | message_identifier=4372 |
    ...    | ...               | serial_number=51 |
    ...    | ...               | repetition_period=5 |
    ...    | ...               | number_of_broadcasts_requested=${10} |
    ...    | ...               | connection=${cbctest_alias} |
    ...    | ...               | nr_of_bits_g_node_b_id=32 |
    ...    | ...               | cell_id=1 |
    Connect to Cbctest
    #ssh.upload_file    local_path=${cbctest_path}/${test_amf_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    #ssh.upload_file    local_path=${cbctest_path}/${testcase_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    ${cmd_local}    catenate    ${cbctest_path}/${testcase_name} ${cbctest_path}/${test_amf_name}
    ...                         &{amf}[connect_hostname] &{amf}[mcc] &{amf}[mnc]
    ...                         &{amf}[tac] ${MRBTS_ID} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${repetition_period}
    ...                         ${number_of_broadcasts_requested} ${cell_id}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    20s
    csn.read_output    connection=${connection}

CMAS PWS Cancel
    [Arguments]    ${amf}=&{AMF6_Han}
    ...            ${message_identifier}=4372
    ...            ${serial_number}=51
    ...            ${connection}=${cbctest_alias}
    ...            ${PWS_Cancel_name}=pws_cancel_RRM3.py
    ...            ${testcase_name}=testcase
    ...            ${nr_of_bits_g_node_b_id}=22
    ...            ${cell_id}=2
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is to trigger the CMAS notification.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${amf} | No | Default is &{AMF6_Han} |
    ...    | ${message_identifier} | No | Default is 4372 |
    ...    | ${serial_number} | No | Default is 51 |
    ...    | ${connection} | No | Default is ${cbctest_alias} |
    ...    | ${PWS_Cancel_name} | No | Default is pws_cancel_RRM3.py |
    ...    | ${testcase_name} | No | Default is testcase |
    ...    | ${nr_of_bits_g_node_b_id} | No | Default is 22 |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | CMAS PWS Cancel | amf=&{AMF6_Han} |
    ...    | ...             | nr_of_bits_g_node_b_id=32 |
    ...    | ...             | cell_id=1 |
    ...    | ...             | connection=${cbctest_alias} |
    ...
    Connect to Cbctest
    #ssh.upload_file    local_path=${cbctest_path}/${PWS_Cancel_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    #ssh.upload_file    local_path=${cbctest_path}/${testcase_name}    remote_path=/home/cbctest    connection=${cbctest_alias}
    ${cmd_local}    catenate    ${cbctest_path}/${testcase_name} ${cbctest_path}/${PWS_Cancel_name}
    ...                         &{amf}[connect_hostname] &{amf}[mcc] &{amf}[mnc]
    ...                         &{amf}[tac] ${MRBTS_ID} ${nr_of_bits_g_node_b_id}
    ...                         ${message_identifier} ${serial_number} ${cell_id}
    csn.send_command    command=${cmd_local}    connection=${connection}
    Sleep    20s
    csn.read_output    connection=${connection}

#----RRM Suite Setup Operations------------------------------------------------------------------------------
Get Active Run Path
    [Arguments]    ${alias}=BTS_LOCAL_Conn
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                This keyword is used to return actual vendor directory from bts.
    ...                In some bts, the value of run (/ffs/run) is not the real run directory, it need to read it from the link.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The connection to the control board ASIX, default is BTS_LOCAL_Conn  |
    ...
    ...    | Return Value | Description |
    ...    | ${default_run_path} | Actual vendor directory from bts |
    ...
    ...    Example
    ...    | ${run_path}= | Get Active Run Path |
    ...
    ${default_run_path}    Set Variable    /ffs/run
    ${ret}    ssh.Execute    command=readlink ${default_run_path}    connection=${alias}
    ${real_run_list}    Split To Lines    ${ret}
    FOR    ${real_path}    IN    @{real_run_list}
        ${default_run_path}    Set Variable    ${real_path}
        Exit For Loop If    '${/}' in '${real_path}'
    END
    [Return]    ${default_run_path}

Get Active Bts Sw Version
    [Arguments]    ${alias}=BTS_LOCAL_Conn
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get active BTS SW Build Version from enb targetBD file.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${alias} | No | The connection to the control board ASIX, default is BTS_LOCAL_Conn  |
    ...
    ...    | Return Value | Description |
    ...    | ${active_sw_version} | Active BTS SW Build Version from enb targetBD file |
    ...
    ...    Example
    ...    | ${active_sw_version}= | Get Active Bts Sw Version |
    ...
    ${target_BD_files}    ssh.Execute    command=cd /ffs/run;ls TargetBD_SBTS*.xml    connection=${alias}
    ${target_BD_file_list}    Split To Lines    ${target_BD_files}
    ${target_BD_file_name}    Get Matches    ${target_BD_file_list}    regexp=TargetBD_[A-Z0-9_]+.xml
    ${active_sw_version}    Remove String    ${target_BD_file_name[0]}    TargetBD_    .xml
    Log to Console    \n***Active Bts Sw Version ${active_sw_version}***
    Set Suite Variable    ${ACTIVE_SW_VERSION}    ${active_sw_version}
    [Return]    ${active_sw_version}

Fix SBTS Trunk Sw Version
    [Arguments]    ${sw}
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Fix trunk SWB version from SBTS22R1_ENB_XXX to SBTS00_ENB_XXX.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | The sw version you need to fix |
    ...
    ...    | Return Value | Description |
    ...    | ${fix_sw_version} | Trunk SWB version in format of SBTS00_ENB_XXX |
    ...
    ...    Example
    ...    |  ${sw_version}=  |  Fix SBTS Trunk Sw Version  |  sw=${sw}  |
    ...
    ${fix_sw_version}    Run Keyword If    "ENB_9999" in "${sw}"    Replace String Using Regexp    ${sw}
    ...    SBTS[0-9A-Za-z]+_    SBTS00_
    ...    ELSE    Set Variable    ${sw}
    [Return]    ${fix_sw_version}

Get Release By Sw Version
    [Arguments]    ${sw}
    [Documentation]    Author: He Winnie
    ...                Contact: winnie.he@nokia-sbell.com
    ...                Get the release information (SBTS00, SBTS 22R1, etc.) from SWB version.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${sw} | Yes | The sw version |
    ...
    ...    | Return Value | Description |
    ...    | ${RELEASE} | Release info. (SBTS00, SBTS 22R1, etc.) |
    ...
    ...    Example
    ...    |  ${release}=  |  Get Release By Sw Version  |  sw=${sw}  |
    ...
    ${sw_list}    Split String    ${sw}    _
    ${Release}    Run Keyword If    "ENB_999" in "${sw}"
    ...    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${sw_list[0]}
    Log to Console    \n***Release ${Release}***
    Set Suite Variable    ${RELEASE}    ${Release}
    [Return]    ${RELEASE}

#----Reporting Portal and Robot file checking Operations (Should be removed from this file later)------------
Report Result To Reporting Portal1
    [Arguments]    ${qc_instance_id}    ${testline}    ${qc_name}
    ...            ${qc_set_name}    ${qc_lab_path}    ${ca}=SRAN_Prod_RRM
    ...            ${username}=mengyang    ${qc_domain}=MN_SRAN    ${qc_project}=SRAN_SBTS
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Report TC result to reporting portal and QC without qc_id.
    ...                Use TAG name 'SKIP_REPORT' to skip the sending Report result to REP.
    ...
    ...    | Variable: |
    ...    | reporting_dict:  contains below parameters with example. |
    ...    | 'qc_project': 'SRAN_SBTS', |
    ...    | 'qc_domain': 'MN_SRAN', |
    ...    | 'squad': 'SRAN_Prod_HZH_RRM_3_Vrf', |
    ...    | 'username': 'owner', |
    ...    | 'suite_path': 'robotws5g/tree/master/testsuite/RRM/Hangzhou/SRAN_5G/CB005882/5GC001983.robot', |
    ...    | 'qc_test_set_name': '5GC001983_Verify the UL SU-MIMO when codebookSubset is noncoherent', |
    ...    | 'features_covered': ["5GC001983-A", "5GC001983-B"], |
    ...    | 'qc_testlab_paths': ['Root\\Trunk_COMMON\\MN SRAN Prod RRM Pz\\SRAN_Prod_HZH_RRM_3_Vrf', |
    ...    |                      'Root\\Test_Sets\\Trunk\\0.835\\5G_SW\UE_Call_Setup']} |
    ...    | test_instance_name:  name should be same as test case instance name in QC. |
    ...    | result_of_test: TC status, Passed or Failed. Default None, then status will read it from ${TEST STATUS} |
    ...    | ute_testline - run time variable is mandatory to send result to REP. |
    ...
    &{links}    Create Dictionary
    ${add_info}    Create List    UTE    TAF
    ${sw_version}=    COAM_Admin.GetSBTSSWVersion
    rp.report_to_rp
    ...    result=Passed
    ...    ca=${ca}
    ...    build=${sw_version}
    ...    username=${username}
    ...    links=${links}
    ...    tool=Robot
    ...    add_info=${add_info}
    ...    name=${qc_name}
    ...    qc_test_set_name=${qc_set_name}
    ...    qc_testlab_path=${qc_lab_path}
    ...    qc_domain=${qc_domain}
    ...    qc_project=${qc_project}
    ...    qc_id=${qc_instance_id}
    ...    testline=${testline}

Report Result To Reporting Portal
    [Arguments]    ${qc_instance_id}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Reports TC result to reporting portal and QC without qc_id.
    ...                Use TAG name 'SKIP_REPORT' to skip the sending Report result to REP.
    ...
    ...    | Variable: |
    ...    | reporting_dict:  contains below parameters with example. |
    ...    | 'qc_project': 'SRAN_SBTS', |
    ...    | 'qc_domain': 'MN_SRAN', |
    ...    | 'squad': 'SRAN_Prod_HZH_RRM_3_Vrf', |
    ...    | 'username': 'owner', |
    ...    | 'suite_path': 'robotws5g/tree/master/testsuite/RRM/Hangzhou/SRAN_5G/CB005882/5GC001983.robot', |
    ...    | 'qc_test_set_name': '5GC001983_Verify the UL SU-MIMO when codebookSubset is noncoherent', |
    ...    | 'features_covered': ["5GC001983-A", "5GC001983-B"], |
    ...    | 'qc_testlab_paths': ['Root\\Trunk_COMMON\\MN SRAN Prod RRM Pz\\SRAN_Prod_HZH_RRM_3_Vrf', |
    ...    |                      'Root\\Test_Sets\\Trunk\\0.835\\5G_SW\UE_Call_Setup']} |
    ...    | test_instance_name:  name should be same as test case instance name in QC. |
    ...    | result_of_test: TC status, Passed or Failed. Default None, then status will read it from ${TEST STATUS} |
    ...    | ute_testline - run time variable is mandatory to send result to REP. |
    ...
    &{links}    Create Dictionary
    ${add_info}    Create List    UTE    TAF
    ${sw_version}=    COAM_Admin.GetSBTSSWVersion
    ${sw_version_list}    Split String    ${sw_version}    _
    ${branch}    Get From List    ${sw_version_list}    0
    ${test_result}    Set Variable If    '${TEST_STATUS}' == 'PASS'    Passed    Failed
    ${qc_lab_path}    Set Variable If    '${branch}' == 'SBTS22R2'    ${trunk_qc_lab_path}
    ...                       ELSE IF    '${branch}' == 'SBTS22R1'    ${branch_qc_lab_path}
    rp.report_to_rp    ca=${ca}
    ...                build=${sw_version}
    ...                username=${username}
    ...                links=${links}
    ...                tool=Robot
    ...                add_info=${add_info}
    ...                result=${test_result}
    ...                qc_test_set_name=${qc_set_name}
    ...                qc_testlab_path=${qc_lab_path}
    ...                qc_domain=${qc_domain}
    ...                qc_project=${qc_project}
    ...                qc_id=${qc_instance_id}
    ...                testline=${testline}
    ...                name=${TEST_NAME}

Report Result To Reporting Portal with KPI
    [Arguments]    ${qc_instance_id}    ${testline}    ${qc_name}
    ...            ${qc_set_name}    ${qc_lab_path}    ${kpi_results}
    ...            ${ca}=SRAN_Prod_RRM    ${username}=mengyang    ${qc_domain}=MN_SRAN    ${qc_project}=SRAN_SBTS
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Reports TC result to reporting portal and QC without qc_id.
    ...                Use TAG name 'SKIP_REPORT' to skip the sending Report result to REP.
    ...
    ...    | Variable: |
    ...    | reporting_dict:  contains below parameters with example. |
    ...    | 'qc_project': 'SRAN_SBTS', |
    ...    | 'qc_domain': 'MN_SRAN', |
    ...    | 'squad': 'SRAN_Prod_HZH_RRM_3_Vrf', |
    ...    | 'username': 'owner', |
    ...    | 'suite_path': 'robotws5g/tree/master/testsuite/RRM/Hangzhou/SRAN_5G/CB005882/5GC001983.robot', |
    ...    | 'qc_test_set_name': '5GC001983_Verify the UL SU-MIMO when codebookSubset is noncoherent', |
    ...    | 'features_covered': ["5GC001983-A", "5GC001983-B"], |
    ...    | 'qc_testlab_paths': ['Root\\Trunk_COMMON\\MN SRAN Prod RRM Pz\\SRAN_Prod_HZH_RRM_3_Vrf', |
    ...    |                      'Root\\Test_Sets\\Trunk\\0.835\\5G_SW\UE_Call_Setup']} |
    ...    | test_instance_name:  name should be same as test case instance name in QC. |
    ...    | result_of_test: TC status, Passed or Failed. Default None, then status will read it from ${TEST STATUS} |
    ...    | ute_testline - run time variable is mandatory to send result to REP. |
    ...
    &{links}    Create Dictionary
    ${add_info}    Create List    UTE    TAF
    ${sw_version}=    COAM_Admin.GetSBTSSWVersion
    rp.report_to_rp
    ...    result=Passed
    ...    ca=${ca}
    ...    build=${sw_version}
    ...    username=${username}
    ...    links=${links}
    ...    tool=Robot
    ...    add_info=${add_info}
    ...    name=${qc_name}
    ...    qc_test_set_name=${qc_set_name}
    ...    qc_testlab_path=${qc_lab_path}
    ...    qc_domain=${qc_domain}
    ...    qc_project=${qc_project}
    ...    qc_id=${qc_instance_id}
    ...    testline=${testline}
    ...    kpi_results=${kpi_results}

Report KPI Result To Reporting Portal
    [Arguments]    ${target}    ${name}    ${value}    ${description}=Average DL UDP throughput
    ...            ${visible_to_db}=True    ${kpi_type}=float
    ...            ${category}=Performance    ${unit}=Mbits
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Reports KPI result to reporting portal
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${target}        | Yes  | KPI target |
    ...    | ${name}          | Yes  | KPI name |
    ...    | ${value}         | Yes  | KPI value |
    ...    | ${description}   | Yes  | KPI description |
    ...    | ${visible_to_db} | No   | defines visibility for db |
    ...    | ${kpi_type}      | No   | KPI type |
    ...    | ${category}      | No   | KPI category |
    ...    | ${unit}          | No   | KPI unit |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | ${kpi_results} | Report KPI Result To Reporting Portal | target=100   |
    ...    | ...            |                                       | name=DL_TPUT |
    ...    | ...            |                                       | value=150    |
    ...
    #${ts_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${kpi_results}    rp.report_kpi_results
    ...               target=${target}
    ...               name=${name}
    ...               visible_to_db=${visible_to_db}
    ...               value=${value}
    ...               kpi_type=${kpi_type}
    ...               description=${description}
    ...               category=${category}
    ...               unit=${unit}
    [Return]    ${kpi_results}

Report testcase name to Rep
    [Arguments]    ${case_name}=${TEST_NAME}
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                Report testcase name to reporting portal
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${case_name} | No | The case name |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Report testcase name to Rep |
    ...
    map_testcase    testcase_name=${case_name}

Check Robot File Name
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to Check Robot File Name.
    ...                Should contains no special charactors or no more than 150 charactors.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Check Robot File Name |
    ...
    ${path}    ${robot_file_name}    OperatingSystem.Split Path    ${SUITE_SOURCE}
    should be true    ${robot_file_name.__len__()<=150}
    ${matches}    get regexp matches    ${robot_file_name}    ^[0-9a-zA-Z_.-]+$
    should be true    ${matches}    Robot file name should consist of 0-9a-zA-Z_.-

Check Suite Name
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to check suite name.
    ...                Should contains no special charactors or no more than 150 charactors.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Check Suite Name |
    ...
    log to console    ${SUITE_NAME}
    should be true    ${SUITE_NAME.__len__()<=150}
    ${matches}    get regexp matches    ${SUITE_NAME}    ^[0-9a-zA-Z_\\s-]+$
    should be true    ${matches}    Suite name should consist of 0-9a-zA-Z_-

Check Maximum Line Length
    [Documentation]    Author: Yang Mengli
    ...                Contact: mengli.yang@nokia-sbell.com
    ...                This kw is used to Check Maximum Line Length less than 150 character.
    ...                Each line should contains no more than 150 charactors.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | No | NA | NA |
    ...
    ...    | Return Value | Description |
    ...    | No | NA |
    ...
    ...    Example
    ...    | Check Maximum Line Length |
    ...
    ${expression}    set variable    [("line_number:{}".format(int(i+1)),"length:{}".format(len(line.strip('\\n'))),line.strip('\\r\\n'))
    ${expression}    set variable    ${expression} for i,line in enumerate(open("${SUITE_SOURCE}")) if len(line.strip('\\n'))>150]
    ${invalid_lines}    evaluate    ${expression}
    run keyword if    ${invalid_lines.__len__()>0}    log to console    robot line length should be <=150(${SUITE_SOURCE})
    should be true    ${invalid_lines.__len__()==0}    ${invalid_lines}

Start Alarm Watch Dog
    [Documentation]    fetch all the alarms from all site which fill in tl.gnbs
    ${gnb_count}    Get Length     ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_count}
        Alarm Operation    operation=start_watch_alarms
        ...                product_type=gnb
        ...                bts_index=${gnb_index}
    END

__check_the_detached_alarms
    [Arguments]    ${res}    ${combined_allow_fault_alarms}
    FOR    ${alarm_obj}    IN    @{res}
        __check_the_detached_alarms_for_one_res    ${alarm_obj}    ${combined_allow_fault_alarms}
    END

__check_the_detached_alarms_for_one_res
    [Arguments]    ${alarm_obj}    ${combined_allow_fault_alarms}
    ${is_exclude}    Set Variable     ${False}
    FOR    ${allowed_alarm}    IN    @{combined_allow_fault_alarms}
        ${is_exclude}    Set Variable If   '${allowed_alarm}[faultId]'=='${alarm_obj.fault_id}'
        ...    ${TRUE}    ${FALSE}
        IF    '${allowed_alarm}[faultId]'=='${alarm_obj.fault_id}'
        ...    BREAK
    END
    Run Keyword If    '${is_exclude}'=='${FALSE}'
    ...    Log    level=WARN
    ...    html=${TRUE}
    ...    message=There are some alarm in the site ${gnb_index}, ${alarm_obj}

Stop And Analysis Alarm Watch Dog
    [Documentation]    fetch all the alarms from all site which fill in tl.gnbs
    [Arguments]
    ...    ${tl_allowed_faults_file_path}=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    ${combined_allow_fault_alarms}    Get All Allow Faults
    ...    tl_allowed_faults_file_path=${tl_allowed_faults_file_path}
    ${gnb_count}    Get Length     ${tl.gnbs}
    FOR    ${gnb_index}    IN RANGE    ${gnb_count}
        ${res}    Alarm Operation    operation=get_detected_alarms
        ...                          product_type=gnb
        ...                          bts_index=${gnb_index}
        ...                          ignored_alarms=${combined_allow_fault_alarms}
        __check_the_detached_alarms    ${res}    ${combined_allow_fault_alarms}
        Run Keyword And Ignore Error
        ...    Alarm Operation    operation=stop_watch_alarms   product_type=gnb
        ...    bts_index=${gnb_index}
    END
