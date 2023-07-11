# Atividade Linux

Repositorio para a atividade de Linux, do programa de bolsas da Compass UOL.

**Objetivo**: Criar um ambiente AWS com uma instância EC2 e configurar o NFS para armazenar dados.

**Escopo**: A atividade incluirá a geração de uma chave pública de acesso, criação de uma instância EC2 com o sistema operacional Amazon Linux 2, geração de um endereço IP elástico e anexá-lo à instância EC2, liberação de portas de comunicação para acesso público, configuração do NFS, criação de um diretório com o nome do usuário no filesystem do NFS, instalação e configuração do Apache, criação de um script para validar se o serviço está online e enviar o resultado para o diretório NFS, e configuração da execução automatizada do script a cada 5 minutos.

**Referências**: [Documentação da Amazon Web Services](https://docs.aws.amazon.com/pt_br/index.html), [Documentação do Amazon Linux 2](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/amazon-linux-2-virtual-machine.html), [Documentação do ApacheServer](https://docs.oracle.com/en/learn/apache-install/#introduction), [Documentação do Contrab](https://docs.oracle.com/en/learn/oracle-linux-crontab/#before-you-begin)
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

### Gerando uma chave publica a parte de uma chave privada

### Criando uma VPC
Ao criar um VPC selecione o serviço de VPC
# FOTO DO MENU
 Criar VPC, e use o assistente para criar a VPC, Sub-nets, tabelas de roteamento e gateways de forma auomatica.
 # FOTO DO ASSISTENTE

### Criando um SecurityGroup
Em EC2 procure por SecurityGroup na barra de navegação a esquerda
# FOTO DA BARRA
 acesse, crie um novo security group de acordo com as portas requeridas no caso: 
# EDITAR
 Tipo | Protocolo | Intervalo de portas | Origem | Descrição
    ---|---|---|---|---
    SSH | TCP | 22 | 0.0.0.0/0 | SSH
    TCP personalizado | TCP | 80 | 0.0.0.0/0 | HTTP
    TCP personalizado | TCP | 443 | 0.0.0.0/0 | HTTPS
    TCP personalizado | TCP | 111 | 0.0.0.0/0 | RPC
    UDP personalizado | UDP | 111 | 0.0.0.0/0 | RPC
    TCP personalizado | TCP | 2049 | 0.0.0.0/0 | NFS
    UDP personalizado | UDP | 2049 | 0.0.0.0/0 | NFS
# FOTO DO MENU DE SECURTY GROUP


### Criando uma instancia EC2 na AWS
No console procure pelo serviço de EC2 e clique para acessar.
clique em executar uma instancia para criar uma instancia
# FOTO DO PAINEL EC2
 em tags adicione as tags necessarios caso haja alguma.
# FOTO TAGS
Na imagem do sistema escolha Amazon Linux 2
# FOTO DO LINUX 2
 no tipo de instancia selecione a instancia desejada (no caso t3.small)
# FOTO INSTANCIA
  selecionar par de chave para ssh ou putty (cuidado ao criar o par de chave pois ele é unico e não recuperavel)
# FOTO PAR DE CHAVE

em configuração de rede selecione a VPC
# FOTO DA VPC
selecionar grupo de segurança existente e selecione o grupo de segurança criado anteriormente
# FOTO DO GRUPO DE SEGURAÇA
após isso na aba configurar armazenamento escolha o tipo de disco e o tamanho do disco(no caso 16GB).
# FOTO DO DISCO
e execute a instancia, ira levar alguns segundos para a AWS inicializar a instancia.
# FOTO DA INICIALIZAÇÃO
aguarde alguns segundo e a instancia estara pronta para uso
# FOTO DA INSTANCIA EM RUNNING

### Criando um Elastic IP
Em EC2 procure no menu a esquerda Elastic IP
# FOTO DO MENU
 após isso clique em alocar endereço IP elástico
# FOTO DO MENU DE IP
  verifique se a região está correta e ipv4 está selecionado, e clique em alocar, após isso clique sobre o endereço IP
# FOTO DA CRIAÇÃO  
 clique em ações selecione Associar endereço IP elástico, marque instancia e selecione a instancia criada previamente após isso clique em associar

### Acessando a instancia via putty
TODO

### Instalando Apache em uma intancia EC2
Após logar na instancia execute o comando:
`sudo su`
depois disso execute o comando para instalar o apache server e suas dependencias:
`sudo yum install -y httpd`
executando depois disso o comando para iniciar o apache server:
`sudo systemctl enable --now httpd.service`
após esse comando execute para verificar o status do apache server:
`sudo systemctl status httpd`
se o servidor estiver rodando corretamente agora deve ser possivel acessar a pagina de teste do apache atraves do ip elastico anexado a instancia.

### Criando um EFS(NSF SERVER)
Busque por EFS na amazon AWS o serviço de arquivos de NFS escalavel da AWS
# FOTO da aba
Na Pagina de EFS clique em criar sistema de arquivos
# FOTO DA PAGINA
Escolha um nome para o EFS e selecione uma VPC(a mesma da instancia) e clique em criar
# FOTO DA PAGINA DE CONFIG
após criado va em network dentro dos detalhes do EFS e altere os security group para o mesmo da instancia EC2
# FOTOS DO CAMINHO E OPERAÇÃO

### Criando uma pasta compartilhada EFS EC2
acesse a instancia, e digite o comando para instalar as dependencias necessarias para acessar o efs na instancia do EC2:
`sudo yum install -y amazon-efs-utils`
após a instalação crie um diretorio para compartilhar entre a instancia EC2 e o EFS atraves do comando:
`sudo mkdir /home/ec2-user/efs`
após criar o diretorio e necessario montar o EFS atraves do comando:
`sudo mount -t efs <EFS_FILE_SYSTEM_ID>:/ /home/ec2-user/efs`
- <EFS_FILE_SYSTEM_ID> = os primeiros fs-xxxxxxxxx, ate o .efs
apos montar o EFS crie um diretorio para armazenar os logs dentro do efs com o comando:
`sudo mkdir /home/ec2-user/efs/logs`

### Criando um Script
crie um arquivo para criar o script atraves do comando
`vi check.sh`
precione "i" e copie o script feito anteriormente no editor de texto
feche o editor de texto precione "esc" para entrar no modo edicao e digite wq e precione enter.
teste o script executando-o pelo comando
`sudo ~/check.sh`
caso ocorra um erro por falta de permissao execute o comando:
`sudo chmod 777 check.sh`
e tente rodar o script novamente

### Utilizando Contrab para automatizar a execução do Script