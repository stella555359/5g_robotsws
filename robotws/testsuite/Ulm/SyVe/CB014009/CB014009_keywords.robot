*** Settings ***
Documentation   Robot Test Suite for feature CB014009 Buffer-based step-wise NR FR1 SCell addition \n
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
Resource    CB014009_TC01_TC02_commissioning.robot
Resource    CB014009_TC03_commissioning.robot
Resource    CB014009_PMverification.robot


*** Keywords ***

Perform Preconditions Of Test Scenario
    [Documentation]    Execution of Test Scenario Pre-Settings
    ...                LNBTS required for SBTS testlines, MRBTS for normal testlines having eNB
    ${RESULTTESTDIR}=    testline.Get Testcase Log Directory
    Set Suite Variable  ${RESULTTESTDIR}
    IF    'TL364' in ${Test Tags}
        ${MRBTS_ID_0}=  scf_info.Get MRBTS-Id  enb_id=${0}
        Set Suite Variable  ${MRBTS_ID_0}
    ELSE
        ${LNBTS_ID_0}=  scf_info.Get LNBTS-Id  gnb_id=${0}
        Set Suite Variable  ${LNBTS_ID_0}
    END
    Log Variables
    Log To Console    \n
    Log To Console    SW Branch: ${GNB_SW_BRANCH}


    IF    'CB014009_TC01' in ${TEST TAGS}
        CB014009_keywords.Set GNB Ids  SOURCE_NODE_ID=${0}  TARGET_NODE_ID=${1}  SOURCE_PCELL=${1}  SOURCE_SCELL1=${4}  SOURCE_SCELL2=${7}
        ...    SOURCE_SCELL3=${10}  SOURCE_SCELL4=${18}  SOURCE_SCELL5=${19}
    ELSE IF    'CB014009_TC02' in ${TEST TAGS}
        CB014009_keywords.Set GNB Ids  SOURCE_NODE_ID=${0}  TARGET_NODE_ID=${1}  SOURCE_PCELL=${4}  SOURCE_SCELL1=${1}  SOURCE_SCELL2=${7}
        ...    SOURCE_SCELL3=${10}  SOURCE_SCELL4=${18}  SOURCE_SCELL5=${19}
    ELSE IF    'CB014009_TC03' in ${TEST TAGS}
        CB014009_keywords.Set GNB Ids  SOURCE_NODE_ID=${0}  TARGET_NODE_ID=${1}  SOURCE_PCELL=${2}  TARGET_SCELL1=${2}  TARGET_SCELL2=${3}
        ...    TARGET_SCELL3=${4}
    END
    Log To Console  GNB IDs SET!
    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}  timeout=900s
    Log To Console    Source gNB: ${NRBTS_ID_${SOURCE_NODE_ID}}
    gnb.Get SCF From GNB    gnb_id=${SOURCE_NODE_ID}    target_dir=${CONFIGSUITEDIR}

    ${physCellIdSourcePCell}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_PCELL}
    Set Test Variable     ${physCellIdSourcePCell}
    Log To Console    Source physical PCell Id: ${physCellIdSourcePCell}

    Log To Console  setting Scell Variables
    IF    'CB014009_TC01' in ${TEST TAGS} or 'CB014009_TC02' in ${TEST TAGS}
    ${physCellIdSourceScell1}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL1}
    Set Test Variable     ${physCellIdSourceScell1}
    ${physCellIdSourceScell2}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL2}
    Set Test Variable     ${physCellIdSourceScell2}
    ${physCellIdSourceScell3}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL3}
    Set Test Variable     ${physCellIdSourceScell3}
    ${physCellIdSourceScell4}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL4}
    Set Test Variable     ${physCellIdSourceScell4}
    ${physCellIdSourceScell5}=  scf_info.Get PhysCellId  gnb_id=${SOURCE_NODE_ID}  nrcell_id=${SOURCE_SCELL5}
    Set Test Variable     ${physCellIdSourceScell5}
    Log To Console    Source physical SCell Id 1: ${physCellIdSourceScell1}
    Log To Console    Source physical SCell Id 2: ${physCellIdSourceScell2}
    Log To Console    Source physical SCell Id 3: ${physCellIdSourceScell3}
    Log To Console    Source physical SCell Id 4: ${physCellIdSourceScell4}
    Log To Console    Source physical SCell Id 5: ${physCellIdSourceScell5}
    ELSE
            ${physCellIdTargetScell1}=  scf_info.Get PhysCellId  gnb_id=${TARGET_NODE_ID}  nrcell_id=${TARGET_SCELL1}
        Set Test Variable     ${physCellIdTargetScell1}
        ${physCellIdTargetScell2}=  scf_info.Get PhysCellId  gnb_id=${TARGET_NODE_ID}  nrcell_id=${TARGET_SCELL2}
        Set Test Variable     ${physCellIdTargetScell2}
        ${physCellIdTargetScell3}=  scf_info.Get PhysCellId  gnb_id=${TARGET_NODE_ID}  nrcell_id=${TARGET_SCELL3}
        Set Test Variable     ${physCellIdTargetScell3}
        Log To Console    Target physical SCell Id 1: ${physCellIdTargetScell1}
        Log To Console    Target physical SCell Id 2: ${physCellIdTargetScell2}
        Log To Console    Target physical SCell Id 3: ${physCellIdTargetScell3}
    END

    CB014009_keywords.Commission Delta GNB_SCF
    Log To Console  Block gNB cells
    IF    'CB014009_TC01' in ${TEST TAGS} or 'CB014009_TC02' in ${TEST TAGS}
        Block Unblock Cells In SBTS Node  blocked_cells=${NR_CELLS_BLOCK}  technology=NR  status=block
    ELSE
        Log To Console    NO Blocking required
    END

    Log To Console  Block eNB cells
    IF    'CB014009_TC01' in ${TEST TAGS} or 'CB014009_TC02' in ${TEST TAGS}
        CB014009_keywords.Block Unblock Cells In SBTS Node  blocked_cells=${LTE_CELLS_BLOCK}  technology=LTE  status=block
    END
    Log To Console    \nSet attenuation to max for all cells
    attenuator.Set Attenuator To Max Value
    ute_tshark.Setup Tshark    eth1  preferences=ntrstr.port:20500,20501,49148,4321 ntrstr.defragment:TRUE


