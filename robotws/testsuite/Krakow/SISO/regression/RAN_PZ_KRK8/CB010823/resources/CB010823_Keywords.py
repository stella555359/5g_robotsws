from datetime import datetime, timedelta
import pytz
from robot.api import logger


def get_current_time():
    return datetime.now(tz=pytz.timezone("Europe/Warsaw"))


def parse_execution_time(time_string: str) -> datetime:
    if "DST" in time_string:
        time_string = time_string.replace("DST", "+0200")
    else:
        logger.info(
            f"No time zone detected in string {time_string}, defaulting to +0100",
            also_console=True,
        )
        time_string = f"{time_string} +0100"

    time_string: datetime = datetime.strptime(
        time_string, r"%d.%m.%Y %H:%M:%S %z")
    return time_string


def legacy_parse_execution_time(time_string: str) -> datetime:
    time_string: datetime = datetime.strptime(
        time_string, r"%Y-%m-%dT%H:%M:%S%z")
    return time_string


def generate_delta_for_scheduled_check(
    current_time: datetime = None, time_offset_seconds: int = 300
):
    if current_time is None:
        current_time = datetime.now(tz=pytz.timezone("Europe/Warsaw"))
    scheduled_time: datetime = current_time + \
        timedelta(seconds=time_offset_seconds)
    scheduled_time: datetime = scheduled_time.replace(microsecond=0)
    scheduled_time_string: str = datetime.strftime(scheduled_time, "%H:%M:%S")
    delta: dict = [
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/FEATCADM-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actDiagnosticCheck",
                    "operation": "update",
                    "value": "true",
                }
            ],
        },
        {
            "distName": "MRBTS-75030/MNL-1/MNLENT-1/TRBLCADM-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "diagnosticCheckSchedule",
                    "operation": "update",
                    "value": [{"checkDays": "127", "checkTime": scheduled_time_string}],
                }
            ],
        }
    ]
    return delta, scheduled_time
