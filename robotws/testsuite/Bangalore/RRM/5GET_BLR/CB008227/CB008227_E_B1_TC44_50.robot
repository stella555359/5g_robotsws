*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Documentation
...             INTRODUCTION:     Test cases involving DL and UL CA
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM



*** Variables ***

${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}      2
${sa_ue_id2}      3
${sa_ue_id3}      ${5}
${sa_ue_id4}      ${32}
${sa_ue_id91}      91
${sa_ue_id92}      92
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${QFI_ID1}     2
${QFI_ID2}     3
${TEST_NAME}     TC1
${CELL_ID1}    1
${CELL_ID2}    2
${CELL_ID3}    3
${CELL_ID4}    4
${CELL_ID5}    5

${delta_file_name}=             Delta_CB008227_act_SA.json
${scfc_TC44}=                        ${CURDIR}/config/SCF_DL_5CC_CA_NBR.xml
${AP_TC44}=                      ${CURDIR}/config/iphy_5CC_CA.xml
${wts_cfg_file_TC44}         ${CURDIR}/config/wts_DL_5CC_CA.cfg
${5CC_2F3T_SCELL}             ('1', '51', '25'), ('2', '52', '66'), ('3', '54', '41'), ('4', '55', '41')
${SCFC_TC48}=                        ${CURDIR}/config/2CC_Scell_swap_scf.xml
${AP_XML_TC48}=                      ${CURDIR}/config/2CC_Scell_swap_iphy.xml
${wts_cfg_file_TC48}          ${CURDIR}/config/2CC_Scell_swap_basic_setup.cfg
${Delta_scf_tc48}     Delta_CB008227_IWK_CB008290.json
${Delta_scf_feature_enable}     Delta_CB008227_act.json
${Delta_scf_feature_disable}    Delta_CB008227_deact.json

${Pdu_session_mod_patten}      Pdu Session Resource Modify Response Message with RAN UE NGAP ID 0 handled successfully
${Pdu_session_qos_patten}      QoS Routing Table


*** Test Cases ***
CB008227-E#B3_TC44_Nominal_Bitrate_interworking_with_DL_CA
    [Documentation]
    ...
    ...             author:           Mundanad Vishnu
    ...             maintainer:       mundanad.vishnu@nokia.com
    ...
    ...             INTRODUCTION:     This user scenario describes Nominal Bitrate interworking with DL and UL CA
    ...                               Following Test cases are covered in this script :
    ...                               CB008227-E#B3_TC44_Nominal_Bitrate_interworking_with_DL_CA
    ...                               CB008227-E#B4_TC50_Nominal_Bitrate_interworking_with_UL_CA
    ...                               5CC DL CA with SA configured with below configuration :
    ...                               Cell 1 : FDD Cell, PCI-51, ChBW-20Mhz, Band-25, SCELL-1
    ...                               Cell 2 : FDD Cell, PCI-52, ChBW-20Mhz, Band-66, SCELL-2
    ...                               Cell 3 : FDD Cell, PCI-53, ChBW-20Mhz, Band-71, PCELL
    ...                               Cell 4 : TDD Cell, PCI-54, ChBW-40Mhz, Band-41, SCELL-3
    ...                               Cell 5 : TDD Cell, PCI-55, ChBW-60Mhz, Band-41, SCELL-4
    ...                               2CC UL CA with SA configured with below configuration :
    ...                               Cell 3 : FDD Cell, PCI-53, ChBW-20Mhz, Band-71, PCELL
    ...                               Cell 4 : TDD Cell, PCI-54, ChBW-40Mhz, Band-41, SCELL-1
    ...                               Step 1: Attach single UE with 5CC capable, start data on nonGBR bearer and check througput
    ...                               Step 2: Add 1 NBR bearer to UE, verify CPRT for bearer addition and check throughput
    ...                               Step 3: Add 1 more NBR bearer to UE, verify CPRT for bearer addition and check throughput
    ...                               Step 4: Verify PM counters with respect to 2 NBR bearers scheduled
    ...                               Step 5: Delete 1 NBR bearer from UE, check CPRT for bearer deletion
    ...                               Step 6: Verify PM counters with respect to 1 NBR bearer scheduled
    ...                               Step 7: Detach CA UE
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   5G_RAN_USR_RRM_20682;5G_RAN_USR_RRM_20734;CB_FIM_39326;CB_FIM_39328;CB_FIM_39329


    [Setup]         Run keywords     Log to console      "Suite Setup started"
    ...                 AND     Prepare TL with all config files New      ${scfc_TC44}     ${AP_TC44}
    ...                 AND     Suite setup from scratch
    ...                 AND     Start Default Logging Gnb ASIL_ABIO
    ...                 AND     Configure UTE ETH3 and ETH4 IPs
    ...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC44}

    ${TEST_NAME}    Set Variable   E_B3_TC44_50
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep     10s
    ${cprt_log}      Stop Log    cprt   test_scenario=usersetup
    Verify actNbrForNonGbrBearers In CellReconfigurationReq     ${cprt_log}[cprt]/NODECPRT_GNB.pcap      sctp
    Wait until the next Measurement Period starts
    log to console   "SA UE attach trigerring now"
