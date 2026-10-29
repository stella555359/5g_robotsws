*** Settings ***
Force Tags      CLOUD_5G_I_MP_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...             CONFIGS_Bangalore/RRM/ET/CB008444/CB008444_B_011_ABIP.yml
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00     CONFIGURED

Documentation
...             author:                 manasa hs, manasa.shankarappa@nokia.com
...             maintainer:             manasa hs, manasa.shankarappa@nokia.com
...
...             INTRODUCTION:      CB008444 Conformance Test and Type Approvals for 5G22R4
...             TEST SET NAME:
...             CB008444_B_011_Performance testing of UCI multiplexed on PUSCH for FR1 FDD-CPRI-non-beamforming, ABIO, CPRI, 40 MHz
...             TESTING SPLIT:     See CB008444-B testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB008444-B CFAM
...

Resource           ../resources/robot/ConformanceConstants/Constants_general_mcshark.robot
Resource           ../resources/robot/ConformanceTest_keywords_mcshark.robot
Resource           ../resources/robot/ConformanceTest_Setup_Env_mcshark.robot
Resource           ../resources/robot/ConformanceConstants/Constants_for_Syslog_mcshark.robot
Resource           ../resources/ECEcommon/common_file_operation.robot

Suite Setup                Run keywords
...                        ConformanceTest_Setup_Env_mcshark.Suite Setup from scratch
...                        AND     Modify IPHY File And Send to Airphone Custom        ${IPHY_FILE}
...                        AND     Send Delta Commissioning     ${delta_filename}     skip_relation_errors=True
...                        AND     sleep    400s    reason=Wait for successful response from admin
...                        AND     Activate Test dedicated Mode
Suite Teardown             TCs Teardown

*** Variables ***
${IPHY_FILE}                    ${CURDIR}/config/iphy_AHFII.xml
${delta_filename}=              ${CURDIR}/config/Delta_config_40MHZ_AHFII.json

&{GNB_ASIK}                ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{AP_ASIK}                 ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik

${test_dn_left}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1
${test_dn_right}    /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1/NR_DOWNLINK_TEST-1


