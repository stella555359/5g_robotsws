# scheduled just on Pcell
# 0x580591:  rdULCaEnablerPhase. 0: Means UL CA both on pcell and scell;
#                                1: Means UL CA only on pcell;
#                                2: Means UL CA only on scell
# 0x58056B: rdUseOptimizedDpaAlgo. 0: Old DPA Algo
#                                  1: New DPA algo from CB007737
SWCONFIG_6137_A = [
    '0x580591=0',
    '0x58056B=1'
]

# syslog print info about power split, RLQ status
SWCONFIG_6137_SYSLOG_INFO = [
    '0x58057F=16',
    '0x58057a=3'
]
