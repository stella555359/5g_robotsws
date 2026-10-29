*** Settings ***
Documentation     [PURPOSE] common variable General keywords
Library     BuiltIn
Library     SSHLibrary


*** Variables ***
${MPLAN_IP}


*** Keywords ***
Set Taf Config Variables
    [Documentation]
    ...  | Time | Release | Author | Modification | Relevant feature |
    ...  |20220524 | SRAN22R3 | Amaand.li@nokia-sbell.com | New KW | Set Taf Config Variables|
    ...  |This KW is about convert common variables from cofig file __init__.py. It is used in common setup,and could
    ...   generate test variables as ${SMOD},${RMOD},${TESTPC_IP},${MPLAN_IP}, if you need more info, please contact
    ${INTERFACES}    create dictionary
    set test variable    ${INTERFACES}
    set test variable    ${tl_configuration}  ${tl.tl_cloud_topology}
    ${is_5g_classical}  set variable if   'CLASSICAL' in '${tl_configuration}'  True  False
    Run keyword if  '${is_5g_classical}'=='True' or '${tl_configuration}'=='CLOUD_SRAN_N_ASIKL_ABIL_3FRGY'
    ...  get 5g classival config variables
    ...  ELSE    get common config varialbes

get common config varialbes
    [Documentation]    Short description.
    ${MPLAN_IP}  set variable if  ${tl.enbs[0].oam_ip}  ${tl.enbs[0].oam_ip.v4}
    ${SMOD_COUNT}    Get length   ${tl.enbs}
    FOR  ${i}  IN RANGE  ${SMOD_COUNT}
         ${SMOD}=    Create Dictionary
         ...    USERNAME    ${tl.enbs[${i}].system_module.common_units[0].lmp_connection.username}
         ...    PASSWORD  ${tl.enbs[${i}].system_module.common_units[0].lmp_connection.password}
         ...    HW_TYPE   ${tl.enbs[${i}].system_module.common_units[0].hardware_type}
         ...    IP   ${tl.enbs[${i}].system_module.common_units[0].lmp_connection.addr}
         ...    IM_IP    192.168.255.1
         ...    TRS_IP   192.168.255.129
         ...    SERIAL_NUMBER    ${tl.enbs[${i}].system_module.common_units[0].serial_number}
         ...    PB_IP    ${tl.enbs[${i}].system_module.common_units[0].pdu_port.pdu.addr}
         ...    PB_PORT    ${tl.enbs[${i}].system_module.common_units[0].pdu_port.port_no}
         ...    PB_TYPE    ${tl.enbs[${i}].system_module.common_units[0].pdu_port.pdu.model}
         ...    CONTACTOR    ${tl.enbs[${i}].system_module.common_units[0].pdu_port.contactor}
         ...    UDP_IP    192.168.255.126
         set test variable    ${SMOD${i+1}}    ${SMOD}
         set to dictionary    ${INTERFACES}    SMOD${i+1}    ${SMOD${i+1}}
    END
    ${TESTPC_COUNT}    Get length    ${tl.test_pcs}
    FOR  ${i}  IN RANGE  ${TESTPC_COUNT}
        ${PC_IP}    Get variable value    ${tl.test_pcs[${i}].default_ssh_connection_details.addr}    None
        set test variable    ${PC_IP${i+1}}    ${PC_IP}
    END
    ${RMOD_List}   Run keyword if  '${SMOD_COUNT}'=='2'   combine lists  ${tl.enbs[0].rms}  ${tl.enbs[1].rms}
    ...  ELSE  set variable  ${tl.enbs[0].rms}
    ${RMOD_Left}    Get length  ${tl.enbs[0].rms}
    ${RMOD_Left}  set variable if  ${RMOD_Left} is None  0  ${RMOD_Left}
    ${RMOD_Right}   run keyword if   '${SMOD_COUNT}'=='2'  Get length  ${tl.enbs[1].rms}
    ${RMOD_Right}  set variable if  ${RMOD_Right} is None  0  ${RMOD_Right}
    ${RMOD_COUNT}    Get length    ${RMOD_List}
    Run keyword if   ${RMOD_Left}   get rmod info  rmod_num_left=${RMOD_Left}  left=${True}  rl=0
    Run keyword if   ${RMOD_Right}  get rmod info  rmod_num_left=${RMOD_Left}
    ...  rmod_num_right=${RMOD_Right}  left=${False}  rl=1

