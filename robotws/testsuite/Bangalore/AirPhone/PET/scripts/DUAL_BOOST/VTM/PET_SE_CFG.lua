require("hw_var")
print('The range for the INTRA_gNB_INTRA_FREQ_HO_UE_SA:'..FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA..'-'..LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA)
print('The range for the INTRA_gNB_INTER_FREQ_HO_UE_SA:'..FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA..'-'..LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA)
print('The range for the INTER_gNB_INTRA_FREQ_HO_UE_SA:'..FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA..'-'..LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA)
print('The range for the INTER_gNB_INTER_FREQ_HO_UE_SA:'..FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA..'-'..LAST_INTER_gNB_INTER_FREQ_HO_UE_SA)
print('The range for the CA_SCELL_ADD_UE_SA==========>:'..FIRST_CA_SCELL_ADD_UE_SA..'-'..LAST_CA_SCELL_ADD_UE_SA)
print('The range for the CA_SCELL_ADD_DEL_UE_SA======>:'..FIRST_CA_SCELL_ADD_DEL_UE_SA..'-'..LAST_CA_SCELL_ADD_DEL_UE_SA)
print('The range for the ADD_DRB_ADD_UE_SA===========>:'..FIRST_ADITIONAL_DRB_ADD_UE_SA..'-'..LAST_ADITIONAL_DRB_ADD_UE_SA)
print('The range for the VoNR_DRB_ADD_UE_SA===========>:'..FIRST_VONR_DRB_ADD_UE_SA..'-'..LAST_VONR_DRB_ADD_UE_SA)
print('The range for the ATTACH_DETACH_UE_SA=========>:'..FIRST_ATTACH_DETACH_UE_SA..'-'..LAST_ATTACH_DETACH_UE_SA)
print('The range for the TAU_UPDATE_UE_SA============>:'..FIRST_TAU_UPDATE_UE_SA..'-'..LAST_TAU_UPDATE_UE_SA)
print('The range for the NGPAGING_UE_SA==============>:'..FIRST_NGPAGING_UE_SA..'-'..LAST_NGPAGING_UE_SA)
print('The range for the STATE_TRASITION_UE_SA=======>:'..FIRST_STATE_TRASITION_UE_SA..'-'..LAST_STATE_TRASITION_UE_SA)
print('The range for the RNA_UPDATE_UE_SA============>:'..FIRST_RNA_UPDATE_UE_SA..'-'..LAST_RNA_UPDATE_UE_SA)
print('The range for the FAKE_PAGING_UE_SA============>:'..FAKE_PAGING_UE_SA)

