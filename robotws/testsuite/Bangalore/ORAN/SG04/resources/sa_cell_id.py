def get_nr_cell_id_in_hex(expected_nr_cell_id):
    return "{0:#0{1}x}".format(int(expected_nr_cell_id), 12)
