from datetime import datetime, timedelta

Documentation = """ Author: arunkumar.a@nokia.com
Why-   Cb010638 required powersaving periored confirguration.
How-   this code can set automatically real time of lbps period. like, day, hour, minutes.
What-  code for time alignment with lbps. """
# giving the format of datetime
format = "%Y-%m-%d %H:%M:%S %Z%z"
# getting the current time in UTC timezone
now_utc = datetime.utcnow()
# Converting to Asia/Kolkata time zone
asia_kolkata = timedelta(hours=5, minutes=30)
isttime = (now_utc + asia_kolkata).ctime()
print('****  Indian standared time: ', isttime, '****')
inthour = int(isttime[11:13])
intminuets = int(isttime[14:16])


def powersaving_parameters():
    try:
        day = [(isttime[0:3]), (isttime[11:13]), (isttime[14:16])]
        if day[1] != '23':
            if day[2] <= '40':
                mit_change_1 = int(day[2]) + 19
                day[2] = str(mit_change_1)
            elif '41' <= day[2] < '60':
                hour_1 = int(day[1]) + 1
                day[1] = str(hour_1)
                mit_change = int(day[2])-38
                day[2] = str(mit_change)
        elif day[1] == '23' and day[2] > '40':
            hour_change = 23 - inthour
            minute_change = intminuets - 38
            day[2] = str(minute_change)
            day[1] = str(hour_change)
        elif day[1] == '23' and day[2] < '40':
            minute_change = intminuets + 16
            day[2] = str(minute_change)
            day[1] = str(inthour)
    except Exception:
        raise BaseException('Something Went wrong in time management\npower saving algorithm not functioning.')
    powersaving_parameters_variable = [{"parameterName": "lbpsPeriodList", "operation": "update",
                                        "value": [{'lbpsDayOfWeek': day[0],
                                                   'lbpsDuration': '20',
                                                   'lbpsStartTimeHour': day[1],
                                                   'lbpsStartTimeMinute': day[2]}]}]
    return powersaving_parameters_variable


check = powersaving_parameters()
# Setting power saving period via automation.
lbpsDayOfWeek_value = check[0]['value'][0]['lbpsDayOfWeek']
lbpsDuration_value = check[0]['value'][0]['lbpsDuration']
lbpsStartTimeHour_value = check[0]['value'][0]['lbpsStartTimeHour']
lbpsStartTimeMinute_value = check[0]['value'][0]['lbpsStartTimeMinute']
# common parameters about cb010638 under nrpgrp
nr_cell_config_abbr = 'nrCellId'
nr_cell_config_param = 'NR cell configuration identifier'
nr_cell_config_value = '4'
lbpslast_cell_switch_off_param = 'Load-based power saving last cell switch off enabled'
lbpsLastCellSOEnabled_abbr = 'lbpsLastCellSOEnabled'
lbpsLastCellSOEnabled_Value = 'true'
lbps_day_of_week_param = 'Load-based power saving day of week'
lbpsDayOfWeek_abbr = 'lbpsDayOfWeek'
lbps_duration_param = 'Load-based power saving duration'
lbpsDuration_abbr = 'lbpsDuration'
lbps_starttimehour_param = 'Load-based power saving start time hour'
lbpsStartTimeHour_abbr = 'lbpsStartTimeHour'
lbps_start_time_minute_param = 'Load-based power saving start time minute'
lbpsStartTimeMinute_abbr = 'lbpsStartTimeMinute'
# under MRBTS-11008/NRBTS-11008 CB010638 feature parameters
powerSavingAvoidanceForPACalls_abbr = 'powerSavingAvoidanceForPACalls'
powerSavingAvoidanceForPACalls_value = 'PA avoidance PCell enabled'
powerSavingAvoidanceForPACalls_value_diabled = 'PA avoidance disabled'
powerSavingAvoidanceForPACalls_param = 'Power saving avoidance options for priority access calls'
# cb008392, cb008133, cb010471, 5GC000431
actNrLBPowerSaving_abbr = 'actNrLBPowerSaving'
actNrLBPowerSaving_param = 'Activate NR load-based power saving'
actNrLBPowerSaving_value = 'true'
MimoRTXPowerSaving_abbr = 'actNrLBmMimoRTXPowerSaving'
MimoRTXPowerSaving_param = 'Activate NR load-based mMIMO TX power saving'
MimoRTXPowerSaving_value = 'false'
TXPowerSaving_abbr = 'actNrLBRTXPowerSaving'
TXPowerSaving_param = 'Activate NR load-based reduced TX power saving'
TXPowerSaving_value = 'false'
# act priority access
actPriorityAccess_abbr = 'actPriorityAccess'
actPriorityAccess_param = 'Activate priority access'
actPriorityAccess_value = 'true'
