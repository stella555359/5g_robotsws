*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013199-B
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : ying.yw.wu@nokia.com
...               Creation Date               : 19-06-2024
...               Modified Date               : 19-06-2024
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2419    ying.yw.wu@nokia.com              Creation
...               0.2       FB2420    ying.yw.wu@nokia.com              Adding .json and BSR download for DL mumimo config
...               0.3       FB2426    ying.yw.wu@nokia.com              Adding keywords for SA ue setup, dl, ul traffic
...               0.4       FB2501    ying.yw.wu@nokia.com              Adding keywords for dl ul mimo commissioning with json
...               0.5       FB2502    ying.yw.wu@nokia.com              Adding keywords for asoh bsr loading
...               0.6       FB2504    philippe.daroux@nokia.com         Including AllocCellThrougput min & sum verification with py
...               0.7       FB2505    ying.yw.wu@nokia.com              AllocCellThroughput check DL+UL
...               0.8       FB2505    ying.yw.wu@nokia.com              Add Produce Scout Data in teardown of TC ASOH DL+UL
...               0.9       FB2515    ying.yw.wu@nokia.com              Add F1 check before BSR SW update
Resource          ./CB013199-Common-Keywords.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
# Resource          ../../../../../resources/SWENG/robot/TtiConvertInterface.robot
# Resource          ../../../../../resources/SWENG/robot/TtiAnalysisInterface.robot
Library           ../python/CB013199_checkTTItrace.py



*** Variables ***


${conf_DIR}             ${CURDIR}/../config
${jsonPath_Mimo}           ${conf_DIR}/Delta_Configuration_CB013199_DL_Mumo_Activate_On_Cell_1.json
${jsonPath_Dl_Ul_Mimo}           ${conf_DIR}/Delta_Configuration_CB013199_6_Cells_Activate_DL_UL_MuMimo_On_Cell1.json
${jsonPath_Asoh_Dl_Ul_Mimo}      ${conf_DIR}/Delta_Configuration_CB013199_4_Cells_Activate_DL_UL_MuMimo_On_Cell1.json

