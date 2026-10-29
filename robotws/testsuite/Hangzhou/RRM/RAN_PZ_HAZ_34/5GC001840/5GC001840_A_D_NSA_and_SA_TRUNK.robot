*** Settings ***
Documentation     author: Shi Taotao
...               contact: taotao.shi@nokia-sbell.com
...               Cases in 5GC001840 that requires one mixed cell and two UE:
...               Huawei UE1(index=0) for SA access, and Huawei UE2(index=2) for NSA access.
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup    AND    Setup My Suite
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown    AND   Teardown My Suite
Force Tags                SG_01
...    PY36
Resource          ../5GC000496_C/Resources/L3Call.robot
Resource          ../5GC000900/Resources/5GC000900_PowerUE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library           taf.ue    WITH NAME    ute_ue
Library           taf.ue.rpc.mtk    WITH NAME    rpc_mtk
Library           taf.ul.messaging.mtk    WITH NAME    mtk_msg
#Variables         ${CFGFILE_ON_GIT}/5GC001840/Delta_SCF.py
#Variables         ${CFGFILE_ON_GIT}/5GC001840/Delta_SCF_ENB.py
#Variables         ${CFGFILE_ON_GIT}/TLDelta.py

*** Variables ***
#${CFGFILE_ON_GIT}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}
#${GoldenSCF_PATH}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/5G_PZ_HZ_1_SG/${GoldenSCF}

#${TL_DeltaPath}        ${CFGFILE_ON_GIT}/TLDelta.py
#${DeltaPath}           ${CFGFILE_ON_GIT}/5GC001840/Delta_SCF.py
#${DeltaPath_ENB}       ${CFGFILE_ON_GIT}/5GC001840/Delta_SCF_ENB.py

${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}

${initial_S111_SCF}       ${LOG_PATH}/TestLineSCF3Cell_Both.xml
#${initial_ENB_SCF}        ${CFGFILE_PATH}/TestLineSCFeNB.xml

#${UE_TYPE}                  huawei_sigspark
${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}

