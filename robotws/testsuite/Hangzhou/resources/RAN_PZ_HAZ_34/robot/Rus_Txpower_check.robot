*** Settings ***
Documentation
...   author: shengrong.rao@nokia-sbell.com
...   contact: shengrong.rao@nokia-sbell.com civen.chen@nokia-sbell.com
...   This robot is main to check RU Tx power, will connitue to update...

Library    String
Library    OperatingSystem
Library    DateTime
Library    Collections
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.config.testline.info.testline_info.TestlineInfo

*** Variables ***
@{RU_Power_check_list}    AWEUA    AWEUB    AWEUC    AEWB    AEUD    AEHC    AEQE    AEQP    AEQY    AEQZ    AEQV    AEQQ    AEQC
&{AWEUA}    22R1=&{RU_account4}    22R2=&{RU_account5}    22R3=&{RU_account5}    22R4=&{RU_account5}
&{AWEWB}    22R1=&{RU_account4}    22R2=&{RU_account5}    22R3=&{RU_account5}    22R4=&{RU_account5}
&{AWEUC}    22R1=&{RU_account4}    22R2=&{RU_account5}    22R3=&{RU_account5}    22R4=&{RU_account5}
&{AWEUB}    22R1=&{RU_account4}    22R2=&{RU_account5}    22R3=&{RU_account5}    22R4=&{RU_account5}
&{AEWB}    22R1=&{RU_account2}    22R2=&{RU_account3}    22R3=&{RU_account3}    22R4=&{RU_account3}
&{AEWD}    22R1=&{RU_account2}    22R2=&{RU_account3}    22R3=&{RU_account3}    22R4=&{RU_account3}
&{AEWE}    22R1=&{RU_account2}    22R2=&{RU_account3}    22R3=&{RU_account3}    22R4=&{RU_account3}
&{AEUB}    22R1=&{RU_account2}    22R2=&{RU_account3}    22R3=&{RU_account3}    22R4=&{RU_account3}
&{AEUD}    22R1=&{RU_account2}    22R2=&{RU_account3}    22R3=&{RU_account3}    22R4=&{RU_account3}
&{AEQN}    22R1=&{RU_account11}    22R2=&{RU_account11}    22R3=&{RU_account12}
&{AZQO}    22R1=&{RU_account8}    22R2=&{RU_account9}    22R3=&{RU_account9}
&{AZQU}    22R1=&{RU_account8}    22R2=&{RU_account9}    22R3=&{RU_account9}
&{AZQJ}    22R1=&{RU_account8}    22R2=&{RU_account9}    22R3=&{RU_account9}
&{AZQL}    22R1=&{RU_account8}    22R2=&{RU_account9}    22R3=&{RU_account11}
&{AZQH}    22R1=&{RU_account8}    22R2=&{RU_account9}    22R3=&{RU_account11}
&{AQQL}    22R1=&{RU_account13}    22R2=&{RU_account13}    22R3=&{RU_account13}
&{AQQK}    22R1=&{RU_account13}    22R2=&{RU_account13}    22R3=&{RU_account13}
&{AEHC}    22R1=&{RU_account8}    22R2=&{RU_account14}    22R3=&{RU_account14}
&{AEHB}    22R1=&{RU_account8}    22R2=&{RU_account14}    22R3=&{RU_account14}
&{AEQE}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AEQP}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AEQZ}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AEQC}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AEQQ}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AEQY}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AHBCC}    22R1=&{RU_account8}    22R2=&{RU_account8}    22R3=&{RU_account8}
&{AZQG}    22R1=&{RU_account10}    22R2=&{RU_account11}    22R3=&{RU_account11}
&{AZQV}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account11}
&{AWHHF}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account10}
&{AWHHD}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account10}
&{AWHQM}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account10}
&{AWHQF}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account10}
&{AWHQE}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account10}
&{AAHF}    22R1=&{RU_account1}    22R2=&{RU_account1}    22R3=&{RU_account1}
&{AEQD}    22R1=&{RU_account1}    22R2=&{RU_account1}    22R3=&{RU_account1}
&{AEQV}    22R1=&{RU_account7}    22R2=&{RU_account7}    22R3=&{RU_account7}
&{AHPE}    22R2=&{RU_account10}    22R3=&{RU_account10}
&{AHQK}    22R1=&{RU_account10}    22R2=&{RU_account10}    22R3=&{RU_account10}

