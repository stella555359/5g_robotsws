import logging
import io
from tti_utilities.variables import METADATA_COLUMNS
from tti_utilities.loader import format_aligned, color_text

vlogger = logging.getLogger("vlogger")


def hierarchical_filter(row, ranges):
    # cols = ['hfnTickCount', 'sfn', 'slot']
    start_hfn, end_hfn = ranges["hfnTickCount"]
    val_hfn = row["hfnTickCount"]
    val_sfn = row["sfn"]
    val_slot = row["slot"]
    val_absolute = to_absolute(val_sfn, val_slot)
    start_sfn, end_sfn = ranges["sfn"]
    start_slot, end_slot = ranges["slot"]
    if start_hfn < val_hfn < end_hfn:  # Strictly within range
        return True
    elif start_hfn == val_hfn and end_hfn == val_hfn:
        return (
            to_absolute(start_sfn, start_slot)
            < val_absolute
            < to_absolute(end_sfn, end_slot)
        )
    elif val_hfn == start_hfn:
        absoulte = to_absolute(start_sfn, start_slot)
        return val_absolute >= absoulte
    elif val_hfn == end_hfn:
        absoulte = to_absolute(end_sfn, end_slot)
        return val_absolute <= absoulte
    else:
        return False


def ulcheck(switchNumber, sfn_range_df, dataframes, recorded_range):
    vlogger.info(f"UL Check for Switch {switchNumber}")
    buffer = io.StringIO()  # buffer for the loop
    # a switch row will be passed by the main function you have to check in that
    # you have to make two filters
    # PdcchDciData.PdcchMonitoringAdaptationInd # filter this row to not have blanks
    # we have to get which switch is that from the row so that we can see the same switch there,
    # then only we can do
    # who will provide rnti
    # measurement duraiton funciton will pass the sfn df which have all the info about switch infomration
    # threshold check after completion , wi
    # we will go into the if its first switch first row of sfn df will be the data of the first switch
    # we will pass info about first switch to the ul check function
    # based on this information , we will filter ulddci to not have blanks and filter the uldci with rnti you
    # are looking for the sfn df in the first switch
    # in that we have to get to the switch in which we are in
    # if we are in the first switch, check the first row and check whether it is falling the range
    # make that ul dci to have only switches and filter based on rnti
    # the rnti thing
    # we have the rnti afer clearing the blanks you have the sfn range and all
    # filter rnti
    # we have to check whether the switch is falling in the range
    # get the added the k2 value and get the updated hfn things,
    # check if this hfn things is NON DTX OR DTX
    # if its NON DTX print True else Print False
    # ul_flag = ulcheck(switchNumber, sfn_range_df, dataframes)
    # falling in the range
    # threshold function completes checks all the thresholds
    # we will call ul_check function and pass switch number and also that particular switch from sfn_df to make it get
    # rnti range and all those
    # print(ulPdcchDci)
    # print("no blank one")
    # print(ulPdcchDci['rnti'].apply(type).value_counts())
    # print(sfn_range_df['rnti'].apply(type).value_counts())
    vlogger.info(f"sfn range received {sfn_range_df.iloc[0].to_dict()}")
    ulPdcchDci = dataframes["ulPdcchDci"]
    filtered_ulPdcchDci = ulPdcchDci[
        ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].notna()
        & (ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"] != "")
        & (ulPdcchDci["rnti"] == sfn_range_df.iloc[0]["rnti"])
    ]
    vlogger.info("Filtering ulPdcchDci to not contain blanks")
    vlogger.info(f"Filtering ulPdcchDci with rnti {sfn_range_df.iloc[0]['rnti']}")

    # print(filtered_ulPdcchDci)
    filtered_switch_rows_ulPdcchDci = filtered_ulPdcchDci[
        (
            filtered_ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"]
            != filtered_ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].shift()
        )
    ]
    vlogger.info("Filtering ulPdcchDci to only have switches")
    ulPdcchDci_switched_rows = filtered_switch_rows_ulPdcchDci.iloc[1:]
    # print(ulPdcchDci_switched_rows)
    # print("Data from Ul")
    # print(ulPdcchDci_switched_rows)
    vlogger.info(f"checking sfn range with for switch {switchNumber}")
    if recorded_range is None:
        row = ulPdcchDci_switched_rows.iloc[[switchNumber - 1]].iloc[0]
    else:
        row = recorded_range[recorded_range["switch"] == switchNumber]

        # row = recorded_range[recorded_range["switch"] == switchNumber]
        # buffer.write(row.iloc[0].to_string(index=False))
        if row.empty:
            print(f"Switch {switchNumber} doesn't exist in pairs_df")
            buffer.write(
                format_aligned(
                    f"No switch found for {switchNumber}", color_text("FATAL", "fail")
                )
            )
            buffer_closed = buffer.getvalue()
            buffer.close()
            return False, buffer_closed
        else:
            start_col1 = row["start_hfnTickCount"].iloc[0]
            start_col2 = row["start_sfn"].iloc[0]
            start_slot = row["start_slot"].iloc[0]
            end_col1 = row["end_hfnTickCount"].iloc[0]
            end_col2 = row["end_sfn"].iloc[0]
            end_slot = row["end_slot"].iloc[0]
            ranges = {
                "hfnTickCount": (int(start_col1), int(end_col1)),
                "sfn": (int(start_col2), int(end_col2)),
                "slot": (int(start_slot), int(end_slot)),
            }
            # print("Ranges from dl")
            # pprint(ranges)

            matching_rows = ulPdcchDci_switched_rows[
                ulPdcchDci_switched_rows.apply(
                    lambda row: hierarchical_filter(row, ranges), axis=1
                )
            ]
            if matching_rows.empty:
                # val = row["is_last_entry"].iloc[0]
                # print(f"Type: {type(val)}, Value: {val}, {repr(val)}")  # Debug first
                if row["is_last_entry"].iloc[0]:
                    # buffer.write("Is last entry is True")
                    # buffer.write(format_aligned(f"No data in DCI for switch {switchNumber}"))
                    buffer.write(
                        format_aligned(f"No data in DCI for switch  {switchNumber}")
                    )
                    flag = True
                else:
                    buffer.write(
                        format_aligned(
                            f"No row in ulPdcchDci_decode falls within switch {switchNumber} range"
                        )
                    )
                    buffer.write(
                        format_aligned(
                            f"No switch found for {switchNumber}",
                            color_text("FATAL", "fail"),
                        )
                    )
                    flag = False
                buffer_closed = buffer.getvalue()
                buffer.close()
                return flag, buffer_closed

            else:
                buffer.write(
                    format_aligned(f"Found {len(matching_rows)} row(s) within range:")
                )
                # print(matching_rows)
                matching_row = matching_rows.iloc[0]  # First match
                row = matching_row

    buffer.write(
        format_aligned(
            "ulPdcchDci_decode",
            f"[{row[METADATA_COLUMNS[0]]} {row[METADATA_COLUMNS[1]]} {row[METADATA_COLUMNS[2]]}]",
        )
    )
    meta_req_for_harq = add_k_value_and_return(row, dataframes, buffer)
    dtx_flag = get_dtx_or_non_dtx_flag(meta_req_for_harq, dataframes, buffer)
    buffer_closed = buffer.getvalue()
    buffer.close()
    # if dtx_flag:
    #     type_out(format_aligned("UL Check", color_text("Test Passed", "pass")))
    # else:
    #     type_out(format_aligned("UL Check", color_text("Test Failed", "fail")))
    # type_out(buffer_closed)
    # dtx_flag = False
    return dtx_flag, buffer_closed
    # return None


