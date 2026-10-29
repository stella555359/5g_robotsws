*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    CRT    RAN_5G_TDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py
Resource         ../resources/robot/configuration_id.robot



Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     BuiltIn.Log     ${SCFC}
...                 AND     Prepare TL with config files
...                 AND     Suite setup from scratch
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Configure UTE ETH3 and ETH4 IPs
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Madhukara M V
...             maintainer:       madhukara.m_v@nokia.com
...
...             INTRODUCTION:     This user scenario describes the gNB behaviour for  NBR activation when PSCell change happens
...                               during the inter GNB handover of the feature in NSA mode  ( with 5GC000573-A#B1: Intra-Frequency inter
...                               en-gNB mobility for NSA Opt 3x  Successful scenario (Ref 5G_RAN_USR_RRM_1034) are satisfied.)

...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/PScell_change_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}   1
${sa_ue_id2}   2
${sa_ue_id3}   3
${nsa_ue_id1} 	31
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC33
${x2_UP_pattern_with_simulated_gnb}    ENB-1: X2AP Link with GNB-4 .* is up
${UE_attach_pattern}                   Bearer-type change from MCG to SCG-split is \nsuccessful
${timeout}    20
${SCFC}=                        ${CURDIR}/config/PScell_change_scf.xml
${AP_XML}=                      ${CURDIR}/config/PScell_change_iphy.xml
${Delta_scf_feature_enable}     Delta_CB008227_act.json
${Delta_scf_feature_disable}    Delta_CB008227_deact.json
${CELL_ID}    1

*** Test Cases ***
[1]CB008227-C#B6_TC33_Support_Nominal_Bit_Rate_of_nonGBR_bearers_for_Inter_gNB_PSCell_change_procedure_NSA
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${Delta_scf_feature_enable}
    log to console   "waiting till next messurement  period"
    Wait until the next Measurement Period starts
    log to console   "Next Meassuement period  started"
    log to console   "Make X2 link up with ENB1(Simulated) and GNB4(simulated) and make x2 link up with ENB1 and Real GNB2"
#Step : 1 Attach NSA UE to simulated ENB 1 and configure ENDC with Sumilated GNB 4
    X2AP Link Should be UP
    X2AP Link Should be UP with simulated ENB and simulated GNB    src=1   target=4
    sleep     5s
    Link SCOUT SCF to Configuration ID for Reporting
    UE Attach and ENDC should be Successful   ${nsa_ue_id1}  Trgt_Cell=1   Trgt_gNB4=4  Bearer_ID=2
    sleep     5s
    Multiple NSA UE start and validate DL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=20
    Multiple NSA UE start and validate UL Traffic    ${nsa_ue_id1}  ${nsa_ue_id1}   dl_rate=10
    sleep    5s
    Start Log    cprt
#step 3: Trigger the A3 measuusremts report from NSA ue from Simuated GNB 4 about the target GNB(real) cell (phycell id 50)
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB for PScell Change    ue_id=${nsa_ue_id1}    meas_id=3    phycell_id=50
    ${path2}    Stop Log    cprt   test_scenario=user_bearersetup
    Verify nbrDrbSpecificParams In usersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap   sctp    2000    2000
    sleep   10s
    Validate DL Traffic For NSA     ${nsa_ue_id1}     20
    Validate UL Traffic For NSA     ${nsa_ue_id1}     10
	# verify that NBR ADMIT and NBR Request counters are geting pegged
	${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  1  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  1  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}

    log to console   "wait till meas period stops and collect the PM files and verify the PM counters for NBR DL and UL"
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  M55115C03510  300  NSA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID}
    ...  file_path=${pm_counter_file}

    Multiple NSA UE Detach   ${nsa_ue_id1}  ${nsa_ue_id1}
    Stop Log   btslog   snapshot



*** keywords ***

X2AP Link Should be UP with simulated ENB and simulated GNB    # This is for setting ENDC call with ENB and GNB ( both simulated)
    [Arguments]     ${src}   ${target}
    [Documentation]    This keyword is used to Create a X2 connection with gNB
    ...                And checks if the X2AP link with the gNB is UP in the output file.
    wtsrunner.enb_x2_link_up    enb=${src}    target=${target}
    Read WTS Output For Pattern And Print matching Lines    ${x2_UP_pattern_with_simulated_gnb}    ${timeout}
    BuiltIn.Log    x2_is_ok


UE Attach and ENDC should be Successful  #NSA
    [Arguments]    ${NSA_UE_ID}  ${Trgt_Cell}   ${Trgt_gNB4}   ${Bearer_ID}
    [Documentation]    This keyword is used to Attach the UE with gNB and check the completion message in output file.
    LTE Attach should be Successful    ${nsa_ue_id1}
    sleep    10s
    wtsrunner.enb_ue_dc_start    target_gnb=${Trgt_gNB4}    target_cells=${Trgt_Cell}    ue=${NSA_UE_ID}
    ...  bearer=${Bearer_ID}    type=split_scg
    ${output}    Read WTS Output For Pattern And Print matching Lines    ${UE_attach_pattern}    ${timeout}
    [Return]      ${output}


Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB for PScell Change
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Inter Sgnb Handover is successful   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    Inter Sgnb Handover is successful    partial_match=${TRUE}
    Log to Console    ${output}

Configure UTE ETH3 and ETH4 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run     sudo ip addr add 10.0.2.1/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.126/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.127/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.128/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.129/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.130/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.140/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.141/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.142/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.143/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.144/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.145/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.146/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.147/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.148/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.149/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.150/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.151/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.152/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.153/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.154/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.155/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.2.90/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.91/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.92/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.93/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.94/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.95/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.96/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.97/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.98/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.100/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.1.9/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.10/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.11/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.12/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.13/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.14/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.15/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.100/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.101/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.103/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.104/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.105/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.106/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.107/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.108/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.109/24 dev eth3
