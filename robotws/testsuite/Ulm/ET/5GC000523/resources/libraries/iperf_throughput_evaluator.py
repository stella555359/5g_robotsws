import re


def compute_average(file_name):
    _file = open(file_name)
    contents = _file.readlines()
    start_track = False
    multi_streams = False
    interval = 0
    totalthroughput = 0

    for line in contents:
        if "SUM" in line:
            multi_streams = True
            break

    for line in contents:
        throughput = 0
        if "Interval" in line:
            start_track = True
        if start_track:
            bw = re.split(' Mbits/sec', line)
            if "SUM" in line and multi_streams:
                interval += 1
                throughput = float(bw[0][-3:])
            elif not multi_streams:
                try:
                    throughput = float(bw[0][-4:])
                    interval += 1
                except ValueError:
                    pass

        totalthroughput += throughput
    average_throughput = float(totalthroughput) / float(interval)
    return int(average_throughput)


def verdict_generator(expected_throughput, actual_throughput, allowed_variance):
    variance = int((float(int(allowed_variance)) / 100) * int(expected_throughput))

    max_expected_throughput_with_variance = int(expected_throughput) + variance
    min_expected_throughput_with_variance = int(expected_throughput) - variance

    if max_expected_throughput_with_variance >= actual_throughput > min_expected_throughput_with_variance:
        return "Pass"
    else:
        return "Fail"


if __name__ == "__main__":
    file_name = "D:/userdata/srjanard/Desktop/Test_iPerf/ue0_iperf_serv_DL.log"
    average_throughput = compute_average(file_name)
    verdict = verdict_generator(expected_throughput="250", actual_throughput=average_throughput, allowed_variance="10")
    print(average_throughput, verdict)
