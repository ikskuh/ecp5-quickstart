

connect_rpc -exec python3 scripts/genpll.py

read -sv src/*.v; 

synth_ecp5 -top top -json build/top.json