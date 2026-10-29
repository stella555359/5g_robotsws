*** Keywords ***
Check_CNI113494_iBler_match_Legacy_counters_1cell
    [Arguments]    ${PM_counter_file}	

	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list

    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
	Log To Console    \n----------------------end-------------------------
		
    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
	END	
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------
	
	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}	
	END		
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}	
	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})	
	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})	
    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}	
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})		
	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})		
    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013	
	
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list	
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	END	
	
	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1

    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}	
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}

    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
	
    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
    Log To Console    \n----------------------end-------------------------	

	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015

    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}	
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	END	

	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1

    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}		
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})	
	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
	
    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
    Log To Console    \n----------------------end-------------------------	
	
    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   

	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 	
	

Check_CNI113494_iBler_match_Legacy_counters_2cell
    [Arguments]    ${PM_counter_file}	
	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list
    ${PDSCH_INI_All_Beam_counter_cell2}    	create list	
    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
    ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PDSCH_INI_All_Beam_counter_cell2}    ${PDSCH_INI_cell2}
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_INI_All_Beam_counter_cell2}	
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
	${PDSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell2})	
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell2}    	create list	
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
    ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell2}    ${PDSCH_SUC_cell2}
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_SUC_All_Beam_counter_cell2}	
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
	${PDSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell2})	
	Log To Console    \n----------------------end-------------------------
	
    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    ${PUSCH_INI_All_Beam_counter_cell2}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
    ${PUSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PUSCH_INI_All_Beam_counter_cell2}    ${PUSCH_INI_cell2}
	END	
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_INI_All_Beam_counter_cell2}	
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
	${PUSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell2})
    Log To Console    \n----------------------end-------------------------
	
	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell2}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
    ${PUSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell2}    ${PUSCH_SUC_cell2}	
	END		
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_SUC_All_Beam_counter_cell2}	
	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
	${PUSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell2})
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=2
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=2
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=2
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}   ${256_value}
	END	
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell2:${PDSCH_INITX_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell2:${PDSCH_INITX_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell2:${PDSCH_INITX_LOWSE_MCS_00_28_cell2}
	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell2})
	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
	${PDSCH_INITX_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell2})		
	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
	${PDSCH_INITX_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell2})	
    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
    ${PDSCH_LG_INITX_Sum_cell2}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell2}+${PDSCH_INITX_256TBL_Sum_cell2}+${PDSCH_INITX_LOWSE_Sum_cell2}		
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=2
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=2
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=2
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	END	
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell2:${PDSCH_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell2:${PDSCH_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell2:${PDSCH_SUC_LOWSE_MCS_00_28_cell2}
	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell2})
	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
	${PDSCH_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell2})		
	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
	${PDSCH_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell2})		
    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
    ${PDSCH_LG_SUC_Sum_cell2}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell2}+${PDSCH_SUC_256TBL_Sum_cell2}+${PDSCH_SUC_LOWSE_Sum_cell2}	
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013	

    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}    	create list	
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}    	create list		
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}   ${LOW_value}		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=2
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}   ${256_value}
	END	

	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
	${INI_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=2	
	${INI_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=2

    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell2:${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell2:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell2:${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}		
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell2:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell2:${INI_SAG_R2_C2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell2:${INI_SAG_R4_C2}
	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${CP_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell2})
	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
	${DFT_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2})	
	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
	${CP_INI_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell2})	
	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
	${CP_INI_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2})
	
    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
    ${PUSCH_LG_INI_Sum_cell2_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell2}+${DFT_INI_64TBL_Sum_cell2}+${CP_INI_256TBL_Sum_cell2}
    ${PUSCH_LG_INI_Sum_cell2}    Evaluate    ${PUSCH_LG_INI_Sum_cell2_tmp}+${CP_INI_LOWSE_Sum_cell2}+${INI_SAG_R2_C2}+${INI_SAG_R4_C2}	
    Log To Console    \n----------------------end-------------------------	

	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015

    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}    	create list	
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}    	create list	
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}    	create list		
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}		
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=2
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	END	

	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
	${SUC_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=2	
	${SUC_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=2

    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell2:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell2:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}		
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell2:${SUC_SAG_R2_C2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell2:${SUC_SAG_R4_C2}
	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${CP_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2})
	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
	${DFT_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2})	
	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
	${CP_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2})	
	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
	${CP_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2})

    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
    ${PUSCH_LG_SUC_Sum_cell2_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell2}+${DFT_SUC_64TBL_Sum_cell2}+${CP_SUC_256TBL_Sum_cell2}
    ${PUSCH_LG_SUC_Sum_cell2}    Evaluate    ${PUSCH_LG_SUC_Sum_cell2_tmp}+${CP_SUC_LOWSE_Sum_cell2}+${SUC_SAG_R2_C2}+${SUC_SAG_R4_C2}	
    Log To Console    \n----------------------end-------------------------	
	
    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   

	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell2--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell2:${PDSCH_INI_counter_Sum_cell2}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell2:${PDSCH_SUC_counter_Sum_cell2}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_INITX_Sum_cell2}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell2}==${PDSCH_LG_INITX_Sum_cell2}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell2}==${PDSCH_LG_SUC_Sum_cell2} 

	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 	

	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell2--------		
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell2:${PUSCH_INI_counter_Sum_cell2}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell2:${PUSCH_SUC_counter_Sum_cell2}		
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_INI_Sum_cell2}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell2}==${PUSCH_LG_INI_Sum_cell2}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell2}==${PUSCH_LG_SUC_Sum_cell2} 

	
Check_CNI113494_iBler_match_Legacy_counters_3cell
    [Arguments]    ${PM_counter_file}
	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list
    ${PDSCH_INI_All_Beam_counter_cell2}    	create list
    ${PDSCH_INI_All_Beam_counter_cell3}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
    ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PDSCH_INI_All_Beam_counter_cell2}    ${PDSCH_INI_cell2}
    ${PDSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3
    append to list    ${PDSCH_INI_All_Beam_counter_cell3}    ${PDSCH_INI_cell3}
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_INI_All_Beam_counter_cell2}
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_INI_All_Beam_counter_cell3}
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
	${PDSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell2})
	${PDSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell3})
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell2}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell3}    	create list
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
    ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PDSCH_SUC_All_Beam_counter_cell2}    ${PDSCH_SUC_cell2}
    ${PDSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3
    append to list    ${PDSCH_SUC_All_Beam_counter_cell3}    ${PDSCH_SUC_cell3}
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_SUC_All_Beam_counter_cell2}
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_SUC_All_Beam_counter_cell3}
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
	${PDSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell2})
	${PDSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell3})
	Log To Console    \n----------------------end-------------------------

    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    ${PUSCH_INI_All_Beam_counter_cell2}    	create list
    ${PUSCH_INI_All_Beam_counter_cell3}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
    ${PUSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PUSCH_INI_All_Beam_counter_cell2}    ${PUSCH_INI_cell2}
    ${PUSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3
    append to list    ${PUSCH_INI_All_Beam_counter_cell3}    ${PUSCH_INI_cell3}
	END
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_INI_All_Beam_counter_cell2}
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_INI_All_Beam_counter_cell3}
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
	${PUSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell2})
	${PUSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell3})
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell2}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell3}    	create list
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
    ${PUSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2
    append to list    ${PUSCH_SUC_All_Beam_counter_cell2}    ${PUSCH_SUC_cell2}
    ${PUSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3
    append to list    ${PUSCH_SUC_All_Beam_counter_cell3}    ${PUSCH_SUC_cell3}
	END
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_SUC_All_Beam_counter_cell2}
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_SUC_All_Beam_counter_cell3}

	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
	${PUSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell2})
	${PUSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell3})

    Log To Console    \n----------------------end-------------------------
	
	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell3}    	create list

    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell3}    	create list

    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=2
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=2
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=3
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell3}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=3
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=2
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=3
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell3}   ${256_value}

	END
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell2:${PDSCH_INITX_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell3:${PDSCH_INITX_64TBL_MCS_00_28_cell3}

    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell2:${PDSCH_INITX_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell3:${PDSCH_INITX_256TBL_MCS_00_27_cell3}

    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell2:${PDSCH_INITX_LOWSE_MCS_00_28_cell2}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell3:${PDSCH_INITX_LOWSE_MCS_00_28_cell3}

	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell2})
	${PDSCH_INITX_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell3})

	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
	${PDSCH_INITX_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell2})
	${PDSCH_INITX_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell3})

	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
	${PDSCH_INITX_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell2})
	${PDSCH_INITX_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell3})

    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
    ${PDSCH_LG_INITX_Sum_cell2}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell2}+${PDSCH_INITX_256TBL_Sum_cell2}+${PDSCH_INITX_LOWSE_Sum_cell2}
    ${PDSCH_LG_INITX_Sum_cell3}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell3}+${PDSCH_INITX_256TBL_Sum_cell3}+${PDSCH_INITX_LOWSE_Sum_cell3}

    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell3}    	create list

    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell3}    	create list

    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=2
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=2
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=3
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell3}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=3
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=2
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=3
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell3}   ${256_value}

	END
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell2:${PDSCH_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell3:${PDSCH_SUC_64TBL_MCS_00_28_cell3}

    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell2:${PDSCH_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell3:${PDSCH_SUC_256TBL_MCS_00_27_cell3}

    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell2:${PDSCH_SUC_LOWSE_MCS_00_28_cell2}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell3:${PDSCH_SUC_LOWSE_MCS_00_28_cell3}

	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell2})
	${PDSCH_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell3})

	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
	${PDSCH_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell2})
	${PDSCH_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell3})

	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
	${PDSCH_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell2})
	${PDSCH_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell3})

    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
    ${PDSCH_LG_SUC_Sum_cell2}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell2}+${PDSCH_SUC_256TBL_Sum_cell2}+${PDSCH_SUC_LOWSE_Sum_cell2}
    ${PDSCH_LG_SUC_Sum_cell3}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell3}+${PDSCH_SUC_256TBL_Sum_cell3}+${PDSCH_SUC_LOWSE_Sum_cell3}

    Log To Console    \n----------------------end-------------------------
	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013

    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}    	create list

    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}    	create list

    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}    	create list

    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=3
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=3
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=2
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=3
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=3
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}   ${256_value}
	END

	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
	${INI_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=2
	${INI_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=2
	${INI_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=3
	${INI_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=3

    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell2:${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell3:${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}

    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell2:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell3:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}

    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell2:${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell3:${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}

    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell2:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell3:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}

    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell2:${INI_SAG_R2_C2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell3:${INI_SAG_R2_C3}

    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell2:${INI_SAG_R4_C2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell3:${INI_SAG_R4_C3}

	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${CP_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell2})
	${CP_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell3})

	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
	${DFT_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2})
	${DFT_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3})

	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
	${CP_INI_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell2})
	${CP_INI_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell3})

	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
	${CP_INI_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2})
	${CP_INI_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3})


    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
    ${PUSCH_LG_INI_Sum_cell2_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell2}+${DFT_INI_64TBL_Sum_cell2}+${CP_INI_256TBL_Sum_cell2}
    ${PUSCH_LG_INI_Sum_cell2}    Evaluate    ${PUSCH_LG_INI_Sum_cell2_tmp}+${CP_INI_LOWSE_Sum_cell2}+${INI_SAG_R2_C2}+${INI_SAG_R4_C2}
    ${PUSCH_LG_INI_Sum_cell3_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell3}+${DFT_INI_64TBL_Sum_cell3}+${CP_INI_256TBL_Sum_cell3}
    ${PUSCH_LG_INI_Sum_cell3}    Evaluate    ${PUSCH_LG_INI_Sum_cell3_tmp}+${CP_INI_LOWSE_Sum_cell3}+${INI_SAG_R2_C3}+${INI_SAG_R4_C3}
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015

    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}    	create list

    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}    	create list

    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}    	create list

    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}    	create list

	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=3
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=3
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=2
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=3
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}   ${DFT_64}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=3
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}   ${256_value}
	END

	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
	${SUC_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=2
	${SUC_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=2
	${SUC_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=3
	${SUC_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=3

    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell2:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell3:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}

    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}

    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell2:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell3:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}

    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}

    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell2:${SUC_SAG_R2_C2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell3:${SUC_SAG_R2_C3}

    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell2:${SUC_SAG_R4_C2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell3:${SUC_SAG_R4_C3}

	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${CP_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2})
	${CP_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3})

	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
	${DFT_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2})
	${DFT_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3})

	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
	${CP_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2})
	${CP_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3})

	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
	${CP_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2})
	${CP_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3})

    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
    ${PUSCH_LG_SUC_Sum_cell2_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell2}+${DFT_SUC_64TBL_Sum_cell2}+${CP_SUC_256TBL_Sum_cell2}
    ${PUSCH_LG_SUC_Sum_cell2}    Evaluate    ${PUSCH_LG_SUC_Sum_cell2_tmp}+${CP_SUC_LOWSE_Sum_cell2}+${SUC_SAG_R2_C2}+${SUC_SAG_R4_C2}
    ${PUSCH_LG_SUC_Sum_cell3_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell3}+${DFT_SUC_64TBL_Sum_cell3}+${CP_SUC_256TBL_Sum_cell3}
    ${PUSCH_LG_SUC_Sum_cell3}    Evaluate    ${PUSCH_LG_SUC_Sum_cell3_tmp}+${CP_SUC_LOWSE_Sum_cell3}+${SUC_SAG_R2_C3}+${SUC_SAG_R4_C3}
    Log To Console    \n----------------------end-------------------------

    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}

	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell2--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell2:${PDSCH_INI_counter_Sum_cell2}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell2:${PDSCH_SUC_counter_Sum_cell2}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_INITX_Sum_cell2}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell2}==${PDSCH_LG_INITX_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell2}==${PDSCH_LG_SUC_Sum_cell2}

	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell3--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell3:${PDSCH_INI_counter_Sum_cell3}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell3:${PDSCH_SUC_counter_Sum_cell3}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_INITX_Sum_cell3}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_SUC_Sum_cell3}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell3}==${PDSCH_LG_INITX_Sum_cell3}
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell3}==${PDSCH_LG_SUC_Sum_cell3}

	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1}

	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell2--------
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell2:${PUSCH_INI_counter_Sum_cell2}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell2:${PUSCH_SUC_counter_Sum_cell2}
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_INI_Sum_cell2}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell2}==${PUSCH_LG_INI_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell2}==${PUSCH_LG_SUC_Sum_cell2}
	
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell3--------
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell3:${PUSCH_INI_counter_Sum_cell3}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell3:${PUSCH_SUC_counter_Sum_cell3}
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_INI_Sum_cell3}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_SUC_Sum_cell3}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell3}==${PUSCH_LG_INI_Sum_cell3}
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell3}==${PUSCH_LG_SUC_Sum_cell3}



