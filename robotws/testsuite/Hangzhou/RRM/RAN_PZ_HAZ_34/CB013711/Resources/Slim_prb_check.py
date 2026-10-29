import csv
# calc total prb nums per slot for this PY
# x_counter is the Maximum_scheduled_prb
# y_counter for Maximum_PRB_abnormal_times
# csv_filename tti file
# cellid_checked is the cell to be checked


def check_the_slim_prb_perslot(csv_filename, cellid_checked, x_counter, y_counter):
    try:
        cellid_checked = int(float(cellid_checked))
        x_counter = int(float(x_counter))
        y_counter = int(float(y_counter))
    except ValueError:
        raise ValueError("cellid_checked x_counter and y_counter must be numeric values")
    Maximum_scheduled_prb = 0
    Maximum_PRB_abnormal_times = 0
    Start_PRB_abnormal = 0
    segment_id = 1
    with open(csv_filename) as csvfile:
        list_reader = list(csv.DictReader(csvfile))
    total_rows = len(list_reader)
    st_check_index = 0
    while st_check_index < total_rows:
        start_index = None
        init_mu_slot = None
        # find the start slot point
        for idx in range(st_check_index, total_rows):
            row = list_reader[idx]
            if row['lcrId'].strip() == str(cellid_checked) and row['dlFdSchedData.numOfPrb'].strip():
                start_index = idx
                init_mu_slot = row['slot']
                break
        if start_index is None:
            break  # not fine ,breakout
        # find the end point of current slot (next time slot is diff)
        end_index = total_rows
        for idx in range(start_index + 1, total_rows):
            if list_reader[idx]['slot'] != init_mu_slot:
                end_index = idx
                break
        # 统计这个 slot 段的 PRB 总和
        total_prb_this_slot = 0
        start_prb_fail_counter = 0
        for idx in range(start_index, end_index):
            row = list_reader[idx]
            if row['lcrId'].strip() != str(cellid_checked):
                continue
            prb_str = row['dlFdSchedData.numOfPrb']
            if prb_str.strip():
                try:
                    prb = int(float(prb_str))
                    total_prb_this_slot += prb
                except ValueError:
                    continue
            prb_start = row['dlFdSchedData.startPrb']
            if prb_start.strip():
                try:
                    prb_start1 = int(float(prb_start))
                    if prb_start1 < y_counter:
                        start_prb_fail_counter += 1
                except ValueError:
                    continue
        # print(f"[Segment {segment_id}] Slot {init_mu_slot} → Total PRB: {total_prb_this_slot}")     #debug
        # print(f"[Segment {segment_id}] Slot {init_mu_slot} → prb_start1: {prb_start1}")  # debug
        # print(f"[Segment {segment_id}] Slot {init_mu_slot} → start_prb_fail: {start_prb_fail_counter}")  # debug
        segment_id += 1
        st_check_index = end_index  # move to next slot
        if total_prb_this_slot == x_counter:
            Maximum_scheduled_prb += 1
        if total_prb_this_slot > x_counter:
            Maximum_PRB_abnormal_times += 1
        if start_prb_fail_counter > 0:
            Start_PRB_abnormal += 1
    print(f"Maximum_scheduled_prb (== {x_counter}): {Maximum_scheduled_prb}")
    print(f"Maximum_PRB_abnormal_times (> {x_counter}): {Maximum_PRB_abnormal_times}")
    print(f"Start_PRB_abnormal (startPrb < {y_counter}): {Start_PRB_abnormal}")
    if Maximum_PRB_abnormal_times > 0:
        # print(f"Maximum_PRB_abnormal_times is {Maximum_PRB_abnormal_times} ")
        raise Exception('FAIL: PRB exceeds max upper bound')
    if Maximum_scheduled_prb >= 800:
        # print(f"Maximum_scheduled_prb is {x_counter} ")
        print("PASS: PRB reached max target 800+ times")
        return True
    if Start_PRB_abnormal > 0:
        # print(f"Start_PRB_abnormal is {Start_PRB_abnormal} ")
        raise Exception('FAIL: startPrb is too low in some segments')


# if __name__ == "__main__":
#     result = check_the_slim_prb_perslot(r"C:\Users\l3gao\1_logs\tti_slim_enable_dl.csv", 700,233,6)
#     print(f"Result: {result}")
