*** Settings ***
Documentation   Robot Test Suite for feature CB013511_A_CA_capability_dedicated_mobility_parameters_NSA \n
...             Team: I_MN_RAN_RD_VRF_ULM_VT2 \n
...             Email: i_mn_ran_rd_vrf_ulm_vt2@internal.nsn.com \n

#-----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library     OperatingSystem
Library     taf.hw.rf_attenuator               WITH NAME    attenuator
Library     ute_tshark
Library     taf.sbts.oam.coam.admin
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/connect.robot
Resource    ../resources/syve_testline.robot
Resource    ../resources/attenuator.robot
Resource    ../resources/scf_info.robot
Resource    ../resources/pcap_analysis.robot
Resource    ../resources/sqd63/common_keywords.robot
Resource    CB013511_commissioning.robot
Resource    CB013511_verification.robot
Resource    CB013511_PMverification.robot


*** Keywords ***

Perform Preconditions Of Test Scenario
    [Documentation]    Execution of Test Scenario Pre-Settings
    ...                LNBTS required for SBTS testlines, MRBTS for normal testlines having eNB
    ${RESULTTESTDIR}=    testline.Get Testcase Log Directory
    Set Suite Variable  ${RESULTTESTDIR}
    Log Variables
    Log To Console    \n
    Log To Console    SW Branch: ${GNB_SW_BRANCH}

    IF    'CB013511_A_TC03' in ${TEST TAGS}
        Set GNB Ids  SOURCE_NODE_ID=${0}  TARGET_NODE_ID=${1}  SOURCE_PCELL=${1}  SOURCE_SCELL1=${5}  SOURCE_SCELL2=${10}
        ...    SOURCE_SCELL3=${15}    SOURCE_SCELL4=${20}
    ELSE IF    'CB013511_A_TC05' in ${TEST TAGS}
        Set GNB Ids  SOURCE_NODE_ID=${0}  TARGET_NODE_ID=${1}  SOURCE_PCELL=${2}  TARGET_SCELL1=${2}  TARGET_SCELL2=${3}
        ...    TARGET_SCELL3=${4}
    ELSE IF    'CB013511_A_TC07' in ${TEST TAGS}
        Set GNB Ids  SOURCE_NODE_ID=${0}  TARGET_NODE_ID=${1}  SOURCE_PCELL=${11}  TARGET_SCELL1=${2}  TARGET_SCELL2=${4}
    END
    Log To Console  GNB IDs SET!
    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}  timeout=900s
    Log To Console    Source gNB: ${NRBTS_ID_${SOURCE_NODE_ID}}
    gnb.Get SCF From GNB    gnb_id=${SOURCE_NODE_ID}    target_dir=${CONFIGSUITEDIR}

    ${physCellIdSourcePCell}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_PCELL}
    Set Test Variable     ${physCellIdSourcePCell}
    Log To Console    Source physical PCell Id: ${physCellIdSourcePCell}

    Log To Console  setting Scell Variables
    IF    'CB013511_A_TC03' in ${TEST TAGS}
        ${physCellIdSourceScell1}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL1}
        Set Test Variable     ${physCellIdSourceScell1}
        ${physCellIdSourceScell2}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL2}
        Set Test Variable     ${physCellIdSourceScell2}
        ${physCellIdSourceScell3}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL3}
        Set Test Variable     ${physCellIdSourceScell3}
        ${physCellIdSourceScell4}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL4}
        Set Test Variable     ${physCellIdSourceScell4}
        Log To Console    Target physical SCell Id 1: ${physCellIdSourceScell1}
        Log To Console    Target physical SCell Id 2: ${physCellIdSourceScell2}
        Log To Console    Target physical SCell Id 3: ${physCellIdSourceScell3}
        Log To Console    Target physical SCell Id 4: ${physCellIdSourceScell4}
    END

    Commission Delta GNB_SCF
    Log To Console  Block gNB and cells
     IF    any(tag in @{TEST_TAGS} for tag in ['CB013511_A_TC03', 'CB013511_A_TC05', 'CB013511_A_TC07'])
        Block Unblock Cells In Node  blocked_cells=${NR_CELLS_BLOCK}  technology=NR  status=block
        Block Unblock Cells In Node  blocked_cells=${LTE_CELLS_BLOCK}  technology=LTE  status=block
    ELSE
        Log To Console    NO Blocking required
    END

    Log To Console    \nSet attenuation to max for all cells
    attenuator.Set Attenuator To Max Value
    ute_tshark.Setup Tshark    eth1  preferences=ntrstr.port:20500,20501,49148,4321 ntrstr.defragment:TRUE


