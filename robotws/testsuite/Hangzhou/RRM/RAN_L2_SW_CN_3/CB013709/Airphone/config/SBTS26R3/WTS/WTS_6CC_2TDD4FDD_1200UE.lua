-- Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
os.execute('sudo sysctl -w net.core.wmem_max=674572800')
os.execute('sudo sysctl -w net.core.wmem_default=674572800')
os.execute('sudo sysctl -w net.core.rmem_max=674572800')
os.execute('sudo sysctl -w net.core.rmem_default=674572800')
os.execute('sudo sysctl -w net.sctp.rto_min=100')

CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT=22222
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

EDAEMON_PORT="22222"

--Variables for NSA configuration
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.2"

ENB1_X2_ADDR="10.0.1.121"
GNB_X2_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"
PDN_IP_2="4.7.254.209"


--new add

PLMN = "311:489"	--gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
TAC = 200	--gNB & AMF supported Tracking Area Code
FIRST_AMF_ID = 1   --Starting AMF id
AMF_COUNT = 6
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1

SA_UECID = 1
UEC_COUNT = 6   --Total number of UEC
AMF_IP_TABLE 	= { "10.0.1.1",
                   "10.0.1.61",
                   "10.0.1.62",
		   "10.0.1.63",
	           "10.0.1.64",
                   "10.0.1.65"
                    } 
UPF_IP_TABLE 	= { "1.2.0.1",
                    "1.2.8.1",
                    "1.2.16.1",
		    "1.2.24.1",
		    "1.2.32.1",
                    "1.2.40.1"
                    }  --IP table for each UPF
					
SNSSAI = "0x01:0xD143A5"	--SLICE ID

--add

--VLAN Finder
-------------------------------------------------------------------------------------
function find_vlan(interface)
    local filename = os.tmpname()
    local command = "ip link > " .. filename
    os.execute(command)
  
    local file = io.open(filename, "r")
    local output = ""
    if file then
      for line in file:lines() do
		if string.match(line, "trunk") then
			break
        elseif string.match(line, interface) then
          local vlan = string.match(line, "%.%d+")
          if vlan then
            output = vlan
            break
          end
        end
      end
      file:close()
      os.remove(filename)
    end
    if output ~= "" then
      return output -- Return VLAN ID if found
    else
      return "" -- Return empty string if VLAN ID is not found
    end
  end
  
  GNB_VLAN = find_vlan("eth3")
  AP_VLAN = find_vlan("eth4")
  
  -- Write the VLAN IDs to file
  os.execute('echo "GNB_VLAN:'..GNB_VLAN..'"> /opt/wts/latest/vlan')
  os.execute('echo "AP_VLAN:'..AP_VLAN..'">> /opt/wts/latest/vlan')

-------------------------------------------------------------------------------------
--IP configuration
--------------------------------------------------------------------------------------
for ip1 = 61, 65 do	--To configure IP 10.0.1.61,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
--    os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3.1801')
	os.execute('sudo ip addr add 10.0.1.'..ip1..'/24 dev eth3'..GNB_VLAN..'')
end

for ip2 = 3, 28 do	--To configure IP 10.0.2.3,.. on eth4. If interface has vlan 1001, configure below with 'dev eth4.1001'
    os.execute('sudo ip addr add 10.0.2.'..ip2..'/24 dev eth4'..AP_VLAN..'')
end

for ip3 = 131, 139 do	--To configure IP 10.0.1.131,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip3..'/24 dev eth3'..GNB_VLAN..'')
end

for ip4 = 200, 214 do	--To configure IP 10.0.1.200,.. on eth3. If interface has vlan 1801, configure below with dev eth3.1801'
    os.execute('sudo ip addr add 10.0.1.'..ip4..'/24 dev eth3'..GNB_VLAN..'')
end

os.execute('sudo sysctl net.sctp.rto_min=100') --UE_APP-OAM SCTP Delay WA
os.execute('rm egate_console.log.*')  --remove old or previous egate_console logs

----------------------------------------------------------------------------------------------------

					
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=1400:19400 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')
--exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=$DAEMON_IP:12219|$DAEMON_IP:8889 earfcn=1400:19400 tdd_cell=on mandatory_for_activation=off')
--exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')


----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=633000:633000 gscn=7840 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=637550:637550 gscn=7890 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=145700:156840 gscn=1959 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=390000:428000 gscn=5350 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 nr_arfcn=349500:368500 gscn=4604 eci=0x000021f pci=18:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x05 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 nr_arfcn=507000:531000 gscn=6636 eci=0x000021f pci=18:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x06 tdd_cell=off  mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------


