/*  HISTORY *************************************************************
15/Nov/2005 16:30 - Initial Release
16/Nov/2005 16:00 - Add traffic duration parameter d
25/Nov/2005 09:10 - Tune Uplink traffic
01/Dec/2005 13:10 - Fix bug for infinite duration
05/Dec/2005 15:10 - Add UL rate display
01/Feb/2006 15:40 - MAX_TIME is now 3 days
03/Feb/2006 14:30 - Add indication of how many packet lost
17/Feb/2006 10:00 - More indication of how many packet lost
02/Mar/2006 16:00 - Increase receive buffer to 200kB
05/Jun/2006 12:00 - Automatic calculation of DL packet size (optional)
20/Jun/2006 12:00 - Automatic calculation of IP Address
20/Jul/2006 11:00 - Change MAX UDP size to 1400 bytes
02/Mar/2007 04:00 - Display a 10 seconds averaging on DL rate
24/Sep/2007 03:00 - UL rate feedback to Mobile
20/Jan/2008 03:00 - Auto rate feedback
31/Jan/2008 22:00 - Correction if rate is null
16/Jun/2008 23:00 - Correction if dlPeriod is not null
11/May/2009 12:00 - Add one parameter for time print (h=1)
15/Sep/2010 12:00 - Unit is now 0.1ms
19/Nov/2010 12:00 - Small length for UL message
18/Jul/2012 12:00 - Option c=0 to avoid route creation
04/Dec/2012 10:00 - Correction for rate greater than 110Mbs
10/Dec/2012 16:00 - Enlarge send socket buffer
04/Apr/2013 06:00 - Ul Rate is displayed as 0 if there is no DL data
05/Apr/2013 10:00 - Packet Loss takes into account all packets
26/Sep/2013 15:00 - Max time is now 4 days
31/Dec/2015 14:00 - Protect critical variables with mutex
08/Feb/2022 08:00 - Version now managed in git
*************************************************************************/
#define CURR_VERSION "managed in git"

#include <sys/timeb.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "udpServer.hpp"

void* ThreadProc(void* arg);

char recvBuff[65535];

unsigned long gMobileMsgType = MSG_MOBILE;
mobileMsg_t gMobileMsg;
mobileSmlMsg_t gMobileSmlMsg;

sem_t gMutex;
unsigned long gNbRecvBytes = 0;
unsigned long gNbRecvPkts = 0;
unsigned long gNbLostPkts = 0;
unsigned long gCumulDeltaTimeUs = 0;
unsigned long gCumulNbSample = 0;
unsigned long gUlRateKbps = 0;
bool gPrintAllowed = true;
bool gTraceEnabled = false;

unsigned long getTimeUs()
{
    static timespec iniTime;
    static BOOL timeInitialized = FALSE;
    unsigned long timeUs;
    timespec currentTime;

    if (timeInitialized == FALSE)
    {
        clock_gettime(CLOCK_REALTIME, &iniTime);
        timeInitialized = TRUE;
    }

    clock_gettime(CLOCK_REALTIME, &currentTime);
    timeUs = (currentTime.tv_sec - iniTime.tv_sec) * nbUsIn1sec + currentTime.tv_nsec / nbNanoIn1us;
    // printf("\timeUs %lu", timeUs);
    return (timeUs);
}


unsigned long getPeriodUs(unsigned long packetSizeInBytes, unsigned long rateKbps)
{
    unsigned long packetSizeInBits = 8 * packetSizeInBytes;
    unsigned long numberOfBitsPerSecond = rateKbps * 1000;
    unsigned long periodUs = (packetSizeInBits * nbUsIn1sec) / numberOfBitsPerSecond;
    return (periodUs);
}


unsigned long getPacketSizeBytes(unsigned long rateKbps, unsigned long periodUs)
{
    unsigned long numberOfBitsPerSecond = rateKbps * 1000;
    unsigned long packetSizeInBits = (numberOfBitsPerSecond * periodUs) / nbUsIn1sec;
    return (packetSizeInBits / 8);
}


