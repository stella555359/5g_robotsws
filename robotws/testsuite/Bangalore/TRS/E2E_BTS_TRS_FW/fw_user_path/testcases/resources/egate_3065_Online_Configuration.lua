--************************************************************************************
--************************************************************************************
-- HW variables
DAEMON_PORT = 50000


NETWORK_NUMBER='1.7'
NAT_NETWORK_NUMBER = '11.7'

NETWORK2_NUMBER='2.7.'
NAT_NETWORK2_NUMBER = '12.7.'

NETWORK3_NUMBER='3.7.'
NAT_NETWORK3_NUMBER = '13.7.'

NETWORK4_NUMBER='4.7.'
NAT_NETWORK4_NUMBER = '14.7.'

NETWORK5_NUMBER='5.7.'
NAT_NETWORK5_NUMBER = '15.7.'

NETWORK6_NUMBER='6.7.'
NAT_NETWORK6_NUMBER = '16.7.'

SERVER_IP = '10.0.2.1' -- IPaddress of uelinpc eth2
EPC_IP = '10.0.1.1'
sgw_o1_v4 = '10.0.1.20'
sgw_o2_v4 = '10.0.1.21'
sgw_o3_v4 = '10.0.1.22'
sgw_o4_v4 = '10.0.1.23'
sgw_o5_v4 = '10.0.1.24'
sgw_o6_v4 = '10.0.1.25'
mme_o1_v4 = '10.0.1.26'
mme_o2_v4 = '10.0.1.27'
mme_o3_v4 = '10.0.1.28'
mme_o4_v4 = '10.0.1.29'
mme_o5_v4 = '10.0.1.30'
mme_o6_v4 = '10.0.1.31'

sgw_o1_v6 = 'fc00::20'
sgw_o2_v6 = 'fc00::21'
sgw_o3_v6 = 'fc00::22'
sgw_o4_v6 = 'fc00::23'
sgw_o5_v6 = 'fc00::24'
sgw_o6_v6 = 'fc00::25'
mme_o1_v6 = 'fc00::26'
mme_o2_v6 = 'fc00::27'
mme_o3_v6 = 'fc00::28'
mme_o4_v6 = 'fc00::29'
mme_o5_v6 = 'fc00::30'
mme_o6_v6 = 'fc00::31'
PROXY_ADDR = '10.0.2.2:2152' -- I-PHY FSMr3 address

ENB_ADDR='10.0.1.2'
S1_ADDR='10.0.1.1:36412' -- IP of MME as specified in eNB config
S1U_ADDR='10.0.1.1:2152'
S11_ADDR='10.0.1.1:2153'

DAEMONS={ EPC_ADDR= '10.0.1.1',
      UEC_ADDR_IP= '10.0.2.1'}

UE_COUNT = 20
CELL_COUNT = 3

--trf_type=internal

--************************************************************************************
--************************************************************************************

function get_ip(network_number)
    local _ip_ = ''
    local _index_ = 1
    for w in string.gmatch(network_number, "%d+") do
        _number_ = tostring(tonumber(w))
        
        if _index_ < 4 then
            _ip_=_ip_.._number_..'.'
        else
            _ip_=_ip_.._number_
        end
        _index_=_index_+1
    end
    return _ip_
end

function check_user_var(value, name)
    if (nil == value) then
        print("CFG ERROR: No "..name .. " set in user_vars.lua")
        return false
    end
    return true
end

