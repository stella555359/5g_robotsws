def calculate_avg_list(param):
    nsum = 0
    param = list(map(int, param))
    for i in param:
        nsum += i
    return nsum / len(param)
