onerror {quit -f}

set TB    tb_top
set SNAP  ${TB}_opt

echo "INFO: Starting elaboration for $TB ..."

# Use -voptargs=+acc for better visibility without the warning
vopt +acc work.$TB -L work -o $SNAP

echo "INFO: Elaboration completed. Snapshot: $SNAP"
quit -f