*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013527-A-B
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-03-2025
...               Modified Date               : 19-03-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                                 Notes
...               0.1       FB2506    ying.yw.wu@nokia.com                   Creation
...               0.2       FB2512    axel.gouilly-frossard@nokia.com        Add Mumimo configs, keywords, new TCs
...               0.3       FB2513    ying.yw.wu@nokia.com                   Add TC C1 IWK RAT TTI and RD counters check
...               0.4       FB2513    ying.yw.wu@nokia.com                   Add TC ASOH post processing

Resource          ./CB013527-Common-Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../resources/DSS/robot/aashell.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Library           ../../../CB013199/resources/python/CB013199_checkTTItrace.py



*** Variables ***

${BLER_KPI}             ${CURDIR}/../../config/CounterKPI/CB013527_BLER_KPI.csv
${8_Cells_BLER_KPI}     ${CURDIR}/../../config/CounterKPI/CB013527_8_Cells_Counters_BLER_KPI.csv

# BSR custom beamset package for AEQE Beamset_6
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
# ${BSR_git_folder}       CB013199
# ${BSR_git_file_name}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

# &{CB013199_ASOH_BSR_Dic}        BSR_file_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
# ...                             BSR_folder=CB013199


# Variables for TTI check
# RAT1 check in TTI traces
&{Dict_IWK_8927_RAT1_Check}          eventType=dlFdSchedData
...                                  columnName=rat0Bitmap

#CB013527 DL RD Counters
&{TC_C1_Expected_DL_BLOCK_UE_RD_Counters}         BLOCKED_PDSCH_UE_COUNT=0
&{TC_C1_Expected_DL_SHAVING_PRB_RD_Counters}      REDUCED_PDSCH_SUBCELL_PRB_COUNT=0


# The max pdsch tput limit = 5032000 (bits/slot) (corresponding to vendor file defaut setting)
# The max pusch tput limit = 1892000 (bits/slot) (corresponding to vendor file defaut setting)
# The min data alloc per slot DL = 29952 (bits/slot)
# The min data alloc per slot UL = 33696 (bits/slot)

# The detailed calculation of the min data alloc per slot (minDataPerSlotAlloc):
# 	minDataPerSlotAlloc = numMinPrbPoolingAlloc(i)* nominalCellSpecEff(i)
# 	numMinPrbPoolingAlloc(i) is the minimum number of cell PRB allocated to the cell i by BBRM
# 	nominalCellSpecEff(i) is the norminal Cell spectral efficiency of cell i
# 	nominalCellSpecEff(i) = minActiveSubcellsPerCell * minLayerPerCell * rdSpectralEffForMinAlloc * numSubCarrierPerPrb * numSymbolsPerSlot

# 	Cell i :  256 qam, 8DL8UL, 100Mhz
# 		minActiveSubcellsPerCell=1
# 		minLayerPerCell=1
# 		rdSpectralEffForMinAlloc=4 (RAD param default value : 0x58098D=4)
# 		numSubCarrierPerPrb=12
# 		numSymbolsPerSlot=13 (13 symbols pusch per slot)
#
# 		nominalCellSpecEff = 1*4*12*13=624
# 	For DL : numMinPrbPoolingAlloc = 48 (hardcoded value in CPRT, CB012605)
# 		     minDataPerSlotAlloc = 48*624=29 952   (bits per slot)
#
# 	For UL : umMinPrbPoolingAlloc = 24(hardcoded value in CPRT, CB012605)
# 		     minDataPerSlotAlloc = 24*624=14 976   (bits per slot)

# vendor file default settings of max tput limit for ASOH/half mode/TDD/cpriOrEcpri72e:
#   maxPdschTpSlotL1Pool=5032 (kbits/slot)
#   maxPuschTpSlotL1Pool=2523 (kbits/slot)

&{Dict_DL_Tput_TTI_Check}           eventType=dlAllocatedPooledResourcesData
...                                 columnName=allocCellThroughputDl
...                                 minDataAlloc=29952
...                                 maxThroughputL1Pool=5032000

&{Dict_UL_Tput_TTI_Check}           eventType=ulAllocatedPooledResourcesData
...                                 columnName=allocCellThroughputUl
...                                 minDataAlloc=14976
...                                 maxThroughputL1Pool=2523000

&{Dict_DL_Tput_TTI_Check_2_L1Pools}           eventType=dlAllocatedPooledResourcesData
...                                           columnName=allocCellThroughputDl
...                                           minDataAlloc=29952
...                                           maxThroughputL1Pool=10064000

