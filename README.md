[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README.md)[![pt-br](https://img.shields.io/badge/lang-pt--br-green.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README_PT-BR.md)

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
**FOTO DO APP**
- In the VPC menu, click on `Create VPC`.
**FOTO DO MENU**
- Select the `VPC and more` option in the creation menu to have AWS assist in creating the VPC.
- Name the VPC, subnets, route tables, and network connections.
- Keep the IPv4 CIDR block.
- Keep the IPv6 CIDR block option as None.
- Select the default tenancy.**FOTO DO ASSISTENTE****FOTO DO ASSISTENTE**
- Select the Number of Availability Zones as two.
- Select the Number of public and private subnets as two.**FOTO DO ASSISTENTE**
- Select the NAT gateways as None.
- Select the VPC endpoint as the S3 Gateway. **FOTO DO ASSISTENTE**
- Enable DNS hostnames and DNS resolution. **FOTO DO ASSISTENTE**
- Click on `Create VPC`.
**FOTO DO ASSISTENTE**

### Criando um SecurityGroup
- No menu EC2 procure por SecurityGroup na barra de navegação a esquerda.
**FOTO DA BARRA**
- Acesse e clique em `Criar novo grupo de segurança`.
**FOTO DA PAGINA C O BOTAO**
- No menu de criação do SecurityGroup de um nome e uma descrição ao SecurityGroup.
- Ainda no menu de criação de SegurityGroup selecione como VPC a VPC criada anteriormente.
- Em regras de entrada, adicione regras para liberar as portas necessaria conforme a tabela abaixo:
Tipo | Protocolo | Intervalo de portas | Origem | Descrição
---|---|---|---|---
SSH | TCP | 22 | 0.0.0.0/0 | SSH
TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP
TCP personalizado | TCP | 443 | 0.0.0.0/0 | HTTPS
TCP personalizado | TCP | 111 | 0.0.0.0/0 | RPC
UDP personalizado | UDP | 111 | 0.0.0.0/0 | RPC
TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS
UDP personalizado | UDP | 2049 | 0.0.0.0/0 | NFS
- Em regras de saída mantenha a regra de saída padrão para liberar todo o trafego.
**FOTO DO MENU DE SECURTY GROUP**
- Para finalizar clique em `Criar grupo de segurança`.


### Criando uma instancia EC2 na AWS
- Na AWS busque pelo serviço de EC2 e acesse.
- Clique em `executar uma instancia`.
**FOTO DO PAINEL EC2**
- Na aba de Configuração Nome e Tags adione o nome e tags necessarias.
**FOTO TAGS**
- Em imagens de aplicação e de sistema operacional, busque e selecione Amazon Linux 2.
**FOTO DO LINUX 2**
- Em Tipo de instância selecione a instancia t3.small.
**FOTO INSTANCIA**
- Selecione o par de chave criado previamente.
**FOTO PAR DE CHAVE**
- Em Configuração de Rede Selecione a VPC criada anteriormente.
**FOTO DA VPC**
- Ainda em Configuração de Rede selecione o grupo de segurança criado anteriormente.
**FOTO DO GRUPO DE SEGURAÇA**
- Na aba Configurar armazenamento selecione um disco de 16GB padrão gp2.
**FOTO DO DISCO**
- Ao terminar as configurações basta clicar em `Executar Instância` para iniciar a criação.
**FOTO DA INICIALIZAÇÃO**
- Aguarde alguns segundos, a AWS ira criar e iniciar a instancia.
**FOTO DA INSTANCIA EM RUNNING**

### Criando um Elastic IP
- No menu EC2 procure no menu de servicos a esquerda pelo servico Elastic IP.
**FOTO DO MENU**
- No menu de Elastic IP clique em alocar endereço IP elástico.
**FOTO DO MENU DE IP**
- No menu de crição verifique se a região está correta e IPv4 está selecionado, e clique em alocar.
**FOTO DA CRIAÇÃO**
**EDITAR CASO NECESSARIO**
- No menu de Elastic IP clique em `Ações` selecione Associar endereço IP elástico, marque instancia e selecione a instancia criada previamente após isso clique em `Associar endereço de IP elástico`.

### Acessando a instancia via Putty
- Baixe e instale o [Putty](https://www.putty.org/).
- Em `Session` no campo Host Name, insira o public DNS(IPv4) da instancia EC2.
- Acesse `Connecrion` > `SSH` > `Auth` > `Credentials` e no campo `Private key file for authentication` selecione o arquivo .ppk da chave criada previamente.

### Acessando a instancia via SSH
- E necessario ter instalado o OpenSSH client, para instalar execute:
```
sudo yum install openssh-clients
```
- Tendo o OpenSSH instalado execute o comando:
```
ssh -i private_key.pem user@public_ip_or_dns
```
- `private_key.pem` = caminho para a chave .pem
- `user@public_ip_or_dns` = public DNS(IPv4) ou DNS da instancia EC2.

### Instalando Apache em uma intancia EC2
- Ao logar na instancia execute o comando abaixo para ganhar acesso como root.
```
sudo su
```
- Execute o comando para instalar o apache server e suas dependencias:
```
sudo yum install -y httpd
```
- Executando depois disso o comando para iniciar o apache server:
```
sudo systemctl enable --now httpd.service
```
- Execute para verificar o status do apache server:
```
sudo systemctl status httpd
```
- Caso o servidor esteja rodando corretamente agora deve ser possivel acessar a pagina de teste do apache atraves do ip elastico anexado a instancia.

### Criando um EFS(NSF SERVER)
- Busque por EFS na amazon AWS o serviço de arquivos de NFS escalavel da AWS.
**FOTO da aba**
- Na Pagina de EFS clique em `Criar sistema de arquivos`.
**FOTO DA PAGINA**
- Escolha um nome para o EFS e selecione uma VPC(a mesma da instancia) e clique em `Criar`.
**FOTO DA PAGINA DE CONFIG**
- Uma vez criado o EFS navegue ate network dentro dos detalhes do EFS e altere os security group para aquele que foi criado anteriormente.
**FOTOS DO CAMINHO E OPERAÇÃO**

### Criando uma pasta compartilhada EFS EC2
- Acesse a instancia, e digite o comando para instalar as dependencias necessarias para acessar o EFS na instancia do EC2:
```
sudo yum install -y amazon-efs-utils
```
- Uma vez que a instalação foi concluida, crie um diretorio para compartilhar entre a instancia EC2 e o EFS atraves do comando:
```
sudo mkdir /home/ec2-user/efs
```
- E necessario montar o EFS no diretorio atraves do comando:
```
sudo mount -t efs <EFS_FILE_SYSTEM_ID>:/ /home/ec2-user/efs
```
- `<EFS_FILE_SYSTEM_ID>` = o ID do EFS e composto por fs-xxxxxxxxx, ate o .efs.

- Uma vez concluido o processo de montagem do EFS crie um diretorio para armazenar os logs dentro do EFS com o comando:
```
sudo mkdir /home/ec2-user/efs/logs
```

### Criando um Script
- Crie um arquivo .sh para criar o script e abra-o com o editor de texto padrao atraves do comando:
```
vi check.sh
```
- Precione "i" para entrar no modo edicao do editor.
- Copie o script feito anteriormente no editor de texto.
- Feche o editor de texto, para isso precione "esc" para entrar no modo de comando, digite wq e precione enter.
- Habilite as permissaos necessarias para o Script, para isso execute o comando:
```
sudo chmod 777 check.sh
```
- Teste a execucao do script executando-o pelo comando:
```
sudo ~/check.sh
```

### Utilizando Contrab para automatizar a execução do Script
- Abra o crontab atraves do comando: 
```
crontab -e
```
- Precione "i" para entrar no modo edicao do editor.
- Cole `*/5 * * * * user Path_to_Script.sh`
- Substitua `user` pelo usuario desejado
- `Path_to_Script.sh` pelo caminho até o Script