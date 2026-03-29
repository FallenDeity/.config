$hint = if ($args.Count -gt 0) { $args[-1] } else { '' }
if (-not [string]::IsNullOrWhiteSpace($hint)) {
    $query = [uri]::EscapeDataString($hint)
    Start-Process ('https://duckduckgo.com/?q=' + $query)
}
