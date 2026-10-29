*** Settings ***
Documentation     [SUITE PURPOSE]  Common keyword of CB008940-F feature
...               Prerequisite :
...               Scope :
...               Test Case Scenario author   : yann.merlin@nokia.com
...               Creation Date               : 16-01-2023
...               Modified Date               : 24-01-2023
...               Last Modified by            : yann.merlin@nokia.com
...               Version   Date      Author                             Notes
...               0.1       FB2302    yann.merlin@nokia.com              Creation
...               0.2       FB2414    blandine.garnier@nokia.com         Update value de poolid

Library           OperatingSystem
Library           String
Library           BuiltIn

Resource          ./CB008940-Common-Keywords.robot

*** Variables ***

${TDD_FR1_chBw_60MHz_148PRB_specific_BWP_NUM_MAX_PRB}                  148
${TDD_FR1_chBw_60MHz_155PRB_specific_BWP_NUM_MAX_PRB}                  155
${TDD_FR1_chBw_80MHz_203PRB_specific_BWP_NUM_MAX_PRB}                  203
${TDD_FR1_chBw_90MHz_239PRB_specific_BWP_NUM_MAX_PRB}                  239
${TDD_FR1_chBw_100MHz_256PRB_specific_BWP_NUM_MAX_PRB}                 256

# maximum of PRB that can be distributed in one subpool

*** Keywords ***

