# !!!! Atenção - esse projeto esá em fase inicial e não está pronto para produção. !!!!

Objetivo do projeto: Um firewall OPNSense/PFSense poder criar alias atraves de consulta web com o IP da estação de qual um usuario efetuou login para criação de regras.


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