&{Dict_UL_Tput_TTI_Check_2_L1Pools}           eventType=ulAllocatedPooledResourcesData
...                                           columnName=allocCellThroughputUl
...                                           minDataAlloc=14976
...                                           maxThroughputL1Pool=5046000

# vendor file default settings of max stream PRB capa per L1 subpool for ABIP
# l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI_7_2e
# For: UL
#  before CB013127:
#    maxNumLayerPrbL1Sp=1092, totalNumLayerPrb per L1 pool=2184
#
#  With CB013527:
#    maxNumLayerPrbL1Sp=2184, totalNumLayerPrb per L1 pool=4368
#
# For: DL
#  before CB013127:
#    maxNumLayerPrbL1Sp=2184, totalNumLayerPrb per L1 pool=4368
#
#  With CB013527:
#    maxNumLayerPrbL1Sp=4368, totalNumLayerPrb per L1 pool=8736

#todo : to adapt below for CB013527
&{Dict_UL_PRB_TTI_Check}            eventType=ulAllocatedPooledResourcesData
...                                 columnName=numAllocCellPrbUl
...                                 minPrbAlloc=54
...                                 maxCellPrbL1PoolLegacy=819
...                                 maxCellPrbL1PoolCB013199=1090

&{Dict_DL_PRB_TTI_Check}            eventType=dlAllocatedPooledResourcesData
...                                 columnName=numAllocCellPrbDl
...                                 minPrbAlloc=48
...                                 maxCellPrbL1PoolLegacy=1092
...                                 maxCellPrbL1PoolCB013199=1638
#end todo


*** Keywords ***
TC CB013527-DL-UL-Traffic
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013527 define SA UEs            UEdefList=${UEdefListparam}
    ${returned_syslog}       CB013527 Cell Setup With Syslogs
    Critical Step            CB013527 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013527 start traffic DL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL traffic started ...
    Step                     CB013527 start traffic UL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=dummu pdsh filled
    Step                     CB013527 start TTI Capture       suffix=DL_UL
    Traced Sleep             duration=3s                      msg=start DL UL traffic TTI capture...
    Step                     CB013527 stop TTI Capture        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
	Step                     CB013527 Tput And PRB Alloc Check in TTI   	TTIpcap=${TTIpcap}
    Traced Sleep             duration=360s                    msg=Collecting PM Files ...
    Step                     CB013527 Check BLER KPIs         BLER_KPI_Constraints_File=${BLER_KPI}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB013527 End Of TC

TC CB013527-ASOH-DL-UL-Traffic
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013527 define SA UEs            UEdefList=${UEdefListparam}
    ${returned_syslog}       CB013527 Cell Setup With Syslogs
    Critical Step            CB013527 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013527 start traffic DL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL traffic started ...
    Step                     CB013527 start traffic UL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=dummu pdsh filled
    Step                     CB013527 start TTI Capture       suffix=DL_UL
    Traced Sleep             duration=3s                      msg=start DL UL traffic TTI capture...
    Step                     CB013527 stop TTI Capture        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
	Step                     CB013527 ASOH Tput And PRB Alloc Check in TTI   	TTIpcap=${TTIpcap}
    Traced Sleep             duration=360s                    msg=Collecting PM Files ...
    Step                     CB013527 Check BLER KPIs         BLER_KPI_Constraints_File=${8_Cells_BLER_KPI}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB013527 End Of TC

TC CB013527-DL-UL-Traffic-GBR
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013527 define SA UEs            UEdefList=${UEdefListparam}
    ${returned_syslog}       CB013527 Cell Setup With Syslogs
    Critical Step            CB013527 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013527 Set Mumimo UEs position    UElist=${UEs_SA_List}
    Step                     CB013527 start traffic DL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL traffic started ...
    Step                     CB013527 start traffic DL GBR    UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL GBR traffic started ...
    Step                     CB013527 start traffic UL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=UL traffic started ...
    Step                     CB013527 fill dummy pdsch
    Traced Sleep             duration=5s                      msg=dummu pdsh filled
    Step                     CB013527 start TTI Capture       suffix=DL_UL
    Traced Sleep             duration=3s                      msg=start DL UL traffic TTI capture...
    Step                     CB013527 stop TTI Capture        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
	Step                     CB013527 Tput And PRB Alloc Check in TTI   	TTIpcap=${TTIpcap}
    Traced Sleep             duration=360s                    msg=Collecting PM Files ...
    Step                     CB013527 Check BLER KPIs         BLER_KPI_Constraints_File=${BLER_KPI}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB013527 End Of TC

