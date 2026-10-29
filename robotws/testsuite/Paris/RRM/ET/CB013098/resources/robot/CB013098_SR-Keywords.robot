*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013098
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : philippe.daroux@nokia.com
...               Creation Date               : 15-08-2025
...               Modified Date               : 18-09-2025
...               Last Modified by            : philippe.daroux@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2507    philippe.daroux@nokia.com             Creation
Resource          ./CB013098_SR-Common-Keywords.robot
# Resource          ../../../resources/common/TtiTrace/ttitrace.robot
# Resource          ../../../../../resources/SWENG/robot/Setup.robot
# Resource          ../../../../../resources/SWENG/robot/Oam.robot

Resource          taf/rfrl/common_resources/robot/preconditions.robot

Resource          ../../../../../resources/SWENG/robot/GenericTest.robot
Resource          ../../../../../resources/SWENG/robot/Counters.robot
Resource          ../../../../../resources/SWENG/robot/SetConfig.robot
Resource          ../../../../../resources/SWENG/robot/Setup.robot
Resource          ../../../../../resources/SWENG/robot/CallSetup.robot
Resource          ../../../../../resources/SWENG/robot/Traffic.robot
Resource          ../../../../../resources/SWENG/robot/CaptureFilter.robot
Resource          ../../../../../resources/SWENG/robot/Oam.robot
Resource          ../../../../../resources/SWENG/robot/Tools.robot
Resource          ../../../../../resources/SWENG/robot/Restart.robot
Resource          ../../../../../resources/SWENG/robot/Scf.robot
Resource          ../../../../../resources/SWENG/robot/Container.robot
Resource          ../../../../../resources/SWENG/robot/Sherpa.robot
Resource          ../../../../../resources/SWENG/robot/PacketSearch.robot


# Resource          ../../../../ST/resources/sg_radio_perf/robot/Keywords_gNB.robot
# Resource          ../../../../ST/resources/sg_radio_perf/robot/preconditions.robot
# Resource          ../../../../ST/resources/sg_radio_perf/robot/Commissioning.robot

Library           taf.config.scf             WITH NAME    scf
# Library           ../../../resources/scf_parameters.py
# Library           ../../../resources/pm_analyze.py        WITH NAME      pm_analyze


   # Library             taf.sbts.oam.coam.admin   WITH NAME    admin
   # Library             ta5g_file_system
   # Library             ta5g_testline_management
   # Library             ta5g_iphy
   # Library             ta5g_enb
   # Library             ta5g_ue_measurements
   # Library             ta5g_delta
   # Library             taf.ul.ettf.setups
   # Library             ta5g_egate
   # Library             ute_reporting_portal
   # Library             ta5g_pm_counters
   # Library             ta5g_ue_mobility
   # Library             ute_wtssim
   # Library             ute_common_store

*** Variables ***

${UEcapa}               $small
${dist_name1}            MRBTS-1/NRBTS-1/NRCELL-1
${dist_name3}            MRBTS-1/NRBTS-1/NRCELL-3
${ADMIN_ALIAS}				admin_1
${conf_DIR}             ${CURDIR}/../config
# ${jsonPath_Mimo}           ${conf_DIR}/Delta_Configuration_CB013199_DL_Mumo_Activate_On_Cell_1.json
# ${jsonPath_Dl_Ul_Mimo}           ${conf_DIR}/Delta_Configuration_CB013199_6_Cells_Activate_DL_UL_MuMimo_On_Cell1.json
# ${jsonPath_Asoh_Dl_Ul_Mimo}      ${conf_DIR}/Delta_Configuration_CB013199_4_Cells_Activate_DL_UL_MuMimo_On_Cell1.json

# BSR custom beamset package for AEQE Beamset_6
# ${BSR_git_path}         gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git
# ${BSR_git_folder}       CB013199
# ${BSR_git_file_nacme}    BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip

# &{CB013199_ASOH_BSR_Dic}        BSR_file_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
# ...                             BSR_folder=CB013199


