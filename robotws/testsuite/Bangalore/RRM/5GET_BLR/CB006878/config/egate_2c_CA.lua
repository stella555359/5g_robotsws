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
local AP_CONFIG_PATH="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/L2PS_WRO/5GC000937/5GC000937_A/config/AirphoneConfig2.xml"
--local AP_CONFIG_PATH="/opt/wts/latest/AirphoneConfig2.xml"

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
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=632700:632700 gscn=7839 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 file='..AP_CONFIG_PATH)

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
for i=1,50 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=E1A09000575F7A1316000380A02C1001018093170019C3D0304D9061CF9863CA160704C020311C01AA3626EB04610D04083A4023EB64C558D0E7C471E819F604F8CC8E3C873E819F604FA8E7CC31E50B0381C3C5C0017C0070005F0001C80E003650000500000751B0A303582308682041D2011F5B262AC6873E238F40CFB027C66471E439F40CFB027D473E618F28581C0E1E2E000BE0038002F8000E007001860E140400000E30F0A000309A00010E30F0A000305000020E30E0A00E268000030E307134200000718789A00184D00010B80180510134142281A044D8E7C3851276C73E1C28913639F0E14E89B1CF870226C73E1C28913639F0C0F40B00F800A040300E0600A80E000C07C270040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000300200001C0100000E00800400000010000100080040300C010000120080000A004002020080080040701C0100001724A0040C030B925000061724A00C0C0300C030B92500406018061724A0180C0300C0300C0300C2E4940201806018060185C928070300C0300C0300C0300C2E094000185C928000313925002060189C928020300C0313825000062724A01C0C0300C0300C0300C031392500606018060189C92800030392500E060180601806018060181C928030300C0300C0E0940001818020000340DE54D654D60A56065606D60CD652D64CD602D60256045646D6E9182B40D04000025949410000196524040000A594941000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B9652504010300C965250400032594940C52AAAA55174AAAE95455058AA071541A2A94C55268AA031540A2A91D5576A0097C09E8140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A050000600101C00C20200C018080300010100600C04008000808030000200C018D50300008101820303A100')
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
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)
exec('sim_start version_check=off')
