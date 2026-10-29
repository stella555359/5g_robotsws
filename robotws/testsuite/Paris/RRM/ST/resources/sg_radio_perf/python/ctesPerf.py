# -*- coding: utf-8 -*-
from robot.libraries.BuiltIn import BuiltIn
rf_built_in = BuiltIn()

tl_name = rf_built_in.get_variable_value('${tl_name}')

CV001 = 'IV_PS_001'
CV065 = 'IV_PS_065'
CV098 = 'IV_PS_098'

cLA_TESTNAME = 'T00'
cLA_PROFILE = 'AWGN'
cLA_TRAFICTYPE = 'DL'
cLA_CAPTUREDURATION = 10

cLA_TYPEATTEN = 'Pwr'
cLA_IATTENPWR = 30.0
cLA_IATTENCN = 30.0

cLA_IATTEN = 40.0
cLA_FATTEN = 42.0
cLA_STEP = 1
cLA_NBLOOP = 1
cLA_ALLERRETOUR = 'A'
cLA_TRACETYPE = 'TQ'
cLA_HDF2TXR = 'Y'
cLA_CTE_DL_PL = 13

cLA_ASIK_OAM_IP = '10.14.49.0'
cLA_ASIK_OAM_LOGIN = 'toor4nsn'
cLA_ASIK_OAM_PWD = 'oZPS0POrRieRtu'
# cLA_ABIL_IP_MASTER = '192.168.253.20'
# cLA_ABIL_IP_SLAVE = '192.168.253.21'

cLA_ABIL_IP_MASTER = 'fd5f:4268:2387:53c4:40:43ff:fe80:1101'
cLA_ABIL_IP_SLAVE = 'fd5f:4268:2387:53c4:40:43ff:fe80:121'
cLA_ABIL_IP_TTI = cLA_ABIL_IP_MASTER
cLA_PC_SPIRENT_IP = '10.0.100.113'
cLA_PC_SPIRENT_LOGIN = 'frpscs-spirent'
cLA_PC_SPIRENT_PWD = '$p1r3nT91'
cLA_SPIRENT_IP = '192.168.200.5'
cLA_SPIRENT_PORT = 3000
cLA_SPIRENT_PORT_SSH = 9000
cLA_SPIRENT_LOGIN = 'spirent_rpi'
cLA_SPIRENT_PWD = 'Sp!rent'
cLA_SSH_PORT = 22
cLA_SSH_TO = 20
cLA_SFTP_TO = 20
cLA_STABILISATIONTIME = 2
cLA_MIMOMODE = '4x4'
cLA_SPIRENT_OUTPUT_PORTS_DL = 'B(1-4)'
cLA_SPIRENT_OUTPUT_PORTS_UL = 'A(1-4)'
cLA_TTI = 'TTI'
cLA_getTTItraces = 'nohup /ffs/run/config/scripts/LA/getTTI.sh '
cLA_getTTItraces = '/ffs/run/config/scripts/LA/getTTI.sh '
cLA_ASIK_PATH = '/ffs/run/logs/LA/'
cLA_PC_UE_IP = '10.28.1.210'
cLA_PC_UE_LOGIN = 'cv5g1_5'
cLA_PC_UE_PWD = 'P@scal5G'
cLA_UE_IP = '172.10.1.195'
cLA_QCT = 'QCT'
cLA_getQCTtraces = 'nohup /cygdrive/c/Python310/python.exe C:/AUTOMATION/LA/TOOLS/QXDM5LogCatch.py '
# cLA_UE_5G_DMC_CONF = 'C:/AUTOMATION/LA/CONF_QXDM/Config5G_auto_SDX65_woDCI_0xB891_0xB992.dmc'
# cLA_UE_5G_DMC_CONF = 'C:/AUTOMATION/LA/CONF_QXDM/Config5G_auto_SDX65.dmc'
cLA_UE_5G_DMC_CONF = 'C:/AUTOMATION/LA/CONF_QXDM/Config5G_auto_SDX65_cv01.dmc'
# cLA_UE_5G_DMC_CONF = 'C:/AUTOMATION/LA/CONF_QXDM/Sa_NoDRX_VOLTE_VONR.dmc'
# cLA_UE_5G_DMC_CONF = 'C:/AUTOMATION/LA/CONF_QXDM/RRC.dmc'
cLA_UE_5G_TRACES = 'C:/AUTOMATION/LA/TESTS/'
cLA_UE_5G_EXEC_QCAT = 'QCAT.exe'


