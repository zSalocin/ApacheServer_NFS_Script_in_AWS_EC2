Instalando o Oracle Linux em uma VM (VirtualBox):
Após instalar o VirtualBox, clique em "Novo" para criar uma nova máquina virtual (VM). Dê um nome para a VM e selecione o sistema operacional que será instalado. Escolha um nome de usuário e senha para o sistema operacional. Selecione a quantidade de RAM e o número de núcleos de processamento desejados, bem como o tamanho do disco rígido. Finalize a criação da VM.

Acesse as configurações da VM, vá para a seção de discos e selecione a imagem ISO para o primeiro disco. Em seguida, inicie a máquina virtual.

Durante a instalação do Oracle Linux, selecione "start installation" e escolha o idioma desejado. Em seguida, selecione o disco de instalação. Caso ocorra algum erro, faça um refresh. Selecione a versão do Oracle Linux (com GUI, versão do servidor, ou mínima). Habilite a conexão com a internet e defina uma senha para o usuário root. Crie também um usuário comum para uso geral. Por fim, clique em "Begin".

Após a conclusão da instalação, remova a imagem ISO da VM. Acesse as configurações da VM, vá para a seção de discos e remova o primeiro disco. Em seguida, clique no botão de reiniciar ("Reboot").

-Instalando Apache
primeiro e necesseario instalar o pacote httpd e suas dependencias atraves do comando:

sudo dnf install httpd

após a instalação e necessario habilitar o serviço

sudo systemctl enable --now httpd.service

após habilitar cheque o status do serviço

sudo systemctl status httpd

Execute o comando abaixo para verificar o IP e tente-se conectar ao servidor Apache

ip a s

caso seja necessario abra a porta 80 para o serviço apache

sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --reload

-Criando o Scrit
No Terminal do linux crie um script com o editor de texto com o seguinte comando:

vi checkapache.sh

o editor de texto vi ira criar um arquivo .sh e abrir para edição, copie ou cole o script registrado no arquivo Script.md nesse diretorio, esse script ira verificar o status do apache e criar um arquivo de log por dia para as verificações.

-Criando uma VPC
Ao criar um VPC selecione o serviço de VPC, Criar VPC, e use o assistente para criar a VPC, Sub-nets, tabelas de roteamento e gateways de forma auomatica.

-Criando um SecurityGroup
Em EC2 procure por SecurityGroup na barra de navegação a esquerda, acesse, crie um novo security group de acordo com as portas requeridas no caso: 22/TCP, 111/TCP/UDP, 2049/TCP/UDP, 80/TCP, 443/TCP. Utilize a VPC padrão caso não haja uma VPC especifica.

-Criando uma instancia EC2 na AWS
No console procure pelo serviço de EC2 e clique para acessar.
clique em criar uma instancia ou executar uma instancia para criar uma instancia, em tags adicione as tags necessarios caso haja alguma.

Na imagem do sistema escolha Amazon Linux 2, no tipo de instancia selecione a instancia desejada (no caso t3.small), crie um par de chave para ssh ou putty (cuidado ao criar o par de chave pois ele é unico e não recuperavel)

em configuração de rede selecione, selecionar grupo de segurança existente e selecione o grupo de segurança criado anteriormente, após isso na aba configurar armazenamento escolha o tipo de disco e o tamanho do disco(no caso 16GB). e execute a instancia, ira levar alguns segundos para a AWS inicializar a instancia.

-Criando um Elastic IP
Em EC2 procure no menu a esquerda Elastic IP, após isso clique em alocar endereço IP elástico, verifique se a região está correta e ipv4 está selecionado, e clique em alocar, após isso clique sobre o endereço IP, clique em ações selecione Associar endereço IP elástico, marque instancia e selecione a instancia criada previamente após isso clique em associar

-Acessando a instancia via putty
TODO

-Instalando Apache em uma intancia EC2
Após logar na instancia execute o comando:
sudo su
depois disso execute o comando:
sudo yum install -y httpd
para instalar o apache server e suas dependencias. executando depois disso o comando:
sudo systemctl enable --now httpd.service
para iniciar o apache server, após esse comando execute:
sudo systemctl status httpd
para verificar o status do apache server, se o servidor estiver rodando corretamente agora deve ser possivel acessar a pagina de teste do apache atraves do ip elastico anexado a instancia.

-Criando um EFS(NSF SERVER)
na aba de buscar da AWS busque por EFS o serviço de arquivos de NFS escalavel da AWS, na pagina do EFS clique em criar sistema de arquivos, de um nome ao EFS e selecione uma VPC(a mesma da instancia) e clique em criar, após criado va em network dentro dos detalhes do EFS e altere os security group para o mesmo da instancia EC2

-Criando uma pasta compartilhada EFS EC2
acesse a instancia, e digite o comando:
sudo yum install -y amazon-efs-utils
para instalar as dependencias necessarias para acessar o efs na instancia do EC2, após a instalação crie um diretorio para compartilhar entre a instancia EC2 e o EFS atraves do comando:
sudo mkdir /home/ec2-user/efs
após criar o diretorio e necessario montar o EFS atraves do comando:
sudo mount -t efs <EFS_FILE_SYSTEM_ID>:/ /home/ec2-user/efs
<EFS_FILE_SYSTEM_ID> = os primeiros fs-xxxxxxxxx, ate o .efs
apos montar o EFS crie um diretorio para armazenar os logs dentro do efs com o comando:
sudo mkdir /home/ec2-user/efs/logs

-Criando um Script
crie um arquivo para criar o script atraves do comando
vi check.sh
precione "i" e copie o script feito anteriormente no editor de texto
feche o editor de texto precione "esc" para entrar no modo edicao e digite wq e precione enter.
teste o script exeutando-o pelo comando
~/check.sh
caso ocorra um erro por falta de permissao execute o comando:
chmod 777 check.sh
e tente rodar o script novamente