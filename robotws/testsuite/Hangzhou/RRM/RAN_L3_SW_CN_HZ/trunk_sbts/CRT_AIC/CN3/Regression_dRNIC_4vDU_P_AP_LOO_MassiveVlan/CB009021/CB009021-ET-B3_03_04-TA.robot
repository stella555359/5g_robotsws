*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env Aic 4DU
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic
Force Tags    QCD_MN_RAN    QCP_RAN_ET    vDUCNF00    RAN_Aic    RAN_5G    CRT    team-CN3ET    owner-carol.an
...    CLOUD_5GC_dRNIC_4vDU_P_AP_LOO_DC_MassiveVlan    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_4CPIF_HA    release-SBTS24R2
Resource    ../../../../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/4du/8cells_du1_2T_du2_2T_du3_2T_du4_2T_4cpif_ransharing
${MULTI_CPIF_FLAG}    True
${RANSHARING_FLAG}    True
${REDUNDANT_MODE_CU_FLAG}    True
${SOS_REPORT_FLAG}    pass:False,fail:False
@{FAULTS_EXCLUDED_CHECKING}    7300    7107    4405
@{PARAMS_IN_SCF_CU}    @{parameterscu}
@{PARAMS_IN_SCF_DU1}    @{DU_CELL1}
@{PARAMS_IN_SCF_DU2}    @{DU_CELL2}
@{PARAMS_IN_SCF_DU3}    @{DU_CELL3}
@{PARAMS_IN_SCF_DU4}    @{DU_CELL4}
@{parameterscu}
...    NRBTS:actX2ConfigTransfer=true
...    NRBTS:maxNumX2Links=128
...    NRBTS:actEnhancedX2LinkSupervision=true
...    NRBTS:x2LinkSupervisionTmr=1
...    NRBTS:x2LinkReestabTmr=1
...    delete:MRBTS-1/NRBTS-1/SERVEDAMF-2
...    delete:MRBTS-1/NRBTS-1/SERVEDAMF-3
...    delete:MRBTS-1/NRBTS-1/SERVEDAMF-4
...    delete:MRBTS-1/NRBTS-1/SERVEDAMF-5
...    delete:MRBTS-1/NRBTS-1/SERVEDAMF-6

@{DU_CELL1}
...    NRDU-1:remotef1CplaneIpAddr=172.16.1.101
...    MRBTS-1/NRBTS-1/NRCELL-1:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{DU_CELL2}
...    NRDU-2:remotef1CplaneIpAddr=172.16.1.102
...    MRBTS-1/NRBTS-1/NRCELL-2:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{DU_CELL3}
...    NRDU-3:remotef1CplaneIpAddr=172.16.1.103
...    MRBTS-1/NRBTS-1/NRCELL-3:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{DU_CELL4}
...    NRDU-4:remotef1CplaneIpAddr=172.16.1.104
...    MRBTS-1/NRBTS-1/NRCELL-4:actFlexGapOffset=SR_and_DRX_and_CSIRS

@{output}
...    sgnb_ue_x2ap_id IE will not be included
...    Successfully reconfigured dual connectivity
...    UE-X2AP-ID : 955

${x2LinkSupervisionTmr}    60s
${cpif0MME1IP}    10.0.1.10
${cpif1MME2IP}    10.1.1.11
${cpif2MME3IP}    10.2.1.12
${cpif3MME4IP}    10.3.1.13