function pet_se_group()
exec('set_ue_group simulated id=1 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=2 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=3 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=4 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=5 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=6 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=7 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=8 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=9 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=10 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=11 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=12 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=13 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=14 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=15 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=16 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=17 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=18 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=19 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=20 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=21 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=22 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=23 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=24 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=25 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=26 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=27 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=28 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=29 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=30 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=31 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=32 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=33 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=34 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=35 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=36 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=37 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=38 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=39 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=40 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=41 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=42 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=43 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=44 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=45 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=46 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=47 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=48 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=49 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=50 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=51 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=52 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=53 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=54 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=55 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=56 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=57 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=58 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=59 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=60 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=61 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=62 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=63 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=64 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=65 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=66 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=67 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=68 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=69 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=70 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=71 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=72 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=73 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=74 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=75 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=76 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=77 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=78 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=79 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=80 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=81 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=82 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=83 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=84 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=85 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=86 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=87 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=88 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=89 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=90 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=91 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=92 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=93 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=94 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=95 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=96 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=97 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=98 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=99 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=100 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=101 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=102 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=103 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=104 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=105 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=106 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=107 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=108 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=109 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=110 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=111 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=112 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=113 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=114 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=115 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=116 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=117 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=118 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=119 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=120 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=121 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=122 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=123 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=124 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=125 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=126 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=127 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=128 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=129 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=130 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=131 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=132 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=133 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=134 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=135 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=136 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=137 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=138 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=139 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=140 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=141 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=142 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=143 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=144 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=145 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=146 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=147 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=148 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=149 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=150 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=151 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=152 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=153 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=154 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=155 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=156 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=157 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=158 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=159 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=160 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=161 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=162 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=163 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=164 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

exec('set_ue_group simulated id=165 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=166 uec=2 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=167 uec=3 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=168 uec=4 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=169 uec=5 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=170 uec=6 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=171 uec=7 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')
exec('set_ue_group simulated id=172 uec=8 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

--fake paging UEs
exec('set_ue_group simulated id=173 uec=1 ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g')

end

function pet_se_ue_per_group()
----INTRA gNB Inter Freq HO STARTs--------------------------------------------------
UE_GROUP = 1
SA_UECGROUPID = 1
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_INTRA_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTRA_FREQ_HO_UE_SA do
    if UE_GROUP == 7 then
        UE_GROUP = 1
        SA_UECGROUPID = 1
        SA_CELLID = START_SA_CELLID 
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 2
    SA_CELLID = SA_CELLID + 2
end

-------------INTRA gNB HO ENDs--------------------------------------------
----------- INTRA gNB INTER FREQ HO STARTs--------------------------------------------
UE_GROUP = 1
SA_UECGROUPID = 2
SA_CELLID = START_SA_CELLID + 1

for SA_UEID = FIRST_INTRA_gNB_INTER_FREQ_HO_UE_SA,LAST_INTRA_gNB_INTER_FREQ_HO_UE_SA do
    if UE_GROUP == 7 then
        UE_GROUP = 1
        SA_UECGROUPID = 2
        SA_CELLID = START_SA_CELLID + 1
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 2
    SA_CELLID = SA_CELLID + 2
end

----------INTRA gNB INTER FREQ HO ENDS------------------------------------------------

------------INTER gNB INTRA FREQ HO STARTs ------------------------------
UE_GROUP = 1
SA_UECGROUPID = 13
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_INTER_gNB_INTRA_FREQ_HO_UE_SA,LAST_INTER_gNB_INTRA_FREQ_HO_UE_SA do
    if UE_GROUP == 13 then
        UE_GROUP = 1
        SA_UECGROUPID = 13
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
--------INTER gNB  INTRA FREQ HO ENDs----------------------------------------------------

-------INTER gNB INTER FREQ HO STARTs---------------------------------------------------
UE_GROUP = 1
SA_UECGROUPID = 25
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_INTER_gNB_INTER_FREQ_HO_UE_SA,LAST_INTER_gNB_INTER_FREQ_HO_UE_SA do
    if UE_GROUP == 13 then
        UE_GROUP = 1
        SA_UECGROUPID = 25
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
------INTER gNB INTER FREQ HO ENDs-------------------------------------------------------
--------------CA SCELL ADD_DEL STARTS----------------------------------------------------
UE_GROUP = 1
SA_UECGROUPID = 37
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_CA_SCELL_ADD_DEL_UE_SA,LAST_CA_SCELL_ADD_DEL_UE_SA do
    if UE_GROUP == 13 then
        UE_GROUP = 1
        SA_UECGROUPID = 37
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
  end
----------CA SCELL ADD_DEL ENDs-------------------------------------------------------------------

------------CA SCELL ADD ALONE---------------------------------------------------------
UE_GROUP = 1
SA_UECGROUPID = 49
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_CA_SCELL_ADD_UE_SA,LAST_CA_SCELL_ADD_UE_SA do
    if UE_GROUP == 13 then
        UE_GROUP = 1
        SA_UECGROUPID = 49
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
--------------CA SCELL ADD ALONE ENDS------------------------------------------------
-------------ADD_DRB_SETUP_UE STARTS--------------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 61
SA_CELLID = START_SA_CELLID
for SA_UEID = FIRST_ADITIONAL_DRB_ADD_UE_SA,LAST_ADITIONAL_DRB_ADD_UE_SA do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 61
	end
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
exec("set_pdu_param ue="..SA_UEID.." pdu=2 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
	end
-------------ADD_DRB_SETUP_UE ENDS-----------------------------------------------------
-------------VONR UE START
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 77
SA_CELLID = START_SA_CELLID
for SA_UEID = FIRST_VONR_DRB_ADD_UE_SA,LAST_VONR_DRB_ADD_UE_SA  do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 77
    end
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1 qfi=3 trf_prof_dl=3  trf_prof_ul=3")
    
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
------------UE CONFIG ENDs ------------------------------------------------------------
-----ApD Group START----------------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 93
SA_CELLID = START_SA_CELLID
for SA_UEID = FIRST_ATTACH_DETACH_UE_SA,LAST_ATTACH_DETACH_UE_SA  do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 93
	end
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
end
----ApD Group ENDs-------------------------------------------------------

---------TAU UPDATE  STARSs----------------------------------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 109
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_TAU_UPDATE_UE_SA,LAST_TAU_UPDATE_UE_SA do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 109
	end
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end	
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
--------------TAU UPDATE ENDs-------------------------------------------------
-----NG PGAING STARTs--------------------------------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 125
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_NGPAGING_UE_SA,LAST_NGPAGING_UE_SA do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 125
	end
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end	
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2 trf_prof_ul=1  qfi=2 trf_prof_dl=2 trf_prof_ul=2 ")
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
--------NG Paging ENDS --------------------------------------------------------------------

-------UE STATE TRASITION STARTs----------------------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 141
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_STATE_TRASITION_UE_SA,LAST_STATE_TRASITION_UE_SA do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 141
	end	
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1  trf_prof_dl=2 trf_prof_ul=1 qfi=2  trf_prof_ul=1 trf_prof_dl=2 ")
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
---------------UE STATE TRASITION ENDs-----------------------------------------------------

--------------RNA UPDATE STARts----------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 157
SA_CELLID = START_SA_CELLID

for SA_UEID = FIRST_RNA_UPDATE_UE_SA,LAST_RNA_UPDATE_UE_SA do
    if UE_GROUP == 17 then
        UE_GROUP = 1
        SA_UECGROUPID = 157
	end
    if CELL_GROUP == 12 then
        CELL_GROUP = 1
        SA_CELLID = START_SA_CELLID
    end
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")
    UE_GROUP = UE_GROUP + 1
	CELL_GROUP = CELL_GROUP + 1
    SA_UECGROUPID = SA_UECGROUPID + 1
    SA_CELLID = SA_CELLID + 1
   end
------------RNA UPDATE ENDs------------------------------------------------------------
-----------FAKE PAGING UE GROUP-------------------------------------------------------
UE_GROUP = 1
CELL_GROUP = 1
SA_UECGROUPID = 173
SA_CELLID = START_SA_CELLID
SA_UEID = FAKE_PAGING_UE_SA
    exec('set_ue  id='..SA_UEID..' group='..SA_UECGROUPID..'  opc_key=0ED47545168EAFE2C39C075829A7B61F  sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..SA_CELLID..' suci=0:'..PLMN..':0000:0:0:0'.. IMSI_1 + SA_UEID - 1)
exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal qfi=1 trf_prof_dl=2   trf_prof_ul=1 qfi=2 trf_prof_dl=2  trf_prof_ul=1")

end
----------------------------------------------------------------------------------------------------------
function pet_se_seq_vtm(paging_loop,paging_sleep,ue_st_loop,ue_st_sleep,TAU_loop,TAU_sleep,maxUeRrcInactTime,rna_loop,rna_sleep,page_per_amf_per_burst,page_period)
-----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--Intra-gNB Intra-Freq HO
---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell1 to cell2 & viceversa(Intra-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=1 name=Intra-gNB-Intra-Freq-HO-1<->2 ue_group=1')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_2..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')		
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell3 to cell4 & viceversa (Intra-freq)
---------------------------------------------------------------------------------------------------
        exec('seq_set id=2 name=Intra-gNB-Intra-Freq-HO-3<->4  ue_group=3')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_3..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_2..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell5 to cell6 & viceversa(Intra-freq)
---------------------------------------------------------------------------------------------------
        exec('seq_set id=3 name=Intra-gNB-Intra-Freq-HO-5<->6  ue_group=5')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_4..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_3..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell1 to cell2 & viceversa(Intra-freq) x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=4 name=Intra-gNB-Intra-Freq-HO-1<->2 ue_group=7')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')		
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell3 to cell4 & viceversa (Intra-freq) x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=5 name=Intra-gNB-Intra-Freq-HO-3<->4  ue_group=9')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=57 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell5 to cell6 & viceversa(Intra-freq) x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=6 name=Intra-gNB-Intra-Freq-HO-5<->6  ue_group=11')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=58 tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
----------------------------------------------------------------------------------------------------
--Intra-gNB Inter-Freq HO
---------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell2 to cell3 & viceversa(Inter-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=7 name=Intra-gNB-Inter-Freq-HO-2<->3 ue_group=2')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_5..' tgt_cell_ssb_frequency=649920')
	    exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_4..' tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
         exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell4 to cell5 & viceversa (Inter-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=8 name=Intra-gNB-Inter-Freq-HO-4<->5  ue_group=4')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_6..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_5..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell6 to cell1 & viceversa(Inter-freq)
---------------------------------------------------------------------------------------------------
		exec('seq_set id=9 name=Intra-gNB-Inter-Freq-HO-6<->1  ue_group=6')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_6..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell2 to cell3 & viceversa(Inter-freq) x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=10 name=Intra-gNB-Inter-Freq-HO-2<->3 ue_group=8')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=649920')
	    exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=59 tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3')
         exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell4 to cell5 & viceversa (Inter-freq) x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=11 name=Intra-gNB-Inter-Freq-HO-4<->5  ue_group=10')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=60 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Intra-GNB cell6 to cell1 & viceversa(Inter-freq) x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=12 name=Intra-gNB-Inter-Freq-HO-6<->1  ue_group=12')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id=56 tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
		exec('ue_ho_nr meas_type=A3 tgt_phycell_id=61 tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell 1-6 to simGNB 1-3
------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell1---->gNBSim1---->cell1
---------------------------------------------------------------------------------------------------
      	exec('seq_set id=13 name=Inter-gNB-1->gNB1->1 ue_group=13')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_1..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
------------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell2---->gNBSim1----->cell2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=14 name=Inter-gNB-2->gNB1->2 ue_group=14')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_2..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell3---->gNBSim3---->cell3
---------------------------------------------------------------------------------------------------
     	exec('seq_set id=15 name=Inter-gNB-3->gNB2->3   ue_group=15')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_3..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intar-Freq cell4--->gNBSim2---->cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=16 name=Inter-gNB-4->gNB3->4  ue_group=16')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_4..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell5-->simgNB3---->cell5
---------------------------------------------------------------------------------------------------
        exec('seq_set id=17 name=Inter-gNB-5->gNB3->5  ue_group=17')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_5..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell6 --->simgNB3---->cell6
---------------------------------------------------------------------------------------------------
		exec('seq_set id=18 name=Inter-gNB-6->gNB3->5->6   ue_group=18')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_6..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell7---->gNBSim1---->cell7 x 2
---------------------------------------------------------------------------------------------------
      	exec('seq_set id=19 name=Inter-gNB-1->gNB1->1 ue_group=19')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_1..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
------------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell8---->gNBSim1----->cell8 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=20 name=Inter-gNB-2->gNB1->2 ue_group=20')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_2..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell9---->gNBSim3---->cell9 x 2
---------------------------------------------------------------------------------------------------
     	exec('seq_set id=21 name=Inter-gNB-3->gNB2->3   ue_group=21')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_3..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intar-Freq cell10--->gNBSim2---->cell10 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=22 name=Inter-gNB-4->gNB3->4  ue_group=22')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_4..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell11-->simgNB3---->cell11 x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=23 name=Inter-gNB-5->gNB3->5  ue_group=23')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_5..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB-Intra-Freq cell12 --->simgNB3---->cell12 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=24 name=Inter-gNB-6->gNB3->5->6   ue_group=24')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_6..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')


-----Inter-GNB Inter freq-------------------
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell1---->gNBSim3-->-Cell1
---------------------------------------------------------------------------------------------------
        exec('seq_set id=25 name=Inter-gNB-HO-1->gNB3->1 ue_group=25')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_1..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell2 ---->simgnb3---->cell2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=26 name=Inter-gNB-HO-2->gNB3->2  ue_group=26')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_2..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell3----->simgnb1----->cell3
---------------------------------------------------------------------------------------------------
    	exec('seq_set id=27 name=Inter-gNB-HO-3->gNB1->3  ue_group=27')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_3..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell4--->simggnb1----->cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=28 name=Inter-gNB-HO-4->gNB1->4  ue_group=28')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_4..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell5--->simgnb2----->cell5
---------------------------------------------------------------------------------------------------
        exec('seq_set id=29 name=Inter-gNB-HO-5->gNB2->6->5  ue_group=29')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_5..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell6 ----> simgnb2----->cell5------->cell6
---------------------------------------------------------------------------------------------------
		exec('seq_set id=30 name=Inter-gNB-HO-6->gNB2->5->6  ue_group=30')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_6..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')


-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell7---->gNBSim3-->-Cell7 x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=31 name=Inter-gNB-HO-1->gNB3->1 ue_group=31')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_1..' tgt_cell_ssb_frequency=636576')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
-----------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell8 ---->simgnb3----->cell8 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=32 name=Inter-gNB-HO-2->gNB3->2  ue_group=32')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_2..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell9----->simgnb1----->cell9 x 2
---------------------------------------------------------------------------------------------------
    	exec('seq_set id=33 name=Inter-gNB-HO-3->gNB1->3  ue_group=33')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_3..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell10--->simggnb1----->cell10 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=34 name=Inter-gNB-HO-4->gNB1->4  ue_group=34')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_3..' tgt_cell_ssb_frequency=649920')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_4..' tgt_cell_ssb_frequency=643296')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell11--->simgnb2----->cell11 x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=35 name=Inter-gNB-HO-5->gNB2->6->5  ue_group=35')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_2..' tgt_cell_ssb_frequency=643296')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_5..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end') 
