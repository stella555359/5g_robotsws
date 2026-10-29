*** Settings ***
Documentation     Keywords for ssh connections 

Library    String
Library    Collections
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info

*** Variables ***
*** Keywords ***
Connect to TestPc
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to TestPc. addr, username, password are from testline_configuration.
    ...                :param ${alias}: TestPc is default value, you can set with other name.
    [Arguments]    ${alias}=TestPc
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to Cloud OAM
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to cloud gNB OAM VM. addr, username, password are from testline_configuration.
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
    [Return]    ${alias}

Connect to gNB OAM
    [Documentation]    Author: Rajesh Venkata
    ...                connect to  gNB OAM VM. addr, username, password are from testline_configuration.
    ...                :param ${gnb_index}: testline_info contains  gNB list, any element can be visited in list.
    ...                :param ${alias}: OAM is default value, you can set with other name.
    [Arguments]    ${gnb_index}=${0}    ${alias}=OAM
    ssh.Connect to                      ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...                                 ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...                                 ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...                                 alias=${alias}
    [Return]      ${alias}


Connect to VM
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to cloud gNB VM which need "OAM" as proxy.
    ...                :param ${vmname}: VM name, include CPCL, CPIF, CPNB, CPUE, UPUE, CPNRT, DBVM...
    ...                :param ${gnb_index}: Define which gnb in the testline gnbs list shall be used for this connect.
    ...                default alias is ${vmname}, can't be reset.
    [Arguments]    ${vmname}    ${gnb_index}=${0}
    ${cloud_coam_alias}    Connect to Cloud OAM
    ${vm}=    Convert To Lowercase    ${vmname}
    ${hostname}    _Get hostname    vm=${vm}
    ${gnbs}    testline_info.get_cloudbts_gnbs    ${tl}
    ssh.Connect to    hostname=${hostname}
    ...               username=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               proxy=${cloud_coam_alias}    alias=${vmname}
    [Return]    ${vmname}

_Get hostname
    [Documentation]    Author: Civen Chen
    ...                [PRIVATE] This keyword is used by `Connect to VM`, get hostname with vm type.
    ...                :param ${vm}: lowercase vm name. eg: dbvm, upue, cpue
    [Arguments]    ${vm}
    ${dbvmhostname}    Run keyword if    '${vm}' == 'dbvm'
    ...    ssh.Execute    commmand=echo -n `hostname | sed s/'oam-0'/'db-0'/`.local
    ...                   connection=OAM
    ${hostname} =    Set Variable If    '${vm}' == 'dbvm'
    ...              ${dbvmhostname}
    ...              ${vm}-0.local
    [Return]    ${hostname}

Connect to LTEEmuEnb
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to LTEEmuEnb, addr, username, password are from testline_configuration.
    ...                :param ${lteemuenb_index}: testline_info.get_lteemu_enbs will return LTEEmuEnb list. any element can be visited in list.
    ...                :param ${alias}: LTEEmuEnb is default value, you can set with other name.
    [Arguments]    ${lteemuenb_index}=${0}    ${alias}=LTEEmuEnb
    ${lteemuenbs}    testline_info.get_lteemu_enbs    ${tl}
    Run Keyword If    ${lteemuenbs}
    ...               ssh.Connect to    ${lteemuenbs[${lteemuenb_index}].default_ssh_connection_details.addr}
    ...                                 ${lteemuenbs[${lteemuenb_index}].default_ssh_connection_details.username}
    ...                                 ${lteemuenbs[${lteemuenb_index}].default_ssh_connection_details.password}
    ...                                 alias=${alias}
    ...       ELSE    Fail    There is no LTEEmuEnb in testline.
    [Return]    ${alias}

Connect to DocomoEnb
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to DocomoEnb, addr, username, password are from testline_configuration.
    ...                :param ${docomoenb_index}: testline_info.get_docomo_enbs will return DocomoEnb list. any element can be visited in list.
    ...                :param ${alias}: DocomoEnb is default value, you can set with other name.
    [Arguments]    ${docomoenb_index}=${0}    ${alias}=DocomoEnb
    ${docomoenbs}    testline_info.get_docomo_enbs    ${tl}
    Run Keyword If    ${docomoenbs}
    ...               ssh.Connect to    ${docomoenbs[${docomoenb_index}].default_ssh_connection_details.addr}
    ...                                 ${docomoenbs[${docomoenb_index}].default_ssh_connection_details.username}
    ...                                 ${docomoenbs[${docomoenb_index}].default_ssh_connection_details.password}
    ...                                 alias=${alias}
    ...       ELSE    Fail    There is no DocomoEnb in testline.
    [Return]    ${alias}

