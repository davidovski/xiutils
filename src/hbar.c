/*
 * hbar
 *
 * create a horizontal progres bar across the screen
 */

#include <sys/ioctl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include <getopt.h>

#include "colors.h"

#define DEFAULT_COLOR BLACK BG_WHITE 
#define DEFAULT_RESET WHITE BG_BLACK

#define SAVE_POS "\033[s"
#define LOAD_POS "\033[u"

int main (int argc, char **argv) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    int width = w.ws_col;

    char *text = "";
    char *unit = "";
    int total = 0;
    int completed = 0;
    int line = 1;
    bool terminate = false;

    char *color = DEFAULT_COLOR;
    char *reset = DEFAULT_RESET;
 
    int opt;
    int option_index = 0;

    const char *optstring = "T:u:c:r:l:t";
    static const struct option opts[] = {
        {"text", required_argument, 0, 'T'},
        {"unit", optional_argument, 0, 'u'},
        {"color", optional_argument, 0, 'c'},
        {"reset", optional_argument, 0, 'r'},
        {"line", optional_argument, 0, ';'},
        {"terminate", no_argument, 0, 't'}
    };

    while ((opt = getopt_long(argc, argv, optstring, opts, &option_index)) != -1) {
        switch (opt) {
            case 'T':
                text = optarg;
                break;
            case 'c':
                printf("%s color is \n", optarg);
                color = optarg;
                break;
            case 'r':
                reset = optarg;
                break;
            case 'u':
                unit = optarg;
                break;
            case 't':
                terminate = true;
                break;
            case 'l':
                line = atoi(optarg);
                break;
        }
    }


    if (argc < optind + 2) {
        printf(RESET "\n");
        return 1;
    }

    completed = atoi(argv[optind]);
    total = atoi(argv[optind+1]);

    if (line != -1) {
        printf("\033[%dA", line, 0);
    }

    char *count = malloc(width);
    sprintf(count, "[%d%s/%d%s]", completed, unit, total, unit);

    printf(RESET "\r");
    printf(color);
    for (int i = 0; i < width; i++) {
        int reset_at = 0;
        if (total > 0) {
            float percent = (float) completed / (float) total;
            reset_at = percent * width;
        }

        if (i == reset_at) {
            printf(reset);
        }

        if (text && i < strlen(text)) {
            printf("%c", text[i]);
        } else if (i + 1 > width - strlen(count)) {
            printf("%c", count[i - width + strlen(count)]);
        } else {
            printf(" ");
        }
    }

    if (line != -1) {
        printf("\033[%dB", line, 0);
    }
    if (terminate) {
        printf(RESET "\r");
    }


    return 0;
}

