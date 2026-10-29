*** Settings ***
Documentation
...    author: Ming Shi
...    contact: ming.shi@nokia-sbell.com
...    squad group: SG_03
...    feature : TDD_FDD

Library      OperatingSystem
Library      Process
Library      Collections
Library      String
Library      BuiltIn
Library      taf.transport.ssh    WITH NAME    csn
Library    taf.hw.rf_attenuator    WITH NAME   attena
Library    taf.analyzer.pcap   WITH NAME    parser
Library     taf.selenium.sbts      WITH NAME       selenium_coam
Variables    ../Resources/FDD_TMO_case_commission/__init__.py
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_keywords.py
Variables    ../Resources/variable_new.py
Library    ../Resources/upload_SFE_KPI_value_to_compass_new.py
Library    ../Resources/control_para.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/SFE_TMO_HO_common_keywords.py

*** Variables ***
${tl_scf_path}    /opt/workspace/SCF
${gnb_path}    /tmp
${nglogname}    VoNR.pcap
${logname_VoNR_DRX}    logname_VoNR_DRX
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap\"  -T pdml
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}     ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ue_info_excel}    SFE_env_UE_information.xlsx
${control_pc_ip1}    ${tl.ues[0].ssh_connection_details.addr}
${control_pc_ip3352}    ${tl.ues[15].ssh_connection_details.addr}
${control_pc_ip3353}    ${tl.ues[30].ssh_connection_details.addr}
${control_pc_ip3752}    ${tl.ues[20].ssh_connection_details.addr}
${control_pc_username}    ${tl.ues[0].ssh_connection_details.username}
${control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${check_name}    Serial number
@{types}    NSA    SA
${action}    Yes
@{ue_action}    attach    detach
${ute_ip}    ${tl.test_pc.default_ssh_connection_details.addr}
${ute_username}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
@{hanging_resource_file}    hanging_check_4G_5G.py
${SCF_path}    /opt/workspace/SCF/
@{list_}
@{counter_list_}
${enb_instance}     ${tl.enbs[0].instance_id}
@{enb_id}    33523    37521
${model}    ${tl.attenuator[0].model}
${ue_info_path}    /opt/workspace/SCF/ue_traffic_info.yml


*** Keywords ***
Get all the counters and add in excel
    [Arguments]    ${celltype}    ${file_path}=${epc_log_path}${celltype}_HO_counter.xlsx    ${timeout}=60
    create_excel_and_write_date_list    start_date=${start_date}    end_date=${end_date}
    ...                         filepath=${file_path}
    ...                         filesheet=${celltype}_HO_SFE
    FOR  ${pm_counter}  IN   @{pm_all_list}
        ${counter_value}    get the Counter dict from COAM    gnb_id=${pm_counter['gnb_id']}
        ...                                counter_id=${pm_counter['counter_id']}
        ...                                dic_path=${pm_counter['dic_path']}
        ...                                timeout=${timeout}
        write_counter_to_excel    counter_value=${counter_value}    counter_prop=${pm_counter}
        ...                       filepath=${epc_log_path}${celltype}_HO_counter.xlsx
        ...                       filesheet=${celltype}_HO_SFE
    END

Prepare with PM counter time caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    360-${utc0}%300
    sleep    ${left_timer}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Add the PM counter list
    [Arguments]    ${pm_counters}
    FOR  ${pm_counter}  IN   @{pm_counters}
        Append To List    ${PM_all_list}    ${pm_counter}
    END

get the Counter dict from COAM
    [Arguments]    ${counter_id}    ${gnb_id}=1    ${dic_path}=full    ${date}=all    ${min_len}=1    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_dict    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${dic_path}    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections
    [Return]    ${counter_value}

Prepare the gnb commission for SFE two testline
    [Arguments]  ${cell_type}=NSA    ${timeout}=600
    Prepare the gnb scf commission    gnb_id=1    cell_type=${cell_type}    timeout=${timeout}
#    run keyword if    '${enb_instance}'!='@{enb_id}[0]'
#    ...    Prepare the gnb scf commission    gnb_id=2    cell_type=${cell_type}    timeout=${timeout}
    Prepare the gnb scf commission    gnb_id=2    cell_type=${cell_type}    timeout=${timeout}
    sleep    5min
    Coam with check the gnb cell status onair    gnb_id=1
#    run keyword if    '${enb_instance}'!='@{enb_id}[0]'
#    ...    Coam with check the gnb cell status onair    gnb_id=2
    Coam with check the gnb cell status onair    gnb_id=2
    run keyword if    '${cell_type}'=='NSA'    Check all enb x2link status avaliable

get traffic direction and ho times
    [Arguments]  ${cell_type}=NSA
    Get path of control para txt    gnb_id=1    cell_type=${cell_type}
    run keyword if    '${enb_instance}'!='${enb_id}[0]'
    ...    Get path of control para txt    gnb_id=2    cell_type=${cell_type}

get value of control parameter
    ${traffic_direction}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=traffic_direction
    ${ho_times}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=HO_times
    ${Import_SA_SCF}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=Import_SA_SCF
    ${Import_NSA_SCF}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=Import_NSA_SCF
    ${Import_pingpang_SCF}=    get_control_para
    ...    file_path=${control_para_file_path}    control_para_name=Import_pingpang_SCF
    set suite variable      ${traffic_direction}
    set suite variable      ${ho_times}
    set suite variable      ${Import_SA_SCF}
    set suite variable      ${Import_NSA_SCF}
    set suite variable      ${Import_pingpang_SCF}

Check all enb x2link status avaliable
    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=0    gnbid=0
    run keyword if    '${enb_instance}'!='${enb_id}[0]'
    ...    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=0    gnbid=1
#    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=1    gnbid=0
#    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=1    gnbid=1

Prepare the gnb commission for SFE two testline TL366
    [Arguments]  ${cell_type}=NSA
    Prepare the gnb scf commission    gnb_id=1    cell_type=${cell_type}
    Prepare the gnb scf commission    gnb_id=2    cell_type=${cell_type}
    sleep    5min
    Coam with check the gnb cell status onair    gnb_id=1
    Coam with check the gnb cell status onair    gnb_id=2
    run keyword if    '${cell_type}'=='NSA'    Check all enb x2link status avaliable

Check all enb x2link status avaliable TL366
    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=0    gnbid=0
#    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=0    gnbid=1
#    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=1    gnbid=0
#    wait until keyword succeeds    5x    30s    Check the enb x2link status    enb_index=1    gnbid=1

Check the enb x2link status
    [Arguments]  ${enb_index}=0    ${gnbid}=0    ${adjGnbId}=${tl.gnbs[${gnbid}].instance_id}
    Connect to eNB via ssl    enb_index=${enb_index}
    @{MOs}    enblte.get_managed_objects    class_name=LNADJGNB_A    connection=enblte
    FOR    ${list}    IN    @{MOs}
        ${status}    run keyword and return status    Should be equal as strings    ${list['parameters']['adjGnbId']}
        ...    ${adjGnbId}
        ${dist_name} =    set variable if    '${status}'=='${True}'    ${list['distName']}
        EXIT FOR LOOP IF    '${status}'=='${True}'
    END
    should be true    '${status}'=='${True}'    msg=there has no match adjGnb with provide adjGnbId
    &{x2_link_status}    enblte.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=x2ToGnbLinkStatus    connection=enblte
    Should be equal as strings    ${x2_link_status['x2ToGnbLinkStatus']}    available    msg=X2 link to gnb is unavailable
    [Teardown]    Enblte close down

Prepare the gnb scf commission
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA    ${timeout}=600
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${Active_SW_version}    Get Active SW Version    timeout=30
    set suite variable      ${Active_SW_version}
    ${char}    run keyword and return status     Should contain    ${Active_SW_version}    .
    Run Keyword If    '${char}' == 'True'    Get SCF path and perform define commission    gnb_id=${gnb_id}
    ...    cell_type=${cell_type}
    Run Keyword If    '${char}' == 'False'    Get SCF path and perform define commission with SBTS    gnb_id=${gnb_id}
    ...    cell_type=${cell_type}    timeout=${timeout}

#Get path of control para txt
#    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
#    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
#    ${Active_SW_version}    Get Active SW Version
#    set suite variable      ${Active_SW_version}
#    ${char}    run keyword and return status     Should contain    ${Active_SW_version}    .
#    Run Keyword If    '${char}' == 'True'    Get SCF and control para txt path    gnb_id=${gnb_id}    cell_type=${cell_type}
#    Run Keyword If    '${char}' == 'False'    Get SCF and control para txt path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}
Get path of control para txt
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${Active_SW_version}    Get Active SW Version    timeout=30
    set suite variable      ${Active_SW_version}
    ${char}    run keyword and return status     Should contain    ${Active_SW_version}    .
    Run Keyword If    '${char}' == 'True'    Get SCF and control para txt path    gnb_id=${gnb_id}    cell_type=${cell_type}
    Run Keyword If    '${char}' == 'False'    Get SCF and control para txt path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}

Prepare the gnb commission for SFE two testline with traffic TL366
    [Arguments]  ${cell_type}=NSA
    Prepare the gnb scf commission with traffic    gnb_id=1    cell_type=${cell_type}
    Prepare the gnb scf commission with traffic    gnb_id=2    cell_type=${cell_type}
    sleep    5min
    Coam with check the gnb cell status onair    gnb_id=1
    Coam with check the gnb cell status onair    gnb_id=2
    run keyword if    '${cell_type}'=='NSA'    Check all enb x2link status avaliable

Prepare the gnb scf commission with traffic
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${Active_SW_version}    Get Active SW Version    timeout=30
    set suite variable      ${Active_SW_version}
    ${char}    run keyword and return status     Should contain    ${Active_SW_version}    .
    Run Keyword If    '${char}' == 'True'    Get SCF path    gnb_id=${gnb_id}    cell_type=${cell_type}
    Run Keyword If    '${char}' == 'False'    Get SCF path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}
    modify name of traffic scf    gnb_id=${gnb_id}    cell_type=${cell_type}
    Perform define commission for COAM gnb    scf_path=${Golden_SCF_traffic_Path}    gnb_id=${gnb_id}

Check if need to import SA pingpang SCF file
    run keyword if    '${Import_pingpang_SCF}' == '${action}'    Prepare the gnb commission for SFE two testline with pingpang
    ...    ELSE    Run Keywords    change AMF status
    ...    AND    change a3OffsetSsbRsrp value

Prepare the gnb commission for SFE two testline with pingpang
    [Arguments]  ${cell_type}=SA
    Prepare the gnb scf commission with pingpang    gnb_id=1    cell_type=${cell_type}
    Prepare the gnb scf commission with pingpang    gnb_id=2    cell_type=${cell_type}
    sleep    10min
    Coam with check the gnb cell status onair    gnb_id=1
    Coam with check the gnb cell status onair    gnb_id=2
#    run keyword if    '${cell_type}'=='NSA'    Check all enb x2link status avaliable

Prepare the gnb scf commission with pingpang
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${Active_SW_version}    Get Active SW Version    timeout=30
    set suite variable      ${Active_SW_version}
    ${char}    run keyword and return status     Should contain    ${Active_SW_version}    .
    Run Keyword If    '${char}' == 'True'    Get SCF path    gnb_id=${gnb_id}    cell_type=${cell_type}
    Run Keyword If    '${char}' == 'False'    Get SCF path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}
    modify name of pingpang scf    gnb_id=${gnb_id}    cell_type=${cell_type}
    Perform define commission for COAM gnb    scf_path=${Golden_SCF_traffic_Path}    gnb_id=${gnb_id}

Get SCF and control para txt path
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    Get SCF path    gnb_id=${gnb_id}    cell_type=${cell_type}

