remove_voltage_area -all
set sum 0

#set a [get_attribute [get_flat_cells *u_key_gen_lp*] area]

foreach area [get_attribute [get_flat_cells *u_key_gen_lp*] area] {

    set sum [expr $area + $sum]

    puts "total area is : $sum"
}

set util 0.8

set voltage_area [expr $sum / $util]

puts "Total area of PD LP with 0.8 % util is : $voltage_area"

set height 25
set h [expr {ceil($height / 1.672) * 1.672}]

#set width 439
set width [expr $voltage_area / $height]
set w [expr {ceil($width / 0.152) * 0.152}]

puts $width

set llx 10.016
#10.016
set lly 10.016
set urx [expr $llx + $w]
set ury [expr $lly + $h]

puts "urx : $urx"
puts "ury : $ury"

set coordinates [list [list $llx $lly] [list $urx $ury]]

create_voltage_area -region $coordinates -guard_band {5.016 5.016} -power_domains PD_LP