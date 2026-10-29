from taf.analyzer.netconf import NetconfLogReader, Notification, \
    Rpc, RpcRequest, RpcReply, HelloRequest, HelloReply
from lxml import etree
from datetime import datetime
import re

mtype = {"rpc": RpcRequest, "rpc-reply": RpcReply, "notification": Notification,
         "hellorequest": HelloRequest, "helloreply": HelloReply}


def _xml_iter(log_entry, parameter, subtag='', value=''):
    final_dict = {}
    matched = []
    for i in log_entry.message.xml.iter():
        if parameter and parameter == i.tag:
            if subtag:
                for j in i.xpath(".//"+subtag):
                    if value:
                        if value == j.text:
                            matched.append(j.text)
                    else:
                        matched.append(j.text)
                final_dict[i.tag] = matched
            else:
                if value:
                    if value == i.text:
                        final_dict[i.tag] = i.text
                else:
                    final_dict[i.tag] = i.text
        elif parameter == '':
            final_dict[i.tag] = i.text
    return final_dict


def netconf_get_message_id(file_path, tag, value=''):
    """
    This function returns message id of rpc message
    Arguments:
        file_path: provide file path of the log
        tag: provide root tag for which message id is required
        value: provide the value of the tag
    """
    entrylist = []
    for log_entry in NetconfLogReader.from_file(file_path=file_path):
        message = log_entry.message
        if isinstance(message, mtype["rpc"]) and tag in message.operation:
            xml_entry = _xml_iter(log_entry, tag, '', '')
            if xml_entry:
                entrylist.append([message.id, "rpc", xml_entry])
    return entrylist


def validate_netconf_reply_message(file_path, rpctag, replytag, subtag='', value=''):
    """
    This function returns validates rpc message and reply message based on the input parameters
    it collects all the message id for the given tag and value
    Arguments:
        file_path: provide file path of the log
        rpctag: provide rpc root tag for which message id is required
        replytag: Provide the rpc-reply main tag
        subtag: provide the sub tag subtag
    """
    entrylist = []
    final_dict1 = {}
    rpc = netconf_get_message_id(file_path, rpctag, replytag)
    rpcr = [rpc[i][0] for i in range(0, len(rpc))]
    for log_entry in NetconfLogReader.from_file(file_path=file_path):
        if isinstance(log_entry.message, mtype["rpc-reply"]) \
                and str(log_entry.message.id) in rpcr:
            final_dict = _xml_iter(log_entry, replytag, subtag, value)
            for i, v in final_dict.items():
                if (('ok' not in i) and v):
                    final_dict1[i] = v
                else:
                    final_dict1 = final_dict
            if final_dict1:
                entrylist.append([log_entry.message.id, "reply", final_dict1])
    return entrylist


def netconf_get_value(file_path, messagetype, tag, subtag, value=''):
    """
    This function returns value of rpc message and reply message based on the input parameters
    Arguments:
        file_path: provide file path of the log
        messagetype: "rpc" or "rpc-reply" or "notification"
        tag: provide root tag for which message id is required
        subtag: provide the sub tag
    """
    valuelist = []
    for log_entry in NetconfLogReader.from_file(file_path=file_path):
        message = log_entry.message
        if messagetype == "rpc":
            if isinstance(message, mtype[messagetype]) and tag in message.operation:
                if ":" in subtag:
                    root = etree.fromstring(str(message))
                    tags = subtag.split(":")
                    matched = [re.match(r'(\{.*\})'+tags[1], child.tag)[0]
                               for child in root.iter() if re.match(r'(\{.*\})'+tags[1], child.tag)]
                    for i in matched:
                        text = root.findtext(".//"+i)
                        if text:
                            valuelist.append([message.id, text])
                else:
                    text = message.xml.findall(".//" + subtag)
                    if text:
                        elem_list = [elem.text for i in text for elem in i.iter() if elem.text]
                        valuelist.append([message.id, elem_list])
        elif messagetype == "rpc-reply" or messagetype == "notification":
            if isinstance(log_entry.message, mtype[messagetype]):
                text = message.xml.findtext(".//"+subtag)
                if text and messagetype == "notification":
                    valuelist.append([text])
                elif text:
                    if value:
                        if text == value:
                            valuelist.append([message.id, text])
                    else:
                        valuelist.append([message.id, text])
    return valuelist


def netconf_time_diff(file_path, messagetype="rpc", tag='', subtag=''):
    final_list = []
    msgid = ''
    for log_entry in NetconfLogReader.from_file(file_path=file_path):
        message = log_entry.message
        if isinstance(log_entry.message, mtype["rpc"]) and tag in message.operation:
            starttime = (re.search(r"(.*?)\+", str(log_entry))[0]).strip("+")
            if subtag:
                text = message.xml.findtext(".//" + subtag)
                if text:
                    msgid = log_entry.message.id
            else:
                msgid = log_entry.message.id
            try:
                starttime = datetime.strptime(starttime, "%Y-%m-%d %H:%M:%S.%f")
            except Exception as e:
                starttime = datetime.strptime(starttime, "%Y-%m-%d %H:%M:%S")
        if isinstance(log_entry.message, mtype["rpc-reply"]) and \
                str(msgid) == str(log_entry.message.id) and msgid:
            endtime = (re.search(r"(.*?)\+", str(log_entry))[0]).strip("+")
            try:
                endtime = datetime.strptime(endtime, "%Y-%m-%d %H:%M:%S.%f")
                print(msgid, str(log_entry.message.id))
            except Exception as e:
                endtime = datetime.strptime(endtime, "%Y-%m-%d %H:%M:%S")
            dt = endtime-starttime
            final_list.append([msgid, dt.total_seconds()])
    return (final_list)


def netconf_get_time(file_path, messagetype, tag):
    timestamp = []
    for log_entry in NetconfLogReader.from_file(file_path=file_path):
        message = log_entry.message
        if (isinstance(message, mtype[messagetype])
                and message.xml.findall(".//"+tag)):
            line = "{timestamp}".format(timestamp=log_entry.timestamp).split("+")[:-1]
            print(line)
            endtime = datetime.strptime(line[0], "%Y-%m-%d %H:%M:%S.%f")
            print(endtime)
            timestamp.append(endtime)
    return timestamp


def time_diff(date1, date2):
    if (isinstance(date1, str)):
        date1 = datetime.strptime(date1, '%Y-%m-%d %H:%M:%S.%f')
    if (isinstance(date2, str)):
        date2 = datetime.strptime(date2, '%Y-%m-%d %H:%M:%S.%f')
    a = date1-date2
    return int(a.total_seconds())