*** Test Cases ***
CB009021-CR-BB-B3_ET_03_RAN sharing with dedicated mode in multi-CPIF scenario for NSA UE
    [Tags]
    Set 4 x2link up for ransharing
    ${ue32_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=32    target_gnbCell=1     enb_id=1
    ${ue33_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=33    target_gnbCell=2     enb_id=105
    ${ue34_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=34    target_gnbCell=3     enb_id=110
    ${ue35_sgNB_X2APID}    Attach And Set ENDC For UE and Return X2APID    ue_id=35    target_gnbCell=4     enb_id=115
    Set Test Variable    ${ue32_sgNB_X2APID}    ${ue32_sgNB_X2APID}
    Set Test Variable    ${ue33_sgNB_X2APID}    ${ue33_sgNB_X2APID}
    Set Test Variable    ${ue34_sgNB_X2APID}    ${ue34_sgNB_X2APID}
    Set Test Variable    ${ue35_sgNB_X2APID}    ${ue35_sgNB_X2APID}
    Check WireShark multi-CPIF
    [Teardown]    caseb03_teardown

CB009021-CR-BB-B3_ET_04_X2 IP address shall be provided according to load balance in ENDC Configuration Transfer message
    [Tags]
    [Documentation]    x2 link down, the cpif load shall be cleaN
    Set simenb1 x2link up for ransharing
    Send X2 Enb Configuration Transfer CPIF resource ip X2 setup    eNBId=105    plmnid=312:489    outputIP=${cpif1MME2IP}
    Send X2 Enb Configuration Transfer CPIF resource ip X2 setup    eNBId=110    plmnid=313:489    outputIP=${cpif2MME3IP}
    Send X2 Enb Configuration Transfer CPIF resource ip X2 setup    eNBId=115    plmnid=314:489    outputIP=${cpif3MME4IP}
    duplicate x2 setup and drop x2 at CPIF0
    receive resource CPIF0 ip for X2 setup
    [Teardown]    caseb04_teardown

*** Keywords ***
Check WireShark multi-CPIF
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB3-03${/}a2a32.ini    wait_string=rrcReconfigurationComplete
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB3-03${/}a2a33.ini    wait_string=rrcReconfigurationComplete    pod_name_cu=cpifa1
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB3-03${/}a2a34.ini    wait_string=rrcReconfigurationComplete    pod_name_cu=cpifa2
    Check WireShark Log Aic    a2a_ini_file=${CURDIR}${/}A2A_BB3-03${/}a2a35.ini    wait_string=rrcReconfigurationComplete    pod_name_cu=cpifa3

Set simenb1 x2link up for ransharing
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=${cpif0MME1IP}    pass_regexp=is up    timeout=120
    sleep    2s    wait for cell setup.

Send X2 Enb Configuration Transfer CPIF resource ip X2 setup
    [Arguments]    ${eNBId}=100    ${plmnid}=311:489    ${outputIP}=10.0.1.11
    ${endcSon_transf}    catenate    enb_trigger_endc_son_configuration_transfer eNBId=1 source_enb_plmnid=${plmnid} source_enb_tac=222
    ...    en_gnbid=2 source_enbId=0x00120 target_gnb_tac=280
    ${output}    Execute Egate Command    ${endcSon_transf}    pass_regexp=eNBX2TransportLayerAddresses    timeout=30
    ${ip_address1}    Get_ENDC_Transfer_IPs    ${output}
    Should Be True    '${ip_address1}' =='${outputIP}'
    Execute Egate Command    enb_x2_link_up enb=${eNBId} target=2 x2_link_addr=${ip_address1}    pass_regexp=is up    timeout=35

duplicate x2 setup and drop x2 at CPIF0
    Execute Egate Command    enb_x2_link_up enb=102 target=2 duplicate_x2_setup_error=true x2_link_addr=${cpif0MME1IP}    pass_regexp=is up
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2    pass_regexp=dropped by command
    Execute Egate Command    link_drop link=x2 by=enb:102 to=gnb:2    pass_regexp=dropped by command
    sleep    2min    wait for moc released.
    Object Should Not Exist in CU    LTEENB-0:x2LinkLock=unlocked

receive resource CPIF0 ip for X2 setup
    ${endcSon_transf}    catenate    enb_trigger_endc_son_configuration_transfer eNBId=105 source_enb_plmnid=312:489 source_enb_tac=222
    ...    en_gnbid=2 source_enbId=0x00120 target_gnb_tac=280
    ${output}    Execute Egate Command    ${endcSon_transf}    pass_regexp=eNBX2TransportLayerAddresses    timeout=10
    log    the eNBX2TransportLayerAddresses value should follow the loadbalance roles: cpif1's address: xx.xx.xx.10
    ${ip_address5}    Get_ENDC_Transfer_IPs    ${output}
    Should Be True    '${ip_address5}' =='10.1.1.10'

caseb03_teardown
    Release Ues    ue_type=all
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2    pass_regexp=dropped by command
    Execute Egate Command    link_drop link=x2 by=enb:105 to=gnb:2    pass_regexp=dropped by command
    Execute Egate Command    link_drop link=x2 by=enb:110 to=gnb:2    pass_regexp=dropped by command
    Execute Egate Command    link_drop link=x2 by=enb:115 to=gnb:2    pass_regexp=dropped by command
    sleep    ${x2LinkSupervisionTmr}
    Cell alarm due to associated X2 links unavailability
    Common Test Teardown And Stop Capture Logs Aic

caseb04_teardown
    Execute Egate Command    link_drop link=x2 by=enb:1 to=gnb:2    pass_regexp=ENB-1
    Execute Egate Command    link_drop link=x2 by=enb:105 to=gnb:2    pass_regexp=dropped by command
    Execute Egate Command    link_drop link=x2 by=enb:110 to=gnb:2    pass_regexp=dropped by command
    Execute Egate Command    link_drop link=x2 by=enb:115 to=gnb:2    pass_regexp=dropped by command
    sleep    ${x2LinkSupervisionTmr}
    Cell alarm due to associated X2 links unavailability
    Common Test Teardown And Stop Capture Logs Aic

Cell alarm due to associated X2 links unavailability
    ${fault7107}    Create List
    ...    fault_id=7107    alarming_object=MRBTS-1/NRBTS-1/NRCELL-1
    ...    fault_name=Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    ...    fault_id=7107    alarming_object=MRBTS-1/NRBTS-1/NRCELL-2
    ...    fault_id=7107    alarming_object=MRBTS-1/NRBTS-1/NRCELL-3
    ...    fault_id=7107    alarming_object=MRBTS-1/NRBTS-1/NRCELL-4
    Fm Fault Should Be Raised Cu    ${fault7107}

Modify Cfg Aic
    Update Cfg Aic    gnb_param id=3 xn_listening_socket=1 send_xn_setup=off measEvent=A3 sib1_period=3000
    ${multiple_cpif}    catenate    set_gnb id=2 xn=10.0.12.10,10.0.12.11,10.0.12.12,10.0.12.13
    ...    ng=10.0.11.10,10.0.11.11,10.0.11.12,10.0.11.13 amf=1-4
    ...    x2=${cpif0MME1IP},${cpif1MME2IP},${cpif2MME3IP},${cpif3MME4IP},10.0.1.11,10.0.1.12
    update cfg param aic    ${multiple_cpif}
    update cfg param aic    set_ue simulated id=32 imsi=311:489:21645548
    update cfg param aic    set_ue simulated id=33 imsi=312:489:21645558
    update cfg param aic    set_ue simulated id=34 imsi=313:489:21645563
    update cfg param aic    set_ue simulated id=35 imsi=314:489:21645567

Get_ENDC_Transfer_IPs
    [Arguments]    ${output}
    [Return]    ${ip_address}
    ${pattern}    set variable    '([0-9A-F ]+)'B
    ${matches}    Get Regexp Matches    ${output}    ${pattern}
    Run Keyword If    ${matches}    Log    ${matches[-1]}    ELSE    Log    No match found.
    ${ip_address}    Convert Hex String to IP Address    ${matches[-1]}

Convert Hex String to IP Address
    [Arguments]    ${hex_string}
    [Return]    ${ip_address}
    ${ip_address}    Evaluate    '.'.join(str(int(byte, 2)) for byte in ${hex_string.strip("'B").split()})

Attach And Set ENDC For UE and Return X2APID
    [Arguments]    ${ue_id}    ${target_gnbCell}    ${enb_id}
    [Return]    ${sgNB_x2apIDList[0]}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=1
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE
    ${command}    Set Variable    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_gnbCell} bearer=2 type=split_scg
    ${output}    Execute Egate Command    ${command}    pass_regexp=reported successful RA
    ${sgNB_x2apIDList}    Get Regexp Matches    ${output}    value SgNB-UE-X2AP-ID : (\\d+)    1

Set 4 x2link up for ransharing
    Execute Egate Command    enb_x2_link_up enb=1 target=2 x2_link_addr=${cpif0MME1IP}    pass_regexp=is up    timeout=120
    Execute Egate Command    enb_x2_link_up enb=105 target=2 x2_link_addr=${cpif1MME2IP}    pass_regexp=is up    timeout=120
    Execute Egate Command    enb_x2_link_up enb=110 target=2 x2_link_addr=${cpif2MME3IP}    pass_regexp=is up    timeout=120
    Execute Egate Command    enb_x2_link_up enb=115 target=2 x2_link_addr=${cpif3MME4IP}    pass_regexp=is up    timeout=120

Perform Steps After Onair
    Add Required Message Log

Add Required Message Log
    Execute Egate Command    sim_trace uec=1 protocol=nr_rrc on
    Execute Egate Command    sim_trace uec=1 protocol=rrc on
    Execute Egate Command    sim_trace uec=1 protocol=x2 on
    Execute Egate Command    sim_trace amf=1 protocol=ng on
    Execute Egate Command    sim_trace amf=2 protocol=ng on
    Execute Egate Command    sim_trace amf=3 protocol=ng on
    Execute Egate Command    sim_trace amf=4 protocol=ng on
    Execute Egate Command    sim_trace amf=5 protocol=ng on
    Execute Egate Command    sim_trace amf=6 protocol=ng on
    Execute Egate Command    sim_trace amf=20 protocol=ng on
    Execute Egate Command    sim_trace enb=1 protocol=x2 on
    Execute Egate Command    sim_trace enb=100 protocol=x2 on
    Execute Egate Command    sim_trace enb=101 protocol=x2 on
    Execute Egate Command    sim_trace enb=102 protocol=x2 on
    Execute Egate Command    sim_trace enb=105 protocol=x2 on
    Execute Egate Command    sim_trace enb=110 protocol=x2 on
    Execute Egate Command    sim_trace enb=115 protocol=x2 on
    Execute Egate Command    sim_trace enb=120 protocol=x2 on
    Execute Egate Command    sim_trace enb=3 protocol=xn on
    Execute Egate Command    sim_trace enb=4 protocol=xn on
    Execute Egate Command    sim_trace enb=5 protocol=xn on