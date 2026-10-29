
def get_hw_conf(bts_hw_infos):
    """
    Function to return automatically a hardware configuration
    Example: NSA_2xASIB_6xABIO_10xAHCA_8xAHFIB_18xAHEH_20xCells_n5_FDD_36xCells_n3_FDD_16xCells_n25_FDD
    @param bts_hw_infos:
    @return:
    """
    # Retrieve information about radio, baseband, system modules, and cells
    ru_infos = get_ru_infos(bts_hw_infos)
    bb_infos = get_bb_infos(bts_hw_infos)
    sm_infos = get_sm_infos(bts_hw_infos)
    cells_infos = get_cells_infos(bts_hw_infos)

    hw_topology = f"{bts_hw_infos['gNbCuType']}_"

    hw_topology += "_".join(f"{len(lst)}x{sm.split(' ')[0]}" for sm, lst in sm_infos.items()) + "_"

    bbs = sorted(f"{len(lst)}x{bb.split(' ')[0]}" for bb, lst in bb_infos.items())
    hw_topology += "_".join(bbs) + "_"

    rus = sorted(f"{len(lst)}x{ru}" for ru, lst in ru_infos.items())
    hw_topology += "_".join(rus) + "_"

    cells = sorted(f"{len(lst)}xCells_{id}" for id, lst in cells_infos.items())
    hw_topology += "_".join(cells)

    return hw_topology.rstrip('_')


def get_sw_version(bts_hw_infos):
    sw_info = bts_hw_infos.get('swInfo')
    return sw_info.get('swVersion') if sw_info else None


def get_ru_infos(bts_hw_infos):
    ru_infos = {}
    for ru in bts_hw_infos['radioModules']['rmod']:
        productName = ru['productName']
        module_info = {
            'productCode': ru['productCode'],
            'serialNumber': ru['serialNumber']
        }
        if productName not in ru_infos:
            ru_infos[productName] = [module_info]
        else:
            ru_infos[productName].append(module_info)
    return ru_infos


def get_bb_infos(bts_hw_infos):
    bb_infos = {}
    for bb in bts_hw_infos['basebandModules']:
        productName = bb['productName']
        module_info = {
            'productCode': bb['productCode'],
            'serialNumber': bb['serialNumber']
        }
        if productName not in bb_infos:
            bb_infos[productName] = [module_info]
        else:
            bb_infos[productName].append(module_info)
    return bb_infos


def get_sm_infos(bts_hw_infos):
    sm_infos = {}
    for sm in bts_hw_infos['systemModules']:
        productName = sm['productName']
        module_info = {
            'productCode': sm['productCode'],
            'serialNumber': sm['serialNumber']
        }
        if productName not in sm_infos:
            sm_infos[productName] = [module_info]
        else:
            sm_infos[productName].append(module_info)
    return sm_infos


def get_cells_infos(bts_hw_infos):
    cellsInfo = {}
    for cell in bts_hw_infos['cells']['nr']:
        id = f"{cell['band']}_{cell['technology']}"
        cell_info = {'nrcell': cell['id']['configuration']}
        if id not in cellsInfo:
            cellsInfo[id] = [cell_info]
        else:
            cellsInfo[id].append(cell_info)
    return cellsInfo
