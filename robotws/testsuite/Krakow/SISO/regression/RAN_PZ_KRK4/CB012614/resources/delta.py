from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value('${tl.gnbs[0].dus[0].global_bts_id}')


def generate_lte_qrxlevmin_delta(attach_cell_id, number_of_cells):
    delta = list()
    for cell in range(number_of_cells):
        cell += 1
        value = "-80" if cell is attach_cell_id else "-44"
        cell_conf = {
            "distName": "MRBTS-{0}/LNBTS-{0}/LNCEL-{1}/SIB-0".format(bts_id, cell),
            "operation": "update",
            "parameters": [
                {"parameterName": "qrxlevmin", "value": value, "operation": "update"},
            ]
        },
        delta.append(*cell_conf)
    return delta
