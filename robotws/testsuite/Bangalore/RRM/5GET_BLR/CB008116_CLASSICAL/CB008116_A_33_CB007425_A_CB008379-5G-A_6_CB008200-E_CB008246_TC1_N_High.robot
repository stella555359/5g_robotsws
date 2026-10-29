*** Settings ***
Force Tags      CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_SC_TDD    5G_RAN     SBTS00    SBTS23R2     CONFIGURED

Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Library          ta5g_commissioning
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
#Library          ../resources/python/BIP_Capture.py
#Library          ../resources/python/CPRT_Capture.py
#Resource        ta5g_setups_and_teardowns
Resource         ./basic_resource.robot
Library          ./python/update_delta_and_create.py




Resource         ../resources/robot/common_log_collection.robot
#Resource         ../CB008379/CB008379_Resource.robot
Resource         ./CB008379_Resource.robot
Resource         ./resources/common/common_log_capture.robot
#Resource        ../resources/ECEcommon/common_file_operation.robot

#Resource         ../CB008200/CB008200_Resource.robot
Resource         ./CB008200_Resource.robot
Library          ../CB008200/resources/python/PM_Counter_Verify.py

#tc4

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
#Resource         ../CB008246/CB008246_resource.robot
Resource         ./CB008246_resource.robot
###Resource         /home/ute/MN/UTE/robotws/testsuite/Bangalore/RRM/5GET_BLR/CB008927/CB008927_resource.robot
Library          ../CB008927/python/CB008927_Verification.py
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Library          ../CB008246/python/CB008246_validation.py
Library          SSHLibrary


#Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}

Documentation
...
...             author:            vuyyuri.satyanarayana_raju@nokia.com
...             maintainer:        vuyyuri.satyanarayana_raju@nokia.com
...             INTRODUCTION:      This user scenario describes the behaviour of Nokia gNB in SA mode during NG based
...                                handover of a SA call with active UP IP in downlink direction with UP IP Indication
...                                as ?Required?    with AES UPIP algorithm.
...             TEST SET NAME:    CB008116_A_33_US6_NGHO_SgNB-UPIPInd-Req-AES-MaxUERate_TgNB-UPIPInd-Req-AES
...                 -MaxUERate_5QI9_DL_FDD_LN
...             TESTING SPLIT:    See CB008116 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008116 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_16583,5G_CP_MM_3839


*** Variables ***
${wts_cfg_file1}     ${CURDIR}/config/wts/basic_setup_rjio.cfg
#${WTS_DIR}          /opt/iphy/latest
#&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
#${epc_log_path}    /tmp/
&{ciph}         nea0=1      nea1_128=2  nea2_128=4  nea3_128=3
&{intgr}        nia0=1      nia1_128=2  nia2_128=4  nia3_128=3
${ip_prof}      null
${ip_prof1}      snow3g
${ip_prof2}      aes
${ip_prof3}      zuc
&{ue_profile}    ${1}=${ip_prof2}    ${2}=${ip_prof2}

&{ip_ie}    ${1}=required      ${2}=preferred
&{max_ip_rate}    ${1}=maximum-UE-rate     ${2}=maximum-UE-rate
&{max_ip_rate_dl}    ${1}=maximum-UE-rate      ${2}=maximum-UE-rate
&{ip_result}      ${1}=performed     ${2}=not-performed

#${st_ue_id}      ${1}
#${en_ue_id}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile}                5_gfbr_ul=10   5_gfbr_dl=20    5_mfbr_ul=40     5_mfbr_dl=50

@{QOS_Prof1}                1
@{QOS_Prof1_speed_ul}       10
@{QOS_Prof1_speed_dl}       10
@{QOS_Prof1_unit}           mbps

${SCFC}             ${CURDIR}/config/SCF/SCF_CB008379-A_6_FDD_20MHZ.xml
${AP_XML}           ${CURDIR}/config/SCF/iphy_CB008379-A_6_FDD_20MHZ.xml
${wts_cfg_file2}     ${CURDIR}/config/wts/basic_setup_max_gfbr_30_fdd_um_mode_mp.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${st_ue_id}      ${1}
${en_ue_id}      ${1}

