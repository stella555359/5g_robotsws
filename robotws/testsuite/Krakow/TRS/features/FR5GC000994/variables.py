from robot.libraries.BuiltIn import BuiltIn

current_release = str(BuiltIn().get_variable_value('${ENB_BRANCH}'))

releases = ['SBTS22R3', 'SBTS22R4', 'SBTS23R1']

if any(release in current_release for release in releases):
    plr_alarm = "PLR threshold crossed on "
else:
    plr_alarm = "PLR Threshold crossed on "

rtt_alarm = "RTT threshold crossed on "
