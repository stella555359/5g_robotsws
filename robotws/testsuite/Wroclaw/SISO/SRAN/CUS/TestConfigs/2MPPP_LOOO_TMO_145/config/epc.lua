require('common_params')

current_imsi = 1001201001
ue_type = 'external'
trf_type = 'external'

ue_count_per_cell = 1
ue_iot_count_per_cell = 1
ue_catm_count_per_cell = 1

exec('set_pgw'..
         ' id=1'..
         ' type=simulated'..
         ' ip='..edaemon_ip..':'..edaemon_port..
         ' devtype=tun '..
         ' devname=tunPGW'..
         ' addr='..pgw_ip)

exec('set_sgw'..
         ' id=1'..
         ' type=simulated'..
         ' ip='..edaemon_ip..':'..edaemon_port..
         ' s1u='..s1_ip..':'..s1u_port..
         ' s11='..s1_ip..':'..s11_port)

exec('set_mme'..
         ' id=1'..
         ' type=simulated'..
         ' ip='..edaemon_ip..':'..edaemon_port..
         ' s1='..s1_ip..':'..mme_port..
         ' mmegi='..mmegi..
         ' mmec='..mmec..
         ' supported_plmn='..plmn..
         ' supported_rat=lte,nblte')

exec('set_enb'..
         ' type=external'..
         ' id=1'..
         ' plmn='..plmn..
         ' enb_id_macro='..enb_macro_id..
         ' s1='..enb_s1_ip..
         ' daemon='..edaemon_ip..':'..edaemon_port)

exec('set_param SEC_OP_KEY='..sec_op_key)

for ue_index=1,ue_count_per_cell do

            local ue_id = ue_index
            local bearer_id = 1

            local ue_id_aligned
            if (ue_id>0 and ue_id<10) then
                ue_id_aligned = '00'..ue_id
            elseif (ue_id>=10 and ue_id<100) then
                ue_id_aligned = '0'..ue_id
            elseif (ue_id>=100 and ue_id<1000) then
                ue_id_aligned = ue_id
            end

            local ue_imsi = imsi_prefix..ue_id_aligned

            exec('set_ue '..ue_type..
                ' id='..ue_id..
                ' sec_key='..sec_key..
                ' imsi='..ue_imsi)

            exec('set_bearer'..
                ' id='..bearer_id..
                ' ue='..ue_id..
                ' trf_type='..trf_type..
                ' default=on'..
                ' qci=8')
end

for ue_index=1,ue_iot_count_per_cell do

        local ue_id = ue_index + ue_count_per_cell
        local bearer_id = 2

        local ue_id_aligned
        if (ue_id>0 and ue_id<10) then
            ue_id_aligned = '00'..ue_id
        elseif (ue_id>=10 and ue_id<100) then
            ue_id_aligned = '0'..ue_id
        elseif (ue_id>=100 and ue_id<1000) then
            ue_id_aligned = ue_id
        end

        local ue_imsi = imsi_prefix..ue_id_aligned

        exec('set_ue '..ue_type..
             ' id='..ue_id..
             ' sec_key='..sec_key..
             ' imsi='..ue_imsi)

        exec('ue_mme_param'..
            ' id='..ue_id..
            ' inject_conn_establish_ind=ue_capa_from_ue'..
            ' identity_type=imsi'..
            ' supported_ciot=cplane')

        exec('set_bearer'..
            ' id='..bearer_id..
            ' ue='..ue_id..
            ' trf_type='..trf_type..
            ' default=on'..
            ' qci=8')
end

for ue_index=1,ue_catm_count_per_cell do

        local ue_id = ue_index + ue_count_per_cell + ue_iot_count_per_cell
        local bearer_id = 3

        local ue_id_aligned
        if (ue_id>0 and ue_id<10) then
            ue_id_aligned = '00'..ue_id
        elseif (ue_id>=10 and ue_id<100) then
            ue_id_aligned = '0'..ue_id
        elseif (ue_id>=100 and ue_id<1000) then
            ue_id_aligned = ue_id
        end

        local ue_imsi = imsi_prefix..ue_id_aligned

        exec('set_ue '..ue_type..
             ' id='..ue_id..
             ' sec_key='..sec_key..
             ' imsi='..ue_imsi)

        exec('set_bearer'..
            ' id='..bearer_id..
            ' ue='..ue_id..
            ' trf_type='..trf_type..
            ' default=on'..
            ' qci=8')
end

exec('set EDAEMON_PORT="10000"')

exec('set_amf_region id=1 tac_list=11075328 plmn=244:09')
exec('set_amf id=1 daemon=:$EDAEMON_PORT ng=10.0.1.1:38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon=:$EDAEMON_PORT type=simulated addr=1.2.4.1/24 ngu=192.168.1.123')

exec('set_gnb id=2 type=external plmn=244:09 ng=10.0.1.2 gnb_id=0x2 daemon=:$EDAEMON_PORT x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=280:0 tac=11075328 nrci=0x0 tdd_cell=on nr_arfcn=636666:636666')

exec('set_ue lmts id=9000 nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1')
exec('ue_param id=9000 ue_nr_capabilities=01000000010800000004D780000000000001150000000000000150')
 
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=9000 amf=1')


exec('set_log log_to_file=on')
exec('debug_log level=5')
exec("set_cnode")

exec('link_ctrl_param hb_period=180 hb_retries=10 app_type=mme')

exec('cfg_end')
sleep(1)
