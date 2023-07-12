[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README.md)   [![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README_PT-BR.md)

# Linux Activity

Repository for the Linux activity of the Compass UOL scholarship program.

**Objective**: Create an AWS environment with an EC2 instance and configure NFS to store data.

**Scope**: The activity will include generating a public access key pair, creating an EC2 instance with the Amazon Linux 2 operating system, generating an elastic IP address and attaching it to the EC2 instance, opening communication ports for public access, configuring NFS, creating a directory with the user's name in the NFS filesystem, installing and configuring Apache, creating a script to validate if the service is online and sending the result to the NFS directory, and configuring automated execution of the script every 5 minutes.

**References**: [Amazon Web Services Documentation](https://docs.aws.amazon.com/pt_br/index.html), [Amazon Linux 2 Documentation](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html), [ApacheServer Documentation](https://docs.oracle.com/en/learn/apache-install/#introduction), [Crontab Documentation](https://docs.oracle.com/en/learn/oracle-linux-crontab/#before-you-begin).

---
## Requirements

### AWS Instance:
- Public key for accessing the environment
- Amazon Linux 2
    - t3.small
    - 16 GB SSD
- 1 Elastic IP associated with the instance
- Open communication ports
    - 22/TCP (SSH)
    - 111/TCP e UDP (RPC)
    - 2049/TCP/UDP (NFS)
    - 80/TCP (HTTP)
    - 443/TCP (HTTPS)

### Linux Configuration:

- Configure the delivered NFS;
- Create a directory within the NFS filesystem with your name;
- Set up an Apache server - the Apache server should be online and running;
- Create a script that validates if the service is online and sends the validation result to your directory in NFS;
    - The script should contain - DATE TIME + service name + status + custom message of ONLINE or offline;
    - The script should generate 2 output files: 1 for the online service and 1 for the offline service;
    - Automate the script execution every 5 minutes.
---
## Step by Step

### Generating a Key Pair
- In the EC2 menu, search for Key Pair in the left navigation bar.
- In the Key Pair menu, click on `Create Key Pair`.
- Enter a name for the key pair.
- Keep the key pair type as `RSA`.
- In the private key file format:
    - Use .pen if using SSH;
    - Use .ppk if using Putty.
- Click on `Create Key Pair`.

### Generating a Public Key from a Private Key .pem
- To generate the public key, execute the following command:
```
ssh-keygen -y -f private_key.pem > chave_publica.pub
```
- `private_key.pem` = path to the .pem private key

### Generating a Public Key from a Private Key .ppk
- If the Operating System is Windows
    - Download and install [Puttygen](https://www.putty.org/)
    - Click on `load` and select the .ppk private key.
    - Click on `Save public key` and select a location.
- If the Operating System is Linux
    - Download Puttygen using the command
    ```
    sudo yum install putty-tools
    ```
    - Generate the public key using the command:
     ```
    puttygen private_key.ppk -O public-openssh -o chave_publica.pub
    ```
    - `private_key.ppk` = path to the .ppk private key

### Creating a VPC
- In AWS, search for VPC.
![VPC_APP](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_APP.png)
- In the VPC menu, click on `Create VPC`.
![VPC_ASSISTENTE](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE.png)
- Select the `VPC and more` option in the creation menu to have AWS assist in creating the VPC.
- Name the VPC, subnets, route tables, and network connections.
- Keep the IPv4 CIDR block.
- Keep the IPv6 CIDR block option as None.
- Select the default location.
![VPC_ASSISTENTE_PADRAO](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_PADRAO.png)
- Select the Number of Availability Zones as two.
- Select the Number of public and private subnets as two.
![VPC_ASSISTENTE_AZ](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_AZ.png)
- Select the NAT gateways as None.
- Select the VPC endpoint as the S3 Gateway.
![VPC_ASSISTENTE_GATEWAY](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_GATEWAY.png)
- Enable DNS hostnames and DNS resolution.
![VPC_ASSISTENTE_DNS](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_DNS.png)
- Click on `Create VPC`.

### Creating a Security Group
- In the EC2 menu, search for Security Group in the left navigation bar.
![SC_BARRA](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/SC_BARRA.png)
- Access it and click on `Create Security Group`.
- In the Security Group creation menu, give a name and description to the Security Group.
- AIn the same Security Group creation menu, select the VPC created earlier.
- In inbound rules, add rules to open the necessary ports according to the table below:
Type | Protocol | Port Range | Source | Description
---|---|---|---|---
SSH | TCP | 22 | 0.0.0.0/0 | SSH
TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP
TCP personalizado | TCP | 443 | 0.0.0.0/0 | HTTPS
TCP personalizado | TCP | 111 | 0.0.0.0/0 | RPC
UDP personalizado | UDP | 111 | 0.0.0.0/0 | RPC
TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS
UDP personalizado | UDP | 2049 | 0.0.0.0/0 | NFS
- Keep the default outbound rule to allow all traffic.
![SC_MENU](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/SC_MENU.png)
- Click on `Create Security Group` to finish.


### Criando uma instancia EC2 na AWS
- In AWS, search for the EC2 service and access it.
![EC2_APP](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_APP.png)
- Click on `Launch Instance`.
- In the Name and Tags Configuration tab, add the necessary name and tags.
![EC2_TAGS](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_TAGS.png)
- In the application and operating system images, search and select Amazon Linux 2.
![EC2_LINUX](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_LINUX.png)
- In the Instance Type, select the t3.small instance.
![EC2_INSTANCE](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_INSTANCE.png)
- Select the previously created key pair.
![EC2_KEYPAIR](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_KEYPAIR.png)
- In the Network Configuration, select the previously created VPC.
![EC2_SC](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_SC.png)
- Still in the Network Configuration, select the previously created security group.
![EC2_SC](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_SC.png)
- In the Configure Storage tab, select a 16GB gp2 default disk.
![EC2_HD](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_HD.png)
- After completing the configurations, click on `Launch Instance` to start the creation process.
- Wait for a few seconds, AWS will create and start the instance.
**FOTO DA INSTANCIA EM RUNNING**

### Criando um Elastic IP
- In the EC2 menu, search for Elastic IP in the left navigation bar.
![SC_BARRA](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/SC_BARRA.png)
- In the Elastic IP menu, click on `Allocate new address`.
- Check if the region is correct and IPv4 is selected, and click on `Allocate`.
![IP_MENU](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/IP_MENU.png)
- In the Elastic IP menu, click on `Actions`, select `Associate Elastic IP address`, check instance, select the previously created instance, and then click on `Associate Elastic IP address`.

### Accessing the Instance via Putty
- Download and install [Putty](https://www.putty.org/).
- In `Session`, enter the public DNS (IPv4) of the EC2 instance in the Host Name field.
- Access `Connection` > `SSH` > `Auth` > `Credentials` and in the `Private key file for authentication` field, select the .ppk file of the previously created key.

### Accessing the Instance via SSH
- You need to have the OpenSSH client installed. To install it, execute the command:
```
sudo yum install openssh-clients
```
- Once you have OpenSSH installed, use the following command to access the instance:
```
ssh -i private_key.pem user@public_ip_or_dns
```
- `private_key.pem` = path to the .pem key
- `user@public_ip_or_dns` = EC2 instance's public DNS (IPv4) or DNS.

### Installing Apache on an EC2 Instance
- After logging into the instance, use the following command to gain root access:
```
sudo su
```
- Execute the command to install the Apache server and its dependencies:
```
sudo yum install -y httpd
```
- After that, execute the command to start the Apache server:
```
sudo systemctl enable --now httpd.service
```
- Use the following command to check the status of the Apache server:
```
sudo systemctl status httpd
```
- If the server is running correctly, it should be possible to access the Apache test page using the elastic IP attached to the instance.

### Criando um EFS(NSF SERVER)
- Search for EFS in the Amazon AWS, the scalable NFS file service.
![EFS_APP](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EFS_APP.png)
- On the EFS page, click on `Create file system`.
![EFS_MENU](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EFS_MENU.png)
- Choose a name for the EFS and select a VPC (the same as the instance) and click on `Create`.
**FOTO DA PAGINA DE CONFIG**
- Once the EFS is created, navigate to the network within the EFS details and change the security group to the one created earlier.
**FOTOS DO CAMINHO E OPERAÇÃO**

### Creating a Shared EFS EC2 Folder
- Access the instance and execute the command to install the necessary dependencies to access the EFS on the EC2 instance:
```
sudo yum install -y amazon-efs-utils
```
- Once the installation is complete, create a directory to share between the EC2 instance and the EFS using the command:
```
sudo mkdir /home/ec2-user/efs
```
- EMount the EFS to the directory using the command:
```
sudo mount -t efs <EFS_FILE_SYSTEM_ID>:/ /home/ec2-user/efs
```
- `<EFS_FILE_SYSTEM_ID>` = the EFS ID in the format fs-xxxxxxxxx, up to the .efs.

- After the EFS is mounted, create a directory to store logs within the EFS using the command:
```
sudo mkdir /home/ec2-user/efs/logs
```

### Creating a Script
- Create a .sh file to create the script and open it with the default text editor using the command:
```
vi check.sh
```
- Press "i" to enter the editor's edit mode.
- Copy the previously made script into the text editor.
- Close the text editor by pressing "esc" to enter command mode, type wq, and press enter.
- Grant the necessary permissions to the script using the command:
```
sudo chmod 777 check.sh
```
- Test the script execution by running it using the command:
```
sudo ~/check.sh
```

### Using Cron to Automate Script Execution
- Abra o crontab atraves do comando: 
```
crontab -e
```
- Press "i" to enter the editor's edit mode.
- Copy `*/5 * * * * user Path_to_Script.sh`
- Replace `user` with the desired user.
- Replace `Path_to_Script.sh` with the path to the script.