Get SCF path and perform define commission
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    Get SCF path    gnb_id=${gnb_id}    cell_type=${cell_type}
    Perform define commission for COAM gnb    scf_path=${Golden_SCF_Path}    gnb_id=${gnb_id}

Get SCF and control para txt path with SBTS
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    Get SCF path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}

Get SCF path and perform define commission with SBTS
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA    ${timeout}=600
    Get SCF path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}
    Perform define commission for COAM gnb    scf_path=${Golden_SCF_Path}    gnb_id=${gnb_id}    timeout=${timeout}

Get SCF path
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    ${Golden_SCF_Path}    Get Golden local SCF Path    gnb_id=${gnb_id}    cell_type=${cell_type}
    set suite variable      ${Golden_SCF_Path}

Get SCF path with SBTS
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    ${Golden_SCF_Path}    Get Golden local SCF Path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}
    set suite variable      ${Golden_SCF_Path}

Get Golden local SCF Path
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    @{rest}    String.split string    string=${Active_SW_version}    separator=.
    ${GOLDEN_FULL_SCF}   Set Variable    ${tl_scf_path}/${rest}[0].${rest}[1]/GNB${gnb_id}_${cell_type}_SCF.xml
    set suite variable    ${control_para_file_path}   ${tl_scf_path}/${rest}[0].${rest}[1]/TA_para_control.txt
    [Return]   ${GOLDEN_FULL_SCF}

Get Golden local SCF Path with SBTS
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    @{rest}    String.split string    string=${Active_SW_version}    separator=_
    set suite variable    ${gNB_Rel}   ${rest}[0]
    ${GOLDEN_FULL_SCF}   Set Variable    ${tl_scf_path}/${rest}[0]/GNB${gnb_id}_${cell_type}_SCF.xml
    set suite variable    ${control_para_file_path}   ${tl_scf_path}/${rest}[0]/TA_para_control.txt
    [Return]   ${GOLDEN_FULL_SCF}

modify name of traffic scf
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    @{rest}    String.split string    string=${Golden_SCF_Path}    separator=/
    set suite variable    ${Golden_SCF_traffic_Path}   ${tl_scf_path}/${rest}[4]/GNB${gnb_id}_${cell_type}_5M_10M_15M_SCF.xml

modify name of pingpang scf
    [Arguments]  ${gnb_id}=1    ${cell_type}=NSA
    @{rest}    String.split string    string=${Golden_SCF_Path}    separator=/
    set suite variable    ${Golden_SCF_traffic_Path}   ${tl_scf_path}/${rest}[4]/GNB${gnb_id}_${cell_type}_pingpang_SCF.xml

Coam with check the gnb cell status onair
     [Arguments]    ${gnb_id}=1
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Perform define commission for COAM gnb
    [Arguments]    ${scf_path}    ${is_pdl_checking_needed}=${False}    ${gnb_id}=1    ${timeout}=600
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    COAM Commission with scf file    scf_file_path=${scf_path}    is_pdl_checking_needed=${is_pdl_checking_needed}
     ...    timeout=${timeout}
    [Teardown]    COAM Teardown gnb connections

Prepare all online UE with data start
    [Arguments]    ${cell_type}=NSA    ${ue_number}=all    ${traffic_direction}=DL
     Run Keyword If    '${traffic_direction}' == 'DL'
     ...    Prepare all online UE with DL data start    cell_type=${cell_type}    ue_number=${ue_number}
     ...    ELSE IF    '${traffic_direction}' == 'UL'
     ...    Prepare all online UE with UL data start    cell_type=${cell_type}    ue_number=${ue_number}
     ...    ELSE IF    '${traffic_direction}' == 'DLUL'
     ...    Prepare all online UE with UL and DL data start    cell_type=${cell_type}    ue_number=${ue_number}

Prepare all online UE with data start test
    [Arguments]    ${cell_type}=NSA
    sleep    10s
#     Run Keyword If    '${traffic_direction}' == 'DL'
#     ...    Prepare all online UE with DL data start    cell_type=${cell_type}
#     ...    ELSE IF    '${traffic_direction}' == 'UL'
#     ...    Prepare all online UE with UL data start    cell_type=${cell_type}
#     ...    ELSE IF    '${traffic_direction}' == 'DLUL'
#     ...    Prepare all online UE with UL and DL data start    cell_type=${cell_type}

Prepare all online UE with UL data start
    [Arguments]    ${cell_type}=NSA    ${ue_number}=all
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    ue_num=${ue_num}    cell_type=${cell_type}    ue_number=${ue_number}
    Start all online UE UL data transfer    ue_num=${ue_num}

Prepare all online UE with DL data start
    [Arguments]    ${cell_type}=NSA    ${ue_number}=all
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    ue_num=${ue_num}    cell_type=${cell_type}    ue_number=${ue_number}
    Start all online UE DL data transfer    ue_num=${ue_num}

Prepare all online UE with UL and DL data start
    [Arguments]    ${cell_type}=NSA    ${ue_number}=all
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    ue_num=${ue_num}    cell_type=${cell_type}    ue_number=${ue_number}
    Start all online UE UL and DL data transfer    ue_num=${ue_num}

Prepare all online UE with data start with attach and detach
    [Arguments]    ${cell_type}=NSA
     Run Keyword If    '${traffic_direction}' == 'DL'
     ...    Prepare all online UE with DL data start with attach and detach    cell_type=${cell_type}
     ...    ELSE IF    '${traffic_direction}' == 'UL'
     ...    Prepare all online UE with UL data start with attach and detach    cell_type=${cell_type}
     ...    ELSE IF    '${traffic_direction}' == 'DLUL'
     ...    Prepare all online UE with UL and DL data start with attach and detach    cell_type=${cell_type}

Prepare all online UE with UL data start with attach and detach
    [Arguments]    ${cell_type}=NSA
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Start all online UE UL data transfer    ue_num=${ue_num}

Prepare all online UE with DL data start with attach and detach
    [Arguments]    ${cell_type}=NSA
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Start all online UE DL data transfer    ue_num=${ue_num}

Prepare all online UE with UL and DL data start with attach and detach
    [Arguments]    ${cell_type}=NSA
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Start all online UE UL and DL data transfer    ue_num=${ue_num}

Prepare all online UE with data start with VoNR of multi ues
     Run Keyword If    '${traffic_direction}' == 'DL'
     ...    Prepare all online UE with DL data start with VoNR of multi ues
     ...    ELSE IF    '${traffic_direction}' == 'UL'
     ...    Prepare all online UE with UL data start with VoNR of multi ues
     ...    ELSE IF    '${traffic_direction}' == 'DLUL'
     ...    Prepare all online UE with UL and DL data start with VoNR of multi ues

Prepare all online UE with DL data start with VoNR of multi ues
#    Check all online UE network status and recover with VoNR of multi ues
    Start all online UE DL data transfer with VoNR of multi ues

Prepare all online UE with UL data start with VoNR of multi ues
#    Check all online UE network status and recover with VoNR of multi ues
    Start all online UE UL data transfer with VoNR of multi ues

Prepare all online UE with UL and DL data start with VoNR of multi ues
#    Check all online UE network status and recover with VoNR of multi ues
    Start all online UE UL and DL data transfer with VoNR of multi ues

Check all online UE network status and recover with VoNR of multi ues
    slect specified index of ue on TL335
    ${offline_ues}    set variable    ${0}
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} shell getprop gsm.network.type
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        ${result} =    csn.read output    connection=cpc_${ue_index}
        ${network_status}    run keyword and return status    should not contain    ${result}    Unknown
        ${offline_ues}    set variable if    '${network_status}'=='False'    ${offline_ues+1}    ${offline_ues}
        run keyword if    '${network_status}'=='False'    csn.send command
        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
    END
    Log    total ${offline_ues}ues offline and ${offline_ues}ues do the reboot operation
    run keyword if    ${offline_ues}>0    sleep    3min

make multi ues network with multi pc
    [Arguments]    ${action_index}=${0}
    multi_ues_network_operate    control_pc_ip=${control_pc_ip1}    username=${control_pc_username}
    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    multi_ues_network_operate    control_pc_ip=${control_pc_ip2}    username=${control_pc_username}
    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]

make multi ues network with single pc
    [Arguments]    ${action_index}=${0}    ${control_pc_ip}=${control_pc_ip1}    ${ue_number}=all
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip}    ue_number=${ue_number}
    sleep    1min

Start all online UE UL data transfer with VoNR of multi ues
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE UL data transfer with VoNR of multi ues
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all online UE DL data transfer with VoNR of multi ues
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}
    slect specified index of ue on TL335
    Stop all online UE DL data transfer with VoNR of multi ues
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
Start all online UE DL data transfer with multi ues for SA
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}
    select specified index of ue for SA on TL335
    Stop all online UE DL data transfer with VoNR of multi ues
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
Start all online UE DL data transfer with multi ues for NSA
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}
    select specified index of ue for NSA on TL335
    Stop all online UE DL data transfer with VoNR of multi ues
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
Start all online UE DL data transfer with VoNR of multi ues TL375
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}
    slect specified index of ue on TL375
    Stop all online UE DL data transfer with VoNR of multi ues
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
Start all online UE UL and DL data transfer with VoNR of multi ues
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}
    ...    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE DL data transfer with VoNR of multi ues
    Stop all online UE UL data transfer with VoNR of multi ues
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} - (${ue_index} + ${1})
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Stop all online UE UL data transfer with VoNR of multi ues
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
    END

Stop all online UE DL data transfer with VoNR of multi ues
    FOR  ${ue_index}  IN   @{ues_index}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
    END

Prepare all online UE with UL and DL data start with Qcom366
    [Arguments]    ${cell_type}=NSA
#    ${ue_num}    get length    ${tl.ues}
#    set suite variable    ${ue_num}
#    Check all online UE network status and recover    ue_num=${ue_num}    cell_type=${cell_type}
    Start all online UE UL and DL data transfer with Qcom366    ue_num=${1}

#PA with one cell on and set value
#    [Arguments]    ${cellid}    ${set_value}=${0}    ${total_gnb1cell}=${13}    ${total_gnb2cell}=${13}
#    ...    ${cell_type}=SA    ${index1}=${5}    ${index2}=${1}
#    ####gnb1 cell1 P1 P2 P3 P4######
#    Change Attenuation value    atten_ip=${atten_ip}    cell=5Gcell${cellid}    value=${set_value}
#    ####gnb1 cell2 cell 3 P5-P12######
#    FOR  ${index1}    IN RANGE    ${index1}    ${total_gnb1cell}
#         Change Attenuation value for PA   atten_ip=${atten_ip}    cell=5Ggnb1cell   value=${127}    index1=${index1}
#    END
#    FOR  ${index2}    IN RANGE    ${index2}    ${total_gnb2cell}
#         Change Attenuation value for PA   atten_ip=${atten_ip2}    cell=5Ggnb2cell   value=${127}    index1=${index2}
#    END
#    run keyword if    '${cell_type}'=='NSA'    run keywords
#    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell2    value=${0}    AND
#    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell1    value=${127}
#    run keyword if    '${cell_type}'=='SA'    run keywords
#    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell1    value=${127}    AND
#    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell2    value=${127}

