import re
from set_pandas import *
pd = None
np = None


def check_sfn_slot_in_ap_syslog(s, csv_file, retrans_value):
    init_pandas()
    fi = open(s, "r")
    for line in fi:
        pattern = r"(.*)<(.*):(.*:.*)>(.*)Slot=\[Sfn\/Slot\/Gran\(NbCycle\)=(.*)/(.*)/.*"
        result = re.search(pattern, line)
        sfn = result.group(5)
        slot = result.group(6)
        df = pd.read_csv(csv_file, low_memory=False)
        df2 = df[(df["3gpp.sfn"] == int(sfn)) & (df["3gpp.slot"] == int(slot))]
        if len(df2) >= 1:
            p = df2.loc[df2.index[0], "dci.dci11.HARQ_ProcessNumber"]
            n = df2.loc[df2.index[0], "_ws.col.No."]
            FDRA = df2.loc[df2.index[0],
                           "dci.dci11.FrequencyDomainResourceAssignment"]
            TDRA = df2.loc[df2.index[0],
                           "dci.dci11.TimeDomainResourceAssignment"]
            MCS = df2.loc[df2.index[0], "dci.dci11.MCS_TB1"]
            print('sfn slot:{0}/{1}, HARQ_ProcessNumber:{2}, col_num:{3}'.format(sfn, slot, p, n))

            df3 = df[df["dci.dci11.HARQ_ProcessNumber"] == p]
            df3 = df3.reset_index(drop=True)
            list = []
            count = 0
            for i in range(df3.index.max()):
                col_No = df3.loc[i, "_ws.col.No."]
                if col_No in range(n-200, n+200):
                    list.append(col_No)
                    if df3.loc[i, "dci.dci11.FrequencyDomainResourceAssignment"] == FDRA \
                            and df3.loc[i, "dci.dci11.TimeDomainResourceAssignment"] == TDRA \
                            and df3.loc[i, "dci.dci11.MCS_TB1"] == MCS:
                        count += 1
            if count == retrans_value:
                break
    print('count value:{0}, reTrans col No:{1}'.format(count, list))
    df_ack = df.copy()
    df_ack = df_ack.reset_index(drop=False)
    req_index = df_ack[df_ack["_ws.col.No."] == list[-1]].index
    ack_data = df_ack.loc[df_ack.index[req_index[0]+1], "data.data"]
    print(int(ack_data))
    return count, int(ack_data)


if __name__ == '__main__':
    check_sfn_slot_in_ap_syslog("text.txt", "5GBipL2L1_filtering_off.csv", 7)