Verify QC Test Case
    [Documentation]    Each subfeature will be verified according to given checks
    ...                TCP files are saved Wireshark traces for analysis
    Log To Console    \nStarting TC Verification


    IF  'CB014009_TC01' in ${TEST TAGS}
        CB014009_verification.Verification For CB014009_TC01
        ...    tcp_files=UE1_CB014009_TC01_Part1,UE1_CB014009_TC01_Part2,UE1_CB014009_TC01_Part3
    ELSE IF  'CB014009_TC02' in ${TEST TAGS}
        CB014009_verification.Verification For CB014009_TC02
        ...    tcp_files=UE1_CB014009_TC02_Part1,UE1_CB014009_TC02_Part2,UE1_CB014009_TC02_Part3
    ELSE IF  'CB014009_TC03' in ${TEST TAGS}
        CB014009_verification.Verification For CB014009_TC03
        ...    tcp_files=UE1_CB014009_TC03_Part1,UE1_CB014009_TC03_Part2,UE1_CB014009_TC03_Part3,UE1_CB014009_TC03_Part4
    END

    Log To Console    \nStarting PM Counter Verification
    IF    '${WITH_PMCOUNTER_CHECK}'=='true'
        IF  'CB014009_TC01' in ${TEST TAGS}
            CB014009_PMverification.Verify PM Counters CB014009_TC01
        ELSE IF  'CB014009_TC02' in ${TEST TAGS}
            CB014009_PMverification.Verify PM Counters CB014009_TC02
        ELSE IF  'CB014009_TC03' in ${TEST TAGS}
            CB014009_PMverification.Verify PM Counters CB014009_TC03
        END
    END

    IF    'CB014009_TC01' in ${TEST TAGS} or 'CB014009_TC02' in ${TEST TAGS}
        IF    ${status_verification_TC}!=True or ${status_PM_Counters}!=True
            Fail    Failure in TC verification or PM Counters from TC01 or TC02
        END
    END


Prepare TL For Testing
    testline.Create Test Suite Log Folders
    testline.Check TL Infos
    syve_testline.Testline Setup for CCRT
    pcap_analysis.Set Correct F1AP Protocol Name For Wireshark Check
    CB014009_keywords.Set All Suite Variables
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
    [Arguments]    ${transfer}  ${dl_throughput}  ${ul_throughput}  ${duration_dl}  ${duration_ul}  ${parallel}=${1}
    ${dl_dt_name}=  Set Variable    DT_DL_${UE_ALIAS_1}_${transfer}
    ${ul_dt_name}=  Set Variable    DT_UL_${UE_ALIAS_1}_${transfer}
    IF    'CB014009_TC01' in ${TEST TAGS}
        taf.ue.Start Data Transfer    ${dl_dt_name}  ${UE_ALIAS_1}  DL  duration=${duration_dl}
        ...    throughput=${dl_throughput}    protocol=${DL_Protocol}  packet_size=1300  parallel=${parallel}
        taf.ue.Start Data Transfer    ${ul_dt_name}  ${UE_ALIAS_1}  UL  duration=${duration_ul}
        ...    throughput=${ul_throughput}    protocol=${UL_Protocol}  packet_size=1300  parallel=${parallel}
    ELSE
        taf.ue.Start Data Transfer    ${dl_dt_name}  ${UE_ALIAS_1}  DL  duration=${duration_dl}
        ...    throughput=${dl_throughput}    protocol=${DL_Protocol}  packet_size=1300
        taf.ue.Start Data Transfer    ${ul_dt_name}  ${UE_ALIAS_1}  UL  duration=${duration_ul}
        ...    throughput=${ul_throughput}    protocol=${UL_Protocol}  packet_size=1300
    END
    RETURN    ${dl_dt_name}    ${ul_dt_name}


