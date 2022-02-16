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
#define DEFAULT_RESET WHITE BG_DEFAULT

#define SAVE_POS "\033[s"
#define LOAD_POS "\033[u"

static void human_format(int bytes, char *output) {
	char *suffix[] = {"B", "KB", "MB", "GB", "TB"};
	char length = sizeof(suffix) / sizeof(suffix[0]);

	int i = 0;
	double dblBytes = bytes;

	if (bytes > 1024) {
		for (i = 0; (bytes / 1024) > 0 && i<length-1; i++, bytes /= 1024)
			dblBytes = bytes / 1024.0;
	}

	sprintf(output, "%.0lf%s", dblBytes, suffix[i]);
}

int main (int argc, char **argv) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    int width = w.ws_col;

    char *text = "";
    char *unit = "";
    int total = 0;
    int completed = 0;
    int line = 0;
    bool terminate = false;
    bool human = false;

    char *color = DEFAULT_COLOR;
    char *reset = DEFAULT_RESET;
 
    int opt;
    int option_index = 0;

    const char *optstring = "T:u:c:r:l:th";
    static const struct option opts[] = {
        {"text", required_argument, 0, 'T'},
        {"unit", optional_argument, 0, 'u'},
        {"color", optional_argument, 0, 'c'},
        {"reset", optional_argument, 0, 'r'},
        {"line", optional_argument, 0, 'l'},
        {"terminate", no_argument, 0, 't'},
        {"human-readable", no_argument, 0, 'h'}
    };

    while ((opt = getopt_long(argc, argv, optstring, opts, &option_index)) != -1) {
        switch (opt) {
            case 'T':
                text = optarg;
                break;
            case 'c':
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
            case 'h':
                human = true;
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
    if (human) {
        // i suck at these
        char *c = malloc(width);
        char *t = malloc(width);
        human_format(completed, c);
        human_format(total, t);
        sprintf(count, "[%s%s/%s%s]", c, unit, t, unit);
    } else {
        sprintf(count, "[%d%s/%d%s]", completed, unit, total, unit);
    }

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
        printf(RESET "\n");
    }


    return 0;
}