${USER_LOG_DIR}    /opt/ute/Logs
${UPDATE_FILE_PATH}    /opt/ute/tmp
#${CFGFILE_PATH}    /home/ute/TAF/cfgfile/
${EGATE_CFG_NAME}    ${tl.core.cfg_filename}
${WTS_FILE_PATH}    ${tl.core.dir_path}
###eNB###
${ENB_WEBUI_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}    https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
###eNB PB###
${PB_4GRU_IP}     ${tl.enbs[0].rms.pdu_port.pdu.addr}
${PB_4GRU_PORT}    ${tl.enbs[0].rms.pdu_port.port_no}
${PB_WMPeNB_IP}    ${tl.enbs[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_WMPeNB_PORT}    ${tl.enbs[0].airscale.common_units[0].pdu_port.port_no}
#${ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${UTE_IP}         ${tl.core.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.core.default_ssh_connection_details.password}
###gNB1 PB###
${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_5GRU_IP}     ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${PB_5GRU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${PB_5GRU1_IP}     ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${PB_5GRU1_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
${PB_5GRU2_IP}     ${tl.gnbs[0].dus[0].rus[2].pdu_port.pdu.addr}
${PB_5GRU2_PORT}    ${tl.gnbs[0].dus[0].rus[2].pdu_port.port_no}

#${QC_IP}          ${tl.ues[1].ssh_connection_details.addr}
#${QC_USERNAME}    ${tl.ues[1].ssh_connection_details.username}
#${QC_PASSWORD}    ${tl.ues[1].ssh_connection_details.password}
#${device_model}    ${tl.ues[1].serial_number}
${REPEAT_TIME}    ${50}
${THRESHOLD}      ${49}
${EXPECTED_PRECENT}    1
${IMSI}           ${tl.ues[0].imsi}
${IMSI2}          ${tl.ues[1].imsi}
#${PB_MTK_IP}      10.57.251.174
#${PB_MTK_PORT}    8
###AMF###
${5GC_IP}         ${tl.core.default_ssh_connection_details.addr}
${5GC_USERNAME}    ${tl.core.default_ssh_connection_details.username}
${5GC_PASSWORD}    ${tl.core.default_ssh_connection_details.password}
#${MTK_CtrlPC_IP}    ${tl.ues[0].ssh_connection_details.addr}
#${MTK_CtrlPC_USERNAME}    ${tl.ues[0].ssh_connection_details.username}
#${MTK_CtrlPC_PASSWORD}    ${tl.ues[0].ssh_connection_details.password}
#${MTK_PYRO_IP}    ${tl.ues[0].ssh_connection_details.addr}
#${MTK_PYRO_PORT}    ${tl.ues[0].server_port}
${ASIK_LMP_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${WEBUI_IP}       ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
##################define these variable for convenient############################
${ALIAS_ASIK}     asik
${ALIAS_ASIK_SLAVE}    asik_slave
${ALIAS_UTE}      ute
${ALIAS_ENBCTLPC}    ENB_PC
${ALIAS_SHP}      SHP
${ALIAS_E500}     E500
${ALIAS_PRISMA}    Prisma
${ALIAS_REAL_EPC_SERVER}    Real_EPC
${ALIAS_LONER}    LONER
${ALIAS_ASP_1A}    ASP_1A
${AlIAS_QC}       Qualcomm
${QC_UE_alias}    QC_UE
${MTK_UE_alias}    MTK_UE
${ALIAS_5GC}      5gc
########################END of alias Define#######################################

*** Test Cases ***
[1][1.0] 5GC001840_A_11_DataTraffic_PLMN2_selected_by_NSA_and_SA_UE_in_Cell2
    [Documentation]    Main test Steps:
    ...    1) Wait until Cell on air (NG + X2 all available)
    ...    2) NSA L3 Call with Huawei UE2(index=1)
    ...    3) SA L3 call with Huawei UE1(index=0)
    ...    4) Verifiy throughput
    [Tags]    CRT_TRUNK    CRT_20A    CRT_20B    CRT_21A    CIT_21B    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
    [Setup]    Run Keywords    robot_common_operations.Common Case Setup    allowed_faults_ids=7107,7305,7523    AND    TestCase.CommonStart
    Process.Verify gNB Readiness and Fail Case if Not After Reset
    X2 Should Be Ready
    Get rid of loner ssh fingerprint change issue
    MultiUE.L3Call  UECFG=${TLCommonConfig['MultiUECFG']}
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Frequency band Indicator NR	    value=77
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout
#    PowerUE.Reserve UE   ue_index=${0}
#    PowerUE.Reserve UE   ue_index=${1}
#    SigSpark_Dual_UE attach and ULDL traffic
#    Run Keyword And Ignore error    PowerUE.Detach UE  ue_index=${0}    power_reset=True
#    Run Keyword And Ignore error    PowerUE.Detach UE   ue_index=${1}    power_reset=True
    [Teardown]    TestCase.CommonStop