# GFBR and MFBR profile <qos flow id>_gfbr_<dir>=speed
&{gfbr_mfbr_profile_1}                6_gfbr_ul=10   6_gfbr_dl=20    6_mfbr_ul=40     6_mfbr_dl=50

#Make sure VONR Traffic profile should in kbps for 5QI1 and 5QI 5 i.e QFI 2 and 3
@{QOS_Prof1_1}                1            6
@{QOS_Prof1_speed_ul_1}       2            30
@{QOS_Prof1_speed_dl_1}       2            30
@{QOS_Prof1_unit_1}           mbps         mbps

#tc3
${wts_cfg_file3}     ${CURDIR}/config/wts/basic_setup_1CC_fdd_multi_ue_vonr_new.cfg



${st_ue_id_1}      ${1}
${en_ue_id_1}      ${10}

#tc4
${wts_cfg_file4}      ${CURDIR}/config/wts/k-split.cfg
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${qfi_id}    1
${Q_O_ADD}      1
${RTP_COD}      1
${TLConfig.isUTE}       True
${TEST_NAME}        test_case
${Timeout_SA}       60
${radparam}                SEPARATOR=${EMPTY}    0x890073=0



*** Test Cases ***
[1][1.0] CB008116_A_33_US6_NGHO_SgNB-UPIPInd-Req-AES-MaxUERate_TgNB-UPIPInd-Req-AES-MaxUERate_5QI9_DL_FDD_LN
    [Tags]    TC01
    [Setup]    Run keywords     Suite setup from scratch
    ...                 AND     Add RadParam to swconfig      ${radparam}
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.3/24 dev eth3
    ...                 AND     OperatingSystem.Run     sudo ip addr add 10.0.1.4/24 dev eth3
    ...                 AND     Update bsr package
    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_IntraDU_intrafreq_rjio_2.json
    ...                 AND     sleep   30s
    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_scf_IntraDU_intrafreq_rjio_4.json
##    ...                 AND     Perform SCF Delta Commissioning with Delete_nradjgnb.json
##    ...                 AND     sleep   60
#    ...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_NGHO.json
#    ...                 AND     sleep    120
#    ...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G_XnLinkDel.json
#    ...                 AND     sleep    90
#    ...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G_xnlink.json
#    ...                 AND     sleep    120
#    ...                 AND     Perform SCF Delta Commissioning with Delta_Config_2CC_FDD_XnHO_Snow3G_NRAdjGNB.json
#    ...                 AND     sleep    90

#   #...                 AND     update_delta_and_create.update_and_gen    ${CURDIR}/config/SBTS23R2/basic_delta.json   ${intgr}    ${ciph}
#   #...                 AND     sleep     60
#   #...                 AND     Perform SCF Delta Commissioning with delta_gen.json
#   #...                 AND     sleep     60

#    ...                 AND     Perform SCF Delta Commissioning with basic_delta_AES.json
    ...                 AND     sleep    50
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                 AND     update_delta_and_create.update_cfg  ${CURDIR}/config/wts/basic_setup_2CC_FDD_NGHO.cfg
#    ...                 ${ue_profile}
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file1}

    Set Suite Variable    ${ip_ie}      &{ip_ie}
    Set Suite Variable    ${max_ip_rate}      &{max_ip_rate}
    Set Suite Variable    ${max_ip_rate_dl}      &{max_ip_rate_dl}
    Set Suite Variable    ${ip_result}      &{ip_result}
    Set Suite Variable    ${ue_profile}      &{ue_profile}

    Increase Buffer Size for VM and IPHY

    ue location change
    Sleep   20
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1}              ${2}=${QOS_Prof1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul}     ${2}=${QOS_Prof1_speed_ul}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl}     ${2}=${QOS_Prof1_speed_dl}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit}         ${2}=${QOS_Prof1_unit}


    ${ue_to_bearer_list}=  MultiUE Register should be Successful Custom      ${st_ue_id}    ${en_ue_id}
    ... 	pdu_session_setup   ${ip_ie}      ${max_ip_rate}     pdu_id=1    nw_id=1  ho=${1}

    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile}   ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    300
    ${trf_id}      Set Variable    ${1}
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    both   ${trf_id}   ${qos_profile_unit}
    ...     ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}
    sleep   ${60}s

    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    basic_resource.Set CPRT capture    ${CaptureCPRT}
    HO SA A3 UE measurements
    sleep   ${120}s
    basic_resource.Stop CPRT capture  ${CaptureCPRT}

    Validate DL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     dl_rate=10   pdu_id=1   qfi_id=1
    Validate UL Traffic For MultiUE for SA    ${st_ue_id}    ${en_ue_id}     ul_rate=10   pdu_id=1   qfi_id=1

    Verify Bearer_context_setup_req     ${CaptureCPRT.path}      ${st_ue_id}

    Check Integrity failure count
