
def generate_delta_for_barred_lncells(cells):
    return _generate_delta_for_cell_barred_param(cells=cells, value='barred', cell_type='LTE')


def generate_delta_for_not_barred_lncells(cells):
    return _generate_delta_for_cell_barred_param(cells=cells, value='notBarred', cell_type='LTE')


def generate_delta_for_barred_nrcells(cells):
    return _generate_delta_for_cell_barred_param(cells=cells, value='barred', cell_type='NR')


def generate_delta_for_not_barred_nrcells(cells):
    return _generate_delta_for_cell_barred_param(cells=cells, value='notBarred', cell_type='NR')


def _generate_delta_for_cell_barred_param(cells, value='barred', cell_type='LTE'):
    delta = []
    if not isinstance(cells, list):
        cells = cells.split(',')
    get_delta_method = _get_delta_for_lncell_barred_param if cell_type == 'LTE' else _get_delta_for_nrcell_barred_param
    for cell_id in cells:
        delta.append(get_delta_method(cell_id=cell_id, value=value))
    return delta


def _get_delta_for_lncell_barred_param(cell_id, value='barred'):
    delta = {"distName": "MRBTS-{}/LNBTS-{}/LNCEL-{}/SIB-0".format('{}', '{}', cell_id),
             "operation": "update",
             "parameters": [{"parameterName": "cellBarred",
                             "value": "{}".format(value),
                             "operation": "update"}]}
    return delta


def _get_delta_for_nrcell_barred_param(cell_id, value='barred'):
    delta = {"distName": "MRBTS-{}/NRBTS-{}/NRCELL-{}".format('{}', '{}', cell_id),
             "operation": "update",
             "parameters": [{"parameterName": "cellBarred",
                             "value": "{}".format(value),
                             "operation": "update"}]}
    return delta
