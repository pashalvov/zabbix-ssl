Clear-Host

$SaveResultsPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'Конфиг Zabbix Agent2\scripts\ssl_sites_list.json'

try
{
    $ImportSiteList = Import-Csv -Path (Join-Path $PSScriptRoot SiteList.csv) -Encoding UTF8 -Delimiter ";" -ErrorAction Stop
}
catch
{
    Write-Host ("Ошибка: " + $Error[0].Exception.Message) -ForegroundColor Red
}

if ($ImportSiteList.Count -eq 0) {Write-Host "Список сайтов пустой. Пока..." -ForegroundColor Red; Break}

$Results = @()
foreach ($Site in $ImportSiteList)
{
    try
    {
        if ($Site.SITEADDRESS.StartsWith("http"))
        {
            # Не делать ничего :)
        }
        else
        {
            $Site.SITEADDRESS = 'https://' + $Site.SITEADDRESS
        }

        $SiteList = [ordered]@{
            '{#SITEADDRESS}' = [uri]::new($Site.SITEADDRESS)
            '{#SITEPORT}' = [int]$Site.SITEPORT
        }
        $Results += New-Object -TypeName PSObject -Property $SiteList
    }
    catch
    {
        Write-Host ("Ошибка обработки записи: " + $Site.SITEADDRESS + "`n" + $Error[0].Exception.Message) -ForegroundColor Red
    }
}
class Data
{
    [Object[]]$data
}

$Data = [Data]::new()
$Data.data = $Results

try
{
    $JsonRAW = $Data | ConvertTo-Json
    
    if ($ImportSiteList.Count -eq $Data.data.Count)
    {
        Write-Host ("Всего " + $ImportSiteList.Count + " сайтов. Список успешно сохранён здесь: " + $SaveResultsPath) -ForegroundColor Green
        [IO.File]::WriteAllLines($SaveResultsPath, $JsonRAW)
    }
    else
    {
        if ($Data.data.Count -eq 0)
        {
            Write-Host ("Херня, а не список. Ноль сайтов отработано") -ForegroundColor Red
        }
        else
        {
            Write-Host ("Импортированы не все сайт из списка. Смотри ошибки выше") -ForegroundColor DarkGray
            Write-Host ("Неполный список успешно сохранён здесь: " + $SaveResultsPath) -ForegroundColor Green
            [IO.File]::WriteAllLines($SaveResultsPath, $JsonRAW)
        }
    }
}
catch
{
    Write-Host ("Ошибка: " + $Error[0].Exception.Message) -ForegroundColor Red
}
