def Check_scf_cell_match(scf_name, cell_list_nr):
    flag = 0
    if scf_name == 'lte_only':
        if cell_list_nr == []:
            flag = 1
    if scf_name == 'nr_only':
        if len(cell_list_nr) == 4:
            flag = 1
    if scf_name == 'nr_lte':
        if len(cell_list_nr) == 2:
            flag = 1
    return flag


def Check_configuration(cell_list_nr):
    goal = 'NR_only'
    if cell_list_nr == []:
        goal = 'LTE_only'
    if len(cell_list_nr) == 2:
        goal = 'NR_LTE'
    if len(cell_list_nr) == 4:
        goal = 'NR_only'
    return goal