--************************************************************************************
--************************************************************************************
--CHECK USER VARS PERAMETRES
if ( check_user_var(DAEMON_PORT,'DAEMON_PORT')
    and check_user_var(NETWORK_NUMBER,"NETWORK_NUMBER")
    and check_user_var(NAT_NETWORK_NUMBER,"NAT_NETWORK_NUMBER")
    and check_user_var(NETWORK2_NUMBER,"NETWORK2_NUMBER")
    and check_user_var(NAT_NETWORK2_NUMBER,"NAT_NETWORK2_NUMBER")
    and check_user_var(NETWORK3_NUMBER,"NETWORK3_NUMBER")
    and check_user_var(NAT_NETWORK3_NUMBER,"NAT_NETWORK3_NUMBER")
    and check_user_var(NETWORK4_NUMBER,"NETWORK4_NUMBER")
    and check_user_var(NAT_NETWORK4_NUMBER,"NAT_NETWORK4_NUMBER")
    and check_user_var(NETWORK5_NUMBER,"NETWORK5_NUMBER")
    and check_user_var(NAT_NETWORK5_NUMBER,"NAT_NETWORK5_NUMBER")
    and check_user_var(NETWORK6_NUMBER,"NETWORK6_NUMBER")
    and check_user_var(NAT_NETWORK6_NUMBER,"NAT_NETWORK6_NUMBER")
    and check_user_var(PROXY_ADDR,"PROXY_ADDR")
    ) then

--************************************************************************************
--************************************************************************************
--COUNTABLE PARAMETERES
UEC_ADDR    = NAT_NETWORK_NUMBER..'.254'..'.254'

PGW_ADDR    = NETWORK_NUMBER..'.'..'254'..'.'..'254'
PGW2_ADDR   = NETWORK2_NUMBER..'.'..'254'..'.'..'254'
PGW3_ADDR   = NETWORK3_NUMBER..'.'..'254'..'.'..'254'
PGW4_ADDR   = NETWORK4_NUMBER..'.'..'254'..'.'..'254'

sec_key='0102030405060708090A0B0C0D0E'


--*****************************************************************************
--*****************************************************************************
-- SET VARIABLES
exec('set DAEMON_PORT='..DAEMON_PORT)

exec('set UE_COUNT='..UE_COUNT)

exec('set PROXY_PORT='..2152)
exec('set PROXY_IP='..get_ip(PROXY_ADDR))

exec('set ENB_ADDR='..get_ip(ENB_ADDR))
exec('set S1_ADDR='..'"'..S1_ADDR..'"')
exec('set S1U_ADDR='..'"'..S1U_ADDR..'"')
exec('set S11_ADDR='..'"'..S11_ADDR..'"')
exec('set PGW_ADDR='..get_ip(PGW_ADDR))

exec('set EPC_IP="'..EPC_IP..'"')
exec('set sgw_o1_v4="'..sgw_o1_v4..'"')
exec('set sgw_o2_v4="'..sgw_o2_v4..'"')
exec('set sgw_o3_v4="'..sgw_o3_v4..'"')
exec('set sgw_o4_v4="'..sgw_o4_v4..'"')
exec('set sgw_o5_v4="'..sgw_o5_v4..'"')
exec('set sgw_o6_v4="'..sgw_o6_v4..'"')
exec('set mme_o1_v4="'..mme_o1_v4..'"')
exec('set mme_o2_v4="'..mme_o2_v4..'"')
exec('set mme_o3_v4="'..mme_o3_v4..'"')
exec('set mme_o4_v4="'..mme_o4_v4..'"')
exec('set mme_o5_v4="'..mme_o5_v4..'"')
exec('set mme_o6_v4="'..mme_o6_v4..'"')

exec('set sgw_o1_v6="'..sgw_o1_v6..'"')
exec('set sgw_o2_v6="'..sgw_o2_v6..'"')
exec('set sgw_o3_v6="'..sgw_o3_v6..'"')
exec('set sgw_o4_v6="'..sgw_o4_v6..'"')
exec('set sgw_o5_v6="'..sgw_o5_v6..'"')
exec('set sgw_o6_v6="'..sgw_o6_v6..'"')
exec('set mme_o1_v6="'..mme_o1_v6..'"')
exec('set mme_o2_v6="'..mme_o2_v6..'"')
exec('set mme_o3_v6="'..mme_o3_v6..'"')
exec('set mme_o4_v6="'..mme_o4_v6..'"')
exec('set mme_o5_v6="'..mme_o5_v6..'"')
exec('set mme_o6_v6="'..mme_o6_v6..'"')

