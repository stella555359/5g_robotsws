def check_counters_values(values):
    counter_c0 = []
    counter_c1 = []
    for i in range(1, 4):
        counter_c0.append(int(list(list(list(values[-i*2].values())[0].values())[0].values())[0]))
        counter_c1.append(int(list(list(list(values[-i*2+1].values())[0].values())[0].values())[0]))

    print(counter_c1)
    print(counter_c0)

    if abs(max(counter_c1)*8 - (1100000000*300))/(max(counter_c1)*8) < 0.05:
        return True

    return False


def check_M51301C5(values):
    counter = []
    for i in range(1, 4):
        counter.append(int(list(list(list(values[-i].values())[0].values())[0].values())[0]))

    print(counter)
    if sum(counter) == 0:
        return True
    return False
