messages_9103_B = [r'"F1AP:\s?IgNBCAUeContextModificationRequest"', r'"F1AP:\s?IgNBCAUeContextModificationResponse"',
                   r'"sCellToBeReleaseItem":\s?\[\n[\s{]{1,80}"nrCellId":\s?"816068"',
                   r'"XnAP:\s?IgNBCAAdditionRequestReject"',
                   r'"igNBCACause":[\n\s{]*"standardCause":[\s\n{]*"radioNetwork":\s"no-radio-resources-available"']

messages_9103_E = [r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,450}"physCellId":\s?60',
                   r'"physCellId": 415',
                   r'"sCellULConfigured":\s?"ul"']

messages_9103_G = [r'"sCellToAddModList":\s?\[\s[A-Za-z0-9\s{}":,]{10,450}"physCellId":\s?60',
                   r'"physCellId": 145',
                   r'"physCellId": 16',
                   r'"physCellId": 163',
                   r'"physCellId": 263']
