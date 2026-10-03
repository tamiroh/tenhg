# tenhg

A simple command-line ten puzzle solver written in Mercury.

## Build and run

Requires the Mercury compiler (`mmc`) and `make`.

```sh
make
./ten 1 2 3 4
```

If no solution exists, the solver prints `No solution.`.
Invalid arguments print usage instructions and return exit code 1.
