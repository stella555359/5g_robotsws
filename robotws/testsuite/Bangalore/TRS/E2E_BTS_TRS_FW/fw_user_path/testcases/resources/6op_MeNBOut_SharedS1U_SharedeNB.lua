-- Copyright (c) 2019 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
DAEMON_IP="10.0.2.1"
SERVER_IP=DAEMON_IP
DAEMON_PORT=22222



MME1_S1_ADDR="10.0.1.132"

GNB1_NGC1_ADDR="10.0.1.2"
AMF1_NG_ADDR="10.0.1.130"

ENB1_X2_ADDR="10.0.1.121"
ENB1_X2U_ADDR="10.0.1.135"

ENB1_S1_ADDR="10.0.1.136"
NGU1_ADDR="10.0.1.130"

SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

PGW_ADDR="4.7.254.207"
PROXY_SERVER_IP="10.0.2.80"

PDN_IP1="4.7.254.208"
UEC_ADDR="72.22.0.1"
UPF1_ADDR="1.2.3.1"

for QCI = 128, 148 do
exec('set_qci qci='..QCI..' gbr=no priority=1 delay=80')
end

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=8103,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..NGU1_ADDR..' devname=tunUPF ngu_snd_buff_size=8M ngu_rcv_buff_size=8M ngu_read_packets_threshold=10')

exec('smf_upf_mapping id=1 upf=1')
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 type=simulated plmn=311:489 s1='..ENB1_S1_ADDR..' x2='..ENB1_X2_ADDR..'  enb_id_macro=0x12346 x2u='..ENB1_X2U_ADDR..'  daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 tac=222 pci=3:1 proxy='..DAEMON_IP..':12219 earfcn=2000:20000 mapped_earfcn=4200:22200 eci=0x1234601 tdd_cell=on mandatory_for_activation=off  shared_plmn=311:490,311:491,311:492,311:493,311:494')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')
---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
--WITH DIFF IPs FOR NGU & NGC
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB1_NGC1_ADDR..' gnb_id=0x1 x2=10.0.1.2:36422 x2_peers=none amf=1 plmnList=311:489,311:490,311:491,311:492,311:493,311:494 nssai=0x01:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=16:2 tac=8103 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF mandatory_for_activation=off tdd_cell=on')


-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------

mme_id=1
mmegi_id=1
mnc_id=489

for mmeid_var = 1, 6 do
    exec('mme_pool_area id='..mme_id..' mmegi='..mmegi_id..' plmn=311:'..mnc_id..' tac_list=555,234,222,444,333,124')
    mnc_id=mnc_id+1
	mme_id=mme_id+1
end

exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1 pool=2:1 pool=3:1 pool=4:1 pool=5:1 pool=6:1 ')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':2152')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA1')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------

exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152  retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
MAX_NUM_UES = 100
IMSI_FIRST_UE=11111001
IMSI_FIRST_UE_SA=21645400


FIRST_UE_SA = 51
END_UE_SA = 100

QCI = 128
QCI2 = 129
QCI3 = 130

mnc_val=489
for UEID = 1, 6 do
	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=1 enb=1 uec=1 pdn=1  release=15 idle_edrx_cycle_len=2 ptw=2.56 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null imsi=311:'..mnc_val..':'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801') 
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
	
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=internal')
   
   
   --exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')  
    --exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1') 
    --exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
	    --QCI = QCI + 1
        --if (QCI2 < 147) then 
        ---QCI2 = QCI2 + 1
        ---else QCI2 = QCI2 - 1 
        --end
		--if (QCI3 < 145) then 
		--QCI3 = QCI3 + 1 
		--else QCI3 = QCI3 - 2
		--end
        mnc_val=mnc_val+1
end
-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
QOS_ID = 2
for QI = 128, 147 do
    exec('set_qosflow id='..QOS_ID..' 5qi='..QI..' default=off')
    QOS_ID = QOS_ID + 1
end

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all')

--exec('set_cnode   ip=127.0.0.1:7676')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('start version_check=off')
exec('sim_trace uec=1 protocol=nr_rrc,rrc on')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_debug_log level=6 uec=1')
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace amf=1 protocol=ng on')
--exec('sim_param_set NR_PDCP_CIPHERING=distributed')



