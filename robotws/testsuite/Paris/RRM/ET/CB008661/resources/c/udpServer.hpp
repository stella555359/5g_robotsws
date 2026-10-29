#pragma once

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <netinet/ip.h>

#define SERVER_PORT 54294
#define MSG_SERVER 10
#define MSG_MOBILE 20
#define MSG_STOPMS 21
#define MSG_MOBSML 22
#define MSG_TIMER 30
#define MAX_BUF 10000
#define MAX_MS 512
#define MAX_DURATION_US 345600000000 /* 4 days */
//#define OPTIM_UDP_PACKET_SIZE 1350
#define OPTIM_UDP_PACKET_SIZE 1400
//#define OPTIM_UDP_PACKET_SIZE 1472 OK 1473 NOK

#define SOCKET int
#define LONGLONG long long
#define BOOL int
#define FALSE 0
#define TRUE 1

#define SOCKADDR_IN sockaddr_in
#define SOCKADDR_OUT sockaddr_out
#define INVALID_SOCKET -1
#define SOCKET_ERROR SO_ERROR

typedef struct refInfo_s
{
    unsigned long sequenceNumber;
    unsigned long timeUs;
} refInfo_t;

typedef struct header_s
{
    unsigned long msgType;
    refInfo_t loc;
} header_t;

typedef struct timerMsg_s
{
    header_t h;
} timerMsg_t;

typedef struct mobileMsg_s
{
    header_t h;
    refInfo_t dist;
    unsigned long packetSizeInBytes;
    unsigned long periodUs;
    unsigned long port;
    char ipAddr[20];
    unsigned long remainDurationUs;
    char buffer[MAX_BUF];
} mobileMsg_t;

typedef struct mobileSmlMsg_s
{
    unsigned long msgType;
    char buffer[MAX_BUF];
} mobileSmlMsg_t;

typedef struct serverMsg_s
{
    header_t h;
    refInfo_t dist;
    unsigned long ulRateKbps;
    char buffer[MAX_BUF];
} serverMsg_t;

typedef struct mobileInfo_s
{
    char ipAddr[20];
    unsigned long port;
    SOCKET socketId;
    SOCKADDR_IN destinationInfo;
    unsigned long nextSndTimeUs;
    unsigned long lastRcvTimeUs;
    unsigned long sequenceNumber;
    unsigned long packetSizeInBytes;
    unsigned long periodUs;
    unsigned long remainDurationUs;
    unsigned long receivedBytes;
    unsigned long lastStatisticsTimeUs;
    unsigned long sentBytes;
    unsigned long ulRateKbps;
    unsigned long highestSequenceNumberReceivedByMobile;
    unsigned long numberOfSkippedSending;
    bool toBePrinted;
    refInfo_t dist;
} mobileInfo_t;

const unsigned long nbNanoIn1us = 1000;
const unsigned long nbUsIn1sec = 1000000;
