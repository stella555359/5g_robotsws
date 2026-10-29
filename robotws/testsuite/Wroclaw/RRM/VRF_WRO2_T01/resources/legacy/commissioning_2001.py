from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.AdminHelper import AdminHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.DeltaStore import DeltaStore


def delta_commissioning_2001():
    delta = DeltaStore()
    admin = AdminHelper()

    object_path = admin.get_mrbts_id() + '/' + admin.get_nrbts_id()
    cell_path = admin.get_cells_distname_list()[0]

    delta.initialise_delta_store()

    for cell_path in admin.get_cells_distname_list():
        delta.add_param_to_delta(object_path + '/' + cell_path, 'nrCellType', value='4DL4UL')
    admin.recommission_with_delta_from_admin(delta.collect_delta_store())
    # set_fivegstac(value='7151')


def set_fivegstac(value='7151'):
    admin = AdminHelper()

    object_path = admin.get_mrbts_id() + '/' + admin.get_nrbts_id()

    new_scf = '/tmp/scf_new.xml'
    tracking_area = object_path + '/TRACKINGAREA-0'
    connection = admin.connect_to()
    xml_path = admin.get_current_scf_file(local_dir_path='/tmp', file_name='scf.xml')
    BuiltIn().log_to_console(xml_path)
    cm = scf()
    cm.load_scf(xml_path)
    try:
        cm.add_object_to_scf(class_name='com.nokia.srbts.nrbts:TRACKINGAREA',
                             dist_name=tracking_area, version='NRBTSCL5G20B_2010_100')
    except Exception:
        pass

    try:
        cm.modify_scf_element(dist_name=tracking_area, p_name='fiveGsTac', value=value)
    except Exception:
        cm.add_element_to_scf(dist_name=tracking_area, p_name='fiveGsTac', value=value)

    # cm.add_list_to_scf(dist_name=tracking_area, list_name='snssaiDNList')
    # cm.add_elements_to_list(dist_name=tracking_area, list_name='snssaiDNList', elements=[object_path + '/SNSSAI-1'])

    cm.save_scf(new_scf)
    admin.perform_commissioning(scf_file=new_scf)
    admin.teardown_admin()


def cell_preparation_2001(actBeamforming='true', numberOfTransmittedSsBlocks='6 beams', beamSet='beamSet_6',
                          leftEdgeAngle='45', rightEdgeAngle='45', beamsMuted='4',
                          dlMimoMode='4x4 or 4x2 Open Loop Spatial Multiplexing',
                          numberOfRxBeamforming='4Rx', nrBtsBeamRefinementP2='false', nrCellType='4DL4UL'):
    delta = DeltaStore()
    admin = AdminHelper()

    object_path = admin.get_mrbts_id() + '/' + admin.get_nrbts_id()
    cell_path = object_path + '/' + admin.get_cells_distname_list()[0]

    delta.initialise_delta_store()

    admin.create_admin_session()
    for nrcellgrp in admin.get_subcells_info().keys():
        delta.add_param_to_delta(object_path + '/' + nrcellgrp, 'numberOfTransmittedSsBlocks',
                                 numberOfTransmittedSsBlocks)

    if numberOfRxBeamforming == '4Rx':
        delta.add_param_to_delta(object_path, 'actFdmScheduling', value='true')
        delta.add_param_to_delta(object_path, 'actFdmEnhancedScheduling', value='true')
    else:
        delta.add_param_to_delta(object_path, 'actFdmScheduling', value='false')
        delta.add_param_to_delta(object_path, 'actFdmEnhancedScheduling', value='false')

    for cell_path in admin.get_cells_distname_list():
        delta.add_param_to_delta(object_path + '/' + cell_path, 'actBeamforming', actBeamforming)
        delta.add_param_to_delta(object_path + '/' + cell_path, 'numberOfRxBeamforming', numberOfRxBeamforming)
        delta.add_param_to_delta(object_path + '/' + cell_path, 'nrCellType', nrCellType)
        # Disable feature 2200
        delta.add_param_to_delta(object_path + '/' + cell_path, 'dlMimoMode', dlMimoMode)

        delta.add_list_parameters_to_delta(object_path + '/' + cell_path, 'beamSet',
                                           basicBeamSet=beamSet,
                                           leftEdgeAngle=leftEdgeAngle,
                                           rightEdgeAngle=rightEdgeAngle,
                                           beamsMuted=beamsMuted,
                                           nrBtsBeamRefinementP2=nrBtsBeamRefinementP2,
                                           )
        delta.add_param_to_delta(object_path + '/' + cell_path, 'antennaMechanicalDowntilt', value='0')

    admin.recommission_with_delta_from_admin(delta.collect_delta_store())
    delta.delete_delta_if_already_present("")