#Step 1. Attach CA capable SA UE
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    UE Register should be Success   ${sa_ue_id2}
    sleep     5s
    Trigger High DL Traffic SA     ${sa_ue_id2}     1000
    sleep    20s
    Trigger UL Traffic SA      ${sa_ue_id2}      150     qfi_id=${QFI_ID}
    sleep    20s
    Get And Check Scell Infos    ${5CC_2F3T_SCELL}
# Add 1 NBR bearer and start data
    Start Log    cprt
    UE PDU Modfication should be Successful     ${sa_ue_id2}    ${Pdu_session_ID}    ${QFI_ID1}
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup1
    sleep   10s
    Trigger High DL Traffic SA     ue_id=${sa_ue_id2}     dl_rate=${1000}    qfi_id=${QFI_ID1}
    sleep    20s
    Trigger UL Traffic SA      ${sa_ue_id2}      100     qfi_id=${QFI_ID1}
    sleep    20s
    Verify nbrDrbSpecificParams In bearersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16387    495896   86612
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16385    495896
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16386    495896
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16388    495896
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16389    495896

# Add 2 NBR bearer and start data
    Start Log    cprt
    UE PDU Modfication should be Successful     ${sa_ue_id2}    ${Pdu_session_ID}    ${QFI_ID2}
    sleep   2s
    ${path3}    Stop Log    cprt   test_scenario=bearersetup2
    sleep   10s
    Trigger High DL Traffic SA     ue_id=${sa_ue_id2}     dl_rate=${1000}    qfi_id=${QFI_ID2}
    sleep    20s
    Trigger UL Traffic SA      ${sa_ue_id2}      100     qfi_id=${QFI_ID2}
    sleep    20s
    Verify nbrDrbSpecificParams In bearersetupreq   ${path3}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16387    498245   58346
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path3}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16385    498245
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path3}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16386    498245
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path3}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16388    498245
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path3}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16389    498245

    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID3}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID4}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID5}
    ...  file_path=${pm_counter_file}
    Wait until the current Measurement Period stops
    ${pm_counter_file1}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file1}
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file1}
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  M55139C03510  600  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID3}
    ...  file_path=${pm_counter_file1}
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  M55139C03510  0  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID4}
    ...  file_path=${pm_counter_file1}
    Verify Any Counters In File
    ...  M55139C03509  600  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID5}
    ...  file_path=${pm_counter_file1}

