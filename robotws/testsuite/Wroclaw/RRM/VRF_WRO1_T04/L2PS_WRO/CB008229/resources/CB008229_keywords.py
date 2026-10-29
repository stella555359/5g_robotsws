from robot.api import logger

from robot.libraries.BuiltIn import BuiltIn
import re
import io
import subprocess

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    if direction == 'dl':
        stats_type = 'pdsch'
    else:
        stats_type = 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type={} scell={}'
                                                                       .format(ue_id, stats_type, cc),
                                                                       pass_regexp='UE-{}: NR {} Throughput'
                                                                       .format(ue_id, stats_type.upper()))


def get_max_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    max_tput = pattern.findall(ue_stats)[-2][0]
    return float(max_tput)


def avg_prb_for_cell_dl(file_path, cell_id):
    try:
        import pandas as pd
    except ImportError:
        subprocess.run(['pip', 'install', 'pandas'])
        import pandas as pd

    df = pd.read_csv(f'{file_path}.csv', sep=',')
    df['dlTdSchedSubcellData.numAllocCellPrbDl'] = pd.to_numeric(
        df['dlTdSchedSubcellData.numAllocCellPrbDl'],
        errors='coerce'
    )
    df = df[df['dlTdSchedSubcellData.numAllocCellPrbDl'].notna()]
    df['dlTdSchedSubcellData.numAllocCellPrbDl'] = df['dlTdSchedSubcellData.numAllocCellPrbDl'].astype(int)
    filtered_df = df[df['physCellId'] == int(cell_id)]

    filtered_df.to_csv(f'{file_path}_cellid_{cell_id}.csv', sep=';', index=False)

    average_value = filtered_df['dlTdSchedSubcellData.numAllocCellPrbDl'].mean(skipna=True)

    if average_value == 133:
        raise ValueError("Average PRB allocated is equal to max")

    return average_value


def avg_prb_for_cell_ul(file_path, cell_id):
    try:
        import pandas as pd
    except ImportError:
        subprocess.run(['pip', 'install', 'pandas'])
        import pandas as pd

    df = pd.read_csv(f'{file_path}.csv', sep=',')
    df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'] = pd.to_numeric(
        df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'],
        errors='coerce'
    )
    df = df[df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'].notna()]
    df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'] = \
        df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'].astype(int)
    filtered_df = df[df['physCellId'] == int(cell_id)]

    filtered_df.to_csv(f'{file_path}_cellid_{cell_id}.csv', sep=';', index=False)

    average_value = filtered_df['ulAllocatedPooledResourcesData.numAllocCellPrbUl'].mean(skipna=True)

    if average_value == 133:
        raise ValueError("Average PRB allocated is equal to max")

    return average_value