def eirp_params_configuration(actEirpControl='true', miNrEirp='5min'):
    delta = DeltaStore()
    admin = AdminHelper()

    object_path = admin.get_mrbts_id() + '/' + admin.get_nrbts_id()
    cell_path = object_path + '/' + admin.get_cells_distname_list()[0]

    delta.initialise_delta_store()
    for cell_path in admin.get_cells_distname_list():
        delta.add_param_to_delta(object_path + '/' + cell_path, 'actEirpControl', actEirpControl)
    delta.add_param_to_delta(object_path + '/NRPMRNL-1', 'miNrEirp', miNrEirp)

    admin.recommission_with_delta_from_admin(delta.collect_delta_store())
    delta.delete_delta_if_already_present("")


def eirp_control_power_list_configuration(numOfSegmentAzimuthEdges='9', numOfSegmentElevationEdges='5',
                                          minGuaranteedBudgetRatioMode='actualEirpBudgetRatio',
                                          minSignificantNormalizedBeamGain='-20',
                                          schedulWeightFactorEnabled='false',
                                          minGuaranteedBudgetRatio='5',
                                          azimuth_start_val=-40, elevation_start_val=-50,
                                          azimuth_step=10, elevation_step=25,
                                          eirpControlPowerReductionFactorListElems=60):
    delta = DeltaStore()
    admin = AdminHelper()

    object_path = admin.get_mrbts_id() + '/' + admin.get_nrbts_id()
    cell_path = object_path + '/' + admin.get_cells_distname_list()[0]

    delta.initialise_delta_store()

    azimuths = [str(azimuth_start_val + azimuth_step * i) for i in range(9)]
    elevations = [str(elevation_start_val + elevation_step * i) for i in range(5)]
    eirpControlPowerReductionFactorList = [0 for i in range(eirpControlPowerReductionFactorListElems)]
    # delta.add_param_to_delta(cell_path, 'numOfSegmentAzimuthEdges', numOfSegmentAzimuthEdges)
    # delta.add_param_to_delta(cell_path, 'numOfSegmentElevationEdges', numOfSegmentElevationEdges)

    for cell_path in admin.get_cells_distname_list():
        delta.add_list_parameters_to_delta(object_path + '/' + cell_path, 'eirpControl',
                                           schedulWeightFactorEnabled=schedulWeightFactorEnabled,
                                           minGuaranteedBudgetRatioMode=minGuaranteedBudgetRatioMode,
                                           numOfSegmentElevationEdges=numOfSegmentElevationEdges,
                                           minSignificantNormalizedBeamGain=minSignificantNormalizedBeamGain,
                                           numOfSegmentAzimuthEdges=numOfSegmentAzimuthEdges,
                                           minGuaranteedBudgetRatio=minGuaranteedBudgetRatio,
                                           segmentAzimuthEdge0=azimuths[0],
                                           segmentAzimuthEdge1=azimuths[1],
                                           segmentAzimuthEdge2=azimuths[2],
                                           segmentAzimuthEdge3=azimuths[3],
                                           segmentAzimuthEdge4=azimuths[4],
                                           segmentAzimuthEdge5=azimuths[5],
                                           segmentAzimuthEdge6=azimuths[6],
                                           segmentAzimuthEdge7=azimuths[7],
                                           segmentAzimuthEdge8=azimuths[8],
                                           segmentElevationEdge0=elevations[4],
                                           segmentElevationEdge1=elevations[3],
                                           segmentElevationEdge2=elevations[2],
                                           segmentElevationEdge3=elevations[1],
                                           segmentElevationEdge4=elevations[0], )
        delta.add_param_to_delta(object_path + '/' + cell_path, 'eirpControlPowerReductionFactorList',
                                 eirpControlPowerReductionFactorList)
    admin.recommission_with_delta_from_admin(delta.collect_delta_store())
    delta.delete_delta_if_already_present("")