def check_sfn_is_falling(switchNumber, sfn_df, ulPdcchDci_switched_rows, buffer):
    try:
        row = ulPdcchDci_switched_rows.iloc[switchNumber - 1]
    except Exception:
        buffer.write(
            format_aligned(
                f"No switch found for switch {switchNumber}",
                color_text("FATAL", "fail"),
            )
        )
        buffer_closed = buffer.getvalue()
        buffer.close()
        return False, buffer_closed
    vlogger.info(f"Retrieving Switch {switchNumber} from ulPdcchDci :{row.to_dict()}")
    # vlogger.info("Retrieving Switch {switchNumber} from ulPdcchDci")
    # current_hfnTickCount = row['hfnTickCount']
    current_sfn = (row["hfnTickCount"], row["sfn"])
    start_sfn_range = (
        sfn_df.iloc[0]["starthfnTickCount"],
        sfn_df.iloc[0]["startRange"],
    )
    end_sfn_range = (sfn_df.iloc[0]["endhfnTickCount"], sfn_df.iloc[0]["endRange"])
    vlogger.info(
        f"""Checking {(int(row['hfnTickCount']), int(row['sfn']))} from ulPdcchDci in range
                 {(int(sfn_df.iloc[0]['starthfnTickCount']), int(sfn_df.iloc[0]['startRange']))}
                 {(int(sfn_df.iloc[0]['endhfnTickCount']), int(sfn_df.iloc[0]['endRange']))}"""
    )
    is_in_range_flag = is_in_range(start_sfn_range, end_sfn_range, current_sfn)
    if is_in_range_flag:
        vlogger.info(
            f"""sfn {(int(row['hfnTickCount']), int(row['sfn']))} is in range
                     {(int(sfn_df.iloc[0]['starthfnTickCount']),
                       int(sfn_df.iloc[0]['startRange']))} {(int(sfn_df.iloc[0]['endhfnTickCount']),
                                                             int(sfn_df.iloc[0]['endRange']))}"""
        )
    else:
        vlogger.info(
            f"""sfn {(int(row['hfnTickCount']), int(row['sfn']))}
                     is not in range {(int(sfn_df.iloc[0]['starthfnTickCount']),
                                       int(sfn_df.iloc[0]['startRange']))}
                                        {(int(sfn_df.iloc[0]['endhfnTickCount']),
                                          int(sfn_df.iloc[0]['endRange']))}"""
        )
    return is_in_range_flag


