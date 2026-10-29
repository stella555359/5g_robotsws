//
//  src.c
//  xml2json
//
//  Pascal Lecuyer - 20/01/2022.
//  Copyright 2022 Nokia. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define     FALSE       0
#define     TRUE        1
#define     MAX_CAR     1000

#define     VERSION         "1.3"
#define     DATE            "20/01/2022"

#define     START       0
#define     END         1
#define     OBJ         2
#define     END_HEADER  3
#define     ATTRIBUTE   4
#define     STRING      5
#define     EQUAL       6
#define     END_OBJ     7
#define     SPACE       8
#define     VALUE       9

int         lineno;
int         char_saved;
char        precedent_char;
char        value[MAX_CAR];
int         nb_error;
int         in_header;

char        str_symbol[10][20] = { {"START"},
                                   {"END"},
                                   {"OBJ"},
                                   {"END_HEADER"},
                                   {"ATTRIBUTE"},
                                   {"STRING"},
                                   {"EQUAL"},
                                   {"END_OBJ"},
                                   {"SPACE"},
                                   {"VALUE"} };

struct attribute {
    char                *name;
    char                *value;
    int                 lineno;
    struct attribute    *next;
};

struct node {
    char                *type_obj;
    char                *value;
    int                 lineno;
    struct attribute    *attributes;
    struct node         *elements;
    struct node         *next;
};

struct node *           g_header;

/* ------------------------------------------------------- */
   FILE *open_file(const char *filename, const char *mode)
/* ------------------------------------------------------- */
{
    FILE    *f;

    if ((f = fopen (filename, mode)) == NULL) {
        fprintf (stderr, "Cannot open file '%s'\n", filename);
        perror ("");
        return (NULL);
    }
    return (f);
}

/* --------------------------- */
   void usage(const char *cmd)
/* --------------------------- */
{
    printf ("Version: %s  (%d)\n", VERSION, DATE);
    printf ("Usage: %s <XML filename>\n", cmd);
}

/* ------------------------------- */
   void print_error(const char *s)
/* ------------------------------- */
{
    printf("ERROR: [Line: %d] [%s]\n", lineno, s);
}

/* ---------------------------------------------------------------------------- */
   void print_error_symbol_not_expected(const char *function, const int symbol)
/* ---------------------------------------------------------------------------- */
{
    char    s[100];

    strcpy(s, function);
    strcat(s, ": Symbol ");
    if ((symbol >= START) && (symbol <= VALUE))
        strcat(s, str_symbol[symbol]);
    else
        strcat(s, "unknown");
    strcat(s, " unexpected");
    nb_error++;
    print_error(s);
}

/* --------------------------------------------------------- */
   void get_root_file_name(const char *filename, char *root)
/* --------------------------------------------------------- */
{
    int     i;
    int     n;
    int     max;

    root[0] = '\0';
    if (filename == NULL) return;
    max = n = (int) strlen(filename);

    for (i=n-1; i>=0; i--)
    {
        if (filename[i] == '.')
        {
            max = i;
            break;
        }
    }

    for (i=0; i<max; i++)
        root[i] = filename[i];
    root[max] = '\0';
}

/* ------------------------------------- */
   void raz(char *pstr, const int size)
/* ------------------------------------ */
{
    int     i;
    for (i=0; i<size; i++)
        pstr[i] = '\0';
}

/* ----------- */
   void init()
/* ----------- */
{
    int i;

    lineno = 1;
    char_saved = FALSE;
    precedent_char = ' ';
    nb_error = 0;
    in_header = FALSE;
    for (i=0; i<MAX_CAR; i++) value[i] = '\0';
}

/* ---------------------------- */
   void save_char(const char c)
/* ---------------------------- */
{
    char_saved = TRUE;
    precedent_char = c;
}

/* --------------------------------- */
   void add_c_to_value(const char c)
/* --------------------------------- */
{
    int     i;

    i = strlen(value);
    if (i < (MAX_CAR - 1)) value[i] = c;
}


/* -------------------------------------- */
   int next_char(FILE *f, int with_space)
