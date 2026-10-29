import json
import testsuite.Ulm.resources.Common.python.egate_analyzer as analyzer


def test_find_measurement_reports():
    egate_output_data = """
    {
              eventId eventA3 :
              {
                a3-Offset rsrp : 6,
                reportOnLeave FALSE,
                hysteresis 0,
                timeToTrigger ms320,
                useAllowedCellList FALSE
              },
              rsType ssb,
              reportInterval ms120,
              reportAmount r4,
              reportQuantityCell
              {
                rsrp TRUE,
                rsrq TRUE,
                sinr TRUE
              },
              maxReportCells 8,
              reportQuantityRS-Indexes
              {
                rsrp TRUE,
                rsrq TRUE,
                sinr TRUE
              },
              maxNrofRS-IndexesToReport 8,
              includeBeamMeasurements TRUE
            frequencyBandList

                  {

                    78

                  },
            }
    """
    expected_result = {
        "101": {
            "eventId eventA3": {
                "line_start": 2,
                "message": {
                    "a3-Offset rsrp": "6",
                    "reportOnLeave": "FALSE",
                    "hysteresis": "0",
                    "timeToTrigger": "ms320",
                    "useAllowedCellList": "FALSE"
                }
            },
            "frequencyBandList": {
                "line_start": 28,
                "message": {
                    "": "78"
                }
            }
        }}
    analyzer.analyze_egate_output(egate_output_data, '/tmp/events.json', 101,
                                  regex_search=[r'eventId eventA\d',
                                                r'frequencyBandList'])
    with open('/tmp/events.json', 'r', encoding='utf-8') as output:
        result_dict = json.load(output)
        assert result_dict == expected_result