---------------------------------------------------------------------------------------------------
--PET_SE Inter-GNB cell12 ----> simgnb2----->cell5------->cell12 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=36 name=Inter-gNB-HO-6->gNB2->5->6  ue_group=36')
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 8')
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..NPCI_1..' tgt_cell_ssb_frequency=636576')
		exec('seq_delay 3') 
        exec('ue_ho_nr meas_type=A3 tgt_phycell_id='..SPCI_6..' tgt_cell_ssb_frequency=649920')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------CA function----------------
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to cell5 
---------------------------------------------------------------------------------------------------
		exec('seq_set id=37 name=scell-add-del-1-5 ue_group=37')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
	    exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=649920 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell4
---------------------------------------------------------------------------------------------------
		exec('seq_set id=38 name=scell-add-del-2-4 ue_group=38')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
		exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=643296 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
			 
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell1 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=39 name=scell-add-del-3-1  ue_group=39')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636576 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                  	
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell6 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=40 name=scell-add-del-4-6  ue_group=40')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=649920 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
	    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	    exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell3 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=41 name=scell-add-del-5-3  ue_group=41')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=643296 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell2 & viceversa
---------------------------------------------------------------------------------------------------
		exec('seq_set id=42 name=scell-add-del-6-5  ue_group=42')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636576 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell1 to cell5 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=43 name=scell-add-del-1-5 ue_group=43')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2') 
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
	    exec('seq_delay 3')
		exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=649920 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell2 to cell4 x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=44 name=scell-add-del-2-4 ue_group=44')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
		exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=643296 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
			 
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell3 to cell1 & viceversa x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=45 name=scell-add-del-3-1  ue_group=45')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636576 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                  	
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell4 to cell6 & viceversa x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=46 name=scell-add-del-4-6  ue_group=46')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=649920 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
	    exec('ue_deregister by=ue ue_deregister_type=switch_off')
	    exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell5 to cell3 & viceversa x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=47 name=scell-add-del-5-3  ue_group=47')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=643296 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add-del cell6 to cell2 & viceversa x 2