&{RU_account1}    username=root    password=umniedziala
&{RU_account2}    username=root    password=XwcvfotfCCOIAqtk7uQjN38d8sG5Yp2Pb2/p6Eqw8+Y=
&{RU_account3}    username=rfsw    password=PD6N1DB0lWmwomtNL2qd3ISypbiocdGRy7U+Lipiksk=
&{RU_account4}    username=root    password=asmr
&{RU_account5}    username=rfsw    password=ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=
&{RU_account6}    username=toor4nsn    password=oZPS0POrRieRtu
&{RU_account7}    username=rfsw    password=gSDBExyEbO33komYWL6iPrtSaYc5XimHAGrsJ/K8+AY=
&{RU_account8}    username=root    password=a2%FgSz3$fHmdusap354xujw7a
&{RU_account9}    username=rfsw    password=5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=
&{RU_account10}    username=root    password=root
&{RU_account11}    username=root    password=w@=EIj7P6R0bVy85OjCVa^ho&8
&{RU_account12}    username=rfsw    password=HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=
&{RU_account13}    username=root    password=ZCS81C3RIAZegZtvIn43EaAdA4oMSNFkSBrj4iMwTuI=
&{RU_account14}    username=rfsw    password=bdS%ztWG3v7%SjreCVA79wTPb

${service_username}     serviceuser
${service_password_22R3}     bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
${service_password_22R4}     bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
${root_username}    root
${root_password}    a2%FgSz3$fHmdusap354xujw7a
@{release_need_service_account}    22R3    22R4
@{ru_login_with_service_account}    AEQB    AEQC    AEQV    AEQE    AEQP    AEQP_I    AEQK    AEQK_I    AEQY    AEQQ    AEQI    AEQZ
...    AENB    AEUA    AEQU    AEQM

*** Keywords ***
Check RU Tx power
    [Documentation]    Check RU Tx power after cells on-air, otherwise check will failed, RU in list 'RU_Power_check_list' are implemented.
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${connect}=GNB_OAM
    ${du_count}    taf.config.testline.info.testline_info.TestlineInfo.get_number_of_du    tl=${tl}
    Return From Keyword If    '${du_count}'=='0'    ${None}
    ${status}    Verify gnb connection    connection=${connect}
    ${dict_RUs_detail_info}    ${result}    run keyword if    '${status}'=='True'    COAM get ru index by ru SN
    ${len}=    run keyword if    '${status}'=='True'    Get length    ${dict_RUs_detail_info}
    ${status1}    Run Keyword And Return Status    should be true    ${len}>0 and '${result}'=='True'
    run keyword if    '${status1}'=='True'   Start Check RU Tx power    dict_RUs_detail_info=${dict_RUs_detail_info}
    [Teardown]   Run Keyword And Ignore Error   Logout DU via admin    alias=${connect}

Start Check RU Tx power
    [Documentation]    Check RU Tx power after cells on-air, otherwise check will failed, RU in list 'RU_Power_check_list' are implemented.
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${dict_RUs_detail_info}    ${gnb_index}=0
    ...    ${du_index}=0    ${asik_alias}=ASIK Master    ${connect}=GNB_OAM
    ${version_active_sw}=    Get Active SW Version by Coam for power check    connection=${connect}
    ${release}=    Get program version based on gNB active version by Coam for power check    version_active_sw=${version_active_sw}
    Log To Console    Current SW release is ${release}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    csn.Send Command    command=cat /ffs/run/config/FRIps.txt |cut -d ';' -f 3-5    connection=${asik_alias}
    ${RU_IP}    csn.Read Output    connection=${asik_alias}
    Run Keyword And Ignore Error    Should not be empty    ${RU_IP}    msg=not found RU, please check RU connetion.
    FOR    ${item}    IN    @{RU_IP.split()}
        ${status}    ${Rmod_index}    Run Keyword And Ignore Error    Get From Dictionary    ${dict_RUs_detail_info}    ${item.split(';')[1]}
        ${result}=    Run Keyword And Return Status    Should Contain    ${RU_Power_check_list}    ${item.split(';')[2]}
        ...    msg=${item.split(';')[2]} Tx power check not implemented.
        ${ru}    set variable if    '${result}'=='${True}'    ${${item.split(';')[2]}}
        ${ru_rel}    run keyword if    '${result}'=='${True}'    Get Dictionary Keys    ${ru}
        ${ru_release_cehck}    Run Keyword And Return Status    Should Contain    ${ru_rel}    ${release}
        run keyword and continue on failure    run keyword if
        ...    '${result}'=='${True}' and '${release}'!='Undefined' and '${status}'=='PASS' and '${ru_release_cehck}'=='${True}'
        ...    wait until keyword succeeds    2x    1min    ${item.split(';')[2]} Tx Power check from RU
        ...    RU_type=${item.split(';')[2]}    RU_IP=${item.split(';')[0]}
        ...    RU_USERNAME=${ru['${release}']['username']}
        ...    RU_PASSWORD=${ru['${release}']['password']}    index=${Rmod_index}
    END

