# A Nushell wrapper around the macOS `defaults` tool, used to manage user
# settings. Groups of such settings are referred to as "domains".

use log.nu

# Lists all domains.
export def domains [] {
    ^defaults domains | split row "," | each {|| str trim }
}

# Reads the settings of a given domain.
export def read [domain: string@domain-completions, key?: cell-path] {
    let xml = (^defaults export $domain - | lines | skip 2 | str join | from xml)
    if $key == null {
        xml-to-native $xml
    } else {
        xml-to-native $xml | get $key
    }
}

# Applies a setting within a given domain, and returns whether it was
# overwritten.
export def write [domain: string@domain-completions, key: cell-path, value: any, --force, --verbose] {
    if $value == null {
        return (error make --unspanned {msg: "Value cannot be null"})
    }
    let plist = read $domain
    let current = $plist | get --ignore-errors $key
    if $current == $value {
        return false
    }

    let updated = if $current == null {  # Inserting
        if not $force {
            return (error make --unspanned {msg: $"($domain): ($key) not present. Use --force to insert"})
        }
        {value: ($plist | insert $key $value), context: "inserted"}
    } else {  # Updating
        let expected_type = $current | describe
        let actual_type = $value | describe
        if not $force and $expected_type != $actual_type {
            return (error make --unspanned {
                msg: $"($domain): `($value)` and current value `($current)` have differing types \(($actual_type) vs. ($expected_type)\); use --force to update"
            })
        }
        {value: ($plist | update $key $value), context: $"updated from `($current)`"}
    }

    native-to-xml $updated.value | to xml | ^defaults import $domain -
    if $verbose {
        log info $"($domain): ($key) = ($value) \(($updated.context)\)"
    }
    return true
}

# Getting the full list of domains via `defaults domains` takes too long to be
# useful for completions. This is a quick and dirty alternative that gets most
# of them.
def domain-completions [] {
    ls $"($env.HOME)/Library/Preferences" |
        get name |
        each {|el| $el | path parse | get stem } |
        append [ NSGlobalDomain ]
}

# Translates a nu-representation of a plist XML value to a native equivalent.
def xml-to-native [xml: record<tag:string, content:any>] {
    let raw = if ($xml.content | is-not-empty) { $xml.content.0.content }
    match $xml.tag {
        "plist" => { xml-to-native $xml.content.0 }
        "true" => true
        "false" => false
        "integer" => ($raw | into int)
        "real" => ($raw | into float )
        "string" | "key" => (if $raw == null { "" } else { $raw })
        "data" => ($raw | into binary )
        "date" => ($raw | into datetime )
        "array" => ($xml.content | each {|el| xml-to-native $el })
        "dict" => {
            mut dict = {}
            mut key = null
            for $row in $xml.content {
                let value = (xml-to-native $row)
                if $row.tag == "key" {
                    $key = $value
                } else {
                    $dict = ($dict | merge { $key : $value})
                }
            }
            $dict
        }
        _ => { error make --unspanned {msg: $"Invalid plist tag type \"($xml.tag)\"" }}
    }
}

# Translates a native representation of a plist value back into the XML-friendly
# form.
def native-to-xml [value: any, tag?: string] {
    let tag = if $tag == null { xml-tag $value } else { $tag }
    let content = match $tag {
        "true" | "false" => null
        "data" => [{content: ($value | decode)}]
        "date" => [{content: ($value | format date "%Y-%m-%dT%H:%M:%SZ")}]
        "array" => ($value | each {|el| native-to-xml $el })
        "dict" => {
            $value | items {|key, val| [(native-to-xml $key key) (native-to-xml $val)]} | flatten
        }
        _ => [{content: ($value | into string)}]
    }
    {tag: $tag, content: $content}
}

# Gives the plist 'type' or XML tag associated with a native Nushell
# representation.
def xml-tag [value: any] {
    match ($value | describe --detailed | get type) {
        "bool" => ($value | into string)
        "int" => "integer"
        "float" => "real"
        "string" => "string"
        "binary" => "data"
        "date" => "date"
        "list" => "array"
        "record" => "dict"
        _ => { error make --unspanned {msg: $"Nushell object does not represent a plist value: `($value)`"}}
    }
}
