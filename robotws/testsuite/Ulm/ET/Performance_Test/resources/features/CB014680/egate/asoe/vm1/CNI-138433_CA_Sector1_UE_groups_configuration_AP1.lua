require "CNI-138433_CA_Sector1_SIMULATION_variables_AP1"


-------------------------------------------------------------
-- DEFINE TESTGROUPS AND reserved UES for every Group in CELL
-- Allowed types:
-- state_transition
-- dl_tput
-- ul_tput
-- ping_2drb_2
-- vonr
-- mobility_intra_gnb
-- ca_dl
-- ca_ul
-- ping_2drb_1
-- attach_detach
-------------------------------------------------------------

TEST_GROUPS_PER_CELL = {  -- make sure each ue_group has unique ue_group id. First cell 101 - 199, 2nd cell 201-299 etc
                          -- Also please remember that UEC instances will be rotated from 1 to 6 starting from beginning. Group 101 = UECID 1, Group 107,203,208 etc shares the same UEC ID 1. Make sure you don't overload one UEC too much e.g. with state transitions
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'state_transition_1', ue_group_id = 101, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'dl_tput',            ue_group_id = 102, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'ul_tput',            ue_group_id = 103, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'vonr',               ue_group_id = 104, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'ping_2drb_1',        ue_group_id = 105, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'ping_2drb_2',        ue_group_id = 106, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'attach_detach',      ue_group_id = 107, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'state_transition_2', ue_group_id = 108, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'mobility_intrafreq', ue_group_id = 109, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'bidir_tput',         ue_group_id = 110, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'RNA',                ue_group_id = 111, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'TAU',                ue_group_id = 112, ue_amount = 20  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'PAGING',             ue_group_id = 113, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'SLICE2',             ue_group_id = 114, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'SLICE3',             ue_group_id = 115, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'SLICE4',             ue_group_id = 116, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'SLICE5',             ue_group_id = 117, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[1].cell_id, ue_group_type = 'SLICE6',             ue_group_id = 118, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'state_transition_1', ue_group_id = 201, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'dl_tput',            ue_group_id = 202, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'ul_tput',            ue_group_id = 203, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'vonr',               ue_group_id = 204, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'ping_2drb_1',        ue_group_id = 205, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'ping_2drb_2',        ue_group_id = 206, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'attach_detach',      ue_group_id = 207, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'state_transition_2', ue_group_id = 208, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'mobility_intrafreq', ue_group_id = 209, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'bidir_tput',         ue_group_id = 210, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'RNA',                ue_group_id = 211, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'TAU',                ue_group_id = 212, ue_amount = 20  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'PAGING',             ue_group_id = 213, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'SLICE2',             ue_group_id = 214, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'SLICE3',             ue_group_id = 215, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'SLICE4',             ue_group_id = 216, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'SLICE5',             ue_group_id = 217, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[2].cell_id, ue_group_type = 'SLICE6',             ue_group_id = 218, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'state_transition_1', ue_group_id = 301, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'dl_tput',            ue_group_id = 302, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'ul_tput',            ue_group_id = 303, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'vonr',               ue_group_id = 304, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'ping_2drb_1',        ue_group_id = 305, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'ping_2drb_2',        ue_group_id = 306, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'attach_detach',      ue_group_id = 307, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'state_transition_2', ue_group_id = 308, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'mobility_intrafreq', ue_group_id = 309, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'bidir_tput',         ue_group_id = 310, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'RNA',                ue_group_id = 311, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'TAU',                ue_group_id = 312, ue_amount = 20  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'PAGING',             ue_group_id = 313, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'SLICE2',             ue_group_id = 314, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'SLICE3',             ue_group_id = 315, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'SLICE4',             ue_group_id = 316, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'SLICE5',             ue_group_id = 317, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[3].cell_id, ue_group_type = 'SLICE6',             ue_group_id = 318, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'state_transition_1', ue_group_id = 401, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'dl_tput',            ue_group_id = 402, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'ul_tput',            ue_group_id = 403, ue_amount = 80  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'vonr',               ue_group_id = 404, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'ping_2drb_1',        ue_group_id = 405, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'ping_2drb_2',        ue_group_id = 406, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'attach_detach',      ue_group_id = 407, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'state_transition_2', ue_group_id = 408, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'mobility_intrafreq', ue_group_id = 409, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'bidir_tput',         ue_group_id = 410, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'RNA',                ue_group_id = 411, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'TAU',                ue_group_id = 412, ue_amount = 20  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'PAGING',             ue_group_id = 413, ue_amount = 100 },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'SLICE2',             ue_group_id = 414, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'SLICE3',             ue_group_id = 415, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'SLICE4',             ue_group_id = 416, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'SLICE5',             ue_group_id = 417, ue_amount = 50  },
							{   cellid    = CELL_ID_TABLE[4].cell_id, ue_group_type = 'SLICE6',             ue_group_id = 418, ue_amount = 50  },
						}

