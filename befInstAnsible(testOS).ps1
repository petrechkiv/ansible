<#
Добавлена установка обновлений PS
Исправлена ошибка при подключении Chocolatey
Добавлена установка WPS Office Free
Добавлено правило для возможности обмена ICMP-пакетами с клиентом
Добавлено правило для подключения к удаленному ПК
Добавлена автоматическая установка обновлений PS до версии 5.1
Изменен порядок ввода пароля, пароль вводится в самом начале при запуске сценария
#>


# Порты и сайты доступность которых необходимо проверять
$Ports  = "80","443"
$Sites = "google.com", "chocolatey.org"


#определение строки пароля
Write-Host "Необходимо ввести пароль администратора: "
$UserPassword = Read-Host –AsSecureString

Write-Host "Import Module PSWindowsUpdate sucsseed"

$ips = @("192.168.130.226")
New-NetFirewallRule -DisplayName "Allow inbound ICMPv4" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -RemoteAddress $ips -Action Allow

#Enable ICMP-protocol for ping of computers with Windows
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

#Install Chocolatey 
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Host "Chocolate Installed" #test string

#$archproc = (Get-WmiObject Win32_Processor).datawidth #проверяем разрядность системы
#if ($archproc = 64) {

# Проверка версии PowerShell (ниже 5 у 7ки. винхп уже не рассматриваем)
if ($PSVersionTable.PSVersion.Major -ge 5) 
{ #begin IF

     Write-Host 'Проверка доступности http...'
        ForEach($S in $Sites)
        {
            Foreach ($P in $Ports)
            {
                $TestCon = New-Object Net.Sockets.TcpClient
                $TestCon.Connect($S,$P)
                if($TestCon.Connected)
                
                    {Write-Host "Успех "$S $P -ForegroundColor Green -Separator " => "}
                else
                    {Write-Host "Неудача"$S $P -ForegroundColor Red -Separator " => "}
                $TestCon.Close()
            }
        }
        
    #Install 7-zip from chocolatey
    choco install 7zip.install -y --force
    Write-Host "7-zip installed" #test string

    choco install multicommander -y --force
    Write-Host "Multicommander installed" #test string

    #install wps-office
    choco install wps-office-free -y
    Write-Host "wps office installed" #test string
         
  Pause
} #End IF 

else {
  #Begin Else
        Write-Host 'Ваша ОС ниже Windows 8,1. Начинаем обновление'
        Write-Host 'Проверка доступности http...'
        ForEach($S in $Sites)
        {
            Foreach ($P in $Ports)
            {
                $TestCon = New-Object Net.Sockets.TcpClient
                $TestCon.Connect($S,$P)
                if($TestCon.Connected)
                
                    {Write-Host "Успех "$S $P -ForegroundColor Green -Separator " => "}
                else
                    {Write-Host "Неудача"$S $P -ForegroundColor Red -Separator " => "}
                $TestCon.Close()
            }
        }      
        
    #Install KB for PS5 (x86)
    #wmf5.1 KB3191566
    #KB4054856 - netFramework 4.7.1
    Get-WUInstall -KBArticleID KB3191566, KB3191564, KB4054856 -AcceptAll –IgnoreReboot
    
    #Create user of Admin  
    New-LocalUser "Admin" -Password $UserPassword -FullName "BW_Admin" -Description "Local Account dlya udalennogo vhoda"
    Set-LocalUser -Name Admin –PasswordNeverExpires $False #password never expires
    Add-LocalGroupMember -Group 'Администраторы' -Member ('Admin') –Verbose
    Add-LocalGroupMember -Group 'Пользователи удаленного управления' -Member ('Admin') –Verbose
    Add-LocalGroupMember -Group 'Пользователи удаленного рабочего стола' -Member ('Admin') –Verbose

    #install .NetFramework 4.8.0
    choco install netfx-4.8 -y
    #install WMF5.1 (Windows Management Framework)
    choco install powershell -y

    #Install 7-zip from chocolatey
    choco install 7zip.install -y --force
    Write-Host "7-zip installed" #test string

    choco install doublecmd -y --force
    Write-Host "Doublecommander installed" #test string

    #install wps-office
    choco install wps-office-free -y
    Write-Host "wps office installed" #test string
    } #END Else


#test перезагрузка ПК и продолжение выполнения сценария после перезагрузки с места остановки
#Restart-Computer -Wait

&'(./ConfigureAnsible.ps1)'
