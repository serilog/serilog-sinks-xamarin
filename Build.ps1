param(
    [String] $majorMinorPatch = "0.0.0",  # 2.0
    [String] $revision = "0",         # $env:APPVEYOR_BUILD_VERSION
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

function Invoke-MSBuild($solution, $assembly, $customLogger)
{
    if ($customLogger)
    {
        msbuild "$solution" /verbosity:minimal /p:Configuration=Release /p:AssemblyVersion=$assembly /p:FileVersion=$assembly /p:InformationalVersion=$assembly /logger:"$customLogger"
    }
    else
    {
        msbuild "$solution" /verbosity:minimal /p:Configuration=Release /p:AssemblyVersion=$assembly /p:FileVersion=$assembly /p:InformationalVersion=$assembly
    }
}

function Invoke-NuGetPack($version)
{
    nuget pack "src/Serilog.Sinks.Xamarin.nuspec" -Version $version -OutputDirectory artifacts\ -properties Configuration=Release
}

function Invoke-Build($majorMinorPatch, $revision, $customLogger, $notouch, $sln)
{
    $package="$majorMinorPatch.$revision"
    $slnfile = "$sln.sln"

    Write-Output "$sln $package"

    if (-not $notouch)
    {
        $assembly = "$majorMinorPatch.$revision"

        Write-Output "Assembly version will be set to $assembly"
        Set-AssemblyVersions $package $assembly
    }

    $assembly = "$majorMinorPatch.$revision"

    Write-Output "Assembly version will be set to $assembly"
    Set-AssemblyVersions $package $assembly

    Install-NuGetPackages $slnfile
    
    Invoke-MSBuild $slnfile $assembly $customLogger

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

Invoke-Build $majorMinorPatch $revision $customLogger $notouch $sln