*** Test Cases ***
CB008444_B_011_Performance testing of UCI multiplexed on PUSCH for FR1 FDD-CPRI-non-beamforming, ABIO, eCPRI, 40 MHz
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...          The purpose of this test is to verify from test Tool and gNB point of view, the correct initiation of
    ...          a performance PUCCH test procedure with Test Model set to FR1-FDD: F0-ACK
    ...
    ...         Update configurable IE reportingTimeInterval value range and step to '0.1.. 3600, step 0.1'
    ...         second from webEM/test tool, currently the reportingTimeInterval value range and
    ...         step is '1.. 3600, step 1'second.
    ...
    ...         Special handling for configurable IE receivingSlot and expectationSlot
    ...         that only the LSB 8 bits of the pattern are used for FDD PUCCH/PRACH.
    ...
    ...
    ...     The following IE in messages are verified:
    ...       1. (CPRT)   CpRtCm_StartConformanceTestReq contains {
    ...                  _nrCellIdentity, type==control testingConfig, controlChannelTestType==PUCCH, PUCCH format==F0,
    ...                  receivingSlot, expectationSlot - are equal to ones set in WebElementManager
    ...                 _ruMode is set to NR_ONLY
    ...                 _physCellId is set to 7
    ...            }
    ...
    ...       2. (L2PS)  PsCell_CellSetupReq  contains {
    ...                    * physCellId equal to the same value as in  CpRtCm_StartConformanceTestReq
    ...                    * dlMimoMode (set in NIDD)
    ...           }
    ...
    ...       3. (L1-L3) [L1 logs] UlCell_CellSetupReq contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...            }
    ...
    ...       4. (L1-L3) [L1 logs] DlCell_CellSetupReq  contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 0(CL 2X2)
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check message contents with settings corresponding to F0-ACK (3GPP 38.141-1) and
    ...                       FDD frame structure (3GPP 37.141) {
        ...                 *  DlData_SlotTypeReq (UL, DL and calibration)
        ...                 * _DlData_PatternConfigReq
    ...                 * _UlData_PucchReceiveReq contains {
    ...                         -       pucchFormat
        ...                         -   numOfPrb
        ...                         -   nANPucch
        ...                         -   numOfBitsOfUciInformation
        ...                         -   numOfSymbols
        ...                         -   dmrsSymbols
        ...                         -   firstSymbol
        ...                         -   frequencyHopping
        ...                         -   modulationType
    ...                   }
    ...                 * IE prbOffset set to 0
    ...                 * IE largestPrbIndex set to 200
    ...                 * IE startPrb: set to prbOffset under structure pucch in PsTM_StartConformanceTest
    ...                 * IE secondHopPrb: largestPrbIndex - (numOfPrb - 1), where largestPrbIndex from PsTM_StartConformanceTestReq.
    ...                 * _UlData_PucchReceiveRespHarqD
    ...           }
    ...
    ...
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AHFII
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15519, 5G_RAN_USR_RRM_15520, 5G_RAN_USR_RRM_15521
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   I_MN_RAN_L2_5G_BLR_ET_ALL_GMS
    ...  AUTHOR:     manasa.shankarappa@nokia.com
    ...
    ...  REFERENCES:   CB008444 CFAM
    ...
    ...
    Set test log path
    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${10}   ${10}
    Start Collecting Syslog
    Start Performance Test PUSCH UCI     reporting_int=.7
    ...                             beamPatternId=${beampattern}
    ...                             ru_mode=NR_Only
    ...                             pci=187
    ...                             frcIndex=G_FR1_A4_9
    ...                             mapType=B
    ...                             nrarfcn_ul=135760
    ...                             nrarfcn_dl=126380
    sleep    3s    reason=Wait for successful response from admin
    Stop CPRT capture   ${CaptureCPRT}

    Get Information elements from StartConformanceTestReq message for Long PUCCH TCs and verify
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Run Keyword and Continue on Failure     Verify that DlCell_CellSetupReq contains dlMimoMode set to 3 (OL 4x4 Or 4x2 MIMO)
    Run Keyword and Continue on Failure     Verify the Reporting Time Interval between the MeasurementRepInd messages   0.7
    Run Keyword and Continue on Failure     Verify the detected and missed counters in the MeasurementRepInd messages for Pusch

    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture    ${CaptureL1L2}
    Stop L1L2 capture   ${CaptureL1L2}
    Stop Collecting Syslog

    Run Keyword and Continue on Failure     Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements
    Run Keyword and Continue on Failure     Verify that ULData_PuschReceiveReq message contains the numofUciCsiPart1Bits
    Run Keyword and Continue on Failure     Verify that ULData_PuschReceiveResp message contains array of numofUciCsiPart1Bits

    run keyword and ignore error    Check the syslog contain the startconformance test and other parameters for FDD
    ...       ${CURRENT_SYSLOG_PATH}     pusch    change_beam=False

    [Teardown]  Run Keywords     Stop Test Receiver test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog
    ...         AND       Link SCOUT SCF to Configuration ID for Reporting

