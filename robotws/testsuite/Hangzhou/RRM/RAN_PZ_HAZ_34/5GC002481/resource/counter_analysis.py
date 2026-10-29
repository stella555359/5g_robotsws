# -*- coding: utf-8 -*-


def get_cell_counter_value(counter_values, cellId,
                           measType, measId, epochTime):
    dictionary_counter = counter_values['BTS']['CELLS'][cellId][measType][measId]
    list_counter = []
    for k, v in dictionary_counter.items():
        list_counter.append(v)
    return list_counter