#[1][1.0] 5GC001840_A_12_DataTraffic_NSA_UE(PLMN1)_and_SA_UE(PLMN2)_in_Cell2
#    [Documentation]    Main test Steps:
#    ...    1) Wait until Cell on air (NG + X2 all available)
#    ...    2) NSA L3 Call with Qualcomm
#    ...    3) SA L3 call with MTK
#    ...    4) Verifiy if peakrate is higher than expected.
#    [Tags]    Classicalbts    Blow6GHz    3GPPDEC    Case_12
#    [Setup]    Setup My Case
#    Process.Verify gNB Readiness and Fail Case if Not After Reset
#    X2 Should Be Ready
#    Get rid of loner ssh fingerprint change issue
#    Reserve ue for tests    UE_alias=${QC_UE_alias}    UE_CAPABILITIES=REAL_ANDROID_UE
#    MTK.Reserve ue for tests_With_Retry    UE_alias=${MTK_UE_alias}    UE_CAPABILITIES=REAL_MEDIATEK_UE
#    Dual_UE Call with_traffic
#    [Teardown]    Teardown My Case    UE_alias=${MTK_UE_alias}
#
#[1][1.0]5GC001840_A_15_DataTraffic_PLMN2_selected_by_NSA_and_SA_UE_in_Cell3
#    [Documentation]    Main test Steps:
#    ...    1) Wait until Cell on air (NG + X2 all available)
#    ...    2) NSA L3 Call with Qualcomm
#    ...    3) SA L3 call with MTK
#    ...    4) Verifiy if peakrate is higher than expected.
#    [Tags]    Classicalbts    Blow6GHz    3GPPDEC    Case_15
#    [Setup]    Setup My Case
#    Process.Verify gNB Readiness and Fail Case if Not After Reset
#    X2 Should Be Ready
#    Get rid of loner ssh fingerprint change issue
#    Reserve ue for tests    UE_alias=${QC_UE_alias}    UE_CAPABILITIES=REAL_ANDROID_UE
#    MTK.Reserve ue for tests_With_Retry    UE_alias=${MTK_UE_alias}    UE_CAPABILITIES=REAL_MEDIATEK_UE
#    Dual_UE Call with_traffic
#    [Teardown]    Teardown My Case    UE_alias=${MTK_UE_alias}
#
#[1][1.0]5GC001840_D_04_PDCP_SDU_user_DLdata _per_PLMN_for_SA_user_by_WebUI
#    [Documentation]    Main test Steps:
#    ...    1) Wait until Cell on air (NG + X2 all available)
#    ...    2) NSA L3 Call with Qualcomm
#    ...    3) SA L3 call with MTK
#    ...    4) Verifiy throughput
#    [Tags]    Classicalbts    Blow6GHz    3GPPDEC    Case_04
#    [Setup]    Setup My Case
#    Process.Verify gNB Readiness and Fail Case if Not After Reset
#    X2 Should Be Ready
#    Get rid of loner ssh fingerprint change issue
#    Reserve ue for tests    UE_alias=${QC_UE_alias}    UE_CAPABILITIES=REAL_ANDROID_UE
#    MTK.Reserve ue for tests_With_Retry    UE_alias=${MTK_UE_alias}    UE_CAPABILITIES=REAL_MEDIATEK_UE
#    Dual_UE Call with_traffic
#    Check Counter    M55326C00501    100
#    [Teardown]    Teardown My Case    UE_alias=${MTK_UE_alias}
#
#[1][1.0]5GC001840_D_05_PDCP_SDU_user_ULdata _per_PLMN_for_SA_user_by_WebUI
#    [Documentation]    Main test Steps:
#    ...    1) Wait until Cell on air (NG + X2 all available)
#    ...    2) NSA L3 Call with Qualcomm
#    ...    3) SA L3 call with MTK
#    ...    4) Verifiy if peakrate is higher than expected.
#    [Tags]    Classicalbts    Blow6GHz    3GPPDEC    Case_05
#    [Setup]    Setup My Case
#    Process.Verify gNB Readiness and Fail Case if Not After Reset
#    X2 Should Be Ready
#    Get rid of loner ssh fingerprint change issue
##    Reserve ue for tests    UE_alias=${QC_UE_alias}    UE_CAPABILITIES=REAL_ANDROID_UE
##    MTK.Reserve ue for tests_With_Retry    UE_alias=${MTK_UE_alias}    UE_CAPABILITIES=REAL_MEDIATEK_UE
##    Dual_UE Call with_traffic
#    [Teardown]    Teardown My Case    UE_alias=${MTK_UE_alias}

*** Keywords ***
Setup My Suite
    TestSuite.Start
    Import Variables   ${CFGFILE_PATH}5GC001840/Delta_SCF.py
    Import Variables   ${CFGFILE_PATH}5GC001840/Delta_SCF_ENB.py
    set suite variable   ${initial_ENB_SCF}        ${CFGFILE_PATH}/TestLineSCFeNB.xml
    set suite variable    ${GoldenSCF_PATH}    ${GoldenSCF_ON_GIT}/${GoldenSCF}
    set suite variable    ${DeltaPath}       ${CFGFILE_PATH}5GC001840/Delta_SCF.py
