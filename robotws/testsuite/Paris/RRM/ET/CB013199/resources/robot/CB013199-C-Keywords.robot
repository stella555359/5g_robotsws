*** Settings ***
Documentation     [SUITE PURPOSE]  Keywords of CB013199-C
...               Author   : ying.yw.wu@nokia.com
...               Creation Date               : 17-02-2025
...               Modified Date               : 19-02-2025
...               Last Modified by            : ying.yw.wu@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2505    ying.yw.wu@nokia.com              Creation
...               0.2       FB2505    ying.yw.wu@nokia.com              Adding IWK 8927 TTI postprocessing
...               0.3       FB2505    ying.yw.wu@nokia.com              Adding Produce Scout Data at teardown
Resource          ./CB013199-Common-Keywords.robot
Resource          ./CB013199-B-Keywords.robot
Resource          ../../../../../resources/SWENG/robot/RdCounters.robot
Resource          ../../../resources/common/TtiTrace/ttitrace.robot
Library           ../python/CB013199_checkTTItrace.py




*** Variables ***

#json & BSR package for ASOH AQQL 4 SSB beams
${jsonPath_Asoh_SemiStatic_4_6}     ${conf_DIR}/Delta_Configuration_CB013199_4_Cells_Beamset_4_Activate_DL_UL_MuMimo_On_Cell1.json
&{CB013199_ASOH_SemiStatic_4-6_BSR_Dic}    BSR_file_name=BSR_AQQL_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00001.zip
...                                        BSR_folder=CB013199

#json & BSR package for ABIP AEQE 6 SSB beams
${jsonPath_ABIP_Tdlte_3ms}           ${conf_DIR}/Delta_Configuration_CB013199_6_Cells_Activate_DL_UL_MuMimo_On_Cell1.json
&{CB013199_ABIP_BSR_Dic}             BSR_file_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001.zip
...                                  BSR_folder=CB008830

#CB013199 UL RD Counters
&{Expected_UL_BLOCK_UE_RD_Counters}         BLOCKED_PUSCH_UE_COUNT=0
&{Expected_UL_SHAVING_PRB_RD_Counters}      REDUCED_PUSCH_SUBCELL_PRB_COUNT=0

#CB013199 DL RD Counters
&{Expected_DL_BLOCK_UE_RD_Counters}         BLOCKED_PDSCH_UE_COUNT=0
&{Expected_DL_SHAVING_PRB_RD_Counters}      REDUCED_PDSCH_SUBCELL_PRB_COUNT=0


# TC ASOH semi static 4/6 : 2 SA UEs + 3 NSA UEs
# SA UEs : in cell 1, each 350 mbps UL
&{SA_Cell1_UlTput350M_Pos_Profile_1}         callType=SA     targetCell=1     dltput=0          ultput=420        pos_profile=1
&{SA_Cell1_UlTput350M_Pos_Profile_2}         callType=SA     targetCell=1     dltput=0          ultput=420        pos_profile=2

@{SA_UE_Def_List_01}        ${SA_Cell1_UlTput350M_Pos_Profile_1}
...                         ${SA_Cell1_UlTput350M_Pos_Profile_2}

# NSA UEs : UE 102 in cell 2, UE 103 in cell 3, UE 104 in cell 4
&{NSA_Cell2_UlTput175M}                      callType=NSA   targetCell=2    dltput=0          ultput=280
&{NSA_Cell3_UlTput175M}                      callType=NSA   targetCell=3    dltput=0          ultput=280
&{NSA_Cell4_UlTput175M}                      callType=NSA   targetCell=4    dltput=0          ultput=280

@{NSA_UE_Def_List_01}       ${NSA_Cell2_UlTput175M}
...                         ${NSA_Cell3_UlTput175M}
...                         ${NSA_Cell4_UlTput175M}

&{TC_ASOH_SemiStatic_4_6_UE_List}       saUeList=${SA_UE_Def_List_01}
...                                     nsaUeList=${NSA_UE_Def_List_01}

