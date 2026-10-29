import pandas as pd


def get_tp_dict(path_to_pickle):
    df = pd.read_pickle(path_to_pickle)
    if len(df) == 0:
        return {}
    groupby = df.groupby(['UE', 'Direction'])
    ue_tp_dict = {}
    for ue, data in list(groupby[['Absolute max data rate']]):
        try:
            ue_tp_dict[ue[0]].update({ue[1]: max(data['Absolute max data rate']) / 10**6})
        except KeyError:
            ue_tp_dict.update({ue[0]: {ue[1]: max(data['Absolute max data rate']) / 10**6}})
    return ue_tp_dict


if __name__ == '__main__':
    print(get_tp_dict())