#    Refine PA Port
    Run Keyword And Ignore error    PA.AdjustAttenuationValueByGroups
    Setup Suite
    gNB.FormatBTSID
    GNB.SwconfigReplace    file_path=${CFGFILE_PATH}/5GC001840
    gNB.Generate TL SCF    GoldenSCF_PATH=${GoldenSCF_PATH}    TLDelta_PATH=${CFGFILE_PATH}
    ...            TestLineSCF_cell_num=${TestLineSCF_cell_num}   cell_type=Both
    ...            MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

    gNB.ReplaceDeltaID    DeltaPath=${DeltaPath}
    gNB.ModifySCF    InputFile=${LOG_PATH}/TestLineSCF${TestLineSCF_cell_num}Cell_Both.xml
    ...     OutputFile=${LOG_PATH}/1840_A11_SCF.xml
    ...     ParameterToDelete=${PARAMS_TO_DELETE_1840_A_011}    ParamterToModify=${PARAMS_TO_MODIFY_1840_A_011}
    ...     MOsToAdd=${ADD_MOs_1840_A_011}    ListToAdd=${ADD_TO_List_1840_A_011}
    GNB.Commissioning    scf_file=1840_A11_SCF.xml    file_path=${LOG_PATH}
    COAM_WebEM.Login
    COAM_WebEM.SetParameterValue    distName=MRBTS-10031/NRBTS-10031/NRCELL-201
    ...    abbr=Frequency band Indicator NR	    value=78
    COAM_WebEM.ValidateAndActiveParameters
    COAM_WebEM.Logout

    gNB.ModifySCF    InputFile=${initial_ENB_SCF}    OutputFile=${LOG_PATH}/1840_ENB_A11_SCF.xml
    ...     ParameterToDelete=${PARAMS_TO_DELETE_ENB_1840_A_011}    ParamterToModify=${PARAMS_TO_MODIFY_ENB_1840_A_011}
    ...    MOsToAdd=${ADD_MOs_ENB_1840_A_011}    ListToAdd=${ADD_TO_List_ENB_1840_A_011}
    ENB.Commissioning    scf_file=1840_ENB_A11_SCF.xml    file_path=${LOG_PATH}
    gNB.SetLoggingSeverity    LoggingSeverity=debug


Teardown My Suite
    [Arguments]    ${recover_scf}=no
    Run Keyword And Ignore error    PA.AdjustAttenuationValueByGroups
    Teardown Suite
    run keyword if    '${recover_scf}'=='yes'    GNB.Commissioning    scf_file=TestLineSCF3Cell_Both.xml    file_path=${CFGFILE_PATH}

Setup My Case
    [Documentation]
#    Adjust RU1 Attenuation to ${0}
#    Adjust RU2 Attenuation to ${60}
#    Run Keyword And Ignore error    Adjust RU3 Attenuation to ${127}
#    #Adjust GNB2_RU1 Attenuation to ${60}
    Run Keyword And Ignore error    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['1']}
    Run Keyword And Ignore error     PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['2']}    value=${60}
    Run Keyword And Ignore error    PA.AdjustAttenuationValueByGroup    PAGroup=${TLCommonConfig['PAGroups']['3']}
    Setup Case

Teardown My Case
    [Arguments]
    Teardown Case

Setup My Case_04
    [Arguments]    ${withqc}=no
    [Documentation]    Setup Case only inlude preconditions for MTK, this have Qualcomm preconditions covered.
    Set Test Variable    ${recover_enb}    ${FALSE}
    ENB.Commissioning    scf_file=scf_enb_46002.xml    file_path=${CFGFILE_PATH}/5GC001840
    Set Test Variable    ${recover_enb}    ${TRUE}
    Setup Case
    run keyword if    '${withqc}'=='yes'    run keywords    Qualcomm.RebootUeViaADB
    ...    AND    sleep    2min

Teardown My Case_04
    [Arguments]    ${UE_alias}=UE_1    ${recover_cell}=no
    run keyword if    '${recover_cell}'=='yes'    run keywords    COAM_WebEM.Login
    ...    AND    Unlock Cell
    ...    AND    COAM_WebEM.Logout
    run keyword if    ${recover_enb}    ENB.Commissioning    scf_file=scf_enb_26203.xml    file_path=${CFGFILE_PATH}/5GC001840
    Teardown Case    UE_alias=${UE_alias}

Unlock Cell
    [Arguments]    ${timeout}=60
    ${cell_info}=    selenium_coam.get_cell_info
    log    ${cell_info}and ${cell_info['Status']['Administrative state']}
    run keyword if    '${cell_info['Status']['Administrative state']}'=="Locked"    selenium_coam.unlock_cell    cell_idx=1    timeout=${timeout}
    Sleep    40s

