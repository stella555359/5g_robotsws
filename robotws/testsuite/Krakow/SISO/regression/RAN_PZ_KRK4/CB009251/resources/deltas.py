from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns
from testsuite.Krakow.resources.RAN_PZ_KRK4.delta_generator import generate_base_delta, \
    generate_param_delta_for_multiple_cells

ACTIVATE_TIMING_OFFSET = {
    'GNB0': [
        generate_base_delta(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", parameter_name='actCellTimingOffset',
                            value='true'),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, cell_start=1,
                                                 cell_end=8, param_name="frameStartOffset", value="600"),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, cell_start=1,
                                                 cell_end=8, param_name="sfnOffset", value="-500"),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, cell_start=11,
                                                 cell_end=18, param_name="frameStartOffset", value="600"),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, cell_start=11,
                                                 cell_end=18, param_name="sfnOffset", value="-500")
    ],
}

DEACTIVATE_TIMING_OFFSET = {
    'GNB0': [
        generate_base_delta(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1", parameter_name='actCellTimingOffset',
                            value='false'),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, operation="delete",
                                                 cell_start=1, cell_end=8, param_name="frameStartOffset", value=[]),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, operation="delete",
                                                 cell_start=1, cell_end=8, param_name="sfnOffset", value=[]),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, operation="delete",
                                                 cell_start=11, cell_end=18, param_name="frameStartOffset", value=[]),
        *generate_param_delta_for_multiple_cells(nrbts_dist_name=GnbDistNamePatterns.bts_dist_name, operation="delete",
                                                 cell_start=11, cell_end=18, param_name="sfnOffset", value=[])
    ],
}

DELTA_ACTIVATE_CATEGORY_ALARMS = {
    'GNB0': [
        generate_base_delta(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1", parameter_name='actCategoryAlarms',
                            value='true')
    ]
}
