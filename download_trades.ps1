$base_path = "D:\data"
$base_url = "https://data.binance.vision"

# $interval = "monthly"
# $typeArray = "aggTrades", "trades"
$type = "trades"
$symbol_in_uppercase = "BTCUSDT"

New-Item -Path "$base_path\spot\monthly\$type\$symbol_in_uppercase" -ItemType Directory -Force
$path = "$base_path\spot\monthly\$type\$symbol_in_uppercase"

$yearArray = "2018", "2019", "2020"
$monthArray = '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'


$counter_y = 0
foreach ($year in $yearArray)
{
    $counter_y++
    $ProgressPreference = 'Continue'
    Write-Progress -Id 1 -Activity Downloading -Status "$symbol_in_uppercase-$year" -PercentComplete (($counter_y / $yearArray.count) * 100) #-CurrentOperation OuterLoop
    $counter_m = 0
    foreach ($month in $monthArray)
    {
        $file_name = "$symbol_in_uppercase-$type-$year-$month.zip"
        $counter_m++
        Write-Progress -Id 2 -ParentId 1 -Activity Downloading -Status $month `
            -PercentComplete (($counter_m / $monthArray.Count) * 100) -CurrentOperation $file_name

        $url = "$base_url/data/spot/monthly/$type/$symbol_in_uppercase/$file_name"

        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest "$url.CHECKSUM" -OutFile "$path\$file_name.CHECKSUM"
        Invoke-WebRequest $url -OutFile "$path\$file_name"
        $ProgressPreference = 'Continue'

        $checksum = (Get-Content "$path\$file_name.CHECKSUM").split()[0]
        if ( (Get-FileHash "$path\$file_name").Hash -eq $checksum )
        {
            Expand-Archive -Path "$path\$file_name" -DestinationPath $path
            Remove-Item "$path\$file_name", "$path\$file_name.CHECKSUM" 
        }
        else
        {
            Write-Warning "$path\$file_name doesn't match CHECKSUM."
        }
    }
    New-Item -Path "$path\$year" -ItemType Directory -Force
    Get-ChildItem -File "$path\*$year*" | Move-Item -Destination "$path\$year"
}


# Deal with "singular" years

$yearArray = "2017", "2021"
$year_month = @{"2017" = '08', '09', '10', '11', '12'; `
                "2021" = '01', '02', '03', '04', '05', '06', '07'}

$counter_y = 0
foreach ($year in $yearArray)
{
    $monthArray = $year_month[$year]
    $counter_y++
    Write-Progress -Id 0 -Activity Downloading -Status "$symbol_in_uppercase-$year" -PercentComplete (($counter_y / $yearArray.count) * 100) -CurrentOperation OuterLoop
    $counter_m = 0
    foreach ($month in $monthArray)
    {
        $file_name = "$symbol_in_uppercase-$type-$year-$month.zip"
        $counter_m++
        Write-Progress -Id 1 -ParentId 0 -Activity Downloading -Status $month `
            -PercentComplete (($counter_m / $monthArray.Count) * 100) -CurrentOperation $file_name

        $url = "$base_url/data/spot/monthly/$type/$symbol_in_uppercase/$file_name"

        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest "$url.CHECKSUM" -OutFile "$path\$file_name.CHECKSUM"
        Invoke-WebRequest $url -OutFile "$path\$file_name"
        $ProgressPreference = 'Continue'


        $checksum = (Get-Content "$path\$file_name.CHECKSUM").split()[0]
        if ( (Get-FileHash "$path\$file_name").Hash -eq $checksum )
        {
            Expand-Archive -Path "$path\$file_name" -DestinationPath $path
            Remove-Item "$path\$file_name", "$path\$file_name.CHECKSUM" 
        }
        else
        {
            Write-Warning "$path\$file_name doesn't match CHECKSUM."
        }
    }
    New-Item -Path "$path\$year" -ItemType Directory -Force
    Get-ChildItem -File "$path\*$year*" | Move-Item -Destination "$path\$year"
}