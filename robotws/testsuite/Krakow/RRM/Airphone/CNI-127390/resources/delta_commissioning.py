FAFs_activation = [
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [{
            "parameterName": "actRrcReconfProcessingDelay",
            "value": "true",
            "operation": "update"
        }]
    },
    {
        "distName": "MRBTS-1/NRBTS-1/NRCELLGRP-0",
        "operation": "update",
        "parameters": [{
            "parameterName": "actHighNumberOfUEs",
            "value": "true",
            "operation": "update"
        },
            {
                "parameterName": "nbActiveCarriersThreshold",
                "value": "200",
                "operation": "update"
            }]
    }
]
