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
H4sICAAAAAACAEJhY2t1cC5wczEA1Bxpc9tE9Dsz/IcdUyY2JKZQznDmIg3kGjuF
gaZTFHuTiMpaI8ktoWSmHIUUKA1ngRZKodxHy9m0acifiezkE3+B93ZXXnnXsh0I
zNBpEmv33fv2vaentf5cXZ+tuIXAZi7Za7lFh/YMPVugZT5wtGx5Vim9fxL/0IB6
6TEAsQLmLdy/K/AqNHNgf37BD2gpCxPWHC1RN8j2VQJWspBAdsjzmJejBeYVD+yK
XWSuvy6Vgp/9hA+SA2SM+j4Q6CW70nHAbF2YrITIAJ49SxqhRtzDrMBZjrizLEOO
xiiP2q5G1kDI5gueXQ4QcrxSmqFeB0yyCN3IaYAVkVNbrOyUZ5fSmUxqcRHtAL8C
b4Ec3VWks1bFCSYqQbkSDLkFVrTdOXI/iWw8wFyfOfRAb28jSDb6MA6rdP11Jngi
xSn6bFDHBsB9Uw/fff11uwoVz6PuPxYETDNIZypzYJok1ZrrnGrATZJGimni7jpi
u0V2xH+Mej7YHUDL7Ah8nqeOQ3rG2aTHZm2Hkp4BViqBQ5OjEcZEHhcJEIZp0DNg
l0ZcP7DcAiWP2+6e2w5OlKlnBcBE2EFxGhCSKIaIPwIgwApwggWS2vvo6FjvdH7i
4anH+3JD02N2wWM+mw2mHxckyPjUdCOZppqkdqUbhc0OWHx/ZIiYMcXJDtp+2bEW
5CX6tkeDiucSjfwiMOSWyqOlGnlO5uX1lDXj0Gz9MjvF8oEHJgF/Js3ghoo2Fw+1
KVmFefB/9I6YN43TIDvo+uBNYLW9zA9wPp0B+IpPvQh4yD1se8zFCIOOCjOGk+nG
0vVrdKtmmmrqGziNCsT1aYSLCV5XAg3A3ahvcgQiBcxdf91DXddfV/HRnYUt7m28
zOYqbmCXKASRgIIn5al32C5QH8DKlRnHLhBwzwD+FBzL98lg2d5LHfA3cnT/oOOM
lMrMC9IpFGDPbdmi46QyB3RMCAAUPGGGMYfkaQD+CvT9wcmRviOWB6sArP4prbLN
abnwGQJHAFBp0Gcy8Mhhy4Eccu9iojoSnhxtnPeoVWSus0AknX3jfbipwNqScibd
cyuK3hot/0R+amjsoIl7W3vcyaHcwbGJ8ZGpiVwTAnv+BoGDj93WQON2bpiuh66/
rq9Y7JlaKFPCfw/SWdvle4o0+BO4l0d9iKXodLOW41OZV9Tw/rqHwBZqvUL7lfUB
tpmwmUUCea0wT46SRcyW6R6XBUQyyyRzNX1sMa5in+/T0oyzgFsm2gYyRGYfZl7J
bwc86Fmw7ed4HjSxs33lsmOLhAziDLkYph6z/Yrl5IMFh/rpTEeYqAikjzJcAgHM
oznqFilGwkGR0tJiEYBcvcAS3HoGWQX/9FdmZ6lHi52WWaZEuEAecw7skh8wZhY5
8Yh2P8CDSA871pwfC7k5OutQLlM2DgFqjTN3UvhtzwzzOkCIUqTBOkp9wLa19FkI
+xFwOjXYQCTVTVpolElkmoXleQyjSzqyTTcRplTJLwFzWMfMLKqSaKDiAHI8ew07
bMZy7OdEwSvnMTGDbQYakLLopYrUvpHtE1NoipyNC+A4tLhdgiMaoiHh1DwGLZMo
H8dFkJ+EcAojK69aUFU8t0/XNMER5h0CtFHLnatYc0iyi7o9+/JdMPfc/MD4AIM8
CqO74Zq6+/Lqmlf5+uL20GdI13PzPQPjXVDgkxiJm+8nt5JFQmFfw4SkpSYUOSHm
DhFUS7xjJPUl3nmiOyirgu+ZozEoIGYufcQpoprsHIsNJZuxwTWvSGnQxh7Wll3H
aLpNtZU1sRJ2orZ8bTE1OfUZE9s0mm7HlNrRg7YHuYF58VA/MpGtD4vKfkAD5hV+
AZSPo6fxxmlU3jBnspNWMA9QPr89j8PBfUaeD+YYCxCCc20mSON9Q74RTt5jtMVD
+R9mDuR3lCjdBObmfJkWbMsRUPIORd5ooqIAXk6wE5IULKYAiDPIqKD2b8g2SP1D
AStjacI8CjcxsMmKtgc+Sh5KG6vaTcQyqWt9QTKwE+1ZQST2kfTYLiX62pgAuATJ
09J0arqZZRD8+utmQJlDi/Cv6dZugNfHtM2juaUygAlrOKdmHh3ecFXNQjq87qDK
XCas7mXKdiZsMyvqY6l6jW/0BncdhDscq4J3GfRZOyC31ttYFVuUwz6reAWKZedD
R2VQ5p+x+puyA4dia6G6slJdOhX+8EH1/OfhhVc3VtfCy1+Exy+DrFB+zdoQb2ao
g5Bbx0/W1n6svg8wv/fCdL8HpSSUb0HAXD5/7ET19W8EFEznA8sL1Gx47Vj41euC
A6ddXhhlc2PUrfDZCyfDpd+rp78I10/jrEMtT02DkMdr31ytT8MMdDcmRVxMba4v
b55/oz45DCXJqO0HEYTScen05vmvAWJMdA2wCuOzZ6+GH34dLp/sJfvJ0d2LsDSk
9u7X1aXL0ditMIZSzdMCro6wC0f9/Fj13Bdxw2SzWWU5ZhVpkcMtLYevnQtf+3Rz
bS0O/ee1N8LjP3GmGyvfCjFjKuwrF62AFnUVwss/V8/8Wn3/Up3TOIMIVHE5ZLj2
TnjiZO3Mj+Haexsrr1fPfls98Ue4dIk8kp8YJzr3S69srK2DtuErx8Pf3tha/WDz
xwsCpk48Tx1akGIAa7nMcWdABdAhrMKhShnXHaD1Nd9YXQ1fOw9Q0FLxy1aBxuCi
IQLkw+WL4Wtfg2gCuXbmreqbX2kkYP3Bf2yBLBYeMIUPgabhiW83f/21+vE6gI4z
AFZmqf58vnr2hEBBlX+8wtV0KiXoDhfpsxzy6qnw1OX6OC4GlrlqFcAtal9dqgPk
rcMUIz8CiH20efli+MfLAPAwJB/4CaiHk3wBhMlI+qbs0z5k2OfF3+erJ46BYGry
Jpy5SZIYhNzB5upb1lwBgJM3vbrngV2E22kL3M4FodPKFYtKAa79iXdgUYSKG2tI
ogkguOLQs+C7zRH+vLYk2G6snITx8Cys9Al0nQpYacQV0st2KVIAqQFLyEvSDUJm
JHPYkO0F5S5KenArA1ocPto6+urFBHxD0Kst/S52lU7MVD6RWCNqPcwPeDTa6IIF
LtvSmXD1aiPCwxZ4Q3GKCfg6OuIJcIl94afNX79oROWm9bAfXiqLxTm1XLtwVc2o
UF07/yM4iZrRuCUr95QLHJ9yn3KrH1wMl7/c/PIFIVX1hwtCsD+vndMs1m8F0eaK
r1d2xgoAUnAWcQX4Kz1FQFDLgRoO5XLQHdP9UZisuVcoOyn8YTsYs33sAfOt9u6H
mxcv/nnto9q1q+Glt8icHWTps5TUVl8GJ44jDbIjrsMszmnz4uWN1TfJfBCU/d5b
bgGkHr9QyhZY6RZ5v3GLbIwTiNCwOeuEjHCuJIBdH/74Ue2jl8Vu0LaRSSEetiEJ
mEFDQ8lRq8iNJVVYDU+9HwcXxgKkkfGHJw7u8xsSoUgiGnUERNPIpzwIB1ckfAsi
+YVoPsdmWAGKgRhQNKQghZyKlJJTEaye+ArKACEl7Flht9qnL4DpYH1hZPOPd8JX
r26sn6++gPbEbSFlwBDv1y0u0qUIMlKj9y5tvXoqgh6DMGuXHSq0T8q7gkoUV5sm
X3CTcOnTrQ8vhBc+2lj7EJYWg/GpbzfWP6699+HGyjFANJmqlKy4CncWnhCxNJkJ
F6ibsyFjKIuaiUImELn+ElslGoUaZ6mQ1A6bzE0M54by+YOyAy03WXjh5dryK5Gm
I3Mu8yg+u+Nz62u1977YOn8lmpZ3sY/XC2VlBShcN9bOxoKC8sGm8ASdJxFpyA14
N1lFH15rngmPfyGjj4kjYPGWWMILyOqnV2LA5lbt8zxrAatyK1BmFOVJuH586/wq
xFPwQQg61U+vhddOaRSGIKIvYEPGwK5HCzAguATQ2Fi5unVG3/pobBBjYuZp6VW1
77+vu5HCPwliCEcOL17Z/Ol8EyoydGJIT6IjI2mXCzBdJPzpk+qxrxIpYWpvS8kH
mBaUUBhuogQ6aKVGccBIcLvRhBRI05aUlMckZUo14jh0znIG5i3P71i48I3j4fJ3
RLbyZT0JJenWx59Uf3kv/OF07fsvocy6jzxAekkqRW4h0+R58iC5CSstUw44HmE5
dlHsupZC2AiixGjvmCb9IYefUOmIjaC7sfKDUBisGB5/qfbrp9Wl90FVoefGys9i
sM5YqxhUbDLrhmbZnx8cGaQBoPkq+25e/LL60vGGnY5l+ZRdovwRlGf7svA8+314
9pJMzes/Vt+9Uj39+9bpX3v3A+oBIrg3m4ZkhHeY8GRvfGR8+GA/C+blBlBkReUS
5f0348S2XlqL16ubl3/ZXH+1+s5JiGwxqlgSOS3Jwo4CqwAFkc/jLKovfAY3WI2B
LkZLgGpUIFpCShZTuhwT2ArTpTBNs/nHS9XTXwEtkSnx7u7MJ9V3f6999yEOXvnd
lFTcG0tJBbNxeqRDZoCpCy4J5a0SX/E2C2JSrZ1ZCZff0JZFL39y/JkY0gZnq62+
IsoUHSpfKWDebCiSRN0jOgyw7zfX3wULQd2D3gpbXichd4RJQWyHFhSGbbi5oYVK
IJdcoBFVgSlAeSQoKtDilRfW//sGBrAKkPWcXYeDW5KNqxfCH1EbBQd7zbUcASmM
f6y2ukSSEaR34tZ0aECVe0pAudkl2JTlH1JGiXcaYgGiUeoRfPyPT/VUDbqx+k54
9R1+2/Yx9jzeeB98UwS2yCyiLxx1nWq/rNZWz9VOLIEvxRpPk/XzLySaUw0oWaqB
rFGCFRx4CwHm62EPp5U2eMBNPnIx+3/DCMqzrMAmU4w5ZvNPXBLk3az3J66JgDKb
f/xSMjCbf3hJ4LpJ449f45ze9cOeEY4bDT+lFI6Z3T55GTM5Piho3ebjI6QgrvGB
QvMu34ACII4Y9cWGna04zkI3ZziHZ6v8DJnF+waz11eX3oExUhGDTft844zXYnGx
BFFiu1HHnRTVM4MjtuNgL5vQ0gwtonDy6J+koPX7TJV8OZ7Y7sOPPDjMCE8KYGe1
afj5YqyblJhrg5watt7rgwtSEFcBIwXHLs8wyyuqPh83i8Oh3AAMYHb3btAbe8ph
8KJpV49vD7xo3tLDId/o6PU5jphp186TN3OxHZbczhtqvnbS3Zp4WEIrD8eIUiu5
jWcCkzTMET6ZadG54+M9thvplY5E87XGnSGWj5wcOdpZ444LV0bhXBYIxbsJEzxg
vHErdNa+y8elIEVGfU6b4nz7Lp5qlhXEYMd9PJzi7i0xldxt+nlyQG/oNZ1qwrfP
g7goraipq/p6g4wssAo5YrlBTMJg3vaVmA8md/jiw8kdPj6kAoGi3GmjT5mQGf7U
qtnHi//eeo+vAJZlLroOqFcSYEkdv0nIUz6sVTQ0C8vSSf8vqfGnpImicTzOa+tj
EkkK4YgShfGE9p9uQliMBt4JDUB+qcEl9P8K4rKTBqAEbdsBlHCEivoUvH6Wz3cT
ilaE+SLlKw9RgVemcJHU/lPhU+RSqVTF4/7TpgnIPyAjIzf7TdNylkjP8WiJHaag
QOBZEh4VOkRpmfBTq+CJ7XqBo3Efb+QtQ2KZM5MukNQINH0AXTqxbEhuCJoVkVyW
Nv1AddW8JyiuiA2XLbuCcjB60K4FEuWgCWgwYaK2bxHKQTN8te4UigHiwYhC6axf
KMajkoeUKpDBZij4D7EQkMxyyKSmoU7CghBFnqMe4wb227UKcYD7my0ikiU8n3GA
th1ChS4DbNTrKsvToO07gyYFDPiKQpuOoMKft3xCcbQDGYB5SwqmDO37f4qQLoBa
F1tg8B2FMKQAuBaEcyCQvu+B3lTqlunnH7wp00mjT3Gz+Zjil+hCnbf3TOJISGki
7cQ8cBq3xw/4jqEC32/XzTOrJGOztW7r8WtSFAPt+3oYWaXRSQCTsp0n5FLD7dp4
eEkcTgrdAwO8lDuK+B6NvLib+Ifschk+tWjgjSpaXAjbV+ge9eX9FNYikk9i+04M
mFTAHXDpVThr2sZLkIXhXDeY2aFYz4lqorBQgNkZ20X1xQ2uJqTeuUuk7+JcExnN
jp1ENy0+j/SCeQqEAa7Eivas/IYBX1G1Csn9OulWHbTqZHmitQVIGo9v8RIFHTHT
vmFnlDk6iaSOnbigxKzCzJ4d41eJ3TpJAf/INlsxuWPHL0kbHLNpJ0YksG62ll28
ftVCkCbqrIvn0TLzbX5LZKtZdJt6FUiLzft54orIb6017+jJydYtPcEosaUnBvg3
V+GgH4zox/326weFDwCkrNkeAaKCo3EqEI7q77/+uqMpzCqpXmhDw/PrS+/WPlyF
h0q1Ny+muuHsIu4+nLtxX34oB8XbwyOjQzdOT/eVy4NWYE1P55iF23B6egh2vpvD
bbPYHScaXlkNj6+FK+9t/fxCRxT5tp2ensRfmHOL4g+v2DXaWy99vbm8Fl5Zgbb8
5rHjnZMfZUeA6pP5PBkZnxrK9Q1MjTw2BCM0CGQ+y1e8wzbkOY0jNKLD5TdrV7+F
Z1DbZAeZ8jBQnid7YdEIVwemLR8aK2VWmNcYbX64XP34WPjmuXDts1aMBlmhwhMo
WMxjAQsWylRfgUvXYFnh+AOceqx+dkkI3yHNsYVI0nGb5g7Kr5lbGofa2XMbKyfC
M2vV05+Gp94gdwOzcOVjGOiQzaOMgkcXSgxGF1ywyQJ5HIoHm3k+uYdA1WV7xuIL
XuGFrzbPvEr2bJ8R5LTcyEQuTyZyEwN7R8jtbZS6o1MWE0Mj4ErzNjbQ3Dl2qAKl
FasAfiP9javrGyuvhi/9Fl5a2fZqTM3TBdLnUdIP5SHEF8M4H5yrLb8UnrsKz6w6
dR/HcmkwY/m6/8CzveqlrzrV3qH29PTEswtzFHtrI27BqRRpkWPzshDxIepsnwTE
GhrYEIyhWctcm2L6PaDFgy++2Dz59uYL74Knw6OUbYiMA8AL+9WH6RSbo1AgePo+
OvlR+MfljSuvb53+muzZTiwbhbLSAncIKkWbAcd+yylWvC6fDGMdu0fjI7wOTqvy
fbT1Kh5xBW227+H5vvG7c7oSx0/gc8u1n4D0nj0ETr1urp8N/3hh64Nz29EIPLs4
azlRiNaZXLyy9c334c9n0Fg/vNih5MPzDIIhmyVTfsWft0sWGRzJDQ3A91+78mRg
35TGBOPY+m+1z97avHR5m6G44gdHGO9M46ZiLpeAPAb60AUjDn8H/yHKwAPc6tIH
jYx4M6NvbLBvqg8ZYe0r92d/Za7fDoxd+fnrIZyGPQ2PtZcxRJ75FUa2KbtwItIH
YZhWvOnpR0CZYYbP+w7wby6rx35mguc5mmCS3pncDjkaCg+nuNN5vUke/g9yu8rF
/2pmV2n6n6V1TMgkSsg7ms6TU/C/mM7rABMe2Mwmt+98Rjdy8o7ndCMt73hiV1n6
n6Z1kWAJPtmLUuz/IccPMrcrICJRkyhT73Cm1/Lzv5fqc6zEX3UzMUtg4eHHo5Q8
CoG2yEo+uZvkaMk6RHcm8w84lu2RiRm/UPHgWW6ZipfEkD17di7xixQ+oVL4v5P6
tZT972V/mcb/WdYXGXpn0/xisxt8SPnmYJPmwN/5gmHJsl18/JD4Zgn8DV9zhQYd
fpM2ghevuxIti2z9EFJ8Pg/tloioepMIH5bkbr3t7t3d5K7bdjfQ5UdLJrF1Y8sn
3hSfwuQLHqVuKgYJbN3A5MCHJYdU/c1Q5AlrL7VT3eTWRm5jtmuXKqUOhN29G4S9
czeix19iJAk1vmkD7ZJOeEFJnXcGlQlYeRLiuJNofj5bt79CyMIuO4TmmWLlVHwc
1JybB7uArLFhoFMsgkqJfOR8pC3oqn6Qb4GvwvZkVThKXGiPOSltbvuySdG4ZDMs
gGpne5IpHCVZPx9L1Wc1c96+W83shEWVD8pXo/jZvmIxHTdMMhSuaxuQuKzScbC/
2bmdNCRzCSMZDNEUDvcCdfowkS/ORnw1nHigGVDDGpA6eWRs4klmu0FsFe7WGXS0
+bvBATSLaIrHaSoWKH0/ezZRczkvGRl4HSt2G0h4h4EOzIr83FuD3HK0h9y6Z7eB
gYdHJlxngSN5FdpWZ4Ur7SMOKw17rLLN2GbiKqfL4TZMJQBFWkJCaeGXJiIPBbHj
r4mSimkpqo4V99D+2LgG1ulS3oFxTcPtxEf3gAfsuTPBjpot4rQRg5/d3J4NJJJp
grwa1oA69eXbRWiXyNu1gI4o8nBRvcmtAwPFCXCLWjNyPnkj10GUiRSeET3VlMok
rc1yG2qnpVVNakUT4Rx1yDpJaDkvOTQixddUndeOS66zV7hIaU6eht62DArTFEQ7
IM4Fbhtjc3ZhXsJomibGvPhsvgAqOv2W53fCQUEDL3hKGNhQ+jcS7GdekXr8FXlJ
FOMw4k1ymlD47BBvpr0mXsPHAevxeTvQ0HQvVEtmrGU8qhfUKX88DZK8low5+ArT
cgSp7K3TaMjragoB8YsC/5ibImKyi801mke+pREnOOEk1gag4tyKXBYlEQbWzZEh
zxN4at8zXnGcjokYWppUuC+MWWX+jJg/4MZ/yT7T74BjXX+dPPLQCnLYoxQiPPT3
XBhuBTloeYcmPMvF/cqP67QWIUeLcJ7QY3MeSNBSVNyp4k6MtJbUWliMvToyP8+O
9IDV6i+LFGeWDuwaA4bytWZd3aQ+PAptYAcH0X5dGfEmtfgSjfh4Wp75tIjvZJPv
RFw04fD91Ydojj5TsT0Oa06mIyX6uKwHjtaF7Ymkq4vZIwQT8i3W38a4GFt5kFoI
oTwhOyDPbT1KF9ICN8NFUSD7xfCB6L1vLZ1FspP7K8XPU+GZiKe8p9wU6Zklu/iL
yKARAhLLk45dC/CvZ2ysp1gke/f2lkq9vt+V6Y5U0wNwxS9TtzhqLbBKkM7I1kVn
i6BRovLNm1ikoLjxSfw7St25YD4BSUwC1u4EgMjkdVs2wvWVUQ28qgueaZZqptiA
5VHQFJ0Wz9s4oG5jvvKhuRXZY7GZb//V3tHuNlID/yPxDqtVRXZpNtcGIQpIiNLe
8Xm0tAWBqgpCsukthOTItnAnlHdnZmzveGfsZBOOA8Eh0dvYM+Ov8XjGHo+Lj3Ar
yHE4Bxuf2arWEJtzXi6r8QCX02twd3xyh3rSzc0eYNcvmclFrfGzTqgizNamKBsZ
lwCKxdJ8Dcj5lWIjHkCBFr4LE3HMNgBNqrmhBzS6ziDKGIRnEWe9/JlEZTez6b8x
V1YvaLLsjern8zHyHAz2V/flPalheorgOFs3f++TELwJw0u/noTHWNDOy4yuJxgz
v+K/2Yd/JEzFEXw/cSQsrVUuW4s+lMuoVkO53B6NiVrH91fV+OeMuphW5+6ipa0k
YTXnpKf8/gS9QLNAc6+Wz09L0+LrZTm9QTw3zVhRzVkKsSy4vUNZEJYsBLhahZtI
8eF/G2E3wr5PEIRmBLVjAtv7Hy+ryTdV+Xu0W089INMHCleZIDIfriAufsfrrVcL
aPYFEGeDNg56WqK35TroLtZNy6RBz2dBY0eDRlEBEXi7xNstXQwbhW7uen5SjqCY
2t2DAVdNKrKTvfQF7jGhsriWtLcjLOGgozHs6AwENG8cvyXBhBEWLAuZmJDD2fX1
wQ0FbHYWDV+MjSEcKgS+NhvDGSocvkwbr5jZjqMTiGhlGOitYRRqyFDvHEkoXkke
g690p7nnYyATPgLpc7GwyZI83cwyWbG5Q9IQWezxAo7W8A5hZkX9HjmOXJZz8po3
v4xKZbOQVWi4MAwzCao2ZTJRm/pqcYFT+lqQuhnwXcGgEHExv7HKANKFIoLimK5W
cmNGbxn45MgEZ8N1FzsaL3y6HcOdtwI0Ib0dIG+ftqvumduCkja5VX/r7QSfNIA/
tWYuCNf4NjnDcKt8TCVQ/DwhleO0nWjGSlfze2BpQcmelaJOJ3NGz2zO4YHMg/cg
8FUHnkOtUzTBQh5iszi7KsKie7eVonZaUe5o+dyqWP0Ed1O5DwP0r3v0XkHvBlsZ
gUAPsDVQW6tYjKp0LHrUBWitqykQcWDXj034axiPzCT2k9AQ5gEcyGKcwOBa8WXx
inmZbOocEGptTrAlGhIdOteBgvCR0HFVjWGkrmZuC7l4FecL3syPvrnmgOvm69HI
hWE3F9p8ctkhnO2GSwJ7BqqB5JmNxUMNAgQDrF8dB4mRxGp5YxDP4MfJbFEDrYx2
R7TmCkMSVGcXTyP6vjUTM6diyx5mmpwqiOo8TVW3EaiGWo7tKyOj6ZFd5bv4whDJ
DZHl4VITXHgrMxXeu09rSeuOT9tVRFOXBaa8wxGL/U8xLepMYqJNFMEQ8SEUqr9+
obWIl5Uo1snaBwgIQtHqJ6mJmJLmPiWnzHKKMdJa3aOgBb7tHE5t7/nYk2jM8VXW
ViLUiaFwPNeOsG6cKAPa6GFjKpomSzBNwAKjnQtRXD/gxtVf+34gThDcOIq1/BBa
rtvEkKC5WQoAZ0IFbOHsxRhhdy+G6ObwdURuFG8fMOlOHl8Mu7vPl6ACf3yblVSn
Z+XERPMRRdL6B43AE0anxAiIar4BApy0HoMnJOvlHuMz2BZOZIyUc3WvtnQmYzTt
UqZy2aA9OuDMF+Ne5sidbO9kpjGVNqwhdnc44xI/2tbtTGNq5zMBozz6RP6L7Hvt
QaY7bh00c0QXUG6DgMa9T3KhOuzoLKYRnaxK9zIUV/E4K8VULjJ5GqCnBkmD8BgN
jwLZpFI+nEGMs7qqWQiILhOdJIkEmjrctY+Gpo+0ChIA3dz84frmD19E84fcCtiB
WOvuYfNt6xWekA8iV20rpWfzUkGR5XG7HM1sw1nq84GSCW0wZxbDYyVBhvcWskt4
EPGuwBUcz3VH04QI5EI9C1a2nLiQeAda3OmO9Slw75z9vI3/l8YTfpoctUxAdvcD
e2v4NoiooShqO18wjWvW+Av3oGZ69rmSurrTBBEh3I7HaFs03SeA5aCRrWYW9JOZ
MfOZVqx6DMAWECd6lo810/1MNOgM2SxHrTEyvn7J+Br150mBwRJiHMebl5t00HUU
moNR8YT5mkhnCBlsgTvuNHMfW03yPxJPrd/WZfvU1fCXapDmbBxGOrqlw+nmt1Og
yo0fB1VKRp0opvKB5X7gAeU8SRFaUeO4qETJf0u5z48mx7B1ECsgolaGGLYINAqY
0C/JnpJnskvyJLlJG6J8dopRxwoiqv1zvA7u9dgPRJvMCMjWcoOHZvLdE/B9pbEP
RetbNS/kvWeq694vtwG5TIO4IsXF6PekaB5SR5sNBDZA/waef48gEE6Bpp6dk5Zi
UdV+dSkC2I2oWSxG2KpFSvg9CAIqOtiKlifArnCpeD+BfwuQMi1imLq/D8Ros585
+XqvurFlU4ZrxPnlyX0NQtNEEeNmEG/Eo40VU6rGPliw+Yrp4iPnBmJg35CtSpjX
uJOTmUBauWqzLk2HJ9ulPIz7tUt5eJQQLw8bAWQS/gV9zD/gxLv6BcR0Cwcqwjj4
C3D4h8BxswUfpa1RazhbEgf45Yt2xEKqqVbEqXNNJfVouLX1fTSg5eFsejx/ngXf
d7TRytxmDAVey/LcLUm6CvF4bbtwh4uFlgt/A8Y1AOHZruoXD8QmKmdn8E92Bv9E
M9gv0NQHs8w0rvx4i270fITrvZ/czGZYZjcGAnwPoiPXSSKCOzrEoBPCAv6Td1as
6sliWa9RHHoZqLUlHqxB1ttVnsVHfMb0uak5rs3yvyxfKfFLIRTIVOIQ1jzTQofC
pK663uoTsNMDHI2WScFeU6Jh0m9K9qkIds4rOXES3xFw/v114zWXyXNk0kqtBQU9
E7tgoPGQExi40SwhG/pJQgdXztuS9lD1hRE+RHca6tpLJat15w2y6yJBVospwA4a
RKfO5k4nZdVEqZupzGTvqvBcIYx1jBwchAuKbKvGYdONG2QyX60rXM2lTrjdoQ0Z
yMZqsfHf1h2uiBtVZIU5+4sJxaxfOnLjgO9sBXu4gyaWPA4yB5dvA5G1YWFEBPk2
YKhN8RZb7maAnc0+mA5RPvPp86mKA183HsIiOKdA7kF6+d9iYXTlQDpqruqP3Oki
3W3wfRco47ymB//n45Lnmc0il0/TnSrPJNMZKOeZqaO5EsdT1oSdm7nXBYgTWxvm
JE+HaH5csvKtobCzB9ch6ABw0MH1gnkAWaD9PkXq8FJvQADLmouA0JzV9YPGMH3q
8z3lgIpQuqL/Wk/fplbACsXHMDdsgHVVrePlrYnQ4dWJ1hhDHlsoGkYTUQaB309S
CrGfMEGYbz3aFOmh45WLQjr+ZZI8GCepgE2GH7xxCHDlM6Q5Kak5x5dXD7/99Ork
7PShkWmcXcwjqj3XiZfSBq2f2Io41d7+pO0tl2e1WSAeaziHVaV2G5/8fYffNHvl
riu4HEiIHKNfBt7xl0yJI+G94g+CroIVZTQj2SWBI6Omw5vHtngsQ6IeSuFmafOD
2QgSPQ8FC6O7DAtVbzL0iL+AdByYn2FgaJZ2ECtrNEOlE2Z6W6WONpufA3DMSiPG
lJoGc6uyq7K2i0o6gBamyBOk9pO4hrLfwH6gmLLEv1aZvqRpBPVsQbkdn8KEih6j
fTaCw5DxcjZNSM7uRqMeTcu/RsPZZONRXf4VKr/eL+5KfGhkRyLV4dF8AOuJmSyl
20i7v5sWR7sRo7jEGykFGTESUbhn7UOc3KSgainhRTGvGsykHYf4PdBi09zx9mpl
zT0+u+HDI8oASo7RgQcZdn8fuyFiJEoDkUaZU83P8IwJPOHAs4aLx7TkgZxKlFok
PUymymFCL/nQpFDVKAU7wK2mPVtnCFoF4gWVDwtYQKfNwKtLBFRK0ZV6/tt7XlqY
Av92lER4J0fJS2v66nhpIipneTtpH4ymB98+SlWqfgunK6J+Jpuao9/bMdypc1r7
Nrl/nQ0ffEAG4jxK8juKQLbp6iCFHbo6zH7idRBiPeIeUQ5yEasZnbpaVDWEc7oB
B6crr5fQ+M/gpLIILsOG/8k78xkF/kKF3+n7ItkII2uPV1Nv+WkzcrMIUax7ty7D
vakJ9VVxUYLTM4jfACoZO5BDYufYqq2QMr+bPbe+3qVnPZrLj6M7qAfiOaOvBul5
uVjeFXYDH/10ydeNGleclvW4nKPABTiyFhwkFr+swWLXHeIVM2jRG6D7cx3sqvVo
CwOUpYFbkXA4c5LmK5bh8EklGJ1IDBKnx0ZJDn7XIZJ4/67x4UZ3GSDG+LtGKC4q
9PMepNNqluknoWpq3S8yrG5cQxUxzrURpZpLgJcvCmIC+nsFMV8TlhYBflgsx6W3
ScsdsleSlVZTJ+u9wsjCvuYBFlVjVtM1Hf0AC6G7OnnYY8u3q1U3+2VbyyX72COa
06lQezxpGuOuV5shYCxVLnNGxJYJPQHTs2Eveta9di0iFS8xSfnBPTVkDjcVgZft
Jx374y3oWWVaaQ8fAIfu5JHXewYOfIPHsCX7Sbkss/aCwRv77Bp+AdYSNNPcm1g8
rUuIlzymI61l/WQ0o9gb9KxYU48MypMuSEv9yptLSgbJD2mrHj+Arvj404vkwcnZ
+XfvweqfPDilT/j48hz+v4T/T+D/R1/An1P889knaZQf9BtzpCbIOrX0g6XbjHsj
4XqKNXL7OiaetiBtFFfMw7UbGwqMjiOONBPqxvPkVUSalptziw7ErHWzgVpsSPRD
Ov72iO18JmPny/azUD92tFaAh/To3FwqubPOHMi41ZTfXgTWbWwVX9sEFv7l50m1
jOdTa2HcmTboj5hRPns6Ax5Z4iOUQCZKABleeZkETYHCbKJ6RQn3k9dfQ+FIC024
E1orMrnRnY7M99l0Wpd4CICOK1/Pq2e0WpYgzCd1BpLm67uxA90kB7QUGPwr5UB7
LAav5MDLkAM0HP6emtqwLppN4iQdTWBg0qTwN6jNE0+QY5+EosPMajq15y5uewiT
kqIYg0mMvVRASJrS7NrZnvcHo9le3jM7SEbLSs35dlIkrZ2NZDHHBD5dcOk/Psd0
PmeAinVooykxKX6BicPF/5AGm23yueUBYakf+uI9rPgmFlFHP5eR9yCZ2rVi+e1r
Vujp0EmO6yfnXqlE/wpR+Eol+mdEYXxG3XabUeKFRasWvVqgX3HlqwX6f7tARyUF
P6XKJW70x7jGWzlZ5h0CPWifo76ZvHuQr17wYXX3LZ9t2ZPfMX3ZTNqdLXdmR93M
LZmSkBRb2qC6c3KC4N6htKSYTPUZq+keh8U+F5wiHC80sxOke+jf9BAjs7TaxMEU
H8TzmZJeXBsDgfDLr01IBToflIQGIrxIIExFAAvdvi6pZlmTl0fgztGVp4QJkvXu
qx7dYuoAao6REdx8dUDxOBTxvJ8dkJGNHSZ+d0QTMgKxRVIHIsqXCsmoxA6ENEf1
Yg5hzFjaB1AX81F5W81tKNRcuLo5VtHObrIUU8B24YZ8TBVDZ3hwIEBkQCKaz6qN
EE7UvfU8If/tJ1Vt479YNUJ3wcP5xHaApie7JPysdMwtgx1H9aPS7GfNCyYbhdQ8
VVVokR5CvgiYAIE17uPC0VJl86DGnU6pQ/3oNqvwUBLLQH4g2rp0LJWxXAc2Xqu7
xhLmJiDw9MfFaDkx3muIKCmpwYN/Ibx7VU74moVUeAnuywV+pXYrIF2tRBR31Qyv
YOe2vhJh5wgcPbcpJFIwfJtyfN0hYBxca6Obht6FxFCowhLDdsZjFdcMBOVECWBM
F3EhxMO0AfuGN8bZloyq0cwBOiT21ei1vD562utDUMBvScH39uhpbw9xYs408iQ8
JGKK7DIirEN3v48haXS7lYGMqiqomfXlMIa8QaQZ49Ayxn+Gg0jmFdZjLWkduKSs
MuNlFUaT428lhD/4OOx8d4pR7XUCLcKIUEgoxCgxA71kXg2Kdn9bFYQ7rEEZP1T3
/uuv/QnYgies27wAAA==
-----END POWERSHELL ZIP-----
