-Instalando Apache
primeiro e necesseario instalar o pacote httpd e suas dependencias atraves do comando:
--sudo dnf install httpd
após a instalação e necessario habilitar o serviço
--sudo systemctl enable --now httpd.service
após habilitar cheque o status do serviço
--sudo systemctl status httpd
caso seja necessario abra a porta 80 para o serviço apache
--sudo firewall-cmd --add-service=http --permanent
--sudo firewall-cmd --reload

execute ip a s to check ip and try to connect

-Instalando Oracle Linux em uma VM(Virtual Box)
depois de instalar a VirtualBox clique em novo, de um nome a vm, e selecione a imagem da ISO, escolha um nome de usuario e senha para o SO, selecione a quantidade de RAM e nucleos de processamento, o tamanho do HD e finalize, a virtual box deve ser iniciada. se houver um erro acesse configurações, disco e no primeiro disco re-selecione a ISO

durante a instalação do linux, selecione iniciar instalação, selecione a linguagem, apos isso selecione o disco de instalação, caso haja erro de um refresh, selecione a versão de linux tb(server+gui ou server) ,selecione o disco e clique em done novamente, habilite a insternet, depois escolha uma senha para o root user. depois de criar um usuario root crie e um usuario comum, para fins de uso. e clique em "begin installation"

após completar a insalaçao va na maquina virtual e retire o ISO de disco, configurações, disco, primeiro disco, remover disco, após isso clique no botão de reboot
