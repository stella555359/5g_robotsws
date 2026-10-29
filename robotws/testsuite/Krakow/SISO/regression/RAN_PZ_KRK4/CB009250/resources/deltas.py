from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns
from testsuite.Krakow.resources.RAN_PZ_KRK4.delta_generator import generate_param_delta_for_multiple_cells, \
    generate_base_delta


def generate_delta_ibw(operation_mode="One_Sector_1600MHz_IBW_2T2R_SU_MIMO", cell_start=1, cell_end=8):
    return [*generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name,
                                                     cell_start=cell_start, cell_end=cell_end,
                                                     param_name="fr2OperationMode",
                                                     value=operation_mode)]


def generate_power_saving_delta(mode="activate"):
    return [generate_base_delta(dist_name="MRBTS-{}/NRBTS-{}", parameter_name='actLbpsCtrlLogicEnh',
                                value='true' if mode == "activate" else "false"),
            generate_base_delta(dist_name="MRBTS-{}/NRBTS-{}", parameter_name='actNrLBPowerSaving',
                                value='true' if mode == "activate" else "false"),
            generate_base_delta(dist_name="MRBTS-{}/NRBTS-{}", parameter_name='actCoordinated4g5gPowerSaving',
                                value="cellDeactAndReact" if mode == "activate" else "disabled")]


DELTA_ACTIVATE_CATEGORY_ALARMS_AND_SIGNATURES = {
    'GNB0': [
        generate_base_delta(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1", parameter_name='actCategoryAlarms',
                            value='true'),
        generate_base_delta(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", parameter_name='actFaultSignature',
                            value='true')]
}

DELTA_ACTIVATE_POWER_SAVING = {
    'GNB0': [
        *generate_power_saving_delta(mode="activate")]
}

DELTA_DEACTIVATE_POWER_SAVING = {
    'GNB0': [
        *generate_power_saving_delta(mode="deactivate")]
}