AWEUA Tx Power check from RU
    [Documentation]    Check AWEUA Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen5 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AWEUB Tx Power check from RU
    [Documentation]    Check AWEUB Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen5 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AWEWB Tx Power check from RU
    [Documentation]    Check AWEWB Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen5 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AWEUC Tx Power check from RU
    [Documentation]    Check AWEUC Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen5 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AEWB Tx Power check from RU
    [Documentation]    Check AEWB Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen4 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AEWD Tx Power check from RU
    [Documentation]    Check AEWD Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen4 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AEWE Tx Power check from RU
    [Documentation]    Check AEWE Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen4 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AEUD Tx Power check from RU
    [Documentation]    Check AEUD Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen4 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AEUB Tx Power check from RU
    [Documentation]    Check AEUB Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    Gen4 mmw RU Tx power check form RU    RU_type=${RU_type}    RU_IP=${RU_IP}    RU_USERNAME=${RU_USERNAME}
    ...    RU_PASSWORD=${RU_PASSWORD}    index=${index}    gnb_index=${gnb_index}    du_index=${du_index}    asik_alias=${asik_alias}

AEQN Tx Power check from RU
    [Documentation]    Check AZQJ Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEQV Tx Power check from RU
    [Documentation]    Check AZQJ Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEHC Tx Power check from RU
    [Documentation]    Check AEHC Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh 192.168.100.10 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AZQJ Tx Power check from RU
    [Documentation]    Check AZQJ Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AZQO Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.101.2 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEQE Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.101.2 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEQY Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.101.2 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEQQ Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.101.2 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEQZ Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.101.2 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AEQC Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.101.2 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AWHHF Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AWHHD Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AWHQM Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AWHQF Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AWHQE Tx Power check from RU
    [Documentation]    Check AZQO Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AZQG Tx Power check from RU
    [Documentation]    Check AZQG Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AZQV Tx Power check from RU
    [Documentation]    Check AZQG Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AZQH Tx Power check from RU
    [Documentation]    Check AZQH Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

AZQL Tx Power check from RU
    [Documentation]    Check AZQL Tx power
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} ssh root@192.168.100.3 dapd -sq    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    Should Match Regexp     ${RU_object}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

Gen5 mmw RU Tx power check form RU
    [Documentation]   common mmw gen5 RU Tx power keyword
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    log    ${RU_IP}
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=sudo haxer la:ra show ECpriTxArrayCarrierConf | grep object_name:|awk '{print $2}'|cut -d '"' -f 2    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    @{RU_object}    Split To Lines    ${RU_object}
    csn.Send Command    command=rm -rf 1.txt    connection=RU
    csn.Send Command    command=echo "/ action create TxGainControl /txgc1 /rf/tx1" >> 1.txt    connection=RU
    csn.Send Command    command=echo "/ action create TxGainControl /txgc2 /rf/tx2" >> 1.txt    connection=RU
    csn.Send Command    command=echo "/txgc1 action measure_power dBFS" >> 1.txt    connection=RU
    csn.Send Command    command=echo "/txgc2 action measure_power dBFS" >> 1.txt    connection=RU
    csn.Send Command    command=echo "/ action create AntennaPath /am /rf/ant1" >> 1.txt    connection=RU
    FOR    ${item}    IN    @{RU_object}
        ${output}    csn.execute    command=echo -e '/am action measure_power_ecpri_array_carrier "${item}"' >> 1.txt    connection=RU
    END
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} frmonShellClient localhost 2000 1.txt    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    OperatingSystem.Run    echo '${RU_object}' >2.txt
    ${power_value}    OperatingSystem.Run    cat 2.txt |awk '{print $NF}'|grep '-'
    Should Match Regexp     ${power_value}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

