require "wts_variable"


function total_ue_amount()
	TOTAL_UE_AMOUNT = 0
	for _, UEs in ipairs(TEST_TYPES_PER_CELL) do
		TOTAL_UE_AMOUNT = TOTAL_UE_AMOUNT + #INCLUDED_FOR_TEST_TYPES_PER_CELL * UEs.ue_amount
	end

	for _, UEs in ipairs(INDIVIDUAL_UE_GROUPS) do
		TOTAL_UE_AMOUNT = TOTAL_UE_AMOUNT + UEs.ue_amount
	end

	return TOTAL_UE_AMOUNT
end


function set_amf_to_register_multiue2(start_amf, end_amf, plmn, num_ues)
	-- Function moved from external resources
    local err = {}
    local result = {}
    local state = {}
    local amf_region_id = start_amf
    local amf_set_id = 2
    local amf_pointer = 2

    for loop_id=1, num_ues do
        -- exec("ue_nr_rrc_setup_param  id="..loop_id.." registered_amf="..plmn.."|"..amf_region_id..":"..amf_set_id..":"..amf_pointer.." exclude_stmsi=on s_tmsi_format=random:none:none")
        exec("ue_nr_rrc_setup_param id="..loop_id.." registered_amf="..plmn.."|"..amf_region_id..":"..amf_set_id..":"..amf_pointer.." exclude_stmsi=on")
        if amf_region_id >= end_amf then
            amf_region_id = start_amf
            amf_set_id = 2
            amf_pointer = 2
        else
            amf_region_id = amf_region_id + 1
            amf_set_id = amf_set_id + 1
            amf_pointer = amf_pointer + 1
        end
    end
end


function start_traffic()
	TOTAL_UE_AMOUNT = total_ue_amount()

	-------------------------------------------------------
	-- CREATE SEQUENCES and MAP UE TYPE to UE GROUP
	-------------------------------------------------------

	id = 0

	for index = 1, #INCLUDED_FOR_TEST_TYPES_PER_CELL do
		ue_group = INCLUDED_FOR_TEST_TYPES_PER_CELL[index] * 10 + 1
		for index, test_data in ipairs(TEST_TYPES_PER_CELL) do
			id = id + 1
			exec('seq_set file=./'..test_data.file..' id='..id..' ue_group='..ue_group..'')
			ue_group = ue_group + 1
		end
	end

	individual_ue_group_id = 700
	for index, test_data in ipairs(INDIVIDUAL_UE_GROUPS) do
		individual_ue_group_id = individual_ue_group_id + 1
		id = id + 1
		exec('seq_set file=./'..test_data.file..' id='..id..' ue_group='..individual_ue_group_id..'')
	end

	---------------------------------------------------------------------------------------------------
	-- SETUP AMF AND OTHER CONFIGURATION BEFORE STARTING SEQUENCES
	---------------------------------------------------------------------------------------------------

	--set_amf_to_register_multiue2(1, AMF_COUNT, PLMN, TOTAL_UE_AMOUNT)

	exec('uec_l2_testmode_params fixed_csi_report=true')	

	-- DISABLE LOGGING
	exec('sim_param_set disable_events_on_telnet_session=yes')

	---------------------------------------------------------------------------------------------------
	-- START SEQUENCES
	---------------------------------------------------------------------------------------------------

	for index = 1, id do
		exec('seq_start id='..index..' rate=0.5 start_delay='..index..'')
	end
end

function stop_traffic()
	-- More graceful stop without radio link failures
	TOTAL_UE_AMOUNT = total_ue_amount()
	exec('seq_stop id=all mode=abort rate=1')
	sleep(30)
	exec('ue_deregister by=ue id=all ue_deregister_type=switch_off')
	exec('sim_param_set disable_events_on_telnet_session=no')
end
