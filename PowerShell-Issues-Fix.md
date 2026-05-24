# PowerShell 各类问题和处理方案总结

## 1. 文件选择框强制显示为英文

## 问题场景

在依次执行以下步骤后触发：  
1. 使用 using assembly 引入 System.Windows.Forms  
2. 修改控制台输出编码，例如设置 [Console]::OutputEncoding 的值或执行 chcp 命令  
3. 使用 New-Object 创建 OpenFileDialog 文件选择框  

此时，文件选择框强制显示为英文元素的界面，而不是根据系统语言设置的中文来显示  

## 解决方案

优先使用 new 的写法，代替 New-Object 写法  
可以调用一次 Get-Culture 或 Get-UICulture 来修复  

## 测试环境

| 系统版本 | PowerShell 版本 | Windows 语言设置 |
| -- | -- | -- |
| Microsoft Windows 11 专业工作站版 24H2 | 5.1.26100.4061 Desktop | 中文 |

## 测试用例

检查语言设置，均为中文
```
[System.Globalization.CultureInfo]::CurrentCulture
[System.Globalization.CultureInfo]::CurrentUICulture
[System.Globalization.CultureInfo]::InstalledUICulture
[System.Threading.Thread]::CurrentThread.CurrentCulture
[System.Threading.Thread]::CurrentThread.CurrentUICulture
pause
```

1. 使用 Add-Type 和 New-Object 的写法，文件选择框的界面元素为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

2. 使用 Add-Type 和 new 的写法，文件选择框的界面元素为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

3. 使用 using 和 New-Object 的写法，文件选择框的界面元素为中文✅

```
using assembly System.Windows.Forms
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

4. 使用 using 和 new 的写法，文件选择框的界面元素为中文✅

```
using assembly System.Windows.Forms
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

5. 使用 Add-Type 和 New-Object 的写法，文件选择框的界面元素为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

6. 使用 Add-Type 和 new 的写法，文件选择框的界面元素为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

7. 使用 using 和 New-Object 的写法，文件选择框的界面元素为英文❌

```
using assembly System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

8. 使用 using 和 new 的写法，文件选择框的界面元素为中文✅

```
using assembly System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

9. 使用 Add-Type 和 New-Object 在前面的写法，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

10. 使用 Add-Type 和 new 在前面的写法，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

11. 使用 using 和 New-Object 在前面的写法，2 个文件选择框的界面元素都为英文❌

```
using assembly System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

12. 使用 using 和 new 在前面的写法，2 个文件选择框的界面元素都为中文✅

```
using assembly System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

13. 使用 chcp 65001，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
chcp 65001
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

14. 使用 chcp 65001，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
chcp 65001
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

15. 使用 chcp 65001，2 个文件选择框的界面元素都为英文❌

```
using assembly System.Windows.Forms
chcp 65001
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

16. 使用 chcp 65001，2 个文件选择框的界面元素都为中文✅

```
using assembly System.Windows.Forms
chcp 65001
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

17. 使用 Add-Type 和 New-Object 在前面的写法，并调用一次 Get-Culture，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
Get-Culture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

18. 使用 Add-Type 和 new 在前面的写法，并调用一次 Get-Culture，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
Get-Culture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

19. 使用 using 和 New-Object 在前面的写法，并调用一次 Get-Culture，2 个文件选择框的界面元素都为中文✅

```
using assembly System.Windows.Forms
Get-Culture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

20. 使用 using 和 new 在前面的写法，并调用一次 Get-Culture，2 个文件选择框的界面元素都为中文✅

```
using assembly System.Windows.Forms
Get-Culture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

21. 使用 Add-Type 和 New-Object 在前面的写法，并调用一次 Get-UICulture，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
Get-UICulture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

22. 使用 Add-Type 和 new 在前面的写法，并调用一次 Get-UICulture，2 个文件选择框的界面元素都为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
Get-UICulture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

23. 使用 using 和 New-Object 在前面的写法，并调用一次 Get-UICulture，2 个文件选择框的界面元素都为中文✅

```
using assembly System.Windows.Forms
Get-UICulture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

24. 使用 using 和 new 在前面的写法，并调用一次 Get-UICulture，2 个文件选择框的界面元素都为中文✅

```
using assembly System.Windows.Forms
Get-UICulture
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

25. 获取 Win32_OperatingSystem 对象，文件选择框的界面元素为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
Get-CimInstance Win32_OperatingSystem
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

26. 获取 Win32_OperatingSystem 对象，文件选择框的界面元素为中文✅

```
Add-Type -AssemblyName System.Windows.Forms
Get-CimInstance Win32_OperatingSystem
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

27. 获取 Win32_OperatingSystem 对象，文件选择框的界面元素为中文✅

```
using assembly System.Windows.Forms
Get-CimInstance Win32_OperatingSystem
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

28. 获取 Win32_OperatingSystem 对象，文件选择框的界面元素为中文✅

```
using assembly System.Windows.Forms
Get-CimInstance Win32_OperatingSystem
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

29. 修改输出编码后，获取 Win32_OperatingSystem 对象，文件选择框的界面元素为英文❌

```
Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Get-CimInstance Win32_OperatingSystem
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

30. 修改输出编码后，获取 Win32_OperatingSystem 对象，文件选择框的界面元素为英文❌

```
Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Get-CimInstance Win32_OperatingSystem
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```

31. 修改输出编码后，获取 Win32_OperatingSystem 对象，文件选择框的界面元素为英文❌

```
using assembly System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Get-CimInstance Win32_OperatingSystem
(New-Object Windows.Forms.OpenFileDialog).ShowDialog()
```

32. 修改输出编码后，获取 Win32_OperatingSystem 对象，文件选择框的界面元素为英文❌

```
using assembly System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Get-CimInstance Win32_OperatingSystem
[Windows.Forms.OpenFileDialog]::new().ShowDialog()
```