Verify QC Test Case
    [Documentation]    Each subfeature will be verified according to given checks
    ...                TCP files are saved Wireshark traces for analysis
    Log To Console    \nStarting TC Verification

    IF  'CB013511_A_TC03' in ${TEST TAGS}
        CB013511_verification.Verification For CB013511_A_RE_TC03
        ...    tcp_files=UE1_CB013511_A_TC03_Part1
    ELSE IF  'CB013511_A_TC05' in ${TEST TAGS}
        CB013511_verification.Verification For CB013511_A_RE_TC05
        ...    tcp_files=UE1_CB013511_A_TC05_Part1
    ELSE IF  'CB013511_A_TC07' in ${TEST TAGS}
        CB013511_verification.Verification For CB013511_A_RE_TC07
        ...    tcp_files=UE1_CB013511_A_TC07_Part1
    END

    Log To Console    \nStarting PM Counter Verification
    IF    '${WITH_PMCOUNTER_CHECK}'=='true'
        IF  'CB013511_A_TC03' in ${TEST TAGS}
            CB013511_PMverification.Verify PM Counters CB013511_A_TC03  tcp_files=UE1_CB013511_A_TC03
        ELSE IF  'CB013511_A_TC05' in ${TEST TAGS}
            CB013511_PMverification.Verify PM Counters CB013511_A_TC05  tcp_files=UE1_CB013511_A_TC05
        ELSE IF  'CB013511_A_TC07' in ${TEST TAGS}
            CB013511_PMverification.Verify PM Counters CB013511_A_TC07  tcp_files=UE1_CB013511_A_TC07
        END
    END


Prepare TL For Testing
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Testline Setup for CCRT
    pcap_analysis.Set Correct F1AP Protocol Name For Wireshark Check
    Set All Suite Variables
    Log To Console  Set All Attenuator Port Mapping
    attenuator_scenario.Register All Attenuators
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${0}
    attenuator_scenario.Get Cell Attenuator Port Mapping  node_id=${1}
    Log To Console  Attenuators OK!


Set All Suite Variables
    [Documentation]    This keyword sets all relevant Suite variables, which are required for test execution
    ${CONFIGSUITEDIR}  testline.Get Test Suite Config Directory
    Set Suite Variable  ${CONFIGSUITEDIR}
    ${RESULTSUITEBASEDIR}=    Get Test Suite Result Base Directory
    Set Suite Variable  ${RESULTSUITEBASEDIR}
    ${TL_NAME}  testline.Get Testline Name
    Set Suite Variable  ${TL_NAME}
    ${GNB_SW_BRANCH}  Get GNB SW Branch
    Set Suite Variable  ${GNB_SW_BRANCH}
    ${MRBTS_ID_0}=  scf_info.Get MRBTS-Id  enb_id=${0}
    Set Suite Variable  ${MRBTS_ID_0}
    ${NRBTS_ID_0}=  scf_info.Get NRBTS-Id  gnb_id=${0}
    Set Suite Variable  ${NRBTS_ID_0}
    ${NRBTS_ID_1}=  scf_info.Get NRBTS-Id  gnb_id=${1}
    Set Suite Variable  ${NRBTS_ID_1}


Set GNB Ids
    [Arguments]    ${SOURCE_NODE_ID}  ${SOURCE_PCELL}  ${SOURCE_SCELL1}=${None}  ${SOURCE_SCELL2}=${None}
    ...            ${SOURCE_SCELL3}=${None}  ${SOURCE_SCELL4}=${None}  ${SOURCE_SCELL5}=${None}  ${TARGET_NODE_ID}=${None}
    ...            ${target_node_type}=${None}  ${TARGET_SCELL1}=${None}  ${TARGET_SCELL2}=${None}  ${TARGET_SCELL3}=${None}
    [Documentation]     Set test variables for target and source ids
    Set Test Variable  ${SOURCE_NODE_ID}    ${SOURCE_NODE_ID}
    Set Test Variable  ${SOURCE_NODE_TYPE}  gnb
    Set Test Variable  ${TARGET_NODE_ID}    ${TARGET_NODE_ID}
    Set Test Variable  ${TARGET_NODE_TYPE}  gnb
    Set Test Variable  ${SOURCE_PCELL}      ${SOURCE_PCELL}
    Set Test Variable  ${SOURCE_SCELL1}     ${SOURCE_SCELL1}
    Set Test Variable  ${SOURCE_SCELL2}     ${SOURCE_SCELL2}
    Set Test Variable  ${SOURCE_SCELL3}     ${SOURCE_SCELL3}
    Set Test Variable  ${SOURCE_SCELL4}     ${SOURCE_SCELL4}
    Set Test Variable  ${SOURCE_SCELL5}     ${SOURCE_SCELL5}
    Set Test Variable  ${TARGET_SCELL1}     ${TARGET_SCELL1}
    Set Test Variable  ${TARGET_SCELL2}     ${TARGET_SCELL2}
    Set Test Variable  ${TARGET_SCELL3}     ${TARGET_SCELL3}