function run_ue_configuration()

    exec('filter_sim_rfm enable=all')
	print('Total number of UEs reserved for gNB: '..NUMBER_OF_CELLS*UE_COUNT_ON_CELL)
	print('First cell id served by this AP: '..FIRST_CELL_ID)
	print('Number of items in TEST_GROUPS_PER_CELL table: '..#TEST_GROUPS_PER_CELL)

	for item=1, #CELL_ID_TABLE do
		print('-------------------------------------------------')
		print('Cell '..CELL_ID_TABLE[item].cell_id..' traffic model:')
		for groups = 1, #TEST_GROUPS_PER_CELL do
			if TEST_GROUPS_PER_CELL[groups].cellid == CELL_ID_TABLE[item].cell_id then
				print('Cell '..TEST_GROUPS_PER_CELL[groups].cellid..' UE group '..TEST_GROUPS_PER_CELL[groups].ue_group_type..' with ID '..TEST_GROUPS_PER_CELL[groups].ue_group_id..' has '..TEST_GROUPS_PER_CELL[groups].ue_amount..' UEs')
			end
			groups = groups + 1
		end
		item = item + 1
	end


	---------------------------------------------------------------------------------------------------
	--UE GROUPS FOR PET_SE
	---------------------------------------------------------------------------------------------------
	uecid = 1

	if PET_SE_FLAG == 'yes' then
		for item=1, #CELL_ID_TABLE do
			for groups = 1, #TEST_GROUPS_PER_CELL do
				if uecid > UEC_COUNT then
					uecid = 1
				end
				if TEST_GROUPS_PER_CELL[groups].cellid == CELL_ID_TABLE[item].cell_id then
					--print('set_ue_group id='..TEST_GROUPS_PER_CELL[groups].ue_group_id..' name=UE_GRP-'..TEST_GROUPS_PER_CELL[groups].ue_group_id..' uec='..uecid..' enb=2 cell='..cellid..' ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
					exec("set_ue_group id="..TEST_GROUPS_PER_CELL[groups].ue_group_id.." name=UE_GRP-"..TEST_GROUPS_PER_CELL[groups].ue_group_id.." uec="..uecid.." enb=2 cell="..TEST_GROUPS_PER_CELL[groups].cellid.." rohc=8:rtp,udp ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
					uecid = uecid + 1
				end
				groups = groups + 1
			end
			item = item + 1
		end
	end

	-- ---------------------------------------------------------------------------------------------------
	-- --UE CONFIGURATION
	-- ---------------------------------------------------------------------------------------------------

	SA_UECID = 1
	SA_CELLID = FIRST_CELL_ID

	-------------------------------------------------------------------
	-- Following code will create a new lua file which includes a table with SA UEID to GROUP mapping. It can be used to alter testmodes for all UEs in one group.
	local file = io.open(UEID_TO_GROUP_FILE,"rb")
	if file then
		file:close()
		assert(os.remove(UEID_TO_GROUP_FILE))
		print('File '..UEID_TO_GROUP_FILE..' exits and it is now deleted')
	end
	exec('filter_sim_rfm disable=all')
	exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR')
	file = io.open(UEID_TO_GROUP_FILE,"w")
	file:write("UEID_TO_GROUP_MAP = {", "\n")

	exec('filter_sim_rfm disable=all')
	exec('filter_sim_rfm enable=CSI,ACR,OERR,IERR')
	if Test_UEs == 'SA' or Test_UEs == 'Both' then
		if PET_SE_FLAG == 'yes' then
			SA_UEID = FIRST_UE_SA_CELL
			for item=1, #CELL_ID_TABLE do
				for groups = 1, #TEST_GROUPS_PER_CELL do
					UE_AMOUNT_IN_GROUP = 1
					if TEST_GROUPS_PER_CELL[groups].cellid == CELL_ID_TABLE[item].cell_id then
						if TEST_GROUPS_PER_CELL[groups].ue_amount > 0 then
							for UE_AMOUNT_IN_GROUP = 1, TEST_GROUPS_PER_CELL[groups].ue_amount do
								print('SA_UEID: '..SA_UEID..' cell: '..TEST_GROUPS_PER_CELL[groups].cellid)
								exec('set_ue id='..SA_UEID..' group='..TEST_GROUPS_PER_CELL[groups].ue_group_id..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..TEST_GROUPS_PER_CELL[groups].cellid..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
								exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
								file:write("                    { ueid=" ..tonumber(SA_UEID)..", group_id="..tonumber(TEST_GROUPS_PER_CELL[groups].ue_group_id)..", cell_id="..tonumber(TEST_GROUPS_PER_CELL[groups].cellid).." },", "\n")
								SA_UEID = SA_UEID + 1
								UE_AMOUNT_IN_GROUP = UE_AMOUNT_IN_GROUP + 1
								if SA_UEID > END_UE_SA_CELL then
									print('Too many UEs defined')
									return
								end
							end
						end
					end
					groups = groups + 1
				end
				item = item + 1
			end
			file:write("                    }", "\n")
	        file:close()
		else
			for SA_UEID = FIRST_UE_SA_CELL, END_UE_SA_CELL do
				if SA_CELLID > END_CELL_ID then
					SA_CELLID = FIRST_CELL_ID
				end
				if SA_UECID > UEC_COUNT then
					SA_UECID = 1
				end
				exec('set_ue simulated id='..SA_UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
				exec('ue_param id='..SA_UEID..' ue_nr_capabilities=UE_CAP_FDD_SA_RI4_PUSCH_2L_20MHz capability_file=./capability.cfg')
				SA_UECID = SA_UECID + 1
				SA_CELLID = SA_CELLID + 1
			end
		end
	end

	if Test_UEs == 'NSA' or Test_UEs == 'Both' then
		for NSA_UEID = FIRST_UE_NSA_CELL, END_UE_NSA_CELL do
			if NSA_CELLID > END_CELL_ID then
				NSA_CELLID = FIRST_CELL_ID
			end
			if NSA_UECID > UEC_COUNT then
				NSA_UECID = 1
			end
			exec('set_ue simulated id='..NSA_UEID..' uec='..NSA_UECID..' pdn=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=242:09:'.. NSA_IMSI + NSA_UEID - 1)
	--		exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c8000878180c4034026010180e01951b0a3582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b133582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b137582028688965954c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b13b582028680965944c043d6c10101070ef1c39061c00103278faa8000028000000841c4d00000000202682807008089ec1601800140e0601c0c01601c001a0f8000000000000395340004000025965400d2aba0207000b000000040080118b130001020304050607080b101112131921252627284a0 dual_conn=eutra_nr ue_eutra_nr_capabilities=010C040100904D00000402404D000200020100801002')
			exec('ue_param id='..NSA_UEID..' ue_nr_capabilities=NSA_UE_CAP dual_conn=eutra_nr ue_eutra_nr_capabilities=NSA_UE_EUTRA_CAP capability_file=./capability.cfg')
			if NSA_IP2 == 253 then
				NSA_IP1 = NSA_IP1 + 1
				NSA_IP2 = 1
			end
			exec('set_bearer id=2 ue='..NSA_UEID..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ip=4.7.'..NSA_IP1..'.'..NSA_IP2)
			NSA_UECID = NSA_UECID + 1
			NSA_CELLID = NSA_CELLID + 1
			NSA_IP2 = NSA_IP2 + 1
		end
	end
	exec('filter_sim_rfm enable=all')

end