get 5g classival config variables
    [Documentation]    Short description.
    log  ${tl.gnbs[0]}
    log  ${tl.gnbs[0].cu}
    ${MPLAN_IP}  set variable if  ${tl.gnbs[0].cu.oam_ssh_connection_details}
    ...  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ${SMOD_COUNT}    Get length   ${tl.gnbs}
    FOR  ${i}  IN RANGE  ${SMOD_COUNT}
         ${SMOD}=    Create Dictionary
         ...    USERNAME    ${tl.gnbs[${i}].dus[0].airscale.common_units[0].lmp_connection.username}
         ...    PASSWORD  ${tl.gnbs[${i}].dus[0].airscale.common_units[0].lmp_connection.password}
         ...    HW_TYPE   ${tl.gnbs[${i}].dus[0].airscale.common_units[0].hardware_type}
         ...    IP   ${tl.gnbs[${i}].dus[0].airscale.common_units[0].lmp_connection.addr}
         ...    IM_IP    192.168.255.1
         ...    TRS_IP   192.168.255.129
         ...    SERIAL_NUMBER    ${tl.gnbs[${i}].dus[0].airscale.common_units[0].serial_number}
         ...    PB_IP    ${tl.gnbs[${i}].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
         ...    PB_PORT    ${tl.gnbs[${i}].dus[0].airscale.common_units[0].pdu_port.port_no}
         ...    PB_TYPE    ${tl.gnbs[${i}].dus[0].airscale.common_units[0].pdu_port.pdu.model}
         ...    CONTACTOR    ${tl.gnbs[${i}].dus[0].airscale.common_units[0].pdu_port.contactor}
         ...    UDP_IP    192.168.255.126
         set test variable    ${SMOD${i+1}}    ${SMOD}
         set to dictionary    ${INTERFACES}    SMOD${i+1}    ${SMOD${i+1}}
    END
    ${TESTPC_COUNT}    Get length    ${tl.test_pcs}
    FOR  ${i}  IN RANGE  ${TESTPC_COUNT}
        ${PC_IP}    Get variable value    ${tl.test_pcs[${i}].default_ssh_connection_details.addr}    None
        set test variable    ${PC_IP${i+1}}    ${PC_IP}
    END
    ${RMOD_List}   Run keyword if  '${SMOD_COUNT}'=='2'  combine lists
    ...  ${tl.gnbs[0].dus[0].rus}  ${tl.gnbs[1].dus[0].rus}
    ...  ELSE  set variable  ${tl.gnbs[0].dus[0].rus}
    ${RMOD_Left}    Get length  ${tl.gnbs[0].dus[0].rus}
    ${RMOD_Left}  set variable if  ${RMOD_Left} is None  0  ${RMOD_Left}
    ${RMOD_Right}   run keyword if   '${SMOD_COUNT}'=='2'  Get length  ${tl.gnbs[1].dus[0].rus}
    ${RMOD_Right}  set variable if  ${RMOD_Right} is None  0  ${RMOD_Right}
    ${RMOD_COUNT}    Get length    ${RMOD_List}
    Run keyword if   ${RMOD_Left}  get rmod info  rmod_num_left=${RMOD_Left}  left=${True}  rl=0  common=${False}
    Run keyword if   ${RMOD_Right}  get rmod info  rmod_num_left=${RMOD_Left}  rmod_num_right=${RMOD_Right}
    ...  left=${False}  rl=1  common=${False}

get rmod info
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${rmod_num_left}: <description>
    ...        ${rmod_num_right}: <description>
    ...        ${left}: <description>
    ...        ${rl}: <description>
    ...        ${common}: <description>
    [Arguments]  ${rmod_num_left}=0  ${rmod_num_right}=0  ${left}=${True}  ${rl}=0  ${common}=${True}
    ${rmod_num}  set variable if  ${left}  ${rmod_num_left}
    ...  ${rmod_num_right}
    FOR  ${j}  IN RANGE  ${rmod_num}
        ${rms}  set variable if  '${common}'=='${True}'  ${tl.enbs[${rl}].rms[${j}]}
        ...  ${tl.gnbs[${rl}].dus[0].rus[${j}]}
         ${RMOD}=    Create dictionary
         ...    RADIO_TYPE    ${rms.radio_type}
         ...    PB_IP    ${rms.pdu_port.pdu.addr}
         ...    PB_PORT    ${rms.pdu_port.port_no}
         ...    SERIAL_NUMBER    ${rms.serial_number}
         ...    PB_TYPE    ${rms.pdu_port.pdu.model}
         ...    CONTACTOR    ${rms.pdu_port.contactor}
         Run keyword if   ${left}
         ...   Run keywords   set test variable    ${RMOD${j+1}}  ${RMOD}
         ...   AND  set to dictionary    ${INTERFACES}    RMOD${j+1}    ${RMOD${j+1}}
         ...   ELSE  Run keywords  set test variable    ${RMOD${j+1+${rmod_num_left}}}  ${RMOD}
         ...   AND  set to dictionary    ${INTERFACES}    RMOD${j+1+${rmod_num_left}}    ${RMOD${j+1+${rmod_num_left}}}
    END
