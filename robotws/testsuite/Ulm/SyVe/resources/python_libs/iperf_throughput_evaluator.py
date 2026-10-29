import re
import logging

logging.basicConfig(level=logging.DEBUG)

exponents = {'K': 10 ** 3, 'M': 10 ** 6, 'G': 10 ** 9}


def convert_to_bps(bw, bw_unit):
    return float(bw) * float(exponents[bw_unit])


def convert_to_desired_unit(bw_in_bps, desired_unit):
    return float(bw_in_bps)/float(exponents[desired_unit])


def extract_data_compute_average(file_name):
    """Author : Srihari Janardhan  |  Description : Extracts Bandwidth, Interval and ID from the iperf server file as
    defined by the regular expression and creates a dictionary with interval end time as the key and associated
    attributes as value in the form of a dictionary.
    Attributes have keys ID and BW for ID and Bandwidth respectively"""
    pattern_throughput_string = re.compile(r'\[(.+)\]\s+(\d+\.\d+)\-\s*(\d+\.\d+).+\s+(\d+\.\d+|\d+)\s([MKG])bits/sec')
    dict_time_throughput = {}
    with open(file_name, 'rb') as file_:
        for line in file_:
            try:
                line = line.decode('utf-8')
                logging.debug("Evaluating string: %s" % line)
                matches_throughput_string = (pattern_throughput_string.search(line))
                extracted_data = matches_throughput_string.groups()
                stream_number = extracted_data[0]
                interval_start = extracted_data[1]
                interval_end = extracted_data[2]
                bw = extracted_data[3]
                bw_unit = extracted_data[4]
                bw_bps = convert_to_bps(bw, bw_unit)
                key = str(interval_start)+"-"+str(interval_end)
                dict_time_throughput[key] = {"Stream_Number": stream_number, "Interval_Start": interval_start,
                                             "Interval_end": interval_end, "BW": bw, "BW_Unit": bw_unit,
                                             "BW_BPS": bw_bps}
            except AttributeError:
                logging.debug("This line did not match Regex check for iperf server logs: %s" % line)
    return dict_time_throughput


def compute_average(file_name, analysis_start=0, analysis_end=0, desired_unit='M'):
    """Author : Srihari Janardhan   |  Description : This function is called from robot, to compute the average
    throughput for a given iperf server log. If the parameters analysis_start and analysis_end are not provided then
    the average throughput is computed over the complete log file. If the aforementioned values are passed then
    the average is computed only for the mentioned time interval.

    In the case where the average of the entire log file is require The function tries to retrieve the average
    computed by the iperf tool, else a python function is called to compute the average"""
    desired_unit_expanded = {'M': 'Mbps', 'K': 'Kbps', 'G': 'Gbps'}
    iperf_parsed_data = extract_data_compute_average(file_name)
    average_bps = average_calculator(iperf_parsed_data, analysis_start, analysis_end)
    computed_average = convert_to_desired_unit(average_bps, desired_unit)
    logging.info("Computed Average Throughput %s %s" % (computed_average, desired_unit_expanded[desired_unit]))
    return computed_average


def average_calculator(iperf_parsed_data, analysis_start=0, analysis_end=0):
    average_bps = 0.0
    throughput = []
    if analysis_start > analysis_end:
        logging.error("Invalid Time Range defined in analysis_start and analysis_end, value of analysis_end should be "
                      "greater than that of analysis_start")
        return average_bps
    elif analysis_end > analysis_start:
        """Check for total time period present in iperf logs"""
        for item in iperf_parsed_data.values():
            try:
                if float(item["Interval_Start"]) >= analysis_start and float(item["Interval_end"]) <= analysis_end:
                    throughput.append(float(item['BW_BPS']))
                else:
                    logging.debug("Time interval defined is not found in iPerf logs")
                average_bps = sum(throughput) / float(int(analysis_end) - int(analysis_start))
            except KeyError:
                logging.debug("Time interval defined is not found in iPerf logs")
    elif analysis_start == analysis_end == 0:
        """Find time range"""
        start_times = []
        end_times = []
        for item in iperf_parsed_data.values():
            start_times.append(float(item["Interval_Start"]))
            end_times.append(float(item["Interval_end"]))
        try:
            start_time = min(start_times)
            end_time = max(end_times)
            key_iperf_computed_average = str(start_time) + "-" + str(end_time)
            try:
                average_bps = iperf_parsed_data[key_iperf_computed_average]['BW_BPS']
            except KeyError:
                logging.debug("Iperf computed average not present. Running average through parsed file contents")
                for item in iperf_parsed_data.values():
                    throughput.append(float(item['BW_BPS']))
                average_bps = sum(throughput)/len(iperf_parsed_data.values())
        except ValueError:
            if len(start_times) == 0 and len(end_times) == 0:
                logging.debug("Iperf logs are empty, please check if traffic is working on your Testline")
            else:
                logging.debug("Unknown error please contact script developer")
            return 0
    return average_bps


def verdict_generator(expected_throughput, actual_throughput, allowed_variance):
    """Author : Srihari Janardhan  |  Description : Generates a pass or a fail based on the permitted variance"""
    variance = (float(int(allowed_variance)) / 100.0) * float(expected_throughput)
    logging.info("The allowed variance is %s " % variance)
    max_expected_throughput_with_variance = float(expected_throughput) + variance
    min_expected_throughput_with_variance = float(expected_throughput) - variance
    logging.info("The expected throughput should range from %s - %s " % (min_expected_throughput_with_variance,
                                                                         max_expected_throughput_with_variance))
    if max_expected_throughput_with_variance >= float(actual_throughput) >= min_expected_throughput_with_variance:
        return "Pass"
    else:
        return "Fail"


""" For Local Test and debug use only """
if __name__ == "__main__":
    file_name = "/mnt/etlogs/logs/7_15_UTE5GCLASSICAL118/5GC001095-B/5G_0.800.944/20200624_091743/" \
                "[1]5GC001095_B_Successful_Intra-DU_PSCell_change_Without_SRB3_Classical/" \
                "dl_ue0_mue0_bearer1_server.log"
    average_throughput = compute_average(file_name, analysis_start=0, analysis_end=0, desired_unit='K')
    print(average_throughput)
    result = verdict_generator(expected_throughput=700, actual_throughput=average_throughput, allowed_variance=10)
    print(result)