#   ${nongbr_tp_read}=     Verify data transfer and get tp gbr_nongbr    ${st_ue_id}    ${en_ue_id}    ${duration}    both   ${trf_id}
#    ...    ${qos_profile_unit}    ${qos_profile_speed_ul}     ${qos_profile_speed_dl}    ${qos_profile}

    MultiUE Deregister should be Successful      ${st_ue_id}    ${en_ue_id}
#    [Teardown]  Run Keywords   Log To console  TCTeardown
#    ...         AND        Link SCOUT SCF to Configuration ID for Reporting

    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting
[1][1.0] CB007425_A_CB008379-5G-A_6_Verify_Max_UL_throughput_with_Link_Adaptation_for_5QI-4_FDD

    [Tags]    TC02
    [Setup]         Run keywords     Suite setup from scratch
    ...                 AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                 AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_GBR_8379_20MHz_LA.json
    ...                 AND     Reboot gNB System Module from Console and check Airscale is ready
    ...                 AND     Check Cell On Air      ${wts_cfg_file2}


    set test variable      ${LOG_PATH}
    CB008379_Resource.Increase Buffer Size for VM and IPHY
    log to console   UE attach trigerring now...
    ${qos_profile}               Create Dictionary   ${1}=${QOS_Prof1_1}
    ${qos_profile_speed_ul}      Create Dictionary   ${1}=${QOS_Prof1_speed_ul_1}
    ${qos_profile_speed_dl}      Create Dictionary   ${1}=${QOS_Prof1_speed_dl_1}
    ${qos_profile_unit}          Create Dictionary   ${1}=${QOS_Prof1_unit_1}

#Step 1. Attach 1 UE with profile GFBR profile 30mbps with fiveQI3
    ${ue_to_bearer_list}=       MultiUE Register should be Successful with Fetch Bearer ID     ${st_ue_id}
    ...    ${en_ue_id}    pdu_id=1    nw_id=1
    Log to Console             Bearerlist with${ue_to_bearer_list}
    Create Modify PDU session   ${st_ue_id}     ${en_ue_id}    ${qos_profile}   pdu_id=1
    ...    gfbr_mfbr_profile=${gfbr_mfbr_profile_1}   ue_to_bearer_list=${ue_to_bearer_list[1]}
    ${duration}      Set Variable    1800
    ${trf_id}      Set Variable    ${1}

