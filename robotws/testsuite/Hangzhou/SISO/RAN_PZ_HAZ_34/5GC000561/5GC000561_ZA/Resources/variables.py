import os

# from taf.config.testline.legacy import (CONFIG_5G, SCF)

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

PARAM_561_001 = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCpri Master Synchronous Ethernet SSM support network standard',
        p_name='eCpriMasterSsmType'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master SSM value',
        p_name='eCpriMasterSsmValue')
]

PARAM_561_002 = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock identity',
        p_name='eCpriMasterClockIdentity')
]

PARAM_561_004_010_014 = [
    dict(
        value='SSM_ITU',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCpri Master Synchronous Ethernet SSM support network standard',
        p_name='eCpriMasterSsmType')
]

PARAM_561_005_013 = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCpri Master Synchronous Ethernet SSM support network standard',
        p_name='eCpriMasterSsmType'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master SSM value',
        p_name='eCpriMasterSsmValue'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock class',
        p_name='eCpriMasterClockClass'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock accuracy',
        p_name='eCpriMasterClockAccuracy'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master OffsetScaledLogVariance',
        p_name='eCpriMasterOffsetScaledLogVariance'),
    dict(
        value='2.048MHz input',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        filter_param='Sync input type',
        p_name='syncInputType')
]

PARAM_561_006 = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCpri Master standard profile',
        p_name='eCpriMasterStandardProfile')
]

PARAM_561_007 = [
    dict(
        value='24',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCPRI Master domain number',
        p_name='eCpriMasterDomainNumber')
]

PARAM_561_008 = [
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/ECPRIMASTER-1',
        filter_param='eCPRI Master over Ethernet multicast address',
        p_name='eCpriMasterEthMulticastAddress'),
    dict(
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        filter_param='ToP over Ethernet multicast address',
        p_name='topEthMulticastAddress')
]

PARAM_561_011 = [
    dict(
        value='MASTER_CLOCK_OK',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock state',
        p_name='eCpriMasterClockState'),
    dict(
        value='128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master priority 1',
        p_name='eCpriMasterTransmitPriority1'),
    dict(
        value='128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master priority 2',
        p_name='eCpriMasterTransmitPriority2'),
    dict(
        value='0',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master steps removed',
        p_name='eCpriMasterStepsRemoved'),
    dict(
        value='6',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock class',
        p_name='eCpriMasterClockClass'),
    dict(
        value='21',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock accuracy',
        p_name='eCpriMasterClockAccuracy'),
    dict(
        value='4e5d',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master OffsetScaledLogVariance',
        p_name='eCpriMasterOffsetScaledLogVariance'),
    dict(
        value='37',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master UTC offset from TAI time',
        p_name='eCpriMasterCurrentUtcOffset'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master UTC offset validity flag',
        p_name='eCpriMasterCurrentUtcOffsetValid'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master negative leap second flag',
        p_name='eCpriMasterLeap59'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master positive leap second flag',
        p_name='eCpriMasterLeap61'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master time traceable to a PRTC clock',
        p_name='eCpriMasterTimeTraceable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock frequency traceable to a PRC clock',
        p_name='eCpriMasterFreqTraceable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master time scale',
        p_name='eCpriMasterPtpTimescale'),
    dict(
        value='20',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='Source of time at eCPRI Master',
        p_name='eCpriMasterTimeSource'),
    dict(
        value='PRC',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master SSM value',
        p_name='eCpriMasterSsmValue')
]

PARAM_561_011_TRUNK = [
    dict(
        value='MASTER_CLOCK_OK',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock state',
        p_name='eCpriMasterClockState'),
    dict(
        value='128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master priority 1',
        p_name='eCpriMasterTransmitPriority1'),
    dict(
        value='128',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master priority 2',
        p_name='eCpriMasterTransmitPriority2'),
    dict(
        value='0',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master steps removed',
        p_name='eCpriMasterStepsRemoved'),
    dict(
        value='6',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock class',
        p_name='eCpriMasterClockClass'),
    dict(
        value='21',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock accuracy',
        p_name='eCpriMasterClockAccuracy'),
    dict(
        value='4e5d',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master offset scaled log variance',
        p_name='eCpriMasterOffsetScaledLogVariance'),
    dict(
        value='37',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master UTC offset from TAI time',
        p_name='eCpriMasterCurrentUtcOffset'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master UTC offset validity flag',
        p_name='eCpriMasterCurrentUtcOffsetValid'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master negative leap second flag',
        p_name='eCpriMasterLeap59'),
    dict(
        value='false',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master positive leap second flag',
        p_name='eCpriMasterLeap61'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master time traceable to a PRTC clock',
        p_name='eCpriMasterTimeTraceable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master clock frequency traceable to a PRC clock',
        p_name='eCpriMasterFreqTraceable'),
    dict(
        value='true',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master time scale',
        p_name='eCpriMasterPtpTimescale'),
    dict(
        value='20',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='Source of time at eCPRI Master',
        p_name='eCpriMasterTimeSource'),
    dict(
        value='PRC',
        dist_name='MRBTS-1900/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1',
        filter_param='eCPRI Master SSM value',
        p_name='eCpriMasterSsmValue')
]

PARAM_561_012 = [
    dict(
        dist_name='MRBTS-1900/MNL-1/PMMNL-1',
        filter_param='eCPRI Master clock statistics measurement interval',
        p_name='eCpriMasterStatisticsInterval')
]
