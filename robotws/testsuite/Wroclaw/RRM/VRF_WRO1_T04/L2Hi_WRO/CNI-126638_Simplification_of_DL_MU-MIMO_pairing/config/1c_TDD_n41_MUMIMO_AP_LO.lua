---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------

local CONTAINER_IP="10.0.2.1"
local DAEMON_IP=CONTAINER_IP
local SERVER_IP=CONTAINER_IP
local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"


--VARIABLES for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP1="4.7.254.208"
local PDN_IP2="4.7.254.209"
local PDN_IP3="4.7.254.210"
local PDN_IP4="4.7.254.211"
local PDN_IP5="4.7.254.212"
local PDN_IP6="4.7.254.213"
local PDN_IP7="4.7.254.214"
local PDN_IP8="4.7.254.215"
local PDN_IP9="4.7.254.216"
local PDN_IP10="4.7.254.217"


local UE_CAPA_SA="E1A09000575F7A13160003C12016080080C0498B800CE1E81826C830E7CC31E50B03826010188E00D51B137582308682041D2011F5B262AC6873E238F40CFB027C66471E439F40CFB027D473E618F28581C0E1E2E000BE0038002F80012403800D940001400001D46C28C0D608C21A0810748047D6C98AB1A1CF88E3D033EC09F1991C790E7D033EC09F51CF9863CA160703878B8002F800E000BE0004800E0030C1C280800001C61E14000613400021C61E1400060A000041C61C1401C4D0000061C60E268400000E30F13400309A00021700300A202682845034089B1CF870A24ED8E7C3851226C73E1C29D13639F0E044D8E7C3851226C73E181E81E00F800A040300E0600A80E000C07C270040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000300200001C0100000E00800400000010000100080040300C010000120080000A004002020080080040701C0100001724A0040C030B925000061724A00C0C0300C030B92500406018061724A0180C0300C0300C0300C2E4940201806018060185C928070300C0300C0300C0300C2E094000185C928000313925002060189C928020300C0313825000062724A01C0C0300C0300C0300C031392500606018060189C92800030392500E060180601806018060181C928030300C0300C0E0940001818020000340DE54D654D60A56065606D60CD652D64CD602D60256045646D6E9182B40D04000025949410000196524040000A594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504010300C965250400032594940C52AAAA55174AAAE95455058AA071541A2A94C55268AA031540A2A91D5576A018BE04F40A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028000300080E00610100600C040180008080300602004000404018000100600C6A8180004080C10181D0800"

NUMBER_OF_UES_SA=90
NUMBER_OF_UES_NSA=5

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')


---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')


---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')

exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 gscn=6372 eci=0x000021f nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=510000:510000 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

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
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 opc_key=0ED47545168EAFE2C39C075829A7B61F'..
         ' nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g suci=0:311:489:0000:0:0:0216454'..ue_id_aligned..' mode=nr enb=2 cell=1')
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities='..UE_CAPA_SA..'')
    exec('set_pdu_gateway id='..ue_id..' ue_nat_ip=72.23.'..ue_id..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for ue_id=NUMBER_OF_UES_SA+1,NUMBER_OF_UES_NSA+NUMBER_OF_UES_SA do
    local imsi_prefix = '311:489:216455'
    local ue_id_aligned
                if (ue_id>0 and ue_id<10) then ue_id_aligned = '0'..ue_id
                elseif (ue_id>=10 and ue_id<100) then ue_id_aligned = ue_id
                end
                local imsi = imsi_prefix..ue_id_aligned

    exec('set_ue simulated id='..ue_id..
         ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
         ' nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null'..
         ' imsi='..imsi)
    exec('ue_param id='..ue_id..
         ' ue_nr_capabilities=e1201000014f5e0302c00201404820d9c4c3e140426c020ffcc31e50b03826010188a01014c200141f11b586368e9315047f2ca4d940220b64c1203063c63ff30c7942c0e070f0113804e0001083011b9343e01c8200000148200000548200000949280000d300f81b7953781b5bac0141000009652504000065949410000296525040000e594941000049652524000154b29280ba07974ab2e81e4d2ac9a55915dc8020f00340201000000100'..
         ' dual_conn=eutra_nr'..
         ' ue_eutra_nr_capabilities=a10181102c0c0388c000000888160641c460000024400401c0462002100008040401803080008020200c0180')
    exec('set_bearer id=2 ue='..ue_id..
         ' qci=9 pdn=1 ip=4.7.254.'..ue_id..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 ue=all')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')


