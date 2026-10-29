---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

local PDN_IP="4.7.254.208"

NUMBER_OF_UES_SA=10

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 n4_snd_buff_size=20M n4_rcv_buff_size=20M')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION NR-ARFCN values UL:DL
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=17:0 tac=200 tdd_cell=on nrci=0x01 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636400:636400 gscn=7878 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:1 tac=200 tdd_cell=on nrci=0x02 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2071591:2071591 gscn=22446 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 sctp_rto_min=100 proxy_snd_buf_size=20000000 proxy_rcv_buf_size=20000000 tun_snd_buff_size=20000000 tun_rcv_buff_size=20000000 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for ue_id=1,NUMBER_OF_UES_SA do
    local ue_id_aligned
    if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
    elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
    end
    print(ue_id_aligned)

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+snow3g+aes nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00'..
         ' suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..
         ' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=E7A05000574F7E03560803C2A002C10010180910600098383C03120D000281009804062280C0299C052A3626EB04610D04083A40E0516CAA2A121CFA067D813E31CF99E7CA1609038780BFFFFF800FFFFFE00141F003582308682041E207024B65515050E7D033E31CF9863CA16070387813FFE00000FFF80000141F107582308682041E207024B65515050E7D033E31CF9863CA16070387813FB000000FEC00000540B41378E3087000A8F3F141C08FDB30552003C78010E208308A8147EFE40DC6E307400180E81680E06F1C610E00151E7E283811FB660AA40078F0021C4106115028FDFC81B8FC70E800301502D00DE38C21C002A3CFC507023F6CC154800F1E00438820C22A051F8790375FAE1D0006000C61E268007400C00007FFFFFFFFC41E208007410C30017FFFFFFFFC41E000007400C0000FFFFFFFFFC00C04D82001681D80E1C0C0040607033D19F0C06060600381865C587030010181C0C32E280581A0100800F413803E00280030101401C0C0250070006020211001042C0420010003278060080000092500E008020080200802008025C9280700401004010040100401300080000300F9415BA46E11831403040000259494101C0100401004010040100659494101C0100401004010040100A5949400000300F4A2AABB515CA8A0D540208080100202008010404020040100600C2020100200802004150B90080328')
    exec('set_pdu_gateway id='..ue_id..
         ' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=1')

exec('qosrule_set id=1 proto=tcp qos_flow=1')
exec('qosrule_set id=2 proto=udp qos_flow=2')

exec('set_nwslice id=1 qos_flows=1,2 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')
exec('amf_ue_ics_param ue=1 id=1 indexToRFSP=1 include_ue_capabilities=off')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=6')
exec('sim_debug_log level=1 uec=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
sleep(1)
