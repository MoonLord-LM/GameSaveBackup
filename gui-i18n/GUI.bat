@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
powershell -NoProfile -Command "Write-Host '[ %~nx0 ]' -ForegroundColor Cyan" && echo.



REM Open source address: https://github.com/MoonLord-LM/GameSaveBackup



set "temp_file=%temp%\MyBatch_%random%_%random%_%random%_%random%.ps1"
set "self_path=%~f0"

powershell -NoProfile -Command ^
    "$lines = Get-Content -LiteralPath $env:self_path -Encoding utf8;" ^
    "$startIndex = -1;" ^
    "$endIndex = -1;" ^
    "for ($i = 0; $i -lt $lines.Length; $i++) {" ^
    "    if ($lines[$i] -eq '-----BEGIN POWERSHELL ZIP-----') {" ^
    "        $startIndex = $i;" ^
    "        break;" ^
    "    }" ^
    "}" ^
    "if ($startIndex -eq -1) {" ^
    "    Write-Error 'BEGIN marker not found';" ^
    "    exit 1;" ^
    "}" ^
    "for ($i = $startIndex + 1; $i -lt $lines.Length; $i++) {" ^
    "    if ($lines[$i] -eq '-----END POWERSHELL ZIP-----') {" ^
    "        $endIndex = $i;" ^
    "        break;" ^
    "    }" ^
    "}" ^
    "if ($endIndex -eq -1) {" ^
    "    Write-Error 'END marker not found';" ^
    "    exit 1;" ^
    "}" ^
    "if ($endIndex - $startIndex -le 1) {" ^
    "    Write-Error 'Base64 content not found';" ^
    "    exit 1;" ^
    "}" ^
    "$base64Lines = $lines[($startIndex+1)..($endIndex-1)];" ^
    "$base64 = $base64Lines -join '';" ^
    "$base64 = $base64 -replace '\s', '';" ^
    "$bytes = [Convert]::FromBase64String($base64);" ^
    "$ms = New-Object System.IO.MemoryStream (,$bytes);" ^
    "$gzip = New-Object System.IO.Compression.GzipStream($ms, [System.IO.Compression.CompressionMode]::Decompress);" ^
    "$outMs = New-Object System.IO.MemoryStream;" ^
    "$gzip.CopyTo($outMs);" ^
    "$gzip.Close();" ^
    "$ms.Close();" ^
    "$rawBytes = $outMs.ToArray();" ^
    "$outMs.Close();" ^
    "[System.IO.File]::WriteAllBytes($env:temp_file, $rawBytes);" ^
    "& $env:temp_file;" ^
    "exit $LASTEXITCODE;"



set "exitcode=!errorlevel!"
if exist "!temp_file!" ( del /f /q "!temp_file!" )
exit /b 



