import logging

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB007564.resources.test_specific_keywords_7564 import atten, tcpdump
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from taf.collectors.pmcounters import pmcounters
from taf.analyzer.pmcounter.interface import pmcounter

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2

l1l2 = L1L2()
mrbts_id = 55200  # for purpose of problem
nrbts_id = tl.gnbs[0].instance_id


def preparing_for_handover_CB012439(handover='handover', bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMeasProfileInterFreq', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMobilityReportCu', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrRANS', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMeasProfileInterRat', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMeasProfileIntraFreq', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMeasProfileMappingNSA', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMeasProfileMappingSA', '5min')
    ds.add_param_to_delta(nrbts_object + '/NRPMRNL-1',
                          'miNrMeasProfileSCell', '5min')
    if handover == 'handover':
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-4',
                              'handoverAllowedSA', 'allowed')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                              'qRxLevMin', '-22')
        ds.add_param_to_delta(nrbts_object, 'measProfProtectTimer', '0')
        ds.add_param_to_delta(nrbts_object, 'actMeasurementProfile', 'SA')
        ds.add_param_to_delta_to_delete_it(nrbts_object+'/NRCELL-3/NRREL-2', 'sCellAdditionMethod')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-3/NRREL-4', 'sCellAdditionMethod')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-3/NRREL-5', 'sCellAdditionMethod')
        ds.add_param_to_delta_to_delete_it(nrbts_object+'/NRCELL-3/NRREL-2', 'sCellOperationalMode')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-3/NRREL-4', 'sCellOperationalMode')
        ds.add_param_to_delta_to_delete_it(nrbts_object + '/NRCELL-3/NRREL-5', 'sCellOperationalMode')
    else:
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                              'qRxLevMin', '-22')
        ds.add_param_to_delta(nrbts_object,
                              'actBufferBasedSCellAddition', 'oneShot_Dl_Fr1')
        ds.add_param_to_delta(nrbts_object,
                              'sCellActivationMethod', 'bufferBased')
        ds.add_param_to_delta(nrbts_object, 'measProfProtectTimer', '25')
        ds.add_param_to_delta(nrbts_object, 'actMobilityProfile', 'true')
        ds.add_param_to_delta(nrbts_object, 'actMeasurementProfile', 'SA')
        ds.add_param_to_delta(nrbts_object, 'actMeasProfileCa', 'SA')
        ds.add_param_to_delta(nrbts_object, 'actCAMeasInMeasProf', 'SA')
        ds.add_param_to_delta(nrbts_object, 'actMobilityProfileReSelect', 'true')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-2', 'sCellAdditionMethod', 'covBasedA1')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-4', 'sCellAdditionMethod', 'covBasedA1')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-5', 'sCellAdditionMethod', 'covBasedA1')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRREL-1', 'sCellAdditionMethod', 'covBasedA1')
        ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRREL-2', 'sCellAdditionMethod', 'covBasedA1')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    logging.debug("------------------Preconditions for cell counters done, handover allowed-------------------------")


def deactivating_handover_CB012439(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-4',
                          'handoverAllowedSA', 'forbidden')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3',
                          'qRxLevMin', '-60')
    ds.add_param_to_delta(nrbts_object,
                          'actBufferBasedSCellAddition', 'disabled')
    ds.add_param_to_delta(nrbts_object,
                          'sCellActivationMethod', 'blind')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-2', 'sCellAdditionMethod', 'blind')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-4', 'sCellAdditionMethod', 'blind')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-5', 'sCellAdditionMethod', 'blind')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-2', 'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-4', 'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-3/NRREL-5', 'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRREL-1', 'sCellAdditionMethod', 'blind')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRREL-2', 'sCellAdditionMethod', 'blind')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRREL-1', 'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(nrbts_object + '/NRCELL-4/NRREL-2', 'sCellOperationalMode', 'dlOnly')
    ds.add_param_to_delta(nrbts_object, 'actMeasurementProfile', 'deactivated')
    ds.add_param_to_delta(nrbts_object, 'measProfProtectTimer', '0')
    ds.add_param_to_delta(nrbts_object, 'actMobilityProfile', 'false')
    ds.add_param_to_delta(nrbts_object, 'actMeasProfileCa', 'deactivated')
    ds.add_param_to_delta(nrbts_object, 'actCAMeasInMeasProf', 'deactivated')
    ds.add_param_to_delta(nrbts_object, 'actMobilityProfileReSelect', 'false')

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    logging.debug("------------------Handover forbidden------------------------")


