# !!!! Atenção - esse projeto esá em fase inicial e não está pronto para produção. !!!!

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
- ( mais ideia futuras )

Pré-requisitos:

Para o servidor Microsoft AD: NXLog - https://nxlog.co/downloads/nxlog-ce#nxlog-community-edition

Para o servidor de log:
  - AlmaLinux 10
  - PHP com os módilos php-cli, php-fpm, php-mysqlnd e respectivas dependencias;
  - NGINX
  - MySQL ou MariaDB
  - syslog-ng



Processo de instalação:

Windows:
- Baixe e instale o agente do NXLog no servidor AD;
- Copie o arquivo nxlog.conf para o diretorio "conf" da instalação do agente ( %ProgramFiles%\nxlog\conf );
- Altere o parametro "Host 99.99.99.99" informando o IP do servidor de syslog;
- Reinicie o serviço do NXLog;
- Abra o Group Policy Manager e edite a GPO "Default Domain Controllers Policy" ou crie uma nova GPO e aplique na OU "Domain Controllers"
- Localize e altere os parametros no "Computer Configuration" -> "Policies" -> "Windows Settings" -> "Security Settings" -> "Local Policies" -> "Audit Policy" conforme imagem abaixo e aguarde a replicação da GPO;


<img width="876" height="302" alt="image" src="https://github.com/user-attachments/assets/67fffa91-369a-4356-ba28-24130864b0a0" />


Linux:
- Remova o pacote rsyslog;
- Instale o pacote syslog-ng;
- Crie os diretorios /opt/int_user_login/bin/ e /opt/int_user_login/tmp/;
- Copie os arquivos *int_user_login.sh para o /opt/int_user_login/bin/;
- Execute como root "chown -r root:root /opt/int_user_login";
- Execute como root "chmod 700 /opt/int_user_login/bin/*"
- Copie o arquivo syslog-ng.conf para o /etc/syslog-ng/;
- Ative e reinicie o daemon do syslog-ng;
- Nesse momento o servidor deve começar a criar arquivos no /opt/int_user_login/tmp/ com os dados dos logins efetuados;