Start UL And DL Traffic
    [Documentation]     start DL/UL Traffic on default PDU and second PDU
    [Arguments]    ${transfer}  ${dl_throughput}  ${ul_throughput}  ${duration_dl}  ${duration_ul}
    ${dl_dt_name}=  Set Variable    DT_DL_${UE_ALIAS_1}_${transfer}
    ${ul_dt_name}=  Set Variable    DT_UL_${UE_ALIAS_1}_${transfer}
    taf.ue.Start Data Transfer    ${dl_dt_name}  ${UE_ALIAS_1}  DL  duration=${duration_dl}
    ...    throughput=${dl_throughput}    protocol=${DL_PROTOCOL}  packet_size=1300
    taf.ue.Start Data Transfer    ${ul_dt_name}  ${UE_ALIAS_1}  UL  duration=${duration_ul}
    ...    throughput=${ul_throughput}    protocol=${UL_PROTOCOL}  packet_size=1300
    RETURN    ${dl_dt_name}    ${ul_dt_name}


Await UL And DL Traffic
    [Documentation]     Await UL And DL Traffic to finish
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  ${dl_dt_name}
    Run Keyword And ignore Error  taf.ue.Await Data Transfer Finish  ${ul_dt_name}


Stop DL And UL Traffic And Check Throughput
    [Documentation]     Stop DL/UL Traffic and check throughput with given deviation
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}
    taf.ue.Stop Data Transfer    ${dl_dt_name}
    taf.ue.Stop Data Transfer    ${ul_dt_name}


Commission Delta GNB_SCF
    [Documentation]     Settings for file commissioning and executiong of Delta commissioning
    ...                 Set all gnb variables
    Log To Console  Setting Commissioning Variables
    Set Suite Variable  ${bts_host_gnb}  ${tl.gnbs[${SOURCE_NODE_ID}].cu.oam_ssh_connection_details.addr}
    Set Suite Variable  ${basic_scf_name_gnb_${SOURCE_NODE_ID}}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${gnb_sw_branch}/${tl_name}/GNB-${SOURCE_NODE_ID}/scf.xml
    Set Suite Variable  ${basic_scf_name_gnb_${TARGET_NODE_ID}}
    ...  /mnt/etfiles/config/entitytests-tools/PzUlm_CRT_TL_configs/${gnb_sw_branch}/${tl_name}/GNB-${TARGET_NODE_ID}/scf.xml
    Set Suite Variable   ${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}
    ...    ${configSuiteDir}/scf_updated_gnb_${SOURCE_NODE_ID}_Part1.xml
    Set Suite Variable   ${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1_1}
    ...    ${configSuiteDir}/scf_updated_gnb_${SOURCE_NODE_ID}_Part1_1.xml
    Set Suite Variable   ${target_scf_name_gnb_${SOURCE_NODE_ID}_Part2}
    ...    ${configSuiteDir}/scf_updated_gnb_${SOURCE_NODE_ID}_Part2.xml
    Set Suite Variable   ${target_scf_name_gnb_${SOURCE_NODE_ID}_Part3}
    ...    ${configSuiteDir}/scf_updated_gnb_${SOURCE_NODE_ID}_Part3.xml
    Set Suite Variable   ${target_scf_name_gnb_${TARGET_NODE_ID}_Part1}
    ...    ${configSuiteDir}/scf_updated_gnb_${TARGET_NODE_ID}_Part1.xml
    Set Suite Variable   ${target_scf_name_gnb_${TARGET_NODE_ID}_Part2}
    ...    ${configSuiteDir}/scf_updated_gnb_${TARGET_NODE_ID}_Part2.xml
    Set Suite Variable  ${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part1}
    ...                 ${configSuiteDir}/delta_scf_${SOURCE_NODE_ID}_Part1.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part1_1}
    ...                 ${configSuiteDir}/delta_scf_${SOURCE_NODE_ID}_Part1_1.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part2}
    ...                 ${configSuiteDir}/delta_scf_${SOURCE_NODE_ID}_Part2.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part3}
    ...                 ${configSuiteDir}/delta_scf_${SOURCE_NODE_ID}_Part3.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part1}
    ...                 ${configSuiteDir}/delta_scf_${TARGET_NODE_ID}_Part1.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part2}
    ...                 ${configSuiteDir}/delta_scf_${TARGET_NODE_ID}_Part2.json
    Set Suite Variable  ${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part3}
    ...                 ${configSuiteDir}/delta_scf_${TARGET_NODE_ID}_Part3.json
    Set Suite Variable  ${revert_delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part1}
    ...                 ${configSuiteDir}/revert_delta_scf_${TEST TAGS[${0}]}_${SOURCE_NODE_ID}.json
    Set Suite Variable  ${revert_delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part1}
    ...                 ${configSuiteDir}/revert_delta_scf_${TEST TAGS[${0}]}_${TARGET_NODE_ID}.json
    Log To Console    \Loading delta gnb scf parameters

    Log To Console  Starting Delta Commissioning
    CB013511_commissioning.Execute GNB Delta Commission JSON For CB013511 GNB-0  nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
    ...        target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}
    ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${SOURCE_NODE_ID}_Part1}

    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}  timeout=900s
    gnb.Wait Until Node To Be Onair State   node_id=${TARGET_NODE_ID}  timeout=900s


