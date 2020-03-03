
#Изменение типа сети
    Get-NetConnectionProfile # получаем вывод команды, содержащий индекс активного сетевого подключения
    Write-Host "Get number InterfaceIndex"

    $numindex = Read-Host #ожидается ввод номера индекса для смены типа сети

    Set-NetConnectionProfile -InterfaceIndex $numindex -NetworkCategory Private # изменяем тип сети
#END Изменение типа сети


#Create user of BWAdmin
$UserPassword = Read-Host –AsSecureString

New-LocalUser "BWAdmin" -Password $UserPassword -FullName "BWAdmin" -Description "Local Account dlya udalennogo vhoda"
Set-LocalUser -Name BWAdmin –PasswordNeverExpires $False #password never expires
Add-LocalGroupMember -Group 'Администраторы' -Member ('BWAdmin') –Verbose
Add-LocalGroupMember -Group 'Пользователи удаленного управления' -Member ('BWAdmin') –Verbose
Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member ('BWAdmin') –Verbose


#Install and Execute script for Update PowerShell
$url = "https://raw.githubusercontent.com/jborean93/ansible-windows/master/scripts/Upgrade-PowerShell.ps1"

$file = "C:\Upgrade-PowerShell.ps1"

#$Username = Read-Host “Enter Your Email Address for github Login:”
#$Password = Read-Host “Enter your Password:” -AsSecureString -ConvertTo-SecureString

(New-Object System.Net.WebClient).DownloadFile($url, $file)
#(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file

#END Install and Execute script for Update PowerShell

set-item -path wsman:\localhost\service\auth\basic -value $true

#Install and Execute script for ConfiguringRemotingForAnsible

$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "C:\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)

powershell.exe -ExecutionPolicy ByPass -File $file

#END Install and Execute script for ConfiguringRemotingForAnsible



#Enable ICMP-protocol for ping of computers with Windows
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

#Install Chocolatey 
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host "Chocolate Installed" #test string

    #Install 7-zip from chocolatey
    choco install 7zip.install -y --force
    Write-Host "7-zip installed" #test string

    choco install doublecmd -y --force
    Write-Host "Multicommander installed" #test string

    #install wps-office
    choco install wps-office-free -y
    Write-Host "wps office installed" #test string
