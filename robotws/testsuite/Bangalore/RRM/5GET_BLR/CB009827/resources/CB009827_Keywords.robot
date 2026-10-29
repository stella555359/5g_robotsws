*** Settings ***
Documentation    :copyright: Nokia
...              :authors: Sruthi/Nagesh
...              :contact: sruthi.jacob@nokia.com/nagesh.k_v@nokia.com
Variables      ta5g_global_var
Resource       taf/rfrl/common_resources/robot/libraries_instances.robot
Resource       ../../CB007113/resources/CB007113_Keyword.robot
Resource       ../../resources/robot/common_log_collection.robot
Resource       ../../resources/robot/BBpooling_MuMIMO.robot
Resource         ../../resources/robot/PM_Counters.robot
Resource        ../../5GC000937/resources/5GC000937_Keywords.robot
Library         ute_admin                         WITH NAME   ute_adm
Library        taf.collectors.btslog  WITH NAME   btslog
Library        Collections
Library        OperatingSystem
Library        ta5g_tshark
Library        ta5g_commissioning
Library        taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library        taf.transport.ssh                 WITH NAME    csn
Library        SSHLibrary


*** Variables ***
${NOKIA_LOGIN}  toor4nsn
${NOKIA_PASS}   oZPS0POrRieRtu
${GNB_IP}     192.168.255.129
${AP_IP}     192.168.200.1
${WTS.Connection}
${WTS_DIR}          /opt/iphy/latest
${WTS.Ip}           127.0.0.1
${ENB_ID}           1
${GNB_ID}           2
${st_ue_id}         11
${en_ue_id}         12
${pdu_id}           1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1