Revert Commission Delta GNB_SCF
    [Documentation]     Reverting delta file commissioning and executiong Revert commissioning
    Log To Console    \Revert delta commissioning
    syve_testline.Load Initial GNB SCF For CCRT


Perform Postconditions Of Test Scenario
    ute_tshark.Teardown Tshark
    attenuator.Set Attenuator To Max Value
    syve_testline.Save Current Loads


CB013511 Teardown
    [Documentation]  Teardown CB013511

    Block Unblock Cells In Node  blocked_cells=${NR_CELLS_BLOCK}  technology=NR  status=unblock
    Block Unblock Cells In Node  blocked_cells=${LTE_CELLS_BLOCK}  technology=LTE  status=unblock

    CB013511_keywords.Revert Commission Delta GNB_SCF
    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}  timeout=900s
    gnb.Wait Until Node To Be Onair State   node_id=${TARGET_NODE_ID}  timeout=900s

    common_keywords.Combined Test Teardown


Block Unblock Cells In Node
    [Documentation]  Block cells according to given cell list for node_type
    [Arguments]  ${blocked_cells}  ${technology}=NR  ${status}=block  ${node_type}=gnb

    IF    '${technology}'=='LTE' and '${node_type}'=='enb'
        ${dist_name}  Set Variable  MRBTS-${MRBTS_ID_0}/LNBTS-${MRBTS_ID_0}/LNCEL-
    ELSE
        ${dist_name}  Set Variable  MRBTS-${NRBTS_ID_0}/NRBTS-${NRBTS_ID_0}/NRCELL-
    END

    ${oam_alias}  connect.Setup OAM HTTP Session  node_type=${node_type}  node_id=${0}
    IF    '${status}'=='block'
        FOR  ${cellid}  IN  @{blocked_cells}
            admin.Block Cell  dist_name=${dist_name}${cellid}
            ...               connection=${oam_alias}
        END
    ELSE
         FOR  ${cellid}  IN  @{blocked_cells}
            admin.Unblock Cell  dist_name=${dist_name}${cellid}
            ...               connection=${oam_alias}
         END
    END


Set Cell Attenuation On
    [Documentation]    Depending on Source or Target Node attenuator setting the following parameters shall be given
    ...                ${node}:     TARGET NODE | SOURCE NODE
    ...                ${<cell_id>}:  Cell to be attenuated
    ...                ${10}:        attenuation value
    ...                example:    Set Cell Attenuation On  SOURCE NODE  ${Pcell}  ${10}
    ...                            Set Cell Attenuation On  TARGET NODE  ${Scell}  ${0}
    [Arguments]    ${node}  @{cell_attenuations}

    FOR    ${cell}   ${attenuation}   IN    @{cell_attenuations}
        attenuator_scenario.Set Cell Attenuation  globalcellid=${cell}
        ...                                       value=${attenuation}
        ...                                       node_id=${${node}_ID}
        ...                                       node_type=${${node}_TYPE}
    END