# For UL and DL data transfer a List tp will return in a list other wise a single dict will come direction both means ul and DL
    Start Data Transfer     ${st_ue_id}     ${en_ue_id}     ${duration}    ul   ${trf_id}
    ...         ${qos_profile_unit}  ${qos_profile_speed_ul}  ${qos_profile_speed_dl}    ${qos_profile}
    Set fixed cqi bler for single UE    ${st_ue_id}    ul
    CB008379_Resource.Start and Stop TTI TRACE    duration=${10}
    sleep   ${duration}s
    ${new_path}      CB008379_Resource.Collect TTI Trace   tti_trace
    ${tti_tp_ul}    tti_trace_utility.get_tp_frm_tti    ${ue_to_bearer_list[0]}     ${ue_to_bearer_list[1]}
    ...    ul       ${new_path}/output_ul_formated.csv
    ${nongbr_tp_read}=     Verify data transfer and get tp      ${st_ue_id}     ${en_ue_id}     ${duration}    ul
   ...    ${trf_id}     ${qos_profile_unit}    ${qos_profile_speed_ul}    ${qos_profile_speed_dl}    ${qos_profile}
    ${status}=      tti_trace_utility.verify_tp_from_tti    ${ue_to_bearer_list[1]}   ${tti_tp_ul}
    ...      ${qos_profile_speed_ul}    ${qos_profile_unit}     ${vonr_codec_rate}  ${0}   ${0}
    Should Contain     ${status}    Pass
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

[1][1.0] CB008200-E_1_UEs_with_buffered_DL_data_in_5QI-1_DRB
#    [Tags]     QC_201785      QCD_MN_RAN    QCP_RAN_ET

    [Tags]    TC03
    [Setup]         Run keywords     Suite setup from scratch
    ...             AND     Perform SCF Delta Commissioning with Delta_Configuration_1CC_FDD_VONR_MultiUE.json
    ...             AND     Reboot gNB System Module from Console and check Airscale is ready
    ...             AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...             AND     Check Cell On Air      ${wts_cfg_file3}

#Starting CPRT Trace Capturing
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Wait until the next Measurement Period starts  additional_time=${0}

#Step 1. Attach 6 VONR UEs, with PDU session 5QI-6 nonGBR qosflow which is default
    MultiUE Register should be Successful     ${st_ue_id_1}    ${en_ue_id_1}    pdu_id=1    nw_id=1

#Step 2. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Addition should be Successful        ${st_ue_id_1}    ${en_ue_id_1}    nw_id=1    pdu_id=2
    MultiUE PDU Modfication should be Successful     ${st_ue_id_1}    ${en_ue_id_1}    pdu_id=2   qosflows_to_add=2
    Sleep   1s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id_1}    ${en_ue_id_1}    Traffic_rate=kbps     dl_rate=32
    ...  pdu_id=2    trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id_1}    ${en_ue_id_1}    Traffic_rate=kbps     ul_rate=32
    ...    pdu_id=2    trf_id=1       qfi_id=2

#Step 3. Establish pdu_id=2 for 5QI-1 VoNR Call
    MultiUE PDU Modfication should be Successful     ${st_ue_id_1}    ${en_ue_id_1}      pdu_id=2      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id_1}    ${en_ue_id_1}    pdu_id=2
    ...     num_trf_id=20    qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic with multiple trfids    ${st_ue_id_1}    ${en_ue_id_1}    pdu_id=2
    ...     num_trf_id=20    qfi_id=3    rtp_codec=custom
    sleep       900s
    Wait until the current Measurement Period stops  additional_time=${0}
    CB008200_Resource.Collect PM Counters
    CB008200_Resource.Get buffer counters and validate    M55308C32000    M55308C32001    M55308C02001    M55308C02003
    ...     M55308C01000    M55308C01001
    Stop MultiUE Data Traffic for SA     ${st_ue_id_1}    ${en_ue_id_1}
#    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}
    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting



[1]TC1_N_High_reliability_feature_interworking_with_VoNR_FDD
    [Tags]    TC04
    [Setup]            Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
    ...     AND     CB008246_resource.Perform SCF Delta Commissioning with CB008246_TC1_K5_HR_interworking_vonr_FDD.json
    ...                AND     sleep    180
        ...             AND     Reboot gNB System Module from Console and check Airscale is ready
#    ...                AND     gnb.Perform gNB reboot
    ...                AND     Start Default Logging    output_dirpath=${LOG_PATH}
    ...                AND     CB008246_resource.Load CFG Config And Capture CPRT Traces      ${wts_cfg_file4}
    ...                AND     Run Keyword and Ignore Error    Start Log    btslog
    ...                AND     Check gNB Bulid

    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...

     Start Log    cprt
