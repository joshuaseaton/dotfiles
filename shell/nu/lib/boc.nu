# Utilities related to the Bank of Canada

const URL = "https://www.bankofcanada.ca/valet/observations/FXUSDCAD/json"

# Returns the USD/CAD exchange rate for a given date (in YYYY-MM-DD format). If
# no date is provided, the most recent exchange rate is returned. 
export def usd-cad [date?: string] {
    let url = $URL + (if $date == null {
        "?recent=1"
    } else {
        $"?start_date=($date)&end_date=($date)"
    })
    let rate = http get $url | get observations.FXUSDCAD.v.0
    if $rate == null {
        log error $"No USD/CAD exchange rate found for date: $date"
        return null
    }
    $rate

}