Gen4 mmw RU Tx power check form RU
    [Documentation]    mmw gen4 RU Tx power common keyword
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]    ${RU_type}    ${RU_IP}    ${RU_USERNAME}    ${RU_PASSWORD}
    ...    ${index}=1    ${gnb_index}=0    ${du_index}=0    ${asik_alias}=ASIK Master
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    log    ${RU_IP}
    csn.connect_to
    ...    hostname=${DU_OAM_IP}
    ...    username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...    alias=${asik_alias}
    ${container_id}    Get FHNET Container ID for power check
    Connect to RU With Allocated IP for power check     container_id=${container_id}   ru_username=${RU_USERNAME}
    ...    ru_password=${RU_PASSWORD}    ru_index=${index}
    log to console    connect ${RU_type} RU successful
    csn.Send Command    command=rm -rf /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action init /rf/tx1" >> 1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action init /rf/tx2" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action measure_power dBFS" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=echo "/Core/TxGainControl action terminate" >> /var/tmp/1.txt    connection=RU
    csn.Send Command    command=which sudo    connection=RU
    ${sudo}  csn.Read Output    connection=RU
    csn.Send Command    command=${sudo} frmonShellClient localhost 2000 /var/tmp/1.txt    connection=RU
    ${RU_object}  csn.Read Output    connection=RU
    OperatingSystem.Run    rm 2.txt
    OperatingSystem.Run    echo '${RU_object}' >2.txt
    ${power_value}    OperatingSystem.Run    cat 2.txt |awk '{print (NF>2?$(NF-1):"None")}'| grep '-'
    Should Match Regexp     ${power_value}     -([1-9]\d*\.\d*|0\.\d*[1-9]\d*)    msg=${RU_type} Tx power value verify failed, please check
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${alias}

COAM get ru index by ru SN
    [Documentation]  Author: shenrao
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${result}=    Run Keyword And Return Status    Verify all cells should be onair for power check
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Run Keyword And Ignore Error    Should be true    ${count_RUs}>=1    msg=No RU found
    ${rmod_status}    ${cell_config_rmod}    Run Keyword And Ignore Error    Check cells config    connection=${connection}
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RMOD}    IN    @{list_RUs}
        ${stau}    Run Keyword And Return Status    Should Contain
        ...    ${cell_config_rmod}    ${RMOD['id']['configuration'].split('RMOD-')[1]}
        run keyword if
        ...    ('${RMOD['status']['operationalState']}'=='Enabled' or '${RMOD['status']['operationalState']}'=='enabled') and '${stau}'=='${True}'
        ...    Run Keyword And Ignore Error    Set to dictionary    ${dict_RUs_detail_info}    ${RMOD['serialNumber']}
        ...    ${RMOD['id']['configuration'].split('RMOD-')[1]}
    END
    [Return]  ${dict_RUs_detail_info}    ${result}

Check cells config
    [Arguments]    ${connection}=GNB_OAM
    ${cells_info}    coam.get_cells_info    connection=${connection}
    ${cell_config_rmod}    create list
    FOR    ${RMOD}    IN    @{cells_info}
        Append To List    ${cell_config_rmod}    ${RMOD['carrierList'][0]['antennaLineId']['configuration'].split('RMOD-')[-1].split('/')[0]}
    END
    [Return]  ${cell_config_rmod}

Login DU via Admin
    [Documentation]    login DU via Admin
    ...                Author: Shenrao
    ...                Contact: shengrong.rao@nokia-sbell.com
    ...                :param gnb_index: the gnb index which config in tl.gnbs[].
    ...                :param du_index: the du index mean the left or right board in AMIA
    [Arguments]  ${gnb_index}=0    ${du_index}=0
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}    ${alias}=default
    Run Keyword And Ignore Error    Logout DU via admin   alias=${alias}
    Sleep  2
    ${DU_OAM_IP}    Set Variable If    '${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}'!='None'
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...    ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ${connection}   coam.Connect To  bts_host=${DU_OAM_IP}  bts_port=443
    ...    username=${username}  password=${password}    name=${alias}
    [Return]  ${connection}

Logout DU via admin
    [Documentation]    logout DU via admin
    ...                Author: Shenrao
    [Arguments]  ${alias}=default
    coam.Teardown  connection=${alias}

Verify gnb connection
    [Arguments]  ${connection}=GNB_OAM
    ${status}=    Run Keyword And Return Status    Login DU via Admin    alias=${connection}
    [Return]  ${status}


