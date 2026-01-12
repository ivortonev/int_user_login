# !!!! Atenção - esse projeto esá em fase inicial !!!
# Use com cuidado.



Pré-requisitos:

Para o servidor Microsoft AD: NXLog - https://nxlog.co/downloads/nxlog-ce#nxlog-community-edition

Para o servidor de log:
  - AlmaLinux 10
  - PHP com os módilos php-cli, php-fpm, php-mysqlnd e respectivas dependencias;
  - NGINX
  - MySQL ou MariaDB
  - syslog-ng



Objetivo do projeto: Um firewall OPNSense/PFSense poder criar alias atraves de consulta web com o IP da estação de qual um usuario efetuou login para criação de regras.



Fluxo simplificado:
- Ususário loga no Active Directory;
- O agente do nxlog captura o evento e envia em formato JSON via syslog para um servidor Linux;
- O servidor Linux recebe o log e o salva em arquivo individual;
- Através de agendamento no CRON um script em BASH analisa arquivo por arquivo e extrai as informações de login e IP da maquina onde o usuário efetuou o login e salva em outro arquivo temporario;
- No final do processamento os registros de login:ip são filtrados para valores únicos;
- No final do script BASH é executado um script PHP para leitura dos valores únicos de login:ip para inserção em banco de dados, adicionando um valor extra de tempo de expiração da sessão;
  - Caso existir registro de sessão com o mesmo login e ip, a expiração é atualizada;
  - Caso não existir registro, o mesmo é criado, permitindo vários IPs de origem para um usuario;
- Através de agendamento no CRON é executado um script em PHP que exclui todas as sessões expiradas.
- O firewall consulta atraves da URL https://[servidor/user.php?login=[usuario] a lista de IPs com sessões validas e armazena o valor em um ALIAS que é usado para criação das regras;
- Se não existir uma sessão válida registrada no banco de dados, é retornado o ip 99.99.99.99.


  
TO-DO
- Criação de tabela de log para consultas futuras dos IPs a partir de quais um usuário logou, como inicio e fim de sessão;
- Limpeza do codigo. No momento foi feito para prover a funcionalidade, sem preocupação com boas praticas de desenvolvimento;
- Criar script para instalação;
- ( mais ideia futuras )




Windows:
- Baixe e instale o agente do NXLog no servidor AD;
- Copie o arquivo nxlog.conf para o diretorio "conf" da instalação do agente ( %ProgramFiles%\nxlog\conf );
- Altere o parametro "Host 99.99.99.99" informando o IP do servidor de syslog;
- Reinicie o serviço do NXLog;
- Abra o Group Policy Manager e edite a GPO "Default Domain Controllers Policy" ou crie uma nova GPO e aplique na OU "Domain Controllers"
- Localize e altere os parametros no "Computer Configuration" -> "Policies" -> "Windows Settings" -> "Security Settings" -> "Local Policies" -> "Audit Policy" conforme imagem abaixo e aguarde a replicação da GPO;



<img width="876" height="302" alt="image" src="https://github.com/user-attachments/assets/67fffa91-369a-4356-ba28-24130864b0a0" />



Linux:
- Execute como root "curl https://raw.githubusercontent.com/ivortonev/int_user_login/refs/heads/main/install.sh | bash";



Para testar:
- Baixe os dois arquivos que estão no "example_log" para o diretório "/opt/int_user_login/tmp";
- Aguarde a proxima execução do CRON;
- Execute "http://localhost/user.php?login=Administrator". A saida deve ser
<img width="470" height="86" alt="curl_test" src="https://github.com/user-attachments/assets/7883d472-5943-43e9-8c7f-11372bbf60e5" />


No firewall é necessário criar alias com o Login do usuário e apontar para o serviço HTTP do servidor de log
<img width="638" height="439" alt="user_alias" src="https://github.com/user-attachments/assets/e11ee8de-2e68-4fc6-b2ef-a76b619d38b0" />