# Remove 1 NB bearer and check counters
    Start Log    cprt
    UE PDU Modfication to delete should be Successful       ${sa_ue_id2}    ${Pdu_session_ID}    ${QFI_ID2}
    sleep    10s
    ${path4}    Stop Log    cprt   test_scenario=bearerdelete
    Verify Bearer Delete for all cells      ${path4}[cprt]/NODECPRT_GNB.pcap
    ...        itf_l2_ps_user_BearerDeleteReq_t.nrCellIdentity == 16385
    Verify Bearer Delete for all cells      ${path4}[cprt]/NODECPRT_GNB.pcap
    ...        itf_l2_ps_user_BearerDeleteReq_t.nrCellIdentity == 16386
    Verify Bearer Delete for all cells      ${path4}[cprt]/NODECPRT_GNB.pcap
    ...        itf_l2_ps_user_BearerDeleteReq_t.nrCellIdentity == 16387
    Verify Bearer Delete for all cells      ${path4}[cprt]/NODECPRT_GNB.pcap
    ...        itf_l2_ps_user_BearerDeleteReq_t.nrCellIdentity == 16388
    Verify Bearer Delete for all cells      ${path4}[cprt]/NODECPRT_GNB.pcap
    ...        itf_l2_ps_user_BearerDeleteReq_t.nrCellIdentity == 16389
    Wait until the current Measurement Period stops
    ${pm_counter_file3}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter3
    ${pm_counter_file4}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter4
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file4}
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file4}
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  M55139C03510  300  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID3}
    ...  file_path=${pm_counter_file4}
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  M55139C03510  0  SA_DU_DRB_NBR_UL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID4}
    ...  file_path=${pm_counter_file4}
    Verify Any Counters In File
    ...  M55139C03509  300  SA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID5}
    ...  file_path=${pm_counter_file4}
    Stop Data Traffic for SA for PDU      ${sa_ue_id2}     1
    sleep    30s

#Verify DL and UL throughput with nonNBR bearer and NBR bearer
    Trigger High DL Traffic SA     ${sa_ue_id2}     1000
    sleep    20s
    Validate DL Traffic For SA for high data     ${sa_ue_id2}     950    1     1
    sleep     5s
    Trigger High DL Traffic SA     ue_id=${sa_ue_id2}     dl_rate=${1000}    qfi_id=${QFI_ID1}
    sleep    20s
    Validate DL Traffic For SA for high data     ${sa_ue_id2}     450    1     1
    Validate DL Traffic For SA for high data     ${sa_ue_id2}     500    1     2
    sleep     5s
    Stop Data Traffic for SA for PDU      ${sa_ue_id2}     1
    sleep    30s
    Trigger UL Traffic SA      ${sa_ue_id2}      150     qfi_id=${QFI_ID}
    sleep    20s
    Validate UL Traffic For SA     ${sa_ue_id2}     75    1     1
    sleep     5s
    Trigger UL Traffic SA      ${sa_ue_id2}      150     qfi_id=${QFI_ID1}
    sleep    20s
    Validate UL Traffic For SA     ${sa_ue_id2}     40    1     1
    Validate UL Traffic For SA     ${sa_ue_id2}     45    1     2
    sleep     5s

    UE Deregister should be Successful    ${sa_ue_id2}
    [Teardown]      Run Keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Default Logging Gnb ASIL_ABIO

CB008227-E#B3_TC48_NBR_IWK_DL_CA__A6_Report_Handling_for_Scell_swap_of_TDD_Scell_with_FDD_Pcell_2CC_CA_F_T
    [Documentation]
    ...             author:           Madhukara M V
    ...             maintainer:       madhukara.m_v@nokia.com
    ...             INTRODUCTION:     This user scenario describes NBR interworking  with SCell swap - US CB008290-A#B4
    ...								  A6 Measurement Report Handling for SCell swap of TDD SCell with FDD PCell, 2CC CA
    ...                              (F+T) and to verify interworkig if and only if the maxnbr bearers are staisfied
    ...                               in the target scell.
    ...								 Step 1: attach ue id 91 and 92 to FDD cell 11 and traffic Cell 11: FDD, Cell1,2:TDD
    ...							     Step 2: Trigger A1 measuremnt for adding TDD Scell 1 for ue id 91 and 92
    ...								 step 3: verify NBR DRB config on Pcell and traffic	on both PCell and Scell
    ...								 step 4: Trigger A6 meas for swapping scell 1 to scell 2( maxnumber of nbr bearer=1)
    ...										and verify NBR configured on new scell and NBR tput is achived
    ...								 step 5: Trigger A6 for Ue id 92 and verify this nbr is not configureed
    ...								 Note  : NBR UL is not supported for CA case .. not verifying this
    ...             TEST SET NAME:    CB008227
    ...             TESTING SPLIT:    Refer CB008227 Test Plan
    ...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...             REFERENCES:       CB008227 CFAM
    ...             Requirement ID:   xxxxx

    [Setup]         Run keywords     Log to console      "Suite Setup started"
    ...         Start Log   btslog
    ...         AND     Suite setup from scratch
    ...         AND     Start Default Logging Gnb ASIL_ABIO
    ...         AND     Start WTS Using WTS_Runner      ${wts_cfg_file_TC48}

    ${TEST_NAME}    Set Variable   E_B3_TC48
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Perform SCF Delta Commissioning with ${Delta_scf_tc48}

    log to console   "waiting till next messurement  period"
    Wait until the next Measurement Period starts