-----BEGIN POWERSHELL ZIP-----
H4sICAAAAAACAEJhY2t1cC5wczEAlFp5UxRHFP/fKr9DF0lKtBSTSlKVULkQ1mQT
A9YuJlUJKTPMNuzE2emtOcTNUYWlKKgIiQciGCQBMUYFE8O1rHyZ7dnlL79CXh+z
M8zssOsfKv36Xf36HT0/eVncdizNGESKZeFcv15A6YJl41zb15qRIUNW23Fi5qz9
++ozdZnKENC9bUPJYSuvqDhGSYgrouVbSegkhkV0/F17e49j5x07Yagkw0Q/RB5L
Lz5nt3l0YDzVe/w9UNCRz+uaqtgaMYCYMJR+HX+lWY6ip+2Cjq3WgxGmNLY7SS4P
S+BlalPYyGAT1HbhAcXR7dbXBxTdwiD5uqWaWt5utzmXRRxTxRY49clPB37MHuns
PsB/Zoft1Wwdw6rFXV93Ryfokzvu/J904XK5WKJri3RkrWX/PjjlgDZ4QunHOuPc
GRmvlJ66t4FntR22j5kQOXzMsW1i8P3hMffqX4ILttO2Ytr+Lt0apktXhQWuO184
QQYD+wvjdHTVnVqk21OwD3u9Sv9JZZA7Wd2erM5fq21+Chd0QrNswRE8xuhUdf4h
cHypqFnNwEljgPDd2U06/ZBOjrejb9FPb/6CvkOocvOhO7rm0d4CGnMri9UzEFlx
dC765E86+9D9c9idWwxGoK2tzQ8RUTI4w7lHJ+mVOXrlfrVUCnK/3LpGR55x0+X1
R8LZwEFO5TOKjTPhg9C1f9yZ5+7tlZqlbmIfJ47BOWnpBh0br8w8paVb5fWr7uwj
d+wFHV1Bn6d7ulHY+sqlcmkbzkwvjdD/ru0U71SfLgiemvI01rEq3QDT8j6Dt47Y
tSvqGSfPbhdYwzdbLhbplXngSjkGL6EAn0dCoJtOLtMrD8EvIVyZ+dW9vhRSASkA
WaIJYXH3ICnyBI5Jxx5Vnz93720DazcBZj8m7j/z7uyYFIHzPt3gZ9SdnJGE0jnH
OTcn6MRajc5uohv++FcAmVFZWqkxpJWz+KRiZxmDqJbq2jJ9cREYjms6hj82Ntkm
j76IF2o91PaDRYyDP4t/f3bHhsExf/MQ2zkkVXRpik4Ga4UZDT/wyYoPpx3EReRc
6HYb5V9PHvODnSCi2/DTj92ASwkd8ZgD50sawm6XZuV1pcCYwR7YEJZQ6y71B6V+
qKaQCVlTQUPlEtPQzh08wqoRhINSXt6Ho19eH4clKIMDCn2V0VVREnsqS5yDqotV
tlu0SzOhLIhZ6DSxV6XCBAv76Awtbu4WOK7AbWZ6ieCviTM5wS6lF55Vny8GRWUh
mrmTJjR87p87MVlZ2PR3Qjrjj/C9AXq/N7433DvLdPJB9cF5Ydt9siDMv9yaC8Xl
mGJ7JRC8lbZ+xQZOYVlUP9j3TyPKNhB0YE6kUj2p059q9peaxWYqT+ib09Xl5Zdb
dytbm3TlVzSo2W34HEaV4kXI0KBQFxkydEhu3vqX18rF6yhr23mr/ehREDpiqbk2
leSOaoZlK7p+dEgMcQRNEEqgpijSMX0PoLbo07uVuxeDNVKLXUhDCisZfqXSnyKd
uB2UE/cIQsnu4z2nT1m7xodoukF2yQjnZGM9pwjXYIXor9D8Frz9FOknKkzJAJNH
CnGy3mXVDimGgKhBaffWys7lCY/7S+gfWl7Hwse4aSK0eA2j7kiBm6Gj93emF+jC
3XJpGqIJRDrxqLx9r3Jrurw+DIK1UO5qXH40o/1K9jEZUynt9ztfNOhNSOhkqufT
VCKdPg11pOJaAtKFi5XJS14ckoMGMXHSxjm+t12q3Frcmd/wtjsd08SG/TUx2XsA
Et4PEjyQyqVZESqPPWHY/Em2qz6q2zN0ZNGvD59dsKUIsSWrYHLvbwi+aBJ3mKZS
YC83xfZPL4Yb3R7ZmS9CncNFQzG597fo1kRIQwL6CaSSY0Ska1UAh4cbAx3l9c2d
mdWQAhYocKOn/wesch2Vx4+99AjIj4MbIlvo8kb12XwdLbIlsFYTp0d2iAMG8BxA
9Nnv7vBSvCboYQ01WcCzhybmDA9RnB6I0m53IEiVvzbrqAJvGqqS/kRVRb1K6joe
VPTOrGJaTTtHr43Qyb+R/LpBskgmx3fu/e7+e4s+mao8fvBya/QD9BGCN10LOor6
0M/oY3To5dZYzY9QwxeVF277kVFWE0+YJjG7sA1ilt98q8sP3AsjglPWAnv79Go5
zD9yTM2Sb4TZx3R2RXbm7afuzQ13anVn6nn7tyD6HRLW623DIGUv+a87Ut3J7k9P
HyN2VuaJr1aMN6/tXw8q27lQCj4qqmv/VrcvuzfGoeIDWtnI1PdUC4kHUQENYgIE
Tbjn/4BX7O5WENAlWENaoJXAF5DYCvvRo2ewGfYiGprqiwvu1BLokl0bntAzv7s3
Vyt/TzPixmrUU/H1IT0VxrrxUJPGQDLsuFSUVnL8xhtcSFRrZWadTl4LXUt4YKaw
7Zg8hyDZKsVL5e159/xymCvtqGw07Bqr7tgS+Cq+4aA8qts3IUKV++dZtkJlhFXI
iohqEOUQo0HO/sQ5rDq2ZgQ+MoUwij4FgCJwBu+lUH1xg17erB0sfaqzE8ad96TQ
anzweixvLtCn7Ew+H1Scoeg+pzs7XCmOongBmaOsQHVsYz9JJaMsecnWq1hn/NAE
P+oCbWK310lDszVF137EtcdQuXiDbt7gL+x77PPy2m3IUNHxvLAIpMX7xq/8W6wU
5ypjo5BRgc/8kwTyNZ3Fuo7Env+5/8v+fQewceRUug4swt5UiA8WcSjUS4gexUTE
ErEWVg8SEWskuKKYCF9KA/UwEUZAQIngISnHEPQoFCJdZ7QoDiKXgfCcsrC5NwDi
UZAqSANw1vrgR6fPgHRBtUSVDTi6XjjMbQ6Cd63WQTTAHp5RCKR2AB1oyBHEuvBH
N+HvjKBbQinSDKSK1xvKyA8lMD6kQQo4cBsAEOIMcy4j3qRSQwgGiR7JkvT6KAj/
kYWpX+SLDVXQAAexBO0wyhFDAydD0mEIBBZIFSubIFXX8v1EMTMe/CFjonMuw4bT
R0GP16J4hxdvtqgLdvAiYIv6SAcjWRGgo0PXxU4jlEMEGwXqKB7lSNS/OJlrddIr
BuFgNOQfKx7d4PQjmuG51+pZsPYANyQZWcyALjeaQza4T3kWd4PY4giHERH6gL47
o5vDN9JBL1CGYIvrxmy/McxRoyFVEJsGOsQWJKqU9P1uAHhIwp6IR4cJbUyGKnQm
H/foIqhAHDSkGHbADTurWb4vH8cjIEFyPALCSX7d+pr3AkL4y7i9hn+ocHRisLsF
13KCLQ4NOaljxYJgeqQBiFsz2EgcKOJ743W9YD8NxXZPXMS/cAjJLi0xyAhfBvni
gRFVLJtBRiRrfWjEbw5iTEjrjslvuQFAIn6AW42MHavuxGlD8rJMnCNnMYTQNhXJ
z7w+g3EeEUMvwF84DieJRpdde+wIi8dLotMZDfCteLjEX9WHTMQKabDcEzSRRDQk
qH6E9sROJDFaWbEQiiAgEyg+d0MgRdC9kYlyDvTNfgw3hBTGiAY4ZxyaElahQN2h
H7FJeFisRhgKI/CU0kSZKSK3CGdoCJ344rJreCBA3oShYdqFxpBJVAOMrbCGeKjE
l88qFsKc2tgHML6nhqgPjYERX1HYAf9eNCHBS4DxIBVkFWh6oKD1g4/aW1qO9v38
8aGDjRCQ6HSLJOneUAhfo4wgNIGFwBySbiMbNiUEIvzyyY2gD7ZEOlfFAsybkPRb
diUTe3lwGFlntHweftoD9Djh6+JOaJYvbmJLvGj5iJJ2YiEPQYhqgQtk9ee3gbrQ
R4wvhO0dhjDrmI1oMZrUggq7/ZrBji++L0JOhtGOWP0G26vjYxTlkOLRiGeZPjuL
QTHw5UhGG5D/789v1L+FeIxDplUz8AbmkEPoqwy14nN8xGYwS8SDjUEOqQeclCMk
rCIO5fAX0aEexTgIX+2FbqhipUpYIhOPcPAlipGJBzkERTKHAxePeviSNhBlkJpD
PUycJ5bG37laYBfiVHur4Ex9/EOs0FfQzeBq6iMgcjMAgfzi/9KIfEt8bhH5JRT6
zZH9+z45AL+csn/fTy2se7a0A8A29oKu3KxMFwFVrlxfbjm8f18L1Ajfe+NUOpGC
p8Xx5InEG319Hfl8l2IrfX0porBi6etLQH0aKZbcvxwOKqUbRTpSouu3dv4535RG
Xlx9fSfZX2y2ZMQ//O0X0r1z4WF1skQ31gFwrA6PNK/+BBkCrd+k0yjZ3ZtIdXT2
Jr9KAAXbto5z7OWQdsyz2llFD1kEcI1OXq9sPqIjF17RXELHZ0FzFn1GHBPx48C2
YtkokSdqNmSoOj3p3hum1+do6Y+9DHUR1WEOgy544dnELuRx+AZWtuBa4f9J3dlN
948V4XyTOr8seJ52azh1usOxSQ7OFbJQmZ0rr4/RmZI7dZ9OXEPvgTG6fg8ITZr5
gmCtF6s5AtSCATEpoK8V09QIzPL3EbwuNDNy+cIWXViqzlxGb7+6IZg8qWRPKo16
Uj2dnyXROw0O9W6zJnoSSUilrMZQCWOQnHHgFUockN+tv7y5XV6/TC/8R1fWX/k2
erO4gDpMwDM1XYceEAnOnbnK5AU6twlofLPpoysGtvsVC4cDsbXpriw1e3oda319
PecKg5ghF0lD1Z0MznBpjX9igDx0nVdXAb0GJj80TAC1iKFhNiS/C/WDxcXq+G/V
8zch0wEefhWXgQC2GK53FveSQQxj3AzX0fhd+mKtvHF1Z+oherv56mdVbmoKpIPt
ZDQCFo8pesYxD1hwmzZGb4fsiKyj21O8jnYus9+QgtO8eoan/2fnyFqeBoLvgv9h
KYIt2lJvUQTbz1s/j7YqUovGZtsG00RzePugICi+6JuiIOiTqHigiODxa7z+hTO7
GyfZTYxiFQQ//PjazLmzuzObmVlbu9d29EFcuYYVmXfPgfWKFQyapr58uPvx/aWv
t+79yohgZdsjy01ctC7k6ZuvDx9/fHEHjfXk8k9qvnXigzP0R6wXxuHEmVps0/bO
5rnens7iLpvb39OEoB/78Orz/Ztfnr3+RVcch9FpX6T+cFP5ntCAHYDx8LOGH34E
/8DLQGnq09VbWUHiVbs1v6nVa6EgPKGq/dmOx20nMnblg+sf314Ff/L19g10kXde
wpNf1F0uItYCN8zj4PDhHTCYrT5WPwZQANlIRZC8CC+CNMMoPZvgDkEa8gCuPevA
nhOI/0Jwp2D8R0M7xenfi+sYkVkSkWcaz4tj8B+M598R9gRgM4etnH1IN4LyzIO6
EZdnHtkpTP9uXJcRlkHYY0mM/ReC/CbfWxwxGalZEqpnHOq1AP3nYn0Htp835GzP
iMHEw2/AOdsJjtb2pyFbyzp8ah3nswn9c67lBGzPsXAITmrzmRPcdsRr/4oVs4v8
MobvoRj+Z2K/FrP/XPhXcfz3wr4M0bON86k3/djZZYmUjIz8EPMjSDicX6RqGHOx
G8UBT11m2er6xzAVIathCo6JB7ieMpchamBqFiQpVvu3/zozIiN2qpzF7V9luJ0I
sywPBk7E69twEVX6bBM/Fo/ZgBkW0GxSKSQ0x0s2KCPOHZ05ZmSw6NxkbndSeWiu
hwfc299NP3BGrKrPZJ2fZCqPU2PnWYrJkg1sGbvIuBtyAChmBCB2NJIZMKSxzY4l
4dfHPIUFzIx1r+QkPIv2xcWLDLKxwwk7n543YxplOn/AdonWmkXVRUca271TqnaM
67DRFfwRvjuG0l1Qq7A6lKD4OAANReQKwHHbRYznfLuAMbJs9AJnWq39Is95HobW
OGG7+cyQnxDbRz3/KW6Vi0UrWjdo1sKVtCuSUPPaWj9LMwAazLPjvsfqHextSMBX
a/KxvG+XEdT43s+VoHQhl4rk+FeRL1u+trmUrVne/M5HNOrsxSSso5qwOFYiYQY5
9yoKC3h7EbLCv4pVZd4ZBn7ojyJ2yNrGncpStozYzjueM42neSo0m6DC6qbEda1x
mHJtHT5y+VBMTNvx8CrhFsQA0t2+tzc+5jpDVj/mB6UEyhN6Q7QGlsZQyBxoH/ju
oLGVR3tVuawKxyXgy9vxaMQDPKIxqVWtaK4z+FSShrelWPixqpCHMg7go6owSA2r
BBLQzQBAXBTE/GelhfznJEX+ib2Wx10ctviQrJ8UrAHHi+M45T3/RJqmAbM5nsB8
wyylH++17OTSp/qYTClMKP2iiKFYRIUaEJiUgFKgWyFYuUQlUMg75keRPy2UR2CS
1xbPKgTNDn1lkyC/MHraAWqxhY2WbVfToyrAQDMXg9OqqDlEh1g0YoKbJqYZNTQg
GjFLmd7PPnwgEVlwjjeaI6iGS81joLbveFHKjmt1xvkOZClMjz5K3eDEhHiimm3/
DDJUHxVPA6XR8oYTX5ZC+Shayjq4Lio6WvFgloOSq0y2Bx1btBlmVFdP62zZiqZB
gW1He7BtZoP0FKXDJlplItlguxUiW7FPMNFo2cihFyAlA1q5vFm4svIIxbbMtg/3
5SellY6Qs8baKbCGXTgxq9BjaMi5q2wFTOCK1QYqVjrF8QDxxQcg2IUW2ooR07SS
aY4MQxQgGmMLzEDwIit0CarhFi7Oleg3iXOZEQizzAZtCEMasrzzbwOqvLb/MxZK
M5B7iDrFTRMZGHnuKA0n/BJDLV+jlgvhl5uqfHhZboLEOqYwhG/6/o1GSCiGPycQ
RSl9IKgcRd48nYgJ4rnp/vu++qiYZeE5xqbm/bRyukBigQzH1NhfJJWQikVr9wOU
puT2O85wYrh+wjHdbRbaHYL+btsKQo0ZAYAttB1EDqQpsrRtP7B5IP7bCyROfZXH
W01U7iY7OHEiDU9fDGRWzd5Ek5gSMypbA8c+4PDTKCX9naxjoBo2ysNpua5/Gm9b
9HyQ3gGHl3iAMvRNHJtPyii0qcjYHzu/8kjKZ8AkEvNAb4XGbOTSyFsF27gF/MOk
xZW7rpD1wxBinS3llzmimrhguB6HBh4r4nSaXZGHqi2dQrlJtmVFMUrYbw5Eoknz
unQdo4Q2OUasbv4IcVmRELrgUUKeyFmx/IeClhcJorsiJeSJoDVrcwV1uXptnfdt
ru+9NBCX5pbYdTu+epzHTbRwS/CPd5ltH8F1OO/HIcc+++p5aLu0ptVFojzX5Z5o
IVzEayrJxHE5ifkTWaYmJpfMUbvcCr7rnO8ycDv3U+wGDbp2VOxEVHoUVQa0n+GK
qLigLl7U4oXpEA126rSOWZl57sVid9LXbgTrIOUV8Z5Kcm5AuGoT7+PFOYGbPCyh
yQli+iWerF4NpJJDyGVYYxcYtBbWd8OqyTOqPiaQnWYv0xTjgIchuFNxkKCvNJY0
UtaRaDDh8zQ2ic9FVRwvhtWoEan0EaZ4dYh1RkGWNXXYASd04KxJW4De4I3zTpqw
Rvk5+f6EPYGibx5ZeWBHQrDCs96ww0PYcSYQDj7Cn89bJ0QvoehVhJ+0o2+74P4X
LlANqxmQeoOAOi/egMqANlnB8T2B5eGRRqQ0Na4iV5lYOCsOt5bIJmkkGGwgoTmK
PbFvmcw/wRCYcgrQGhFGASY6FqksKaaKFy9NPd8FfsPFpzhSqKvUVGlFOA86cIg0
7nHe4SdjLF2CFzGB1X5L6DE4T4rUE7nfFahLiVIw7vFAdAZjsQc7iMPImqLpISVW
h0UP+Ormw+Kz8FOfn6/bNtu2bd10ui4MF+O+UnFYKGzOYmNONdPv5GerUmgNtTcx
+xI6SHLs2fkW+sl9XhHd7NiPejQ46kHaecRI9aXJSPVzZxzCTrd3WXDFK6omVk5h
UEDB10GUkwbi313cG2PUyiWSQNxuBQjJeUUaLIvUOoG64beqGGQt78wMt+asgIPu
uOSwPdnVBoB7asqTEf4vRZSVIi5qPgnW4r6Yx+lCIdCq6QtxIauqVupj2xr3J1Y4
ifAVfUDOXWeMbf0iFIgPJXjilNFzhserOL+yqxqRT0/wIkE1V+lGUsmKWFN5B/Ku
zqiIqhec7VnoOgI+GiARbE4ldIncAWimxBmFmpQRGNkaTiQQ77QJJACYDkiAGroT
wmfSEV28WGiN7fjCfcpCL7m82SzCErsWrWS643oLMX/PKeebD+Pgt/aOpjWWIngX
/A/NGNwdk9kYRRAFUWPUqDEhG1FJRNfs7HNwsxNnNvpEA+LFo3gQRPCgoDfPovh3
VPwXVnXXdNV0T28n+/yIug/eezs93VX9UV1dU1/9+AeK4TQgH1UNDAJ2mbrk1pw1
0PE5NgU42giBPESFKkfpSFb2iMnaPYL9OO7pPvReo0XXLVhybckKBOx4D2R56AlI
HFR/AyULYEChfrnLitWVukdB8pDfv/nstx8h8dgPkAsEkyH99N2vX30dAsPrzgyd
KpY1Lh2dYy+fFRRBB/ltHnzgdZAOKx3FY3Y5g69yHYC5O6aGKAw2Zi6VPPv8C3uP
nAz3nz4CJ7CdE2u9O2my5rx4dELyNoVNAB/SLMucy2pYTOHd9H0S2nJGTEG31AzP
uLV+eyiD7ZHmcSnwPK+7AwpBp/ZpwpDPHaAHQ3o+Qo41sI+Do3KoqR+YseqqtwOu
PASbd3dfyNxOhAkey93D21Be51KVYJtkdWZFzixe2DOTmYM+su9Vp2djtXmq0Mlp
BmXCYF7nFdU63pm9W1TlDJ2RMMMsvQmtKCX/4NX0MG8oF0uzku4HQZMcIhEM+ghE
tgzVDl50JrFqy5A1ZABZiEo4Hpgv+GZNjiEW843kZPMEozFPbt9/f3Zye2vyWtII
t6rVcLBb7yGV9Q1YIcEjAy4wgQj2isK5bV90dO9rZB/S3zYbSpz9axeF9USgj39Z
V2VFDQG7VrLQha8BT52/BbYMJVsPwvHHlz5gOpLRGeb+ODiOQ8ZhlxXAKrQbkIL/
s+lc+aDx1fp6o7eAyrLK8VpBR4V+a0d5MNy+qOG70fBdHmff6Vko1Dmb6J6tq600
pUFnCBixIDcy1QbEnAuAZZbUhPKmMXx+dPTSGDH2OI7Rj6buxEgEj84XNWof9iu9
YH3TCRxbBJEfdH19NDCgK6OBgYTRhPd3pqecR3VFbD4cifRS7mRMZZC1ciMACpQQ
gmwprMAIxjt6LkegOII37wKBPA3xwRnUBG1EF1PJJGsIYc7EXCjG5Bm4ff1XZ36a
bBLARBs9dAx0JNeJwkpVQvqZLrV44Gu8Wz1ptKP9NMCvAr0IsC6/NnMxrETnqSBN
JAxObsQ7JKCjNbqxhig3dAM6Ki0cqV+8lF/zHkT3m14skVxuJyUWHcHEl4X5kLS4
tVXK9F0Fb4oHCSn/YN5CtkevHXZNVLa6aXhNsyZrU88CS8c+mVvQBd8Uzhpvdsdc
YC7HGV5JlQugBSX6cIKZdZWEUaaUryIsA0a1xSEWh01jXKKTZg91Sh2fbCOuFv6R
wswfM294guq2HSiADp83ol5wLugbdJvyzGS6aQe07HD0nsrshRJ4bcSNOIa4iyH6
Wp0oqxPl33mirNQUd3Cg8Lb/H54mnbvNyaHqaVDGwiSxuz+wqQ3RBpnPSedoS/sh
V3g/5ZxkYOPgsvnZ08ySJWpdNE87+o1LYbJ60mEGFowxfsm5xxnwf0oTmpiEoIku
yCMKVNr1HjpHKdI56U5iw4SMxtB//9sRFg75QgTbrbnmL4FJDGUK5IPPh5leqVsh
lE522nVUAA/Pp8VcTz4aYUbduNFdRuvGEl7ULuknYzFmIRyhtpzYjK6UzOipTlp0
nIaN383UWDEYBG4LdPXgNLFsERHVBkRarU9kzkzbrkuJZmVVJwttu37HMOJjJcIV
YIZvle+Zn31zYh6bJ+MogfeGPZ8GhElnpFo2uOKES2o40OliI+Lb0uTF4K5PVLJ1
y6pU1MSVLma4RyyjZT7sEg9Oe6A1TC+7QoQRzKuogzYTb/B9WLBh79Ogbw71wbfG
kftB3LqHFdHi9vsn+lqPnz/+9ftvjbntl0+/gKtfIBP97x99CQnzlVVwq19+/hyS
/UNO+sAh1k5wnWjEJK1XlMD6oCyn4ijbG81gmGiMGFCWCDz5D6lybX89PWpOO5Nf
8VCA629tANN1cGj/L+NjVTdRbFG8nPXMInJAYIfkOFo4WzWR5IxwZ/0DHdkEhPe2
HaUxoGy0lPfw9KY8eOF5SsbnDWUJQD9fwfTdbfhWAbs3eaEsY+nmnhjXpEyk6PXN
8E9Ut0yQvrTB63OfcLBblDMwR1/sZANGlqSzJitGAcynp8Uh9F0qm/yB9zq1BpqP
9Xuql6oHHrt3iz6vjIUUGmL6QpS+9aifGB7tvLJ7tL3/1I7h6/w6m+XCKpO0BqX6
O1CNhHjbJIXflMiQtOhNLzMcET00sn18QmSiRD0fxmdqvYFkp+PSGsvoDavNXBxr
r6ueHgnMoR4ZCrYB+XTYIZ+2SRqWFiplNoIkewGwVaOpOQBkVTip48P1UwqzsOog
JjqPQfXF3zjEtVs6lSWJvQ09QmFEoGW7E0HoWOJW59x04bwy8WYyVzi340NQKIdg
IC4H03E6EJOv81Lwe8egEKdOTrjNs8qA7ZTyzKBdiWSMZACzlKQp2Xb0157dzpgP
s2v3tmudkiYs04lu4bHKByM4FU6r6UTp43o5GPVokt8pDJPo5nRU53cC5Z2Lcp5j
5vslgRRbD88GcBAYtpA3isaL+SR7eDlgOqdqFFKEhAN5UXukJeyF+VdfpGMubFPV
Tqf6CLC5JG22xeUlqQq0l7yRs9j7DV8ApNYWAJrkBuvrOC0BRaCrBNSrzqXmMbaX
OlKy837ijmCZ2nQ3mS7NVA+LdTexoKcepxLolynB+Wjkuh71HrL8AGtD6ZYqZjCH
UxCKnAw0CUZFzN59RJR1Q+BnhiTz4VhIoszO2hMVu0tykXZmTDZfeTrxSv1rG67Y
0L/xkobjXQ3hkK1Xhbg+wW+5VWJOeCQsfqeL5Izh87XmvBPCEnMeo0j3AgCkRiIo
iZEIS0hl8dl3Ot3V5qlIG72h3xT3BzxXFrOsQ+ZQa7RVz0a3deokytCtuZxTbPgW
aRaLiTip2pRtz6tJt27sMAdNHXDqjqbXUItp4EgyGMlWz7EdoCKcH6phWc0zcrfB
RIJ6NfXgQMlUQ5ir5s0f0j0fVBPRVzXoufwJEWgGLXgD9D6tA1MVbsYeiUlH6AHY
ubaTVNh28SdiMIKaXCRZHlklpojrLRG3u1nrw4OOL5Bs8RetUIxlhG40QBWpTzwb
qqvDvsAYWOBmhRd3yb3CJ5sIGIwL0v5nhjDw3yPIpKlYz9ZBIyUAFzY7nqS1XH8i
1jjxXQaR2BQuuIfC7TuJNjGI/o0UCMj2U8A5JfqGhY5/0l3xc86/64XFmv4zAkk6
QOjt1dfb39gfJfnAyntvmY6in1xdt2X0SE3fkyr5OAjdJQ8GChKo2AWistsadgP9
1CoqDBma0s0P1tHgLR1yqzVSkOMlHeyBkerZvMr77cNH2odtFqiLGYZQGaf88rwG
z/ziVPs4VvVboynGxxlnc9sPANo2O6MOzr9nqSlSA/VG0urHGyCI7u0eqs3t/YNX
HwGJQm0+pX/CjxcP4O8Q/m7D36dfgH+ewn+eezaJ04x/35OhGLd3LZmjauIR71Wi
x63+LtFbJSQQ9yOpQbOzUJXkV0Mr9sOSROPTwNvfA2fngAzf1wFLH1oRuPEF828p
kXoqWhoGSDvsTnawf6fMwkOjS6zXcVIg9ZN7DpJ6MeGbz4DY7aeTlHSB6M/eBvNr
+D2OG6hcwAbZFV/kt8+nQEsVXgEHYIIAEsN8m8bhIajMGA0EKseP6O67+k0YTPck
tOQBisI3v/cnkzpHuxV6IL00K27rEzqHI2Jc94E3vTQ/barGOIfPNwY3nHO0V2Ww
4hw3gnPAOSmVhL5lIrP6f5WMxrBwicqkxt7cuANv+Ca8tXExmWgbLZsRsEhl2Sl8
wuPcZRCynRtFJK2MXCxrIlgzSjEj+SXG70plqqWSUeUMC4TpiMrffN+UX9iInquN
0uBU2RlsMu7AG0nnwKkyjT2infPvYGLF3CLNHCIqMT5PXBflqeL4AJBiHXrvLSnK
8dVgKynshvHSlRR2E3lpeA/euu4edO7OI0lsJROs6HglE6xkguvJBHFWw7dsCuRE
BW1/GuksdYyJIPt9YUfbbBup79MpD6Su82/waoirwe6cvOkmzL+dyP8ZsuYBL03c
uvm1yJsQxonc3roBMuBsv+27pMtUNp74dnSafGrFvkRUEnMoSp6x4Etd11CdbM38
mccZhuOOjlWn8Rn2r13lSWYHJh3JkXoeeQfoeAZNqn7P8WXpbYQCeRZCEbQpIIjS
ha2JgmVTLIq34zmRTYuFjVocRw53vLAZ+f9RH/0MOAsbMzslCEHH1DSUHk4CfzK/
Vcwo1Vna7YRqPTR9N1TaPCaHErlY+SghNwQRlrbSHosPPMwhV+68i9wE0WsM2XCK
l/Jne3iRVm20W+qh+/VXWNcQdmZjGkAH7mDYhm2lGGjfSjJ9vLftES7B2wzQAAW7
OU14P4YjcuSFxEK4e50Zj/hURVYiRgRzJJ50HpqyBtTku9jykMW68hmCbLCu57wr
gSyI1Qq5WUccpOGcjjuQX16KlNW+F/kV3bfdHH74/8AkirMptI4B5Pmb5agaG2dJ
rOM1ClG7zp53XuRjjo0Ukrdf/8USCjikhEbJmSv1GNF3Gm26H3AewkDy1RyzErux
Nt0pOn0XeOFrz8Dg/UJkmJjUCZ8UrSl36QOvmcXWm3A0pYq2Ebu49E5c75ie7zDj
QKHfHhTpGUNQZJHjaMBw4jMmAxMjlf2Y96s3CGVXZbpfliKWX2kOoO1e6S1a6f8c
SZjDhVz5VMv0k7BUi6GH3CwUpkP7WfqdIX/nMGIGwWm4iNjOR+S53RkrxA3dsXDD
6w2G24VGI4dhY/ec4TBy5nWCL8ah7qAJLzhJHJDKh/wxfT6YrPgYzAUBDl6wVHVm
HDOEa8hEAIbwB78FzBvk14FXAoU5kWrA9Gpev1i2X+6ealkFhK7a6KUpGxV11g8u
M2Aad5i4Jwv32HdkAbnoTyRdi9hM2zi4JHz+xQQeI+Aclc5CuJBft6t8CX+6gAof
YmSbSvu+TomG9KcNQ4AVcCRJEDjosim4gO8PNCGs0LKkAAA=
-----END POWERSHELL ZIP-----
