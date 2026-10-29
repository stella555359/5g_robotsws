# -*- coding: utf-8 -*
#        R&D parameters setting:
#        0x580017=1   set DL rank=2   rdDlRank = 1
#        0x580011=0   rdActIllaDl = 0    ( set to 0 deactivates the ILLA in DL): l2ps_defs+0x11
#        0x580013=0   rdActOllaDl = 0    ( set to 0 deactivates the OLLA in DL): l2ps_defs+0x13
SWCONFIG_MODIFY_CASE141 = [
    '0x580017=4',
    '0x580011=0',
    '0x580013=0',
]
