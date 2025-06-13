using Microsoft.AspNetCore.ResponseCompression;
using OpenTelemetry.Exporter;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using Prometheus;
using Serilog;
using Serilog.Extensions;
using Serilog.Sinks.OpenTelemetry;

var builder = WebApplication.CreateSlimBuilder(args);
var configuration = builder.Configuration;

builder.WebHost.UseKestrel((context, options) => { options.Configure(context.Configuration.GetSection("Kestrel")); });

var resourceAttributes = new Dictionary<string, object>
{
    ["service.name"] = Environment.GetEnvironmentVariable("INSTANCE_NAME") ?? "unknown",
    ["service.version"] = "1.0.0",
    ["service.instance.id"] = Guid.NewGuid().ToString("N")
};

builder.Services.AddResponseCompression(options =>
{
    options.Providers.Add<GzipCompressionProvider>();
    options.EnableForHttps = true;
});

builder.Host.UseSerilog((context, services, logger) =>
{
    logger
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .WriteTo.Async(opt => opt.OpenTelemetry(otp =>
        {
            otp.Endpoint = configuration["otel:http"]!;
            otp.Protocol = OtlpProtocol.HttpProtobuf;
            otp.ResourceAttributes = resourceAttributes;
        }));
});

builder.Services.AddOpenTelemetry()
    .ConfigureResource(resourceBuilder =>
    {
        resourceBuilder.AddService(
            resourceAttributes["service.name"].ToString()!,
            serviceVersion: resourceAttributes["service.version"].ToString(),
            serviceInstanceId: resourceAttributes["service.instance.id"].ToString()
        );
        resourceBuilder.AddAttributes(resourceAttributes);
    })
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation(opt => opt.RecordException = true)
        .AddHttpClientInstrumentation(opt => opt.RecordException = true)
        .AddOtlpExporter(opt =>
        {
            opt.Endpoint = new Uri(configuration["otel:grpc"]!);
            opt.Protocol = OtlpExportProtocol.Grpc;
        }))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddRuntimeInstrumentation()
        .AddHttpClientInstrumentation()
        .AddProcessInstrumentation()
        .AddPrometheusExporter()
        .AddOtlpExporter(opt =>
        {
            opt.Endpoint = new Uri(configuration["otel:grpc"]!);
            opt.Protocol = OtlpExportProtocol.Grpc;
        }));


builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapGet("internal/api/v1/ping", () =>
    Results.Ok(new
    {
        Instance = Environment.GetEnvironmentVariable("INSTANCE_NAME") ?? "unknown",
        RequestId = Guid.NewGuid().ToString("N"),
        Timestamp = DateTime.UtcNow.ToString("O")
    }));

app.UseRouting();
app.UseResponseCaching();
app.UseMetricServer();
app.UseHttpMetrics();
app.UseOpenTelemetryPrometheusScrapingEndpoint();
app.UseSerilogMemoryUsageExact();
app.UseSerilogRequestLogging();
app.MapHealthChecks("/health");

await app.RunAsync();