TC CB013527-DL-UL-Traffic-RAT
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013527 define SA UEs            UEdefList=${UEdefListparam}
    ${returned_syslog}       CB013527 Cell Setup With Syslogs
    Critical Step            CB013527 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013527 Set Mumimo UEs position    UElist=${UEs_SA_List}
    Step                     CB013527 start traffic DL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL traffic started ...
    Step                     CB013527 start traffic UL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=UL traffic started ...
    Step                     CB013527 fill dummy pdsch
    Traced Sleep             duration=5s                      msg=dummu pdsh filled
    Step                     CB013527 start TTI Capture       suffix=DL_UL
    Traced Sleep             duration=3s                      msg=start DL UL traffic TTI capture...
    Step                     CB013527 stop TTI Capture        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
	Step                     CB013527 IWK 8927 TTI Post Processing   	TTIpcap=${TTIpcap}
    Traced Sleep             duration=360s                    msg=Collecting PM Files ...
    Step                     CB013527 RAT1 DL RD Counters Check
    Step                     CB013527 Check BLER KPIs         BLER_KPI_Constraints_File=${BLER_KPI}
    Step                     Oam.OAM Get Snapshot
    # Step                     GenericTest.Display Diagnosis
    [Teardown]               CB013527 End Of TC

CB013527 fill dummy pdsch
    [Documentation]    :Complete the traffic load with dummy pdsch to trigger the tput limit hit
    ...
    ...     :param gnb_id:      Id of gnb                       [0.. ]  default=0
    ...

    [Arguments]   ${gnb_id}=${0}

    ${rad_param}    set variable   0x58017C
    ${rad_param_value}    set variable    1000000
    aashell.Execute Aashell Command on Node     command=rad -mw ${rad_param} ${rad_param_value}\r
    ...                                         node_id=${gnb_id}   node_type=gnb
    dated log   set ${rad_param} with value ${rad_param_value}
    # ${comu_alias}=   Connect to gNB Common Unit  gnb_id=${gnb_id}    du_id=${du_id}     comu_id=${comu_id}
    # ssh.Send Command
    # ...    command=telnet 0 15007  connection=${comu_alias}
    # ssh.Read Output Until
    # ...    match=AaShell>${SPACE}
    # ...    timeout=3
    # ...    connection=${comu_alias}
    # ${rad_param}    set variable   0x58017C
    # ${rad_param_value}    set variable    1000000
    # ssh.Write Input
    # ...    data=rad -mw ${rad_param} ${rad_param_value}\r
    # ...    connection=${comu_alias}
    # dated log   set ${rad_param} with value ${rad_param_value}
    # ssh.Read Output Until
    # ...    match=written succesfully
    # ...    timeout=3
    # ...    connection=${comu_alias}
    # ssh.Write Input
    # ...    data=rad -mw 0x58017B  0xFFFFFFFF\r
    # ...    connection=${comu_alias}
    # ssh.Read Output Until
    # ...    match=written succesfully
    # ...    timeout=3
    # ...    connection=${comu_alias}
    # ssh.Write Input
    # ...    data=rad -mw 0x58017A  1\r
    # ...    connection=${comu_alias}
    # ssh.Read Output Until
    # ...    match=written succesfully
    # ...    timeout=3
    # ...    connection=${comu_alias}
    # ssh.Write Input
    # ...    data=quit\r
    # ...    connection=${comu_alias}
    # ssh.Read Output Until
    # ...    match=Bye ...
    # ...    timeout=3
    # ...    connection=${comu_alias}


CB013527 Load CB013527 BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position
    [Arguments]             ${CB013527_BSR_Dic}

    Dated Log New Line     ===> Download BSR file ${CB013527_BSR_Dic.BSR_file_name}
    Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${CB013527_BSR_Dic.BSR_folder}
    ...                                 git_file_name=${CB013527_BSR_Dic.BSR_file_name}
    ...                                 target_dir=${LOG_PATH}/BSR