#Step : 1 Attach SA ue with CA capable UE with FDD and TDD ue capabilty
# This test will attach 2 ue's to FDD cell 11 and add the TDD scell 1
	Link SCOUT SCF to Configuration ID for Reporting
	Start Log    cprt
    sleep     20s
	MultiUE Register should be Successful    ${sa_ue_id91}     ${sa_ue_id92}
	sleep     5s
    FOR    ${i}    IN RANGE    1   7
        MultiUE Trigger DL Traffic for SA    ${sa_ue_id91}  ${sa_ue_id92}   Traffic_rate=mbps     dl_rate=100
        ...     pdu_id=1     trf_id=${i}     qfi_id=1
    END

	sleep     20s
    Run Keyword and Continue on Failure     Validate DL Traffic For MultiUE for SA   ${sa_ue_id91}  ${sa_ue_id92}
    ...       dl_rate=200   pdu_id=1   qfi_id=1

# verify CPRT logs for NBR specific params in Pcell 11 , NBRDL is 300 and NBR UL is 100 as configured in SCF
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In bearersetupreq   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp    300000  100000

#	Send A1 Messurement Report aboubt TDD scell from Pcell for CA scell for both the Ues


	Trigger A1 Measurement and verify Scell added successfully     ${sa_ue_id91}    5
	Trigger A1 Measurement and verify Scell added successfully     ${sa_ue_id92}    5

#   Verify Traffic on PCell and scell
	sleep     10s
    ${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id91}     0    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${pcell_tput}     133
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id91}     1    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}     485
    Start Log    cprt


#	Verify Scel swap is successfull and nbr is configured for scell index 2 for ued id 1 as maxnbr is configured to 1
#   NBR allowed only if the maxnbr is satisfied, ue id 2 will be admitted as non nbr on swap

	Send A6 Messurement for swapping TDD scell 1 to TDD scell 2 and verify       ${sa_ue_id91}
# 	Verify NBR is configured to ue id -1
	${path2}    Stop Log    cprt   test_scenario=user_bearersetup
    Verify usersetupreq and usermodifyreq for nbrdl and scellindex for CA scellswap
    ...     ${path2}[cprt]/NODECPRT_GNB.pcap    sctp    300000   2
    sleep   10s
#   Verify Traffic on Swapped scell id 2 and see if the NBR is reached to ~300 Mbps

	${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id91}     0    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${pcell_tput}     133
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id91}     2    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}      485

# Swap Scell for ue id 2 also, check nbr is not configured and it is allowed as normal Non-GBR verify ~100 mbps tput
	Send A6 Messurement for swapping TDD scell 1 to TDD scell 2 and verify       ${sa_ue_id92}


    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  M55139C03507  1  SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55139C03508  1  SA_DU_DRB_NBR_ADMIT_WITH_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
    ...  file_path=${pm_counter_file}

    sleep   10s

    ${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id92}     0    Mbps
    Run Keyword and Continue on Failure     Check Average Data Rate      ${pcell_tput}     133
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id92}     2    Mbps
    Run Keyword and Continue on Failure     Check Average Data Rate      ${scell_tput}     485

    MultiUE Deregister should be Successful   ${sa_ue_id91}    ${sa_ue_id92}
    [Teardown]      Run Keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...             AND     Stop Default Logging Gnb ASIL_ABIO

*** Keywords ***

