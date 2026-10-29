*** Settings ***
#Force Tags      CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
#...             CRT    RAN_5G    5G_RAN_TDD     master_vDU    vDUCNF22R4

Documentation
...             author:            Manasa Shankarappa
...             maintainer:        manasa.shankarappa@nokia.com
...
...             INTRODUCTION:      CB010411
...             TEST SET NAME:     CB010411-CB008444-A_PUSCH_performance.robot
...             TESTING SPLIT:     See CB0010411 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB010411 CFAM

Library             taf.gnb.oam.coam.vdu.interface.Vdu      WITH NAME    vdu
Library             taf.gnb.oam.coam.cu.interface.cu        WITH NAME    cu
Library             taf.transport.ssh           WITH NAME    taf_ssh
Resource            ../resources/robot/WTS_Runner_Keywords.robot
Resource            ../resources/robot/AIC_Common_Keywords.robot
Resource            ../resources/robot/Common_Keywords.robot
Resource            ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource            resources/ConformanceTest_keywords_AiC.robot
Resource            ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_log.robot
Resource            taf/rfrl/cbts/robot/vdu/vdu_operations.robot

Library            ./python/update_iphy_aic.py

Suite Setup             Run keywords      Test Suite Setup
...                     AND       AIC Software Build Info
...                     AND       Fetch Taf Library used in TL
#...                     AND       Log to console    Performing full commissioning
#...                     AND       Prepare AIC TL with all config files   ${vcu_file_path}    ${vdu_file_path}    ${iphy_file_path}
...                     AND       Update vDU TargetBDxml contents in AP_iphyxml for all RMODs    ${iphy_file_path}
...                     AND       Fast Delta Commission vDU With Delta XML File      ${delta_vdu2}
...                     AND       BuiltIn.Run Keyword And Ignore Error   AP Reboot Wait For Connection    ${120}
...                     AND       BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}    
...                     AND       Fast Delta Commission vDU With Delta XML File      ${delta_vdu1}
...                     AND       Fast Delta Commission vCU Using Delta XML File     ${delta_vcu1}    
...                     AND       Log to console   loading cfg file...
...                     AND       Start WTS Using WTS_Runner      ${wts_cfg_file}
...                     AND       Fast Delta Commission vDU With Delta XML File      ${delta_vdu}
...                     AND       BuiltIn.Run Keyword And Ignore Error   Verify RMODs Online Status       ${800}

Suite Teardown         Run keywords        Suite Teardown

*** Variables ***
${iphy_file_path}  ${CURDIR}/config/iphy_2T_2F_AHFII.xml
${wts_cfg_file}    ${CURDIR}/config/basic_FDD_1cell.cfg
${vcu_file_path}   ${CURDIR}/config/vCU_40Mhz_1cell.xml
${vdu_file_path}   ${CURDIR}/config/vDU_40Mhz_1cell.xml
${delta_vdu1}      ${CURDIR}/config/vDu_delta.xml
${delta_vcu1}      ${CURDIR}/config/vCu_delta.xml
${delta_vdu2}      ${CURDIR}/config/vDu_delta_2.xml


${WTS_DIR}          /opt/iphy/latest
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${epc_log_path}    /tmp/
${delta_vdu}        ${CURDIR}/config/SBTS24R2/Delta_configuration_scf_MRBTS-1_DU-11133_BLR_Thor_2cell_TDD_SA.xml

${gscn_value}   1
@{conformance_params}     SStartConformanceTestReq      frcIndex      ulDmrsMappingType     prbOffset
...       i11Codebook4AntPorts    ruMode    StartConformanceTestResp    ENgStatus
@{cellsetup_params}    CellSetupReq_t

