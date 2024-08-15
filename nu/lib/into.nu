
const hex_digits = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ]

# Print the given number as hex.
export def hex [] {
    if ($in == 0) {
        return "0x0"
    }

    mut n = $in
    mut str = ""
    while $n > 0 {
        $str += ($hex_digits | get ($n mod 16 | into int))
        $n = ($n / 16 | into int)
    }
    "0x" + ($str | str reverse)
}
