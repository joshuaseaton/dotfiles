# Originally cribbed from https://github.com/nushell/nu_scripts/blob/main/sourced/cool-oneliners/dict.nu

# Looks up the provided word or phrase in the dictionary.
export def main [
    ...words: string,  # The word or phrase to look up
    --phonetics,  # If passed the phonetics will be returned instead of the definitions
] {
  let url = 'https://api.dictionaryapi.dev/api/v2/entries/en/' + ($words | str join %20)
  let result = http get --full --allow-errors $url
  match $result.status {
    200 => {}
    404 => (error make --unspanned {msg: $"Unknown entry: \"($words | str join ' ')\""})
    $code => (error make --unspanned {msg: $"HTTP error: ($code)"})
  }
  let body = $result.body
  if $phonetics {
    return ($body | get --optional phonetics.0.text | where $it != null)
  }
  $body |
    get meanings
    | flatten
    | select partOfSpeech definitions
    | flatten
    | flatten
    | reject synonyms antonyms
    | default null example
    | rename "part of speech"
}
