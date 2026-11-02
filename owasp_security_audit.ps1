$baseUrl = "http://localhost:8081"
$endpoints = @(
    "/api/posts/college-feed?collegeId=1",
    "/api/reels/all?collegeId=1",
    "/api/events/all",
    "/api/social/posts/1/stats",
    "/api/notifications/user/84",
    "/api/auth/users"
)

$results = @()

Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "         OWASP TOP 10 SECURITY AUDIT & VULNERABILITY VERIFICATION             " -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

foreach ($ep in $endpoints) {
    $url = "$baseUrl$ep"
    try {
        $resp = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing
        $headers = $resp.Headers

        $hasClickjacking = $headers.ContainsKey("X-Frame-Options")
        $hasNoSniff = $headers.ContainsKey("X-Content-Type-Options")
        $hasCsp = $headers.ContainsKey("Content-Security-Policy")
        $hasReferrer = $headers.ContainsKey("Referrer-Policy")
        $hasPermissions = $headers.ContainsKey("Permissions-Policy")
        $hasXss = $headers.ContainsKey("X-XSS-Protection")

        $leaksPassword = ($resp.Content -match '"password":') -or ($resp.Content -match '"passwordHash":')

        $status = "PASS"
        if (!$hasClickjacking -or !$hasNoSniff -or !$hasCsp -or $leaksPassword) {
            $status = "FAIL"
        }

        $obj = [PSCustomObject]@{
            Endpoint = $ep
            HttpStatus = $resp.StatusCode
            ClickjackingProtected = $hasClickjacking
            MimeSniffingProtected = $hasNoSniff
            CspEnabled = $hasCsp
            CredentialsProtected = (-not $leaksPassword)
            AuditStatus = $status
        }
        $results += $obj

        $color = "Green"
        if ($status -ne "PASS") { $color = "Red" }
        Write-Host "[$status] $ep" -ForegroundColor $color
        Write-Host "   - X-Frame-Options: $($headers['X-Frame-Options'])"
        Write-Host "   - X-Content-Type-Options: $($headers['X-Content-Type-Options'])"
        Write-Host "   - CSP: $($headers['Content-Security-Policy'])"
        Write-Host "   - Credentials Protected: $(-not $leaksPassword)"
    } catch {
        Write-Host "[ERROR] $ep -> $($_.Exception.Message)" -ForegroundColor Red
    }
}

$results | ConvertTo-Json -Depth 5 | Out-File -FilePath "C:\Users\mkmk3\OneDrive\Documents\Edupulse123\Edupulse\owasp_security_audit_report.json" -Encoding utf8
Write-Host "`n✅ OWASP Security Audit Report saved to owasp_security_audit_report.json" -ForegroundColor Green