--5GCN CONFIGURATION					
local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
    exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
    exec('set_amf id='..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
    exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
    exec('set_upf id='..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[array_id]..'/21 ngu='..AMF_IP_TABLE[array_id]..' devname=tunUPF'..amf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

    exec('smf_upf_mapping id='..amf_id..' upf='..amf_id)
    exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
	array_id = array_id + 1
end

--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
UEC_IP2 = UEC_COUNT + 2
UEC_IP = 1

for uec_id = 1, UEC_COUNT do
    exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
end

					
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
--new comment exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
--new comment exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
--new comment exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
--new comment exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
--new comment exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
--Cell 1 UEs:
FIRST_UE_SA_CELL_1 = 1
END_UD_SA_CELL_1 = 200
FIRST_UE_NSA_CELL_1 = 281
END_UE_NSA_CELL_1 = 285

FIRST_UE_SA_CELL_2 = 201
END_UD_SA_CELL_2 = 400
FIRST_UE_NSA_CELL_2 = 486
END_UE_NSA_CELL_2 = 590

FIRST_UE_SA_CELL_3 = 401
END_UD_SA_CELL_3 = 600
FIRST_UE_NSA_CELL_3 = 791
END_UE_NSA_CELL_3 = 800

FIRST_UE_SA_CELL_4 = 601
END_UD_SA_CELL_4 = 800

FIRST_UE_SA_CELL_5 = 801
END_UD_SA_CELL_5 = 1000

FIRST_UE_SA_CELL_6 = 1001
END_UD_SA_CELL_6 = 1200

--FDD cell
FIRST_UE_SA_CELL_11 = 2005
END_UD_SA_CELL_11 = 2205

FIRST_UE_SA_CELL_12 = 2206
END_UD_SA_CELL_12 = 2306

FIRST_UE_SA_CELL_13 = 2307
END_UD_SA_CELL_13 = 2408

FIRST_UE_SA_CELL_14 = 2409
END_UD_SA_CELL_14 = 2510


SA_Capa_6CC="FFA0F200475F7A6B5F83820140682002024107CC02024807031FFF800140F804060380950FC00DF981A150452CB2A20097BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE0D405002B66000F00066000F00002A1F805BF30342A08A596544012F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC1A80A0056CC001E000CC001E0000543F1377E606854114B2CA88025EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF83501400AD98003C00198003C0000A83E036FCC0D0A822965951004BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF06A028015B3000780033000780001507C1BDF981A150452CB2A20096BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FF77FFDBFFEDFFF6FFFB7FFDBFFEA3004DFE7FEDFE7FE0D405002B66000F00066000F000000945E268007134003800001C02000E03000706C0000015BF0000000020713400000FF0000000002400080050136003401B0543202813F03FD7B7027E07FAF6C0E043183F7FFFFE0B80F800F000C070380F000E07E0B00F000C035DC0E02C00380D770380B000E0400200000010008000001BC02910000002C880000056440000048013076F2A6B0568084F000029659427800054B2CA1200004A5965490000352CB2A4F000200000001141E2E954552ABAA0D7541628025010040080401002010020040400801010020040401805000802006168250"

IMSI_1 = 21641000
IMSI_2 = 21642000
IMSI_3 = 21643000
IMSI_4 = 21644000
IMSI_5 = 21645000
IMSI_6 = 21646000


QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UD_SA_CELL_1 do
	if SA_UECID > UEC_COUNT then
		SA_UECID = 1
	end
    exec('set_ue simulated id='..UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_Capa_6CC)
   --for gw_id = 1, 10 do
   --    exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
  -- end
   SA_UECID = SA_UECID + 1
end


for UEID = FIRST_UE_SA_CELL_2, END_UD_SA_CELL_2 do
	if SA_UECID > UEC_COUNT then
		SA_UECID = 1
	end
    exec('set_ue simulated id='..UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_Capa_6CC)
   --for gw_id = 1, 10 do
   --    exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
  -- end
   SA_UECID = SA_UECID + 1
end

for UEID = FIRST_UE_SA_CELL_3, END_UD_SA_CELL_3 do
	if SA_UECID > UEC_COUNT then
		SA_UECID = 1
	end
    exec('set_ue simulated id='..UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_3 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_Capa_6CC)
   SA_UECID = SA_UECID + 1
end

for UEID = FIRST_UE_SA_CELL_4, END_UD_SA_CELL_4 do
	if SA_UECID > UEC_COUNT then
		SA_UECID = 1
	end
    exec('set_ue simulated id='..UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:489:0000:0:0:0'.. IMSI_4 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_Capa_6CC)
   --for gw_id = 1, 10 do
   --    exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
  -- end
   SA_UECID = SA_UECID + 1
end


for UEID = FIRST_UE_SA_CELL_5, END_UD_SA_CELL_5 do
	if SA_UECID > UEC_COUNT then
		SA_UECID = 1
	end
    exec('set_ue simulated id='..UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=5 suci=0:311:489:0000:0:0:0'.. IMSI_5 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_Capa_6CC)
   SA_UECID = SA_UECID + 1
end

for UEID = FIRST_UE_SA_CELL_6, END_UD_SA_CELL_6 do
	if SA_UECID > UEC_COUNT then
		SA_UECID = 1
	end
    exec('set_ue simulated id='..UEID..' uec='..SA_UECID..' release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=6 suci=0:311:489:0000:0:0:0'.. IMSI_6 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_Capa_6CC)
   SA_UECID = SA_UECID + 1
end

local ip_base = "72.23."
--SA UES
for i=1,1200 do
    local ip_address = ip_base .. math.floor((i-1)/255) + 1 .. "." .. (i-1)%255 + 1 .. ".1"
    exec('set_pdu_gateway id='..i%255+1 ..' ue_nat_ip='..ip_address..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=1')
exec('set_qosflow id=3 5qi=2')
exec('set_qosflow id=4 5qi=3')
exec('set_qosflow id=5 5qi=4')
exec('set_qosflow id=6 5qi=5')
exec('set_qosflow id=8 5qi=7')
exec('set_qosflow id=9 5qi=8')
exec('set_qosflow id=10 5qi=9')
exec('set_qosflow id=11 5qi=128')
exec('set_qosflow id=12 5qi=66')
exec('set_qosflow id=13 5qi=80')
exec('set_qosflow id=14 5qi=82')
exec('set_qosrule id=1 proto=udp  qos_flow=1')
exec('set_qosrule id=2 proto=tcp  qos_flow=2')
exec('set_qosrule id=3 proto=udp  qos_flow=3')
exec('set_qosrule id=4 proto=udp  qos_flow=4')
exec('set_qosrule id=5 proto=udp  qos_flow=5')
exec('set_qosrule id=6 proto=udp  qos_flow=6')
exec('set_qosrule id=8 proto=udp  qos_flow=8')
exec('set_qosrule id=9 proto=udp  qos_flow=9')
exec('set_qosrule id=10 proto=udp  qos_flow=10')
exec('set_qosrule id=11 proto=udp  qos_flow=11')
exec('set_qosrule id=12 proto=udp  qos_flow=12')
exec('set_qosrule id=13 proto=udp  qos_flow=13')
exec('set_qosrule id=14 proto=udp  qos_flow=14')
exec('set_nwslice id=1 qos_flows=1,2,3,4,5,6,8,9,10,11,12,13,14 qos_rules=1,2,3,4,5,6,8,9,10,11,12,13,14 snssai=0x01:0xD143A5 default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')

--exec('set_nwslice id=1 qos_flows=1,2,3 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID..'')
for amf_id = FIRST_AMF_ID, END_AMF_ID do
	exec('smf_param id='..amf_id..' additional_qosflows_to_activate=2')
end

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('debug_log level=5')
--exec('sim_debug_log level=4 mme=1')
--exec('sim_debug_log level=4 pgw=1')
--exec('sim_debug_log level=4 uec=1')
--exec('sim_debug_log level=4 sgw=1')
--exec('sim_debug_log level=2 app_type=l2nrt')
--exec('sim_debug_log level=2 app_type=l2rt')
--exec('sim_debug_log level=2 app_type=ueproxy')
--exec('sim_debug_log enable_events_date=off')
--exec('sim_debug_log enable_debug_date=off')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')--new add
--exec('trace uec=1 protocol=rrc off')
--exec('trace uec=1 protocol=nr_rrc off')
--exec('trace enb=1 protocol=x2 off')
--exec('trace uec=1 protocol=x2 off')
--exec('sim_trace uec=1 protocol=nr_rrc off')
--exec('sim_trace amf='..FIRST_AMF_ID..','..END_AMF_ID..' protocol=ng off')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