Await UL And DL Traffic
    [Documentation]     Await UL And DL Traffic to finish
    [Arguments]    ${dl_dt_name}    ${ul_dt_name}
    Run Keyword And Ignore Error  taf.ue.Await Data Transfer Finish  ${dl_dt_name}
    Run Keyword And Ignore Error  taf.ue.Await Data Transfer Finish  ${ul_dt_name}


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
    IF    'CB014009_TC01' in ${TEST TAGS}
        CB014009_TC01_TC02_commissioning.Execute gNB Delta Commission JSON For CB014009_TC01 gnb-0 Part1
        ...        nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part1}
    ELSE IF    'CB014009_TC02' in ${TEST TAGS}
        CB014009_TC01_TC02_commissioning.Execute gNB Delta Commission JSON For CB014009_TC02 gnb-0 Part1
        ...        nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part1}
    ELSE IF    'CB014009_TC03' in ${TEST TAGS}
        CB014009_TC03_commissioning.Execute gNB Delta Commission JSON For CB014009_TC03 gnb-0  nrbts_id=${NRBTS_ID_0}  gnb_id=${SOURCE_NODE_ID}
        ...        target_scf_name_gnb=${target_scf_name_gnb_${SOURCE_NODE_ID}_Part1}
        ...        delta_scf_recommissioning_name=${delta_scf_recommissioning_name_${TARGET_NODE_ID}_Part1}
    END

    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}  timeout=900s


Revert Commission Delta GNB_SCF
    [Documentation]     Reverting delta file commissioning and executiong Revert commissioning
    Log To Console    \Revert delta commissioning
    IF  'CB014009_TC01' in ${TEST TAGS}
        syve_testline.Load Initial GNB SCF For CCRT  gnb_id=${0}
    ELSE
        syve_testline.Load Initial GNB SCF For CCRT
    END


Perform Postconditions Of Test Scenario
    ute_tshark.Teardown Tshark
    attenuator.Set Attenuator To Max Value
    syve_testline.Save Current Loads


CB014009 Teardown
    [Documentation]  Teardown CB014009
    IF    'CB014009_TC01' in ${TEST TAGS} or 'CB014009_TC02' in ${TEST TAGS}
        Block Unblock Cells In SBTS Node  blocked_cells=${NR_CELLS_BLOCK}  technology=NR  status=unblock
        Block Unblock Cells In SBTS Node  blocked_cells=${LTE_CELLS_BLOCK}  technology=LTE  status=unblock
    END

    CB014009_keywords.Revert Commission Delta GNB_SCF
    gnb.Wait Until Node To Be Onair State   node_id=${SOURCE_NODE_ID}  timeout=900s

    common_keywords.Combined Test Teardown  node_type=sbts


Block Unblock Cells In SBTS Node
    [Documentation]  LTE Block cells according to given cell list
    [Arguments]  ${blocked_cells}  ${technology}=NR  ${status}=block  ${node_type}=gnb

    IF    '${technology}'=='LTE'
        ${dist_name}  Set Variable  MRBTS-${NRBTS_ID_0}/LNBTS-${LNBTS_ID_0}/LNCEL-
    ELSE
        ${dist_name}  Set Variable  MRBTS-${NRBTS_ID_0}/NRBTS-${NRBTS_ID_0}/NRCELL-
    END

    ${oam_alias}  connect.Setup OAM HTTP Session  node_type=gnb  node_id=${0}
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
    connect.Teardown OAM HTTP Session  node_type=${node_type}  node_id=${0}


Set Cell Attenuation On
    [Documentation]    Depending on Source or Target Node attenuator setting the following parameters shall be given
    ...                ${node}:     TARGET NODE | SOURCE NODE
    ...                ${<cell_id>}:  Cell to be attenuated
    ...                ${10}:        attenuation value
    ...                example:    Set Cell Attenuation On  SOURCE NODE  ${Pcell}  ${10}
    ...                            Set Cell Attenuation On  TARGET NODE  ${Scell}  ${0}
    [Arguments]    ${node}  @{cell_attenuations}

    IF    '${node}'=='TARGET NODE'
        ${node_id}    Set Variable  ${TARGET_NODE_ID}
        ${node_type}  Set Variable  ${TARGET_NODE_TYPE}
    ELSE
        ${node_id}    Set Variable  ${SOURCE_NODE_ID}
        ${node_type}  Set Variable  ${SOURCE_NODE_TYPE}
    END
    FOR    ${cell}   ${attenuation}   IN    @{cell_attenuations}
        attenuator_scenario.Set Cell Attenuation  globalcellid=${cell}
        ...                                       value=${attenuation}
        ...                                       node_id=${node_id}
        ...                                       node_type=${node_type}
    END