@logged_keyword
def handover_attenuation_preparing_CB012439(handover='handover'):
    cell_1_attenuator_ports = tl.gnbs[0].dus[0].rus[0].attenuation_ports,
    cell_3_attenuator_ports = tl.gnbs[0].dus[0].rus[2].attenuation_ports,
    cell_4_attenuator_ports = tl.gnbs[0].dus[0].rus[3].attenuation_ports,
    cell_5_attenuator_ports = tl.gnbs[0].dus[0].rus[4].attenuation_ports,
    atten.initialise_attenuator()
    if handover == 'handover':
        logging.debug("attenuating target cell")
        atten.set_attenuation(value_string='0', ports=[5, 6])
        atten.set_attenuation(value_string='90', ports=[1, 2])
        atten.set_attenuation(value_string='90', ports=cell_3_attenuator_ports)
        atten.set_attenuation(value_string='90', ports=cell_4_attenuator_ports)
        atten.set_attenuation(value_string='90', ports=cell_5_attenuator_ports)
    else:
        logging.debug("attenuating  cells for CA")
        atten.set_attenuation(value_string='0', ports=[5, 6])
        atten.set_attenuation(value_string='90', ports=[1, 2])
        atten.set_attenuation(value_string='90', ports=cell_3_attenuator_ports)
        atten.set_attenuation(value_string='90', ports=cell_4_attenuator_ports)
        atten.set_attenuation(value_string='0', ports=cell_5_attenuator_ports)


@logged_keyword
def handover_attenuation_loop_CB012439(cell_1=0, cell_2=4):
    cell_1_attenuator_ports = tl.gnbs[0].dus[0].rus[cell_1].attenuation_ports,
    cell_2_attenuator_ports = tl.gnbs[0].dus[0].rus[cell_2].attenuation_ports,
    atten.initialise_attenuator()
    logging.debug(cell_1_attenuator_ports, "celka 3")
    logging.debug(cell_2_attenuator_ports, "celka 4")
    logging.debug("attenuating target cell")
    for i in range(0, 90, 10):
        atten.set_attenuation(value_string=0, ports=cell_2_attenuator_ports)
        atten.set_attenuation(value_string=5 + i, ports=cell_1_attenuator_ports)


@logged_keyword
def get_and_verify_counters_complicated_name(pi_dir, counter_ids):
    analyzer = pmcounter()
    pi_dict = analyzer.get_pi_value(pi_list=counter_ids, pi_dir=pi_dir, pi_file_pattern='PM*.[rx][am][wl]')
    return pi_dict


@logged_keyword
def Finding_counters(data_collected, counter_filer, counter_ids):
    result = {t: [] for t in counter_ids}

    for entry in data_collected:
        for ts, content in entry.items():
            for t in counter_ids:
                if t in content:
                    value = content[t].get(counter_filer)
                    if value is not None:
                        result[t].append(value)

    return result