CB013527 Set Mumimo UEs position
    [Documentation]          In Mumimo testing, test mode 'ul_mimo_srs_beam_pos_nr' in egate is used to position the UE
    ...                      in a Pre-defined Quadrant/sub-Quadrant position relative to the RU geometry
    [Arguments]             ${UElist}

    # # Define UE position profiles
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=1    mode=fixed    init_quad_pos=0    init_sub_quad_pos=0
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=2    mode=fixed    init_quad_pos=1    init_sub_quad_pos=0
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=3    mode=fixed    init_quad_pos=2    init_sub_quad_pos=0
    # wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=4    mode=fixed    init_quad_pos=3    init_sub_quad_pos=0
    #For 7.2e

    wtsemu.ul_sinr_testmode_nr     profile_id=1
    ...                             pusch_tx_power=-394
    ...                             pathloss=28

    Wtsemu.ul_ue_beam_pos_nr  profile_id=1
    ...                              num_beam_paths=2
    ...                              azimuth=-70,-70
    ...                              zenith=-40,-40
    ...                              power=-250,-250

    Wtsemu.ul_ue_beam_pos_nr  profile_id=2
    ...                              num_beam_paths=2
    ...                              azimuth=-53,-53
    ...                              zenith=-30,-30
    ...                              power=-250,-250


    FOR    ${UEitem}    IN     @{UElist}
        #wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        #...                          testmode=ul_mimo_srs_beam_pos
        #...                          action=activate
        #...                          profile_id=${UEitem.ue_srs_beam_pos_profile}

        wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        ...                          testmode=ul_sinr
        ...                          action=activate
        ...                          profile_id=1

        wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        ...                          testmode=ue_ul_beam_position
        ...                          action=activate
        ...                          profile_id=${UEitem.ue_srs_beam_pos_profile}

    END


CB013527 Configure iphy For Mumimo
    [Documentation]         Modify iphy to enable SRS (current case is for DL Beam forming) and BSR file
    WtsXmlConfig.startSession           file=iphy

    # WtsXmlConfig.addTextEltAll          Elt=//vcell     name=ulFeatures      val=advancedSRS
    WtsXmlConfig.addTextEltAll          Elt=//vcell     name=ulFeatures      val=ulMuMIMO
    # obsolete item FB2513:  WtsXmlConfig.addTextEltAll          Elt=//vcell     name=refinedBeams    val=true
    WtsXmlConfig.addTextEltAll          Elt=//vcell     name=dlFeatures      val=pmiBeams

    ${Feat1}                            Create Dictionary    feature=FILE_DOWNLOAD                      support=1
    ${Feat2}                            Create Dictionary    feature=BEAMFORMING_PATTERNS_FILE          support=1
    ${Feat3}                            Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V1    support=0
    ${Feat4}                            Create Dictionary    feature=BEAMFORMING_DATA_FILE_FORMAT_V2    support=1
    @{Feat_list}                        Create List          ${Feat1}    ${Feat2}    ${Feat3}    ${Feat4}

    WtsXmlConfig.addObjectEltAll        Elt=//soap-config    name=supportedFeatures
    WtsXmlConfig.addItemsFromListAll    Elt=//soap-config/supportedFeatures    itemlist=${Feat_list}

    WtsXmlConfig.stop Session           file=iphy


Alloc Tput Check In TTI
    [Documentation]                    Check the DL Tput Allocation of all cells in TTI traces
    [Arguments]                        ${Dict_Tput_TTI_Check}    ${path_to_json}
    Dated Log New Line         ====> Check Tput Allocation in tti json file : ${path_to_json}
    ${Tput_Alloc_Check_failure}        Check_allocCellThroughput
    ...                                     jsonPathName=${path_to_json}
    ...                                     eventTTI=${Dict_Tput_TTI_Check.eventType}
    ...                                     columnInEvent=${Dict_Tput_TTI_Check.columnName}
    ...                                     min_data_allocation=${Dict_Tput_TTI_Check.minDataAlloc}
    ...                                     maxTputLimit=${Dict_Tput_TTI_Check.maxThroughputL1Pool}
    Dated Log New Line         ===> Tput_Allocation_Check_failure status is: ${Tput_Alloc_Check_failure}
    should not be true      '${Tput_Alloc_Check_failure}' =='1'

Cell PRB Alloc Check In TTI
    [Documentation]                    Check the Cell PRB Allocation of all cells in TTI traces
    [Arguments]                        ${Dict_Cell_PRB_TTI}    ${path_to_json}
    ${Cell_PRB_Alloc_Check_failure}       Check_PrbAllocation
    ...                                     jsonPathName=${path_to_json}
    ...                                     eventTTI=${Dict_Cell_PRB_TTI.eventType}
    ...                                     columnInEvent=${Dict_Cell_PRB_TTI.columnName}
    ...                                     min_prb_allocation=${Dict_Cell_PRB_TTI.minPrbAlloc}
    ...                                     maxCellPrbL1Pool_Legacy=${Dict_Cell_PRB_TTI.maxCellPrbL1PoolLegacy}
    ...                                     maxCellPrbL1Pool=${Dict_Cell_PRB_TTI.maxCellPrbL1PoolCB013199}
    Dated Log New Line         ===> DL PRB Allocation_Check_failure status is: ${Cell_PRB_Alloc_Check_failure}
    should not be true      '${Cell_PRB_Alloc_Check_failure}' =='1'

