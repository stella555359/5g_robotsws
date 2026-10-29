import UExGate.Script
exec(
"ue_param id=1..6 ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0"
)

:timer.sleep(1000)

exec(
"ue_param id=1..6 ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010"
)

:timer.sleep(1000)

exec(
"ue_param id=1..6 ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096340211807135E0000018800000094408200002100"
)

:timer.sleep(2000)

exec("ue_attach id=1 enb=1 cell=11 selected_plmn=311:489 scg_ul_dist_percent=100")
:timer.sleep(1000)
exec("ue_measurement_send event=B1_NR id=1 phycell_id=50 srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
:timer.sleep(1000)
exec("trf_data_start ue=1 dir=dl_and_ul protocol=udp kbps_dl=200 kbps_ul=200 stats=true")

:timer.sleep(5000)
exec("trf_data_stop ue=1")
:timer.sleep(1000)
exec("ue_detach id=1")
:timer.sleep(3000)

exec("ue_attach id=2 enb=1 cell=11 selected_plmn=311:490 scg_ul_dist_percent=100")
:timer.sleep(1000)
exec("ue_measurement_send event=B1_NR id=2 phycell_id=50 srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
:timer.sleep(1000)
exec("trf_data_start ue=2 dir=dl_and_ul protocol=udp kbps_dl=200 kbps_ul=200 stats=true")

:timer.sleep(5000)

exec("trf_data_stop ue=2")
:timer.sleep(1000)
exec("ue_detach id=2")

:timer.sleep(3000)

exec("ue_attach id=3 enb=1 cell=11 selected_plmn=311:491 scg_ul_dist_percent=100")
:timer.sleep(1000)
exec("ue_measurement_send event=B1_NR id=3 phycell_id=50 srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
:timer.sleep(1000)
exec("trf_data_start ue=3 dir=dl_and_ul protocol=udp kbps_dl=200 kbps_ul=200 stats=true")

:timer.sleep(5000)
exec("trf_data_stop ue=3")
:timer.sleep(1000)
exec("ue_detach id=3")

:timer.sleep(3000)

exec("ue_attach id=4 cell=11 selected_plmn=311:492 scg_ul_dist_percent=100")
:timer.sleep(1000)
exec("ue_measurement_send event=B1_NR id=4 phycell_id=50 srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
:timer.sleep(1000)
exec("trf_data_start ue=4 dir=dl_and_ul protocol=udp kbps_dl=200 kbps_ul=200 stats=true")
:timer.sleep(5000)
exec("trf_data_stop ue=4")
:timer.sleep(1000)
exec("ue_detach id=4")

:timer.sleep(3000)


:timer.sleep(1000)
exec("ue_attach id=5 cell=11 selected_plmn=311:493 scg_ul_dist_percent=100")
:timer.sleep(1000)
exec("ue_measurement_send event=B1_NR id=5 phycell_id=50 srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
:timer.sleep(1000)
exec("trf_data_start ue=5 dir=dl_and_ul protocol=udp kbps_dl=200 kbps_ul=200 stats=true")

:timer.sleep(5000)

exec("trf_data_stop ue=5")
:timer.sleep(1000)
exec("ue_detach id=5")

:timer.sleep(3000)

exec("ue_attach id=6 cell=11 selected_plmn=311:494 scg_ul_dist_percent=100")
:timer.sleep(1000)
exec("ue_measurement_send event=B1_NR id=6 phycell_id=50 srsrp=97  srsrq=34  nrsrp=97  nrsrq=30  nsinr=0")
:timer.sleep(1000)
exec("trf_data_start ue=6 dir=dl_and_ul protocol=udp kbps_dl=200 kbps_ul=200 stats=true")

:timer.sleep(5000)
exec("trf_data_stop ue=6")
:timer.sleep(1000)
exec("ue_detach id=6")
:timer.sleep(1000)
exec("exit")