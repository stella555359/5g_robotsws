import logging
import numpy
import pandas


def clean_data_rate_data(row):
    for index, entry in enumerate(row):
        try:
            row.iloc[index] = int(entry.split(' ')[0])
        except AttributeError as e:
            logging.warning('defective data value found')
    return row


def clean_data_rate_for_df(df):
    selected_index_names = ['Absolute max data rate', 'Absolute min data rate',
                            'Maximum data rate', 'Minimum data rate',
                            'Average data rate', 'Last data rate']
    df.loc[selected_index_names] = df.loc[selected_index_names].apply(clean_data_rate_data, axis=1)
    return df


def remove_non_esential_data(df, rows_to_keep):
    return df.loc[rows_to_keep]


def calculate_statistics_for_all_ues(df, data_point='Last data rate'):
    ue_dfs = {}
    ue_statistics = {}
    for ue in df.columns.get_level_values(1):
        ue_dfs.update({ue: df.loc[:, (slice(None), ue)]})
        ue_dfs[ue] = clean_data_rate_for_df(ue_dfs[ue])
        ue_statistics.update({ue: get_statistics_for_df(ue_dfs[ue], data_point)})
    return ue_statistics, pandas.DataFrame(ue_statistics)


def get_statistics_for_df(df, row_name):
    stats = {}
    stats.update({'avg': numpy.average(df.loc[row_name])})
    stats.update({'min': numpy.min(df.loc[row_name])})
    stats.update({'max': numpy.max(df.loc[row_name])})
    stats.update({'std': numpy.nanstd(df.loc[row_name])})
    stats.update({'var': numpy.var(df.loc[row_name])})
    stats.update({'median': numpy.median(df.loc[row_name])})
    return stats
