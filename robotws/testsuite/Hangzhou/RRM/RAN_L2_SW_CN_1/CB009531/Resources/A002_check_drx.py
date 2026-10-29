# encoding=utf-8
from set_pandas import *
pd = None
np = None


def get_No_min_value_No_max_value(csv_file, retrans_value):
    print(csv_file, retrans_value)
    init_pandas()
    df = pd.read_csv(csv_file, low_memory=False)
    df1 = df.copy()
    df1.dropna(subset=["dci.dci11.HARQ_ProcessNumber"], inplace=True)
    harq_value = df1.loc[df1.index[0], "dci.dci11.HARQ_ProcessNumber"]
    print("First HARQ_value:", harq_value)
    df2 = df[(df["dci.dci11.HARQ_ProcessNumber"] == harq_value)]
    small_dfs = np.split(df2, range(retrans_value+1, len(df2), retrans_value+1))
    small_dfs = small_dfs[0].reset_index(drop=True)

    No_min_value = small_dfs.loc[0, "_ws.col.No."]
    No_max_value = small_dfs.loc[retrans_value, "_ws.col.No."]
    return df, small_dfs, No_min_value, No_max_value


def check_retrans_outside_inactivity_timer(csv_file, retrans_value, ul_dciSize):
    a = get_No_min_value_No_max_value(csv_file, retrans_value)
    df4 = a[0][(a[0]["DlData_DciInfo.dciSize"] == ul_dciSize)]
    df4 = df4.reset_index(drop=True)
    count = 0
    j = 0
    for i in range(df4.index.max()-1):
        if df4.iloc[i]['_ws.col.No.'] >= a[2] and df4.iloc[i]['_ws.col.No.'] <= a[3]:
            count += 1
            j = i
    if count >= 1:
        inactive_sfn = df4.iloc[j]['3gpp.sfn'] + 4
        inactive_slot = df4.iloc[j]['3gpp.slot']
    else:
        inactive_sfn = a[1].loc[0, '3gpp.sfn']+4
        inactive_slot = a[1].loc[0, '3gpp.slot']
    print("info:inactivityTimer endwindow sfn and slot :", inactive_sfn, inactive_slot)
    last_retrans_sfn = a[1].loc[retrans_value, '3gpp.sfn']
    last_retrans_slot = a[1].loc[retrans_value, '3gpp.slot']
    print("info:last_retrans sfn and slot :", last_retrans_sfn, last_retrans_slot)
    if last_retrans_sfn > inactive_sfn:
        print("info:trigger,retrans outside inactivity")
    elif last_retrans_sfn == inactive_sfn and last_retrans_slot > inactive_slot:
        print("info:trigger,retrans outside inactivity")
    # else:
    #     print("not trigger,retrans inside inactivity")


def check_TBS_Rank_symbols(csv_file, retrans_value):
    b = get_No_min_value_No_max_value(csv_file, retrans_value)
    count = 0
    for i in range(1, retrans_value+1):
        if b[1].loc[0, "dci.dci11.FrequencyDomainResourceAssignment"] == \
                b[1].loc[i, "dci.dci11.FrequencyDomainResourceAssignment"] and \
                b[1].loc[0, "dci.dci11.TimeDomainResourceAssignment"] ==\
                b[1].loc[i, "dci.dci11.TimeDomainResourceAssignment"] and b[1].loc[0, "dci.dci11.MCS_TB1"] \
                == b[1].loc[i, "dci.dci11.MCS_TB1"]:
            count += 1
    print("info:count value", count)
    if count == retrans_value:
        print("info: retrans same TBS Rank symbols with initial")
    # else:
    #     print("info:error, retrans different TBS Rank symbols with initial")


if __name__ == '__main__':
    check_retrans_outside_inactivity_timer("5GBipL2L1_filtering_off.csv", 7, 42.0)
    # check_TBS_Rank_symbols("5GBipL2L1_filtering_off.csv", 7)
    # get_No_min_value_No_max_value("5GBipL2L1_filtering_off.csv", 7)
