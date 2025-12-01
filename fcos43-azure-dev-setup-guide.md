# Bazzite (Fedora Core 43 based) Linux
## Azure Developer Setup Guide

This guide will detail how to setup Azure CLI inside a Distrobox Debian based container, Azure Functions Core Tools and Azurite Docker Container to provide local storage emulation.

### Prequisites

Ensure your Bazzite distro is updated:
```bash
ujust update
```

Distrobox installed
Podman & Podman-Compose installed (*see [this guide](https://github.com/trevor-the-developer/articles/blob/main/fcos43-dotnet-dev-setup.md#podman-and-podman-compose) to perform the installation*).

An Azure account is needed and a free 30 day trial is available here (*the account details will be used later when configuring Azure CLI*): [Get started with Azure](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account?icid=free-services)

### Distrobox setup

Create a new Debian based Distrobox container:
```bash
distrobox create --name azure-tools --image docker.io/debian/eol:bullseye
```

Enter the container and perform the initial setup:
```bash
distrobox enter azure-tools
```

Once the setup is complete install nano editor:
```bash
sudo dnf install nano
```

We need to modify the sudoers file to ensure the container user has elevated privileges:
```bash
sudo visudo
```

Page-down key to get to the end locate the line:
```bash
root    ALL=(ALL)       ALL
```

add the following line below:
```bash
your-username    ALL=(ALL)       ALL
```

Where `your-username` is the user logged into the container - finally press `Ctrl o` key to write the changes and then `Ctrl x` key to exit.

Update the container:
```bash
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
```

### Azure CLI Installation

The best way to install Azure CLI is using a single command (*[source](https://learn.microsoft.com/en-gb/cli/azure/install-azure-cli-linux?view=azure-cli-latest&pivots=apt)*):
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Export the az tool to the host:
```bash
# run inside the container
distrobox-export --bin /usr/bin/az --export-path ~/.local/bin
```

### Azure Functions Core Tools Installation

Install the Microsoft package repository GPG key, to validate package integrity:
```bash
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
```

Set up the APT source list before doing an APT update.
```bash
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/debian/$(lsb_release -rs 2>/dev/null | cut -d'.' -f 1)/prod $(lsb_release -cs 2>/dev/null) main" > /etc/apt/sources.list.d/dotnetdev.list'
```

Update APT
```bash
sudo apt-get update && sudo apt-get upgrade
```

Install the Azure Functions Core Tools package:
```bash
sudo apt-get install azure-functions-core-tools-4

# opt out of telemetry if you prefer (recommended)
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1
```

Export the func tool to the host:
```bash
# run inside the container
distrobox-export --bin /usr/bin/func --export-path ~/.local/bin
```

### Test on the host
```bash
# azure-cli
az --version

# azure functions core tool
func --version
```

### Perform Azure Login

The following commands perform an Azure Login (*the browser will display the authentication page, login to complete the process*):
```bash
# inside the distrobox container
az login

# authentication persistence
az config set core.persistence=true
```

### Azurite

The best way to run the Azure Storage Emulator is a Docker image.   Create a `docker-compose.yml` in a suitable location:
```bash
# make a directory if one doesn't exist for example
mkdir -p ~/container-images/azurite

# create a new file using your favourite editor (micro is great available via flatpak on the host:
# flatpak install github.zyedidia.micro)
micro ~/container-images/azurite/docker-compose.yml
```

Enter the following yaml code (*pulls the Azurite image and configures it*):
```yaml
services:
  azurite:
    image: mcr.microsoft.com/azure-storage/azurite:latest
    container_name: azurite
    hostname: azurite
    restart: unless-stopped
    ports:
      - "10000:10000"  # Blob service
      - "10001:10001"  # Queue service
      - "10002:10002"  # Table service
    volumes:
      - azurite-data:/data
    command: "azurite --blobHost 0.0.0.0 --queueHost 0.0.0.0 --tableHost 0.0.0.0 --location /data --debug /data/debug.log"

volumes:
  azurite-data:
```

Start the docker container (navigate to the folder `~/container-images/azurite/`):
```bash
# the -d switch starts the containers in the background
podman-compose up -d
```

Verify the container is running:
```bash
podman ps
```

Check logs:
```bash
podman logs azurite
```

### Configure Azurite Connection String

Enter the distrobox container and set the connection string:
```bash
distrobox enter azure-tools

# set the connection string (replace the IP with your host IP)
export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://192.168.0.120:10000/devstoreaccount1;QueueEndpoint=http://192.168.0.120:10001/devstoreaccount1;TableEndpoint=http://192.168.0.120:10002/devstoreaccount1;"

# make permanent by adding to ~/.bashrc
echo 'export AZURE_STORAGE_CONNECTION_STRING="DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://192.168.0.120:10000/devstoreaccount1;QueueEndpoint=http://192.168.0.120:10001/devstoreaccount1;TableEndpoint=http://192.168.0.120:10002/devstoreaccount1;"' >> ~/.bashrc
```

### Test Azurite Connectivity

#### Basic Storage Operations
```bash
# Test Blob Storage
az storage container create --name test-container
az storage container list

# Test Queue Storage
az storage queue create --name test-queue

# Test Table Storage (note: no hyphens in table names)
az storage table create --name testtable

# Test file upload
echo "Hello Azure!" > test.txt
az storage blob upload --container-name test-container --file test.txt --name hello.txt
az storage blob list --container-name test-container
```

#### Verify Services
```bash
az storage container list
az storage queue list
az storage table list
```

The commands will output JSON:
```json
[
  {
    "approximateMessageCount": null,
    "metadata": null,
    "name": "test-queue"
  }
]

[
  {
    "deleted": null,
    "encryptionScope": null,
    "immutableStorageWithVersioningEnabled": null,
    "metadata": null,
    "name": "test-container",
    "properties": {
      "etag": "\"0x228BD69E6DBB4A0\"",
      "hasImmutabilityPolicy": false,
      "hasLegalHold": false,
      "lastModified": "2025-11-30T09:04:57+00:00",
      "lease": {
        "duration": null,
        "state": "available",
        "status": "unlocked"
      },
      "publicAccess": null
    },
    "version": null
  }
]

[
  {
    "name": "testtable"
  }
]
```

### Rider IDE Configuration

Start Rider then go to Settings (*File > Settings or `Ctrl+Alt+s` or the :gear: icon top right of the navigation strip*).   Select Plugins and then search for **Azure Toolkit for Rider** and install the plugin, when prompted restart Rider to enable (you will see an Azure icon on the left hand verticable icon bar the letter A).

### Azure Function Project Configuration

When you create a new Azure Function project e.g:
```bash
# inside your solution folder, targeting a specific dotnet framework
func init TestAzureFuncApp --worker-runtime dotnet-isolated --target-framework net9.0
```

Open the solution folder in Rider and when the Azure Functions project has loaded up open the file `local.settings.json` and paste the following:
```bash
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://192.168.0.120:10000/devstoreaccount1;QueueEndpoint=http://192.168.0.120:10001/devstoreaccount1;TableEndpoint=http://192.168.0.120:10002/devstoreaccount1;",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet"
  }
}
```

#### Azure Function Testing and Deployment

The Azure Toolkit in Rider can be used to publish the Function project to the Azure account.   The Azure Function can be tested locally with this command:
```bash
func start
```

Deploy to Azure Functions
```bash
# replace TestAzureFuncApp with your azure function app name
func azure functionapp publish TestAzureFuncApp
```

### Resources

#### Azurite Default Credentials

*Account Name*: `devstoreaccount1`
*Account Key*: `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==`
*Connection Shortcut*: `UseDevelopmentStorage=true`

#### Common Errors

Table naming: No hyphens allowed in table names
Queue features: Some queue commands are in preview
Network connectivity: Ensure ports `10000-10002` are accessible

#### Clean up commands
```bash
# replace name value with what is relevant to your app or testing
az storage container delete --name test-container
az storage queue delete --name test-queue
az storage table delete --name testtable
```

## Contributing

If you found this guide helpful, consider sharing it with the Bazzite/Universal Blue community on their Discord or GitHub discussions!

---

**Last Updated**: November 2025  
**Tested On**: Bazzite 43 (*Fedora Core 43*), NVIDIA Driver 580.95.05