exec('set UEC1_ADDR='..get_ip(UEC_ADDR))
exec('set UEC1_PIP="'..SERVER_IP..':2152"')

--***************************************************************
--***************************************************************
-- BEGIN CONFIGURATION
sim_ = sim()
if (sim.INIT == sim_.state) then
sim_:configure()
end
exec('debug_log gate=1 level=0')

--*************************USER DEFINED QCI*******************************************

exec('set_qci qci=128 gbr=yes priority=2 delay=80') -- QCI=128 GBR RLC-UM
exec('set_qci qci=191 gbr=yes priority=3 delay=80') -- QCI=191 GBR RLC-UM
exec('set_qci qci=254 gbr=yes priority=4 delay=80') -- QCI=254 GBR RLC-UM

--******************ENB INFO*************************************
exec('set_enb type=external id=1 plmn=244:09 s1=10.0.3.210 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=2 plmn=404:99 s1=10.0.3.214 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=3 plmn=777:12 s1=10.0.3.218 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=4 plmn=777:17 s1=10.0.3.222 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=5 plmn=777:18 s1=10.0.3.226 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=6 plmn=777:19 s1=10.0.3.230 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')

exec('set_enb type=external id=7 plmn=244:09 s1=fc00::3:7 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=8 plmn=404:99 s1=fc00::3:b enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=9 plmn=777:12 s1=fc00::3:f enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=10 plmn=777:17 s1=fc00::3:13 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=11 plmn=777:18 s1=fc00::3:17 enb_id_macro=0x00001 daemon=:$DAEMON_PORT')
exec('set_enb type=external id=12 plmn=777:19 s1=fc00::3:1b enb_id_macro=0x00001 daemon=:$DAEMON_PORT')


-- TODO: derive from CELL_COUNT
exec('set_cell id=11 enb=1 pci=3:2 tac=124 shared_plmn=404:99,777:12,777:17,777:18,777:19 proxy='..PROXY_ADDR..' eci=0x000010B')
exec('set_cell id=12 enb=1 pci=4:0 tac=124 shared_plmn=404:99,777:12,777:17,777:18,777:19 proxy='..PROXY_ADDR..' eci=0x000010C')
exec('set_cell id=13 enb=1 pci=4:1 tac=124 shared_plmn=404:99,777:12,777:17,777:18,777:19 proxy='..PROXY_ADDR..' eci=0x000010D')
--exec('set_cell id=4 enb=1 pci=2:1 tac=124 proxy='..PROXY_ADDR..' eci=0x0D6F004')


-- NOTE: the EPC runs in a different egate!!

--exec('set_mme id=1 type=simulated ip=$EPC_IP:50000 s1=$S1_ADDR mmegi=1 mmec=3')
--exec('set_sgw id=1 type=simulated ip=$EPC_IP:50000 s1u=$S1U_ADDR s11=$S11_ADDR')
exec('set_pgw id=1 type=simulated ip=$EPC_IP:50000 apn=ulm1.net devtype=tun devname=pgw477 addr=$PGW_ADDR/16')

exec('set_uec id=1 ip=:$DAEMON_PORT gtpu=on pdn=1 addr=$UEC1_ADDR/16 peer=$UEC1_PIP retries=unlimited')


-- RAN SHARING CONFIG START--
--MME POOL RANSHARING

--configuring simulated devices (ePC)

--multi MME
exec('mme_pool_area id=1 mmegi=1 plmn=244:09 tac_list=124')
exec('mme_pool_area id=2 mmegi=2 plmn=404:99 tac_list=124')
exec('mme_pool_area id=3 mmegi=3 plmn=777:12 tac_list=124')
exec('mme_pool_area id=4 mmegi=4 plmn=777:17 tac_list=124')
exec('mme_pool_area id=5 mmegi=5 plmn=777:18 tac_list=124')
exec('mme_pool_area id=6 mmegi=6 plmn=777:19 tac_list=124')

