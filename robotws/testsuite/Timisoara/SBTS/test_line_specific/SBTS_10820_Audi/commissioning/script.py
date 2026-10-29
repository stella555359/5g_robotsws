#!/usr/bin/env python3
# Copyright (c) 2025 Nokia. All rights reserved.

import os
import sys
import time
import array
from ccs.AaSysCom import *
from ccs.AaSysLog import *
from ccs.AaSysComMsg import AaSysComMsg
from ccs.AaSysComConnection import *
from env.ps.mcu.ApiSwdlServiceMsgs import *
from env.ps.mcu.EFileId import *
from env.bts.api_def import HWAPI_SWDL_SERVICE


def SetActiveSw(syscom, syslog):
    request = ApiOmSetActiveSwReq()
    request.file_id = 100  # invalid_file_id
    address = AaSysComSicadGet(HWAPI_SWDL_SERVICE, syscom.getOwnNid())
    req = AaSysComMsg(API_OM_SET_ACTIVE_SW_MSG, address, 0, request)
    syslog.info("Send API_OM_SET_ACTIVE_SW_MSG to 0x%X" % req.receiver)
    syscom.send(req)

    while True:
        syslog.info("Wait messages")
        resp = syscom.receive(5000000)

        if resp is not None:
            if resp.id == API_OM_SET_ACTIVE_SW_RESP_MSG:
                syslog.info("Received API_OM_SET_ACTIVE_SW_RESP_MSG from 0x%X" % resp.sender)
                response = ApiOmSetActiveSwResp(resp)
                print(resp)
                print(response)

                if response.success_code == 0:
                    syslog.info("set active sw succeed")
                else:
                    syslog.info("set active sw failed, status 0x%X" % response.success_code)

                return
            else:
                syslog.info("Received unknown message id = 0x%X" % resp.id)
        else:
            syslog.info("No response in time")
            break


if __name__ == '__main__':

    syslog = AaSysLog()
    connection = AaSysComConnection(mode=SYSCOM_CAPI_ENABLED, ip='192.168.255.1')
    syscom = AaSysCom(connection)

    SetActiveSw(syscom, syslog)

    time.sleep(1)
    syslog.info("Done")
    print("Exit")