#tti IWK 8927 RAT1 Check Variables
&{Dict_IWK_8927_RAT_Check}          eventType=dlFdSchedData
...                                 columnName=rat0Bitmap

&{Dict_IWK_8927_DL_Tput_TTI_Check}           eventType=dlAllocatedPooledResourcesData
...                                          columnName=allocCellThroughputDl
...                                          minDataAlloc=29952
...                                          maxThroughputL1Pool=5032000

&{Dict_IWK_8927_UL_Tput_TTI_Check}           eventType=ulAllocatedPooledResourcesData
...                                          columnName=allocCellThroughputUl
...                                          minDataAlloc=31200
...                                          maxThroughputL1Pool=1892000

*** Keywords ***

TC CB013199-IWK-RAT1-DL-Traffic-With-Mumimo
    [Documentation]         6 CELLs with SA DL traffic + Dummy PDSCH on all cells all UEs to trigger the DL Tput Limit
    [Arguments]             ${params}
    Init Sequence           ${params}
    Critical Step           CB013199 define SA UEs                  UEdefList=${params}
    Step                    Set RAD Params Of CB013199
    Step                    CB013199 Load CB013199 BSR file         CB01399_BSR_Dic=${CB013199_ABIP_BSR_Dic}
    Step                    CB013199 json recommissioning           jsonFile=${jsonPath_ABIP_Tdlte_3ms}
    Step                    CB013199 Configure iphy For Mumimo
    Dated Log New Line      =====  Params : ${params}
    Critical Step           Restart TL
    Critical Step           WTS Setup                           shouldUseLua=False
    Critical Step           CB013199 attach SA UEs              UElist=${UEs_SA_List}
    Step                    CB013199 Set Mumimo UEs position    UElist=${UEs_SA_List}
    Step                    CB013199 start traffic DL           UElist=${UEs_SA_List}
    Traced Sleep            duration=60s                        msg=SA UEs DL traffic started ...
    Step                    CB013199 Add Dummy Pdsch On All UEs
    Traced Sleep            duration=10s                        msg=Dummy PDSCH Load on all UEs to trigger DL Tput limit ...
    Step                    CB013199 start TTI Capture          suffix=DL_With_Dummy
    Traced Sleep            duration=3s                         msg=start DL traffic TTI capture...
    Step                    CB013199 stop TTI Capture           suffix=DL_With_Dummy
    Traced Sleep            duration=60s                        msg=stop TTI waiting for 60seconds
    Step                    CB013199 IWK 8927 TTI Post Processing          TTIpcap=${TTIpcap}
    Traced Sleep            duration=360s                       msg=Collecting RD counters and check PRB shaving and UE Block ...
    Step                    CB013199 RAT1 DL RD Counters Check
    Step                    Oam.OAM Get Snapshot
    # Step                    GenericTest.Display Diagnosis
    [Teardown]              CB013199 End Of TC


TC CB013199-C-ASOH-SemiStatic-4-6-UL-Traffic
    [Documentation]         4 CELLs with SA+NSA high UL traffic to trigger the UL Tput Limit
    [Arguments]             ${params}
    Init Sequence           ${params}
    Critical Step           CB013199 C define NSA and SA UEs        UEdefList=${params}
    Step                    Set RAD Params Of CB013199
    Step                    CB013199 Load CB013199 BSR file         ${CB013199_ASOH_SemiStatic_4-6_BSR_Dic}
    Step                    CB013199 json recommissioning           jsonFile=${jsonPath_Asoh_SemiStatic_4_6}
    Step                    CB013199 Configure iphy For Mumimo
    Dated Log New Line      =====  Params : ${params}
    Critical Step           Restart TL
    Critical Step           WTS Setup                           shouldUseLua=False
    Critical Step           CB013199 attach SA UEs              UElist=${UEs_SA_List}
    Step                    CB013199 Set Mumimo UEs position    UElist=${UEs_SA_List}
    Step                    CB013199 start traffic UL           UElist=${UEs_SA_List}
    Traced Sleep            duration=5s                         msg=SA UEs UL traffic started ...
    Critical Step           CB013199 attach NSA UEs             UElist=${UEs_NSA_List}
    Step                    CB013199 start traffic UL           UElist=${UEs_NSA_List}
    Traced Sleep            duration=5s                         msg=NSA UEs UL traffic started ...
    Step                    CB013199 start TTI Capture          suffix=UL
    Traced Sleep            duration=3s                         msg=start UL traffic TTI capture...
    Step                    CB013199 stop TTI Capture           suffix=UL_Traffic
    Traced Sleep            duration=60s                        msg=stop TTI waiting for 60seconds
    Step                    CB013199 C TTI Post Checks          TTIpcap=${TTIpcap}
    Traced Sleep            duration=360s                       msg=Collecting RD counters and check PRB shaving and UE Block ...
    Step                    CB013199 ASOH UL RD Counters Check
    Step                    Oam.OAM Get Snapshot
    # Step                    GenericTest.Display Diagnosis
    [Teardown]              CB013199 End Of TC