SigSpark_Dual_UE attach and ULDL traffic
    [Arguments]    ${ue_type}=${UE_TYPE}
    Clear UE info from AMF    ue_imsi=${IMSI}
    Clear UE info from AMF    ue_imsi=${IMSI2}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${0}    power_reset=True
    sleep    10s
    power_ue.UE Attach    ue_type=${ue_type}     ue_index=${0}    power_reset=True
    sleep    5s
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${0}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=dl    throughput=10MKbits/sec    duration=600
   ...    apn_address=${SA_APN}    ue_mode=SA
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=ul     throughput=5MKbits/sec    duration=600
   ...    apn_address=${SA_APN}    ue_mode=SA
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${1}    power_reset=True
    sleep    10s
    power_ue.UE Attach    ue_type=${ue_type}     ue_index=${1}    power_reset=True
    sleep    5s
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=dl    throughput=10MKbits/sec    duration=600
   ...    apn_address=${NSA_APN}    ue_mode=NSA
    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${1}    direction=ul     throughput=5MKbits/sec    duration=600
   ...    apn_address=${NSA_APN}    ue_mode=NSA
    sleep    30
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${0}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${0}    direction=ul    throughput=2
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${1}    direction=dl    throughput=5
    power_ue.Check throughput    ue_type=${ue_type}    ue_index=${1}    direction=ul    throughput=2



Dual_UE Call with_traffic
    [Arguments]
    Clear UE info from AMF    ue_imsi=${IMSI}
    Clear UE info from AMF    ue_imsi=${IMSI2}
    UE Attach and Start data transfer with Log Capturing    ue_index=${0}
    ${SA_DL}    PowerUE.Check DL Throughput  ue_index=${0}
    ${SA_UL}    PowerUE.Check UL Throughput  ue_index=${0}
    should be true   ${SA_DL} and ${SA_UL}
    UE Attach and Start data transfer with Log Capturing    ue_index=${1}
    ${NSA_DL}    PowerUE.Check DL Throughput  ue_index=${1}
    ${NSA_UL}    PowerUE.Check UL Throughput  ue_index=${1}
    should be true   ${NSA_DL} and ${NSA_UL}
    ${SA_DL_Remain}    PowerUE.Check DL Throughput  ue_index=${0}
    ${SA_UL_Remain}    PowerUE.Check UL Throughput  ue_index=${0}
    should be true   ${SA_DL_Remain} and ${SA_UL_Remain}

Dual_UE Call with_traffic_original
    [Arguments]    ${peak}=False
    Clear UE info from AMF with Retry
    QC.UE Attach
    Start DL Traffic    DT_Name=dl_qc    UE_alias=${QC_UE_alias}    Expected_Tput=${DL_TPUT}bits/sec    Duration=10min
    Start UL Traffic    DT_Name=ul_qc    UE_alias=${QC_UE_alias}    Expected_Tput=${UL_TPUT}bits/sec    Duration=10min
    ${QC_DL}    Get DLTP Percent
    ${QC_UL}    Get ULTP Percent
    UE Attach and Start data transfer with Log Capturing    UE_alias=${MTK_UE_alias}
    ${QC_MTK_DL}    Get DLTP Percent
    ${QC_MTK_UL}    Get ULTP Percent
    run keyword If    '${QC_DL}'=='0.0' or '${QC_UL}'=='0.0'    Fail    msg=NSA traffic is NOK!
    run keyword if  not '${QC_DL}'=='0.0' or '${QC_UL}'=='0.0'    Verify traffic increment    first_DL=${QC_DL}    first_UL= ${QC_UL}
    ...    second_DL=${QC_MTK_DL}    second_UL=${QC_MTK_UL}
    run keyword if    '${peak}' == 'True'    Verify traffic percentage    DL=${QC_MTK_DL}    UL=${QC_MTK_UL}
    [Teardown]    Run Keyword And Ignore error    UE Detach    UE_alias=${QC_UE_alias}

Verify traffic increment
    [Arguments]    ${first_DL}=1    ${first_UL}=1    ${second_DL}=2    ${second_UL}=2    ${Final}=1.1
    ${DL_res}    evaluate    ${second_DL} / ${first_DL} > ${Final}
    ${UL_res}    evaluate    ${second_UL} / ${first_UL} > ${Final}
    should be true    ${DL_res} and ${UL_res}    msg=DL or UL Traffic is increased less than 10%.

Verify traffic percentage
    [Arguments]    ${DL}=1    ${UL}=1    ${expected}=0.8
    ${DL_res}    evaluate    ${DL} > ${expected}
    ${UL_res}    evaluate    ${UL} > ${expected}
    should be true    ${DL_res} and ${UL_res}    msg=DL or UL Traffic throughput is less than ${expected}.

