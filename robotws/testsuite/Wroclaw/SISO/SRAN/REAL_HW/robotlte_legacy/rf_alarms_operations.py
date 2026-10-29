from robot.api import logger


def _get_cells_tx_list(lcr_id_list, cell_dictionary):
    tx_list = []
    for cell, cell_info in cell_dictionary.items():
        if int(cell) in lcr_id_list:
            try:
                float(cell_info.tx_frequency)
                float(cell_info.rx_frequency)
                float(cell_info.bandwidth)
                logger.info("Cell " + str(cell) + " info read")
                tx_list.append((float(cell_info.tx_frequency), float(cell_info.bandwidth)))
            except (TypeError, ValueError):
                logger.info("Cell " + str(cell) + " has no valid info in cell_dictionary")
                continue
    logger.info("tx list: " + str(tx_list))
    return tx_list


def _get_tx_pim_list(tx_list):
    pim_list = []
    for tx1 in tx_list:
        for tx2 in tx_list:
            if tx1 > tx2:
                pim3_f_low = min([tx1[0], tx2[0]]) - abs(tx2[0]-tx1[0])
                pim5_f_low = min([tx1[0], tx2[0]]) - 2 * abs(tx2[0] - tx1[0])
                pim3_f_high = max([tx1[0], tx2[0]]) + abs(tx2[0] - tx1[0])
                pim5_f_high = max([tx1[0], tx2[0]]) + 2 * abs(tx2[0] - tx1[0])
                pim3_bw = 3 * min([tx1[1], tx2[1]])
                pim5_bw = 5 * min([tx1[1], tx2[1]])
                pim_list.append((pim3_f_low, pim3_bw))
                pim_list.append((pim5_f_low, pim5_bw))
                pim_list.append((pim3_f_high, pim3_bw))
                pim_list.append((pim5_f_high, pim5_bw))
    logger.info("pim list: " + str(pim_list))
    return pim_list


def _get_lcr_id_list_with_pim(lcr_id_list, cell_dictionary, pim_list):
    lcr_id_list_with_pim = []
    logger.debug(lcr_id_list)
    for cell, cell_info in cell_dictionary.items():
        logger.debug("Checking cell " + str(cell))
        if int(cell) in lcr_id_list:
            try:
                rx_f = float(cell_info.rx_frequency)
                rx_bw = float(cell_info.bandwidth)
                rx_l = rx_f - rx_bw / 2
                rx_r = rx_f + rx_bw / 2
                for pim in pim_list:
                    pim_l = pim[0] - pim[1] / 2
                    pim_r = pim[0] + pim[1] / 2
                    logger.debug("Checking if RX range: " + str(rx_l) + "-" + str(rx_r) +
                                 " falls in PIM range: " + repr(pim))
                    if (pim_l <= rx_l <= pim_r) or (pim_l <= rx_r <= pim_r):
                        lcr_id_list_with_pim.append(cell)
                        break
            except (TypeError, ValueError):
                continue
    return lcr_id_list_with_pim


def filter_out_cells_not_affected_by_pim(lcr_id_list, cell_dictionary):
    lcr_id_list = [int(x) for x in lcr_id_list]
    tx_list = _get_cells_tx_list(lcr_id_list, cell_dictionary)
    pim_list = _get_tx_pim_list(tx_list)
    lcr_id_list_with_pim = _get_lcr_id_list_with_pim(lcr_id_list, cell_dictionary, pim_list)
    return lcr_id_list_with_pim