Get And Check Scell Infos
    [Arguments]    ${scells_info}    ${egate_file}=/opt/iphy/latest/egate_console.log
    [Documentation]    This keyword is to get and check Scell Info from egate Log.
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${scells_info} | Yes |expected scell info with the format ('sCellIndex', 'physCellId', 'frequencyBandList') |
    ...    | ${egate_file | No | the egate Log path|
    ...    The keyword return a tuple list, then check whether it include above expected infos defined in ${scells_info}
    ...    Examples:
    ...    | Get And Check Scell Infos | ('1', '51', '2'), ('2', '52', '66')|
    ...
#    wtsrunner.sim_log_set flush
    ${content}    OperatingSystem.Get File    path=${egate_file}
    ${regexp}    Catenate    SEPARATOR=    sCellIndex\\s+(?P<sCellIndex>\\d+),[\\s\\S]*?physCellId\\s(?P<physCellId>\\d+),
    ...    [\\s\\S]*?frequencyBandList\\s+{\\s+(?P<frequencyBandList>\\d+)\\s+},
    ${ret}    String.Get Regexp Matches    ${content}    ${regexp}    sCellIndex    physCellId    frequencyBandList
    ${ret_str}=    Convert To String    ${ret}
    ${ret}=    String.Replace String Using Regexp    ${ret_str}    u    ${EMPTY}
    Log to console    ${ret}
    Should Contain    ${ret}    ${scells_info}

UE PDU Modfication to delete should be Successful
     [Arguments]     ${ue_id}      ${pdu_id}=${Pdu_session_ID}      ${qosflows_to_del}=${QFI_ID2}
     wtsrunner.ue_pdu_session_modify      ue=${ue_id}       pdu=${pdu_id}    qosflows_to_del=${qosflows_to_del}    by=amf
     sleep    5s

Stop Data Traffic for SA for PDU
    [Arguments]    ${ue_id}      ${pdu_id}
    [Documentation]    This keyword stops the Data Traffic for the SA variant
    Log to Console    \nStopping Data Traffic...
    wtsrunner.trf_data_stop     ue=${ue_id}     pdu=${pdu_id}
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Traffic was stopped   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Traffic was stopped   partial_match=${TRUE}
    Log to Console    ${output}

Configure UTE ETH3 and ETH4 IPs
    [Documentation]    This keyword is to configure VM interfaces.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run     sudo ip addr add 10.0.1.122/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run     sudo ip addr add 10.0.2.90/24 dev eth4
    OperatingSystem.Run     sudo ip addr add 10.0.2.91/24 dev eth4


Send A6 Messurement for swapping TDD scell 1 to TDD scell 2 and verify
    [Arguments]       ${ue_id}     ${loc_BW}=
    wtsrunner.ue_meas_cfg_disp     id=${ue_id}    meas_obj_type=nr
    wtsrunner.ue_measurement_send_nr     id=${ue_id}    meas_id=8   event=A6   srsrp_nr=11   srsrq_nr=11   scell=1
    ...          scell_rsrp=20   scell_rsrq=20    phycell_id=53    nrsrp_nr=80   nrsrq_nr=80
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*activated successfully.*  timeout=15
    Get Lines Matching Regexp    ${output}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}

Verify usersetupreq and usermodifyreq for nbrdl and scellindex for CA scellswap
    [Arguments]      ${logpath}       ${filter_req}     ${allownbr_dl_value}   ${allownbr_ul_value}
    [Documentation]      this KW Verifies the nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    log to console       Verifying nbrDrbSpecificParams In usersetupreq captured in CPRT logs
    ${pdmlFile} =    Get filtered PDML file from pcap     ${logpath}       ${filter_req}
    ${allowNBR_DL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usersetupreq
    ...                                                path=.*nbrDl_item$
    ...                                                endPacket=${2}
    ${allowNBR_UL}       analyzer.get_unique          pdmlFile=${pdmlFile}
    ...                                                packetName=itf_l2_ps_user_usermodifyreq
    ...                                                path=.*NbrDrbSCellListItem.sCellIndex$
    ...                                                endPacket=${2}
    Should Contain    ${allowNBR_DL}    ${allownbr_dl_value}
    Should Contain    ${allowNBR_UL}    ${allownbr_ul_value}


Check Average Data Rate
    [Arguments]       ${output}    ${mbps}
    ${result}         Evaluate    (${mbps} * 1.2) > int(${output}) > (${mbps} * 0.85)
    Run Keyword if    ${result}    Log to Console    DL Average data rate: ${output}
    ...               ELSE    BuiltIn.Log     DL Average data rate: ${output}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=DL Average data rate failed!
