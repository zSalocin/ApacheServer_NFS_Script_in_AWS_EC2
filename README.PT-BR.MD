[![en](https://img.shields.io/badge/lang-en-green.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README.md)

[![pt-br](https://img.shields.io/badge/lang-pt--br-red.svg)](https://github.com/zSalocin/ApacheServer_NFS_Script_in_AWS_EC2/blob/main/README.PT-BR.md)

# Atividade Linux

Repositorio para a atividade de Linux, do programa de bolsas da Compass UOL.

**Objetivo**: Criar um ambiente AWS com uma instância EC2 e configurar o NFS para armazenar dados.

**Escopo**: A atividade incluirá a geração de uma chave pública de acesso, criação de uma instância EC2 com o sistema operacional Amazon Linux 2, geração de um endereço IP elástico e anexá-lo à instância EC2, liberação de portas de comunicação para acesso público, configuração do NFS, criação de um diretório com o nome do usuário no filesystem do NFS, instalação e configuração do Apache, criação de um script para validar se o serviço está online e enviar o resultado para o diretório NFS, e configuração da execução automatizada do script a cada 5 minutos.

**Referências**: [Documentação da Amazon Web Services](https://docs.aws.amazon.com/pt_br/index.html), [Documentação do Amazon Linux 2](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html), [Documentação do ApacheServer](https://docs.oracle.com/en/learn/apache-install/#introduction), [Documentação do Contrab](https://docs.oracle.com/en/learn/oracle-linux-crontab/#before-you-begin).

---
## Requisitos

### Instancia AWS:
- Chave pública para acesso ao ambiente
- Amazon Linux 2
    - t3.small
    - 16 GB SSD
- 1 Elastic IP associado a instancia
- Portas de comunicação liberadas
    - 22/TCP (SSH)
    - 111/TCP e UDP (RPC)
    - 2049/TCP/UDP (NFS)
    - 80/TCP (HTTP)
    - 443/TCP (HTTPS)

### Configurações Linux:

- Configurar o NFS entregue;
- Criar um diretorio dentro do filesystem do NFS com seu nome;
- Subir um apache no servidor - o apache deve estar online e rodando;
- Criar um script que valide se o serviço esta online e envie o resultado da validação para o seu diretorio no nfs;
    - O script deve conter - Data HORA + nome do serviço + Status + mensagem personalizada de ONLINE ou offline;
    - O script deve gerar 2 arquivos de saida: 1 para o serviço online e 1 para o serviço OFFLINE;
    - Execução automatizada do script a cada 5 minutos.
---
## Passo a Passo

### Gerando um par de chaves
- No menu EC2 procure por KeyPair na barra de navegação a esquerda.
- No menu de KeyPair clique em `Criar par de chaves`.
- Insira um nome para a chave.
- Mantenha o tipo de par de chave como `RSA`.
- Em formato de arquivo da chave privada:
    - Use .pen caso faça uso do SSH;
    - Use .ppk caso faça uso do Putty.
- Clique em `Criar par de chaves`.

### Gerando uma chave publica a parte de uma chave privada .pem
- Para gerar a chave publica execute o comando:
```
ssh-keygen -y -f private_key.pem > chave_publica.pub
```
- `private_key.pem` = caminho da chave privada .pem

### Gerando uma chave publica a parte de uma chave privada .ppk
- Caso o Sistema Operacional seja Windows
    - Baixe e instale o [Puttygen](https://www.putty.org/)
    - Clique em `load` e selecione a chave privada .ppk
    - Clique em `Save public key` e selecione um local
- Caso o Sistema Operacional seja Linux
    - Baixe o Puttygen atraves do comando 
    ```
    sudo yum install putty-tools
    ```
    - Gere a chave publica atraves do comando:
     ```
    puttygen private_key.ppk -O public-openssh -o chave_publica.pub
    ```
    - `private_key.ppk` = caminho da chave privada .ppk

### Criando uma VPC
- Na AWS busque por VPC.
**FOTO DO APP**
- No menu de VPC clique em `Criar VPC`.
**FOTO DO MENU**
- Selecione no menu de criação a opção `VPC e muito mais` para que a AWS auxilie a criação da VPC.
- Nomeie a VPC, Sub-redes, Tabelas de rotas e Conexões de rede.
- Mantenha o Bloco CIDR IPv4.
- Mantenha a opção de Nenhum bloco CIDR IPv6.
- Selecione Locação como padrão**FOTO DO ASSISTENTE****FOTO DO ASSISTENTE**
- Selecione o Número de zonas de disponibilidades como dois.
- Selecione o Numero de sub-redes públicas e privadas como dois.**FOTO DO ASSISTENTE**
- Selecione Gatways NAT como nenhum.
- Selecione como Endpoint da VPC o Gateway do S3. **FOTO DO ASSISTENTE**
- Habilite nomes de host DNS e resolução de DNS. **FOTO DO ASSISTENTE**
- Clique em `Criar VPC`.

### Criando um SecurityGroup
- No menu EC2 procure por SecurityGroup na barra de navegação a esquerda.
**FOTO DA BARRA**
- Acesse e clique em `Criar novo grupo de segurança`.
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
**FOTO EC2 APP**
- Clique em `executar uma instancia`.
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
- Aguarde alguns segundos, a AWS ira criar e iniciar a instancia.
**FOTO DA INSTANCIA EM RUNNING**

### Criando um Elastic IP
- No menu EC2 procure no menu de servicos a esquerda pelo servico Elastic IP.
**FOTO DO MENU MSM DO SC**
- No menu de Elastic IP clique em alocar endereço IP elástico.
**FOTO DO MENU DE IP**
- No menu de crição verifique se a região está correta e IPv4 está selecionado, e clique em alocar.
**FOTO DA CRIAÇÃO**
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