#    Start Log       ttitrace

#Step 1. Attach VONR UEs with PDU session 5QI-6 nonGBR qosflow which is default
    ${crnti}    MultiUE Register should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1    nw_id=1
    MultiUE PDU Modfication should be Successful     1    1      pdu_id=1      qosflows_to_add=1


#Step 2.Add pdu and start data
#    MultiUE PDU Addition should be Successful        ${st_ue_id}    ${en_ue_id}    nw_id=1    pdu_id=2
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     trf_id=1
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     trf_id=1

    Start Log       ttitrace

#Step 3.modify pdu with qos flow : 4 and trigger data
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1   qosflows_to_add=7
    Sleep       2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=1
    ...     trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=1
    ...     trf_id=1       qfi_id=2
#Step 4. Establish pdu_id=2 for 5QI-5 SIP Signalling
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}    pdu_id=1   qosflows_to_add=2
    Sleep   2s
    MultiUE Trigger DL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     dl_rate=32     pdu_id=1
    ...     trf_id=1       qfi_id=2
    MultiUE Trigger UL Traffic for SA    ${st_ue_id}    ${en_ue_id}    Traffic_rate=kbps     ul_rate=32     pdu_id=1
    ...     trf_id=1       qfi_id=2
#Step 5. Establish pdu_id=2 for 5QI-1 VoNR Call
    MultiUE PDU Modfication should be Successful     ${st_ue_id}    ${en_ue_id}      pdu_id=1      qosflows_to_add=3
    Trigger MultiUE VoNR DL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=1     num_trf_id=20
    ...     qfi_id=3    rtp_codec=custom
    Trigger MultiUE VoNR UL Traffic with multiple trfids    ${st_ue_id}    ${en_ue_id}    pdu_id=1     num_trf_id=20
    ...     qfi_id=3    rtp_codec=custom
	${path_ttitrace_1}    Stop log    ttitrace    test_scenario=ttitrace_add_FDD
    Log to Console    ${path_ttitrace_1}[ttitrace]
     ${path_cprt}    Stop log    cprt       test_scenario=cprt

#    Decode TTI Trace    ttitrace_add_FDD
     Common TTI PCAP to CSV Converter    ttitrace_add_FDD    dir=dl
     Common TTI PCAP to CSV Converter    ttitrace_add_FDD    dir=ul


#    Start Log    cprt

    wtsrunner.ue_pdu_session_modify     ue=1    pdu=1   qosflows_to_del=3   by=amf
    Start Log       ttitrace
    Sleep   2s

    Stop MultiUE Data Traffic for SA     ${st_ue_id}    ${en_ue_id}
    MultiUE Deregister should be Successful   ${st_ue_id}    ${en_ue_id}

	${path_ttitrace_2}    Stop log    ttitrace    test_scenario=ttitrace_del_FDD
    Log to Console    ${path_ttitrace_2}[ttitrace]
#   ${path_cprt}    Stop log    cprt       test_scenario=cprt

#    Decode TTI Trace    ttitrace_del_FDD
    Common TTI PCAP to CSV Converter    ttitrace_del_FDD    dir=dl
    Common TTI PCAP to CSV Converter    ttitrace_del_FDD    dir=ul

    Verify lamode and mcstable HR DRB added after CG DRB_1    ${path_ttitrace_1}[ttitrace]
    ...      ${crnti}
    Verify lamode and mcstable HR DRB added after CG DRB_2     ${path_ttitrace_2}[ttitrace]
    ...      ${crnti}

    [Teardown]    Run Keywords    Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
    ...        AND     Run Keyword and Ignore Error    Get Snapshot
    ...        AND        Stop Default Logging    output_dirpath=${LOG_PATH}
    ...        AND   Link SCOUT SCF to Configuration ID for Reporting

** Keywords **

