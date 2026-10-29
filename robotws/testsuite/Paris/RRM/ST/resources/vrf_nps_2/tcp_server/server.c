/*
    C socket server example
*/

#include<stdio.h>
#include<stdlib.h>
#include<string.h>    //strlen
#include <unistd.h> /* getopt */
#include<sys/socket.h>
#include<arpa/inet.h> //inet_addr
#include<unistd.h>    //write

int main(int argc , char *argv[])
{
    int socket_desc , client_sock , c , read_size;
    struct sockaddr_in server , client;
    unsigned char client_message[2000];
    uint16_t port_from_param=1977;

    for (;;) {
        int opt = getopt(argc, argv, "hp:");
        if (opt == -1)
            break;
        switch (opt) {
        case 'p':
            port_from_param = atoi(optarg);
            break;
        case 'h':
        default:
            printf( "usage: ./servertcp -p <port number: default value 1977>\n" );
            printf( "usage: ./servertcp -h for help\n" );
            /* Unexpected option */
            return 1;
        }
    }
 
    printf ("Port Used : %u\n", port_from_param);

    //Create socket
    socket_desc = socket(AF_INET , SOCK_STREAM , 0);
    if (socket_desc == -1)
    {
        printf("Could not create socket");
    }
    puts("Socket created");

    //Prepare the sockaddr_in structure
    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons( port_from_param );

    //Bind
    if( bind(socket_desc,(struct sockaddr *)&server , sizeof(server)) < 0)
    {
        //print the error message
        perror("bind failed. Error");
        return 1;
    }
    puts("bind done");

    //Listen
    listen(socket_desc , 3);

    //Accept and incoming connection
    puts("Waiting for incoming connections...");
    c = sizeof(struct sockaddr_in);

    //accept connection from an incoming client
    client_sock = accept(socket_desc, (struct sockaddr *)&client, (socklen_t*)&c);
    if (client_sock < 0)
    {
        perror("accept failed");
        return 1;
    }
    puts("Connection accepted");

    //Receive a message from client
    while( (read_size = read(client_sock , client_message , sizeof(client_message))) > 0 )
    {
        fprintf(stderr,"aatrace client test : Rx %d bytes\n",read_size);
        unsigned int i;
        for (i=0;i<read_size;i++)
           fprintf(stderr,"%02x",client_message[i]);
        fprintf(stderr,"\n");
    }

    if(read_size == 0)
    {
        puts("Client disconnected");
        fflush(stdout);
    }
    else if(read_size == -1)
    {
        perror("recv failed");
    }

    return 0;
}