# SA 4 UEs, NSA 1 UE
&{SA_Cell1_DlTput175M_UlTput75M}         callType=SA     targetCell=1     dltput=175     ultput=75      pos_profile=1
&{SA_Cell2_DlTput175M_UlTput75M}         callType=SA     targetCell=2     dltput=175     ultput=75      pos_profile=1
&{SA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175     ultput=75      pos_profile=1
&{NSA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175     ultput=75      pos_profile=1

@{UE_Def_DL_UL_List_02}     ${SA_Cell1_DlTput175M_UlTput75M}
...                         ${SA_Cell2_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}
#...                         ${NSA_Cell_DlTput175M_UlTput75M}
# Setting profile 4Ues SA + 1 Ue NSA
# SA 4UEs
# &{SA_Cell1_DlTput175M_UlTput75M}         callType=SA     targetCell=1     dltput=175          ultput=75        pos_profile=1
# &{SA_Cell2_DlTput175M_UlTput75M}         callType=SA     targetCell=1     dltput=175          ultput=75        pos_profile=1
# &{SA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175          ultput=75        pos_profile=1

@{SA_UE_Def_List_02}        ${SA_Cell1_DlTput175M_UlTput75M}
...                         ${SA_Cell2_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}

@{SA_UE_Def_List_03}        ${SA_Cell1_DlTput175M_UlTput75M}
...                         ${SA_Cell2_DlTput175M_UlTput75M}
...                         ${SA_Cell3_DlTput175M_UlTput75M}

# NSA UEs : UE 11 in cell 3
# &{NSA_Cell3_DlTput175M_UlTput75M}         callType=NSA   targetCell=3    dltput=175          ultput=75

@{NSA_UE_Def_List_02}       ${NSA_Cell3_DlTput175M_UlTput75M}


&{UE_Def_DL_UL_List_SA_NSA}             saUeList=${SA_UE_Def_List_02}
...                                     saUeList3=${SA_UE_Def_List_03}
...                                     nsaUeList=${NSA_UE_Def_List_02}







# SA 4 UEs, 1 UE per cell, dl 175mbps, ul 75mbps
# &{SA_Cell1_DlTput175M_UlTput75M}         callType=SA     targetCell=1     dltput=175     ultput=75      pos_profile=1
# &{SA_Cell2_DlTput175M_UlTput75M}         callType=SA     targetCell=2     dltput=175     ultput=75      pos_profile=1
# &{SA_Cell3_DlTput175M_UlTput75M}         callType=SA     targetCell=3     dltput=175     ultput=75      pos_profile=1
# &{SA_Cell4_DlTput175M_UlTput75M}         callType=SA     targetCell=4     dltput=175     ultput=75      pos_profile=1

# @{UE_Def_DL_UL_List_01}     ${SA_Cell1_DlTput175M_UlTput75M}
# ...                         ${SA_Cell2_DlTput175M_UlTput75M}
# ...                         ${SA_Cell3_DlTput175M_UlTput75M}
# ...                         ${SA_Cell4_DlTput175M_UlTput75M}


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


TEST
    Update bwpDN
    Set actMultipleDedicatedBWPs
    Dated Log New Line         ====> parameter actMultipleDedicatedBWPs changed to false


TC CB013098-DL-UL-Traffic
    [Documentation]         6 CELLs up with SA+NSA high DL and UL traffic
    [Arguments]             ${UEdefListparam}
    Init Sequence           ${UEdefListparam}
    Critical Step           CB013198 define NSA and SA UEs        UEdefList=${UEdefListparam}
    Dated Log New Line      =====  Params : ${UEdefListparam}
    Critical Step           Restart TL
    Critical Step           WTS Setup                           shouldUseLua=False
    Critical Step           CB013098 attach SA UEs              UElist=${UEs_SA_List}
    Step                    CB013098 start traffic UL           UElist=${UEs_SA_List}
    Traced Sleep            duration=5s                         msg=SA UEs UL traffic started ...
    Step                    CB013098 start traffic DL           UElist=${UEs_SA_List}
    Traced Sleep            duration=5s                         msg=SA UEs DL traffic started ...
    Critical Step           CB013098 attach NSA UEs             UElist=${UEs_NSA_List}
    Step                    CB013098 start traffic UL           UElist=${UEs_NSA_List}
    Traced Sleep            duration=5s                         msg=NSA UEs UL traffic started ...
    Step                    CB013098 start traffic DL           UElist=${UEs_NSA_List}
    Traced Sleep            duration=5s                         msg=NSA UEs DL traffic started ...
    Traced Sleep            duration=20s                        msg=TIME OFF ...
    Critical Step           Set actMultipleDedicatedBWPs
    Dated Log New Line         ====> parameter actMultipleDedicatedBWPs changed to false
    Step                    CB013098_SR-Common-Keywords.CB013098 UE Deregister SA UEs       UElist=${UEs_SA_list}
    Step                    CB013098_SR-Common-Keywords.CB013098 Unregister NSA UEs         UElist=${UEs_NSA_list}
    Critical Step           CB013098 attach SA UEs              UElist=${UEs_SA_List3}
    Step                    CB013098 start traffic UL           UElist=${UEs_SA_List3}
    Traced Sleep            duration=5s                         msg=SA UEs UL traffic started ...
    Step                    CB013098 start traffic DL           UElist=${UEs_SA_List3}
    Traced Sleep            duration=5s                         msg=SA UEs DL traffic started ...
    Critical Step           CB013098 attach SA UE4
    Critical Step           CB013098 attach NSA UEs             UElist=${UEs_NSA_List}
    Step                    CB013098 start traffic UL           UElist=${UEs_NSA_List}
    Traced Sleep            duration=5s                         msg=NSA UEs UL traffic started ...
    Step                    CB013098 start traffic DL           UElist=${UEs_NSA_List}
    Traced Sleep            duration=5s                         msg=NSA UEs DL traffic started ...
    Traced Sleep            duration=20s                        msg=TIME OFF
   # Step                    CB013199 start TTI Capture          suffix=UL
   # Traced Sleep            duration=3s                         msg=start UL traffic TTI capture...
   # Step                    CB013199 stop TTI Capture           suffix=UL_Traffic
   # Traced Sleep            duration=60s                        msg=stop TTI waiting for 60seconds
   # Step                    CB013199 C TTI Post Checks          TTIpcap=${TTIpcap}
   # Traced Sleep            duration=360s                       msg=Collecting RD counters and check PRB shaving and UE Block ...
   # Step                    CB013199 ASOH UL RD Counters Check
   # Step                    Oam.OAM Get Snapshot
    # Step                    GenericTest.Display Diagnosis
    [Teardown]              CB013098 End Of TC


CB013198 define NSA and SA UEs
    [Arguments]               ${UEdefList}

    ${nb_Of_SA_UEs}           Get Length    ${UEdefList.saUeList}
    ${nb_Of_NSA_UEs}          Get Length    ${UEdefList.nsaUeList}

    Dated Log New Line     ===> Define ${nb_Of_SA_UEs} SA UEs in CFG
    Dated Log New Line     ===> Define ${nb_Of_NSA_UEs} NSA UEs in CFG
    Create UEs in Cfg File    nb_sa_ues=${nb_Of_SA_UEs}
    ...                       nb_nsa_ues=${nb_Of_NSA_UEs}

    #build SA UE list with 4 Ues
    ${SA_UE_id}               Set Variable    1
    ${SA_UE_id3}               Set Variable    1
    ${UEs_SA_list}            Create List
    ${UEs_SA_list3}            Create List

    FOR    ${UEitem}    IN     @{UEdefList.saUeList}
        # Copy UE dictionary from SWENG according to call type
        ${UEdef}              Copy Dictionary     ${BASIC_UE_SA}

        # Set UE id according to call type and target cell
        Set To Dictionary     ${UEdef}     ue    ${SA_UE_id}
        ${tgtCellId}          Set Variable      ${TDD_Cell_list[${UEitem.targetCell}-1].nrCellId}
        Set To Dictionary     ${UEdef}     pdu               ${SA_UE_id}
        Set To Dictionary     ${UEdef}     target_cells      ${tgtCellId}
        Set To Dictionary     ${UEdef}     dlthroughput      ${UEitem.dltput}
        Set To Dictionary     ${UEdef}     ulthroughput      ${UEitem.ultput}
        Set To Dictionary     ${UEdef}     ue_srs_beam_pos_profile      ${UEitem.pos_profile}

        Modify UE Data in Cfg File    sa_or_nsa=SA    ue_id=${SA_UE_id}   cell_id=${tgtCellId}
        Modify UE Data in Cfg File    sa_or_nsa=SA    ue_id=4    ue_nr_capa=${UEcapa}

        Dated Log new line    ==== ${UEdef} ====

        Append To List        ${UEs_SA_list}     ${UEdef}
        ${SA_UE_id}           Evaluate           ${SA_UE_id}+1
    END
    Set Suite Variable        ${UEs_SA_list}

    #build SA UE list with 3 Ues
    FOR    ${UEitem}    IN     @{UEdefList.saUeList3}
        # Copy UE dictionary from SWENG according to call type
        ${UEdef}              Copy Dictionary     ${BASIC_UE_SA}

        # Set UE id according to call type and target cell
        Set To Dictionary     ${UEdef}     ue    ${SA_UE_id3}
        ${tgtCellId}          Set Variable      ${TDD_Cell_list[${UEitem.targetCell}-1].nrCellId}
        Set To Dictionary     ${UEdef}     pdu               ${SA_UE_id3}
        Set To Dictionary     ${UEdef}     target_cells      ${tgtCellId}
        Set To Dictionary     ${UEdef}     dlthroughput      ${UEitem.dltput}
        Set To Dictionary     ${UEdef}     ulthroughput      ${UEitem.ultput}
        Set To Dictionary     ${UEdef}     ue_srs_beam_pos_profile      ${UEitem.pos_profile}

        Modify UE Data in Cfg File    sa_or_nsa=SA    ue_id=${SA_UE_id3}   cell_id=${tgtCellId}
        Modify UE Data in Cfg File    sa_or_nsa=SA    ue_id=4    ue_nr_capa=${UEcapa}

        Dated Log new line    ==== ${UEdef} ====

        Append To List        ${UEs_SA_list3}     ${UEdef}
        ${SA_UE_id3}           Evaluate           ${SA_UE_id3}+1
    END
    Set Suite Variable        ${UEs_SA_list3}


   # Build NSA UE list, first NSA UE id=11 (nb of SA UE =4, the first nsa ue is 11)
    ${NSA_UE_id}               Evaluate     ${nb_Of_SA_UEs}+1
    ${UEs_NSA_list}            Create List

    FOR    ${UEitem}    IN     @{UEdefList.nsaUeList}
        # Copy UE dictionary from SWENG according to call type, UE_SIMPLE is a NSA UE profile defined in sweng CallSetup.robot
        ${UEdef}              Copy Dictionary     ${UE_SIMPLE}
        # Set UE id according to call type and target cell
        Set To Dictionary     ${UEdef}     ue     ${NSA_UE_id}
        Set To Dictionary     ${UEdef}     target_cells      ${UEitem.targetCell}
        Set To Dictionary     ${UEdef}     dlthroughput      ${UEitem.dltput}
        Set To Dictionary     ${UEdef}     ulthroughput      ${UEitem.ultput}

        Modify UE Data in Cfg File    sa_or_nsa=NSA    ue_id=${NSA_UE_id}
        Dated Log new line    ==== ${UEdef} ====

        Append To List        ${UEs_NSA_list}     ${UEdef}
        ${NSA_UE_id}           Evaluate           ${NSA_UE_id}+1
    END
    Set Suite Variable        ${UEs_NSA_list}

Update bwpDN

    ${list_param_to_change0}=    Create Dictionary    bwpDN=BWP_PROFILE-0    cellBwpId=0
    ...                                               actPdcchCceFragmentControl=False
    ...                                               actUpperThrAckNackFiltering=False
    ...                                               actUpperThrAckNackHrFiltering=False
    ...                                               pdcchResourcePreference=peakRate
    ${list_param_to_change1}=    Create Dictionary    bwpDN=BWP_PROFILE-44    cellBwpId=1
    ...                                               actPdcchCceFragmentControl=False
    ...                                               actUpperThrAckNackFiltering=False
    ...                                               actUpperThrAckNackHrFiltering=False
    ...                                               pdcchResourcePreference=peakRate
    ${list_param_to_change2}=    Create Dictionary    bwpDN=BWP_PROFILE-55    cellBwpId=2
    ...                                               actPdcchCceFragmentControl=False
    ...                                               actUpperThrAckNackFiltering=False
    ...                                               actUpperThrAckNackHrFiltering=False
    ...                                               pdcchResourcePreference=peakRate
    ${list_param_to_change3}=    Create Dictionary    bwpDN=BWP_PROFILE-66    cellBwpId=3
    ...                                               actPdcchCceFragmentControl=False
    ...                                               actUpperThrAckNackFiltering=False
    ...                                               actUpperThrAckNackHrFiltering=False
    ...                                               pdcchResourcePreference=peakRate
    @{list1}=    create list    ${list_param_to_change0}    ${list_param_to_change1}
    @{list2}=    create list    ${list_param_to_change0}    ${list_param_to_change1}    ${list_param_to_change3}

    admin.perform_parameter_recommissioning    dist_name=${dist_name1}
    ...                                            parameter=cellBwpList
    ...                                            operation=update
    ...                                            value=@{list1}
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${ADMIN_ALIAS}

    admin.perform_parameter_recommissioning    dist_name=${dist_name3}
    ...                                            parameter=cellBwpList
    ...                                            operation=update
    ...                                            value=@{list2}
    ...                                            should_activate=${True}
    ...                                            skip_parameter_relation_errors=${True}
    ...                                            connection=${ADMIN_ALIAS}
    sleep		  2s


Set actMultipleDedicatedBWPs
    &{modify_param1}    Create Dictionary
    ...    parameter=actMultipleDedicatedBWPs
    ...    dist_name=MRBTS-1/NRBTS-1
   # ...    dist_name=${dist_name}
    ...    value=false
    @{modify_param}    Create List    ${modify_param1}
    Oam.OAM Set Params                ${modify_param}




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


CB013098 End Of TC
   [Documentation]        At the end of each TC :
   ...                      - show the Diagnosis of the TC steps
   ...                      - collect the gnb Snapshot
   ...                      - if TC failed, collect also AP sosReport

   Dated Log              End Of TC : start ... produce scout data ...
   GenericTest.Display Diagnosis
   Setup.Produce Scout Data