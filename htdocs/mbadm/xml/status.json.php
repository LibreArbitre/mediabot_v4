<?php
	require_once('includes/conf/config.php');
	require_once('includes/auth_xml.php');
	require_once('includes/functions/dbConnect.php');
	
	$data = [
		'rows' => []
	];

	$statusQuery = "SELECT * FROM STATUS";
	$statusResult = mysqli_query($link, $statusQuery);

	$row_data = [
		"N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A"
	];

	if ($statusResult && $statusResult->num_rows >= 1) {
		if ($statusFields = mysqli_fetch_assoc($statusResult)) {
			$row_data = [
				htmlspecialchars($statusFields["user"], ENT_QUOTES),
				$statusFields["pid"],
				$statusFields["ppid"],
				$statusFields["c"],
				htmlspecialchars($statusFields["stime"], ENT_QUOTES),
				htmlspecialchars($statusFields["tty"], ENT_QUOTES),
				htmlspecialchars($statusFields["time"], ENT_QUOTES),
				htmlspecialchars($statusFields["cmd"], ENT_QUOTES),
			];
		}
	}

	$data['rows'][] = [
		'id' => 1,
		'data' => $row_data
	];

	header('Content-type: application/json');
	echo json_encode($data);
?>