cLA_VM_PATH = '/home/localuser/AUTOMATION/LA/TESTS/'

cLA_QCT_LOG_CSV = False
cLA_h1DL = 'Atten;RNTI (list);RSRP  ;Path Loss;Expected PL;DL RSRQ;UE PUCCH TxPwr;CQI   ;DL SNR;DL MCS;\
Initial DL Bler (UE side);Avg DL Bler (UE side);Rank  ;Rank1%;Rank2%;Rank3%;Rank4%;App DL Tput (Mbps);\
L1 Phys DL Tput (Mbps);DL PRB;Initial DL Target Bler (gNB side);Initial DL Bler (gNB side);\
Avg DL Bler (gB side)      ;App DL Tput (Mbps) (gNB side);L1 Phys DL Tput (Mbps) (gNB side);DL PRB       ;\
rrmCorrAvgCQI;RNTI         ;filename'

cLA_h2DL = '     ;0xB887     ;0xB97F;0xB884   ;             ;0xB97F ;0xB884        ;0xB891;0xB97F;0xB887;\
0xB887                   ;0xB887               ;0xB887;0xB887;0xB887;0xB887;0xB887;0xB887            ;\
0xB887                ;0xB887;dlLaDeltaCqi                     ;dlFdSchedData             ;\
dlLaDeltaCqi               ;dlFdSchedData                ;dlFdSchedData                    ;dlFdSchedData;\
dlFdSchedData;dlFdSchedData;'

cLA_h1UL = 'Atten;RNTI (list);RSRP  ;Path Loss;Expected PL;DL RSRQ;CQI   ;UE PUCCH TxPwr;UE PUSCH TxPwr;\
L1 Phys UL Tput (Mbps);UL Instant SNR ;UL Corrected SNR;UL RSSI                 ;UL MCS       ;\
Initial UL Target Bler (gNB side);Initial UL Bler (gNB side);Avg UL Bler  ;Rank         ;Rank1%       ;\
Rank2%       ;Rank3%       ;Rank4%       ;App UL Tput (Mbps) (gNB side);L1 Phys UL Tput (Mbps) (gNB side);\
UL PRB       ;RNTI	      ;filename'

cLA_h2UL = '     ;0xB887     ;0xB97F;0xB884   ;             ;0xB97F ;0xB891;0xB884        ;0xB884         ;\
0xB884               ;ulLaAverageSinr;ulLaAverageSinr ;ulPuschReceiveRespPsData;ulFdSchedData;\
ulLaDeltaSinr                    ;ulFdSchedData             ;ulLaDeltaSinr;ulFdSchedData;ulFdSchedData;\
ulFdSchedData;ulFdSchedData;ulFdSchedData;ulFdSchedData                ;ulFdSchedData                    ;\
ulFdSchedData;ulFdSchedData;'

cLA_DLemptyQCT = ';;;;;;;;;;;;;;;;;;'
cLA_DLemptyTTI = ';;;;;;;;'
cLA_ULemptyQCT = ';;;;;;;;'
cLA_ULemptyTTI = ';;;;;;;;;;;;;;;;;'

if tl_name == CV065:
    cLA_ASIK_OAM_IP = '10.14.48.65'
    cLA_ABIL_IP_MASTER = 'fd5f:4268:2387:53c4:40:43ff:fe80:101'
    cLA_ABIL_IP_SLAVE = 'fd5f:4268:2387:53c4:40:43ff:fe80:1121'
    cLA_ABIL_IP_TTI = cLA_ABIL_IP_SLAVE
    cLA_PC_SPIRENT_IP = '10.0.100.117'
    cLA_SPIRENT_IP = '192.168.200.17'
    cLA_SPIRENT_PORT_SSH = None
    cLA_SPIRENT_LOGIN = None
    cLA_SPIRENT_PWD = None
    cLA_PC_UE_IP = '10.28.1.174'
    cLA_PC_UE_LOGIN = 'cv5g2_5'
    cLA_PC_UE_PWD = 'M!k@el5G'
    cLA_UE_IP = '172.10.1.195'
    cLA_UE_5G_DMC_CONF = 'C:/AUTOMATION/LA/CONF_QXDM/Config5G_auto_SDX65_woDCI_0xB891_0xB992.dmc'
