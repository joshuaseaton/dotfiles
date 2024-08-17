
const hex_digits = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" ]

# Print the given number as hex.
export def hex [] {
    # math floor will round to int, but this seems to detect fractional part
    # (though it doesn't fully preserve it.)
    if ($in mod 1) != 0 {
        error make --unspanned {msg: "into hex: input must be integral"}
    }

    if ($in == 0) {
        return "0x0"
    }

    # Take care not to treat $n as an int below. Sufficiently large integral
    # values are necessarily floats, and we don't want to int-ify and thus
    # truncate them.
    mut n = $in
    mut str = ""
    while $n > 0 {
        let remainder = $n mod 16 | into int
        $str += ($hex_digits | get $remainder)
        $n = ($n - $remainder) / 16
    }
    "0x" + ($str | str reverse)
}