def is_in_range(start, end, point):
    start_val = to_absolute(start)
    # print(start_val)
    end_val = to_absolute(end)
    # print(end_val)
    point_val = to_absolute(point)
    # print(point_val)

    if start_val <= end_val:
        # print(start_val <= point_val <= end_val)
        return start_val <= point_val <= end_val
    else:
        # Wrap-around case
        # return point_val >= start_val or point_val <= end_val
        raise ValueError(
            f"Invalid range: start {start_val} is greater than end {end_val}"
        )


def to_absolute(major, minor):
    """
    Converts a (major, minor) pair into a single integer value
    to allow linear comparison across wrap boundaries.
    """
    # major, minor = pair
    # print(f"major:{major}, minor:{minor}")
    # print("major", major)
    # print("minor", minor)
    # print("max sfn", MAX_SFN)

    return major * (19 + 1) + minor  # 1025 values per major


def add_k_value_and_return(row, dataframes, buffer):
    vlogger.info(f"Adding k value for row {row.to_dict()}")
    THRESHOLD = 19
    # metadata = [int(row[col]) for col in METADATA_COLUMNS]
    metadata = [int(row[col]) for col in METADATA_COLUMNS]

    # print(metadata)
    ulFdSched = dataframes["ulFdSched"]
    # match = ulFdSched[
    #             (ulFdSched[METADATA_COLUMNS[0]] == metadata[0]) &
    #             (ulFdSched[METADATA_COLUMNS[1]] == metadata[1]) &
    #             (ulFdSched[METADATA_COLUMNS[2]] == metadata[2])
    #         ]
    # if match.empty:
    #     print("No related row found in ulFdSched")
    ulFdSched_sorted = ulFdSched.sort_values("K2")
    k_value = ulFdSched_sorted[ulFdSched_sorted["K2"] != 0].iloc[0]["K2"]
    buffer.write(format_aligned("ulFdSched k2", f"{k_value}"))
    vlogger.info(f"k2 value from ulFdSched Data is {k_value}")
    # print(k_value)
    # k_value = match.iloc[0][K]
    total = metadata[2] + int(k_value)

    if total <= THRESHOLD:
        new_meta = metadata.copy()
        # print(new_meta)
        new_meta[2] = total
        # print(new_meta, "new_meta")
        vlogger.info(f"k_value added directly: {new_meta}")
        metas_to_check = new_meta

        # print(new_meta)
    else:
        new_meta = metadata.copy()
        new_meta[2] = THRESHOLD
        overflow = total % THRESHOLD
        overflow_meta = [metadata[0], metadata[1] + 1, overflow]
        # print(overflow_meta,"overflowmeta")
        vlogger.info(f"k_value overflow: {new_meta} + {overflow_meta - 1}")
        metas_to_check = overflow_meta
    buffer.write(
        format_aligned("ulHarqRx", f"{[metas_to_check[col] for col in [0, 1, 2]]}")
    )
    return metas_to_check


