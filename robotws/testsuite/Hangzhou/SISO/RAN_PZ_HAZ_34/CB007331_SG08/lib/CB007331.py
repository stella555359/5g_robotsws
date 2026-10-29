import random

frame_1070_GP1 = {
    'frameStructureType': 'semiStatic',
    'guardPeriodLength': '2Symbols',
    'lteToNrFrameShift': None,
    'tdLteUlDlConfig': None,
    'ulDlDataSlotRatio': 3/7
}

frame_1070_GP2 = {
    'frameStructureType': 'semiStatic',
    'guardPeriodLength': '4Symbols',
    'lteToNrFrameShift': None,
    'tdLteUlDlConfig': None,
    'ulDlDataSlotRatio': 3/7
}

frame_1208_GP1 = {
    'frameStructureType': 'semiStatic',
    'guardPeriodLength': '2Symbols',
    'lteToNrFrameShift': None,
    'tdLteUlDlConfig': None,
    'ulDlDataSlotRatio': 1/4
}

frame_1208_GP2 = {
    'frameStructureType': 'semiStatic',
    'guardPeriodLength': '4Symbols',
    'lteToNrFrameShift': None,
    'tdLteUlDlConfig': None,
    'ulDlDataSlotRatio': 1/4
}

frame_1116_0ms_GP1 = {
    'frameStructureType': 'tdLte',
    'guardPeriodLength': '4Symbols',
    'lteToNrFrameShift': '0ms',
    'tdLteUlDlConfig': 'tdLteConfig2',
    'ulDlDataSlotRatio': None
}

frame_1116_0ms_GP2 = {
    'frameStructureType': 'tdLte',
    'guardPeriodLength': '6Symbols',
    'lteToNrFrameShift': '0ms',
    'tdLteUlDlConfig': 'tdLteConfig2',
    'ulDlDataSlotRatio': None
}

frame_1116_3ms_GP1 = {
    'frameStructureType': 'tdLte',
    'guardPeriodLength': '4Symbols',
    'lteToNrFrameShift': '3ms',
    'tdLteUlDlConfig': 'tdLteConfig2',
    'ulDlDataSlotRatio': None
}

frame_1116_3ms_GP2 = {
    'frameStructureType': 'tdLte',
    'guardPeriodLength': '6Symbols',
    'lteToNrFrameShift': '3ms',
    'tdLteUlDlConfig': 'tdLteConfig2',
    'ulDlDataSlotRatio': None
}


def get_framestrut_type(frameinfo):
    if frameinfo['frameStructureType'] == 'tdLte' and frameinfo['guardPeriodLength'] == '4Symbols' and  \
            frameinfo['lteToNrFrameShift'] == '0ms' and frameinfo['tdLteUlDlConfig'] == 'tdLteConfig2':
        return '1116_0ms_GP1'
    elif frameinfo['frameStructureType'] == 'semiStatic' and frameinfo['guardPeriodLength'] == '2Symbols' and  \
            frameinfo['ulDlDataSlotRatio'] == '1/4':
        return '1208_GP1'
    elif frameinfo['frameStructureType'] == 'semiStatic' and frameinfo['guardPeriodLength'] == '4Symbols' and  \
            frameinfo['ulDlDataSlotRatio'] == '1/4':
        return '1208_GP2'
    elif frameinfo['frameStructureType'] == 'semiStatic' and frameinfo['guardPeriodLength'] == '2Symbols' and  \
            frameinfo['ulDlDataSlotRatio'] == '3/7':
        return '1070_GP1'
    elif frameinfo['frameStructureType'] == 'semiStatic' and frameinfo['guardPeriodLength'] == '4Symbols' and  \
            frameinfo['ulDlDataSlotRatio'] == '3/7':
        return '1070_GP2'


def get_subcells_by_random(cell_count_all, cell_count_select):
    cells = []
    for i in range(1, cell_count_all+1):
        cells.append(i)
    random_cells = random.sample(cells, cell_count_select)
    return random_cells


def get_pa_port_list_by_subcell_id(subcell_id):
    if subcell_id == 1:
        return [1, 34, 67, 100]
    elif subcell_id == 2:
        return [9, 42, 75, 108]
    elif subcell_id == 3:
        return [17, 50, 83, 116]
    elif subcell_id == 4:
        return [5, 38, 71, 104]
    elif subcell_id == 5:
        return [13, 46, 79, 112]
    elif subcell_id == 6:
        return [21, 54, 87, 120]