*** Test Cases ***
[1]CB008444_B_011_Performance testing of UCI multiplexed on PUSCH for FR1 FDD-CPRI-non-beamforming, ABIO, eCPRI, 40 MHz
    [Setup]     Run keywords        Log to console     \n-----> Test Setup <-----
    ...         AND                 Testcase Setup
    ...         AND                 Wait Until Keyword Succeeds    10 min     10 sec    Check TDS Mode

    Start Syslog Monitoring
    ${beampattern}       Create List       ${20}   ${20}  ${20}  ${20}
    Start Performance Test PUSCH CB008444
    ...                             reporting_int=0.2
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=52
    ...                             frcIndex=G-FR1-A4-9
    ...                             mapType=A
    ...                             nrarfcn_dl=391660
    ...                             nrarfcn_ul=377460
    ...                             nrcell_id=3
    sleep    1s    reason=Wait for successful response from admin
    Stop and Collect Syslog Monitoring
    Run Keyword And Continue on Failure           Stop PUSH Test model    nrcell_id=3
    Validate Conformance test results in Syslog    syslog     ${conformance_params}
    Validate CellSetup in Syslog    syslog     ${cellsetup_params}
    [Teardown]       Run Keyword And Ignore Error           Stop and Collect Syslog Monitoring

*** Keywords ***
Update vDU TargetBDxml contents in AP_iphyxml for all RMODs
    [Arguments]     ${iphy_xml_path}
    Log to console    "Processing iphy xml file" ${iphy_xml_path}
    ${rmod_name_bldver}   Create Dictionary
    ${rmod_name_swkey}    Create Dictionary
    ${alias}    get_unique_id_string
    ssh_conn.Connect To Vdu Cloud Hosting    using_tenant=${True}   prompt=${EMPTY}   vdu_index=0   gnb_index=0
    ...  alias=${alias}
    ${ns}   tl_config.get_vdu_namespace    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${preferredVlanId}     Grep vDU FHM vlanid from default path
    ${cardname}=   operatingSystem.Run    grep -i cardname ${iphy_xml_path} | awk -F "<|>" '{print $3}'
    @{cardname}=   Split String    ${cardname}    \n
    Log to console    List of RMODs @{cardname}
    FOR   ${RMOD_name}   IN   @{cardname}
        ${Build_version}  ${SwFileKey_version}=      Grep Build and SwFileKey version from vDU_TargetBDxml   ${ns}   ${alias}    ${RMOD_name}
        Set To Dictionary   ${rmod_name_bldver}    ${RMOD_name}    ${Build_version}
        Set To Dictionary   ${rmod_name_swkey}     ${RMOD_name}    ${SwFileKey_version}
    END
    Log to console   rmod_name_bldver ${rmod_name_bldver}
    Log to console   ${rmod_name_swkey}
    Set Suite Variable  ${preferredVlanId}
    parse_xml_update_value   ${iphy_xml_path}   ${rmod_name_bldver}
    Copy the iphy xml to Airphone   ${iphy_xml_path}

Copy the iphy xml to Airphone
    [Arguments]    ${iphy_xml_file}
    OperatingSystem.Run     ssh toor4nsn@192.168.200.1 rm -rf /ffs/run/simmode/iphy.xml
    OperatingSystem.Run     scp ${iphy_xml_file} toor4nsn@192.168.200.1:/ffs/run/simmode/
    @{iphy_xml_file_list}=    Split String    ${iphy_xml_file}   /
    ${iphy_file_name}=    Set Variable     ${iphy_xml_file_list}[-1]
    Log to console   iphy_file_name  ${iphy_file_name}
    OperatingSystem.Run     ssh toor4nsn@192.168.200.1 ln -s /ffs/run/simmode/${iphy_file_name} /ffs/run/simmode/iphy.xml




Suite Teardown
    Log to Console    \n-----> Teardown Start <-----

