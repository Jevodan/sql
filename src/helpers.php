<?php
require_once 'pdo.php';
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);


function getDates()
{
    $stmt = getPDO()->prepare("SELECT * FROM get_list_data()");
    $stmt->execute();
    $values = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
    return $values;
}

function getObjects()
{
    $stmt = getPDO()->prepare("SELECT * FROM get_list_object()");
    $stmt->execute();
    $values = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
    return $values;
}

function getWorks()
{
    $stmt = getPDO()->prepare("SELECT * FROM get_list_types()");
    $stmt->execute();
    $values = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
    return $values;
}

function getAccumulateData($startDate, $endDate, $object, $workType)
{
    $pdo = getPDO();
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $pdo->prepare("SELECT * FROM get_cumulative_work_data(:start_date, :end_date, :object, :work_type)");
    $stmt->execute([
        ':start_date' => $startDate,
        ':end_date' => $endDate,
        ':object' => $object,
        ':work_type' => $workType
    ]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function getNotAccumulateData($startDate, $endDate, $object, $workType)
{
    $pdo = getPDO();
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $stmt = $pdo->prepare("SELECT * FROM get_not_cumulative_work_data(:start_date, :end_date, :object, :work_type)");
    $stmt->execute([
        ':start_date' => $startDate,
        ':end_date' => $endDate,
        ':object' => $object,
        ':work_type' => $workType
    ]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}
