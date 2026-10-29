from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')


default_beam_set = [{
            'basicBeamSet': 'beamSet_1',
            'leftEdgeAngle': '60',
            'rightEdgeAngle': '60'
         }
    ]

emfBeamDNList = [
    "NRBEAM_EMF-1",
    "NRBEAM_EMF-2"
]

eirpControlPowerEnabled = [
    '-150',
    '-150'
]

eirpControlDisabled = [
    '0',
    '0'
]

eirpControl = [
    {
        'numOfSegmentAzimuthEdges': 1,
        'segmentAzimuthEdge0': 0,
        'numOfSegmentElevationEdges': 0
    }
]

NRCELL_DIST_NAME = BuiltIn().get_variable_value('${GNB_CELL_NAME}')

DISABLE_EMF_PARAMS = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actEmfTestMode', value='false', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='actEirpControl', value='false', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='actPdcchSharingWithPdsch', value='true', operation='update'),
]

ENABLE_EMF_PARAMS = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actEmfTestMode', value='true', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='emfBeamDNList', value=emfBeamDNList, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='emfElevation', value=1, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='emfAzimuth', value=1, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='emfTargetTotalLoad', value=100, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='actEirpControl', value='true', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='eirpControlPowerReductionFactorList',
         value=eirpControlDisabled, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='actPdcchSharingWithPdsch', value='false', operation='update'),
]

ENABLE_EIRP_PARAMS = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actEirpControl', value='true', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='eirpControl', value=eirpControl, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='eirpControlPowerReductionFactorList',
         value=eirpControlPowerEnabled, operation='update')
]

reconfig_beam_set = [{
            'nrBtsBeamRefinementP2': 'true',
            'beamsMuted': '12'
         }
    ]

ENABLE_nrBtsBeamRefinementP2 = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='beamSet', value=reconfig_beam_set, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='actDlDynSwitchAlloc', value='false', operation='update'),
]

BEAM_SET_PARAM = [
    dict(dist_name=NRCELL_DIST_NAME, parameter='actDynSsbBeamGen', value='false', operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='beamSet', value=default_beam_set, operation='update'),
    dict(dist_name=NRCELL_DIST_NAME, parameter='numberOfTransmittedSsBlocks', value=1, operation='update')
]

BEAT_SET_LST_DIC = [
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=10, rightEdgeAngle=10),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=10, rightEdgeAngle=60),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=10, rightEdgeAngle=30),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=10, rightEdgeAngle=45),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=20, rightEdgeAngle=20),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=30, rightEdgeAngle=30),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=40, rightEdgeAngle=45),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=45, rightEdgeAngle=60),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=45, rightEdgeAngle=45),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_2', leftEdgeAngle=60, rightEdgeAngle=60),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_4', leftEdgeAngle=20, rightEdgeAngle=50),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_4', leftEdgeAngle=30, rightEdgeAngle=45),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_4', leftEdgeAngle=30, rightEdgeAngle=40),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_4', leftEdgeAngle=60, rightEdgeAngle=10),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_4', leftEdgeAngle=60, rightEdgeAngle=60),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_6', leftEdgeAngle=45, rightEdgeAngle=45),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_6', leftEdgeAngle=45, rightEdgeAngle=50),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_6', leftEdgeAngle=50, rightEdgeAngle=50),
    dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_6', leftEdgeAngle=60, rightEdgeAngle=60),
    # dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_1', leftEdgeAngle=10, rightEdgeAngle=10),
    # dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_1', leftEdgeAngle=30, rightEdgeAngle=20),
    # dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_1', leftEdgeAngle=45, rightEdgeAngle=45),
    # dict(actDynSsbBeamGen='true', basicBeamSet='beamSet_1', leftEdgeAngle=60, rightEdgeAngle=60)
]
