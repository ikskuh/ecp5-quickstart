#!/bin/bash

set -e
source cfg/project.sh

mkdir -p build/tests

for file in $(find tests -type f -name "*.v"); do
  fname=$(basename ${file})
  testbench="${fname%.v}_testbench"

  echo "Run test ${testbench}"

  cat > build/testbench.v <<EOF
module testbench_root;

reg rst = 0;
reg clk = 1;

initial begin
  \$dumpfile("build/tests/${fname%.v}.vcd");
  \$dumpvars(0, root);

  #2 rst <= 1;
end

always #1 clk = !clk;

${testbench} root (.rst(rst), .clk(clk));

endmodule
EOF

  iverilog \
    -s "testbench_root" \
    -o "build/${fname}.vvp" \
    "${file}" \
    build/testbench.v \
    src/*.v
  vvp "build/${fname}.vvp" 

done