---------------------------------------------------------------------------------------------------
		exec('seq_set id=48 name=scell-add-del-6-5  ue_group=48')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
		exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
		exec('seq_delay 3')
        exec('ue_scell_measurement_nr meas_type=A2 ssb_frequency=636576 src_rsrp_nr=10 src_rsrq_nr=10 scell=1')
        exec('seq_delay 3')                   	
		exec('ue_deregister by=ue ue_deregister_type=switch_off')
		exec('seq_end')

------------------------------------------------------------------------------------------------------
--PET_SE Add Only
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell1 to cell5
---------------------------------------------------------------------------------------------------
        exec('seq_set id=49 name=scell-add-1-5 ue_group=49')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell2 to cell4
---------------------------------------------------------------------------------------------------
        exec('seq_set id=50 name=scell-add-2-4 ue_group=50')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add  cell3 to cell1 & viceversa
---------------------------------------------------------------------------------------------------
        exec('seq_set id=51 name=scell-add-3-1  ue_group=51')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell4 to cell6 & viceversa
---------------------------------------------------------------------------------------------------
        exec('seq_set id=52 name=scell-add-4-6  ue_group=52')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell5 to cell3 & viceversa
---------------------------------------------------------------------------------------------------
       exec('seq_set id=53 name=scell-add-5-3  ue_group=53')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell6 to cell2 & viceversa
