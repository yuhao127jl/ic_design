debImport "-2005" "-sv" "+define+gui+" "-f" "../bin/rtl.flist"
wvCreateWindow
wvResizeWindow -win $_nWave2 0 30 1143 236
wvOpenFile -win $_nWave2 {/home/klin/work/socwork/tinyriscv/sim/run/e203.fsdb}
wvResizeWindow -win $_nWave2 0 30 1366 237
verdiWindowBeWindow -win nWave_2
wvResizeWindow -win $_nWave2 0 30 1366 237
wvResizeWindow -win $_nWave2 2 56 1362 237
wvResizeWindow -win $_nWave2 2 56 1366 668
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
debReload
srcDeselectAll -win $_nTrace1
srcSelect -word -line 15 -pos 3 -win $_nTrace1
srcAction -pos 15 3 4 -win $_nTrace1 -name "\"defines.v\"" -ctrlKey off
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {49 54 1 1 1 1} -backward
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcHBSelect "tinyriscv_soc_tb.tinyriscv_soc_top_0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tinyriscv_soc_tb.tinyriscv_soc_top_0" -delim "."
srcHBSelect "tinyriscv_soc_tb.tinyriscv_soc_top_0.gpio_0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tinyriscv_soc_tb.tinyriscv_soc_top_0.gpio_0" -delim \
           "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {2 2 1 1 16 29}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {2 3 1 1 3 51}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {2 2 1 1 7 48} -backward
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {4 6 1 1 17 59}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {3 6 1 1 37 57} -backward
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {8 8 1 1 13 46}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {7 8 1 1 11 29}
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {10 14 1 1 12 47}
srcDeselectAll -win $_nTrace1
srcHBSelect "tinyriscv_soc_tb.tinyriscv_soc_top_0.timer_0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tinyriscv_soc_tb.tinyriscv_soc_top_0.timer_0" -delim \
           "."
srcDeselectAll -win $_nTrace1
srcSelect -word -line 16 -pos 3 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {6 14 1 1 5 33} -backward
srcDeselectAll -win $_nTrace1
srcHBSelect "tinyriscv_soc_tb.tinyriscv_soc_top_0.u_jtag_top" -win $_nTrace1
srcHBSelect "tinyriscv_soc_tb.tinyriscv_soc_top_0.u_rib" -win $_nTrace1
srcSetScope -win $_nTrace1 "tinyriscv_soc_tb.tinyriscv_soc_top_0.u_rib" -delim \
           "."
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {2 3 1 1 29 50} -backward
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {97 103 9 1 4 1} -backward
srcDeselectAll -win $_nTrace1