Validate Conformance test results in Syslog
    [Arguments]      ${NAME}    ${conformance_params}
    log to console     Verifying conformance test messages in syslog
    FOR   ${item}   IN    @{conformance_params}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'SStartConformanceTestReq'    Validate SStartConformanceTestReq    ${status}
          #Run Keyword If    '${item}' == 'transmitterTestingConfig'    Validate transmitterTestingConfig    ${status}
          Run Keyword If    '${item}' == 'i11Codebook4AntPorts'    Validate i11Codebook4AntPorts    ${status}
          Run Keyword If    '${item}' == 'ruMode'    Validate ruMode    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'StartConformanceTestResp'    Validate StartConformanceTestResp    ${status}
          Run Keyword If    '${item}' == 'ENgStatus'      Validate ENgStatus    ${status}
          Run Keyword If    '${item}' == 'frcIndex'      Should Contain     ${status}     EFrcIndex = G_FR1_A4_9
          Run Keyword If    '${item}' == 'ulDmrsMappingType'      Should Contain     ${status}     EUlDmrsMappingType = TYPE_A
          Run Keyword If    '${item}' == 'prbOffset'      Should Contain     ${status}     TPrbOffset = 0
    END

Validate CellSetup in Syslog
    [Arguments]      ${NAME}    ${cellsetup_params}
    log to console     Verifying Dl/UL cell setup messages in syslog
    FOR   ${item}   IN    @{cellsetup_params}
          ${status} =   run    command=grep -i "${item}" ${TESTCASE_LOG_PATH}/Syslog_vDU/*
          Should Not Be Empty    ${status}
          Run Keyword If    '${item}' == 'CellSetupReq_t'    Validate DLCellSetup Msg   ${status}
          Run Keyword If    '${item}' == 'CellSetupReq_t'    Validate ULCellSetup Msg   ${status}
    END

Validate DLCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}     "physCellId":52
     Should Contain     ${status}     "dlBandwidth":"P
     Should Contain     ${status}     RBS_216"
     Should Contain     ${status}     "ssbScs":"KHZ_15"
     Should Contain     ${status}     "dlSubcellType":"SUBCELLTYPE_A4"

Validate ULCellSetup Msg
     [Arguments]      ${status}
     Should Contain     ${status}     "physCellId":52
     Should Contain     ${status}     "ulBandwidth":"PRBS_216"
     Should Contain     ${status}     "ssbScs":"KHZ_15"
     Should Contain     ${status}     "ulSubcellType":"SUBCELLT
     Should Contain     ${status}     YPE_A4"

Validate SStartConformanceTestReq
     [Arguments]      ${status}
#     Should Contain     ${status}     TCellIdentity = 62357505
     Should Contain     ${status}     ETypeTest = RECEIVER
     Should Contain     ${status}     TBeamPatternId[4] = [20, 20, 20, 20]
     Should Contain     ${status}     TReportingTimeInterval = 0.2

Validate transmitterTestingConfig
     [Arguments]      ${status}
     Should Contain     ${status}     TestModel = TM3_1
     Should Contain     ${status}     polarization = 0
     Should Contain     ${status}     TPowerBackoff = 0
     Should Contain     ${status}     EMimoRank = MIMO_RANK_1
     Should Contain     ${status}     TCodebook2AntPorts = 0
     Should Contain     ${status}     TReportingTimeInterval = 1
     Should Contain     ${status}     TCodebook2AntPorts = 0
     Should Contain     ${status}     EMimoRank = MIMO_RANK_1

Validate i11Codebook4AntPorts
     [Arguments]      ${status}
     Should Contain     ${status}     TI11Codebook4AntPorts = 0
     Should Contain     ${status}     TI13Codebook4AntPorts = 0
     Should Contain     ${status}     TI2Codebook4AntPorts = 0
Validate ruMode
     [Arguments]      ${status}
     Should Contain     ${status}     ERuMode = NR_ONLY
     Should Contain     ${status}     TPhysCellId = 52

Validate StartConformanceTestResp
     [Arguments]      ${status}
     Should Contain     ${status}     StartConformanceTestResp

Validate ENgStatus
     [Arguments]      ${status}
     Should Contain     ${status}     ENgStatus = OK
