def compare_throughputs(tputs_a, tputs_b, margin=1):
    return len(tputs_a) == len(tputs_b) == len([b for a, b in zip(tputs_a, tputs_b) if b >= a * (float(margin))])