PA with one cell on and set value
    [Arguments]    ${5Ggnb1cell}    ${5Ggnb2cell}    ${cell_type}=SA
    ####gnb1 cell1 P1 P2 P3 P4######
    Change Attenuation value    atten_ip=${atten_ip}    cell=${5Ggnb1cell}${cellid}[0]    value=${set_value}[0]

    ####gnb1 cell2 P5 P6 P7 P8######
    Change Attenuation value    atten_ip=${atten_ip}    cell=${5Ggnb1cell}${cellid}[1]     value=${set_value}[1]

    ####gnb1 cell3 P9 P10 P11 P12######
    Change Attenuation value    atten_ip=${atten_ip}    cell=${5Ggnb1cell}${cellid}[2]     value=${set_value}[1]

    ####gnb2 cell301 P1 P2 P3 P4######
    Change Attenuation value    atten_ip=${atten_ip2}    cell=${5Ggnb2cell}${cellid}[6]     value=${set_value}[1]

    ####gnb2 cell302 P5 P6 P7 P8######
    Change Attenuation value    atten_ip=${atten_ip2}    cell=${5Ggnb2cell}${cellid}[7]     value=${set_value}[1]

    ####gnb2 cell303 P9 P10 P11 P12######
    Change Attenuation value    atten_ip=${atten_ip2}    cell=${5Ggnb2cell}${cellid}[8]     value=${set_value}[1]

    ####gnb2 cellpre P13 P14 P15 P16######
#    Change Attenuation value    atten_ip=${atten_ip2}    cell=${5Ggnb2cell}@{cellid}[8]     value=@{set_value}[1]

    run keyword if    '${cell_type}'=='NSA'    run keywords
    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell2    value=${0}    AND
    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell1    value=${127}
    run keyword if    '${cell_type}'=='SA'    run keywords
    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell1    value=${127}    AND
    ...    Change Attenuation value for LTE    atten_ip=${atten_ip}    cell=4Gcell2    value=${127}

Start all online UE UL data transfer
    [Arguments]    ${ue_num}    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE UL data transfer    ue_num=${ue_num}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all online UE DL data transfer
    [Arguments]    ${ue_num}    ${source_dl_port}=${tl.appserver.iperf_details.port}
    Stop all online UE DL data transfer    ue_num=${ue_num}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
Start All UE DL UDP data transfer on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=dl    ${ue_type}=${ue_type}
    select all index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${dl_port}    ue_index=${ue_index}
    END
Start ALL UE UL UDP data transfer on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=ul    ${ue_type}=${ue_type}    ${iperf_type}=command
    select all index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${ul_port}    ue_index=${ue_index}    iperf_type=${iperf_type}
    END
Start SA UE DL UDP data transfer on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=dl    ${ue_type}=${ue_type}
    select specified index of ue for SA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${dl_port}    ue_index=${ue_index}
    END
Start SA UE UL UDP data transfer on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=ul    ${ue_type}=${ue_type}    ${iperf_type}=command
    select specified index of ue for SA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${ul_port}    ue_index=${ue_index}    iperf_type=${iperf_type}
    END
Start NSA UE DL UDP data transfer on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=dl    ${ue_type}=${ue_type}
    select specified index of ue for NSA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${dl_port}    ue_index=${ue_index}
    END
Start NSA UE UL UDP data transfer on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=ul    ${ue_type}=${ue_type}    ${iperf_type}=command
    select specified index of ue for NSA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${ul_port}    ue_index=${ue_index}    iperf_type=${iperf_type}
    END
Start benchmark UE DL UDP data transfer on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=dl    ${ue_type}=${ue_type}
    slect specified index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${dl_port}    ue_index=${ue_index}
    END
Start benchmark UE UL UDP data transfer on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=ul    ${ue_type}=${ue_type}    ${iperf_type}=command
    slect specified index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${ul_port}    ue_index=${ue_index}    iperf_type=${iperf_type}
    END
Start All UE DL UDP data transfer on 375
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=dl    ${ue_type}=${ue_type}
    select all index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${dl_port}    ue_index=${ue_index}
    END
Start ALL UE UL UDP data transfer on 375
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=ul    ${ue_type}=${ue_type}    ${iperf_type}=command
    select all index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${ul_port}    ue_index=${ue_index}    iperf_type=${iperf_type}
    END
Start benchmark UE DL UDP data transfer on 375
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=dl    ${ue_type}=${ue_type}
    slect specified index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${dl_port}    ue_index=${ue_index}
    END
Start benchmark UE UL UDP data transfer on 375
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${throughput}=10    ${duration}=${3600}
    ...    ${direction}=ul    ${ue_type}=${ue_type}    ${iperf_type}=command
    slect specified index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+20
        power_ue.Start traffic     direction=${direction}    ue_type=${ue_type}    throughput=${throughput}    duration=${duration}
        ...                       iperf_port=${ul_port}    ue_index=${ue_index}    iperf_type=${iperf_type}
    END
Stop ALL UE DL UDP traffic on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${direction}=dl    ${ue_type}=${ue_type}
    select all index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${dl_port}
    END
Stop ALL UE UL UDP traffic on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${direction}=ul    ${ue_type}=${ue_type}
    ...    ${iperf_type}=command
    select all index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${ul_port}
        ...                     iperf_type=${iperf_type}
    END
Stop SA UE DL UDP traffic on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${direction}=dl    ${ue_type}=${ue_type}
    select specified index of ue for SA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${dl_port}
    END
Stop SA UE UL UDP traffic on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${direction}=ul    ${ue_type}=${ue_type}
    ...    ${iperf_type}=command
    select specified index of ue for SA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${ul_port}
        ...                     iperf_type=${iperf_type}
    END
Stop NSA UE DL UDP traffic on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${direction}=dl    ${ue_type}=${ue_type}
    select specified index of ue for NSA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${dl_port}
    END
Stop NSA UE UL UDP traffic on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${direction}=ul    ${ue_type}=${ue_type}
    ...    ${iperf_type}=command
    select specified index of ue for NSA on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${ul_port}
        ...                     iperf_type=${iperf_type}
    END
Stop benchmark UE DL UDP traffic on 335
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${direction}=dl    ${ue_type}=${ue_type}
    slect specified index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${dl_port}
    END
Stop benchmark UE UL UDP traffic on 335
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${direction}=ul    ${ue_type}=${ue_type}
    ...    ${iperf_type}=command
    slect specified index of ue on TL335
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${ul_port}
        ...                     iperf_type=${iperf_type}
    END
Stop ALL UE DL UDP traffic on 375
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${direction}=dl    ${ue_type}=${ue_type}
    select all index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${dl_port}
    END
Stop ALL UE UL UDP traffic on 375
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${direction}=ul    ${ue_type}=${ue_type}
    ...    ${iperf_type}=command
    select all index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+40
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${ul_port}
        ...                     iperf_type=${iperf_type}
    END
Stop benchmark UE DL UDP traffic on 375
    [Arguments]    ${source_dl_port}=${tl.appserver.iperf_details.port}    ${direction}=dl    ${ue_type}=${ue_type}
    slect specified index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${dl_port}
    END
Stop benchmark UE UL UDP traffic on 375
    [Arguments]    ${source_ul_port}=${tl.appserver.iperf_details.port}    ${direction}=ul    ${ue_type}=${ue_type}
    ...    ${iperf_type}=command
    slect specified index of ue on TL375
    sleep    3s
    FOR  ${ue_index}  IN   @{ues_index}
        ${ul_port} =    evaluate    ${source_ul_port} + ${ue_index}+20
        power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}   direction=${direction}    iperf_port=${ul_port}
        ...                     iperf_type=${iperf_type}
    END

Start all online UE UL and DL data transfer
    [Arguments]    ${ue_num}    ${source_dl_port}=${tl.appserver.iperf_details.port}
    ...    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE DL data transfer    ue_num=${ue_num}
    Stop all online UE UL data transfer    ue_num=${ue_num}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} - (${ue_index} + ${1})
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all online UE UL and DL data transfer with Qcom366
    [Arguments]    ${ue_num}    ${source_dl_port}=${tl.appserver.iperf_details.port}
    ...    ${source_ul_port}=${tl.appserver.iperf_details.port}
    Stop all online UE DL data transfer    ue_num=${ue_num}
    Stop all online UE UL data transfer    ue_num=${ue_num}
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${dl_port} =    evaluate    ${source_dl_port} + ${ue_index}
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_dl_iperf_Qcom.sh ${tl.ues[${ue_index}].serial_number} ${dl_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END
    sleep    3s
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        ${ul_port} =    evaluate    ${source_ul_port} - (${ue_index} + ${1})
        csn.send command
        ...    command=/cygdrive/c/Iperf/andriod_ul_iperf_Qcom.sh ${tl.ues[${ue_index}].serial_number} ${ul_port}
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    1s
        Csn.disconnect    connection=cpc_${ue_index}
    END

Start all tcp receive port on appserver
    [Arguments]    ${port_num}    ${source_ul_port}=${tl.appserver.iperf_details.port}
    create connect to appserver
    FOR  ${item}    IN RANGE    ${port_num}
        ${ul_port} =    evaluate    ${source_ul_port} + ${item}
        csn.send_command    command=iperf3 -s -p ${ul_port} -i 1 &    connection=APPserver    timeout=15
        sleep    1s
    END

Stop all tcp receive port on appserver
    [Arguments]    ${port_num}    ${source_ul_port}=${tl.appserver.iperf_details.port}
    create connect to appserver
    FOR  ${item}    IN RANGE    ${port_num}
        ${ul_port} =    evaluate    ${source_ul_port} + ${item}
        csn.send_command    command=ps -ef | grep iperf3 | grep ${ul_port} | awk '{print $2}' |xargs kill -9
        ...    connection=APPserver    timeout=15
        sleep    1s
    END

create connect to appserver
    [Arguments]    ${alias}=APPserver
    csn.connect_to    hostname=${tl.appserver.iperf_details.ssh_connection_details.addr}
    ...    username=${tl.appserver.iperf_details.ssh_connection_details.username}
    ...    password=${tl.appserver.iperf_details.ssh_connection_details.password}
    ...    alias=${alias}

Stop all online UE UL data transfer
    [Arguments]    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
    END

Stop all online UE DL data transfer
    [Arguments]    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
#        ...    command=ps -ef | grep "adb" | grep -v grep | awk '{print $2}' | xargs kill -s 9
        ...    command=ps -ef |grep iperf3 |awk '{print $2}'|xargs kill -9
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
    END
Check all online UE network status and recover

    [Arguments]    ${ue_num}    ${cell_type}=NSA    ${action_index}=${0}    ${ue_number}=all
    run keyword if    '${cell_type}'=='NSA'    Check all online UE network status and recover for NSA    ue_num=${ue_num}
    ...    action_index=${action_index}    ue_number=${ue_number}
    run keyword if    '${cell_type}'=='SA'    Check all online UE network status and recover for SA    ue_num=${ue_num}
    ...    action_index=${action_index}    ue_number=${ue_number}

Check all online UE network status and recover for SA
    [Arguments]    ${ue_num}    ${action_index}=${0}    ${ue_number}=all
#    ${offline_ues}    set variable    ${0}
#    FOR  ${ue_index}    IN RANGE    ${ue_num}
#        Connect to control pc enhanced    ue_index=${ue_index}
#        csn.send command
#        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} shell getprop gsm.network.type
#        ...    connection=cpc_${ue_index}
#        ...    timeout=15
#        sleep    1s
#        ${result} =    csn.read output    connection=cpc_${ue_index}
#        ${network_status}    run keyword and return status    should not contain    ${result}    Unknown
#        ${offline_ues}    set variable if    '${network_status}'=='False'    ${offline_ues+1}    ${offline_ues}
#        run keyword if    '${network_status}'=='False'    csn.send command
#        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot
#        ...    connection=cpc_${ue_index}
#        ...    timeout=15
#        sleep    1s
#    END
#    Log    total ${offline_ues}ues offline and ${offline_ues}ues do the reboot operation
#    run keyword if    ${offline_ues}>0    sleep    3min
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip1}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip2}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip1}    ue_number=${ue_number}
    Run Keyword If    '${testline_instance_id}' == '375'
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3752}    ue_number=${ue_number}
    Run Keyword If    '${testline_instance_id}' == '335'    Run Keywords
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3352}    ue_number=${ue_number}
    ...    AND    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3353}
    ...    ue_number=${ue_number}