unsigned long getRateKbps(unsigned long numberOfBytes, unsigned long timeUs)
{
    unsigned long numberOfBits = numberOfBytes * 8;
    unsigned long rateInBitsPerSecond = (numberOfBits * nbUsIn1sec) / timeUs;
    return (rateInBitsPerSecond / 1000);
}


int main(int argc, char* argv[])
{
    SOCKET socketId;
    SOCKADDR_IN destinationInfo;
    int errorCode;
    int msgLg;
    pthread_t ThreadId;
    int dlRateKbs = 500000;
    unsigned long dlPeriodUs = 0, configDlPeriodUs = 0, autoFeedbackDlPeriodUs;
    unsigned long ulRateKbs = 10;
    unsigned long ulPeriodUs = 100000;
    unsigned int printTime = 0;
    unsigned long durationUs = 0;
    int firstTimePassed = 0;
    int autoFeedback = 1, createRoute = 1;
    char addr[20];
    char outRas[50];
    unsigned long dlPacketSizeBytes = 1000, autoFeedbackDlPacketSizeBytes;
    unsigned long ulPacketSizeBytes = 100;
    unsigned long currTimeUs = 0, lastTimeRateCalcUs = 0;
    serverMsg_t serverMsg;
    unsigned long lastRttUs = 1000;
    unsigned long nextSndTimeUs = 0;
    double cumulSampleAve, maxSampleAve, autoFeedbackDlRateKbs;
    double sampleAve[10];
    unsigned long currentSampleAve, sampleAveIdx, nbSampleAve = 0;
    FILE* fin;
    char tmpStr[200];
    char tmpStr2[200];
    int tmpInt1, tmpInt2, tmpInt3, tmpInt4;
    u_long iMode = 1;
    int iOptVal;
    int iOptLen = sizeof(int);

    printf("\n---------------------------------------------------------------------------\n");
    printf("Running udpClient Version: %s\n", CURR_VERSION);
    printf("Please send feedback to fabrice.delecroix@alcatel-lucent.com\n");
    printf("---------------------------------------------------------------------------\n\n");

    sem_init(&gMutex, 0, 1);

    for (currentSampleAve = 0; currentSampleAve < 10; currentSampleAve++)
        sampleAve[currentSampleAve] = 0;

    strcpy(addr, "72.23.0.1");
    strcpy(outRas, "");
    strcpy(gMobileMsg.ipAddr, "000.000.000.000");
    gMobileMsg.port = 10001;

    pthread_create(&ThreadId, NULL, &ThreadProc, NULL);

    for (int i = 1; i < argc; i++)
    {
        switch (argv[i][0])
        {
        case 'a':
        {
            if (sscanf(argv[i], "a=%d", &autoFeedback) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'c':
        {
            if (sscanf(argv[i], "c=%d", &createRoute) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'd':
        {
            unsigned long parameterValue = 0;
            if (sscanf(argv[i], "d=%lu", &parameterValue) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            durationUs = parameterValue * nbUsIn1sec;
            break;
        }
        case 'h':
        {
            if (sscanf(argv[i], "h=%lu", &printTime) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'i':
        {
            if (sscanf(argv[i], "i=%lu", &configDlPeriodUs) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'm':
        {
            if (sscanf(argv[i], "m=%s", &gMobileMsg.ipAddr) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'p':
        {
            if (sscanf(argv[i], "p=%lu", &gMobileMsg.port) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'q':
        {
            if (sscanf(argv[i], "q=%s", &outRas) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'r':
        {
            if (sscanf(argv[i], "r=%lu", &dlRateKbs) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 's':
        {
            if (sscanf(argv[i], "s=%s", &addr) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 't':
        {
            int parameterValue = 0;
            if (sscanf(argv[i], "t=%d", &parameterValue) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            gTraceEnabled = (parameterValue == 1);
            break;
        }
        case 'u':
        {
            if (sscanf(argv[i], "u=%lu", &ulRateKbs) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        case 'v':
        {
            if (sscanf(argv[i], "v=%lu", &ulPeriodUs) != 1)
            {
                fprintf(stderr, "Parsing error in %s\n", argv[i]);
            }
            break;
        }
        default:
        {
            fprintf(stderr, "Unrecognized keyword %s\n", argv[i]);
            break;
        }
        }
    }

    if (strlen(outRas) > 0)
    {
        printf("NOT SUPPORTED at line %u", __LINE__);
        return (1);
    }

    if ((strcmp(gMobileMsg.ipAddr, "000.000.000.000") != 0) && (createRoute == 1))
    {
        printf("NOT SUPPORTED at line %u", __LINE__);
        return (1);
        /*		sprintf(tmpStr, "route delete %s", addr);
                printf("%s\n", tmpStr);
                system(tmpStr);

                sprintf(tmpStr, "route -p add %s %s", addr, gMobileMsg.ipAddr);
                printf("%s\n", tmpStr);
                system(tmpStr);*/
    }

    if ((durationUs > MAX_DURATION_US) || (durationUs == 0))
    {
        durationUs = MAX_DURATION_US;
    }

    if (ulPeriodUs == 0)
    {
        if (ulRateKbs != 0)
        {
            ulPeriodUs = getPeriodUs(OPTIM_UDP_PACKET_SIZE, ulRateKbs);
        }
        else
        {
            ulPeriodUs = 1000;
        }
    }

    dlPeriodUs = configDlPeriodUs;

    if (configDlPeriodUs == 0)
    {
        if (dlRateKbs != 0)
        {
            dlPeriodUs = getPeriodUs(OPTIM_UDP_PACKET_SIZE, dlRateKbs);
            printf("dlPeriodUs %lu\n", dlPeriodUs);

            // Case where dlRateKbs is too high
            if (dlPeriodUs < 1)
            {
                dlPeriodUs = 1;
            }
        }
        else
        {
            dlPeriodUs = 1000;
        }
    }

    dlPacketSizeBytes = getPacketSizeBytes(dlRateKbs, dlPeriodUs);
    ulPacketSizeBytes = getPacketSizeBytes(ulRateKbs, ulPeriodUs);

    if (dlPacketSizeBytes == 0)
    {
        dlPacketSizeBytes = sizeof(serverMsg) - sizeof(serverMsg.buffer);
        dlPeriodUs = MAX_DURATION_US;
    }

    if (dlPacketSizeBytes < (sizeof(serverMsg) - sizeof(serverMsg.buffer)))
    {
        printf(
            "Not enough Bytes per Packet in DL direction, minimum is %d Bytes\n",
            (sizeof(serverMsg) - sizeof(serverMsg.buffer)));
        return (1);
    }

    if (ulPacketSizeBytes == 0)
    {
        ulPacketSizeBytes = sizeof(gMobileSmlMsg) - sizeof(gMobileSmlMsg.buffer);
        ulPeriodUs = MAX_DURATION_US;
    }

    if (ulPacketSizeBytes < (sizeof(gMobileMsg) - sizeof(gMobileMsg.buffer)))
    {
        gMobileMsgType = MSG_MOBSML;
        printf("\nSwitching to small UL message length\n");
    }

    if (ulPacketSizeBytes < (sizeof(gMobileSmlMsg) - sizeof(gMobileSmlMsg.buffer)))
    {
        printf(
            "Not enough Bytes per Packet in UL direction, minimum is %d Bytes\n",
            (sizeof(gMobileSmlMsg) - sizeof(gMobileSmlMsg.buffer)));
        return (1);
    }

    printf("\nWill configure server %s for %.1f s of traffic:\n", addr, float(durationUs) / nbUsIn1sec);
    printf("\t* Mobile %s:%lu\n", gMobileMsg.ipAddr, gMobileMsg.port);
    printf("\t* DL %lu kbps\n", dlRateKbs);
    printf(
        "\t* DL %lu bytes / %lu us\n\t* DL %lu bits / %lu us\n",
        dlPacketSizeBytes,
        dlPeriodUs,
        dlPacketSizeBytes * 8,
        dlPeriodUs);
    printf("\t* UL %lu kbps\n", ulRateKbs);
    printf(
        "\t* UL %lu bytes / %lu us\n\t* UL %lu bits / %lu us\n\n",
        ulPacketSizeBytes,
        ulPeriodUs,
        ulPacketSizeBytes * 8,
        ulPeriodUs);

    socketId = socket(AF_INET, SOCK_DGRAM, 0);
    if (socketId == INVALID_SOCKET)
    {
        // printf("\nSorry, can not open Socket, error : %d : %d",WSAGetLastError());
        printf("\nSorry, can not open Socket");
        return (1);
    }

    // if (ioctlsocket(socketId, FIONBIO, &iMode) != 0)
    //	printf("\nFailed to set non-blocking mode\n");

    iOptVal = 1000000;

    if (setsockopt(socketId, SOL_SOCKET, SO_SNDBUF, (char*)&iOptVal, iOptLen) == SOCKET_ERROR)
    {
        printf("Not able to enlarge send buffer to %d,", iOptVal);
    }
    else
    {
        printf("\nSocket created with send buffer enlarged to %d\n", iOptVal);
    }

    destinationInfo.sin_family = AF_INET;
    destinationInfo.sin_addr.s_addr = inet_addr(addr);
    destinationInfo.sin_port = htons((unsigned short)SERVER_PORT);

    serverMsg.h.msgType = MSG_SERVER;
    gMobileMsg.h.msgType = gMobileMsgType;
    gMobileMsg.h.loc.sequenceNumber = 0;
    gMobileMsg.dist.sequenceNumber = 0;
    gMobileMsg.dist.timeUs = 0;
    gMobileMsg.packetSizeInBytes = dlPacketSizeBytes;
    gMobileMsg.periodUs= dlPeriodUs;
    gMobileMsg.remainDurationUs = 2 * ulPeriodUs + 5 * nbUsIn1sec;

    usleep(900000);

    // SetTimer(NULL,NULL,4,NULL);

    currTimeUs = getTimeUs();

    if (printTime == 1) printf("\nInit Time = %ld seconds since 1970\n", time(NULL));

    lastTimeRateCalcUs = currTimeUs;
    nextSndTimeUs = 0;
    autoFeedbackDlRateKbs = (float)dlRateKbs;

    // while(GetMessage(&msg,NULL,0,0))
    while (1)
    {
        usleep(500);
        // printf("*");
        // if(msg.message==WM_TIMER)
        if (1)
        {
            currTimeUs = getTimeUs();
            gMobileMsg.h.loc.timeUs = currTimeUs;

            if (currTimeUs >= durationUs)
            {
                printf("\nEnding");
                break;
            }

            if ((durationUs - currTimeUs) < gMobileMsg.remainDurationUs)
                gMobileMsg.remainDurationUs = durationUs - currTimeUs;

            while ((nextSndTimeUs <= currTimeUs) || (nextSndTimeUs == 0))
            {
                msgLg = sendto(
                            socketId,
                            (char*)&gMobileMsg,
                            ulPacketSizeBytes,
                            0,
                            (struct sockaddr*)&destinationInfo,
                            sizeof(destinationInfo));

                if (msgLg == SOCKET_ERROR)
                {
                    // errorCode = WSAGetLastError();
                    // if (errorCode != WSAEWOULDBLOCK)
                    // printf("\nCannot send due to errorCode: %d", errorCode);
                    printf("\nCannot send");
                }

                gMobileMsg.h.loc.sequenceNumber++;

                if (nextSndTimeUs == 0)
                    nextSndTimeUs = currTimeUs + ulPeriodUs;
                else
                    nextSndTimeUs += ulPeriodUs;
            }

            if (currTimeUs - lastTimeRateCalcUs > nbUsIn1sec)
            {
                gPrintAllowed = false;

                currentSampleAve = (currentSampleAve + 1) % 10;
                cumulSampleAve = 0;

                if (nbSampleAve < 10) nbSampleAve++;

                sampleAve[currentSampleAve] = getRateKbps(gNbRecvBytes, currTimeUs - lastTimeRateCalcUs);

                maxSampleAve = 10;

                for (sampleAveIdx = 0; sampleAveIdx < 10; sampleAveIdx++)
                {
                    cumulSampleAve += sampleAve[sampleAveIdx];
                    if (maxSampleAve < sampleAve[sampleAveIdx]) maxSampleAve = sampleAve[sampleAveIdx];
                }

                // printf("\n");

                if (printTime == 1)
                    sprintf(tmpStr, "\ntime=%lu us ", currTimeUs);
                else
                    sprintf(tmpStr, "\n#%u ", gMobileMsg.port % 10);

                sprintf(
                    tmpStr2,
                    "%sUL %07luk, DL %08.1fk (av %08.1fk)",
                    tmpStr,
                    gUlRateKbps,
                    sampleAve[currentSampleAve],
                    cumulSampleAve / nbSampleAve);

                // printf(tmpStr2);

                                /*if ((autoFeedback == 1) && (nbSampleAve >= 10))
                                {
                                    //autoFeedbackDlRateKbs = (float)dlRateKbs;
                                    autoFeedbackDlRateKbs = 1.05 * maxSampleAve;
                                    autoFeedbackDlPeriodUs = configDlPeriodUs;

                                    if (autoFeedbackDlRateKbs > (1.05 * maxSampleAve))
                                    {
                                        autoFeedbackDlRateKbs = (1.05 * maxSampleAve);
                                    }

                                    if (configDlPeriodUs == 0)
                                    {
                                        if (autoFeedbackDlRateKbs != 0)
                                        {
                                            autoFeedbackDlPeriodUs = getPeriodUs(OPTIM_UDP_PACKET_SIZE, (unsigned long)autoFeedbackDlRateKbs);

                                            // Case where dlRateKbs is too high
                                            if (autoFeedbackDlPeriodUs == 0)
                                            {
                                                autoFeedbackDlPeriodUs = 1;
                                            }
                                        }
                                        else
                                        {
                                            autoFeedbackDlPeriodUs = 1000;
                                        }
                                    }

                                    autoFeedbackDlPacketSizeBytes = getPacketSizeBytes((unsigned long)autoFeedbackDlRateKbs, autoFeedbackDlPeriodUs);

                                    if (autoFeedbackDlPacketSizeBytes < (sizeof(serverMsg) - sizeof(serverMsg.buffer)))
                                        autoFeedbackDlPacketSizeBytes = sizeof(serverMsg) - sizeof(serverMsg.buffer);

                                    gMobileMsg.packetSizeInBytes = autoFeedbackDlPacketSizeBytes;
                                    gMobileMsg.periodUs= autoFeedbackDlPeriodUs;
                                    printf(" autoFeedbackDlRateKbs=%d, autoFeedbackDlPacketSizeBytes=%lu, autoFeedbackDlPeriodUs=%lu, \
                                    maxSampleAve=%d", 	(int)autoFeedbackDlRateKbs, autoFeedbackDlPacketSizeBytes, \
                                    autoFeedbackDlPeriodUs, (int)maxSampleAve);
                                } */

                if ((autoFeedback == 1) && (nbSampleAve >= 10))
                {
                    float lossRatePercent = ((float)100 * gNbLostPkts) / (gNbLostPkts + gNbRecvPkts);
                    // autoFeedbackDlRateKbs = (float)dlRateKbs;
                    autoFeedbackDlPeriodUs = configDlPeriodUs;
                    // float currentDlRateKbps = ((float)gNbRecvBytes * 80) / (currTimeUs - lastTimeRateCalcUs);

                    if (lastRttUs < 2*nbUsIn1sec)
                    {
                        // printf(" + %u %.01f ", lastRttUs/10, lossRatePercent);
                        printf(" + ");
                        autoFeedbackDlRateKbs = 1.05 * autoFeedbackDlRateKbs;
                    }
                    else
                    {
                        // printf(" - %u %.01f ", lastRttUs/10, lossRatePercent);
                        printf(" - ");
                        // autoFeedbackDlRateKbs = 0.99 * ((float)gNbRecvBytes * 80) / (currTimeUs -
                        // lastTimeRateCalcUs);
                        autoFeedbackDlRateKbs = 0.99 * autoFeedbackDlRateKbs;
                    }

                    if (autoFeedbackDlRateKbs > (1.05 * maxSampleAve))
                    {
                        autoFeedbackDlRateKbs = (1.05 * maxSampleAve);
                    }

                    if (autoFeedbackDlRateKbs < 200)
                    {
                        autoFeedbackDlRateKbs = 200;
                    }

                    if (configDlPeriodUs == 0)
                    {
                        if (autoFeedbackDlRateKbs != 0)
                        {
                            autoFeedbackDlPeriodUs = getPeriodUs(OPTIM_UDP_PACKET_SIZE, (unsigned long)autoFeedbackDlRateKbs);

                            // Case where dlRateKbs is too high
                            if (autoFeedbackDlPeriodUs == 0)
                            {
                                autoFeedbackDlPeriodUs = 1;
                            }
                        }
                        else
                        {
                            autoFeedbackDlPeriodUs = 100;
                        }
                    }

                    autoFeedbackDlPacketSizeBytes = getPacketSizeBytes((unsigned long)autoFeedbackDlRateKbs, autoFeedbackDlPeriodUs);

                    if (autoFeedbackDlPacketSizeBytes < (sizeof(serverMsg) - sizeof(serverMsg.buffer)))
                        autoFeedbackDlPacketSizeBytes = sizeof(serverMsg) - sizeof(serverMsg.buffer);

                    gMobileMsg.packetSizeInBytes = autoFeedbackDlPacketSizeBytes;
                    gMobileMsg.periodUs= autoFeedbackDlPeriodUs;
                    printf(
                        " autoFeedbackDlRateKbs=%lu, autoFeedbackDlPacketSizeBytes=%lu, autoFeedbackDlPeriodUs=%lu, "
                        "maxSampleAve=%lu",
                        (unsigned long)autoFeedbackDlRateKbs,
                        autoFeedbackDlPacketSizeBytes,
                        autoFeedbackDlPeriodUs,
                        (unsigned long)maxSampleAve);
                }

                if (gCumulNbSample != 0)
                {
                    lastRttUs = (gCumulDeltaTimeUs) / gCumulNbSample;
                    sprintf(tmpStr, "%s, RTT %06lums", tmpStr2, lastRttUs/1000);
                    gCumulNbSample = 0;
                }
                else
                {
                    sprintf(tmpStr, "%s, RTT ------ms", tmpStr2);
                }

                if ((gNbRecvPkts != 0) && (firstTimePassed == 1))
                {
                    sprintf(
                        tmpStr2,
                        "%s, Loss %06.02f%%",
                        tmpStr,
                        ((float)100 * gNbLostPkts) / (gNbLostPkts + gNbRecvPkts));
                }
                else
                {
                    sprintf(tmpStr2, "%s, Loss ------%%", tmpStr);
                }

                printf("%s", tmpStr2);
                lastTimeRateCalcUs = currTimeUs;
                firstTimePassed = 1;

                sem_wait(&gMutex);
                gNbRecvBytes = 0;
                gNbRecvPkts = 0;
                gNbLostPkts = 0;
                gUlRateKbps = 0;
                gPrintAllowed = true;
                sem_post(&gMutex);
            }
        }
    }

    usleep(lastRttUs);

    return 0;
}

void* ThreadProc(void* arg)
{
    SOCKET socketId;
    SOCKADDR_IN senderInfo;
    unsigned int tempo;
    int errorCode;
    int msgLg;
    serverMsg_t* rcvMsg;
    unsigned long packNb = 0;
    int unkMsgNb = 0;
    unsigned long currTimeUs;
    unsigned long lastPacketReturned = 0;
    int iOptVal;
    int iOptLen = sizeof(int);

    usleep(500000);

    printf("\nChild activation OK...\n");

    socketId = socket(AF_INET, SOCK_DGRAM, 0);
    if (socketId == INVALID_SOCKET)
    {
        printf("\nSorry, can not open Socket");
        //        printf("\nSorry, can not open Socket, error : %d",WSAGetLastError());
        // return(&socketId);
    }

    senderInfo.sin_family = AF_INET;
    senderInfo.sin_addr.s_addr = INADDR_ANY;
    senderInfo.sin_port = htons((unsigned short)gMobileMsg.port);
    errorCode = bind(socketId, (struct sockaddr*)&senderInfo, sizeof(senderInfo));
    if (errorCode != 0)
    {
        printf("\nSorry, can not listen on this port : %d", gMobileMsg.port);
        //        printf("\nSorry, can not listen on this port : %d %d",errorCode,WSAGetLastError());
        //		exit(1);
    }

    tempo = sizeof(senderInfo);

    /* if (getsockopt(socketId, SOL_SOCKET, SO_RCVBUF, (char*)&iOptVal, &iOptLen) != SOCKET_ERROR)
    {
        printf("Trying to increase Rcv Buffer from %d,", iOptVal);
    } */

    iOptVal = 1000000;

    if (setsockopt(socketId, SOL_SOCKET, SO_RCVBUF, (char*)&iOptVal, iOptLen) == SOCKET_ERROR)
    {
        printf("Not able to enlarge recv buffer to %d,", iOptVal);
    }

    rcvMsg = (serverMsg_t*)&recvBuff[0];

    while (1)
    {
        msgLg = recvfrom(socketId, &recvBuff[0], 65535, 0, (struct sockaddr*)&senderInfo, &tempo);

        switch (rcvMsg->h.msgType)
        {
        case MSG_SERVER:
        {
            unsigned long waitedPackNb = packNb + 1;
            unsigned long recvPackNb = rcvMsg->h.loc.sequenceNumber;

            sem_wait(&gMutex);

            if (recvPackNb > waitedPackNb)
            {
                if ((gPrintAllowed and gTraceEnabled) || 0)
                {
                    printf(
                        "\nHole in packet number, waited = 0x%08lX, received = 0x%08lX, Delta = %ld\n",
                        waitedPackNb,
                        recvPackNb,
                        recvPackNb - waitedPackNb);
                }
                gNbLostPkts += (recvPackNb - waitedPackNb);
                packNb = recvPackNb;
                gMobileMsg.dist = rcvMsg->h.loc;
            }
            else
            {
                if (recvPackNb < waitedPackNb)
                {
                    if ((gPrintAllowed and gTraceEnabled) || 0)
                    {
                        printf(
                            "\nGoing back in packet number, waited = 0x%08lX, Received = 0x%08lX",
                            waitedPackNb,
                            recvPackNb);
                    }
                }
                else
                {
                    packNb = recvPackNb;
                    gMobileMsg.dist = rcvMsg->h.loc;
                }
            }

            gNbRecvPkts += 1;
            gNbRecvBytes += msgLg;
            gUlRateKbps = rcvMsg->ulRateKbps;

            if (lastPacketReturned != rcvMsg->dist.sequenceNumber)
            {
                currTimeUs = getTimeUs();

                if (gCumulNbSample == 0) gCumulDeltaTimeUs = 0;

                // printf("\nSent %lu, Recv %lu\n", rcvMsg->dist.time, currTimeUs);

                if (currTimeUs >= rcvMsg->dist.timeUs)
                {
                    gCumulDeltaTimeUs += (currTimeUs - rcvMsg->dist.timeUs);
                    gCumulNbSample++;
                }

                lastPacketReturned = rcvMsg->dist.sequenceNumber;
            }

            sem_post(&gMutex);
            break;
        }
        default:
        {
            unkMsgNb++;

            if (unkMsgNb == 100)
            {
                printf("\n100 Unknown messages received\n");
                unkMsgNb = 0;
            }
            break;
        }
        }
    }

    return 0;
}
