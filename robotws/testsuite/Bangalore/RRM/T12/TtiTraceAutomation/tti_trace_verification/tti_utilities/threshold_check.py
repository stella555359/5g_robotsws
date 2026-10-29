import io
import logging
from tti_utilities.loader import format_aligned

# logger = vlogger
# ✅ Fail-fast threshold check based on type
vlogger = logging.getLogger("vlogger")


def row_passes_threshold(row, thresholds, thresholds_mappings_to_check, voNrFlag):
    buffer = io.StringIO()  # buffer for the loop
    vlogger.info(f"Theshold check for {row.to_dict()}")
    type_value = row["currentSssg"].strip().lower()
    isBufferRatioValid = row["isBufferRatioValid"]
    mapping_to_check = (
        "dense_to_sparse_mapping"
        if type_value == "dense"
        else "sparse_to_dense_mapping"
    )
    vlogger.info(f"UE is switching from {mapping_to_check}")
    mapping = thresholds_mappings_to_check[mapping_to_check]

    if voNrFlag is False:
        is_all_check = mapping_to_check == "dense_to_sparse_mapping"

        if is_all_check:
            vlogger.info("All thresholds to be met")
        else:
            vlogger.info("Any one threshold to be met")

        for col, rule in mapping.items():
            if isBufferRatioValid == 0 and col in (
                "bufferEmptyRatioDl",
                "bufferEmptyRatioUl",
            ):
                vlogger.info(
                    "BufferRatioValid is set 0. Skipping Threshold check for Buffer Fields"
                )
                buffer.write(
                    format_aligned(
                        f"BufferRatioValid is set 0. Skipping Threshold check for {col}"
                    )
                )

                continue
            threshold_name = rule["threshold"]
            operator = rule["operator"]
            threshold_value = thresholds.get(threshold_name)
            if threshold_value is None:
                return False  # can't proceed without threshold
            value = row[col]

            if operator == "gt":
                condition_met = value >= threshold_value
                if condition_met:
                    vlogger.info(
                        f"Condition met: {value} >  {threshold_name} {threshold_value}"
                    )
                else:
                    vlogger.warning(
                        f"Condition not met: {value} not > {threshold_name} {threshold_value}"
                    )
                if condition_met:
                    buffer.write(
                        format_aligned(
                            f"Condition met: {col} {value} >  {threshold_name} {threshold_value}"
                        )
                    )
                else:
                    buffer.write(
                        format_aligned(
                            f"Condition not met: {col} {value} not > {threshold_name} {threshold_value}"
                        )
                    )
            elif operator == "lt":
                condition_met = value <= threshold_value
                if condition_met:
                    vlogger.info(
                        f"Condition met: {value} <  {threshold_name} {threshold_value}"
                    )
                else:
                    vlogger.warning(
                        f"Condition not met: {value} not < {threshold_name} {threshold_value}"
                    )
                # vlogger.info(f"Condition met: {value} <  {threshold_name} {threshold_value}") if condition_met else
                # vlogger.warning(f"Condition not met: {value} not < {threshold_name} {threshold_value}")
                if condition_met:
                    buffer.write(
                        format_aligned(
                            f"Condition met: {col} {value} <  {threshold_name} {threshold_value}"
                        )
                    )
                else:
                    buffer.write(
                        format_aligned(
                            f"Condition not met: {col} {value} not < {threshold_name} {threshold_value}"
                        )
                    )
            else:
                buffer_closed = buffer.getvalue()
                buffer.close()
                return False, buffer_closed  # unknown operator

            if is_all_check and not condition_met:
                vlogger.error("Threshold check failed")
                buffer_closed = buffer.getvalue()
                buffer.close()
                return False, buffer  # fail fast for 'abc'
            if not is_all_check and condition_met:
                vlogger.info("Threshold check passed")
                buffer_closed = buffer.getvalue()
                buffer.close()
                return True, buffer_closed  # succeed fast for 'def'
        (
            vlogger.info("Threshold check passed")
            if is_all_check
            else vlogger.error("Threshold check failed")
        )
        buffer_closed = buffer.getvalue()
        buffer.close()
        return (
            is_all_check,
            buffer_closed,
        )  # True if 'abc' and all passed, False if 'def' and none passed

    else:
        if mapping_to_check == "dense_to_sparse_mapping":
            even_one_fail = False
            for col, rule in mapping.items():
                if isBufferRatioValid == 0 and col in (
                    "bufferEmptyRatioDl",
                    "bufferEmptyRatioUl",
                ):
                    buffer.write(
                        format_aligned(
                            f"BufferRatioValid is set 0. Skipping Threshold check for {col}"
                        )
                    )
                    continue
                threshold_name = rule["threshold"]
                operator = rule["operator"]
                threshold_value = thresholds.get(threshold_name)
                if threshold_value is None:
                    return False  # can't proceed without threshold
                value = row[col]
                if operator == "gt":
                    condition_met = value >= threshold_value
                    if condition_met:
                        vlogger.info(
                            f"Condition met: {value} >  {threshold_name} {threshold_value}"
                        )
                    else:
                        vlogger.warning(
                            f"Condition not met: {value} not > {threshold_name} {threshold_value}"
                        )
                    if condition_met:
                        buffer.write(
                            format_aligned(
                                f"Condition met: {col} {value} >  {threshold_name} {threshold_value}"
                            )
                        )
                    else:
                        buffer.write(
                            format_aligned(
                                f"Condition not met: {col} {value} not > {threshold_name} {threshold_value}"
                            )
                        )
                        even_one_fail = True
                elif operator == "lt":
                    condition_met = value <= threshold_value
                    if condition_met:
                        vlogger.info(
                            f"Condition met: {value} <  {threshold_name} {threshold_value}"
                        )
                    else:
                        vlogger.warning(
                            f"Condition not met: {value} not < {threshold_name} {threshold_value}"
                        )
                    # vlogger.info(f"Condition met: {value} <  {threshold_name} {threshold_value}")
                    # if condition_met else
                    # vlogger.warning(f"Condition not met: {value} not < {threshold_name} {threshold_value}")
                    if condition_met:
                        buffer.write(
                            format_aligned(
                                f"Condition met: {col} {value} < {threshold_name} {threshold_value}"
                            )
                        )
                    else:
                        buffer.write(
                            format_aligned(
                                f"Condition not met: {col} {value} not < {threshold_name} {threshold_value}"
                            )
                        )
                        even_one_fail = True
            buffer_closed = buffer.getvalue()
            buffer.close()
            if even_one_fail:
                return False, buffer_closed
            else:
                return True, buffer_closed

        elif mapping_to_check == "sparse_to_dense_mapping":
            even_one_pass = False
            for col, rule in mapping.items():
                if isBufferRatioValid == 0 and col in (
                    "bufferEmptyRatioDl",
                    "bufferEmptyRatioUl",
                ):
                    buffer.write(
                        format_aligned(
                            f"BufferRatioValid is set 0. Skipping Threshold check for {col}"
                        )
                    )
                    continue
                threshold_name = rule["threshold"]
                operator = rule["operator"]
                threshold_value = thresholds.get(threshold_name)
                if threshold_value is None:
                    return False  # can't proceed without threshold
                value = row[col]
                if operator == "gt":
                    condition_met = value >= threshold_value
                    if condition_met:
                        vlogger.info(
                            f"Condition met: {value} >  {threshold_name} {threshold_value}"
                        )
                    else:
                        vlogger.warning(
                            f"Condition not met: {value} not > {threshold_name} {threshold_value}"
                        )
                    if condition_met:
                        buffer.write(
                            format_aligned(
                                f"Condition met: {col} {value} >  {threshold_name} {threshold_value}"
                            )
                        )
                        even_one_pass = True
                    else:
                        buffer.write(
                            format_aligned(
                                f"Condition not met: {col} {value} not > {threshold_name} {threshold_value}"
                            )
                        )
                elif operator == "lt":
                    condition_met = value <= threshold_value
                    if condition_met:
                        vlogger.info(
                            f"Condition met: {value} <  {threshold_name} {threshold_value}"
                        )
                    else:
                        vlogger.warning(
                            f"Condition not met: {value} not < {threshold_name} {threshold_value}"
                        )
                    # vlogger.info(f"Condition met: {value} <  {threshold_name} {threshold_value}")
                    # if condition_met else
                    # vlogger.warning(f"Condition not met: {value} not < {threshold_name} {threshold_value}")
                    if condition_met:
                        buffer.write(
                            format_aligned(
                                f"Condition met: {col} {value} <  {threshold_name} {threshold_value}"
                            )
                        )
                        even_one_pass = True
                    else:
                        buffer.write(
                            format_aligned(
                                f"Condition not met: {col} {value} not < {threshold_name} {threshold_value}"
                            )
                        )
            buffer_closed = buffer.getvalue()
            buffer.close()
            if even_one_pass:
                return True, buffer_closed
            else:
                return False, buffer_closed


def row_passes_cqi(row, thresholds):
    buffer = io.StringIO()  # buffer for the loop

    vlogger.info(f"Theshold check for {row.to_dict()}")
    row_cqi = row["averageCqi"]
    threshold_cqi = thresholds["cqiThreshold"]
    # flag = (row_cqi < threshold_cqi)
    if row_cqi < threshold_cqi:
        buffer.write(
            format_aligned(
                f"Condition met: averageCqi {row_cqi} <  cqiThreshold {threshold_cqi}"
            )
        )
        buffer_closed = buffer.getvalue()
        buffer.close()
        return True, buffer_closed
    else:
        buffer.write(
            format_aligned(
                f"Condition not met: averageCqi {row_cqi} not <  cqiThreshold {threshold_cqi}"
            )
        )
        buffer_closed = buffer.getvalue()
        buffer.close()
        return False, buffer_closed
