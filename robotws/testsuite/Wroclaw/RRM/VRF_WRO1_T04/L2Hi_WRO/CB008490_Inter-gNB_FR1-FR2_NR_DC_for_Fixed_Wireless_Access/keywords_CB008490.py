from robot.libraries.BuiltIn import BuiltIn
import ute_syslog
import csv
from robot.errors import ExecutionFailed
from robot.api import logger


def apply_testlines_variables(testline):
    testline_ips = [test_pc.default_ssh_connection_details.addr for test_pc in testline.test_pcs[1:]]
    BuiltIn().set_suite_variable('@{REMOTE_HOSTS}', *testline_ips)

    for idx, ip in enumerate(testline_ips, start=1):
        BuiltIn().set_suite_variable('${REMOTE_HOST_' + str(idx) + '_IP}', ip)


def start_syslog_on_second_gnb(log_dir, log_name, remote_ip):
    syslog = ute_syslog.ute_syslog()
    syslog.start_syslog(
            log_dir=log_dir,
            log_name=log_name,
            ip=remote_ip[0],
            alias='second_gnb'
        )


def find_packet_lost_in_csv(csv_file_path, packet_lost_and_retransmited):
    try:
        with open(csv_file_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            for row_idx, row in enumerate(reader):
                for col_idx, value in enumerate(row):
                    if packet_lost_and_retransmited in value:
                        parts = value.split(';')
                        if len(parts) >= 4:
                            start_of_lost_range = parts[2]
                            end_of_lost_range = parts[3]
                            print(f"StartOfLostRange: {start_of_lost_range}")
                            print(f"EndOfLostRange: {end_of_lost_range}")
                            return start_of_lost_range, end_of_lost_range
                        else:
                            logger.console(
                                "The found value does not contain enough parts to extract the required values.")
                            raise ExecutionFailed(message="The found value does not contain enough "
                                                  "parts to extract the required values.", continue_on_failure=False)
        logger.console("Packet lost and retransmitted value not found in file.")
        raise ExecutionFailed(message="Packet lost and retransmitted value not found in file.",
                              continue_on_failure=False)
    except FileNotFoundError:
        logger.console("The specified CSV file does not exist.")
        raise ExecutionFailed(message="The specified CSV file does not exist.", continue_on_failure=False)


def find_tpdu_data_in_csv(csv_file_path):
    packet_lost_and_retransmited = '1;1'

    result = find_packet_lost_in_csv(csv_file_path, packet_lost_and_retransmited)
    if result is None:
        logger.console("Packet lost and retransmitted value not found in file.")
        raise ExecutionFailed(message="{} not found in CSV file.}".format(packet_lost_and_retransmited),
                              continue_on_failure=False)

    start_of_lost_range, _ = result
    start_of_lost_range_base = int(start_of_lost_range)

    tpdu_values = []

    for i in range(5):
        current_start_of_lost_range = start_of_lost_range_base + i
        start_of_lost_range2 = ';;;' + str(current_start_of_lost_range)

        with open(csv_file_path, mode='r', newline='', encoding='utf-8') as file:
            reader = csv.reader(file)

            for row in reader:
                if row and start_of_lost_range2 in row[0]:
                    parts = row[0].split(start_of_lost_range2, 1)
                    if len(parts) > 1:
                        remaining = parts[1].split(';', 1)
                        if len(remaining) > 1:
                            tpdu_value = remaining[1][:82]
                            tpdu_values.append(tpdu_value)
                            print(f"Lost Sequence Number: {current_start_of_lost_range} with Tpdu data: {tpdu_value}")
                            break
            else:
                logger.console("No Packet Lost with SN: {} found.".format(result))
                raise ExecutionFailed(message="No Packet Lost with SN: {} found.".format(result),
                                      continue_on_failure=False)

    return tpdu_values


def count_tpdu_repetitions(csv_file_path, tpdu_values):
    tpdu_counts = {tpdu: 0 for tpdu in tpdu_values}

    with open(csv_file_path, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)

        for row in reader:
            for tpdu in tpdu_values:
                if tpdu in row[0]:
                    tpdu_counts[tpdu] += 1

    return tpdu_counts


def check_tpdu_data_reps_for_sequence_numbers(csv_file_path):
    tpdu_values = find_tpdu_data_in_csv(csv_file_path)
    tpdu_counts = count_tpdu_repetitions(csv_file_path, tpdu_values)

    passed_tpdu = []
    failed_tpdu = []

    for tpdu, count in tpdu_counts.items():
        if count < 2:
            failed_tpdu.append(tpdu)
        else:
            passed_tpdu.append(tpdu)

    if failed_tpdu:
        raise ExecutionFailed(message="TPDU data missing retransmission for one of the sequence numbers.",
                              continue_on_failure=True)
    elif passed_tpdu:
        print(f"All packets lost with sequence numbers above have been retransmitted successfully")


def check_for_no_pdcp_duplications(csv_file, column_name):
    try:
        with open(csv_file, mode='r', newline='') as file:
            csv_reader = csv.reader(file)
            header = next(csv_reader)
            if column_name not in header:
                return False
            column_index = header.index(column_name)
            for row in csv_reader:
                if len(row) > column_index and row[column_index].strip():
                    print("{} have values.".format(column_name))
                    raise ExecutionFailed(message="TPDU data missing retransmission for one of the sequence numbers.",
                                          continue_on_failure=True)
        print("{} have no values.".format(column_name))
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        return False


def remove_duplicates(file_path, column_name, output_path, encoding='latin1'):
    with open(file_path, mode='r', newline='', encoding=encoding) as infile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames
        if column_name not in fieldnames:
            raise ValueError(f"Column '{column_name}' does not exist in the CSV file.")
        seen = set()
        unique_rows = []
        for row in reader:
            value = row[column_name]
            if value not in seen:
                seen.add(value)
                unique_rows.append(row)
    with open(output_path, mode='w', newline='', encoding=encoding) as outfile:
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(unique_rows)

    print("Duplicates removed and cleaned file saved as:", output_path)
    return output_path


def check_for_pdcp_duplications(file_path, column_name, output_file_path, growth_threshold=200, encoding='latin1'):
    output_path = remove_duplicates(file_path, column_name, output_file_path)
    with open(output_path, mode='r', newline='',  encoding=encoding) as infile:
        reader = csv.DictReader(infile)
        previous_value = None
        for row in reader:
            current_value = int(row[column_name])
            if previous_value is not None:
                if current_value - previous_value < growth_threshold:
                    print(f"Growth check failed: {current_value} - {previous_value} < {growth_threshold}")
                    raise ExecutionFailed(message=f"Growth check failed: {current_value} - {previous_value} "
                                                  f"< {growth_threshold}", continue_on_failure=True)
            previous_value = current_value

    print(f"All values in column '{column_name}' are growing by at least {growth_threshold}.")
    return True


def check_for_dud_retx(file_path):
    count = 0
    with open(file_path, newline='') as csvfile:
        csvreader = csv.reader(csvfile)
        for row in csvreader:
            if row[0] == '1':
                count += 1
    if count > 1000:
        return f"Number of DUD retransmissions is: {count}"
    else:
        raise ExecutionFailed(message=f"Number of DUD retransmissions is insufficient: {count}",
                              continue_on_failure=True)


testline = BuiltIn().get_variable_value('${tl}')
apply_testlines_variables(testline)

UE_CAPA_PDCCH_BLIND_DETECTION_CA_5_WITHOUT_NRDC = 'E7A05000574F7E03560803C3A000B0400406' \
    '02441800260E12006241A0130080C450' \
    '18053380A546C4DD608C21A0810748340145B2A8A84873E819F604F8C73E618F28581C0E1E02FFF' \
    'FFE003FFFFF800507C00D608C21A081078' \
    '8340125B2A8A82873E819F18E7CC31E50B0381C3C09FFF000007FFC00000A0F88' \
    '3AC1184341020F1068024B65515050E7D033E31CF9863CA1' \
    '6070387813FB000000FEC00000540B41378E3087000A8F3F1434011FB660AA4007' \
    '8F0021C4106115028FDFC81B8DC6168000301D02D01C0DE' \
    '38C21C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F206E3F1C5A0000C' \
    '0540B40378E3087000A8F3F1434011FB660AA40078F002' \
    '1C4106115028FDFC81BAFD71680003000630F134003A00618003FFFFFFFFE20F104' \
    '003A0861800BFFFFFFFFE20F000003A00618007FFFFFFF' \
    'FE00A026C10080002A800EC070E06002030381967C786030303001C0C4082C3818' \
    '0080C0E06597140540D120001120001020047A0BC00F800' \
    'A000C040500703009401C001808084400410B0108004000C5E01802000002494038' \
    '02008020080200802009724A01C0100401004010040100' \
    '4C00200000C03E5056E91B8460C500C100000965250407004010040100401004019' \
    '652504070040100401004010040296525040000C000080' \
    '3D28AAAED4572A28355008202004008080200410100801004010020808040080200' \
    '8010142E40200CA00'

UE_CAPA_PDCCH_BLIND_DETECTION_CA_9_WITHOUT_NRDC = 'E7A05000574F7E03560803C3A000B04004060' \
    '2441800260E12006241A0130080C45' \
    '018053380A546C4DD608C21A0810748340145B2A8A84873E819' \
    'F604F8C73E618F28581C0E1E02FFFFFE003FFFFF800507C00D608C21A081078' \
    '8340125B2A8A82873E819F18E7CC31E50B0381C3C09FFF00000' \
    '7FFC00000A0F883AC1184341020F1068024B65515050E7D033E31CF9863CA16' \
    '070387813FB000000FEC00000540B41378E3087000A8F3F143' \
    '4011FB660AA40078F0021C4106115028FDFC81B8DC6168000301D02D01C0DE38' \
    'C21C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F20' \
    '6E3F1C5A0000C0540B40378E3087000A8F3F1434011FB660AA40078F0021C4' \
    '106115028FDFC81BAFD71680003000630F134003A00618003FF' \
    'FFFFFFE20F104003A0861800BFFFFFFFFE20F000003A00618007FFFFFFFFE00' \
    'A026C10080002A800EC070E06002030381967C786030303001' \
    'C0C4082C38180080C0E06597140540D120001120001020047A0BC00F800A000C' \
    '040500703009401C001808084400410B0108004000D5E0180200' \
    '000249403802008020080200802009724A01C01004010040100401004C0020' \
    '0000C03E5056E91B8460C500C100000965250407004010040100' \
    '401004019652504070040100401004010040296525040000C0000803D28AAA' \
    'ED4572A283550082020040080802004101008010040100208080400802008010142E40200CA00'

UE_CAPA_PDCCH_BLIND_DETECTION_CA_4_WITH_NRDC = 'E7A05000574F7E03560803C' \
    '3A000B040040602441800260E13006241A0005020130080C' \
    '45018053380A546C4DD608C21A0810748340145B2A8A84873E819F604F8C73' \
    'E618F28581C0E1E02FFFFFE003FFFFF800507C00D608C21A08107' \
    '88340125B2A8A82873E819F18E7CC31E50B0381C3C09FFF000007F' \
    'FC00000A0F883AC1184341020F1068024B65515050E7D033E31CF9863CA16' \
    '070387813FB000000FEC00000540B41378E3087000A8F3F1434011' \
    'FB660AA40078F0021C4106115028FDFC81B8DC6168000301D02D01C0DE38C' \
    '21C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F206E' \
    '3F1C5A0000C0540B40378E3087000A8F3F1434011FB660AA40078F0021C410' \
    '6115028FDFC81BAFD71680003000630F134003A00618003FFFFF' \
    'FFFE20F104003A0861800BFFFFFFFFE20F000003A00618007FFFFFFFFE00A02' \
    '6C10080002A800EC070E06002030381967C786030303001C0C4' \
    '082C38180080C0E06597140540D120001120001020047A0BC00F800A000C0405' \
    '00703009401C001808084400410B0108004000C1E0180200000' \
    '249403802008020080200802009724A01C01004010040100401004C00200000C' \
    '03E5056E91B8460C500C100000965250407004010040100401' \
    '004019652504070040100401004010040296525040000C0000803D28AAAED4572' \
    'A283550082020040080802004101008010040100208080400802008010142E40200CA00'

UE_CAPA_PDCCH_BLIND_DETECTION_CA_5_WITH_NRDC = 'E7A05000574F7E03560803C3A000' \
    'B040040602441800260E13006241A0005020130080C4' \
    '5018053380A546C4DD608C21A0810748340145B2A8A84873E819' \
    'F604F8C73E618F28581C0E1E02FFFFFE003FFFFF800507C00D608C21A081078' \
    '8340125B2A8A82873E819F18E7CC31E50B0381C3C09FFF00000' \
    '7FFC00000A0F883AC1184341020F1068024B65515050E7D033E31CF9863CA160' \
    '70387813FB000000FEC00000540B41378E3087000A8F3F1434' \
    '011FB660AA40078F0021C4106115028FDFC81B8DC6168000301D02D01C0DE38C2' \
    '1C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F2' \
    '06E3F1C5A0000C0540B40378E3087000A8F3F1434011FB660AA40078F0021C4106' \
    '115028FDFC81BAFD71680003000630F134003A00618003FFF' \
    'FFFFFE20F104003A0861800BFFFFFFFFE20F000003A00618007FFFFFFFFE00A02' \
    '6C10080002A800EC070E06002030381967C786030303001C0' \
    'C4082C38180080C0E06597140540D120001120001020047A0BC00F800A000C0405' \
    '00703009401C001808084400410B0108004000C5E01802000' \
    '00249403802008020080200802009724A01C01004010040100401004C00200000C' \
    '03E5056E91B8460C500C1000009652504070040100401004' \
    '01004019652504070040100401004010040296525040000C0000803D28AAAED4572' \
    'A283550082020040080802004101008010040100208080400802008010142E40200CA00'

UE_CAPA_WITHOUT_PDCCH_BLIND_DETECTION_CA_AND_NRDC = 'E7A05000574F7E03560803C3A000B040' \
    '040602441800260E12006241A0130080C450' \
    '18053380A546C4DD608C21A0810748340145B2A8A8487' \
    '3E819F604F8C73E618F28581C0E1E02FFFFFE003FFFFF800507C00D608C21A08107883' \
    '40125B2A8A82873E819F18E7CC31E50B0381C3C09FFF000' \
    '007FFC00000A0F883AC1184341020F1068024B65515050E7D033E31CF9863CA16070' \
    '387813FB000000FEC00000540B41378E3087000A8F3F14' \
    '34011FB660AA40078F0021C4106115028FDFC81B8DC6168000301D02D01C0DE38C21C' \
    '002A3CFC50D0047ED982A9001E3C0087104184540A3F7F' \
    '206E3F1C5A0000C0540B40378E3087000A8F3F1434011FB660AA40078F0021C410611' \
    '5028FDFC81BAFD71680003000630F134003A00618003F' \
    'FFFFFFFE20F104003A0861800BFFFFFFFFE20F000003A00618007FFFFFFFFE00A026C1' \
    '0080002A800EC070E06002030381967C786030303001C' \
    '0C4082C38180080C0E06597140540D120001120001020047A0BC00F800A000C0405007' \
    '03009401C001808084400410B0108000000DE0180200' \
    '000249403802008020080200802009724A01C01004010040100401004C00200000C03E5' \
    '056E91B8460C500C10000096525040700401004010' \
    '0401004019652504070040100401004010040296525040000C0000803D28AAAED4572A283' \
    '550082020040080802004101008010040100208080400802008010142E40200CA0'