---------------------------------------------------------------------------------------------------
        exec('seq_set id=54 name=scell-add-6-2  ue_group=54')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')



-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell7 to cell11 x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=55 name=scell-add-1-5 ue_group=55')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------
--PET_SE Scell add cell8 to cell10 x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=56 name=scell-add-2-4 ue_group=56')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=636576')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

---------------------------------------------------------------------------------------------------
--PET_SE Scell add  cell9 to cell7 & viceversa x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=57 name=scell-add-3-1  ue_group=57')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell10 to cell12 & viceversa x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=58 name=scell-add-4-6  ue_group=58')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=643296')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell11 to cell9 & viceversa x 2
---------------------------------------------------------------------------------------------------
       exec('seq_set id=59 name=scell-add-5-3  ue_group=59')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
---------------------------------------------------------------------------------------------------
--PET_SE Scell add cell12 to cell8 & viceversa x 2
---------------------------------------------------------------------------------------------------
        exec('seq_set id=60 name=scell-add-6-2  ue_group=60')
        exec('ue_register ue_nr_capabilities=CA_2CC capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay 2')
        exec('ue_scell_measurement_nr meas_type=A1 ssb_frequency=649920')
        exec('seq_delay 8')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')

------------------------------------------------------------------------------------------------------------
-- PET SE ADD_DRB_ADD UE Group
------------------------------------------------------------------------------------------------------------
gr_id = 61
	for seq_gr_id =61,76 do
			
				exec('seq_set id='..seq_gr_id..' name=Pet_DRB-add-del'..seq_gr_id..' ue_group='..gr_id)
				exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
				exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
                exec('seq_delay 0.1')
                exec("ue_pdu_session_setup pdu=2 gw=1 nwslice=1")
                exec('seq_delay 8')
				exec('ue_deregister by=ue ue_deregister_type=switch_off')	
				exec('seq_end')
				gr_id = gr_id + 1				
	 end