Establish Xn Link To UPIP gNB${gnb}
    BuiltIn.Log    Setup Xn Link Between gNB${gnb} and gNB2...    console=${True}
    wtsrunner.gnb_param    id=${gnb}     xn_listening_socket=1     send_xn_setup=true     ciphering_disabled=6:false
    ...     integrityProtection_enabled=6:true     ciphering_algorithm=nea2     integrityprotection_algorithm=nia2
    ${output}       wtsrunner.read_wtsemu_output_until_prompt     timeout=20
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    Sleep   30s
    wtsrunner.gnb_xn_link_up      gnb=${gnb}     target=2
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=GNB-${gnb}: XnAP Link with GNB-2   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    GNB-${gnb}: XnAP Link with GNB-2   partial_match=${TRUE}
    Log to Console    ${output}

Check Cell On Air
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
    wtsrunner.configure                   file=${wts_cfg_file}
    wtsrunner.read_wtsemu_output_until_re    expected=Airphone: Cell Setup completed     timeout=240

Set fixed cqi bler for single UE
    [Arguments]  ${ue_id}    ${dirct}
    # For DL BLER
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.bler_testmode_nr    profile_id=40    target_mcs=3
    ...    num_dl_pkts=10000    num_harq_nack=500
    Run Keyword if  '${dirct}' == 'dl'    wtsrunner.ue_testmode_set_nr    id=${ue_id}    testmode=bler
    ...     action=activate    profile_id=40
    # Fr UL SINR
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ul_sinr_testmode_nr    profile_id=3    sinr_target_srs=-250    sinr_target_pusch=-250
    ...    sinr_target_pucch=-250    sinr_target_preamble=-250
    Run Keyword if  '${dirct}' == 'ul'
    ...    wtsrunner.ue_testmode_set_nr  id=${ue_id}  testmode=ul_sinr    action=activate    profile_id=3

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}

Increase Buffer Size for VM and IPHY
    increase_buffer_size.increase_buffer_size    ${AP_ASIK.ip}    ${port}    ${AP_ASIK.username}     ${AP_ASIK.password}


Verify lamode and mcstable HR DRB added after CG DRB_1
    [Arguments]   ${FolderName}    ${UE_crnti_list}
    ${rc}    SplitK9425verify     ulFdSchedData    ${UE_crnti_list}[0]     ${FolderName}/output_ul_formated.csv
    Should Contain	${rc}	PASS

Verify lamode and mcstable HR DRB added after CG DRB_2
    [Arguments]   ${FolderName}    ${UE_crnti_list}
    ${rc}    SplitK9425verify_vonr_rel     ulFdSchedData    ${UE_crnti_list}[0]     ${FolderName}/output_ul_formated.csv
    Should Contain	${rc}	PASS

Update bsr package
    Run     mkdir ${CURDIR}/BSR
    ${dllink}   Set Variable     https://artifactory-espoo1.ext.net.nokia.com:443/artifactory/mnpute-rotta-local/BSR
    ${filename}    Set variable     BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    Run     sudo wget ${dllink}/${filename} --user=dheerajn --password=AP33ZXKC1P9cgTCGJmyvY3bv5NA -P ${CURDIR}/BSR
    admin.setup admin
    ${ret}     admin.Update Software      ${CURDIR}/BSR/BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471.zip
    admin.teardown admin

Add RadParam to swconfig
    [Documentation]    This keyword will append the flags to swconfig.txt file.
    ...      Usage: Add RadParam to swconfig     "0x58057f=50"    "0x58057a=50"      IP=192.168.255.129
    [Arguments]    @{flag_list}
    Log To Console  Adding GNB RadParam to swconfig...
    SSHLibrary.open connection    192.168.255.129
    SSHLibrary.login    toor4nsn    oZPS0POrRieRtu
    SSHLibrary.execute command    cp /ffs/run/swconfig.txt /ffs/run/swconfig_original.txt
    FOR    ${flag}    IN    @{flag_list}
    SSHLibrary.execute command    echo "${flag}" >> /ffs/run/swconfig.txt
    END
    SSHLibrary.execute command    crasign /ffs/run/swconfig.txt
    SSHLibrary.execute command    craverify /ffs/run/swconfig.txt /ffs/run/swconfig.txt.p7
    SSHLibrary.close connection