# BSR custom beamset package for AEQE Beamset_6
${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
${BSR_git_folder}       CB013199
${BSR_git_file_name}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

&{CB013199_ASOH_BSR_Dic}        BSR_file_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                             BSR_folder=CB013199



# SA 4 UEs, 1 UE per cell, dl 175mbps, ul 75mbps
&{SA_Cell1_DlTput175M_UlTput75M}         callType=SA     targetCell=1     dltput=175     ultput=75      pos_profile=1
&{SA_Cell2_DlTput175M_UlTput75M}         callType=SA     targetCell=2     dltput=175     ultput=75      pos_profile=1
&{SA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175     ultput=75      pos_profile=1
&{SA_Cell4_DlTput175M_UlTput75M}         callType=SA     targetCell=4     dltput=175     ultput=75      pos_profile=1

@{UE_Def_DL_UL_List_01}     ${SA_Cell1_DlTput175M_UlTput75M}
...                         ${SA_Cell2_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}
...                         ${SA_Cell4_DlTput175M_UlTput75M}


# SA DL only,  4 UEs, 1 UE per cell
&{SA_Cell1_DlTput750M_UlTput0M}         callType=SA     targetCell=1     dltput=750     ultput=0        pos_profile=1
&{SA_Cell2_DlTput15M_UlTput0M}          callType=SA     targetCell=2     dltput=15      ultput=0        pos_profile=1
&{SA_Cell3_DlTput175M_UlTput0M}         callType=SA     targetCell=3     dltput=175     ultput=0        pos_profile=1
&{SA_Cell4_DlTput15M_UlTput0M}          callType=SA     targetCell=4     dltput=15      ultput=0        pos_profile=1

@{UE_Def_DL_List_01}    ${SA_Cell1_DlTput750M_UlTput0M}
...                     ${SA_Cell2_DlTput15M_UlTput0M}
...                     ${SA_Cell3_DlTput175M_UlTput0M}
...                     ${SA_Cell4_DlTput15M_UlTput0M}

#SA UL only,  4 UEs, 1 UE per cell

&{SA_Cell1_DlTput0M_UlTput200M}        callType=SA     targetCell=1     dltput=0     ultput=200         pos_profile=1
&{SA_Cell2_DlTput0M_UlTput15M}         callType=SA     targetCell=2     dltput=0     ultput=15          pos_profile=1
&{SA_Cell3_DlTput0M_UlTput75M}         callType=SA     targetCell=3     dltput=0     ultput=75          pos_profile=1
&{SA_Cell4_DlTput0M_UlTput15M}         callType=SA     targetCell=4     dltput=0     ultput=15          pos_profile=1

@{UE_Def_UL_List_01}    ${SA_Cell1_DlTput0M_UlTput200M}
...                     ${SA_Cell2_DlTput0M_UlTput15M}
...                     ${SA_Cell3_DlTput0M_UlTput75M}
...                     ${SA_Cell4_DlTput0M_UlTput15M}

# Variables for TTI check
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
# 	For DL : numMinPrbPoolingAlloc = 48 (CPRT setting for DL, chBW=100Mhz)
# 		     minDataPerSlotAlloc = 48*624=29 952   (bits per slot)
#
# 	For UL : umMinPrbPoolingAlloc = 54(depending on config, diff long pucch size, for this TC, it is 54)
# 		     minDataPerSlotAlloc = 54*624=33 696   (bits per slot)

# vendor file default settings of max tput limit for ASOH/half mode/TDD/cpriOrEcpri72a:
#   maxPdschTpSlotL1Pool=5032 (kbits/slot)
#   maxPuschTpSlotL1Pool=1892 (kbits/slot)

&{Dict_DL_Tput_TTI_Check}           eventType=dlAllocatedPooledResourcesData
...                                 columnName=allocCellThroughputDl
...                                 minDataAlloc=29952
...                                 maxThroughputL1Pool=5032000

&{Dict_UL_Tput_TTI_Check}           eventType=ulAllocatedPooledResourcesData
...                                 columnName=allocCellThroughputUl
...                                 minDataAlloc=33696
...                                 maxThroughputL1Pool=1892000

# vendor file default settings of max stream PRB capa per L1 subpool for ASOH
# l1PoolType=NR_L1Pool_Thor_TDD_FR1_eCPRI
# For: UL
#  before CB013199:
#    maxNumStreamPrbL1Sp=1638, totalMaxStreamPrb per L1 pool=3276
#    4 streams per cell, total Max UL Cell Prbs in 1 L1 pool=3276/4=819
#  With CB013199:
#    maxNumStreamPrbL1Sp=2180, totalMaxStreamPrb per L1 pool=4360
#    4 streams per cell, total Max UL Cell Prbs in 1 L1 pool=4360/4=1090
# For: DL
#  before CB013199:
#    maxNumStreamPrbL1Sp=2184, totalMaxStreamPrb per L1 pool=4368
#    4 streams per cell, total Max UL Cell Prbs in 1 L1 pool=4368/4=1092
#  With CB013199:
#    maxNumStreamPrbL1Sp=3276, totalMaxStreamPrb per L1 pool=6552
#    4 streams per cell, total Max UL Cell Prbs in 1 L1 pool=6552/4=1638

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


*** Keywords ***
TC CB013199-DL-UL-Mumimo-Cell-Setup
    [Documentation]
    ...     Conditions:     CB013199 feature flag activation, BSR file loading, dl ul mimo config for all cells but
    ...                     dl ul mumimo activated on cell 1 only
    ...     Actions:        Cell setup & call setup
    ...     Checks:         cells setup ok ...
    ...     Verdict:        ...
    [Arguments]             ${param}


    Init Sequence           ${param}
    Step                    Set RAD Params Of CB013199
    Step                    CB013199 Load BSR file
    Step                    CB013199 json recommissioning       jsonFile=${jsonPath_Dl_Ul_Mimo}
    Step                    CB013199 Configure iphy For Mumimo
    # Step                    Deploy Vendor File Config
    Dated Log New Line      =====  Params : ${param}
    # Critical Step           Perform Recommissionning if need
    Critical Step           Restart TL
    Step                    Multi Cells Setup CB013199               argument=${param.nbCell}
    Step                    Oam.OAM Get Snapshot
    [Teardown]              GenericTest.Display Diagnosis

TC CB013199-DL-UL-Mumimo-Cell-Setup-ASOH
    [Documentation]
    ...     Conditions:     CB013199 feature flag activation, ASOH BSR file loading, dl ul mimo config for 4 cells but
    ...                     dl ul mumimo activated on cell 1 only
    ...     Actions:        Cell setup & call setup
    ...     Checks:         cells setup ok ...
    ...     Verdict:        ...
    [Arguments]             ${param}


    Init Sequence           ${param}
    Step                    Set RAD Params Of CB013199
    Step                    CB013199 Load CB013199 BSR file     ${CB013199_ASOH_BSR_Dic}
    Step                    CB013199 json recommissioning       jsonFile=${jsonPath_Asoh_Dl_Ul_Mimo}
    Step                    CB013199 Configure iphy For Mumimo
    # Step                    Deploy Vendor File Config
    Dated Log New Line      =====  Params : ${param}
    # Critical Step           Perform Recommissionning if need
    Critical Step           Restart TL
    Step                    Multi Cells Setup CB013199               argument=${param.nbCell}
    Step                    Oam.OAM Get Snapshot
    [Teardown]              GenericTest.Display Diagnosis




TC CB013199-TC-Mumimo-Cell-Setup
    [Documentation]
    ...     Conditions:     CB013199-A activation
    ...     Actions:        Cell setup & call setup
    ...     Checks:         ...
    ...     Verdict:        ...
    [Arguments]             ${param}


    Init Sequence           ${param}
    Step                    Set RAD Params Of CB013199
    Step                    CB013199 Load BSR file
    Step                    CB013199 json recommissioning       jsonFile=${jsonPath_Mimo}
    Step                    CB013199 Configure iphy For Mumimo
    # Step                    Deploy Vendor File Config
    Dated Log New Line      =====  Params : ${param}
    # Critical Step           Perform Recommissionning if need
    Critical Step           Restart TL
    Step                    Multi Cells Setup CB013199               argument=${param.nbCell}
    Step                    Oam.OAM Get Snapshot
    [Teardown]              GenericTest.Display Diagnosis

TC CB013199-DL-Traffic-Only
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013199 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Set RAD Params Of CB013199
    Critical Step            Restart TL
    Critical Step            WTS Setup                        shouldUseLua=False
    Critical Step            CB013199 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013199 start traffic DL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL traffic started ...
    Step                     CB013199 start TTI Capture       suffix=DL_only
    Traced Sleep             duration=3s                      msg=start DL traffic TTI capture...
    Step                     CB013199 stop TTI Capture        suffix=DL_traffic_only
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
    # Step                     CB013199 stop traffic DL        UElist=${UEs_SA_List}
    Step                     Oam.OAM Get Snapshot
    [Teardown]               GenericTest.Display Diagnosis


TC CB013199-UL-Traffic-Only
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013199 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Set RAD Params Of CB013199
    Critical Step            Restart TL
    Critical Step            WTS Setup                        shouldUseLua=False
    Critical Step            CB013199 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013199 start traffic UL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=UL traffic started ...
    Step                     CB013199 start TTI Capture       suffix=UL_only
    Traced Sleep             duration=3s                      msg=start UL traffic TTI capture...
    Step                     CB013199 stop TTI Capture        suffix=UL_traffic_only
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
    # Step                     CB013199 stop traffic UL        UElist=${UEs_SA_List}
    Step                     Oam.OAM Get Snapshot
    [Teardown]               GenericTest.Display Diagnosis

TC CB013199-DL-UL-Traffic
    [Documentation]
    [Arguments]              ${UEdefListparam}
    Init Sequence            ${UEdefListparam}
    Critical Step            CB013199 define SA UEs            UEdefList=${UEdefListparam}
    Step                     Set RAD Params Of CB013199
    Critical Step            Restart TL
    Critical Step            WTS Setup                        shouldUseLua=False
    Critical Step            CB013199 attach SA UEs           UElist=${UEs_SA_List}
    Step                     CB013199 start traffic DL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=DL traffic started ...
    Step                     CB013199 start traffic UL        UElist=${UEs_SA_List}
    Traced Sleep             duration=5s                      msg=UL traffic started ...
    Step                     CB013199 start TTI Capture       suffix=DL_UL
    Traced Sleep             duration=3s                      msg=start DL UL traffic TTI capture...
    Step                     CB013199 stop TTI Capture        suffix=DL_UL_Traffic
    Traced Sleep             duration=60s                     msg=stop TTI waiting for 60seconds
	Step                     CB013199 Tput And PRB Alloc Check in TTI   	TTIpcap=${TTIpcap}
    # Step                     CB013199 stop traffic UL        UElist=${UEs_SA_List}
    # Step                     CB013199 stop traffic DL        UElist=${UEs_SA_List}
    Step                     Oam.OAM Get Snapshot
    Step                     GenericTest.Display Diagnosis
    [Teardown]               Setup.Produce Scout Data


CB013199 Load BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position

    Dated Log New Line     ===> Download BSR file ${BSR_git_file_name}
    Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${BSR_git_folder}
    ...                                 git_file_name=${BSR_git_file_name}
    ...                                 target_dir=${LOG_PATH}/BSR

CB013199 Load CB013199 BSR file
    [Documentation]         Load BSR file to enable the use of Spatial Managed UE position
    [Arguments]             ${CB01399_BSR_Dic}

    Dated Log New Line     ===> Download BSR file ${CB01399_BSR_Dic.BSR_file_name}
    Dated Log New Line     ===> check F1 is ready before SW update with BSR package
    F1 Wait Link Classical
    Download Package Using Git Update OAM
    ...                                 git_path=${BSR_git_path}
    ...                                 git_folder=${CB01399_BSR_Dic.BSR_folder}
    ...                                 git_file_name=${CB01399_BSR_Dic.BSR_file_name}
    ...                                 target_dir=${LOG_PATH}/BSR

CB013199 Configure iphy For Mumimo
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

CB013199 Tput And PRB Alloc Check in TTI
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=60000
    Dated Log New Line     ====> DL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_DL_Tput_TTI_Check}       ${TTIjson}
    Dated Log New Line     ====> UL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_UL_Tput_TTI_Check}       ${TTIjson}
    Dated Log New Line     ====> DL Cell PRB Allocation check : ====
    Cell PRB Alloc Check In TTI     ${Dict_DL_PRB_TTI_Check}        ${TTIjson}
    Dated Log New Line     ====> UL Cell PRB Allocation check : ====
    Cell PRB Alloc Check In TTI     ${Dict_UL_PRB_TTI_Check}        ${TTIjson}
