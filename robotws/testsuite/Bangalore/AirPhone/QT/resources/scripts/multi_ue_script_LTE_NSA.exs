import UExGate.Script

defmodule MultiUeScript do
    def lte_attach_with_profile_for_ap_iphy(ue_id, selected_qci, plmn) do

    exec("ue_attach id=#{ue_id} enb=1 cell=11 selected_plmn=#{plmn}"
    )

    exec(
	   "bearer_add ue=#{ue_id}  qci=#{selected_qci}"
    )

  end
  
  def lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
        start_ue,
        end_ue,
        delay_bw_ue_attach,
        selected_qci,
        plmn
      ) do
	  
    start_ue = String.to_integer(start_ue)
    end_ue = String.to_integer(end_ue)
    delay_bw_ue_attach = String.to_integer(delay_bw_ue_attach)
    selected_qci = String.to_integer(selected_qci)
    
    exec("ue_param id=#{start_ue}..#{end_ue} ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096340211807135E0000018800000094408200002100")

	
	  for ue_id <- start_ue..end_ue do
        if ue_id >= 1 and ue_id <= 20 do
          selected_qci = selected_qci - 1 + ue_id
          lte_attach_with_profile_for_ap_iphy(ue_id, selected_qci, plmn)
          Process.sleep(delay_bw_ue_attach)
        end
    end
  end
  
    def start_traffic_kbps_with_range(
        start_ue,
        end_ue,
        brid,
        dir,
        trf_id,
        kbpsrate
      ) do
    start_ue = String.to_integer(start_ue)
    end_ue = String.to_integer(end_ue)
    for ue_id <- start_ue..end_ue do
        exec(
          "trf_data_start ue=#{ue_id} dir=#{dir} protocol=udp bearer=#{brid} kbps=#{kbpsrate} trf_id=#{trf_id} stats=true"
        )
      end
        Process.sleep(2000)
        exec( "cell_stats id=11 type=#{dir}_pdcp unit=kbps")
	end
    
    def stop_traffic_kbps(
        start_ue,
		end_ue,
		brid,
		trf_id
    ) do
    start_ue = String.to_integer(start_ue)
    end_ue = String.to_integer(end_ue)
    for ue_id <- start_ue..end_ue do
        exec(
          "trf_data_stop ue=#{ue_id} bearer=#{brid} trf_id=#{trf_id}"
        )
	  end
  end

    def ue_dettach_with_profile(
        start_ue,
        end_ue
    ) do
    start_ue = String.to_integer(start_ue)
    end_ue = String.to_integer(end_ue)
    for ue_id <- start_ue..end_ue do
        exec(
          "ue_detach id=#{ue_id}"
        )
        end
  end
	
    def lte_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_operator(
        start_op1ue,
        end_op1ue,
        start_op2ue,
        end_op2ue,
        start_op3ue,
        end_op3ue,
        start_op4ue,
        end_op4ue,
        start_op5ue,
        end_op5ue,
        start_op6ue,
        end_op6ue,
        delay_bw_ue_attach,
        selected_qci,
        plmn1,
        plmn2,
        plmn3,
        plmn4,
        plmn5,
        plmn6
      ) do

    lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op1ue,
      end_op1ue,
      delay_bw_ue_attach,
      selected_qci,
      plmn1
    )

    Process.sleep(1000)
	
    lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op2ue,
      end_op2ue,
      delay_bw_ue_attach,
      selected_qci,
      plmn2
    )

    Process.sleep(1000)

    lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op3ue,
      end_op3ue,
      delay_bw_ue_attach,
      selected_qci,
      plmn3
    )

    Process.sleep(1000)

    lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op4ue,
      end_op4ue,
      delay_bw_ue_attach,
      selected_qci,
      plmn4
    )

    Process.sleep(1000)

    lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op5ue,
      end_op5ue,
      delay_bw_ue_attach,
      selected_qci,
      plmn5
    )

    Process.sleep(1000)

    lte_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op6ue,
      end_op6ue,
      delay_bw_ue_attach,
      selected_qci,
      plmn6
    )
  end

    def fiveG_attach_for_ap_iphy_SUE_1OPR(ue_id, phycell) do #NSA Attach and Measurement
        exec("ue_measurement_send event=B1_NR id=#{ue_id} phycell_id=#{phycell} srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
    end
	
	def nsa_attach_with_profile_for_ap_iphy(ue_id, enb_id, cell_id, selected_qci,plmn,split_per) do
        exec("ue_attach id=#{ue_id} enb=#{enb_id} cell=#{cell_id} selected_plmn=#{plmn} scg_ul_dist_percent=#{split_per}")
        exec("bearer_add ue=#{ue_id}  qci=#{selected_qci}")
    end
	
	
    def nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
        start_ue,
        end_ue,
		    enb_id,
  		  cell_id,
  	  	delay_bw_ue_attach,
        selected_qci,
	    	plmn,
		    phycell,
        split_per
      ) do
	  
        start_ue = String.to_integer(start_ue)
        end_ue = String.to_integer(end_ue)
        delay_bw_ue_attach = String.to_integer(delay_bw_ue_attach)
        selected_qci = String.to_integer(selected_qci)
        
        #UE capability
        exec("ue_param id=#{start_ue}..#{end_ue} ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0")
        exec("ue_param id=#{start_ue}..#{end_ue} ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010")
        exec("ue_param id=#{start_ue}..#{end_ue} ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096340211807135E0000018800000094408200002100")

	
    	for ue_id <- start_ue..end_ue do
        if ue_id >= 21 and ue_id <= 40 do
          selected_qci = selected_qci - 21 + ue_id
          nsa_attach_with_profile_for_ap_iphy(ue_id, enb_id, cell_id, selected_qci,plmn,split_per)
		      fiveG_attach_for_ap_iphy_SUE_1OPR(ue_id, phycell)
          Process.sleep(delay_bw_ue_attach)
        end
      end
  end
   
    def nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy_for_six_operator(
        start_op1ue,
        end_op1ue,
        start_op2ue,
        end_op2ue,
        start_op3ue,
        end_op3ue,
        start_op4ue,
        end_op4ue,
        start_op5ue,
        end_op5ue,
        start_op6ue,
        end_op6ue,
        delay_bw_ue_attach,
        selected_qci,
        plmn1,
        plmn2,
        plmn3,
        plmn4,
        plmn5,
        plmn6,
		enb_id,
		cell_id,
		phycell,
        split_per
      ) do

    nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op1ue,
      end_op1ue,
	  enb_id,
	  cell_id,
      delay_bw_ue_attach,
      selected_qci,
      plmn1,
	  phycell,
      split_per
    )

    Process.sleep(1000)
	
    nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op2ue,
      end_op2ue,
	  enb_id,
	  cell_id,
      delay_bw_ue_attach,
      selected_qci,
      plmn2,
	  phycell,
      split_per
    )

    Process.sleep(1000)

    nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op3ue,
      end_op3ue,
	  enb_id,
	  cell_id,
      delay_bw_ue_attach,
      selected_qci,
      plmn3,
	  phycell,
      split_per
    )

    Process.sleep(1000)

    nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op4ue,
      end_op4ue,
	  enb_id,
	  cell_id,
      delay_bw_ue_attach,
      selected_qci,
      plmn4,
	  phycell,
      split_per
    )

    Process.sleep(1000)

    nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op5ue,
      end_op5ue,
	  enb_id,
	  cell_id,
      delay_bw_ue_attach,
      selected_qci,
      plmn5,
	  phycell,
      split_per
    )

    Process.sleep(1000)

    nsa_attach_with_profile_multi_ue_with_range_for_AP_iphy(
      start_op6ue,
      end_op6ue,
	  enb_id,
	  cell_id,
      delay_bw_ue_attach,
      selected_qci,
      plmn6,
	  phycell,
      split_per
    )
  end 
  
  def start_traffic_kbps_with_diff_packet_size(
        start_ue,
        end_ue,
        brid,
        dir,
        trf_id,
        kbpsrate,
        packet_size_diff
      ) do
    start_ue = String.to_integer(start_ue)
    end_ue = String.to_integer(end_ue)
    pack_size_diff=String.to_integer(packet_size_diff)
    pack_size=500
    
    for ue_id <- start_ue..end_ue do
        pack_size=pack_size+(pack_size_diff*(ue_id-start_ue))
        exec(
          "trf_data_start ue=#{ue_id} dir=#{dir} protocol=udp bearer=#{brid} kbps=#{kbpsrate} trf_id=#{trf_id} size=#{pack_size} stats=true"
        )
        
      end
        Process.sleep(2000)
        exec( "cell_stats id=11 type=#{dir}_pdcp unit=kbps")
    end
    
    def nsa_handover(ue_id,pcell_id,event_id,narfcn,srsrp,srsrq,nrsrp,nrsrq)do
    
        exec("ue_measurement_send_nr id=#{ue_id} phycell_id=#{pcell_id} nrsrp=#{nrsrp} srsrp=#{srsrp} event=#{event_id} nrsrq=#{nrsrq} srsrq=#{srsrq} narfcn=#{narfcn}")

    end
    
    def mue_nsa_handover(start_ue,end_ue,pcell_id,event_id,narfcn,srsrp,srsrq,nrsrp,nrsrq)do
    
        start_ue = String.to_integer(start_ue)
        end_ue = String.to_integer(end_ue)
        
        for ue_id <- start_ue..end_ue do
            
            nsa_handover(ue_id,pcell_id,event_id,narfcn,srsrp,srsrq,nrsrp,nrsrq)
            
            Process.sleep(1000)
        end
    end
end	

	