Connect to PrismaEnb
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to PrismaEnb, addr, username, password are from testline_configuration.
    ...                :param ${prismaenb_index}: testline_info.get_prisma_enbs will return PrismaEnb list. any element can be visited in list.
    ...                :param ${alias}: PrismaEnb is default value, you can set with other name.
    [Arguments]    ${prismaenb_index}=${0}    ${alias}=PrismaEnb
    ${prismaenbs}    testline_info.get_prisma_enbs    ${tl}
    Run Keyword If    ${prismaenbs}
    ...               ssh.Connect to    ${prismaenbs[${prismaenb_index}].tstm_x2_ssh_connection_details.addr}
    ...                                 ${prismaenbs[${prismaenb_index}].tstm_x2_ssh_connection_details.username}
    ...                                 ${prismaenbs[${prismaenb_index}].tstm_x2_ssh_connection_details.password}
    ...                                 alias=${alias}
    ...       ELSE    Fail    There is no PrismaEnb in testline.
    [Return]    ${alias}

Connect to GNB Common Unit Master
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                Connect to Common Unit Master with Mplane IP which configured in EIF port.
    ...                This keyword currently only suitable for DU with singe Common Unit.
    ...                In cloud gNB, Common Unit Master connection need OAM as proxy.
    ...                In classical gNB, Common Unit Master connection don't need any proxy.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: Common Unit Master is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=Common Unit Master    ${common_unit_id}=${0}    ${gnb_index}=${0}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run Keyword If    ${has_cbts}    Connect to Cloud OAM
    ${proxy}    Set Variable If    ${has_cbts}    OAM
    ...                                           ${None}
    ssh.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_id}].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_id}].lmp_connection.password}
    ...               proxy=${proxy}   alias=${alias}
    [Return]    ${alias}

Connect to GNB Common Unit Slave
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                Connect to Common Unit Slave with IP which search from Common Unit Master.
    ...                username and password are same to related Common Unit Master.
    ...                set related Common Unit Master as proxy is mandantory.
    ...                one Common Unit only have one Common Unit Master and one Common Unit Slave.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${alias}: Common Unit Slave is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}    ${alias}=Common Unit Slave    ${common_unit_id}=${0}    ${gnb_index}=${0}
    ${proxy_alias}    Connect to Common Unit Master    ${du_index}    common_unit_id=${common_unit_id}    gnb_index=${gnb_index}
    ${hoststr}    ssh.Execute    commmand=arp -a | grep fct-
    ...                          connection=Common Unit Master
    ${hostnames}    Get Hosts From String    ${hoststr}
    ssh.Connect to    @{hostnames}[0]
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_id}].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${common_unit_id}].lmp_connection.password}
    ...               proxy=${proxy_alias}    alias=${alias}
    [Return]    ${alias}

Connect to GNB Capacity Unit
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                Connect to Capacity Unit ${instance} with IP which search from Common Unit Master.
    ...                username and password are same to related Common Unit Master.
    ...                set related Common Unit Master as proxy is mandantory.
    ...                one Common Unit connect to Capacity Unit minnum one and maxnum three.
    ...                one Capacity Unit contains one Capacity Unit Master, one Capacity Unit Slave, one Capacity Unit ${instance}.
    ...                :param ${instance}: Three valid value: master, slave, loner.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${hw_slot}: In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...                :param ${alias}: Capacity Unit ${instance} is default value, you can set with other name.
    [Arguments]    ${instance}
    ...            ${du_index}=${0}
    ...            ${hw_slot}=${1}
    ...            ${alias}=Capacity Unit ${instance}
    ...            ${common_unit_alias}=Common Unit Master
    ...            ${capacity_unit_id}=${0}
    ...            ${common_unit_id}=${0}
    ...            ${gnb_index}=${0}
    ${hw_character}    set variable if
    ...                '${instance}'=='master'    a
    ...                '${instance}'=='slave'    b
    ...                '${instance}'=='loner'    c
    run keyword if    ${hw_character} == ${None}    fail   msg=instance type should be master/slave/loner!
    ${proxy_alias}    Connect to Common Unit Master    ${du_index}
    ...                                                alias=${common_unit_alias}
    ...                                                common_unit_id=${common_unit_id}
    ...                                                gnb_index=${gnb_index}
    ${hoststr}    ssh.Execute    commmand=arp -a| grep 'fsp-..${hw_slot}${hw_character}.*etha01$'
    ...                          connection=${common_unit_alias}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ssh.Connect to    @{hostnames}[0]
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${capacity_unit_id}].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[${capacity_unit_id}].lmp_connection.password}
    ...               proxy=${proxy_alias}    alias=${alias}
    [Return]    ${alias}

