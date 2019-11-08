debImport "-2005" "-sv" "+define+gui+" "-f" "../bin/rtl.flist"
debLoadSimResult \
           /home/klin/work/uvm_work/uvm_work/02_router_lab_ral/sim/router_sim/router.fsdb
wvCreateWindow
wvResizeWindow -win $_nWave2 0 30 1920 393
verdiWindowBeWindow -win nWave_2
wvResizeWindow -win $_nWave2 2 56 1916 393
wvResizeWindow -win $_nWave2 2 56 1920 980
srcHBSelect "top.host_inf" -win $_nTrace1
srcSetScope -win $_nTrace1 "top.host_inf" -delim "."
srcSetOptions -win $_nTrace1 -annotate on
schSetOptions -win $_nSchema1 -annotate on
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -word -line 4 -pos 2 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {6 10 4 1 1 1} -backward
srcAddSelectedToWave -win $_nTrace1
srcHBSelect "top.inf" -win $_nTrace1
srcSetScope -win $_nTrace1 "top.inf" -delim "."
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {6 14 4 1 1 1} -backward
srcAddSelectedToWave -win $_nTrace1
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomAll -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoom -win $_nWave2 0.000000 9427238.406270
wvZoom -win $_nWave2 80048.399269 418714.703871
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -win $_nTrace1 -range {10 21 10 1 1 1} -backward
srcDeselectAll -win $_nTrace1
wvResizeWindow -win $_nWave2 2 56 1916 828
wvResizeWindow -win $_nWave2 2 56 1920 980
wvResizeWindow -win $_nWave2 2 56 1916 828
wvResizeWindow -win $_nWave2 2 56 1920 980