Check all online UE network status and recover for NSA
    [Arguments]    ${ue_num}    ${cell_type}=NSA    ${action_index}=${0}    ${ue_number}=all
#    ${offline_ues}    set variable    ${0}
#    FOR  ${ue_index}    IN RANGE    ${ue_num}
#        Connect to control pc enhanced    ue_index=${ue_index}
#        csn.send command
#        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot
#        ...    connection=cpc_${ue_index}
#        ...    timeout=15
#        sleep    1s
#    END
#    sleep    3min
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip1}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip2}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip1}    ue_number=${ue_number}
    Run Keyword If    '${testline_instance_id}' == '375'
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3752}    ue_number=${ue_number}
    Run Keyword If    '${testline_instance_id}' == '335'    Run Keywords
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3352}    ue_number=${ue_number}
    ...    AND    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3353}
    ...    ue_number=${ue_number}

multi_all_ues_network_operate
    [Arguments]    ${action_index}=${0}    ${ue_number}=all
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip1}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
#    multi_ues_network_operate    control_pc_ip=${control_pc_ip2}    username=${control_pc_username}
#    ...    password=${control_pc_password}    action=${ue_action}[${action_index}]
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip1}    ue_number=${ue_number}
    Run Keyword If    '${testline_instance_id}' == '375'
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3752}    ue_number=${ue_number}
    Run Keyword If    '${testline_instance_id}' == '335'    Run Keywords
    ...    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3352}    ue_number=${ue_number}
    ...    AND    multi_ues_operation_exe_with_threading    action=${ue_action}[${action_index}]    pc_ip=${control_pc_ip3353}
    ...    ue_number=${ue_number}

multi_ues_operation_exe_with_threading
    [Arguments]    ${action}    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}    ${ue_number}=all
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    Wait Until Keyword Succeeds    2min    10s    csn.send command
    ...    command=chmod +x ${SCF_path}multi_ue_attach_threading.exe; chmod +x ${SCF_path}multi_ue_detach_threading.exe
    ...    connection=ute
    sleep    1s
    Wait Until Keyword Succeeds    2min    10s    csn.send command
    ...    command=chmod +x ${SCF_path}partial_ue_attach_threading.exe; chmod +x ${SCF_path}partial_ue_detach_threading.exe
    ...    connection=ute
    sleep    1s
    Run Keyword If    '${action}'=='attach'
    ...   operate_all_or_partial_ue_attach    ue_number=${ue_number}    pc_ip=${pc_ip}
    ...    ELSE IF    '${action}'=='detach'
    ...    operate_all_or_partial_ue_detach    ue_number=${ue_number}    pc_ip=${pc_ip}
    sleep    20s
    [Teardown]    csn.disconnect     connection=ute

operate_all_or_partial_ue_attach
    [Arguments]    ${ue_number}=all    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}
    Run Keyword If    '${ue_number}' == 'all'
    ...    csn.send command
    ...    command=wine ${SCF_path}multi_ue_attach_threading.exe ${pc_ip} ${pc_username} ${pc_password}
    ...    connection=ute
    ...    ELSE IF    '${ue_number}' == 'partial'    Run Keywords
    ...    get sn of partial ues
    ...    AND    csn.send command
    ...    command=wine ${SCF_path}partial_ue_attach_threading.exe ${pc_ip} ${pc_username} ${pc_password} '${ue_sn}'
    ...    connection=ute

operate_all_or_partial_ue_detach
    [Arguments]    ${ue_number}=all    ${pc_ip}=${tl.ues[0].ssh_connection_details.addr}
    ...    ${pc_username}=${tl.ues[0].ssh_connection_details.username}
    ...    ${pc_password}=${tl.ues[0].ssh_connection_details.password}
    Run Keyword If    '${ue_number}' == 'all'
    ...    csn.send command
    ...    command=wine ${SCF_path}multi_ue_detach_threading.exe ${pc_ip} ${pc_username} ${pc_password}
    ...    connection=ute
    ...    ELSE IF    '${ue_number}' == 'partial'    Run Keywords
    ...    get sn of partial ues
    ...    AND    csn.send command
    ...    command=wine ${SCF_path}partial_ue_detach_threading.exe ${pc_ip} ${pc_username} ${pc_password} '${ue_sn}'
    ...    connection=ute

get sn of partial ues
    ${ue_sn}=    get_partial_ues_sn   file_path=${SCF_path}partial_ue_sn.txt
    Set Test Variable    ${ue_sn}

Operate all online UE network reoot for NSA attach
    [Arguments]    ${ue_num}
    ${offline_ues}    set variable    ${0}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
        Connect to control pc enhanced    ue_index=${ue_index}
        csn.send command
        ...    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot
        ...    connection=cpc_${ue_index}
        ...    timeout=15
        sleep    3s
    END
    sleep    3min
    Log    All ${ue_num}ues reboot finish
    Check all online UE network status and recover    ue_num=${ue_num}

Adjust_HBTE_PA
    [Arguments]    ${atten_ip}    ${t_cell}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    [Timeout]    10 hour
    ${s_value}    Evaluate    float(${s_value})
    ${e_value}    Evaluate    float(${e_value})
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set    atten_ip=${atten_ip}    t_cell=${t_cell}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}
    END
    ${pa_status}    run keyword and return status    Change Attenuation value    atten_ip=${atten_ip}    cell=${t_cell}    value=${e_value}
    run keyword if  '${pa_status}'=='False'    PA error counter set
    Log     msg=PA set error counter all ${paerror_counter} times

Adjust_HBTE_PA_LTE
    [Arguments]    ${atten_ip}    ${t_cell}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    [Timeout]    10 hour
    ${s_value}    Evaluate    float(${s_value})
    ${e_value}    Evaluate    float(${e_value})
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set for LTE    atten_ip=${atten_ip}    t_cell=${t_cell}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}
    END
    ${pa_status}    run keyword and return status    Change Attenuation value for LTE    atten_ip=${atten_ip}
    ...    cell=${t_cell}    value=${e_value}
    run keyword if  '${pa_status}'=='False'    PA error counter set
    Log     msg=PA set error counter all ${paerror_counter} times

loop for PA set
    [Arguments]    ${atten_ip}    ${t_cell}    ${s_value}    ${step}     ${step_value}     ${sleep}
    FOR  ${index}    IN RANGE    -${step}    ${step}    1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    ${s_value}+${step_value}*${index}
         ${pa_status}    run keyword and return status    Change Attenuation value     atten_ip=${atten_ip}    cell=${t_cell}    value=${pa_value}
         run keyword if  '${pa_status}'=='False'    PA error counter set
         sleep    ${sleep}s
    END

loop for PA set for LTE
    [Arguments]    ${atten_ip}    ${t_cell}    ${s_value}    ${step}     ${step_value}     ${sleep}
    FOR  ${index}    IN RANGE    -${step}    ${step}    1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    ${s_value}+${step_value}*${index}
         ${pa_status}    run keyword and return status    Change Attenuation value     atten_ip=${atten_ip}    cell=${t_cell}    value=${pa_value}
         run keyword if  '${pa_status}'=='False'    PA error counter set
         sleep    ${sleep}s
    END

#loop for PA set
#    [Arguments]    ${atten_ip}    ${t_cell}    ${s_value}    ${step}     ${step_value}        ${sleep}    ${index3}=${9}    ${total_gnb2cell}=${13}
#    FOR  ${index}    IN RANGE    -${step}    ${step}    1
#         ${index} =    evaluate    abs(${index})
#         ${pa_value} =    evaluate    ${s_value}+${step_value}*${index}
##        ${pa_status}    run keyword and return status    Change Attenuation value    atten_ip=${atten_ip}    cell=${t_cell}    value=${pa_value}
#
#         FOR  ${index1}    IN RANGE    ${index3}    ${total_gnb1cel2}
##             Change Attenuation value for PA   atten_ip=${atten_ip}    cell=5Ggnb1cell   value=${127}    index1=${index1}
#             ${pa_status}    run keyword and return status    Change Attenuation value for PA   atten_ip=${atten_ip}
#             ...    cell=${t_cell}    value=${pa_value}
#         END
#
#
#
#
#         run keyword if  '${pa_status}'=='False'    PA error counter set
#         sleep    ${sleep}s
#    END

PA error counter set
    ${paerror_counter} =    Evaluate    ${paerror_counter}+1


Change Attenuation value for PA
    [Arguments]    ${atten_ip}    ${cell}    ${value}    ${index1}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT${index1}}    value=${value}

Change Attenuation value
    [Arguments]     ${atten_ip}     ${cell}    ${value}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT1}    value=${value}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT2}    value=${value}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT3}    value=${value}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT4}    value=${value}

recover PA value
    PA with one cell on and set value    5Ggnb1cell=${Setgnb1_cell}    5Ggnb2cell=${Setgnb2_cell}
    Change Attenuation value    atten_ip=${atten_ip}    cell=${Setgnb1_cell}${cellid}[0]     value=${set_value}[1]

Change Attenuation value for LTE
    [Arguments]    ${atten_ip}    ${cell}    ${value}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT1}    value=${value}
    Set the Attenuations Values    atten_ip=${atten_ip}     ports=${${cell}_ANT2}    value=${value}

Set the Attenuations Values
    [Arguments]    ${atten_ip}    ${ports}    ${value}
    atten.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${ports}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    atten.set_attenuation     port=${ports}    value=${value}

Check the cell UL throughput
    [Arguments]    ${bandwidth}    ${cellid}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect_TMO_${bandwidth}}    cellid=${nrcellid}    sleep_time=${20}

Set PA all ports to default value
    FOR  ${port}    IN RANGE    16
        ${d_port}  Evaluate    ${port}+${1}
        Adjust the Attenuation Value    ports=${d_port}    value=${127}
    END

Save snapshot Teardown for SFE
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=3600
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}    connection=${connection}
    COAM Save snapshot via rest api    log_path=${epc_log_path}    connection=${connection}    timeout=${timeout}
    COAM Teardown gnb connections    connection=${connection}

Add time list
    ${time1_start}    Get Variable Value    ${time1_start}
    ${time1_end}    Get Variable Value    ${time1_end}
    ${time2_start}    Get Variable Value    ${time2_start}
    ${time2_end}    Get Variable Value    ${time2_end}
    ${time3_start}    Get Variable Value    ${time3_start}
    ${time3_end}    Get Variable Value    ${time3_end}
    ${time4_start}    Get Variable Value    ${time4_start}
    ${time4_end}    Get Variable Value    ${time4_end}
    ${time5_start}    Get Variable Value    ${time5_start}
    ${time5_end}    Get Variable Value    ${time5_end}
    ${time6_start}    Get Variable Value    ${time6_start}
    ${time6_end}    Get Variable Value    ${time6_end}
    Append To List    ${list_}    ${time1_start}    ${time1_end}    ${time2_start}    ${time2_end}
    ...    ${time3_start}    ${time3_end}    ${time4_start}    ${time4_end}    ${time5_start}    ${time5_end}
    ...    ${time6_start}    ${time6_end}
    @{list}    replace_value_from_list    ${list_}
    Set Suite Variable    @{list}