Verify all cells should be onair for power check
    [Documentation]    Author: shengrong.rao@nokia-sbell.com
    ...                Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr  ${connection}=GNB_OAM
    Log to console    Verify all cells are on air
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${unlocked}    Set Variable If    ${result}==${False} and '${cell_type}'=='lte'    unlocked    ${unlocked}
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}     ${unlocked}
        Run keyword and continue on failure    Should be equal as strings    ${cell['status']['operationalState']}    ${enabled}
        run keyword if  ${result}    Run keyword and continue on failure
        ...    Should Be Equal As Strings    ${cell['status']['availabilityStatus']}   Online
    END


Get Active SW Version by Coam for power check
    [Documentation]  Author: shengrong.rao@nokia-sbell.com
    ...              Description: Get the active sw version, the result is like SBTS21B_ENB_9999_210528_000013 and so on
    [Arguments]  ${connection}=GNB_OAM
    ${sw_version} =     coam.get_sw_version    connection=${connection}
    ${sbts}    run keyword and return status     Should contain    ${sw_version}    SBTS
    return from keyword if    ${sbts}      ${sw_version}
    @{result}    string.split string    ${sw_version}    separator=_
    ${length}    Get Length    ${result}
    ${i} =    Set Variable    ${1}
    ${SW_vesion_tmp}    convert to integer     ${result}[2]
    FOR    ${i}    IN RANGE    1    ${length} - ${2}
         ${j} =    Evaluate    ${i} + ${2}
         ${build}    set variable    ${result}[${j}]
         ${build}    Run Keyword If    ${j} < 5    convert to integer    ${result}[${j}]    ELSE    set variable    ${result}[${j}]
         ${SW_vesion_tmp}    set variable    ${SW_vesion_tmp}.${build}
    END
    [Return]   ${SW_vesion_tmp}


Get program version based on gNB active version by Coam for power check
    [Documentation]  Author: shengrong.rao@nokia-sbell.com
    ...              Description: Get the release version, the rsult is like 21A, 21B, 22R1 and so on
    [Arguments]  ${version_active_sw}=${None}
    ${sbts_22R1}    run keyword and return status     Should contain    ${version_active_sw}    22R1
    return from keyword if    ${sbts_22R1}      22R1
    ${sbts_22R2}    run keyword and return status     Should contain    ${version_active_sw}    22R2
    return from keyword if    ${sbts_22R2}      22R2
    ${sbts_22R3}    run keyword and return status     Should contain    ${version_active_sw}    22R3
    return from keyword if    ${sbts_22R3}      22R3
    ${sbts_22R4}    run keyword and return status     Should contain    ${version_active_sw}    22R4
    return from keyword if    ${sbts_22R4}      22R4
    ${sbts_21b}    run keyword and return status     Should contain    ${version_active_sw}    21B
    return from keyword if    ${sbts_21b}      21B
    @{rest}    String.split string    string=${version_active_sw}    separator=.
    ${stream}    set variable    ${rest}[0].${rest}[1]
    ${program_version}    set variable if    ${stream} in [9.1800]    20A
    ...    ${stream} in [10.1800]    20B
    ...    ${stream} in [11.800]    21A
    ...    Undefined
    [Return]    ${program_version}


Get FHNET Container ID for power check
    [Arguments]    ${asik_alias}=ASIK Master
    ${hostname}=    csn.execute    command=hostname    connection=${asik_alias}
    ${container_id}=    Set Variable If    'fct-0a' in '''${hostname}''' or 'asc-0a' in '''${hostname}'''    0x1018
    ...    'fct-4a' in '''${hostname}'''    0x2018    None
    [Return]   ${container_id}