*** Keywords ***
Add AP RadParam for CB009827-A
    Log To Console  Adding AP RadParam to swconfig...
    SSHLibrary.open connection    ${AP_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
     # rdActUlMuMimoTestFunction - D
    SSHLibrary.execute command    echo "0x580550=7" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection


Add GNB RadParam for CB009827-A
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    # rdTddPoolingFeaturesEnable activate 7113+8847+8940
    SSHLibrary.execute command    echo "0x420068=7" >> /ffs/run/swconfig.txt
    #Enabling CB009827-SR-B Load-based subcell pooling for UL on TDD FR1  " RdTddUlPrbMutingWorkaroundEnable"
    SSHLibrary.execute command    echo "0x600015 =1" >> /ffs/run/swconfig.txt
    # rdSlowPRBPoolingRangeTDDUl is set to 1 (Inter plus Intra subpool)
    SSHLibrary.execute command    echo "0x580612 =1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x480005 =0" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection


Add GNB RadParam for CB009827-D
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    # rdTddPoolingFeaturesEnable activate 7113+8847
    SSHLibrary.execute command    echo "0x420068=6" >> /ffs/run/swconfig.txt
    #Enabling CB009827-SR-B Load-based subcell pooling for UL on TDD FR1 " RdTddUlPrbMutingWorkaroundEnable"
    SSHLibrary.execute command    echo "0x600015 =1" >> /ffs/run/swconfig.txt
    # rdSlowPRBPoolingRangeTDDUl is set to 1 (Inter plus Intra subpool)
    SSHLibrary.execute command    echo "0x580612 =1" >> /ffs/run/swconfig.txt
    #Energy saving feature off
    SSHLibrary.execute command    echo "0x480005 =0" >> /ffs/run/swconfig.txt
    #CB008941
    SSHLibrary.execute command    echo "0x5901C9 =1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x600015 =1" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    echo "0x5901CA =0" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command   echo "0x190297 =1" >> /ffs/run/swconfig.txt
    # ul Prb pooling
    SSHLibrary.execute command   echo "0x58057c =0x7800" >> /ffs/run/swconfig.txt
    #intersubpooling ul Prb pooling
    SSHLibrary.execute command   echo "0x58057e =0x80" >> /ffs/run/swconfig.txt
    #UEnable ERR&WRN&INF&DBG in syslogs
    SSHLibrary.execute command   echo "0x58057a =4" >> /ffs/run/swconfig.txt
    #PMcounter every 3mins
    SSHLibrary.execute command   echo "0x340000=5" >> /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection
Add routes
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.135/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.1.99/24 dev eth3
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.137/24 dev eth3
    Run    sudo ip addr add 10.0.1.138/24 dev eth3
    Run    sudo ip addr add 10.0.1.139/24 dev eth3

Start WTS Using WTS_Runner
    [Arguments]             ${wts_cfg_file}
    Stop Edaemon and Egate process
    Stop Sim_enb
    run    command=sudo rm -rf ${WTS_DIR}/*.log.*
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    wtsrunner.configure                      file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    wtsrunner.sim_state_disp
    wtsrunner.read_wtsemu_output_until_re    expected=The state is ACTIVE   timeout=120
    sleep    120s


Setup X2 Link
    [Documentation]                 Establish on WTSEmu the X2 link between eNB and gNB.
    ...                             Wait for cell cetup for each cell by using keyword 'UE Cell Setup Check'.
    ...                             See keyword 'UE Cell Setup Check' for more details.
    ...
    ...                             *Argument details:*
    ...                             - alias: vm connection alias (default value = dynamically retrieved)
    [Arguments]                     ${alias}=${HOST_EPCSIM.alias}
    Log to Console                  ${alias}
    wtsrunner.Enb X2 Link Up           enb=${ENB_ID}                               target=${GNB_ID}
    sleep                           3s
#    wtsrunner.Read Wtsemu Output Until Re
#    ...                             expected=ENB-${ENB_ID}: X2AP Link with [EG]NB-${GNB_ID} \\((\\d+\\.){3}\\d+\\:\\d+\\[\\d\\]\\) is up
#    ...                             timeout=500


Revert GNB RadParam
    Log To Console  Removing GNB RadParam from swconfig...
    SSHLibrary.open connection    ${GNB_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig_original.txt /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection

Revert AP RadParam
    Log To Console  Removing GNB RadParam from swconfig...
    SSHLibrary.open connection    ${AP_IP}
    SSHLibrary.login    ${NOKIA_LOGIN}    ${NOKIA_PASS}
    SSHLibrary.execute command    cp /ffs/run/swconfig_original.txt /ffs/run/swconfig.txt
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection




Attach NSA UEs and perform data transfer
     [Arguments]    ${ue_id}
     wtsrunner.ue_attach  id=${ue_id}
     sleep   15s
     wtsrunner.enb_ue_dc_start  ue=${ue_id}   target_gnb=2   target_cells=3   bearer=2   type=split_scg
     sleep   10s
     wtsrunner.trf_data_start   ue=${ue_id}   id=2   dir=dl   trf_id=1   mbps=10
     sleep  6s
     wtsrunner.trf_data_start   ue=${ue_id}   id=2   dir=ul   trf_id=1   mbps=10
     sleep  6s
     wtsrunner.bearer_stats  ue=${ue_id}   id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=mcg
     sleep  6s
     wtsrunner.bearer_stats  ue=${ue_id}  id=2   dir=dl   trf_id=1   type=l3   dc_cell_group=scg
     sleep  6s


Attach Multiple SA UEs and perform data transfer
    Attach SA UEs and perform data transfer   ue_id=1     trf_id=1    profile_id=2
    Attach SA UEs and perform data transfer   ue_id=2     trf_id=3    profile_id=3
    Attach SA UEs and perform data transfer   ue_id=31     trf_id=5    profile_id=2
    Attach SA UEs and perform data transfer   ue_id=32     trf_id=7    profile_id=3


Attach Multiple NSA UEs and perform data transfer
    Attach NSA UEs and perform data transfer   ue_id=101
    sleep  10s
    Attach NSA UEs and perform data transfer   ue_id=102
    sleep  10s
    Attach NSA UEs and perform data transfer   ue_id=103
    sleep  10s

Verify PM Counters for Cell${id} [${moc}]
    Log To Console   ${id}
    #TOT_MU_MIMO_PAIR_UE_PUSCH
    ${TOT_MU_MIMO_PAIR_UE_PUSCH}=  Verify PM Counters   feature_id=CB008360    counter_id=M55308C35010    moc=${moc}
    #PRB_UL_MU_MIMO_4LAYER
    Verify PM Counters     feature_id=CB008360    counter_id=M55308C35005   moc=${moc}
    #PRB_UL_MU_MIMO_2PAIR_UE
    Verify PM Counters    feature_id=CB008360    counter_id=M55308C35007    moc=${moc}
    #TOT_MU_MIMO_ELIG_UE_PUSCH
    ${TOT_MU_MIMO_ELIG_UE_PUSCH}=  Verify PM Counters    feature_id=CB008360    counter_id=M55308C35011    moc=${moc}
    run keyword and continue on failure    should be true    (${TOT_MU_MIMO_PAIR_UE_PUSCH}/${TOT_MU_MIMO_ELIG_UE_PUSCH}) >0.75


Verify PM Counters
    [Arguments]     ${feature_id}   ${counter_id}    ${moc}
    Log To Console   ${feature_id}    ${counter_id}    ${moc}
    sleep    240s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM counter value is bigger than given value   PM_dir=${PM_dir_1}    PM_counter=${counter_id}    expected_value=0  moc=${moc}
    ${Counter_value}=  Get PM counter value    ${PM_dir_1}   ${counter_id}    ${moc}
    [Return]     ${Counter_value}

Validate PM counter value is bigger than given value
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}   ${moc}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}



Detach NSA Ues
    [Arguments]     ${ue_id}
    wtsrunner.ue_detach   id=${ue_id}
    sleep   15s

Detach SA Ue
    [Arguments]     ${ue_id}
    wtsrunner.ue_deregister   id=${ue_id}    ue_deregister_type=switch_off
    sleep   15s

Attach SA UEs and perform data transfer
    [Arguments]     ${ue_id}    ${trf_id}   ${profile_id}
    wtsrunner.ue_register  id=${ue_id}
    sleep  6s
    wtsrunner.set_pdu_param   ue=${ue_id}   pdu=1   trf_type=internal
    sleep  6s
    wtsrunner.ue_pdu_session_setup   pdu=1   ue=${ue_id}   nwslice=1   gw=1
    sleep  6s
    wtsrunner.ue_testmode_set_nr    id=${ue_id}   testmode=ul_mimo_srs_beam_pos    action=activate   profile_id=${profile_id}    scell=0
    sleep  6s
#    wtsrunner.trf_data_start    ue=${ue_id}    pdu=1    qfi=1   trf_id=${ue_id}    mbps=5    dir=dl
#    sleep  6s
    wtsrunner.trf_data_start    ue=${ue_id}     pdu=1    qfi=1   trf_id=${trf_id}    mbps=100   dir=ul
    sleep  6s
    wtsrunner.trf_data_start    ue=${ue_id}     pdu=1    qfi=1   trf_id=${trf_id}+1    mbps=100   dir=ul
    sleep  6s
    wtsrunner.bearer_stats      ue=${ue_id}     pdu=1    qfi=1    dir=ul
    sleep  6s

Set SRS Beam Position for muMIMO
    Set Srs beam position    2     0    3
    Set Srs beam position    3     1    2
    Set Srs beam position    9     2    3

Decrease SA Users data traffic
    [Arguments]     ${ue_id}    ${trf_id}
    wtsrunner.trf_data_stop   ue=${ue_id}     pdu=1    qfi=1   trf_id=${trf_id}    ue=${ue_id}
    sleep  6s


Trigger multiple NSA UEs
#    CB009827_Keywords.Setup X2 Connection
    X2AP Link Should be UP
    MultiUE Attach for NSA    ${st_ue_id}    ${en_ue_id}
    MultiUE DL Traffic Start for NSA    ${st_ue_id}    ${en_ue_id}    mbps    20    id=2    trf_id=1
    MultiUE UL Traffic Start for NSA    ${st_ue_id}    ${en_ue_id}    mbps    20    id=2    trf_id=1
#    sleep   120s
#    MultiUE Validate UL Traffic For NSA    ${st_ue_id}    ${en_ue_id}     20     id=2
#    MultiUE Validate DL Traffic For NSA    ${st_ue_id}    ${en_ue_id}     20     id=2
#    MultiUE DL Traffic Stop for NSA    ${st_ue_id}    ${en_ue_id}    2    1
#    MultiUE UL Traffic Stop for NSA    ${st_ue_id}    ${en_ue_id}    2    1
#    MultiUE Detach for NSA    ${st_ue_id}    ${en_ue_id}

Trigger multiple SA UEs
#    Start CPRT Trace Capturing
    ${crnti_list}=      MultiUE Register should be Successful    1  4
#    Stop CPRT capture   ${CaptureCPRT}
#    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UEs_Attach.pcap
    MultiUE Trigger DL Traffic for SA    1  4    Traffic_rate=mbps     dl_rate=100     pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger UL Traffic for SA    1  4    Traffic_rate=mbps     ul_rate=50     pdu_id=1     trf_id=1     qfi_id=1
#    Validate DL Traffic For MultiUE for SA    1  4     dl_rate=20
#    Validate UL Traffic For MultiUE for SA    1  4     ul_rate=20
    Start L2 BIP Trace Capturing
    sleep      2s
    Stop L1L2 capture    ${CaptureL1L2}
#    Stop MultiUE Data Traffic for SA     1  4
#    MultiUE Deregister should be Successful   1  4
    Log to Console  ${CaptureL1L2}

MultiUE Attach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${chk_fail}=${-1}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    LTE Attach should be Successful    ${ue_id}
#    UE Attach should be Successful    ${ue_id}
    NSA UE Attach    ${UE_ID}    chk_fail=${chk_fail}
    END

NSA UE Attach  #NSA
    [Arguments]    ${UE_ID}    ${chk_fail}=${-1}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    wtsrunner.enb_ue_dc_start    target_gnb=${Target_gNB}    target_cells=${Target_Cells}    ue=${UE_ID}
    ...                         bearer=${Bearer_ID}    type=split_scg
#    ${fail_pt}    Set Variable    UE${UE_ID}: No band combinations in MR-DC capabilities*
    ${fail_pt}    Set Variable    value Cause : radioNetwork : tDCprep-expiry
    ${pattern}    Set Variable If    ${chk_fail}!=${-1}    ${fail_pt}    ${UE_attach_pattern}
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${pattern}    ${Timeout_NSA}
    [Return]      ${output}



MultiUE DL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
    Log to Console     ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}  ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger DL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${dl_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE UL Traffic Start for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${ul_rate}    ${id}=${Bearer_ID}    ${trf_id}=${TRF_ID}
     Log to Console     ${start_ue_id}    ${stop_ue_id}    ${Traffic_rate}    ${dl_rate}    ${id}  ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    Trigger UL Traffic for NSA    ${ue_id}    ${Traffic_rate}    ${ul_rate}    id=${Bearer_ID}    trf_id=${TRF_ID}
    END

MultiUE Validate UL Traffic For NSA
    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
    Validate UL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    END

MultiUE Validate DL Traffic For NSA
    [Arguments]    ${st_ue_id}    ${en_ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    FOR    ${ue_id}    IN RANGE    ${st_ue_id}    ${en_ue_id}+${1}
    Validate DL Traffic For NSA    ${ue_id}     ${ul_rate}     ${id}=${Bearer_ID}
    END


MultiUE DL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    dl    ${trf_id}
    END

MultiUE UL Traffic Stop for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}    ${Bearer_ID}    ${trf_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    TRF Data Stop for NSA    ${ue_id}    ${Bearer_ID}    ul    ${trf_id}
    END


MultiUE Detach for NSA
    [Arguments]    ${start_ue_id}    ${stop_ue_id}
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${stop_ue_id}+${1}
    UE Detach should be Successful    ${ue_id}
    END

Detach both NSA and SA UEs
    MultiUE DL Traffic Stop for NSA    ${st_ue_id}    ${en_ue_id}    2    1
    MultiUE UL Traffic Stop for NSA    ${st_ue_id}    ${en_ue_id}    2    1
    MultiUE Detach for NSA    ${st_ue_id}    ${en_ue_id}
    Stop MultiUE Data Traffic for SA     1  4
    MultiUE Deregister should be Successful   1  4


Verify Counters CB008360
    sleep    240s
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55308C10002    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55308C10006    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55308C10004    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55308C35006    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55308C35011    expected_value=0
    Validate PM Counters bigger than    PM_dir=${PM_dir_1}    PM_counter=M55308C35010    expected_value=0

Validate PM Counters bigger than
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1

