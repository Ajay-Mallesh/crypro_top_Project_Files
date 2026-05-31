## get the net name
## pins connected
## filter output pin
## get cell for output pin
## get ref name of cell
## get next higher drive strength from lib
## size cell
## legalize_placement -incremental
## update_timing -full

proc upsizeCell {net_name} {

    ## get the net name
    set net_name [get_nets $net_name]
    puts [get_object_name $net_name]

    ## pins connected & output pin filtering ->
    set out_pin [get_flat_pins -filter "direction == out" -of_objects $net_name]
    puts $out_pin

    ## cell from output pin
    set driver_cell [get_flat_cells -of_objects $out_pin]
    puts $driver_cell

    ## ref name
    set ref_name [get_attribute $driver_cell ref_name]
    puts $ref_name

    ## parse library naming (AND2X1_HVT style etc.)
    regexp {([A-Z0-9]*X)([0-9]*)(_[A-Za-z]*)} $ref_name temp cell ds flav

    if {$ds == 0 || $ds == 1} {
        set ds [expr $ds + 1]
        puts "Next higher ds is $ds"

        set ds [expr $ds * 2]
        puts "Next higher ds is $ds"

        set lib_name "${cell}${ds}${flav}"
        size_cell $driver_cell $lib_name

        puts "The [get_object_name $driver_cell] got upsized to $lib_name"
    }
}

########## to get the net name from the report ###############

set read_file [open "/home/ajaym/vg_10/pd/docs/max_trans_vio.txt" r]
set i 0
set flag 0
set j 0

while {[gets $read_file line] != -1} {

    if {[llength $line] == 5 &&
        [lindex $line 0] != "Number" &&
        [lindex $line 0] != "Total" &&
        [lindex $line 0] != "Information" &&
        [lindex $line 0] != "Clock" &&
        [lindex $line 0] != "Net"} {

        set net_name [lindex $line 0]
        set flag [catch {upsizeCell $net_name}]

        if {$flag == 1} {
            incr i
        } else {
            incr j
        }

        puts "The cell upsized is $i and not getting upsized is $j"
    }
}

close $read_file