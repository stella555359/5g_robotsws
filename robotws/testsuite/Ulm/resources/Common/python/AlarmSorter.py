from datetime import datetime
from typing import List, Dict, Any, Union


class AlarmSorter:
    """
    Eine Klasse, die eine Liste von Dictionaries nach dem Schlüssel `btsObservationTime` sortiert.
    """

    def sort_alarm_list_by_observation_time(self, alarm_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Sortiert eine Liste von Dictionaries nach dem Schlüssel `btsObservationTime`.

        :param alarm_list: Liste von Dictionaries, die den Schlüssel `btsObservationTime` enthalten.
        :return: Sortierte Liste von Dictionaries.
        """
        def parse_observation_time(timestamp: Union[str, int]) -> datetime:
            """
            Konvertiert den Zeitstempel in ein Datetime-Objekt.

            :param timestamp: Zeitstempel im Format "YYYYMMDDHHMMSS.sss+ZZZZ" (als String) oder als Integer.
            :return: Datetime-Objekt.
            """
            if isinstance(timestamp, str):
                try:
                    # Entferne die Zeitzoneninformationen (+0000) und parse den Zeitstempel
                    return datetime.strptime(timestamp[:-5], "%Y%m%d%H%M%S.%f")
                except ValueError as e:
                    raise ValueError(f"Invalid timestamp: {timestamp}") from e
            elif isinstance(timestamp, int):
                try:
                    # Falls der Zeitstempel ein Integer ist, konvertiere ihn in einen String und parse ihn
                    return datetime.strptime(str(timestamp), "%Y%m%d%H%M%S")
                except ValueError as e:
                    raise ValueError(f"Invalid timestamp: {timestamp}") from e
            else:
                raise TypeError(f"Timestamp must be String or Integer, got {type(timestamp)} instead.")

        # Sortiere die Liste nach dem Zeitstempel im Schlüssel `btsObservationTime`
        sorted_list = sorted(
            alarm_list,
            key=lambda x: parse_observation_time(x["btsObservationTime"])
        )

        return sorted_list
