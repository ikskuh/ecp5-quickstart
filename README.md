# ECP5 QuickStart

This repo contains my personal quick-start for creating new FPGA projects based on the ECP5.

## Preparations

Build the `Dockerfile` with Docker to get a development environment with all required tools.  
**Warning:** This might take more than an hour of time, as a lot of tools are built from source!

```sh-session
[user@host ecp5-quickstart]$ docker build -t ecp5-devenv .
<snip output>
[user@host ecp5-quickstart]$
```

Also install `openocd` and `gtkwave` on your host system.

Then create a bash script that will start the container:

```sh
#!/bin/bash
exec docker run \
  -ti \
  --rm \
  --volume "$(pwd):/mnt" \
  --user "$(id -u):$(id -g)" \
  "ecp5-devenv" \
  /bin/bash
```

Start the script in your project folder to get into a shell in your current working directory. This shell will run inside the container to give you access to the synthesis and simulation toolchain.

## Usage

### `./build.sh`

**NOTE:** Use in the docker container.

Will perform synthesis, place and route and will render the bitstream. It will use all files in `src` for this. Configure the `top` module in `cfg/project.sh`.

### `./prog.sh`

**NOTE:** Use on your host.

Will program the previously created synthesized bitstream.

### `./test.sh`

**NOTE:** Use in the docker container.

Will run each testbench in `tests`. The testbenches must be named as the file + `_testbench` and will each get a `clk` and `rst` input. The `clk` will tick every time step, so a delay of one clock period is `#2`. `rst` will be LOW for two ticks.

Each testbench will output its data in `build/tests/${testbench}.vcd`.
