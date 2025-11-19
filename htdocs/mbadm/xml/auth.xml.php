<?php
	require_once('../includes/conf/config.php');
	require_once('../includes/functions/commonFunctions.php');
	require_once('../includes/functions/dbConnect.php');


	header('Content-type: text/xml');

$login = $_POST['login'];
$password = $_POST['credential'];
$auth_success = 0;
$ip = $_SERVER['REMOTE_ADDR'];
$hostname = gethostbyaddr($ip);
$member = null;

if (!empty($login) && !empty($password)) {
	// Create prepared statement
	$stmt = mysqli_prepare($link, "SELECT * FROM USER, USER_LEVEL WHERE USER.id_user_level = USER_LEVEL.id_user_level AND nickname = ?");
	mysqli_stmt_bind_param($stmt, "s", $login);
	
	if (mysqli_stmt_execute($stmt)) {
		$result = mysqli_stmt_get_result($stmt);
		if ($result && $result->num_rows == 1) {
			$member = mysqli_fetch_assoc($result);
			// Verify password
			if (password_verify($password, $member['password'])) {
				$auth_success = 1;
			}
		}
	}
	mysqli_stmt_close($stmt);
}

$html = <<< EOH
<?xml version="1.0" encoding="UTF-8"?>
	<authentication>$auth_success</authentication>

EOH;

	echo ($html);
?>
<?php
	
	
	if ( $auth_success == 1 && $member) {
		//Start session
		session_start();
		
		//Login Successful
		session_regenerate_id();
		$_SESSION['SESS_MEMBER_ID'] = $member['id_user'];
		$_SESSION['SESS_MEMBER_LOGIN'] = $member['nickname'];
		$_SESSION['SESS_MEMBER_LEVEL'] = $member['level'];
		$_SESSION['SESS_MEMBER_DESC'] = _convert($member['description']);
		
		session_write_close();
		$logHostname = gethostbyaddr($_SERVER['REMOTE_ADDR']);
		$connectionLogQuery = "INSERT INTO WEBLOG (login_date,nickname,password,ip,hostname,logresult) VALUES ('" . date("Y-m-d H:i:s") . "','" . $_SESSION['SESS_MEMBER_LOGIN']. "',NULL,'" . $_SERVER['REMOTE_ADDR'] . "','" . $logHostname ."',1)";
		//error_log($connectionLogQuery);
		 $req = mysqli_query($link,$connectionLogQuery);
		 if ( ML_ALERTS_SUCCESS_ENABLED ) {
			 if ( !mail_utf8(ML_ALERTS, "Connexion à l'interface d'administration de " . PORTAL_NAME . " : " . $_SESSION['SESS_MEMBER_LOGIN'] . " (" . $_SERVER['REMOTE_ADDR'] . " - $logHostname ) ","[" . date("d/m/Y H:i:s") . "] L'utilisateur : " . $_SESSION['SESS_MEMBER_LOGIN'] . " s'est connecté depuis l'adresse : " . $_SERVER['REMOTE_ADDR'] . " ( $logHostname )") ) {
				error_log("Could not send connection login mail to " . ML_ALERTS, 0);
			}
		}

	} else if (!empty($login)) { // Log failed attempt
		$logHostname = gethostbyaddr($_SERVER['REMOTE_ADDR']);
		// Do not log the password itself for security reasons
		$connectionLogQuery = "INSERT INTO WEBLOG (login_date,nickname,password,ip,hostname,logresult) VALUES ('" . date("Y-m-d H:i:s") . "','" . $login . "',NULL,'" . $_SERVER['REMOTE_ADDR'] . "','" . $logHostname ."',0)";
		//error_log($connectionLogQuery);
		 $req = mysqli_query($link,$connectionLogQuery);
		 if ( ML_ALERTS_FAIL_ENABLED ) {
			 if ( !mail_utf8(ML_ALERTS, "Tentative de connexion à l'interface d'administration de " . PORTAL_NAME . " : " . $login . " (" . $_SERVER['REMOTE_ADDR'] . " - $logHostname ) ","[" . date("d/m/Y H:i:s") . "] L'utilisateur : " . $login . " a tenté de se connecter depuis l'adresse : " . $_SERVER['REMOTE_ADDR'] . " ( $logHostname )") ) {
				error_log("Could not send connection login mail to " . ML_ALERTS, 0);
			}
		}
	}

?>