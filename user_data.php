<?php

require_once './conf.php';

$nomeArquivo=$argv[1];

$handle = fopen($nomeArquivo, "r");

$expire_time = time() + ($session_time * 3600);
$run_time = time();

if ($handle) {
	while (($linha = fgets($handle)) !== false) {
		$linha = trim($linha);
        
		if (empty($linha)) continue;

		$dados = explode(':', $linha);

		if (count($dados) == 2) {
			$user_login = $dados[0];
			$source_ip_login = $dados[1];

		} else {
			echo "Invalid Line: $linha\n";
		}

		// Select para verificar se ja existe o registro e ainda esta valido
		$sql_verifica_registro = "SELECT login, source_ip, expire_time from login where login = '$user_login' and source_ip = '$source_ip_login' and expire_time > '$run_time';";
		//echo "Verificando se o registro do usuario existe e se ainda e valido: $user_login : $source_ip_login\n";
		$result_verifica_registro = $conn->query($sql_verifica_registro);

		// Se o registro existiri e for o mesmo IP, so atualiza a expiracao para o tempo definido de sessao 
		if ($result_verifica_registro->num_rows > 0) {
			$sql_atualiza_registro = "UPDATE login set time = '$run_time', login = '$user_login', source_ip = '$source_ip_login', expire_time = '$expire_time' where login = '$user_login' and source_ip = '$source_ip_login' and expire_time > '$run_time';";
			//echo "Registro para o IP ja existe. Atualizando o campo de expiracao: $user_login : $source_ip_login\n";
			$result_atualiza_registro = $conn->query($sql_atualiza_registro);

		// Se o registro nao existir, verifica se existe registro para o login e cria a entrada
		} else {
			// Verifica se existe entrada pra o usuario
			$sql_verifica_usuario = "SELECT login, source_ip from login where login = '$user_login' and source_ip = '99.99.99.99';";
			//echo "Verificando se o registro do usuario existe e aponta para o IP invalido: $user_login : $source_ip_login\n";
			$result_verifica_usuario = $conn->query($sql_verifica_usuario);

			if ($result_verifica_usuario->num_rows > 0) {
				// O registro do usuario existe. Atualizando o IP para o IP da estacao de login e o expire_time
				//echo "O registro do usuario existe, atualizando o IP e o expire_time: $user_login : $source_ip_login\n";
				$sql_atualiza_registro = "UPDATE login set time = '$run_time', login = '$user_login', source_ip = '$source_ip_login', expire_time = '$expire_time' where login = '$user_login' and source_ip = '99.99.99.99';";
				$result_atualiza_registro = $conn->query($sql_atualiza_registro);

			}
		} 
				
		// Criando registro para o uduario com o IP da estacao de login
		if ($result_verifica_registro->num_rows == 0) {
			$sql_cria_registro = "INSERT INTO login (`time`, `login`, `source_ip`, `expire_time`) VALUES ('$run_time', '$user_login', '$source_ip_login', '$expire_time');";
			//echo "O registro do usuario nao existe, criando: $user_login : source_ip_login\n";
			$result_cria_registro = $conn->query($sql_cria_registro);
		}
				
	}

	fclose($handle);

	} else {
		 echo "Error: unable to open file $nomeArquivo.\n";
}

$conn->close();

?>

