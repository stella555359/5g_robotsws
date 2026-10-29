from ta_emss import ta_emss


def check_counter_for_cells(counter_id, cells, values):
    emss = ta_emss(host='10.0.1.1', port=4001)
    cell_list = ["NRCELL-" + cell for cell in cells.split(',')]
    values_list = values.split(',')

    for i in range(len(values_list)):
        if values_list[i][0] == '>':
            emss.verify_that_rtpm_counter_value_is_equal_to(cell_list[i],
                                                            counter_id,
                                                            [int(values_list[i][1:]), 99999999])
        elif values_list[i][0] == '<':
            emss.verify_that_rtpm_counter_value_is_equal_to(cell_list[i],
                                                            counter_id,
                                                            [0, int(values_list[i][1:])])
        else:
            if '-' in values_list[i]:
                emss.verify_that_rtpm_counter_value_is_equal_to(cell_list[i],
                                                                counter_id,
                                                                [int(values_list[i][:values_list[i].find('-')]),
                                                                 int(values_list[i][values_list[i].find('-')+1:])])
            else:
                emss.verify_that_rtpm_counter_value_is_equal_to(cell_list[i],
                                                                counter_id,
                                                                int(values_list[i]))
