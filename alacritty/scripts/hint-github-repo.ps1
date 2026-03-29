$value = if ($args.Count -gt 0) { $args[-1] } else { '' }
if (-not [string]::IsNullOrWhiteSpace($value)) {
    Start-Process ('https://github.com/' + $value)
}
