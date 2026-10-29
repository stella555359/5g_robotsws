from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
import json


def create_delta(param_name, value, number_of_cells=1, dist_name_sufix=''):
    parameter_delta = []
    if dist_name_sufix:
        dist_name_sufix = '/' + dist_name_sufix
    for cell_nr in range(1, number_of_cells + 1):
        cell_dist_name = "{}/NRCELL-{}{}".format(bts_prefix, cell_nr, dist_name_sufix)
        parameter = {
            "distName": cell_dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": param_name,
                    "value": value,
                    "operation": "update"
                }
            ]
        }
        parameter_delta.append(parameter)
    return parameter_delta


def change_bwp_profile(cell_dep_type, bandwith):
    bwp_id = 30 if cell_dep_type == "SA" else 20
    bwp_id += (int(bandwith) / 5 - 1)
    number_of_cells = fixture.webUI.get_cells_number()
    delta_list = []
    delta_list.append(create_delta('cellDepType', cell_dep_type, number_of_cells))
    delta_list.append(create_delta('chBwDl', bandwith + 'MHz', number_of_cells, 'NRCELL_FDD-1'))
    delta_list.append(create_delta('cellBwpList', [
        {
            'bwpDN': "{}/BWP_PROFILE-{}".format(bts_prefix, 4),
            'cellBwpId': 0,
        },
        {
            'bwpDN': "{}/BWP_PROFILE-{}".format(bts_prefix, bwp_id),
            'cellBwpId': 1,
        },
    ], number_of_cells))
    delta = json.dumps(delta_list)
    with fixture.webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta,
                                           skip_parameter_relation_errors=True
                                           )
