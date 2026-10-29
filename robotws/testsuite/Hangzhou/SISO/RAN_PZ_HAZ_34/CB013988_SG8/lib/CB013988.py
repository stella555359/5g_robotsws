def get_counter_value(counter_list):
    POOR_Reset_Counter = 0
    BTS_POOR_Reset_Counter = 0
    Reset_Counter = 0
    for item in counter_list:
        print(item)
        if item.startswith('POOR Reset Counter'):
            POOR_Reset_Counter = int(item.split(":")[1].strip())
        elif item.startswith('BTS POOR Reset Counter'):
            BTS_POOR_Reset_Counter = int(item.split(":")[1].strip())
        elif item.startswith('Reset Counter'):
            Reset_Counter = int(item.split(":")[1].strip())
    return POOR_Reset_Counter, BTS_POOR_Reset_Counter, Reset_Counter


def get_poor_reset_last_write_ISTI(counter_list):
    last_write_ISTI = 0.0
    length = len(counter_list)
    for i in range(length):
        if counter_list[i].startswith('Item type: POOR_reset'):
            if i + 2 < length and counter_list[i + 2].startswith('Last write ISTI:'):
                last_write_ISTI = float(counter_list[i + 2].split(":")[1].strip())
                break
    return last_write_ISTI


def get_reset_0_ISTI(counter_list):
    reset_0_ISTI = 0.0
    for item in counter_list:
        if item.startswith('Reset[0] ISTI:'):
            reset_0_ISTI = float(item.split(":")[1].strip())
            break
    return reset_0_ISTI