def get_dtx_or_non_dtx_flag(metadata, dataframes, buffer):
    vlogger.info(f"Checking for {metadata} in ulHarqRx")
    ulHarqRx = dataframes["ulHarqRx"]
    match = ulHarqRx[
        (ulHarqRx[METADATA_COLUMNS[0]] == metadata[0])
        & (ulHarqRx[METADATA_COLUMNS[1]] == metadata[1])
        & (ulHarqRx[METADATA_COLUMNS[2]] == metadata[2])
    ]
    if match.empty:
        buffer.write(format_aligned("No related row found in ulHarqRx"))
        return False
    dtxResult = match.iloc[0]["dtx"]
    crcResult = match.iloc[0]["crcResult"]
    dtxResultFlag = dtxResult == "NON_DTX"
    crcResultFlag = crcResult == "OK"

    if dtxResultFlag:
        if crcResultFlag:
            vlogger.info("dtx Result is NON_DTX and crcResult is OK. Test Passed")
            buffer.write(
                format_aligned(
                    f"{[int(match.iloc[0][col]) for col in METADATA_COLUMNS]}",
                    f"dtxFlag => {dtxResult} and crcResult => {crcResult}",
                )
            )
            return True
        else:
            vlogger.info("dtx Result is NON_DTX and crcResult is NOT OK. Test Passed")
            buffer.write(
                format_aligned(
                    f"{[int(match.iloc[0][col]) for col in METADATA_COLUMNS]}",
                    f"dtxFlag => {dtxResult} and crcResult => {crcResult}",
                )
            )
            return False
    else:
        vlogger.error("dtx Result is DTX. Test Failed")
        buffer.write(
            format_aligned(
                f"{[int(match.iloc[0][col]) for col in METADATA_COLUMNS]}",
                f"dtxFlag => {dtxResult}",
            )
        )
        return False


def get_number_of_switches_in_UL_DCI(dataframes, sfn_range_df):
    ulPdcchDci = dataframes["ulPdcchDci"]
    filtered_ulPdcchDci = ulPdcchDci[
        ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].notna()
        & (ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"] != "")
        & (ulPdcchDci["rnti"] == sfn_range_df.iloc[0]["rnti"])
    ]
    # vlogger.info("Filtering ulPdcchDci to not contain blanks")
    # vlogger.info(f"Filtering ulPdcchDci with rnti {sfn_range_df.iloc[0]['rnti']}")

    # print(filtered_ulPdcchDci)
    filtered_switch_rows_ulPdcchDci = filtered_ulPdcchDci[
        (
            filtered_ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"]
            != filtered_ulPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].shift()
        )
    ]
    # vlogger.info(f"Filtering ulPdcchDci to only have switches")
    ulPdcchDci_switched_rows = filtered_switch_rows_ulPdcchDci.iloc[1:]
    print(f"Found {len(ulPdcchDci_switched_rows)} switches in ulPdcchDci 📶⬆️")
    return len(ulPdcchDci_switched_rows)
