import logging
import io
from tti_utilities.variables import METADATA_COLUMNS
from tti_utilities.loader import color_text
from tti_utilities.loader import format_aligned

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
        # print(f"{val_hfn} is between {start_hfn} and {end_hfn}")
        return True
    elif start_hfn == val_hfn and end_hfn == val_hfn:
        # print(f"hfn is equal to {start_hfn}, ")
        return (
            to_absolute(start_sfn, start_slot)
            <= val_absolute
            <= to_absolute(end_sfn, end_slot)
        )
    elif val_hfn == start_hfn:
        absoulte = to_absolute(start_sfn, start_slot)
        return val_absolute >= absoulte
    elif val_hfn == end_hfn:
        absoulte = to_absolute(end_sfn, end_slot)
        return val_absolute <= absoulte
    else:
        return False


def dlcheck(switchNumber, sfn_range_df, dataframes, recorded_range):
    buffer = io.StringIO()
    vlogger.info(f"DL check for switch Number : {switchNumber}")
    dlPdcchDci = dataframes["dlPdcchDci"]
    # PdcchDciData.dciFromat
    filtered_dlPdcchDci = dlPdcchDci[
        dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].notna()
        & (dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"] != "")
        & (dlPdcchDci["rnti"] == sfn_range_df.iloc[0]["rnti"])
        & (dlPdcchDci["PdcchDciData.dciFromat"] == "DL_11")
    ]
    vlogger.info("Filtering dlPdcchDci to not contain blanks")
    vlogger.info(f"Filtering dlPdcchDci with RNTI {sfn_range_df.iloc[0]['rnti']}")
    vlogger.info("Filtering dlPdcchDci with PdcchDciData.dciFromat DL_11")

    filtered_switch_rows_dlPdcchDci = filtered_dlPdcchDci[
        (
            filtered_dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"]
            != filtered_dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].shift()
        )
    ]
    vlogger.info("Filtering dlPdcchDci to only have switches")
    dlPdcchDci_switched_rows = filtered_switch_rows_dlPdcchDci.iloc[1:]

    if recorded_range is None:
        row = dlPdcchDci_switched_rows.iloc[[switchNumber - 1]].iloc[0]
    else:
        row = recorded_range[recorded_range["switch"] == switchNumber]

        # row = recorded_range[recorded_range["switch"] == switchNumber]
        if row.empty:
            print(f"Switch {switchNumber} doesn't exist in pairs_df")
            buffer.write(
                format_aligned(
                    f"No switch found for switch {switchNumber}",
                    color_text("FATAL", "fail"),
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
            matching_rows = dlPdcchDci_switched_rows[
                dlPdcchDci_switched_rows.apply(
                    lambda row: hierarchical_filter(row, ranges), axis=1
                )
            ]
            if matching_rows.empty:
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
                            f"No row in dlPdcchDci_decode falls within switch {switchNumber} range"
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
                matching_row = matching_rows.iloc[0]  # First match
                row = matching_row
    buffer.write(
        format_aligned(
            "dlPdcchDci_decode",
            f"[{row[METADATA_COLUMNS[0]]} {row[METADATA_COLUMNS[1]]} {row[METADATA_COLUMNS[2]]}]",
        )
    )
    meta_req_for_harq_dl = add_k1_value_and_return(row, dataframes, buffer)

    dtx_flag_dl = get_dtx_or_non_dtx_flag_dl(meta_req_for_harq_dl, dataframes, buffer)
    buffer_closed = buffer.getvalue()
    buffer.close()
    return dtx_flag_dl, buffer_closed


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
    # return major * (MAX_SFN + 1) + minor  # 1025 values per major
    return major * (19 + 1) + minor  # 1025 values per major


def add_k1_value_and_return(row, dataframes, buffer):
    vlogger.info(f"Adding k value for row {row.to_dict()}")
    THRESHOLD = 19
    metadata = [int(row[col]) for col in METADATA_COLUMNS]
    # metadata = [int(row[col].iloc[0]) for col in METADATA_COLUMNS]

    dlFdSched = dataframes["dlFdSched"]
    match = dlFdSched[
        (dlFdSched[METADATA_COLUMNS[0]] == metadata[0])
        & (dlFdSched[METADATA_COLUMNS[1]] == metadata[1])
    ]
    if match.empty:
        print(format_aligned("No related row found in ulFdSched", ""))
    k_value = match.iloc[0]["K1"]
    buffer.write(
        format_aligned(
            f"dlFdSched [{row[METADATA_COLUMNS[0]]} {row[METADATA_COLUMNS[1]]}]",
            f"K1 value => {k_value}",
        )
    )
    vlogger.info(f"k1 value from dlFdSched Data is {k_value}")
    total = metadata[2] + int(k_value)

    if total <= THRESHOLD:
        new_meta = metadata.copy()
        new_meta[2] = total
        vlogger.info(f"k1_value added directly: {new_meta}")
        metas_to_check = new_meta
    else:
        new_meta = metadata.copy()
        new_meta[2] = THRESHOLD
        overflow = total % THRESHOLD
        overflow_meta = [metadata[0], metadata[1] + 1, overflow - 1]
        vlogger.info(f"k1_value overflow: {new_meta} + {overflow_meta}")
        metas_to_check = overflow_meta
    buffer.write(
        format_aligned(
            "dlHarqRx", f"[{metas_to_check[0]} {metas_to_check[1]} {metas_to_check[2]}]"
        )
    )
    return metas_to_check


def get_dtx_or_non_dtx_flag_dl(metadata, dataframes, buffer):
    data = METADATA_COLUMNS
    vlogger.info(f"Checking for {metadata} in dlHarqRx")
    dlHarqRx = dataframes["dlHarqRx"]
    match = dlHarqRx[
        (dlHarqRx[METADATA_COLUMNS[0]] == metadata[0])
        & (dlHarqRx[METADATA_COLUMNS[1]] == metadata[1])
        & (dlHarqRx[METADATA_COLUMNS[2]] == metadata[2])
    ]
    if match.empty:
        buffer.write(format_aligned("No related row found in dlHarqRx", ""))
        return False
    try:
        dtxResult = match.iloc[0]["dtx"]
    except Exception:
        return False
    if dtxResult == "NON_DTX":
        vlogger.info("dtx Result is NON_DTX. Test Passed")
        buffer.write(
            format_aligned(
                f"[{match.iloc[0][data[0]]} {match.iloc[0][data[1]]} {match.iloc[0][data[2]]}]",
                f"dtxFlag => {dtxResult}",
            )
        )

        return True
    else:
        vlogger.error("dtx Result is DTX. Test Failed")
        buffer.write(
            format_aligned(
                f"[{match.iloc[0][data[0]]} {match.iloc[0][data[1]]} {match.iloc[0][data[2]]}]",
                f"dtxFlag => {dtxResult}",
            )
        )
        return False


def get_number_of_switches_in_DL_DCI(dataframes, sfn_range_df):
    dlPdcchDci = dataframes["dlPdcchDci"]
    filtered_dlPdcchDci = dlPdcchDci[
        dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].notna()
        & (dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"] != "")
        & (dlPdcchDci["rnti"] == sfn_range_df.iloc[0]["rnti"])
        & (dlPdcchDci["PdcchDciData.dciFromat"] == "DL_11")
    ]
    filtered_switch_rows_dlPdcchDci = filtered_dlPdcchDci[
        (
            filtered_dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"]
            != filtered_dlPdcchDci["PdcchDciData.PdcchMonitoringAdaptationInd"].shift()
        )
    ]
    dlPdcchDci_switched_rows = filtered_switch_rows_dlPdcchDci.iloc[1:]
    print(f"Found {len(dlPdcchDci_switched_rows)} switches in dlPdcchDci 📶⬇️\n")
    return len(dlPdcchDci_switched_rows)
