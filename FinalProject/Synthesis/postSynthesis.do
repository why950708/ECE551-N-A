vlog -work final ../follower.v ../dig_core.sv ../UART_rcv.sv ../motor_cntrl.sv ../barcode.sv ../A2D_intf.sv ../cmd_cntrl.sv ../motion_cntrl.sv ../pwm.sv ../SPI_mstr16.sv ../pwm8.sv ../alu.svd ../rise_edge_detector.v follower_tb.v}
vsim -t ns -L /userspace/h/hongyi/ece551/TSMC_lib -novopt final.Follower_tb
run -all