/* -------------------------------------- */
{
    int     space=FALSE;
    char    c;

    while (1)
    {
        if (char_saved)
        {
            c = precedent_char;
            char_saved = FALSE;
        }
        else c = fgetc (f);

        if (c == EOF)
        {
            if (! with_space && (space, FALSE))
            {
                save_char(c);
                return (' ');
            }
            return (c);
        }
        else if (((! with_space && (c <= ' ')) || (with_space && (c < ' '))) || (c >= 127))
        {
            if (c == '\n') lineno++;
            if (! with_space) space = TRUE;
        }
        else
        {
            if (! with_space && (space))
            {
                save_char(c);
                return (' ');
            }
            return (c);
        }
    }
}

/* --------------------------------------- */
   int next_char_is(FILE *f, const char c)
/* --------------------------------------- */
{
    char    c_red;
    c_red = next_char(f, FALSE);
    if (c_red == c) return (TRUE);
    return (FALSE);
}

/* ------------------------------------------ */
   int next_chars_are(FILE *f, const char *s)
/* ------------------------------------------ */
{
    int     i;
    for (i=0; s[i]!='\0'; i++)
        if (! next_char_is(f, s[i])) return (FALSE);
    return (TRUE);
}

/* -------------------------- */
   int x_next_symbol(FILE *f)
/* -------------------------- */
{
    char    c;
    int     thereisc;
    int     symbol_ret;

    c = next_char(f, FALSE);

    raz(value, MAX_CAR);

    if (c == EOF) return (END);

    else if (c == ' ') return (SPACE);

    else if (c == '<')
    {
        in_header = TRUE;
        c = next_char(f, FALSE);
        symbol_ret = OBJ;
        thereisc = FALSE;
        if (c == '/') symbol_ret = END_OBJ;
        else thereisc = TRUE;
        while(1)
        {
            if (! thereisc) c = next_char(f, FALSE);
            if (c == EOF)
            {
                if (strlen(value) < 1) return (END);
                save_char(c);
                return (symbol_ret);
            }
            else if (c == ' ') return (symbol_ret);
            else if ((c == '?') || (c == '/') || (c == '>') || (c == '=') || (c == '"') || (c == '\''))
            {
                save_char(c);
                return (symbol_ret);
            }
            // Comment management
            else if (c == '!')
            {
                if (next_chars_are(f, "--"))
                    while(1)
                        if (next_chars_are(f, "-->")) return (SPACE);
            }
            else add_c_to_value(c);
            thereisc = FALSE;
        }
    }
    else if (c == '>')
    {
        in_header = FALSE;
        return (END_HEADER);
    }
    else if (c == '=') return (EQUAL);
    else if ((c == '?') || (c == '/'))
    {
        add_c_to_value(c);
        c = next_char(f, FALSE);
        if (c == '>')
        {
            in_header = FALSE;
            return (END_HEADER);
        }
        thereisc = TRUE;
        while(1)
        {
            if (! thereisc) c = next_char(f, FALSE);
            if (c == EOF)
            {
                save_char(c);
                return (ATTRIBUTE);
            }
            else if (c == ' ') return (ATTRIBUTE);
            else if ((c == '?') || (c == '/') || (c == '>'))
            {
                save_char(c);
                return (ATTRIBUTE);
            }
            else add_c_to_value(c);
            thereisc = FALSE;
        }
    }
    else if (c == '"')
    {
        while(1)
        {
            c = next_char(f, TRUE);
            if (c == EOF) return (END);
            else if (c == '"') return (STRING);
            else add_c_to_value(c);
        }
    }
    else if (c == '\'')
    {
        while(1)
        {
            c = next_char(f, TRUE);
            if (c == EOF) return (END);
            else if (c == '\'') return (STRING);
            else add_c_to_value(c);
        }
    }
    else if (in_header)
    {
        add_c_to_value(c);
        while(1)
        {
            c = next_char(f, FALSE);
            if (c == EOF)
            {
                save_char(c);
                return (ATTRIBUTE);
            }
            else if (c == ' ') return (ATTRIBUTE);
            else if ((c == '?') || (c == '/') || (c == '>') || (c == '=') || (c == '"') || (c == '\''))
            {
                save_char(c);
                return (ATTRIBUTE);
            }
            else add_c_to_value(c);
        }
    }
    else
    {
        add_c_to_value(c);
        while(1)
        {
            c = next_char(f, FALSE);
            if (c == EOF)
            {
                save_char(c);
                return (VALUE);
            }
            else if (c == '<')
            {
                save_char(c);
                return (VALUE);
            }
            else add_c_to_value(c);
        }
    }
}