CB008444-5G-B_001_Transmitter test model is successful aligned with 09-2020 TS 38.141-1-2-NR-FR1-TM1.1-FDD-CPRI - ABIO
    [Documentation]
    ...
    ...  DESCRIPTION:
    ...
    ...  The purpose of this test is to verify the correct CB008444 22R4
    ...  Update data content of ‘all zero data’ to random data for PDCCH and PDSCH channels,
    ...  random data payload will be generated in 5G-L2-PS and sent to L1-DL for PDCCH and PDSCH channels.
    ...
    ...  The following IE in messages are verified:
    ...       1. (CPRT)   CpRtCm_StartConformanceTestReq contains {
    ...                    _nrCellindentity, type, transmiter testingConfig, polarization) are equal to ones set in WebElementManager
    ...                    - _ruMode is set to NR only
    ...                    - _physCellId
    ...                    - nrCellindentity, type, status=OK
    ...            }
    ...                    CpRtCm_MeasurmentReportInd - check frequency and value of messages toward OAM
    ...
    ...       2. (L2PS)  PsCell_CellSetupReq  contains {
    ...                    * physCellId equal to the same value as in  CpRtCm_StartConformanceTestReq
    ...           }
    ...
    ...       3. (L1-L3) [L1 logs] UlCell_CellSetupReq contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...            }
    ...
    ...       4. (L1-L3) [L1 logs] DlCell_CellSetupReq  contains {
    ...                   * physCellId corresponding to one in CpRtCm_StartConformanceTestReq
    ...                   * DlMimoMode set to 0(CL 2X2)
    ...           }
    ...
    ...       5. (L1-L2) [BIP] Check contents of following messages with specific setting corresponding to TM1_1 {
    ...                   *_DlData_PatternConfigReq
    ...                   *_DlData_PdcchSendReq
    ...                   *_DlData_PdschSendReq
    ...                   *_DlData_PdschPayloadTbSendReq (payload = 0)
    ...           }
    ...
    ...  TESTING TOOLS:  AirPhone, WebEM
    ...
    ...  TEST ENVIRONMENT:
    ...         HARDWARE ID:   AHFIB
    ...
    ...   *REQUIREMENTS COVERAGE:
    ...       *REQUIREMENTS IN SCOPE:  5G_RAN_USR_RRM_15519, 5G_RAN_USR_RRM_15520, 5G_RAN_USR_RRM_15521
    ...
    ...  REQUIRED LOGS:   Snapshot and IM logs are required by default. If there is any other log that should be taken
    ...                  during the execution of this Test case - list it here
    ...
    ...  CONTACTS:   I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
    ...
    ...  REFERENCES:   CB008444 CFAM, 5G_RAN_USR_8146
    ...


    ${capture_cprt}     Capture CPRT Set Upon Config
    Set test variable    ${CaptureCPRT}    ${capture_cprt}
    Set CPRT capture    ${CaptureCPRT}
    ${beampattern}       Create List       ${10}   ${10}
    Start Collecting Syslog
    Run Keyword And Continue On Failure       Link SCOUT SCF to Configuration ID for Reporting
    Start DL Test Transmitter    test_model=TM1_1
    ...                          ru_mode=NR_Only
    ...                          pci=187
    ...                          polarization=P_both
    ...                          beamPatternId=${beampattern}
    ...                          power_backoff=0
    ...                          mimo_rank=1
    ...                          p_max=30
    sleep    1ms    reason=Wait for successful response from admin
    ${changebeampattern}       Create List       ${69}   ${69}
    ${test_dn_rcvr}    set variable if    '${DomainId}' == '1'    ${test_dn_left}    ${test_dn_right}
    Change beamPattern id    ${test_dn_rcvr}        ${changebeampattern}
    Stop CPRT capture  ${CaptureCPRT}

    Get information elements from L2PS_StartConformanceTestReq message
    Get Information Elements from DlCell_SetupReq
    Get Information Elements from UlCell_SetupReq

    Run Keyword and Continue on Failure    Verify that DlCell_CellSetupReq contains dlMimoMode set to 3 (OL 4x4 Or 4x2 MIMO)
    Run Keyword and Continue on Failure    Verify that DlCell_CellSetupReq contains dlBandwidth set to 216
    Run Keyword and Continue on Failure    Get Information Elements from Beampatternchangereq and verify     1     ${changebeampattern}
    Run Keyword and Continue on Failure    Get Information Elements from Beampatternchangeresp and verify    1


    ${capture_l1l2}      Capture L1L2 Set Upon Config
    Set test variable    ${CaptureL1L2}    ${capture_l1l2}
    Set L1L2 capture  ${CaptureL1L2}
    sleep    1ms    reason=Wait for successful response from admin
    Stop L1L2 capture  ${CaptureL1L2}

    Run Keyword and Continue on Failure     Verify that DlData_SlotTypeReq is set in accordance with conformance test requirements

    Run Keyword and Continue on Failure     Verify that ULData_PuschReceiveReq message contains the numofUciCsiPart1Bits
    Run Keyword and Continue on Failure     Verify that ULData_PuschReceiveResp message contains array of numofUciCsiPart1Bits

    Stop Collecting Syslog
    run keyword and ignore error     Check the syslog contain the startconformance test and other parameters for FDD
    ...      ${CURRENT_SYSLOG_PATH}    tm1.1_FDD

    [Teardown]  Run Keywords     Stop Test Transmitter test model
    ...         AND        run keyword if test failed      Stop Collecting Syslog


*** Keywords ***
Modify IPHY File And Send to Airphone Custom
    [Arguments]    ${iphy_path}
    ${RRU_type_list}    Get RRU Type From Local IPHY XML Custom   ${iphy_path}
    FOR    ${RRU_type}    IN    @{RRU_type_list}
        ${RRU_Version}    Get RRU Version From TargetBD File Custom    ${RRU_type}    ${OUTPUT_DIR}
        Modify RRU Version Of IPHY XML Custom    ${iphy_path}    ${RRU_type[0]}    ${RRU_Version}
    END
    Send IPHY XML To Airphone custom    ${iphy_path}