Add time list NSA
#    @{list}=    Create List    ${time7_start}    ${time7_end}    ${time8_start}    ${time8_end}
#    ...    ${time9_start}    ${time9_end}    ${time10_start}    ${time10_end}    ${time11_start}    ${time11_end}
#    ...    ${time12_start}    ${time12_end}    ${time13_start}    ${time13_end}    ${time14_start}    ${time14_end}
    ${time7_start}    Get Variable Value    ${time7_start}
    ${time7_end}    Get Variable Value    ${time7_end}
    ${time8_start}    Get Variable Value    ${time8_start}
    ${time8_end}    Get Variable Value    ${time8_end}
    ${time9_start}    Get Variable Value    ${time9_start}
    ${time9_end}    Get Variable Value    ${time9_end}
    ${time10_start}    Get Variable Value    ${time10_start}
    ${time10_end}    Get Variable Value    ${time10_end}
    ${time11_start}    Get Variable Value    ${time11_start}
    ${time11_end}    Get Variable Value    ${time11_end}
    ${time12_start}    Get Variable Value    ${time12_start}
    ${time12_end}    Get Variable Value    ${time12_end}
    ${time13_start}    Get Variable Value    ${time13_start}
    ${time13_end}    Get Variable Value    ${time13_end}
    ${time14_start}    Get Variable Value    ${time14_start}
    ${time14_end}    Get Variable Value    ${time14_end}
    Append To List    ${list_}    ${time7_start}    ${time7_end}    ${time8_start}    ${time8_end}
    ...    ${time9_start}    ${time9_end}    ${time10_start}    ${time10_end}    ${time11_start}    ${time11_end}
    ...    ${time12_start}    ${time12_end}    ${time13_start}    ${time13_end}    ${time14_start}    ${time14_end}
    @{list}    replace_value_from_list    ${list_}
    Set Suite Variable    @{list}

Add time list VoNR
    @{list}=    Create List    ${time1_start}    ${time1_end}    ${time2_start}    ${time2_end}
    Set Suite Variable    @{list}

Add time list VoNR with multi ues
    @{list}=    Create List    ${time1_start}    ${time1_end}
    Set Suite Variable    @{list}

Add time list EMC with multi ues
    @{list}=    Create List    ${time1_start}    ${time1_end}
    Set Suite Variable    @{list}


upload_kpi_to_compass
    [Arguments]    ${celltype}
    FOR  ${id}  IN   @{KPI_ID}
    upload_execute_data    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    KPI_ID=${id}    tl_id=${tl.gnbs[0].instance_id}    time_list=@{list}    childern_list_len=${2}
    ...    ue_number=${actual_ue_num}
    END

get_counter_name_per_scenario
    [Arguments]    ${pm_counters}    ${index}
    ${counter_name}=    get_counter_names    counter_prop=${pm_counters}
    Set Suite Variable    ${counter_name${index}}    ${counter_name}
    [Return]    ${counter_name${index}}

Add counters list NSA
#    @{counter_list}=    Create List    ${counter_name7}    ${counter_name8}    ${counter_name9}
#    ...    ${counter_name12}    ${counter_name14}
#    Set Suite Variable    @{counter_list}
    ${counter_name7}    Get Variable Value    ${counter_name7}
    ${counter_name8}    Get Variable Value    ${counter_name8}
    ${counter_name9}    Get Variable Value    ${counter_name9}
    ${counter_name10}    Get Variable Value    ${counter_name10}
    ${counter_name11}    Get Variable Value    ${counter_name11}
    ${counter_name12}    Get Variable Value    ${counter_name12}
    ${counter_name13}    Get Variable Value    ${counter_name13}
    ${counter_name14}    Get Variable Value    ${counter_name14}
    Append To List    ${counter_list_}    ${counter_name7}    ${counter_name8}    ${counter_name9}    ${counter_name10}
    ...    ${counter_name11}    ${counter_name12}    ${counter_name13}    ${counter_name14}
    @{counter_list}    replace_value_from_list    ${counter_list_}
    Set Suite Variable    @{counter_list}


set redundant value to 0
    [Arguments]    ${celltype}    ${inital}=7    ${total}=11    ${inital_13}=13    ${inital_14}=14
    FOR  ${index}    IN RANGE    ${inital}    ${total}
    remove_no_use_value    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    start_time=${time${index}_start}    end_time=${time${index}_end}    counter_name=${counter_name${index}}
    END
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    Run Keyword If    '${testline_instance_id}' == '375'
    ...    remove_no_use_value    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    start_time=${time${inital_13}_start}    end_time=${time${inital_13}_end}    counter_name=${counter_name${inital_13}}
    remove_no_use_value    filepath=${epc_log_path}${celltype}_HO_counter.xlsx    filesheet=${celltype}_HO_SFE
    ...    start_time=${time${inital_14}_start}    end_time=${time${inital_14}_end}    counter_name=${counter_name${inital_14}}

backup NSA counter excel
    [Arguments]    ${celltype}
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    csn.send command
    ...    command=cp -r ${epc_log_path}${celltype}_HO_counter.xlsx ${epc_log_path}${celltype}_HO_counter_backup.xlsx
    ...    connection=ute
    csn.disconnect     connection=ute

make VoNR setup
    [Arguments]    ${nglogname}=VoNR.pcap
#    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=any
    Make VoNR call(+6688)
#    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}
#    check points with VoNR    logname=${nglogname}
    check voice call enable

Make mutil UE for VoNR Setup
    slect specified index of ue on TL335
    FOR  ${index}  IN   @{ues_index}
    Make VoNR call(+6688)    ue_index=${index}
#    ${result}=    Run Keyword And Return Status    check voice call enable    ue_index=${index}
#    Run Keyword If    ${result}==${False}    Wait Until Keyword Succeeds    3x    15s
#    ...    make and check voice call enable with adb command    ue_index=${index}
    END

Make mutil UE for VoNR Setup with special index
    slect specified index of ue on TL335 for VONR
    FOR  ${index}  IN   @{ues_index}
    Make VoNR call(+6688)    ue_index=${index}
#    ${result}=    Run Keyword And Return Status    check voice call enable    ue_index=${index}
#    Run Keyword If    ${result}==${False}    Wait Until Keyword Succeeds    3x    15s
#    ...    make and check voice call enable with adb command    ue_index=${index}
    END

Make mutil UE for VoNR Setup TL375
    slect specified index of ue on TL375 for VONR
    FOR  ${index}  IN   @{ues_index}
    Make VoNR call(+6688)    ue_index=${index}
#    ${result}=    Run Keyword And Return Status    check voice call enable    ue_index=${index}
#    Run Keyword If    ${result}==${False}    Wait Until Keyword Succeeds    3x    15s
#    ...    make and check voice call enable with adb command    ue_index=${index}
    END

Make mutil UE for EMC Setup
    slect specified index of ue on TL335
    FOR  ${index}  IN   @{ues_index}
    Make EC call(911)    ue_index=${index}
    END

Make mutil UE for EMC Setup with special index
    slect specified index of ue on TL335 for EMC
    FOR  ${index}  IN   @{ues_index}
    ## temp way for 24R3 not support EC#Make EC call(911)    ue_index=${index}
    Run Keyword If	'${gNB_Rel}' != 'SBTS24R3'	   Make EC call(911)    ue_index=${index}
    Run Keyword If	'${gNB_Rel}' == 'SBTS24R3'	   Make VoNR call(+6688)    ue_index=${index}
    END
Make mutil UE for EMC Setup TL375
    slect specified index of ue on TL375 for EMC
    FOR  ${index}  IN   @{ues_index}
    Make EC call(911)    ue_index=${index}
#    ${result}=    Run Keyword And Return Status    check voice call enable    ue_index=${index}
#    Run Keyword If    ${result}==${False}    Wait Until Keyword Succeeds    3x    15s
#    ...    make and check EMC call enable with adb command    ue_index=${index}
    END
hang up mutil UE for VoNR Setup
    slect specified index of ue on TL335
    FOR  ${index}  IN   @{ues_index}
    hang up VoNR for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END
hang up mutil UE for VoNR Setup with special index
    slect specified index of ue on TL335 for VONR
    FOR  ${index}  IN   @{ues_index}
    hang up VoNR for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END
hang up mutil UE for VoNR Setup TL375
    slect specified index of ue on TL375 for VONR
    FOR  ${index}  IN   @{ues_index}
    hang up VoNR for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END
hang up mutil UE for EMC Setup
    slect specified index of ue on TL335
    FOR  ${index}  IN   @{ues_index}
    hang up EC call for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END
hang up mutil UE for EMC Setup with special index
    slect specified index of ue on TL335 for EMC
    FOR  ${index}  IN   @{ues_index}
    hang up EC call for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END
hang up mutil UE for EMC Setup TL375
    slect specified index of ue on TL375 for EMC
    FOR  ${index}  IN   @{ues_index}
    hang up EC call for SFE    ue_index=${index}
    check voice call disable    ue_index=${index}
    END
select specified index of ue for SA on TL335
    @{ues_index}=    Create List    ${20}    ${21}    ${22}    ${23}    ${24}    ${25}    ${26}    ${27}    ${28}
    ...    ${29}    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}    ${37}    ${38}    ${39}
    Set Suite Variable    @{ues_index}

select specified index of ue for NSA on TL335
    @{ues_index}=    Create List    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
    ...    ${9}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}
    Set Suite Variable    @{ues_index}
select all index of ue on TL335
    @{ues_index}=    Create List    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
    ...    ${9}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}
    ...    ${20}    ${21}    ${22}    ${23}    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}    ${30}
    ...    ${31}    ${32}    ${33}    ${34}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL335
    @{ues_index}=    Create List    ${30}    ${31}    ${32}    ${33}    ${34}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL335 for VONR
    @{ues_index}=    Create List    ${20}    ${21}    ${22}    ${23}    ${24}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL335 for EMC
    @{ues_index}=    Create List    ${25}    ${26}    ${27}    ${28}    ${29}
    Set Suite Variable    @{ues_index}
select all index of ue on TL375
    @{ues_index}=    Create List    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
    ...    ${9}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}
    ...    ${20}    ${21}    ${22}    ${23}    ${24}    ${25}    ${26}    ${27}    ${28}    ${29}
    ...    ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}    ${37}    ${38}    ${39}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL375
    @{ues_index}=    Create List    ${20}    ${21}    ${22}    ${23}    ${24}    ${25}    ${26}    ${27}
    ...    ${28}    ${29}   ${30}    ${31}    ${32}    ${33}    ${34}    ${35}    ${36}    ${37}    ${38}    ${39}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL375 for VONR
    @{ues_index}=    Create List    ${22}    ${24}    ${25}    ${26}    ${27}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL375 for EMC
    @{ues_index}=    Create List    ${15}    ${16}    ${17}    ${18}    ${19}
    Set Suite Variable    @{ues_index}
slect specified index of ue on TL366
    @{ues_index}=    Create List    ${0}
    Set Suite Variable    @{ues_index}

Make VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

Make EC call(911)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

check points with VoNR
    [Arguments]    ${logname}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1

check voice call enable persistence
    [Arguments]    ${phone_number}=6688
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    run keyword if    '${testline_instance_id}' == '335'    slect specified index of ue on TL335
    ...    ELSE IF    '${testline_instance_id}' == '366'    slect specified index of ue on TL366
    FOR  ${ue_index}  IN   @{ues_index}
    ${serial_number}=    Set Variable    ${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    ${mCallState_status}    run keyword and return status    should contain    ${result}    mCallState=2
    csn.disconnect      connection=cpc_${ue_index}
    ${standby_ues}    set variable if    '${mCallState_status}'=='False'    ${standby_ues+1}    ${standby_ues}
    run keyword if    '${mCallState_status}'=='False'
    ...    Wait Until Keyword Succeeds    3x    10s    make and check voice call enable with adb command
    ...    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}
    END