#to Do : to adapte for CB013527
CB013527 Tput And PRB Alloc Check in TTI
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=60000
    Dated Log New Line     ====> DL tput allocation check : ====
    # Alloc Tput Check In TTI         ${Dict_DL_Tput_TTI_Check}       ${TTIjson}
    Dated Log New Line     ====> UL tput allocation check : ====
    # Alloc Tput Check In TTI         ${Dict_UL_Tput_TTI_Check}       ${TTIjson}
    Dated Log New Line     ====> DL Cell PRB Allocation check : ====
    # Cell PRB Alloc Check In TTI     ${Dict_DL_PRB_TTI_Check}        ${TTIjson}
    Dated Log New Line     ====> UL Cell PRB Allocation check : ====
    # ell PRB Alloc Check In TTI     ${Dict_UL_PRB_TTI_Check}        ${TTIjson}

CB013527 ASOH Tput And PRB Alloc Check in TTI
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=60000
    Dated Log New Line     ====> DL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_DL_Tput_TTI_Check_2_L1Pools}       ${TTIjson}
    Dated Log New Line     ====> UL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_UL_Tput_TTI_Check_2_L1Pools}       ${TTIjson}
    # Dated Log New Line     ====> DL Cell PRB Allocation check : ====
    # Cell PRB Alloc Check In TTI     ${Dict_DL_PRB_TTI_Check}        ${TTIjson}
    # Dated Log New Line     ====> UL Cell PRB Allocation check : ====
    # ell PRB Alloc Check In TTI     ${Dict_UL_PRB_TTI_Check}        ${TTIjson}

CB013527 Check BLER KPIs
    [Arguments]            ${BLER_KPI_Constraints_File}

    Dated Log New Line     ====> collect and check BLER KPIs
    ${PM_lastFile}         Counters.Collect PM files from BTS    ${LOG_PATH}/PM_FILES
    Dated Log New Line     ====> Last PM File : ${PM_lastFile}
    KPI Evaluate                    pmFile=${PM_lastFile}
    ...                             constraintsFile=${BLER_KPI_Constraints_File}
    ...                             failOnError=${True}

CB013527 IWK 8927 TTI Post Processing
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000
    Dated Log New Line     ===> TTI json file : ${TTIjson}
    Dated Log New Line     ===> TTI csv file  : ${TTIcsv}
    Dated Log New Line     ====> CB013527 IWK 8927 DL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_DL_Tput_TTI_Check}        ${TTIjson}
    Dated Log New Line     ====> CB013527 IWK 8927 UL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_UL_Tput_TTI_Check}        ${TTIjson}
    Dated Log New Line     ====> CB013527 IWK DL RAT check : ====
    CB013527_IWK_8927_RAT_Check In TTI       ${Dict_IWK_8927_RAT1_Check}       ${TTIjson}

CB013527_IWK_8927_RAT_Check In TTI
    [Documentation]                    Check the DL Resource Allocation Type values of all cells in TTI traces
    [Arguments]                        ${Dict_Check}    ${path_to_json}
    ${Rat_Check_failure}        Check_IWK_8927_RAT_Value
    ...                                     jsonPathName=${path_to_json}
    ...                                     eventTTI=${Dict_Check.eventType}
    ...                                     columnInEvent=${Dict_Check.columnName}
    Dated Log New Line         ===> IWK RAT Check failure status is: ${Rat_Check_failure}
    should not be true      '${Rat_Check_failure}' =='1'

CB013527 RAT1 DL RD Counters Check
    Dated Log New Line     ====> Collect & Verify RD counters
    ${RD_Counters_Log_Path}      Set Variable         ${LOG_PATH}/RD_Counters_Files
    Dated Log New Line     ====> The RD counters file collected from gnb will be stored under : ${RD_Counters_Log_Path}
    ${RD_Counters_Files}=   Collect RD Counters
    ${NRCELL_ID_1}          Set Variable    1
    ${Check_Result_1}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${TC_C1_Expected_DL_BLOCK_UE_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>='
    ${Check_Result_2}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${TC_C1_Expected_DL_SHAVING_PRB_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>'
