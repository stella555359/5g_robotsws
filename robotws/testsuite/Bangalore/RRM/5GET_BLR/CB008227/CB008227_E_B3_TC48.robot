*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_LOO    CRT    RAN_5G_TDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    CONFIGURED

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
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
...             INTRODUCTION:     This user scenario describes NBR interworking  with SCell swap - US CB008290-A#B4
...								  A6 Measurement Report Handling for SCell swap of TDD SCell with FDD PCell, 2CC CA
...                              (F+T) and to verify interworkig if and only if the maxnbr bearers are staisfied
...                               in the target scell.
...								 Step 1: attach ue id 81 and 82 to FDD cell 11 and traffic Cell 11: FDD, Cell1,2:TDD
...							     Step 2: Trigger A1 measuremnt for adding TDD Scell 1 for ue id 81 and 82
...								 step 3: verify NBR DRB config on Pcell and traffic	on both PCell and Scell
...								 step 4: Trigger A6 meas for swapping scell 1 to scell 2( maxnumber of nbr bearer=1)
...										and verify NBR configured on new scell and NBR tput is achived
...								 step 5: Trigger A6 for Ue id 82 and verify this nbr is not configureed
...								 Note  : NBR UL is not supported for CA case .. not verifying this

...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   xxxxx



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/2CC_Scell_swap_basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${sa_ue_id1}   2
${sa_ue_id2}   3
${sa_ue_id3}   6
${sa_ue_id4}   4
${sa_ue_id5}   5


${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC48

${SCFC}=                        ${CURDIR}/config/2CC_Scell_swap_scf.xml
${AP_XML}=                      ${CURDIR}/config/2CC_Scell_swap_iphy.xml
${Delta_scf_feature_enable}     Delta_CB008227_act.json
${Delta_scf_feature_disable}    Delta_CB008227_deact.json
${CELL_ID}    1

*** Test Cases ***
CB008227-E#B3_TC48_NBR_IWK_DL_CA__A6_Report_Handling_for_Scell_swap_of_TDD_Scell_with_FDD_Pcell_2CC_CA_F_T

    set test variable      ${LOG_PATH}
    log to console   "waiting till next messurement  period"
    Wait until the next Measurement Period starts

#Step : 1 Attach SA ue with CA capable UE with FDD and TDD ue capabilty
# This test will attach 2 ue's to FDD cell 11 and add the TDD scell 1
	Link SCOUT SCF to Configuration ID for Reporting
	Start Log    cprt
	MultiUE Register should be Successful    ${sa_ue_id1}     ${sa_ue_id2}
	sleep     5s

    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=175
    ...     pdu_id=1     trf_id=1     qfi_id=1
    MultiUE Trigger DL Traffic for SA    ${sa_ue_id1}  ${sa_ue_id2}   Traffic_rate=mbps     dl_rate=175
    ...     pdu_id=1     trf_id=2     qfi_id=1


	sleep     20s
    Run Keyword and Continue on Failure     Validate DL Traffic For MultiUE for SA   ${sa_ue_id1}  ${sa_ue_id2}
    ...       dl_rate=48   pdu_id=1   qfi_id=1

# verify CPRT logs for NBR specific params in Pcell 11 , NBRDL is 300 and NBR UL is 100 as configured in SCF
    ${path1}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In bearersetupreq   ${path1}[cprt]/NODECPRT_GNB.pcap   sctp    300000  100000

#	Send A1 Messurement Report aboubt TDD scell from Pcell for CA scell for both the Ues


	Trigger A1 Measurement and verify Scell added successfully     ${sa_ue_id1}    3
	Trigger A1 Measurement and verify Scell added successfully     ${sa_ue_id2}    3

#   Verify Traffic on PCell and scell
	sleep     10s
    ${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id1}     0    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${pcell_tput}      48
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id1}     1    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}      248
    Start Log    cprt


#	Verify Scel swap is successfull and nbr is configured for scell index 2 for ued id 1 as maxnbr is configured to 1
#   NBR allowed only if the maxnbr is satisfied, ue id 2 will be admitted as non nbr on swap

	Send A6 Messurement for swapping TDD scell 1 to TDD scell 2 and verify       ${sa_ue_id1}
# 	Verify NBR is configured to ue id -1
	${path2}    Stop Log    cprt   test_scenario=user_bearersetup
    Verify usersetupreq and usermodifyreq for nbrdl and scellindex for CA scellswap
    ...     ${path2}[cprt]/NODECPRT_GNB.pcap    sctp    300000   2
    sleep   10s
#   Verify Traffic on Swapped scell id 2 and see if the NBR is reached to ~300 Mbps

	${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id1}     0    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${pcell_tput}      48
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id1}     2    Mbps
    Run Keyword and Continue on Failure      Check Average Data Rate      ${scell_tput}       300

# Swap Scell for ue id 2 also, check nbr is not configured and it is allowed as normal Non-GBR verify ~100 mbps tput
	Send A6 Messurement for swapping TDD scell 1 to TDD scell 2 and verify       ${sa_ue_id2}


    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55139C03506  2  SA_DU_DRB_NBR_REQ
    ...  M55139C03507  1  SA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  M55139C03508  1  SA_DU_DRB_NBR_ADMIT_WITH_NOT_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-6
    ...  file_path=${pm_counter_file}

    sleep   10s

    ${pcell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id2}     0    Mbps
    Run Keyword and Continue on Failure     Check Average Data Rate      ${pcell_tput}      48
    ${scell_tput} =  Get AVG DL DATA TRAFFIC For Given CC     ${sa_ue_id2}     2    Mbps
    Run Keyword and Continue on Failure     Check Average Data Rate      ${scell_tput}      193

    MultiUE Deregister should be Successful   ${sa_ue_id1}    ${sa_ue_id2}




*** keywords ***


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
    wtsrunner.ue_measurement_send_nr     id=${ue_id}    meas_id=4   event=A6   srsrp_nr=11   srsrq_nr=11   scell=1
    ...          scell_rsrp=20   scell_rsrq=20    phycell_id=55    nrsrp_nr=80   nrsrq_nr=80
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
    ${result}         Evaluate    (${mbps} * 1.1) > int(${output}) > (${mbps} * 0.9)
    Run Keyword if    ${result}    Log to Console    DL Average data rate: ${output}
    ...               ELSE    BuiltIn.Log     DL Average data rate: ${output}    level=ERROR
    Run Keyword and Continue on Failure
    ...               Should Be True    ${result}    msg=DL Average data rate failed!


