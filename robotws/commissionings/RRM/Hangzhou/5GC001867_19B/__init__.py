__maintainer__ = 'Li Ying'
__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = 'ying.15.li@nokia-sbell.com'

PATH_TO_SCF = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19B/SBTS5G19B_5g_1596_A_AEUD.xml'

PARAMS_TO_MODIFY = [
    dict(
        value='Nokia_HZSG3_mmW_TL239',
        dist_name='MRBTS-1900',
        p_name='btsName'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab6Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab5Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab69Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab70Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab79Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab7Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab8Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='qciTab9Nsa3x',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab5',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab6',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab7',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab8',
         p_name='dlFlowControlAlgo'),
    dict(value='3gppFlowControl', dist_name='MRBTS-1900/NRBTS-1', list_name='fiveQiTab9',
         p_name='dlFlowControlAlgo'),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab5Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab6Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab7Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab8Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab9Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab69Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab70Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='dlOverF1U',
        dist_name='MRBTS-1900/NRBTS-1',
        list_name='qciTab79Nsa3x',
        p_name="dlDataSplitMode"),
    dict(
        value='2071675',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='nrarfcn'),
    dict(
        value='2071675',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='nrarfcn'),
    dict(
        value='2071675',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='nrarfcn'),
    dict(
        value='2071675',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='nrarfcn'),
    dict(value='262', dist_name='MRBTS-1900/NRBTS-1', p_name='mcc'),
    dict(value='3', dist_name='MRBTS-1900/NRBTS-1', p_name='mnc'),
    dict(value='2', dist_name='MRBTS-1900/NRBTS-1', p_name='mncLength'),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='pMax'),
    dict(value='22446', dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='gscn'),
    dict(
        value='28',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name="dllaIniMcs"),
    dict(
        value='semiStatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name="frameStructureType"),
    dict(
        value='2Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name="guardPeriodLength"),
    dict(
        value='1/4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name="ulDlDataSlotRatio"),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='pMax'),
    dict(value='22446', dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='gscn'),
    dict(
        value='28',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name="dllaIniMcs"),
    dict(
        value='semiStatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name="frameStructureType"),
    dict(
        value='2Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name="guardPeriodLength"),
    dict(
        value='1/4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name="ulDlDataSlotRatio"),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='pMax'),
    dict(value='22446', dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='gscn'),
    dict(
        value='28',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name="dllaIniMcs"),
    dict(
        value='semiStatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name="frameStructureType"),
    dict(
        value='2Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name="guardPeriodLength"),
    dict(
        value='1/4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name="ulDlDataSlotRatio"),
    dict(value='190', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='pMax'),
    dict(value='22446', dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='gscn'),
    dict(
        value='28',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name="dllaIniMcs"),
    dict(
        value='semiStatic',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name="frameStructureType"),
    dict(
        value='2Symbols',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name="guardPeriodLength"),
    dict(
        value='1/4',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name="ulDlDataSlotRatio"),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', dist_name='MRBTS-1900/NRBTS-1/NRDU-1',
         list_name='f1Mplane',
         p_name='ipV4AddressDN1'),
    dict(value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1', dist_name='MRBTS-1900/NRBTS-1/NRDU-1',
         list_name='f1Uplane',
         p_name='ipV4AddressDN1'),
    dict(
        value='8103',
        dist_name='MRBTS-1900/NRBTS-1/TRACKINGAREA-1',
        p_name='fiveGsTac'),
    dict(
        value='Nokia HZDX',
        dist_name='MRBTS-1900/EQM-1/APEQM-1',
        p_name='location'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1',
        p_name='actPdlRuleValidation'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1',
        p_name='actServiceAccountSsh'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SECADM-1',
        p_name='ethernetPortSecurityEnabled'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/FEATCADM-1',
        p_name='systemAcctPermEnable'),
    dict(
        value='15min',
        dist_name='MRBTS-1900/MNL-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(value='DISCOVERED', dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
         p_name='ipAddressAllocationMethod'),
    dict(
        value='(GMT+8) Asia/Shanghai',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/TIME-1',
        p_name="timeZone"),
    dict(value='TOPP',
         dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1', list_name='syncInputList', p_name='syncInputType')
]

PARAMS_TO_DELETE = [
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4', p_name='trackingAreaDN'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-1/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-2/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-3/NRCELL_FDD-1'),
    dict(dist_name='MRBTS-1900/NRBTS-1/NRCELL-4/NRCELL_FDD-1'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpAddr'),
    dict(
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='localIpPrefixLength'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-2'),
    dict(dist_name='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-3'),
    dict(dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1')
]

OBJECTS_TO_CREATE = [
    dict(
        dist_name='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-3',
        class_name="com.nokia.srbts.eqm:SFP",
        version="EQM5G19B_1911_200"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        class_name="com.nokia.srbts.mnl:SYNC",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1',
        class_name="com.nokia.srbts.mnl:CLOCK",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1',
        class_name="com.nokia.srbts.mnl:TOPPSTATUS",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCKSTATUS-1',
        class_name="com.nokia.srbts.mnl:CLOCKSTATUS",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/TIME-1',
        class_name="com.nokia.srbts.mnl:TIME",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2',
        class_name="com.nokia.srbts.mnl:MNLENT",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SECADM-1',
        class_name="com.nokia.srbts.mnl:SECADM",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/FEATCADM-1',
        class_name="com.nokia.srbts.mnl:FEATCADM",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/FMCADM-1',
        class_name="com.nokia.srbts.mnl:FMCADM",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1',
        class_name="com.nokia.srbts.mnl:CERTHENT",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CRLHS-1',
        class_name="com.nokia.srbts.mnl:CRLHS",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CMPS-1',
        class_name="com.nokia.srbts.mnl:CMPS",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/CERTHENT-1/CRLINFO-1',
        class_name="com.nokia.srbts.mnl:CRLINFO",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1',
        class_name="com.nokia.srbts.mnl:SYNC",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/TIME-1',
        class_name="com.nokia.srbts.mnl:TIME",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1',
        class_name="com.nokia.srbts.mnl:CLOCK",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        class_name="com.nokia.srbts.mnl:NTP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/ECPRIMASTER-1',
        class_name="com.nokia.srbts.mnl:ECPRIMASTER",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1',
        class_name="com.nokia.srbts.mnl:CMD",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-1',
        class_name="com.nokia.srbts.mnl:HWRESETREQ",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1',
        class_name="com.nokia.srbts.mnl:HWRESETRES",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-2',
        class_name="com.nokia.srbts.mnl:HWRESETREQ",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-2/HWRESETRES-1',
        class_name="com.nokia.srbts.mnl:HWRESETRES",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-3',
        class_name="com.nokia.srbts.mnl:HWRESETREQ",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-3/HWRESETRES-1',
        class_name="com.nokia.srbts.mnl:HWRESETRES",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        class_name="com.nokia.srbts.mnl:TOP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        class_name="com.nokia.srbts.mnl:TOPP",
        version="MNL5G19B_1910_100"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1',
        class_name="com.nokia.srbts.mnl:TOPPSTATUS",
        version="MNL5G19B_1910_100")
]

PARAMS_TO_ADD = [
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        p_name='configuredEpsTac'),
    dict(
        value='0',
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        p_name='configuredEpsTac'),
    dict(
        value='S-RF1',
        dist_name='MRBTS-1900/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-3',
        p_name='physicalPort'),
    dict(
        value='MASTER_CLOCK_OK',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterClockState'),
    dict(
        value='128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterTransmitPriority1'),
    dict(
        value='128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterTransmitPriority2'),
    dict(
        value='0',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterStepsRemoved'),
    dict(
        value='c04121FFFE0b1f5e',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterClockIdentity'),
    dict(
        value='6',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterClockClass'),
    dict(
        value='21',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterClockAccuracy'),
    dict(
        value='4e5d',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterOffsetScaledLogVariance'),
    dict(
        value='37',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterCurrentUtcOffset'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterCurrentUtcOffsetValid'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterLeap59'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterLeap61'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterTimeTraceable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterFreqTraceable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterPtpTimescale'),
    dict(
        value='20',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterTimeSource'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterTwoStepFlag'),
    dict(
        value='PRC',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS-1',
        p_name='eCpriMasterSsmValue'),
    dict(value='VNF', dist_name='MRBTS-1900/TNLSVC-1/TNL-1', p_name='tnlType'),
    dict(value='VNF', dist_name='MRBTS-1900/TNLSVC-1/TNL-2', p_name='tnlType'),
    dict(value='VNF', dist_name='MRBTS-1900/TNLSVC-1/TNL-3', p_name='tnlType'),
    dict(value='DU', dist_name='MRBTS-1900/TNLSVC-1/TNL-4', p_name='tnlType'),
    dict(
        value='F1-M',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='X2-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='F1-C',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='X2-U S1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='F1-U',
        dist_name='MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPIF-2/IPADDRESSV4-1',
        p_name='uniqueIpAddressIdentifier'),
    dict(
        value='RU',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        p_name='profileType'),
    dict(
        value='24',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
        p_name='topDomainNumber'),
    dict(
        value='01-80-C2-00-00-0E',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topEthMulticastAddress'),
    dict(
        value='G.8275.1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        p_name='topStandardProfile'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/RMOD-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1',
        p_name='targetDN'),
    dict(
        value='standalone',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2',
        p_name='redundancyRole'),
    dict(
        value='VM',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2',
        p_name='targetDNType'),
    dict(
        value='PhaseSync',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1',
        p_name='btsSyncMode'),
    dict(
        value='RAC',
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1',
        p_name='profileType'),
    dict(
        value='Locked',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCKSTATUS-1',
        p_name='syncStatus'),
    dict(
        value='MRBTS-1900/NRBTS-1/NRDU-1',
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-1',
        p_name='targetHwResetUDN'),
    dict(
        value='MRBTS-1900/EQM-1/APEQM-1/RMOD-1',
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-2',
        p_name='targetHwResetUDN'),
    dict(
        value='MRBTS-1900',
        dist_name='MRBTS-1900/MNL-1/CMD-1/HWRESETREQ-3',
        p_name='targetHwResetUDN'),
    dict(
        value='46',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        p_name='sPlaneDscp'),
    dict(
        value='MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        p_name='sPlaneIpAddressDN'),
    dict(
        value='0',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1',
        p_name='topDomainNumber'),
    dict(
        value='RATE_128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        p_name='syncMessageRate'),
    dict(
        value='Telecom2008',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        p_name='topStandardProfile'),
    dict(
        value='Locked',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1',
        p_name='lockState'),
    dict(
        value='c04121fffe10df2b',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1',
        p_name='topSlaveClockIdentity'),
    dict(
        value='255',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1',
        p_name='topSlaveClockClass')
]
LIST_TO_CREATE = [
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-2/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-3/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name="MRBTS-1900/TNLSVC-1/TNL-4/IPNO-1/IPRT-1",
        list_name="staticRoutes"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name="targetDNList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name="acceptedClockClass"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name="topMasterList"),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1",
        list_name="topMasterList"),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name="ntpServerList")
]
PARAMS_TO_ADD_ITEM_TO_LIST = [
    dict(value='128', dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1', list_name='topMasterList',
         p_name="localPriority", version='MNL5G19B_1910_100'),
    dict(value='10.57.249.62', dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
         list_name='topMasterList', p_name="masterIpAddr", version='MNL5G19B_1910_100'),
    dict(value='0', dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
         list_name='topMasterList', p_name="maximumNetworkTimingError", version='MNL5G19B_1910_100'),
    dict(value='0', dist_name='MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1', list_name='topMasterList',
         p_name="phaseErrorComp", version='MNL5G19B_1910_100')
]
LIST_ITEM_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='topMasterList',
        elements={
            'phaseErrorComp': '0'}),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-2/SYNC-1/CLOCK-1/NTP-1',
        list_name='ntpServerList',
        elements={
            'ntpServerIpAddr': '10.56.126.22'}),
    dict(
        dist_name="MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1/TOPPSTATUS-1",
        list_name="topMasterList",
        elements={
            "freqTraceable": "true",
            "topMasterClockState": "MASTER_CLOCK_OK",
            "timeTraceable": "true",
            "topGMasterClockAccuracy": "21",
            "topGMasterClockClass": "6",
            "topGMasterClockIdentity": "b0aefffe05260b",
            "topGMasterOffsetScaledLogVariance": "6400",
            "topMasterClockIdentity": "b0aefffe05260b",
            "topMasterPortNumber": "1",
            "topSlavePortNumber": "1",
            "topStepsRemoved": "1",
            "receivedPriority_1": "128",
            "receivedPriority_2": "128",
            "topMasterUsed": "used"})
]
LIST_ELEMENT_TO_ADD = [
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-1',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-2',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-3',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/NRBTS-1/NRCELL-4',
        list_name='fPdcchMonOccsnPo',
        elements=['1610']),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2',
        list_name='targetDNList',
        elements=['MRBTS-1900/EQM-1/APEQM-1/RMOD-1']),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        list_name='acceptedClockClass',
        elements=[
            6,
            7]),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1',
        list_name='acceptedClockClass',
        elements=[
            6,
            7,
            13,
            14])
]

AMOUNT_OF_CELLS = 1