check voice call enable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=2

check voice call disable
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=0

hang up EC call for SFE and check status
    [Arguments]    ${ue_index}=${0}
    hang up EC call for SFE    ue_index=${ue_index}
    check voice call disable    ue_index=${ue_index}

make and check voice call enable with adb command
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    reattach and check network status    ue_index=${ue_index}
    Make VoNR call(+6688)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}
    check voice call enable    ue_index=${ue_index}

make and check EMC call enable with adb command
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    reattach and check network status    ue_index=${ue_index}
    Make EC call(911)    ue_index=${ue_index}    serial_number=${serial_number}    phone_number=${phone_number}
    check voice call enable    ue_index=${ue_index}

reboot and check network status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send command    command=adb -s ${serial_number} reboot    connection=cpc_${ue_index}
    Wait Until Keyword Succeeds    3x    1m    check network status    ue_index=${ue_index}
    [teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}

reattach and check network status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${gnb_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}[0]    ue_index=${ue_index}    ui_version=S21UI3.1
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=@{ue_type}[0]    ue_index=${ue_index}    gnb_index=${gnb_index}
#    power_ue.Verify attach    ue_type=@{ue_type}[0]    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}
#    ...    gnb_index=${gnb_index}    4G_check=${False}
    set airplane and check network status    ue_index=${ue_index}    status=Unknown
    set airplane and check network status    ue_index=${ue_index}
    Wait Until Keyword Succeeds    3x    1m    check network status    ue_index=${ue_index}
    [teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cpc_${ue_index}

check network status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=NR
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    csn.send command    command=adb -s ${serial_number} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}    timeout=15
    ${result} =    csn.read output    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}
    Should Contain    ${result}    ${status}
#    [teardown]    csn.disconnect      connection=cpc_${ue_index}

select ues to set airplane
    [Arguments]    ${contrain_ip1}=134    ${status}=NR
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
    ${result}=    Run Keyword And Return Status
    ...    Should Contain    ${tl.ues[${ue_index}].ssh_connection_details.addr}    ${contrain_ip1}
    Run Keyword If    ${result}==${True}    set airplane and check network status    ue_index=${ue_index}    status=${status}
    END

select ues to set airplane for 2 pc
    [Arguments]    ${status}=NR
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    FOR  ${ue_index}    IN RANGE    ${ue_num}
    set airplane and check network status    ue_index=${ue_index}    status=${status}
    END

set airplane and check network status
    [Arguments]    ${ue_index}=${0}    ${status}=NR
    ${check_status_result}=    Run Keyword And Return Status    check network status    ue_index=${ue_index}    status=${status}
    ${result}=    Run Keyword And Return Status    Get product brand    ue_index=${ue_index}
#    Run Keyword If    ${result}==${False}        set suite variable    ${abnormal_ue_status}    ue_status_abnormal
#    ...    ELSE IF    ${result}==${True}        set suite variable    ${abnormal_ue_status}    ${brand}
    Run Keyword If    ${check_status_result}==${False} and '${brand}'=='samsung' and ${result}==${True}
    ...    set airplane of samsung S21 TMO    ue_index=${ue_index}    status=${status}
    ...    ELSE IF    ${check_status_result}==${False} and '${brand}'=='lge' and ${result}==${True}
#    ...    set airplane of lge    ue_index=${ue_index}    status=${status}
    ...    sleep    0.5s
    ...    ELSE IF    ${check_status_result}==${False} and '${brand}'=='OnePlus' and ${result}==${True}
    ...    set airplane of OnePlus    ue_index=${ue_index}    status=${status}
    ...    ELSE IF    ${check_status_result}==${False} and ${result}==${False}
    ...    sleep    0.5s

set airplane of samsung S21 TMO
    [Arguments]    ${ue_index}=${0}    ${status}=NR    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    power_ue.Prepare UE    ue_type=${ue_type}[0]    ue_index=${ue_index}    ui_version=S21UI3.1
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.disconnect      connection=cpc_${ue_index}
    Connect to control pc via cygwin    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}    ue_index=${ue_index}
    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    check network status    ue_index=${ue_index}    status=${status}

set airplane of lge
    [Arguments]    ${ue_index}=${0}    ${status}=NR
    power_ue.Prepare UE    ue_type=${ue_type}[1]    ue_index=${ue_index}
    Connect to control pc via cygwin    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}    ue_index=${ue_index}
    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    check network status    ue_index=${ue_index}    status=${status}

set airplane of OnePlus
    [Arguments]    ${ue_index}=${0}    ${status}=NR
    power_ue.Prepare UE    ue_type=${ue_type}[2]    ue_index=${ue_index}
    Connect to control pc via cygwin    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}    ue_index=${ue_index}
    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    check network status    ue_index=${ue_index}    status=${status}

Adjust_HBTE_PA with VoNR
    [Arguments]    ${atten_ip}    ${t_cell}    ${s_value}    ${e_value}    ${step}    ${ho_times}    ${phone_number}=6688
    [Timeout]    10 hour
    Set Suite Variable    ${standby_ues}    ${0}
    ${s_value}    Evaluate    int(${s_value})
    ${e_value}    Evaluate    int(${e_value})
    ${step}    Evaluate    int(${step})
    ${ho_times}    Evaluate    int(${ho_times}/2)
    ${step_value}    Evaluate    int((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set    atten_ip=${atten_ip}    step=${step}    s_value=${s_value}    step_value=${step_value}
       ...    t_cell=${t_cell}    sleep=${sleep}
       check voice call enable persistence    phone_number=${phone_number}
    END
#    ${pa_status}    run keyword and return status    Change Attenuation value    cell=${t_cell}    value=${e_value}
#    run keyword if  '${pa_status}'=='False'    PA error counter set
#    Log     msg=PA set error counter all ${paerror_counter} times

Adjust_HBTE_PA with VoNR and DRX
    [Arguments]    ${t_cell}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    ...    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    [Timeout]    10 hour
    Set Suite Variable    ${standby_ues}    ${0}
    ${s_value}    Evaluate    int(${s_value})
    ${e_value}    Evaluate    int(${e_value})
    ${step}    Evaluate    int(${step})
    ${ho_times}    Evaluate    int(${ho_times}/2)
    ${step_value}    Evaluate    int((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       Start Capture Classical wiresahrk Logs    logname=${logname_VoNR_DRX}${times}.pcap    interface=any
       Make VoNR call(+6688)    ue_index=${ue_index}
       check voice call enable    ue_index=${ue_index}
       Stop and save Capture Classical wiresahrk Logs    logname=${logname_VoNR_DRX}${times}.pcap
       Start Capture Classical wiresahrk Logs    logname=${logname_VoNR_DRX}${times}${times}.pcap    interface=any
       loop for PA set    step=${step}    s_value=${s_value}    step_value=${step_value}    t_cell=${t_cell}    sleep=${sleep}
       Stop and save Capture Classical wiresahrk Logs    logname=${logname_VoNR_DRX}${times}${times}.pcap
       Start Capture Classical wiresahrk Logs    logname=${logname_VoNR_DRX}${times}${times}${times}.pcap    interface=any
       hang up VoNR for SFE    ue_index=${ue_index}
       check voice call disable    ue_index=${ue_index}
       Stop and save Capture Classical wiresahrk Logs    logname=${logname_VoNR_DRX}${times}${times}${times}.pcap
#       Check IE wireshark log for CDRX config    logname=${logname_VoNR_DRX}${times}.pcap    message_filter=${gnb_filter2}
#       ...    value1=@{value2}[0]    value2=@{value2}[1]
       Check IE wireshark log for CDRX config    logname=${logname_VoNR_DRX}${times}${times}.pcap    message_filter=${gnb_filter3}
       ...    value1=${value3}[0]    value2=${value3}[1]
       Check IE wireshark log for CDRX config    logname=${logname_VoNR_DRX}${times}${times}${times}.pcap    message_filter=${gnb_filter4}
       ...    value1=${value4}[0]    value2=${value4}[1]
       log to console    check successfull HO
       Check wireshark log for intra-F intra-gNB HO    logname=${logname_VoNR_DRX}${times}${times}.pcap    target_cellID=${cell_target_id}
#       check point with HO of IntraFreq    logname=${logname_VoNR_DRX}${times}${times}.pcap
       PA with one cell on and set value    cellid=1    set_value=${23}
    END
    ${pa_status}    run keyword and return status    Change Attenuation value    cell=${t_cell}    value=${e_value}
    run keyword if  '${pa_status}'=='False'    PA error counter set
    Log     msg=PA set error counter all ${paerror_counter} times

Adjust_HBTE_PA with EC call HO
    [Arguments]    ${t_cell}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    ...    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    [Timeout]    10 hour
    Set Suite Variable    ${standby_ues}    ${0}
    ${s_value}    Evaluate    int(${s_value})
    ${e_value}    Evaluate    int(${e_value})
    ${step}    Evaluate    int(${step})
    ${ho_times}    Evaluate    int(${ho_times}/2)
    ${step_value}    Evaluate    int((${e_value}-${s_value})/${step})
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       Wait Until Keyword Succeeds    5x    1s    hang up EC call for SFE and check status    ue_index=${ue_index}
       Prepare with PM counter time to caculate    period=start
       Start Capture Classical wiresahrk Logs    logname=${logname_EC_call}${times}.pcap    interface=any
       Make EC call(911)    ue_index=${ue_index}
       check voice call enable    ue_index=${ue_index}
       loop for PA set    step=${step}    s_value=${s_value}    step_value=${step_value}    t_cell=${t_cell}    sleep=${sleep}
       Stop and save Capture Classical wiresahrk Logs    logname=${logname_EC_call}${times}.pcap
       check voice call enable    ue_index=${ue_index}
       Check intra-F intra-gNB intra-PLMN HO with EC call ongoing    logname=${logname_EC_call}${times}.pcap
       Prepare with PM counter time to caculate    period=end
       sleep    30s
       get and check all counters for EC call HO with source and target cell
       Wait Until Keyword Succeeds    5x    1s    hang up EC call for SFE and check status    ue_index=${ue_index}
       PA with one cell on and set value    cellid=1    set_value=${23}
    END
    ${pa_status}    run keyword and return status    Change Attenuation value    cell=${t_cell}    value=${e_value}
    run keyword if  '${pa_status}'=='False'    PA error counter set
    Log     msg=PA set error counter all ${paerror_counter} times

Check intra-F intra-gNB intra-PLMN HO with EC call ongoing
    [Arguments]    ${logname}
    log to console    check successfull HO
    Check wireshark log for intra-F intra-gNB HO    logname=${logname}    target_cellID=${cell_target_id}
    log to console    check EC ongoing
    Check wireshark log for EC ongoing    logname=${logname}

Check wireshark log for intra-F intra-gNB HO
    [Arguments]    ${logname}    ${target_cellID}
    Check wireshark log for VoNR    logname=${logname}
    ...    command_template=${command_template_with_Y}
    ...    message_filter=f1ap.procedureCode == 7 and nr-rrc.measResultNeighCellListNR == 1
    ...    xpath_filter=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId    expect_value=${target_cellID}

Check wireshark log for VoNR
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_with_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}

Check wireshark log for EC ongoing
    [Arguments]    ${logname}
#    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC not release unusual    logname=${logname}

Check wireshark log for EC setup
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 46 and nas_5gs.mm.req_typ == 3
    ...    xpath_filter=nas_5gs.mm.req_typ    expect_value=3

Check wireshark log for EC 5QI 5
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.fiveQI == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 1
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.fiveQI == 1
    ...    xpath_filter=ngap.fiveQI    expect_value=1
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC not release unusual
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template_with_Y}
    ${filter_expression}=     Catenate    ngap.procedureCode == 42
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    xpath=.//ngap.UEContextReleaseRequest_element    attribute_name=showname
    should be empty    ${filtered_value}

Record counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3    Record counter action timer again
#    ${utc_left} =    Evaluate    5-${utc_min}+1
    ${utc_left} =    Evaluate    5-${utc_min}
    set test variable    ${utc_left}

Record counter action timer again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

hang up VoNR for SFE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

hang up EC call for SFE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    timeout=60
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 485 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

Check IE wireshark log for CDRX config
    [Arguments]    ${logname}    ${message_filter}    ${value1}    ${value2}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${drx_InactivityTimer}=     parser.get_field_value_by_xpath   xpath=.//nr-rrc.drx_InactivityTimer
    should be equal    ${drx_InactivityTimer[0]}    ${value1}
    ${drx_LongCycleStartOffset}=     parser.get_field_value_by_xpath   xpath=.//nr-rrc.drx_LongCycleStartOffset
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value2}

Get Cell Id common keyword
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_source_id} =    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1
    ...    abbr=physCellId    filter_param=Physical cell identifier    timeout=40
    ${cell_target_id} =    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}/NRCELL-3
    ...    abbr=physCellId    filter_param=Physical cell identifier    timeout=40
    set suite variable     ${cell_source_id}
    set suite variable     ${cell_target_id}
    [teardown]    Run Keywords    Run Keyword And Ignore Error    selenium_coam.logout    AND
                  ...    run keyword and ignore error    CI_interface.Common Case Teardown