--operator 1 MME
exec('set_mme id=1 type=simulated ip=$EPC_IP:50000 s1=$mme_o1_v4:36412 pool=1:1')
exec('set_mme id=7 type=simulated ip=$EPC_IP:50000 s1=$mme_o1_v6.36412 pool=1:2')

--operator 2 MMES
exec('set_mme id=2 type=simulated ip=$EPC_IP:50000 s1=$mme_o2_v4:36412 pool=2:3')
exec('set_mme id=8 type=simulated ip=$EPC_IP:50000 s1=$mme_o2_v6.36412 pool=2:4')

--operator 3 MMES
exec('set_mme id=3 type=simulated ip=$EPC_IP:50000 s1=$mme_o3_v4:36412 pool=3:5')
exec('set_mme id=9 type=simulated ip=$EPC_IP:50000 s1=$mme_o3_v6.36412 pool=3:6')

--operator 4 MMES
exec('set_mme id=4 type=simulated ip=$EPC_IP:50000 s1=$mme_o4_v4:36412 pool=4:7')
exec('set_mme id=10 type=simulated ip=$EPC_IP:50000 s1=$mme_o4_v6.36412 pool=4:8')

--operator 5 MMES
exec('set_mme id=5 type=simulated ip=$EPC_IP:50000 s1=$mme_o5_v4:36412 pool=5:9')
exec('set_mme id=11 type=simulated ip=$EPC_IP:50000 s1=$mme_o5_v6.36412 pool=5:10')

--operator 6 MMES
exec('set_mme id=6 type=simulated ip=$EPC_IP:50000 s1=$mme_o6_v4:36412 pool=6:11')
exec('set_mme id=12 type=simulated ip=$EPC_IP:50000 s1=$mme_o6_v6.36412 pool=6:12')


-------------------------------------------------------------------------------------------------------------
exec('set_sgw id=1 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o1_v4:2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')
exec('set_sgw id=7 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o1_v6.2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')

exec('set_sgw id=2 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o2_v4:2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')
exec('set_sgw id=8 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o2_v6.2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')

exec('set_sgw id=3 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o3_v4:2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')
exec('set_sgw id=9 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o3_v6.2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')

exec('set_sgw id=4 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o4_v4:2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')
exec('set_sgw id=10 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o4_v6.2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')

exec('set_sgw id=5 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o5_v4:2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')
exec('set_sgw id=11 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o5_v6.2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')

exec('set_sgw id=6 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o6_v4:2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')
exec('set_sgw id=12 type=simulated ip=$EPC_IP:50000 s1u=$sgw_o6_v6.2152 s1u_rcv_buff_size=32000000 s1u_snd_buff_size=32000000 s5u_rcv_buff_size=16000000 s5u_snd_buff_size=16000000')


-----------------------------------------------------

--*****NEIGHBORING ENB*********
--                exec('set_enb id=30 type=simulated daemon='..DAEMONS.EPC_ADDR..':10001 x2=10.0.1.28:36422 x2u=10.0.1.28 s1=10.0.1.28 plmn=244:09 enb_id_macro=0x0001E x2_peers=none name=enbsim30')
--                exec('set_cell id=11 enb=30 tac=124 pci=20:1 shared_plmn=404:99 proxy='..DAEMONS.EPC_ADDR..':10666 earfcn=1400:19400 eci=0x0001E01')

