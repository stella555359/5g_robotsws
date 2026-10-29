import xml.etree.ElementTree as et
import sys
from datetime import datetime


class HtmlReport(object):
    def __init__(self, output_file, jobName="", buildNb=1, release="", gNBLoadId="", tl_hw="", logs="", streamName=" ",
                 airphoneswVersion=" ", luasharkVersion="", sequence="", dryRun=True, nbExec=1, gnbRepository=""):
        self.output_file = output_file
        self.jobName = jobName
        self.buildNb = buildNb
        self.release = release
        self.gNBLoadId = gNBLoadId
        self.tl_hw = tl_hw
        self.logs = logs
        self.streamName = streamName
        self.airphoneswVersion = airphoneswVersion
        self.luasharkVersion = luasharkVersion
        if len(luasharkVersion) == 0:
            self.luasharkVersion = gNBLoadId
        self.sequence = sequence
        self.dryRun = True
        if dryRun == "false":
            self.dryRun = False
        self.nbExec = nbExec
        self.gnbRepository = gnbRepository
        self.total_case = 0
        self.pass_case = 0
        self.exec_case = 0
        self.fail_case = 0
        self.ET_status = 0
        self.not_run = 0
        self.duration = ''

    def mode_str(self):
        if self.dryRun:
            return "DRY"
        return "REAL"

    def mode_color(self):
        if self.dryRun:
            return "orange"
        return "green"

    def status_str(self):
        if self.ET_status == 0:
            return "NOT RELEASED"
        return "RELEASED"

    def status_color(self):
        if self.ET_status == 0:
            return "red"
        return "green"

    def get_header_line(self, title, bgcolor, fontcolor, value):
        str = "<b>{}<b/></th><th ALIGN=left bgcolor='{}'><FONT color='{}'>{}".format(title, bgcolor, fontcolor, value)
        return "<tr><th ALIGN=left bgcolor=#EEEEEE>{}</FONT></th></tr>".format(str)

    def get_table_title(self, title):
        return "<font face='arial' size='4'><b><u>{}:</u></b></font><br/>".format(title)

    def html_header(self):
        buildRef = "<a href='{}/{}'>{}</a>".format(self.gnbRepository, self.gNBLoadId, self.gNBLoadId)
        title = "<h2 Align=center>5GSC_SW_CRT_NPS Test Status</h2>"
        title += self.get_table_title("Setup Details")
        title += '<table  BORDER=1 CELLSPACING=0 style="text-align:left; width:800px">'
        title += self.get_header_line("Job Name", "white", "black", self.jobName)
        title += self.get_header_line("Build Number", "white", "black", "#{}".format(self.buildNb))
        title += self.get_header_line("Release", "white", "black", self.release)
        title += self.get_header_line("Stream Name", "white", "black", self.streamName)
        title += self.get_header_line("5G SW Build", "white", "black", buildRef)
        title += self.get_header_line("Luashark version", "white", "black", self.luasharkVersion)
        title += self.get_header_line("Airphone version", "white", "black", self.airphoneswVersion)
        title += self.get_header_line("Execution Sequence", "white", "black", self.sequence)
        title += self.get_header_line("Execution Mode", "white", self.mode_color(), self.mode_str())
        title += self.get_header_line("Execution Loop", "white", "black", self.nbExec)
        title += self.get_header_line("Status", self.status_color(), "black", self.status_str())
        title += self.get_header_line("Run Duration", "white", "black", self.duration)
        title += self.get_header_line("Test Line HW", "white", "black", self.tl_hw)
        title += '</table><br/><br/><br/'
        return title

    def html_table_stats(self):
        self.total_case += self.exec_case if self.total_case < self.exec_case else self.total_case
        stats = self.get_table_title("Tests Statistics")
        stats += '<table  BORDER=1 CELLSPACING=0 style="text-align:center; width:800px"><tr>'
        stats += '<th ALIGN=center bgcolor=#CECECE>Num TCs</th>'
        stats += '<th ALIGN=center bgcolor=#CECECE>Passed</th>'
        stats += '<th ALIGN=center bgcolor=#CECECE>Failed</th>'
        stats += '<th ALIGN=center bgcolor=#CECECE>Executed</th>'
        stats += '<th ALIGN=center bgcolor=#CECECE>Not Run</th>'
        stats += '<th ALIGN=center bgcolor=#CECECE>Status</th></tr>'
        td = '<tr><td>{}</td><td>'.format(self.total_case)
        pc = '<FONT color="green"><b>{}</b>'.format(self.pass_case)
        fc = '</FONT></td><td><FONT color="red"><b>{}</b>'.format(self.fail_case)
        stats += '{}{}{}</FONT></td><td>{}</td><td>{}</td>'.format(
            td, pc, fc, self.exec_case, self.not_run)
        if int(self.fail_case) == 0:
            self.ET_status = 1
            stats += '<th><FONT color="green">PASS</FONT></th></tr></table><br/><br/>'
        else:
            self.ET_status = 0
            stats += '<th><FONT color="red">FAIL</FONT></th></tr></table><br/><br/>'
        return stats

    def html_table_TC_head(self):
        tc_head = self.get_table_title("Tests Cases Details")
        tc_head += '<table  BORDER=1 CELLSPACING=0 style="text-align:center; width:800px" ><tr>'
        tc_head += '<th ALIGN=center bgcolor=#CECECE> Type</th>'
        tc_head += '<th ALIGN=center bgcolor=#CECECE> Test Case</th>'
        tc_head += '<th ALIGN=center bgcolor=#CECECE> Status</th>'
        # tc_head += '<th ALIGN=center bgcolor=#CECECE> Pronto</th>'
        tc_head += '</tr>'
        return tc_head

    def get_tc_type(self, tc_name):
        if tc_name.startswith("[1]"):
            return "Test"
        return "Step"

    def get_tc_color(self, tc_status):
        if tc_status == "PASS":
            self.exec_case += 1
            self.pass_case += 1
            return "green"
        elif tc_status == "FAIL":
            self.exec_case += 1
            self.fail_case += 1
            return "red"
        else:
            self.not_run += 1
            self.total_case += 1
            return "silver"

    def html_table_TC_entry(self, tc_name, tc_status, tc_pronto=" "):
        tc_type = self.get_tc_type(tc_name)
        tc_color = self.get_tc_color(tc_status)
        if tc_type == 'Test':
            entry = "<tr><td>{}</td>".format(tc_type)
            entry += "<td ALIGN=LEFT BGCOLOR={}><b>{}</b></td>".format(tc_color, tc_name)
            entry += "<td BGCOLOR={}><b>{}</b></FONT></td>".format(tc_color, tc_status)
        else:
            entry = "<tr><td>{}</td>".format(tc_type)
            entry += "<td ALIGN=LEFT>{}</td>".format(tc_name)
            entry += "<td><FONT color={}>{}</FONT></td>".format(tc_color, tc_status)
        entry += "</tr>"
        return entry

    def html_table_TC_suite(self, suite_name):
        suite = "<tr><td ALIGN=LEFT COLSPAN=2 bgcolor=#EFEFEF >%s:</td></tr><tr><td></td></tr>" % suite_name
        return suite

    def html_table_case_ET_details(self, input_xml):
        details = ""
        tree = et.parse(input_xml)
        root = tree.getroot()
        id = 1
        '''Get Suite  Duration'''
        for suite in root.iter('suite'):
            start_time = suite.find('status').attrib['starttime']
            end_time = suite.find('status').attrib['endtime']
            start_time_formate = datetime.strptime(start_time, '%Y%m%d %H:%M:%S.%f')
            end_time_formate = datetime.strptime(end_time, '%Y%m%d %H:%M:%S.%f')
            duration = end_time_formate - start_time_formate
            dur_str = str(duration)
            if duration.days != 0:
                self.duration += str(duration.days) + ' days, '
                dur_str = dur_str.split(',')[1]
            dur_list = dur_str.split(':')
            self.duration += dur_list[0] + ' hours, ' + dur_list[1] + ' minutes, and ' + dur_list[2].split('.')[0]
            self.duration += ' seconds'
            print("Duration: {}".format(self.duration))
            break

        # spec_keyword = ['run keyword and', 'run keyword if', 'wait until keyword', 'sleep', 'for', 'foritem']
        try:
            for testsuite in root.iter('test'):
                print("==== test name= {} {}".format(testsuite.attrib['name'],
                                                     testsuite.find('status').attrib['status']))
                id = id + 1
                if id > 1:
                    details += self.html_table_TC_entry(testsuite.attrib['name'],
                                                        testsuite.find('status').attrib['status'])
        except Exception:
            print("Skipping exception: {}".format(sys.exc_info()[0]))
        return details

    def html_table_case_FT_details(self, input_xml_list):
        details = ""
        for input_xml in input_xml_list:
            tree = et.parse(input_xml)
            root = tree.getroot()
            id = 1
            # spec_keyword = ['run keyword and', 'run keyword if', 'wait until keyword', 'sleep', 'for', 'foritem']
            try:
                for testsuite in root.iter('suite'):
                    print("==== suite name= {}".format(testsuite.attrib['name']))
                    id = id + 1
                    if id > 1:
                        details += self.html_table_TC_suite(testsuite.attrib['name'])
                        for testcase in testsuite.iter('test'):
                            if not (list(dict(list(testcase.items())).keys()).__contains__("library") or list(dict(
                                    list(testcase.items())).keys()).__contains__("type")):
                                print("***** test name = {}".format(testcase.attrib['name']))
                                details += self.html_table_TC_entry(testcase.attrib['name'],
                                                                    testcase.find('status').attrib['status'])
                                # return details
            except Exception:
                continue
                print("Skipping exception {}".format(sys.exc_info()[0]))
        return details

    def html_table_TC_style(self):
        style = "<style> " + "table, td { color: black; font-family: Arial; font-size: 10pt; } " + \
                "th { color: black; font-family: Arial; font-size: 11pt; }" + "</style>"
        return style

    def html_log(self):
        log = "<br></br>"+self.get_table_title("Logs")
        log += '<font face="Calibri"><b>Build CRT Logs: </b><a href="{}">here</a></font><br/>'.format(self.logs)
        return log

    def html_regards(self):
        testline = "<br/><font face='Calibri'> Regards,</font><br/>"
        testline += "<font face='Calibri'> CRT team</font><br/>"
        return testline

    def html_page_creation(self):
        case_details = self.html_table_case_ET_details(self.output_file)
        stats = self.html_table_stats()
        html_body = "<body>" + self.html_header() + stats
        html_page = "<html>" + html_body + self.html_table_TC_head() + case_details + "</table>" + \
                    self.html_log() + self.html_regards() + "</body>" + "</html>"
        return html_page

    def set_properties(self):
        property_content = "ET_NB_TOTAL_TEST=%d\n" % self.total_case
        property_content += "ET_NB_EXECUTED_TEST=%d\n" % self.exec_case
        property_content += "ET_NB_PASSED_TEST=%d\n" % self.pass_case
        property_content += "ET_NB_FAILED_TEST=%d\n" % self.fail_case
        property_content += "ET_STATUS=%d\n" % self.ET_status
        return property_content


if __name__ == '__main__':
    report = HtmlReport(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4],
                        sys.argv[5], sys.argv[6], sys.argv[7], sys.argv[8],
                        sys.argv[9], sys.argv[10], sys.argv[11], sys.argv[12],
                        sys.argv[13], sys.argv[14])
    with open("./ci_report.html", "w") as output_file:
        output_file.write(report.html_page_creation())
    with open("./internal_info", "w") as properties_file:
        properties_file.write(report.set_properties())
