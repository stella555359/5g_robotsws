/*  HISTORY *************************************************************
15/Nov/2005 16:30 - Initial Release
16/Nov/2005 16:00 - Implement STOPMS message
25/Nov/2005 09:10 - Tune Uplink Traffic
07/Dec/2005 16:30 - Improve Start/Stop message display
01/Feb/2006 15:40 - Max Time is now 3 days
24/Sep/2007 03:00 - UL rate feedback to Mobile
01/Feb/2008 16:00 - Add debugging message
15/Jul/2010 14:00 - Unit is now 100us
21/Jan/2011 10:00 - Additional traces
02/Feb/2011 14:30 - Extend to 512 UE
07/Apr/2011 09:30 - Reinit time regularly
10/Dec/2012 18:00 - Enlarge receive buffer
08/Feb/2022 08:00 - Version now managed in git
*************************************************************************/
#define CURR_VERSION "managed in git"

#include <sys/timeb.h>
#include <arpa/inet.h>
#include <cstring>
#include <netinet/in.h>
#include <pthread.h>
#include <stdio.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>
#include "udpServer.hpp"

void* ThreadProc(void* arg);

char recvBuff[65535];

mobileInfo_t gMobile[MAX_MS];
int gNbMobile = 0;

serverMsg_t gServerMsg[10];

unsigned long gCurrTimeUs = 0;
BOOL gTimeInitialized = FALSE;

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

int main(int argc, char* argv[])
{
    SOCKET socketId;
    SOCKADDR_IN destinationInfo;
    int errorCode;
    int msgLength;
    pthread_t ThreadId;
    timerMsg_t timerMsg;

    printf("\n---------------------------------------------------------------------------\n");
    printf("Running udpServer Version: %s\n", CURR_VERSION);
    printf("Please send feedback to fabrice.delecroix@nokia.com\n");
    printf("---------------------------------------------------------------------------\n\n");

    pthread_create(&ThreadId, NULL, &ThreadProc, NULL);

    socketId = socket(AF_INET, SOCK_DGRAM, 0);
    if (socketId == INVALID_SOCKET)
        printf("\nCannot create socket");
    else
        printf("\nsocket      : OK");

    destinationInfo.sin_family = AF_INET;
    destinationInfo.sin_addr.s_addr = inet_addr("127.0.0.1");
    destinationInfo.sin_port = htons((unsigned short)SERVER_PORT);

    timerMsg.h.msgType = MSG_TIMER;
    timerMsg.h.loc.sequenceNumber = 0;
    timerMsg.h.loc.timeUs = 0;

    sleep(1);

    // SetTimer(NULL,NULL,4,NULL);

    while (1)
    {
        // printf("*");

        if (1)
        {
            // printf("-");

            msgLength = sendto(
                        socketId,
                        (char*)&timerMsg,
                        sizeof(timerMsg),
                        0,
                        (struct sockaddr*)&destinationInfo,
                        sizeof(destinationInfo));

            if (msgLength == SOCKET_ERROR) printf("\nCannot send data");

            timerMsg.h.loc.sequenceNumber++;
        }
        usleep(500);
    }

    return 0;
}

void _strtime(char* outTime)
{
    strcpy(outTime, "TBD");
}