check point with HO of IntraFreq
    [Arguments]    ${logname}    ${event_ID}=2
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}

    ${measurement_filter}    Catenate
    ...    f1ap.procedureCode == 13 and nr-rrc.physCellId == ${cell_source_id} and nr-rrc.physCellId == ${cell_target_id}
    ${measurement_packets}    parser.filter_packets_by_expression    filter_expression=${measurement_filter}
    ${target_cell}=     parser.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId
    should not be empty    ${target_cell}
    ${UeModify_req_filter}    Catenate
    ...    f1ap.procedureCode == 7  and nr-rrc.eventId == ${event_ID} and  nr-rrc.physCellId == ${cell_source_id}
    ${UeModify_req_packets}    parser.filter_packets_by_expression    filter_expression=${UeModify_req_filter}
    ${eventId}=    parser.get_field_value_by_xpath    xpath=.//nr-rrc.eventId
    should not be empty    ${eventId}
    ${UeModify_res_filter}    Catenate    f1ap.protocolIEs == 5 and nr-rrc.physCellId == ${cell_source_id}
    ${UeModify_res_packets}    parser.filter_packets_by_expression    filter_expression=${UeModify_res_filter}
    ${UeModify_res}    parser.get_field_value_by_xpath    xpath=.//f1ap.procedureCode
    should be equal    ${UeModify_res[0]}    7
    ${RRC_reconfig_filter}    Catenate    f1ap.procedureCode == 12 and nr-rrc.physCellId == ${cell_source_id}
    ${RRC_reconfig_packets}    parser.filter_packets_by_expression    filter_expression=${RRC_reconfig_filter}
    ${RRC_reconfig}    parser.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    should be equal    ${RRC_reconfig[0]}    ${cell_source_id}
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    should be equal    ${RRC_reconfig[1]}    ${cell_source_id}
#    should be equal    ${RRC_reconfig[0]}    ${cell_source_id}
    @{frame_time}=     parser.get_field_value_by_xpath    xpath=.//frame.time_epoch
    ${timestamp}=    convert_to_number    ${frame_time}[-1]
    ${RRC_re_complete_filter}    Catenate    f1ap.procedureCode == 13 and nr-rrc.rrc_TransactionIdentifier
    ${RRC_re_complete_packets}    parser.filter_packets_by_expression    filter_expression=${RRC_re_complete_filter}
    ${RRC_re_complete}    parser.get_field_value_by_xpath    xpath=.//f1ap.procedureCode
    should be equal    ${RRC_re_complete[-1]}    13
    @{frame_time_1}=     parser.get_field_value_by_xpath    xpath=.//frame.time_epoch
    ${timestamp_1}=    convert_to_number    ${frame_time_1}[-1]
    ${time_dif1} =    evaluate  float(${timestamp_1})-float(${timestamp})
    should be true    ${time_dif1} > 0
    ${Vonr_release_filter}    Catenate    ngap.procedureCode == 26 and ngap.nas == 0
    ${Vonr_release_filter_packets}    parser.filter_packets_by_expression    filter_expression=${Vonr_release_filter}
    ${Vonr_release}    parser.get_field_value_by_xpath    xpath=.//ngap.nas
    should not contain    ${Vonr_release}    0

check actual UE num and which ue is not available
    [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}
    ${id}=    Convert To String    ${tl.gnbs[0].instance_id}
    ${instance_id}=    Get Substring    ${id}    0    3
    Set Suite Variable    ${testline_instance_id}    ${instance_id}
    run keyword if    '${testline_instance_id}' == '335'    get actual ue info on TL335
    ...    ELSE IF    '${testline_instance_id}' == '375'    get actual ue info on TL375
    @{excel_ue_info}=    get_all_ue_info    file_path=${tl_scf_path}/${ue_info_excel}
    ...    file_sheet=TL${testline_instance_id}    check_name=${check_name}
    Set Suite Variable    ${excel_ue_num}    ${excel_ue_info}[1]
    Set Suite Variable    ${excel_ue_info}    ${excel_ue_info}[0]
    ${diff_ue_info}=    get_lost_ues    actual_ue_info=${actual_ue_info}    excel_ue_info=${excel_ue_info}

get actual ue info on TL335
   [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}
    Set Suite Variable    ${control_pc_ip1}    ${tl.ues[0].ssh_connection_details.addr}
    Set Suite Variable    ${control_pc_ip2}    ${tl.ues[30].ssh_connection_details.addr}
    @{ue_info}=    Wait Until Keyword Succeeds    3x    2m
    ...    get_available_ue_sn    control_pc_ip=${control_pc_ip1}    username=${username}    password=${password}
    @{ue_info2}=    Wait Until Keyword Succeeds    3x    2m
    ...    get_available_ue_sn    control_pc_ip=${control_pc_ip2}    username=${username}    password=${password}
    ${actual_ue_num}=    Evaluate    ${ue_info}[1] + ${ue_info2}[1]
    ${actual_ue_info}=    Evaluate    ${ue_info}[0] + ${ue_info2}[0]
    Set Suite Variable    ${actual_ue_num}
    Set Suite Variable    ${actual_ue_info}

get actual ue info on TL375
    [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}
    Set Suite Variable    ${control_pc_ip1}    ${tl.ues[0].ssh_connection_details.addr}
    @{ue_info}=    get_available_ue_sn    control_pc_ip=${control_pc_ip1}    username=${username}    password=${password}
    Set Suite Variable    ${actual_ue_num}    ${ue_info}[1]
    Set Suite Variable    ${actual_ue_info}    ${ue_info}[0]

check actual UE num on VoNR of multi ues
    [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}
    get actual ues info on second pc of TL335

get actual ues info on second pc of TL335
   [Arguments]    ${username}=${control_pc_username}    ${password}=${control_pc_password}
    Set Suite Variable    ${control_pc_ip2}    ${tl.ues[30].ssh_connection_details.addr}
    @{ue_info}=    get_available_ue_sn    control_pc_ip=${control_pc_ip2}    username=${username}    password=${password}
    ${actual_ue_num}=    Evaluate    ${ue_info}[1]
#    ${actual_ue_info}=    Evaluate    @{ue_info}[0]
    Set Suite Variable    ${actual_ue_num}
#    Set Suite Variable    ${actual_ue_info}

change AMF status
    [Arguments]    ${para}=${AMF_STATUS_UNLOCKED}    ${para2}=${AMF_STATUS_UNLOCKED_GNB2}
    Online modify parmeters    parameters_to_update=${para}
    run keyword if    '${enb_instance}'!='${enb_id}[0]'
    ...    Online modify parmeters    parameters_to_update=${para2}    gnb_index=${1}

change a3OffsetSsbRsrp value
    [Arguments]    ${para}=${a3OffsetSsbRsrp_value}    ${para2}=${a3OffsetSsbRsrp_value_GNB2}
    Online modify parmeters    parameters_to_update=${para}
    Online modify parmeters    parameters_to_update=${para2}    gnb_index=${1}

check amf status
    [Arguments]    ${gnb_index}=${0}    ${status}=Unlocked
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    @{MOs_SERVEDAMF_a}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=GNB_OAM
    &{dict_administrativeState}     coam.get_parameters    dist_name=${MOs_SERVEDAMF_a[0]['distName']}
    ...    pattern=administrativeState    connection=GNB_OAM
    sleep    5
    Set Suite Variable    ${AMF_state}    ${dict_administrativeState['administrativeState']}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Block GSM cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.block_all_cells    rat=GSM    timeout=180    connection=GNB_OAM
    sleep    5
    [Teardown]  COAM Teardown gnb connections

Block NR cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.block_all_cells    rat=NR    timeout=180    connection=GNB_OAM
    sleep    5
    [Teardown]  COAM Teardown gnb connections

Unblock NR cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.unblock_all_cells    rat=NR    timeout=180    connection=GNB_OAM
    sleep    5
    [Teardown]  COAM Teardown gnb connections

Unblock GSM cell
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.unblock_all_cells    rat=GSM    timeout=180    connection=GNB_OAM
    sleep    5
    [Teardown]  COAM Teardown gnb connections

check and prepare the gnb commission for SFE two testline
    run keyword if    '${suite_type}' == '${types}[0]'    Check if need to import NSA SCF file
    ...    ELSE IF    '${suite_type}' == '${types}[1]'    Check if need to import SA SCF file

Check if need to import NSA SCF file
    run keyword if    '${Import_NSA_SCF}' == '${action}'    Prepare the gnb commission for SFE two testline    cell_type=${types}[0]
    ...    ELSE    change AMF status    para=${AMF_STATUS_LOCKED}    para2=${AMF_STATUS_LOCKED_GNB2}

Check if need to import SA SCF file
    run keyword if    '${Import_SA_SCF}' == '${action}'    Prepare the gnb commission for SFE two testline    cell_type=${types}[1]
    ...    ELSE    change AMF status

check SA or NSA suite name
    ${suite_name}=    set variable    SuiteName: ${SUITE NAME}
    @{type}    String.split string    string=${suite_name}    separator=
    Set Suite Variable    ${suite_type}    ${type}[1]

check SA or NSA case name
    ${case_name}=    set variable    TestName: ${TEST_NAME}
    @{type}    String.split string    string=${case_name}    separator=_
    Set Suite Variable    ${case_type}    ${type}[4]

get CIENV folder name
    ${ci_env_name}=    get_ci_env_name    ute_ip=${ute_ip}    username=${ute_username}    password=${ute_password}
    Set Suite Variable    ${tl_ci_name}    ${ci_env_name}

check hanging resource
#    operate_all_cell_of_bts_threading    action=block
#    modify cellBarred state of all gnb cell on testline    barred_status=barred
    get CIENV folder name
    start_hanging_resource_file    ip=${ute_ip}    username=${ute_username}    password=${ute_password}
    ...    tl_cienv_name=${tl_ci_name}    file_name=${hanging_resource_file}[0]