CB013199 Set Mumimo UEs position
    [Documentation]          In Mumimo testing, test mode 'ul_mimo_srs_beam_pos_nr' in egate is used to position the UE
    ...                      in a Pre-defined Quadrant/sub-Quadrant position relative to the RU geometry
    [Arguments]             ${UElist}

    # Define UE position profiles
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=1    mode=fixed    init_quad_pos=0    init_sub_quad_pos=0
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=2    mode=fixed    init_quad_pos=1    init_sub_quad_pos=0
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=3    mode=fixed    init_quad_pos=2    init_sub_quad_pos=0
    wtsemu.ul_mimo_srs_beam_pos_nr    profile_id=4    mode=fixed    init_quad_pos=3    init_sub_quad_pos=0

    FOR    ${UEitem}    IN     @{UElist}
        wtsemu.ue_testmode_set_nr    id=${UEitem.ue}
        ...                          testmode=ul_mimo_srs_beam_pos
        ...                          action=activate
        ...                          profile_id=${UEitem.ue_srs_beam_pos_profile}
    END


TC CB013199-DL-UL-Semi-Static-4-6-Mumimo-Cell-Setup-ASOH
    [Documentation]
    ...     Conditions:     CB013199 feature flag activation, ASOH semistatic 4-6 BSR file loading,
    ...                     dl ul mimo config for 4 cells but dl ul mumimo activated on cell 1 only
    ...     Actions:        Cell setup & call setup
    ...     Checks:         cells setup ok ...
    ...     Verdict:        ...
    [Arguments]             ${params}


    Init Sequence           ${params}
    Step                    Set RAD Params Of CB013199
    Step                    CB013199 Load CB013199 BSR file     ${CB013199_ASOH_SemiStatic_4-6_BSR_Dic}
    Step                    CB013199 json recommissioning       jsonFile=${jsonPath_Asoh_SemiStatic_4_6}
    Step                    CB013199 Configure iphy For Mumimo
    # Step                    Deploy Vendor File Config
    Dated Log New Line      =====  Params : ${params}
    # Critical Step           Perform Recommissionning if need
    Critical Step           Restart TL
    Step                    Multi Cells Setup CB013199               argument=${params.nbCell}
    Step                    Oam.OAM Get Snapshot
    [Teardown]              GenericTest.Display Diagnosis

CB013199 C define NSA and SA UEs
    [Arguments]               ${UEdefList}

    ${nb_Of_SA_UEs}           Get Length    ${UEdefList.saUeList}
    ${nb_Of_NSA_UEs}          Get Length    ${UEdefList.nsaUeList}

    Dated Log New Line     ===> Define ${nb_Of_SA_UEs} SA UEs in CFG
    Dated Log New Line     ===> Define ${nb_Of_NSA_UEs} NSA UEs in CFG
    Create UEs in Cfg File    nb_sa_ues=${nb_Of_SA_UEs}
    ...                       nb_nsa_ues=${nb_Of_NSA_UEs}

    #build SA UE list
    ${SA_UE_id}               Set Variable    1
    ${UEs_SA_list}            Create List

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

        Dated Log new line    ==== ${UEdef} ====

        Append To List        ${UEs_SA_list}     ${UEdef}
        ${SA_UE_id}           Evaluate           ${SA_UE_id}+1
    END
    Set Suite Variable        ${UEs_SA_list}

   # Build NSA UE list, first NSA UE id=3 (nb of SA UE =2, the first nsa ue is 3)
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