/* ----------------------------------------------- */
   void write_symbol(FILE *fout, const int symbol)
/* ----------------------------------------------- */
{
    switch(symbol)
    {
        case START:
            fprintf(fout, "[%4d]   [START]        [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case END:
            fprintf(fout, "[%4d]   [END]          [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case OBJ:
            fprintf(fout, "[%4d]   [OBJ]          [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case END_HEADER:
            fprintf(fout, "[%4d]   [END_HEADER]   [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case ATTRIBUTE:
            fprintf(fout, "[%4d]   [ATTRIBUTE]    [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case STRING:
            fprintf(fout, "[%4d]   [STRING]       [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case EQUAL:
            fprintf(fout, "[%4d]   [EQUAL]        [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case END_OBJ:
            fprintf(fout, "[%4d]   [END_OBJ]      [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case SPACE:
            fprintf(fout, "[%4d]   [SPACE]        [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        case VALUE:
            fprintf(fout, "[%4d]   [VALUE]        [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
        default:
            fprintf(fout, "[%4d]   [unknown]      [%s]   [%d] [%d] [%c] [%d]\n", lineno, value, value[0], char_saved, precedent_char, in_header);
            break;
    }
}

/* ------------------------ */
   int next_symbol(FILE *f)
/* ------------------------ */
{
    int     symbol;

    symbol = x_next_symbol(f);
    return (symbol);
}

/* ------------------------------------------------------------- */
   struct node *create_node(const char *name, const int plineno)
/* ------------------------------------------------------------- */
{
    struct node     *ptr;

    ptr = (struct node *) malloc(sizeof(struct node));
    if (ptr != NULL)
    {
        if (name != NULL)
            ptr->type_obj = strdup(name);
        else
            ptr->type_obj = NULL;
        ptr->lineno = plineno;
        ptr->value = NULL;
        ptr->attributes = NULL;
        ptr->elements = NULL;
        ptr->next = NULL;
    }

    return ptr;
}

/* ------------------------------------------------------------------------------------------- */
   struct attribute *create_attribute(const char *name, const char *pvalue, const int plineno)
/* ------------------------------------------------------------------------------------------- */
{
    struct attribute     *ptr;

    ptr = (struct attribute *) malloc(sizeof(struct attribute));
    if (ptr != NULL)
    {
        if (name != NULL)
            ptr->name = strdup(name);
        else
            ptr->name = NULL;
        if (pvalue != NULL)
            ptr->value = strdup(pvalue);
        else
            ptr->value = NULL;
        ptr->next = NULL;
        ptr->lineno = plineno;
    }

    return ptr;
}

/* ------------------ */
   void init_struct()
/* ------------------ */
{
    g_header = create_node(NULL, 0);
}

/* ------------------------------------------------------- */
   void add_element(struct node *pnode, struct node *pelt)
/* ------------------------------------------------------- */
{
    struct node     *ptr;
    struct node     *qpt;
    struct node     *pqt;

    if (pnode->elements == NULL) pnode->elements = pelt;
    else
    {
        pqt = pnode->elements;
        if (pqt->next == NULL) pqt->next =pelt;
        else
        {
            qpt = pqt->next;
            while(qpt != NULL)
            {
                ptr = qpt;
                qpt = ptr->next;
            }
            ptr->next = pelt;
        }
    }
}

/* -------------------------------------------------------------- */
   void add_attribute(struct node *pnode, struct attribute *patt)
/* -------------------------------------------------------------- */
{
    struct attribute     *ptr;
    struct attribute     *qpt;

    if (pnode->attributes == NULL)
        pnode->attributes = patt;
    else
    {
        qpt = pnode->attributes;
        while(qpt != NULL)
        {
            ptr = qpt;
            qpt = ptr->next;
        }
        ptr->next = patt;
    }
}

/* ----------------------------- */
   void read_only_obj(FILE *fin)
/* ----------------------------- */
{
    int     symbol=OBJ;

    while (symbol != END_HEADER)
        symbol = next_symbol(fin);
}

/* -------------------------------------------------------------------- */
   void read_attribute(FILE *fin, struct node *pnode, const char *name)
/* -------------------------------------------------------------------- */
{
    int                     symbol;
    struct attribute *      ptr;
    char                    lname[MAX_CAR];

    strcpy(lname, name);

    symbol = next_symbol(fin);
    while(symbol == SPACE) symbol = next_symbol(fin);
    if (symbol != EQUAL)
    {
        print_error_symbol_not_expected("read_attribute(1)", symbol);
        return;
    }

    symbol = next_symbol(fin);
    while(symbol == SPACE) symbol = next_symbol(fin);
    if (symbol != STRING)
    {
        print_error_symbol_not_expected("read_attribute(2)", symbol);
        return;
    }

    ptr = create_attribute(lname, value, lineno);
    add_attribute(pnode, ptr);
}

/* ---------------------------------------------- */
   int read_header(FILE *fin, struct node *pnode)
/* ---------------------------------------------- */
{
    int     symbol;

    while (1)
    {
        symbol = next_symbol(fin);
        switch(symbol)
        {
            case END:
                print_error_symbol_not_expected("read_header(1)", symbol);
                return (END);
            case SPACE:
                break;
            case ATTRIBUTE:
                read_attribute(fin, pnode, value);
                break;
            case END_HEADER:
                if (value[0] == '/') return (END_OBJ);
                return (END_HEADER);
                break;
            default:
                print_error_symbol_not_expected("read_header(2)", symbol);
                break;
        }
    }
}

/* ------------------------------------------------------------------ */
   void read_obj(FILE *fin, struct node *pnode, const char *obj_type)
/* ------------------------------------------------------------------ */
{
    int                  symbol;
    struct node          *ptr;
    int                  value_done=FALSE;
    char                 save[MAX_CAR];

    ptr = create_node(obj_type, lineno);
    add_element(pnode, ptr);

    symbol = read_header(fin, ptr);

    if (symbol ==  END_HEADER)
    {
        while (1)
        {
            symbol = next_symbol(fin);
            switch(symbol)
            {
                case END:
                    print_error_symbol_not_expected("read_obj(1)", symbol);
                    //glevel--;
                    return;
                case SPACE:
                    break;
                case VALUE:
                    if (! value_done) ptr->value = strdup(value);
                    else print_error_symbol_not_expected("read_obj(2)", symbol);
                    break;
                case OBJ:
                    read_obj(fin, ptr, value);
                    break;
                case END_OBJ:
                    symbol = next_symbol(fin);
                    while(symbol == SPACE) symbol = next_symbol(fin);
                    if (symbol != END_HEADER) print_error_symbol_not_expected("read_obj(3)", symbol);
                    return;
                    break;
                default:
                    print_error_symbol_not_expected("read_obj(4)", symbol);
                    break;
            }
        }
    }
}

/* ----------------------- */
   int read_xml(FILE *fin)
/* ----------------------- */
{
    int     symbol=START;

    init_struct();

    while (symbol != END)
    {
        symbol = next_symbol(fin);
        switch (symbol) {
            case END:
            case SPACE:
                break;
            case OBJ:
                if (strlen(value) < 1) read_only_obj(fin);
                else read_obj(fin, g_header, value);
                break;
            default:
                print_error_symbol_not_expected("read_xml(1)", symbol);
                break;
        }
    }
}

/* ------------------------------------ */
   void display_indent(const int level)
/* ------------------------------------ */
{
    int     i;

    for (i=0; i< level; i++)
        printf("  ");
}

/* ----------------------------------------------- */
   void display_attributes(struct attribute *patt)
/* ----------------------------------------------- */
{
    if (patt == NULL) return;
    printf(" (%s: '%s')", patt->name, patt->value);
    display_attributes(patt->next);
}

/* --------------------------------------------------------------------- */
   void display_node(struct node *pnode, const int level, const char *s)
/* --------------------------------------------------------------------- */
{
    if (pnode == NULL) return;

    if (pnode->type_obj != NULL)
    {
        display_indent(level);
        printf("OBJ(%s): [%s]\n", s, pnode->type_obj);
        display_indent(level+1);
        printf("ATTRIBUTES: [");
        display_attributes(pnode->attributes);
        printf(" ]\n");
        display_indent(level+1);
        printf("VALUE:");
        if (pnode->value != NULL)
            printf(" [%s]", pnode->value);
        printf("\n");
    }
    display_node(pnode->elements, level+1, "ELT");
    display_node(pnode->next, level, "NXT");
}

/* --------------------------------------------- */
   void indent_in_file(FILE *f, const int level)
/* --------------------------------------------- */
{
    int     i;

    for (i=0; i< level; i++)
        fprintf(f, "  ");
}

/* ------------------------------------------------------------- */
   void generate_xml_attributes(FILE *f, struct attribute *patt)
/* ------------------------------------------------------------- */
{
    if (patt == NULL) return;
    fprintf(f, " %s=\"%s\"", patt->name, patt->value);
    generate_xml_attributes(f, patt->next);
}

/* -------------------------------------------------------------------- */
   void generate_xml_node(FILE *f, struct node *pnode, const int level)
/* -------------------------------------------------------------------- */
{
    if (pnode == NULL) return;

    if (pnode->type_obj != NULL)
    {
        indent_in_file(f, level);
        fprintf(f, "<%s", pnode->type_obj);
        generate_xml_attributes(f, pnode->attributes);
        if ((pnode->elements == NULL) && (pnode->value == NULL)) fprintf(f, "/>\n");
        else
        {
            fprintf(f, ">");
            if (strcmp(pnode->type_obj, "p") != 0)
            {
                fprintf(f, "\n");
                if (pnode->value != NULL) fprintf(f, "%s\n", pnode->value);
                generate_xml_node(f, pnode->elements, level+1);
                indent_in_file(f, level);
                fprintf(f, "</%s>\n", pnode->type_obj);
            }
            else
            {
                if (pnode->value != NULL) fprintf(f, "%s</p>\n", pnode->value);
            }
        }
        generate_xml_node(f, pnode->next, level);
    }
    else generate_xml_node(f, pnode->elements, level+1);
}

/* -------------------------- */
   void generate_xml(FILE *f)
/* -------------------------- */
{
    fprintf(f, "<?xml version='1.0' encoding='UTF-8'?>\n");
    generate_xml_node(f, g_header, -1);
}

/* ------------------------------------------------------------------------------- */
   void generate_json_attributes(FILE *f, struct attribute *patt, const int level)
/* ------------------------------------------------------------------------------- */
{
    if (patt == NULL) return;
    indent_in_file(f, level);
    if (patt->next == NULL)
        fprintf(f, "\"%s\" : \"%s\"\n", patt->name, patt->value);
    else
        fprintf(f, "\"%s\" : \"%s\",\n", patt->name, patt->value);
    generate_json_attributes(f, patt->next, level);
}

void generate_json_node(FILE *f, struct node *pnode, const int level, const int first);

/* --------------------------------------------------------------------- */
   void generate_json_item(FILE *f, struct node *pnode, const int level)
/* --------------------------------------------------------------------- */
{
    struct node *       ptr;

    if (pnode == NULL) return;

    if (strcmp(pnode->type_obj, "item") == 0)
    {
        if (pnode->value != NULL)
        {
            indent_in_file(f, level);
            if (pnode->next == NULL) fprintf(f, "\"%s\"\n", pnode->value);
            else fprintf(f, "\"%s\",\n", pnode->value);
        }
        else
        {
            indent_in_file(f, level);
            fprintf(f, "[\n");
            generate_json_node(f, pnode->elements, level+2, FALSE);
            indent_in_file(f, level);
            if (pnode->next == NULL) fprintf(f, "]\n");
            else fprintf(f, "],\n");
        }
    }
    else if (strcmp(pnode->type_obj, "p") == 0)
    {
        indent_in_file(f, level);
        fprintf(f, "{\n");
        indent_in_file(f, level+1);
        fprintf(f, "\"type\" : \"p\",\n");
        indent_in_file(f, level+1);
        if (pnode->attributes == NULL)
            fprintf(f, "\"attributes\" : null,\n");
        else
        {
            fprintf(f, "\"attributes\" : {\n");
            generate_json_attributes(f, pnode->attributes, level+2);
            indent_in_file(f, level+1);
            fprintf(f, "},\n");
        }
        indent_in_file(f, level+1);
        fprintf(f, "\"value\" : \"%s\"\n", pnode->value);
        indent_in_file(f, level);
        if (pnode->next == NULL) fprintf(f, "}\n");
        else fprintf(f, "},\n");
    }
    generate_json_item(f, pnode->next, level);
}

/* ---------------------------------------- */
   int elements_present(struct node *pnode)
/* ---------------------------------------- */
{
    if (pnode == NULL) return (FALSE);
    if (strcmp(pnode->type_obj, "item") == 0) return (FALSE);
    return (TRUE);
}

/* -------------------------------------------------------------------------------------- */
   void generate_json_node(FILE *f, struct node *pnode, const int level, const int first)
/* -------------------------------------------------------------------------------------- */
{
    if (pnode == NULL) return;

    if (pnode->type_obj != NULL)
    {
        if (strcmp(pnode->type_obj, "item") == 0) return;

        indent_in_file(f, level);
        if (first) fprintf(f, "\"contents\" : {\n");
        else fprintf(f, "{\n");

        /* key: type */
        indent_in_file(f, level+1);
        fprintf(f, "\"type\" : \"%s\",\n", pnode->type_obj);

        /* key: attributes */
        indent_in_file(f, level+1);
        if (pnode->attributes == NULL) fprintf(f, "\"attributes\" : null,\n");
        else
        {
            fprintf(f, "\"attributes\" : {\n");
            generate_json_attributes(f, pnode->attributes, level+2);
            indent_in_file(f, level+1);
            fprintf(f, "},\n");
        }

        /* key: value */
        indent_in_file(f, level+1);
        if (strcmp (pnode->type_obj, "list") == 0)
        {
            if (pnode->elements == NULL) fprintf(f, "\"value\" : []\n");
            else
            {
                fprintf(f, "\"value\" : [\n");
                generate_json_item(f, pnode->elements, level+2);
                indent_in_file(f, level+1);
                fprintf(f, "]\n");
            }
        }
        else if (strcmp (pnode->type_obj, "p") == 0)
        {
            if (pnode->value == NULL) fprintf(f, "\"value\" : null\n");
            else fprintf(f, "\"value\" : \"%s\"\n", pnode->value);
        }
        else
        {
            if (pnode->value == NULL) fprintf(f, "\"value\" : null,\n");
            else fprintf(f, "\"value\" : \"%s\",\n", pnode->value);
        }

        /* key: elements */
        if ((strcmp (pnode->type_obj, "list") != 0) && (strcmp (pnode->type_obj, "p") != 0))
        {
            indent_in_file(f, level+1);
            if (! elements_present(pnode->elements)) fprintf(f, "\"elements\" : []\n");
            else
            {
                fprintf(f, "\"elements\" : [\n");
                generate_json_node(f, pnode->elements, level+2, FALSE);
                indent_in_file(f, level+1);
                fprintf(f, "]\n");
            }
        }

        indent_in_file(f, level);
        if (pnode->next == NULL) fprintf(f, "}\n");
        else fprintf(f, "},\n");
        generate_json_node(f, pnode->next, level, FALSE);
    }
    else generate_json_node(f, pnode->elements, level+1, TRUE);
}

/* --------------------------- */
   void generate_json(FILE *f)
/* --------------------------- */
{
    fprintf(f, "{\n");
    generate_json_node(f, g_header, 0, TRUE);
    fprintf(f, "}\n");
}

/* ----------------------------------- */
   int translate(const char *filename)
/* ----------------------------------- */
{
    char    fileoutname[300];
    FILE    *fin;
    FILE    *fout;
    int     ret;

    get_root_file_name(filename, fileoutname);
    strcat(fileoutname, ".json");

    printf("fileoutname = '%s'\n", fileoutname);

    ret = FALSE;
    if ((fin = open_file(filename, "r")) != NULL)
    {
        if ((fout = open_file(fileoutname, "w")) != NULL)
        {
            init();
            ret = read_xml(fin);
            fclose(fin);
            //generate_xml(fout);
            generate_json(fout);
            fclose(fout);
        }
        else fclose(fin);
    }

    return (ret);
}

/* --------------------------------------- */
   int main(int argc, const char * argv[])
/* --------------------------------------- */
{
    char                cmd[MAX_CAR];
    struct st_cmd       *ptr=NULL;

    if (argc != 2)
    {
        usage(argv[0]);
        return (1);
    }

    if (translate(argv[1])) return (0);
    return (1);
}