@logged_keyword
def comparison_of_counters(cell3_SA, cell4_SA, cell3_IAF, cell4_IAF, cell3_IEF, handover_counter):
    blog("results for CELL_3", "M55190C00001", cell3_SA['M55190C00001'][-1], "M55190C00002",
         cell3_SA['M55190C00002'][-1], "M55187C00001", cell3_IAF['M55187C00001'][-1],
         "M55187C00002", cell3_IAF['M55187C00002'][-1], "M55188C00001", cell3_IEF['M55188C00001'][-1], "M55147C00024",
         handover_counter['M55147C00024'][-1])

    blog("results for CELL_4", "M55190C00001", cell4_SA['M55190C00001'][-1], "M55190C00002",
         cell4_SA['M55190C00002'][-1], "M55187C00001", cell4_IAF['M55187C00001'][-1],
         "M55187C00002", cell4_IAF['M55187C00002'][-1])

    assert cell3_SA['M55190C00001'][-1] == '3', (f"Expected last value for M55190C00001 for Cell 3"
                                                 f"to be 3, but got {cell3_SA['M55190C00001'][-1]}")

    assert cell3_SA['M55190C00002'][-1] == '2', (f"Expected last value for M55190C00002 for Cell 3"
                                                 f" be 2, but got {cell3_SA['M55190C00002'][-1]}")

    assert cell4_SA['M55190C00001'][-1] == '1', (f"Expected last value for M55190C00001 for cell 4"
                                                 f" to be 1, but got {cell4_SA['M55190C00001'][-1]}")

    assert cell4_SA['M55190C00002'][-1] == '1', (f"Expected last value for M55190C00002 for cell 4"
                                                 f" to be 1, but got {cell4_SA['M55190C00002'][-1]}")

    assert cell3_IAF['M55187C00001'][-1] == '2', (f"Expected last value for M55187C00001 cell 3 to be 2, "
                                                  f"to be 2 but got {cell3_IAF['M55187C00001'][-1]}")

    assert cell3_IAF['M55187C00002'][-1] == '2', (f"Expected last value for M55187C00002 for cell 3"
                                                  f" to be 2, but got {cell3_IAF['M55187C00002'][-1]}")

    assert cell4_IAF['M55187C00001'][-1] == '1', (f"Expected last value for M55187C00001 for cell 4"
                                                  f" to be 1, but got {cell4_IAF['M55187C00001'][-1]}")

    assert cell4_IAF['M55187C00002'][-1] == '1', (f"Expected last value for M55187C00002 for cell 4"
                                                  f", to be 1but got {cell4_IAF['M55187C00002'][-1]}")

    assert cell3_IEF['M55188C00001'][-1] == '1', (f"Expected last value for M55188C00001 for cell 3 to "
                                                  f" be 1, but got {cell3_IEF['M55188C00001'][-1]}")

    assert handover_counter['M55147C00024'][-1] == '1', (f"Expected last value for M55147C00024 for cell 3 to"
                                                         f" be 1, but got {handover_counter['M55147C00024'][-1]}")


def comparison_of_counters_BC(cell3_SA, cell4_SA, cell3_IAF, cell4_IAF, cell3_IEF):
    blog("results for CELL_4", "M55190C00001", cell3_SA['M55190C00001'][-1], "M55190C00002",
         cell3_SA['M55190C00002'][-1], "M55187C00001", cell4_SA['M55187C00001'][-1],
         "M55187C00002", cell4_SA['M55187C00002'][-1], "M55187C00003", cell3_IAF['M55187C00003'][-1],
         "M55187C00004", cell3_IAF['M55187C00004'][-1], "M55188C00001", cell4_IAF['M55188C00001'][-1],
         "M55188C00002", cell4_IAF['M55188C00002'][-1], 'M55157C00033', cell3_IEF['M55157C00033'][-1])

    assert cell3_SA['M55190C00001'][-1] == '1', (f"Expected last value for M55190C00001 for Cell 4"
                                                 f"to be 1, but got {cell3_SA['M55190C00001'][-1]}")

    assert cell3_SA['M55190C00002'][-1] == '1', (f"Expected last value for M55190C00002 for Cell 4"
                                                 f" be 1, but got {cell3_SA['M55190C00002'][-1]}")

    assert cell4_SA['M55187C00001'][-1] == '1', (f"Expected last value for M55187C00001 for cell 4"
                                                 f" to be 1, but got {cell4_SA['M55187C00001'][-1]}")

    assert cell4_SA['M55187C00002'][-1] == '1', (f"Expected last value for M55187C00002 for cell 4"
                                                 f" to be 1, but got {cell4_SA['M55187C00002'][-1]}")

    assert cell3_IAF['M55187C00003'][-1] == '1', (f"Expected last value for M55187C00003 for cell 4"
                                                  f" to be 1, but got {cell3_IAF['M55187C00003'][-1]}")

    assert cell3_IAF['M55187C00004'][-1] == '0', (f"Expected last value for M55187C00004 for cell 4"
                                                  f" to be 0, but got {cell3_IAF['M55187C00004'][-1]}")

    assert cell4_IAF['M55188C00001'][-1] == '0', (f"Expected last value for M55188C00001 for cell 4"
                                                  f" to be 1, but got {cell4_IAF['M55188C00001'][-1]}")

    assert cell4_IAF['M55188C00002'][-1] == '0', (f"Expected last value for M55188C00002 for cell 4"
                                                  f" to be 0, but got {cell4_IAF['M55188C00002'][-1]}")

    assert cell3_IEF['M55157C00033'][-1] == '1', (f"Expected last value for M55157C00033 for cell 4"
                                                  f" to be 0, but got {cell3_IEF['M55157C00033'][-1]}")
