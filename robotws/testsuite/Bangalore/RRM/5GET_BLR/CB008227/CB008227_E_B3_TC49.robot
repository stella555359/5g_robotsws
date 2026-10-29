*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Resource         CB008227_Resource.robot
Resource         ../CB008285/CB008285_Resource.robot
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords     Log to console      "Suite Setup started"
...                 AND     Suite setup from scratch
...                 AND     Configure UTE ETH3 IPs
...                 AND     Prepare TL with config files
...                 AND     Start Default Logging Gnb ASIL_ABIO
...                 AND     Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND     sleep   2s

Suite Teardown      Run Keywords     Run Keyword and Ignore Error     Kill WTS processes Using WTS_Runner
...                 AND     Stop Default Logging Gnb ASIL_ABIO

Documentation
...
...             author:           Vishnu Mundanad
...             maintainer:       mundanad.vishnu@nokia.com
...
...             INTRODUCTION:     This user scenario describes Nominal Bitrate interworking with DL CA for NSA.
...                               2CC DL CA with NSA configured with below configuration :
...                               Cell 1 : TDD Cell, PCI-50, ChBW-60Mhz, Band-41, SCELL-1
...                               Cell 2 : FDD Cell, PCI-51, ChBW-10Mhz, Band-71, PCELL
...                               Step 1: Attach single NSA UE with 2CC capable and start data on nonGBR bearer
...                               Step 2: Add 1 NBR bearer to UE, verify CPRT for bearer addition and check throughput
...                               Step 3: Verify PM counters with resepect to NBR on both PCELL and SCELL
...                               Step 4: Detach NSA CA UE
...
...             TEST SET NAME:    CB008227
...             TESTING SPLIT:    Refer CB008227 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008227 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_20682



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts_NSA_CA_NBR.cfg
${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${nsa_ue_id1}      ${16}
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${TRF_ID}     1
${QFI_ID}     1
${TEST_NAME}     TC1
${CELL_ID1}     1
${CELL_ID2}     2
${delta_file_name}    Delta_CB008227_act.json
${SCFC}=                        ${CURDIR}/config/SCF_NSA_CA_NBR.xml
${AP_XML}=                      ${CURDIR}/config/iphy_NSA_CA.xml

${LTE_Bearer_creation_success}        Bearer-.* .*EBI=.*Q\nCI=.*.* created

*** Test Cases ***
[1]CB008227-E#B3_TC49_Nominal_Bitrate_interworking_with_DL_CA_NSA
    [Tags]     QC_xxxx
    set suite variable     ${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Enable ENDC for all Bearer
    Start Log    cprt
    Perform SCF Delta Commissioning with ${delta_file_name}
    sleep     10s
    ${cprt_log}     Stop Log  cprt  test_scenario=cellsetup
    Verify actNbrForNonGbrBearers In CellReconfigurationReq     ${cprt_log}[cprt]/NODECPRT_GNB.pcap      sctp
    Wait until the next Measurement Period starts
    log to console   "NSA UE attach trigerring now"
#Step 1. Attach NSA CA UE
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    NSA CA UE Register    ${nsa_ue_id1}
    sleep     10s
    Trigger High DL Traffic for NSA   ue_id=${nsa_ue_id1}     Traffic_rate=Mbps     dl_rate=${400}       bearer_id=${2}
    Start Log    cprt
    Add new LTE Bearer for NSA CA UE    ${nsa_ue_id1}    7     7
    sleep   2s
    ${path2}    Stop Log    cprt   test_scenario=bearersetup
    Verify nbrDrbSpecificParams In bearersetupreq   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16386    300000   30000
    Verify nbrDrbSpecificParams In bearersetupreq for Scells   ${path2}[cprt]/NODECPRT_GNB.pcap
    ...         itf_l2_ps_user_BearerSetupReq_t.nrCellIdentity == 16385    300000
    Run Keyword and Continue on Failure    NSA CA UE Start DL Traffic for new Bearer    ${nsa_ue_id1}   7    400
    sleep   60s
    Validate DL Traffic For CA UE

#Validate PM counters in Pcell and Scell
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter1
    Verify Any Counters In File
    ...  M55115C03506  1  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  1  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55115C03506  1  NSA_DU_DRB_NBR_REQ
    ...  M55115C03507  1  NSA_DU_DRB_NBR_ADMIT_WITH_NBR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file}
    Wait until the current Measurement Period stops
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File   output_dirpath=${OUTPUT DIR}/pmcounter2
    Verify Any Counters In File
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID1}
    ...  file_path=${pm_counter_file}
    Verify Any Counters In File
    ...  M55115C03509  300  NSA_DU_DRB_NBR_DL
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${CELL_ID2}
    ...  file_path=${pm_counter_file}
    Stop Data Traffic for NSA    ${nsa_ue_id1}
    NSA CA UE Detach    ${nsa_ue_id1}

*** Keywords ***
Enable ENDC for all Bearer
     wtsrunner.enb_param   id=1   endc_capable_qci=all

NSA CA UE Start DL Traffic for new Bearer
    [Arguments]    ${ue_id}    ${bearer_id}   ${dl_rate}
    Trigger High DL Traffic for NSA   ue_id=${ue_id}     Traffic_rate=Mbps     dl_rate=${dl_rate}      bearer_id=${bearer_id}

Validate DL Traffic For CA UE
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id1}     dl_rate=140   id=2
    Run Keyword and continue on Failure   Validate DL Traffic For NSA   ue_id=${nsa_ue_id1}     dl_rate=250   id=7

Add new LTE Bearer for Multiple UE
     [Arguments]    ${first_ue_id}    ${last_ue_id}    ${bearer_id}   ${precedence}
     FOR    ${ue_id}    IN RANGE    ${first_ue_id}     ${last_ue_id}+${1}
        Add new LTE Bearer   ${ue_id}    ${bearer_id}   ${precedence}
        ENDC Modify for Bearer Addition   ${ue_id}    ${bearer_id}
     END

Add new LTE Bearer for NSA CA UE
    [Arguments]    ${ue_id}   ${bearer_id}   ${precedence}
    Add new LTE Bearer   ${ue_id}    ${bearer_id}   ${precedence}
    ENDC Modify for Bearer Addition   ${ue_id}    ${bearer_id}

NSA CA UE Detach
    [Arguments]    ${ue_id}
    UE Detach should be Successful    ${ue_id}

NSA CA UE Register
    [Arguments]    ${ue_id}
    LTE Attach should be Successful    ${ue_id}
    UE Attach should be Successful     ${ue_id}     ${2}

Add new LTE Bearer
    [Arguments]    ${ue_id}   ${bearer_id}    ${precedence}
    wtsrunner.bearer_add    ue=${ue_id}   id=${bearer_id}  filter=0  precedence=${precedence}
    ${output}    Read WTS Output Until Pattern Matches    ${LTE_Bearer_creation_success}    ${10}
    Print Matching Lines from Output File    ${output}    ${LTE_Bearer_creation_success}
    Log to console    New LTE Bearer addition is Success
