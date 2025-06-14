FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

COPY yarp/yarp.csproj ./yarp/
WORKDIR /src/yarp
RUN dotnet restore -r linux-musl-x64

COPY yarp/. ./
RUN dotnet publish -c Release -o /app/publish \
    --self-contained true \
    -r linux-musl-x64 \
    -p:PublishTrimmed=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final
WORKDIR /app

# Create a non-root user and group
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set environment variables
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

# Copy published files and set ownership to non-root user
COPY --from=build --chown=appuser:appgroup /app/publish .
# Switch to non-root user
USER appuser

EXPOSE 8080
ENTRYPOINT ["dotnet", "yarp.dll"]