FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

ENV DOTNET_GCServer=1 \
    DOTNET_GCConcurrent=1 \
    DOTNET_System_GCLatencyMode=0 \
    DOTNET_ThreadPool_MinThreads=16 \
    DOTNET_GCHeapHardLimit=0 \
    DOTNET_GCHeapCount=0 \
    DOTNET_GCHeapAffinitizeMask=0 \
    DOTNET_GCMemoryInfo=1 \
    DOTNET_TieredPGO=1 \
    DOTNET_TieredCompilation=1 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY instance/instance.csproj ./instance/
WORKDIR /src/instance
RUN dotnet restore

COPY instance/. ./
RUN dotnet publish -c Release --no-restore -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "instance.dll"]