Connect to EPCSim
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to EPCSim which configred in testline_configuration.
    ...                :param ${alias}: EPCSim is default value, you can set with other name.
    [Arguments]    ${alias}=EPCSim
    ${has_epcsim}    testline_info.has_epcsim    ${tl}
    Run Keyword If    ${has_epcsim}==False    Fail    There is no EPCSim in testline.
    ${epcsim}    testline_info.get_core    ${tl}
    ssh.Connect to    ${epcsim.default_ssh_connection_details.addr}
    ...               ${epcsim.default_ssh_connection_details.username}
    ...               ${epcsim.default_ssh_connection_details.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to LTEEmuCore
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to LTEEmuCore which configred in testline_configuration.
    ...                :param ${alias}: LTEEmuCore is default value, you can set with other name.
    [Arguments]    ${alias}=LTEEmuCore
    ${has_lteemucore}    testline_info.has_lteemucore    ${tl}
    Run Keyword If    ${lteemucore}==False    Fail    There is no LTEEmuCore in testline.
    ${lteemucore}    testline_info.get_core    ${tl}
    ssh.Connect to    ${lteemucore.default_ssh_connection_details.addr}
    ...               ${lteemucore.default_ssh_connection_details.username}
    ...               ${lteemucore.default_ssh_connection_details.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to RU
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to RU which IP configred in default_ssh_connection_details in testline_configuration.
    ...                :param ${du_index}: testline_info.get_du_list will return du list, any element can be visited in list.
    ...                :param ${ru_index}: Get RU List will return RU list, any element can be visited in list.
    ...                :param ${alias}: RU is default value, you can set with other name.
    [Arguments]    ${du_index}=${0}     ${ru_index}=${0}    ${alias}=RU
    ${rus}    Get RU List
    ${rus_length}    Get Length    ${rus}
    Run Keyword If    ${rus_length} == 0    Fail    There is no RU in testline.
    Connect to Common Unit Master    ${du_index}
    ssh.Connect to    ${rus[${ru_index}].default_ssh_connection_details.addr}
    ...               ${rus[${ru_index}].default_ssh_connection_details.username}
    ...               ${rus[${ru_index}].default_ssh_connection_details.password}
    ...               proxy=Common Unit Master     alias=${alias}
    [Return]    ${alias}

Connect to RU LMP
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to RU LMP which IP configred in lmp_connection in testline_configuration.
    ...                :param ${ru_index}: Get RU List will return RU list, any element can be visited in list.
    ...                :param ${alias}: RU LMP is default value, you can set with other name.
    [Arguments]    ${ru_index}=${0}    ${alias}=RU LMP
    ${rus}    Get RU List
    ${rus_length}    Get Length    ${rus}
    Run Keyword If    ${rus_length} == 0    Fail    There is no RU in testline.
    ssh.Connect to    ${rus[${ru_index}].lmp_connection.addr}
    ...               ${rus[${ru_index}].lmp_connection.username}
    ...               ${rus[${ru_index}].lmp_connection.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to TM500
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to UE TM500 which configred in testline_configuration.
    ...                :param ${tm500_index}: testline_info.get_tm500_ues will return UE TM500 list, any element can be visited in list.
    ...                :param ${alias}: TM500 is default value, you can set with other name.
    [Arguments]    ${tm500_index}=${0}    ${alias}=TM500
    ${has_tm500}    testline_info.has_tm500    ${tl}
    Run Keyword If    ${has_tm500}==False    Fail    There is no TM500 in testline.
    ${tm500_ues}    testline_info.get_tm500_ues    ${tl}
    ssh.Connect to    ${tm500_ues[${tm500_index}].tma_host.addr}
    ...               ${tm500_ues[${tm500_index}].tma_host.username}
    ...               ${tm500_ues[${tm500_index}].tma_host.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to Airphone Egate
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to UE Airphone Egate which configred in testline_configuration.
    ...                :param ${airphone_index}: testline_info.get_airphone_ues will return UE Airphone list, any element can be visited in list.
    ...                :param ${alias}: Airphone Egate is default value, you can set with other name.
    [Arguments]    ${airphone_index}=${0}    ${alias}=Airphone Egate
    ${has_airphone}    testline_info.has_airphone    ${tl}
    Run Keyword If    ${has_airphone}==False    Fail    There is no Airphone in testline.
    ${airphones}    testline_info.get_airphone_ues    ${tl}
    ssh.Connect to    ${airphones[${airphone_index}].egate.addr}
    ...               ${airphones[${airphone_index}].egate.username}
    ...               ${airphones[${airphone_index}].egate.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to Airphone L2
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to UE Airphone L2 which configred in testline_configuration.
    ...                :param ${airphone_index}: testline_info.get_airphone_ues will return UE Airphone list, any element can be visited in list.
    ...                :param ${alias}: Airphone L2 is default value, you can set with other name.
    [Arguments]    ${airphone_index}=${0}    ${alias}=Airphone L2
    ${has_airphone}    testline_info.has_airphone    ${tl}
    Run Keyword If    ${has_airphone}==False    Fail    There is no Airphone in testline.
    ${airphones}    testline_info.get_airphone_ues    ${tl}
    ssh.Connect to    ${airphones[${airphone_index}].l2_ssh_connection_details.addr}
    ...               ${airphones[${airphone_index}].l2_ssh_connection_details.username}
    ...               ${airphones[${airphone_index}].l2_ssh_connection_details.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to Airphone L3
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to UE Airphone L3 which configred in testline_configuration.
    ...                :param ${airphone_index}: testline_info.get_airphone_ues will return UE Airphone list, any element can be visited in list.
    ...                :param ${alias}: Airphone L3 is default value, you can set with other name.
    [Arguments]    ${airphone_index}=${0}    ${alias}=Airphone L3
    ${has_airphone}    testline_info.has_airphone    ${tl}
    Run Keyword If    ${has_airphone}==False    Fail    There is no Airphone in testline.
    ${airphones}    testline_info.get_airphone_ues    ${tl}
    ssh.Connect to    ${airphones[${airphone_index}].l3_ssh_connection_details.addr}
    ...               ${airphones[${airphone_index}].l3_ssh_connection_details.username}
    ...               ${airphones[${airphone_index}].l3_ssh_connection_details.password}
    ...               alias=${alias}
    [Return]    ${alias}

Connect to Airphone AirphoneCloud
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                connect to UE Airphone AirphoneCloud which configred in testline_configuration.
    ...                :param ${airphone_index}: testline_info.get_airphone_ues will return UE Airphone list, any element can be visited in list.
    ...                :param ${alias}: Airphone AirphoneCloud is default value, you can set with other name.
    [Arguments]    ${airphone_index}=${0}    ${alias}=Airphone AirphoneCloud
    ${has_airphone}    testline_info.has_airphone    ${tl}
    Run Keyword If    ${has_airphone}==False    Fail    There is no Airphone in testline.
    ${airphones}    testline_info.get_airphone_ues    ${tl}
    ssh.Connect to    ${airphones[${airphone_index}].airphone_cloud.oam_ssh_connection_details.addr}
    ...               ${airphones[${airphone_index}].airphone_cloud.oam_ssh_connection_details.username}
    ...               ${airphones[${airphone_index}].airphone_cloud.oam_ssh_connection_details.password}
    ...               alias=${alias}
    [Return]    ${alias}

#base keywords
Get CommonUnit List
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                get CommonUnit list from testline_configuration
    ...                :return: CommonUnits List
    ${dus}    testline_info.get_du_list    ${tl}
    @{commonunits}    Create List
    :FOR    ${du}    IN    @{dus}
    \    ${commonunit}    Set Variable    ${du.airscale.common_units}
    \    ${commonunits}=    Combine Lists    ${commonunits}    ${commonunit}
    [Return]    ${commonunits}

Get Hosts From String
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                get IP list from String which search from Common Unit Master
    ...                :param ${output_string}: is output of searching Common Unit slave ip string
    ...                or Capacity Unit master ip string, or Capacity Unit slave ip string, or Capacity Unit loner ip string from Common Unit master
    ...                :return: Common Unit slave ip list, or Capacity Unit master ip list,
    ...                         or Capacity Unit slave ip list, or Capacity Unit loner ip list.
    [Arguments]    ${output_string}
    @{lines}=    Split To Lines    ${output_string}
    @{hosts}    Create List
    :FOR    ${line}    IN    @{lines}
    \    @{first_split}=    Split String    ${line}    (
    \    @{second_split}=    Split String    @{first_split}[1]    )
    \    Append To List    ${hosts}    @{second_split}[0]
    sort list    ${hosts}
    [Return]    @{hosts}

Get RU List
    [Documentation]    Author: Chaosi Fang, Civen Chen
    ...                get RU list from testline_configuration
    ...                :return: Rus List
    ${dus}    testline_info.get_du_list    ${tl}
    @{rus}    Create List
    :FOR    ${du}    IN    @{dus}
    \    ${ru}    Set Variable    ${du.rus}
    \    @{rus}=    Combine Lists    ${rus}    ${ru}
    [Return]    ${rus}
