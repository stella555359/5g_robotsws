from robot.libraries.BuiltIn import BuiltIn
import logging
tl = BuiltIn().get_variable_value('${tl}')
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-11'
NR_CELL_NAME2 = NR_NAME + '/NRCELL-12'
NR_CELL_NAME3 = NR_NAME + '/NRCELL-13'
NR_CELL_NAME4 = NR_NAME + '/NRCELL-14'
NR_CELL_GRP = NR_NAME + '/NRCELLGRP-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'
DIST_RLRESUMEBACKOFFTMR = NR_CELL_NAME


MODIFY_BASE_SCF = [
    dict(
        value='NSA',
        dist_name=NR_CELL_NAME,
        p_name='cellDepType'),
    dict(
        value='100MHz',
        dist_name=NR_CELL_NAME,
        p_name='chBw'),
    dict(
        value='Unrestricted',
        dist_name=NR_CELL_NAME,
        p_name='prachSequenceType'),
    dict(
        value='240 KHz',
        dist_name=NR_CELL_NAME,
        p_name='ssbScs'),
    dict(
        value='120 KHz',
        dist_name=NR_NAME + '/NRCELLGRP-1',
        p_name='scs'),
    dict(
        value='1x_range',
        dist_name=NR_CELL_NAME,
        p_name='rangeExtension'),
    dict(
        value='64',
        dist_name=NR_CELL_NAME,
        p_name='totalNumberOfRAPreambles'),
    dict(
        value='n48',
        dist_name=NR_CELL_NAME,
        p_name='cbraPreamblesPerSsb'),
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actBeamforming'),
    dict(
        value='38',
        dist_name=NR_CELL_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='8',
        dist_name=NR_CELL_NAME,
        p_name='zeroCorrelationZoneConfig'),
    dict(
        value='0',
        dist_name=NR_CELL_NAME,
        p_name='prachRootSequenceIndex'),
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrCaDu'),
    ]

FRAME_STRUCT_1127_SCF = [
    dict(
        value='semiStatic',
        dist_name=NR_CELL_NAME,
        list_name='tddFrameStructure',
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name=NR_CELL_NAME,
        list_name='tddFrameStructure',
        p_name='guardPeriodLength'),
    dict(
        value='1/4',
        dist_name=NR_CELL_NAME,
        list_name='tddFrameStructure',
        p_name='ulDlDataSlotRatio'),
]

MODIFY_1305_02_PRECONDITION_API = [
    dict(
        dist_name=NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='38'),
    dict(
        dist_name=NR_CELL_NAME,
        parameter='zeroCorrelationZoneConfig',
        value='8'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='prachConfigurationIndex',
        value='38'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='zeroCorrelationZoneConfig',
        value='8'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='prachConfigurationIndex',
        value='38'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='zeroCorrelationZoneConfig',
        value='8'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='prachConfigurationIndex',
        value='38'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='zeroCorrelationZoneConfig',
        value='8'),
]

MODIFY_1305_13_PRECONDITION_API = [
    dict(
        dist_name=NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='187'),
    dict(
        dist_name=NR_CELL_NAME,
        parameter='zeroCorrelationZoneConfig',
        value='12'),
    dict(
        dist_name=NR_CELL_NAME,
        parameter='actBeamforming',
        value='false'),
    dict(
        dist_name=NR_CELL_NAME,
        parameter='beamSet',
        value=[dict(basicBeamSet='beamSetAbf_1A')]),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='prachConfigurationIndex',
        value='187'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='zeroCorrelationZoneConfig',
        value='12'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='actBeamforming',
        value='false'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='beamSet',
        value=[dict(basicBeamSet='beamSetAbf_1A')]),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='prachConfigurationIndex',
        value='187'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='zeroCorrelationZoneConfig',
        value='12'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='actBeamforming',
        value='false'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='beamSet',
        value=[dict(basicBeamSet='beamSetAbf_1A')]),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='prachConfigurationIndex',
        value='187'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='zeroCorrelationZoneConfig',
        value='12'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='actBeamforming',
        value='false'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='beamSet',
        value=[dict(basicBeamSet='beamSetAbf_1A')]),
    dict(
        dist_name=NR_CELL_GRP,
        parameter='numberOfTransmittedSsBlocks',
        value='1 beam'),
]

MODIFY_1305_16_PRECONDITION_API = [
    dict(
        dist_name=NR_CELL_NAME,
        parameter='prachConfigurationIndex',
        value='149'),
    dict(
        dist_name=NR_CELL_NAME,
        parameter='zeroCorrelationZoneConfig',
        value='15'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='prachConfigurationIndex',
        value='149'),
    dict(
        dist_name=NR_CELL_NAME2,
        parameter='zeroCorrelationZoneConfig',
        value='15'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='prachConfigurationIndex',
        value='149'),
    dict(
        dist_name=NR_CELL_NAME3,
        parameter='zeroCorrelationZoneConfig',
        value='15'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='prachConfigurationIndex',
        value='149'),
    dict(
        dist_name=NR_CELL_NAME4,
        parameter='zeroCorrelationZoneConfig',
        value='15'),
]

MODIFY_DEFAULT_SCF = MODIFY_BASE_SCF + FRAME_STRUCT_1127_SCF