Get RRU Type From Local IPHY XML Custom
    [Arguments]    ${iphy_path}
    ${content}=    OperatingSystem.Get File    path=${iphy_path}
    ${x}  Set Variable  <RE>[\\s\\S]*?<cardName>(?P<RRU_type>\\w+)<\\/cardName>[\\s\\S]*?(?P<Ecpri_tag>[\\w]+)>
    @{RRU_type_for_version}    String.Get Regexp Matches    ${content}    ${x}    RRU_type    Ecpri_tag
    @{RRU_type_list}    String.Get Regexp Matches    ${content}    ${x}    RRU_type
    Set Suite Variable    ${RRU_TYPE_LIST}    ${RRU_type_list}
    Set Suite Variable    ${RRU_TYPE}    ${RRU_type_list[0]}
    Log To Console   RRU Type List from local iphy.xml: ${RRU_type_list}
     Log To Console    RRU Type from local iphy.xml: ${RRU_TYPE}
    [Return]    @{RRU_type_for_version}

Get RRU Version From TargetBD File Custom
    [Arguments]    ${RRU_type}    ${save_dir}
    ${RRU_type}=    Set Variable If    "${RRU_type[0]}"=="AAHF"    AAHF_C1
    ...    "${RRU_type[0]}"=="AEUB"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEHC"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AEQE"    ${RRU_type[0]}_E1
    ...    "${RRU_type[0]}"=="AEUD"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AWEUA"    ${RRU_type[0]}
    ...    "${RRU_type[0]}"=="AHLOA"    ${RRU_type[0]}
    ...    "${RRU_type[1]}"=="ecpri"    ${RRU_type[0]}_E1
    ...    ${RRU_type[0]}
    OperatingSystem.Run
    ...    sshpass -p ${GNB_ASIK.password} scp ${GNB_ASIK.username}@${GNB_ASIK.ip}:/ffs/run/TargetBD_SB*.xml ${save_dir}/TargetBD.xml
    OperatingSystem.Should Exist    ${save_dir}/TargetBD.xml
    ${content}=    OperatingSystem.Get File    path=${save_dir}/TargetBD.xml
    ${check_point_regexp}    Set Variable    resourceBuildKey="LTX_${RRU_type}".*resourceSWVersion="(?P<RRU_Version>.*)"
    @{RRU_Version}    String.Get Regexp Matches    ${content}    ${check_point_regexp}    RRU_Version
    [Return]    ${RRU_Version}[0]

Modify RRU Version Of IPHY XML Custom
    [Arguments]    ${iphy_path}    ${RRU_type}    ${RRU_Version}
    ${content}    OperatingSystem.Get File    path=${iphy_path}
    ${bldVersion}=    String.Get Regexp Matches    ${content}
    ...    <cardName>${RRU_type}<\/cardName>[\\s\\S]*?<bldVersion>(?P<bldVersion>.*)<\/bldVersion>
    ...    bldVersion
    Log Many    ${bldVersion[0]}    ${RRU_Version}
    ${new_content}    String.Replace String    ${content}    ${bldVersion[0]}    ${RRU_Version}
    Log To Console    ${new_content}
    OperatingSystem.Create File    path=${iphy_path}    content=${new_content}

Send IPHY XML To Airphone custom
    [Arguments]    ${iphy_path}
    [Documentation]    This keyword is to send target iphy.xml to Airphone /ffs/run/simmode/
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${iphy_path} | Yes | iphy.xml located, eg:/home/ute/iphy.xml |
    ...
    ...    Examples:
    ...    | Send IPHY XML To Airphone | /home/ute/iphy.xml |
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} rm -f /ffs/run/simmode/*.xml
    Should Be Equal As Integers    ${rc}    0
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} scp ${iphy_path} ${AP_ASIK.username}@${AP_ASIK.ip}:/ffs/run/simmode/iphy_modify.xml
    Should Be Equal As Integers    ${rc}    0
    ${soft_link}=    Set Variable    ln -fs /ffs/run/simmode/iphy_modify.xml /ffs/run/simmode/iphy.xml
    ${rc}    OperatingSystem.Run And Return Rc
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} ${soft_link}
    Should Be Equal As Integers    ${rc}    0
