FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
WORKDIR /app

ENV DOTNET_GCServer=1 \
    DOTNET_GCConcurrent=1 \
    DOTNET_System_GCLatencyMode=0 \
    DOTNET_GCHeapHardLimit=0 \
    DOTNET_GCHeapCount=0 \
    DOTNET_GCHeapAffinitizeMask=0 \
    DOTNET_GCMemoryInfo=1 \
    DOTNET_TieredPGO=1 \
    DOTNET_TieredCompilation=1 \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=true

FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

COPY yarp/yarp.csproj ./yarp/
WORKDIR /src/yarp
RUN dotnet restore --use-current-runtime 

COPY yarp/. ./
RUN dotnet publish -c Release -o /app/publish \
    --no-restore \
    --self-contained true \
    -p:RuntimeIdentifier=linux-musl-x64 \
    -p:PublishTrimmed=false
    
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "yarp.dll"]