TC 8940 F Interaction with CB8917 Call Setup Multi Ues With nonGBR and GBR DL Traffic
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${vendor_custom} ${dict_ues} ${nrCell}
    ...     Actions:        it performs the call setup for 2 UES on NrCell belonging to the same L1SubPool with nonGBR raffic
    ...     Checks:         it checks nothing more than already done on lib.
    ...     Verdict:        calls for multi ues and PRB pooling are passed
    [Arguments]             ${param}
    ...                     ${vendor_custom}
    ...                     ${dict_ues}
    ...                     ${nrCell}

    Init Sequence           ${param}
    Step                    CB008940-F-Keywords.Set RAD Params Of 8940-F
    Critical Step           Deploy Vendor File Config     vendor_param=${vendor_custom}           is_perform_full_commissioning=${True}
    Dated Log New Line      ${vendor_custom}


    # Configure new ue's dynamically
    ${initial_NbOfUe}       get length          ${dict_ues}
    Run Keyword If          ${initial_NbOfUe} < ${param.totalNbOfUe}    Configure New Ues         ${dict_ues}
    ...                                                                                           ${initial_NbOfUe}
    ...                                                                                           ${param.totalNbOfUe}
    ...                                                                                           ${dict_settings_ue_default}
    # Configure the current setting for all the ue's
    ${param.totalNbOfUe}    get length          ${dict_ues}
    Step                    Dated Log           Configure the setting for the ${param.totalNbOfUe} ue's
    @{listOfUes}            Create List
    FOR    ${current_id}    IN RANGE    0    ${param.totalNbOfUe}
        ${current_ue}=                Evaluate                      ${current_id} + 1
        ${current_ueSetting}=         Copy Dictionary               ${BASIC_UE_SA}
        Set To Dictionary             ${current_ueSetting}          ue                  ${current_ue}
        Set To Dictionary             ${current_ueSetting}          pdu                 1
        # Adapting trf_id parameter for each ue
        Set To Dictionary             ${current_ueSetting}          trf_id              ${current_ue}
        Set To Dictionary             ${current_ueSetting}          target_gnb          ${param.targetGnb}

        # Dispatching each ue on the requested original cell for the call establishment
        Set To Dictionary             ${current_ueSetting}          target_cells        ${dict_ues[${current_id}].originalCell}
        # Set the correct requested throughput per ue
        Set To Dictionary             ${current_ueSetting}          throughput          ${dict_ues[${current_id}].throughput}
        Set To Dictionary             ${current_ueSetting}          throughput_GBR      ${dict_ues[${current_id}].throughput_GBR}

        Append To List                ${listOfUes}                  ${current_ueSetting}
    END
    Dated Log New Line                UE_List=${listOfUes}
    Check Multi Ues Setting In List                                 multiUesList=${listOfUes}
    # Setup wtsemu SA for all the ue's
    Traced Sleep            duration=60s                            msg=before setup Wtsemu SA to give radio modules time to start
    Critical Step           CallSetup.Setup Wtsemu SA               nbUe=${param.totalNbOfUe}
    ...                                                             nbSaUe=${param.totalNbOfUe}
    ...                                                             shouldUseLua=${True}
    ###...                                                          nbCell=${param.totalNbOfCell}
    ...                                                             list_of_UE_tobe_created=${listOfUes}

    # Start Sherpa capture before call establishment
    #  Step                    Activate Sherpa On All Cells

    # Register and launch PDU for all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
                            Critical Step       CallSetup.UE Register
        ...                                                         ue=${current_elem.ue}
        ###...                                                      nwslice=1
        ###...                                                      timeout=30
        ...                 depends=CallSetup.Setup Wtsemu SA

                            Critical Step       CallSetup.Launch PDU Session
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         gw=${current_elem.ue}
        ###...                                                      nwslice=1
        ...                 depends=CallSetup.UE Register
    END

    # Start the non GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.throughput} > ${NO_THROUGHPUT}
        ...                 Critical Step    ${param.dir} Traffic SA Not Stopped
        ...                                                         param=${param}
        ...                                                         ueSetting=${current_elem}
        ...                 depends=CallSetup.Launch PDU Session
    END

    # PDU session modify reserved for the ue's configured with GBR traffic
    ${nbOfUe_traffic_GBR}=    Get Number Of Ue Configured With GBR Traffic    dict_ues=${listOfUes}
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.throughput_GBR} > ${NO_THROUGHPUT}
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=2
        ...                                                         by=amf
        ...                 depends=CallSetup.Launch PDU Session
        Run Keyword If      ${current_elem.throughput_GBR} > ${NO_THROUGHPUT}
        ...                 Critical Step    CallSetup.UE PDU Session Modify
        ...                                                         ue=${current_elem.ue}
        ...                                                         pdu=${current_elem.pdu}
        ...                                                         qfta=3
        ...                                                         by=amf
        ...                 depends=CallSetup.Launch PDU Session
    END

    # Start the GBR traffic for all the ue's when requested
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.throughput_GBR} > ${NO_THROUGHPUT}
        ...                 Critical Step    ${param.dir} Traffic GBR SA Not Stopped
        ...                                                         param=${param}
        ...                                                         nbOfUe=${param.totalNbOfUe}
        ...                                                         ueSetting=${current_elem}
        ...                 depends=CallSetup.Launch PDU Session
    END


    Step                    Activate Sherpa On All Cells


    Step          Traced Sleep        duration=30s        msg=deregistering              depends=CallSetup.UE Register
    # Unregister all the ue's
    FOR    ${current_elem}    IN    @{listOfUes}
        Run Keyword If      ${current_elem.target_cells} != ${nrCell}
        ...                 Step      CallSetup.UE Deregister       id=${current_elem.ue}
        ###...                                                      ue_deregister_type=switch_off
        ###...                                                      by=ue
        ...                                                         depends=CallSetup.UE Register
    END

   # Stop Sherpa capture & Decoded Sherpa csv files
    Stop Sherpa Collection
    Calling Panda Extract Csv For PRB Pooling
    Step    Verification of Pool Id within PRB Pooling Report    pool_id=9    subpool_id=0
    Step    Verification of Pool Id within PRB Pooling Report    pool_id=9    subpool_id=1
    Step    Verification of BB Pooling cell distribution within PRB Pooling Report    nrCell_id=0x4001    subpool_id=0
    Step    Verification of BB Pooling cell distribution within PRB Pooling Report    nrCell_id=0x4002    subpool_id=1
    Step    Verification of BB Pooling cell distribution within PRB Pooling Report    nrCell_id=0x4003    subpool_id=0
    Step    Verification of Stream PRB Information within PRB Pooling Report    stream_prb_capa=${vendor_custom.maxNumStreamPrbL1Sp}
    ...                                                             alloc_stream_prb=${vendor_custom.maxNumStreamPrbL1Sp}
    ...                                                             subpool_id=0

    # The number PRB Allocated for CELL-1 + number PRB allocated for CELL-3 must be lowered than
    # the value of the variable TDD_FR1_chBw_60MHz_148PRB_specific_BWP_NUM_MAX_PRB :
    # NUM_MIN_PRB_DEFAULT   : minimum of PRB that can be allocated to one cell
    # NUM_MAX_PRB_DEFAULT   : maximum of PRB that can be allocated to the L1 SubPool
#   Verification of the PRB Demand to cellId=0x4001 is within range : 18 =< nonGBR PRB Request =< 30
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4001
    ...                                                             prb_req=${COL_NAME_NOGBRPRBREQUEST}
    ...                                                             prb_value=15
    ...                                                             check_operator=<=
     Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4001
    ...                                                             prb_req=${COL_NAME_NOGBRPRBREQUEST}
    ...                                                             prb_value=30
    ...                                                             check_operator=>=
#   Verification of the PRB Demand to cellId=0x4001 is within range : 2 =< GBR PRB Request =< 5
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4001
    ...                                                             prb_req=${COL_NAME_GBRPRBREQUEST}
    ...                                                             prb_value=5
    ...                                                             check_operator=>=
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4001
    ...                                                             prb_req=${COL_NAME_GBRPRBREQUEST}
    ...                                                             prb_value=2
    ...                                                             check_operator=<=
#   Verification of the PRB Demand to cellId=0x4003 is within range : 38 =< nonGBR PRB Request =< 66
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4003
    ...                                                             prb_req=${COL_NAME_NOGBRPRBREQUEST}
    ...                                                             prb_value=38
    ...                                                             check_operator=<=
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4003
    ...                                                             prb_req=${COL_NAME_NOGBRPRBREQUEST}
    ...                                                             prb_value=66
    ...                                                             check_operator=>=
