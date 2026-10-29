*** Settings ***
Documentation    :copyright: Nokia
...        This test case describes the behaviour of Nokia gNB in SA mode 
...         during Xn based handover of a SA call with active UP IP in
...         downlink direction with IP IP Indication as Preferred.

Variables    ta5g_global_var

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Library             taf.wts.runner              WITH NAME    wtsrunner
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/Airphone.robot
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Library             ../resources/python/IphyUpdate.py
Library             ./python/execute_command.py
Resource                ./basic_resource.robot

Suite Setup             Run keywords     Test Suite Setup
...                     AND              AIC Software Build Info
...                     AND              Fetch Taf Library used in TL
...                     AND              OperatingSystem.Run     sudo ip addr add 10.0.11.100/24 dev eth7
...                     AND              OperatingSystem.Run     sudo ip addr add 10.0.12.100/24 dev eth8
...                 AND           Fast Delta Commission vCU Using Delta XML File     ${delta_cu}
...                 AND           sleep    300s
...                 AND           Log to console    vdU delta commissioning
...                 AND           Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                 AND           Log to console    cOMMISSION DONE
...                 AND           sleep    700s
...                     AND              Run keyword and Ignore error   Verify RMODs Online Status   ${800}
...                     AND              log to console   loading cfg file 
...                     AND              Configure UTE ETH3 IPs
...                     AND              Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown         Run keywords        Kill WTS processes Using WTS_Runner


*** Variables ***
${VCU_SCF_PATH}             ${CURDIR}/config/SCF/CB008116_23_cu_full.xml
${VDU_SCF_PATH}             ${CURDIR}/config/SCF/CB008116_23_du_full.xml
${delta_vdu}                ${CURDIR}/config/SBTS24R2/vdu_new_xnho.xml
${delta_cu}                 ${CURDIR}/config/SBTS24R2/vcu_new_xnho.xml
${wts_cfg_file}     ${CURDIR}/config/wts/new_basic_setup_23.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof3}    ${2}=${ip_prof2}

&{ip_ie}    ${1}=required      ${2}=preferred
&{max_ip_rate}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=not-performed

${st_ue_id}      ${1}
${en_ue_id}      ${1}

&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1           5
@{QOS_Prof1_speed_ul}       2           6
@{QOS_Prof1_speed_dl}       2           6
@{QOS_Prof1_unit}           mbps        mbps

#${UE_ID}        1
#${nwslice_ID}   1
#${gw_ID}     1
#${Pdu_session_ID}       1
#${QFI_ID}    1
#${TRF_ID}    1
#${Q_O_ADD}      1
#${RTP_COD}      1
#${epc_log_path}    /tmp/
#${st_ue_id}      ${1}
#${en_ue_id}      ${3}
#${st_ue_id_1}    ${3}
#${en_ue_id_1}    ${3}

*** Test Cases ***
[1]CB008116_A_23_US5_XnHO-withUPIP_SgNB-Req-ZUC-64Kbps_TgNB-Req-ZUC-maxUERate_5QI6-3_DL_TDD_LN

    [setup]  Testcase Setup
    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}
    Increase Buffer Size for VM and IPHY
    X2AP Link Should be UP
    ue location change
    Sleep   20
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}              ${2}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}     ${2}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}     ${2}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}         ${2}=${QOS_Prof1_unit}
    Start Syslog Monitoring
    ${ue_to_bearer_list}=   Run Keyword and Continue on Failure   MultiUE Register should be Successful Custom      
    ...         ${st_ue_id}    ${en_ue_id}   pdu_session_setup
    ...     ${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1  ho=${1}

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1    gfbr_mfbr_profile=${gfbr_mfbr_profile}
    ...    ue_to_bearer_list=${ue_to_bearer_list[1]}  ho=${1}
    ${duration}      Set Variable    500
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}  ${qos_profile_speed_ul}
    ...     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${60}s

    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=6   pdu_id=1   qfi_id=2
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=6   pdu_id=1   qfi_id=2

    Establish Xn Link To UPIP gNB3

    Enable Max integrity dat rate       path_switch    ${ip_ie[${st_ue_id}]}    ${ip_ie[${st_ue_id}]}
    
    Start CPRT F1 Monitoring
    HO SA A3 UE measurements
    Stop and Collect CPRT F1 Monitoring

    sleep   ${180}s
    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=6   pdu_id=1   qfi_id=2
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=6   pdu_id=1   qfi_id=2
    Stop and Collect Syslog Monitoring
    Check Integrity failure count Aic
    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id} 
    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${LOG_PATH}

*** Keywords ***
Make MultiUE 5qi1 call with varying cqi and collect ttitrace
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}
    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    1  1   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  1   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    2  2   Traffic_rate=mbps     dl_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    2  2   Traffic_rate=mbps     ul_rate=10        pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    3  3   Traffic_rate=mbps     dl_rate=130       pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    3  3   Traffic_rate=mbps     ul_rate=25        pdu_id=1     trf_id=1     qfi_id=1
    Sleep   30
    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    sleep    300s
    8955_new_resources.Collect PM Counters
    Run Keyword And Ignore Error    Get 8955 counters and validate  M55308C10008  M55308C00019
    sleep   10s
    Wait until the current Measurement Period stops  additional_time=${0}

Verify egate and TTI trace
#    Run Keyword And Continue on Failure   Get L2stream logs using cOAM cli from vDU   #kw will provide by next FB 
    set test variable      ${crnti_list}
    sleep  10s       reason=Wait for traffic to start
    ${numofLayer}    Create List     RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1    RANK1
    Log To Console    \nStartingTTICapture
    Log To Console    \nDoneTTICapture


Configure UTE ETH3 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.3/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.4/24 dev eth3

Establish Xn Link To UPIP gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true     ciphering_disabled=6:false,3:false
    ...     integrityProtection_enabled=6:true,3:true     ciphering_algorithm=nea3     integrityprotection_algorithm=nia3
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}
