# Serilog.Sinks.Xamarin [![Build status](https://ci.appveyor.com/api/projects/status/8iy9owuib92gvtix?svg=true)](https://ci.appveyor.com/project/serilog/serilog-sinks-xamarin) [![Join the chat at https://gitter.im/serilog/serilog](https://img.shields.io/gitter/room/serilog/serilog.svg)](https://gitter.im/serilog/serilog)

Writes [Serilog](https://serilog.net) events to the console of Xamarin.iOS (NSLog) / Xamarin.Android (AndroidLog).

### Getting started

Install from [NuGet](https://nuget.org/packages/serilog.sinks.xamarin):

```powershell
Install-Package Serilog.Sinks.Xamarin
```

When using Xamarin.iOS

```csharp
Log.Logger = new LoggerConfiguration()
    .WriteTo.NSLog()
    .CreateLogger();
```

When using Xamarin.Android


```csharp
Log.Logger = new LoggerConfiguration()
    .WriteTo.AndroidLog()
    .Enrich.WithProperty(Constants.SourceContextPropertyName, "MyCustomTag") //Sets the Tag field.
    .CreateLogger();
```

Within your portable class libary or within your application

```csharp
Log.Information("This will be written to either NSLog or AndroidLog");

```

Because the memory buffer may contain events that have not yet been written to the target sink, it is important to call `Log.CloseAndFlush()` or `Logger.Dispose()` when the application/activity exits.

### About this sink

This sink is maintained by [Geoffrey Huntley](https://ghuntley.com/).