void* ThreadProc(void* arg)
{
    SOCKET socketId;
    SOCKADDR_IN senderInfo;
    int errorCode;
    int msgLength;
    mobileMsg_t* rcvMsg;
    char sourceIp[20];
    int numberOfUnknownMsg = 0;
    int nbOfActiveMs = 0;
    char sysTime[128];
    int socketOption;
    socklen_t socketOptionLength = sizeof(socketOption);

    printf("\nChild activation OK...\n");

    for (int i = 0; i < 10; i++)
    {
        memset(&gServerMsg[i], i, sizeof(serverMsg_t));
        gServerMsg[i].h.msgType = MSG_SERVER;
    }

    socketId = socket(AF_INET, SOCK_DGRAM, 0);
    if (socketId == INVALID_SOCKET)
        printf("\nCannot create socket");
    else
        printf("\nsocket      : OK");

    socketOption = 10000000;
    if (setsockopt(socketId, SOL_SOCKET, SO_RCVBUF, (char*)&socketOption, socketOptionLength) == SOCKET_ERROR)
        printf("\nNot able to enlarge recv buffer to %d\n", socketOption);
    else
        printf("\nSocket created with recv buffer enlarged to %d\n", socketOption);

    senderInfo.sin_family = AF_INET;
    senderInfo.sin_addr.s_addr = INADDR_ANY;
    senderInfo.sin_port = htons((unsigned short)SERVER_PORT);
    errorCode = bind(socketId, (struct sockaddr*)&senderInfo, sizeof(senderInfo));
    if (errorCode != 0)
        printf("\nCannot listen this port: %d", SERVER_PORT);
    else
        printf("\nbind        : OK");

    socklen_t senderInfoLength = sizeof(senderInfo);

    rcvMsg = (mobileMsg_t*)&recvBuff[0];

    while (1)
    {
        msgLength = recvfrom(socketId, &recvBuff[0], 65535, 0, (struct sockaddr*)&senderInfo, &senderInfoLength);

        gCurrTimeUs = getTimeUs();

        // printf("-");

        switch (rcvMsg->h.msgType)
        {
        case MSG_TIMER:
        {
            // printf(".");
            // printf("%lu\n", gCurrTimeUs);
            bool dataHasBeenSent = true;
            int numberOfPacketSentOnOneTimer = 0;
            while (dataHasBeenSent)
            {
                dataHasBeenSent = false;
                nbOfActiveMs = 0;

                for (int i  = 0; i < gNbMobile; i++)
                {
                    if (gCurrTimeUs < (gMobile[i].lastRcvTimeUs + gMobile[i].remainDurationUs))
                    {
                        nbOfActiveMs += 1;

                        if (gMobile[i].toBePrinted)
                        {
                            _strtime(sysTime);
                            printf(
                                "\n%s - Start mobile %s:%lu, %lu bytes / %lu *100us will be sent.\n",
                                sysTime,
                                gMobile[i].ipAddr,
                                gMobile[i].port,
                                gMobile[i].packetSizeInBytes,
                                gMobile[i].periodUs);
                            gMobile[i].toBePrinted = false;
                        }

                        if (gMobile[i].nextSndTimeUs <= gCurrTimeUs)
                        {
                            //if ((gMobile[i].sequenceNumber < gMobile[i].highestSequenceNumberReceivedByMobile + 5000)
                            //        || (gMobile[i].numberOfSkippedSending > 100))
                            {
                                gMobile[i].numberOfSkippedSending = 0;
                                unsigned msgIndex = (gMobile[i].sequenceNumber) % 10;

                                gServerMsg[msgIndex].h.loc.sequenceNumber = gMobile[i].sequenceNumber;
                                gServerMsg[msgIndex].h.loc.timeUs = gCurrTimeUs;
                                gServerMsg[msgIndex].dist = gMobile[i].dist;
                                gServerMsg[msgIndex].ulRateKbps = gMobile[i].ulRateKbps;

                                msgLength = sendto(
                                            gMobile[i].socketId,
                                            (char*)&gServerMsg[msgIndex],
                                            gMobile[i].packetSizeInBytes,
                                            0,
                                            (struct sockaddr*)&(gMobile[i].destinationInfo),
                                            sizeof(gMobile[i].destinationInfo));

                                gMobile[i].sentBytes += msgLength;
                                dataHasBeenSent = true;
                                numberOfPacketSentOnOneTimer++;

                                if (msgLength == SOCKET_ERROR)
                                {
                                    // errorCode = WSAGetLastError();
                                    // if (errorCode != WSAEWOULDBLOCK)
                                    printf("\nCan not send data\n");
                                }

                                gMobile[i].sequenceNumber++;
                            }
                            //else
                            //{
                            //    gMobile[i].numberOfSkippedSending++;
                                /*if (gMobile[i].numberOfSkippedSending > 100)
                                {
                                    printf("numberOfSkippedSending %lu > 100, Bucket %lu\n", gMobile[i].numberOfSkippedSending, gMobile[i].sequenceNumber - gMobile[i].highestSequenceNumberReceivedByMobile);
                                }
                                if (gMobile[i].numberOfSkippedSending == 1)
                                {
                                    printf("numberOfSkippedSending %lu, Bucket %lu\n", gMobile[i].numberOfSkippedSending, gMobile[i].sequenceNumber - gMobile[i].highestSequenceNumberReceivedByMobile);
                                }*/
                            //}

                            gMobile[i].nextSndTimeUs += gMobile[i].periodUs;
                            // printf("*");
                        }
                    }
                    else
                    {
                        gMobile[i].nextSndTimeUs = gCurrTimeUs;

                        if (not gMobile[i].toBePrinted)
                        {
                            _strtime(sysTime);
                            printf(
                                "\n%s - Stop  Mobile %s:%lu (%lu > %lu + %lu).\n",
                                sysTime,
                                gMobile[i].ipAddr,
                                gMobile[i].port,
                                gCurrTimeUs,
                                gMobile[i].lastRcvTimeUs,
                                gMobile[i].remainDurationUs);
                            gMobile[i].lastRcvTimeUs = 0;
                            gMobile[i].remainDurationUs = 0;
                            gMobile[i].sequenceNumber = 0;
                            gMobile[i].toBePrinted = true;
                        }
                    }
                } // end for (i=0; i<gNbMobile; i++)
            } // end while (dataHasBeenSent)

            if (nbOfActiveMs == 0) gTimeInitialized = FALSE;

            if (numberOfPacketSentOnOneTimer > 50)
            {
                printf("numberOfPacketSentOnOneTimer = %u\n", numberOfPacketSentOnOneTimer);
            }
            break;
        } // end case MSG_TIMER
        case MSG_MOBILE:
        {
            bool isMobileFound = false;

            if (strcmp(rcvMsg->ipAddr, "000.000.000.000") == 0)
                strcpy(sourceIp, inet_ntoa(senderInfo.sin_addr));
            else
                strcpy(sourceIp, rcvMsg->ipAddr);

            for (int i  = 0; i < gNbMobile; i++)
            {
                if ((strcmp(gMobile[i].ipAddr, sourceIp) == 0) && (gMobile[i].port == rcvMsg->port))
                {
                    isMobileFound = true;
                    gMobile[i].lastRcvTimeUs = gCurrTimeUs;
                    gMobile[i].dist = rcvMsg->h.loc;
                    gMobile[i].packetSizeInBytes = rcvMsg->packetSizeInBytes;
                    gMobile[i].periodUs = rcvMsg->periodUs;
                    gMobile[i].remainDurationUs = rcvMsg->remainDurationUs;
                    gMobile[i].receivedBytes += msgLength;
                    gMobile[i].highestSequenceNumberReceivedByMobile = rcvMsg->dist.sequenceNumber;
                    if (gCurrTimeUs - gMobile[i].lastStatisticsTimeUs > nbUsIn1sec)
                    {
                        // printf("8*gMobile[i].receivedBytes = %lu", 8*gMobile[i].receivedBytes);
                        // printf("Float = %f\n", (float)(((double)80000 * (double)gMobile[i].receivedBytes) /
                        // (double)(gCurrTimeUs - gMobile[i].lastStatisticsTimeUs))); printf("Unsigned long = %lu\n",
                        // (unsigned long)(((double)80000 * (double)gMobile[i].receivedBytes) / (double)(gCurrTimeUs -
                        // gMobile[i].lastStatisticsTimeUs)));
                        gMobile[i].ulRateKbps = (8 * ((nbUsIn1sec * gMobile[i].receivedBytes) / (gCurrTimeUs - gMobile[i].lastStatisticsTimeUs)))/1000;
                        unsigned long dlRateKbps =  (8 * ((nbUsIn1sec * gMobile[i].sentBytes) / (gCurrTimeUs - gMobile[i].lastStatisticsTimeUs)))/1000;
                        gMobile[i].lastStatisticsTimeUs = gCurrTimeUs;
                        gMobile[i].receivedBytes = 0;
                        gMobile[i].sentBytes = 0;
                        if (gMobile[i].nextSndTimeUs > gCurrTimeUs + gMobile[i].periodUs)
                        {
                            _strtime(sysTime);
                            printf(
                                "\n%s - Reinit Mobile %s:%lu at time %lu, nextSndTimeUs was %lu\n",
                                sysTime,
                                gMobile[i].ipAddr,
                                gMobile[i].port,
                                gMobile[i].lastRcvTimeUs,
                                gMobile[i].nextSndTimeUs);
                            gMobile[i].nextSndTimeUs = gCurrTimeUs + gMobile[i].periodUs;
                        }
                        _strtime(sysTime);
                        printf(
                            "\n%s - Stats Mobile %s:%05lu at time %.05f s, DL rate %05lu kb/s, UL rate %05lu kb/s, DL Bucket %05lu (%09lu - %09lu), nbOfActiveMs %d\n",
                            sysTime,
                            gMobile[i].ipAddr,
                            gMobile[i].port,
                            float(gMobile[i].lastRcvTimeUs) / nbUsIn1sec,
                            dlRateKbps,
                            gMobile[i].ulRateKbps,
                            gMobile[i].sequenceNumber - gMobile[i].highestSequenceNumberReceivedByMobile,
                            gMobile[i].sequenceNumber, gMobile[i].highestSequenceNumberReceivedByMobile,
                            nbOfActiveMs);
                    }
                    break;
                }
            }

            if (not isMobileFound)
            {
                if (gNbMobile == MAX_MS)
                {
                    printf("\nNo More Free Mobile Context\n");
                    // return(1);
                }
                strcpy(gMobile[gNbMobile].ipAddr, sourceIp);
                gMobile[gNbMobile].toBePrinted = true;
                gMobile[gNbMobile].port = rcvMsg->port;
                gMobile[gNbMobile].lastRcvTimeUs = gCurrTimeUs;
                gMobile[gNbMobile].nextSndTimeUs = gCurrTimeUs;
                gMobile[gNbMobile].dist = rcvMsg->h.loc;
                gMobile[gNbMobile].packetSizeInBytes = rcvMsg->packetSizeInBytes;
                gMobile[gNbMobile].periodUs = rcvMsg->periodUs;
                gMobile[gNbMobile].remainDurationUs = rcvMsg->remainDurationUs;
                gMobile[gNbMobile].receivedBytes = msgLength;
                gMobile[gNbMobile].lastStatisticsTimeUs = gCurrTimeUs;
                gMobile[gNbMobile].ulRateKbps = 0;

                gMobile[gNbMobile].socketId = socket(AF_INET, SOCK_DGRAM, 0);
                if (gMobile[gNbMobile].socketId == INVALID_SOCKET) printf("\nSocket creation error ");

                int flags = fcntl(gMobile[gNbMobile].socketId, F_GETFL);
                if (fcntl(gMobile[gNbMobile].socketId, F_SETFL, flags | O_NONBLOCK) != 0)
                	printf("\nFailed to set non-blocking mode\n");

                socketOption = 1000000;
                if (setsockopt(gMobile[gNbMobile].socketId, SOL_SOCKET, SO_SNDBUF, (char*)&socketOption, socketOptionLength) ==
                        SOCKET_ERROR)
                    printf("\nNot able to enlarge send buffer to %d\n", socketOption);
                else
                    printf("\nSocket created with send buffer enlarged to %d\n", socketOption);

                gMobile[gNbMobile].destinationInfo.sin_family = AF_INET;
                gMobile[gNbMobile].destinationInfo.sin_addr.s_addr = inet_addr(sourceIp);
                gMobile[gNbMobile].destinationInfo.sin_port = htons((unsigned short)gMobile[gNbMobile].port);

                gNbMobile++;
            }

            break;
        }
        case MSG_STOPMS:
        {
            if (strcmp(rcvMsg->ipAddr, "000.000.000.000") == 0)
                strcpy(sourceIp, inet_ntoa(senderInfo.sin_addr));
            else
                strcpy(sourceIp, rcvMsg->ipAddr);

            for (int i  = 0; i < gNbMobile; i++)
            {
                if (strcmp(gMobile[i].ipAddr, sourceIp) == 0)
                {
                    gMobile[i].lastRcvTimeUs = 0;
                    break;
                }
            }

            break;
        }
        default:
        {
            numberOfUnknownMsg++;

            if (numberOfUnknownMsg == 100)
            {
                printf("\n100 Unknown messages received, last received = %lu\n", rcvMsg->h.msgType);
                numberOfUnknownMsg = 0;
            }
            break;
        }
        }
    }

    return 0;
}
