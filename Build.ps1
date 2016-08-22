param(
    [String] $majorMinor = "0.0",  # 2.0
    [String] $patch = "0",         # $env:APPVEYOR_BUILD_VERSION
    [String] $customLogger = "",   # C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll
    [Switch] $notouch,
    [String] $sln                  # e.g serilog-sink-name
)

function Set-AssemblyVersions($informational, $assembly)
{
    (Get-Content assets/CommonAssemblyInfo.cs) |
        ForEach-Object { $_ -replace """1.0.0.0""", """$assembly""" } |
        ForEach-Object { $_ -replace """1.0.0""", """$informational""" } |
        ForEach-Object { $_ -replace """1.1.1.1""", """$($informational).0""" } |
        Set-Content assets/CommonAssemblyInfo.cs
}

function Install-NuGetPackages($solution)
{
    nuget restore $solution
}

function Invoke-MSBuild($solution, $customLogger)
{
    if ($customLogger)
    {
        C:\PROGRA~2\MSBuild\14.0\Bin\amd64\msbuild "$solution" /verbosity:minimal /p:Configuration=Release /logger:"$customLogger"
    }
    else
    {
        C:\PROGRA~2\MSBuild\14.0\Bin\amd64\msbuild "$solution" /verbosity:minimal /p:Configuration=Release
    }
}

function Invoke-NuGetPack($version)
{
    nuget pack "src\Serilog.Sinks.Xamarin.nuspec" -Version $version -OutputDirectory artifacts\
}

function Invoke-Build($majorMinor, $patch, $customLogger, $notouch, $sln)
{
    $package="$majorMinor.$patch"
    $slnfile = "$sln.sln"

    Write-Output "$sln $package"

    if (-not $notouch)
    {
        $assembly = "$majorMinor.0.0"

        Write-Output "Assembly version will be set to $assembly"
        Set-AssemblyVersions $package $assembly
    }

    Install-NuGetPackages $slnfile
    
    Invoke-MSBuild $slnfile $customLogger

    Invoke-NuGetPack $package
}

$ErrorActionPreference = "Stop"

if (-not $sln)
{
    $slnfull = ls *.sln |
        Where-Object { -not ($_.Name -like "*net40*") } |
        Select -first 1

    $sln = $slnfull.BaseName
}

Invoke-Build $majorMinor $patch $customLogger $notouch $sln