Get ULTP Percent
    [Arguments]    ${ULThroughput}=6
    [Timeout]    10min
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${uTP}    gNB.GetULThroughput   ALIAS_ASP_1A=${ALIAS_ASP_1A}    duration=40
    Conn.Disconnect    ${ALIAS_ASP_1A}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Evaluate    ${uTP}*${100}/${ULThroughput}
    [Return]    ${ULPercent}

Get DLTP Percent
    [Arguments]    ${DLThroughput}=22
    [Timeout]    10min
    sleep    1min
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    gNB.GetDLThroughput    ALIAS_ASP_1A=${ALIAS_ASP_1A}    duration=60    location=${16}
    Conn.Disconnect    ${ALIAS_ASP_1A}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Evaluate    ${dTP}*${100}/${DLThroughput}
    [Return]    ${DLPercent}

ENB_Admin.Commission
    [Arguments]    ${scf_file}    ${timeout}=${600}    ${connnection}=ENB
    wait until keyword succeeds    3x    1min    ENB_Admin.Login    bts_host=${ENBWEBUI_IP}
    coam.perform_commissioning    scf_file=${scf_file}    skip_parameter_relation_errors=True    should_activate=${true}    timeout=${timeout}
    ...    connection=${connnection}
    ENB_Admin.Logout

ENB.Commissioning
    [Arguments]    ${scf_file}    ${file_path}=${CFGFILE_PATH}
    ENB_Admin.Commission    scf_file=${file_path}/${scf_file}
    sleep    3min

ENB_Admin.Login
    [Arguments]    ${bts_host}=${ENB_WEBUI_IP}    ${username}=${WEBUI_USERNAME}    ${password}=${WEBUI_PASSWORD}    ${bts_port}=${443}
    ...    ${log_dir}=${OUTPUT_DIR}    ${alias}=ENB
    coam.connect_to    bts_host=${bts_host}    bts_port=${bts_port}    username=${username}    password=${password}    use_ssl=${True}
    ...    update_interval=${5000}    admin_api_log_dir=${log_dir}    name=${alias}

ENB_Admin.Logout
    [Arguments]    ${connection}=ENB
    coam.teardown    connection=${connection}

Check counter tree is not empty
    [Arguments]    ${counter_id}=M55327C00001
    [Documentation]    use counter:M55327C00001 to check the counter tree is empty or not
    ...    this keyword only for gNB, can't use in eNB.
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ${values}    get dictionary values    ${res}
    sleep    5
    Should Not Be Empty    ${values[0]}

Check UL DL counter is as expected
    [Arguments]    ${counter_id}    ${target_value}
    [Documentation]    check counters
    wait until keyword succeeds    30min    1min    Check counter tree is not empty    ${counter_id}
    ${date}    Get Current Date    exclude_millis=True
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ${values}    get dictionary values    ${res}
    log    The last one is: ${values[-1]}
    run keyword if    '${values[-1]}' < '${target_value}'    Fail    Check UL DL counter is not as expected

Check Counter
    [Arguments]    ${counter_id}=M55326C00501    ${target}=100
    COAM_WebEM.Login
    wait until keyword succeeds    30min    1min    CheckBTSConuters    ${counter_id}    ${target}
    COAM_WebEM.Logout

CheckBTSConuters
    [Arguments]    ${counter_id}    ${target_value}
    ${date}    Get Current Date    exclude_millis=True
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ${values}    get dictionary values    ${res}
    log    The latest one is: ${values[-1]}
    #should be equal    ${values[-1]}    ${target_value}
    Should Be True    '${values[-1]}' > '${target_value}'

###AMF operation###
Connect to 5GC
    csn.connect to    hostname=${5GC_IP}   username=${5GC_USERNAME}    password=${5GC_PASSWORD}    alias=${ALIAS_5GC}

Disconnect from 5GC
    csn.disconnect    connection=${ALIAS_5GC}

Clear UE info from AMF
   [Arguments]  ${ue_imsi}=${IMSI}
   Connect to 5GC
   ${imsi_presence}=    csn.execute   command=cmm subscriber show --imsi ${ue_imsi} 2> /dev/null| head -n 7 | grep GENERALINFO
   ...    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    csn.execute   command=cmm subscriber delete --imsi ${ue_imsi}    connection=${ALIAS_5GC}
   run keyword if  not '${imsi_presence.replace('\r','\\r').replace('\n','\\n')}'=='${EMPTY}'
   ...    sleep   2min    # WA, make IMSI clear opeation is done completely.
   Disconnect from 5GC