#    start_hanging_resource_file    ip=${ute_ip}    username=${ute_username}    password=${ute_password}
#    ...    tl_cienv_name=${tl_ci_name}    file_name=@{hanging_resource_file}[1]
#    [Teardown]    modify cellBarred state of all gnb cell on testline    barred_status=notBarred
    #operate_all_cell_of_bts_threading    action=unblock

Keywords for PA
    Comment    Keywords for PA

PA preparation
    [Arguments]    ${cell_type}=SA
    FOR  ${index}    ${pa_name}  IN ENUMERATE   @{all_cell_pa_name}
        Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${all_cell_pa_initial_values}[${index}]
        Run Keyword If    '${cell_type}'=='NSA'    Set SFE attenuation value    att_ipaddr=${enb1_cell221_pa_info}[pa_ip]
        ...    att_ports=${enb1_cell221_pa_info}[pa_ports]    values=${enb1_cell221_pa_value}[min]
    END

PA recover
    FOR  ${index}    ${pa_name}  IN ENUMERATE   @{all_cell_pa_name}
        Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${all_cell_pa_max_values}[${index}]
    END

set PA port on one cell
    [Arguments]    ${pa_name}=${gnb1_cell1_pa_info}    ${value}=${gnb1_cell1_pa_value}[setup][0]
    Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${value}

set all PA ports and one cell set designated value
    [Arguments]    ${pa_name}=${gnb1_cell1_pa_info}    ${value}=${gnb1_cell1_pa_value}[setup][0]    ${cell_type}=SA
    Set SFE attenuation value    att_ipaddr=${pa_name}[pa_ip]    att_ports=${pa_name}[pa_ports]    values=${value}
    FOR  ${index}    ${pa_names}  IN ENUMERATE   @{all_cell_pa_name}
        Run Keyword If    ${pa_names}!=${pa_name}    Set SFE attenuation value
        ...    att_ipaddr=${pa_names}[pa_ip]    att_ports=${pa_names}[pa_ports]    values=${all_cell_pa_max_values}[${index}]
    END
    Run Keyword If    '${celltype}'=='NSA'    Set SFE attenuation value    att_ipaddr=${enb1_cell11_pa_info}[pa_ip]
        ...    att_ports=${enb1_cell11_pa_info}[pa_ports]    values=${enb1_cell11_pa_value}[min]

Set SFE attenuation value
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    model=${model}
        ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
#        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END
Adjust_HBTE_PA with loop
    [Arguments]    ${pa_name}    ${s_value}    ${e_value}    ${step}    ${ho_times}
    ${length_s_value}=    get length    ${s_value}
#    Set Test Variable    ${initial_s_value}    ${s_value}
#    Set Suite Variable    ${initial_s_value}    ${s_value}
    ${initial_s_value}=    Copy List    ${s_value}
	Set Test Variable    ${initial_s_value}
    ${unequal_port}    Create List
    FOR    ${port}    IN RANGE    ${length_s_value}
        Run Keyword If    ${s_value}[${port}] != ${e_value}[${port}]    Append To List    ${unequal_port}    ${port}
    END
    Set Test Variable    ${need_change_port_index}    ${unequal_port}[0]
    ${step}    Evaluate    float(${step})
    ${ho_times}    Evaluate    float(${ho_times}/2)
    ${step_value}    Evaluate    float((${e_value}[${need_change_port_index}]-${s_value}[${need_change_port_index}])/${step})
    ${s_value}    Evaluate    float(${s_value}[${need_change_port_index}])
    ${e_value}    Evaluate    float(${e_value}[${need_change_port_index}])
    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
    FOR  ${times}    IN RANGE    ${ho_times}
       loop for PA set value    pa_name=${pa_name}    s_value=${s_value}    step=${step}
       ...    step_value=${step_value}    sleep=${sleep}    port_num=${length_s_value}    initial_s_value=${initial_s_value}
       ...    unequal_port=${unequal_port}
    END

loop for PA set value
    [Arguments]    ${pa_name}    ${s_value}    ${step}     ${step_value}     ${sleep}    ${port_num}    ${initial_s_value}
    ...    ${unequal_port}
    FOR  ${index}    IN RANGE    -${step}    ${step}    1
         ${index} =    evaluate    abs(${index})
         ${pa_value} =    evaluate    int(${s_value}+${step_value}*${index})
         change initial s value    unequal_port=${unequal_port}    pa_value=${pa_value}
#         ${pa_value}    Create List    ${pa_value}
#         ${pa_value} =    evaluate    ${pa_value}*${port_num}
         ${pa_status}    run keyword and return status    set PA port on one cell     pa_name=${pa_name}    value=${initial_s_value}
         run keyword if  '${pa_status}'=='False'    PA error counter set
         sleep    ${sleep}s
    END
change initial s value
    [Arguments]    ${unequal_port}    ${pa_value}
    FOR    ${p}    IN    @{unequal_port}
         Set List Value    ${initial_s_value}    ${p}    ${pa_value}
    END
#Adjust_HBTE_PA with loop
#    [Arguments]    ${pa_name}    ${s_value}    ${e_value}    ${step}    ${ho_times}
#    [Timeout]    10 hour
#    ${length_s_value}=    get length    ${s_value}
#    ${s_value}    Evaluate    float(${s_value}[0])
#    ${e_value}    Evaluate    float(${e_value}[0])
#    ${step}    Evaluate    float(${step})
#    ${ho_times}    Evaluate    float(${ho_times}/2)
#    ${step_value}    Evaluate    float((${e_value}-${s_value})/${step})
#    ${sleep}    Evaluate    round((${interval}-${step}*${pa_settime})/${step},1)
#    FOR  ${times}    IN RANGE    ${ho_times}
#       loop for PA set value    pa_name=${pa_name}    s_value=${s_value}    step=${step}
#       ...    step_value=${step_value}    sleep=${sleep}    port_num=${length_s_value}
#    END
#
#loop for PA set value
#    [Arguments]    ${pa_name}    ${s_value}    ${step}     ${step_value}     ${sleep}    ${port_num}
#    FOR  ${index}    IN RANGE    -${step}    ${step}    1
#         ${index} =    evaluate    abs(${index})
#         ${pa_value} =    evaluate    int(${s_value}+${step_value}*${index})
#         ${pa_value}    Create List    ${pa_value}
#         ${pa_value} =    evaluate    ${pa_value}*${port_num}
#         ${pa_status}    run keyword and return status    set PA port on one cell     pa_name=${pa_name}    value=${pa_value}
#         run keyword if  '${pa_status}'=='False'    PA error counter set
#         sleep    ${sleep}s
#    END

Benchamrk ues network set
    [Arguments]    ${cell_type}=NSA    ${ue_number}=all
    ${ue_num}    get length    ${tl.ues}
    set suite variable    ${ue_num}
    Check all online UE network status and recover    ue_num=${ue_num}    cell_type=${cell_type}    ue_number=${ue_number}

Prepare the gnb commission for SFE GNB1
    [Arguments]  ${SCF_name}    ${cell_type}=NSA    ${timeout}=600
    Prepare the gnb1 scf commission    gnb_id=1    cell_type=${cell_type}    timeout=${timeout}    SCF_name=${SCF_name}
    sleep    5min
    Coam with check the gnb cell status onair    gnb_id=1
    run keyword if    '${cell_type}'=='NSA'    Check all enb x2link status avaliable

Prepare the gnb1 scf commission
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA    ${timeout}=600
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_id}-1].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${Active_SW_version}    Get Active SW Version    timeout=30
    set suite variable      ${Active_SW_version}
    ${char}    run keyword and return status     Should contain    ${Active_SW_version}    .
    Run Keyword If    '${char}' == 'True'    Get GNB1 SCF path and perform define commission    gnb_id=${gnb_id}
    ...    cell_type=${cell_type}    SCF_name=${SCF_name}
    Run Keyword If    '${char}' == 'False'    Get GNB1 SCF path and perform define commission with SBTS    gnb_id=${gnb_id}
    ...    cell_type=${cell_type}    timeout=${timeout}    SCF_name=${SCF_name}

Get GNB1 SCF path and perform define commission
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA
    Get GNB1 SCF path    gnb_id=${gnb_id}    cell_type=${cell_type}    SCF_name=${SCF_name}
    Perform define commission for COAM gnb    scf_path=${Golden_SCF_Path}    gnb_id=${gnb_id}

Get GNB1 SCF path
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA
    ${Golden_SCF_Path}    Get Golden local GNB1 SCF Path    gnb_id=${gnb_id}    cell_type=${cell_type}    SCF_name=${SCF_name}
    set suite variable      ${Golden_SCF_Path}

Get Golden local GNB1 SCF Path
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA
    @{rest}    String.split string    string=${Active_SW_version}    separator=.
    ${GOLDEN_FULL_SCF}   Set Variable    ${tl_scf_path}/${rest}[0].${rest}[1]/${SCF_name}
    set suite variable    ${control_para_file_path}   ${tl_scf_path}/${rest}[0].${rest}[1]/TA_para_control.txt
    [Return]   ${GOLDEN_FULL_SCF}

Get GNB1 SCF path and perform define commission with SBTS
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA    ${timeout}=600
    Get GNB1 SCF path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}    SCF_name=${SCF_name}
    Perform define commission for COAM gnb    scf_path=${Golden_SCF_Path}    gnb_id=${gnb_id}    timeout=${timeout}

Get GNB1 SCF path with SBTS
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA
    ${Golden_SCF_Path}    Get GNB1 Golden local SCF Path with SBTS    gnb_id=${gnb_id}    cell_type=${cell_type}    SCF_name=${SCF_name}
    set suite variable      ${Golden_SCF_Path}

Get GNB1 Golden local SCF Path with SBTS
    [Arguments]  ${SCF_name}    ${gnb_id}=1    ${cell_type}=NSA
    @{rest}    String.split string    string=${Active_SW_version}    separator=_
    ${GOLDEN_FULL_SCF}   Set Variable    ${tl_scf_path}/${rest}[0]/${SCF_name}
    set suite variable    ${control_para_file_path}   ${tl_scf_path}/${rest}[0]/TA_para_control.txt
    [Return]   ${GOLDEN_FULL_SCF}

Start brust DL UDP traffic
    [Arguments]    ${path}    ${file_name}    ${tl_id}    ${shell_file_name}    ${cpc_ip}=${ute_ip}    ${alias}=alias
    ...    ${cpc_usrname}=${ute_username}   ${cpc_passwd}=${ute_password}
    Connect to cpc   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    ${alias}
    csn.send command
    ...    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;python ${path}${file_name} ${shell_file_name}
    ...    connection=${alias}
    [Teardown]    Csn.disconnect    connection=${alias}

Stop brust DL UDP traffic
    [Arguments]    ${tl_id}    ${sh_file_name}    ${cpc_ip}=${ute_ip}    ${alias}=alias
    ...    ${cpc_usrname}=${ute_username}   ${cpc_passwd}=${ute_password}
    Connect to cpc   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
    csn.send command
    ...    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;ps -ef |grep ${sh_file_name} |awk '{print $2}'|xargs kill -9
    ...    connection=${alias}
    [Teardown]    Csn.disconnect    connection=${alias}

Stop DL ping
    [Arguments]    ${tl_id}    ${cpc_ip}=${ute_ip}    ${alias}=alias
    ...    ${cpc_usrname}=${ute_username}   ${cpc_passwd}=${ute_password}
    Connect to cpc   ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}
    csn.send command
    ...    command=source CIENV/7_5_UTE5G402T${tl_id}/bin/activate;ps -ef |grep ping |awk '{print $2}'|xargs kill -9
    ...    connection=${alias}
    [Teardown]    Csn.disconnect    connection=${alias}

Teardown for case failure
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    connection=GNB_OAM    gnb_index=0
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown    connection=GNB_OAM1    gnb_index=1