Connect To RU Via FHNET Container for power check
    [Documentation]   Auther: shengrong.rao@nokia-sbell.com
    ...               Description: Connect To RU Via FHNET Container for power check
    ...               ContainerID is 0x1018 for left side of AMIA, 0x2018 for right side.
    ...               eth0(FHNET) ip is 192.168.255.254
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...            ${ru_index}=${1}
    ...            ${coam_connection}=GNB_OAM
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    ${version_active_sw}    Get Active SW Version by Coam for power check    connection=${coam_connection}
    ${release}    Get program version based on gNB active version by Coam for power check    version_active_sw=${version_active_sw}
    ${ru_info}    COAM get ru detial by ru index for power check    ru_index=${ru_index}    connection=${coam_connection}
    ${radio_type}    set variable    ${ru_info}[productName]
    Run keyword if    '${release}' in @{release_need_service_account} and '${radio_type}' in @{ru_login_with_service_account}
    ...    Connect To RU By ServiceAccount for power check
    ...            ru_ip_addr=${ru_ip_addr}
    ...            service_username=${service_username}
    ...            service_password=${service_password_${release}}
    ...            root_username=${root_username}
    ...            root_password=${root_password}
    ...            container_alias=${container_alias}
    ...            ru_alias=${ru_alias}
    ...    ELSE    Run Keyword    csn.connect to
    ...                      hostname=${ru_ip_addr}
    ...                      username=${ru_username}
    ...                      password=${ru_password}
    ...                      alias=${ru_alias}
    ...                      proxy=${container_alias}


COAM get ru detial by ru index for power check
    [Documentation]  Author: shengrong.rao@nokia-sbell.com
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
    ${ru_index}    Convert to string    ${ru_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${status}    Run Keyword And Return Status    Should Contain   '${RU}'   RMOD-${ru_index}/
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_RUs_detail_info}    ${ru_index}    ${RU}
    END
    [Return]  ${dict_RUs_detail_info['${ru_index}']}

Connect to RU With Allocated IP for power check
    [Documentation]   Auther: shengrong.rao@nokia-sbell.com
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]  ${ru_index}=${1}   ${ru_alias}=RU   ${asik_alias}=ASIK Master   ${connection}=GNB_OAM
    ...          ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
	${container_id}    Get FHNET Container ID for power check    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial by ru index for power check     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}    Coam Get RU IP via RMOD object for power check  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU Via FHNET Container for power check    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...                                         ru_index=${ru_index}
    ...                                         coam_connection=${connection}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${asik_alias}

Get RU IP Address Via File FRIps for power check
    [Documentation]   Auther: shengrong.rao@nokia-sbell.com
    ...               Description: Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]   ${ru_serial_number}    ${connection}=ASIK Master
    ${get_ru_ip_command}   Set Variable   cat /rom/config/FRIps.txt
    ${output}   csn.execute   command=${get_ru_ip_command}  connection=${connection}
    ${contained_ip_lines}   Get Lines Containing String   ${output}  ${ru_serial_number}   case-insensitive=${True}
    ${ru_ip_addr}  Set Variable    ${contained_ip_lines.split(';')}[2]
    [Return]   ${ru_ip_addr}

Connect To RU By ServiceAccount for power check
    [Documentation]   Auther: shengrong.rao@nokia-sbell.com
    ...               Description: log in ru with service accout, then add sudo for service account
    [Arguments]  ${ru_ip_addr}    ${service_username}    ${service_password}    ${root_username}    ${root_password}
    ...    ${container_alias}=Container    ${service_alias}=SERVICE    ${ru_alias}=RU
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${service_username}
    ...               password=${service_password}
    ...               alias=${service_alias}
    ...               proxy=${container_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${service_alias}
    ${channel_service}    Call Method    ${connection_service}    invoke_shell
    Call Method    ${channel_service}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel_service}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${port}    get_idle_port    connection=${connection_service}
    ${time}  get time  epoch
    ${start_sshd}    Set Variable    sudo /usr/sbin/sshd -p ${port} -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug_${time}.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel_service}    send    ${start_sshd}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel_service}    recv    ${65535}
    ${get_sshd_port}    Set Variable    ps -ef|grep sshd|grep -v grep|grep 'PermitRootLogin yes'|awk '{print $7}'
    Call Method    ${channel_service}    send    ${get_sshd_port}\n
    Sleep    3 sec
    ${output}    Call Method    ${channel_service}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${output}=    Split String    ${output}    \r\n
    ${port}    set variable    ${output[1]}
    Call Method    ${channel_service}    close
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${root_username}
    ...               password=${root_password}
    ...               port=${port}
    ...               alias=${ru_alias}
    ...               proxy=${service_alias}

Coam Get RU IP via RMOD object for power check
    [Arguments]    ${ru_serial_number}    ${connection}=GNB_OAM
    ${results}    coam.get_managed_objects    class_name=RMOD_L    connection=${connection}
    FOR    ${RU_info}    IN    @{results}
        IF    '${RU_info['parameters']['serialNumber']}' == '${ru_serial_number}'    RETURN    ${RU_info['parameters']['ipAddress']}
    END
