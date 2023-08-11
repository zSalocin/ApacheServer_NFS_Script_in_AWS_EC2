[![en](https://img.shields.io/badge/lang-en-green.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README.md)   [![pt-br](https://img.shields.io/badge/lang-pt--br-red.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README_PT-BR.md)

# Atividade Linux

Repositório para a atividade de Linux, do programa de bolsas da Compass UOL.

**Objetivo**: Criar um ambiente AWS com uma instância EC2 e configurar o NFS para armazenar dados.

**Escopo**: A atividade incluirá a geração de uma chave pública de acesso, criação de uma instância EC2 com o sistema operacional Amazon Linux 2, geração de um endereço IP elástico e anexá-lo à instância EC2, liberação de portas de comunicação para acesso público, configuração do NFS, criação de um diretório com o nome do usuário no filesystem do NFS, instalação e configuração do Apache, criação de um script para validar se o serviço está online e enviar o resultado para o diretório NFS, e configuração da execução automatizada do script a cada 5 minutos.

**Referências**: [Documentação da Amazon Web Services](https://docs.aws.amazon.com/pt_br/index.html), [Documentação do Amazon Linux 2](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html), [Documentação do ApacheServer](https://docs.oracle.com/en/learn/apache-install/#introduction), [Documentação do Contrab](https://docs.oracle.com/en/learn/oracle-linux-crontab/#before-you-begin).

---
## Requisitos

### Instância AWS:
- Chave pública para acesso ao ambiente
- Amazon Linux 2
    - t3.small
    - 16 GB SSD
- 1 Elastic IP associado a instância
- Portas de comunicação liberadas
    - 22/TCP (SSH)
    - 111/TCP e UDP (RPC)
    - 2049/TCP/UDP (NFS)
    - 80/TCP (HTTP)
    - 443/TCP (HTTPS)

### Configurações Linux:

- Configurar o NFS entregue;
- Criar um diretório dentro do filesystem do NFS com seu nome;
- Subir um apache no servidor - o apache deve está online e rodando;
- Criar um script que valide se o serviço esta online e envie o resultado da validação para o seu diretório no nfs;
    - O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline;
    - O script deve gerar 2 arquivos de saída: 1 para o serviço online e 1 para o serviço OFFLINE;
    - Execução automatizada do script a cada 5 minutos.
---
## Passo a Passo

### Gerando um par de chaves
- No menu EC2 procure por KeyPair na barra de navegação à esquerda.
- No menu de KeyPair clique em `Criar par de chaves`.
- Insira um nome para a chave.
- Mantenha o tipo de par de chave como `RSA`.
- Em formato de arquivo da chave privada:
    - Use .pen caso faça uso do SSH;
    - Use .ppk caso faça uso do Putty.
- Clique em `Criar par de chaves`.

### Gerando uma chave pública a parte de uma chave privada .pem
- Para gerar a chave pública execute o comando:
```
ssh-keygen -y -f private_key.pem > chave_publica.pub
```
- `private_key.pem` = caminho da chave privada .pem

### Gerando uma chave pública a parte de uma chave privada .ppk
- Caso o Sistema Operacional seja Windows
    - Baixe e instale o [Puttygen](https://www.putty.org/)
    - Clique em `load` e selecione a chave privada .ppk
    - Clique em `Save public key` e selecione um local
- Caso o Sistema Operacional seja Linux
    - Baixe o Puttygen através do comando 
    ```
    sudo yum install putty-tools
    ```
    - Gere a chave pública através do comando:
     ```
    puttygen private_key.ppk -O public-openssh -o chave_publica.pub
    ```
    - `private_key.ppk` = caminho da chave privada .ppk

### Criando uma VPC
- Na AWS busque por VPC.

![VPC_APP](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_APP.png)

- No menu de VPC clique em `Criar VPC`.

![VPC_ASSISTENTE](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE.png)

- Selecione no menu de criação a opção `VPC e muito mais` para que a AWS auxilie a criação da VPC.
- Nomeie a VPC, Sub-redes, Tabelas de rotas e Conexões de rede.
- Mantenha o Bloco CIDR IPv4.
- Mantenha a opção de `Nenhum bloco CIDR IPv6`.
- Selecione Locação como padrão

![VPC_ASSISTENTE_PADRAO](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_PADRAO.png)

- Selecione o Número de zonas de disponibilidades como dois.
- Selecione o Número de sub-redes públicas e privadas como dois.

![VPC_ASSISTENTE_AZ](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_AZ.png)

- Selecione Gatways NAT como nenhum.
- Selecione como Endpoint da VPC o Gateway do S3.

![VPC_ASSISTENTE_GATEWAY](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_GATEWAY.png)

- Habilite nomes de host DNS e resolução de DNS.

![VPC_ASSISTENTE_DNS](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/VPC_ASSISTENTE_DNS.png)

- Clique em `Criar VPC`.

### Criando um SecurityGroup
- No menu EC2 procure por SecurityGroup na barra de navegação à esquerda.

![SC_BARRA](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/SC_BARRA.png)

- Acesse e clique em `Criar novo grupo de segurança`.
- No menu de criação do Security Group de um nome e uma descrição ao Security Group.
- Ainda no menu de criação de Segurity Group selecione como VPC a VPC criada anteriormente.
- Em regras de entrada, adicione regras para liberar as portas necessária conforme a tabela abaixo:

| Tipo | Protocolo | Intervalo de portas | Origem | Descrição |
| ---|---|---|---|--- |
| SSH | TCP | 22 | 0.0.0.0/0 | SSH |
| TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP |
| TCP personalizado | TCP | 443 | 0.0.0.0/0 | HTTPS |
| TCP personalizado | TCP | 111 | 0.0.0.0/0 | RPC |
| TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS |
| UDP personalizado | UDP | 111 | 0.0.0.0/0 | RPC |
| UDP personalizado | UDP | 2049 | 0.0.0.0/0 | NFS |

- Em regras de saída mantenha a regra de saída padrão para liberar todo o tráfego.

![SC_MENU](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/SC_MENU.png)

- Para finalizar clique em `Criar grupo de segurança`.


### Criando uma instancia EC2 na AWS
- Na AWS busque pelo serviço de EC2 e acesse.

![EC2_APP](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_APP.png)

- Clique em `executar uma instância`.
- Na aba de Configuração Nome e Tags adione o nome e tags necessarias.

![EC2_TAGS](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_TAGS.png)

- Em imagens de aplicação e de sistema operacional, busque e selecione Amazon Linux 2.

![EC2_LINUX](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_LINUX.png)

- Em Tipo de instância selecione a instância t3.small.

![EC2_INSTANCE](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_INSTANCE.png)

- Selecione o par de chaves criado previamente.

![EC2_KEYPAIR](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_KEYPAIR.png)

- Em Configuração de Rede Selecione a VPC criada anteriormente.

![EC2_SC](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_SC.png)

- Ainda em Configuração de Rede selecione o grupo de segurança criado anteriormente.

![EC2_SC](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_SC.png)

- Na aba Configurar armazenamento selecione um disco de 16GB padrão gp2.

![EC2_HD](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_HD.png)

- Ao terminar as configurações basta clicar em `Executar Instância` para iniciar a criação.
- Aguarde alguns segundos, a AWS irá criar e iniciar a instância.

![EC2_RUNNING](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EC2_RUNNING.png)

### Criando um Elastic IP
- No menu EC2 procure no menu de serviços a esquerda pelo serviços Elastic IP.

![SC_BARRA](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/SC_BARRA.png)

- No menu de Elastic IP clique em alocar endereço IP elástico.
- No menu de criação verifique se a região está correta e IPv4 está selecionado, e clique em alocar.

![IP_MENU](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/IP_MENU.png)

- No menu de Elastic IP clique em `Ações` selecione Associar endereço IP elástico, marque instância e selecione a instância criada previamente após isso clique em `Associar endereço de IP elástico`.

![IP_ASSOCIAR](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/IP_ASSOCIAR.png)

### Acessando a instância via Putty
- Baixe e instale o [Putty](https://www.putty.org/).
- Em `Session` no campo Host Name, insira o public DNS(IPv4) da instância EC2.
- Acesse `Connection` > `Data` e no campo `Auto-login username`, digite `ec2-user`.
- Acesse `Connection` > `SSH` > `Auth` > `Credentials` e no campo `Private key file for authentication` selecione o arquivo .ppk da chave criada previamente.

### Acessando a instância via SSH
- É necessário ter instalado o OpenSSH client, para instalar execute:
```
sudo yum install openssh-clients
```
- Tendo o OpenSSH instalado execute o comando:
```
ssh -i private_key.pem user@public_ip_or_dns
```
- `private_key.pem` = caminho para a chave .pem
- `user@public_ip_or_dns` = public DNS(IPv4) ou DNS da instância EC2.

### Instalando Apache em uma instância EC2
- Execute o comando para instalar o apache server e suas dependências:
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
- Caso o servidor esteja rodando corretamente agora deve ser possível acessar a página de teste do apache através do ip elástico anexado a instância.

### Criando um EFS(NSF SERVER)
- Busque por EFS na Amazon AWS o serviço de arquivos de NFS escalável da AWS.

![EFS_APP](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EFS_APP.png)

- Na Página de EFS clique em `Criar sistema de arquivos`.
- Escolha um nome para o EFS e selecione uma VPC(a mesma da instância) e clique em `Criar`.

![EFS_MENU](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EFS_MENU.png)

- Acesse a pagina de configuração do EFS

![EFS_CONFIG](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EFS_CONFIG.png)

- Uma vez criado o EFS navegue até network, e acesse gerenciar dentro dos detalhes do EFS e altere os security group para aquele que foi criado anteriormente.

![EFS_NETWORK_SC](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/Assets/EFS_NETWORK_SC.png)

### Criando uma pasta compartilhada EFS EC2
- Acesse a instância, e digite o comando para instalar as dependencias necessárias para acessar o EFS na instância do EC2:
```
sudo yum install -y amazon-efs-utils
```
- Uma vez que a instalação foi concluida, crie um diretorio para compartilhar entre a instância EC2 e o EFS através do comando:
```
sudo mkdir /home/ec2-user/efs
```
- É necessário montar o EFS no diretório através do comando:
```
sudo mount -t efs <EFS_FILE_SYSTEM_ID>:/ /home/ec2-user/efs
```
- `<EFS_FILE_SYSTEM_ID>` = o ID do EFS é composto por fs-xxxxxxxxx, até o .efs.

- Uma vez concluído o processo de montagem do EFS crie um diretório para armazenar os logs dentro do EFS com o comando:
```
sudo mkdir /home/ec2-user/efs/logs
```

#### Para tornar a montagem persistente, siga estes passos:
- Acesse o arquivo /etc/fstab usando o comando:
```
sudo nano /etc/fstab
```
- No interior do arquivo, adicione a seguinte linha no final:
```
<DNS_NAME_DO_EFS>:/ /mnt/efs nfs4 defaults 0 0
```
- Para confirmar, leia o arquivo /etc/fstab usando o comando:
```
cat /etc/fstab
```

### Criando um Script
- Crie um arquivo .sh para criar o script e abra-o com o editor de texto padrão através do comando:
```
vi check.sh
```
- Pressione "i" para entrar no modo edição do editor.
- Copie o script feito anteriormente no editor de texto.
- Feche o editor de texto, para isso pressione "esc" para entrar no modo de comando, digite wq e pressione enter.
- Habilite as permissões necessárias para o Script, para isso execute o comando:
```
sudo chmod +x check.sh
```
- Teste a execução do script executando-o pelo comando:
```
sudo /home/ec2-user/check.sh
```

### Utilizando Crontab para automatizar a execução do Script
- Abra o crontab através do comando: 
```
crontab -e
```
- Pressione "i" para entrar no modo edição do editor.
- Digite `*/5 * * * * /home/ec2-user/check.sh`.
- Substitua `/home/ec2-user/check.sh` pelo caminho até o Script.
- Verifique se o serviço cron esta sendo executado:
```
sudo systemctl status crond
```
- Caso o serviço não esteja em exeução, inicie-o com o comando abaixo: 
```
sudo systemctl start crond
```