Check_CNI113494_iBler_match_Legacy_counters_4cell
    [Arguments]    ${PM_counter_file}	
	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
    ${PDSCH_INI_All_Beam_counter_cell1}    	create list
    ${PDSCH_INI_All_Beam_counter_cell2}    	create list
    ${PDSCH_INI_All_Beam_counter_cell3}    	create list
    ${PDSCH_INI_All_Beam_counter_cell4}    	create list	
    FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
    ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
    ${PDSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PDSCH_INI_All_Beam_counter_cell2}    ${PDSCH_INI_cell2}
    ${PDSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
    append to list    ${PDSCH_INI_All_Beam_counter_cell3}    ${PDSCH_INI_cell3}
    ${PDSCH_INI_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
    append to list    ${PDSCH_INI_All_Beam_counter_cell4}    ${PDSCH_INI_cell4}	
	END
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_INI_All_Beam_counter_cell2}	
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_INI_All_Beam_counter_cell3}	
	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell4:${PDSCH_INI_All_Beam_counter_cell4}
	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})
	${PDSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell2})
	${PDSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell3})    
	${PDSCH_INI_counter_Sum_cell4}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell4})	
    Log To Console    \n----------------------end-------------------------


	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
    ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell2}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell3}    	create list
    ${PDSCH_SUC_All_Beam_counter_cell4}    	create list	
    FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
    ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
    ${PDSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell2}    ${PDSCH_SUC_cell2}
    ${PDSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell3}    ${PDSCH_SUC_cell3}
    ${PDSCH_SUC_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
    append to list    ${PDSCH_SUC_All_Beam_counter_cell4}    ${PDSCH_SUC_cell4}	
	END
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell2:${PDSCH_SUC_All_Beam_counter_cell2}	
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell3:${PDSCH_SUC_All_Beam_counter_cell3}	
	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell4:${PDSCH_SUC_All_Beam_counter_cell4}
	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})
	${PDSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell2})
	${PDSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell3})    
	${PDSCH_SUC_counter_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell4})	
	Log To Console    \n----------------------end-------------------------
	

			
    Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
    ${PUSCH_INI_All_Beam_counter_cell1}    	create list
    ${PUSCH_INI_All_Beam_counter_cell2}    	create list
    ${PUSCH_INI_All_Beam_counter_cell3}    	create list
    ${PUSCH_INI_All_Beam_counter_cell4}    	create list	
    FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
    ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
    ${PUSCH_INI_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PUSCH_INI_All_Beam_counter_cell2}    ${PUSCH_INI_cell2}
    ${PUSCH_INI_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
    append to list    ${PUSCH_INI_All_Beam_counter_cell3}    ${PUSCH_INI_cell3}
    ${PUSCH_INI_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
    append to list    ${PUSCH_INI_All_Beam_counter_cell4}    ${PUSCH_INI_cell4}	
	END	
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_INI_All_Beam_counter_cell2}	
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_INI_All_Beam_counter_cell3}	
	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell4:${PUSCH_INI_All_Beam_counter_cell4}
	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
	${PUSCH_INI_counter_Sum_cell2}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell2})
	${PUSCH_INI_counter_Sum_cell3}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell3})    
	${PUSCH_INI_counter_Sum_cell4}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell4})
    Log To Console    \n----------------------end-------------------------
	
	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
    ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell2}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell3}    	create list
    ${PUSCH_SUC_All_Beam_counter_cell4}    	create list	
    FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
    ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
    ${PUSCH_SUC_cell2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=2    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell2}    ${PUSCH_SUC_cell2}
    ${PUSCH_SUC_cell3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=3    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell3}    ${PUSCH_SUC_cell3}
    ${PUSCH_SUC_cell4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=4    
    append to list    ${PUSCH_SUC_All_Beam_counter_cell4}    ${PUSCH_SUC_cell4}		
	END		
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell2:${PUSCH_SUC_All_Beam_counter_cell2}	
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell3:${PUSCH_SUC_All_Beam_counter_cell3}	
	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell4:${PUSCH_SUC_All_Beam_counter_cell4}
	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
	${PUSCH_SUC_counter_Sum_cell2}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell2})
	${PUSCH_SUC_counter_Sum_cell3}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell3})    
	${PUSCH_SUC_counter_Sum_cell4}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell4})
    Log To Console    \n----------------------end-------------------------

	
	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
    ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell3}    	create list
    ${PDSCH_INITX_64TBL_MCS_00_28_cell4}    	create list	
    ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell3}    	create list
    ${PDSCH_INITX_256TBL_MCS_00_27_cell4}    	create list	
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}    	create list
    ${PDSCH_INITX_LOWSE_MCS_00_28_cell4}    	create list	
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=2
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=2
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=3
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell3}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=3
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=4
	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell4}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=4
	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=2
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell2}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=3
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell3}   ${256_value}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=4
	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell4}   ${256_value}
	END	
	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell2:${PDSCH_INITX_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell3:${PDSCH_INITX_64TBL_MCS_00_28_cell3}
    Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell4:${PDSCH_INITX_64TBL_MCS_00_28_cell4}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell2:${PDSCH_INITX_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell3:${PDSCH_INITX_256TBL_MCS_00_27_cell3}
    Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell4:${PDSCH_INITX_256TBL_MCS_00_27_cell4}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell2:${PDSCH_INITX_LOWSE_MCS_00_28_cell2}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell3:${PDSCH_INITX_LOWSE_MCS_00_28_cell3}
    Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell4:${PDSCH_INITX_LOWSE_MCS_00_28_cell4}
	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
	${PDSCH_INITX_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell2})
	${PDSCH_INITX_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell3})
	${PDSCH_INITX_64TBL_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell4})	
	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})
	${PDSCH_INITX_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell2})
	${PDSCH_INITX_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell3})
	${PDSCH_INITX_256TBL_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell4})		
	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
	${PDSCH_INITX_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell2})
	${PDSCH_INITX_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell3})
	${PDSCH_INITX_LOWSE_Sum_cell4}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell4})		
    ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}
    ${PDSCH_LG_INITX_Sum_cell2}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell2}+${PDSCH_INITX_256TBL_Sum_cell2}+${PDSCH_INITX_LOWSE_Sum_cell2}	
    ${PDSCH_LG_INITX_Sum_cell3}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell3}+${PDSCH_INITX_256TBL_Sum_cell3}+${PDSCH_INITX_LOWSE_Sum_cell3}
    ${PDSCH_LG_INITX_Sum_cell4}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell4}+${PDSCH_INITX_256TBL_Sum_cell4}+${PDSCH_INITX_LOWSE_Sum_cell4}	
    Log To Console    \n----------------------end-------------------------

	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
    ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell3}    	create list
    ${PDSCH_SUC_64TBL_MCS_00_28_cell4}    	create list	
    ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell3}    	create list
    ${PDSCH_SUC_256TBL_MCS_00_27_cell4}    	create list	
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}    	create list
    ${PDSCH_SUC_LOWSE_MCS_00_28_cell4}    	create list	
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=2
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell2}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=2
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=3
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell3}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=3
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=4
	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell4}   ${64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=4
	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=2
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=3
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell3}   ${256_value}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=4
	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell4}   ${256_value}
	END	
	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell2:${PDSCH_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell3:${PDSCH_SUC_64TBL_MCS_00_28_cell3}
    Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell4:${PDSCH_SUC_64TBL_MCS_00_28_cell4}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell2:${PDSCH_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell3:${PDSCH_SUC_256TBL_MCS_00_27_cell3}
    Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell4:${PDSCH_SUC_256TBL_MCS_00_27_cell4}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell2:${PDSCH_SUC_LOWSE_MCS_00_28_cell2}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell3:${PDSCH_SUC_LOWSE_MCS_00_28_cell3}
    Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell4:${PDSCH_SUC_LOWSE_MCS_00_28_cell4}
	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
	${PDSCH_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell2})
	${PDSCH_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell3})
	${PDSCH_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell4})	
	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})
	${PDSCH_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell2})
	${PDSCH_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell3})
	${PDSCH_SUC_256TBL_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell4})		
	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})
	${PDSCH_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell2})
	${PDSCH_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell3})
	${PDSCH_SUC_LOWSE_Sum_cell4}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell4})		
    ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}
    ${PDSCH_LG_SUC_Sum_cell2}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell2}+${PDSCH_SUC_256TBL_Sum_cell2}+${PDSCH_SUC_LOWSE_Sum_cell2}	
    ${PDSCH_LG_SUC_Sum_cell3}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell3}+${PDSCH_SUC_256TBL_Sum_cell3}+${PDSCH_SUC_LOWSE_Sum_cell3}
    ${PDSCH_LG_SUC_Sum_cell4}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell4}+${PDSCH_SUC_256TBL_Sum_cell4}+${PDSCH_SUC_LOWSE_Sum_cell4}
    Log To Console    \n----------------------end-------------------------


	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013	
	
	
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}    	create list
    ${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}    	create list		
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}    	create list
    ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}    	create list	
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}    	create list
    ${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}    	create list			
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}    	create list
    ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}    	create list	
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=3
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=3
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=4
	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=4
	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=2
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=2
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=3
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}   ${DFT_64}		
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=3
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}   ${256_value}	
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=4
	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=4
	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}   ${256_value}
	END	
	
	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
	${INI_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=2	
	${INI_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=2
	${INI_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=3	
	${INI_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=3	
	${INI_SAG_R2_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=4	
	${INI_SAG_R4_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=4

    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell2:${PUSCH_CP_INI_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell3:${PUSCH_CP_INI_64TBL_MCS_00_28_cell3}
    Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell4:${PUSCH_CP_INI_64TBL_MCS_00_28_cell4}	
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell2:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell3:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3}
    Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell4:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell2:${PUSCH_CP_INI_256TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell3:${PUSCH_CP_INI_256TBL_MCS_00_27_cell3}
    Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell4:${PUSCH_CP_INI_256TBL_MCS_00_27_cell4}		
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell2:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell3:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3}
    Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell4:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell2:${INI_SAG_R2_C2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell3:${INI_SAG_R2_C3}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell4:${INI_SAG_R2_C4}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell2:${INI_SAG_R4_C2}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell3:${INI_SAG_R4_C3}
    Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell4:${INI_SAG_R4_C4}
	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
	${CP_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell2})
	${CP_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell3})
	${CP_INI_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell4})
	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})
	${DFT_INI_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell2})
	${DFT_INI_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell3})
	${DFT_INI_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell4})	
	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})
	${CP_INI_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell2})
	${CP_INI_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell3})
	${CP_INI_256TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell4})	
	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
	${CP_INI_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell2})
	${CP_INI_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell3})
	${CP_INI_LOWSE_Sum_cell4}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell4})
	
    ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
    ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
    ${PUSCH_LG_INI_Sum_cell2_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell2}+${DFT_INI_64TBL_Sum_cell2}+${CP_INI_256TBL_Sum_cell2}
    ${PUSCH_LG_INI_Sum_cell2}    Evaluate    ${PUSCH_LG_INI_Sum_cell2_tmp}+${CP_INI_LOWSE_Sum_cell2}+${INI_SAG_R2_C2}+${INI_SAG_R4_C2}	
    ${PUSCH_LG_INI_Sum_cell3_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell3}+${DFT_INI_64TBL_Sum_cell3}+${CP_INI_256TBL_Sum_cell3}
    ${PUSCH_LG_INI_Sum_cell3}    Evaluate    ${PUSCH_LG_INI_Sum_cell3_tmp}+${CP_INI_LOWSE_Sum_cell3}+${INI_SAG_R2_C3}+${INI_SAG_R4_C3}	
    ${PUSCH_LG_INI_Sum_cell4_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell4}+${DFT_INI_64TBL_Sum_cell4}+${CP_INI_256TBL_Sum_cell4}
    ${PUSCH_LG_INI_Sum_cell4}    Evaluate    ${PUSCH_LG_INI_Sum_cell4_tmp}+${CP_INI_LOWSE_Sum_cell4}+${INI_SAG_R2_C4}+${INI_SAG_R4_C4}
    Log To Console    \n----------------------end-------------------------	
	

	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015
	
	
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}    	create list
    ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}    	create list		
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}    	create list
    ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}    	create list	
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}    	create list
    ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}    	create list			
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}    	create list
    ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}    	create list	
	
	FOR    ${i}    IN RANGE     0     29
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}   ${LOW_value}	
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=3
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=3
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}   ${LOW_value}
	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=4
	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}   ${CP_64_value}
	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=4
	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}   ${LOW_value}	
	END

	FOR    ${i}    IN RANGE     0     28
	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=2
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=2
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}   ${256_value}
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=3
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}   ${DFT_64}		
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=3
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}   ${256_value}	
	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=4
	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}   ${DFT_64}	
	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=4
	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}   ${256_value}
	END	
	
	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
	${SUC_SAG_R2_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=2	
	${SUC_SAG_R4_C2}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=2
	${SUC_SAG_R2_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=3	
	${SUC_SAG_R4_C3}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=3	
	${SUC_SAG_R2_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=4	
	${SUC_SAG_R4_C4}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=4


    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell2:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell3:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3}
    Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell4:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4}	
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3}
    Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell2:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell3:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3}
    Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell4:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4}		
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3}
    Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell2:${SUC_SAG_R2_C2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell3:${SUC_SAG_R2_C3}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell4:${SUC_SAG_R2_C4}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell2:${SUC_SAG_R4_C2}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell3:${SUC_SAG_R4_C3}
    Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell4:${SUC_SAG_R4_C4}
	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
	${CP_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell2})
	${CP_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell3})
	${CP_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell4})
	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})
	${DFT_SUC_64TBL_Sum_cell2}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell2})
	${DFT_SUC_64TBL_Sum_cell3}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell3})
	${DFT_SUC_64TBL_Sum_cell4}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell4})	
	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})
	${CP_SUC_256TBL_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell2})
	${CP_SUC_256TBL_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell3})
	${CP_SUC_256TBL_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell4})	
	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
	${CP_SUC_LOWSE_Sum_cell2}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell2})
	${CP_SUC_LOWSE_Sum_cell3}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell3})
	${CP_SUC_LOWSE_Sum_cell4}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell4})
	
    ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
    ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}
    ${PUSCH_LG_SUC_Sum_cell2_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell2}+${DFT_SUC_64TBL_Sum_cell2}+${CP_SUC_256TBL_Sum_cell2}
    ${PUSCH_LG_SUC_Sum_cell2}    Evaluate    ${PUSCH_LG_SUC_Sum_cell2_tmp}+${CP_SUC_LOWSE_Sum_cell2}+${SUC_SAG_R2_C2}+${SUC_SAG_R4_C2}	
    ${PUSCH_LG_SUC_Sum_cell3_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell3}+${DFT_SUC_64TBL_Sum_cell3}+${CP_SUC_256TBL_Sum_cell3}
    ${PUSCH_LG_SUC_Sum_cell3}    Evaluate    ${PUSCH_LG_SUC_Sum_cell3_tmp}+${CP_SUC_LOWSE_Sum_cell3}+${SUC_SAG_R2_C3}+${SUC_SAG_R4_C3}	
    ${PUSCH_LG_SUC_Sum_cell4_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell4}+${DFT_SUC_64TBL_Sum_cell4}+${CP_SUC_256TBL_Sum_cell4}
    ${PUSCH_LG_SUC_Sum_cell4}    Evaluate    ${PUSCH_LG_SUC_Sum_cell4_tmp}+${CP_SUC_LOWSE_Sum_cell4}+${SUC_SAG_R2_C4}+${SUC_SAG_R4_C4}
    Log To Console    \n----------------------end-------------------------	
	
    Log To Console    \n----------------------All Counter Summary-------------------------
	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   



	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell2--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell2:${PDSCH_INI_counter_Sum_cell2}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell2:${PDSCH_SUC_counter_Sum_cell2}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_INITX_Sum_cell2}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell2:${PDSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell2}==${PDSCH_LG_INITX_Sum_cell2}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell2}==${PDSCH_LG_SUC_Sum_cell2} 


	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell3--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell3:${PDSCH_INI_counter_Sum_cell3}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell3:${PDSCH_SUC_counter_Sum_cell3}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_INITX_Sum_cell3}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell3:${PDSCH_LG_SUC_Sum_cell3}
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell3}==${PDSCH_LG_INITX_Sum_cell3}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell3}==${PDSCH_LG_SUC_Sum_cell3} 


	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell4--------
	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell4:${PDSCH_INI_counter_Sum_cell4}
	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell4:${PDSCH_SUC_counter_Sum_cell4}
    Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell4:${PDSCH_LG_INITX_Sum_cell4}
    Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell4:${PDSCH_LG_SUC_Sum_cell4}	
    run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell4}==${PDSCH_LG_INITX_Sum_cell4}   
    run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell4}==${PDSCH_LG_SUC_Sum_cell4} 
	
	
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 	
	
	
	
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell2--------		
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell2:${PUSCH_INI_counter_Sum_cell2}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell2:${PUSCH_SUC_counter_Sum_cell2}		
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_INI_Sum_cell2}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell2:${PUSCH_LG_SUC_Sum_cell2}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell2}==${PUSCH_LG_INI_Sum_cell2}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell2}==${PUSCH_LG_SUC_Sum_cell2} 

	
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell3--------		
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell3:${PUSCH_INI_counter_Sum_cell3} 
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell3:${PUSCH_SUC_counter_Sum_cell3}	
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_INI_Sum_cell3}	
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell3:${PUSCH_LG_SUC_Sum_cell3}
    run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell3}==${PUSCH_LG_INI_Sum_cell3}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell3}==${PUSCH_LG_SUC_Sum_cell3} 
	
	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell4--------		
    Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell4:${PUSCH_INI_counter_Sum_cell4}
    Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell4:${PUSCH_SUC_counter_Sum_cell4}	
    Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell4:${PUSCH_LG_INI_Sum_cell4}
    Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell4:${PUSCH_LG_SUC_Sum_cell4}	    
	run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell4}==${PUSCH_LG_INI_Sum_cell4}   
    run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell4}==${PUSCH_LG_SUC_Sum_cell4}