-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=0,100,200,258,788 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 xn='..GNB_NG_ADDR)
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on gscn=7880 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on gscn=7880 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off gscn=1582 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off gscn=1582 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380')


exec('set_gnb id=3 xn=10.0.1.101 ng=10.0.1.102 plmn=311:489 gnb_id=0x3 type=simulated daemon='..SERVER_IP..':'..EDAEMON_PORT..' nssai=0x01:0xD143A5')
exec('gnb_param id=3 sib1_period=40 send_xn_setup=false xn_listening_socket=on measEvent=A5')
exec('cell_set id=1 gnb=3 tac=200 pci=17:1 nr_arfcn=636666:636666 proxy=:5555 nrci=0x1 tdd_cell=on gscn=7880 nr_scs=30kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=636576 ssb_subcarrier_spacing=kHz30 ssb_mtc_periodicity_and_offset=sf5:0 ssb_mtc_duration=sf1')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,50 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:021645400 enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A0000007C8E5A031E00038420007824C1900010F09003100D00980C0301C01AA3626EB04052D012CB289A482C3400F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8002C4003B7000080000000700008000000002A8D89DAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F5500000500000162001DB800040000000380004000000000021071340000000378EAAF2015E482C04D1700007008089EC2F0036003C00301C1401E0C026007800683E0000000000000E54D000100000965950034AAA85800E001600000008010023162600020406080A0C0E10162022242632424A4C4E50940')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

exec('debug_log level=0')
exec('trace uec=1 protocol=nr_rrc on')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('start version_check=off')