for cell_id=1,CELL_COUNT do
    for ue_index=1,UE_COUNT do
        ue_id = cell_id * 1000 + ue_index

        if (ue_index>0 and ue_index<=250) then
        subnet_addr = cell_id..'1'
        ue_ip_id = ue_index
        elseif (ue_index>=251 and ue_index<=500) then
        subnet_addr = cell_id..'2'
        ue_ip_id = ue_index - 250
        elseif (ue_index>=501 and ue_index<=750) then
        subnet_addr = cell_id..'3'
        ue_ip_id = ue_index - 500
        elseif (ue_index>=751 and ue_index<=1000) then
        subnet_addr = cell_id..'4'
        ue_ip_id = ue_index - 750
        end

        if (ue_ip_id>0 and ue_ip_id<10) then
        host_number = '00'..ue_ip_id
        elseif (ue_ip_id>=10 and ue_ip_id<100) then
        host_number = '0'..ue_ip_id
        elseif (ue_ip_id>=100 and ue_ip_id<=UE_COUNT) then
        host_number = ue_ip_id
        end
    
        if (ue_index>0 and ue_index<10) then
        ue_index_str = '00'..ue_index
        elseif (ue_index>=10 and ue_index<100) then
        ue_index_str = '0'..ue_index
        elseif (ue_index>=100 and ue_index<1000) then
        ue_index_str = ue_index
        end

        _sec_key_ = sec_key..cell_id..ue_index_str
        _imsi_ = '244:101:11111'..cell_id..ue_index_str
        _ip_ = get_ip(NETWORK_NUMBER..'.'..subnet_addr..'.'..host_number)
        _ip2_ = get_ip(NETWORK2_NUMBER..'.'..subnet_addr..'.'..host_number)
        _ip3_ = get_ip(NETWORK3_NUMBER..'.'..subnet_addr..'.'..host_number)
        _ip4_ = get_ip(NETWORK4_NUMBER..'.'..subnet_addr..'.'..host_number)
        _ip5_ = get_ip(NETWORK5_NUMBER..'.'..subnet_addr..'.'..host_number)
        _ip6_ = get_ip(NETWORK6_NUMBER..'.'..subnet_addr..'.'..host_number)
    
        _nat_ip_ = get_ip(NAT_NETWORK_NUMBER..'.'..subnet_addr..'.'..host_number)
        _nat_ip2_ = get_ip(NAT_NETWORK2_NUMBER..'.'..subnet_addr..'.'..host_number)
        _nat_ip3_ = get_ip(NAT_NETWORK3_NUMBER..'.'..subnet_addr..'.'..host_number)
        _nat_ip4_ = get_ip(NAT_NETWORK4_NUMBER..'.'..subnet_addr..'.'..host_number)
        _nat_ip5_ = get_ip(NAT_NETWORK5_NUMBER..'.'..subnet_addr..'.'..host_number)
        _nat_ip6_ = get_ip(NAT_NETWORK6_NUMBER..'.'..subnet_addr..'.'..host_number)

        exec('set_ue id='..ue_id..' sec_key='.._sec_key_..' imsi='.._imsi_..' cell='..cell_id + 10)
        
        exec('set_bearer id=1 ue='..ue_id..' trf_type=internal default=on qci=9 ip='.._ip_)
        exec('set_bearer id=2 ue='..ue_id..' qci=1 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100 ')
        exec('set_bearer id=3 ue='..ue_id..' qci=2 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100 ')
        exec('set_bearer id=9 ue='..ue_id..' qci=3 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100 ')
        exec('set_bearer id=8 ue='..ue_id..' qci=4 gbr_ul=100 gbr_dl=100 mbr_ul=250 mbr_dl=250 ')
        exec('set_bearer id=13 ue='..ue_id..' qci=191 gbr_ul=100 gbr_dl=100 mbr_ul=100 mbr_dl=100 preemption=on vulnerability=on')
        exec('set_bearer id=4 ue='..ue_id..' qci=5  ')


                        

    end -- for ue_id
end -- for cell

end -- if

exec('debug_log level=5')
exec('set_log log_to_file=on')
exec("debug_log level=0")
exec('cfg_end')

sleep (2)

print("INFO: activate RRC protocol traces for UEC1")
--exec('trace uec=1 protocol=rrc on')

--[[sim_:start()

local i=0

repeat
    sleep(1)
    i= i + 1 
    if(i == 90) then 
        sim_:stop()
        print("ERROR: SimMode can not became ACTIVE!")
        break
    end

until (sim.ACTIVE == sim_.state) or (sim.CONFIGURED == sim_.state)

sleep(5)

end]]--