#   Verification of the PRB Demand to cellId=0x4003 is within range : 5=< GBR PRB Request =< 10
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4003
    ...                                                             prb_req=${COL_NAME_GBRPRBREQUEST}
    ...                                                             prb_value=5
    ...                                                             check_operator=<=
    Step    Verification of BB Pooling Traffic PRB Request within PRB Pooling Report
    ...                                                             nrCell_id=0x4003
    ...                                                             prb_req=${COL_NAME_GBRPRBREQUEST}
    ...                                                             prb_value=10
    ...                                                             check_operator=>=

#   Verification of the PRB Allocated to cellId=0x4001 within range 60 (min) =< PRBAllocated =< 70 (max):
    Step    CB008940-F-Keywords.Verify PRB Allocated within PRB Pooling Report is included between 2 values
        ...                                                         nrCell_id=0x4001
        ...                                                         min_prb_value=58
        ...                                                         max_prb_value=70
#   Verification of the PRB Allocated to cellId=0x4003 within range 80 (min) =< PRBAllocated =< 87 (max):
    Step    CB008940-F-Keywords.Verify PRB Allocated within PRB Pooling Report is included between 2 values
        ...                                                         nrCell_id=0x4003
        ...                                                         min_prb_value=80
        ...                                                         max_prb_value=91

    [Teardown]             Display diagnosis



Verify PRB Allocated within PRB Pooling Report is included between 2 values
    [Documentation]
    [Arguments]             ${nrCell_id}
    ...                     ${min_prb_value}
    ...                     ${max_prb_value}
    ...                     ${result_req}=True
    ${file_path_report}     Set Variable        Dl_PrbPoolingAllocationReport_45_.csv
    Dated Log New Line      ${file_path_report}
    Dated Log New Line      Verify the number of PRB allocated by BBRM to NRCELLID=${nrCell_id}
    ${min_result}           Verify value with operator in csv Files with Prerequisite
    ...                                         CsvName=${file_path_report}
    ...                                         ColumnName=${COL_NAME_NUMPRBALLOC}
    ...                                         valuetocheck=${min_prb_value}
    ...                                         check_operator=<=
    ...                                         directory=${sherpa_output_path}
    ...                                         colum_prereq=${COL_NAME_NRCELLID}
    ...                                         regex_prereq=${nrCell_id}
    ${max_result}           Verify value with operator in csv Files with Prerequisite
    ...                                         CsvName=${file_path_report}
    ...                                         ColumnName=${COL_NAME_NUMPRBALLOC}
    ...                                         valuetocheck=${max_prb_value}
    ...                                         check_operator=>=
    ...                                         directory=${sherpa_output_path}
    ...                                         colum_prereq=${COL_NAME_NRCELLID}
    ...                                         regex_prereq=${nrCell_id}
    Run Keyword If          ${min_result} == True and ${max_result} == True
    ...      Dated Log New Line    The number of PRB Allocated to the NRCell: ${nrCell_id} is included between ${min_prb_value} and ${max_prb_value}
    ...      ELSE
    ...      Dated Log New Line    The number of PRB Allocated to the NRCell: ${nrCell_id} is outside the range :${min_prb_value} and ${max_prb_value}
    should be true          ${min_result} == ${result_req}
    should be true          ${max_result} == ${result_req}

Set RAD Params Of 8940-F
    [Documentation]     Add or Modify the RAD params of 8940 To Activate the feature
    ...                 will be replaced later by NIDD params
    ...                 0x580117=1 : #CSI-RS Event Sherpa
    ...                 0x58057A=4 : L2 feature flags : ERR & WRN & INF & DBG
    ...                 0x420068=3 : rdFeatureFlagBitmap1 :
    ...                 bit 2 -> CB007113 : 0  (disabled)
    ...                 bit 1 -> CB008847 : 1 (enabled)
    ...                 bit 0 -> CB008940 : 1 (enabled)
    ...                 0x5901C0=1 : rdEnableBBL1SpPrbInitCapacity
    ...                 0x580690=0 : rdAllowZeroAllocByPass - 0 : ZAB Disabled - 1 : Enabled
    ...                 0x58066a=0 : InterL1SubPool         - 0 : Disabled - 1 : Enabled
    Dated Log New Line   Add RAD params of 8940-F InterL1SubPool and ZeroAllocationByPass are Disabled ......
    ${rad_param_1}=      create dictionary       field=0x580117    value=1
    ${rad_param_2}=      create dictionary       field=0x420068    value=3
    ${rad_param_3}=      create dictionary       field=0x580690    value=0
    ${rad_param_4}=      create dictionary       field=0x58066a    value=0
    ${rad_param_list}=       Create List         ${rad_param_1}
    ...                                          ${rad_param_2}
    ...                                          ${rad_param_3}
    ...                                          ${rad_param_4}
    Dated Log New Line    RAD params :  ${rad_param_list}
    SetConfig.Set Fields in swconfig DU       param_list=${rad_param_list}
    Dated Log New Line   RAD params of 8940-F update completed
