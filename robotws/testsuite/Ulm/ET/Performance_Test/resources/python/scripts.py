
import traceback
import re
import sys
import logging

from robot.libraries.BuiltIn import BuiltIn

logger = logging.getLogger()


def is_cell_included_in_distname(dn, active_cells):
    if active_cells in ['all', ['all']]:
        logger.debug("    all cells active (%s): %s", active_cells, dn)
        return True
    if 'NRCELL' in str(dn).upper():
        if re.findall('.*NRCELL-([0-9]+).*', dn)[0] in [str(x) for x in active_cells]:
            return True
        logger.debug("    skip cell: %s", dn)
        return False
    logger.debug("    nrcell not found: %s", dn)
    return False


def convert_pmc_tput_to_rate(tput: int, interval: int = 300, rate: str = 'mbps'):
    '''
    tput - pmcounter value (from: M55326C00501, M55326C00502, ...etc)
    interval - pm counter interval
    '''
    bytes_to_bits_conversion_factor = 8
    return round(((int(tput) / int(interval)) * mb_conversion_factor[rate] * bytes_to_bits_conversion_factor), 2)


def get_tput_from_ue_stats(ue_stats_str):
    '''
    ue_stats_str
        result of egate command
            ue_stats_nr id=${index} scell=${scell} type=${dir} size_unit=bytes
    Return
        0 - Current
        1 - Minimum
        2 - Maximum
        3 - Average
    '''
    # ue_stats_nr id=${index} scell=${scell} type=${dir} size_unit=bytes
    # CellIndex    Current    Minimum    Maximum    Average
    # CellIndex-0  17.9 Mbps  17.9 Mbps  19.3 Mbps  18.6 Mbps
    #     0          1   2     3    4     5    6      7   8
    try:
        total_mbps = [0, 0, 0, 0]
        cells = [line for line in ue_stats_str.split('\n') if "CellIndex-" in line]
        for cell in cells:
            perma_shift = 0
            for i in range(0, 4):
                column_index = (i*2)+1-perma_shift
                columns = cell.split()
                tput = float(columns[column_index].strip())
                rate = columns[column_index+1].strip()
                if rate.isnumeric():
                    rate = 'bps'
                    perma_shift = perma_shift+1
                mbps_tput = round(tput * tput_convertion_table[rate], 2)
                total_mbps[i] = total_mbps[i] + mbps_tput
    except Exception as e:
        print(f"{e}\n {traceback.format_exc()}")
        return total_mbps
    return total_mbps


def get_expected_pmcounter_value_with_max_ue_per_cell_and_per_cell_throughput(args, dir, interval=300):
    logger.debug("========= start: get_expected_pmcounter_value_with_max_ue_per_cell_and_per_cell_throughput =========")
    try:
        _sum = 0
        for cell_index in range(0, args['num_cells']):
            throughput = args[f'expected_{dir}_cell_tput'][cell_index]
            logger.debug("         throughput: %s", throughput)
            logger.debug("         cell: %s", cell_index + 1)
            _sum = _sum + convert_rate_to_expected_pmcounter_value(
                throughput,
                1,  # because UE count is already calculated in cell throughput,
                interval=interval,
                tolerance=args['tolerance'],
                rate=args['rate']
            )
            logger.debug("         sum: %s", _sum)
        return _sum
    except Exception as e:
        logger.warning("%s\n %s", e, traceback.format_exc())
        return sys.maxsize


def convert_rate_to_expected_pmcounter_value(tput, total_ue=1, interval=300, tolerance=.05, rate='mbps'):
    tput = float(tput)
    interval = int(interval)
    total_ue = int(total_ue)
    tolerance = float(tolerance)
    bytes_to_bits_conversion_factor = 8
    convertion_factor = (
        mb_conversion_factor[rate] * bytes_to_bits_conversion_factor)
    actual_tput = (tput * interval * total_ue) / convertion_factor
    tput_tolerance = actual_tput * tolerance
    return int(actual_tput - tput_tolerance)


# #### private #####
mb_conversion_factor = {'gbps': .000001,
                        'mbps': .001, 'kbps': 1, 'bps': 10000}

tput_convertion_table = {
    'Gbps': 1000,
    'Mbps': 1,
    'Kbps': .001,
    'bps': .000001,
}


def get_ues_in_cells(active_cells: str, num_ues_per_cell: int, total_cells: int):
    cell_ue_dictionary = get_dict_for_cells(num_ues_per_cell, total_cells)
    active_cells_list = [int(x) for x in active_cells]
    cell_ue_dictionary = {}
    for cell, ues in cell_ue_dictionary.items():
        if int(cell) in active_cells_list:
            cell_ue_dictionary.update({
                str(cell): ues
            })
    return cell_ue_dictionary


def get_dict_for_cells(num_ues_per_cell, total_cells):
    cell_dict = {cell: [] for cell in range(1, total_cells)}
    for i in range(num_ues_per_cell):
        for cell in cell_dict.keys():
            cell_dict[cell].append(cell + i*total_cells)
    return cell_dict


def get_active_ues_comma_separated(chunk_size: int, cell_ue_mapping: list[list]):
    all_active_ues = []
    for cell in cell_ue_mapping:
        all_active_ues.extend(cell)
    all_active_ues = [str(ue) for ue in all_active_ues]
    num_chunks = len(all_active_ues)//chunk_size
    num_chunks += 1 if len(all_active_ues) % chunk_size != 0 else 0
    output_list: list[str] = []
    for chunk in range(num_chunks):
        output_list.append(
            ','.join(all_active_ues[chunk*chunk_size:(chunk+1)*chunk_size]))
    return output_list


def try_round(num, *args, default=None, **kwargs):
    return round(num, *args, **kwargs) if num is not None else default
