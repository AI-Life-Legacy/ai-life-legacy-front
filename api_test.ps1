$baseUrl = "http://localhost:3000"
$r = Get-Random
$email = "test_$r@test.com"
$pwd = "password123"

Write-Host "--- Starting API Tests with $email ---"

# 1. Signup
$signupBody = @{
    email = $email
    password = $pwd
} | ConvertTo-Json

Write-Host "`n[1] Testing Signup..."
try {
    $signupRes = Invoke-RestMethod -Uri "$baseUrl/auth/signup" -Method Post -Body $signupBody -ContentType "application/json"
} catch {
    Write-Host "Signup Failed: $_"
    exit
}

$token = $null
if ($signupRes.data.accessToken) { $token = $signupRes.data.accessToken }
elseif ($signupRes.result.accessToken) { $token = $signupRes.result.accessToken }
elseif ($signupRes.accessToken) { $token = $signupRes.accessToken }

if (!$token) {
    Write-Host "Token not found in response."
    $signupRes | ConvertTo-Json | Write-Host
    exit
}

Write-Host "Signup Successful. Token: $($token.Substring(0, 10))..."

$headers = @{
    Authorization = "Bearer $token"
}

# Helper function
function Test-AiApi($name, $path, $bodyObj) {
    Write-Host "`n[$name] Testing $path..."
    $body = $null
    if ($bodyObj -ne $null) {
        $body = $bodyObj | ConvertTo-Json -Compress
    }
    
    try {
        $res = Invoke-RestMethod -Uri "$baseUrl$path" -Method Post -Headers $headers -Body $body -ContentType "application/json; charset=utf-8"
        $res | ConvertTo-Json -Depth 5 | Write-Host
    } catch {
        Write-Host "$name Failed: $_"
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.ReadToEnd() | Write-Host
        }
    }
}

Test-AiApi "Case" "/api/case" @{data="I am 70 years old"}
Test-AiApi "Sync" "/api/sync" @{content="I love the beach"}
Test-AiApi "Question" "/api/question" @{question="What do you like?"; data="Swimming"}
Test-AiApi "Autobiography" "/api/autobiography" $null
Test-AiApi "Chat" "/api/chat" @{message="Hello"; role="Father"}
Test-AiApi "Search" "/api/search" @{query="beach"}
