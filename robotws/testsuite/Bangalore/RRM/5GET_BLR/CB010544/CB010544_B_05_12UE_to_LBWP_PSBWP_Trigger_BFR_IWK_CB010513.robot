*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LOOO
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS24R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: shankar
...              :contact: shankar.karalatti@nokia.com
...         The feature removes restrictions concerning the feature 5GC000937 allowing
...         PRACH frequency position outside the Power Saving Bandwidth Part (PS-BWP)
...         3 dedicated BWP configured with band77: LBWP (100MHZ),SBWP (60MHZ), PSBWP (40MHZ)

...         Activate FR1 TDD PRB pooling extension by setting NRBTS.actBbPoolExtensionTddFr1
...         is set to "TRUE".
...         To get CB010513 enabled, additional settings are required, initiate the
...         validation and activation of the configuration plan
...         NRCELL.actDlMuMimo shall be equal to "FALSE"
...         NRCELL.cellCsiRsImLocationMode shall be equal to 'automatic' or not configured
...         NRCELL.pucchModeSelect shall be equal to 'longPucch'
...         NRCELL.actSuperCell shall be equal to "FALSE"
...         Calls are established, at least one call at each cell.
...         Perform the equal high GBR and/or non-GBR load to each cell
...         The combined ?PRB demand? of all cells in the L1 Pool shall be enough
...         to trigger both Inter and Intra L1 SP Pooling
...         Increase GBR and Non-GBR cell(s) traffic load in L1 SP#1 so the ?all PRB demand
...         ? is higher than the actual PRB capability of SP#1.
...         This triggers the inter L1 SP PRB pooling in the way that free PRBs of the
...         L1 SP#2 are allocated to the L1 SP#1 (L1 PRB capability reconfiguration in example
...         This should also trigger the BBRM to provide ZAB privilege to at least one of the
...         Cells in the L1 SP#1
...         Decrease GBR and non-GBR cell(s) traffic load to low level in L1 SP#1.
...         Increase GBR and/or non-GBR cell(s) traffic load in L1 SP#2 so the ?all PRB
...         demand? is higher than the actual PRB capability of SP#2.
...         Decrease the data on all UEs so that UEs will move to PSBWP, Trigger BFR


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Resource         ../CB007112/resources/CB007112_keywords.robot
Resource         CB010544_Resource.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Prepare TL with IPHY file change
...        AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_CB010544_B_05_12UE_to_LBWP_PSBWP_Trigger_BFR_IWK_CB010513.json
...                 AND    Get and Update BSR SW via gitlab   ${BSR_SW_FILE}
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_8DL.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        2
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}    1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${psbwp_id}     2
${start_ue_id}    1
${end_ue_id}      6
${epc_log_path}    /tmp/
${BSR_SW_FILE}     BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
${AP_XML}=         custom-config/Bangalore/RRM/ET/CB010544/CB010544_B5_10513_iphy.xml

*** Test Cases ***
[1]CB010544_B_05_12UE_to_LBWP_PSBWP_Trigger_BFR_IWK_CB010513
    [Documentation]   This test case verifies functinality of CB010544 with CB010513.
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log  btslog
    Create BeamForming profile attach UE and trigger low data
    Stop Log   btslog  test_scenario=attach
    Start Log  btslog
    Trigger Beam recovery and verify PSBWP through TTI trace
    Stop Log   btslog  test_scenario=beam
    Increase traffic on UE and validate switching to LargeBWP and data traffic
    Stop Data Traffic for SA     ue_id=${UE_ID}
    MultiUE Deregister should be Successful   1   6

*** Keywords ***
Create BeamForming profile attach UE and trigger low data
    Create Beamforming Profile for association of 4 Beams and activate MUE    1      6
    log to console   UE attach trigerring now...
    #Multi UE registration and no rach validation
    ${crnti_list}       Create List
    FOR      ${ue_idx}   IN RANGE    ${1} 	  ${6}+1
    ${rnti}     UE Registered Successfully & Rach validation      ue_id=${ue_idx}
    Append To List    ${crnti_list}   ${rnti}
    END
    set suite variable    ${crnti_list}
    Sleep    5s
    MultiUE Trigger DL Traffic for SA    1   6    Traffic_rate=kbps     dl_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   6    Traffic_rate=kbps     ul_rate=10          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    ${bwpid}    Create List     3    3    3    3    3    3
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}

Trigger Beam recovery and verify PSBWP through TTI trace
    log to console    Trigger beam recovery...
    FOR	    ${ue_idx}   IN RANGE    ${start_ue_id} 	  ${end_ue_id}+1
    Beamcontrol Beam Recovery      ue_id=${ue_idx}    beam_profile_id=2    best_beam=2
    sleep      5s
    Check Rach msg
    END
    ${bwpid}    Create List     3    3    3    3    3    3
    Run keyword and continue on failure     Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    beamrecovery    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
	Validate UE beamid from TTI traces    ${LOG_PATH}/ttitrace_streaming/beamrecovery     ${crnti_list}    ${2}
    Run keyword and ignore error    Validate DL Traffic For MultiUE for SA    1   6     dl_rate=0.010
    Run keyword and ignore error    Validate UL Traffic For MultiUE for SA    1   6     ul_rate=0.010

Increase traffic on UE and validate switching to LargeBWP and data traffic
    MultiUE Trigger DL Traffic for SA    1   6    Traffic_rate=mbps     dl_rate=100          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    MultiUE Trigger UL Traffic for SA    1   6    Traffic_rate=mbps     ul_rate=100          trf_id=${TRF_ID}    qfi_id=${QFI_ID}
    sleep      10s
    ${bwpid}    Create List     1      1      1      1      1      1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    largeBWP    ${crnti_list}
	...     ${bwpid}    ${Branch_22R1}
    Run keyword and continue on failure     Validate DL Traffic For MultiUE for SA    1   6     dl_rate=100
    Run keyword and continue on failure     Validate UL Traffic For MultiUE for SA    1   6     ul_rate=75
