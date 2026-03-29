$value = if ($args.Count -gt 0) { $args[-1] } else { '' }
if ($value -match '^(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)#(?<pr>[0-9]+)$') {
    Start-Process ('https://github.com/' + $Matches.repo + '/pull/' + $Matches.pr)
}
