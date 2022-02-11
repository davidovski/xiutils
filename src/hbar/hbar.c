/*
 * hbar
 *
 * create a horizontal progres bar across the screen
 */

#include <sys/ioctl.h>
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>

int main (int argc, char **argv) {
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    int width = w.ws_col;

    char *text;
    int total;
    int completed;

    int opt;
    int option_index = 0;

    const char *optstring = "T:ucr:";
    static const struct option opts[] = {
        {"text", required_argument, 0, 'T'},
        {"unit", optional_argument, 0, 'u'},
        {"color", optional_argument, 0, 'c'},
        {"reset", optional_argument, 0, 'r'}
    };

    while ((opt = getopt_long(argc, argv, optstring, opts, &option_index)) != -1) {
        switch (opt) {
            case 'T':
                text = optarg;
        }
    }

    if (argc < optind + 2) {
        fprintf(stderr, "Not enough arguments provided");
    }

    completed = atoi(argv[optind]);
    total = atoi(argv[optind+1]);

    char output[width+6] = '\0';

    return 0;
}