CB013199 C TTI Post Checks
    [Arguments]            ${TTIpcap}

    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000
    Dated Log New Line     ===> TTI json file : ${TTIjson}
    Dated Log New Line     ===> TTI csv file  : ${TTIcsv}
    Dated Log New Line     ===> To add TTI post checks ...

CB013199 ASOH UL RD Counters Check
    Dated Log New Line     ====> Collect & Verify RD counters
    ${RD_Counters_Log_Path}      Set Variable         ${LOG_PATH}/RD_Counters_Files
    Dated Log New Line     ====> The RD counters file collected from gnb will be stored under : ${RD_Counters_Log_Path}
    ${RD_Counters_Files}=   Collect RD Counters
    ${NRCELL_ID_1}          Set Variable    1
    ${Check_Result_1}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${Expected_UL_BLOCK_UE_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>='
    ${Check_Result_2}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${Expected_UL_SHAVING_PRB_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>'

CB013199 RAT1 DL RD Counters Check
    Dated Log New Line     ====> Collect & Verify RD counters
    ${RD_Counters_Log_Path}      Set Variable         ${LOG_PATH}/RD_Counters_Files
    Dated Log New Line     ====> The RD counters file collected from gnb will be stored under : ${RD_Counters_Log_Path}
    ${RD_Counters_Files}=   Collect RD Counters
    ${NRCELL_ID_1}          Set Variable    1
    ${Check_Result_1}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${Expected_DL_BLOCK_UE_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>='
    ${Check_Result_2}       Verify RD Counters With Criteria
    ...                     ${RD_Counters_Files}
    ...                     ${Expected_DL_SHAVING_PRB_RD_Counters}
    ...                     ${NRCELL_ID_1}
    ...                     '>'

CB013199 IWK 8927 TTI Post Processing
    [Arguments]            ${TTIpcap}
    Dated Log New Line     ===> convert TTI trace ${TTIpcap}
    ${TTIjson}             Convert TTI trace from pcap to others    input_file_path=${TTIpcap}
    ${TTIcsv}              decode_tti_traces_json_using_TtitraceReaderEvtDec    jsonPathName=${TTIjson}    num_of_events=100000
    Dated Log New Line     ===> TTI json file : ${TTIjson}
    Dated Log New Line     ===> TTI csv file  : ${TTIcsv}
    Dated Log New Line     ====> CB013199 IWK 8927 DL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_IWK_8927_DL_Tput_TTI_Check}        ${TTIjson}
    Dated Log New Line     ====> CB013199 IWK 8927 UL tput allocation check : ====
    Alloc Tput Check In TTI         ${Dict_IWK_8927_UL_Tput_TTI_Check}        ${TTIjson}
    Dated Log New Line     ====> CB0131199 IWK DL RAT check : ====
    IWK_8927_RAT_Check In TTI       ${Dict_IWK_8927_RAT_Check}       ${TTIjson}

IWK_8927_RAT_Check In TTI
    [Documentation]                    Check the DL Resource Allocation Type values of all cells in TTI traces
    [Arguments]                        ${Dict_Check}    ${path_to_json}
    ${Rat_Check_failure}        Check_IWK_8927_RAT_Value
    ...                                     jsonPathName=${path_to_json}
    ...                                     eventTTI=${Dict_Check.eventType}
    ...                                     columnInEvent=${Dict_Check.columnName}
    Dated Log New Line         ===> IWK RAT Check failure status is: ${Rat_Check_failure}
    should not be true      '${Rat_Check_failure}' =='1'