----------------------------------------------------------------------------------------------------------------
---PET SE VONR STARTs--
----------------------------------------------------------------------------------------------------------------
gr_id1 = 77
 for seq_gr_id = 77,92 do
  
        exec('seq_set id='..seq_gr_id..' name=Pet_DRB-add-del'..seq_gr_id..' ue_group='..gr_id1)
        exec('ue_register ue_nr_capabilities=E1A01380174E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA8000028000000841C4D00000000202682807008089EC1601800140E0601C0C01601C001A0F8000000000000395340004000025965400D2AAA0207000B00000004008011AB130001020304050607080B101112131921252627284A32D registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
        exec('seq_delay 0.1')
        exec('ue_pdu_session_modify pdu=1 qosflows_to_add=3 by=ue')
        exec('seq_delay 120')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
            gr_id1 = gr_id1 + 1
     end
---------------------------------------------------------------------------------------------------------------------------------------------------------
--PET SE VONR ENDs-
---------------------------------------------------------------------------------------------------------------------------------------------------------
    gr_id = 93
	for seq_gr_id = 93,108 do		
	
		exec('seq_set id='..seq_gr_id..' name=PS_BHCA_2DRB'..seq_gr_id..' ue_group='..gr_id)
		exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
		exec("ue_pdu_session_setup pdu=1 gw=1  nwslice=1")
        exec('seq_delay 8')
	    exec('ue_deregister by=ue ue_deregister_type=switch_off')					
		exec('seq_end')	
		gr_id = gr_id + 1
	end
---------------------------------------------------------------------------------------------------------------------------------------------
--PET SE TAU UPDATE
--------------------------------------------------------------------------------------------------------------------------------------------
gr_id = 109
for seq_gr_id = 109, 124 do

        exec('seq_set id='..seq_gr_id..' name=TAU_UPDATE'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_loop_start loop='..TAU_loop)
        exec('seq_delay '..TAU_sleep)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg reactivate_pdu=off use_suci=off registration_type=MobilityRegistrationUpdting')
        exec('seq_loop_end')
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
--------------------------------------------------------------------------------------------------------------------------------------------
---PAGING SEQ-----
---------------------------------------------------------------------------------------------------------------------------------------------
    gr_id = 125
    for seq_gr_id = 125, 140 do

        exec('seq_set id=' .. seq_gr_id .. ' name=PagingStartStop-' .. seq_gr_id .. ' ue_group=' .. gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
      if NG_PAGING ~= 'FAKE' then
         exec('seq_loop_start loop=' .. paging_loop)
        exec('seq_delay ' .. paging_sleep)
         exec('amf_paging_start id=1-5')
          exec("seq_loop_end")
         exec('seq_delay 3')
       else 
         exec('seq_delay '..maxUeRrcInactTime)
       end
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
-----------------------------------------------------------------------------------------------------------------------------------------------
-----PAGING SEQ ENDs--
------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
-----UE INITIATED IDLE TO CONNECTED and VICEVERS--
--------------------------------------------------------------------------------------------------------------------------------------------------
if UE_STATE_TRANSITION == '8225' then
    gr_id = 141
    for seq_gr_id = 141, 156 do

        exec('seq_set id=' .. seq_gr_id .. ' name=ue_state_transition' .. seq_gr_id .. ' ue_group=' .. gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 nwslice=1")
        exec('seq_loop_start loop=' .. ue_st_loop)
        exec('seq_delay ' .. ue_st_sleep)
        exec("ue_nr_rrc_resume")
        exec('seq_delay 0.1')
        exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl size=1277 kbps=1055 seconds=8')
        exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl size=1277 kbps=1055 seconds=8')
        exec("seq_loop_end")
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
else
    gr_id = 141
    for seq_gr_id = 141, 156 do
   
        exec('seq_set id=' .. seq_gr_id .. ' name=ue_state_transition' .. seq_gr_id .. ' ue_group=' .. gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 nwslice=1")
        exec('seq_loop_start loop=' .. ue_st_loop)
        exec('seq_delay ' .. ue_st_sleep)
        exec("ue_im_exit by=ue")
        exec("seq_loop_end")
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------
--PET SE RNA UPDATE--
--------------------------------------------------------------------------------------------------------------------------------------------------------
if RNA_UPDATE == 'T380' then
gr_id = 157
UE_GROUP_COUNT = 172
for seq_gr_id = 157, 172 do

        exec('seq_set id='..seq_gr_id..' name=RNA_UPDATE'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_delay '..maxUeRrcInactTime)
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
else 
gr_id = 157
UE_GROUP_COUNT = 172
for seq_gr_id = 157, 172 do

        exec('seq_set id='..seq_gr_id..' name=RNA_UPDATE'..seq_gr_id..' ue_group='..gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec('ue_pdu_session_setup pdu=1 gw=1 nwslice=1')
        exec('seq_loop_start loop='..rna_loop)
        exec('seq_delay ' ..rna_sleep)
        exec("ue_nr_rrc_resume")
        exec("seq_loop_end")
        exec('seq_delay 3')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
        gr_id = gr_id + 1
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--PET SE RNA Update ends-
------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------
-----FAKE PAGING STARTs--
-------------------------------------------------------------------------------------------------------------------------------------------------------
    gr_id = 173
    seq_gr_id = 173

        exec('seq_set id=' .. seq_gr_id .. ' name=PagingStartStop-' .. seq_gr_id .. ' ue_group=' .. gr_id)
        exec('ue_register ue_nr_capabilities=FR1_TDD_VTM capability_file=./capability.cfg registration_type=InitialRegistration')
        exec("ue_pdu_session_setup pdu=1 gw=1 nwslice=1")
        exec('amf_fake_paging_start amf=1-5 gnbs=2 session_id=1 '
            .. 'burst_size=' .. page_per_amf_per_burst .. ' '
            .. 'burst_period=' .. page_period .. ' '
            .. 'tai=' .. PLMN .. '|' .. TAC .. ' '
            .. '5g_s_tmsi=1:1:2 5g_s_tmsi_num=5 drx_cycle_len=256')
        exec('seq_delay '..maxUeRrcInactTime)
        exec('amf_fake_paging_stop amf=1-5 gnbs=2 session_id=1')
        exec('ue_deregister by=ue ue_deregister_type=switch_off')
        exec('seq_end')
-----------------------------------------------------------------------------------------------------------------------------------------------------
----FAKE PAGING ENDs---
-------------------------------------------------------------------------------------------------------------------------------------------------------

end
