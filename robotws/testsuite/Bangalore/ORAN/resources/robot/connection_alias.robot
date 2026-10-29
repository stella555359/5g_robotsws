*** Settings ***

Documentation     Keywords For Classical

Library     taf.collectors.tcpdump      WITH NAME   tcpdump
Library     taf.collectors.core         WITH NAME   core
Library     taf.transport.ssh           WITH NAME   SSH
Library     taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library     taf.gnb.oam.coam.admin      WITH NAME    coamadmin
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info

*** Keywords ***
Connect To Classic Gnb Asik
    [Arguments]    ${alias}=GNB_ASIK
    csn.connect_to      hostname=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...                 username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...                 password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}    alias=${alias}

Connect To Ap Asik
    [Arguments]    ${alias}=AP_ASIK
    csn.connect_to      hostname=${tl.ues[0].l1.common_units[0].lmp_connection.addr}
    ...                 username=${tl.ues[0].l1.common_units[0].lmp_connection.username}
    ...                 password=${tl.ues[0].l1.common_units[0].lmp_connection.password}    alias=${alias}

Connect to Common Unit Master
    [Documentation]    Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe ASIK.
    ...                In cloud gNB, ASIK Master connection need OAM as proxy.
    ...                In classical gNB, ASIK Master connection don't need any proxy.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    ${dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${proxy}   alias=${alias}

Connect to Capacity Unit Master
    [Documentation]    Connect to Capacity Unit Master with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: ABIL Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Master    ${asik_alias}=ASIK Master
    Connect to Common Unit Master    ${du_index}    alias=${asik_alias}
    ${hoststr}    SSH.execute    arp -a| grep 'fsp-.*${hw_slot}a[[:space:]].*$'    ${asik_alias}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    @{hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asik_alias}    alias=${alias}

Connect to All Capacity Unit Master
    [Documentation]    Connect to All Capacity Unit Master with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK connect to ABIL minnum one and maxnum three.
    ...                one ABIL contains one ABIL Master, one ABIL Slave, one ABIL Loner.
    ...                :param ${alias}: it's part of final alias. For example: ABIL Master0, ABIL Master1...
    ...                :return: final ${abil_index} is abil number
    [Arguments]    ${alias}=ABIL Master
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ${dus}    testline_info.get_du_list    ${tl}
    ${asik_index}    Set Variable    ${0}
    ${abil_index}    Set Variable    ${0}
    FOR    ${du}    IN    @{dus}
            ssh.Connect to    ${du.airscale.common_units[0].lmp_connection.addr}
    ...                       ${du.airscale.common_units[0].lmp_connection.username}
    ...                       ${du.airscale.common_units[0].lmp_connection.password}
    ...                       proxy=${proxy}    alias=ASIK Master${asik_index}
            ${hoststr}    SSH.execute    arp -a| grep 'fsp-...a.*etha01'    ASIK Master${asik_index}
            ${hostnames}    Get Hosts From String    ${hoststr}
            ${abil_index}=    Connect to ABIL Component    ${hostnames}
    ...                                                    ${du.airscale.common_units[0].lmp_connection.username}
    ...                                                    ${du.airscale.common_units[0].lmp_connection.password}
    ...                                                    ASIK Master${asik_index}
    ...                                                    ${alias}
    ...                                                    ${abil_index}
            ${asik_index}    Evaluate    ${asik_index}+1
    END
    Return From Keyword    ${abil_index}

Connect to Common Unit Slave
    [Documentation]    Connect to Common Unit Slave with IP which search from ASIK Master.
    ...                username and password are same to related ASIK Master.
    ...                set related ASIK Master as proxy is mandantory.
    ...                one ASIK only have one ASIK Master and one ASIK Slave.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: ASIK Slave is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Slave
    Connect to Common Unit Master    ${du_index}
    ${hoststr}    ssh.execute    arp -a | grep fct    ASIK Master
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    @{hostnames}[0]
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=ASIK Master    alias=${alias}

Connect to ABIL Component
    [Documentation]    ABIL Component means abil master, abil slave, abil loner.
    ...                :param ${components}: input ABIL Components list
    ...                :param ${username}: abil component username, same to ASIK MASTER
    ...                :param ${password}: abil component password, same to ASIK MASTER
    ...                :param ${proxy}: usually is ASIK MASTER
    ...                :param ${alias}: can be set by user
    ...                :param ${component_index}: abil Component index
    ...                :return: return final ${component_index}
    [Arguments]    ${components}    ${username}    ${password}    ${proxy}    ${alias}    ${component_index}
    FOR    ${component}    IN    @{components}
            ssh.Connect to    ${component}    ${username}    ${password}    proxy=${proxy}
    ...     alias=${alias}${component_index}
            ${component_index}    Evaluate    ${component_index}+1
    END
    Return From Keyword    ${component_index}

Connect to Cloud OAM
    [Documentation]    connect to cloud gNB OAM VM. addr, username, password are from testline_configuration.
    ...                :param ${gnb_index}: testline_info.get_cloudbts_gnbs will return cloud gNB list, any element can be visited in list.
    ...                :param ${alias}: OAM is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${alias}=OAM
    ${gnbs}    testline_info.get_cloudbts_gnbs    ${tl}
    Run Keyword If    ${gnbs}
    ...               ssh.Connect to    ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                 ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                                 ${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                                 alias=${alias}
    ...       ELSE    Fail    There is no CloudBts in testline.

Get Hosts From String
    [Documentation]    get IP list from String which search from ASIK Master
    ...                :param ${output_string}: is output of searching asik slave ip string
    ...                or abil master ip string, or abil slave ip string, or abil loner ip string from asik master
    ...                :return: asik slave ip list, or abil master ip list, or abil slave ip list, or abil loner ip list.
    [Arguments]    ${output_string}
    @{lines}=    Split To Lines    ${output_string}
    @{hosts}    Create List
    FOR    ${line}    IN    @{lines}
         @{first_split}=    Split String    ${line}    (
         @{second_split}=    Split String    @{first_split}[1]    )
         Append To List    ${hosts}    @{second_split}[0]
    END
    Return From Keyword    @{hosts}

